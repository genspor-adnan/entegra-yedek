using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sigorta;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SİGORTA UÇLARI — v1 (430): poliçe sorgu, provizyon oluştur/güncelle/tazele/
/// iptal, doküman gönderimi.
///
/// <para><b>Sağlayıcısı olmayan kurumda ekran ELLE çalışır</b> (bugünkü
/// davranış): bu uçlar 422 ile "hesap tanımlı değil" der, başvuru kartındaki
/// elle provizyon alanları kalır. Yeni yapı eskisini bozmuyor.</para>
///
/// <para><b>Yetenekler ekranı sürer.</b> <c>/saglayicilar</c> ve
/// <c>/hesap</c> uçları yetenek bayraklarını döndürür; desteklenmeyen düğme
/// hiç çizilmez - pasif düğme "neden çalışmıyor" sorusu doğurur.</para>
/// </summary>
public static class SigortaUclari
{
    public sealed record PoliceIstegiGovdesi(int TarafId, int KurumId, int? HekimId,
                                             string? PoliceNo, string? Tarih);

    public sealed record ProvizyonIstegiGovdesi(int BelgeId, short? Tip, short? AltTip,
                                                short? HizmetTipi, short? VakaTipi,
                                                short? TalepTuru, bool? Acil, string? Not);

    public sealed record IptalIstegiGovdesi(short NedenKodu, string? Aciklama);

    public sealed record DokumanIstegiGovdesi(string TipKodu, int? DokumanId,
                                              string? DosyaAdi, string? Mime,
                                              string? IcerikBase64);

    public static void SigortaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/sigorta").WithTags("Sigorta").RequireAuthorization();

