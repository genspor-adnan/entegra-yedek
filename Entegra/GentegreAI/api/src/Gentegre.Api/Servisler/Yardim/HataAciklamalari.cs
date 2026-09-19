using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Api.Servisler.Yardim;

/// <summary>
/// HATA KODU AÇIKLAMALARI (871) — "bu hata ne demek" sorusunun kaynağı.
///
/// Kodlar sözleşme §1.2'deki sabit küme + iş kuralı engellerinin bilinen
/// kodları. Açıklama <b>kullanıcı diliyle</b> yazılır: ne oldu, ne yapılır.
/// İstemciden gelen kod bu listede yoksa bağlama alınmaz - asistan
/// "tanımadığım bir kod" der, açıklama uydurmaz.
/// </summary>
public static class HataAciklamalari
{
    public sealed record Aciklama(string Kod, string Baslik, string Ne, string NeYapilir);

    private static readonly Dictionary<string, Aciklama> Liste = new(StringComparer.Ordinal)
    {
        [HataKodu.Dogrulama] = new(HataKodu.Dogrulama, "Doğrulama hatası",
            "Formdaki bir ya da birkaç alan kurala uymuyor (zorunlu alan boş, uzunluk aşıldı, biçim yanlış). Hatalı alanlar formda kırmızı işaretlenir.",
            "İşaretli alanları düzeltip yeniden kaydedin. Alan zorunluysa boş bırakılamaz; kimlik no ve telefon biçimi şubenin ülkesine göre denetlenir."),
        [HataKodu.Yetkisiz] = new(HataKodu.Yetkisiz, "Oturum yok / süresi dolmuş",
            "Oturumunuz kapanmış ya da süresi dolmuş; sunucu kim olduğunuzu doğrulayamıyor.",
            "Yeniden giriş yapın. Sık tekrarlıyorsa yöneticiniz oturum süresini (Güvenlik ayarları) uzatabilir."),
        [HataKodu.IlkParola] = new(HataKodu.IlkParola, "İlk parola belirlenmemiş",
            "Hesap açılmış ama parola hiç tanımlanmamış.",
            "Giriş ekranındaki \"Parola belirle\" adımını tamamlayın ya da \"Şifremi Unuttum\" ile kod isteyin."),
        [HataKodu.Yasak] = new(HataKodu.Yasak, "Yetki yok",
            "Bu işlem ya da ekran için rolünüzde yetki tanımlı değil; ya da bulunduğunuz şubede yalnız görüntüleme hakkınız var.",
            "Yöneticinizden ilgili yetkiyi (Yönetim › Roller) ya da şube yazma hakkını isteyin. Asistan yetkiniz olmayan işlemin adımlarını anlatmaz."),
        [HataKodu.Bulunamadi] = new(HataKodu.Bulunamadi, "Kayıt bulunamadı",
            "Aradığınız kayıt yok ya da sizin kapsamınızın (şube / portal) dışında. İkisi aynı mesajla döner: var olup göremediğiniz kayıt \"yok\" görünür.",
            "Kayıt numarasını ve aktif şubeyi kontrol edin. Başka şubenin kaydıysa üst şeritten şube değiştirin (yetkiniz varsa)."),
        [HataKodu.Cakisma] = new(HataKodu.Cakisma, "Eşzamanlı değişiklik",
            "Siz kartı açtıktan sonra başkası aynı kaydı değiştirmiş; sizin sürümünüz eskidi.",
            "Kartı yenileyin (sunucunun döndürdüğü güncel değerler gösterilir), değişikliğinizi güncel sürüm üzerine yeniden yapın."),
        [HataKodu.IsKurali] = new(HataKodu.IsKurali, "İş kuralı engeli",
            "İşlem bir kurumsal kurala takıldı (örn. faturası olan cari silinemez, kapanmış başvuruya istem açılamaz). Mesaj kuralın kendisini söyler.",
            "Mesajdaki ön koşulu yerine getirin ya da işlemi yapmayın. Bazı kurallar onayla aşılabilir - ekran o zaman \"yine de devam\" sorar."),
        [HataKodu.Sunucu] = new(HataKodu.Sunucu, "Beklenmeyen sunucu hatası",
            "Sunucuda öngörülmeyen bir hata oluştu; ayrıntı güvenlik gereği kullanıcıya gösterilmez.",
            "İşlemi bir kez daha deneyin. Sürüyorsa izleme numarasını (izlemeNo) destek ekibine iletin - kayıt sunucu günlüğünde bu numarayla bulunur."),
        // İş kuralı ENGEL kodları (engel.kod) - onayla aşılabilen kurallar.
        ["BD_ONAY"] = new("BD_ONAY", "Bowie-Dick testi onayı",
            "Sterilizasyon: bugün bu cihazda Bowie-Dick testi yapılmadan yükleme döngüsü başlatılmak isteniyor.",
            "Önce test döngüsünü çalıştırın ya da kurum kuralı izin veriyorsa onay notu yazarak devam edin."),
        ["KARANTINA"] = new("KARANTINA", "Paket karantinada",
            "Okutulan steril paketin biyolojik indikatör sonucu henüz gelmedi; paket karantinada.",
            "Sonucu bekleyin ya da acil durumda \"yine de kullan\" onayı verin - kullanım kayda geçer, sonuç pozitif çıkarsa geri çağırma açılır."),
        ["AKILCI_ENGEL"] = new("AKILCI_ENGEL", "Akılcı test istemi engeli",
            "Bakanlık Akılcı Test İstem Listesi'ne göre bu test bu tesiste istenemez: ya yalnız 3. basamakta çalışılıyor ya da liste dışı (kapalı).",
            "Testi listeden çıkarın. 3. basamak testi için hastanın uygun tesise sevkini önerin; tesis basamağı yanlışsa yöneticiniz şube kartından düzeltir."),
        ["AKILCI_UYARI"] = new("AKILCI_UYARI", "Akılcı test istemi uyarısı",
            "Test ya branşınıza doğrudan açık değil ya da tekrar aralığı dolmadan yeniden isteniyor (son sonuç ekranda gösterilir).",
            "Devam etmek için SKRS gerekçesini seçin (klinik uyumsuzluk, tedavi takibi, replasman izlem, yeni hastalık; branş için klinik gerekçe) - karar kayda geçer. Vazgeçerseniz test istemden çıkar, o da kaydedilir."),
        ["SERBEST_EKSIK"] = new("SERBEST_EKSIK", "Serbest bırakma ön koşulu eksik",
            "Döngü serbest bırakılmak isteniyor ama zorunlu indikatör ya da parametre girilmemiş.",
            "Döngü kartında eksik indikatör sonucunu / parametreyi girin, sonra serbest bırakın."),
    };

    public static Aciklama? Bul(string? kod)
        => string.IsNullOrWhiteSpace(kod) ? null
           : Liste.TryGetValue(kod.Trim().ToUpperInvariant(), out var a) ? a : null;

    public static bool Bilinir(string? kod) => Bul(kod) is not null;
}
