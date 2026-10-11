using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler.EFatura;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GİDEN e-FATURA uçları - Delphi e-Fatura menüsü (Hazırla · Önizle · Gönder |
/// PDF / HTML / XML Kaydet | Seri Değiştir · Hazırı Geri Al | Mesaj Geçmişi).
/// Kullanan yerler: Başvuru › Belgeye Dönüşüm, fatura kartı, fatura listesi.
///
/// Okuma: belgenin türünü görme yetkisi. Yazma (hazırla / gönder / seri / geri
/// al / bilgi kaydet): türde değiştirme + "ebelge.gonder" aksiyonu.
/// </summary>
public static class EFaturaUclari
{
    public sealed record HazirlaGovdesi(string? Tur, string? Eposta, string? Alias, bool IkinciSeri, long? BaslangicNo);
    public sealed record SeriGovdesi(string? Seri);

    public static void EFaturaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/efatura").WithTags("e-Fatura").RequireAuthorization();

        grup.MapGet("/{id:int}/durum", async (int id, EFaturaServisi s, VeriKaynagi veri, BaglamCozucu cozucu,
                                              HttpContext ctx, CancellationToken iptal) =>
        {
            await ErisimAsync(cozucu, veri, ctx, id, false, iptal);
            return Results.Ok(await s.DurumAsync(id, iptal));
        });

        grup.MapPost("/{id:int}/hazirla", async (int id, HazirlaGovdesi? g, EFaturaServisi s, VeriKaynagi veri,
                                                 BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var bg = await ErisimAsync(cozucu, veri, ctx, id, true, iptal);
            var r = await s.HazirlaAsync(id, new EFaturaServisi.HazirlaIstegi(g?.Tur, g?.Eposta, g?.Alias, g?.IkinciSeri ?? false, g?.BaslangicNo),
                                         bg.Yazma, iptal);
            return Results.Ok(new { soru = r.Soru, mesaj = r.Mesaj, belgeNo = r.BelgeNo, turAdi = r.TurAdi,
                                    varsayilan = r.Varsayilan, secenekler = r.Secenekler, izlemeNo = bg.IzlemeNo });
        });

        grup.MapPost("/{id:int}/gonder", async (int id, EFaturaServisi s, VeriKaynagi veri, BaglamCozucu cozucu,
                                                HttpContext ctx, CancellationToken iptal) =>
        {
            var bg = await ErisimAsync(cozucu, veri, ctx, id, true, iptal);
            return Results.Ok(new { mesaj = await s.GonderAsync(id, bg.Yazma, iptal), izlemeNo = bg.IzlemeNo });
        });

        grup.MapPost("/{id:int}/sifirla", async (int id, EFaturaServisi s, VeriKaynagi veri, BaglamCozucu cozucu,
                                                 HttpContext ctx, CancellationToken iptal) =>
        {
            var bg = await ErisimAsync(cozucu, veri, ctx, id, true, iptal);
            return Results.Ok(new { mesaj = await s.SifirlaAsync(id, bg.Yazma, iptal), izlemeNo = bg.IzlemeNo });
        });

        grup.MapGet("/{id:int}/seriler", async (int id, EFaturaServisi s, VeriKaynagi veri, BaglamCozucu cozucu,
                                                HttpContext ctx, CancellationToken iptal) =>
        {
            var bg = await ErisimAsync(cozucu, veri, ctx, id, false, iptal);
            return Results.Ok(await s.SerilerAsync(id, bg.Yazma, iptal));
        });

        grup.MapPost("/{id:int}/seri", async (int id, SeriGovdesi g, EFaturaServisi s, VeriKaynagi veri,
                                              BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var bg = await ErisimAsync(cozucu, veri, ctx, id, true, iptal);
            return Results.Ok(new { mesaj = await s.SeriDegistirAsync(id, g.Seri ?? "", bg.Yazma, iptal), izlemeNo = bg.IzlemeNo });
        });

        // GÖRÜNÜM: filigran=1 -> gönderilmemişse TASLAK (PDF / HTML Kaydet); önizlemede yok (Delphi).
        grup.MapGet("/{id:int}/html", async (int id, bool? filigran, EFaturaServisi s, VeriKaynagi veri,
                                             BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            await ErisimAsync(cozucu, veri, ctx, id, false, iptal);
            var (html, ad) = await s.HtmlAsync(id, filigran ?? false, iptal);
            return Results.Ok(new { html, dosyaAdi = ad });
        });

        grup.MapGet("/{id:int}/xml", async (int id, EFaturaServisi s, VeriKaynagi veri, BaglamCozucu cozucu,
                                            HttpContext ctx, CancellationToken iptal) =>
        {
            await ErisimAsync(cozucu, veri, ctx, id, false, iptal);
            var (xml, ad) = await s.XmlAsync(id, iptal);
            return Results.Ok(new { xml, dosyaAdi = ad });
        });

        grup.MapGet("/{id:int}/mesajlar", async (int id, EFaturaServisi s, VeriKaynagi veri, BaglamCozucu cozucu,
                                                 HttpContext ctx, CancellationToken iptal) =>
        {
            await ErisimAsync(cozucu, veri, ctx, id, false, iptal);
            return Results.Ok(new { mesajlar = await s.MesajlarAsync(id, iptal) });
        });

        // e-FATURA BİLGİLERİ: tevkifat / istisna kodu, ihracat, SGK, kamu (belge_efatura[_satir]).
        grup.MapGet("/{id:int}/bilgi", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
                                              HttpContext ctx, CancellationToken iptal) =>
        {
            await ErisimAsync(cozucu, veri, ctx, id, false, iptal);
            await using var b = await veri.AcAsync(iptal);
            var baslik = await b.TekAsync("""
                select bl.tipi, coalesce(bl.senaryo, 0) senaryo, coalesce(bl.efatura_durum, 0) efatura_durum,
                       coalesce(e.tevkifat_kodu, 0) tevkifat_kodu, coalesce(e.istisna_kodu, 0) istisna_kodu,
                       coalesce(e.navlun, 0) navlun, coalesce(e.sigorta, 0) sigorta, coalesce(e.sgk_tip, '') sgk_tip,
                       coalesce(e.sgk_mukellef_kod, '') sgk_mukellef_kod, coalesce(e.sgk_mukellef_ad, '') sgk_mukellef_ad,
                       coalesce(e.sgk_dosya_no, '') sgk_dosya_no, e.sgk_donem_bas, e.sgk_donem_bit, e.kamu_hesap_id
                  from public.belge bl left join public.belge_efatura e on e.belge_id = bl.id where bl.id = @p0
                """, null, [id], o => o.Sozluk(), iptal) ?? throw GentegreHatasi.Bulunamadi();
            var satirlar = await b.ListeAsync("""
                select s.id satir_id, coalesce(nullif(btrim(s.aciklama), ''), st.ad, hz.ad, '') ad,
                       coalesce(nullif(es.gtip, ''), st.gtip_kodu, '') gtip, coalesce(es.teslim_sarti, '') teslim_sarti,
                       coalesce(es.tasima_sekli, 0) tasima_sekli, coalesce(es.kap_cinsi, '') kap_cinsi,
                       coalesce(es.kap_no, '') kap_no, coalesce(es.kap_adet, 0) kap_adet, coalesce(s.kdv, 0) kdv
                  from public.belge_satir s
                  left join public.stok st on st.id = s.stok_id
                  left join public.hizmet hz on hz.id = s.hizmet_id
                  left join public.belge_efatura_satir es on es.satir_id = s.id
                 where s.belge_id = @p0 order by s.sira, s.id
                """, null, [id], o => o.Sozluk(), iptal);
            return Results.Ok(new { baslik = Deve(baslik), satirlar = satirlar.Select(Deve) });
        });

        grup.MapPut("/{id:int}/bilgi", async (int id, JsonElement g, VeriKaynagi veri, BaglamCozucu cozucu,
                                              HttpContext ctx, CancellationToken iptal) =>
        {
            var bg = await ErisimAsync(cozucu, veri, ctx, id, true, iptal);
            await using var b = await veri.AcAsync(iptal);
            var durum = await b.TekDegerAsync<short?>("select efatura_durum from public.belge where id = @p0", null, [id], iptal) ?? 0;
            if (EFaturaKodlari.Gonderildi(durum))
                throw GentegreHatasi.IsKurali("e-Fatura gönderilmiş; bilgileri değiştirilemez.");
            var h = g.TryGetProperty("baslik", out var hb) ? hb : default;
            string M(string a) => h.ValueKind == JsonValueKind.Object && h.TryGetProperty(a, out var x) && x.ValueKind == JsonValueKind.String ? x.GetString()!.Trim() : "";
            decimal D(JsonElement e, string a) => e.ValueKind == JsonValueKind.Object && e.TryGetProperty(a, out var x) && x.ValueKind == JsonValueKind.Number ? x.GetDecimal() : 0;
            DateTime? T(string a) => DateTime.TryParse(M(a), out var t) ? t.Date : null;
            int? HesapId() => D(h, "kamuHesapId") is var d && d > 0 ? (int)d : null;

            await using var tx = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                insert into public.belge_efatura (belge_id, tevkifat_kodu, istisna_kodu, navlun, sigorta, sgk_tip, sgk_mukellef_kod,
                                                  sgk_mukellef_ad, sgk_dosya_no, sgk_donem_bas, sgk_donem_bit, kamu_hesap_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12)
                on conflict (belge_id) do update set tevkifat_kodu = excluded.tevkifat_kodu, istisna_kodu = excluded.istisna_kodu,
                       navlun = excluded.navlun, sigorta = excluded.sigorta, sgk_tip = excluded.sgk_tip,
                       sgk_mukellef_kod = excluded.sgk_mukellef_kod, sgk_mukellef_ad = excluded.sgk_mukellef_ad,
                       sgk_dosya_no = excluded.sgk_dosya_no, sgk_donem_bas = excluded.sgk_donem_bas,
                       sgk_donem_bit = excluded.sgk_donem_bit, kamu_hesap_id = excluded.kamu_hesap_id,
                       degistiren = @p12, degistirme_tarihi = now()
                """, tx, [id, (short)D(h, "tevkifatKodu"), (short)D(h, "istisnaKodu"), D(h, "navlun"), D(h, "sigorta"),
                          Kirp(M("sgkTip"), 20), Kirp(M("sgkMukellefKod"), 30), Kirp(M("sgkMukellefAd"), 200),
                          Kirp(M("sgkDosyaNo"), 50), T("sgkDonemBas"), T("sgkDonemBit"), HesapId(), bg.KullaniciId], iptal);

            if (g.TryGetProperty("satirlar", out var ss) && ss.ValueKind == JsonValueKind.Array)
                foreach (var s in ss.EnumerateArray())
                {
                    string SM(string a) => s.TryGetProperty(a, out var x) && x.ValueKind == JsonValueKind.String ? x.GetString()!.Trim() : "";
                    await b.CalistirAsync("""
                        insert into public.belge_efatura_satir (satir_id, belge_id, gtip, teslim_sarti, tasima_sekli, kap_cinsi, kap_no, kap_adet)
                        select @p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7
                         where exists (select 1 from public.belge_satir where id = @p0 and belge_id = @p1)
                        on conflict (satir_id) do update set gtip = excluded.gtip, teslim_sarti = excluded.teslim_sarti,
                               tasima_sekli = excluded.tasima_sekli, kap_cinsi = excluded.kap_cinsi,
                               kap_no = excluded.kap_no, kap_adet = excluded.kap_adet
                        """, tx, [(int)D(s, "satirId"), id, Kirp(EFaturaKodlari.Rakam(SM("gtip")), 12), Kirp(SM("teslimSarti"), 3),
                                  (short)D(s, "tasimaSekli"), Kirp(SM("kapCinsi"), 3), Kirp(SM("kapNo"), 30), D(s, "kapAdet")], iptal);
                }
            await tx.CommitAsync(iptal);
            return Results.Ok(new { mesaj = "e-Fatura bilgileri kaydedildi.", izlemeNo = bg.IzlemeNo });
        });

        // KOD LİSTELERİ: tevkifat / istisna / ihraç kayıtlı (DB), ihracat ve SGK sabitleri, IBAN'lı banka hesapları.
        grup.MapGet("/kodlar", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var kodlar = await b.ListeAsync("""
                select l.kod liste, d.deger, d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                 where l.kod in ('belge.tevkifat', 'belge.kdv_muafiyeti', 'belge.ihrac_kayitli') and d.dil = 0 and d.aktif = 1
                 order by l.kod, d.sira, d.deger
                """, null, null, o => (Liste: o.GetString(0), Deger: o.GetInt32(1), Ad: o.GetString(2)), iptal);
            object Liste(string l) => kodlar.Where(k => k.Liste == l).Select(k => new { deger = k.Deger, ad = k.Ad });
            var hesaplar = await b.ListeAsync("""
                select id, coalesce(ad, '') ad, coalesce(iban, '') iban from public.hesap
                 where coalesce(iban, '') <> '' and coalesce(durum, 1) = 1 order by ad
                """, null, null, o => new { id = o.GetInt32(0), ad = o.GetString(1), iban = o.GetString(2) }, iptal);
            return Results.Ok(new
            {
                tevkifat = Liste("belge.tevkifat"), istisna = Liste("belge.kdv_muafiyeti"), ihracKayitli = Liste("belge.ihrac_kayitli"),
                teslimSartlari = EFaturaKodlari.TeslimSartlari.Select(x => new { kod = x.Kod, ad = x.Ad }),
                tasimaSekilleri = EFaturaKodlari.TasimaSekilleri.Select(x => new { deger = x.Kod, ad = x.Ad }),
                kapCinsleri = EFaturaKodlari.KapCinsleri.Select(x => new { kod = x.Kod, ad = x.Ad }),
                sgkTipleri = EFaturaKodlari.SgkTipleri.Select(x => new { kod = x.Kod, ad = x.Ad }),
                hesaplar,
            });
        });
    }

    /// <summary>Belgenin türünü görme / değiştirme yetkisi; yazmada ayrıca e-Belge aksiyonu.</summary>
    private static async Task<IstekBaglami> ErisimAsync(BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, int id,
                                                        bool yaz, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        var tt = await veri.TekAsync("select tur, tipi from public.belge where id = @p0", [id],
                                     r => new[] { (int)r.GetInt16(0), (int)r.GetInt16(1) }, iptal);
        if (tt is null || !BelgeUclari.TurIzinli(baglam, tt[0], tt[1], yaz ? Islem.Degistir : Islem.Gor))
            throw GentegreHatasi.Bulunamadi();
        if (yaz) baglam.AksiyonIste("ebelge.gonder");
        return baglam;
    }

    private static IDictionary<string, object?> Deve(IDictionary<string, object?> d)
        => d.ToDictionary(k => JsonNamingPolicy.CamelCase.ConvertName(
                                   string.Concat(k.Key.Split('_').Select((p, i) => i == 0 ? p : char.ToUpperInvariant(p[0]) + p[1..]))),
                          k => k.Value);

    private static string Kirp(string s, int n) => s.Length <= n ? s : s[..n];
}
