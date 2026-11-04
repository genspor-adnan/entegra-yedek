using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Kimlik;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KİMLİĞİ OKUT - MRZ (1255, mockup Ekranlar/Kayıt Kabul/kimlik_mrz_okut.html). OCR tarayıcıda; buraya yalnız 2-3 satır
/// metin gelir (görüntü sunucuya ve diske GİTMEZ - KVKK). Sunucu: alanları çözer (MrzCozucu), kontrol haneleri ve T.C.
/// algoritması, kimlik no / pasaport no ile kayıtlı hastayı bulur, uyruğu SKRS listesine eşler, süresi dolmuş belge
/// kuralını uygular, okutmayı işlem loguna yazar (953, "mrz"). Karta yazma kartın normal kaydıdır - ayrı uç yok.
/// </summary>
public static class MrzUclari
{
    public sealed record CozIstegi(string Metin);

    /// <summary>Kimlik belgesi türü (taraf_hasta.belge_turu): 1 kimlik kartı · 2 pasaport · 3 diğer.</summary>
    public static readonly IReadOnlyDictionary<string, string> BelgeTurleri = new Dictionary<string, string>
    {
        ["1"] = "Kimlik Kartı", ["2"] = "Pasaport", ["3"] = "Diğer (ikamet, sürücü belgesi)",
    };

    public static void MrzUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kimlik").WithTags("Kimlik MRZ").RequireAuthorization();

        // POST /api/kimlik/mrz-coz {metin} - hasta kartı ekleyebilen ya da değiştirebilen kullanıcı.
        grup.MapPost("/mrz-coz", async (CozIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("hasta", Islem.Ekle) && !baglam.Yetkiler.Var("hasta", Islem.Degistir))
                throw GentegreHatasi.Yasak("Hasta kartı ekleme / değiştirme yetkiniz yok.");
            var metin = istek.Metin ?? "";
            if (metin.Length > 400) throw GentegreHatasi.Dogrulama("MRZ metni en çok 3 satır × 44 karakterdir.");

            await using var b = await veri.AcAsync(iptal);
            var okutma = await AyarDeposu.SayiAsync(b, null, "kayit.kimlik_okutma", iptal);
            if (okutma == 0) throw GentegreHatasi.IsKurali("Kimlik okutma bu kurulumda kapalı (Kayıt Kabul Ayarları › Hasta).");

            var sonuc = MrzCozucu.Coz(metin, DateOnly.FromDateTime(Saat.Bugun));
            if (sonuc is null)
                return Results.Ok(new { gecerli = false, hatalar = new[] { "MRZ satırları tanınmadı: kimlik kartında 3 × 30, pasaportta 2 × 44 karakter beklenir." },
                                        satirlar = MrzCozucu.Satirlar(metin) });

            var bugun = DateOnly.FromDateTime(Saat.Bugun);
            var suresiDolmus = sonuc.SonKullanma is { } skt && skt < bugun;
            var engelle = await AyarDeposu.SayiAsync(b, null, "kayit.suresi_dolmus_belge", iptal) == 1;
            var uyarilar = new List<string>();
            if (suresiDolmus) uyarilar.Add(engelle
                ? $"Belgenin geçerliliği {sonuc.SonKullanma:dd.MM.yyyy} tarihinde dolmuş - kurum ayarı gereği karta aktarılamaz."
                : $"Belgenin geçerliliği {sonuc.SonKullanma:dd.MM.yyyy} tarihinde dolmuş - kayıt engellenmez, kimlik alanına uyarı düşer.");

            // Kimlik no biçimi (679/916): 'tc' ise pasaport no kimlik alanına yazılamaz - kart kaydı reddeder, önceden söyle.
            var kimlikBicimi = await b.TekDegerAsync<string?>(
                "select bicim from public.fn_kimlik_kurali(@p0)", null, [baglam.SubeId ?? 0], iptal) ?? "serbest";
            var belgeTuru = sonuc.Bicim == "TD3" || sonuc.BelgeKodu.StartsWith('P') ? 2 : sonuc.BelgeKodu.StartsWith('I') ? 1 : 3;
            if (sonuc.Gecerli && sonuc.KimlikNo == "" && kimlikBicimi == "tc")
                uyarilar.Add("Kurum profili kimlik no biçimi \"T.C. Kimlik No\" - pasaport numarası kimlik alanına yazılamaz; yabancı hastada biçimi \"serbest\" yapın ya da Kimliksiz / Pasaport No alanlarını kullanın.");

            // Uyruk: ISO alpha-3 → SKRS hasta.uyruk kodu (ad ile; listede ISO kodu yok). Bulunamazsa kullanıcı seçer.
            string? uyrukKod = null;
            var uyrukAdi = MrzCozucu.UlkeAdi(sonuc.Uyruk);
            if (uyrukAdi is not null)
                uyrukKod = await b.TekDegerAsync<string?>("""
                    select d.deger from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                     where l.kod = 'hasta.uyruk' and d.dil = 0 and d.aktif = 1 and d.ad ilike @p0 || '%'
                     order by length(d.ad) limit 1
                    """, null, [uyrukAdi], iptal);

            // Kayıtlı hasta: T.C. kimlik no (TD1) ya da pasaport no (TD2 / TD3).
            IDictionary<string, object?>? eslesen = null;
            if (sonuc.Gecerli && (sonuc.KimlikNo != "" || sonuc.BelgeNo != ""))
            {
                var tcIle = sonuc.KimlikNo != "";
                eslesen = await b.TekAsync($"""
                    select t.id, t.kod, t.ad, t.soyad, t.vkno as "kimlikNo", t.durum,
                           th.dogum_tarihi as "dogumTarihi", th.cinsiyet, th.uyruk, th.pasaport_no as "pasaportNo",
                           th.belge_turu as "belgeTuru", th.belge_seri_no as "belgeSeriNo", th.belge_son_kullanma as "belgeSonKullanma",
                           (select max(x.belge_tarihi) from public.belge x where x.taraf_id = t.id and x.tur = 19) as "sonBasvuru"
                      from public.taraf t
                      left join public.taraf_hasta th on th.id = t.id
                     where t.hasta = 1 and {(tcIle ? "t.vkno = @p0" : "th.pasaport_no = @p0 and coalesce(th.pasaport_no, '') <> ''")}
                     order by t.durum, t.id
                     limit 1
                    """, null, [tcIle ? sonuc.KimlikNo : sonuc.BelgeNo], OkuyucuGenisletmeleri.Sozluk, iptal);
            }

            await log.YazAsync(LogIslemi.Ekle, MernisUclari.LogKimlikSorgu, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "mrz", bicim = sonuc.Bicim, gecerli = sonuc.Gecerli, kimlikNo = sonuc.KimlikNo,
                      belgeNo = sonuc.BelgeNo, eslesenId = eslesen?["id"], suresiDolmus },
                tarafId: eslesen?["id"] is int tid ? tid : null, iptal: iptal);

