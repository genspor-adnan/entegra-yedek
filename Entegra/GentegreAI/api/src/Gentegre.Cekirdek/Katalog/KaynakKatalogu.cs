namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Liste sorgusunun BEYAZ LISTESI. Istekten gelen hicbir metin SQL'e gecmez;
/// alan adlari yalnizca buradaki tanimlarla eslesirse kullanilir, degerler her
/// zaman parametre olarak baglanir.
/// </summary>
public sealed record KolonTanimi(
    string Ad,                 // API/JSON adi: "tarafUnvan"
    string Sql,                // SQL ifadesi: "b.taraf_unvan"
    string Tip,                // metin | sayi | para | tarih | kod | mantik
    string Baslik,
    string Hizalama = "sol",   // sol | orta | sag
    string? Bicim = null,      // "#,##0.00", "dd.MM.yyyy"
    bool Varsayilan = true,    // kolon seciciye varsayilan gorunur gelir
    bool Siralanabilir = true,
    bool Filtrelenebilir = true,
    string? YetkiAlani = null, // alan yetkisi adi; null ise kolon adi kullanilir
    int? Genislik = null       // px - varsayilan (icerige gore) genislik gridde tasarsa (or. uzun metin)
)
{
    public string AlanAdi => YetkiAlani ?? Ad;
    public bool MetinMi => Tip == "metin";
    public bool SayiMi => Tip is "sayi" or "para" or "kod";
}

/// <summary>
/// Bir liste kaynagi. YetkiKodu = yetki tablosundaki kaynak kodu (or. 'cari').
/// SubeKolonu dolu ise HAREKET tablosudur ve sube filtresi SUNUCUDA eklenir;
/// bos ise ana veridir (subeler arasi ortak - 019'daki model).
/// </summary>
public sealed record KaynakTanimi(
    string Ad,                     // yol parcasi: "cari", "belge"
    string YetkiKodu,
    string Kaynak,                 // FROM ifadesi: "public.taraf t"
    IReadOnlyList<KolonTanimi> Kolonlar,
    string? SubeKolonu = null,     // "b.sube_id"
    string? SabitKosul = null,     // "t.musteri = 1 or t.tedarikci = 1"
    string VarsayilanSirala = "id desc",
    string? KapsamKolonu = null    // kullanici_kapsam (tur=1) suzmesi icin taraf id kolonu
)
{
    private Dictionary<string, KolonTanimi>? _dizin;

    public KolonTanimi? Kolon(string ad)
    {
        _dizin ??= Kolonlar.ToDictionary(k => k.Ad, StringComparer.Ordinal);
        return _dizin.TryGetValue(ad, out var k) ? k : null;
    }
}

public static class KaynakKatalogu
{
    private static readonly Dictionary<string, KaynakTanimi> Kaynaklar =
        new(StringComparer.OrdinalIgnoreCase);

    public static KaynakTanimi? Bul(string ad)
        => Kaynaklar.TryGetValue(ad, out var k) ? k : null;

    public static IEnumerable<KaynakTanimi> Tumu => Kaynaklar.Values;

    static KaynakKatalogu()
    {
        Ekle(Cari());
        Ekle(Kisi());
        Ekle(Belge());
        Ekle(Stok());
        Ekle(Personel());
        Ekle(Hizmet());
        Ekle(Masraf());
        Ekle(MaliHareket());
        Ekle(EBelge());
        Ekle(IslemLog());
        Ekle(Rol());
    }

    private static void Ekle(KaynakTanimi k) => Kaynaklar[k.Ad] = k;

