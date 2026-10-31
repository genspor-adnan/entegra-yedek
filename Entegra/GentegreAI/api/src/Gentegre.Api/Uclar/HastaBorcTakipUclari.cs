using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HASTA BORÇ TAKİBİ (mockup Ekranlar/İcmal/hasta_borc_takibi.html, kullanıcı
/// 10.10.2026: "hasta borç takibini kodla").
///
/// Açık borcu olan hastalar (borç HastaBorcSorgusu'ndan - hasta icmali ve alacak
/// yaşlandırmayla aynı kural) ve onlar için yapılan işler (hasta_borc_islem,
/// 1020): toplu SMS / e-posta hatırlatma (bildirim kuyruğu, şablon
/// borc.hatirlatma), ödeme sözü / planı, tahsilata çağır işareti, not.
///
/// Söz / planın tutulup tutulmadığı SAKLANMAZ: vadesi geçmiş ve borç hâlâ
/// açıksa "tutulmadı". Aynı hastaya aynı kanaldan 24 saat içinde ikinci
/// hatırlatma konmaz - toplu düğmeye iki kez basmak hastaya iki SMS demekti.
/// </summary>
public static class HastaBorcTakipUclari
{
    private const string Kod = "hasta.borc_takip";
    /// <summary>bildirim.kaynak_tur - hasta borç takibi (40-47 dolu).</summary>
    private const short KaynakBorc = 48;

    private const short TurHatirlatma = 1, TurSoz = 2, TurPlan = 3, TurIsaret = 4, TurNot = 5;

    public sealed record HatirlatIstegi(int[] HastaIds, short Kanal);
    public sealed record SozIstegi(int HastaId, short Tur, decimal Tutar, DateTime Vade, short? TaksitSayisi, string? Aciklama);
    public sealed record IsaretIstegi(int[] HastaIds, string? Aciklama);
    public sealed record NotIstegi(int HastaId, string Aciklama);

    private sealed record BorcIslemi(int Id, int HastaId, short Tur, short? Kanal, long? BildirimId, short? BildirimDurum,
                                decimal? Tutar, DateTime? Vade, short? TaksitSayisi, string Aciklama, short Durum,
                                DateTime Zaman, string Ekleyen);

    public static void HastaBorcTakipUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/hasta-borc").WithTags("Hasta Borç Takibi").RequireAuthorization();

        // ------------------------------------------------------- borçlular --
        grup.MapGet("/", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var bugun = Saat.Bugun;
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var basvurular = await HastaBorcSorgusu.BasvurularAsync(b, bugun.AddDays(1), sube, null, iptal);
            var acik = basvurular.Where(x => x.Kalan > 0.005m).ToList();
            var idler = acik.Select(x => x.HastaId).Distinct().ToArray();

            var kisiler = (await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), coalesce(t.kod, ''),
                       coalesce(t.cep_tel, ''), coalesce(t.eposta, '')
                  from public.taraf t where t.id = any(@p0)
                """, null, [idler], o => (id: o.GetInt32(0), ad: o.GetString(1), dosyaNo: o.GetString(2),
                    tel: o.GetString(3), eposta: o.GetString(4)), iptal)).ToDictionary(x => x.id);
            var islemler = await IslemlerAsync(b, idler, 0, iptal);

            // Bu ay başvurulara yapılan tahsilat (yalnız takipteki borçlu hastalar).
            var ayBasi = new DateTime(bugun.Year, bugun.Month, 1);
            var buAyTahsil = await b.TekDegerAsync<decimal?>("""
                select coalesce(sum(case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end), 0)
                  from public.kasa_islem ki
                  join public.kasa_islem_turu kt on kt.kod = ki.tur
                  join public.belge be on be.id = ki.belge_id and be.tipi = 30 and be.tur = 19
                  join public.belge_basvuru bb on bb.id = be.id
                 where ki.durum <> 9 and ki.islem_tarihi >= @p0
                   and coalesce(bb.hasta_id, be.taraf_id) = any(@p1)
                """, null, [ayBasi, idler], iptal) ?? 0m;

            var borclular = acik.GroupBy(x => x.HastaId).Select(g =>
            {
                kisiler.TryGetValue(g.Key, out var k);
                var borc = g.Sum(x => x.Kalan);
                var hi = islemler.Where(i => i.HastaId == g.Key && i.Durum == 0).ToList();
                var sonHatirlatma = hi.Where(i => i.Tur == TurHatirlatma).MaxBy(i => i.Zaman);
                var soz = hi.Where(i => i.Tur is TurSoz or TurPlan).MaxBy(i => i.Zaman);
                var isaret = hi.Where(i => i.Tur == TurIsaret).MaxBy(i => i.Zaman);
                // Söz tutuldu mu: vadesi geçti ve borç hâlâ açık -> tutulmadı.
                var sozDurum = soz is null ? "" : soz.Vade < bugun ? "tutulmadi" : "bekliyor";
                var durum = isaret is not null ? "tahsilata"
                          : sozDurum == "tutulmadi" ? "soz_tutulmadi"
                          : soz is not null ? (soz.Tur == TurPlan ? "planli" : "soz")
                          : sonHatirlatma is not null && (bugun - sonHatirlatma.Zaman.Date).TotalDays <= 7 ? "hatirlatildi"
                          : "yeni";
                var enEski = g.Min(x => x.Tarih);
                return new
                {
                    id = g.Key, ad = k.ad ?? "", dosyaNo = k.dosyaNo ?? "",
                    telefon = Maskele(k.tel ?? ""), telefonVar = !string.IsNullOrWhiteSpace(k.tel),
                    epostaVar = !string.IsNullOrWhiteSpace(k.eposta),
                    borc, acikProtokol = g.Count(), gun = (int)(bugun - enEski.Date).TotalDays,
                    sonBasvuru = g.Max(x => x.Tarih),
                    sonTahsilat = basvurular.Where(x => x.HastaId == g.Key).Select(x => x.SonTahsilat).Max(),
                    sonHatirlatma = sonHatirlatma?.Zaman, sonHatirlatmaKanal = sonHatirlatma?.Kanal,
                    soz = soz is null ? null : new { soz.Id, tur = soz.Tur, soz.Tutar, soz.Vade, soz.TaksitSayisi, durum = sozDurum },
                    isaretId = isaret?.Id,
                    durum,
                    protokoller = g.OrderBy(x => x.Tarih).Select(x => new
                    {
                        x.BelgeId, x.ProtokolNo, tarih = x.Tarih, x.Bolum, hastaPayi = x.Toplam - x.KurumPayi,
                        x.Tahsil, x.Kalan, gun = (int)(bugun - x.Tarih.Date).TotalDays,
                    }),
                };
            }).OrderByDescending(x => x.borc).ToList();

            var ozet = new
            {
                borclu = borclular.Count,
                toplam = borclular.Sum(x => x.borc),
                gun30 = borclular.Where(x => x.gun > 30).Sum(x => x.borc),
                gun30Hasta = borclular.Count(x => x.gun > 30),
                hatirlatmaBekleyen = borclular.Count(x => x.durum == "yeni"),
                buAyTahsil,
                sozTutar = borclular.Where(x => x.soz is not null && x.soz.tur == TurSoz && x.soz.durum == "bekliyor").Sum(x => x.soz!.Tutar ?? 0),
                planTutar = borclular.Where(x => x.soz is not null && x.soz.tur == TurPlan && x.soz.durum == "bekliyor").Sum(x => x.soz!.Tutar ?? 0),
                tutulmayan = borclular.Count(x => x.durum == "soz_tutulmadi"),
                tahsilata = borclular.Count(x => x.durum == "tahsilata"),
            };
            return Results.Ok(new { tarih = bugun, ozet, borclular });
        });

        // --------------------------------------------------------- geçmiş --
        grup.MapGet("/gecmis", async (int? hastaId, VeriKaynagi veri, BaglamCozucu cozucu,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await IslemlerAsync(b, hastaId is > 0 ? [hastaId.Value] : [], 300, iptal);
            var adlar = (await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '')
                  from public.taraf t where t.id = any(@p0)
                """, null, [liste.Select(x => x.HastaId).Distinct().ToArray()],
                o => (id: o.GetInt32(0), ad: o.GetString(1)), iptal)).ToDictionary(x => x.id, x => x.ad);
            return Results.Ok(new
            {
                islemler = liste.Select(i => new
                {
                    i.Id, i.HastaId, hasta = adlar.GetValueOrDefault(i.HastaId, ""), i.Tur, i.Kanal,
                    i.BildirimId, i.BildirimDurum, i.Tutar, i.Vade, i.TaksitSayisi, i.Aciklama, i.Durum,
                    zaman = i.Zaman, i.Ekleyen,
                }),
            });
        });

        // ------------------------------------------------------- hatırlat --
        grup.MapPost("/hatirlat", async (HatirlatIstegi istek, VeriKaynagi veri, BildirimDeposu bildirim,
                                         BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Ekle);
            if (istek.Kanal is not (1 or 2)) throw GentegreHatasi.Dogrulama("Kanal SMS (1) ya da e-posta (2) olmalı.");
            var ids = (istek.HastaIds ?? []).Where(x => x > 0).Distinct().ToArray();
            if (ids.Length == 0) throw GentegreHatasi.Dogrulama("Hasta seçilmedi.");
            if (ids.Length > 500) throw GentegreHatasi.Dogrulama("Tek seferde en çok 500 hastaya hatırlatma gönderilir.");
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var borc = (await HastaBorcSorgusu.BasvurularAsync(b, Saat.Bugun.AddDays(1), sube, ids, iptal))
                .Where(x => x.Kalan > 0.005m).GroupBy(x => x.HastaId).ToDictionary(g => g.Key, g => g.Sum(x => x.Kalan));
            var kisiler = await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(t.cep_tel, ''), coalesce(t.eposta, ''),
                       exists (select 1 from public.hasta_borc_islem i
                                where i.hasta_id = t.id and i.tur = 1 and i.kanal = @p1 and i.durum = 0
                                  and i.ekleme_tarihi > now() - interval '24 hours')
                  from public.taraf t where t.id = any(@p0)
                """, null, [ids, istek.Kanal], o => (id: o.GetInt32(0), ad: o.GetString(1), tel: o.GetString(2),
                    eposta: o.GetString(3), yakin: o.GetBoolean(4)), iptal);
            var kurum = await b.TekAsync("""
                select coalesce(nullif(s.unvan, ''), s.ad, ''), coalesce(nullif(s.telefon, ''), s.gsm, '')
                  from public.sube s where s.id = @p0
                """, null, [sube], o => new { ad = o.GetString(0), tel = o.GetString(1) }, iptal);

            var atlanan = new List<object>();
            var konan = 0;
            // TEK İŞLEM (kod inceleme 30.10.2026 K52): bildirim kuyruğu + borç işlemi birlikte yazılır; işlem
            //   satırı düşerse SMS kuyrukta yetim kalmaz, 24 saat kuralı atlanmaz.
            await using var islem = await b.BeginTransactionAsync(iptal);
            foreach (var k in kisiler)
            {
                if (!borc.TryGetValue(k.id, out var tutar)) { atlanan.Add(new { k.ad, neden = "açık borcu yok" }); continue; }
                var alici = istek.Kanal == 1 ? k.tel : k.eposta;
                if (string.IsNullOrWhiteSpace(alici))
                { atlanan.Add(new { k.ad, neden = istek.Kanal == 1 ? "cep telefonu yok" : "e-posta yok" }); continue; }
                if (k.yakin) { atlanan.Add(new { k.ad, neden = "son 24 saatte bu kanaldan hatırlatıldı" }); continue; }

                var bildirimId = await bildirim.KuyrugaEkleAsync(b, islem, new BildirimIstegi(
                        SablonKodu: istek.Kanal == 1 ? "borc.hatirlatma" : "borc.hatirlatma.eposta",
                        Kanal: (BildirimKanali)istek.Kanal,
                        Alici: alici,
                        Degiskenler: new Dictionary<string, string>
                        {
                            ["hasta_ad"] = k.ad,
                            ["tutar"] = tutar.ToString("N2", new System.Globalization.CultureInfo("tr-TR")),
                            ["kurum"] = kurum?.ad ?? "",
                            ["telefon"] = kurum?.tel ?? "",
                        },
                        TarafId: k.id, KaynakTur: KaynakBorc, KaynakId: k.id, Oncelik: 7),
                    baglam.KullaniciId, baglam.SubeId, iptal);
                if (bildirimId is null) { atlanan.Add(new { k.ad, neden = "hatırlatma şablonu pasif" }); continue; }
                await IslemYazAsync(b, k.id, TurHatirlatma, istek.Kanal, bildirimId, tutar, null, null, "", baglam, iptal, islem);
                konan++;
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { kuyruga = konan, atlanan });
        });

        // ------------------------------------------------ söz / plan / işaret --
        // KAYIT KAPSAMI (kod inceleme 30.10.2026 K26): hasta kimliği GÖVDEDEN gelir (soz / isaret / not) -
        //   kapsam dışı hastaya söz / işaret / not yazılamaz; olmayan hastayla aynı 404.
        grup.MapPost("/soz", async (SozIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, KayitErisimi erisim,
                                    HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Ekle);
            if (istek.Tur is not (TurSoz or TurPlan)) throw GentegreHatasi.Dogrulama("Tür ödeme sözü (2) ya da plan (3) olmalı.");
            if (istek.Tutar <= 0) throw GentegreHatasi.Dogrulama("Tutar sıfırdan büyük olmalı.");
            if (istek.Vade.Date < Saat.Bugun) throw GentegreHatasi.Dogrulama("Vade bugünden önce olamaz.");
            if (istek.Tur == TurPlan && istek.TaksitSayisi is not (>= 2 and <= 36))
                throw GentegreHatasi.Dogrulama("Ödeme planı 2 ile 36 taksit arasında olmalı.");
            await erisim.IsteAsync(baglam, "hasta", istek.HastaId, "Hasta bulunamadı.", iptal);
            await using var b = await veri.AcAsync(iptal);
            // TEK İŞLEM + HASTA KİLİDİ (K36): eski sözün kapanışı ve yeni söz birlikte - araya düşen istek hastayı
            //   sözsüz bırakmasın; aynı hastaya eşzamanlı iki söz danışma kilidiyle sıraya girer (ikisi de "açık"
            //   kalamaz).
            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("select pg_advisory_xact_lock(@p0, @p1)", islem, [(int)KaynakBorc, istek.HastaId], iptal);
            // Yeni söz / plan eskisinin yerine geçer: aynı anda iki söz takip edilmez.
            await b.CalistirAsync("""
                update public.hasta_borc_islem set durum = 9, degistiren = @p1, degistirme_tarihi = now()
                 where hasta_id = @p0 and tur in (2, 3) and durum = 0
                """, islem, [istek.HastaId, baglam.KullaniciId], iptal);
            var id = await IslemYazAsync(b, istek.HastaId, istek.Tur, null, null, istek.Tutar, istek.Vade.Date,
                                         istek.Tur == TurPlan ? istek.TaksitSayisi : null, istek.Aciklama ?? "", baglam, iptal, islem);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        grup.MapPost("/isaret", async (IsaretIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, KayitErisimi erisim,
                                       HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Ekle);
            var ids = (istek.HastaIds ?? []).Where(x => x > 0).Distinct().ToArray();
            if (ids.Length == 0) throw GentegreHatasi.Dogrulama("Hasta seçilmedi.");
            // Kapsam (K26): listedeki her hasta - biri dışarıdaysa hiçbiri işaretlenmez (toplu istek bütündür).
            foreach (var h in ids)
                await erisim.IsteAsync(baglam, "hasta", h, "Hasta bulunamadı.", iptal);
            await using var b = await veri.AcAsync(iptal);
            // TEK İŞLEM (K36): toplu işaret bütündür - yarıda kalan istek listenin yarısını işaretli bırakmaz.
            //   "Var mı?" + ekle, hasta başına danışma kilidi altında: eşzamanlı iki toplu istek aynı hastaya
            //   iki açık işaret koyamaz.
            await using var islem = await b.BeginTransactionAsync(iptal);
            var konan = 0;
            foreach (var h in ids)
            {
                await b.CalistirAsync("select pg_advisory_xact_lock(@p0, @p1)", islem, [(int)KaynakBorc, h], iptal);
                var var_ = await b.TekDegerAsync<bool>("""
                    select exists (select 1 from public.hasta_borc_islem where hasta_id = @p0 and tur = 4 and durum = 0)
                    """, islem, [h], iptal);
                if (var_) continue;
                await IslemYazAsync(b, h, TurIsaret, null, null, null, null, null, istek.Aciklama ?? "", baglam, iptal, islem);
                konan++;
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { isaretlenen = konan });
        });

        grup.MapPost("/not", async (NotIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, KayitErisimi erisim,
                                    HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Ekle);
            if (string.IsNullOrWhiteSpace(istek.Aciklama)) throw GentegreHatasi.Dogrulama("Not boş olamaz.");
            await erisim.IsteAsync(baglam, "hasta", istek.HastaId, "Hasta bulunamadı.", iptal);
            await using var b = await veri.AcAsync(iptal);
            var id = await IslemYazAsync(b, istek.HastaId, TurNot, null, null, null, null, null, istek.Aciklama.Trim(), baglam, iptal);
            return Results.Ok(new { id });
        });

        // Söz / plan / işaret / not kaldırılır (silinmez - geçmişte iptal görünür).
        grup.MapPost("/islem/{id:int}/kaldir", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
                                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.hasta_borc_islem set durum = 9, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and tur <> 1 and durum = 0
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Kayıt bulunamadı ya da kaldırılamaz (gönderilmiş hatırlatma geri alınmaz).");
            return Results.Ok(new { kaldirildi = true });
        });
    }

    private static Task<List<BorcIslemi>> IslemlerAsync(NpgsqlConnection b, int[] hastalar, int limit, CancellationToken iptal)
        => b.ListeAsync("""
            select i.id, i.hasta_id, i.tur, i.kanal, i.bildirim_id, bl.durum, i.tutar, i.vade, i.taksit_sayisi,
                   i.aciklama, i.durum, i.ekleme_tarihi,
                   -- ekleyen = kullanıcının taraf kimliği
                   coalesce((select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)
                               from public.taraf t where t.id = i.ekleyen), '')
              from public.hasta_borc_islem i
              left join public.bildirim bl on bl.id = i.bildirim_id
             where cardinality(@p0::int[]) = 0 or i.hasta_id = any(@p0::int[])
             order by i.ekleme_tarihi desc, i.id desc
             limit case when @p1 > 0 then @p1 else 100000 end
            """, null, [hastalar, limit], o => new BorcIslemi(
                o.GetInt32(0), o.GetInt32(1), o.GetInt16(2), o.IsDBNull(3) ? null : o.GetInt16(3),
                o.IsDBNull(4) ? null : o.GetInt64(4), o.IsDBNull(5) ? null : o.GetInt16(5),
                o.IsDBNull(6) ? null : o.GetDecimal(6), o.IsDBNull(7) ? null : o.GetDateTime(7),
                o.IsDBNull(8) ? null : o.GetInt16(8), o.GetString(9), o.GetInt16(10), o.GetDateTime(11),
                o.GetString(12)), iptal);

    private static Task<int> IslemYazAsync(NpgsqlConnection b, int hastaId, short tur, short? kanal, long? bildirimId,
        decimal? tutar, DateTime? vade, short? taksit, string aciklama, IstekBaglami baglam, CancellationToken iptal,
        NpgsqlTransaction? islem = null)
        => b.TekDegerAsync<int>("""
            insert into public.hasta_borc_islem (hasta_id, tur, kanal, bildirim_id, tutar, vade, taksit_sayisi,
                                                 aciklama, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
            returning id
            """, islem, [hastaId, tur, kanal, bildirimId, tutar, vade, taksit,
                        aciklama.Length > 500 ? aciklama[..500] : aciklama, baglam.SubeId, baglam.KullaniciId], iptal);

    /// <summary>"0555 *** ** 89": son iki hane - görevli doğru kişiyi arıyor mu anlasın.</summary>
    private static string Maskele(string tel)
    {
        var r = new string(tel.Where(char.IsDigit).ToArray());
        // Ülke kodu (90 / 0090) yerel biçime: "905551234567" -> "05551234567".
        if (r.StartsWith("0090")) r = "0" + r[4..];
        else if (r.StartsWith("90") && r.Length == 12) r = "0" + r[2..];
        else if (r.Length == 10 && r[0] == '5') r = "0" + r;   // "5321234567"
        return r.Length < 4 ? "" : $"{r[..Math.Min(4, r.Length - 2)]} *** ** {r[^2..]}";
    }
}
