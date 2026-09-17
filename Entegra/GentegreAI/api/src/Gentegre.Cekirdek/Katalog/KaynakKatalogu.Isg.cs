namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// İŞYERİ HEKİMLİĞİ (741) listeleri — mockup <c>Ekranlar/ISG/*.html</c>.
/// Firma → çalışan → Ek-2 muayene → ziyaret → olay. Pano ve periyodik takvim
/// özel sayfa; çalışan kartı özel modal.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi IsgFirma() => new(
        Ad: "isg-firma",
        YetkiKodu: "isg.firma",
        Kaynak: "public.v_isg_firma f",
        SubeKolonu: null,
        VarsayilanSirala: "f.durum desc, f.firma_adi",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "f.id",             "sayi",  "Id", Varsayilan: false),
            new("firmaAdi",      "f.firma_adi",      "metin", "Firma", Genislik: 220),
            new("nace",          "f.nace",           "metin", "NACE", Genislik: 70),
            new("tehlikeAdi",    "f.tehlike_adi",    "metin", "Tehlike", Genislik: 110, Bicim: "rozet"),
            new("aktifCalisan",  "f.aktif_calisan",  "sayi",  "Çalışan", Hizalama: "orta"),
            new("calisanSayisi", "f.calisan_sayisi", "sayi",  "Beyan", Hizalama: "orta", Varsayilan: false),
            new("hekimAdi",      "f.hekim_adi",      "metin", "İşyeri hekimi", Genislik: 140),
            new("isgUzmanAdi",   "f.isg_uzman_adi",  "metin", "İSG uzmanı", Genislik: 130, Varsayilan: false),
            new("planDk",        "f.plan_dk",        "sayi",  "Plan dk/ay", Hizalama: "sag"),
            new("muayeneDkAy",   "f.muayene_dk_ay",  "sayi",  "Muayene dk", Hizalama: "sag"),
            new("ziyaretDkAy",   "f.ziyaret_dk_ay",  "sayi",  "Ziyaret dk", Hizalama: "sag"),
            new("vadeYaklasan",  "f.vade_yaklasan",  "sayi",  "Vade (30 g)", Hizalama: "orta"),
            new("kazaYil",       "f.kaza_yil",       "sayi",  "Kaza (yıl)", Hizalama: "orta"),
            new("sozlesmeBit",   "f.sozlesme_bit",   "tarih", "Sözleşme bitiş"),
            new("durumAdi",      "f.durum_adi",      "metin", "Durum", Genislik: 70, Bicim: "rozet"),
            new("tarafId",       "f.taraf_id",       "sayi",  "Taraf Id", Varsayilan: false),
            new("tehlike",       "f.tehlike",        "sayi",  "Tehlike Kodu", Varsayilan: false),
            new("durum",         "f.durum",          "sayi",  "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi IsgCalisan() => new(
        Ad: "isg-calisan",
        YetkiKodu: "isg.calisan",
        Kaynak: "public.v_isg_calisan c",
        SubeKolonu: null,
        VarsayilanSirala: "c.durum desc, c.kalan_gun, c.calisan_adi",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "c.id",             "sayi",  "Id", Varsayilan: false),
            new("calisanAdi",    "c.calisan_adi",    "metin", "Çalışan", Genislik: 170),
            new("firmaAdi",      "c.firma_adi",      "metin", "Firma", Genislik: 170),
            new("bolumAdi",      "c.bolum_adi",      "metin", "Bölüm", Genislik: 110),
            new("gorev",         "c.gorev",          "metin", "Görev", Genislik: 120),
            new("tehlikeAdi",    "c.tehlike_adi",    "metin", "Tehlike", Genislik: 100, Bicim: "rozet", Varsayilan: false),
            new("calismaAdi",    "c.calisma_adi",    "metin", "Çalışma", Genislik: 120, Varsayilan: false),
            new("iseGiris",      "c.ise_giris",      "tarih", "İşe giriş"),
            new("sonMuayene",    "c.son_muayene",    "tarih", "Son muayene"),
            new("sonKanaatAdi",  "c.son_kanaat_adi", "metin", "Kanaat", Genislik: 120, Bicim: "rozet"),
            new("vade",          "c.vade",           "tarih", "Vade"),
            new("kalanGun",      "c.kalan_gun",      "sayi",  "Kalan gün", Hizalama: "orta"),
            new("periyotHesap",  "c.periyot_hesap",  "sayi",  "Periyot (ay)", Hizalama: "orta", Varsayilan: false),
            new("muayeneSayisi", "c.muayene_sayisi", "sayi",  "Muayene", Hizalama: "orta", Varsayilan: false),
            new("acikMuayene",   "c.acik_muayene",   "sayi",  "Açık muayene", Hizalama: "orta"),
            new("olaySayisi",    "c.olay_sayisi",    "sayi",  "Olay", Hizalama: "orta", Varsayilan: false),
            new("cepTel",        "c.cep_tel",        "metin", "Cep", Genislik: 120, Varsayilan: false),
            new("durumAdi",      "c.durum_adi",      "metin", "Durum", Genislik: 70, Bicim: "rozet"),
            new("hastaId",       "c.hasta_id",       "sayi",  "Hasta Id", Varsayilan: false),
            new("firmaId",       "c.firma_id",       "sayi",  "Firma Id", Varsayilan: false),
            new("sonKanaat",     "c.son_kanaat",     "sayi",  "Kanaat Kodu", Varsayilan: false),
            new("durum",         "c.durum",          "sayi",  "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi IsgMuayene() => new(
        Ad: "isg-muayene",
        YetkiKodu: "isg.muayene",
        Kaynak: "public.v_isg_muayene m",
        SubeKolonu: "m.sube_id",
        VarsayilanSirala: "m.durum, m.tarih desc, m.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "m.id",             "sayi",  "Id", Varsayilan: false),
            new("tarih",         "m.tarih",          "tarih", "Tarih"),
            new("calisanAdi",    "m.calisan_adi",    "metin", "Çalışan", Genislik: 170),
            new("firmaAdi",      "m.firma_adi",      "metin", "Firma", Genislik: 160),
            new("bolumAdi",      "m.bolum_adi",      "metin", "Bölüm", Genislik: 100, Varsayilan: false),
            new("turAdi",        "m.tur_adi",        "metin", "Tür", Genislik: 100, Bicim: "rozet"),
            new("hekimAdi",      "m.hekim_adi",      "metin", "Hekim", Genislik: 130),
            new("formDurumAdi",  "m.form_durum_adi", "metin", "Ek-2 formu", Genislik: 110, Bicim: "rozet"),
            new("kanaatAdi",     "m.kanaat_adi",     "metin", "Kanaat", Genislik: 130, Bicim: "rozet"),
            new("kosul",         "m.kosul",          "metin", "Koşul", Genislik: 200),
            new("sonrakiTarih",  "m.sonraki_tarih",  "tarih", "Sonraki"),
            new("sevk",          "m.sevk",           "mantik", "Sevk", Hizalama: "orta"),
            new("durumAdi",      "m.durum_adi",      "metin", "Durum", Genislik: 90, Bicim: "rozet"),
            new("calisanId",     "m.calisan_id",     "sayi",  "Çalışan Id", Varsayilan: false),
            new("formIstekId",   "m.form_istek_id",  "sayi",  "Form Id", Varsayilan: false),
            new("hastaId",       "m.hasta_id",       "sayi",  "Hasta Id", Varsayilan: false),
            new("tur",           "m.tur",            "sayi",  "Tür Kodu", Varsayilan: false),
            new("kanaat",        "m.kanaat",         "sayi",  "Kanaat Kodu", Varsayilan: false),
            new("durum",         "m.durum",          "sayi",  "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi IsgZiyaret() => new(
        Ad: "isg-ziyaret",
        YetkiKodu: "isg.ziyaret",
        Kaynak: "public.v_isg_ziyaret z",
        SubeKolonu: "z.sube_id",
        VarsayilanSirala: "z.tarih desc, z.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "z.id",           "sayi",  "Id", Varsayilan: false),
            new("tarih",       "z.tarih",        "tarih", "Tarih"),
            new("firmaAdi",    "z.firma_adi",    "metin", "Firma", Genislik: 180),
            new("turAdi",      "z.tur_adi",      "metin", "Tür", Genislik: 120, Bicim: "rozet"),
            new("sureDk",      "z.sure_dk",      "sayi",  "Süre (dk)", Hizalama: "sag"),
            new("hekimAdi",    "z.hekim_adi",    "metin", "Hekim", Genislik: 130),
            new("bolumler",    "z.bolumler",     "metin", "Gezilen", Genislik: 160, Varsayilan: false),
            new("oneri",       "z.oneri",        "metin", "Öneri (defter)", Genislik: 260),
            new("termin",      "z.termin",       "tarih", "Termin"),
            new("terminGecti", "z.termin_gecti", "mantik", "Termin geçti", Hizalama: "orta"),
            new("defterSayfa", "z.defter_sayfa", "metin", "Defter", Genislik: 80),
            new("imzaSayisi",  "z.imza_sayisi",  "sayi",  "İmza", Hizalama: "orta"),
            new("firmaId",     "z.firma_id",     "sayi",  "Firma Id", Varsayilan: false),
            new("tur",         "z.tur",          "sayi",  "Tür Kodu", Varsayilan: false),
        });

    private static KaynakTanimi IsgOlay() => new(
        Ad: "isg-olay",
        YetkiKodu: "isg.olay",
        Kaynak: "public.v_isg_olay o",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.durum, o.tarih desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "o.id",            "sayi",  "Id", Varsayilan: false),
            new("tarih",        "o.tarih",         "tarih", "Tarih"),
            new("turAdi",       "o.tur_adi",       "metin", "Tür", Genislik: 150, Bicim: "rozet"),
            new("calisanAdi",   "o.calisan_adi",   "metin", "Çalışan", Genislik: 160),
            new("firmaAdi",     "o.firma_adi",     "metin", "Firma", Genislik: 160),
            new("yer",          "o.yer",           "metin", "Yer", Genislik: 120),
            new("yaralanma",    "o.yaralanma",     "metin", "Yaralanma", Genislik: 160),
            new("gunKaybi",     "o.gun_kaybi",     "sayi",  "Gün kaybı", Hizalama: "orta"),
            new("sgkBildirim",  "o.sgk_bildirim",  "tarih", "SGK bildirim"),
            new("sgkKalanGun",  "o.sgk_kalan_gun", "sayi",  "SGK kalan gün", Hizalama: "orta"),
            new("sgkGecikti",   "o.sgk_gecikti",   "mantik", "SGK gecikti", Hizalama: "orta"),
            new("durumAdi",     "o.durum_adi",     "metin", "Durum", Genislik: 80, Bicim: "rozet"),
            new("firmaId",      "o.firma_id",      "sayi",  "Firma Id", Varsayilan: false),
            new("calisanId",    "o.calisan_id",    "sayi",  "Çalışan Id", Varsayilan: false),
            new("tur",          "o.tur",           "sayi",  "Tür Kodu", Varsayilan: false),
            new("durum",        "o.durum",         "sayi",  "Durum Kodu", Varsayilan: false),
        });
}