        // GET /api/sigorta/saglayicilar - adapter kataloğu + yetenekler
        grup.MapGet("/saglayicilar", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select s.id, s.kod, s.ad, s.yetenekler::text, s.durum,
                       (select count(*) from public.sigorta_hesap h
                         where h.saglayici_id = s.id and h.durum = 0) as hesap
                  from public.sigorta_saglayici s
                 order by s.durum, s.ad
                """, null,
                o => new { Id = o.GetInt16(0), Kod = o.GetString(1), Ad = o.GetString(2),
                           Yetenekler = o.GetString(3), Durum = o.GetInt16(4),
                           Hesap = o.GetInt64(5) }, iptal);

            return Results.Ok(new { saglayicilar = liste, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/sigorta/police-sorgu
        grup.MapPost("/police-sorgu", async (
            PoliceIstegiGovdesi istek, BaglamCozucu cozucu, SigortaServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta", Islem.Gor);

            var tarih = DateTime.TryParse(istek.Tarih, out var t) ? t : DateTime.Now;
            var (id, sonuc) = await servis.PoliceSorgulaAsync(
                istek.TarafId, istek.KurumId, istek.HekimId, istek.PoliceNo ?? "",
                tarih, baglam, iptal);

            return Results.Ok(new
            {
                id, sonuc.Gecerli, sonuc.PoliceNo, sonuc.PoliceAdi, sonuc.KartNo,
                sonuc.MusteriNo, sonuc.AgKodu, notlar = sonuc.Notlar,
                mesaj = sonuc.Gecerli ? "Poliçe bu kurumda geçerli."
                                      : "Poliçe geçerli görünmüyor - notlara bakın.",
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/sigorta/provizyon - başvurudan provizyon oluştur/güncelle
        grup.MapPost("/provizyon", async (
            ProvizyonIstegiGovdesi istek, BaglamCozucu cozucu, SigortaServisi servis,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta.provizyon", Islem.Degistir);

            var ayar = new SigortaServisi.ProvizyonAyari(
                Tip: istek.Tip ?? SigortaKanonik.ProvizyonTipi.Ayakta,
                AltTip: istek.AltTip,
                HizmetTipi: istek.HizmetTipi ?? 1,     // GENERAL
                VakaTipi: istek.VakaTipi ?? 1,         // genel başvuru
                TalepTuru: istek.TalepTuru ?? SigortaKanonik.TalepTuru.Provizyon,
                Acil: istek.Acil ?? false,
                Not: istek.Not ?? "");

            var id = await servis.ProvizyonYazAsync(istek.BelgeId, ayar, baglam, iptal);
            var ozet = await OzetAsync(veri, id, iptal);
            return Results.Ok(new { id, ozet, mesaj = OzetMesaji(ozet),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/sigorta/provizyon/{id} - kanonik provizyon + satır + not
        grup.MapGet("/provizyon/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta", Islem.Gor);

            var ozet = await OzetAsync(veri, id, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Provizyon bulunamadı.");

            var satirlar = await veri.ListeAsync("""
                select s.id, s.satir_turu, s.kod, s.ad, s.adet, s.talep_tutar,
                       s.sirket_tutar, s.katilim_payi, s.istisna_tutar,
                       s.muafiyet_tutar, s.limit_ustu, s.odenecek, s.kapsam,
                       s.karar_tipi, s.aciklama, s.belge_satir_id
                  from public.sigorta_provizyon_satir s
                 where s.provizyon_id = @p0 order by s.id
                """, [id],
                o => new { Id = o.GetInt32(0), SatirTuru = o.GetInt16(1),
                           Kod = o.GetString(2), Ad = o.GetString(3),
                           Adet = o.GetDecimal(4), TalepTutar = o.GetDecimal(5),
                           SirketTutar = o.GetDecimal(6), KatilimPayi = o.GetDecimal(7),
                           IstisnaTutar = o.GetDecimal(8), MuafiyetTutar = o.GetDecimal(9),
                           LimitUstu = o.GetDecimal(10), Odenecek = o.GetDecimal(11),
                           Kapsam = o.GetString(12), KararTipi = o.GetString(13),
                           Aciklama = o.GetString(14),
                           BelgeSatirId = o.IsDBNull(15) ? (int?)null : o.GetInt32(15) },
                iptal);

            var tanilar = await veri.ListeAsync("""
                select kod, ad from public.sigorta_provizyon_tani
                 where provizyon_id = @p0 order by sira, id
                """, [id], o => new { Kod = o.GetString(0), Ad = o.GetString(1) }, iptal);

            var notlar = await veri.ListeAsync("""
                select tip, metin from public.sigorta_provizyon_not
                 where provizyon_id = @p0 order by id
                """, [id], o => new { Tip = o.GetString(0), Metin = o.GetString(1) }, iptal);

            var dokumanlar = await veri.ListeAsync("""
                select id, tip_kodu, dosya_adi, durum, hata, gonderim
                  from public.sigorta_dokuman where provizyon_id = @p0 order by id
                """, [id],
                o => new { Id = o.GetInt32(0), TipKodu = o.GetString(1),
                           DosyaAdi = o.GetString(2), Durum = o.GetInt16(3),
                           Hata = o.GetString(4),
                           Gonderim = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5) },
                iptal);

            return Results.Ok(new { ozet, satirlar, tanilar, notlar, dokumanlar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/sigorta/provizyon/{id}/tazele
        grup.MapPost("/provizyon/{id:int}/tazele", async (
            int id, BaglamCozucu cozucu, SigortaServisi servis, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta", Islem.Gor);

            await servis.ProvizyonTazeleAsync(id, baglam, iptal);
            var ozet = await OzetAsync(veri, id, iptal);
            return Results.Ok(new { id, ozet, mesaj = OzetMesaji(ozet),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/sigorta/provizyon/{id}/iptal
        grup.MapPost("/provizyon/{id:int}/iptal", async (
            int id, IptalIstegiGovdesi istek, BaglamCozucu cozucu, SigortaServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta.iptal", Islem.Degistir);

            if (istek.NedenKodu <= 0)
                throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                    [new("nedenKodu", "İptal nedeni seçilmeli.")]);

            var mesaj = await servis.ProvizyonIptalAsync(id, istek.NedenKodu,
                            istek.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/sigorta/provizyon/{id}/dokuman
        grup.MapPost("/provizyon/{id:int}/dokuman", async (
            int id, DokumanIstegiGovdesi istek, BaglamCozucu cozucu,
            SigortaServisi servis, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta.provizyon", Islem.Degistir);

            byte[] icerik;
            string ad = istek.DosyaAdi ?? "", mime = istek.Mime ?? "";

            if (istek.DokumanId is > 0)
            {
                // İÇERİK MEVCUT DEPODAN: aynı epikrizin ikinci kopyasını
                //   üretmemek için doküman kaydı yeniden yüklenmez.
                var d = await veri.TekAsync("""
                    select d.ad, coalesce(d.icerik_tipi, ''), d.icerik
                      from public.dokuman d where d.id = @p0
                    """, [istek.DokumanId.Value],
                    o => new { Ad = o.GetString(0), Mime = o.GetString(1),
                               Icerik = o.IsDBNull(2) ? Array.Empty<byte>()
                                                      : (byte[])o.GetValue(2) }, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Doküman bulunamadı.");
                icerik = d.Icerik;
                if (ad.Length == 0) ad = d.Ad;
                if (mime.Length == 0) mime = d.Mime;
            }
            else if (istek.IcerikBase64 is { Length: > 0 } b64)
            {
                icerik = Convert.FromBase64String(b64);
            }
            else
            {
                throw GentegreHatasi.Dogrulama("Gönderilecek içerik yok.",
                    [new("dokumanId", "Doküman seçin ya da içerik gönderin.")]);
            }

            if (icerik.Length == 0)
                throw GentegreHatasi.IsKurali("Doküman içeriği boş.");

            var kayitId = await servis.DokumanGonderAsync(id, istek.TipKodu, ad, mime,
                              icerik, istek.DokumanId, baglam, iptal);
            return Results.Ok(new { id = kayitId, mesaj = "Doküman gönderildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/sigorta/hesap/{id}/test - jeton alıp bağlantıyı doğrular.
        //   SAHTE BAŞARI YOK: hesap eksikse ya da servis reddederse hata döner
        //   (İTS ve e-Nabız'daki standing kural).
        grup.MapPost("/hesap/{id:int}/test", async (
            int id, BaglamCozucu cozucu, SigortaServisi servis, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("sigorta.ayar", Islem.Degistir);

            var kurumId = await veri.TekDegerAsync<int>(
                "select kurum_id from public.sigorta_hesap where id = @p0", [id], iptal);
            if (kurumId == 0) throw GentegreHatasi.Bulunamadi("Sigorta hesabı bulunamadı.");

            var b = await servis.HesapCozAsync(kurumId, baglam.SubeId, iptal);
            // YALNIZ JETON: sahte kimlikle poliçe sorgusu denemek yanıltıcı -
            //   ASMED test ortamı sıfırlardan oluşan kimlik numarasına hiç
            //   yanıt vermiyor, istek zaman aşımına düşüyor ve "servis
            //   çalışmıyor" sanılıyordu. Kimlik akışı zaten kapının kendisi.
            var mesaj = await b.Saglayici.BaglantiTestAsync(b.Hesap, iptal);

            return Results.Ok(new
            {
                id, saglayici = b.Hesap.SaglayiciKod, test = b.Hesap.TestMi,
                baglanti = true, notlar = Array.Empty<string>(),
                mesaj,
                izlemeNo = baglam.IzlemeNo,
            });
        });
    }

    private static async Task<object?> OzetAsync(VeriKaynagi veri, int id,
                                                 CancellationToken iptal)
        => await veri.TekAsync("""
            select p.id, p.belge_id, p.provizyon_no, p.kurum_ref_no, p.durum, p.tip,
                   p.talep_toplam, p.sirket_payi, p.hasta_payi, p.karar_tipi,
                   p.red_nedeni, p.provizyon_tarihi, s.ad as saglayici,
                   coalesce(k.unvan, '') as kurum
              from public.sigorta_provizyon p
              join public.sigorta_saglayici s on s.id = p.saglayici_id
              left join public.sigorta_hesap h on h.id = p.hesap_id
              left join public.taraf k on k.id = h.kurum_id
             where p.id = @p0
            """, [id],
            o => (object)new
            {
                Id = o.GetInt32(0), BelgeId = o.GetInt32(1), ProvizyonNo = o.GetString(2),
                KurumRefNo = o.GetString(3), Durum = o.GetInt16(4), Tip = o.GetInt16(5),
                TalepToplam = o.GetDecimal(6), SirketPayi = o.GetDecimal(7),
                HastaPayi = o.GetDecimal(8), KararTipi = o.GetString(9),
                RedNedeni = o.GetString(10), ProvizyonTarihi = o.GetDateTime(11),
                Saglayici = o.GetString(12), Kurum = o.GetString(13),
            }, iptal);

    private static string OzetMesaji(object? ozet)
    {
        if (ozet is null) return "Provizyon kaydedilemedi.";
        var tip = ozet.GetType();
        var durum = (short)(tip.GetProperty("Durum")?.GetValue(ozet) ?? (short)0);
        var no = tip.GetProperty("ProvizyonNo")?.GetValue(ozet)?.ToString() ?? "";
        var sirket = (decimal)(tip.GetProperty("SirketPayi")?.GetValue(ozet) ?? 0m);
        var hasta = (decimal)(tip.GetProperty("HastaPayi")?.GetValue(ozet) ?? 0m);

        return durum switch
        {
            SigortaKanonik.Durum.Onayli =>
                $"Provizyon onaylandı ({no}) · kurum {sirket:0.00} · hasta {hasta:0.00}",
            SigortaKanonik.Durum.Kismi =>
                $"Provizyon kısmi onaylandı ({no}) · kurum {sirket:0.00} · hasta {hasta:0.00}",
            SigortaKanonik.Durum.Red => $"Provizyon reddedildi ({no}).",
            SigortaKanonik.Durum.Iptal => "Provizyon iptal edildi.",
            _ => $"Provizyon gönderildi ({no}).",
        };
    }
}
