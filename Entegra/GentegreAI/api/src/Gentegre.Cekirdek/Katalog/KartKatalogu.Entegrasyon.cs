namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ENTEGRASYON HESABI KARTI (336).
///
/// Dış servislerin kimlikleri tek yerde: SKRS/Sağlık.NET, e-Nabız, MEDULA,
/// ÜTS, e-Belge entegratörü, SMS. Her satır bir (entegrasyon · şube · ortam)
/// üçlüsüdür - şubesi boş kayıt kurum genelidir, şubeli kayıt onu ezer.
///
/// Şifre alanı düz metin saklanıyor (mevcut e-Belge/ÜTS ile aynı durum);
/// şifreleme ayrı iş. Kart dışında hiçbir uç şifreyi geri döndürmez.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi EntegrasyonHesap() => new(
        Ad: "entegrasyon-hesap",
        YetkiKodu: "entegrasyon",
        Tablo: "public.entegrasyon_hesap",
        LogTabloId: 951,
        // Sube ALAN olarak girilir (bos = kurum geneli) - otomatik damgalanmaz.
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1, ["test_mi"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",   "id",   "sayi", Yazilabilir: false),
            new("kod",  "kod",  "kod",  Zorunlu: true,
                SabitKodlar: EntegrasyonKodlari,
                Baslik: "Entegrasyon", Grup: "Kimlik"),
            new("ad",   "ad",   "metin", EnFazlaUzunluk: 120,
                Baslik: "Ad", Grup: "Kimlik"),
            new("subeId", "sube_id", "kod", KodTablosu: "public.sube",
                Baslik: "Şube (boş = tümü)", Grup: "Kimlik"),
            // Test/canli AYNI kartta degil AYRI SATIRDIR: kurum canliya
            //   gecerken test hesabini silmez, ikisi yan yana durur.
            new("testMi", "test_mi", "mantik", Baslik: "Test Ortamı", Grup: "Kimlik"),
            new("aktif",  "aktif",   "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            new("kullaniciAdi", "kullanici_adi", "metin", EnFazlaUzunluk: 100,
                Baslik: "Kullanıcı Adı", Grup: "Hesap"),
            new("sifre",        "sifre",         "metin", EnFazlaUzunluk: 200,
                Baslik: "Şifre", Grup: "Hesap"),
            // SKRS'de "UygulamaKodu", MEDULA'da tesis kodu gibi ucuncu kimlik.
            new("uygulamaKodu", "uygulama_kodu", "metin", EnFazlaUzunluk: 100,
                Baslik: "Uygulama Kodu", Grup: "Hesap"),
            new("kurumKodu",    "kurum_kodu",    "metin", EnFazlaUzunluk: 50,
                Baslik: "Kurum / Tesis Kodu", Grup: "Hesap"),

            new("url",     "url",      "metin", EnFazlaUzunluk: 300,
                Baslik: "Canlı Adres", Grup: "Adres"),
            new("testUrl", "test_url", "metin", EnFazlaUzunluk: 300,
                Baslik: "Test Adresi", Grup: "Adres"),

            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Adres"),
            // Son kullanim/sonuc SERVIS tarafindan yazilir - salt okunur.
            new("sonKullanim", "son_kullanim", "zaman", Yazilabilir: false,
                Baslik: "Son Kullanım", Grup: "Adres"),
            new("sonSonuc",    "son_sonuc",    "metin", Yazilabilir: false,
                Baslik: "Son Sonuç", Grup: "Adres"),
        });
}
