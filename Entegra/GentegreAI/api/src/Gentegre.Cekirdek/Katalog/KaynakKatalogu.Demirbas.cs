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
                "coalesce((select t.unvan from public.taraf t where t.id = d.zimmet_taraf_id), '')",
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
}
