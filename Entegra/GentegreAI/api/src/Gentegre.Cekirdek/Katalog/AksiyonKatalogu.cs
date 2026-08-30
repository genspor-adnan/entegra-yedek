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
    /// <summary>Hangi yuzeyde gorunur: araccubugu | sagtus | palet (virgullu).</summary>
    string Hedef = "araccubugu,sagtus,palet",
    string? Kisayol = null,
    /// <summary>Kaynak yetkisi (or. "cari") + islem. Null ise AksiyonYetkisi bakilir.</summary>
    string? KaynakKodu = null,
    Islem Islem = Islem.Gor,
    /// <summary>Aksiyon yetkisi kodu (yetki tablosunda tur = 1).</summary>
    string? AksiyonYetkisi = null,
    /// <summary>Kayit secilmeden calismaz (sag tus / liste secimi).</summary>
    bool KayitGerekir = false,
    int Sira = 0);

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
                .. Crud("fiyat-listesi", "fiyat", "fiyat_listesi"),
                new("fiyat-listesi.uret", "⟳ Listeyi Üret", "fiyat",
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
                new("radyoloji.cekildi",  "✔ Çekildi İşaretle", "radyoloji",
                    KaynakKodu: "radyoloji", Islem: Islem.Degistir,
                    KayitGerekir: true, Sira: 30),
                new("radyoloji.rapor",    "✎ Rapor Yaz", "radyoloji",
                    AksiyonYetkisi: "rad.rapor_yaz", KayitGerekir: true, Sira: 40),
                new("radyoloji.iptal",    "✖ İstemi İptal Et", "radyoloji",
                    AksiyonYetkisi: "rad.istem_iptal", KayitGerekir: true, Sira: 50),
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
                new("belge.donustur", "⇢ Dönüştür",      "belge",
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
                new("belge.donustur", "⇢ Dönüştür",      "belge",
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
        bool yazdir = true, int silSira = 30)
    {
        AksiyonTanimi[] dortlu =
        [
            new($"{onEk}.yeni", ekleAdi, grup, Kisayol: "Ctrl+N",
                KaynakKodu: kaynakKodu, Islem: Islem.Ekle, Sira: 10),
            new($"{onEk}.duzenle", "✎ Düzenle", grup, Kisayol: "Enter",
                KaynakKodu: kaynakKodu, Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            silHedef is null
                ? new($"{onEk}.sil", "🗑 Sil", grup, Kisayol: "Del",
                      KaynakKodu: kaynakKodu, Islem: Islem.Sil, KayitGerekir: true, Sira: silSira)
                : new($"{onEk}.sil", "🗑 Sil", grup, Hedef: silHedef, Kisayol: "Del",
                      KaynakKodu: kaynakKodu, Islem: Islem.Sil, KayitGerekir: true, Sira: silSira),
        ];
        return yazdir ? [.. dortlu, Yazdir()] : dortlu;
    }

    /// <summary>Yazdir / CSV kaydet - salt gorunum ekranlarinda tek basina da kullanilir.</summary>
    private static AksiyonTanimi Yazdir()
        => new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
               AksiyonYetkisi: "veri.disa-aktar", Sira: 90);

}
