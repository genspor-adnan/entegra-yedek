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
    int? Genislik = null,      // px - varsayilan (icerige gore) genislik gridde tasarsa (or. uzun metin)
    // GRUPLU listede yalniz GRUP icinde toplanabilen kolon (ekstrede doviz
    //   tutarlari): USD borcuyla TL borcunu toplamak anlamsizdir, o yuzden bu
    //   kolonlar grup ara toplaminda VAR, en alttaki genel toplamda YOK.
    bool SadeceGrupToplami = false,
    // Grubun KAPANIS degeri: toplanmaz, grubun SON satirindaki deger alinir
    //   (yuruyen bakiye boyledir - toplami degil son degeri anlamlidir).
    bool GrupKapanisi = false
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
    string? KapsamKolonu = null,   // kullanici_kapsam (tur=1) suzmesi icin taraf id kolonu
    // GRUPLU LISTE (ekstreler): satirlar bu kolonun degerine gore obeklenir, her
    //   obegin sonuna ARA TOPLAM satiri gelir (or. "dovizCinsi": once TL
    //   hareketleri ve toplami, sonra USD...). Grup toplamlari sunucuda, butun
    //   suzulmus kume uzerinde hesaplanir - sayfa basina degil.
    string? GrupKolonu = null,
    // Gruplarin SIRASI bu kolona gore (or. "dovizSira": yerel para 0, digerleri 1).
    //   Verilmezse grup kolonunun kendisi kullanilir.
    string? GrupSiraKolonu = null
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
        Ekle(Gorev());
        Ekle(BankaListesi());
        Ekle(MasrafMerkezi());
        Ekle(HesapPlani());
        Ekle(KasaIslemTuru());
        Ekle(Firsat());
        Ekle(HesapEkstre());
        Ekle(CariEkstre());
        // Kasa motoru (076, F2)
        Ekle(KasaIslem());
        Ekle(MuhasebeFis());
        Ekle(MuhasebeFisSatir());
        Ekle(PlanVade());
        // Belge donusumu (F8)
        Ekle(BelgeAcikSatir());
        Ekle(Depo());
        Ekle(Irsaliye());
        Ekle(StokTransfer());
        Ekle(StokTalep());
        Ekle(StokFisi(3));
        Ekle(StokFisi(4));
    }

    private static void Ekle(KaynakTanimi k) => Kaynaklar[k.Ad] = k;

    // --------------------------------------------------------------- cari ----
    private static KaynakTanimi Cari() => new(
        Ad: "cari",
        YetkiKodu: "cari",
        Kaynak: "public.taraf t",
        SabitKosul: "(t.musteri = 1 or t.tedarikci = 1 or t.aday = 1)",
        VarsayilanSirala: "t.unvan asc",
        KapsamKolonu: "t.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "t.id",            "sayi",  "Id",            Varsayilan: false),
            // Kod dar: cari kodlari "329.01.417" gibi kisa, kolon bosuna
            //   genisleyip unvani sikistiriyordu.
            new("kod",          "t.kod",           "metin", "Kod", Genislik: 110),
            new("unvan",        "t.unvan",         "metin", "Unvan"),
            new("faturaUnvan",  "t.fatura_unvan",  "metin", "Fatura Unvani", Varsayilan: false),
            new("vkno",         "t.vkno",          "metin", "VKN/TCKN"),
            new("vd",           "t.vd",            "metin", "Vergi Dairesi", Varsayilan: false),
            new("telefon",      "t.telefon",       "metin", "Telefon"),
            new("cepTel",       "t.cep_tel",       "metin", "Cep",           Varsayilan: false),
            new("eposta",       "t.eposta",        "metin", "E-posta"),
            new("adres",        "(select ta.adres from public.taraf_adres ta where ta.taraf_id = t.id and ta.varsayilan = 1 limit 1)",
                                                    "metin", "Adres"),
            // Ilce/il adresle AYNI kaynaktan (varsayilan adres satiri) - adresin
            //   sagina konur; ayri bir adres tablosu join'i gerektirmez.
            new("ilce",         "(select ta.ilce from public.taraf_adres ta where ta.taraf_id = t.id and ta.varsayilan = 1 limit 1)",
                                                    "metin", "İlçe"),
            new("il",           "(select ta.il from public.taraf_adres ta where ta.taraf_id = t.id and ta.varsayilan = 1 limit 1)",
                                                    "metin", "İl"),
            new("musteri",      "t.musteri",       "mantik","Musteri",       Hizalama: "orta"),
            new("aday",         "t.aday",          "mantik","Aday",          Hizalama: "orta", Varsayilan: false),
            new("tedarikci",    "t.tedarikci",     "mantik","Tedarikci",     Hizalama: "orta"),
            new("grup",         "t.grup",          "kod",   "Grup",          Varsayilan: false),
            // Kategori ve temsilci ADIYLA gosterilir: kolonlar "kod" tipindeydi
            //   ama listede kod ad'a cevrilmiyor, ekranda ham "1" / "2"
            //   goruluyordu. Deger yine id, gosterim ad.
            new("kategori",     "(select k.ad from public.kategori k where k.id = t.kategori)",
                                                    "metin", "Kategori",      Varsayilan: false),
            new("temsilci",     "(select p.unvan from public.taraf p where p.id = t.temsilci)",
                                                    "metin", "Temsilci",      Varsayilan: false),
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
        Kaynak: "public.belge b " +
                "left join public.kasa_islem_turu bt on bt.kod = b.tur " +
                // F8 donusum zinciri: kaynak baslik bagindan okunur.
                "left join public.belge kb on kb.id = b.kaynak_id and b.kaynak_tur = 30 " +
                "left join public.kasa_islem_turu kt2 on kt2.kod = kb.tur",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        KapsamKolonu: "b.taraf_id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id",          Varsayilan: false),
            new("tur",           "b.tur",            "kod",   "Tur",         Hizalama: "orta"),
            new("turAdi",        "bt.ad",            "metin", "Belge Türü"),
            // F8: siparis/irsaliye ne kadari donusturuldu (0 acik / 1 kismi / 2 kapandi)
            new("kapanmaDurum",  "b.kapanma_durum",  "kod",   "Kapanma",     Hizalama: "orta", Varsayilan: false),
            new("tipi",          "b.tipi",           "kod",   "Tipi",        Hizalama: "orta", Varsayilan: false),
            new("belgeSeri",     "b.belge_seri",     "metin", "Seri",        Varsayilan: false),
            new("belgeNo",       "b.belge_no",       "metin", "Belge No"),
            new("belgeTarihi",   "b.belge_tarihi",   "tarih", "Tarih",       Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tarafId",       "b.taraf_id",       "sayi",  "Cari Id",     Varsayilan: false),
            new("tarafUnvan",    "b.taraf_unvan",    "metin", "Cari"),
            // KAYNAK / HEDEF: donusum zincirinin iki ucu (irsaliye listesindeki
            //   ile ayni). Kaynak baslik bagindan; hedef SATIR bagindan turer -
            //   bir belge birden fazla belgeye bolunebilir, numaralar birlestirilir.
            //   Iptal (durum=2) hedefler sayilmaz.
            new("kaynak",
                "case when kb.id is null then '' " +
                "else coalesce(kt2.ad, '') || case when kb.belge_no <> '' " +
                "then ' ' || kb.belge_no else '' end end",
                                                      "metin", "Kaynak",      Genislik: 170,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("hedef",
                "coalesce((select string_agg(distinct coalesce(ht.ad, '') || ' ' || hb.belge_no, ', ') " +
                "            from public.belge_satir hs " +
                "            join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30 " +
                "            join public.belge hb on hb.id = hs.belge_id " +
                "            left join public.kasa_islem_turu ht on ht.kod = hb.tur " +
                "           where ks.belge_id = b.id and hb.durum <> 2), '')",
                                                      "metin", "Hedef",       Genislik: 190,
                                                      Siralanabilir: false, Filtrelenebilir: false),
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
            // Hizmette satis/alis ayrimi yok - tek fiyat listesi.
            new("fiyat",
                "(select f.fiyat from public.hizmet_fiyat f " +
                " where f.hizmet_id = h.id and f.fiyat > 0 order by f.fiyat_adi limit 1)",
                                            "para",  "Fiyat",      Hizalama: "sag", Bicim: "#,##0.00",
                                            Siralanabilir: false, Filtrelenebilir: false),
            // ISO'ya cevrilir: fiyat tablolarinda kod SEMBOL olabiliyor ('$', '€'),
            //   doviz_kur ise ISO tutuyor - kalem penceresi kuru bu kodla ariyor.
            new("fiyatDovizi",
                "public.fn_doviz_iso((select f.doviz_cinsi from public.hizmet_fiyat f " +
                " where f.hizmet_id = h.id and f.fiyat > 0 order by f.fiyat_adi limit 1))",
                                            "metin", "Döviz",      Hizalama: "orta",
                                            Siralanabilir: false, Filtrelenebilir: false),
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
            // Kategori ve birim ADIYLA gosterilir: kolonlar "kod" tipindeydi ve
            //   listede kod ad'a cevrilmedigi icin ekranda ham id goruluyordu.
            new("kategori",  "(select k.ad from public.kategori k where k.id = s.kategori)",
                                            "metin", "Kategori"),
            new("marka",     "s.marka",     "kod",   "Marka",    Varsayilan: false),
            new("model",     "s.model",     "metin", "Model",    Varsayilan: false),
            new("kdv",       "s.kdv",       "sayi",  "KDV %",    Hizalama: "sag"),
            // Kalem arama penceresi icin: VARSAYILAN depodaki kalan ve izleme
            //   turu. Kullanici "elimde var mi, seri/lot girmem gerekecek mi"
            //   sorusunu stok secerken gormeli - sonradan degil.
            new("kalan",
                "(select coalesce(sum(sd.kalan), 0) from public.stok_durum sd " +
                " join public.depo d on d.id = sd.depo_id " +
                " where sd.stok_id = s.id and d.varsayilan = 1)",
                                            "para",  "Kalan",    Hizalama: "sag", Bicim: "#,##0.##",
                                            Siralanabilir: false, Filtrelenebilir: false),
            // BIRIM, Kalan'in SAGINDA (kullanici): miktar ve birimi yan yana
            //   okumak dogal - "78 Adet".
            new("anaBirim",
                "(select kd.ad from public.kod_deger kd" +
                "   join public.kod_liste kl on kl.id = kd.liste_id" +
                "  where kl.kod = 'stok.ana_birim' and kd.deger = s.ana_birim)",
                                            "metin", "Birim",    Hizalama: "orta"),
            // Birim KODU (gizli): secim pencerelerinden gelen satirda birimi
            //   yazabilmek icin gerekli - ad ile kod eslestirmek kirilgan olurdu.
            new("anaBirimKod","s.ana_birim","sayi",  "Birim Kodu", Hizalama: "orta", Varsayilan: false),
            new("izlemeAdi",
                "case s.izleme when 1 then 'Seri No' when 2 then 'Lot No' when 3 then 'SKT' " +
                "when 4 then 'Karekod' when 5 then 'Lot No + SKT' when 6 then 'Seri + Lot' else 'Yok' end",
                                            "metin", "İzleme",   Hizalama: "orta"),
            new("izleme",    "s.izleme",    "sayi",  "İzleme Kodu", Hizalama: "orta", Varsayilan: false),
            // PAKET (124): belge kalemi secimde bunu okur ve paketi ICERIGIYLE
            //   birlikte ekler.
            new("paket",     "s.paket",     "mantik","Paket",     Hizalama: "orta", Varsayilan: false),
            // Fiyat: stok_fiyat'ta satis/alis AYRI kayittir ve -1 "fiyat girilmemis"
            //   demektir; en dusuk fiyat_adi (ana liste) alinir.
            new("fiyat",
                "(select f.fiyat from public.stok_fiyat f " +
                " where f.stok_id = s.id and f.satis = 1 and f.fiyat > 0 " +
                " order by f.fiyat_adi limit 1)",
                                            "para",  "Fiyat",    Hizalama: "sag", Bicim: "#,##0.00",
                                            Siralanabilir: false, Filtrelenebilir: false),
            new("fiyatDovizi",
                "public.fn_doviz_iso((select f.doviz_cinsi from public.stok_fiyat f " +
                " where f.stok_id = s.id and f.satis = 1 and f.fiyat > 0 " +
                " order by f.fiyat_adi limit 1))",
                                            "metin", "Döviz",    Hizalama: "orta",
                                            Siralanabilir: false, Filtrelenebilir: false),
            new("alisFiyat",
                "(select f.fiyat from public.stok_fiyat f " +
                " where f.stok_id = s.id and f.satis = 0 and f.fiyat > 0 " +
                " order by f.fiyat_adi limit 1)",
                                            "para",  "Alış Fiyatı", Hizalama: "sag", Bicim: "#,##0.00",
                                            Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false),
            new("alisDovizi",
                "(select f.doviz_cinsi from public.stok_fiyat f " +
                " where f.stok_id = s.id and f.satis = 0 and f.fiyat > 0 " +
                " order by f.fiyat_adi limit 1)",
                                            "metin", "Alış Dövizi", Hizalama: "orta",
                                            Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false),
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
            // Tur kolonu GIZLI: her hesap ekrani (Kasa/Banka/POS/Kredi Karti/Kredi)
            //   zaten TEK turu gosteriyor, her satirda ayni harf tekrarliyordu.
            new("tur",         "h.tur",           "metin", "Tur",  Hizalama: "orta", Varsayilan: false),
            new("kod",         "h.kod",           "metin", "Kod"),
            new("ad",          "h.ad",            "metin", "Hesap Adi", Genislik: 220),
            new("dovizCinsi",  "h.doviz_cinsi",   "metin", "Doviz", Hizalama: "orta"),
            new("bakiye",      "coalesce(b.bakiye, 0)",       "para", "Bakiye",     Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("yerelBakiye", "coalesce(b.yerel_bakiye, 0)", "para", "TL Bakiye",  Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false),
            new("bankaAdi",    "h.banka_adi",     "metin", "Banka",   Varsayilan: false),
            new("iban",        "h.iban",          "metin", "IBAN",    Varsayilan: false),
            new("hesapNo",     "h.hesap_no",      "metin", "Hesap No", Varsayilan: false),
            new("bagliHesap",  "bh.ad",           "metin", "Bagli Hesap", Varsayilan: false),
            // Durum METIN olarak: liste katmani kod listesi cozmuyordu, gridde
            //   ham 0/1 gorunuyordu. Metin gelince GenGrid yesil/kirmizi rozet basar.
            new("durumAdi",    "case h.durum when 1 then 'Aktif' else 'Pasif' end",
                                                  "metin", "Durum",   Hizalama: "orta",
                                                  Genislik: 90, Filtrelenebilir: false),
            new("durum",       "h.durum",         "kod",   "Durum Kodu", Hizalama: "orta",
                                                  Varsayilan: false),
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

    // ------------------------------------------------------------- firsat ----
    // CRM satis firsati listesi (121, mockup firsat_listesi.html). AGIRLIKLI
    //   tutar gorunumde hesaplanir (tutar x olasilik) - saklanan bir kolon
    //   olsaydi olasilik degisince bayatlardi.
    private static KaynakTanimi Firsat() => new(
        Ad: "firsat",
        YetkiKodu: "firsat",
        Kaynak: "public.v_firsat_liste f",
        SubeKolonu: "f.sube_id",
        KapsamKolonu: "f.taraf_id",
        VarsayilanSirala: "f.beklenen_kapanis asc nulls last, f.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",              "f.id",               "sayi",  "Id", Varsayilan: false),
            new("oncelik",         "f.oncelik",          "kod",   "Önc.", Hizalama: "orta"),
            new("firsatNo",        "f.firsat_no",        "metin", "Fırsat No", Genislik: 130),
            new("konu",            "f.konu",             "metin", "Fırsat Adı", Genislik: 260),
            new("tarafId",         "f.taraf_id",         "sayi",  "Cari Id", Varsayilan: false),
            new("tarafUnvan",      "f.taraf_unvan",      "metin", "Müşteri / Aday", Genislik: 220),
            new("sektor",          "f.sektor",           "metin", "Sektör", Varsayilan: false),
            new("kaynak",          "f.kaynak",           "kod",   "Kaynak", Varsayilan: false),
            new("sorumluAdi",      "f.sorumlu_adi",      "metin", "Temsilci", Genislik: 160),
            new("asama",           "f.asama",            "kod",   "Aşama", Hizalama: "orta"),
            new("olasilik",        "f.olasilik",         "sayi",  "Olasılık %", Hizalama: "sag"),
            new("tahminiTutar",    "f.tahmini_tutar",    "para",  "Tahmini Tutar", Hizalama: "sag", Bicim: "#,##0.00"),
            new("agirlikliTutar",  "f.agirlikli_tutar",  "para",  "Ağırlıklı", Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",      "f.doviz_cinsi",      "metin", "PB", Hizalama: "orta"),
            new("sonTemas",        "f.son_temas",        "tarih", "Son Temas", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("sonrakiAksiyon",  "f.sonraki_aksiyon",  "metin", "Sonraki Aksiyon", Genislik: 200),
            new("beklenenKapanis", "f.beklenen_kapanis", "tarih", "Tah. Kapanış", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("durum",           "f.durum",            "kod",   "Durum", Hizalama: "orta"),
            new("subeId",          "f.sube_id",          "sayi",  "Sube", Varsayilan: false)
        });

    // ---------------------------------------------------------- ekstreler ----
    // Yuruyen bakiye SIRAYA bagli oldugu icin bakiye kolonu siralanamaz -
    //   kullanici siralamayi degistirse "bakiye" anlamsizlasirdi.
    //
    // EKSTRELER PARA BIRIMI BAZINDA GRUPLU (111): once yerel para (TL)
    //   hareketleri ve ara toplami, sonra USD, sonra EUR... en altta yerel para
    //   cinsinden genel toplam. Farkli para birimlerini tek yuruyen bakiyede
    //   toplamak (eski hali) anlamsiz bir sayi uretiyordu.
    private static KaynakTanimi HesapEkstre() => new(
        Ad: "hesap-ekstre",
        YetkiKodu: "hesap",
        Kaynak: "public.v_hesap_ekstre e",
        SubeKolonu: "e.sube_id",
        GrupKolonu: "dovizCinsi",
        GrupSiraKolonu: "dovizSira",
        VarsayilanSirala: "e.doviz_sira asc, e.doviz_cinsi asc, e.islem_tarihi asc, e.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",            "sayi",  "Id", Varsayilan: false),
            new("hesapId",      "e.hesap_id",      "sayi",  "Hesap Id", Varsayilan: false),
            // Cift tik hedefi (gizli): satiri ureten kasa islemi / belge.
            new("kasaIslemId",  "e.kasa_islem_id", "sayi",  "Kasa Islem Id", Varsayilan: false),
            new("belgeId",      "e.belge_id",      "sayi",  "Belge Id", Varsayilan: false),
            new("hesapAdi",     "e.hesap_adi",     "metin", "Hesap", Varsayilan: false),
            new("islemTarihi",  "e.islem_tarihi",  "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "e.tur_adi",       "metin", "Islem"),
            new("islemNo",      "e.islem_no",      "metin", "Makbuz No"),
            new("belgeNo",      "e.belge_no",      "metin", "Belge No", Varsayilan: false),
            new("tarafUnvan",   "e.taraf_unvan",   "metin", "Cari", Genislik: 200),
            new("aciklama",     "e.aciklama",      "metin", "Aciklama", Genislik: 220),
            // Doviz tutarlari GRUP ICINDE toplanir; en alttaki genel toplamda yer
            //   almazlar (USD giris ile TL girisi toplamak anlamsiz).
            new("giris",        "e.giris",         "para",  "Giris",  Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            new("cikis",        "e.cikis",         "para",  "Cikis",  Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            // Bakiye TOPLANMAZ: grubun son satirindaki deger o para biriminin
            //   kapanis bakiyesidir.
            new("bakiye",       "e.bakiye",        "para",  "Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, SadeceGrupToplami: true, GrupKapanisi: true),
            // Para birimi grup basliginda yaziyor; kolon olarak da acilabilir.
            new("dovizCinsi",   "e.doviz_cinsi",   "metin", "Doviz",  Hizalama: "orta", Varsayilan: false),
            new("dovizSira",    "e.doviz_sira",    "sayi",  "Doviz Sira", Varsayilan: false),
            new("dovizKuru",    "e.doviz_kuru",    "para",  "Kur",    Hizalama: "sag", Bicim: "#,##0.0000", Varsayilan: false),
            // Yerel karsiliklar GORUNUR: gruplu ekstrede genel toplam ancak yerel
            //   parada anlamli, gizli kolonun toplami da kullaniciya ulasmaz.
            new("yerelBorc",    "e.yerel_borc",    "para",  "Yerel Giris",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelAlacak",  "e.yerel_alacak",  "para",  "Yerel Cikis",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelBakiye",  "e.yerel_bakiye",  "para",  "Yerel Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false, SadeceGrupToplami: true, GrupKapanisi: true),
            new("subeId",       "e.sube_id",       "sayi",  "Sube",   Varsayilan: false)
        });

    private static KaynakTanimi CariEkstre() => new(
        Ad: "cari-ekstre",
        YetkiKodu: "mali_hareket",
        Kaynak: "public.v_cari_ekstre e",
        SubeKolonu: "e.sube_id",
        KapsamKolonu: "e.taraf_id",
        GrupKolonu: "dovizCinsi",
        GrupSiraKolonu: "dovizSira",
        VarsayilanSirala: "e.doviz_sira asc, e.doviz_cinsi asc, e.islem_tarihi asc, e.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",           "sayi",  "Id", Varsayilan: false),
            new("tarafId",      "e.taraf_id",     "sayi",  "Cari Id", Varsayilan: false),
            // Cift tik hedefi (gizli): satiri ureten kasa islemi / belge.
            new("kasaIslemId",  "e.kasa_islem_id","sayi",  "Kasa Islem Id", Varsayilan: false),
            new("belgeId",      "e.belge_id",     "sayi",  "Belge Id", Varsayilan: false),
            new("tarafUnvan",   "e.taraf_unvan",  "metin", "Cari", Genislik: 220),
            new("islemTarihi",  "e.islem_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",       "e.tur_adi",      "metin", "Islem"),
            new("islemNo",      "e.islem_no",     "metin", "Makbuz No", Varsayilan: false),
            new("belgeNo",      "e.belge_no",     "metin", "Belge No"),
            new("aciklama",     "e.aciklama",     "metin", "Aciklama", Genislik: 220),
            // GRUP para biriminde: satirin kendi biriminde borc/alacak/bakiye.
            //   Grup basligi hangi birim oldugunu soyler, kolon basliginda tekrar
            //   edilmez ("Doviz Borc" gibi bir baslik gruplu ekranda gereksiz).
            new("borc",         "e.borc",         "para",  "Borc",   Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            new("alacak",       "e.alacak",       "para",  "Alacak", Hizalama: "sag", Bicim: "#,##0.00", SadeceGrupToplami: true),
            new("dovizKuru",    "e.doviz_kuru",   "para",  "Kur",    Hizalama: "sag", Bicim: "#,##0.0000"),
            // Yerel karsilik HAREKETIN KENDI KURUYLA (kayit anindaki), ekstre
            //   gununun kuruyla degil - gecmise donuk ekstre hep ayni cikmali.
            new("yerelBorc",    "e.yerel_borc",   "para",  "Yerel Borc",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("yerelAlacak",  "e.yerel_alacak", "para",  "Yerel Alacak", Hizalama: "sag", Bicim: "#,##0.00"),
            // Bakiye TOPLANMAZ - grubun son satirindaki deger kapanis bakiyesidir.
            new("bakiye",       "e.bakiye",       "para",  "Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, SadeceGrupToplami: true, GrupKapanisi: true),
            new("yerelBakiye",  "e.yerel_bakiye", "para",  "Yerel Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false, SadeceGrupToplami: true, GrupKapanisi: true),
            new("dovizCinsi",   "e.doviz_cinsi",  "metin", "Doviz",  Hizalama: "orta", Varsayilan: false),
            new("dovizSira",    "e.doviz_sira",   "sayi",  "Doviz Sira", Varsayilan: false),
            new("planTarihi",   "e.plan_tarihi",  "tarih", "Vade", Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("subeId",       "e.sube_id",      "sayi",  "Sube", Varsayilan: false)
        });

    // ---------------------------------------------------------- kasa islem ----
    // Baslik listesi (makbuz seviyesi). Bacaklar "mali-hareket" listesindedir;
    //   ikisi ayni veriye iki farkli granulariteden bakar.
    private static KaynakTanimi KasaIslem() => new(
        Ad: "kasa-islem",
        YetkiKodu: "kasa_islem",
        Kaynak: """
            public.kasa_islem ki
            join      public.kasa_islem_turu kt on kt.kod = ki.tur
            left join public.taraf t            on t.id   = ki.taraf_id
            left join public.hesap h            on h.id   = ki.hesap_id
            left join public.hesap kh           on kh.id  = ki.karsi_hesap_id
            left join public.proje p            on p.id   = ki.proje_id
            left join public.muhasebe_fis f     on f.id   = ki.muhasebe_fis_id
            """,
        SubeKolonu: "ki.sube_id",
        KapsamKolonu: "ki.taraf_id",
        VarsayilanSirala: "ki.islem_tarihi desc, ki.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "ki.id",                "sayi",  "Id",        Varsayilan: false),
            new("islemTarihi",   "ki.islem_tarihi",      "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("turAdi",        "kt.ad",                "metin", "İşlem",     Genislik: 180),
            new("tur",           "ki.tur",               "sayi",  "Tür Kodu",  Hizalama: "orta", Varsayilan: false),
            new("turGrup",       "kt.grup",              "metin", "Grup",      Hizalama: "orta", Varsayilan: false),
            new("islemNo",       "ki.islem_no",          "metin", "Makbuz No"),
            new("tarafUnvan",    "coalesce(t.unvan, ki.taraf_unvan)", "metin", "Cari", Genislik: 220),
            new("hesapAdi",      "h.ad",                 "metin", "Hesap",     Genislik: 180),
            new("karsiHesapAdi", "kh.ad",                "metin", "Karşı Hesap", Varsayilan: false),
            new("tutar",         "ki.tutar",             "para",  "Tutar",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",    "ki.doviz_cinsi",       "metin", "Döviz",     Hizalama: "orta"),
            new("dovizKuru",     "ki.doviz_kuru",        "para",  "Kur",       Hizalama: "sag", Varsayilan: false),
            new("yerelTutar",    "ki.yerel_tutar",       "para",  "TL Tutar",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("projeAdi",      "p.ad",                 "metin", "Proje",     Varsayilan: false),
            new("planTarihi",    "ki.plan_tarihi",       "tarih", "Vade",      Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("kalanTutar",    "ki.kalan_tutar",       "para",  "Kalan",     Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("fisNo",         "f.fis_no",             "metin", "Fiş No",    Varsayilan: false),
            new("muhasebeFisId", "ki.muhasebe_fis_id",   "sayi",  "Fiş Id",    Varsayilan: false),
            new("durum",         "ki.durum",             "kod",   "Durum",     Hizalama: "orta"),
            new("aciklama",      "ki.aciklama",          "metin", "Açıklama",  Genislik: 240),
            new("iptalIslemId",  "ki.iptal_islem_id",    "sayi",  "Ters İşlem", Varsayilan: false),
            // Belge kartinin "Tahsilat" sekmesi bu kolonla suzuyor (belge basina
            //   tahsilat/odeme listesi).
            new("belgeId",       "ki.belge_id",          "sayi",  "Belge Id",  Varsayilan: false),
            new("subeId",        "ki.sube_id",           "sayi",  "Şube",      Varsayilan: false)
        });

    // ------------------------------------------------------- muhasebe fisi ----
    private static KaynakTanimi MuhasebeFis() => new(
        Ad: "muhasebe-fis",
        YetkiKodu: "muhasebe_fis",
        Kaynak: """
            public.muhasebe_fis f
            left join public.muhasebe_donem d on d.id = f.donem_id
            """,
        SubeKolonu: "f.sube_id",
        VarsayilanSirala: "f.fis_tarihi desc, f.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "f.id",            "sayi",  "Id",       Varsayilan: false),
            new("fisNo",        "f.fis_no",        "metin", "Fiş No"),
            new("fisTarihi",    "f.fis_tarihi",    "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tur",          "f.tur",           "kod",   "Fiş Türü", Hizalama: "orta"),
            new("durum",        "f.durum",         "kod",   "Durum",    Hizalama: "orta"),
            new("kaynakTur",    "f.kaynak_tur",    "kod",   "Kaynak",   Hizalama: "orta"),
            new("kaynakId",     "f.kaynak_id",     "sayi",  "Kaynak Id", Varsayilan: false),
            new("toplamBorc",   "f.toplam_borc",   "para",  "Borç",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("toplamAlacak", "f.toplam_alacak", "para",  "Alacak",   Hizalama: "sag", Bicim: "#,##0.00"),
            new("aciklama",     "f.aciklama",      "metin", "Açıklama", Genislik: 280),
            new("tersFisId",    "f.ters_fis_id",   "sayi",  "Ters Fiş", Varsayilan: false),
            new("donem",        "case when d.id is null then '' else lpad(d.ay::text, 2, '0') || '.' || d.yil::text end",
                                                    "metin", "Dönem",    Hizalama: "orta", Varsayilan: false),
            new("subeId",       "f.sube_id",       "sayi",  "Şube",     Varsayilan: false)
        });

    private static KaynakTanimi MuhasebeFisSatir() => new(
        Ad: "muhasebe-fis-satir",
        YetkiKodu: "muhasebe_fis",
        Kaynak: """
            public.muhasebe_fis_satir s
            join      public.muhasebe_fis f  on f.id  = s.fis_id
            join      public.hesap_plani hp  on hp.id = s.hesap_plani_id
            left join public.taraf t         on t.id  = s.taraf_id
            left join public.proje p         on p.id  = s.proje_id
            """,
        SubeKolonu: "f.sube_id",
        VarsayilanSirala: "f.fis_tarihi desc, s.fis_id desc, s.sira",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "s.id",         "sayi",  "Id",      Varsayilan: false),
            new("fisId",      "s.fis_id",     "sayi",  "Fiş Id",  Varsayilan: false),
            new("fisNo",      "f.fis_no",     "metin", "Fiş No"),
            new("fisTarihi",  "f.fis_tarihi", "tarih", "Tarih",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("sira",       "s.sira",       "sayi",  "Sıra",    Hizalama: "orta", Varsayilan: false),
            new("hesapKodu",  "hp.kod",       "metin", "Hesap Kodu"),
            new("hesapAdi",   "hp.ad",        "metin", "Hesap Adı", Genislik: 240),
            new("borc",       "s.borc",       "para",  "Borç",    Hizalama: "sag", Bicim: "#,##0.00"),
            new("alacak",     "s.alacak",     "para",  "Alacak",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi", "s.doviz_cinsi","metin", "Döviz",   Hizalama: "orta", Varsayilan: false),
            new("tarafUnvan", "t.unvan",      "metin", "Cari",    Varsayilan: false),
            new("projeAdi",   "p.ad",         "metin", "Proje",   Varsayilan: false),
            new("aciklama",   "s.aciklama",   "metin", "Açıklama", Genislik: 260)
        });

    // ------------------------------------------------------- vade / planlar ----
    // Acik planlar (durum 1): beklenen tahsilat/odemeler. `gecikmeGun` pozitifse
    //   vade gecmis - listenin varsayilan sirasi en gecikmisi ustte.
    private static KaynakTanimi PlanVade() => new(
        Ad: "plan-vade",
        YetkiKodu: "kasa_islem",
        Kaynak: "public.v_plan_vade v",
        SubeKolonu: "v.sube_id",
        KapsamKolonu: "v.taraf_id",
        VarsayilanSirala: "v.plan_tarihi asc, v.id asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",               "v.id",                "sayi",  "Id",     Varsayilan: false),
            new("planTarihi",       "v.plan_tarihi",       "tarih", "Vade",   Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("gecikmeGun",       "v.gecikme_gun",       "sayi",  "Gecikme (gün)", Hizalama: "sag"),
            new("turAdi",           "v.tur_adi",           "metin", "Plan Türü"),
            new("turGrup",          "v.tur_grup",          "metin", "Grup",   Hizalama: "orta", Varsayilan: false),
            new("tarafUnvan",       "v.taraf_unvan",       "metin", "Cari",   Genislik: 220),
            new("tutar",            "v.tutar",             "para",  "Plan Tutarı", Hizalama: "sag", Bicim: "#,##0.00"),
            new("gerceklesenTutar", "v.gerceklesen_tutar", "para",  "Gerçekleşen", Hizalama: "sag", Bicim: "#,##0.00"),
            new("kalanTutar",       "v.kalan_tutar",       "para",  "Kalan",  Hizalama: "sag", Bicim: "#,##0.00"),
            new("dovizCinsi",       "v.doviz_cinsi",       "metin", "Döviz",  Hizalama: "orta"),
            new("yerelTutar",       "v.yerel_tutar",       "para",  "TL Tutar", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("projeId",          "v.proje_id",          "sayi",  "Proje Id", Varsayilan: false),
            new("aciklama",         "v.aciklama",          "metin", "Açıklama", Genislik: 240),
            new("subeId",           "v.sube_id",           "sayi",  "Şube",   Varsayilan: false)
        });

    // ------------------------------------------- stok belgeleri: ortak kolonlar ----
    // Transfer / talep / giris-cikis fisi listeleri ayni kuyrugu paylasiyor:
    //   kac kalem, toplam miktar, aciklama, durum, sube. Uc yere kopyalanmisti;
    //   yeni bir stok belgesi eklenince dorduncu kopya olacakti.
    private static KolonTanimi[] StokBelgesiKuyrukKolonlari() => new KolonTanimi[]
    {
        // Satir-basi alt sorgu: bu listeler kucuktur (belge sayisi binlerle
        //   olculmez), maliyeti kabul edilir.
        new("kalemSayisi",
            "(select count(*) from public.belge_satir s where s.belge_id = b.id)",
                                              "sayi",  "Kalem", Hizalama: "sag",
                                              Siralanabilir: false, Filtrelenebilir: false),
        new("miktar",
            "(select coalesce(sum(s.miktar), 0) from public.belge_satir s where s.belge_id = b.id)",
                                              "para",  "Miktar", Hizalama: "sag", Bicim: "#,##0.##",
                                              Siralanabilir: false, Filtrelenebilir: false),
        new("aciklama",    "coalesce(b.aciklama, '')", "metin", "Açıklama", Genislik: 240),
        new("durumAdi",    "case b.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end",
                                              "metin", "Durum", Hizalama: "orta"),
        new("durum",       "b.durum",        "sayi",  "Durum Kodu", Hizalama: "orta", Varsayilan: false),
        new("subeId",      "b.sube_id",      "sayi",  "Şube", Varsayilan: false),
    };

    // --------------------------------------------------------------- banka ----
    private static KaynakTanimi BankaListesi() => new(
        Ad: "banka",
        YetkiKodu: "hesap",
        Kaynak: "public.banka b",
        SubeKolonu: null,
        VarsayilanSirala: "b.sira, b.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "b.id",      "sayi",  "Id", Varsayilan: false),
            new("kod",     "b.kod",     "metin", "EFT Kodu", Hizalama: "orta"),
            new("ad",      "b.ad",      "metin", "Banka Adı", Genislik: 280),
            new("kisaAd",  "b.kisa_ad", "metin", "Kısa Ad"),
            new("swift",   "b.swift",   "metin", "SWIFT", Varsayilan: false),
            new("subeSayisi",
                "(select count(*) from public.banka_sube s where s.banka_id = b.id)",
                                        "sayi",  "Şube", Hizalama: "sag",
                                        Siralanabilir: false, Filtrelenebilir: false),
            new("durumAdi", "case b.aktif when 1 then 'Aktif' else 'Pasif' end",
                                        "metin", "Durum", Hizalama: "orta"),
            new("aktif",   "b.aktif",   "sayi",  "Durum Kodu", Varsayilan: false),
        });

    // --------------------------------------------------- stok transferi ----
    // Ayni `belge` tablosu, tur 20. Ayri kaynak: transferde CARI ve TUTAR yoktur,
    //   bunun yerine IKI DEPO ve miktar konusur - genel belge listesinin cari/tutar
    //   kolonlari burada hep bos kalirdi.
    private static KaynakTanimi StokTransfer() => new(
        Ad: "stok-transfer",
        YetkiKodu: "belge",
        Kaynak: """
            public.belge b
            left join public.depo cd on cd.id = b.cikis_depo_id
            left join public.depo gd on gd.id = b.giris_depo_id
            left join public.taraf te on te.id = b.teslim_eden_id
            left join public.taraf ta on ta.id = b.teslim_alan_id
            """,
        SabitKosul: "b.tur = 20",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "b.id",           "sayi",  "Id",    Varsayilan: false),
            new("belgeNo",     "b.belge_no",     "metin", "Transfer No"),
            new("belgeTarihi", "b.belge_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("cikisDepo",   "coalesce(cd.ad, '')", "metin", "Çıkış Deposu", Genislik: 180),
            new("girisDepo",   "coalesce(gd.ad, '')", "metin", "Giriş Deposu", Genislik: 180),
            // Sorumluluk devri: eski transferlerde bos olabilir (alan 100'de eklendi).
            new("teslimEden",  "coalesce(te.unvan, '')", "metin", "Teslim Eden", Genislik: 180),
            new("teslimAlan",  "coalesce(ta.unvan, '')", "metin", "Teslim Alan", Genislik: 180),
        }.Concat(StokBelgesiKuyrukKolonlari()).ToArray());

    // ------------------------------------------------------ stoktan talep ----
    // Belge turu 105: bir birim/kisi depodan mal ISTER. Stok ve cari ETKILEMEZ
    //   (kasa_islem_turu 105: stok_etkiler=0, cari_etkiler=0) - talep karsilaninca
    //   asil hareketi stok transferi (20) yapar.
    private static KaynakTanimi StokTalep() => new(
        Ad: "stok-talep",
        YetkiKodu: "belge",
        Kaynak: """
            public.belge b
            left join public.depo cd on cd.id = b.cikis_depo_id
            left join public.depo gd on gd.id = b.giris_depo_id
            left join public.taraf ta on ta.id = b.teslim_alan_id
            """,
        SabitKosul: "b.tur = 105",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "b.id",           "sayi",  "Id",    Varsayilan: false),
            new("belgeNo",     "b.belge_no",     "metin", "Talep No"),
            new("belgeTarihi", "b.belge_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("cikisDepo",   "coalesce(cd.ad, '')", "metin", "İstenen Depo", Genislik: 180),
            new("girisDepo",   "coalesce(gd.ad, '')", "metin", "Teslim Deposu", Genislik: 180),
            new("talepEden",   "coalesce(ta.unvan, '')", "metin", "Talep Eden", Genislik: 200),
            // Talep KARSILANDI mi: F8 sayaci (0 acik / 1 kismi / 2 kapandi).
            new("karsilanma",
                "case b.kapanma_durum when 2 then 'Karşılandı' when 1 then 'Kısmi' else 'Bekliyor' end",
                                                  "metin", "Karşılanma", Hizalama: "orta"),
            new("kapanmaDurum","b.kapanma_durum","sayi",  "Karşılanma Kodu", Hizalama: "orta", Varsayilan: false),
        }.Concat(StokBelgesiKuyrukKolonlari()).ToArray());

    // -------------------------------------------------------- stok fisleri ----
    // 3 Giris Fisi / 4 Cikis Fisi (101). Irsaliye gibi ama CARI YOK; TIPI fisin
    //   sebebini tasir ve listede METNE cevrilir (liste katmani kod cozmez).
    private static KaynakTanimi StokFisi(int tur)
    {
        var giris = tur == 3;
        // Tip adlari 101'deki kod_deger ile ayni; liste katmani kod_liste'ye
        //   join atmaz (tek satirlik CASE hem daha hizli hem tek sorgu).
        var tipIfade = giris
            ? "case b.tipi when 1 then 'Fire' when 2 then 'Sayım Fazlası' else 'Diğer' end"
            : "case b.tipi when 1 then 'Sarf' when 2 then 'İmha (Bozuk / SKT Geçmiş)' " +
              "when 3 then 'Kayıp' when 4 then 'Fire' when 5 then 'Sayım Eksiği' else 'Diğer' end";

        return new KaynakTanimi(
            Ad: giris ? "giris-fis" : "cikis-fis",
            YetkiKodu: "belge",
            Kaynak: """
                public.belge b
                left join public.depo d on d.id = coalesce(b.giris_depo_id, b.cikis_depo_id)
                left join public.taraf sc on sc.id = b.satici_id and b.satici_id > 0
                """,
            SabitKosul: $"b.tur = {tur}",
            SubeKolonu: "b.sube_id",
            VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
            Kolonlar: new KolonTanimi[]
            {
                new("id",          "b.id",           "sayi",  "Id", Varsayilan: false),
                new("belgeNo",     "b.belge_no",     "metin", "Fiş No"),
                new("belgeTarihi", "b.belge_tarihi", "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy"),
                new("tipAdi",      tipIfade,         "metin", "Tipi", Hizalama: "orta", Genislik: 170),
                // Ham kod cip filtreleri icin gizli durur.
                new("tipi",        "b.tipi",         "sayi",  "Tip Kodu", Hizalama: "orta", Varsayilan: false),
                new("depo",        "coalesce(d.ad, '')", "metin", giris ? "Giriş Deposu" : "Çıkış Deposu",
                                                      Genislik: 180),
                new("sorumlu",     "coalesce(sc.unvan, '')", "metin", "Sorumlu", Genislik: 180),
                // Tutar muhasebe fisinin (F7) matrahi - fiste KDV yok.
                new("genelToplam", "b.genel_toplam", "para",  "Tutar", Hizalama: "sag", Bicim: "#,##0.00"),
            }.Concat(StokBelgesiKuyrukKolonlari()).ToArray());
    }

    // --------------------------------------------------------------- gorev ----
    // Gorev / hatirlatma / takvim (108). Liste katmani kod cozmez: tur, durum ve
    //   oncelik SQL'de metne cevrilir, ham kodlar cip filtreleri icin gizli kalir.
    private static KaynakTanimi Gorev() => new(
        Ad: "gorev",
        YetkiKodu: "gorev",
        Kaynak: """
            public.gorev g
            left join public.taraf so on so.id = g.sorumlu_id
            left join public.taraf ta on ta.id = g.taraf_id
            left join public.proje pr on pr.id = g.proje_id
            """,
        SubeKolonu: null,                    // gorev subeler arasi paylasilir
        VarsayilanSirala: "coalesce(g.termin, g.baslangic) nulls last, g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "g.id",        "sayi",  "Id", Varsayilan: false),
            new("gorevNo",   "g.gorev_no",  "metin", "Görev No", Varsayilan: false),
            new("konu",      "g.konu",      "metin", "Konu", Genislik: 280),
            new("turAdi",
                "case g.tur when 1 then 'Görev' when 2 then 'Hatırlatma' " +
                "when 3 then 'Görüşme / Aktivite' when 4 then 'Toplantı' else 'Diğer' end",
                                            "metin", "Tür", Hizalama: "orta"),
            new("tur",       "g.tur",       "sayi",  "Tür Kodu", Varsayilan: false),
            new("durumAdi",
                "case g.durum when 0 then 'Bekliyor' when 1 then 'Devam Ediyor' " +
                "when 2 then 'Tamamlandı' else 'İptal' end",
                                            "metin", "Durum", Hizalama: "orta"),
            new("durum",     "g.durum",     "sayi",  "Durum Kodu", Varsayilan: false),
            new("oncelikAdi",
                "case g.oncelik when 1 then 'Düşük' when 3 then 'Yüksek' " +
                "when 4 then 'Acil' else 'Normal' end",
                                            "metin", "Öncelik", Hizalama: "orta"),
            new("oncelik",   "g.oncelik",   "sayi",  "Öncelik Kodu", Varsayilan: false),
            new("sorumlu",   "coalesce(so.unvan, '')", "metin", "Sorumlu", Genislik: 180),
            new("baslangic", "g.baslangic", "tarih", "Başlangıç", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm"),
            new("termin",    "g.termin",    "tarih", "Termin", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm"),
            // Gecikme LISTEDE hesaplanir: termin gecmis ve is bitmemisse.
            new("gecikti",
                "case when g.termin is not null and g.termin < now() and g.durum in (0,1) " +
                "then 'Gecikti' else '' end",
                                            "metin", "Gecikme", Hizalama: "orta"),
            new("ilerleme",  "g.ilerleme",  "sayi",  "İlerleme %", Hizalama: "sag"),
            new("cari",      "coalesce(ta.unvan, '')", "metin", "İlgili Cari", Genislik: 200),
            new("proje",     "coalesce(pr.ad, '')",    "metin", "Proje", Varsayilan: false),
            new("aciklama",  "g.aciklama",  "metin", "Açıklama", Genislik: 240, Varsayilan: false),
        });

    // ---------------------------------------------------------- irsaliye ----
    // Ekranlar/satis_irsaliye_listesi.html kolonlariyla BIREBIR. Ayni `belge`
    //   tablosu ama AYRI kaynak: irsaliye listesi sevkiyat odakli (arac/sofor,
    //   cikis deposu, kaynak siparis, faturalama durumu) - bu kolonlari genel
    //   belge listesine eklemek onu 20 kolonluk bir seye cevirirdi.
    private static KaynakTanimi Irsaliye() => new(
        Ad: "irsaliye",
        YetkiKodu: "belge",
        Kaynak: """
            public.belge b
            left join public.depo  cd on cd.id = b.cikis_depo_id
            left join public.taraf te on te.id = b.teslim_eden_id
            left join public.taraf sc on sc.id = b.satici_id
            left join public.belge kb on kb.id = b.kaynak_id and b.kaynak_tur = 30
            left join public.kasa_islem_turu kt2 on kt2.kod = kb.tur
            """,
        SabitKosul: "b.tur in (10, 14, 109, 119)",
        SubeKolonu: "b.sube_id",
        KapsamKolonu: "b.taraf_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id",        Varsayilan: false),
            // Liste katmaninda kod_liste cozumu YOK (yalniz kartta var); bu yuzden
            //   kullaniciya gorunen kolonlar SQL'de metne cevrilir, ham kodlar gizli
            //   kalir (cip filtreleri onlari kullanir).
            //
            // TIP kolonu YOK: mockup SVK/NUM/IPT gosteriyor ama gocten gelen
            //   `belge.tipi` 10 farkli deger tasiyor (415 kaydin hepsi "1") ve anlami
            //   belgesiz. Ekran zaten YALNIZ satis irsaliyelerini gosterdigi icin her
            //   satirda ayni kisaltmayi tekrarlamanin bilgi degeri de yoktu.
            new("tipi",          "b.tipi",           "sayi",  "Tip Kodu",  Hizalama: "orta", Varsayilan: false),
            new("belgeNo",       "b.belge_no",       "metin", "İrsaliye No"),
            new("belgeTarihi",   "b.belge_tarihi",   "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tarafUnvan",    "b.taraf_unvan",    "metin", "Müşteri",   Genislik: 220),
            new("cikisDepo",     "cd.ad",            "metin", "Çıkış Deposu"),
            // KAYNAK / HEDEF: F8 donusum zincirinin iki ucu. Kaynak baslik bagindan
            //   (belge.kaynak_id) okunur; hedef ise SATIR bagindan turetilir -
            //   bir irsaliye birden fazla faturaya bolunebilir, o yuzden distinct
            //   belge numaralari birlestirilir. Iptal (durum=2) hedefler sayilmaz.
            new("kaynak",
                "case when kb.id is null then '' " +
                "else coalesce(kt2.ad, '') || case when kb.belge_no <> '' " +
                "then ' ' || kb.belge_no else '' end end",
                                                      "metin", "Kaynak",    Genislik: 170,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("hedef",
                "coalesce((select string_agg(distinct coalesce(ht.ad, '') || ' ' || hb.belge_no, ', ') " +
                "            from public.belge_satir hs " +
                "            join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30 " +
                "            join public.belge hb on hb.id = hs.belge_id " +
                "            left join public.kasa_islem_turu ht on ht.kod = hb.tur " +
                "           where ks.belge_id = b.id and hb.durum <> 2), '')",
                                                      "metin", "Hedef",     Genislik: 190,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("kaynakBelgeNo", "kb.belge_no",      "metin", "Kaynak Belge No", Varsayilan: false),
            // Plaka ve sofor tek kolonda: mockup "07 ABC 145 / Hasan Celik" gosteriyor.
            new("aracSofor",
                "case when btrim(coalesce(b.arac_plaka, '') || coalesce(b.sofor_ad, '')) = '' then '' " +
                "else btrim(coalesce(b.arac_plaka, '')) || " +
                "case when coalesce(b.sofor_ad, '') <> '' then ' / ' || b.sofor_ad else '' end end",
                                                      "metin", "Araç / Şoför", Genislik: 170,
                                                      Varsayilan: false),
            // Teslim eden bos ise satis temsilcisi gosterilir (mockup'taki davranis).
            new("teslimEden",    "coalesce(te.unvan, sc.unvan)", "metin", "Teslim Eden",
                                                      Varsayilan: false),
            // Faturalama durumu GIZLI: Hedef kolonu zaten hangi faturaya donustugunu
            //   (ya da donusmedigini) gosteriyor; ikisi ayni bilgiyi tekrarliyordu.
            //   Cip filtreleri kapanmaDurum uzerinden calismaya devam eder.
            new("faturalama",
                "case b.kapanma_durum when 2 then 'Faturalandı' when 1 then 'Kısmi' else 'Faturalanmadı' end",
                                                      "metin", "Faturalama", Hizalama: "orta",
                                                      Varsayilan: false),
            new("kapanmaDurum",  "b.kapanma_durum",  "sayi",  "Faturalama Kodu", Hizalama: "orta", Varsayilan: false),
            new("eIrsaliye",
                "case when coalesce(b.efatura_durum, 0) = 0 then 'Kağıt' " +
                "when b.efatura_durum = 1 then 'Hazırlandı' when b.efatura_durum = 2 then 'Gönderildi' " +
                "when b.efatura_durum = 3 then 'Kabul' when b.efatura_durum = 4 then 'Red' else 'Bilinmiyor' end",
                                                      "metin", "e-İrsaliye", Hizalama: "orta",
                                                      // Kullanici: listede gereksiz - kolon secicide duruyor.
                                                      Varsayilan: false),
            new("efaturaDurum",  "b.efatura_durum",  "sayi",  "e-Belge Kodu", Hizalama: "orta", Varsayilan: false),
            // Miktar GIZLI: satir-basi alt sorgu (her satirda bir belge_satir taramasi)
            //   ve irsaliyede farkli birimler (adet/kg/metre) toplanip tek sayi olarak
            //   gosterildiginde yaniltici. Kolon seciciden acilabilir.
            new("miktar",
                "(select coalesce(sum(s.miktar), 0) from public.belge_satir s where s.belge_id = b.id)",
                                                      "para",  "Miktar",    Hizalama: "sag", Bicim: "#,##0.##",
                                                      Siralanabilir: false, Filtrelenebilir: false,
                                                      Varsayilan: false),
            new("genelToplam",   "b.genel_toplam",   "para",  "Tutar",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("teslimSekli",
                "case b.teslim_sekli when 1 then 'Alıcı adresine teslim' when 2 then 'Alıcı kendi aracıyla' " +
                "when 3 then 'Kargo / nakliye' when 4 then 'Depoda teslim' when 5 then 'Yurt dışı sevk' " +
                "else 'Belirtilmemiş' end",
                                                      "metin", "Teslim Şekli", Hizalama: "orta", Varsayilan: false),
            new("irsaliyeTarihi","b.irsaliye_tarihi","tarih", "Sevk Zamanı", Hizalama: "orta",
                                                      Bicim: "dd.MM.yyyy HH:mm", Varsayilan: false),
            new("aracPlaka",     "b.arac_plaka",     "metin", "Plaka",     Varsayilan: false),
            new("soforAd",       "b.sofor_ad",       "metin", "Şoför",     Varsayilan: false),
            new("tur",           "b.tur",            "sayi",  "Tür Kodu",  Hizalama: "orta", Varsayilan: false),
            new("durumAdi",      "case b.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end",
                                                      "metin", "Durum",     Hizalama: "orta"),
            new("durum",         "b.durum",          "sayi",  "Durum Kodu", Hizalama: "orta", Varsayilan: false),
            new("subeId",        "b.sube_id",        "sayi",  "Şube",      Varsayilan: false)
        });

    // -------------------------------------------------------------- depo ----
    // Belge kartinda cikis/giris deposu ADIYLA secilir (GenLookup kaynagi).
    private static KaynakTanimi Depo() => new(
        Ad: "depo",
        YetkiKodu: "stok",
        Kaynak: "public.depo d",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.ad asc",
        // Tipi ve Durum METIN olarak uretilir: liste katmani kod listesi cozmuyor
        //   (kart cozuyor), ham kod gosterirsek kullanici sayi gorur. Ham kodlar
        //   gizli kolon olarak durur - cip/filtre onlar uzerinden calisir.
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "d.id",         "sayi",  "Id",   Varsayilan: false),
            new("ad",         "d.ad",         "metin", "Depo Adı", Genislik: 220),
            new("tipAdi",
                "case d.tip when 1 then 'Merkez' when 2 then 'Demirbaş' " +
                "when 3 then 'Konsinye Alış' when 4 then 'Konsinye Satış' else '' end",
                                              "metin", "Tipi", Genislik: 150, Filtrelenebilir: false),
            new("tip",        "d.tip",        "kod",   "Tip Kodu", Varsayilan: false),
            new("durumAdi",   "case d.durum when 1 then 'Aktif' else 'Pasif' end",
                                              "metin", "Durum", Hizalama: "orta", Genislik: 90,
                                              Filtrelenebilir: false),
            new("durum",      "d.durum",      "kod",   "Durum Kodu", Varsayilan: false),
            // Tek isaretlik kolonlar: genislik verilmezse baslik kadar yayilip
            //   satirin yarisini bos birakiyordu.
            new("maliyetiEtkilesin", "d.maliyeti_etkilesin", "mantik", "Maliyeti Etkilesin",
                                              Hizalama: "orta", Genislik: 130),
            new("varsayilan", "d.varsayilan", "mantik","Varsayılan", Hizalama: "orta", Genislik: 90),
            new("subeId",     "d.sube_id",    "sayi",  "Şube", Varsayilan: false)
        });

    // ------------------------------------------------- acik belge satirlari ----
    // "Hangi siparislerin nesi teslim edilmedi" raporu. Donusum ekrani ayri bir
    //   uctan (GET /api/belge/{id}/acik-satirlar) okur; bu liste genel gorunum.
    private static KaynakTanimi BelgeAcikSatir() => new(
        Ad: "belge-acik-satir",
        YetkiKodu: "belge",
        Kaynak: "public.v_belge_acik_satir a",
        SubeKolonu: "a.sube_id",
        KapsamKolonu: "a.taraf_id",
        VarsayilanSirala: "a.belge_tarihi asc, a.belge_id asc, a.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("satirId",         "a.satir_id",         "sayi",  "Satır Id", Varsayilan: false),
            new("belgeId",         "a.belge_id",         "sayi",  "Belge Id", Varsayilan: false),
            new("belgeTurAdi",     "a.belge_tur_adi",    "metin", "Belge Türü"),
            new("belgeTur",        "a.belge_tur",        "sayi",  "Tür Kodu", Hizalama: "orta", Varsayilan: false),
            new("belgeNo",         "a.belge_no",         "metin", "Belge No"),
            new("belgeTarihi",     "a.belge_tarihi",     "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("tarafUnvan",      "a.taraf_unvan",      "metin", "Cari",     Genislik: 220),
            new("stokKodu",        "a.stok_kodu",        "metin", "Stok Kodu"),
            new("stokAdi",         "a.stok_adi",         "metin", "Stok",     Genislik: 240),
            new("aciklama",        "a.aciklama",         "metin", "Açıklama", Varsayilan: false),
            new("miktar",          "a.miktar",           "para",  "Miktar",   Hizalama: "sag", Bicim: "#,##0.##"),
            new("kapatilanMiktar", "a.kapatilan_miktar", "para",  "Dönüşen",  Hizalama: "sag", Bicim: "#,##0.##"),
            new("kalanMiktar",     "a.kalan_miktar",     "para",  "Kalan",    Hizalama: "sag", Bicim: "#,##0.##"),
            new("birimFiyat",      "a.birim_fiyat",      "para",  "Birim Fiyat", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("belgeDovizi",     "a.belge_dovizi",     "metin", "Döviz",    Hizalama: "orta", Varsayilan: false),
            new("kapanmaDurum",    "a.kapanma_durum",    "kod",   "Kapanma",  Hizalama: "orta", Varsayilan: false),
            new("subeId",          "a.sube_id",          "sayi",  "Şube",     Varsayilan: false)
        });
}
