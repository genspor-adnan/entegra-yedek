using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DEVİR / AÇILIŞ BAKİYESİ - TEK UÇ (mockup Ekranlar/devir_girisi.html, kullanıcı 24.10.2026:
/// "jenerik devir girişi mockup'ı kodla"; cari için 1156'nın genelleştirilmişi).
///
/// <para>Neden tek: cari devri mali_hareket tür 2 satırıydı (1156), kasa / banka / POS / kredi
/// devri ise karttaki <c>hesap.acilis_bakiye</c> - ve o alanı hiçbir bakiye okumuyordu
/// (v_hesap_bakiye, Ekstre devri, gün sonu yalnız hareket toplar). Artık HER tür için tür 2
/// "Devir" satırı: cari'de taraf_id + hesap_turu 'C', hesapta hesap_turu + hesap_id. Ekstre
/// (1158), hesap bakiyesi, gün sonu, banka sistem bakiyesi (1157), cari icmali (1154) devri
/// değişiklik gerektirmeden görür. Karttaki açılış alanları <see cref="AcilisCevir"/> ile bir
/// kez devir satırına çevrilir.</para>
///
/// <para>Satır biçimi türden bağımsız (tutar · para · kur · vade · belge no · açıklama); türe
/// özgü giriş (POS gün satırı, kredi ana para, kredi kartı dönem borcu) ekranda satırlara
/// çevrilir. Hesap satırının para birimi hesabın para birimi olmak ZORUNDA (hesap kuralı).
/// İşaret: cari + borçlu / - alacaklı; hesapta + giriş (borc) / - çıkış (alacak).</para>
///
/// <para>Kurallar (1156): bir hesaba tek devir (yeniden kaydetmek web devrini baştan yazar,
/// Delphi aktarımının satırlarına dokunulmaz); veri kaynağı Delphi olan kurumda kapalı;
/// devir tarihi ilk hareketten sonraysa onay (zorla); işlem günlüğü 1610 (kayıt = hesap / cari,
/// anahtar türle). Yetki iki katlı: ekran <c>finans.devir</c> (1160, eski finans.cari_devir),
/// veri türün kodu (Ekstre kuralı). Eski /api/cari/{id}/devir uçları takma ad olarak kalır.</para>
/// </summary>
public static class DevirUclari
{
    private const string Kod = "finans.devir";
    private const int LogDevir = 1610;
    private const short TurDevir = 2;

    /// <summary>tür anahtarı → (hesap.tur harfi, veri yetki kodu, kart yolu).</summary>
    private static readonly (string tur, string harf, string yetki)[] Turler =
    [
        ("cari", "C", "mali_hareket"), ("kasa", "K", "hesap.tanim"), ("banka", "B", "hesap.tanim.banka"),
        ("pos", "P", "hesap.tanim.pos"), ("kredi", "R", "hesap.tanim.kredi"), ("kredikarti", "V", "hesap.tanim.kredi_karti"),
    ];

    public sealed class DevirSatiri
    {
        public string? BelgeNo { get; set; }
        public DateTime? BelgeTarihi { get; set; }
        public DateTime? Vade { get; set; }
        /// <summary>İşaretli: cari + borçlu / - alacaklı; hesap + giriş / - çıkış.</summary>
        public decimal Tutar { get; set; }
        public string? Doviz { get; set; }
        public decimal? Kur { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class DevirIstegi
    {
        public DateTime Tarih { get; set; }
        public List<DevirSatiri> Satirlar { get; set; } = new();
        /// <summary>Devir tarihi ilk hareketten sonra - kullanıcı onayladı.</summary>
        public bool Zorla { get; set; }
    }

    public sealed class TopluSatir
    {
        /// <summary>cari | kasa | banka | pos | kredi | kredikarti (boş = cari).</summary>
        public string? Tur { get; set; }
        /// <summary>Cari: kod / VKN / ünvan (eşleştirme anahtarı); hesap: kod ya da ad.</summary>
        public string? Hesap { get; set; }
        /// <summary>Eski alan adı (cari-devir): Hesap boşsa bu okunur.</summary>
        public string? Cari { get; set; }
        public decimal Tutar { get; set; }
        public string? Doviz { get; set; }
        public decimal? Kur { get; set; }
        public DateTime? Vade { get; set; }
        public string? BelgeNo { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class TopluIstek
    {
        public DateTime Tarih { get; set; }
        /// <summary>kod | vkn | unvan (cari eşleştirmesi; hesaplar kod sonra ad).</summary>
        public string? Eslestirme { get; set; }
        public bool Kontrol { get; set; } = true;
        public List<TopluSatir> Satirlar { get; set; } = new();
    }

    public sealed class CevirIstegi { public List<int> Idler { get; set; } = new(); }

    public static void DevirUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/devir").WithTags("Devir").RequireAuthorization();

        grup.MapGet("/kur", KurAsync);
        grup.MapGet("/acilis-bakiyeleri", AcilisBakiyeleriAsync);
        grup.MapPost("/acilis-cevir", AcilisCevirAsync);
        grup.MapPost("/toplu", TopluAsync);
        grup.MapGet("/{tur}/{id:int}", OkuAsync);
        grup.MapPut("/{tur}/{id:int}", KaydetAsync);

        // ESKİ UÇLAR (1156) takma ad - kart penceresi ve eski bağlantılar.
        var eski = yol.MapGroup("/api/cari").WithTags("Devir").RequireAuthorization();
        eski.MapGet("/{id:int}/devir", (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal)
            => OkuAsync("cari", id, cozucu, veri, ctx, iptal));
        eski.MapPut("/{id:int}/devir", (int id, DevirIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log, HttpContext ctx, CancellationToken iptal)
            => KaydetAsync("cari", id, istek, cozucu, veri, log, ctx, iptal));
        eski.MapGet("/devir-kur", KurAsync);
        eski.MapPost("/devir/toplu", TopluAsync);
    }

    // ------------------------------------------------------------------- oku --
    private static async Task<IResult> OkuAsync(string tur, int id, BaglamCozucu cozucu, VeriKaynagi veri,
        HttpContext ctx, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YetkiIste(Kod, Islem.Gor);
        if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
        // HESAP SEÇİLMEDEN (id 0): ekran yalnız yetkili TÜR listesini ister (Devir.tsx tür seçici). Hesap okunmaya
        //   çalışılırsa 404 dönüyor, istemci listeyi boş sanıp yalnız "Cari"yi gösteriyordu (kullanıcı 25.10.2026:
        //   "Devir Girişi'ni jenerik yapmıştın, şu an sadece cari görünüyor").
        if (id == 0)
            return Results.Ok(new
            {
                tur, turler = Turler.Where(x => baglam.Yetkiler.Var(x.yetki, Islem.Gor)).Select(x => x.tur).ToArray(),
                hesap = (object?)null, satirlar = Array.Empty<object>(),
            });
        await using var b = await veri.AcAsync(iptal);
        var t = await TurCozAsync(b, tur, id, iptal);
        baglam.YetkiIste(t.yetki, Islem.Gor);
        var cari = t.harf == "C";
        if (cari) KapsamDenetle(baglam, id);

        var hesap = cari ? await CariOkuAsync(b, id, iptal) : await HesapOkuAsync(b, id, t.harf, baglam.SubeId ?? 0, iptal);
        var satirlar = await b.ListeAsync($"""
            -- GÜN olarak (oturumun şube diliminde): timestamptz anı istemcide bir gün kayıyordu.
            select m.id, m.islem_tarihi::date, m.plan_tarihi::date, coalesce(m.belge_no, ''), m.borc - m.alacak, m.doviz_cinsi,
                   coalesce(m.doviz_kuru, 0), m.yerel_borc - m.yerel_alacak, coalesce(m.aciklama, ''), (m.aktarim_kaynak is not null)
              from public.mali_hareket m
             where {HesapKosulu(cari)} and m.tur = @p2
             order by m.aktarim_kaynak nulls first, m.plan_tarihi nulls first, m.id
            """, null, [id, t.harf, TurDevir], o => new
            {
                id = o.GetInt32(0), tarih = o.GetDateTime(1), vade = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                belgeNo = o.GetString(3), tutar = o.GetDecimal(4), doviz = o.GetString(5), kur = o.GetDecimal(6),
                yerel = o.GetDecimal(7), aciklama = o.GetString(8), delphi = o.GetBoolean(9),
            }, iptal);
        var ilk = await IlkHareketAsync(b, id, t.harf, iptal);
        var webDevir = satirlar.Where(s => !s.delphi).ToList();
        var turler = Turler.Where(x => baglam.Yetkiler.Var(x.yetki, Islem.Gor)).Select(x => x.tur).ToArray();
        // Hesabın hareket bakiyesi (devir dahil) - banka API bakiyesi farkı kontrolü.
        var hareketBakiye = cari ? 0m : await b.TekDegerAsync<decimal?>(
            "select bakiye from public.v_hesap_bakiye where hesap_id = @p0", null, [id], iptal) ?? 0m;
        return Results.Ok(new
        {
            tur = t.tur, harf = t.harf, turler, hesap, cari = hesap, ilkHareket = ilk, hareketBakiye,
            varsayilanTarih = webDevir.Count > 0 ? webDevir[0].tarih.Date : await VarsayilanTarihAsync(b, iptal),
            delphiKaynakli = await b.TekDegerAsync<bool>("select public.fn_veri_kaynagi_delphi()", null, [], iptal),
            satirlar = webDevir, delphiSatirlari = satirlar.Where(s => s.delphi).ToList(),
            dovizler = await DovizlerAsync(b, iptal),
            izlemeNo = baglam.IzlemeNo,
        });
    }

    private static async Task<IResult> KurAsync(string doviz, DateTime tarih, BaglamCozucu cozucu, VeriKaynagi veri,
        HttpContext ctx, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YetkiIste(Kod, Islem.Gor);
        await using var b = await veri.AcAsync(iptal);
        var kur = await b.TekDegerAsync<decimal?>("select public.fn_doviz_kur_getir(@p0, @p1::date, 2::smallint)", null,
            [doviz, tarih.Date], iptal);
        return Results.Ok(new { doviz, tarih = tarih.Date, kur });
    }

    // ---------------------------------------------------------------- kaydet --
    // Web devrini BAŞTAN yazar (eski satırlar silinir, yenileri eklenir). Boş liste = devri kaldır.
    private static async Task<IResult> KaydetAsync(string tur, int id, DevirIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
        LogDeposu log, HttpContext ctx, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YetkiIste(Kod, Islem.Ekle);
        if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
        await using var b = await veri.AcAsync(iptal);
        await KaynakDenetleAsync(b, iptal);
        var t = await TurCozAsync(b, tur, id, iptal);
        baglam.YetkiIste(t.yetki, Islem.Gor);
        var cari = t.harf == "C";
        if (cari) { KapsamDenetle(baglam, id); await CariOkuAsync(b, id, iptal); }
        var hesapDoviz = cari ? null : (string?)((IDictionary<string, object?>)await HesapOkuAsync(b, id, t.harf, baglam.SubeId ?? 0, iptal))["doviz"];
        var satirlar = await SatirlariDogrulaAsync(b, istek.Tarih, istek.Satirlar, hesapDoviz, iptal);

        var ilk = await IlkHareketAsync(b, id, t.harf, iptal);
        if (satirlar.Count > 0 && ilk is { } ih && ih.Date < istek.Tarih.Date && !istek.Zorla)
            throw GentegreHatasi.IsKurali(
                $"Hesabın {ih:dd.MM.yyyy} tarihli hareketi var - devir ({istek.Tarih:dd.MM.yyyy}) ilk hareketten sonra olur. " +
                "Devir tarihini ilk hareketten önceye alın ya da onaylayarak devam edin.",
                new { kod = "ILK_HAREKET", ilkHareket = ih });

        await using var tx = await b.BeginTransactionAsync(iptal);
        var eski = await b.ListeAsync($"""
            delete from public.mali_hareket m
             where {HesapKosulu(cari)} and m.tur = @p2 and m.aktarim_kaynak is null
            returning m.id, m.islem_tarihi, m.plan_tarihi, m.belge_no, m.borc - m.alacak, m.doviz_cinsi, m.doviz_kuru, m.aciklama
            """, tx, [id, t.harf, TurDevir], o => new
            {
                id = o.GetInt32(0), tarih = o.GetDateTime(1), vade = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                belgeNo = o.IsDBNull(3) ? "" : o.GetString(3), tutar = o.GetDecimal(4), doviz = o.GetString(5),
                kur = o.IsDBNull(6) ? 0 : o.GetDecimal(6), aciklama = o.IsDBNull(7) ? "" : o.GetString(7),
            }, iptal);
        await SatirlariYazAsync(b, tx, id, t.harf, istek.Tarih, satirlar, baglam, iptal);
        // Hesap devri yazıldı: karttaki eski açılış alanı artık okunmaz (çift sayım olmasın).
        if (!cari) await b.CalistirAsync("update public.hesap set acilis_bakiye = 0 where id = @p0 and acilis_bakiye <> 0", tx, [id], iptal);
        var bilgi = new { tur = t.tur, tarih = istek.Tarih.Date, eski, yeni = satirlar };
        if (eski.Count > 0)
            await log.YazAsync(b, tx, satirlar.Count == 0 ? LogIslemi.Sil : LogIslemi.Degistir, LogDevir, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi, tarafId: cari ? id : null, iptal: iptal);
        else if (satirlar.Count > 0)
            await log.YazAsync(b, tx, LogIslemi.Ekle, LogDevir, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                bilgi, tarafId: cari ? id : null, iptal: iptal);
        await tx.CommitAsync(iptal);

        return Results.Ok(new { satir = satirlar.Count, silinen = eski.Count, yerel = satirlar.Sum(s => s.Yerel), izlemeNo = baglam.IzlemeNo });
    }

    // ----------------------------------------------------------------- toplu --
    // Sisteme geçişte çok hesap: Excel'den yapıştırılan satırlar; ilk sütun tür. Kontrol=true
    //   yalnız denetler; false iken HAZIR satırlar yazılır (aynı hesaba birden çok satır = açık
    //   belgeler), hatalılar yazılmaz. Devri olan hesaba toplu ekranda dokunulmaz.
    private static async Task<IResult> TopluAsync(TopluIstek istek, BaglamCozucu cozucu, VeriKaynagi veri,
        LogDeposu log, HttpContext ctx, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YetkiIste(Kod, istek.Kontrol ? Islem.Gor : Islem.Ekle);
        if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
        if (istek.Satirlar.Count == 0) throw GentegreHatasi.Dogrulama("Satır yok.");
        if (istek.Satirlar.Count > 5000) throw GentegreHatasi.Dogrulama("En fazla 5.000 satır.");
        await using var b = await veri.AcAsync(iptal);
        await KaynakDenetleAsync(b, iptal);
        var anahtar = istek.Eslestirme switch { "vkn" => "vkn", "unvan" => "unvan", _ => "kod" };
        var sube = baglam.SubeId ?? 0;

        // Eşleştirme: cari metinleri taraf'ta, hesap metinleri hesap'ta (tür harfiyle).
        var cariMetin = istek.Satirlar.Where(s => TurAd(s.Tur) == "cari").Select(s => Metin(s)).Distinct().ToArray();
        var cariEs = cariMetin.Length == 0 ? [] : await b.ListeAsync($"""
            select x.m, t.id, coalesce(t.kod, ''), coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                   exists (select 1 from public.mali_hareket m where m.taraf_id = t.id and m.hesap_turu = 'C' and m.tur = 2),
                   (select min(m.islem_tarihi)::date from public.mali_hareket m where m.taraf_id = t.id and m.hesap_turu = 'C' and m.tur <> 2)
              from unnest(@p0::text[]) x(m)
              join public.taraf t on (t.musteri = 1 or t.tedarikci = 1)
               and {(anahtar == "vkn" ? "t.vkno = x.m" : anahtar == "unvan"
                    ? "upper(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text) = upper(x.m)" : "t.kod = x.m")}
               and (cardinality(@p1::int[]) = 0 or t.id = any(@p1::int[]))
            """, null, [cariMetin, baglam.Kapsam.ToArray()], EslesmeOku, iptal);
        var hesapEs = new List<(string tur, string m, int id, string kod, string ad, bool devirVar, DateTime? ilk, string doviz)>();
        foreach (var g in istek.Satirlar.Where(s => TurAd(s.Tur) != "cari").GroupBy(s => TurAd(s.Tur)))
        {
            var harf = Turler.First(x => x.tur == g.Key).harf;
            var metin = g.Select(Metin).Distinct().ToArray();
            hesapEs.AddRange(await b.ListeAsync("""
                select x.m, h.id, coalesce(h.kod, ''), h.ad,
                       exists (select 1 from public.mali_hareket m where m.hesap_id = h.id and m.tur = 2),
                       (select min(m.islem_tarihi)::date from public.mali_hareket m where m.hesap_id = h.id and m.tur <> 2), h.doviz_cinsi
                  from unnest(@p0::text[]) x(m)
                  join public.hesap h on h.tur = @p1 and (h.kod = x.m or upper(h.ad) = upper(x.m))
                   and (@p2 = 0 or h.sube_id in (0, @p2))
                """, null, [metin, harf, sube], o => (g.Key, o.GetString(0), o.GetInt32(1), o.GetString(2), o.GetString(3),
                    o.GetBoolean(4), o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5), o.GetString(6)), iptal));
        }
        var cariHarita = cariEs.GroupBy(e => e.m).ToDictionary(g => g.Key, g => g.ToList());
        var hesapHarita = hesapEs.GroupBy(e => (e.tur, e.m)).ToDictionary(g => g.Key, g => g.ToList());

        var sonuc = new List<object>();
        var hazir = new List<(string tur, int id, string? doviz, int sira, TopluSatir s)>();
        for (var i = 0; i < istek.Satirlar.Count; i++)
        {
            var s = istek.Satirlar[i];
            var tur = TurAd(s.Tur);
            var m = Metin(s);
            string durum, mesaj = "";
            int? hesapId = null; string hesapAd = "", hesapKod = "";
            if (tur is null) { durum = "hata"; mesaj = $"Tür tanınmadı: {s.Tur}"; }
            else if (!baglam.Yetkiler.Var(Turler.First(x => x.tur == tur).yetki, Islem.Gor)) { durum = "hata"; mesaj = "Bu tür için yetkiniz yok."; }
            else
            {
                List<(string m, int id, string kod, string ad, bool devirVar, DateTime? ilk, string? doviz)> l;
                if (tur == "cari") l = cariHarita.TryGetValue(m, out var cl) ? cl.Select(x => (x.m, x.id, x.kod, x.ad, x.devirVar, x.ilk, (string?)null)).ToList() : [];
                else l = hesapHarita.TryGetValue((tur, m), out var hl) ? hl.Select(x => (x.m, x.id, x.kod, x.ad, x.devirVar, x.ilk, (string?)x.doviz)).ToList() : [];
                if (l.Count == 0) { durum = "cari_yok"; mesaj = tur == "cari" ? "Eşleşen cari yok." : "Eşleşen hesap yok (kod ya da ad)."; }
                else if (l.Count > 1) { durum = "coklu"; mesaj = $"{l.Count} kayıt eşleşti - kod ile eşleştirin."; }
                else
                {
                    var c = l[0]; hesapId = c.id; hesapAd = c.ad; hesapKod = c.kod;
                    if (s.Tutar == 0) { durum = "hata"; mesaj = "Tutar 0."; }
                    else if (c.devirVar) { durum = "devir_var"; mesaj = "Devri var - kartından düzenleyin."; }
                    else if (c.ilk is { } ih && ih.Date < istek.Tarih.Date) { durum = "hareket_once"; mesaj = $"Devir tarihinden önce hareketi var ({ih:dd.MM.yyyy})."; }
                    else if (c.doviz is { } hd && !string.IsNullOrWhiteSpace(s.Doviz) && !string.Equals(s.Doviz.Trim(), hd, StringComparison.OrdinalIgnoreCase))
                    { durum = "hata"; mesaj = $"Hesabın para birimi {hd}; satır {s.Doviz}."; }
                    else { durum = "hazir"; hazir.Add((tur, c.id, c.doviz, i, s)); }
                }
            }
            sonuc.Add(new { sira = i, tur, hesap = m, cari = m, hesapId, hesapKod, hesapAd, cariId = hesapId, cariKod = hesapKod, cariAd = hesapAd, durum, mesaj });
        }

        var yazilan = 0;
        if (!istek.Kontrol && hazir.Count > 0)
        {
            await using var tx = await b.BeginTransactionAsync(iptal);
            foreach (var g in hazir.GroupBy(h => (h.tur, h.id)))
            {
                var harf = Turler.First(x => x.tur == g.Key.tur).harf;
                var satirlar = await SatirlariDogrulaAsync(b, istek.Tarih, g.Select(h => new DevirSatiri
                {
                    BelgeNo = h.s.BelgeNo, Vade = h.s.Vade, Tutar = h.s.Tutar, Doviz = h.s.Doviz ?? h.doviz, Kur = h.s.Kur, Aciklama = h.s.Aciklama,
                }).ToList(), g.First().doviz, iptal);
                await SatirlariYazAsync(b, tx, g.Key.id, harf, istek.Tarih, satirlar, baglam, iptal);
                if (harf != "C") await b.CalistirAsync("update public.hesap set acilis_bakiye = 0 where id = @p0 and acilis_bakiye <> 0", tx, [g.Key.id], iptal);
                await log.YazAsync(b, tx, LogIslemi.Ekle, LogDevir, g.Key.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { tur = g.Key.tur, tarih = istek.Tarih.Date, satirlar, toplu = true }, tarafId: harf == "C" ? g.Key.id : null, iptal: iptal);
                yazilan += satirlar.Count;
            }
            await tx.CommitAsync(iptal);
        }
        return Results.Ok(new { sonuc, hazir = hazir.Count, yazilan, izlemeNo = baglam.IzlemeNo });
    }

    // ------------------------------------------------- karttaki açılış bakiyeleri --
    // Eski mekanizma: hesap.acilis_bakiye - hiçbir bakiye okumuyordu. Devri olmayan hesaplar
    //   listelenir; seçilenler tür 2 devir satırına çevrilir (tarih = karttaki açılış tarihi,
    //   yoksa ilk hareketin bir gün öncesi, o da yoksa yıl başının bir gün öncesi).
    private static async Task<IResult> AcilisBakiyeleriAsync(BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YetkiIste(Kod, Islem.Gor);
        await using var b = await veri.AcAsync(iptal);
        var l = await b.ListeAsync("""
            select h.id, h.tur, coalesce(h.kod, ''), h.ad, h.doviz_cinsi, h.acilis_bakiye, h.acilis_tarihi,
                   coalesce(vb.bakiye, 0),
                   (select min(m.islem_tarihi)::date from public.mali_hareket m where m.hesap_id = h.id and m.tur <> 2),
                   exists (select 1 from public.mali_hareket m where m.hesap_id = h.id and m.tur = 2)
              from public.hesap h
              left join public.v_hesap_bakiye vb on vb.hesap_id = h.id
             where h.acilis_bakiye <> 0 and (@p0 = 0 or h.sube_id in (0, @p0))
             order by h.tur, h.ad
            """, null, [baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt32(0), harf = o.GetString(1), tur = Turler.FirstOrDefault(x => x.harf == o.GetString(1)).tur ?? o.GetString(1),
                kod = o.GetString(2), ad = o.GetString(3), doviz = o.GetString(4), acilisBakiye = o.GetDecimal(5),
                acilisTarihi = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6), hareketBakiye = o.GetDecimal(7),
                ilkHareket = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8), devirVar = o.GetBoolean(9),
            }, iptal);
        var yetkili = l.Where(x => Turler.Any(t => t.harf == x.harf && baglam.Yetkiler.Var(t.yetki, Islem.Gor))).ToList();
        return Results.Ok(new { hesaplar = yetkili, izlemeNo = baglam.IzlemeNo });
    }

    private static async Task<IResult> AcilisCevirAsync(CevirIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
        HttpContext ctx, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YetkiIste(Kod, Islem.Ekle);
        if (istek.Idler.Count == 0) throw GentegreHatasi.Dogrulama("Hesap seçilmedi.");
        await using var b = await veri.AcAsync(iptal);
        await KaynakDenetleAsync(b, iptal);
        var hesaplar = await b.ListeAsync("""
            select h.id, h.tur, h.doviz_cinsi, h.acilis_bakiye, h.acilis_tarihi,
                   (select min(m.islem_tarihi)::date from public.mali_hareket m where m.hesap_id = h.id and m.tur <> 2),
                   exists (select 1 from public.mali_hareket m where m.hesap_id = h.id and m.tur = 2)
              from public.hesap h where h.id = any(@p0::int[]) and h.acilis_bakiye <> 0
            """, null, [istek.Idler.ToArray()], o => (id: o.GetInt32(0), harf: o.GetString(1), doviz: o.GetString(2),
                bakiye: o.GetDecimal(3), tarih: o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                ilk: o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5), devirVar: o.GetBoolean(6)), iptal);
        var yilBasi = new DateTime(Saat.Bugun.Year, 1, 1).AddDays(-1);
        var cevrilen = 0; var atlanan = new List<object>();
        await using var tx = await b.BeginTransactionAsync(iptal);
        foreach (var h in hesaplar)
        {
            var t = Turler.FirstOrDefault(x => x.harf == h.harf);
            if (t.tur is null || !baglam.Yetkiler.Var(t.yetki, Islem.Gor)) { atlanan.Add(new { h.id, neden = "yetki" }); continue; }
            if (h.devirVar) { atlanan.Add(new { h.id, neden = "devir_var" }); continue; }
            var tarih = h.tarih ?? h.ilk?.AddDays(-1) ?? yilBasi;
            var satir = (await SatirlariDogrulaAsync(b, tarih, [new DevirSatiri { Tutar = h.bakiye, Doviz = h.doviz, Aciklama = "Açılış bakiyesi (karttan çevrildi)" }], h.doviz, iptal));
            await SatirlariYazAsync(b, tx, h.id, h.harf, tarih, satir, baglam, iptal);
            await b.CalistirAsync("update public.hesap set acilis_bakiye = 0 where id = @p0", tx, [h.id], iptal);
            await log.YazAsync(b, tx, LogIslemi.Ekle, LogDevir, h.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { tur = t.tur, tarih, satirlar = satir, karttanCevrildi = true, eskiAcilisBakiye = h.bakiye }, iptal: iptal);
            cevrilen++;
        }
        await tx.CommitAsync(iptal);
        return Results.Ok(new { cevrilen, atlanan, izlemeNo = baglam.IzlemeNo });
    }

    // -------------------------------------------------------------- yardımcılar --
    private sealed record Satir(string BelgeNo, DateTime? Vade, decimal Tutar, string Doviz, decimal Kur, decimal Yerel, string Aciklama);

    private static string? TurAd(string? t) => string.IsNullOrWhiteSpace(t) ? "cari"
        : Turler.FirstOrDefault(x => x.tur == t.Trim().ToLowerInvariant().Replace(" ", "").Replace("ı", "i")).tur
          ?? (t.Trim().ToLowerInvariant() is "kredi karti" or "kredi kartı" or "kk" or "kkart" ? "kredikarti" : null);
    private static string Metin(TopluSatir s) => (s.Hesap ?? s.Cari ?? "").Trim();
    private static (string m, int id, string kod, string ad, bool devirVar, DateTime? ilk) EslesmeOku(NpgsqlDataReader o)
        => (o.GetString(0), o.GetInt32(1), o.GetString(2), o.GetString(3), o.GetBoolean(4), o.IsDBNull(5) ? null : o.GetDateTime(5));

    /// <summary>mali_hareket satırının hesap koşulu: @p0 id, @p1 harf.</summary>
    private static string HesapKosulu(bool cari) => cari
        ? "m.taraf_id = @p0 and m.hesap_turu = 'C' and @p1 = 'C'"
        : "m.hesap_id = @p0 and m.hesap_turu = @p1";

    /// <summary>'hesap' türü hesabın kendi türünü bulur; bilinmeyen tür 400.</summary>
    private static async Task<(string tur, string harf, string yetki)> TurCozAsync(NpgsqlConnection b, string? tur, int id, CancellationToken iptal)
    {
        var t = (tur ?? "").Trim().ToLowerInvariant();
        if (t == "hesap")
        {
            var harf = await b.TekDegerAsync<string>("select tur from public.hesap where id = @p0", null, [id], iptal)
                       ?? throw GentegreHatasi.Bulunamadi("Hesap bulunamadı.");
            return Turler.FirstOrDefault(x => x.harf == harf) is { tur: not null } x ? x : throw GentegreHatasi.Dogrulama("Bu hesap türüne devir girilmez.");
        }
        var s = Turler.FirstOrDefault(x => x.tur == t);
        return s.tur is null ? throw GentegreHatasi.Dogrulama("Bilinmeyen devir türü.") : s;
    }

    private static void KapsamDenetle(IstekBaglami baglam, int id)
    {
        if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(id)) throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
    }

    private static async Task KaynakDenetleAsync(NpgsqlConnection b, CancellationToken iptal)
    {
        if (await b.TekDegerAsync<bool>("select public.fn_veri_kaynagi_delphi()", null, [], iptal))
            throw GentegreHatasi.IsKurali("Veri kaynağı Delphi: devirler Delphi'den aktarılır, burada girilmez.");
    }

    private static async Task<object> CariOkuAsync(NpgsqlConnection b, int id, CancellationToken iptal)
        => await b.TekAsync("""
            select t.id, coalesce(t.kod, '') as kod,
                   coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad,
                   case when t.musteri = 1 and t.tedarikci = 1 then 'Müşteri · Tedarikçi' when t.tedarikci = 1 then 'Tedarikçi' else 'Müşteri' end as "altBilgi",
                   t.musteri, t.tedarikci, coalesce(tm.vade_gun, 0)::int as "vadeGun", coalesce(t.risk_limit, 0)::numeric as "riskLimiti",
                   public.fn_yerel_para()::text as doviz
              from public.taraf t
              left join public.taraf_musteri tm on tm.id = t.id
             where t.id = @p0 and (t.musteri = 1 or t.tedarikci = 1 or t.aday = 1 or t.kurum = 1)
            """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
           ?? throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");

    /// <summary>Hesap + türe özgü bilgiler (POS komisyon / valör, banka API bakiyesi, kredi plan, kredi kartı kesim).</summary>
    private static async Task<object> HesapOkuAsync(NpgsqlConnection b, int id, string harf, int sube, CancellationToken iptal)
        => await b.TekAsync("""
            select h.id, coalesce(h.kod, '') as kod, h.ad, h.doviz_cinsi as doviz,
                   trim(both ' · ' from concat_ws(' · ', nullif(h.banka_adi, ''), case when h.iban <> '' then '…' || right(h.iban, 6) end)) as "altBilgi",
                   h.durum, coalesce(h.acilis_bakiye, 0)::numeric as "acilisBakiye", h.acilis_tarihi as "acilisTarihi",
                   coalesce(h.komisyon_orani, 0)::numeric as "komisyonOrani", coalesce(h.valor_gun, 0)::int as "valorGun",
                   h.banka_bakiye as "bankaBakiye", h.banka_bakiye_zaman as "bankaBakiyeZaman",
                   coalesce(h.limit_tutar, 0)::numeric as "limit", coalesce(h.hesap_kesim_gunu, 0)::int as "hesapKesimGunu",
                   coalesce(h.son_odeme_gunu, 0)::int as "sonOdemeGunu", coalesce(bh.ad, '') as "bagliHesap",
                   coalesce(k.anapara, 0)::numeric as "krediAnapara", coalesce(k.vade_ay, 0)::int as "krediVadeAy",
                   coalesce(k.faiz_orani, 0)::numeric as "krediFaiz", k.ilk_taksit_tarihi as "krediIlkTaksit"
              from public.hesap h
              left join public.hesap bh on bh.id = h.bagli_hesap_id
              left join public.kredi k on k.id = h.id
             where h.id = @p0 and h.tur = @p1 and (@p2 = 0 or h.sube_id in (0, @p2))
            """, null, [id, harf, sube], OkuyucuGenisletmeleri.Sozluk, iptal)
           ?? throw GentegreHatasi.Bulunamadi("Hesap bulunamadı.");

    /// <summary>Hesabın devir DIŞINDAKİ ilk hareketi (yoksa null).</summary>
    private static Task<DateTime?> IlkHareketAsync(NpgsqlConnection b, int id, string harf, CancellationToken iptal)
        => b.TekDegerAsync<DateTime?>($"""
            select min(m.islem_tarihi)::date from public.mali_hareket m
             where {HesapKosulu(harf == "C")} and m.tur <> 2
            """, null, [id, harf], iptal);

    private static async Task<DateTime> VarsayilanTarihAsync(NpgsqlConnection b, CancellationToken iptal)
    {
        var hb = await b.TekDegerAsync<string>(
            "select deger from public.aktarim_ayar where anahtar = 'hareket_baslangic'", null, [], iptal);
        if (DateTime.TryParse(hb, out var t) && t.Year > 1900) return t.Date.AddDays(-1);
        return new DateTime(Saat.Bugun.Year, 1, 1).AddDays(-1);
    }

    private static Task<List<string>> DovizlerAsync(NpgsqlConnection b, CancellationToken iptal)
        => b.ListeAsync("""
            select x.k from (select public.fn_yerel_para()::text as k, 0 as s
                             union select distinct d.doviz_cinsi, 1 from public.doviz_kur d
                              where d.doviz_cinsi <> public.fn_yerel_para()) x
             order by x.s, x.k
            """, null, [], o => o.GetString(0), iptal);

    private static async Task<List<Satir>> SatirlariDogrulaAsync(NpgsqlConnection b, DateTime tarih,
        List<DevirSatiri> girdi, string? hesapDoviz, CancellationToken iptal)
    {
        if (tarih == default) throw GentegreHatasi.Dogrulama("Devir tarihi gerekli.", new AlanHatasi("tarih", "Zorunlu"));
        if (tarih.Date > Saat.Bugun.Date) throw GentegreHatasi.Dogrulama("Devir tarihi ileri bir gün olamaz.", new AlanHatasi("tarih", "Bugün ya da önce"));
        if (girdi.Count > 500) throw GentegreHatasi.Dogrulama("Bir hesaba en fazla 500 devir satırı.");
        var yerelPara = await b.TekDegerAsync<string>("select public.fn_yerel_para()", null, [], iptal) ?? "TL";
        var sonuc = new List<Satir>();
        for (var i = 0; i < girdi.Count; i++)
        {
            var s = girdi[i];
            if (s.Tutar == 0) throw GentegreHatasi.Dogrulama($"{i + 1}. satır: tutar 0 olamaz.", new AlanHatasi($"satirlar[{i}].tutar", "0 olamaz"));
            var doviz = string.IsNullOrWhiteSpace(s.Doviz) ? (hesapDoviz ?? yerelPara) : s.Doviz.Trim().ToUpperInvariant();
            if (doviz.Length > 6) throw GentegreHatasi.Dogrulama($"{i + 1}. satır: para birimi geçersiz.");
            // HESAP KURALI: hesaba yazılan bacağın para birimi hesabınkiyle aynı (hesap tablosu yorumu).
            if (hesapDoviz is not null && !string.Equals(doviz, hesapDoviz, StringComparison.OrdinalIgnoreCase))
                throw GentegreHatasi.Dogrulama($"{i + 1}. satır: hesabın para birimi {hesapDoviz} - {doviz} yazılamaz.", new AlanHatasi($"satirlar[{i}].doviz", hesapDoviz));
            decimal kur;
            if (doviz == yerelPara) kur = 1;
            else
            {
                kur = s.Kur ?? await b.TekDegerAsync<decimal?>("select public.fn_doviz_kur_getir(@p0, @p1::date, 2::smallint)", null,
                    [doviz, tarih.Date], iptal) ?? 0;
                if (kur <= 0) throw GentegreHatasi.Dogrulama($"{i + 1}. satır: {doviz} kuru yok - kur girin.", new AlanHatasi($"satirlar[{i}].kur", "Kur gerekli"));
            }
            var aciklama = string.Join(" · ", new[]
            {
                s.BelgeTarihi is { } bt ? $"Belge {bt:dd.MM.yyyy}" : null,
                string.IsNullOrWhiteSpace(s.Aciklama) ? null : s.Aciklama.Trim(),
            }.Where(x => x != null));
            var belgeNo = (s.BelgeNo ?? "").Trim(); if (belgeNo.Length > 30) belgeNo = belgeNo[..30];
            if (aciklama.Length == 0) aciklama = "Devir"; if (aciklama.Length > 100) aciklama = aciklama[..100];
            sonuc.Add(new Satir(belgeNo, s.Vade?.Date, s.Tutar, doviz, kur, Math.Round(s.Tutar * kur, 2, MidpointRounding.ToEven), aciklama));
        }
        return sonuc;
    }

    private static async Task SatirlariYazAsync(NpgsqlConnection b, NpgsqlTransaction tx, int id, string harf, DateTime tarih,
        List<Satir> satirlar, IstekBaglami baglam, CancellationToken iptal)
    {
        var cari = harf == "C";
        foreach (var s in satirlar)
        {
            var borc = s.Tutar > 0 ? s.Tutar : 0m;
            var alacak = s.Tutar < 0 ? -s.Tutar : 0m;
            await b.CalistirAsync("""
                insert into public.mali_hareket
                       (tur, hesap_turu, hesap_id, taraf_id, belge_no, islem_tarihi, plan_tarihi, borc, alacak,
                        doviz_cinsi, doviz_kuru, yerel_borc, yerel_alacak, aciklama, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5::date, @p6::date, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p15)
                """, tx,
                [TurDevir, harf, cari ? DBNull.Value : id, cari ? id : DBNull.Value, s.BelgeNo, tarih.Date, (object?)s.Vade ?? DBNull.Value,
                 borc, alacak, s.Doviz, s.Kur,
                 Math.Round(borc * s.Kur, 2, MidpointRounding.ToEven), Math.Round(alacak * s.Kur, 2, MidpointRounding.ToEven),
                 s.Aciklama, baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
        }
    }
}
