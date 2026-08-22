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
        Ekle(Hasta());
        Ekle(Hizmet());
        Ekle(Masraf());
        Ekle(MaliHareket());
        Ekle(EBelge());
        Ekle(IslemLog());
        Ekle(Rol());
        // Kasa alt sistemi (071-080)
        Ekle(Hesap());
        Ekle(CekSenet());
        Ekle(Proje());
        Ekle(MasrafMerkezi());
        Ekle(HesapPlani());
        Ekle(KasaIslemTuru());
        Ekle(HesapEkstre());
        Ekle(CariEkstre());
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

    private static KaynakTanimi Hasta()
    {
        var p = Personel();
        return p with
        {
            Ad = "hasta",
            // Ayrı hasta yetkisi seed edilmediği için aynı personel yetki yüzeyi kullanılır.
            YetkiKodu = "personel",
            SabitKosul = "t.grup = 101",
            Kolonlar = p.Kolonlar.Select(k => k.Ad switch
            {
                "kod" => k with { Baslik = "Dosya No" },
                _ => k
            }).ToArray()
        };
    }

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
    // BACAK listesi (kasa_islem basliginin altindaki tekil satirlar). 080 gocuyle
    //   "kur" ve "doviz_tutari" kolonlari DUSTU; yerine bacagin kendi dovizi
    //   (doviz_cinsi + borc/alacak) ve TL karsiligi (yerel_borc/yerel_alacak) geldi.
    private static KaynakTanimi MaliHareket() => new(
        Ad: "mali-hareket",
        YetkiKodu: "mali_hareket",
        Kaynak: """
            public.mali_hareket mh
            left join public.taraf t            on t.id  = mh.taraf_id
            left join public.hesap h            on h.id  = mh.hesap_id
            left join public.kasa_islem ki      on ki.id = mh.kasa_islem_id
            left join public.kasa_islem_turu kt on kt.kod = mh.tur
            left join public.masraf ma          on ma.id = mh.masraf_id
            left join public.hizmet hz          on hz.id = mh.hizmet_id
            left join public.proje p            on p.id  = coalesce(mh.proje_id, ki.proje_id)
            """,
        SubeKolonu: "mh.sube_id",
        KapsamKolonu: "mh.taraf_id",
        VarsayilanSirala: "mh.islem_tarihi desc, mh.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "mh.id",            "sayi",  "Id",       Varsayilan: false),
            new("islemTarihi",  "mh.islem_tarihi",  "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "kt.ad",            "metin", "Islem"),
            new("tur",          "mh.tur",           "kod",   "Tur Kodu", Hizalama: "orta", Varsayilan: false),
            new("hesapTuru",    "mh.hesap_turu",    "metin", "Hesap Turu", Hizalama: "orta", Varsayilan: false),
            new("hesapAdi",     "h.ad",             "metin", "Hesap"),
            new("makbuzNo",     "ki.islem_no",      "metin", "Makbuz No", Varsayilan: false),
            new("belgeNo",      "mh.belge_no",      "metin", "Belge No"),
            new("tarafUnvan",   "t.unvan",          "metin", "Cari",     Genislik: 200),
            new("aciklama",     "mh.aciklama",      "metin", "Aciklama", Genislik: 220),
            new("borc",         "mh.borc",          "para",  "Borc",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("alacak",       "mh.alacak",        "para",  "Alacak",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",   "mh.doviz_cinsi",   "metin", "Doviz",    Hizalama: "orta"),
            new("dovizKuru",    "mh.doviz_kuru",    "para",  "Kur",      Hizalama: "sag", Varsayilan: false),
            new("yerelBorc",    "mh.yerel_borc",    "para",  "TL Borc",  Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("yerelAlacak",  "mh.yerel_alacak",  "para",  "TL Alacak",Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("masrafAdi",    "ma.ad",            "metin", "Gider Kalemi", Varsayilan: false),
            new("hizmetAdi",    "hz.ad",            "metin", "Gelir Kalemi", Varsayilan: false),
            new("projeAdi",     "p.ad",             "metin", "Proje",    Varsayilan: false),
            new("kasaIslemId",  "mh.kasa_islem_id", "sayi",  "Islem Id", Varsayilan: false),
            new("subeId",       "mh.sube_id",       "sayi",  "Sube",     Varsayilan: false)
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
    //
    // islem_tipi ve tablo_id ham sayisal kodlar (Gentegre.Veri.Depolar.LogIslemi /
    //   KartTanimi.LogTabloId) - burada okunabilir metne cevriliyor ki UInfo gibi
    //   kullanici "2/71" degil "Degisiklik/Cari" gorsun.
    //
    // Kod/Ad (eski LOGCOZUM karsiligi): tablo_id'ye gore DOGRU tabloya (taraf/stok/
    //   belge/rol) LEFT JOIN ile kayit_id cozulur. Yalniz kart-seviyeli tablolar
    //   (71/73 taraf, 88 stok, 30 belge, 903 rol) cozulur - detay satirlari (adres,
    //   barkod, fiyat, izin, egitim... 340-907 arasi) icin Kod/Ad bos kalir; kayit
    //   silinmisse de (join eslesmez) bos kalir - "bilgi" JSON'daki anlik degerler
    //   burada kullanilmaz, cunku alan adlari tabloya gore degisir (tek SQL'de
    //   duzgun genellenemez).
    private static KaynakTanimi IslemLog() => new(
        Ad: "islem-log",
        YetkiKodu: "islem_log",
        Kaynak: """
            public.islem_log l
            left join public.taraf k on k.id = l.kullanici_id
            left join public.taraf kt on kt.id = l.kayit_id and l.tablo_id in (71, 73)
            left join public.taraf kut on kut.id = l.ust_kayit_id and l.ust_tablo_id in (71, 73)
            left join public.stok ks on ks.id = l.kayit_id and l.tablo_id = 88
            left join public.belge kb on kb.id = l.kayit_id and l.tablo_id = 30
            left join public.rol kr on kr.id = l.kayit_id and l.tablo_id = 903
            """,
        VarsayilanSirala: "l.tarih desc, l.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "l.id",                          "sayi",  "Id",        Varsayilan: false),
            new("tarih",      "(l.tarih + interval '3 hours')", "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("islemTipi",  IslemAdiIfade("l.islem_tipi"),   "metin", "İşlem",     Hizalama: "orta"),
            new("modul",      LogModulIfade(),                 "metin", "Modül",     Hizalama: "orta"),
            new("kod",        "case when l.ust_tablo_id in (71, 73) then kut.kod when l.tablo_id in (71, 73) then kt.kod when l.tablo_id = 88 then ks.kod when l.tablo_id = 30 then kb.belge_no when l.tablo_id = 903 then kr.kod end",
                                                                "metin", "Kod"),
            new("ad",         "case when l.ust_tablo_id in (71, 73) then kut.unvan when l.tablo_id in (71, 73) then kt.unvan when l.tablo_id = 88 then ks.ad when l.tablo_id = 30 then kb.taraf_unvan when l.tablo_id = 903 then kr.ad end",
                                                                "metin", "Ad"),
            new("kayitId",    "l.kayit_id",                    "sayi",  "Kayıt Id",  Hizalama: "sag"),
            new("kullanici",  "k.unvan",                       "metin", "Kullanıcı"),
            new("ip",         "l.ip",                          "metin", "IP"),
            new("ustTabloId", TabloAdiIfade("l.ust_tablo_id"), "metin", "Ust Tablo", Varsayilan: false),
            new("ustKayitId", "l.ust_kayit_id",                "sayi",  "Ust Kayit", Varsayilan: false),
            new("subeId",     "l.sube_id",                     "sayi",  "Sube",      Varsayilan: false),
            // Satir "Icerik" gorunumunde gosterilir (GenGrid icerikAlani) - grid kolonu
            //   olarak DEGIL, gizli veri olarak taşınır.
            new("bilgi",      "l.bilgi::text",                 "metin", "Icerik",    Varsayilan: false,
                                                                 Siralanabilir: false, Filtrelenebilir: false)
        });

    /// <summary>Gentegre.Veri.Depolar.LogIslemi (0 Sil / 1 Ekle / 2 Degistir) okunabilir metne.</summary>
    private static string IslemAdiIfade(string kolon) => $"""
        case {kolon}
            when 0 then 'Silme'
            when 1 then 'Ekleme'
            when 2 then 'Değişiklik'
            else {kolon}::text
        end
        """;

    /// <summary>
    /// LogTabloId (KartKatalogu'ndaki tablo kodlari) okunabilir ada. 71 hem cari hem
    /// kisi hem hasta icin ortak (ucu de ayni fiziksel taraf tablosu) - ayrim satirin
    /// kendisinden (taraf_id) yapilmaz, eski GENDEPO'daki ayni belirsizlik burada da var.
    /// </summary>
    private static string TabloAdiIfade(string kolon) => $"""
        case {kolon}
            when 0 then ''
            when 30 then 'Belge'
            when 71 then 'Cari/Kişi/Hasta'
            when 73 then 'Personel'
            when 88 then 'Stok'
            when 340 then 'Stok Barkod'
            when 346 then 'Stok Fiyat'
            when 901 then 'Adres'
            when 902 then 'Stok Seri/Lot'
            when 903 then 'Rol'
            when 904 then 'İzin'
            when 905 then 'Eğitim/Sertifika'
            when 906 then 'Acil Durum Kişi'
            when 907 then 'Hasta Bilgisi'
            else {kolon}::text
        end
        """;

    private static string LogModulIfade() => """
        case
            when l.ust_tablo_id = 73 then 'Personel'
            when l.ust_tablo_id = 71 then
                case
                    when kut.grup = 101 then 'Hasta'
                    when kut.kisi = 1 then 'Kişi'
                    when kut.musteri = 1 and kut.tedarikci = 1 then 'Müşteri/Tedarikçi'
                    when kut.tedarikci = 1 then 'Tedarikçi'
                    when kut.musteri = 1 then 'Müşteri'
                    else 'Cari'
                end
            when l.tablo_id = 73 then 'Personel'
            when l.tablo_id = 71 then
                case
                    when kt.grup = 101 then 'Hasta'
                    when kt.kisi = 1 then 'Kişi'
                    when kt.musteri = 1 and kt.tedarikci = 1 then 'Müşteri/Tedarikçi'
                    when kt.tedarikci = 1 then 'Tedarikçi'
                    when kt.musteri = 1 then 'Müşteri'
                    else 'Cari'
                end
            when l.tablo_id = 30 then 'Belge'
            when l.tablo_id = 88 then 'Stok'
            when l.tablo_id = 903 then 'Rol'
            else ''
        end
        """;

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

    // ============================================================ KASA ====

    // --------------------------------------------------------------- hesap ----
    // Kasa / banka / POS / kredi karti / kredi tek tabloda (K1). Ayni kaynak
    //   web'de 4 ayri ekran olarak kullanilir: sabitFiltre tur='K'/'B'/'P'/'V'
    //   (Musteri/Tedarikci deseni). Bakiye v_hesap_bakiye'den okunur.
    private static KaynakTanimi Hesap() => new(
        Ad: "hesap",
        YetkiKodu: "hesap",
        Kaynak: """
            public.hesap h
            left join public.v_hesap_bakiye b on b.hesap_id = h.id
            left join public.hesap bh on bh.id = h.bagli_hesap_id
            """,
        SubeKolonu: "h.sube_id",
        VarsayilanSirala: "h.tur asc, h.kod asc, h.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "h.id",            "sayi",  "Id",   Varsayilan: false),
            new("tur",         "h.tur",           "metin", "Tur",  Hizalama: "orta"),
            new("kod",         "h.kod",           "metin", "Kod"),
            new("ad",          "h.ad",            "metin", "Hesap Adi", Genislik: 220),
            new("dovizCinsi",  "h.doviz_cinsi",   "metin", "Doviz", Hizalama: "orta"),
            new("bakiye",      "coalesce(b.bakiye, 0)",       "para", "Bakiye",     Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("yerelBakiye", "coalesce(b.yerel_bakiye, 0)", "para", "TL Bakiye",  Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("bankaAdi",    "h.banka_adi",     "metin", "Banka",   Varsayilan: false),
            new("iban",        "h.iban",          "metin", "IBAN",    Varsayilan: false),
            new("hesapNo",     "h.hesap_no",      "metin", "Hesap No", Varsayilan: false),
            new("bagliHesap",  "bh.ad",           "metin", "Bagli Hesap", Varsayilan: false),
            new("durum",       "h.durum",         "kod",   "Durum",   Hizalama: "orta"),
            new("subeId",      "h.sube_id",       "sayi",  "Sube",    Varsayilan: false)
        });

    // ----------------------------------------------------------- cek/senet ----
    private static KaynakTanimi CekSenet() => new(
        Ad: "cek-senet",
        YetkiKodu: "cek_senet",
        Kaynak: """
            public.cek_senet c
            left join public.taraf t on t.id = c.taraf_id
            left join public.hesap h on h.id = c.hesap_id
            """,
        SubeKolonu: "c.sube_id",
        KapsamKolonu: "c.taraf_id",
        VarsayilanSirala: "c.vade asc, c.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "c.id",           "sayi",  "Id",     Varsayilan: false),
            new("tur",         "c.tur",          "kod",   "Tur",    Hizalama: "orta"),
            new("yon",         "c.yon",          "kod",   "Yon",    Hizalama: "orta"),
            new("seriNo",      "c.seri_no",      "metin", "Seri No"),
            new("tarafUnvan",  "t.unvan",        "metin", "Cari",   Genislik: 200),
            new("kesideci",    "c.kesideci",     "metin", "Kesideci", Varsayilan: false),
            new("tarih",       "c.tarih",        "tarih", "Tarih",  Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("vade",        "c.vade",         "tarih", "Vade",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tutar",       "c.tutar",        "para",  "Tutar",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",  "c.doviz_cinsi",  "metin", "Doviz",  Hizalama: "orta"),
            new("yerelTutar",  "c.yerel_tutar",  "para",  "TL Tutar", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("bankaAdi",    "c.banka_adi",    "metin", "Banka",  Varsayilan: false),
            new("hesapAdi",    "h.ad",           "metin", "Bulundugu Hesap", Varsayilan: false),
            new("durum",       "c.durum",        "kod",   "Durum",  Hizalama: "orta"),
            new("subeId",      "c.sube_id",      "sayi",  "Sube",   Varsayilan: false)
        });

    // --------------------------------------------------------------- proje ----
    private static KaynakTanimi Proje() => new(
        Ad: "proje",
        YetkiKodu: "proje",
        Kaynak: """
            public.proje p
            left join public.taraf t  on t.id = p.taraf_id
            left join public.taraf so on so.id = p.sorumlu_id
            """,
        VarsayilanSirala: "p.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "p.id",          "sayi",  "Id",   Varsayilan: false),
            new("kod",        "p.kod",         "metin", "Kod"),
            new("ad",         "p.ad",          "metin", "Proje Adi", Genislik: 240),
            new("tarafUnvan", "t.unvan",       "metin", "Musteri",   Genislik: 200),
            new("sorumlu",    "so.unvan",      "metin", "Sorumlu",   Varsayilan: false),
            new("baslangic",  "p.baslangic",   "tarih", "Baslangic", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("bitis",      "p.bitis",       "tarih", "Bitis",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("butceTutar", "p.butce_tutar", "para",  "Butce",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("butceDovizi","p.butce_dovizi","metin", "Doviz",     Hizalama: "orta", Varsayilan: false),
            new("durum",      "p.durum",       "kod",   "Durum",     Hizalama: "orta")
        });

    // ------------------------------------------------------ masraf merkezi ----
    private static KaynakTanimi MasrafMerkezi() => new(
        Ad: "masraf-merkezi",
        YetkiKodu: "masraf_merkezi",
        Kaynak: "public.masraf_merkezi m left join public.masraf_merkezi u on u.id = m.ust_id",
        VarsayilanSirala: "m.kod asc, m.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "m.id",    "sayi",  "Id",  Varsayilan: false),
            new("kod",    "m.kod",   "metin", "Kod"),
            new("ad",     "m.ad",    "metin", "Merkez Adi", Genislik: 240),
            new("ustAd",  "u.ad",    "metin", "Ust Merkez", Varsayilan: false),
            new("durum",  "m.durum", "kod",   "Durum", Hizalama: "orta")
        });

    // ---------------------------------------------------------- hesap plani ----
    private static KaynakTanimi HesapPlani() => new(
        Ad: "hesap-plani",
        YetkiKodu: "hesap_plani",
        Kaynak: "public.hesap_plani hp",
        VarsayilanSirala: "hp.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "hp.id",             "sayi",  "Id",  Varsayilan: false),
            new("kod",          "hp.kod",            "metin", "Hesap Kodu"),
            new("ad",           "hp.ad",             "metin", "Hesap Adi", Genislik: 280),
            new("sinif",        "hp.sinif",          "kod",   "Sinif",  Hizalama: "orta"),
            new("seviye",       "hp.seviye",         "sayi",  "Seviye", Hizalama: "orta", Varsayilan: false),
            new("calisirMi",    "hp.calisir_mi",     "mantik","Calisir", Hizalama: "orta"),
            new("cariAltHesap", "hp.cari_alt_hesap", "mantik","Cari Alt Hesap", Hizalama: "orta", Varsayilan: false),
            new("dovizCinsi",   "hp.doviz_cinsi",    "metin", "Doviz", Hizalama: "orta", Varsayilan: false),
            new("durum",        "hp.durum",          "kod",   "Durum", Hizalama: "orta")
        });

    // ------------------------------------------------------- islem turu ----
    private static KaynakTanimi KasaIslemTuru() => new(
        Ad: "kasa-islem-turu",
        YetkiKodu: "kasa_islem_turu",
        Kaynak: "public.kasa_islem_turu t",
        VarsayilanSirala: "t.sira asc, t.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("kod",         "t.kod",          "sayi",  "Kod",  Hizalama: "sag"),
            new("ad",          "t.ad",           "metin", "Islem Turu", Genislik: 220),
            new("grup",        "t.grup",         "metin", "Grup", Hizalama: "orta"),
            new("yon",         "t.yon",          "sayi",  "Yon",  Hizalama: "orta", Varsayilan: false),
            new("cariEkstre",  "t.cari_ekstre",  "mantik","Cari Ekstre",  Hizalama: "orta"),
            new("hesapEkstre", "t.hesap_ekstre", "mantik","Hesap Ekstre", Hizalama: "orta", Varsayilan: false),
            new("bakiyeDahil", "t.bakiye_dahil", "mantik","Bakiyeye Dahil", Hizalama: "orta"),
            new("fisMi",       "t.fis_mi",       "mantik","Fis Uretir", Hizalama: "orta"),
            new("makbuzSeri",  "t.makbuz_seri",  "metin", "Seri", Hizalama: "orta", Varsayilan: false),
            new("aktif",       "t.aktif",        "mantik","Aktif", Hizalama: "orta")
        });

    // ---------------------------------------------------------- ekstreler ----
    // Yuruyen bakiye SIRAYA bagli oldugu icin bakiye kolonu siralanamaz -
    //   kullanici siralamayi degistirse "bakiye" anlamsizlasirdi.
    private static KaynakTanimi HesapEkstre() => new(
        Ad: "hesap-ekstre",
        YetkiKodu: "hesap",
        Kaynak: "public.v_hesap_ekstre e",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.islem_tarihi asc, e.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",            "sayi",  "Id", Varsayilan: false),
            new("hesapId",      "e.hesap_id",      "sayi",  "Hesap Id", Varsayilan: false),
            new("hesapAdi",     "e.hesap_adi",     "metin", "Hesap", Varsayilan: false),
            new("islemTarihi",  "e.islem_tarihi",  "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "e.tur_adi",       "metin", "Islem"),
            new("islemNo",      "e.islem_no",      "metin", "Makbuz No"),
            new("belgeNo",      "e.belge_no",      "metin", "Belge No", Varsayilan: false),
            new("tarafUnvan",   "e.taraf_unvan",   "metin", "Cari", Genislik: 200),
            new("aciklama",     "e.aciklama",      "metin", "Aciklama", Genislik: 220),
            new("giris",        "e.giris",         "para",  "Giris",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("cikis",        "e.cikis",         "para",  "Cikis",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("bakiye",       "e.bakiye",        "para",  "Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("dovizCinsi",   "e.doviz_cinsi",   "metin", "Doviz",  Hizalama: "orta", Varsayilan: false),
            new("yerelBakiye",  "e.yerel_bakiye",  "para",  "TL Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false),
            new("subeId",       "e.sube_id",       "sayi",  "Sube",   Varsayilan: false)
        });

    private static KaynakTanimi CariEkstre() => new(
        Ad: "cari-ekstre",
        YetkiKodu: "mali_hareket",
        Kaynak: "public.v_cari_ekstre e",
        SubeKolonu: "e.sube_id",
        KapsamKolonu: "e.taraf_id",
        VarsayilanSirala: "e.islem_tarihi asc, e.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",           "sayi",  "Id", Varsayilan: false),
            new("tarafId",      "e.taraf_id",     "sayi",  "Cari Id", Varsayilan: false),
            new("tarafUnvan",   "e.taraf_unvan",  "metin", "Cari", Genislik: 220),
            new("islemTarihi",  "e.islem_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "e.tur_adi",      "metin", "Islem"),
            new("islemNo",      "e.islem_no",     "metin", "Makbuz No", Varsayilan: false),
            new("belgeNo",      "e.belge_no",     "metin", "Belge No"),
            new("aciklama",     "e.aciklama",     "metin", "Aciklama", Genislik: 220),
            new("yerelBorc",    "e.yerel_borc",   "para",  "Borc",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelAlacak",  "e.yerel_alacak", "para",  "Alacak", Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelBakiye",  "e.yerel_bakiye", "para",  "Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("dovizCinsi",   "e.doviz_cinsi",  "metin", "Doviz",  Hizalama: "orta", Varsayilan: false),
            new("borc",         "e.borc",         "para",  "Doviz Borc",   Hizalama: "sag", Varsayilan: false),
            new("alacak",       "e.alacak",       "para",  "Doviz Alacak", Hizalama: "sag", Varsayilan: false),
            new("planTarihi",   "e.plan_tarihi",  "tarih", "Vade", Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("subeId",       "e.sube_id",      "sayi",  "Sube", Varsayilan: false)
        });
}
