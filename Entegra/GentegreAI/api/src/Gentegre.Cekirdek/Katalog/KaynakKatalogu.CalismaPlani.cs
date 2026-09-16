namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HEKİM ÇALIŞMA PLANI (711) listeleri: şablonlar ve istisnalar. Haftalık
/// plan liste DEĞİL, türetilir (özel sayfa /calisma-plani); burada yalnız
/// tekrar eden kural (şablon) ve onu ezen istisna listelenir.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi CalismaSablon() => new(
        Ad: "calisma-sablon",
        YetkiKodu: "randevu.plan",
        Kaynak: "public.v_hekim_calisma_sablon s",
        SubeKolonu: null,                 // sube_id null = tüm şubeler; şube süzmesi listede kolonla
        VarsayilanSirala: "s.hekim_adi, s.departman_adi, s.gecerli_bas",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "s.id",            "sayi",   "Id", Varsayilan: false),
            new("hekimAdi",     "s.hekim_adi",     "metin",  "Hekim", Genislik: 170),
            new("departmanAdi", "s.departman_adi", "metin",  "Bölüm", Genislik: 160),
            new("subeAdi",      "s.sube_adi",      "metin",  "Şube", Genislik: 110),
            new("ad",           "s.ad",            "metin",  "Şablon", Genislik: 120),
            new("gunAdlari",    "s.gun_adlari",    "metin",  "Günler", Genislik: 150, Siralanabilir: false),
            new("saat",         "s.saat",          "metin",  "Saat", Genislik: 130, Siralanabilir: false),
            new("slotDk",       "s.slot_dk",       "sayi",   "Slot (dk)", Hizalama: "orta"),
            new("kanallar",     "s.kanallar",      "metin",  "Kanal", Hizalama: "orta", Genislik: 70),
            new("tekrar",       "case s.tekrar when 2 then 'İki haftada bir' else 'Her hafta' end", "metin", "Tekrar", Hizalama: "orta", Filtrelenebilir: false),
            new("gecerliBas",   "s.gecerli_bas",   "tarih",  "Başlangıç"),
            new("gecerliBit",   "s.gecerli_bit",   "tarih",  "Bitiş"),
            new("gunlukKota",   "s.gunluk_kota",   "sayi",   "Kota", Hizalama: "orta", Varsayilan: false),
            new("aktif",        "s.aktif",         "mantik", "Aktif", Hizalama: "orta"),
            new("hekimId",      "s.hekim_id",      "sayi",   "Hekim Id", Varsayilan: false),
            new("departmanId",  "s.departman_id",  "sayi",   "Bölüm Id", Varsayilan: false),
            new("subeId",       "s.sube_id",       "sayi",   "Şube Id", Varsayilan: false),
        });

    private static KaynakTanimi CalismaIstisna() => new(
        Ad: "calisma-istisna",
        YetkiKodu: "randevu.plan",
        Kaynak: "public.v_hekim_calisma_istisna i",
        SubeKolonu: null,
        VarsayilanSirala: "i.bas_tarih desc, i.hekim_adi",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "i.id",            "sayi",   "Id", Varsayilan: false),
            new("tur",          "case i.tur when 1 then 'İzin' when 2 then 'Kongre / eğitim' when 3 then 'Saat değişikliği' when 4 then 'Ek mesai' when 5 then 'Kapalı' else '' end", "metin", "Tür", Hizalama: "orta", Bicim: "rozet", Filtrelenebilir: false),
            new("hekimAdi",     "i.hekim_adi",     "metin",  "Hekim", Genislik: 170),
            new("departmanAdi", "i.departman_adi", "metin",  "Bölüm", Genislik: 150),
            new("subeAdi",      "i.sube_adi",      "metin",  "Şube", Genislik: 110),
            new("basTarih",     "i.bas_tarih",     "tarih",  "Başlangıç"),
            new("bitTarih",     "i.bit_tarih",     "tarih",  "Bitiş"),
            new("saatBas",      "i.saat_bas",      "metin",  "Saat", Hizalama: "orta", Genislik: 70, Siralanabilir: false),
            new("saatBit",      "i.saat_bit",      "metin",  "–", Hizalama: "orta", Genislik: 70, Siralanabilir: false),
            new("etkilenenRandevu", "i.etkilenen_randevu", "sayi", "Etkilenen Randevu", Hizalama: "orta"),
            new("durum",        "i.durum",         "kod",    "Durum", Hizalama: "orta", Bicim: "rozet",
                Kodlar: new Dictionary<string, string> { ["0"] = "Bekliyor", ["1"] = "Onaylı", ["2"] = "İptal" }),
            new("aciklama",     "i.aciklama",      "metin",  "Açıklama", Genislik: 220),
            new("hekimId",      "i.hekim_id",      "sayi",   "Hekim Id", Varsayilan: false),
        });
}
