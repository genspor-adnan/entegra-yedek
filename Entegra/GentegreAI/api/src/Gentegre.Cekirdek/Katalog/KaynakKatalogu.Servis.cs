namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TEKNİK SERVİS LİSTELERİ (773) — çağrı · iş emri · ziyaret · emanet ·
/// cihaz parkı · sözleşme.
///
/// Hepsi `v_servis_*` / `v_taraf_cihaz` görünümlerinden okur: kapsam adı,
/// SLA kalan dakikası ve ziyaret sayısı gibi türetilmiş alanlar orada tek
/// yerde hesaplanıyor - listede ikinci kez kurulursa panodaki sayı ile
/// kartın içindeki sayı bir gün ayrışır.
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> ServisKapsamKodlari = new()
    {
        ["1"] = "Ücretli", ["2"] = "Sözleşme",
        ["3"] = "Üretici garantisi", ["4"] = "Kendi garantimiz",
    };

    internal static readonly Dictionary<string, string> ServisCagriDurumu = new()
    {
        ["0"] = "Açık", ["1"] = "Atandı", ["2"] = "Yolda", ["3"] = "Yerinde",
        ["4"] = "Parça bekliyor", ["5"] = "Çözüldü", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> ServisSahiplikKodlari = new()
    {
        ["1"] = "İç iş (demirbaş)", ["2"] = "Dış iş (müşteri)",
    };

    internal static readonly Dictionary<string, string> ZiyaretSonucKodlari = new()
    {
        ["0"] = "Sürüyor", ["1"] = "Çözüldü", ["2"] = "Çözülemedi",
        ["3"] = "Parça bekliyor", ["4"] = "İptal",
    };

    // ------------------------------------------------------------ çağrı ----
    /// <summary>
    /// SLA KALAN DAKİKA listenin asıl kolonu: eksi değer aşımdır. Panoda
    /// "neye bakmam gerekiyor" sorusunu bu cevaplar - durum kolonu "açık"
    /// derken taahhüt çoktan geçmiş olabilir.
    /// </summary>
    private static KaynakTanimi ServisCagri() => new(
        Ad: "servis-cagri",
        YetkiKodu: "servis",
        Kaynak: "public.v_servis_cagri c",
        SubeKolonu: "c.sube_id",
        // AÇIK ÇAĞRILAR ÖNCE, İÇİNDE SLA'YA GÖRE: taahhüdü dolmak üzere olan
        //   çağrı sayfa altında kalmamalı.
        VarsayilanSirala: "case when c.durum < 5 then 0 else 1 end, "
                        + "c.sla_kalan_dk nulls last, c.acilis desc",
        Kolonlar:
        [
            new("id", "c.id", "sayi", "Id", Varsayilan: false),
            new("cagriNo", "c.cagri_no", "metin", "Çağrı No", Genislik: 120),
            new("tarafAdi", "c.taraf_adi", "metin", "Müşteri", Genislik: 200),
            new("bolge", "c.bolge", "metin", "Bölge", Genislik: 120),
            new("cihaz", "c.cihaz", "metin", "Cihaz", Genislik: 190),
            new("sikayet", "c.sikayet", "metin", "Şikâyet", Genislik: 280),
            new("kapsamAdi", "c.kapsam_adi", "metin", "Kapsam", Hizalama: "orta",
                Genislik: 140, Bicim: "rozet", Filtrelenebilir: false),
            new("kapsamTur", "c.kapsam_tur", "kod", "Kapsam Kodu",
                Varsayilan: false, Kodlar: ServisKapsamKodlari),
            // DURUM METİN OLARAK ÇİZİLİR: ekranın ortak kuralı `durum` adlı
            //   0/1 kolonunu "Aktif/Pasif" rozetine çeviriyor ve AÇIK bir çağrı
            //   "Pasif" görünüyordu (301'de başvuru listesi aynı tuzağa
            //   düşmüştü). Çok değerli durum sunucuda metne çevrilir; sayısal
            //   kolon süzgeç ve çipler için görünmez kalır.
            new("durumAdi", "c.durum_adi", "metin", "Durum", Hizalama: "orta",
                Genislik: 130, Bicim: "rozet", Filtrelenebilir: false),
            new("durum", "c.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: ServisCagriDurumu),
            new("slaKalanDk", "c.sla_kalan_dk", "sayi", "SLA (dk)",
                Hizalama: "sag", Genislik: 100, Filtrelenebilir: false),
            new("acilis", "c.acilis", "tarih", "Açılış", Genislik: 140),
            new("ziyaretSayisi", "c.ziyaret_sayisi", "sayi", "Ziyaret",
                Hizalama: "sag", Genislik: 90, Filtrelenebilir: false),
            new("isEmriSayisi", "c.is_emri_sayisi", "sayi", "İş Emri",
                Hizalama: "sag", Genislik: 90, Varsayilan: false),
            new("bildiren", "c.bildiren", "metin", "Bildiren", Varsayilan: false),
            new("telefon", "c.telefon", "metin", "Telefon", Varsayilan: false),
            new("sozlesmeId", "c.sozlesme_id", "sayi", "Sözleşme", Varsayilan: false),
            new("tarafId", "c.taraf_id", "sayi", "Müşteri Id", Varsayilan: false),
            new("tarafCihazId", "c.taraf_cihaz_id", "sayi", "Cihaz Id",
                Varsayilan: false),
            new("sonuc", "c.sonuc", "metin", "Sonuç", Varsayilan: false),
            new("kapanis", "c.kapanis", "tarih", "Kapanış", Varsayilan: false)
        ]);

    // --------------------------------------------------------- iş emri ----
    /// <summary>
    /// İÇ VE DIŞ İŞ AYNI LİSTEDE (mockup kararı): teknisyenin günü ikiye
    /// bölünmez, sırasını önceliğe göre kurar. Ayrım `sahiplik` sütununda
    /// durur ve ücret tarafını belirler.
    /// </summary>
    private static KaynakTanimi ServisIsEmri() => new(
        Ad: "servis-is-emri",
        YetkiKodu: "servis",
        Kaynak: "public.v_servis_is_emri e",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "case when e.durum between 0 and 4 then 0 else 1 end, "
                        + "e.oncelik, e.bildirim_zamani",
        Kolonlar:
        [
            new("id", "e.id", "sayi", "Id", Varsayilan: false),
            new("isEmriNo", "e.is_emri_no", "metin", "İş Emri", Genislik: 120),
            new("sahiplikAdi", "e.sahiplik_adi", "metin", "Tür", Hizalama: "orta",
                Genislik: 110, Bicim: "rozet", Filtrelenebilir: false),
            new("sahiplik", "e.sahiplik", "kod", "Sahiplik", Varsayilan: false,
                Kodlar: ServisSahiplikKodlari),
            new("cagriNo", "e.cagri_no", "metin", "Çağrı", Genislik: 110),
            new("sahipAdi", "e.sahip_adi", "metin", "Müşteri / Birim",
                Genislik: 200),
            new("cihaz", "e.cihaz", "metin", "Cihaz", Genislik: 180),
            new("arizaMetni", "e.ariza_metni", "metin", "Arıza / İş",
                Genislik: 260),
            new("kapsamAdi", "e.kapsam_adi", "metin", "Kapsam", Hizalama: "orta",
                Genislik: 140, Bicim: "rozet", Filtrelenebilir: false),
            new("durumAdi", "e.durum_adi", "metin", "Durum", Hizalama: "orta",
                Genislik: 130, Bicim: "rozet", Filtrelenebilir: false),
            new("durum", "e.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: DbIsEmriDurumKodlari),
            new("ziyaretSayisi", "e.ziyaret_sayisi", "sayi", "Ziyaret",
                Hizalama: "sag", Genislik: 90, Filtrelenebilir: false),
            // AÇIK EMANET KOLONU: iş emri kapanmadan önce görünmeli - kapanan
            //   iş emriyle unutulan emanet, sahada duran ama envanterde
            //   "depoda" yazan cihaz demektir.
            new("acikEmanet", "e.acik_emanet", "sayi", "Emanet",
                Hizalama: "sag", Genislik: 90, Filtrelenebilir: false),
            new("toplamTutar", "e.toplam_tutar", "para", "Toplam",
                Hizalama: "sag", Genislik: 120),
            new("iscilikTutar", "e.iscilik_tutar", "para", "İşçilik",
                Hizalama: "sag", Varsayilan: false),
            new("parcaTutar", "e.parca_tutar", "para", "Parça",
                Hizalama: "sag", Varsayilan: false),
            new("bildirimZamani", "e.bildirim_zamani", "tarih", "Bildirim",
                Genislik: 140),
            new("planlanan", "e.planlanan", "tarih", "Planlanan",
                Varsayilan: false),
            new("teklifNo", "e.teklif_no", "metin", "Teklif", Varsayilan: false),
            new("cagriId", "e.cagri_id", "sayi", "Çağrı Id", Varsayilan: false),
            new("musteriTarafId", "e.musteri_taraf_id", "sayi", "Müşteri Id",
                Varsayilan: false)
        ]);

    // --------------------------------------------------------- ziyaret ----
    private static KaynakTanimi ServisZiyaret() => new(
        Ad: "servis-ziyaret",
        YetkiKodu: "servis",
        Kaynak: "public.v_servis_ziyaret z",
        SubeKolonu: "z.sube_id",
        VarsayilanSirala: "coalesce(z.varis, z.plan_zamani) desc nulls last",
        Kolonlar:
        [
            new("id", "z.id", "sayi", "Id", Varsayilan: false),
            new("isEmriNo", "z.is_emri_no", "metin", "İş Emri", Genislik: 120),
            new("cagriNo", "z.cagri_no", "metin", "Çağrı", Genislik: 110),
            new("tarafAdi", "z.taraf_adi", "metin", "Müşteri", Genislik: 190),
            new("sira", "z.sira", "sayi", "#", Hizalama: "orta", Genislik: 50),
            new("teknisyenAdi", "z.teknisyen_adi", "metin", "Teknisyen",
                Genislik: 150),
            new("planZamani", "z.plan_zamani", "tarih", "Plan", Genislik: 140),
            new("varis", "z.varis", "tarih", "Varış", Genislik: 140),
            new("ayrilis", "z.ayrilis", "tarih", "Ayrılış", Varsayilan: false),
            new("yerindeSaat", "z.yerinde_saat", "sayi", "Yerinde (sa)",
                Hizalama: "sag", Genislik: 110, Filtrelenebilir: false),
            // YOL DA BİR MALİYETTİR: çizelgede boş görünen saat aslında yolda.
            new("yolKm", "z.yol_km", "sayi", "Yol (km)", Hizalama: "sag",
                Genislik: 90),
            new("sonucAdi", "z.sonuc_adi", "metin", "Sonuç", Hizalama: "orta",
                Genislik: 130, Bicim: "rozet", Filtrelenebilir: false),
            new("sonuc", "z.sonuc", "kod", "Sonuç Kodu", Varsayilan: false,
                Kodlar: ZiyaretSonucKodlari),
            new("imzaAlindi", "z.imza_alindi", "mantik", "İmza",
                Hizalama: "orta", Genislik: 80),
            new("tutar", "z.tutar", "para", "Tutar", Hizalama: "sag",
                Genislik: 110),
            new("yapilan", "z.yapilan", "metin", "Yapılan", Genislik: 260),
            new("arac", "z.arac", "metin", "Araç", Varsayilan: false),
            new("isEmriId", "z.is_emri_id", "sayi", "İş Emri Id",
                Varsayilan: false)
        ]);

    // ---------------------------------------------------------- emanet ----
    /// <summary>
    /// AÇIK EMANET AYRI LİSTE: iş emrinin içinde kalırsa kapanan iş emriyle
    /// birlikte görünmez olur. 15 gündür dışarıdaki cihaz burada durur.
    /// </summary>
    private static KaynakTanimi ServisEmanet() => new(
        Ad: "servis-emanet",
        YetkiKodu: "servis",
        Kaynak: "public.v_servis_emanet m",
        SubeKolonu: "m.sube_id",
        VarsayilanSirala: "case when m.durum = 1 then 0 else 1 end, m.veris",
        Kolonlar:
        [
            new("id", "m.id", "sayi", "Id", Varsayilan: false),
            new("emanetNo", "m.emanet_no", "metin", "Emanet No", Genislik: 110),
            new("tarafAdi", "m.taraf_adi", "metin", "Kimde", Genislik: 200),
            new("cihaz", "m.cihaz", "metin", "Cihaz", Genislik: 220),
            new("veris", "m.veris", "tarih", "Veriliş", Genislik: 140),
            new("iade", "m.iade", "tarih", "İade", Genislik: 140),
            new("gun", "m.gun", "sayi", "Gün", Hizalama: "sag", Genislik: 80,
                Filtrelenebilir: false),
            new("durumAdi", "m.durum_adi", "metin", "Durum", Hizalama: "orta",
                Genislik: 120, Bicim: "rozet", Filtrelenebilir: false),
            new("durum", "m.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: new Dictionary<string, string>
                    { ["1"] = "Dışarıda", ["2"] = "İade alındı" }),
            new("isEmriNo", "m.is_emri_no", "metin", "İş Emri", Genislik: 120),
            new("isEmriId", "m.is_emri_id", "sayi", "İş Emri Id",
                Varsayilan: false),
            new("aciklama", "m.aciklama", "metin", "Açıklama", Varsayilan: false)
        ]);

    // ----------------------------------------------------- cihaz parkı ----
    private static KaynakTanimi TarafCihaz() => new(
        Ad: "taraf-cihaz",
        YetkiKodu: "servis.cihaz",
        Kaynak: "public.v_taraf_cihaz c",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.taraf_adi, c.ad",
        Kolonlar:
        [
            new("id", "c.id", "sayi", "Id", Varsayilan: false),
            new("tarafAdi", "c.taraf_adi", "metin", "Müşteri", Genislik: 200),
            new("ad", "c.ad", "metin", "Cihaz", Genislik: 170),
            new("markaModel", "c.marka_model", "metin", "Marka / Model",
                Genislik: 170),
            new("seriNo", "c.seri_no", "metin", "Seri No", Genislik: 130),
            new("kurulumTarihi", "c.kurulum_tarihi", "tarih", "Kurulum",
                Genislik: 110),
            new("garantiBitis", "c.garanti_bitis", "tarih", "Garanti",
                Genislik: 110),
            new("garantiDurum", "c.garanti_durum", "kod", "Garanti Durumu",
                Hizalama: "orta", Genislik: 130,
                Kodlar: new Dictionary<string, string>
                    { ["0"] = "Bilinmiyor", ["1"] = "Sürüyor", ["2"] = "Bitti" }),
            new("sozlesmeBitis", "c.sozlesme_bitis", "tarih", "Sözleşme",
                Genislik: 110),
            // ÇAĞRI SAYISI: hiç arızalanmamış cihaz da listede durur - yenileme
            //   ve sözleşme teklifi tam onlara gider.
            new("cagriSayisi", "c.cagri_sayisi", "sayi", "Çağrı",
                Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("bolge", "c.bolge", "metin", "Bölge", Genislik: 120),
            new("durum", "c.durum", "kod", "Durum", Hizalama: "orta",
                Genislik: 100,
                Kodlar: new Dictionary<string, string>
                    { ["1"] = "Kullanımda", ["0"] = "Pasif" }),
            new("tarafId", "c.taraf_id", "sayi", "Müşteri Id", Varsayilan: false),
            new("adres", "c.adres", "metin", "Adres", Varsayilan: false)
        ]);

    // -------------------------------------------------------- sözleşme ----
    private static KaynakTanimi ServisSozlesme() => new(
        Ad: "servis-sozlesme",
        YetkiKodu: "servis.sozlesme",
        Kaynak: "public.v_servis_sozlesme s",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "case when s.durum = 1 then 0 else 1 end, s.bitis",
        Kolonlar:
        [
            new("id", "s.id", "sayi", "Id", Varsayilan: false),
            new("sozlesmeNo", "s.sozlesme_no", "metin", "Sözleşme No",
                Genislik: 120),
            new("tarafAdi", "s.taraf_adi", "metin", "Müşteri", Genislik: 210),
            new("baslangic", "s.baslangic", "tarih", "Başlangıç", Genislik: 110),
            new("bitis", "s.bitis", "tarih", "Bitiş", Genislik: 110),
            new("kalanGun", "s.kalan_gun", "sayi", "Kalan Gün", Hizalama: "sag",
                Genislik: 100, Filtrelenebilir: false),
            new("kapsamAdi", "s.kapsam_adi", "metin", "Kapsam", Hizalama: "orta",
                Genislik: 130, Bicim: "rozet", Filtrelenebilir: false),
            new("slaSaat", "s.sla_saat", "sayi", "SLA (sa)", Hizalama: "sag",
                Genislik: 90),
            new("periyotAy", "s.periyot_ay", "sayi", "Periyot (ay)",
                Hizalama: "sag", Genislik: 110),
            new("cihazSayisi", "s.cihaz_sayisi", "sayi", "Cihaz",
                Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            // SLA AŞIMI SÖZLEŞMEYE YAZILIR: yenileme görüşmesinin girdisi.
            new("slaAsim", "s.sla_asim", "sayi", "SLA Aşımı", Hizalama: "sag",
                Genislik: 100, Filtrelenebilir: false),
            new("yillikBedel", "s.yillik_bedel", "para", "Yıllık Bedel",
                Hizalama: "sag", Genislik: 130),
            new("durum", "s.durum", "kod", "Durum", Hizalama: "orta",
                Genislik: 100,
                Kodlar: new Dictionary<string, string>
                    { ["1"] = "Yürürlükte", ["0"] = "Pasif" }),
            new("tarafId", "s.taraf_id", "sayi", "Müşteri Id", Varsayilan: false)
        ]);
}
