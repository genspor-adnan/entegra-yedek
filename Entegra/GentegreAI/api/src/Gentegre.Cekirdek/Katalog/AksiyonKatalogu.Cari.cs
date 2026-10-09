using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Cari, kisi, rol, kullanici, personel, hasta, dis hekim, fiyat listesi, kurum icmali.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleCari(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["cari-liste"] =
        [
            .. Crud("cari", "kart", "cari"),
            // PORTAL ERISIMI (819): kurum portalini KISI kullanir - hesap
            //   burada kurumu TEMSIL EDEN kisiye acilir, kapsam kuruma
            //   baglanir. Paylasimli hesapta kim ne yapti bilinmez.
            new("kullanici.portal", "🔑 Portal Erişimi", "kullanici",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "kullanici.portal", KayitGerekir: true, Sira: 80,
                Ipucu: "Dışarıdan giriş icin PAROLASIZ hesap acar - kisi ilk giriste kendi parolasini koyar"),
            // GIB e-Fatura kaydini entegratore sorar ve karta isler (183).
            new("cari.ebelge-mukellef", "e-Fatura Mükellefiyeti Sorgula", "kart",
                Hedef: "sagtus,palet", KaynakKodu: "cari", Islem: Islem.Degistir,
                KayitGerekir: true, Sira: 45),
        ];

        s["kisi-liste"] = Crud("kisi", "kisi", "cari");
        // Sil ARAC CUBUGUNDA (kullanici: "rollere silme ikonu ekle"); kullanicili rol
        //   sunucuda engellenir (KartKatalogu Rol SilmeEngelleri).
        // ROL SILINMEZ: kullanimdan cikarmak icin kartta `Aktif` kapatilir
        //   (pasif rol yetki de vermez - goc 983). Silme aksiyonu hic
        //   uretilmiyor; sunucu tarafi KartTanimi.SilmeYok ile kapali.
        s["rol-liste"] = Crud("rol", "rol", "rol", yazdir: false, sil: false);

        // KULLANICILAR (Yonetim > Guvenlik) - mockup kullanicilar.html.
        //   CRUD YOK: hesap burada "yeni kayit" gibi acilmaz (personelden
        //   acilir) ve SILINMEZ - islem gunlugu, belge ve log satirlari
        //   kullaniciya bagli; silinen hesap gecmisi sahipsiz birakir.
        //   Pasife alma bunun yerini tutar.
        s["kullanici-liste"] =
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
        ];
        s["personel-liste"] =
            [.. Crud("personel", "personel", "personel"),
             // YENİ TALEP ▾ (kullanıcı: "personel listesinde yeni butonu sağına
             //   Yeni Talep butonu ekle.. seçili personel için"): alt seçenekler
             //   (izin / avans / masraf / belge) ekranda, her biri kendi yetkisiyle.
             new("personel.talep", "📨 Yeni Talep", "personel", Hedef: "araccubugu",
                 KaynakKodu: "personel", Islem: Islem.Gor, KayitGerekir: true, Sira: 11,
                 Ipucu: "Seçili personel için izin, avans, masraf ya da belge talebi")];
        // KADRO HAREKETI (840): pozisyon gecmisi defteri. Silme VAR ama
        //   dar: yanlis girilen hareket duzeltilebilmeli - defterin
        //   kendisi denetim izi degil, `islem_log` o isi yapiyor.
        s["personel-hareket-liste"] =
            Crud("personel-hareket", "personel-hareket", "ik.kadro",
                 ekleAdi: "＋ Hareket", yazdir: true);
        s["hasta-liste"] =
        [
            // SİL ÜST ARAÇ ÇUBUĞUNDA (kullanici: "ekle duzenle saginda Sil"):
            //   Crud varsayilani Sil'i yalniz sag tus/palete koyar.
            .. Crud("hasta", "hasta", "hasta", silHedef: "araccubugu,sagtus,palet"),
            // BAŞVURU EKLE (kullanici: "2. siraya Başvuru Ekle"): secili
            //   hastaya kabul/başvuru acar (varsa kapanmamis basvuru acilir).
            new("hasta.basvuru-ekle", "♿ Başvuru Aç", "belge",
                Hedef: "araccubugu2,sagtus,palet", KaynakKodu: "belge",
                Islem: Islem.Ekle, KayitGerekir: true, Sira: 15, UrunModu: 2,
                Ipucu: "Seçili hastaya başvuru/kabul açar"),
            // FORM MOTORU (740): hastanın formları (onam, değerlendirme, beyan).
            new("form.hasta-formlar", "📋 Formlar", "form", Hedef: "araccubugu2,sagtus,palet", KaynakKodu: "form.istek", Islem: Islem.Gor, KayitGerekir: true, Sira: 60, UrunModu: 2),
            // PORTAL DAVETI (822): hastaya SMS/e-posta ile tek kullanimlik
            //   baglanti gider, hesabini KENDI acar. Hastaya "portalimiz
            //   var, su kodla gir" demek pratikte kimseyi girdirmiyor.
            new("kullanici.portal-davet", "📨 Portal Daveti Gönder", "kullanici",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "kullanici.portal", KayitGerekir: true, Sira: 78,
                Ipucu: "SMS/e-posta ile tek kullanimlik hesap acma baglantisi"),
            // PORTAL ERISIMI (819): hasta kendi sonuc ve randevularini
            //   gorsun diye. Davet gonderemedigin durumda (numara yok)
            //   hesap dogrudan acilir, parola YOKTUR.
            new("kullanici.portal", "🔑 Portal Erişimi", "kullanici",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "kullanici.portal", KayitGerekir: true, Sira: 80,
                Ipucu: "Dışarıdan giriş icin PAROLASIZ hesap acar - kisi ilk giriste kendi parolasini koyar"),
        ];
        // Dis doktor (305): kendi yetkisiyle (1003, eskiden `personel`), kendi kart adiyla.
        s["dis-hekim-liste"] =
        [
            .. Crud("dis-hekim", "dis-hekim", "dis_doktor"),
            // TOPLU ROL (819/822): gocle gelen dis hekimlerin HESABI VAR
            //   ama rolu "Rol Atanmamis" - giris yapsalar hicbir ekran
            //   goremezler. Yetkili bir IC rolu tasiyan hesap atlanir.
            new("kullanici.portal-toplu", "👥 Tümüne Portal Rolü", "kullanici",
                Hedef: "araccubugu2,palet", AksiyonYetkisi: "kullanici.portal",
                Sira: 85,
                Ipucu: "Hesabi olan dis hekimlere Dis Doktor (portal) rolunu atar"),
            // PORTAL ERISIMI (819): dis hekim kendi istem ve sonuclarini
            //   gorsun diye.
            new("kullanici.portal", "🔑 Portal Erişimi", "kullanici",
                Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "kullanici.portal", KayitGerekir: true, Sira: 80,
                Ipucu: "Dışarıdan giriş icin PAROLASIZ hesap acar - kisi ilk giriste kendi parolasini koyar"),
        ];

        // AKSIYON KOMBOSU (sagtus hedefi) yalniz KOPYALA icerir (kullanici):
        //   Yeni/Duzenle/Sil zaten arac cubugunda dugme; komboda tekrar
        //   edilmeleri listeyi doldurup gercek aksiyonu goze batmaz yapiyordu.
        s["stok-liste"] = new AksiyonTanimi[]
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
        };

        // Banka tanimlari (db/109).
        s["banka-liste"] = Crud("banka", "banka", "hesap", silHedef: null);

        // Gorev / hatirlatma / takvim (db/108): stok-liste ile ayni desen.
        //   "Tamamla" ayri bir aksiyon DEGIL - durum kartta degisir; listede
        //   tek tikla tamamlamak, ilerleme/tamamlanma alanlarini atlardi.
        s["gorev-liste"] = Crud("gorev", "gorev", "gorev");

        // Projeler - gorev/firsat listeleriyle AYNI desen (Yeni / Düzenle /
        //   Sil / Yazdır); eskiden aksiyon seridi hic yoktu, kart yalniz
        //   cift tikla aciliyordu.
        s["proje-liste"] = Crud("proje", "proje", "proje");

        // FIYAT LISTESI (201/202). "Listeyi Üret" ayri yetki ister:
        //   binlerce satir yazar ve taban degisince fiyatlari toptan
        //   degistirir - gorme/duzeltme yetkisi tek basina yetmemeli.
        s["fiyat-listesi-liste"] =
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
        ];

        // Satir listesi salt gorunum: satirlar listeden degil KARTTAN
        //   duzenlenir (kural ezmesi baslikla birlikte anlamli).
        s["fiyat-listesi-satir-liste"] = [Yazdir()];

        // CRM satis firsati (121). Kazanildi/Kaybedildi ayri AKSIYON degil:
        //   asama alanindan secilir - iki yerden degistirilen bir durum
        //   birbirini tutmayan iki kayit uretir.
        s["firsat-liste"] = Crud("firsat", "firsat", "firsat");

        // KURUM ICMALI (289): SGK payinin toplu faturalanmasi.
        s["icmal-liste"] = new AksiyonTanimi[]
        {
            new("icmal.yeni",     "＋ İcmal Oluştur", "kurum",
                KaynakKodu: "kurum", Islem: Islem.Ekle, Sira: 10),
            new("icmal.faturala", "🧾 Faturala", "kurum",
                KaynakKodu: "belge", Islem: Islem.Ekle, KayitGerekir: true, Sira: 20),
            new("icmal.belge",    "↗ Faturayı Aç", "kurum",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
        };
    }
}
