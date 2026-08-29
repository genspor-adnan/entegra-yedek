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
        public const string PozisyonAdi =
            "coalesce((select d.ad from public.kod_deger d " +
            "           join public.kod_liste l on l.id = d.liste_id " +
            "          where l.kod = 'taraf.gorev' and d.deger = t.gorev_id), t.gorev, '')";

        /// <summary>taraf.departman smallint bir koddur - adi kod listesinden.</summary>
        public const string DepartmanAdi =
            "coalesce((select d.ad from public.kod_deger d " +
            "           join public.kod_liste l on l.id = d.liste_id " +
            "          where l.kod = 'taraf.departman' and d.deger = t.departman), '')";
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
            new("vkno",         TarafKatalog.TcknMaske, "metin", "VKN/TCKN",
                Filtrelenebilir: false),
            new("vknoHam",      "t.vkno",          "metin", "VKN/TCKN (ham)", Varsayilan: false),
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
                                                   "metin", "Departman"),
            new("gorev",        TarafKatalog.PozisyonAdi, "metin", "Görev"),
            new("rolAdi",       "coalesce(r.ad, '')", "metin", "Rol"),
            new("iseGirisTarihi", "po.ise_giris_tarihi", "tarih", "İşe Giriş",
                Hizalama: "orta"),
            new("vkno",         TarafKatalog.TcknMaske, "metin", "TCKN",
                Filtrelenebilir: false),
            new("vknoHam",      "t.vkno",          "metin", "TCKN (ham)", Varsayilan: false),
            new("cepTel",       "t.cep_tel",       "metin", "Cep"),
            new("eposta",       "t.eposta",        "metin", "E-posta"),
            new("durum",        "t.durum",         "kod",   "Durum",     Hizalama: "orta"),
            new("subeId",       "t.sube_id",       "sayi",  "Sube",      Varsayilan: false)
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
            new("tur",        "k.tur",           "sayi",  "Tür (ham)", Varsayilan: false),
            new("sozlesmeNo", "k.sozlesme_no",   "metin", "Sözleşme No", Genislik: 120),
            new("baslangic",  "k.baslangic",     "tarih", "Başlangıç"),
            new("bitis",      "k.bitis",         "tarih", "Bitiş"),
            new("sozlesmeDurum", "k.durum",      "mantik","Sözleşme Aktif", Hizalama: "orta"),
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
    /// <summary>
    /// Stok kart fiyati kolonu (128). Kural fn_stok_kart_fiyat'ta; burada yalniz
    /// hangi alanin (fiyat / doviz) ve hangi listenin (satis / alis) istendigi
    /// secilir - dort kolon ayni sarti kopyalamasin.
    /// </summary>
}
