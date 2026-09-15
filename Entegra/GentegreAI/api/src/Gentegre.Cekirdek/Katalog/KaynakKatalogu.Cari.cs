namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Cari / kisi / firsat / gorev listeleri - CRM tarafi.
///
/// KaynakKatalogu tek dosyada 1389 satira ulasmisti; tanimlar konu basina
/// partial dosyalara ayrildi. Sozluk, Bul/Tumu ve kayit sirasi ana dosyada.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Taraf listelerinde tekrar eden SQL parcalari.</summary>
    private static class TarafKatalog
    {
        /// <summary>
        /// TCKN listelerde MASKELI gorunur (kullanici): ilk 3 + son 2 acik,
        /// arasi yildiz (12345678901 -> 123******01). 11 haneli olmayan
        /// (10 haneli VKN gibi) degerler oldugu gibi kalir.
        /// </summary>
        public const string TcknMaske =
            "case when length(t.vkno) = 11 " +
            "     then left(t.vkno, 3) || '******' || right(t.vkno, 2) " +
            "     else coalesce(t.vkno, '') end";

        /// <summary>Pozisyon (236) - kod listesi 'taraf.gorev'; eslesmeyen eski metin yedek.</summary>
        /// <summary>taraf.gorev_id artik personel_gorev TABLOSUNA isaret eder (255).</summary>
        public const string PozisyonAdi =
            "coalesce((select g.ad from public.personel_gorev g where g.id = t.gorev_id), " +
            "         t.gorev, '')";

        /// <summary>
        /// ARAMA ICIN normalize telefon (266, kullanici: "kullanici 5336657898
        /// diye girebilir ama varsa bulmasi gerekir"). Cep ve sabit telefon
        /// rakamlara indirgenip birlestirilir; bosluk/parantez/+90 farki arama
        /// sonucunu degistirmesin.
        /// </summary>
        public const string TelefonHam =
            "regexp_replace(coalesce(t.cep_tel, '') || ' ' || coalesce(t.telefon, ''), " +
            "               '[^0-9]', '', 'g')";

        /// <summary>taraf.departman artik departman TABLOSUNA isaret eder (251).</summary>
        public const string DepartmanAdi =
            "coalesce((select dp.ad from public.departman dp where dp.id = t.departman), '')";
    }

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
            // TCKN listede MASKELI (kullanici): ilk 3 + son 2 acik. 10 haneli
            //   VKN dokunulmadan kalir; ham deger gizli kolonda (arama icin).
            new("vkno",         TarafKatalog.TcknMaske, "metin", "Vergi/Kimlik No",
                Filtrelenebilir: false),
            new("vknoHam",      "t.vkno",          "metin", "Vergi/Kimlik No (ham)", Varsayilan: false),
            // Telefonla arama (266): yalniz RAKAMLAR - ekranda gosterilmez.
            new("telefonHam",   TarafKatalog.TelefonHam, "metin", "Telefon (ham)",
                Varsayilan: false),
            new("utsKurumNo",   "t.uts_kurum_no",  "metin", "ÜTS Kurum No", Genislik: 110,
                                                                            Varsayilan: false),
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
            new("departman",    "t.departman",     "kod",   "Bölüm"),
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
            new("baslangic", "g.baslangic", "tarih", "Başlama", Hizalama: "orta",
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

    // ----------------------------------------------------------- personel ----
    private static KaynakTanimi Personel() => new(
        Ad: "personel",
        YetkiKodu: "personel",
        // Ozluk (ise giris) ve kullanici hesabinin rolu listede gorunsun
        //   (kullanici) - ikisi de 1:1 baglanti, satir cogaltmaz.
        Kaynak: """
            public.taraf t
            left join public.taraf_personel po on po.id = t.id
            left join public.taraf_kullanici tk on tk.id = t.id
            left join public.rol r on r.id = tk.rol_id
            """,
        SabitKosul: "t.personel = 1",
        VarsayilanSirala: "t.unvan asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "t.id",            "sayi",  "Id",        Varsayilan: false),
            new("kod",          "t.kod",           "metin", "Sicil No"),
            new("unvan",        "t.unvan",         "metin", "Ad Soyad"),
            // Ad Soyad'in SAGINDA: departman / gorev / rol / ise giris (kullanici).
            new("departmanAdi", TarafKatalog.DepartmanAdi,
                                                   "metin", "Bölüm"),
            new("gorev",        TarafKatalog.PozisyonAdi, "metin", "Görev"),
            new("rolAdi",       "coalesce(r.ad, '')", "metin", "Rol"),
            // Ham rol id ISTEMCIYE GELIR: seritteki Rol suzgeci ad yerine id ile
            //   suzsun - ayni adli iki rol ya da rol adi degisince filtre kaymaz.
            //   Gridde gizli (listeTanimlari.gizliKolonlar), orada rolAdi var.
            new("rolId",        "coalesce(tk.rol_id, 0)", "sayi", "Rol Id",
                Varsayilan: false),
            new("iseGirisTarihi", "po.ise_giris_tarihi", "tarih", "İşe Giriş",
                Hizalama: "orta"),
            new("vkno",         TarafKatalog.TcknMaske, "metin", "Kimlik No",
                Filtrelenebilir: false),
            new("vknoHam",      "t.vkno",          "metin", "Kimlik No (ham)", Varsayilan: false),
            new("cepTel",       "t.cep_tel",       "metin", "Cep"),
            // Randevu/basvuru hekim secimi (296): "randevu verilebilir" personel
            //   = doktor. Bolume gore suzme t.departman ile yapilir.
            new("randevuVerilebilir", "t.randevu_verilebilir", "mantik", "Randevu",
                Hizalama: "orta", Varsayilan: false),
            // Ham bolum id ISTEMCIYE GELIR (297): basvuruda personel secilince
            //   bolum ONDAN doldurulur. Personel gridinde gizli - orada
            //   departmanAdi var (listeTanimlari.gizliKolonlar).
            new("departmanId",  "t.departman",     "sayi",  "Bölüm Id"),
            // Telefonla arama (266): personel/hasta aramasi da rakamla bulsun.
            new("telefonHam",   TarafKatalog.TelefonHam, "metin", "Telefon (ham)",
                Varsayilan: false),
            new("eposta",       "t.eposta",        "metin", "E-posta"),
            new("durum",        "t.durum",         "kod",   "Durum",     Hizalama: "orta"),
            new("subeId",       "t.sube_id",       "sayi",  "Sube",      Varsayilan: false)
        });

    /// <summary>
    /// <summary>
    /// BASVURUDA SECILEBILECEK HEKIMLER (578).
    ///
    /// Kaynak KURUM PROFILINE gore degisir ve PRIM ROLU ARANMAZ:
    ///   lab / goruntuleme / goruntuleme_lab -> DIS hekimler,
    ///   otekiler                            -> randevu verilebilir personel.
    /// Karar gorunumde (`v_basvuru_hekim`); katalog yalniz kolonlari acar.
    /// Eskiden liste `prim-rol-aday`dan geliyordu - prim, hekimin kim oldugu
    /// degil UCRETLENDIRME sorusudur; prim rolu isaretlenmemis hekim
    /// basvuruda secilemez olmustu.
    /// </summary>
    private static KaynakTanimi BasvuruHekim() => new(
        Ad: "basvuru-hekim",
        YetkiKodu: "belge",
        Kaynak: "public.v_basvuru_hekim h",
        VarsayilanSirala: "h.ad asc",
        SubeKolonu: null,
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "h.id",       "sayi",  "Id", Varsayilan: false),
            new("ad",      "h.ad",       "metin", "Hekim"),
            // UNVAN = AD (583): jenerik taraf arama penceresi satirin adini
            //   `unvan` kolonundan okur ve metni `kod`/`unvan`/`telefonHam`
            //   uzerinde arar - hekim de ayni pencereden secilebilsin diye
            //   ucu de acilir. Ayri SQL degil, ayni ifadenin ikinci adi.
            new("unvan",   "h.ad",       "metin", "Hekim", Varsayilan: false),
            new("kod",     "h.kod",      "metin", "Kod", Varsayilan: false),
            new("telefonHam", "h.telefon_ham", "metin", "Telefon (ham)",
                Varsayilan: false),
            new("bolumId", "h.bolum_id", "sayi",  "Bölüm Id", Varsayilan: false),
            new("bolumAdi","h.bolum_adi","metin", "Bölüm", Genislik: 180),
            // BUGUNKU BASVURU (kullanici): hekimin O GUN kac hasta aldigi.
            //   Kayit kabul memuru yuku buna bakarak dengeler - combo'da
            //   gorunmeyen tek bilgi buydu.
            new("bugunBasvuru", "h.bugun_basvuru", "sayi", "Bugünkü Başvuru",
                Hizalama: "sag", Filtrelenebilir: false),
            new("disMi",   "h.dis_mi",   "mantik","Dış Hekim", Hizalama: "orta"),
            new("durum",   "h.durum",    "kod",   "Durum", Hizalama: "orta"),
        });

    /// DIS DOKTOR LISTESI (305): goruntuleme merkezine hasta GONDEREN kurum
    /// disi hekimler. Personel listesiyle ayni tabloyu okur, ayirt eden
    /// taraf_personel.dis_hekim = 1.
    ///
    /// Kolonlar personelinkinden FARKLI: sicil/departman/gorev yerine brans,
    /// calistigi kurum ve GONDERDIGI HASTA SAYISI - listenin sorusu "kim kac
    /// hasta gonderdi".
    /// </summary>
    private static KaynakTanimi DisHekim() => new(
        Ad: "dis-hekim",
        YetkiKodu: "personel",
        Kaynak: """
            public.taraf t
            join public.taraf_personel po on po.id = t.id
            left join public.taraf k on k.id = t.bag_id
            left join public.kod_liste kl on kl.kod = 'hekim.brans'
            left join public.kod_deger kd on kd.liste_id = kl.id
                                         and kd.deger::text = nullif(po.brans, '')
            """,
        SabitKosul: "t.personel = 1 and po.dis_hekim = 1",
        VarsayilanSirala: "t.unvan asc",
        SubeKolonu: null,
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "t.id",     "sayi",  "Id", Varsayilan: false),
            // KOD gizli ama VAR: jenerik arama serbest metni "kod icerir"
            //   kosuluyla da ariyor - kolon yoksa arama "Bilinmeyen alan: kod"
            //   ile 400 donuyor (kisi listesinde ayni cozum).
            new("kod",      "t.kod",    "metin", "Kod", Varsayilan: false),
            // AD SOYAD = unvan oneki + ad + soyad. Onek ayri kolonda DEGIL,
            //   t.unvan icinde durur (306) - kart kaydederken "Op.Dr. Kerem
            //   ATALAY" olarak yazilir. Unvan bos kalmis (disaridan/toplu
            //   eklenmis) kayitta ad+soyada duser, satir bos gorunmesin.
            new("unvan",
                "coalesce(nullif(btrim(t.unvan), ''), "
                + "btrim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')))",
                                        "metin", "Ad Soyad", Genislik: 220),
            // BRANS ARTIK GOREV AGACINDAN (577): kart `taraf.gorev_id`
            //   yaziyor, kod listesi degil. Eski kolon (po.brans) veri
            //   olarak duruyor - MEDULA gonderimi henuz onu okuyor.
            new("bransAdi",
                "coalesce((select g.ad from public.personel_gorev g where g.id = t.gorev_id), "
                + "coalesce(kd.ad, ''))",
                "metin", "Branş", Genislik: 200),
            // BOLUM (367): basvuruda once bolum secilirse arama O BOLUMDEKI
            //   hekimlerle sinirlanir - kolon olmadan filtre "Bilinmeyen alan"
            //   ile 400 doner. Listede gizli, yalniz suzme icin.
            // BOLUM ADI (kullanici): jenerik arama ekraninda dis hekim de
            //   ic personel de Bölüm kolonuyla listelenir - ikisi ayni
            //   listede yan yana geldigi icin alanlarin ADI da ayni olmali.
            new("departmanAdi", TarafKatalog.DepartmanAdi,
                                       "metin", "Bölüm", Genislik: 160),
            new("departman", "coalesce(t.departman, 0)", "sayi", "Bölüm Id",
                Varsayilan: false),
            // Kurum: artik yalniz KAYITLI cari (308) - serbest metin alani yok.
            new("kurum",    "coalesce(k.unvan, '')",
                                        "metin", "Kurum", Genislik: 220),
            new("tescilNo", "po.tescil_no", "metin", "Tescil No"),
            new("cepTel",   "t.cep_tel", "metin", "Cep"),
            new("telefonHam", TarafKatalog.TelefonHam, "metin", "Telefon (ham)",
                Varsayilan: false),
            new("eposta",   "t.eposta",  "metin", "E-posta"),
            // GONDERDIGI HASTA: dis hekimin bizim icin degeri budur - kac
            //   istem acilmis. Iptal (durum 0) sayilmaz.
            new("istemSayisi",
                "(select count(*) from public.radyoloji_istem i "
                + " where i.istek_hekim_id = t.id and i.durum > 0)",
                                        "sayi",  "Gönderdiği Tetkik",
                Hizalama: "sag", Filtrelenebilir: false),
            new("sonIstem",
                "(select max(coalesce(i.cekim_tarihi, i.ekleme_tarihi)) "
                + "   from public.radyoloji_istem i where i.istek_hekim_id = t.id)",
                                        "tarih", "Son Gönderim", Hizalama: "orta",
                Filtrelenebilir: false),
            new("brans",    "po.brans", "metin", "Branş (ham)", Varsayilan: false),
            // TEMSILCI: hekimi bizim adimiza kim takip ediyor - DURUM'un
            //   solunda (kullanici). Kod degil ADIYLA gosterilir.
            new("temsilci",
                "(select p.unvan from public.taraf p where p.id = t.temsilci)",
                                        "metin", "Temsilci", Genislik: 160),
            new("durum",    "t.durum",  "kod",   "Durum", Hizalama: "orta"),
        });

    // ADAY MUSTERILER ayri YETKI (kullanici: satici rolu CRM'i gorsun ama Cari
    //   listelerini GORMESIN). Ayni tablo/kolonlar - degisen yalniz yetki kodu
    //   ve sabit kosul; boylece 'cari' yetkisi verilmeden aday ekrani acilir.
    private static KaynakTanimi Aday()
    {
        var c = Cari();
        return c with
        {
            Ad = "aday",
            YetkiKodu = "aday",
            SabitKosul = "t.aday = 1",
        };
    }

    // ------------------------------------------------------- kurum-icmal ----
    /// <summary>
    /// Kurum donem icmalleri (289): SGK payinin toplu faturalanmasi. Satir
    /// sayisi ve toplam, icmalin ne kadarlik bir fatura uretecegini gosterir.
    /// </summary>
    private static KaynakTanimi KurumIcmal() => new(
        Ad: "kurum-icmal",
        YetkiKodu: "kurum",
        Kaynak: "public.kurum_icmal i " +
                "left join public.taraf t on t.id = i.kurum_id " +
                "left join public.belge b on b.id = i.belge_id",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.donem_bas desc, i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "i.id",        "sayi",  "Id", Varsayilan: false),
            new("kurumAdi",  "coalesce(t.unvan, \'\')", "metin", "Kurum", Genislik: 230),
            new("donemBas",  "i.donem_bas", "tarih", "Dönem Başlama", Hizalama: "orta"),
            new("donemBit",  "i.donem_bit", "tarih", "Dönem Bitiş",   Hizalama: "orta"),
            new("satirSayisi",
                "(select count(*) from public.kurum_icmal_satir ks where ks.icmal_id = i.id)",
                                            "sayi",  "Satır", Hizalama: "sag", Genislik: 80,
                                                     Filtrelenebilir: false),
            new("toplam",    "i.toplam",    "para",  "Toplam", Hizalama: "sag"),
            new("durumAdi",
                "case i.durum when 0 then \'İptal\' when 1 then \'Hazırlanıyor\' " +
                "when 2 then \'Faturalandı\' else \'\' end",
                                            "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                                     Genislik: 120, Filtrelenebilir: false),
            new("durum",     "i.durum",     "kod",   "Durum Kodu", Varsayilan: false),
            new("faturaNo",  "coalesce(b.belge_no, \'\')", "metin", "Fatura No", Genislik: 130),
            new("aciklama",  "i.aciklama",  "metin", "Açıklama", Varsayilan: false),
            new("kurumId",   "i.kurum_id",  "sayi",  "Kurum Id", Varsayilan: false),
            new("belgeId",   "i.belge_id",  "sayi",  "Belge Id", Varsayilan: false),
        });

    // ---------------------------------------------------------- kategori ----
    /// <summary>
    /// Kategori listesi (270). Alt kategori ust kategorisinin ALTINDA ve adi
    /// girintili - agac oldugu tek bakista gorunsun (departman deseni, 257).
    /// </summary>
    private static KaynakTanimi Kategori() => new(
        Ad: "kategori",
        YetkiKodu: "stok",
        Kaynak: "public.kategori k",
        // Sira KOD (kullanici): agac ekrani zaten hiyerarsiyi kendisi kuruyor,
        //   liste ise kod sirasinda okunuyor.
        VarsayilanSirala: "k.kod asc, k.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",     "sayi",  "Id", Varsayilan: false),
            new("kod",      "k.kod",    "metin", "Kod", Genislik: 110),
            // Ad HAM: girintiyi agac ekrani veriyor (345/346) - metne '— '
            //   eklemek agacta cift girinti gosteriyordu.
            new("ad",       "k.ad", "metin", "Kategori"),
            new("ustAdi",   "coalesce((select u.ad from public.kategori u " +
                            "           where u.id = k.ust_id), '')",
                            "metin", "Üst Kategori", Filtrelenebilir: false),
            new("ustId",    "k.ust_id", "sayi",  "Üst Id", Varsayilan: false),
            // TUR (345): 1 stok / 2 hizmet / 3 ortak - ekran iki gride bunun
            //   uzerinden bolunuyor, kolon da rozet olarak gorunur.
            new("tur",      "k.tur",    "sayi",  "Tür Kodu", Varsayilan: false),
            new("turAdi",
                "case k.tur when 2 then 'Hizmet' else 'Stok' end",
                            "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                            Genislik: 80, Filtrelenebilir: false),
            new("stokSayisi", "(select count(*) from public.stok s where s.kategori = k.id)",
                            "sayi", "Stok", Hizalama: "sag", Filtrelenebilir: false),
            new("hizmetSayisi", "(select count(*) from public.hizmet h where h.kategori = k.id)",
                            "sayi", "Hizmet", Hizalama: "sag", Filtrelenebilir: false),
            new("aktif",    "k.aktif",  "mantik","Durum", Hizalama: "orta"),
        });

    // ---------------------------------------------------------- kampanya ----
    /// <summary>Kampanya listesi (268) - Yönetim > Ayarlar yanindaki ekran.</summary>
    private static KaynakTanimi Kampanya() => new(
        Ad: "kampanya",
        YetkiKodu: "fiyat_listesi",
        Kaynak: """
            public.kampanya k
            left join public.fiyat_listesi fl on fl.id = k.fiyat_listesi_id
            """,
        VarsayilanSirala: "k.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",              "k.id",              "sayi",  "Id", Varsayilan: false),
            new("kod",             "k.kod",             "metin", "Kod", Genislik: 110),
            new("ad",              "k.ad",              "metin", "Kampanya"),
            new("baslangic",       "k.baslangic",       "tarih", "Başlama", Hizalama: "orta"),
            new("bitis",           "k.bitis",           "tarih", "Bitiş", Hizalama: "orta"),
            new("fiyatListesi",    "coalesce(fl.ad, '')", "metin", "Fiyat Listesi",
                Genislik: 150, Filtrelenebilir: false),
            new("fiyatListesiId",  "k.fiyat_listesi_id", "sayi", "Liste Id", Varsayilan: false),
            new("satirSayisi",     "(select count(*) from public.kampanya_satir ks " +
                                   "  where ks.kampanya_id = k.id)", "sayi", "Satır",
                Hizalama: "sag", Filtrelenebilir: false),
            new("durum",           "k.durum",           "mantik","Durum", Hizalama: "orta"),
            new("aciklama",        "k.aciklama",        "metin", "Açıklama", Varsayilan: false),
        });

    // ---------------------------------------------------------- departman ----
    /// <summary>
    /// Departman/bolum listesi (251). Randevu bolumleri de burada - farki
    /// `randevuVerilebilir` bayragidir; ayri bir bolum tablosu yok.
    /// </summary>
    private static KaynakTanimi Departman() => new(
        Ad: "departman",
        YetkiKodu: "personel",
        Kaynak: "public.departman d",
        // Alt birim UST BIRIMININ ALTINDA listelensin (257): once ust birimin
        //   adi (kok departmanlarda kendi adi), sonra kendi adi.
        VarsayilanSirala: "coalesce((select u.ad from public.departman u " +
                          "           where u.id = d.ustbirim_id), d.ad) asc, " +
                          "d.ustbirim_id nulls first, d.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",                 "d.id",                  "sayi",  "Id", Varsayilan: false),
            new("kod",                "d.kod",                 "metin", "Kod", Genislik: 110),
            // Alt birim adi GIRINTILI - agac oldugu listede tek bakista gorunsun.
            new("ad",                 "case when d.ustbirim_id is null then d.ad " +
                                      "     else '— ' || d.ad end",
                                      "metin", "Bölüm"),
            // Ust birim (257) - bos ise kok departman.
            new("ustbirimAdi",        "coalesce((select u.ad from public.departman u " +
                                      "           where u.id = d.ustbirim_id), '')",
                                      "metin", "Üst Birim", Filtrelenebilir: false),
            new("ustbirimId",         "d.ustbirim_id",         "sayi",  "Üst Birim Id",
                Varsayilan: false),
            new("randevuVerilebilir", "d.randevu_verilebilir", "mantik","Randevu",
                Hizalama: "orta"),
            new("durum",              "d.durum",               "mantik","Durum", Hizalama: "orta"),
            new("sira",               "d.sira",                "sayi",  "Sıra", Varsayilan: false),
        });

    // ------------------------------------------------------------- gorev ----
    /// <summary>Personel gorevleri (255) - Departmanlar ekraninin SAG gridi.</summary>
    private static KaynakTanimi PersonelGorev() => new(
        // CRM gorevleriyle karismasin: bu personelin POZISYON listesi.
        Ad: "personel-gorev",
        YetkiKodu: "personel",
        Kaynak: "public.personel_gorev g",
        // AGAC SIRASI (570, bolumdeki desenin aynisi): once ust gorevin adi
        //   (koklerde kendi adi), sonra kendi adi - alt gorev ustunun altinda.
        VarsayilanSirala: "coalesce((select u.ad from public.personel_gorev u " +
                          "           where u.id = g.ust_id), g.ad) asc, " +
                          "g.ust_id nulls first, g.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "g.id",           "sayi",  "Id", Varsayilan: false),
            // SKRS BRANS KODU (559/560): gorev listesi SKRS "Personel Branş
            //   Kodu" listesinden kuruluyor; kod eslemesi yerine kodun
            //   KENDISI tabloda duruyor.
            new("kod",          "g.kod",          "metin", "Kod", Genislik: 90),
            // Alt gorev adi GIRINTILI - agac oldugu listede tek bakista gorunsun
            //   (grid agac kipinde bu onek kirpilir, girintiyi cizim verir).
            new("ad",           "case when g.ust_id is null then g.ad " +
                                "     else '— ' || g.ad end",
                                "metin", "Görev"),
            // UST GOREV (570) - bos ise kok baslik.
            new("ustAdi",       "coalesce((select u.ad from public.personel_gorev u " +
                                "           where u.id = g.ust_id), '')",
                                "metin", "Üst Görev", Filtrelenebilir: false),
            new("ustId",        "g.ust_id",       "sayi",  "Üst Görev Id",
                Varsayilan: false),
            // Bagimsiz gorevde (0) bos gorunur - "her departmanda gecerli".
            new("departmanAdi", "coalesce((select dp.ad from public.departman dp " +
                                "           where dp.id = g.departman_id), '')",
                                "metin", "Bölüm", Filtrelenebilir: false),
            new("departmanId",  "g.departman_id", "sayi",  "Bölüm Id", Varsayilan: false),
            new("durum",        "g.durum",        "mantik","Durum", Hizalama: "orta"),
            new("sira",         "g.sira",         "sayi",  "Sıra", Varsayilan: false),
        });

    // -------------------------------------------------------------- kurum ----
    /// <summary>
    /// ANLASMALI KURUMLAR listesi (249, kullanici: "cari altina musteri benzeri
    /// Kurumlar menusu"). Cari listesinin turevi; sozlesme kolonlari
    /// (tur/no/sure/durum) taraf_kurum'dan gelir.
    /// </summary>
    private static KaynakTanimi Kurum()
    {
        var c = Cari();
        // Sozlesme basligi 1:1 - alt sorgu yerine LEFT JOIN, kolon basina
        //   tekrar sorgu acmasin.
        var kaynak = "public.taraf t left join public.taraf_kurum k on k.id = t.id";
        var kolonlar = c.Kolonlar.Select(x => x.Ad switch
        {
            "kod"   => x with { Baslik = "Kurum Kodu" },
            "unvan" => x with { Baslik = "Kurum Adı" },
            _ => x
        }).ToList();
        // Kurum turu adi kod listesinden (Özel/ÖSS/SGK).
        kolonlar.InsertRange(3, new KolonTanimi[]
        {
            new("turAdi",     "coalesce((select d.ad from public.kod_deger d " +
                              "  join public.kod_liste l on l.id = d.liste_id " +
                              " where l.kod = 'taraf.kurum_turu' and d.deger = k.tur), '')",
                              "metin", "Kurum Türü", Genislik: 130, Filtrelenebilir: false),
            // Ham tur ISTEMCIYE GELIR (296): basvuru basligindaki "Ödeyen Tipi"
            //   secimi kurumlari 1 Özel / 2 ÖSS / 3 SGK diye suzer. Kurumlar
            //   gridinde gizli (listeTanimlari.gizliKolonlar) - orada turAdi var.
            new("tur",        "k.tur",           "sayi",  "Tür (ham)"),
            // SOZLESME 1:N (468/478): kurumun tek bir sozlesme no'su yok.
            //   Listede SAYI ve POLICE TURLERI gorunur, ayrintisi kartta.
            new("sozlesmeSayisi",
                "(select count(*) from public.kurum_sozlesme s " +
                "  where s.kurum_id = t.id and s.durum = 1)",
                              "sayi", "Sözleşme", Hizalama: "orta", Genislik: 90,
                              Filtrelenebilir: false),
            new("policeler",
                "coalesce((select string_agg(coalesce(d.ad, s.ad), ' · ' order by s.id) " +
                "            from public.kurum_sozlesme s " +
                "            left join public.kod_deger d " +
                "                   on d.deger = s.alt_kurum and d.dil = 0 " +
                "                  and d.liste_id = (select l.id from public.kod_liste l " +
                "                                     where l.kod = 'kurum.alt_kurum') " +
                "           where s.kurum_id = t.id and s.durum = 1), '')",
                              "metin", "Poliçe / Alt Kurum", Genislik: 220,
                              Filtrelenebilir: false),
        });
        return c with
        {
            Ad = "kurum",
            YetkiKodu = "kurum",
            Kaynak = kaynak,
            SabitKosul = "t.kurum = 1",
            Kolonlar = kolonlar.ToArray()
        };
    }

    private static KaynakTanimi Hasta()
    {
        var p = Personel();

        // HASTA ARAMA KOLONLARI (kullanici): Dosya No · Ad Soyad · Cinsiyet ·
        //   Yas · Telefon · Ilce · Il · Son Basvuru. Kayit kabulde hastayi
        //   ayirt eden bilgiler bunlar; personelin departman/gorev/rol/ise
        //   giris kolonlarinin hastada karsiligi yok - gizlenir.
        // BOLUM ID hastada HIC kullanilmaz (kullanici: "Bolum Id kaldir"):
        //   ham kolon personelde var cunku basvuruda hekim secilince bolum
        //   ondan doldurulur - hastanin bolumu yoktur. Gorunmez yapilir
        //   (silinmez: kolon secicisinden istenirse yine acilabilir).
        var personelAlanlari = new[] { "departmanAdi", "gorev", "rolAdi",
                                       "iseGirisTarihi", "departmanId" };
        var kolonlar = p.Kolonlar
            .Select(k => k.Ad switch
            {
                "kod"    => k with { Baslik = "Dosya No" },
                "cepTel" => k with { Baslik = "Telefon" },
                _ when personelAlanlari.Contains(k.Ad) => k with { Varsayilan = false },
                _ => k
            }).ToList();

        // SIRA HASTAYA GORE KURULUR (kullanici): TCKN Ad Soyad'in HEMEN saginda,
        //   Telefon Ilce'nin solunda. Kolonlar personelden miras geldigi icin
        //   sira da personelinkiydi - orada TCKN ve Cep, departman/gorev/rol
        //   bloguyla birlikte adres kolonlarindan SONRA geliyordu.
        var tckn = kolonlar.First(k => k.Ad == "vkno");
        var telefon = kolonlar.First(k => k.Ad == "cepTel");
        kolonlar.RemoveAll(k => k.Ad is "vkno" or "cepTel");

        // Ad Soyad'in sagina: TCKN, cinsiyet, yas, telefon, adres, son basvuru.
        var ek = new List<KolonTanimi>
        {
            tckn,
            new("cinsiyetAdi",
                "case th.cinsiyet when 1 then 'Erkek' when 2 then 'Kadın' else '' end",
                                   "metin", "Cinsiyet", Hizalama: "orta", Genislik: 90,
                                   Filtrelenebilir: false),
            new("cinsiyet",  "th.cinsiyet",  "sayi",  "Cinsiyet (ham)", Varsayilan: false),
            // Yas dogum tarihinden HESAPLANIR: sabit bir "yas" kolonu tutmak her
            //   dogum gununde bayatlar.
            new("yas",
                "case when th.dogum_tarihi is null then null "
                + "else extract(year from age(current_date, th.dogum_tarihi))::int end",
                                   "sayi",  "Yaş", Hizalama: "sag", Genislik: 60,
                                   Filtrelenebilir: false),
            new("dogumTarihi", "th.dogum_tarihi", "tarih", "Doğum Tarihi",
                Hizalama: "orta", Varsayilan: false),
            telefon,
            new("ilce",      "coalesce(adr.ilce, '')", "metin", "İlçe", Genislik: 120),
            new("il",        "coalesce(adr.il, '')",   "metin", "İl",   Genislik: 120),
            // Son basvuru: hastanin en yeni basvuru (tur 19) tarihi.
            //   SAAT DE GOSTERILIR (kullanici): ayni gun icinde birden cok
            //   basvuru olabiliyor, yalniz tarih "bugun mu geldi" sorusuna
            //   cevap verse de "ne zaman geldi"ye vermiyordu. Bicimde 'HH'
            //   gecmesi grid'e saati de yazdirir (bicim.ts).
            // KURUM, Son Basvuru'nun SOLUNDA (kullanici). Katalog sirasi gridin
            //   varsayilan sirasidir; kolon menusundeki tasima bunu ezer.
            //   Sigorta = hastanin bagli oldugu anlasmali kurum
            //   (taraf_hasta.kurum_id) - hasta seridi de bunu okur.
            new("sigortaAdi", "coalesce(sg.unvan, '')", "metin", "Sigorta / Kurum",
                Genislik: 180),
            new("sonBasvuru",
                "(select max(b.belge_tarihi) from public.belge b "
                + " where b.taraf_id = t.id and b.tur = 19)",
                                   "tarih", "Son Başvuru", Hizalama: "orta",
                                   Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                   Filtrelenebilir: false),
            // VARSAYILAN ODEYEN KURUM (kullanici): basvuru acilirken hastanin
            //   kayitli kurumu kendiliginden secilsin - memur ayni bilgiyi her
            //   basvuruda yeniden aramasin. Listede gizli, yalniz kart kullanir.
            new("kurumId",    "coalesce(th.kurum_id, 0)", "sayi", "Kurum Id",
                Varsayilan: false),
            // Acik borc CARI EKSTRE ile ayni kurali kullanir (v_mali_hareket_ek):
            //   yalniz cari hesap hareketleri, ekstreye giren islem turleri ve
            //   iptal olmayan (durum 1-2) islemler. Ayri bir formul yazmak
            //   ekstredeki bakiyeyle uyusmayan bir sayi uretirdi.
            new("acikBorc",
                "(select coalesce(sum(case when e.bakiye_dahil = 1 "
                + "                       then e.yerel_borc - e.yerel_alacak else 0 end), 0) "
                + "   from public.v_mali_hareket_ek e "
                + "  where e.taraf_id = t.id and e.hesap_turu = 'C' "
                + "    and e.cari_ekstre = 1 and e.islem_durum in (1, 2))",
                                   "para", "Açık Borç", Hizalama: "sag",
                                   Bicim: "#,##0.00", Siralanabilir: false,
                                   Filtrelenebilir: false),
        };
        var unvanSonu = kolonlar.FindIndex(k => k.Ad == "unvan") + 1;
        kolonlar.InsertRange(unvanSonu, ek);

        return p with
        {
            Ad = "hasta",
            // HASTANIN KENDI YETKISI (684, kullanici: "yetki matrisine girdim
            //   kayit kabul altinda personel var, neden"): hasta listesi
            //   `personel` yetkisine bagliydi ve matriste Kayit Kabul basligi
            //   altinda "Personel" olarak goruluyordu. Iki ayri istir:
            //   hastayi kayit kabul gorevlisi gorur, personel kartini IK.
            YetkiKodu = "hasta",
            SabitKosul = "t.grup = 101",
            // Hasta ozluk (1:1) ve VARSAYILAN adres (1:n'den tek satir - lateral,
            //   yoksa cok adresli hastada satir cogalirdi).
            Kaynak = p.Kaynak + """

                left join public.taraf_hasta th on th.id = t.id
                left join public.taraf sg on sg.id = th.kurum_id
                left join lateral (
                    select a.ilce, a.il from public.taraf_adres a
                     where a.taraf_id = t.id and a.aktif = 1
                     order by a.varsayilan desc, a.id
                     limit 1) adr on true
                """,
            Kolonlar = kolonlar.ToArray()
        };
    }

    // ------------------------------------------------------------- hizmet ----

    // --------------------------------------------------------- kullanici ----
    /// <summary>
    /// KULLANICILAR (Yonetim > Guvenlik) - mockup Ekranlar/Ayarlar/kullanicilar.html.
    ///
    /// Hesap yonetimi bugune kadar UC YERE dagilmisti: hesaplar personel
    /// kartindan otomatik aciliyor, rol atamasi rol kartinin Kullanicilar
    /// sekmesinden, denetim Giris Kayitlari'ndan yapiliyordu. Bu liste onlari
    /// tek ekranda toplar - YENI BIR YETKI MEKANIZMASI GETIRMEZ.
    ///
    /// PAROLA HIC GORUNMEZ: yalniz DURUMU ("kendi" / "varsayilan" / "bos")
    /// gosterilir. Parola alani olan bir liste, parolanin bir yerde okunur
    /// durdugunu ima ederdi.
    /// </summary>
    private static KaynakTanimi Kullanici() => new(
        Ad: "kullanici",
        YetkiKodu: "kullanici",
        Kaynak: "public.taraf_kullanici k "
              + "join public.rol r on r.id = k.rol_id "
              + "left join public.taraf t on t.id = k.id",
        VarsayilanSirala: "coalesce(t.unvan, k.kod) asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "k.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",       "k.kod",  "metin", "Kullanıcı Kodu", Genislik: 150),
            new("kisi",      "coalesce(t.unvan, '')", "metin", "Kişi", Genislik: 220),
            new("anaRol",    "r.ad",   "metin", "Ana Rol", Genislik: 150),
            // EK ROLLER (665): kisinin ana isinin yaninda tasidigi gorevler.
            new("ekRoller",
                "coalesce((select string_agg(er.ad, ', ' order by er.ad) "
                + "          from public.kullanici_rol kr "
                + "          join public.rol er on er.id = kr.rol_id "
                + "         where kr.kullanici_id = k.id), '')",
                "metin", "Ek Roller", Genislik: 200),
            // SUBELER ROLDEN gelir (234/665) - kisiye tek tek sube verilmez.
            new("subeler",
                "coalesce((select string_agg(s.ad, ' · ' order by s.ad) "
                + "          from public.fn_kullanici_subeleri(k.id) fs "
                + "          join public.sube s on s.id = fs.sube_id), '')",
                "metin", "Şubeler", Genislik: 180),
            new("aktif",     "k.aktif", "mantik", "Aktif", Hizalama: "orta"),
            // KILIT hatali giristen gelir ve KENDILIGINDEN cozulur; parola
            //   sorunundan AYRI bir durumdur - parolayi bilen ama uc kez yanlis
            //   yazan kisiye parola sifirlatmak gereksiz bir tur attirir.
            new("kilitli",
                "case when k.kilit_bitis is not null and k.kilit_bitis > now() "
                + "    then 1 else 0 end", "mantik", "Kilitli", Hizalama: "orta"),
            new("hataliGiris", "k.hatali_giris", "sayi", "Hatalı", Hizalama: "orta",
                                                                   Varsayilan: false),
            // PAROLA DURUMU - parolanin KENDISI degil:
            //   bos        hic belirlenmemis (ilk giriste kisi koyar)
            //   varsayilan zorunlu degisim bayragi acik
            //   kendi      kisinin kendi koydugu parola
            new("parolaDurum",
                "case when coalesce(k.parola_hash, '') = '' then 'boş' "
                + "    when k.parola_degismeli = 1 then 'varsayılan' "
                + "    else 'kendi' end", "metin", "Parola", Hizalama: "orta", Genislik: 110),
            new("sonGiris",  "k.son_giris_tarihi", "tarih", "Son Giriş", Hizalama: "orta",
                                                            Bicim: "dd.MM.yyyy HH:mm"),
            new("sonGirisIp", "k.son_giris_ip", "metin", "Son IP", Varsayilan: false),
            // ACIK OTURUM: AILE basina tek sayilir - rotation her yenilemede yeni
            //   satir aciyor, ham sayim "47 cihaz" gibi anlamsiz bir sayi verirdi.
            new("oturum",
                "(select count(distinct o.aile_id) from public.oturum o "
                + " where o.kullanici_id = k.id and o.iptal_tarihi is null "
                + "   and o.bitis_tarihi > now())::int",
                "sayi", "Oturum", Hizalama: "orta", Genislik: 90),
            new("eposta",    "coalesce(nullif(k.eposta, ''), t.eposta, '')",
                                       "metin", "E-posta", Genislik: 220),
            new("cepTel",    "coalesce(nullif(k.cep_tel, ''), t.cep_tel, '')",
                                       "metin", "Cep", Varsayilan: false),
            new("parolaTarihi", "k.parola_tarihi", "tarih", "Parola Tarihi",
                                Hizalama: "orta", Varsayilan: false),
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
            // Sistem rolu = programin davranisi ona bagli (664): silinemez, kodu
            //   degismez. Listede GORUNUR dursun - kullanici neyi silemedigini
            //   silmeyi deneyince degil, listeye bakinca anlasin.
            new("sistem",     "r.sistem",       "mantik","Sistem",   Hizalama: "orta"),
            new("amac",       "r.amac",         "metin", "Amaç")
        });

    // --------------------------------------------------------------- stok ----
    /// <summary>
    /// Stok kart fiyati kolonu (128). Kural fn_stok_kart_fiyat'ta; burada yalniz
    /// hangi alanin (fiyat / doviz) ve hangi listenin (satis / alis) istendigi
    /// secilir - dort kolon ayni sarti kopyalamasin.
    /// </summary>
}
