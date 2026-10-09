namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DEMIRBAS listesi (216, Ekranlar/demirbas_listesi.html kolon cekirdegi).
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi Demirbas() => new(
        Ad: "demirbas",
        YetkiKodu: "demirbas",
        Kaynak: "public.demirbas d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.kod, d.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "d.id",        "sayi",  "Id", Varsayilan: false),
            new("kod",       "d.kod",       "metin", "Demirbaş No", Genislik: 110),
            new("ad",        "d.ad",        "metin", "Adı", Genislik: 240),
            // Liste katmani kod listesi COZMEZ - ad SQL'de uretilir (senaryoAdi deseni).
            new("kategoriAdi",
                "coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id" +
                " where kl.kod = 'demirbas.kategori' and kd.deger = d.kategori and kd.dil = 0), '')",
                "metin", "Kategori", Hizalama: "orta", Genislik: 120,
                Siralanabilir: false, Filtrelenebilir: false),
            new("kategori",  "d.kategori",  "kod",   "Kategori Kodu", Hizalama: "orta", Varsayilan: false),
            new("marka",     "d.marka",     "metin", "Marka", Genislik: 110),
            new("model",     "d.model",     "metin", "Model", Genislik: 120),
            new("seriNo",    "d.seri_no",   "metin", "Seri No", Genislik: 120, Varsayilan: false),
            new("lokasyonAdi",
                "coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id" +
                " where kl.kod = 'demirbas.lokasyon' and kd.deger = d.lokasyon and kd.dil = 0), '')",
                "metin", "Lokasyon", Hizalama: "orta", Genislik: 110,
                Siralanabilir: false, Filtrelenebilir: false),
            new("lokasyon",  "d.lokasyon",  "kod",   "Lokasyon Kodu", Hizalama: "orta", Varsayilan: false),
            new("zimmetAdi",
                "coalesce((select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan from public.taraf t where t.id = d.zimmet_taraf_id), '')",
                "metin", "Zimmet", Genislik: 160, Siralanabilir: false, Filtrelenebilir: false),
            new("alisTarihi", "d.alis_tarihi", "tarih", "Alış Tarihi", Hizalama: "orta"),
            new("alisTutari", "d.alis_tutari", "para",  "Alış Tutarı",
                Hizalama: "sag", Bicim: "#,##0.00"),
            new("garantiBitis", "d.garanti_bitis", "tarih", "Garanti Bitiş",
                Hizalama: "orta", Varsayilan: false),
            new("durumAdi", "case d.durum when 1 then 'Aktif' else 'Pasif' end", "metin",
                "Durum", Hizalama: "orta", Genislik: 90, Bicim: "rozet", Filtrelenebilir: false),
            new("durum",    "d.durum",    "kod",  "Durum Kodu", Hizalama: "orta", Varsayilan: false),
            new("subeId",   "d.sube_id",  "sayi", "Şube", Varsayilan: false),
        });

    /// <summary>
    /// ZİMMET / HAREKETLER (1007, Ekranlar/Demirbas/demirbas_zimmet_hareketleri.html):
    /// 1006 tetiğinin yazdığı demirbaş hareketleri. Satır elle girilmez -
    /// zimmet / iade / devir / yer değişikliği DemirbasZimmetUclari'ndan
    /// demirbaş kartını değiştirir, tetik buraya yazar.
    /// </summary>
    private static KaynakTanimi DemirbasHareket() => new(
        Ad: "demirbasHareket",
        YetkiKodu: "demirbas.zimmet",
        Kaynak: "public.v_demirbas_hareket_liste h",
        SubeKolonu: "h.sube_id",
        VarsayilanSirala: "h.zaman desc, h.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "h.id", "sayi", "Id", Varsayilan: false),
            new("zaman", "h.zaman", "tarih", "Tarih", Hizalama: "orta", Genislik: 130),
            new("tipAdi",
                "case h.tip when 1 then case when h.eski_zimmet_id is not null then 'Devir' else 'Veriş' end" +
                " when 9 then 'İade' when 2 then 'Yer değişikliği' when 3 then 'Yedek havuza'" +
                " when 4 then 'Havuzdan atama' when 5 then 'Atölyeye' when 6 then 'Dış servise'" +
                " when 7 then 'Hurdaya' when 8 then 'Sayımda bulundu' else '' end",
                "metin", "Tip", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tip", "h.tip", "kod", "Tip Kodu", Varsayilan: false, Kodlar: HareketTipKodlari),
            new("demirbasKod", "h.demirbas_kod", "metin", "Demirbaş No", Genislik: 120),
            new("demirbasAd", "h.demirbas_ad", "metin", "Demirbaş", Genislik: 220),
            new("kategori", "h.kategori", "metin", "Kategori", Genislik: 110, Varsayilan: false),
            new("kimden",
                "coalesce(nullif(h.eski_kisi, ''), nullif(h.eski_lokasyon, ''), '—')",
                "metin", "Kimden", Genislik: 170, Siralanabilir: false),
            new("kime",
                "case when h.tip = 9 then coalesce(nullif(h.yeni_lokasyon, ''), 'Depo')" +
                " else coalesce(nullif(h.yeni_kisi, ''), nullif(h.yeni_lokasyon, ''), '—') end",
                "metin", "Kime", Genislik: 170, Siralanabilir: false),
            new("eskiKisi", "h.eski_kisi", "metin", "Eski Zimmet", Varsayilan: false),
            new("yeniKisi", "h.yeni_kisi", "metin", "Yeni Zimmet", Varsayilan: false),
            new("yeniLokasyon", "h.yeni_lokasyon", "metin", "Lokasyon", Varsayilan: false),
            new("tutanakNo", "h.tutanak_no", "metin", "Tutanak No", Genislik: 120),
            new("islemYapan", "h.islem_yapan", "metin", "İşlem Yapan", Genislik: 140),
            new("aciklama", "h.aciklama", "metin", "Açıklama", Genislik: 220),
            new("demirbasId", "h.demirbas_id", "sayi", "Demirbaş Id", Varsayilan: false),
            new("eskiZimmetId", "h.eski_zimmet_id", "sayi", "Eski Zimmet Id", Varsayilan: false),
            new("yeniZimmetId", "h.yeni_zimmet_id", "sayi", "Yeni Zimmet Id", Varsayilan: false),
            new("subeId", "h.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    // demirbas_hareket.hareket (723 + 1006: 9 iade).
    private static readonly Dictionary<string, string> HareketTipKodlari = new()
    {
        ["1"] = "Veriş / devir", ["9"] = "İade", ["2"] = "Yer değişikliği",
        ["3"] = "Yedek havuza", ["4"] = "Havuzdan atama", ["5"] = "Atölyeye",
        ["6"] = "Dış servise", ["7"] = "Hurdaya", ["8"] = "Sayımda bulundu",
    };
}
