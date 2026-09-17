using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Bir aksiyonun tanimi (API §7). Arac cubugu, sag tus menusu ve komut paleti
/// AYNI KATALOGDAN uretilir - Delphi'de bu uc yer ayri ayri kodlaniyordu ve
/// zamanla birbirinden ayrisiyordu.
/// </summary>
public sealed record AksiyonTanimi(
    string Kod,                    // "belge.yeni", "ebelge.gonder"
    string Ad,
    string Grup,
    /// <summary>
    /// Hangi yuzeyde gorunur: araccubugu | araccubugu2 | sagtus | palet
    /// (virgullu). "araccubugu2" = arac cubugunun IKINCI sirasi, saga yasli:
    /// gunluk akisin disinda kalan seyrek islemler birinci sirayi bogmasin.
    /// </summary>
    string Hedef = "araccubugu,sagtus,palet",
    string? Kisayol = null,
    /// <summary>Kaynak yetkisi (or. "cari") + islem. Null ise AksiyonYetkisi bakilir.</summary>
    string? KaynakKodu = null,
    Islem Islem = Islem.Gor,
    /// <summary>Aksiyon yetkisi kodu (yetki tablosunda tur = 1).</summary>
    string? AksiyonYetkisi = null,
    /// <summary>Kayit secilmeden calismaz (sag tus / liste secimi).</summary>
    bool KayitGerekir = false,
    int Sira = 0,
    /// <summary>
    /// URUN MODU SUZGECI (342/345): 0 tum kurulumlar, 1 yalniz Gentegre AI
    /// (ERP), 2 yalniz GenoTIP AI (HBYS). Saglik entegrasyonlarina ozgu
    /// aksiyonlar (SKRS senkronu) ERP kurulumunda ARAC CUBUGUNDA HIC
    /// gorunmesin diye var - pasif gosterip "neden calismiyor" sorusu
    /// urettirmek yerine listeden dusuruluyor.
    /// </summary>
    int UrunModu = 0,
    /// <summary>
    /// Dugme vurgusu: "onay" yesil · "ret" kirmizi · "bir" birincil. Bos ise
    /// notr. Kabul/ret gibi KARSIT ciftlerde renk, dugmeyi okumadan hangisinin
    /// hangisi oldugunu soyler - yanlis dugmeye basmak numuneyi reddeder.
    /// </summary>
    string? Bicim = null,
    /// <summary>Fare ipucu; bos ise `Ad` kullanilir (543).</summary>
    string? Ipucu = null);

/// <summary>Ekran basina aksiyon listesi.</summary>
public static class AksiyonKatalogu
{
    private static readonly Dictionary<string, IReadOnlyList<AksiyonTanimi>> Ekranlar =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["cari-liste"] =
            [
                .. Crud("cari", "kart", "cari"),
                // GIB e-Fatura kaydini entegratore sorar ve karta isler (183).
                new("cari.ebelge-mukellef", "e-Fatura Mükellefiyeti Sorgula", "kart",
                    Hedef: "sagtus,palet", KaynakKodu: "cari", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 45),
            ],

            ["kisi-liste"] = Crud("kisi", "kisi", "cari"),
            // Sil ARAC CUBUGUNDA (kullanici: "rollere silme ikonu ekle"); kullanicili rol
            //   sunucuda engellenir (KartKatalogu Rol SilmeEngelleri).
            ["rol-liste"] = Crud("rol", "rol", "rol", yazdir: false, silHedef: null),

