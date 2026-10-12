namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE - İÇ DENETİM (1051, sade) listesi — mockup
/// <c>Ekranlar/Kalite/kalite_ic_denetim.html</c>. Kart generic (bulgular detayı).
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi KysDenetim() => new(
        Ad: "kys-denetim",
        YetkiKodu: "kys.denetim",
        Kaynak: "public.v_kalite_denetim d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.tarih desc, d.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "d.id",              "sayi",  "Id", Varsayilan: false),
            // Mockup Kalite2/ic_denetim.html (1061): No · Birim · Plan tarihi ·
            //   Yapıldı · Denetçi · Bulgu · Açılan DÖF · Durum.
            new("no",            "d.no",              "metin", "No", Genislik: 110),
            new("birimAdi",      "d.birim_adi",       "metin", "Birim", Genislik: 150),
            new("planTarih",     "d.plan_tarih",      "tarih", "Plan tarihi"),
            new("gerceklesen",   "d.gerceklesen",     "tarih", "Yapıldı"),
            new("tarih",         "d.tarih",           "tarih", "Tarih", Varsayilan: false),
            new("denetci",       "d.denetci",         "metin", "Denetçi", Genislik: 200),
            new("basDenetciAdi", "d.bas_denetci_adi", "metin", "Baş denetçi", Genislik: 150, Varsayilan: false),
            new("ekip",          "d.ekip",            "metin", "Ekip", Genislik: 200, Varsayilan: false),
            new("kapsam",        "d.kapsam",          "metin", "Kapsam", Genislik: 240, Varsayilan: false),
            new("bulguOzet",     "d.bulgu_ozet",      "metin", "Bulgu", Genislik: 150),
            new("dofSayisi",     "d.dof_sayisi",      "sayi",  "Açılan DÖF", Hizalama: "orta"),
            new("durumAdi",      "d.durum_adi",       "metin", "Durum", Genislik: 100, Bicim: "rozet"),
            new("departmanId",   "d.departman_id",    "sayi",  "Birim Id", Varsayilan: false),
            new("gecikti",       "d.gecikti",         "mantik", "Gecikti", Varsayilan: false),
            new("durum",         "d.durum",           "sayi",  "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// Denetim bulguları (1059) — kart detay satırında düğme yok; "DÖF aç"
    /// (kaynak_tur 1) bu listenin satır aksiyonu. Menüde görünmez, denetim
    /// listesindeki "Bulgular" ile <c>?denetimId=</c> süzgeciyle açılır.
    /// </summary>
    private static KaynakTanimi KysDenetimBulgu() => new(
        Ad: "kys-denetim-bulgu",
        YetkiKodu: "kys.denetim",
        Kaynak: "public.v_kalite_denetim_bulgu b",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.tarih desc, b.denetim_id desc, b.sinif, b.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "b.id",            "sayi",  "Id", Varsayilan: false),
            new("denetimNo",    "b.denetim_no",    "metin", "Denetim No", Genislik: 110),
            new("tarih",        "b.tarih",         "tarih", "Tarih"),
            new("birimAdi",     "b.birim_adi",     "metin", "Birim", Genislik: 160),
            new("sinifAdi",     "b.sinif_adi",     "metin", "Sınıf", Genislik: 70, Bicim: "rozet"),
            new("aciklama",     "b.aciklama",      "metin", "Bulgu", Genislik: 360),
            new("madde",        "b.madde",         "metin", "Madde", Genislik: 90),
            new("dofNo",        "b.dof_no",        "metin", "DÖF", Genislik: 110),
            new("dofDurumAdi",  "b.dof_durum_adi", "metin", "DÖF durumu", Genislik: 90, Bicim: "rozet"),
            new("denetimId",    "b.denetim_id",    "sayi",  "Denetim Id", Varsayilan: false),
            new("departmanId",  "b.departman_id",  "sayi",  "Birim Id", Varsayilan: false),
            new("sinif",        "b.sinif",         "sayi",  "Sınıf Kodu", Varsayilan: false),
        });
}
