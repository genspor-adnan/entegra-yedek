using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ISTEK BASLIGINI DOGRULA + DB DEGERLERINE CEVIR - tek yer.
///
/// Belge ve kasa uclari bu dongunun kendi kopyasini tasiyordu; govde (beyaz
/// liste kontrolu, <see cref="DegerCevirici"/> cagrisi, uzunluk kesme, alan
/// hatasi uretimi) satir satir aynidiydi, yalnizca alan tablolari farkliydi.
/// Kural bir tarafta duzeltilince oteki geride kaliyordu.
///
/// BEYAZ LISTE ILKESI: istemciden gelen alan adi hicbir zaman dogrudan SQL'e
/// girmez - katalogda karsiligi olmayan ad istegi reddeder.
/// </summary>
public static class BaslikDogrulayici
{
    /// <param name="gelen">Istek govdesindeki baslik alanlari.</param>
    /// <param name="tipBul">Alan adi -> deger tipi ("sayi"/"para"/"tarih"/"metin"); yoksa null.</param>
    /// <param name="uzunlukBul">Metin alaninin DB uzunlugu; sinirsizsa null.</param>
    /// <param name="varlikAdi">Hata mesajinda gecen ad ("belge alani", "kasa işlemi alanı").</param>
    /// <param name="sunucuAlanlari">
    /// Istemcinin GONDEREMEYECEGI alanlar (sunucu belirler: numara, durum, toplam...).
    /// Sessizce yok saymak yerine reddedilir - istemci gonderdiginin yazildigini sanmasin.
    /// </param>
    public static Dictionary<string, object?> Cevir(
        Dictionary<string, JsonElement>? gelen,
        Func<string, string?> tipBul,
        Func<string, int?> uzunlukBul,
        string varlikAdi,
        IReadOnlySet<string>? sunucuAlanlari = null)
    {
        var sonuc = new Dictionary<string, object?>(StringComparer.Ordinal);
        if (gelen is null) return sonuc;

        foreach (var (ad, deger) in gelen)
        {
            if (sunucuAlanlari?.Contains(ad) == true)
                throw GentegreHatasi.Dogrulama($"{ad} sunucuda belirlenir, istekte gönderilemez.",
                    new AlanHatasi(ad, "Sunucu alanı."));

            var tip = tipBul(ad)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen {varlikAdi}: {ad}",
                       new AlanHatasi(ad, "Başlıkta böyle bir alan yok."));

            var cevrilmis = DegerCevirici.Cevir(deger, tip, ad, ad);

            // Uzunluk SUNUCUDA kesilir: aksi halde PG "value too long for type
            //   character varying(5)" ile 500 veriyor ve kullanici neyin uzun
            //   oldugunu ogrenemiyordu (gercek vaka: istemci UTF-8'i bozunca
            //   "Hariç" 6 karakter olmustu).
            if (uzunlukBul(ad) is { } sinir && cevrilmis is string m && m.Length > sinir)
                throw GentegreHatasi.Dogrulama($"{ad}: en fazla {sinir} karakter.",
                    new AlanHatasi(ad, $"En fazla {sinir} karakter ({m.Length} geldi)."));

            sonuc[ad] = cevrilmis;
        }
        return sonuc;
    }
}
