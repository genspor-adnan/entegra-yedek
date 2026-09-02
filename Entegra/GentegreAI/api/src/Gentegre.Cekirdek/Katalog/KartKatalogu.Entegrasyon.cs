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
            // Baz sube VARSAYILAN "Kendisi" (0, kullanici): yeni hesap kendi
            //   subesinin kimligiyle calisir; baska subeye baglamak bilincli
            //   bir secim olsun. Combo bos acilinca kullanici zorunlu olmayan
            //   alani atliyor ve satir "baz yok" mu "secilmedi" mi belirsiz
            //   kaliyordu.
            ["aktif"] = (short)1, ["test_mi"] = (short)1, ["baz_sube_id"] = (short)0,
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
            // BAZ SUBE (338, 227 deseni): sube baska bir subenin hesabiyla
            //   calisacaksa burada YAZILI olur - "kendi satiri yoksa kurum
            //   geneline duser" ortuk kuralina birakilmaz. 0 = Kendisi.
            new("bazSubeId", "baz_sube_id", "kod",
                KodTablosu: "public.v_sube_baz_lookup",
                Baslik: "Baz Alınacak Şube", Grup: "Kimlik"),
            // Test/canli AYNI kartta degil AYRI SATIRDIR: kurum canliya
            //   gecerken test hesabini silmez, ikisi yan yana durur.
            new("testMi", "test_mi", "mantik", Baslik: "Test Ortamı", Grup: "Kimlik"),
            new("aktif",  "aktif",   "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            // MOCKUP DUZENI (Ekranlar/Ayarlar/entegrasyon_hesaplari.html):
            //   Kimlik ust seritte, Hesap ve Adres TEK SAYFADA iki kutu -
            //   bes alanlik kart icin sekme acmak ekrani bolerdi.
            new("kullaniciAdi", "kullanici_adi", "metin", EnFazlaUzunluk: 100,
                Baslik: "Kullanıcı Adı", Grup: "Genel", AltGrup: "Hesap"),
            // UTS sistem token'i 200 karakteri asiyor (337) - kolon `text`.
            new("sifre",        "sifre",         "metin", EnFazlaUzunluk: 4000,
                Baslik: "Şifre / Token", Grup: "Genel", AltGrup: "Hesap"),
            // SKRS'de "UygulamaKodu", MEDULA'da tesis kodu gibi ucuncu kimlik.
            new("uygulamaKodu", "uygulama_kodu", "metin", EnFazlaUzunluk: 100,
                Baslik: "Uygulama Kodu", Grup: "Genel", AltGrup: "Hesap"),
            new("kurumKodu",    "kurum_kodu",    "metin", EnFazlaUzunluk: 50,
                Baslik: "Kurum / Tesis Kodu", Grup: "Genel", AltGrup: "Hesap"),
            // E-BELGE'YE OZGU (337): entegrator ACILIR LISTEDEN secilir.
            //   Oteki servislerde bos kalir - `ayarlar` jsonb'sinde tutulsaydi
            //   jenerik kartta secim arayuzu olmazdi.
            new("entegratorId", "entegrator_id", "kod",
                KodTablosu: "public.v_ebelge_entegrator_lookup",
                Baslik: "Entegratör (e-Fatura)", Grup: "Genel", AltGrup: "Hesap"),

            new("url",     "url",      "metin", EnFazlaUzunluk: 300,
                Baslik: "Canlı Adres", Grup: "Genel", AltGrup: "Adres ve Durum"),
            new("testUrl", "test_url", "metin", EnFazlaUzunluk: 300,
                Baslik: "Test Adresi", Grup: "Genel", AltGrup: "Adres ve Durum"),

            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Genel", AltGrup: "Adres ve Durum"),
            // Son kullanim/sonuc SERVIS tarafindan yazilir - salt okunur.
            new("sonKullanim", "son_kullanim", "zaman", Yazilabilir: false,
                Baslik: "Son Kullanım", Grup: "Genel", AltGrup: "Adres ve Durum"),
            new("sonSonuc",    "son_sonuc",    "metin", Yazilabilir: false,
                Baslik: "Son Sonuç", Grup: "Genel", AltGrup: "Adres ve Durum"),
        });
}