            return Results.Ok(new
            {
                gecerli = sonuc.Gecerli, hatalar = sonuc.Hatalar, satirlar = sonuc.Satirlar,
                bicim = sonuc.Bicim, belgeKodu = sonuc.BelgeKodu, belgeTuru, duzenleyenUlke = sonuc.DuzenleyenUlke,
                belgeNo = sonuc.BelgeNo, belgeNoTamam = sonuc.BelgeNoTamam,
                dogumTarihi = sonuc.DogumTarihi?.ToString("yyyy-MM-dd"), dogumTamam = sonuc.DogumTamam,
                // Kart kod listesi hasta.cinsiyet: 1 Erkek · 2 Kadın (MernisUclari ile aynı).
                cinsiyet = sonuc.Cinsiyet == "E" ? "1" : sonuc.Cinsiyet == "K" ? "2" : "",
                sonKullanma = sonuc.SonKullanma?.ToString("yyyy-MM-dd"), sonKullanmaTamam = sonuc.SonKullanmaTamam,
                suresiDolmus, engellendi = suresiDolmus && engelle,
                uyruk = sonuc.Uyruk, uyrukAdi, uyrukKod,
                kimlikNo = sonuc.KimlikNo, soyad = sonuc.Soyad, ad = sonuc.Ad, bilesikTamam = sonuc.BilesikTamam,
                kimlikBicimi, uyarilar, eslesen,
            });
        });
    }
}
