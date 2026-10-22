namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PERSONEL BELGE TAKİBİ (1135) — İK takip listesi (personel başına satır) ve belge türü listesi.
/// Mockup Ekranlar/IK/personel_belge_takibi.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Takip: id = personel id (çift tık personel kartını açar). Eksik / doldu kırmızı, yaklaşan sarı.</summary>
    private static KaynakTanimi PersonelBelgeOzet() => new(
        Ad: "personel-belge-ozet",
        YetkiKodu: "ik.belge_takip",
        Kaynak: "public.v_personel_belge_ozet x",
        // Personel kurum geneli izlenir (şube damgası taraf'ın şubesi - süzülmez).
        SubeKolonu: null,
        VarsayilanSirala: "x.tamamlanma, x.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "x.id",          "sayi",  "Id", Varsayilan: false),
            new("ad",          "x.ad",          "metin", "Personel", Genislik: 200),
            new("birim",       "x.birim",       "metin", "Bölüm", Genislik: 170),
            new("gorev",       "x.gorev",       "metin", "Görev", Genislik: 150),
            new("tamamlanma",  "x.tamamlanma",  "sayi",  "Tamamlanma", Genislik: 110, Bicim: "yuzde"),
            new("zorunlu",     "x.zorunlu",     "sayi",  "Zorunlu", Hizalama: "orta", Varsayilan: false),
            // Mockup (2): eksik / doldu sıfırdan büyükse vurgulu (sayaç rozeti), yaklaşan düz.
            new("eksik",       "x.eksik",       "sayi",  "Eksik", Hizalama: "orta", Bicim: "sayac"),
            new("doldu",       "x.doldu",       "sayi",  "Doldu", Hizalama: "orta", Bicim: "sayac"),
            new("yaklasan",    "x.yaklasan",    "sayi",  "Yaklaşan", Hizalama: "orta"),
            // "Belge - Süresi doldu (-14 gün)": durum rengi rozette (web gridHucre ROZET_DESENI).
            new("enAcil",      "x.en_acil",     "metin", "En acil", Genislik: 300, Bicim: "rozet"),
            new("departmanId", "x.departman_id", "sayi", "Birim Id", Varsayilan: false),
            new("satirRengi",  "case when x.eksik + x.doldu > 0 then 'kritik' when x.yaklasan > 0 then 'uyari' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });

    /// <summary>
    /// Belge türleri (mockup personel_belge_turu.html (1)): grup başlıklı, sıra · geçerlilik · uyarı ·
    /// dosya · kime zorunlu ve kurum geneli Personel / Tamam / Eksik / Doldu / Yaklaşan (1138).
    /// </summary>
    private static KaynakTanimi PersonelBelgeTuru() => new(
        Ad: "personel-belge-turu",
        YetkiKodu: "ik.belge_takip",
        Kaynak: "public.v_personel_belge_turu t",
        SubeKosulu: "(t.sube_id = 0 or t.sube_id = {sube})",
        VarsayilanSirala: "t.grup, t.sira, t.ad",
        // Grup başlıkları (Kimlik / işe giriş · Mesleki ...) grup koduyla sıralı.
        GrupKolonu: "grupAdi",
        GrupSiraKolonu: "grup",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "t.id",             "sayi",  "Id", Varsayilan: false),
            new("sira",          "t.sira",           "sayi",  "Sıra", Hizalama: "sag", Genislik: 60),
            new("ad",            "t.ad",             "metin", "Belge adı", Genislik: 260),
            new("grupAdi",       "t.grup_adi",       "metin", "Grup", Genislik: 150, Varsayilan: false),
            new("gecerlilikAdi", "t.gecerlilik_adi", "metin", "Geçerlilik", Genislik: 90),
            new("uyariAdi",      "t.uyari_adi",      "metin", "Uyarı", Genislik: 70),
            new("dosyaAdi",      "t.dosya_adi",      "metin", "Dosya", Genislik: 100),
            new("kapsam",        "t.kapsam",         "metin", "Kime zorunlu", Genislik: 240),
            new("personel",      "t.personel",       "sayi",  "Personel", Hizalama: "sag"),
            new("tamam",         "t.tamam",          "sayi",  "Tamam", Hizalama: "sag"),
            new("eksik",         "t.eksik",          "sayi",  "Eksik", Hizalama: "sag", Bicim: "sayac"),
            new("doldu",         "t.doldu",          "sayi",  "Doldu", Hizalama: "sag", Bicim: "sayac"),
            new("yaklasan",      "t.yaklasan",       "sayi",  "Yaklaşan", Hizalama: "sag"),
            new("aktifAdi",      "t.aktif_adi",      "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 80, Filtrelenebilir: false),
            new("aciklama",      "t.aciklama",       "metin", "Açıklama", Genislik: 200, Varsayilan: false),
            new("aktif",         "t.aktif",          "mantik", "Aktif", Varsayilan: false),
            new("grup",          "t.grup",           "sayi",  "Grup kodu", Varsayilan: false),
            new("kapsamli",      "t.kapsamli",       "mantik", "Kapsamlı", Varsayilan: false),
            new("sureli",        "t.sureli",         "mantik", "Süreli", Varsayilan: false),
            new("gecerlilikAy",  "t.gecerlilik_ay",  "sayi",  "Geçerlilik (ay)", Varsayilan: false),
            new("hatirlatGun",   "t.hatirlat_gun",   "sayi",  "Uyarı (gün)", Varsayilan: false),
            new("dosyaZorunlu",  "t.dosya_zorunlu",  "mantik", "Dosya zorunlu", Varsayilan: false),
            new("satirRengi",    "case when t.aktif <> 1 then 'pasif' end", "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });
}
