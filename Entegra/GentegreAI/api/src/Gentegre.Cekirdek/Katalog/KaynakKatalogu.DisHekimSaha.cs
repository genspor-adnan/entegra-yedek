namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DIŞ DOKTOR SAHA LİSTELERİ (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §1 / §2): ziyaretler ve
/// doktor talepleri. Görünümler ad / kod çözümünü taşır (v_dis_hekim_ziyaret, v_dis_hekim_talep).
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi DisHekimZiyaret() => new(
        Ad: "dis-hekim-ziyaret",
        YetkiKodu: "dis_doktor.ziyaret",
        Kaynak: "public.v_dis_hekim_ziyaret z",
        SubeKolonu: "z.sube_id",
        VarsayilanSirala: "z.tarih desc",
        Kolonlar:
        [
            new("id",          "z.id",            "sayi",  "Id", Varsayilan: false),
            new("tarih",       "z.tarih",         "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("hekimAd",     "z.hekim_ad",      "metin", "Dış Doktor", Genislik: 220),
            new("hekimKurum",  "z.hekim_kurum",   "metin", "Kurum", Genislik: 180),
            new("hekimIlce",   "z.hekim_ilce",    "metin", "İlçe", Genislik: 110),
            new("temsilciAd",  "z.temsilci_ad",   "metin", "Temsilci", Genislik: 160),
            new("subeAd",      "z.sube_ad",       "metin", "Şube", Genislik: 120, Varsayilan: false),
            new("turAd",       "z.tur_ad",        "metin", "Tür", Hizalama: "orta", Genislik: 110, Filtrelenebilir: false),
            new("amacAd",      "z.amac_ad",       "metin", "Amaç", Genislik: 150, Filtrelenebilir: false),
            new("sonucAd",     "z.sonuc_ad",      "metin", "Sonuç", Hizalama: "orta", Genislik: 130, Bicim: "rozet", Filtrelenebilir: false),
            new("sureDk",      "z.sure_dk",       "sayi",  "Süre (dk)", Hizalama: "sag", Genislik: 90, Varsayilan: false),
            new("notu",        "left(z.notu, 200)", "metin", "Not", Genislik: 320, Filtrelenebilir: false),
            new("talepSayisi", "z.talep_sayisi",  "sayi",  "Talep", Hizalama: "sag", Genislik: 70, Filtrelenebilir: false),
            new("acikTalep",   "z.acik_talep",    "sayi",  "Açık Talep", Hizalama: "sag", Genislik: 90),
            new("sonrakiTarih","z.sonraki_tarih", "tarih", "Sonraki", Hizalama: "orta", Genislik: 100),
            new("yorumSayisi", "z.yorum_sayisi",  "sayi",  "Yorum", Hizalama: "sag", Genislik: 70, Varsayilan: false),
            new("gorulduAd",   "z.goruldu_ad",    "metin", "Gören", Genislik: 140, Varsayilan: false),
            new("goruldu",     "case when z.goruldu_id is null then 0 else 1 end", "mantik", "Görüldü",
                Hizalama: "orta", Genislik: 80),
            new("mobil",       "z.mobil",         "mantik", "Mobil", Hizalama: "orta", Genislik: 70, Varsayilan: false),
            new("tur",         "z.tur",           "kod",   "Tür Kodu", Varsayilan: false),
            new("amac",        "z.amac",          "kod",   "Amaç Kodu", Varsayilan: false),
            new("sonuc",       "z.sonuc",         "kod",   "Sonuç Kodu", Varsayilan: false),
            new("durum",       "z.durum",         "kod",   "Durum Kodu", Varsayilan: false, Kodlar: KartKatalogu.ZiyaretDurumKodlari),
            new("hekimId",     "z.hekim_id",      "sayi",  "Doktor Id", Varsayilan: false),
            new("temsilciId",  "z.temsilci_id",   "sayi",  "Temsilci Id", Varsayilan: false),
            new("gorulduId",   "z.goruldu_id",    "sayi",  "Gören Id", Varsayilan: false),
        ]);

    private static KaynakTanimi DisHekimTalep() => new(
        Ad: "dis-hekim-talep",
        YetkiKodu: "dis_doktor.talep",
        Kaynak: "public.v_dis_hekim_talep t",
        SubeKolonu: "t.sube_id",
        VarsayilanSirala: "case when t.durum in (1, 2) then 0 else 1 end, t.termin nulls last, t.id desc",
        Kolonlar:
        [
            new("id",          "t.id",            "sayi",  "Id", Varsayilan: false),
            new("hekimAd",     "t.hekim_ad",      "metin", "Dış Doktor", Genislik: 220),
            new("hekimKurum",  "t.hekim_kurum",   "metin", "Kurum", Genislik: 160, Varsayilan: false),
            new("turAd",       "t.tur_ad",        "metin", "Tür", Hizalama: "orta", Genislik: 110, Filtrelenebilir: false),
            new("talep",       "t.talep",         "metin", "Talep", Genislik: 320),
            new("oncelikAd",   "t.oncelik_ad",    "metin", "Öncelik", Hizalama: "orta", Genislik: 90, Bicim: "rozet", Filtrelenebilir: false),
            new("sorumluAd",   "t.sorumlu_ad",    "metin", "Sorumlu", Genislik: 160),
            new("termin",      "t.termin",        "tarih", "Termin", Hizalama: "orta", Genislik: 100),
            new("gecikmeGun",  "t.gecikme_gun",   "sayi",  "Gecikme (gün)", Hizalama: "sag", Genislik: 100),
            // TERMİNİ GEÇEN KIRMIZI (mockup): satır rengi sunucudan.
            new("satirRengi",  "case when t.gecikme_gun > 0 then 'kritik' when t.oncelik = 3 and t.durum in (1, 2) then 'uyari' else '' end",
                "metin", "Satır Rengi", Varsayilan: false, Filtrelenebilir: false),
            new("durumAdi",    "t.durum_ad",      "metin", "Durum", Hizalama: "orta", Genislik: 100, Bicim: "rozet", Filtrelenebilir: false),
            new("temsilciAd",  "t.temsilci_ad",   "metin", "Temsilci", Genislik: 150),
            new("sonuc",       "t.sonuc",         "metin", "Sonuç / Yanıt", Genislik: 240),
            new("ziyaretTarihi","t.ziyaret_tarihi","tarih", "Ziyaret", Hizalama: "orta", Bicim: "dd.MM.yyyy", Genislik: 100, Varsayilan: false),
            new("gorevId",     "t.gorev_id",      "sayi",  "Görev", Hizalama: "sag", Genislik: 80, Varsayilan: false),
            new("tur",         "t.tur",           "kod",   "Tür Kodu", Varsayilan: false),
            new("durum",       "t.durum",         "kod",   "Durum Kodu", Varsayilan: false),
            new("oncelik",     "t.oncelik",       "kod",   "Öncelik Kodu", Varsayilan: false, Kodlar: KartKatalogu.TalepOncelikKodlari),
            new("hekimId",     "t.hekim_id",      "sayi",  "Doktor Id", Varsayilan: false),
            new("ziyaretId",   "t.ziyaret_id",    "sayi",  "Ziyaret Id", Varsayilan: false),
            new("sorumluId",   "t.sorumlu_id",    "sayi",  "Sorumlu Id", Varsayilan: false),
        ]);
}
