namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// YATAN HASTA MODÜLÜ LİSTELERİ (695) — mockuplar <c>Ekranlar/Yatan/*.html</c>.
///
/// <para>Modülün soruları ayaktan hastanınkinden farklıdır: "serviste kim
/// yatıyor ve bugün kimde iş var", "yer var mı", "hangi doz gecikti", "kim
/// çıkacak". Listeler bu dört soruya göre ayrıldı.</para>
///
/// <para>İzlem (vital / sıvı / risk) LİSTE DEĞİL: yatışın kartında ve hemşire
/// izlem ekranında okunur — servis genelinde "bütün vitaller" diye bir soru
/// yok, hep bir hastanın eğrisi sorulur.</para>
/// </summary>
public static partial class KaynakKatalogu
{
    // ------------------------------------------------------- yatan hasta ----
    /// <summary>
    /// YATAN HASTALAR — modülün ana çalışma ekranı (mockup
    /// <c>yatan_hasta_listesi.html</c>).
    ///
    /// <para>Hekim vizitte, hemşire nöbet devrinde, başhemşire yatak
    /// planlarken aynı listeye bakar; üçünün de ilk sorusu aynıdır: <b>kim,
    /// nerede, kaçıncı gün</b>. Bu yüzden yatak kolonu en başta - serviste
    /// hasta adıyla değil YATAKLA konuşulur ("301'in ateşi çıktı").</para>
    /// </summary>
    private static KaynakTanimi Yatan() => new(
        Ad: "yatan",
        YetkiKodu: "yatan",
        Kaynak: "public.yatis y "
              + "join public.taraf t on t.id = y.hasta_id "
              + "left join public.taraf_hasta th on th.id = y.hasta_id "
              + "left join public.yatak yk on yk.id = y.yatak_id "
              + "left join public.oda o on o.id = yk.oda_id "
              + "left join public.departman d on d.id = y.departman_id "
              + "left join public.taraf h on h.id = y.hekim_id "
              + "left join public.taraf k on k.id = y.odeyen_kurum_id",
        SubeKolonu: "y.sube_id",
        VarsayilanSirala: "yk.kod, y.giris_tarihi",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "y.id",       "sayi",  "Id", Varsayilan: false),
            new("hastaId",  "y.hasta_id", "sayi",  "Hasta Id", Varsayilan: false),
            new("yatak",    "coalesce(yk.kod, '')", "metin", "Yatak", Genislik: 110),
            new("hasta",    "t.unvan",    "metin", "Hasta", Genislik: 220),
            new("yasCinsiyet",
                "case when th.dogum_tarihi is null then '' "
                + "     else extract(year from age(th.dogum_tarihi))::int::text end "
                + "|| case th.cinsiyet when 1 then ' / E' when 2 then ' / K' else '' end",
                                          "metin", "Yaş / C", Hizalama: "orta", Genislik: 90,
                                          Filtrelenebilir: false),
            new("dosyaNo",  "y.dosya_no", "metin", "Dosya No", Genislik: 140),
            new("klinik",   "coalesce(d.ad, '')", "metin", "Klinik", Genislik: 160),
            new("hekim",    "coalesce(h.unvan, '')", "metin", "Sorumlu Hekim", Genislik: 180),
            new("girisTarihi", "y.giris_tarihi", "tarih", "Yatış", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy HH:mm"),
            // GÜN SAYISI HESAPLI ve uzun yatış hem klinik hem mali bir sinyal:
            //   provizyon dönemi, enfeksiyon riski, yatak devri.
            new("gun",
                "(coalesce(y.cikis_tarihi, now())::date - y.giris_tarihi::date)",
                                          "sayi", "Gün", Hizalama: "orta", Genislik: 70,
                                          Filtrelenebilir: false),
            new("tani",     "y.yatis_tani_kodu", "metin", "Tanı", Genislik: 120),
            new("odeyen",   "coalesce(k.unvan, '')", "metin", "Ödeyen", Genislik: 160),
            // PROVİZYON LİSTEDE: "reddedildi" rozetini taburcu gününde görmek
            //   geç olur - o gün hastadan ücret istemek ya da faturayı kuruma
            //   yazamamak demektir.
            new("provizyon",
                "case when y.provizyon_no <> '' then 'alındı' "
                + "     when y.odeyen_kurum_id is null then 'gerekmiyor' "
                + "     else 'yok' end",
                                          "metin", "Provizyon", Hizalama: "orta", Bicim: "rozet",
                                          Genislik: 110, Filtrelenebilir: false),
            new("durumAdi",
                "case y.durum when 0 then 'İptal' when 1 then 'Yatış kabul' "
                + "when 2 then 'Yatakta' when 3 then 'Taburcu planlandı' "
                + "when 4 then 'Taburcu' when 5 then 'Sevk' else '' end",
                                          "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                          Genislik: 140, Filtrelenebilir: false),
            new("durum",    "y.durum",    "kod",   "Durum Kodu", Varsayilan: false),
            new("izolasyon",
                "case o.izolasyon when 1 then 'temaslı' when 2 then 'damlacık' "
                + "when 3 then 'solunum' when 4 then 'koruyucu' else '' end",
                                          "metin", "İzolasyon", Hizalama: "orta", Genislik: 110,
                                          Filtrelenebilir: false),
            // GECİKEN DOZ: servisin o anki en acil işi. Karta girmeden
            //   görünmeli - saati geçmiş antibiyotik bir sonraki doza kayar.
            new("gecikenDoz",
                "(select count(*) from public.order_uygulama u "
                + " join public.yatis_order od on od.id = u.order_id "
                + " where od.yatis_id = y.id and u.durum in (1, 5) "
                + "   and u.planlanan < now() - interval '30 minutes')::int",
                                          "sayi", "Geciken Doz", Hizalama: "sag", Genislik: 110,
                                          Filtrelenebilir: false),
            new("tahminiCikis", "y.tahmini_cikis", "tarih", "Tahmini Çıkış", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy"),
            new("refakatci", "case when y.refakatci_ad <> '' then 1 else 0 end",
                                          "mantik", "Refakatçi", Hizalama: "orta",
                                          Varsayilan: false),
            new("cikisTarihi", "y.cikis_tarihi", "tarih", "Çıkış", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy HH:mm", Varsayilan: false),
        });

    // ------------------------------------------------------- yatak panosu ----
    /// <summary>
    /// YATAKLAR — "yer var mı" sorusunun liste hâli (pano
    /// <c>yatak_panosu.html</c> aynı görünümden beslenir).
    ///
    /// <para>Satır YATAKTIR, hasta değil: doluluk, temizlik ve kapalı yatak
    /// yatağın kendi durumudur. Kapalı yatak doluluk paydasından düşer -
    /// arızalı yatağı payda içinde bırakmak oranı olduğundan düşük gösterir ve
    /// "yer var" yanılgısı üretir.</para>
    /// </summary>
    private static KaynakTanimi YatakPanosu() => new(
        Ad: "yatak",
        YetkiKodu: "yatan",
        Kaynak: "public.v_yatak_panosu p",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.kat, p.oda_kod, p.yatak_kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.yatak_id", "sayi", "Id", Varsayilan: false),
            new("yatak",     "p.yatak_kod", "metin", "Yatak", Genislik: 110),
            new("oda",       "p.oda_kod",  "metin", "Oda", Genislik: 100),
            new("bina",      "p.bina",     "metin", "Bina", Genislik: 90),
            new("kat",       "p.kat",      "metin", "Kat", Genislik: 80),
            new("klinik",    "coalesce(p.departman_ad, '')", "metin", "Servis", Genislik: 170),
            new("odaTurAdi",
                "case p.oda_tur when 1 then 'Tek kişilik' when 2 then 'Çift kişilik' "
                + "when 3 then 'Çok yataklı' when 4 then 'Suit' when 5 then 'Yoğun bakım' "
                + "when 6 then 'Doğum' else '' end",
                                           "metin", "Oda Türü", Genislik: 130, Filtrelenebilir: false),
            new("durumAdi",
                "case p.yatak_durum when 1 then 'Boş' when 2 then 'Dolu' "
                + "when 3 then 'Rezerve' when 4 then 'Temizlik bekliyor' "
                + "when 5 then 'Kapalı' else '' end",
                                           "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                           Genislik: 140, Filtrelenebilir: false),
            new("durum",     "p.yatak_durum", "kod", "Durum Kodu", Varsayilan: false),
            new("hasta",     "coalesce(p.hasta_adi, '')", "metin", "Hasta", Genislik: 220),
            new("yatisGun",  "p.yatis_gun", "sayi", "Gün", Hizalama: "orta", Genislik: 70,
                                           Filtrelenebilir: false),
            // "Bugün boşalacak" yatağı BOŞA ÇIKARMAZ, işaretler: öğleden sonra
            //   boşalacak yatak sabah gelen hastaya planlanabilir ama verilemez.
            new("bugunBosalacak", "p.bugun_bosalacak", "mantik", "Bugün boşalacak",
                                           Hizalama: "orta", Genislik: 120),
            new("cinsiyetKurali",
                "case p.cinsiyet_kurali when 1 then 'kadın' when 2 then 'erkek' "
                + "when 3 then 'ilk yatana göre' else '' end",
                                           "metin", "Cinsiyet Kuralı", Hizalama: "orta",
                                           Genislik: 130, Filtrelenebilir: false),
            new("izolasyon",
                "case p.izolasyon when 1 then 'temaslı' when 2 then 'damlacık' "
                + "when 3 then 'solunum' when 4 then 'koruyucu' else '' end",
                                           "metin", "İzolasyon", Hizalama: "orta", Genislik: 110,
                                           Filtrelenebilir: false),
            new("durumNotu", "p.durum_notu", "metin", "Not", Genislik: 200),
            new("yatisId",   "p.yatis_id", "sayi", "Yatış Id", Varsayilan: false),
            new("hastaId",   "p.hasta_id", "sayi", "Hasta Id", Varsayilan: false),
        });

    // ------------------------------------------------------------- order ----
    /// <summary>
    /// ORDER'LAR — servis genelinde açık talimatlar (mockup
    /// <c>order_ilac_uygulama.html</c>).
    ///
    /// <para>Listenin iki işi var: <b>imzasız sözel order</b>ları ve süresi
    /// dolmak üzere olan talimatları göstermek. Tek hastanın order'ı yatış
    /// kartında okunur.</para>
    /// </summary>
    private static KaynakTanimi YatisOrder() => new(
        Ad: "yatis-order",
        YetkiKodu: "yatan.order",
        Kaynak: "public.yatis_order od "
              + "join public.yatis y on y.id = od.yatis_id "
              + "join public.taraf t on t.id = y.hasta_id "
              + "left join public.yatak yk on yk.id = y.yatak_id "
              + "left join public.taraf h on h.id = od.hekim_id",
        SubeKolonu: "od.sube_id",
        VarsayilanSirala: "od.baslangic desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "od.id",      "sayi", "Id", Varsayilan: false),
            new("yatisId",  "od.yatis_id","sayi", "Yatış Id", Varsayilan: false),
            new("yatak",    "coalesce(yk.kod, '')", "metin", "Yatak", Genislik: 100),
            new("hasta",    "t.unvan",    "metin", "Hasta", Genislik: 200),
            new("turAdi",
                "case od.tur when 1 then 'İlaç' when 2 then 'Serum / sıvı' "
                + "when 3 then 'Tetkik' when 4 then 'Görüntüleme' when 5 then 'Konsültasyon' "
                + "when 6 then 'Diyet' when 7 then 'Hemşirelik' when 8 then 'Kan ürünü' else '' end",
                                          "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                          Genislik: 120, Filtrelenebilir: false),
            new("tur",      "od.tur",     "kod",  "Tür Kodu", Varsayilan: false),
            new("ad",       "od.ad",      "metin", "Order", Genislik: 260),
            new("dozYol",
                "trim(coalesce(to_char(od.doz, 'FM9999990D999'), '') || ' ' || od.birim "
                + "|| case od.yol when 1 then ' · PO' when 2 then ' · IV' when 3 then ' · IM' "
                + "   when 4 then ' · SC' when 5 then ' · topikal' when 6 then ' · inhaler' "
                + "   when 7 then ' · rektal' else '' end)",
                                          "metin", "Doz / Yol", Genislik: 140, Filtrelenebilir: false),
            new("siklik",   "od.siklik",  "metin", "Sıklık", Genislik: 110),
            new("baslangic","od.baslangic","tarih", "Başlangıç", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy HH:mm"),
            new("bitis",    "od.bitis",   "tarih", "Bitiş", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy HH:mm"),
            new("hekim",    "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 170),
            // SÖZEL ORDER uygulanır ama imzasız kalmaz: telefonla verilen
            //   talimat verilmemiş sayılmaz, imzasız da bırakılmaz.
            new("sozelDurum",
                "case when od.sozel_order = 0 then '' "
                + "     when od.onay_tarihi is null then 'imza bekliyor' "
                + "     else 'imzalandı' end",
                                          "metin", "Sözel Order", Hizalama: "orta", Bicim: "rozet",
                                          Genislik: 130, Filtrelenebilir: false),
            new("sozelOrder", "od.sozel_order", "mantik", "Sözel", Varsayilan: false),
            new("imzasiz",
                "case when od.sozel_order = 1 and od.onay_tarihi is null then 1 else 0 end",
                                          "mantik", "İmzasız", Varsayilan: false),
            new("durumAdi",
                "case od.durum when 0 then 'İptal' when 1 then 'Aktif' "
                + "when 2 then 'Durduruldu' when 3 then 'Tamamlandı' else '' end",
                                          "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                          Genislik: 110, Filtrelenebilir: false),
            new("durum",    "od.durum",   "kod",  "Durum Kodu", Varsayilan: false),
        });

    // ------------------------------------------------------ ilaç uygulama ----
    /// <summary>
    /// DOZ KUYRUĞU (eMAR) — "hangi doz ne zaman, verildi mi" (mockup
    /// <c>order_ilac_uygulama.html</c> çizelgesi).
    ///
    /// <para>Satır PLANLANAN DOZDUR ve order kaydedilirken önceden üretilir:
    /// plan görünmeden takip olmaz, sonradan üretilen satır da atlanmış dozu
    /// gizler.</para>
    /// </summary>
    private static KaynakTanimi OrderUygulama() => new(
        Ad: "order-uygulama",
        YetkiKodu: "yatan.order",
        Kaynak: "public.order_uygulama u "
              + "join public.yatis_order od on od.id = u.order_id "
              + "join public.yatis y on y.id = od.yatis_id "
              + "join public.taraf t on t.id = y.hasta_id "
              + "left join public.yatak yk on yk.id = y.yatak_id "
              + "left join public.taraf p on p.id = u.uygulayan_id",
        SubeKolonu: "od.sube_id",
        VarsayilanSirala: "u.planlanan",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "u.id",       "sayi", "Id", Varsayilan: false),
            new("yatisId",   "od.yatis_id","sayi", "Yatış Id", Varsayilan: false),
            new("yatak",     "coalesce(yk.kod, '')", "metin", "Yatak", Genislik: 100),
            new("hasta",     "t.unvan",    "metin", "Hasta", Genislik: 200),
            new("order",     "od.ad",      "metin", "Order", Genislik: 240),
            new("planlanan", "u.planlanan","tarih", "Planlanan", Hizalama: "orta",
                                           Bicim: "dd.MM.yyyy HH:mm"),
            new("uygulanan", "u.uygulanan","tarih", "Uygulanan", Hizalama: "orta",
                                           Bicim: "dd.MM.yyyy HH:mm"),
            // GECİKME DAKİKASI: "saati geçti mi" sorusunun cevabı satırda
            //   dursun; yüz satırda yüz kez saat hesaplamak yerine.
            new("gecikmeDk",
                // Atlanan ve reddedilen doz GECİKMİŞ DEĞİLDİR: kararı
                //   verilmiş bir dozdur. Gecikme yalnız HÂLÂ BEKLEYEN doz
                //   için anlamlı - yoksa liste "10 saat gecikti" diye
                //   kapanmış bir işi gündemde tutar.
                "case when u.durum in (2, 3, 4) or u.uygulanan is not null then null "
                // SAATİ GELMEMİŞ DOZ GECİKMİŞ DEĞİL, boştur: "0 dk gecikti"
                //   yazmak, henüz sırası gelmemiş dozu gecikmiş gibi okutur.
                + "     when u.planlanan > now() then null "
                + "     else (extract(epoch from (now() - u.planlanan)) / 60)::int end",
                                           "sayi", "Gecikme (dk)", Hizalama: "sag", Genislik: 110,
                                           Filtrelenebilir: false),
            new("durumAdi",
                "case u.durum when 1 then 'Bekliyor' when 2 then 'Uygulandı' "
                + "when 3 then 'Atlandı' when 4 then 'Hasta reddetti' when 5 then 'Gecikti' "
                + "else '' end",
                                           "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                           Genislik: 130, Filtrelenebilir: false),
            new("durum",     "u.durum",    "kod",  "Durum Kodu", Varsayilan: false),
            new("uygulayan", "coalesce(p.unvan, '')", "metin", "Uygulayan", Genislik: 170),
            new("atlamaNedeni", "u.atlama_nedeni", "metin", "Atlama Nedeni", Genislik: 200),
            // Barkodsuz uygulama engellenmez (acil durum) ama işaretlenir:
            //   ikisini aynı göstermek kontrolü kâğıt üstünde bırakmak olurdu.
            new("elleDogrulandi", "u.elle_dogrulandi", "mantik", "Elle doğrulandı",
                                           Hizalama: "orta", Genislik: 120),
        });

    // ------------------------------------------------------------- odalar ----
    /// <summary>ODA TANIMLARI — kurulum ekranı; kural odanın, yatak odanın içinde.</summary>
    private static KaynakTanimi Oda() => new(
        Ad: "oda",
        YetkiKodu: "yatan.yatak",
        Kaynak: "public.oda o "
              + "left join public.departman d on d.id = o.departman_id "
              + "left join public.hizmet h on h.id = o.ucret_hizmet_id",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.kat, o.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "o.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",     "o.kod",  "metin", "Oda Kodu", Genislik: 120),
            new("ad",      "o.ad",   "metin", "Adı", Genislik: 180),
            new("bina",    "o.bina", "metin", "Bina", Genislik: 100),
            new("kat",     "o.kat",  "metin", "Kat", Genislik: 90),
            new("klinik",  "coalesce(d.ad, '')", "metin", "Servis", Genislik: 180),
            new("turAdi",
                "case o.tur when 1 then 'Tek kişilik' when 2 then 'Çift kişilik' "
                + "when 3 then 'Çok yataklı' when 4 then 'Suit' when 5 then 'Yoğun bakım' "
                + "when 6 then 'Doğum' else '' end",
                                     "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                     Genislik: 130, Filtrelenebilir: false),
            new("tur",     "o.tur",  "kod",   "Tür Kodu", Varsayilan: false),
            new("yatakSayisi",
                "(select count(*) from public.yatak yk where yk.oda_id = o.id and yk.aktif = 1)::int",
                                     "sayi", "Yatak", Hizalama: "sag", Genislik: 80,
                                     Filtrelenebilir: false),
            new("ucret",   "coalesce(h.ad, '')", "metin", "Yatak Ücreti (hizmet)", Genislik: 200),
            new("aktif",   "o.aktif","mantik", "Aktif", Hizalama: "orta", Genislik: 70),
        });

    // -------------------------------------------------------- izlem listesi ----
    /// <summary>
    /// HEMŞİRE İZLEMİ — servis genelindeki ÖLÇÜM satırları (mockup
    /// <c>hemsire_izlem.html</c>).
    ///
    /// <para>Liste tek başına "bütün vitaller" sorusunu cevaplamaz; işi
    /// <b>eşiği aşan ölçümü yüzeye çıkarmaktır</b>: erken uyarı 5 ve üstü olan
    /// satır, hangi hastada olursa olsun nöbetçi hemşirenin görmesi gereken
    /// şeydir. Tek hastanın eğrisi listenin üstündeki nöbet panelinde okunur.</para>
    ///
    /// <para><b>Bildirim sütunu satırda durur:</b> "eşik aşıldı, hekime haber
    /// verildi mi" sorusunun cevabı ölçümün yanında olmalı - ayrı bir bildirim
    /// listesinde arandığında kimse bakmaz.</para>
    /// </summary>
    private static KaynakTanimi YatisIzlem() => new(
        Ad: "yatis-izlem",
        YetkiKodu: "yatan.izlem",
        Kaynak: "public.yatis_izlem i "
              + "join public.yatis y on y.id = i.yatis_id "
              + "join public.taraf t on t.id = y.hasta_id "
              + "left join public.yatak yk on yk.id = y.yatak_id "
              + "left join public.taraf p on p.id = i.olcen_id "
              + "left join public.departman d on d.id = y.departman_id",
        SubeKolonu: "y.sube_id",
        VarsayilanSirala: "i.zaman desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "i.id",        "sayi",  "Id", Varsayilan: false),
            new("yatisId",  "i.yatis_id",  "sayi",  "Yatış Id", Varsayilan: false),
            new("yatak",    "coalesce(yk.kod, '')", "metin", "Yatak", Genislik: 100),
            new("hasta",    "t.unvan",     "metin", "Hasta", Genislik: 200),
            new("klinik",   "coalesce(d.ad, '')",   "metin", "Klinik", Genislik: 150),
            new("zaman",    "i.zaman",     "tarih", "Zaman", Hizalama: "orta",
                                           Bicim: "dd.MM.yyyy HH:mm"),
            // TANSİYON TEK KOLONDA: "120/75" klinikte tek bir okumadır; iki
            //   kolona bölmek listeyi genişletir, okumayı zorlaştırır.
            new("ta",
                "case when i.sistolik is null and i.diyastolik is null then '' "
                + "else concat(coalesce(i.sistolik::text, '—'), '/', "
                + "            coalesce(i.diyastolik::text, '—')) end",
                                           "metin", "TA", Hizalama: "orta", Genislik: 90,
                                           Filtrelenebilir: false),
            new("nabiz",    "i.nabiz",     "sayi",  "Nabız", Hizalama: "sag", Genislik: 80),
            new("ates",     "i.ates",      "ondalik", "Ateş", Hizalama: "sag", Genislik: 80),
            new("spo2",     "i.spo2",      "sayi",  "SpO₂", Hizalama: "sag", Genislik: 80),
            new("solunum",  "i.solunum",   "sayi",  "Solunum", Hizalama: "sag", Genislik: 90),
            new("erkenUyari", "i.erken_uyari", "sayi", "Erken uyarı", Hizalama: "orta",
                                           Genislik: 100),
            // BİLDİRİM: eşik aşıldığında hekime haber verilip verilmediği.
            new("bildirildi",
                "case when i.bildirim_zamani is not null then 1 else 0 end",
                                           "mantik", "Hekime bildirildi", Hizalama: "orta",
                                           Genislik: 120, Filtrelenebilir: false),
            new("olcen",    "coalesce(p.unvan, '')", "metin", "Ölçen", Genislik: 160),
            new("not",      "i.not_metin", "metin", "Gözlem", Genislik: 260),
            // EŞİĞİ AŞAN SATIR RENKLENİR (`satirRengi` sözleşmesi): sayıya
            //   bakıp kendi eşiğini hatırlamayı beklemek, yoğun bir günde
            //   kaçırmak demektir. Renk KOLONU sunucudan gelir - istemci eşik
            //   bilmez, iki yerde iki eşik olmaz.
            new("satirRengi",
                "case when i.erken_uyari >= 5 then 'kritik' "
                + "when i.erken_uyari >= 3 then 'uyari' else '' end",
                                           "metin", "", Varsayilan: false,
                                           Filtrelenebilir: false),
        });

    // ---------------------------------------------------- tahakkuk listesi ----
    /// <summary>
    /// GÜN SONU TAHAKKUKLARI (700) — yatak ve refakat ücretinin gün gün doğan
    /// kaydı (mockup <c>yatan_hizmet_fatura.html</c>).
    ///
    /// <para>Listenin işi <b>faturalanmamış tahakkuku yüzeye çıkarmak</b>:
    /// ücret her gece doğuyor ama fatura çıkışta kesiliyor; arada kalan gün
    /// kimsenin ekranında görünmezse, taburcu olan hastanın son günü
    /// faturalanmadan kapanır.</para>
    ///
    /// <para>Tek yatışın icmali listenin üstündeki panelde okunur - "bütün
    /// tahakkuklar" diye bir soru yok, hep bir hastanın faturası sorulur.</para>
    /// </summary>
    private static KaynakTanimi YatisTahakkuk() => new(
        Ad: "yatis-tahakkuk",
        YetkiKodu: "yatan",
        Kaynak: "public.yatis_tahakkuk th "
              + "join public.yatis y on y.id = th.yatis_id "
              + "join public.taraf t on t.id = y.hasta_id "
              + "left join public.yatak yk on yk.id = th.yatak_id "
              + "left join public.hizmet hz on hz.id = th.hizmet_id "
              + "left join public.departman d on d.id = y.departman_id",
        SubeKolonu: "th.sube_id",
        VarsayilanSirala: "th.tarih desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "th.id",       "sayi",  "Id", Varsayilan: false),
            new("yatisId",  "th.yatis_id", "sayi",  "Yatış Id", Varsayilan: false),
            new("tarih",    "th.tarih",    "tarih", "Tarih", Hizalama: "orta",
                                           Bicim: "dd.MM.yyyy"),
            new("dosyaNo",  "y.dosya_no",  "metin", "Dosya No", Genislik: 120),
            new("hasta",    "t.unvan",     "metin", "Hasta", Genislik: 200),
            new("yatak",    "coalesce(yk.kod, '')", "metin", "Yatak", Genislik: 100),
            new("klinik",   "coalesce(d.ad, '')",   "metin", "Klinik", Genislik: 150),
            new("kaynakAdi",
                "case th.kaynak when 1 then 'Yatak' when 2 then 'Refakatçi' else '' end",
                                           "metin", "Kalem", Hizalama: "orta", Bicim: "rozet",
                                           Genislik: 110, Filtrelenebilir: false),
            new("kaynak",   "th.kaynak",   "kod",   "Kalem Kodu", Varsayilan: false),
            new("hizmet",   "coalesce(hz.ad, '')",  "metin", "Hizmet", Genislik: 220),
            new("birimFiyat", "th.birim_fiyat", "para", "Birim", Hizalama: "sag", Genislik: 110),
            new("tutar",    "th.tutar",    "para",  "Tutar", Hizalama: "sag", Genislik: 110),
            // FATURALANDI MI: tahakkuk silinmez, işaretlenir - "bu gün neden
            //   faturalandı" sorusunun dayanağı satırda kalmalı.
            // FİLTRELENEBİLİR: listenin asıl işi "faturalanmamış tahakkuk"
            //   çipidir; filtreye kapatmak o çipi işlevsiz bırakıyordu.
            new("faturalandi",
                "case when th.belge_satir_id is not null then 1 else 0 end",
                                           "mantik", "Faturalandı", Hizalama: "orta",
                                           Genislik: 110),
        });
}
