using Gentegre.Cekirdek;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KASA / GÜN SONU MUTABAKATI (mockup Ekranlar/İcmal/kasa_gun_sonu_mutabakati.html,
/// kullanıcı 11.10.2026: "kasa mutabakatını kodla").
///
/// <para><b>Kaynak hesap ekstresiyle aynı:</b> v_mali_hareket_ek (hesap_ekstre,
/// gerçekleşmiş). Gün TÜRKİYE saatiyle. Kasa (K) satırı: devir = günden önceki
/// bakiye; giriş / çıkış = günün tahsilat / ödemesi; transfer = virman türleri
/// (40-44, iki bacak da); beklenen = devir + giriş − çıkış + transfer.</para>
///
/// <para><b>Sayılan:</b> banko kasasında gün içinde kapanan son oturumun
/// "kasada bırakılan"ı (sayım − teslim); öteki kasalarda bu ekranda girilen
/// sayım (kasa_gun_sayim). POS gün sonu: elle girilen (pos_gun_sonu) yoksa
/// banko oturum kapanışında girilen cihaz toplamı. Banka: ekstre rakamı
/// elle (banka_gun_mutabakat) - içe aktarma bu sürümde yok.</para>
///
/// <para><b>Günü Kapat engelleri:</b> açık banko oturumu, sayımı girilmemiş
/// (banko dışı) hareketli kasa, gün sonu toplamı olmayan POS, açıklamasız
/// kasa / POS farkı. Banka farkı engel DEĞİL (tahsilat girilince kapanır).
/// Kapalı güne kasa_islem yazılamaz (veritabanı tetikleyicisi, 1030).</para>
/// </summary>
public static class KasaGunSonuUclari
{
    /// <summary>Ekran kodu (1030) - haklarını kasa.finans'tan kopyalar.</summary>
    private const string Kod = "kasa.gun_sonu";

    private static readonly int[] TransferTurleri = [40, 41, 42, 43, 44];

    public static readonly Dictionary<short, string> FarkNedenleri = new()
    {
        [1] = "Para üstü hatası", [2] = "Sayım hatası", [3] = "Tutar hatası", [4] = "Mükerrer işlem",
        [5] = "Makbuz kesilmemiş", [6] = "Provizyon iptali", [7] = "Valör / zamanlama", [9] = "Diğer",
    };

    private sealed record Hareket(int IslemId, int HesapId, string HesapTuru, string Hesap, short Tur, string TurAdi,
        decimal Borc, decimal Alacak, DateTime Zaman, string BelgeNo, string Aciklama, string Kullanici, bool Bugun);

    public sealed record SayimIstegi(DateTime Tarih, int HesapId, decimal Sayilan, string? Aciklama);
    public sealed record PosIstegi(DateTime Tarih, int HesapId, int Adet, decimal? Tutar);
    public sealed record BankaIstegi(DateTime Tarih, int HesapId, decimal? Yatis, decimal? Havale);
    public sealed record FarkIstegi(DateTime Tarih, string Kalem, decimal Fark, short Neden, string? Aciklama);
    public sealed record KapatIstegi(DateTime Tarih);
    public sealed record AcIstegi(DateTime Tarih, string? Gerekce);

    public static void KasaGunSonuUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kasa-gun-sonu").WithTags("Kasa / Gün Sonu").RequireAuthorization();

        grup.MapGet("/", async (DateTime? tarih, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok((await HesaplaAsync(b, (tarih ?? Saat.Bugun.AddDays(-1)).Date, baglam.SubeId ?? 0, iptal)).Veri);
        });

        grup.MapPost("/sayim", async (SayimIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var (baglam, b) = await YazmaHazirla(cozucu, veri, ctx, i.Tarih, iptal);
            await using var _ = b;
            await b.CalistirAsync("""
                insert into public.kasa_gun_sayim (sube_id, tarih, hesap_id, sayilan, aciklama, sayan_id)
                values (@p0, @p1::date, @p2, @p3, @p4, @p5)
                on conflict (sube_id, tarih, hesap_id) do update
                   set sayilan = excluded.sayilan, aciklama = excluded.aciklama, sayan_id = excluded.sayan_id, sayim_zamani = now()
                """, null, [baglam.SubeId ?? 0, i.Tarih.Date, i.HesapId, i.Sayilan, (i.Aciklama ?? "").Trim(), baglam.KullaniciId], iptal);
            return Results.Ok(new { tamam = true });
        });

        grup.MapPost("/pos", async (PosIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var (baglam, b) = await YazmaHazirla(cozucu, veri, ctx, i.Tarih, iptal);
            await using var _ = b;
            if (i.Tutar is null)   // boş = elle girişi sil (oturum cihaz toplamına dön)
                await b.CalistirAsync("delete from public.pos_gun_sonu where sube_id = @p0 and tarih = @p1::date and hesap_id = @p2",
                    null, [baglam.SubeId ?? 0, i.Tarih.Date, i.HesapId], iptal);
            else
                await b.CalistirAsync("""
                    insert into public.pos_gun_sonu (sube_id, tarih, hesap_id, adet, tutar, giren_id)
                    values (@p0, @p1::date, @p2, @p3, @p4, @p5)
                    on conflict (sube_id, tarih, hesap_id) do update
                       set adet = excluded.adet, tutar = excluded.tutar, giren_id = excluded.giren_id, giris_zamani = now()
                    """, null, [baglam.SubeId ?? 0, i.Tarih.Date, i.HesapId, Math.Max(0, i.Adet), i.Tutar, baglam.KullaniciId], iptal);
            return Results.Ok(new { tamam = true });
        });

        grup.MapPost("/banka", async (BankaIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var (baglam, b) = await YazmaHazirla(cozucu, veri, ctx, i.Tarih, iptal);
            await using var _ = b;
            await b.CalistirAsync("""
                insert into public.banka_gun_mutabakat (sube_id, tarih, hesap_id, yatis, havale, giren_id)
                values (@p0, @p1::date, @p2, @p3, @p4, @p5)
                on conflict (sube_id, tarih, hesap_id) do update
                   set yatis = excluded.yatis, havale = excluded.havale, giren_id = excluded.giren_id, giris_zamani = now()
                """, null, [baglam.SubeId ?? 0, i.Tarih.Date, i.HesapId, i.Yatis, i.Havale, baglam.KullaniciId], iptal);
            return Results.Ok(new { tamam = true });
        });

        grup.MapPost("/fark", async (FarkIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            if (!FarkNedenleri.ContainsKey(i.Neden)) throw GentegreHatasi.IsKurali("Fark nedeni seçilmeli.");
            if (i.Neden == 9 && string.IsNullOrWhiteSpace(i.Aciklama)) throw GentegreHatasi.IsKurali("'Diğer' nedeninde açıklama zorunlu.");
            if (!System.Text.RegularExpressions.Regex.IsMatch(i.Kalem ?? "", @"^(kasa|pos|banka):\d+$"))
                throw GentegreHatasi.IsKurali("Geçersiz fark kalemi.");
            var (baglam, b) = await YazmaHazirla(cozucu, veri, ctx, i.Tarih, iptal);
            await using var _ = b;
            await b.CalistirAsync("""
                insert into public.kasa_gun_fark (sube_id, tarih, kalem, fark, neden, aciklama, giren_id)
                values (@p0, @p1::date, @p2, @p3, @p4, @p5, @p6)
                on conflict (sube_id, tarih, kalem) do update
                   set fark = excluded.fark, neden = excluded.neden, aciklama = excluded.aciklama,
                       giren_id = excluded.giren_id, giris_zamani = now()
                """, null, [baglam.SubeId ?? 0, i.Tarih.Date, i.Kalem, i.Fark, i.Neden, (i.Aciklama ?? "").Trim(), baglam.KullaniciId], iptal);
            return Results.Ok(new { tamam = true });
        });

        // GÜNÜ KAPAT: engeller sunucuda YENİDEN hesaplanır - ekrandaki eski veriye güvenilmez.
        grup.MapPost("/kapat", async (KapatIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var (baglam, b) = await YazmaHazirla(cozucu, veri, ctx, i.Tarih, iptal);
            await using var _ = b;
            var sube = baglam.SubeId ?? 0;
            var durum = await HesaplaAsync(b, i.Tarih.Date, sube, iptal);
            if (durum.Engeller.Count > 0)
                throw GentegreHatasi.IsKurali("Gün kapatılamaz: " + string.Join(" · ", durum.Engeller));
            await b.CalistirAsync("""
                insert into public.kasa_gun_kapanis (sube_id, tarih, durum, kapatan_id, kapanis_zamani, ozet)
                values (@p0, @p1::date, 1, @p2, now(), @p3::jsonb)
                on conflict (sube_id, tarih) do update
                   set durum = 1, kapatan_id = excluded.kapatan_id, kapanis_zamani = now(), ozet = excluded.ozet
                """, null, [sube, i.Tarih.Date, baglam.KullaniciId, JsonSerializer.Serialize(durum.Ozet)], iptal);
            return Results.Ok(new { tamam = true });
        });

        // GÜNÜ AÇ: yalnız ekranın "sil" hakkı olan ve gerekçeyle; kapanış satırı silinmez, iz kalır.
        grup.MapPost("/ac", async (AcIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Sil);
            if (string.IsNullOrWhiteSpace(i.Gerekce) || i.Gerekce.Trim().Length < 5)
                throw GentegreHatasi.IsKurali("Günü açma gerekçesi yazılmalı.");
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.kasa_gun_kapanis
                   set durum = 0, acan_id = @p2, acilis_zamani = now(), acilis_gerekce = @p3
                 where sube_id = @p0 and tarih = @p1::date and durum = 1
                """, null, [baglam.SubeId ?? 0, i.Tarih.Date, baglam.KullaniciId, i.Gerekce.Trim()], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Bu gün kapalı değil.");
            return Results.Ok(new { tamam = true });
        });
    }

    /// <summary>Yazma ortak kapısı: değiştir hakkı + gün kapalıysa giriş yapılamaz.</summary>
    private static async Task<(IstekBaglami, NpgsqlConnection)> YazmaHazirla(BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
                                                                           DateTime tarih, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YetkiIste(Kod, Islem.Degistir);
        var b = await veri.AcAsync(iptal);
        var kapali = await b.TekDegerAsync<bool>("""
            select exists (select 1 from public.kasa_gun_kapanis
                            where tarih = @p1::date and durum = 1 and (sube_id = @p0 or sube_id = 0))
            """, null, [baglam.SubeId ?? 0, tarih.Date], iptal);
        if (kapali)
        {
            await b.DisposeAsync();
            throw GentegreHatasi.IsKurali("Gün kapalı - değişiklik için önce günü açın.");
        }
        return (baglam, b);
    }

    /// <summary>Günün bütün hesabı - GET ve Günü Kapat aynı hesabı kullanır.</summary>
    private static async Task<GunSonuSonucu> HesaplaAsync(NpgsqlConnection b, DateTime tarih, int sube, CancellationToken iptal)
    {
        // Günün ve önceki günlerin hareketleri (devir için toplam, liste için bugün).
        var hareketler = await b.ListeAsync("""
            select coalesce(e.kasa_islem_id, 0), e.hesap_id, coalesce(e.hesap_turu, ''), coalesce(e.hesap_adi, ''), e.tur,
                   coalesce(e.tur_adi, ''), coalesce(e.yerel_borc, e.borc, 0), coalesce(e.yerel_alacak, e.alacak, 0), e.islem_tarihi,
                   coalesce(e.belge_no, ''), coalesce(nullif(e.aciklama, ''), e.taraf_unvan, ''),
                   coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''),
                   (e.islem_tarihi at time zone public.fn_sube_zaman_dilimi(@p1))::date = @p0::date
              from public.v_mali_hareket_ek e
              left join public.kasa_islem ki on ki.id = e.kasa_islem_id
              left join public.taraf u on u.id = ki.ekleyen
             where e.hesap_id is not null and e.hesap_ekstre = 1 and e.islem_durum = 2
               and e.hesap_turu in ('K', 'P', 'B')
               and (e.islem_tarihi at time zone public.fn_sube_zaman_dilimi(@p1))::date <= @p0::date
               and (@p1 = 0 or coalesce(e.sube_id, 0) in (0, @p1))
            """, null, [tarih, sube], o => new Hareket(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetString(3), o.GetInt16(4),
                o.GetString(5), o.GetDecimal(6), o.GetDecimal(7), o.GetDateTime(8), o.GetString(9), o.GetString(10), o.GetString(11),
                o.GetBoolean(12)), iptal);
        var bugun = hareketler.Where(h => h.Bugun).ToList();

        // Banko kasaları ve günün oturumları.
        var bankolar = await b.ListeAsync("""
            select bk.hesap_id, bk.ad, o.durum, o.kasada_birakilan, o.kapanis_ts,
                   coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''), o.id
              from public.banko bk
              left join lateral (
                  select x.* from public.banko_oturum x
                   where x.banko_id = bk.id
                     and (x.acilis_ts at time zone public.fn_sube_zaman_dilimi(@p1))::date <= @p0::date
                     and (x.durum in (1, 2, 3) or (x.kapanis_ts at time zone public.fn_sube_zaman_dilimi(@p1))::date = @p0::date)
                   order by (x.durum in (1, 2, 3)) desc, x.kapanis_ts desc nulls first limit 1) o on true
              left join public.taraf u on u.id = o.kullanici_id
             where bk.hesap_id is not null and coalesce(bk.aktif, 1) = 1
               and (@p1 = 0 or coalesce(bk.sube_id, 0) in (0, @p1))
            """, null, [tarih, sube], o => (hesap: o.GetInt32(0), ad: o.GetString(1), durum: o.IsDBNull(2) ? (short)0 : o.GetInt16(2),
                birakilan: o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3), kapanis: o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                sorumlu: o.GetString(5), oturum: o.IsDBNull(6) ? 0L : o.GetInt64(6)), iptal);
        var bankoMap = bankolar.GroupBy(x => x.hesap).ToDictionary(g => g.Key, g => g.First());

        var sayimlar = (await b.ListeAsync("""
            select s.hesap_id, s.sayilan, coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''), s.sayim_zamani
              from public.kasa_gun_sayim s left join public.taraf u on u.id = s.sayan_id
             where s.sube_id = @p1 and s.tarih = @p0::date
            """, null, [tarih, sube], o => (hesap: o.GetInt32(0), sayilan: o.GetDecimal(1), sayan: o.GetString(2), zaman: o.GetDateTime(3)), iptal))
            .ToDictionary(x => x.hesap);
        var posGiris = (await b.ListeAsync("""
            select hesap_id, adet, tutar from public.pos_gun_sonu where sube_id = @p1 and tarih = @p0::date
            """, null, [tarih, sube], o => (hesap: o.GetInt32(0), adet: o.GetInt32(1), tutar: o.GetDecimal(2)), iptal)).ToDictionary(x => x.hesap);
        var posOturum = (await b.ListeAsync("""
            select bp.hesap_id, sum(op.cihaz_toplam)
              from public.banko_oturum_pos op
              join public.banko_oturum o on o.id = op.oturum_id
              join public.banko_pos bp on bp.id = op.banko_pos_id
             where bp.hesap_id is not null and op.cihaz_toplam is not null
               and (o.kapanis_ts at time zone public.fn_sube_zaman_dilimi(@p1))::date = @p0::date
               and (@p1 = 0 or coalesce(o.sube_id, 0) in (0, @p1))
             group by 1
            """, null, [tarih, sube], o => (hesap: o.GetInt32(0), tutar: o.GetDecimal(1)), iptal)).ToDictionary(x => x.hesap, x => x.tutar);
        var posTerminal = (await b.ListeAsync("""
            select bp.hesap_id, string_agg(distinct coalesce(nullif(bp.terminal_no, ''), '?'), ', '), string_agg(distinct bk.ad, ', ')
              from public.banko_pos bp join public.banko bk on bk.id = bp.banko_id
             where bp.hesap_id is not null group by 1
            """, null, [], o => (hesap: o.GetInt32(0), terminal: o.GetString(1), banko: o.GetString(2)), iptal)).ToDictionary(x => x.hesap);
        var bankaGiris = (await b.ListeAsync("""
            select m.hesap_id, m.yatis, m.havale, coalesce(h.iban, '') from public.banka_gun_mutabakat m
              left join public.hesap h on h.id = m.hesap_id
             where m.sube_id = @p1 and m.tarih = @p0::date
            """, null, [tarih, sube], o => (hesap: o.GetInt32(0), yatis: o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1),
                havale: o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2)), iptal)).ToDictionary(x => x.hesap);
        var farkAciklama = (await b.ListeAsync("""
            select f.kalem, f.neden, f.aciklama, f.fark, coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), '')
              from public.kasa_gun_fark f left join public.taraf u on u.id = f.giren_id
             where f.sube_id = @p1 and f.tarih = @p0::date
            """, null, [tarih, sube], o => (kalem: o.GetString(0), neden: o.GetInt16(1), aciklama: o.GetString(2), fark: o.GetDecimal(3),
                giren: o.GetString(4)), iptal)).ToDictionary(x => x.kalem);
        var hesapBilgi = (await b.ListeAsync("""
            select h.id, coalesce(h.kod, ''), coalesce(h.ad, ''), coalesce(h.iban, ''), coalesce(h.banka_adi, '')
              from public.hesap h where h.id = any(@p0)
            """, null, [hareketler.Select(h => h.HesapId).Concat(bankoMap.Keys).Concat(sayimlar.Keys).Concat(posGiris.Keys)
                         .Concat(bankaGiris.Keys).Distinct().ToArray()],
            o => (id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2), iban: o.GetString(3), banka: o.GetString(4)), iptal))
            .ToDictionary(x => x.id);

        string Ad(int id) => hesapBilgi.TryGetValue(id, out var h) ? h.ad : $"Hesap {id}";
        object? Aciklama(string kalem) => farkAciklama.TryGetValue(kalem, out var f)
            ? new { f.neden, nedenAd = FarkNedenleri.GetValueOrDefault(f.neden, ""), f.aciklama, f.fark, f.giren } : null;

        // ------------------------------------------------------------ kasalar --
        var kasaIdler = hareketler.Where(h => h.HesapTuru == "K" && h.Bugun).Select(h => h.HesapId)
            .Concat(bankoMap.Keys).Concat(sayimlar.Keys).Distinct().ToList();
        var kasalar = kasaIdler.Select(id =>
        {
            var tum = hareketler.Where(h => h.HesapId == id).ToList();
            var gun = tum.Where(h => h.Bugun).ToList();
            var devir = tum.Where(h => !h.Bugun).Sum(h => h.Borc - h.Alacak);
            var gunNormal = gun.Where(h => !TransferTurleri.Contains(h.Tur)).ToList();
            var giris = gunNormal.Sum(h => h.Borc); var cikis = gunNormal.Sum(h => h.Alacak);
            var transfer = gun.Where(h => TransferTurleri.Contains(h.Tur)).Sum(h => h.Borc - h.Alacak);
            var beklenen = devir + giris - cikis + transfer;
            decimal? sayilan = null; string durum; string sorumlu = ""; var banko = bankoMap.TryGetValue(id, out var bo);
            if (banko)
            {
                sorumlu = bo.sorumlu;
                if (bo.oturum == 0) { durum = "Oturum yok"; sayilan = gun.Count == 0 ? beklenen : null; }
                else if (bo.durum is 1 or 2 or 3) durum = bo.durum == 3 ? "Kapanış onayı bekliyor" : "Oturum açık";
                else { durum = bo.kapanis is { } kp ? $"Kapandı {Saat.Yerel(kp):HH:mm}" : "Kapandı"; sayilan = bo.birakilan; }
            }
            else if (sayimlar.TryGetValue(id, out var s)) { sayilan = s.sayilan; durum = $"Sayıldı {Saat.Yerel(s.zaman):HH:mm}"; sorumlu = s.sayan; }
            else durum = "Sayım girilmedi";
            var fark = sayilan is { } sy ? sy - beklenen : (decimal?)null;
            var kirilim = gun.GroupBy(h => h.TurAdi).Select(g => new { ad = g.Key, adet = g.Count(), tutar = g.Sum(h => h.Borc - h.Alacak) }).ToList();
            return new
            {
                id, ad = Ad(id), kod = hesapBilgi.TryGetValue(id, out var hb) ? hb.kod : "", banko, devir, giris, cikis, transfer,
                beklenen, sayilan, fark, durum, sorumlu, acik = banko && bo.durum is 1 or 2 or 3,
                sayimGerekli = !banko && gun.Count > 0, kirilim, kalem = $"kasa:{id}", aciklama = Aciklama($"kasa:{id}"),
            };
        }).OrderByDescending(k => !k.banko).ThenBy(k => k.ad).ToList();

        // --------------------------------------------------------------- POS --
        var posIdler = bugun.Where(h => h.HesapTuru == "P").Select(h => h.HesapId).Concat(posGiris.Keys).Distinct().ToList();
        var poslar = posIdler.Select(id =>
        {
            var cekim = bugun.Where(h => h.HesapId == id && h.Tur == 25).ToList();
            var sistem = cekim.Sum(h => h.Borc) - bugun.Where(h => h.HesapId == id && h.Tur != 25 && !TransferTurleri.Contains(h.Tur)).Sum(h => h.Alacak);
            decimal? batch = posGiris.TryGetValue(id, out var pg) ? pg.tutar : posOturum.TryGetValue(id, out var po) ? po : null;
            int? batchAdet = posGiris.TryGetValue(id, out var pa) ? pa.adet : null;
            var kaynak = posGiris.ContainsKey(id) ? "elle" : posOturum.ContainsKey(id) ? "oturum" : "";
            var fark = batch is { } bt ? bt - sistem : (decimal?)null;
            posTerminal.TryGetValue(id, out var t);
            return new
            {
                id, ad = Ad(id), terminal = t.terminal ?? "", banko = t.banko ?? "", adet = cekim.Count, sistem, batchAdet, batch, kaynak, fark,
                durum = batch is null ? (cekim.Count > 0 ? "Gün sonu bekleniyor" : "Çekim yok") : fark == 0 ? "Eşleşti" : "Fark var",
                kalem = $"pos:{id}", aciklama = Aciklama($"pos:{id}"),
            };
        }).OrderBy(p => p.ad).ToList();

        // ------------------------------------------------------------- banka --
        var bankaIdler = bugun.Where(h => h.HesapTuru == "B").Select(h => h.HesapId).Concat(bankaGiris.Keys).Distinct().ToList();
        var bankalar = bankaIdler.Select(id =>
        {
            var g = bugun.Where(h => h.HesapId == id).ToList();
            var yatisB = g.Where(h => h.Tur == 41).Sum(h => h.Borc);
            var havaleS = g.Where(h => h.Tur == 22).Sum(h => h.Borc);
            bankaGiris.TryGetValue(id, out var m);
            var girildi = bankaGiris.ContainsKey(id);
            decimal? fark = girildi ? ((m.yatis ?? yatisB) - yatisB) + ((m.havale ?? havaleS) - havaleS) : null;
            hesapBilgi.TryGetValue(id, out var hb);
            return new
            {
                id, ad = Ad(id), iban = hb.iban ?? "", yatisBeklenen = yatisB, yatisGerceklesen = girildi ? m.yatis : null,
                havaleAdet = g.Count(h => h.Tur == 22), havaleSistem = havaleS, havaleEkstre = girildi ? m.havale : null, fark,
                durum = !girildi ? "Ekstre girilmedi" : fark == 0 ? "Eşleşti" : fark > 0 ? "Ekstrede fazla" : "Ekstrede eksik",
                kalem = $"banka:{id}", aciklama = Aciklama($"banka:{id}"),
            };
        }).OrderBy(x => x.ad).ToList();

        // ---------------------------------------------------------- farklar --
        var farklar = kasalar.Where(k => k.fark is { } f && f != 0).Select(k => new { k.kalem, tur = "Kasa", ad = k.ad, fark = k.fark!.Value, sorumlu = k.sorumlu, k.aciklama, engel = true })
            .Concat(poslar.Where(p => p.fark is { } f && f != 0).Select(p => new { p.kalem, tur = "POS", ad = p.ad, fark = p.fark!.Value, sorumlu = p.banko, p.aciklama, engel = true }))
            .Concat(bankalar.Where(x => x.fark is { } f && f != 0).Select(x => new { x.kalem, tur = "Banka", ad = x.ad, fark = x.fark!.Value, sorumlu = "", x.aciklama, engel = false }))
            .ToList();

        // ---------------------------------------------------------- engeller --
        var engeller = new List<string>();
        foreach (var k in kasalar.Where(k => k.acik)) engeller.Add($"{k.ad} oturumu açık - kapanış sayımı ve onayı gerekli");
        foreach (var k in kasalar.Where(k => k.sayimGerekli && k.sayilan is null)) engeller.Add($"{k.ad} sayımı girilmedi");
        foreach (var p in poslar.Where(p => p.batch is null && p.adet > 0)) engeller.Add($"{p.ad} gün sonu (batch) toplamı girilmedi");
        var aciklamasiz = farklar.Count(f => f.engel && f.aciklama is null);
        if (aciklamasiz > 0) engeller.Add($"{aciklamasiz} farkın açıklaması yok");

        var kapanis = await b.TekAsync("""
            select k.durum, k.kapanis_zamani, coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''),
                   k.acilis_zamani, coalesce(public.fn_taraf_ad(a.unvan, a.ad, a.soyad)::varchar(120), ''), k.acilis_gerekce
              from public.kasa_gun_kapanis k
              left join public.taraf u on u.id = k.kapatan_id left join public.taraf a on a.id = k.acan_id
             where k.sube_id = @p1 and k.tarih = @p0::date
            """, null, [tarih, sube], o => new
        {
            kapali = o.GetInt16(0) == 1, kapanisZamani = o.GetDateTime(1), kapatan = o.GetString(2),
            acilisZamani = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3), acan = o.GetString(4), gerekce = o.GetString(5),
        }, iptal);
        var onceki = await b.TekAsync("""
            select k.tarih, k.durum, k.kapanis_zamani, coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), '')
              from public.kasa_gun_kapanis k left join public.taraf u on u.id = k.kapatan_id
             where k.sube_id = @p1 and k.tarih = @p0::date - 1
            """, null, [tarih, sube], o => new { tarih = o.GetDateTime(0), kapali = o.GetInt16(1) == 1, zaman = o.GetDateTime(2), kapatan = o.GetString(3) }, iptal);

        var sayilanKasalar = kasalar.Where(k => k.sayilan is not null).ToList();
        var ozet = new
        {
            devir = kasalar.Sum(k => k.devir), girisNakit = kasalar.Sum(k => k.giris), cikisNakit = kasalar.Sum(k => k.cikis),
            makbuz = bugun.Count(h => h.HesapTuru == "K" && h.Tur == 21),
            beklenen = kasalar.Sum(k => k.beklenen), sayilan = sayilanKasalar.Sum(k => k.sayilan!.Value),
            sayilanBeklenen = sayilanKasalar.Sum(k => k.beklenen), kasaFark = sayilanKasalar.Sum(k => k.fark!.Value),
            sayilanAdet = sayilanKasalar.Count, kasaAdet = kasalar.Count,
            pos = poslar.Sum(p => p.sistem), posAdet = poslar.Sum(p => p.adet),
            posBatch = poslar.Where(p => p.batch is not null).Sum(p => p.batch!.Value),
            posBatchSistem = poslar.Where(p => p.batch is not null).Sum(p => p.sistem),
            posFark = poslar.Where(p => p.fark is not null).Sum(p => p.fark!.Value),
            posBekleyen = poslar.Where(p => p.batch is null && p.adet > 0).Select(p => p.ad).ToList(),
            havale = bankalar.Sum(x => x.havaleSistem), havaleAdet = bankalar.Sum(x => x.havaleAdet),
            havaleEkstre = bankalar.Where(x => x.havaleEkstre is not null).Sum(x => x.havaleEkstre!.Value),
            bankaFark = bankalar.Where(x => x.fark is not null).Sum(x => x.fark!.Value),
            bankayaYatirilan = bugun.Where(h => h.HesapTuru == "K" && h.Tur == 41).Sum(h => h.Alacak),
            ertesiGunDevri = sayilanKasalar.Sum(k => k.sayilan!.Value) + kasalar.Where(k => k.sayilan is null).Sum(k => k.beklenen),
            ertesiKesin = kasalar.All(k => k.sayilan is not null),
            acikOturum = kasalar.Count(k => k.acik),
        };

        var liste = bugun.OrderBy(h => h.Zaman).Select(h => new
        {
            h.IslemId, zaman = h.Zaman, hesap = h.Hesap, hesapTuru = h.HesapTuru, tur = h.Tur, turAdi = h.TurAdi,
            tutar = h.Borc - h.Alacak, belgeNo = h.BelgeNo, aciklama = h.Aciklama, kullanici = h.Kullanici,
        }).ToList();

        return new GunSonuSonucu(new
        {
            tarih, kapanis, onceki, ozet, kasalar, poslar, bankalar, hareketler = liste, farklar, engeller,
            nedenler = FarkNedenleri.Select(x => new { kod = x.Key, ad = x.Value }),
        }, engeller, ozet);
    }

    private sealed record GunSonuSonucu(object Veri, List<string> Engeller, object Ozet);
}
