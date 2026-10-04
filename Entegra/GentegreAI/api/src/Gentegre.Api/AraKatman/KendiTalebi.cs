using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// KENDİ TALEBİ (Taleplerim, mockup <c>Ekranlar/Taleplerim/taleplerim.html</c>):
/// herkes kendi iznini, avansını, masrafını ve belge talebini İK yetkisi
/// olmadan açar, onaya gönderir ve geri çeker. Başkasının adına işlem yine
/// İK yetkisi ister - kural tek yerde, uçlar onu çağırır.
///
/// "Kendi" = talebin <c>taraf_id</c>'si oturumdaki kullanıcı (kullanıcı kimliği
/// taraf kimliğidir, <c>taraf_kullanici.id</c>). Onay kararı bu yoldan geçmez -
/// onay omurgası kendi kurallarıyla (kendi talebini onaylayamaz) ayrı uçta.
/// </summary>
public static class KendiTalebi
{
    /// <summary>Talep oturumdaki kişinin kendisi için ise yetki aranmaz; değilse İK yetkisi.</summary>
    public static void YetkiIsteKendi(this IstekBaglami baglam, int tarafId, string yetkiKodu, Islem islem)
    {
        if (tarafId > 0 && tarafId == baglam.KullaniciId) return;
        baglam.YetkiIste(yetkiKodu, islem);
    }

    /// <summary>
    /// Var olan kayıt üzerinde işlem: kaydın sahibini okur, kendi kaydıysa yetki
    /// aranmaz. <paramref name="sahipSql"/> tek parametreli (@p0 = kimlik) ve
    /// taraf_id döner. Kayıt yoksa İK yetkisi istenir - uç kendi "bulunamadı"sını verir.
    /// </summary>
    public static async Task IsteAsync(VeriKaynagi veri, IstekBaglami baglam, string sahipSql, int id,
                                       string yetkiKodu, Islem islem, CancellationToken iptal)
    {
        var sahip = await veri.TekDegerAsync<int?>(sahipSql, [id], iptal);
        baglam.YetkiIsteKendi(sahip ?? 0, yetkiKodu, islem);
    }
}