            // KULLANICILAR (Yonetim > Guvenlik) - mockup kullanicilar.html.
            //   CRUD YOK: hesap burada "yeni kayit" gibi acilmaz (personelden
            //   acilir) ve SILINMEZ - islem gunlugu, belge ve log satirlari
            //   kullaniciya bagli; silinen hesap gecmisi sahipsiz birakir.
            //   Pasife alma bunun yerini tutar.
            ["kullanici-liste"] =
            [
                // Parola SIFIRLANIR, yonetici parola YAZMAZ: hesap parolasiz
                //   duruma doner, kisi ilk giriste kendi parolasini koyar.
                new("kullanici.parola-sifirla", "🔑 Parola Sıfırla", "kullanici",
                    Hedef: "araccubugu,sagtus,palet", KaynakKodu: "kullanici",
                    Islem: Islem.Degistir, KayitGerekir: true, Sira: 10,
                    Ipucu: "Hesabı parolasız duruma alır ve tüm oturumları kapatır"),
                // Kilit hatali giristen gelir: parola sorunu DEGIL.
                new("kullanici.kilit-coz", "🔓 Kilidi Çöz", "kullanici",
                    Hedef: "araccubugu,sagtus,palet", KaynakKodu: "kullanici",
                    Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                // Isten ayrilan / cihazini kaybeden kisi: parolasi degismeden
                //   oturumlari kapatilabilmeli.
                new("kullanici.oturum-kapat", "⎋ Oturumları Kapat", "kullanici",
                    Hedef: "araccubugu,sagtus,palet", KaynakKodu: "kullanici",
                    Islem: Islem.Degistir, KayitGerekir: true, Sira: 30),
                new("kullanici.durum", "🚫 Aktif / Pasif", "kullanici",
                    Hedef: "araccubugu,sagtus,palet", KaynakKodu: "kullanici",
                    Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
                // Hesabi olmayan personel: kisi giris yapamayinca aranıyordu.
                new("kullanici.toplu-ac", "👥 Personelden Toplu Aç", "kullanici",
                    Hedef: "araccubugu2,palet", KaynakKodu: "kullanici",
                    Islem: Islem.Ekle, Sira: 50,
                    Ipucu: "Aktif personelden hesabı olmayanlara hesap açar"),
            ],
            ["personel-liste"] = Crud("personel", "personel", "personel"),
            ["hasta-liste"] =
            [
                .. Crud("hasta", "hasta", "hasta"),
                // FORM MOTORU (740): hastanın formları (onam, değerlendirme, beyan).
                new("form.hasta-formlar", "📋 Formlar", "form", Hedef: "araccubugu2,sagtus,palet", KaynakKodu: "form.istek", Islem: Islem.Gor, KayitGerekir: true, Sira: 60, UrunModu: 2),
            ],
            // Dis doktor (305): personel yetkisiyle, kendi kart adiyla.
            ["dis-hekim-liste"] = Crud("dis-hekim", "dis-hekim", "personel"),

            // AKSIYON KOMBOSU (sagtus hedefi) yalniz KOPYALA icerir (kullanici):
            //   Yeni/Duzenle/Sil zaten arac cubugunda dugme; komboda tekrar
            //   edilmeleri listeyi doldurup gercek aksiyonu goze batmaz yapiyordu.
            ["stok-liste"] = new AksiyonTanimi[]
            {
                new("stok.yeni",    "＋ Yeni",     "stok", Hedef: "araccubugu,palet", Kisayol: "Ctrl+N",
                    KaynakKodu: "stok", Islem: Islem.Ekle, Sira: 10),
                new("stok.duzenle", "✎ Düzenle",   "stok", Hedef: "araccubugu,palet", Kisayol: "Enter",
                    KaynakKodu: "stok", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("stok.sil",     "🗑 Sil",         "stok", Hedef: "palet", Kisayol: "Del",
                    KaynakKodu: "stok", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                // Kopyalama (126): secili kart icerigiyle cogaltilir.
                new("stok.kopyala", "⧉ Stok Kartını Kopyala", "stok", Hedef: "sagtus,palet",
                    KaynakKodu: "stok", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Banka tanimlari (db/109).
            ["banka-liste"] = Crud("banka", "banka", "hesap", silHedef: null),

            // Gorev / hatirlatma / takvim (db/108): stok-liste ile ayni desen.
            //   "Tamamla" ayri bir aksiyon DEGIL - durum kartta degisir; listede
            //   tek tikla tamamlamak, ilerleme/tamamlanma alanlarini atlardi.
            ["gorev-liste"] = Crud("gorev", "gorev", "gorev"),

            // Projeler - gorev/firsat listeleriyle AYNI desen (Yeni / Düzenle /
            //   Sil / Yazdır); eskiden aksiyon seridi hic yoktu, kart yalniz
            //   cift tikla aciliyordu.
            ["proje-liste"] = Crud("proje", "proje", "proje"),

            // FIYAT LISTESI (201/202). "Listeyi Üret" ayri yetki ister:
            //   binlerce satir yazar ve taban degisince fiyatlari toptan
            //   degistirir - gorme/duzeltme yetkisi tek basina yetmemeli.
            ["fiyat-listesi-liste"] =
            [
                // SIL ARAC CUBUGUNDA VE IKON (543, kullanici: "kopyala
                //   butonu soluna Sil butonu (ikon) ekle.. herhangi bir yerde
                //   kullanılmamışsa liste ve satırlarını silsin"). Kopyala
                //   (40) bir liste TUREMESI uretiyor; denemeler biriktikce
                //   temizlemek icin sag tus menusunu aramak gerekiyordu.
                //   "Kullanilmamissa" kurali DB'de (543): satirlar cascade
                //   ile gider, kullanan kayit varsa GK422 nerede kullanildigini
                //   soyler.
                .. Crud("fiyat-listesi", "fiyat", "fiyat_listesi",
                        silHedef: "araccubugu,sagtus,palet", silAdi: "🗑",
                        silIpucu: "Listeyi ve satırlarını sil"),
                // KOPYALA (540, kullanici: "Listeyi Üret butonu yerine
                //   Kopyala ekle; secili tek listeyi adinin basina Kopya
                //   ekleyerek kopyalasin"). "Listeyi Üret" 539'da anlamini
                //   yitirdi - taban liste zinciri kalkinca yalniz kalem
                //   listesi kuruyordu.
                new("fiyat-listesi.kopyala", "⧉ Kopyala", "fiyat",
                    Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "fiyat_listesi.uret",
                    KayitGerekir: true, Sira: 40),
                new("fiyat-listesi.satirlar", "Satırları Aç", "fiyat",
                    Hedef: "sagtus,palet", KaynakKodu: "fiyat_listesi", Islem: Islem.Gor,
                    KayitGerekir: true, Sira: 45),
                // EXCEL AKISI (207): sablon indir -> Excel'de doldur -> geri yukle.
                //   Iceri alma jenerik `veri.iceri-al` yetkisine bagli - stok/cari
                //   iceri almalari da ayni yetkiyi kullanacak.
                new("fiyat-listesi.iceri-al", "⬆ Excel'den İçeri Al", "fiyat",
                    Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "veri.iceri-al",
                    KayitGerekir: true, Sira: 46),
                new("fiyat-listesi.sablon", "⬇ Excel Şablonu", "fiyat",
                    Hedef: "sagtus,palet", KaynakKodu: "fiyat_listesi", Islem: Islem.Gor,
                    KayitGerekir: true, Sira: 47),
            ],

            // Satir listesi salt gorunum: satirlar listeden degil KARTTAN
            //   duzenlenir (kural ezmesi baslikla birlikte anlamli).
            ["fiyat-listesi-satir-liste"] = [Yazdir()],

            // CRM satis firsati (121). Kazanildi/Kaybedildi ayri AKSIYON degil:
            //   asama alanindan secilir - iki yerden degistirilen bir durum
            //   birbirini tutmayan iki kayit uretir.
            ["firsat-liste"] = Crud("firsat", "firsat", "firsat"),

            // KURUM ICMALI (289): SGK payinin toplu faturalanmasi.
            ["icmal-liste"] = new AksiyonTanimi[]
            {
                new("icmal.yeni",     "＋ İcmal Oluştur", "kurum",
                    KaynakKodu: "kurum", Islem: Islem.Ekle, Sira: 10),
                new("icmal.faturala", "🧾 Faturala", "kurum",
                    KaynakKodu: "belge", Islem: Islem.Ekle, KayitGerekir: true, Sira: 20),
                new("icmal.belge",    "↗ Faturayı Aç", "kurum",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
            },

            // ===================================================== GOZ (691) ==
            // Goz modulunun kayit ekranlari SIRADAN KARTLARDIR: muayene,
            //   goruntuleme, islem, recete, takip. Hepsinde ekle/duzenle var;
            //   SILME SAG TUSTA ve dar: klinik kayit silinmez, DURUMU degisir.
            //   Silmeyi tamamen kapatmadik - yanlis acilan bos kaydi temizlemek
            //   gerekiyor; ama arac cubugunda durmasi, silmeyi siradan bir
            //   isleme cevirirdi.
            // MUAYENE KARTININ ARAC CUBUGU (mockup goz_detayli_muayene.html):
            //   hekim olcumu bitirince buradan cikis yapiyor - recete, istem,
            //   islem plani, tamamlama. AYNI KODLAR hem listede hem kartta
            //   kullanilir (ListeKarti `ekAraclar`): kural ve yetki tek yerde.
            //
            //   "Goz semasi" ve "dikte" mockupta var ama BURADA YOK: ikisi de
            //   bu üründe henüz olmayan yetenekler (cizim yuzeyi, ses).
            //   Calismayacak dugme koymak, olmayan bir yetenegi vaat etmektir.
            ["goz-muayene-liste"] =
            [
                .. Crud("goz-muayene", "goz", "goz.muayene",
                        ekleAdi: "＋ Yeni Muayene",
                        silIpucu: "Ölçümü olan muayene silinmez; "
                                + "yanlış açılan boş kayıt için"),
                new("goz.muayene-tamamla", "✔ Muayeneyi Tamamla", "goz",
                    KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 15, UrunModu: 2, Bicim: "onay",
                    Ipucu: "Ölçümsüz muayene tamamlanamaz"),
                new("goz.gozluk-recete", "👓 Gözlük Reçetesi", "goz",
                    KaynakKodu: "goz.recete", Islem: Islem.Ekle,
                    KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("goz.goruntuleme-iste", "📷 Görüntüleme İste", "goz",
                    KaynakKodu: "goz.goruntuleme", Islem: Islem.Ekle,
                    KayitGerekir: true, Sira: 45, UrunModu: 2),
                new("goz.islem-planla", "💉 İşlem Planla", "goz",
                    KaynakKodu: "goz.islem", Islem: Islem.Ekle,
                    KayitGerekir: true, Sira: 50, UrunModu: 2,
                    Ipucu: "Enjeksiyon · lazer · ameliyat"),
                new("goz.onceki-kopyala", "📋 Önceki Muayeneden Kopyala", "goz",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 55, UrunModu: 2,
                    Ipucu: "Metinsel bulgular gelir; ölçümler kopyalanmaz"),
                // ÇİZİM VE DİKTE (705): ikisi de bulgu yazmanın başka bir
                //   yolu - bu yüzden ayrı yetkileri yok, "goz.muayene"
                //   değiştirme yetkisine bağlılar.
                new("goz.sema", "🖼 Göz Şeması", "goz",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 60, UrunModu: 2,
                    Ipucu: "Fundus / ön segment çizimi; bulgunun yeri"),
                new("goz.dikte", "🎙 Dikte", "goz",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "goz.muayene", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 65, UrunModu: 2,
                    Ipucu: "Sesle metin bulgu; ölçüm alanları kapalı"),
            ],
            ["goz-goruntuleme-liste"] = Crud("goz-goruntuleme", "goz", "goz.goruntuleme",
                                             ekleAdi: "＋ Yeni Görüntüleme",
                                             silIpucu: "Ölçüm satırı olan çekim silinmez"),
            ["goz-islem-liste"] = Crud("goz-islem", "goz", "goz.islem",
                                       ekleAdi: "＋ Yeni İşlem",
                                       silIpucu: "Uygulanmış işlem silinmez; iptal edin"),
            ["goz-gozluk-recete-liste"] = Crud("goz-gozluk-recete", "goz", "goz.recete",
                                               ekleAdi: "＋ Yeni Reçete",
                                               silIpucu: "Hastaya verilmiş reçete silinmez"),
            ["goz-kontakt-lens-liste"] = Crud("goz-kontakt-lens", "goz", "goz.recete",
                                              ekleAdi: "＋ Yeni Lens Kaydı"),
            ["goz-takip-liste"] = Crud("goz-takip", "goz", "goz.takip",
                                       ekleAdi: "＋ Yeni Takip",
                                       silIpucu: "Takip kapatılır, silinmez"),

            // AYARLAR: protokol ve cihaz TANIMDIR - kurulum isi, tam CRUD.
            ["goz-islem-protokol-liste"] = Crud("goz-islem-protokol", "goz", "goz.islem",
                                                ekleAdi: "＋ Yeni Protokol"),
            // DİKTE SÖZLÜĞÜ (705): terim/komut/sık cümle VERİDİR - yeni bir
            //   kısaltma için sürüm çıkmak gerekmesin diye ekrandan yönetilir.
            ["dikte-terim-liste"] = Crud("dikte-terim", "goz", "goz.dikte_sozluk",
                                         ekleAdi: "＋ Yeni Terim",
                                         silIpucu: "Kurum sözlüğünden silmek "
                                                 + "herkesin diktesini etkiler"),
            ["goz-cihaz-liste"] = Crud("goz-cihaz", "goz", "goz.cihaz",
                                       ekleAdi: "＋ Yeni Cihaz",
                                       silIpucu: "Mesajı olan cihaz silinmez; pasife alın"),

            // CIHAZ MESAJLARI: cihazin gonderdigi HAM KAYIT. Elle eklenmez
            //   (kaynagi cihaz), duzeltilmez ve silinmez - olcumun nereden
            //   geldiginin kanitidir.
            //
            // YENIDEN ISLE (703): surucu duzeltildiginde ya da hasta sonradan
            //   eslestiginde mesaj tekrar ayristirilir. Olcum satiri mesajin
            //   kimligini tasidigi icin mukerrer yazim veritabaninda engelli -
            //   dugmeye iki kez basmak ikinci bir olcum uretmez.
            ["goz-cihaz-mesaj-liste"] = new AksiyonTanimi[]
            {
                new("goz.mesaj-isle",   "🔁 Yeniden İşle", "goz",
                    KaynakKodu: "goz.cihaz", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10, UrunModu: 2,
                    Ipucu: "Mesajı tekrar ayrıştırır; ölçüm mükerrer yazılmaz"),
                new("goz.mesaj-kuyruk", "⏩ Kuyruğu İşle", "goz",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "goz.cihaz", Islem: Islem.Degistir, Sira: 20, UrunModu: 2,
                    Ipucu: "Bekleyen ve sahipsiz bütün mesajları dener"),
                Yazdir(),
            },

            // UNITE AKISI ve HASTA OZETI: ikisi de GORUNUMDUR, kayit degil.
            //   Akistaki satir bir gorunumun (v_goz_unite_akis) satiri; ozet
            //   ise hastanin son olcumlerinden hesaplaniyor. Ikisinde de
            //   ekle/duzenle/sil yok - kayit kendi ekraninda acilir.
            // UNITE AKISI: pano YAZMAZ, TASIR. Dugmeler hastayi bir sonraki
            //   istasyona alir, dilatasyon baslatir, oda atar. Klinik kayit
            //   (olcum, tani, islem) kendi kartinda girilir - panoya form
            //   koymak, ayakta doldurulan yarim kayitlar uretirdi.
            //
            // "Siradakini Cagir" KAYIT ISTEMEZ: secili satir yoksa en uzun
            //   bekleyen cagrilir. Numaraya gore cagirmak, arada dilatasyona
            //   giren hastayi sonsuza kadar geride birakir.
            //
            // HICBIRINDE KayitGerekir YOK: bu ekranda secim KANBAN KARTINDAN
            //   yapiliyor, gridden degil. Kayit sarti konsaydi kullanici karta
            //   tikladiktan sonra bir de gridden ayni satiri secmek zorunda
            //   kalirdi; secili kart yoksa ucun kendisi anlasilir bir cumleyle
            //   reddediyor.
            ["goz-akis-liste"] = new AksiyonTanimi[]
            {
                new("goz.cagir",       "📢 Sıradakini Çağır", "goz",
                    KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 10, UrunModu: 2,
                    Bicim: "onay", Ipucu: "Seçili hasta yoksa en uzun bekleyeni çağırır"),
                new("goz.istasyona-al", "➡ İstasyona Al", "goz",
                    KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 20, UrunModu: 2, Bicim: "bir",
                    Ipucu: "Mevcut istasyon kapanır, yenisi açılır (geçmiş korunur)"),
                new("goz.dilatasyon",  "💧 Dilatasyon Başlat", "goz",
                    KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 30, UrunModu: 2, Ipucu: "20 dakikalık sayaç başlar"),
                new("goz.oda-ata",     "🚪 Oda Ata", "goz",
                    KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 40, UrunModu: 2),
                new("goz.muayene-ac",  "👁 Muayeneyi Aç", "goz",
                    KaynakKodu: "goz.muayene", Islem: Islem.Gor, Sira: 50, UrunModu: 2),
                new("goz.ziyaret-kapat", "✔ Ziyareti Tamamla", "goz",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "goz", Islem: Islem.Degistir, Sira: 60, UrunModu: 2,
                    Ipucu: "Açık istasyon kapanır, hasta panodan düşer"),
                Yazdir(),
            },
            ["goz-hasta-ozet-liste"] = new AksiyonTanimi[] { Yazdir() },

            // ===================================================== DIS (706) ==
            // Hasta listesi: satir HASTA, kart ozel sayfa (odontogram + plan).
            //   Ekle/sil yok - hasta kaydi Kayit Kabul'de acilir.
            ["dis-hasta-liste"] = new AksiyonTanimi[]
            {
                new("dis.hasta-karti", "🦷 Diş Hasta Kartı", "dis",
                    KaynakKodu: "dis.hasta", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
                new("dis.plan-ac", "📋 Yeni Tedavi Planı", "dis",
                    KaynakKodu: "dis.plan", Islem: Islem.Ekle, KayitGerekir: true, Sira: 20, UrunModu: 2),
                Yazdir(),
            },
            // Tedavi plani: crud + onay/sunum. Onay AYRI AKSIYON YETKISI
            //   (dis.plan.onayla): fiyati hekim yazar, onayi hasta danismani alir.
            ["dis-plan-liste"] =
            [
                .. Crud("dis-plan", "dis", "dis.plan",
                        ekleAdi: "＋ Yeni Plan", silHedef: null, yazdir: false,
                        silIpucu: "Onaylı plan silinmez; durumu İptal yapılır"),
                new("dis.plan-sun", "📤 Hastaya Sun", "dis",
                    KaynakKodu: "dis.plan", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2,
                    Ipucu: "Taslak → Sunuldu; proforma numarası üretilir"),
                new("dis.plan-onayla", "✍ Hasta Onayı", "dis",
                    KaynakKodu: "dis.plan", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2,
                    AksiyonYetkisi: "dis.plan.onayla", Bicim: "onay",
                    Ipucu: "Sunulan plan onaylanır; onaylı satır fiyatı değişmez"),
                new("dis.hasta-karti", "🦷 Diş Hasta Kartı", "dis",
                    KaynakKodu: "dis.hasta", Islem: Islem.Gor, KayitGerekir: true, Sira: 60, UrunModu: 2),
                new("dis.odeme-plani-uret", "💳 Ödeme Planı Üret", "dis",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "dis.odeme", Islem: Islem.Ekle, KayitGerekir: true, Sira: 70, UrunModu: 2,
                    Ipucu: "Plan netinden peşinat + taksit satırları üretir"),
                Yazdir(),
            ],
            // Seans: bitirme AYRI KARAR (dis.seans.bitir) - ucret satiri o anda dogar.
            ["dis-seans-liste"] =
            [
                .. Crud("dis-seans", "dis", "dis.seans", ekleAdi: "＋ Seans Aç", yazdir: false, silHedef: null, silIpucu: "Bitmiş seans silinmez"),
                new("dis.seans-bitir", "✔ Seansı Bitir", "dis",
                    KaynakKodu: "dis.seans", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2,
                    AksiyonYetkisi: "dis.seans.bitir", Bicim: "onay",
                    Ipucu: "Tamamlanan işlemler başvuruya ücret satırı olarak düşer, odontogram güncellenir"),
                new("dis.hasta-karti", "🦷 Diş Hasta Kartı", "dis",
                    KaynakKodu: "dis.hasta", Islem: Islem.Gor, KayitGerekir: true, Sira: 60, UrunModu: 2),
                Yazdir(),
            ],
            // Lab is emri: asama ilerletme tek dugme - hangi asamaya gececegi
            //   uc tarafinda sirayla belirlenir (olcu → gonderildi → ... → teslim).
            ["dis-lab-isemri-liste"] =
            [
                .. Crud("dis-lab-isemri", "dis", "dis.lab", ekleAdi: "＋ İş Emri", yazdir: false, silHedef: null, silIpucu: "Teslim edilmiş iş emri silinmez"),
                new("dis.lab-asama", "➡ Aşamayı İlerlet", "dis",
                    KaynakKodu: "dis.lab", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2, Bicim: "bir",
                    Ipucu: "Gönderildi / geldi / prova / teslim - her adım zaman damgalı"),
                new("dis.lab-geri", "🔁 Geri Gönder", "dis",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "dis.lab", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2,
                    Ipucu: "Prova sonrası düzeltme için laba geri"),
                Yazdir(),
            ],
            ["dis-odeme-plani-liste"] = Crud("dis-odeme-plani", "dis", "dis.odeme", ekleAdi: "＋ Ödeme Planı", silHedef: null, silIpucu: "Tahsilatı olan ödeme planı silinmez"),

            // =========================================== KLINIK KALITE (711/713) ==
            // Donem sonuclari: hesapla / kesinlestir DONEM islemidir, satir
            //   secimi istemez. Kesinlestirme TEK YON oldugu icin ayri yetki
            //   (klinik_kalite.kesinlestir) ve kirmizi bicim - geri alinamayan
            //   islemi gundelik hesaplamayla ayni renkte gostermek yanlis
            //   dugmeye basmayi kolaylastirirdi.
            ["klinik-kalite-donem-liste"] = new AksiyonTanimi[]
            {
                new("klinik-kalite.hesapla", "🔄 Dönemi Hesapla", "klinik_kalite",
                    AksiyonYetkisi: "klinik_kalite.hesapla", Sira: 10, UrunModu: 2,
                    Bicim: "bir",
                    Ipucu: "Dönemin tüm otomatik göstergelerini yeniden hesaplar; kesinleşmiş satıra dokunmaz"),
                new("klinik-kalite.kesinlestir", "🔒 Dönemi Kesinleştir", "klinik_kalite",
                    AksiyonYetkisi: "klinik_kalite.kesinlestir", Sira: 20, UrunModu: 2,
                    Bicim: "ret",
                    Ipucu: "Taslak satırları dondurur - geri alınamaz"),
                new("klinik-kalite.onizle", "🔢 Göstergeyi Önizle", "klinik_kalite",
                    KaynakKodu: "klinik_kalite", Islem: Islem.Gor, KayitGerekir: true,
                    Sira: 30, UrunModu: 2,
                    Ipucu: "Seçili göstergeyi hesaplar ama KAYDETMEZ"),
                Yazdir(),
            },

            // Gosterge katalogu: yalniz onizleme. Katalog rehberin mali,
            //   buradan donem yazilmaz.
            ["klinik-gosterge-liste"] = new AksiyonTanimi[]
            {
                new("klinik-kalite.onizle", "🔢 Bu Göstergeyi Önizle", "klinik_kalite",
                    KaynakKodu: "klinik_kalite", Islem: Islem.Gor, KayitGerekir: true,
                    Sira: 10, UrunModu: 2,
                    Ipucu: "Seçili göstergeyi bir dönem için hesaplar ama KAYDETMEZ"),
                Yazdir(),
            },
            // ================================================== MEDULA (707) ==
            // Takip listesi: satir BASVURU; hasta kabul / hizmet kaydi ozel sayfalari
            //   satirdan acilir. Ekle/sil yok - basvuru Kayit Kabul'de acilir.
            ["medula-takip-liste"] = new AksiyonTanimi[]
            {
                new("medula.kabul-ac",   "🪪 Hasta Kabul / Provizyon", "medula",
                    KaynakKodu: "medula.provizyon", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
                new("medula.hizmet-ac",  "🧾 Hizmet Kaydı", "medula",
                    KaynakKodu: "medula.hizmet", Islem: Islem.Gor, KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("medula.cikis",      "🚪 Hasta Çıkışı", "medula",
                    KaynakKodu: "medula.provizyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2,
                    Ipucu: "Takip kapatılır; fatura ancak çıkıştan sonra kesilir"),
                new("medula.fatura-kaydet", "🧮 Fatura Kaydet", "medula",
                    KaynakKodu: "medula.fatura", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40, UrunModu: 2),
                Yazdir(),
            },
            ["medula-islem-liste"] = new AksiyonTanimi[]
            {
                new("medula.hizmet-ac",  "🧾 Hizmet Kaydı Ekranı", "medula",
                    KaynakKodu: "medula.hizmet", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
                new("medula.islem-iptal", "✖ Kaydı İptal Et", "medula",
                    KaynakKodu: "medula.hizmet", Islem: Islem.Sil, KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "onay"),
                new("medula.islem-yerel", "💳 Hastaya Ücretli Bırak", "medula",
                    KaynakKodu: "medula.hizmet", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2),
                Yazdir(),
            },
            ["medula-fatura-liste"] = new AksiyonTanimi[]
            {
                new("medula-fatura.duzenle", "✎ Aç", "medula", Kisayol: "Enter",
                    KaynakKodu: "medula.fatura", Islem: Islem.Gor, KayitGerekir: true, Sira: 10),
                new("medula.fatura-iptal", "✖ Fatura İptal", "medula",
                    KaynakKodu: "medula.fatura", Islem: Islem.Sil, KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "onay"),
                new("medula.kesinti-ekle", "➖ Kesinti Yaz", "medula",
                    KaynakKodu: "medula.fatura", Islem: Islem.Ekle, KayitGerekir: true, Sira: 30, UrunModu: 2),
                new("medula.donem-ac",   "📅 Fatura & Dönem Ekranı", "medula",
                    KaynakKodu: "medula.fatura", Islem: Islem.Gor, Sira: 40, UrunModu: 2),
                Yazdir(),
            },
            ["medula-donem-liste"] = new AksiyonTanimi[]
            {
                new("medula-donem.duzenle", "✎ Aç", "medula", Kisayol: "Enter",
                    KaynakKodu: "medula.fatura", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
                new("medula.donem-ac",   "📅 Fatura & Dönem Ekranı", "medula",
                    KaynakKodu: "medula.fatura", Islem: Islem.Gor, Sira: 20, UrunModu: 2),
                Yazdir(),
            },
            ["medula-kesinti-liste"] =
            [
                .. Crud("medula-kesinti", "medula", "medula.fatura", ekleAdi: "＋ Kesinti", yazdir: false),
                new("medula.itiraz",     "📝 İtiraz Et", "medula",
                    KaynakKodu: "medula.fatura", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("medula.itiraz-sonuc", "⚖ İtiraz Sonucu", "medula",
                    KaynakKodu: "medula.fatura", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2),
                Yazdir(),
            ],
            ["medula-rapor-liste"] =
            [
                .. Crud("medula-rapor", "medula", "medula.recete", ekleAdi: "＋ Rapor", yazdir: false),
                new("medula.rapor-gonder", "📤 Medula'ya Gönder", "medula",
                    KaynakKodu: "medula.recete", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40, UrunModu: 2, Bicim: "onay"),
                Yazdir(),
            ],
            // e-Recete: recete listesinin Medula gorunumu - imzala, gonder, sil.
            ["medula-recete-liste"] = new AksiyonTanimi[]
            {
                new("recete.duzenle", "✎ Reçeteyi Aç", "medula", Kisayol: "Enter",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
                new("medula.recete-imzala", "✍ İmzala", "medula",
                    KaynakKodu: "medula.recete", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2,
                    Ipucu: "Taslak → imzalı; alerji kontrolü burada"),
                new("medula.recete-gonder", "📤 Medula'ya Gönder", "medula",
                    KaynakKodu: "medula.recete", Islem: Islem.Ekle, KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "onay"),
                new("medula.recete-sil", "🗑 Medula'dan Sil", "medula", Hedef: "sagtus,palet",
                    KaynakKodu: "medula.recete", Islem: Islem.Sil, KayitGerekir: true, Sira: 40, UrunModu: 2, Bicim: "onay",
                    Ipucu: "Kabul edilmiş reçete değiştirilemez: sil + yeni"),
                Yazdir(),
            },
            ["medula-kuyruk-liste"] = new AksiyonTanimi[]
            {
                new("medula.kuyruk-gonder", "↻ Bekleyenleri Gönder", "medula",
                    KaynakKodu: "medula", Islem: Islem.Degistir, Sira: 10, UrunModu: 2),
                new("medula.kuyruk-tekrar", "🔁 Yeniden Dene", "medula",
                    KaynakKodu: "medula", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("medula.kuyruk-iptal", "✖ İptal Et", "medula", Hedef: "sagtus,palet",
                    KaynakKodu: "medula", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "onay"),
                new("medula.kuyruk-ac",  "📡 Kuyruk & Ayarlar Ekranı", "medula",
                    KaynakKodu: "medula", Islem: Islem.Gor, Sira: 40, UrunModu: 2),
                Yazdir(),
            },
            ["dis-unit-liste"] = Crud("dis-unit", "dis", "dis.unit", ekleAdi: "＋ Ünit", silHedef: null, silIpucu: "Seansı olan ünit silinmez; pasife alın"),
            // CALISMA PLANI (711): sablon + istisna listeleri.
            // FTR (719): degerlendirme / program / seans / olcek / unite.
            // Ekle / Düzenle / Sil ARAC CUBUGUNDA (kullanici): silme engelleri sunucuda (KartKatalogu.Ftr SilmeEngelleri).
            // FORM MOTORU (740): şablon CRUD + kopyala/önizle; doldurulan formlar
            //   açılır, hatırlatılır, yeniden gönderilir; kurallar CRUD.
            ["form-sablon-liste"] =
            [
                .. Crud("form-sablon", "form", "form.sablon", ekleAdi: "＋ Şablon", silHedef: null, yazdir: false),
                new("form.sablon-kopyala", "⧉ Kopyala", "form", KaynakKodu: "form.sablon", Islem: Islem.Ekle, KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("form.sablon-onizle", "👁 Önizle / Test doldur", "form", KaynakKodu: "form.sablon", Islem: Islem.Gor, KayitGerekir: true, Sira: 41, UrunModu: 2),
                new("form.sablon-editor", "✎ Görsel editör", "form", KaynakKodu: "form.sablon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 42, UrunModu: 2),
            ],
            ["form-istek-liste"] =
            [
                new("form.istek-ac", "📄 Aç / Doldur", "form", Kisayol: "Enter", KaynakKodu: "form.istek", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
                new("form.istek-hatirlat", "🔔 Hatırlat", "form", KaynakKodu: "form.gonder", Islem: Islem.Ekle, KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("form.istek-yeniden", "🔁 Yeniden gönder", "form", KaynakKodu: "form.gonder", Islem: Islem.Ekle, KayitGerekir: true, Sira: 21, UrunModu: 2),
                new("form.istek-iptal", "✖ İptal", "form", Hedef: "sagtus,palet", KaynakKodu: "form.gonder", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2),
                Yazdir(),
            ],
            ["form-kural-liste"] = Crud("form-kural", "form", "form.kural", ekleAdi: "＋ Kural", silHedef: null, yazdir: false),
            // İŞYERİ HEKİMLİĞİ (741): firma/çalışan/ziyaret/olay CRUD + Ek-2 açma,
            //   SMS, çalışan kartı, SGK bildirimi. Muayene listesi formu açar.
            ["isg-firma-liste"] =
            [
                .. Crud("isg-firma", "isg", "isg.firma", ekleAdi: "＋ Firma", silHedef: null, yazdir: false),
                new("isg.firma-kart", "🏭 Firma panosu", "isg", KaynakKodu: "isg.firma", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
            ],
            ["isg-calisan-liste"] =
            [
                .. Crud("isg-calisan", "isg", "isg.calisan", ekleAdi: "＋ Çalışan", silHedef: null, yazdir: false),
                new("isg.calisan-kart", "👷 Çalışan kartı", "isg", KaynakKodu: "isg.calisan", Islem: Islem.Gor, KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("isg.muayene-ac", "🩺 Ek-2 muayene aç", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Ekle, KayitGerekir: true, Sira: 41, UrunModu: 2),
                new("isg.form-gonder", "📱 Formu gönder (SMS)", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Ekle, KayitGerekir: true, Sira: 42, UrunModu: 2),
                new("isg.olay-bildir", "🚨 Olay bildir", "isg", Hedef: "araccubugu2,sagtus,palet", KaynakKodu: "isg.olay", Islem: Islem.Ekle, KayitGerekir: true, Sira: 50, UrunModu: 2),
            ],
            ["isg-muayene-liste"] =
            [
                new("isg.muayene-form", "📄 Ek-2 formu", "isg", Kisayol: "Enter", KaynakKodu: "isg.muayene", Islem: Islem.Gor, KayitGerekir: true, Sira: 10, UrunModu: 2),
                new("isg.muayene-isle", "✔ Kanaati işle", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("isg-muayene.duzenle", "✎ Düzenle", "isg", KaynakKodu: "isg.muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30, UrunModu: 2),
                new("isg.muayene-iptal", "✖ İptal", "isg", Hedef: "sagtus,palet", KaynakKodu: "isg.muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
                Yazdir(),
            ],
            ["isg-ziyaret-liste"] = Crud("isg-ziyaret", "isg", "isg.ziyaret", ekleAdi: "＋ Ziyaret", silHedef: null),
            ["isg-olay-liste"] =
            [
                .. Crud("isg-olay", "isg", "isg.olay", ekleAdi: "＋ Olay", silHedef: null),
                new("isg.olay-sgk", "🏛 SGK'ya bildirildi", "isg", KaynakKodu: "isg.olay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("isg.olay-kapat", "✔ Kapat", "isg", Hedef: "sagtus,palet", KaynakKodu: "isg.olay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41, UrunModu: 2),
            ],
            ["ftr-degerlendirme-liste"] = Crud("ftr-degerlendirme", "ftr", "ftr.degerlendirme", ekleAdi: "＋ Değerlendirme", silHedef: null,
                                               silIpucu: "Programı olan değerlendirme silinmez"),
            ["ftr-program-liste"] =
            [
                .. Crud("ftr-program", "ftr", "ftr.program", ekleAdi: "＋ Program (Kür)", silHedef: null, yazdir: false,
                        silIpucu: "Seansı olan program silinmez; sonlandırılır"),
                new("ftr.program-planla", "🗓 Seansları Planla", "ftr", KaynakKodu: "ftr.program", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("ftr.program-seans-ac", "🏃 Bugünkü Seans", "ftr", KaynakKodu: "ftr.seans", Islem: Islem.Ekle, KayitGerekir: true, Sira: 41, UrunModu: 2),
                new("ftr.program-sonlandir", "✖ Sonlandır", "ftr", Hedef: "sagtus,palet", KaynakKodu: "ftr.program", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50, UrunModu: 2),
            ],
            ["ftr-seans-liste"] =
            [
                .. Crud("ftr-seans", "ftr", "ftr.seans", ekleAdi: "＋ Seans", silHedef: null, yazdir: false,
                        silIpucu: "Yapılmış seans silinmez (uygulama işaretleri kalır)"),
                new("ftr.seans-bitir", "✔ Seansı Bitir", "ftr", KaynakKodu: "ftr.seans", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("ftr.seans-gelmedi", "⛔ Gelmedi", "ftr", Hedef: "sagtus,palet", KaynakKodu: "ftr.seans", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41, UrunModu: 2),
            ],
            ["ftr-olcek-liste"] = Crud("ftr-olcek", "ftr", "ftr.olcek", ekleAdi: "＋ Ölçek", silHedef: null),
            ["ftr-unite-liste"] = Crud("ftr-unite", "ftr", "ftr.unite", ekleAdi: "＋ Ünite", yazdir: false, silHedef: null,
                                       silIpucu: "Programı olan ünite silinmez; pasife alın"),
            ["calisma-sablon-liste"]  = Crud("calisma-sablon", "randevu", "randevu.plan", ekleAdi: "＋ Şablon", yazdir: false),
            ["calisma-istisna-liste"] = Crud("calisma-istisna", "randevu", "randevu.plan", ekleAdi: "＋ İstisna", yazdir: false),
            ["dis-lab-liste"] = Crud("dis-lab", "dis", "dis.unit", ekleAdi: "＋ Laboratuvar", silHedef: null, silIpucu: "İş emri olan laboratuvar silinmez; pasife alın"),

            // YATAN HASTA SERVIS LISTESI (695): yatisin YASAM DONGUSU dugmelerle
            //   ilerler - kabul, hastanin yatagina cikisi, nakil, taburcu.
            //   Yatak durumu bu uclarla BIRLIKTE degisir; ayri bir "yatagi dolu
            //   yap" dugmesi olsaydi pano gercegin yarim saat gerisinde kalirdi.
            //
            //   Kabul/nakil/taburcu AYRI AKSIYON YETKILERIDIR (yatan.kabul /
            //   yatan.nakil / yatan.taburcu): kabul masasi yatis acar ama
            //   taburcu etmez, hemsire izlem girer ama yatak degistirmez.
            ["yatan-liste"] = new AksiyonTanimi[]
            {
                new("yatan.kabul",    "＋ Yatış Kabul", "yatan", Kisayol: "Ctrl+N",
                    AksiyonYetkisi: "yatan.kabul", Sira: 10, UrunModu: 2),
                new("yatan.duzenle",  "✎ Yatış Kartı", "yatan", Kisayol: "Enter",
                    KaynakKodu: "yatan", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                // KABUL ile "hasta yataginda" AYRI adimdir: arada provizyon,
                //   dosya ve transfer var. Yatak ucreti ve hemsire izlemi
                //   hasta geldiginde baslar.
                new("yatan.yatakta",  "🛏 Yatağa Alındı", "yatan",
                    AksiyonYetkisi: "yatan.kabul", KayitGerekir: true,
                    Sira: 30, UrunModu: 2,
                    Ipucu: "Yatış kabul → Yatakta; yatak 'dolu' olur"),
                new("yatan.nakil",    "🔀 Nakil / Yatak Değiştir", "yatan",
                    AksiyonYetkisi: "yatan.nakil", KayitGerekir: true,
                    Sira: 40, UrunModu: 2),
                new("yatan.taburcu-planla", "📅 Taburcu Planla", "yatan",
                    Hedef: "araccubugu2,sagtus,palet",
                    AksiyonYetkisi: "yatan.taburcu", KayitGerekir: true,
                    Sira: 50, UrunModu: 2,
                    Ipucu: "Panoda 'bugün çıkacak' olarak işaretlenir"),
                new("yatan.taburcu",  "🚪 Taburcu Et", "yatan",
                    AksiyonYetkisi: "yatan.taburcu", KayitGerekir: true,
                    Sira: 60, UrunModu: 2, Bicim: "onay"),
                // YATIS SILINMEZ, IPTAL EDILIR. Yatisa order, izlem, doz ve
                //   tahakkuk bagli; silinen yatis bunlari da goturur ve "bu
                //   hasta yatmis miydi" sorusu cevapsiz kalir. Yanlis acilan
                //   yatis icin dogru cevap durum 0 (Iptal): kayit kalir,
                //   yatak serbest kalir.
                new("yatan.iptal",    "✖ Yatışı İptal Et", "yatan",
                    Hedef: "sagtus,palet", AksiyonYetkisi: "yatan.kabul",
                    KayitGerekir: true, Sira: 70, UrunModu: 2, Bicim: "ret",
                    Ipucu: "Yanlış açılan yatışı iptal eder (kayıt silinmez)"),
                Yazdir(),
            },

            // YATAK PANOSU (695): satir YATAKTIR, hasta degil. Temizligi biten
            //   yatagi BOS'a dondurmek ayri bir olaydir ve kim yaptigi loglanir -
            //   "yatak hazir" bilgisi kabul masasinin hasta yollama kararidir.
            ["yatak-liste"] = new AksiyonTanimi[]
            {
                new("yatan.yatak-temizlendi", "🧹 Temizlik Bitti", "yatan",
                    KaynakKodu: "yatan.yatak", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay",
                    Ipucu: "Temizlik bekleyen yatağı 'boş' yapar"),
                // YATAK BIR TANIMDIR: kurulumda acilir, kapanir, duzeltilir.
                //   Silme SAG TUSTA: ustunde yatis gecmisi olan yatak
                //   silinemez (yabanci anahtar) - dogru yol pasife almaktir,
                //   ipucu bunu soyluyor.
                new("yatak.yeni",    "＋ Yeni Yatak", "yatan", Kisayol: "Ctrl+N",
                    KaynakKodu: "yatan.yatak", Islem: Islem.Ekle, Sira: 20, UrunModu: 2),
                new("yatak.duzenle", "✎ Yatak Kartı", "yatan", Kisayol: "Enter",
                    KaynakKodu: "yatan.yatak", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 30, UrunModu: 2),
                new("yatak.sil",     "🗑 Sil", "yatan", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "yatan.yatak", Islem: Islem.Sil,
                    KayitGerekir: true, Sira: 40, UrunModu: 2,
                    Ipucu: "Yatış geçmişi olan yatak silinemez; pasife alın"),
                Yazdir(),
            },

            // ===================================================== AMELİYATHANE (715/719) ==
            // AKIŞ DÜĞMELERİ ARAÇ ÇUBUĞUNDA, AMA HEPSİ DEĞİL. Altı zaman damgası
            //   var; altısını da birinci sıraya koysaydık çubuk, o an yalnız biri
            //   geçerli olan altı düğmeyle dolardı. Birinci sıra AMELİYATIN
            //   OMURGASI (salona alma - kesi - bitiş); anestezi, kapanış ve
            //   salondan çıkış ikinci sırada - kaydedilirler ama akışı onlar
            //   taşımaz (lokal anestezide anestezi damgası hiç olmaz).
            //
            // KESİ AYRI DURUR (Bicim "bir"): time-out tamamlanmadan sunucu
            //   reddeder. Düğmeyi gizlemek yerine reddetmeyi seçtik - gizli
            //   düğme "neden yok" sorusu üretir, red ise NEYİN eksik olduğunu
            //   söyler.
            ["ameliyat-liste"] = new AksiyonTanimi[]
            {
                new("ameliyat.duzenle", "✎ Ameliyat Kartı", "ameliyathane", Kisayol: "Enter",
                    KaynakKodu: "ameliyathane.ameliyat", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 10, UrunModu: 2),
                new("ameliyat.salona-al", "🚪 Salona Alındı", "ameliyathane",
                    AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                    Sira: 20, UrunModu: 2,
                    Ipucu: "Masa süresi buradan başlar (plana göre sapma hesaplanır)"),
                new("ameliyat.kesi", "🔪 Kesi", "ameliyathane",
                    AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                    Sira: 30, UrunModu: 2, Bicim: "bir",
                    Ipucu: "Time-out (aşama 2) tamamlanmadan kaydedilmez"),
                new("ameliyat.bitis", "✅ Ameliyat Bitti", "ameliyathane",
                    AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                    Sira: 40, UrunModu: 2, Bicim: "onay",
                    Ipucu: "Cerrahi süre burada kapanır; sayım uyuşmazlığı uyarı verir"),
                // GÜVENLİ CERRAHİ LİSTESİ kartta SALT OKUNUR (madde metni kopya,
                //   işaretleyen/zaman elle yazılmamalı) - işaretleme buradan geçer.
                new("ameliyat.kontrol", "☑ Güvenli Cerrahi Listesi", "ameliyathane",
                    KaynakKodu: "ameliyathane.ameliyat", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 50, UrunModu: 2),

                // FATURA ve STOK TEK DÜĞMEDE AÇILIR, tek işte DEĞİL: modal
                //   ikisini ayrı düğmeyle yapar. Ücret hasta başvurusuna, malzeme
                //   stok çıkış fişine gider - ayrı defter, ayrı yetki. Tek tıkla
                //   ikisi birden olsaydı faturayı onaylayan kişi farkında olmadan
                //   depo sayımını da değiştirirdi.
                new("ameliyat.fatura", "🧾 Fatura & Stok", "ameliyathane",
                    KaynakKodu: "ameliyathane.ameliyat", Islem: Islem.Gor,
                    KayitGerekir: true, Sira: 55, UrunModu: 2,
                    Ipucu: "İşlemleri hasta başvurusuna aktarır, malzemeyi stoktan düşer"),

                new("ameliyat.anestezi", "💉 Anestezi Başladı", "ameliyathane",
                    Hedef: "araccubugu2,sagtus,palet",
                    AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                    Sira: 60, UrunModu: 2),
                new("ameliyat.kapanis", "🧵 Kapanış Başladı", "ameliyathane",
                    Hedef: "araccubugu2,sagtus,palet",
                    AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                    Sira: 70, UrunModu: 2),
                new("ameliyat.cikis", "🚪 Salondan Çıktı", "ameliyathane",
                    Hedef: "araccubugu2,sagtus,palet",
                    AksiyonYetkisi: "ameliyathane.baslat", KayitGerekir: true,
                    Sira: 80, UrunModu: 2,
                    Ipucu: "Salon bir sonraki vakaya hazır sayılır"),
                new("ameliyat.not-imzala", "✒ Ameliyat Notunu İmzala", "ameliyathane",
                    Hedef: "araccubugu2,sagtus,palet",
                    AksiyonYetkisi: "ameliyathane.not_imzala", KayitGerekir: true,
                    Sira: 85, UrunModu: 2,
                    Ipucu: "İmzadan sonra not değişmez; yalnız ek not yazılabilir"),
                // AMELİYAT SİLİNMEZ, İPTAL EDİLİR: sarf, ekip ve kontrol satırları
                //   ona bağlı ve "planlandı, olmadı" bilgisi masa kullanımı
                //   raporunun girdisi. Kesi yapılmışsa sunucu iptali reddeder.
                new("ameliyat.iptal", "✖ Ameliyatı İptal Et", "ameliyathane",
                    Hedef: "sagtus,palet", AksiyonYetkisi: "ameliyathane.iptal",
                    KayitGerekir: true, Sira: 90, UrunModu: 2, Bicim: "ret",
                    Ipucu: "Kayıt silinmez; talep bekleyen listesine geri döner"),
                Yazdir(),
            },

            // BEKLEYEN TALEPLER - tek gerçek iş "planla". Talep ameliyata
            //   dönüşmez, ameliyat DOĞURUR: bekleme geçmişi talepte kalır ve
            //   ameliyat iptal olursa geri döneceği yer orasıdır.
            ["ameliyat-talep-liste"] = new AksiyonTanimi[]
            {
                new("ameliyat-talep.yeni", "＋ Yeni Talep", "ameliyathane", Kisayol: "Ctrl+N",
                    KaynakKodu: "ameliyathane.talep", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
                new("ameliyat-talep.duzenle", "✎ Düzenle", "ameliyathane", Kisayol: "Enter",
                    KaynakKodu: "ameliyathane.talep", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("ameliyat-talep.planla", "📅 Ameliyata Planla", "ameliyathane",
                    KaynakKodu: "ameliyathane.plan", Islem: Islem.Ekle,
                    KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "bir",
                    Ipucu: "Salon ve saat sorulur; eksik hazırlık ve salon çakışması uyarılır"),
                new("ameliyat-talep.sil", "🗑 Sil", "ameliyathane",
                    Kisayol: "Del", KaynakKodu: "ameliyathane.talep", Islem: Islem.Sil,
                    KayitGerekir: true, Sira: 40, UrunModu: 2,
                    Ipucu: "Planlanmış talep silinemez; önce ameliyatı iptal edin"),
                Yazdir(),
            },

            ["ameliyat-salon-liste"] = new AksiyonTanimi[]
            {
                new("ameliyat-salon.yeni", "＋ Yeni Salon", "ameliyathane", Kisayol: "Ctrl+N",
                    KaynakKodu: "ameliyathane.salon", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
                new("ameliyat-salon.duzenle", "✎ Düzenle", "ameliyathane", Kisayol: "Enter",
                    KaynakKodu: "ameliyathane.salon", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("ameliyat-salon.sil", "🗑 Sil", "ameliyathane",
                    Kisayol: "Del", KaynakKodu: "ameliyathane.salon", Islem: Islem.Sil,
                    KayitGerekir: true, Sira: 30, UrunModu: 2,
                    Ipucu: "Ameliyat geçmişi olan salon silinemez; pasife alın"),
                Yazdir(),
            },

            // ========================================================= ACİL (716) ==
            // TRİYAJ EKRANI ile TAKİP PANOSU aynı kaynağı okur, AYRI aksiyon
            //   listesi taşır: kabul masasının işi hastayı sıraya sokmak (triyaj,
            //   yatak, hekim), panonunki ise içerideki hastayı ilerletmek (çağrı,
            //   çıkış). Tek liste olsaydı her iki kullanıcı da diğerinin
            //   düğmelerini eleyerek çalışırdı.
            ["acil-triyaj-liste"] = new AksiyonTanimi[]
            {
                new("acil.yeni", "＋ Yeni Başvuru", "acil", Kisayol: "Ctrl+N",
                    KaynakKodu: "acil.basvuru", Islem: Islem.Ekle, Sira: 10, UrunModu: 2,
                    Ipucu: "Kimliksiz hasta da kabul edilir (geçici ad ile)"),
                new("acil.duzenle", "✎ Hasta Kartı", "acil", Kisayol: "Enter",
                    KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                // TRİYAJ TEK DÜĞME: yükseltme serbest, DÜŞÜRME ayrı yetki ve
                //   gerekçe ister - kararı sunucu verir, çünkü düşürme hastayı
                //   sıranın gerisine atar.
                new("acil.triyaj-ver", "🎨 Triyaj Ver / Değiştir", "acil",
                    KaynakKodu: "acil.triyaj", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "bir",
                    Ipucu: "Düşürmek ayrı yetki ve gerekçe ister"),
                new("acil.yatak-ver", "🛏 Yatak Ver", "acil",
                    KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 40, UrunModu: 2),
                new("acil.hekim-gordu", "🩺 Hekim Gördü", "acil",
                    KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 50, UrunModu: 2,
                    Ipucu: "Kapı-hekim süresinin ikinci ucu; bir kez yazılır"),
                Yazdir(),
            },

            ["acil-takip-liste"] = new AksiyonTanimi[]
            {
                new("acil.duzenle", "✎ Hasta Kartı", "acil", Kisayol: "Enter",
                    KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 10, UrunModu: 2),
                new("acil.hekim-gordu", "🩺 Hekim Gördü", "acil",
                    KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                // ÇAĞRI PANODAN TEK TIKLA: mavi kodda kart açıp detay satırı
                //   eklemek, ölçtüğümüz sürenin kendisini uzatır.
                new("acil.cagri-ac", "📞 Çağrı Aç", "acil",
                    KaynakKodu: "acil.pano", Islem: Islem.Ekle,
                    KayitGerekir: true, Sira: 30, UrunModu: 2),
                new("acil.cikis-karar", "🚪 Çıkış Kararı", "acil",
                    AksiyonYetkisi: "acil.cikis", KayitGerekir: true,
                    Sira: 40, UrunModu: 2, Bicim: "onay",
                    Ipucu: "Çıkış tanısı zorunlu; yatak temizliğe düşer"),
                new("acil.triyaj-ver", "🎨 Triyaj Değiştir", "acil",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "acil.triyaj", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 50, UrunModu: 2),
                new("acil.yatak-ver", "🛏 Yatak Değiştir", "acil",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "acil.basvuru", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 60, UrunModu: 2),
                Yazdir(),
            },

            // ÇAĞRILAR - üç düğme aynı satırın durumunu ilerletir. "Yanıt yok"
            //   KIRMIZI ve ayrı: tekrar sayacını artırır ve bekleme süresini
            //   kapatmaz; yanıtlandı ile karıştırılması ölçümü bozardı.
            ["acil-cagri-liste"] = new AksiyonTanimi[]
            {
                new("acil.cagri-yanit", "✅ Yanıtlandı", "acil",
                    KaynakKodu: "acil.pano", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay",
                    Ipucu: "Yanıt saati bir kez yazılır (çağrı-yanıt süresi)"),
                new("acil.cagri-kapat", "⏹ Kapat", "acil",
                    KaynakKodu: "acil.pano", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("acil.cagri-tekrar", "🔁 Yanıt Yok / Tekrar Çağır", "acil",
                    KaynakKodu: "acil.pano", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 30, UrunModu: 2, Bicim: "ret"),
                Yazdir(),
            },

            ["acil-yatak-liste"] = new AksiyonTanimi[]
            {
                // Çıkışta yatak BOŞ değil TEMİZLİKTE olur; boşa dönmesi ayrı bir
                //   olaydır ve kim yaptığı loglanır - "yatak hazır" bilgisi
                //   triyajın hasta yollama kararıdır.
                new("acil.yatak-temizlendi", "🧹 Temizlik Bitti", "acil",
                    KaynakKodu: "acil.yatak", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay"),
                new("acil-yatak.yeni", "＋ Yeni Yatak", "acil", Kisayol: "Ctrl+N",
                    KaynakKodu: "acil.yatak", Islem: Islem.Ekle, Sira: 20, UrunModu: 2),
                new("acil-yatak.duzenle", "✎ Düzenle", "acil", Kisayol: "Enter",
                    KaynakKodu: "acil.yatak", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 30, UrunModu: 2),
                new("acil-yatak.sil", "🗑 Sil", "acil", Kisayol: "Del",
                    KaynakKodu: "acil.yatak", Islem: Islem.Sil,
                    KayitGerekir: true, Sira: 40, UrunModu: 2,
                    Ipucu: "Başvuru geçmişi olan yatak silinemez; pasife alın"),
                Yazdir(),
            },

            // ODA TANIMLARI (695) - kurulum ekrani. Kural odanin: cinsiyet,
            //   izolasyon, ucret sinifi. Silme sag tusta ve ayni sebeple
            //   kisitli: odaya bagli yatak ve gecmis yatislar var.
            ["oda-liste"] = new AksiyonTanimi[]
            {
                new("oda.yeni",    "＋ Yeni Oda", "yatan", Kisayol: "Ctrl+N",
                    KaynakKodu: "yatan.yatak", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
                new("oda.duzenle", "✎ Düzenle", "yatan", Kisayol: "Enter",
                    KaynakKodu: "yatan.yatak", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("oda.sil",     "🗑 Sil", "yatan", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "yatan.yatak", Islem: Islem.Sil,
                    KayitGerekir: true, Sira: 30, UrunModu: 2,
                    Ipucu: "Yatağı olan oda silinemez; pasife alın"),
                Yazdir(),
            },

            // ORDER LISTESI (695): talimat kaydi - eklenir, duzeltilir,
            //   DURDURULUR. Silme sag tusta: uygulanmis dozu olan order
            //   silinirse "bu ilac neden verildi" sorusu cevapsiz kalir.
            //   Sozel order imzalama AYRI YETKI (yatan.order.imza): uygulayan
            //   hemsire kendi imzalayamaz.
            ["yatis-order-liste"] = new AksiyonTanimi[]
            {
                new("yatis-order.yeni",    "＋ Yeni Order", "yatan", Kisayol: "Ctrl+N",
                    KaynakKodu: "yatan.order", Islem: Islem.Ekle, Sira: 10, UrunModu: 2),
                new("yatis-order.duzenle", "✎ Düzenle", "yatan", Kisayol: "Enter",
                    KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2),
                new("yatan.order-imzala",  "✍ Sözel Order İmzala", "yatan",
                    AksiyonYetkisi: "yatan.order.imza", KayitGerekir: true,
                    Sira: 30, UrunModu: 2, Bicim: "onay"),
                new("yatan.order-durdur",  "⏸ Order Durdur", "yatan",
                    KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 40, UrunModu: 2,
                    Ipucu: "Gelecekteki bekleyen dozlar düşer, geçmiş kalır"),
                new("yatis-order.sil",     "🗑 Sil", "yatan", Hedef: "sagtus,palet",
                    Kisayol: "Del", KaynakKodu: "yatan.order", Islem: Islem.Sil,
                    KayitGerekir: true, Sira: 50, UrunModu: 2,
                    Ipucu: "Uygulanmış dozu olan order silinmez; durdurun"),
                Yazdir(),
            },

            // DOZ KUYRUGU (698): satir PLANLANMIS DOZDUR ve order'dan uretilir.
            //   ELLE EKLEME/SILME YOK - elle eklenen doz planin disinda kalir,
            //   silinen doz "verilmedi mi, hic planlanmadi mi" sorusunu
            //   cevapsiz birakir. Doz yalniz UYGULANIR ya da sebebiyle ATLANIR.
            ["order-uygulama-liste"] = new AksiyonTanimi[]
            {
                new("yatan.doz-uygula", "💉 Uygulandı", "yatan",
                    KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 10, UrunModu: 2, Bicim: "onay"),
                new("yatan.doz-atla",   "⤫ Atlandı (sebep gir)", "yatan",
                    KaynakKodu: "yatan.order", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "ret"),
                Yazdir(),
            },

            // HEMSIRE IZLEMI (699): olcum ve gozlem HUKUKI KAYITTIR -
            //   duzeltilmez, silinmez; yanlis kayit yeni bir satirla duzeltilir
            //   ve ikisi de durur. Bu yuzden listede duzenle/sil YOK.
            ["yatis-izlem-liste"] = new AksiyonTanimi[]
            {
                new("yatan.izlem-bildir", "🔔 Hekime Bildirildi", "yatan",
                    KaynakKodu: "yatan.izlem", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 10, UrunModu: 2,
                    Ipucu: "Eşiği aşan ölçüm için bildirim kaydı yazar"),
                Yazdir(),
            },

            // HIZMET ICMALI (700): tahakkuk ELLE GIRILMEZ, gun sonu isinden
            //   duser - elle giris acik olsaydi ayni gun hem otomatik hem elle
            //   iki kez faturalanirdi. Yeniden hesaplama, isin atladigi bir
            //   gunu kapatmak icin.
            ["yatis-tahakkuk-liste"] = new AksiyonTanimi[]
            {
                new("yatan.tahakkuk-hesapla", "🔄 Gün Sonunu Yeniden Çalıştır", "yatan",
                    KaynakKodu: "yatan", Islem: Islem.Degistir, Sira: 10, UrunModu: 2,
                    Ipucu: "Seçili satırın günü için yatak/refakat tahakkukunu üretir"),
                Yazdir(),
            },

            // RADYOLOJI CALISMA LISTESI (283): modulun giris ekrani. Durum
            //   akisi dugmelerle ilerler - "Cekildi" teknisyenin, rapor ve
            //   onay hekimin islemidir, o yuzden AYRI aksiyon yetkileri
            //   (rad.rapor_yaz / rad.rapor_onayla) uzerinden yonetilir.
            ["radyoloji-liste"] = new AksiyonTanimi[]
            {
                new("radyoloji.yeni",     "＋ Yeni İstem", "radyoloji", Kisayol: "Ctrl+N",
                    KaynakKodu: "radyoloji", Islem: Islem.Ekle, Sira: 10),
                new("radyoloji.duzenle",  "✎ Düzenle", "radyoloji", Kisayol: "Enter",
                    KaynakKodu: "radyoloji", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 20),
                // RANDEVU (316): radyolojide randevu CIHAZA verilir; kayit yine
                //   public.randevu'ya gider - ayri modul degil.
                new("radyoloji.randevu",  "📅 Randevu Ver", "radyoloji",
                    KaynakKodu: "randevu", Islem: Islem.Ekle,
                    KayitGerekir: true, Sira: 25),
                new("radyoloji.cekildi",  "✔ Çekildi İşaretle", "radyoloji",
                    KaynakKodu: "radyoloji", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 30),
                // SARF (320): cekimde kullanilan kontrast/malzeme stoktan duser.
                //   Cekim isaretlenince kendiliginden acilir; buton atlanmis ya
                //   da sonradan duzeltilecek dusum icin.
                new("radyoloji.sarf",     "🧪 Sarf Düş", "radyoloji",
                    KaynakKodu: "stok", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 35),
                new("radyoloji.rapor",    "✎ Rapor Yaz", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 40),
                // TESLIM (304): film/CD/basili rapor kime verildi - sonuc
                //   kisisel saglik verisi, "kime verdik" kayda gecer.
                new("radyoloji.teslim",   "📦 Sonuç Teslim Et", "radyoloji",
                    AksiyonYetkisi: "rad.teslim", KayitGerekir: true, Sira: 45),
                new("radyoloji.iptal",    "✖ İstemi İptal Et", "radyoloji",
                    AksiyonYetkisi: "rad.istem_iptal", KayitGerekir: true, Sira: 50),
            },

            // KRITIK BULGU TAKIBI (318): rapor ekraninda isaretlenen bulgunun
            //   HABER VERILDIGININ takibi. Bildirim ve kapatma ayri islemdir:
            //   kapatma karsi tarafin teyidini ifade eder.
            ["radyoloji-kritik-liste"] = new AksiyonTanimi[]
            {
                new("radyoloji.kritik-bildir", "📞 Bildirimi Kaydet", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 10),
                new("radyoloji.kritik-kapat",  "✔ Kapat (teyit alındı)", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 20),
                new("radyoloji.istem-ac",      "👁 İstemi Aç", "radyoloji",
                    KaynakKodu: "radyoloji", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
                new("radyoloji.rapor",         "📄 Raporu Aç", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 40),
            },

            // KONSULTASYON TAKIBI (318): istenen ikinci gorusler.
            ["radyoloji-konsultasyon-liste"] = new AksiyonTanimi[]
            {
                new("radyoloji.konsultasyon-cevap", "✎ Cevabı Yaz", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 10),
                new("radyoloji.istem-ac",           "👁 İstemi Aç", "radyoloji",
                    KaynakKodu: "radyoloji", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("radyoloji.rapor",              "📄 Raporu Aç", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 30),
            },

            // SONUC TESLIM TAKIBI (318): raporu onayli ama teslim edilmemis
            //   isler. Teslim modali calisma listesindekiyle AYNI.
            ["radyoloji-teslim-liste"] = new AksiyonTanimi[]
            {
                new("radyoloji.teslim",   "📦 Teslim Et", "radyoloji",
                    AksiyonYetkisi: "rad.teslim", KayitGerekir: true, Sira: 10),
                new("radyoloji.istem-ac", "👁 İstemi Aç", "radyoloji",
                    KaynakKodu: "radyoloji", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("radyoloji.rapor",    "📄 Raporu Aç", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 30),
            },

            // ENTEGRASYON HESAPLARI (336): Ayarlar > Kayit Kabul > Entegrasyon.
            // KATEGORILER (345): iki bolmeli ekran - her iki gridin de kendi
            //   arac cubugu var, aksiyonlar ortak.
            ["kategori-liste"] = new AksiyonTanimi[]
            {
                new("kategori.yeni",    "＋ Yeni", "stok",
                    Islem: Islem.Ekle, Sira: 10),
                new("kategori.duzenle", "✎ Düzenle", "stok",
                    Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("kategori.sil",     "🗑 Sil", "stok",
                    Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            },

            ["entegrasyon-liste"] = new AksiyonTanimi[]
            {
                new("entegrasyon.yeni",     "＋ Yeni", "entegrasyon",
                    Islem: Islem.Ekle, Sira: 10),
                new("entegrasyon.duzenle",  "✎ Düzenle", "entegrasyon",
                    Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("entegrasyon.sil",      "🗑 Sil", "entegrasyon",
                    Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                // Baglanti sinama: kimlik dogru mu, adres ayakta mi.
                new("entegrasyon.sina",     "🔌 Bağlantıyı Sına", "entegrasyon",
                    Islem: Islem.Gor, KayitGerekir: true, Sira: 40),
                // SKRS: kod listelerini servisten cekip yerel listeleri tazeler.
                new("entegrasyon.skrs-senkron", "⟳ SKRS Listelerini Güncelle",
                    "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50,
                    UrunModu: 2),
                // SKRS klinik kodlarini BOLUM KODUNA yazar (455): e-Nabiz
                //   paketlerindeki klinik alani bolum kodundan okunur.
                new("entegrasyon.skrs-klinik", "🏥 SKRS Klinik Kodlarını Eşle",
                    "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 55,
                    UrunModu: 2),
            },

            // HAKEDIS SATIRLARI (324): satirlar tahsilattan DOGAR - elle
            //   eklenmez. Buradaki aksiyonlar kaynaga gitmek ve donem
            //   kapatmak icindir.
            ["hakedis-liste"] = new AksiyonTanimi[]
            {
                new("hakedis.donem-kapat", "🔒 Dönemi Kapat", "prim",
                    AksiyonYetkisi: "prim.donem_kapat", Sira: 10),
                new("hakedis.kalem",       "↗ Kalemi Aç", "prim",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("hakedis.roller",      "👥 Rolleri Düzenle", "prim",
                    KaynakKodu: "prim", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 30),
                // ONAY (330): satiri kilitler - sonradan rol/belge turu
                //   degisse bile prim yeniden hesaplanmaz.
                new("hakedis.onayla",      "✔ Onayla", "prim",
                    AksiyonYetkisi: "prim.onayla", KayitGerekir: true, Sira: 40),
                new("hakedis.onay-kaldir", "↩ Onayı Kaldır", "prim",
                    AksiyonYetkisi: "prim.onayla", KayitGerekir: true, Sira: 50),
            },

            // HAKEDIS BASLIKLARI (324): kapatilmis donemler.
            ["hakedis-donem"] = new AksiyonTanimi[]
            {
                new("hakedis.donem-kapat", "🔒 Dönemi Kapat", "prim",
                    AksiyonYetkisi: "prim.donem_kapat", Sira: 10),
                new("hakedis.satirlar",    "📄 Satırları Gör", "prim",
                    KaynakKodu: "prim", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            },

            // RANDEVU (243): liste + takvim gorunumu ayni ekranda.
            ["randevu-liste"] = new AksiyonTanimi[]
            {
                new("randevu.yeni",     "＋ Yeni",   "randevu", Kisayol: "Ctrl+N",
                    KaynakKodu: "randevu", Islem: Islem.Ekle, Sira: 10),
                new("randevu.duzenle",  "✎ Düzenle", "randevu", Kisayol: "Enter",
                    KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("randevu.geldi",    "✔ Geldi",   "randevu",
                    KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30),
                new("randevu.gelmedi",  "✖ Gelmedi", "randevu",
                    KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
                // Randevudan BASVURUYA (265): hasta geldiginde poliklinik
                //   basvurusu acilir, randevunun hizmeti kalem olur.
                new("randevu.basvuru",  "➜ Başvuruya Dönüştür", "belge",
                    KaynakKodu: "belge", Islem: Islem.Ekle, KayitGerekir: true, Sira: 45),
                new("randevu.iptal",    "⊘ İptal",   "randevu", Hedef: "sagtus,palet",
                    KaynakKodu: "randevu", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50),
                new("randevu.sil",      "🗑 Sil",    "randevu", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "randevu", Islem: Islem.Sil, KayitGerekir: true, Sira: 60),
                new("genel.yazdir",     "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Aday musteriler (122). "Müşteriye Dönüştür" kaydi TASIMAZ, bayragi
            //   degistirir - firsat/gorev/adres gecmisi ayni kayitta kalir.
            ["aday-liste"] = new AksiyonTanimi[]
            {
                new("aday.yeni",      "＋ Yeni",   "cari", Kisayol: "Ctrl+N",
                    KaynakKodu: "cari", Islem: Islem.Ekle, Sira: 10),
                new("aday.duzenle",   "✎ Düzenle", "cari", Kisayol: "Enter",
                    KaynakKodu: "cari", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("aday.donustur",  "🤝 Müşteriye Dönüştür", "cari",
                    KaynakKodu: "cari", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30),
                new("aday.sil",       "🗑 Sil",       "cari", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "cari", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
                new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Hesap ekranlari (Kasa / Banka / POS / Kredi Karti / Kredi) - hepsi
            //   ayni 'hesap' kaynagi, tur'e gore ayri liste.
            ["hesap-liste"] = Crud("hesap", "hesap", "hesap", "＋ Ekle", silHedef: null),

            // Cek / Senet portfoyu. Cek uzerindeki ISLEMLER (tahsil/ciro/bozdurma)
            //   kasa turleriyle yapilir - Kasa planinin F5 fazinda baglanacak;
            //   burada simdilik kart islemleri var.
            ["cek-senet-liste"] = Crud("cek-senet", "cek-senet", "cek_senet", "＋ Ekle", silHedef: null),

            // Salt-gorunum ekranlari (ekstre, mizan...): yalniz cikti alma.
            //   "Yazdır" dugmesi acilir menusunde CSV Kaydet de var (GenGrid ekler).
            ["cikti-liste"] = [Yazdir()],

            // DOKUMAN ONAY KUYRUGU (419): satir = ADIM. Karar iki secenek -
            //   onay ya da ret; ret dokumani TASLAGA dondurur, hazirlayan
            //   duzeltip yeni surum acar (reddedilen surumu yeniden onaya
            //   gondermek, neyin degistigini gorunmez kilardi).
            ["dokuman-onay-liste"] =
            [
                new("dokuman.onay", "✔ Onayla", "dokuman-onay",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "dokuman.onayla", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("dokuman.ret", "✖ Reddet", "dokuman-onay",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "dokuman.onayla", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                Yazdir(),
            ],

            // DOKUMAN LISTESI (419) - mockup dokuman_listesi.html dugmeleri.
            //   YUKLE ve SABLONDAN URET burada YOK: ikisi de dosya secimi ve
            //   kaynak belirlemesi ister, kart galerisinden yurur. Buraya
            //   koymak, listede kaynagi olmayan bir dokuman acmak olurdu.
            // DOKUMAN LISTESI - dugme SIRASI mockuptaki gibi
            //   (Ekranlar/Dokuman/dokuman_listesi.html): Yukle · Duzenle · Sil ·
            //   Indir · Paylas · Bagla · Tasi · Etiket · Onaya Gonder ·
            //   Surum Gecmisi · Depo. "Sablondan Olustur" YOK: sablon
            //   ozelligi henuz kurulmadi, calismayan dugme koymuyoruz.
            ["dokuman-liste"] =
            [
                new("dokuman.yukle", "＋ Yükle", "dokuman",
                    Hedef: "araccubugu,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Ekle, Sira: 5),
                new("dokuman.duzenle", "✎ Düzenle", "dokuman",
                    Hedef: "araccubugu,sagtus,palet", Kisayol: "Enter",
                    KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("dokuman.sil", "🗑 Sil", "dokuman",
                    Hedef: "araccubugu,sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "dokuman", Islem: Islem.Sil, KayitGerekir: true, Sira: 15),
                new("dokuman.ac", "⬇ Aç / İndir", "dokuman",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("dokuman.paylas", "🔗 Paylaş", "dokuman",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 25),
                new("dokuman.bagla", "🔀 Bağla (kaynak)", "dokuman",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 30),
                new("dokuman.tasi", "🗂 Taşı (klasör)", "dokuman",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 35),
                new("dokuman.etiket", "🏷 Etiket", "dokuman",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 40),
                new("dokuman.gizlilik", "🔒 Gizlilik Sınıfı", "dokuman",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 45),
                new("dokuman.onaya-gonder", "✔ Onaya Gönder", "dokuman",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 50),
                // SURUM GECMISI ARAC CUBUGUNDAN KALDIRILDI (kullanici):
                //   surumler dokuman KARTININ kendi sekmesinde duruyor,
                //   listede ayri dugme gerekmiyor. Sag tus ve komut
                //   paletinde kaliyor - hizli erisim isteyen bulsun.
                new("dokuman.surum", "🧾 Sürüm Geçmişi", "dokuman",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Gor, KayitGerekir: true, Sira: 55),
                new("dokuman.depo", "📊 Depo Kullanımı", "dokuman",
                    Hedef: "araccubugu,palet",
                    KaynakKodu: "dokuman", Islem: Islem.Gor, Sira: 60),
                Yazdir(),
            ],

            // DOKUMAN AYARLARI (431): kategori ve klasor artik EKLENIP
            //   DEGISTIRILEBILIYOR. Kullanilan kayit silinemez - kural
            //   SilmeEngelleri'nde (sunucu), dugme yine gosterilir ki
            //   kullanici sebebini ogrensin.
            ["dokuman-kategori-liste"] = Crud("dokuman-kategori", "dokuman-kategori",
                                              "dokuman", "＋ Yeni", silHedef: null,
                                              yazdir: false),
            ["dokuman-klasor-liste"]   = Crud("dokuman-klasor", "dokuman-klasor",
                                              "dokuman", "＋ Yeni", silHedef: null,
                                              yazdir: false),

            // CIHAZ ARA KATMANI (432). Mesaj listesi salt gorunum: kayit
            //   cihazdan gelir, elle eklenmez. "Yeniden Isle" surucu
            //   duzeltildikten sonra ayni ham metni tekrar cozumler.
            ["cihaz-liste"] =
            [
                .. Crud("cihaz", "cihaz", "cihaz", "＋ Yeni", silHedef: null, yazdir: false),
                new("cihaz.klasor-tara", "📂 Klasörleri Tara", "cihaz",
                    Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "cihaz.isle", Sira: 40),
            ],

            ["cihaz-mesaj-liste"] =
            [
                new("cihaz.yeniden-isle", "↻ Yeniden İşle", "cihaz-mesaj",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "cihaz.isle", KayitGerekir: true, Sira: 10),
                // COZUMLEME ile SONUCA YAZMA ayri adimlar (433): mesaj
                //   cozumlenmis olabilir ama barkod hic eslesmemistir.
                //   Tek dugmede birlesseydi, eslesmeyen mesaj "islendi"
                //   gorunur ve sonuc kaybolurdu.
                new("lab.mesaj-sonuca-aktar", "🧪 Lab Sonucuna Aktar", "cihaz-mesaj",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "lab.sonuc", KayitGerekir: true, Sira: 15),
                Yazdir(),
            ],

            // SIGORTA v1 (430). Provizyon BASVURU KARTINDAN alinir; buradaki
            //   liste takip ve duzeltme icindir: tazele (searchProvisions),
            //   iptal (cancelProvision), dokuman gonderimi.
            //   Yapilamayacak adim GIZLENMEZ - sunucu sebebini soyler.
            ["sigorta-provizyon-liste"] =
            [
                new("sigorta.tazele", "↻ Durumu Tazele", "sigorta-provizyon",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "sigorta", Islem: Islem.Gor, KayitGerekir: true, Sira: 10),
                new("sigorta.dokuman", "📎 Doküman Gönder", "sigorta-provizyon",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "sigorta.provizyon", KayitGerekir: true, Sira: 20),
                new("sigorta.basvuru", "📝 Başvuruya Git", "sigorta-provizyon",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "sigorta", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
                new("sigorta.iptal", "✖ Provizyonu İptal Et", "sigorta-provizyon",
                    Hedef: "sagtus,palet",
                    AksiyonYetkisi: "sigorta.iptal", KayitGerekir: true, Sira: 40),
                Yazdir(),
            ],

            ["sigorta-hesap-liste"] =
            [
                .. Crud("sigorta-hesap", "sigorta-hesap", "sigorta", "＋ Yeni",
                        silHedef: null, yazdir: false),
                // BAGLANTI TESTI: jeton akisini ve kimlik bilgilerini dogrular,
                //   hicbir kayit olusturmaz. Kapinin acik olup olmadigi ancak
                //   boyle anlasilir - ilk provizyonda ogrenmek gec olur.
                new("sigorta.hesap-test", "🔌 Bağlantıyı Test Et", "sigorta-hesap",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "sigorta.ayar", KayitGerekir: true, Sira: 40),
            ],

            ["sigorta-kod-esleme-liste"] = Crud("sigorta-kod-esleme", "sigorta-kod-esleme",
                                                "sigorta", "＋ Yeni", silHedef: null,
                                                yazdir: false),

            ["sigorta-istek-log-liste"] = [Yazdir()],

            // URETIM v1 (429). Dugme SIRASI akisin sirasidir: emri ac,
            //   malzemeyi rezerve et, onayla, baslat (sarf), mamul gir, maliyeti
            //   kapat, emri kapat. Yapilamayacak adim GIZLENMEZ - sunucu sebebini
            //   soyler; gizlenen dugme "neden yapamiyorum" sorusunu cevapsiz
            //   birakirdi (ITS ile ayni gerekce).
            ["urun-agaci-liste"] =
            [
                .. Crud("urun-agaci", "urun-agaci", "uretim"),
                new("urun-agaci.maliyet", "🧮 Maliyet Hesapla", "urun-agaci",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
                new("urun-agaci.yeni-surum", "⧉ Yeni Sürüm", "urun-agaci",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Ekle, KayitGerekir: true, Sira: 50),
                new("urun-agaci.nerede", "🔎 Nerede Kullanılıyor", "urun-agaci",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
                new("urun-agaci.emir-ac", "🏭 Üretim Emri Aç", "urun-agaci",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Ekle, KayitGerekir: true, Sira: 70),
            ],

            ["uretim-emri-liste"] =
            [
                .. Crud("uretim-emri", "uretim-emri", "uretim"),
                new("uretim.rezerve", "🔒 Malzeme Rezerve", "uretim-emri",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
                new("uretim.eksik", "⚠ Eksik Malzeme", "uretim-emri",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Gor, KayitGerekir: true, Sira: 45),
                new("uretim.onayla", "✔ Onayla", "uretim-emri",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "uretim.onayla", KayitGerekir: true, Sira: 50),
                new("uretim.baslat", "▶ Üretime Başlat", "uretim-emri",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 55),
                new("uretim.sarf", "📤 Malzeme Sarf Fişi", "uretim-emri",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 60),
                new("uretim.mamul-giris", "📦 Mamul Girişi", "uretim-emri",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 65),
                new("uretim.fire", "🔥 Fire / Ret", "uretim-emri",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 70),
                new("uretim.agactan-yenile", "↻ Ağaçtan Yenile", "uretim-emri",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 75),
                new("uretim.maliyet-kapat", "🧮 Maliyet Kapat", "uretim-emri",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "uretim.maliyet", KayitGerekir: true, Sira: 80),
                new("uretim.kapat", "🔒 Emri Kapat", "uretim-emri",
                    Hedef: "sagtus,palet",
                    AksiyonYetkisi: "uretim.maliyet", KayitGerekir: true, Sira: 82),
                new("uretim.iptal", "✖ İptal Et", "uretim-emri",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "uretim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 85),
            ],

            ["is-merkezi-liste"] = Crud("is-merkezi", "is-merkezi", "uretim",
                                        "＋ Yeni", silHedef: null, yazdir: false),

            // LAB v1 (433/434). Tetkik ve panel sirandan CRUD; numune, sonuc
            //   ve cihaz eslemesi is akisi dugmeleri tasir.
            // LAB ISTEM (360 + 433): kart CRUD'u + kartla acilan isteme barkod
            //   uretimi. Uc uzerinden acilan istemde tup plani zaten calisir.
            ["lab-istem-liste"] =
            [
                .. Crud("lab-istem", "lab-istem", "lab"),
                // DIS NUMUNE ICIN AYRI DUGME YOK (kullanici: "dis numune
                //   kabul butona gerek kalmadi, yeni istem den girebiliyoruz").
                //   Istem kartinin kaynak varsayilani "Dis kurum"; gonderen
                //   kurum ve dis doktor arama penceresiyle seciliyor. Ayni isi
                //   yapan ikinci bir pencere, iki ayri dogrulama yolu demekti.
                // SONUC ELLE GIRISI (433, kullanici: "lab istem sonuclarini
                //   elle girmek istiyorum"). Uc ve kural motoru vardi,
                //   EKRANI yoktu. Istemin butun tetkikleri tek pencerede -
                //   hemogram 23 parametre, her biri icin ayri pencere
                //   teknisyeni 23 kez tiklatirdi.
                new("lab.sonuc-gir", "🧪 Sonuç Gir", "lab-istem",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.sonuc", Islem: Islem.Ekle, KayitGerekir: true,
                    Sira: 4),
                new("lab.numune-plani", "🏷 Barkod Üret", "lab-istem",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Ekle, KayitGerekir: true,
                    Sira: 40),
                // Kultur tetkiginin EKIMI istem satirindan baslar (436):
                //   ayri bir "kultur ac" ekrani, teknisyeni ayni kaydin iki
                //   yuzu arasinda gezdirirdi.
                new("lab.ekim", "🧫 Ekim Yap (kültür)", "lab-istem",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.kultur", Islem: Islem.Ekle, KayitGerekir: true,
                    Sira: 50),
                // SONUC RAPORU: hastaya verilen belge. Istem numarasiyla
                //   acilir - ayni istemdeki sayisal sonuc, kultur ve genetik
                //   TEK kagida basilir.
                // ETIKET: istemin TUM tupleri tek sayfada basilir - kan alma
                //   bankosu tupleri birlikte hazirlar.
                // BARKOD OKUT (mockup "📷 Barkod Okut"): bankonun asil giris
                //   yolu. Teknisyen elindeki tupu okutur, istem KENDILIGINDEN
                //   bulunur - listede ad aramak, ayni isimli iki hastada
                //   yanlis tupu kabul ettirir.
                new("lab.barkod-okut", "📷 Barkod Okut", "lab-istem",
                    Hedef: "araccubugu,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Gor, KayitGerekir: false,
                    Sira: 20),
                new("lab.etiket", "🏷 Etiket Bas", "lab-istem",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Gor, KayitGerekir: true,
                    Sira: 25),
                // KABUL / RET ISTEM DUZEYINDE: bir hastanin dort tupu birlikte
                //   alinir ve birlikte kabul edilir (mockup araç çubuğu).
                //   Tup bazli islem Numune Kabul ekraninda kalir.
                // AD KISA, RENK AYIRT EDICI (kullanici): "Kabul" yesil,
                //   "Ret" kirmizi. Ikisi yan yana duran KARSIT eylemdir;
                //   ayni renkte iki uzun etiket, acele eden bir kullaniciya
                //   yanlis dugmeye bastirir - ve ret geri alinmaz.
                new("lab.istem-kabul", "✔ Kabul", "lab-istem",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 27, Bicim: "onay"),
                new("lab.istem-ret", "✖ Ret", "lab-istem",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 28, Bicim: "ret"),
                new("lab.rapor", "🖨 Sonuç Raporu", "lab-istem",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
                new("lab.genetik-vaka", "🧬 Genetik Vaka Aç", "lab-istem",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Ekle, KayitGerekir: true,
                    Sira: 55),
                // Numune kabul ekranindakiyle AYNI kod: sevk mantigi tek
                //   yerde (disLabAksiyonlari) kalir, dugme iki listede durur.
                new("lab.dis-gonder", "🏍️ Dış Lab'a Gönder", "lab-istem",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "lab.dislab", Islem: Islem.Ekle, KayitGerekir: true,
                    Sira: 60),
                // SAKLAMA YERI: calisilmayi bekleyen tup nerede? Kayitsiz
                //   buzdolabi, tekrar calisma gerektiginde numuneyi
                //   bulunamaz hale getirir (mockup "🧊 Saklama Yeri").
                new("lab.saklama", "🧊 Saklama Yeri", "lab-istem",
                    Hedef: "araccubugu2,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 65),
            ],

            // MIKROBIYOLOJI (436). Kultur bir SUREC: her adim ayri dugme.
            //   Tek "kaydet" dugmesi, hangi asamada olundugunu gizlerdi.
            //   Yapilamayacak adim GIZLENMEZ - sunucu sebebini soyler.
            ["lab-kultur-liste"] =
            [
                new("lab.kultur-okuma", "👁 Okuma Kaydet", "lab-kultur",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("lab.kultur-izolat", "🔬 İzolat / İdentifikasyon", "lab-kultur",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                new("lab.kultur-antibiyogram", "💊 Antibiyogram", "lab-kultur",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 30),
                new("lab.kultur-on-rapor", "📄 Ön Rapor (Gram)", "lab-kultur",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 40),
                new("lab.kultur-rapor", "🖨 Sonuç Raporu", "lab-kultur",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab", Islem: Islem.Gor, KayitGerekir: true, Sira: 45),
                new("lab.kultur-onayla", "✔ Raporu Onayla", "lab-kultur",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 50),
                new("lab.kultur-iptal", "✖ Kültürü İptal Et", "lab-kultur",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 60),
                Yazdir(),
            ],

            // GENETIK (439). Vaka bir SUREC: onam -> izolasyon -> run ->
            //   varyant -> dogrulama -> onay. ONAM ayri dugme cunku raporun
            //   on kosulu (KVKK md. 6) ve tesadufi bulgu tercihi raporlamayi
            //   dogrudan degistirir.
            ["lab-genetik-liste"] =
            [
                new("lab.genetik-onam", "📋 Onam Kaydet", "lab-genetik-vaka",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("lab.genetik-izolasyon", "🧪 DNA İzolasyon", "lab-genetik-vaka",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                new("lab.genetik-run", "📚 Run'a Al", "lab-genetik-vaka",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 30),
                new("lab.genetik-kalite", "📊 Kalite Metrikleri", "lab-genetik-vaka",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 40),
                new("lab.genetik-varyant", "🧬 Varyant Ekle", "lab-genetik-vaka",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 50),
                new("lab.genetik-rapor", "🖨 Sonuç Raporu", "lab-genetik-vaka",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab", Islem: Islem.Gor, KayitGerekir: true, Sira: 55),
                new("lab.genetik-onayla", "✔ Raporu Onayla", "lab-genetik-vaka",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 60),
                new("lab.genetik-iptal", "✖ Vakayı İptal Et", "lab-genetik-vaka",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 70),
                Yazdir(),
            ],

            // VARYANT HAVUZU: sinif ezme ve Sanger dogrulama.
            ["lab-varyant-liste"] =
            [
                new("lab.varyant-sinif", "🏷 Sınıfı Değiştir (uzman)", "lab-varyant",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 10),
                new("lab.varyant-dogrulama", "🔁 Sanger Doğrulama", "lab-varyant",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                Yazdir(),
            ],

            ["lab-genetik-run-liste"] = [Yazdir()],
            // KALITE KONTROL (442). Olcumun kendi karti yok; girise ve
            //   duzeltici faaliyete uctan gidilir. RET satirinda aksiyon
            //   zorunlu (ISO 15189) - kapatilmamis ret listede kalir.
            ["lab-kk-liste"] =
            [
                new("lab.kk-olcum", "＋ KK Sonucu (elle)", "lab-kk-olcum",
                    Hedef: "araccubugu,palet",
                    KaynakKodu: "lab.kk", Islem: Islem.Ekle, Sira: 10),
                new("lab.kk-aksiyon", "🛠 Düzeltici Faaliyet", "lab-kk-olcum",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.kk", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                new("lab.kk-grafik", "📈 Levey-Jennings", "lab-kk-olcum",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.kk", Islem: Islem.Gor, KayitGerekir: true,
                    Sira: 30),
                Yazdir(),
            ],

            ["lab-kk-lot-liste"] = Crud("lab-kk-lot", "lab-kk-lot", "lab.kk"),
            ["lab-kk-kural-liste"] = Crud("lab-kk-kural", "lab-kk-kural", "lab.kk"),
            ["lab-dkk-liste"] = Crud("lab-dkk", "lab-dkk", "lab.kk"),
            ["lab-cihaz-olay-liste"] =
                Crud("lab-cihaz-olay", "lab-cihaz-olay", "lab.kk"),
            ["lab-indeks-esik-liste"] =
                Crud("lab-indeks-esik", "lab-indeks-esik", "lab.tetkik"),

            // DIS LABORATUVAR (445). Gonderim bir surec: her adim ayri dugme.
            //   "Sonuc Gir" burada cunku dis lab sonucu PDF/portal ile gelir
            //   ve elle yazilir; oto-onaya girmez.
            ["lab-dis-gonderim-liste"] =
            [
                new("lab.dis-yolda", "🚚 Yola Çıktı", "lab-dis-gonderim",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("lab.dis-teslim", "📦 Teslim Edildi", "lab-dis-gonderim",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                new("lab.dis-sonuc", "🧾 Sonuç Gir", "lab-dis-gonderim",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.sonuc", Islem: Islem.Ekle, KayitGerekir: true,
                    Sira: 30),
                new("lab.dis-ret", "✖ Dış Lab Reddetti", "lab-dis-gonderim",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 40),
                new("lab.dis-fatura", "🧾 Alış Faturası Eşleştir", "lab-dis-gonderim",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 50),
                Yazdir(),
            ],

            ["lab-dis-lab-liste"] = Crud("lab-dis-lab", "lab-dis-lab", "lab.dislab"),

            ["lab-gen-liste"] = Crud("lab-gen", "lab-gen", "lab.gen"),
            ["lab-genetik-panel-liste"] =
                Crud("lab-genetik-panel", "lab-genetik-panel", "lab.gen"),

            ["lab-besiyeri-liste"] = Crud("lab-besiyeri", "lab-besiyeri", "lab.mikro"),
            ["lab-organizma-liste"] = Crud("lab-organizma", "lab-organizma", "lab.mikro"),
            ["lab-antibiyotik-liste"] =
                Crud("lab-antibiyotik", "lab-antibiyotik", "lab.mikro"),

            ["lab-tetkik-liste"] = Crud("lab-tetkik", "lab-tetkik", "lab.tetkik"),
            ["lab-panel-liste"] = Crud("lab-panel", "lab-panel", "lab.tetkik"),
            // BILDIRIM SABLONLARI (399): kart vardi ama ekran ARAC CUBUGU
            //   tanimli degildi - kullanici kayit ekleyemiyor, bunu "yetkim
            //   yok" saniyordu. Kod SABIT (kodla cagrilir), metin serbest.
            //   Sil ARAC CUBUGUNDA (kullanici: "ekle/duzenle/sil butonlari"):
            //   varsayilan Crud silmeyi yalniz sag tus/palete koyar.
            ["bildirim-sablon-liste"] =
                Crud("bildirim-sablon", "bildirim-sablon", "bildirim_sablon",
                     silHedef: null),

            // e-NABIZ KOD ESLEME (454): duz katalog - ekle/duzenle/sil.
            ["enabiz-kod-esleme-liste"] =
                Crud("enabiz-kod-esleme", "enabiz-kod-esleme", "entegrasyon"),

            ["lab-cihaz-esleme-liste"] =
                Crud("lab-cihaz-esleme", "lab-cihaz-esleme", "lab.cihaz",
                     "＋ Yeni", silHedef: "sagtus,palet", yazdir: false),

            // NUMUNE KABUL: ret AYRI dugme ve neden ister - "kabul etmedim"
            //   ile "reddettim" farkli seylerdir; ret istem satirlarini
            //   "tekrar bekliyor"a alir, sessiz birakmak sonucu hic
            //   gelmeyen istem uretirdi.
            ["lab-numune-liste"] =
            [
                new("lab.numune-alindi", "🩸 Alındı İşaretle", "lab-numune",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("lab.numune-kabul", "✔ Kabul Et", "lab-numune",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                new("lab.numune-ret", "✖ Reddet", "lab-numune",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 30),
                // DIS LABA GONDER: numune kabul bankosundan - tup elde
                //   iken sevk edilir (mockup: "📦 Dis Lab'a Gonder").
                new("lab.dis-gonder", "🏍️ Dış Lab'a Gönder", "lab-numune",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.dislab", Islem: Islem.Ekle, KayitGerekir: true,
                    Sira: 35),
                new("lab.barkod-yazdir", "🏷 Barkod Etiketi", "lab-numune",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "lab.numune", Islem: Islem.Gor, KayitGerekir: true,
                    Sira: 40),
                Yazdir(),
            ],

            // SONUC ONAY KUYRUGU: iki asama ayri dugme (teknik / uzman).
            //   Onayli sonuc GUNCELLENMEZ - "Duzelt" eski satiri iptal edip
            //   yenisini acar, bu yuzden ayri dugme.
            ["lab-sonuc-liste"] =
            [
                new("lab.teknik-onay", "✔ Teknik Onay", "lab-sonuc",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.sonuc", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("lab.onayla", "✅ Uzman Onayı (yayınla)", "lab-sonuc",
                    Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 20),
                new("lab.duzelt", "✎ Sonucu Düzelt", "lab-sonuc",
                    Hedef: "sagtus,palet",
                    AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 30),
                new("lab.panik-bildir", "☎ Panik Bildirimi", "lab-sonuc",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "lab.sonuc", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 40),
                Yazdir(),
            ],

            // ITS KUYRUGU (427): gonderilmis bildirim IPTAL EDILEMEZ - ITS'de
            //   kayit olustu, geri almak ayri bir bildirim turudur (iade /
            //   deaktivasyon). Kural sunucuda, dugme yine de gosterilir ki
            //   kullanici sebebini ogrensin.
            ["its-liste"] =
            [
                new("its.gonder", "📤 Şimdi Gönder", "its-bildirim",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "stok", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
                new("its.iptal", "✖ İptal Et", "its-bildirim",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "stok", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                Yazdir(),
            ],

            // e-NABIZ KUYRUGU (415): eksik duzeltilince paket KAYNAKTAN
            //   YENIDEN URETILIR - paket satirini elle duzeltmek, gonderilen
            //   veriyle kayittaki veriyi ayirirdi.
            ["enabiz-liste"] =
            [
                new("enabiz.gonder", "📤 Şimdi Gönder", "enabiz-paket",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 5),
                new("enabiz.yeniden-uret", "↻ Kaynaktan Yeniden Üret", "enabiz-paket",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 10),
                new("enabiz.iptal", "✖ İptal Et", "enabiz-paket",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true,
                    Sira: 20),
                Yazdir(),
            ],

            // HEKIM CALISMA LISTESI (410): gunun isi tek ekranda. Cagirma ve
            //   muayeneye alma AYRI dugmelerdir - hasta cagrilip gelmeyebilir,
            //   ikisini birlestirmek "geldi mi" sorusunu olculemez yapardi.
            ["hekim-liste"] =
            [
                new("hekim.cagir", "📢 Sıradakini Çağır", "hekim-listesi",
                    Hedef: "araccubugu,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, Sira: 10),
                new("hekim.secileni-cagir", "🔔 Seçileni Çağır", "hekim-listesi",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("hekim.al", "🩺 Muayeneye Al", "hekim-listesi",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Ekle, KayitGerekir: true, Sira: 30),
                Yazdir(),
            ],

            // MUAYENE (409, Faz 1): hekimin gunluk isi iki dugmeye baglidir.
            //   "Muayeneye Al" baslangic zamanini yazar (USS Muayene
            //   Baslangic) - hasta ne zaman iceri girdi sorusunun tek cevabi
            //   budur; kartin acilma zamani degil. "Tamamla" kaydi KILITLER,
            //   basvuruyu tahakkuka dondurur ve e-Nabiz kuyruguna atar; bu
            //   yuzden eksik kayitta reddedilir (ana tani + sikayet + karar).
            ["muayene-liste"] =
            [
                new("muayene.al", "▶ Muayeneye Al", "muayene",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
                new("muayene.tamamla", "✔ Tamamla", "muayene",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                // ISTEM AC ve SABLON UYGULA LISTEDE YOK (kullanici): ikisi de
                //   muayene KARTININ sekmelerinde yapiliyor (Istem & Sonuclar,
                //   Fizik Muayene). Listede tekrar etmek, hangi muayeneye
                //   uygulandigini karti acmadan gormeyi zorlastiriyordu.
                //   Aksiyon KODLARI duruyor - kart arac cubugu onlari cagiriyor.
                new("muayene.istem", "🔬 İstem Aç", "muayene",
                    Hedef: "sagtus",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 25),
                new("muayene.sablon", "📋 Şablon Uygula", "muayene",
                    Hedef: "sagtus",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30),
                // Mockup fizik muayene araç çubuğu: şablonla açılmış boş
                //   satırları tek tıkla "normal" işaretler. Yazılmış bulguya
                //   dokunmaz - kural uçta.
                // Mockup tanı araç çubuğu: hastanın önceki tanıları ve
                //   hekimin sık yazdıkları - kod aramak yerine listeden seçmek
                //   aynı hastalığın iki ayrı ICD ile yazılmasını önler.
                new("muayene.taniOnceki", "🕘 Önceki Tanılar", "muayene",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 36),
                new("muayene.taniSik", "⭐ Sık Tanılarım", "muayene",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 37),
                new("muayene.normal", "☑ Tümü Normal", "muayene",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 35),
                new("muayene.ozet", "🧾 Özeti Derle", "muayene",
                    Hedef: "sagtus,palet",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
                new("kart.duzenle", "✎ Düzenle", "muayene", Kisayol: "F2",
                    KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50),
                Yazdir(),
            ],

            // ILAC KATALOGU (406/407): katalog senkronla dolar, AMA FIYAT
            //   DOLMAZ - TITCK Detayli Fiyat Listesi kurumsal portal hesabi
            //   istiyor. O kapi acilana kadar fiyati elle girmenin bir yolu
            //   olmali, yoksa ilac cikisi fiyatsiz kalir.
            ["ilac-liste"] =
            [
                new("ilac.fiyat", "₺ Fiyat Gir", "ilac", Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "katalog", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
                Yazdir(),
            ],

            // ZAMANLI ISLER (405): zamani beklemeden calistir + zamanlamayi
            //   duzenle. "Simdi Calistir" KayitGerekir - satir secilmeden
            //   pasif gelir; is zaten calisiyorsa sunucu ikinci kez baslatmaz.
            ["zamanli-is-liste"] =
            [
                new("zamanli-is.calistir", "▶ Şimdi Çalıştır", "zamanli-is",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "zamanli_is", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
                new("kart.duzenle", "✎ Düzenle", "zamanli-is", Kisayol: "F2",
                    KaynakKodu: "zamanli_is", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                Yazdir(),
            ],

            // BILDIRIM KUYRUGU (399): gitmeyeni yeniden dene, gitmesini
            //   istemedigini iptal et. Ikisi de KayitGerekir - satir secilmeden
            //   pasif gelir ve sebebi sunucudan yazilir. Toplu secim destekli:
            //   gece bosa dusmus butun bildirimler tek seferde denenebilsin.
            ["bildirim-liste"] =
            [
                new("bildirim.tekrar", "🔄 Tekrar Dene", "bildirim",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "bildirim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
                new("bildirim.iptal", "✖ İptal Et", "bildirim",
                    Hedef: "araccubugu,sagtus,palet",
                    KaynakKodu: "bildirim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                Yazdir(),
            ],

            // HASTA EKSTRESI: cikti aksiyonlari + secili satirin belgesine
            //   gidis (kullanici: "bir satiri isaretledigimde ustte Yazdır'in
            //   solunda Başvuru Aç aktif olsun"). KayitGerekir ile satir
            //   secilmeden pasif gelir - sebebi sunucudan yazilir.
            ["hasta-ekstre"] = [BasvuruAc(), Yazdir()],

            // Stok Ayarlari > Depolar sekmesi.
            ["sube-liste"] = Crud("sube", "sube", "sube", "＋ Ekle", silHedef: null, yazdir: false),

            ["hizmet-liste"] = Crud("hizmet", "hizmet", "hizmet", "＋ Ekle", silHedef: null, yazdir: false),

            ["depo-liste"] = Crud("depo", "depo", "stok", "＋ Ekle", silHedef: null, yazdir: false),

            ["belge-liste"] = new AksiyonTanimi[]
            {
                // ÜTS belge koprusu (226): satista satir basina VERME, alista
                //   askidakilerle eslesip ALMA. Sunucu tur guard'li - yalniz
                //   alis/satis irsaliye/fatura/fis. Sag tusta durur, arac
                //   cubugunu kalabaliklastirmaz.
                new("belge.uts-bildir", "🩺 ÜTS Bildir", "stok",
                    Hedef: "sagtus,palet", AksiyonYetkisi: "uts.bildir",
                    KayitGerekir: true, Sira: 62),
                new("belge.yeni",  "＋ Yeni",      "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",    "Belgeyi Ac",   "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                // SIL, "Belgeyi Aç"in saginda (kullanici). Silme yalniz IZI
                //   OLMAYAN belgede mumkun; kesin/izli belgede "İptal Et".
                new("belge.sil",   "🗑 Sil",       "belge", Kisayol: "Del",
                    KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
                new("belge.kesinlestir", "Kesinlestir", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.kesinlestir", KayitGerekir: true, Sira: 30),
                // DONUSTUR YOK (kullanici): fatura zincirin SONU - siparis ve
                //   irsaliye faturaya donusur, fatura baska bir belgeye donusmez.
                //   Aksiyon siparis-liste ve irsaliye-liste ekranlarinda duruyor.
                new("belge.iptal", "Belgeyi Iptal Et", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
                // e-BELGE MENUSU (Delphi menu sirasiyla ayni, kullanici istegi):
                //   Hazırla · Ön İzle · Gönder | Seri Değiştir · Hazırı Geri Al |
                //   PDF / HTML / XML Kaydet | Mesaj Geçmişi.
                //   AYRAC: kodu "ebelge.ayrac*" olan satirlar - combo'da cizgi
                //   olarak cizilir, secilemez. Sira degerleri bosluklu ki araya
                //   yeni adim girerse numaralar yeniden yazilmasin.
                new("ebelge.hazirla", "Hazırla", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 41),
                new("ebelge.onizle", "Ön İzle", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 42),
                new("ebelge.gonder", "Gönder", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 43),
                new("ebelge.ayrac1", "─", "ebelge", Hedef: "sagtus", Sira: 44),
                new("ebelge.seri", "Seri Değiştir", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 45),
                new("ebelge.sifirla", "Hazırı Geri Al", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 46),
                // IPTAL (188): e-Arsivde dogrudan iptal, e-Faturada IPTAL TALEBI.
                //   Hangisi oldugunu sunucu belirler; kullanici tek dugme gorur.
                new("ebelge.iptal", "İptal Et / İptal Talebi", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 47),
                new("ebelge.ayrac2", "─", "ebelge", Hedef: "sagtus", Sira: 48),
                new("ebelge.pdf", "PDF Kaydet", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 49),
                new("ebelge.html", "HTML Kaydet", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 50),
                new("ebelge.xml", "XML Kaydet", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 51),
                new("ebelge.ayrac3", "─", "ebelge", Hedef: "sagtus", Sira: 52),
                new("ebelge.durum", "Durum Sorgula", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 53),
                new("ebelge.mesajlar", "Mesaj Geçmişini Göster", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 54),
                // MUHASEBE FISI (190) ve DONUSUM ZINCIRI (F8): belgeden tek
                //   tikla fise ve zincirin iki ucuna gidilir.
                new("belge.fis-gor",   "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
                new("belge.kaynak-ac", "Kaynak Belgeyi Aç",  "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
                new("belge.hedef-ac",  "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 62),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // GELEN e-BELGE KUTUSU (187): kutuyu yenile, icerigi gor, yanitla.
            //   "Yeni" YOK - gelen belgeyi biz uretmeyiz.
            ["gelen-belge-liste"] = new AksiyonTanimi[]
            {
                new("gelen.yenile",  "⟳ Kutuyu Yenile", "gelen",
                    AksiyonYetkisi: "ebelge.gonder", Sira: 10),
                new("gelen.goruntule", "Belgeyi Görüntüle", "gelen", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("gelen.kabul",   "✓ Kabul Et",      "gelen", Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 30),
                new("gelen.red",     "✕ Reddet",        "gelen", Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 40),
                // ALIS FATURASINA AKTAR: kutu satiri muhasebeye ancak boyle girer
                //   (kutunun kendisi cari borc/alacak URETMEZ - kullanici kurali).
                //   Kabulde otomatik calisir; burada yanit gerekmeyen belgeler
                //   (temel fatura / e-Arsiv) ve tekrar denemeler icin durur.
                new("gelen.aktar",   "🧾 Faturaya Aktar", "gelen",
                    KaynakKodu: "belge", Islem: Islem.Ekle, KayitGerekir: true, Sira: 25),
                // e-FATURA KOMBOSU (kullanici): giden listedekiyle AYNI serit -
                //   grup "ebelge" oldugu icin arac cubugunda degil kombo'da cikar.
                //   Gelen belgede hazirla/gonder YOK; cikti adimlari var.
                new("ebelge.onizle",   "Ön İzle",     "ebelge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 41),
                new("ebelge.ayrac1",   "─",           "ebelge", Hedef: "sagtus", Sira: 42),
                new("ebelge.pdf",      "PDF Kaydet",  "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 43),
                new("ebelge.html",     "HTML Kaydet", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 44),
                new("ebelge.xml",      "XML Kaydet",  "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 45),
                new("ebelge.ayrac2",   "─",           "ebelge", Hedef: "sagtus", Sira: 46),
                new("ebelge.mesajlar", "Mesaj Geçmişini Göster", "ebelge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 47),
                new("gelen.xml",     "XML Kaydet",      "gelen", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 50),
                new("genel.yazdir",  "🖨️ Yazdır",     "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Siparis listesi: buradan irsaliye/faturaya donusum yapilir (F8).
            //   Ayni 'belge' kaynagi, tur in (9,19) sabit filtresiyle.
            // TEKLIF listesi (216): siparis setinin sadesi - donusum/iptal/fis
            //   akislari ilk surumde yok, yalniz ekle/ac/sil + yazdir.
            ["teklif-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni", "＋ Yeni Teklif", "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",   "Aç",             "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("belge.sil",  "🗑 Sil",         "belge", Kisayol: "Del",
                    KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
                // Teklif -> siparis (KABUL sartiyla; istemci ve sunucu dogrular).
                new("belge.donustur", "⇢ Siparişe Dönüştür", "belge",
                    AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
                new("genel.yazdir", "🖨️ Yazdır",   "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // DEMIRBAS listesi (216): standart kart Crud'u.
            ["demirbas-liste"] = Crud("demirbas", "demirbas", "demirbas"),

            // ECZANE (722). AKIS DUGMESI YOK: eczaci karari, doz kontrolu,
            //   hazirlama dogrulamasi ve imha onayi kendi uclarini ister -
            //   o uclar bu turda YAZILMADI. Calismayan bir dugme koymak,
            //   kullaniciya var olmayan bir yetenek vaat etmektir.
            ["eczane-kontrol-liste"] =
                [.. Crud("eczane-kontrol", "eczane", "eczane.order"),
                 // KARAR AYRI YETKİ (`eczane.onay`): uyarıyı görmek ile onu
                 //   kapatmak aynı sorumluluk değil.
                 new("eczane-kontrol.karar", "✓ Eczacı Kararı", "eczane",
                     AksiyonYetkisi: "eczane.onay", KayitGerekir: true, Sira: 15,
                     UrunModu: 2, Bicim: "bir",
                     Ipucu: "Yüksek düzey uyarıyı 'uygun' kapatmak gerekçe ister"),
                 new("eczane-kontrol.hekim-yanit", "📞 Hekim Yanıtı", "eczane",
                     KaynakKodu: "eczane.order", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16, UrunModu: 2)],

            ["eczane-doz-liste"] =
                [.. Crud("eczane-doz", "eczane", "eczane.doz"),
                 // SIRA SUNUCUDA: hazırlanmadan kontrol, kontrol edilmeden teslim yok.
                 new("eczane-doz.hazirla", "▶ Hazırlandı", "eczane",
                     KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, UrunModu: 2),
                 new("eczane-doz.kontrol", "✓ Kontrol Edildi", "eczane",
                     KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16, UrunModu: 2, Bicim: "bir",
                     Ipucu: "Hazırlayan kendi hazırladığını kontrol edemez"),
                 new("eczane-doz.teslim", "🚚 Teslim Et", "eczane",
                     KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 17, UrunModu: 2),
                 new("eczane-doz.iade", "↩ İade", "eczane", Hedef: "sagtus,palet",
                     KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 18, UrunModu: 2),
                 new("eczane-doz.imha", "🗑 İmha", "eczane", Hedef: "sagtus,palet",
                     AksiyonYetkisi: "eczane.imha", KayitGerekir: true,
                     Sira: 19, UrunModu: 2)],

            ["eczane-hazirlama-liste"] =
                [.. Crud("eczane-hazirlama", "eczane", "eczane.hazirlama"),
                 new("eczane-hazirlama.doz-hesapla", "🧮 Doz Hesapla", "eczane",
                     KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 14, UrunModu: 2,
                     Ipucu: "VYA ve protokol dozundan ÖNERİ üretir; uygulanacak dozu eczacı girer"),
                 // HASTA GELMEDEN HAZIRLANMAZ: hazırlanıp iptal edilen
                 //   kemoterapi sitotoksik atık olarak imha edilir.
                 new("eczane-hazirlama.hasta-geldi", "🧍 Hasta Geldi", "eczane",
                     KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, UrunModu: 2),
                 new("eczane-hazirlama.hazirla", "▶ Hazırlamaya Başla", "eczane",
                     KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16, UrunModu: 2, Bicim: "bir"),
                 new("eczane-hazirlama.dogrula", "✓ 2. Eczacı Doğrulaması", "eczane",
                     KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 17, UrunModu: 2, Bicim: "onay",
                     Ipucu: "Kemoterapide yanlış doz geri alınamaz - doğrulayan başkası olmalı"),
                 new("eczane-hazirlama.teslim", "🚚 Teslim Et", "eczane",
                     KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 18, UrunModu: 2),
                 new("eczane-hazirlama.iptal", "✖ İptal", "eczane", Hedef: "sagtus,palet",
                     KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 19, UrunModu: 2)],

            ["eczane-iade-liste"] =
                [.. Crud("eczane-iade", "eczane", "eczane.iade"),
                 // ÜÇ ÖLÇÜT: ambalaj / sulandırma / soğuk zincir. Biri "evet"
                 //   ise stoğa kabul REDDEDİLİR - burada zorlama yok.
                 new("eczane-iade.karar-stok", "✓ Stoğa Kabul", "eczane",
                     KaynakKodu: "eczane.iade", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, UrunModu: 2, Bicim: "onay",
                     Ipucu: "Ambalajı açılmış / sulandırılmış / soğuk zinciri bozulmuş ilaç kabul edilmez"),
                 new("eczane-iade.karar-imha", "🔥 İmhaya", "eczane",
                     AksiyonYetkisi: "eczane.imha", KayitGerekir: true,
                     Sira: 16, UrunModu: 2),
                 new("eczane-iade.karar-kasa", "🔴 Kasaya (kontrollü)", "eczane",
                     AksiyonYetkisi: "eczane.kontrollu", KayitGerekir: true,
                     Sira: 17, UrunModu: 2,
                     Ipucu: "Kontrollü ilaç defterine iade satırı yazılır")],

            ["eczane-imha-liste"] =
                [.. Crud("eczane-imha", "eczane", "eczane.imha"),
                 new("eczane-imha.onayla", "✓ Komisyon Onayı", "eczane",
                     AksiyonYetkisi: "eczane.imha_onay", KayitGerekir: true,
                     Sira: 15, UrunModu: 2,
                     Ipucu: "İmha tek kişinin işi değil - komisyon yazılmadan ilerlemez"),
                 new("eczane-imha.imha-et", "🔥 İmha Et (stoktan düş)", "eczane",
                     AksiyonYetkisi: "eczane.imha_onay", KayitGerekir: true,
                     Sira: 16, UrunModu: 2, Bicim: "tehlike",
                     Ipucu: "Çıkış fişi keser; kontrollü kalemler deftere de yazılır")],
            // KONTROLLU DEFTER ve MIAD: kart yok, yalniz okunur.
            //   Defter satiri SILINEMEZ (722 tetigi) - "Sil" dugmesi koymak,
            //   basilinca 422 donen bir dugme olurdu.
            // DEFTER SATIRI SİLİNMEZ (722 tetiği) - "Sil" düğmesi basılınca
            //   422 dönen bir düğme olurdu. Yazma kendi ucundan geçer.
            ["kontrollu-defter-liste"] =
                [new("kontrollu-defter.yaz", "🗒️ Defter Kaydı", "eczane",
                     Hedef: "araccubugu", AksiyonYetkisi: "eczane.kontrollu",
                     Sira: 10, UrunModu: 2,
                     Ipucu: "Hatalı satır silinmez; düzeltme satırıyla kapatılır"),
                 Yazdir()],
            ["eczane-miad-liste"] = [Yazdir()],

            // BIYOMEDIKAL (723). Cihaz envanterinin karti DEMIRBAS kartidir -
            //   ekran kodu ayri, Crud ayni karta bagli.
            ["demirbas-cihaz-liste"] =
                [.. Crud("demirbas", "demirbas", "demirbas"),
                 new("demirbas-cihaz.hareket-zimmet", "🔄 Zimmet Değiştir", "demirbas",
                     AksiyonYetkisi: "demirbas.zimmet", KayitGerekir: true,
                     Sira: 15, UrunModu: 2),
                 new("demirbas-cihaz.hareket-yer", "📍 Yer Değiştir", "demirbas",
                     KaynakKodu: "demirbas", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16, UrunModu: 2),
                 new("demirbas-cihaz.hareket-havuz", "📦 Yedek Havuza", "demirbas",
                     KaynakKodu: "demirbas", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 17, UrunModu: 2,
                     Ipucu: "Arıza anında yerine konacak cihaz havuzu"),
                 // AÇIK İŞ EMRİ VARKEN HURDA YOK (uç reddeder).
                 new("demirbas-cihaz.hareket-hurda", "🗑️ Hurdaya Ayır", "demirbas",
                     Hedef: "sagtus,palet", AksiyonYetkisi: "demirbas.hurda",
                     KayitGerekir: true, Sira: 18, UrunModu: 2, Bicim: "tehlike")],

            ["demirbas-kalibrasyon-liste"] =
                [.. Crud("demirbas-kalibrasyon", "demirbas", "demirbas.kalibrasyon"),
                 new("demirbas-kalibrasyon.tamamla", "✓ Kalibrasyonu Tamamla", "demirbas",
                     AksiyonYetkisi: "demirbas.kalibrasyon", KayitGerekir: true,
                     Sira: 15, UrunModu: 2, Bicim: "onay",
                     Ipucu: "Sonuç ölçümlerden türer; sınır dışı ölçümde 'uygun' seçilemez")],

            // ============================================= TEKNIK SERVIS (773) ==
            //  UC KATMAN, UC EKRAN: cagri (SLA isliyor) -> is emri (yapilan
            //  is) -> ziyaret (bir gidis). Aksiyonlar da o sirayi izler.
            ["servis-cagri-liste"] =
                [.. Crud("servis-cagri", "servis", "servis"),
                 new("servis-cagri.is-emri", "🗂️ İş Emri Aç", "servis",
                     KaynakKodu: "servis", Islem: Islem.Ekle,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Çağrı atandı olur, ilk yanıt zamanı damgalanır"),
                 new("servis-cagri.cihaz-parki", "📋 Cihaz Parkı", "servis",
                     Hedef: "sagtus,palet", KaynakKodu: "servis.cihaz",
                     Islem: Islem.Gor, KayitGerekir: true, Sira: 18,
                     Ipucu: "Müşterideki cihazlar, garanti ve sözleşme durumu")],

            //  IS EMRI: ziyaret ve emanet buradan yurur; TESLIM ayri aksiyon
            //  yetkisidir (`servis.teslim`) - duzenlemek ile kapatmak ayni
            //  sorumluluk degil.
            ["servis-is-emri-liste"] =
                [.. Crud("servis-is-emri", "servis", "servis"),
                 new("servis-is-emri.ziyaret", "🚐 Ziyaret Başlat", "servis",
                     KaynakKodu: "servis", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Varış damgalanır; kapanışta imza ve sonuç sorulur"),
                 new("servis-is-emri.emanet", "🔄 Emanet Cihaz Ver", "servis",
                     KaynakKodu: "servis", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16,
                     Ipucu: "İade alınmadan iş emri kapanmaz"),
                 new("servis-is-emri.teslim", "📦 Teslim Et", "servis",
                     AksiyonYetkisi: "servis.teslim", KayitGerekir: true,
                     Sira: 20, Bicim: "bir",
                     Ipucu: "Açık emanet ya da kapanmamış ziyaret varken kapanmaz"),
                 new("servis-is-emri.ziyaretler", "📍 Ziyaretler", "servis",
                     Hedef: "sagtus,palet", KaynakKodu: "servis",
                     Islem: Islem.Gor, KayitGerekir: true, Sira: 22)],

            ["servis-ziyaret-liste"] =
                [.. Crud("servis-ziyaret", "servis", "servis"),
                 new("servis-ziyaret.kapat", "✓ Ziyareti Kapat", "servis",
                     KaynakKodu: "servis", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "İmza alınamadıysa gerekçe zorunlu")],

            //  ACIK EMANET AYRI LISTE: is emrinin icinde kalirsa kapanan is
            //  emriyle birlikte gorunmez olur.
            ["servis-emanet-liste"] =
                [.. Crud("servis-emanet", "servis", "servis"),
                 new("servis-emanet.iade", "↩ İade Al", "servis",
                     KaynakKodu: "servis", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir")],

            ["taraf-cihaz-liste"] = [.. Crud("taraf-cihaz", "servis", "servis.cihaz")],

            ["servis-sozlesme-liste"] =
                [.. Crud("servis-sozlesme", "servis", "servis.sozlesme")],

            ["demirbas-is-emri-liste"] =
                [.. Crud("demirbas-is-emri", "demirbas", "demirbas.isemri"),
                 new("demirbas-is-emri.ata", "👤 Ata", "demirbas",
                     KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, UrunModu: 2),
                 new("demirbas-is-emri.mudahale", "▶ Müdahaleye Başla", "demirbas",
                     KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16, UrunModu: 2, Bicim: "bir",
                     Ipucu: "Yanıt süresi bu damgadan hesaplanır"),
                 // MASRAFLI ONARIM ONAYI (752): esigi asan is emri dis
                 //   servise gonderilmeden once onaydan gecer.
                 new("demirbas-is-emri.onaya-gonder", "📤 Onarımı Onaya Gönder", "demirbas",
                     KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 14, UrunModu: 2, Bicim: "bir",
                     Ipucu: "Eşiği aşan onarım onaysız dış servise gönderilemez"),
                 new("demirbas-is-emri.onay-zinciri", "🧾 Onay Zinciri", "demirbas",
                     Hedef: "sagtus,palet", KaynakKodu: "demirbas.isemri",
                     Islem: Islem.Gor, KayitGerekir: true, Sira: 18, UrunModu: 2),
                 new("demirbas-is-emri.parca-bekle", "⏸ Parça Bekliyor", "demirbas",
                     KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 17, UrunModu: 2),
                 new("demirbas-is-emri.dis-servis", "🚚 Dış Servise Gönder", "demirbas",
                     KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 18, UrunModu: 2),
                 new("demirbas-is-emri.parca-cikis", "🧾 Parçaları Stoktan Düş", "demirbas",
                     AksiyonYetkisi: "stok", KayitGerekir: true, Sira: 19, UrunModu: 2,
                     Ipucu: "Yalnız kurumun ödediği parçalar düşülür (garanti/sözleşme düşülmez)"),
                 new("demirbas-is-emri.tamamla", "✓ Tamamla", "demirbas",
                     KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "onay",
                     Ipucu: "Zorunlu bakım maddeleri işaretsizse gerekçe ister"),
                 new("demirbas-is-emri.iptal", "✖ İptal", "demirbas", Hedef: "sagtus,palet",
                     KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 21, UrunModu: 2)],

            // SATINALMA (724). Onay/karar/ceza dugmeleri YOK: her biri para
            //   cikaran ya da imza zinciri isleyen bir karardir ve kendi ucunu
            //   ister - o uclar bu turda yazilmadi.
            // ONAY GELEN KUTUSU (738/739). TÜR FARK ETMEZ: satır bir
            //   BASAMAKTIR, kararı da basamağa verilir. Kaydın kendi ekranına
            //   gitmeden karar verilebilmesi kutunun varlık sebebi - aksi
            //   hâlde kullanıcı yine tür tür ekran gezerdi.
            // IZIN (743). TALEP -> ONAY -> IPTAL. "Onayla" dugmesi YOK:
            //   karar onay kutusundan ya da kaydin kendi zincirinden verilir -
            //   izin ekranina ikinci bir onay yolu koymak, ayni karari iki
            //   ayri yerde farkli kurallarla vermek olurdu.
            ["personel-izin-liste"] =
                [.. Crud("personel-izin", "ik", "ik.izin"),
                 new("personel-izin.gonder", "📤 Onaya Gönder", "ik",
                     KaynakKodu: "ik.izin", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Zincir: âmir → İK → (10 günü aşarsa) üst yönetim"),
                 new("personel-izin.bakiye", "📊 Bakiye", "ik",
                     KaynakKodu: "ik.izin", Islem: Islem.Gor,
                     KayitGerekir: true, Sira: 16),
                 new("personel-izin.zincir", "🧾 Onay Zinciri", "ik",
                     Hedef: "sagtus,palet", KaynakKodu: "ik.izin", Islem: Islem.Gor,
                     KayitGerekir: true, Sira: 17),
                 new("personel-izin.iptal", "✖ İzni İptal Et", "ik",
                     Hedef: "sagtus,palet", KaynakKodu: "ik.izin",
                     Islem: Islem.Degistir, KayitGerekir: true, Sira: 20,
                     Bicim: "tehlike",
                     Ipucu: "Onaylı izin de iptal edilir - gerekçe zorunlu")],

            // AVANS (753). ODEME ONAYDAN SONRA ve AYRI DUGMEDIR: onay
            //   parayi cikarmaz, cikarma iznini verir.
            ["personel-avans-liste"] =
                [.. Crud("personel-avans", "ik", "ik.avans"),
                 new("personel-avans.gonder", "📤 Onaya Gönder", "ik",
                     KaynakKodu: "ik.avans", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Zincir: âmir → İK → (tutar eşiğine göre) mali işler / üst yönetim"),
                 new("personel-avans.ode", "💸 Öde", "ik",
                     AksiyonYetkisi: "ik.avans_ode", KayitGerekir: true, Sira: 16,
                     Ipucu: "Kasa/banka işlemi üretir ve kesinti planını açar"),
                 new("personel-avans.kesinti", "✂ Kesinti İşle", "ik",
                     KaynakKodu: "ik.avans", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 17,
                     Ipucu: "Bekleyen en eski taksit kesildi olarak işaretlenir"),
                 new("personel-avans.zincir", "🧾 Onay Zinciri", "ik",
                     Hedef: "sagtus,palet", KaynakKodu: "ik.avans", Islem: Islem.Gor,
                     KayitGerekir: true, Sira: 18),
                 new("personel-avans.iptal", "✖ Avansı İptal Et", "ik",
                     Hedef: "sagtus,palet", KaynakKodu: "ik.avans",
                     Islem: Islem.Degistir, KayitGerekir: true, Sira: 20,
                     Bicim: "tehlike",
                     Ipucu: "Ödenmiş avans iptal edilemez - geri alım ayrı tahsilattır")],

            // MASRAF BEYANI (764). Odeme aksiyonu YOK: zincir onayla biter,
            //   muhasebe disarida oder (kullanici karari).
            ["personel-masraf-liste"] =
                [.. Crud("personel-masraf", "ik", "ik.masraf"),
                 new("personel-masraf.gonder", "📤 Onaya Gönder", "ik",
                     KaynakKodu: "ik.masraf", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Zincir: âmir → (tutar eşiğine göre) mali işler / üst yönetim"),
                 new("personel-masraf.zincir", "🧾 Onay Zinciri", "ik",
                     Hedef: "sagtus,palet", KaynakKodu: "ik.masraf", Islem: Islem.Gor,
                     KayitGerekir: true, Sira: 18),
                 new("personel-masraf.iptal", "✖ Beyanı İptal Et", "ik",
                     Hedef: "sagtus,palet", KaynakKodu: "ik.masraf",
                     Islem: Islem.Degistir, KayitGerekir: true, Sira: 20,
                     Bicim: "tehlike",
                     Ipucu: "Beyan silinmez - \"bu harcama talep edilmiş miydi\" sorusu sonradan da sorulur")],

            // BELGE TALEBI (765). Asil is onay degil HAZIRLAMAK: aksiyonlar
            //   da o sirayi izler (hazirla -> teslim).
            ["personel-belge-talep-liste"] =
                [.. Crud("personel-belge-talep", "ik", "ik.belge_talep"),
                 // YAZI EN ÜSTTE (768): hazırlamadan ÖNCE bakılır. Sıra
                 //   işin sırasıdır - önce metni gör, sonra hazırlandı de.
                 new("personel-belge-talep.yazi", "📄 Yazıyı Göster", "ik",
                     KaynakKodu: "ik.belge_talep", Islem: Islem.Gor,
                     KayitGerekir: true, Sira: 14,
                     Ipucu: "Şablondan üretilen metin; yazdırılır ve düzeltilebilir"),
                 new("personel-belge-talep.hazirla", "🖨 Hazırlandı", "ik",
                     KaynakKodu: "ik.belge_talep", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Yalnız onaylanmış (hazırlanacak) talep hazırlanabilir"),
                 new("personel-belge-talep.teslim", "📬 Teslim Edildi", "ik",
                     KaynakKodu: "ik.belge_talep", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16,
                     Ipucu: "Personelin beklediği şey onay değil belgenin kendisi"),
                 new("personel-belge-talep.zincir", "🧾 Onay Zinciri", "ik",
                     Hedef: "sagtus,palet", KaynakKodu: "ik.belge_talep",
                     Islem: Islem.Gor, KayitGerekir: true, Sira: 18,
                     Ipucu: "Otomatik onaylanan talepte zincir kurulmaz"),
                 new("personel-belge-talep.reddet", "✖ Reddet", "ik",
                     Hedef: "sagtus,palet", AksiyonYetkisi: "ik.belge_talep_onay",
                     KayitGerekir: true, Sira: 20, Bicim: "tehlike",
                     Ipucu: "Otomatik onaylanmış talep de gerekçeyle reddedilebilir")],

            // RESMI TATIL (749). "Yili Uret" yalniz MILLI tatilleri yazar;
            //   dini bayramlar elle girilir - hicri takvim algoritmayla
            //   uretilmiyor (bir gun kayan hesap izni yanlis sayar).
            ["resmi-tatil-liste"] =
                [.. Crud("resmi-tatil", "ik", "ik.tatil"),
                 new("resmi-tatil.yil-uret", "📅 Yılın Millî Tatillerini Üret", "ik",
                     KaynakKodu: "ik.tatil", Islem: Islem.Ekle, Sira: 15, Bicim: "bir",
                     Ipucu: "Dinî bayramlar dâhil değildir - onları elle girin")],

            // BAKIYE LISTESI salt okunur: hak karti ayri ekrandir.
            ["izin-bakiye-liste"] =
                [new("izin-bakiye.izin-ac", "＋ İzin Talebi Aç", "ik",
                     KaynakKodu: "ik.izin", Islem: Islem.Ekle,
                     KayitGerekir: true, Sira: 10, Bicim: "bir"),
                 new("izin-bakiye.hak-tanimla", "✎ Hakediş Tanımla", "ik",
                     KaynakKodu: "ik.izin_hak", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 11)],

            ["personel-izin-hak-liste"] =
                [.. Crud("personel-izin-hak", "ik", "ik.izin_hak")],

            // AKIS TANIMI (742): kurumun imza duzeni. "Akisi Dene" KURU
            //   CALISTIRMADIR - kayit uretmez, yalnizca verilen olcu ve
            //   bayraklarla hangi basamaklarin cikacagini gosterir. Eşiği
            //   degistiren kisi sonucunu gercek bir talep acmadan gormeli.
            ["onay-akis-liste"] =
                [.. Crud("onay-akis", "onay", "kullanici"),
                 new("onay-akis.dene", "🧪 Akışı Dene", "onay",
                     KaynakKodu: "kullanici", Islem: Islem.Gor,
                     KayitGerekir: true, Sira: 15,
                     Ipucu: "Kayıt üretmez - hangi basamakların çıkacağını gösterir"),
                 new("onay-akis.yuruyenler", "📋 Yürüyen Onaylar", "onay",
                     Hedef: "sagtus,palet", KaynakKodu: "kullanici", Islem: Islem.Gor,
                     KayitGerekir: true, Sira: 16)],

            // VEKALET EKRANI (741): imza yetkisinin gecici devri. CRUD
            //   yeter - vekaletin akisi yok, tanimlanir ya da kaldirilir.
            ["onay-vekalet-liste"] =
                [.. Crud("onay-vekalet", "onay", "kullanici")],

            ["onay-kutusu-liste"] =
                [new("onay-kutusu.onayla", "✓ Onayla", "onay",
                     KayitGerekir: true, Sira: 10, Bicim: "onay",
                     Ipucu: "Karar bekleyen en küçük basamağa yazılır"),
                 new("onay-kutusu.bilgi", "↩ Bilgi İste", "onay",
                     KayitGerekir: true, Sira: 11,
                     Ipucu: "Zinciri durdurur ama bitirmez - basamak beklemeye devam eder"),
                 new("onay-kutusu.reddet", "✖ Reddet", "onay",
                     KayitGerekir: true, Sira: 12, Bicim: "tehlike"),
                 new("onay-kutusu.sozlu", "🗣 Sözlü Onay", "onay",
                     Hedef: "sagtus,palet", KayitGerekir: true, Sira: 13,
                     Ipucu: "Yazılı tamamlanma süresi izlenir"),
                 new("onay-kutusu.kayda-git", "🔎 Kayda Git", "onay",
                     Hedef: "sagtus,palet", KayitGerekir: true, Sira: 20),
                 new("onay-kutusu.zincir", "🧾 Onay Zinciri", "onay",
                     Hedef: "sagtus,palet", KayitGerekir: true, Sira: 21)],

            ["satinalma-talep-liste"] =
                [.. Crud("satinalma-talep", "satinalma", "satinalma.talep"),
                 // ZİNCİRİ SİSTEM KURAR: "kime göndereyim" sorulmaz.
                 new("satinalma-talep.gonder", "📤 Onaya Gönder", "satinalma",
                     KaynakKodu: "satinalma.talep", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Onay basamakları tutar ve bütçe durumundan türer"),
                 new("satinalma-talep.karar-onayla", "✓ Onayla ve İlerlet", "satinalma",
                     AksiyonYetkisi: "satinalma.onay_birim", KayitGerekir: true,
                     Sira: 16, Bicim: "onay",
                     Ipucu: "Karar hep bekleyen en küçük basamağa yazılır - basamak atlanamaz"),
                 new("satinalma-talep.karar-bilgi", "↩ Bilgi İste", "satinalma",
                     AksiyonYetkisi: "satinalma.onay_birim", KayitGerekir: true, Sira: 17),
                 new("satinalma-talep.karar-sozlu", "🗣 Sözlü Onay", "satinalma",
                     Hedef: "sagtus,palet", AksiyonYetkisi: "satinalma.onay_birim",
                     KayitGerekir: true, Sira: 18,
                     Ipucu: "Yazılı tamamlanma süresi izlenir"),
                 new("satinalma-talep.karar-reddet", "✖ Reddet", "satinalma",
                     AksiyonYetkisi: "satinalma.onay_birim", KayitGerekir: true,
                     Sira: 19, Bicim: "tehlike"),
                 new("satinalma-talep.birlestir", "🔗 Talepleri Birleştir", "satinalma",
                     Hedef: "araccubugu,palet", KaynakKodu: "satinalma.talep",
                     Islem: Islem.Degistir, Sira: 20,
                     Ipucu: "İlk seçilen HEDEF olur; kaynaklar silinmez, birleştirildi olarak kapanır"),
                 new("satinalma-talep.siparise", "📦 Siparişe Dönüştür", "satinalma",
                     AksiyonYetkisi: "satinalma.siparis", KayitGerekir: true, Sira: 21,
                     Ipucu: "Alış siparişi (belge tür 9) oluşturur")],

            ["satinalma-teklif-liste"] =
                [.. Crud("satinalma-teklif", "satinalma", "satinalma.teklif"),
                 new("satinalma-teklif.davet", "📧 Daveti Gönder", "satinalma",
                     KaynakKodu: "satinalma.teklif", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15, Bicim: "bir",
                     Ipucu: "Değerlendirme ağırlıkları KİLİTLENİR"),
                 new("satinalma-teklif.ac", "📂 Teklifleri Aç", "satinalma",
                     KaynakKodu: "satinalma.teklif", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16,
                     Ipucu: "Son tarihten önce açmak gerekçe ister; puanlar burada hesaplanır"),
                 new("satinalma-teklif.karar", "✓ Kararı Ver", "satinalma",
                     AksiyonYetkisi: "satinalma.karar", KayitGerekir: true,
                     Sira: 17, Bicim: "onay",
                     Ipucu: "En düşük teklif alınmıyorsa gerekçe zorunlu")],

            ["satinalma-butce-liste"] = Crud("satinalma-butce", "satinalma", "satinalma.butce"),
            // SIPARIS / FATURA KONTROL / TEDARIKCI: takip listeleri. Siparis
            //   `belge` (tur 9) kartindan, tedarikci cari kartindan duzenlenir;
            //   burada ikinci bir duzenleme yolu acilmiyor.
            ["satinalma-siparis-liste"] =
                [new("satinalma-siparis.gecikme", "⏱ Gecikme Bildir", "satinalma",
                     KaynakKodu: "satinalma.siparis", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 10,
                     Ipucu: "Gecikme söz verilen tarihten sayılır; tedarikçi performansına işlenir"),
                 // CEZA KENDİLİĞİNDEN TAHSİL OLMAZ: işlemek ayrı karardır.
                 new("satinalma-siparis.ceza", "⚖ Ceza İşlet", "satinalma",
                     AksiyonYetkisi: "satinalma.ceza", KayitGerekir: true,
                     Sira: 20, Bicim: "tehlike",
                     Ipucu: "Hesap sözleşmeden (binde/gün, üst sınır %)"),
                 Yazdir()],

            ["satinalma-fatura-liste"] =
                [new("satinalma-fatura.eslestir", "🧮 Yeniden Eşleştir", "satinalma",
                     KaynakKodu: "satinalma.fatura", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 10,
                     Ipucu: "Sipariş - teslim - fatura; karşılaştırma tabanı TESLİMDİR"),
                 // ÖDEME KARARI AYRI YETKİ: farkı görmekle ödemeyi serbest
                 //   bırakmak aynı sorumluluk değil.
                 new("satinalma-fatura.odeme-onay", "✓ Ödemeye Onay Ver", "satinalma",
                     AksiyonYetkisi: "satinalma.odeme_onay", KayitGerekir: true,
                     Sira: 20, Bicim: "onay"),
                 new("satinalma-fatura.odeme-durdur", "⛔ Ödemeyi Durdur", "satinalma",
                     AksiyonYetkisi: "satinalma.odeme_onay", KayitGerekir: true,
                     Sira: 21, Bicim: "tehlike"),
                 new("satinalma-fatura.odeme-itiraz", "📨 Tedarikçiye İtiraz", "satinalma",
                     AksiyonYetkisi: "satinalma.odeme_onay", KayitGerekir: true, Sira: 22),
                 Yazdir()],

            // MAL KABUL (733). Muayene tutanağı: satırlar irsaliyeden gelir,
            //   karar komisyonundur.
            ["satinalma-kabul-liste"] =
                [.. Crud("satinalma-kabul", "satinalma", "satinalma.kabul"),
                 new("satinalma-kabul.tumunu-kabul", "✓ Tüm Kalemleri Kabul Et", "satinalma",
                     KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 15,
                     Ipucu: "İstisna yoksa otuz satırı tek tek işaretlemek zaman kaybı"),
                 new("satinalma-kabul.karar-kabul", "✓ Kabul", "satinalma",
                     KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 16, Bicim: "onay",
                     Ipucu: "Siparişi kapatır; muayenesi bitmemiş tutanak karara bağlanmaz"),
                 new("satinalma-kabul.karar-kismi", "↩ Kısmi Kabul", "satinalma",
                     KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 17,
                     Ipucu: "Uygunsuzluk metni zorunlu"),
                 // RET SİPARİŞİ KAPATMAZ: mal geri gidiyor, taahhüt sürüyor.
                 new("satinalma-kabul.karar-ret", "✖ Ret", "satinalma",
                     KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 18, Bicim: "tehlike"),
                 // KAREKOD OKUMA (734): kutular tek tek okutulur, her kod
                 //   kendi sonucuyla döner - biri okunamadı diye öncekiler
                 //   silinmez.
                 new("satinalma-kabul.karekod", "🔦 Karekod Oku", "satinalma",
                     KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                     KayitGerekir: true, Sira: 12, Bicim: "bir",
                     Ipucu: "Aynı kutu iki kez okutulamaz; beklenmeyen kutu kayda geçer"),
                 new("satinalma-kabul.karekod-ozet", "📋 Karekod Özeti", "satinalma",
                     Hedef: "sagtus,palet", KaynakKodu: "satinalma.kabul",
                     Islem: Islem.Gor, KayitGerekir: true, Sira: 13),
                 // İTS BİLDİRİMİ (736). Kuyruğa alma muayene bittikten SONRA:
                 //   hangi kutunun kabul edildiği kararla belli olur.
                 new("satinalma-kabul.its-gonder", "📡 İTS Bildir", "satinalma",
                     AksiyonYetkisi: "uts.bildir", KayitGerekir: true, Sira: 25,
                     Ipucu: "Reddedilen kalemin kutusu bildirime girmez"),
                 new("satinalma-kabul.its-durum", "📋 İTS Durumu", "satinalma",
                     Hedef: "sagtus,palet", KaynakKodu: "satinalma.kabul",
                     Islem: Islem.Gor, KayitGerekir: true, Sira: 26),
                 new("satinalma-kabul.its-iptal", "✖ İTS Bildirimini İptal Et", "satinalma",
                     Hedef: "sagtus,palet", AksiyonYetkisi: "uts.iptal",
                     KayitGerekir: true, Sira: 27, Bicim: "tehlike",
                     Ipucu: "Gönderilmiş bildirim iptal edilemez (iade/deaktivasyon gerekir)"),
                 new("satinalma-kabul.siparise-git", "📦 Siparişe Git", "satinalma",
                     Hedef: "sagtus,palet", KaynakKodu: "satinalma.siparis",
                     Islem: Islem.Gor, KayitGerekir: true, Sira: 19)],

            ["satinalma-tedarikci-liste"] = [Yazdir()],

            // ÜTS bildirim gecmisi (223). Iptal/yeniden gonderme RESMI islem:
            //   ayri aksiyon yetkileri (uts.iptal / uts.bildir).
            ["uts-bildirim-liste"] = new AksiyonTanimi[]
            {
                // Elle bildirim formlari: TEK "Bildirim" dugmesi, asagi acilir
                //   menu (kullanici) - alt secenekler listeTanimlari'nda.
                new("uts.bildirim-menu", "＋ Bildirim", "stok",
                    Hedef: "araccubugu", AksiyonYetkisi: "uts.bildir", Sira: 10),
                new("uts.detay", "ÜTS Detay Sorgula", "stok",
                    Hedef: "sagtus,palet", KaynakKodu: "uts", Islem: Islem.Gor,
                    KayitGerekir: true, Sira: 20),
                // Iki asamali akis: "Verme" gridi bekleyenlerle doldurur,
                //   secilenler buradan UTS'ye cikar (bekleyen + hatali).
                new("uts.yeniden-gonder", "📤 Gönder", "stok",
                    Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "uts.bildir",
                    KayitGerekir: true, Sira: 30),
                new("uts.iptal", "✖ ÜTS'de İptal Et", "stok",
                    Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "uts.iptal",
                    KayitGerekir: true, Sira: 40),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // ÜTS askidaki/gelen urunler (223): senkron + alma bildirimi.
            ["uts-envanter-liste"] = new AksiyonTanimi[]
            {
                new("uts.senkron", "⟳ Askıdakileri Getir", "stok",
                    Hedef: "araccubugu,palet", AksiyonYetkisi: "uts.bildir", Sira: 10),
                new("uts.al", "📥 Alma Bildirimi Yap", "stok",
                    Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "uts.bildir",
                    KayitGerekir: true, Sira: 20),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // BASVURU (246, kullanici): satis siparisinin AYNISI - ek olarak
            //   tahsilat acilabilir (hasta odemesi basvuru ekranindan alinir).
            ["basvuru-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni",     "＋ Yeni Başvuru", "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",       "Aç",              "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("belge.sil",      "🗑 Sil",          "belge", Kisayol: "Del",
                    KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
                new("belge.donustur", "⇢ Belge Kes",     "belge",
                    AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
                // Tahsilat: hasta odemesi (nakit/banka/POS) basvurudan alinir.
                new("kasa.tahsilat.yeni", "＋ Tahsilat", "kasa",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 35),
                new("belge.iptal",    "İptal Et",        "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
                new("belge.fis-gor",  "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
                new("belge.hedef-ac", "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
                new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["siparis-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni",     "＋ Yeni Sipariş", "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",       "Aç",              "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                // Fatura listesindeki desenin AYNISI: "Aç"in saginda silme.
                //   Izi olmayan (kesinlesmemis) belge silinir; digerinde "İptal Et".
                new("belge.sil",      "🗑 Sil",          "belge", Kisayol: "Del",
                    KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
                new("belge.donustur", "⇢ Belge Kes",     "belge",
                    AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
                new("belge.iptal",    "İptal Et",        "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
                // MUHASEBE FISI (190) ve DONUSUM ZINCIRI (F8): belgeden tek
                //   tikla fise ve zincirin iki ucuna gidilir.
                new("belge.fis-gor",   "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
                new("belge.kaynak-ac", "Kaynak Belgeyi Aç",  "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
                new("belge.hedef-ac",  "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 62),
                new("genel.yazdir",   "🖨️ Yazdır",    "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Irsaliye listesi (Ekranlar/satis_irsaliye_listesi.html aksiyonlari).
            //   Ucu olan ucu calisir: ac, donustur, yeni. Digerleri yetkiye bagli
            //   gorunur ama tiklaninca "henuz baglanmadi" der.
            ["irsaliye-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni",     "＋ Yeni İrsaliye", "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",       "İrsaliyeyi Aç",    "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("belge.sil",      "🗑 Sil",           "belge", Kisayol: "Del",
                    KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
                new("belge.donustur", "🧾 Faturaya Dönüştür", "belge",
                    AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
                // e-BELGE MENUSU - fatura listesindekiyle AYNI adimlar ve sira
                //   (kullanici). Tek fark kutu basligi: irsaliyede "E-İrsaliye".
                //   Ayrac satirlari combo'da secilemez cizgidir.
                new("ebelge.hazirla",  "Hazırla", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 41),
                new("ebelge.onizle",   "Ön İzle", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 42),
                new("ebelge.gonder",   "Gönder", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 43),
                new("ebelge.ayrac1", "─", "ebelge", Hedef: "sagtus", Sira: 44),
                new("ebelge.seri",     "Seri Değiştir", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 45),
                new("ebelge.sifirla",  "Hazırı Geri Al", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 46),
                new("ebelge.ayrac2", "─", "ebelge", Hedef: "sagtus", Sira: 48),
                new("ebelge.pdf",      "PDF Kaydet", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 48),
                new("ebelge.html",     "HTML Kaydet", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 49),
                new("ebelge.xml",      "XML Kaydet", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 50),
                new("ebelge.ayrac3", "─", "ebelge", Hedef: "sagtus", Sira: 52),
                new("ebelge.durum", "Durum Sorgula", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 53),
                new("ebelge.mesajlar", "Mesaj Geçmişini Göster", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 54),
                new("belge.iptal",    "✖ İrsaliyeyi İptal Et", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 50),
                // MUHASEBE FISI (190) ve DONUSUM ZINCIRI (F8): belgeden tek
                //   tikla fise ve zincirin iki ucuna gidilir.
                new("belge.fis-gor",   "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
                new("belge.kaynak-ac", "Kaynak Belgeyi Aç",  "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
                new("belge.hedef-ac",  "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 62),
                new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["belge-kart"] = new AksiyonTanimi[]
            {
                new("belge.kesinlestir", "Kesinlestir", "belge",
                    AksiyonYetkisi: "belge.kesinlestir", KayitGerekir: true, Sira: 10),
                new("ebelge.gonder", "e-Fatura Gonder", "ebelge",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 20),
                new("belge.iptal", "Belgeyi Iptal Et", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 30),
            },

            ["cari-kart"] = new AksiyonTanimi[]
            {
                new("cari.sil", "🗑 Sil", "kart", Hedef: "araccubugu,palet",
                    KaynakKodu: "cari", Islem: Islem.Sil, KayitGerekir: true, Sira: 20),
            },

            ["stok-kart"] = new AksiyonTanimi[]
            {
                new("stok.sil", "🗑 Sil", "stok", Hedef: "araccubugu,palet",
                    KaynakKodu: "stok", Islem: Islem.Sil, KayitGerekir: true, Sira: 20),
            },

            // ---------------------------------------------------------- kasa ----
            // "Yeni" tek dugme degil, tur GRUBU basina bir giris: tahsilat ile
            //   odeme ayni ekrandir ama kullanicinin kafasinda ayri islemdir.
            ["kasa-liste"] = new AksiyonTanimi[]
            {
                new("kasa.tahsilat.yeni", "＋ Tahsilat", "kasa", Kisayol: "Ctrl+N",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 10),
                new("kasa.odeme.yeni",    "－ Ödeme",    "kasa",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 20),
                new("kasa.virman.yeni",   "⇄ Virman",    "kasa",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 22),
                new("kasa.doviz.yeni",    "💱 Döviz",    "kasa",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 24),
                new("kasa.plan.yeni",     "📅 Plan",     "kasa", Hedef: "araccubugu,palet",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 26),
                new("kasa.ac",            "Aç",          "kasa", Kisayol: "Enter",
                    KaynakKodu: "kasa_islem", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
                new("kasa.kesinlestir",   "Kesinleştir", "kasa", Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "kasa.kesinlestir", KayitGerekir: true, Sira: 40),
                new("kasa.iptal",         "İptal Et",    "kasa", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "kasa.iptal", KayitGerekir: true, Sira: 50),
                new("kasa.sil",           "🗑 Sil",         "kasa", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 60),
                new("kasa.fis-gor",       "Muhasebe Fişi", "muhasebe", Hedef: "sagtus,palet",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 70),
                new("genel.yazdir",       "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["kasa-kart"] = new AksiyonTanimi[]
            {
                new("kasa.kesinlestir", "Kesinleştir", "kasa",
                    AksiyonYetkisi: "kasa.kesinlestir", KayitGerekir: true, Sira: 10),
                new("kasa.gerceklestir", "✔ Gerçekleştir", "kasa",
                    AksiyonYetkisi: "kasa.gerceklestir", KayitGerekir: true, Sira: 15),
                new("kasa.fis-gor",     "Muhasebe Fişi", "muhasebe",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("kasa.iptal",       "İptal Et",    "kasa", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "kasa.iptal", KayitGerekir: true, Sira: 30),
                new("kasa.sil",         "🗑 Sil",         "kasa", Hedef: "sagtus,palet",
                    KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
            },

            // Acik planlar: buradan "Gerceklestir" ile tahsilat/odeme uretilir.
            //   Plan kaydin KENDISI degismez (K10) - yeni bir islem acilir.
            ["plan-liste"] = new AksiyonTanimi[]
            {
                new("kasa.plan.yeni",    "📅 Yeni Plan", "kasa", Kisayol: "Ctrl+N",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 10),
                new("kasa.ac",           "Aç",           "kasa", Kisayol: "Enter",
                    KaynakKodu: "kasa_islem", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("kasa.gerceklestir", "✔ Gerçekleştir", "kasa",
                    AksiyonYetkisi: "kasa.gerceklestir", KayitGerekir: true, Sira: 30),
                new("kasa.sil",          "🗑 Sil",          "kasa", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
                new("genel.yazdir",      "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["fis-liste"] = new AksiyonTanimi[]
            {
                new("fis.ac",         "Aç",           "muhasebe", Kisayol: "Enter",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 10),
                new("fis.ters-kayit", "Ters Kayıt",   "muhasebe", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "fis.ters-kayit", KayitGerekir: true, Sira: 20),
                new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },
        };

    public static IReadOnlyList<AksiyonTanimi>? Ekran(string ad)
        => Ekranlar.TryGetValue(ad, out var liste) ? liste : null;

    public static IEnumerable<string> EkranAdlari => Ekranlar.Keys;

    /// <summary>Aksiyon kullanicinin yetkisine giriyor mu (§7: yetkisiz aksiyon HIC donmez).</summary>
    public static bool Yetkili(AksiyonTanimi aksiyon, YetkiSeti yetkiler)
    {
        if (aksiyon.KaynakKodu is { } kaynak) return yetkiler.Var(kaynak, aksiyon.Islem);
        if (aksiyon.AksiyonYetkisi is { } kod) return yetkiler.AksiyonVar(kod);
        return true;
    }

    /// <summary>
    /// STANDART KART DORTLUSU: Yeni · Düzenle · Sil · Yazdır.
    ///
    /// Bu dortlu 28 ekranda tek tek yazilmisti (26 "yeni", 24 "sil", 20 "yazdir"
    /// girdisi). Kisayol ya da hedef yuzeyi birinde degistirilince otekiler
    /// geride kaliyordu. Ayni ilke katalogun baska yerlerinde zaten uygulanmis
    /// (KartKatalogu.NumaraKarti, KaynakKatalogu.NumaraKaynagi); aksiyonlara
    /// gecmemisti.
    ///
    /// Ekranin kendine ozgu aksiyonlari dizinin arkasina eklenir:
    ///   [.. Crud("proje", "proje", "proje"), new("proje.ekstre", ...)]
    /// </summary>
    /// <param name="onEk">Aksiyon kodu oneki ("cari" -> "cari.yeni").</param>
    /// <param name="grup">Aksiyonun gorsel grubu (arac cubugunda obekleme).</param>
    /// <param name="kaynakKodu">Yetki kaynagi ("cari", "hesap"...).</param>
    /// <param name="ekleAdi">Ekleme dugmesinin adi - kart ekranlarinda "＋ Ekle".</param>
    /// <param name="silHedef">Silmenin gorunecegi yuzeyler; null = hepsi.</param>
    /// <param name="yazdir">Yazdir/CSV dugmesi eklensin mi.</param>
    /// <param name="silSira">Silme sirasi - araya aksiyon giren ekranlarda kayar.</param>
    private static AksiyonTanimi[] Crud(string onEk, string grup, string kaynakKodu,
        string ekleAdi = "＋ Yeni", string? silHedef = "sagtus,palet",
        bool yazdir = true, int silSira = 30, string silAdi = "🗑 Sil",
        string? silIpucu = null)
    {
        AksiyonTanimi[] dortlu =
        [
            new($"{onEk}.yeni", ekleAdi, grup, Kisayol: "Ctrl+N",
                KaynakKodu: kaynakKodu, Islem: Islem.Ekle, Sira: 10),
            new($"{onEk}.duzenle", "✎ Düzenle", grup, Kisayol: "Enter",
                KaynakKodu: kaynakKodu, Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            silHedef is null
                ? new($"{onEk}.sil", silAdi, grup, Kisayol: "Del",
                      KaynakKodu: kaynakKodu, Islem: Islem.Sil, KayitGerekir: true, Sira: silSira,
                      Ipucu: silIpucu)
                : new($"{onEk}.sil", silAdi, grup, Hedef: silHedef, Kisayol: "Del",
                      KaynakKodu: kaynakKodu, Islem: Islem.Sil, KayitGerekir: true, Sira: silSira,
                      Ipucu: silIpucu),
        ];
        return yazdir ? [.. dortlu, Yazdir()] : dortlu;
    }

    /// <summary>Yazdir / CSV kaydet - salt gorunum ekranlarinda tek basina da kullanilir.</summary>
    /// <summary>
    /// Ekstre satirindan onu URETEN belgeye gider (kullanici: "başvurusuna
    /// gidebileyim"). Sira 10 - arac cubugunda Yazdır'in (90) SOLUNDA.
    /// </summary>
    private static AksiyonTanimi BasvuruAc()
        => new("basvuru.ac", "📝 Başvuru Aç", "belge", Hedef: "araccubugu,sagtus,palet",
               KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 10);

    private static AksiyonTanimi Yazdir()
        => new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
               AksiyonYetkisi: "veri.disa-aktar", Sira: 90);

}