    // --------------------------------------------------------------- cari ----
    private static KaynakTanimi Cari() => new(
        Ad: "cari",
        YetkiKodu: "cari",
        Kaynak: "public.taraf t",
        SabitKosul: "(t.musteri = 1 or t.tedarikci = 1)",
        VarsayilanSirala: "t.unvan asc",
        KapsamKolonu: "t.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "t.id",            "sayi",  "Id",            Varsayilan: false),
            new("kod",          "t.kod",           "metin", "Kod"),
            new("unvan",        "t.unvan",         "metin", "Unvan"),
            new("faturaUnvan",  "t.fatura_unvan",  "metin", "Fatura Unvani", Varsayilan: false),
            new("vkno",         "t.vkno",          "metin", "VKN/TCKN"),
            new("vd",           "t.vd",            "metin", "Vergi Dairesi", Varsayilan: false),
            new("telefon",      "t.telefon",       "metin", "Telefon"),
            new("cepTel",       "t.cep_tel",       "metin", "Cep",           Varsayilan: false),
            new("eposta",       "t.eposta",        "metin", "E-posta"),
            new("adres",        "(select ta.adres from public.taraf_adres ta where ta.taraf_id = t.id and ta.varsayilan = 1 limit 1)",
                                                    "metin", "Adres"),
            new("musteri",      "t.musteri",       "mantik","Musteri",       Hizalama: "orta"),
            new("tedarikci",    "t.tedarikci",     "mantik","Tedarikci",     Hizalama: "orta"),
            new("grup",         "t.grup",          "kod",   "Grup",          Varsayilan: false),
            new("kategori",     "t.kategori",      "kod",   "Kategori",      Varsayilan: false),
            new("temsilci",     "t.temsilci",      "kod",   "Temsilci",      Varsayilan: false),
            new("efatura",      "t.efatura",       "mantik","e-Fatura",      Hizalama: "orta"),
            new("durum",        "t.durum",         "kod",   "Durum",         Hizalama: "orta"),
            new("subeId",       "t.sube_id",       "sayi",  "Sube",          Varsayilan: false),
            new("eklemeTarihi", "t.ekleme_tarihi", "tarih", "Eklendi",       Hizalama: "orta",
                                                                            Bicim: "dd.MM.yyyy", Varsayilan: false)
        });

    // -------------------------------------------------------------- kisi ----
    // kisi_listesi.html mockup - kullanici "sade grid olsun, altta sekme yanda bilgi
    // olmasin" dedi (mockup'taki sag "Secili Kisi" paneli + roller/etiket filtreleri YOK).
    // Ayni taraf tablosu (kisi=1), Cari'den BAGIMSIZ ikinci bir KaynakTanimi.
    private static KaynakTanimi Kisi() => new(
        Ad: "kisi",
        YetkiKodu: "cari",                    // ayri yetki kodu yok - cari yetkisiyle yonetiliyor
        Kaynak: "public.taraf t",
        SabitKosul: "t.kisi = 1",
        VarsayilanSirala: "t.unvan asc",
        KapsamKolonu: "t.bag_id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "t.id",            "sayi",  "Id",            Varsayilan: false),
            // Gizli (Varsayilan:false) - grid'de gosterilmiyor ama TarafArama'nin "kod
            //   icerir" filtresi (cari ile ORTAK arama mantigi) bu kolonu arar, yoksa
            //   "Bilinmeyen alan: kod" 400 hatasi.
            new("kod",          "t.kod",           "metin", "Kisi Kodu",     Varsayilan: false),
            new("unvan",        "t.unvan",         "metin", "Unvan"),
            // Gizli - GenGrid "gengrid olmali" (cari kartinda gomulu İlgili Kişiler) sabitFiltre
            //   "bagId = @tarafId" burayla calisir; kendi kolonu gorunmez, sadece filtrelenir.
            new("bagId",        "t.bag_id",        "sayi",  "Bagli Cari Id", Varsayilan: false, Filtrelenebilir: true),
            new("bagliCari",    "(select c.unvan from public.taraf c where c.id = t.bag_id)",
                                                    "metin", "Cari (Firma)", Genislik: 180),
            new("departman",    "t.departman",     "kod",   "Departman"),
            new("gorev",        "t.gorev",         "metin", "Gorev"),
            new("cepTel",       "t.cep_tel",       "metin", "Cep Telefonu"),
            new("telefon",      "t.telefon",       "metin", "Telefon",       Varsayilan: false),
            new("eposta",       "t.eposta",        "metin", "E-posta"),
            // "kod" degil "mantik" - kullanici "durum check olsun" dedi (grid'de ✓/bos,
            //   DurumKodlari zaten sadece 1/0=Aktif/Pasif, ikili).
            new("durum",        "t.durum",         "mantik","Durum",         Hizalama: "orta"),
            new("eklemeTarihi", "t.ekleme_tarihi", "tarih", "Eklendi",       Hizalama: "orta",
                                                                            Bicim: "dd.MM.yyyy", Varsayilan: false)
        });

    // -------------------------------------------------------------- belge ----
    private static KaynakTanimi Belge() => new(
        Ad: "belge",
        YetkiKodu: "belge",
        Kaynak: "public.belge b",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        KapsamKolonu: "b.taraf_id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id",          Varsayilan: false),
            new("tur",           "b.tur",            "kod",   "Tur",         Hizalama: "orta"),
            new("tipi",          "b.tipi",           "kod",   "Tipi",        Hizalama: "orta", Varsayilan: false),
            new("belgeSeri",     "b.belge_seri",     "metin", "Seri",        Varsayilan: false),
            new("belgeNo",       "b.belge_no",       "metin", "Belge No"),
            new("belgeTarihi",   "b.belge_tarihi",   "tarih", "Tarih",       Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tarafId",       "b.taraf_id",       "sayi",  "Cari Id",     Varsayilan: false),
            new("tarafUnvan",    "b.taraf_unvan",    "metin", "Cari"),
            new("tarafVkno",     "b.taraf_vkno",     "metin", "VKN/TCKN",    Varsayilan: false),
            new("matrah",        "b.matrah",         "para",  "Matrah",      Hizalama: "sag", Bicim: "#,##0.00"),
            new("kdvTutari",     "b.kdv_tutari",     "para",  "KDV",         Hizalama: "sag", Bicim: "#,##0.00"),
            new("genelToplam",   "b.genel_toplam",   "para",  "Genel Toplam",Hizalama: "sag", Bicim: "#,##0.00"),
            new("efaturaDurum",  "b.efatura_durum",  "kod",   "e-Fatura",    Hizalama: "orta"),
            new("acikKapali",    "b.acik_kapali",    "kod",   "Acik/Kapali", Hizalama: "orta", Varsayilan: false),
            new("durum",         "b.durum",          "kod",   "Durum",       Hizalama: "orta"),
            new("vadeGun",       "b.vade_gun",       "sayi",  "Vade",        Hizalama: "sag", Varsayilan: false),
            new("aciklama",      "b.aciklama",       "metin", "Aciklama",    Varsayilan: false),
            // Alan yetkisine ornek: rol_alan_yetki'de 'belge.maliyetOrt' izin 0 ise
            //   bu kolon yanittan CIKARILIR ve /kolonlar listesinde de gorunmez.
            new("maliyetOrt",    "b.maliyet_ort",    "para",  "Ort. Maliyet",Hizalama: "sag",
                                                                            Bicim: "#,##0.0000", Varsayilan: false),
            new("subeId",        "b.sube_id",        "sayi",  "Sube",        Varsayilan: false)
        });

    // ----------------------------------------------------------- personel ----
    private static KaynakTanimi Personel() => new(
        Ad: "personel",
        YetkiKodu: "personel",
        Kaynak: "public.taraf t",
        SabitKosul: "t.personel = 1",
        VarsayilanSirala: "t.unvan asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "t.id",            "sayi",  "Id",        Varsayilan: false),
            new("kod",          "t.kod",           "metin", "Sicil No"),
            new("unvan",        "t.unvan",         "metin", "Ad Soyad"),
            new("vkno",         "t.vkno",          "metin", "TCKN"),
            new("cepTel",       "t.cep_tel",       "metin", "Cep"),
            new("eposta",       "t.eposta",        "metin", "E-posta"),
            new("durum",        "t.durum",         "kod",   "Durum",     Hizalama: "orta"),
            new("subeId",       "t.sube_id",       "sayi",  "Sube",      Varsayilan: false)
        });

    // ------------------------------------------------------------- hizmet ----
    private static KaynakTanimi Hizmet() => new(
        Ad: "hizmet",
        YetkiKodu: "hizmet",
        Kaynak: "public.hizmet h",
        VarsayilanSirala: "h.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "h.id",       "sayi",  "Id",         Varsayilan: false),
            new("kod",     "h.kod",      "metin", "Kod"),
            new("ad",      "h.ad",       "metin", "Hizmet Adi"),
            new("grubu",   "h.grubu",    "kod",   "Grup"),
            new("kdv",     "h.kdv",      "sayi",  "KDV %",      Hizalama: "sag"),
            new("birim",   "h.birim",    "kod",   "Birim",      Hizalama: "orta"),
            new("muhKodu", "h.muh_kodu", "metin", "Muh. Kodu",  Varsayilan: false),
            new("durum",   "h.durum",    "kod",   "Durum",      Hizalama: "orta")
        });

    // ------------------------------------------------------------- masraf ----
    private static KaynakTanimi Masraf() => new(
        Ad: "masraf",
        YetkiKodu: "masraf",
        Kaynak: "public.masraf m",
        VarsayilanSirala: "m.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "m.id",       "sayi",  "Id",         Varsayilan: false),
            new("kod",     "m.kod",      "metin", "Kod"),
            new("ad",      "m.ad",       "metin", "Masraf Adi"),
            new("grubu",   "m.grubu",    "kod",   "Grup"),
            new("kdv",     "m.kdv",      "sayi",  "KDV %",      Hizalama: "sag"),
            new("birim",   "m.birim",    "kod",   "Birim",      Hizalama: "orta"),
            new("muhKodu", "m.muh_kodu", "metin", "Muh. Kodu",  Varsayilan: false),
            new("durum",   "m.durum",    "kod",   "Durum",      Hizalama: "orta")
        });

    // ------------------------------------------------------- mali hareket ----
    // Cari ekstresi / kasa-banka defteri. HAREKET kaynagi: sube filtresi uygulanir.
    private static KaynakTanimi MaliHareket() => new(
        Ad: "mali-hareket",
        YetkiKodu: "mali_hareket",
        Kaynak: "public.mali_hareket mh left join public.taraf t on t.id = mh.taraf_id",
        SubeKolonu: "mh.sube_id",
        KapsamKolonu: "mh.taraf_id",
        VarsayilanSirala: "mh.islem_tarihi desc, mh.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "mh.id",           "sayi",  "Id",       Varsayilan: false),
            new("islemTarihi", "mh.islem_tarihi", "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tur",         "mh.tur",          "kod",   "Tur",      Hizalama: "orta"),
            new("belgeNo",     "mh.belge_no",     "metin", "Belge No"),
            new("tarafUnvan",  "t.unvan",         "metin", "Cari"),
            new("aciklama",    "mh.aciklama",     "metin", "Aciklama"),
            new("borc",        "mh.borc",         "para",  "Borc",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("alacak",      "mh.alacak",       "para",  "Alacak",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",  "mh.doviz_cinsi",  "metin", "Doviz",    Hizalama: "orta", Varsayilan: false),
            new("dovizTutari", "mh.doviz_tutari", "para",  "Doviz Tutari", Hizalama: "sag", Varsayilan: false),
            new("dovizKuru",   "mh.doviz_kuru",   "para",  "Kur",      Hizalama: "sag", Varsayilan: false),
            new("subeId",      "mh.sube_id",      "sayi",  "Sube",     Varsayilan: false)
        });

    // ------------------------------------------------------------ e-belge ----
    private static KaynakTanimi EBelge() => new(
        Ad: "e-belge",
        YetkiKodu: "e_belge",
        Kaynak: "public.e_belge e left join public.taraf t on t.id = e.taraf_id",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.ekleme_tarihi desc, e.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",             "e.id",               "sayi",  "Id",        Varsayilan: false),
            new("eklemeTarihi",   "e.ekleme_tarihi",    "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("belgeTuru",      "e.belge_turu",       "kod",   "Belge Turu", Hizalama: "orta"),
            new("yon",            "e.yon",              "kod",   "Yon",       Hizalama: "orta"),
            new("belgeNo",        "e.belge_no",         "metin", "Belge No"),
            new("tarafUnvan",     "t.unvan",            "metin", "Cari"),
            new("gondericiVkno",  "e.gonderici_vkno",   "metin", "Gonderici VKN", Varsayilan: false),
            new("durum",          "e.durum",            "kod",   "Durum",     Hizalama: "orta"),
            new("gibDurumKodu",   "e.gib_durum_kodu",   "metin", "GIB Kodu",  Varsayilan: false),
            new("servisDurumAdi", "e.servis_durum_adi", "metin", "Servis Durumu"),
            new("uuid",           "e.uuid",             "metin", "UUID",      Varsayilan: false)
        });

    // ---------------------------------------------------------- islem log ----
    // UInfo karsiligi. islem_log tarihe gore BOLUMLENMIS: varsayilan siralama
    //   tarih desc oldugu icin son kayitlar ilk bolumden gelir.
    private static KaynakTanimi IslemLog() => new(
        Ad: "islem-log",
        YetkiKodu: "islem_log",
        Kaynak: "public.islem_log l left join public.taraf k on k.id = l.kullanici_id",
        VarsayilanSirala: "l.tarih desc, l.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "l.id",           "sayi",  "Id",        Varsayilan: false),
            new("tarih",      "l.tarih",        "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("kullanici",  "k.unvan",        "metin", "Kullanici"),
            new("islemTipi",  "l.islem_tipi",   "kod",   "Islem",     Hizalama: "orta"),
            new("tabloId",    "l.tablo_id",     "kod",   "Tablo",     Hizalama: "orta"),
            new("kayitId",    "l.kayit_id",     "sayi",  "Kayit",     Hizalama: "sag"),
            new("ustTabloId", "l.ust_tablo_id", "kod",   "Ust Tablo", Varsayilan: false),
            new("ustKayitId", "l.ust_kayit_id", "sayi",  "Ust Kayit", Varsayilan: false),
            new("ip",         "l.ip",           "metin", "IP",        Varsayilan: false),
            new("subeId",     "l.sube_id",      "sayi",  "Sube",      Varsayilan: false)
        });

    // ---------------------------------------------------------------- rol ----
    private static KaynakTanimi Rol() => new(
        Ad: "rol",
        YetkiKodu: "rol",
        Kaynak: "public.rol r",
        VarsayilanSirala: "r.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "r.id",           "sayi",  "Id",       Varsayilan: false),
            new("kod",        "r.kod",          "metin", "Kod"),
            new("ad",         "r.ad",           "metin", "Ad"),
            new("aktif",      "r.aktif",        "mantik","Aktif",    Hizalama: "orta"),
            new("sistem",     "r.sistem",       "mantik","Sistem",   Hizalama: "orta", Varsayilan: false)
        });

    // --------------------------------------------------------------- stok ----
    private static KaynakTanimi Stok() => new(
        Ad: "stok",
        YetkiKodu: "stok",
        Kaynak: "public.stok s",
        VarsayilanSirala: "s.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "s.id",        "sayi",  "Id",       Varsayilan: false),
            new("kod",       "s.kod",       "metin", "Kod"),
            new("ad",        "s.ad",        "metin", "Stok Adi"),
            new("kategori",  "s.kategori",  "kod",   "Kategori"),
            new("marka",     "s.marka",     "kod",   "Marka",    Varsayilan: false),
            new("model",     "s.model",     "metin", "Model",    Varsayilan: false),
            new("anaBirim",  "s.ana_birim", "kod",   "Birim",    Hizalama: "orta"),
            new("kdv",       "s.kdv",       "sayi",  "KDV %",    Hizalama: "sag"),
            new("minStok",   "s.min_stok",  "sayi",  "Min. Stok",Hizalama: "sag", Varsayilan: false),
            new("durum",     "s.durum",     "kod",   "Durum",    Hizalama: "orta"),
            new("urunNo",    "s.urun_no",   "metin", "Urun No",  Varsayilan: false),
            new("subeId",    "s.sube_id",   "sayi",  "Sube",     Varsayilan: false)
        });
}
