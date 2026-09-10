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
            ["rol-liste"] = Crud("rol", "rol", "rol", yazdir: false),
            ["personel-liste"] = Crud("personel", "personel", "personel"),
            ["hasta-liste"] = Crud("hasta", "hasta", "personel"),
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
