using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// ROL KAPSAMI KAPISI (RolKapsami): dar kapsamlı kullanıcı (saha temsilcisi) kapsam dışı kaydı ne okur ne yazar.
/// Liste ve kart GET sorguya koşulu ekler; PUT / DELETE / detay / aksiyon uçları ise YAZMADAN ÖNCE buradan sorar -
/// kapsam dışı kayıt "bulunamadı" (var olduğu bile söylenmez).
/// </summary>
public static class RolKapsamKapisi
{
    public static async Task IsteAsync(KartDeposu depo, KartTanimi tanim, IstekBaglami baglam, long id,
                                       CancellationToken iptal)
    {
        var kosul = baglam.RolKosulu(tanim.RolKosullari);
        if (kosul is null) return;
        if (!await depo.KapsamdaMiAsync(tanim, id, kosul, baglam.KullaniciId, iptal))
            throw GentegreHatasi.Bulunamadi();
    }

    public static Task IsteAsync(KartDeposu depo, string kartAdi, IstekBaglami baglam, long id, CancellationToken iptal)
        => IsteAsync(depo, KartKatalogu.Bul(kartAdi) ?? throw new InvalidOperationException($"Kart yok: {kartAdi}"),
                     baglam, id, iptal);

    /// <summary>
    /// YAZMA KURALI: dar kapsamlı temsilci ziyareti yalnız KENDİ adına açar / tutar - `temsilciId` isteğe
    /// bakılmadan kendisine yazılır (yeni kayıtta her zaman, değişiklikte alan gönderildiyse).
    /// </summary>
    public static void YazmaKurali(KartTanimi tanim, IstekBaglami baglam, IDictionary<string, object?> degerler, bool yeni)
    {
        if (tanim.Ad != KartKatalogu.DisHekimZiyaretAdi || !baglam.DarKapsam(tanim.RolKosullari)) return;
        if (yeni || degerler.ContainsKey("temsilciId")) degerler["temsilciId"] = baglam.KullaniciId;
    }
}
