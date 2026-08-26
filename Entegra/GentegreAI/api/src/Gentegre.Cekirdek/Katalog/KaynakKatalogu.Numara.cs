namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// NUMARALAMA (152) - Genel Ayarlar › Numaralama ekranindaki dort grid.
///
/// Dordu de AYNI tabloyu (numara_sablonu) okur; ayrimi kaynak tanimindaki
/// tur suzgeci yapar. Ekran tarafinda sabit filtre kurmak yerine kaynagin
/// kendisi suzuyor: kullanicinin gonderdigi filtre SQL'e girmez (§ katalog
/// ilkesi) ve "satis gridine alis belgesi dustu" gibi bir kaza olamaz.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Numaralama gridlerinin ortak kolonlari - dordunde de ayni.</summary>
    private static KolonTanimi[] NumaraKolonlari() =>
    [
        new("id",            "n.id",              "sayi",  "Id", Varsayilan: false),
        new("tur",           "n.tur",             "sayi",  "Tur Kodu", Varsayilan: false),
        new("turAdi",        "t.ad",              "metin", "Tür", Genislik: 200),
        new("baslamaTarihi", "n.baslama_tarihi",  "tarih", "Başlama", Hizalama: "orta"),
        new("onEk",          "n.on_ek",           "metin", "Ön Ek", Hizalama: "orta", Genislik: 90),
        new("baslamaNo",     "n.baslama_no",      "metin", "Başlama No", Hizalama: "orta", Genislik: 120),
        // Hane kullanicinin yazdigi ornekten TURETILIR - bilgi olsun diye durur,
        //   varsayilan kolonlarda degil.
        new("hane",          "n.hane",            "sayi",  "Hane", Hizalama: "orta", Varsayilan: false),
        new("subeAdi",       "s.ad",              "metin", "Şube", Varsayilan: false),
        // SON SUTUN: durum rozeti (kullanici). "kod" tipli 0/1 kolonu gridHucre
        //   otomatik yesil "Aktif" / kirmizi "Pasif" olarak cizer.
        new("durum",         "n.durum",           "kod",   "Durum", Hizalama: "orta")
    ];

    /// <summary>
    /// Numara sablonu kaynagi. <paramref name="turSuzgeci"/> hangi tur kumesinin
    /// listelenecegini soyler (satis / alis / tahsilat / odeme).
    /// </summary>
    private static KaynakTanimi NumaraKaynagi(string ad, string turSuzgeci) => new(
        Ad: ad,
        YetkiKodu: "numara_sablonu",
        Kaynak: $"""
            public.numara_sablonu n
              join public.kasa_islem_turu t on t.kod = n.tur
              left join public.sube s on s.id = n.sube_id
            """,
        // En yeni sablon ustte: yururlukte olan hangisiyse once o gorunur.
        VarsayilanSirala: "t.ad asc, n.baslama_tarihi desc",
        SabitKosul: $"n.tur in ({turSuzgeci})",
        Kolonlar: NumaraKolonlari());

    // Kod kumeleri db/152'deki gorunumlerle AYNI olmali - biri degisirse oteki de
    //   degismeli (grid listeler, kart secim kutusunu doldurur).
    private const string NumaraSatisTurleri    = "13, 14, 15, 16, 19, 119";
    private const string NumaraAlisTurleri     = "8, 9, 10, 11, 12, 17, 109";
    private const string NumaraTahsilatTurleri = "21, 22, 23, 24, 25, 26";
    private const string NumaraOdemeTurleri    = "31, 32, 33, 34, 35, 36, 87";

    /// <summary>
    /// e-BELGE SERI KURALLARI (156) - Delphi'deki "Seri Bilgileri" gridi.
    /// Belgenin IC numarasi degil, GIB'e giden SERI kodu.
    /// </summary>
    /// <summary>
    /// Seri kurallari gridinde kolon enleri (kullanici): tur/seri/senaryo/kullanici
    /// AYNI ende, Sira ve Durum DAR - ikisi de kisa deger tasiyor, genis kolonda
    /// ortada yalniz basina duruyordu.
    /// </summary>
    /// <summary>
    /// e-BELGE XSLT SABLONLARI (160). Ayri tablo YOK: sablonlar merkezi
    /// `dokuman` deposunda durur - ad, boyut, hash, varsayilan, audit ve dosya
    /// yukleme/indirme altyapisi orada hazir.
    ///
    ///     kaynak = 'ebelge-xslt' · kaynak_id = belge turu kodu · yon 1/2
    /// </summary>
    private static KaynakTanimi EBelgeXslt() => new(
        Ad: "ebelge-xslt",
        YetkiKodu: "ebelge_xslt",
        Kaynak: "public.dokuman d",
        SabitKosul: "d.kaynak = 'ebelge-xslt'",
        VarsayilanSirala: "d.kaynak_id asc, d.yon asc, d.varsayilan desc, d.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "d.id",         "sayi",  "Id", Varsayilan: false),
            // Turun okunur adi dokumanda saklı; rozet olarak cizilir.
            new("belgeTuru", "d.belge_turu", "metin", "e-Belge Türü",
                                             Hizalama: "orta", Bicim: "rozet", Genislik: SeriKolonEni),
            new("yon",       "case d.yon when 1 then 'Gelen' else 'Giden' end",
                                             "metin", "Yön", Hizalama: "orta", Genislik: SeriDarKolon),
            new("ad",        "d.ad",         "metin", "Şablon Adı", Genislik: 260),
            new("varsayilan","d.varsayilan", "mantik","Varsayılan", Hizalama: "orta",
                                             Genislik: SeriDarKolon),
            new("boyut",     "d.boyut",      "sayi",  "Boyut", Hizalama: "sag",
                                             Genislik: SeriDarKolon),
            new("turKodu",   "d.kaynak_id",  "sayi",  "Tür Kodu", Varsayilan: false)
        });

    /// <summary>
    /// FIRMA / SUBE listesi - e-Belgede gonderici taraf (KartKatalogu.Firma).
    /// e-Belge icin ZORUNLU alanlarin dolu olup olmadigi listede gorunur.
    /// </summary>
    private static KaynakTanimi Sube() => new(
        Ad: "sube",
        YetkiKodu: "sube",
        Kaynak: """
            public.sube s
              left join public.ebelge_entegrator ent on ent.id = s.entegrator_id
            """,
        VarsayilanSirala: "s.varsayilan desc, s.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "s.id",       "sayi",  "Id", Varsayilan: false),
            new("kod",      "s.kod",      "metin", "Kod", Genislik: 80),
            new("ad",       "s.ad",       "metin", "Şube", Genislik: 160),
            new("unvan",    "s.unvan",    "metin", "Resmî Unvan", Genislik: 260),
            new("vkno",     "s.vkno",     "metin", "VKN / TCKN", Hizalama: "orta"),
            new("vd",       "s.vd",       "metin", "Vergi Dairesi", Varsayilan: false),
            new("il",       "s.il",       "metin", "İl", Hizalama: "orta"),
            new("efaturaAlias", "s.efatura_alias", "metin", "Gönderici Etiketi", Varsayilan: false),
            // Sube kendi kimligiyle mi merkezin kimligiyle mi gonderiyor (169).
            new("ebelgeKimlikAdi",
                """
                case s.ebelge_kimlik when 2 then 'Merkez'
                                     when 3 then 'Merkez kimliği + şube adresi'
                                     else 'Kendi' end
                """,                      "metin", "Gönderici Kimliği",
                                          Genislik: 190, Filtrelenebilir: false),
            // e-Belge gonderimi icin gereken alanlar tam mi - eksikse gonderim
            //   dogrulamasi durur, sebebi listede bir bakista gorunsun. Merkez
            //   kimligi kullanan sube kendi VKN'si olmadan da "Tamam" olabilir,
            //   o yuzden kontrol gorunumden (169) gelir.
            new("ebelgeHazir",
                """
                case when public.fn_sube_ebelge_hazir(s.id) then 'Tamam' else 'Eksik' end
                """,                      "metin", "e-Belge Bilgileri",
                                          Hizalama: "orta", Bicim: "rozet", Genislik: 130,
                                          Siralanabilir: false, Filtrelenebilir: false),
            // Mukellef hesabi (171): hangi entegrator, hangi ortam.
            new("entegratorAdi", "coalesce(ent.ad, '')", "metin", "Entegratör",
                                          Genislik: 140, Filtrelenebilir: false),
            new("testOrtami",    "s.test_ortami",        "kod",   "Test Ortamı",
                                          Hizalama: "orta", Varsayilan: false),
            new("varsayilan","s.varsayilan","mantik","Varsayılan", Hizalama: "orta", Varsayilan: false),
            new("aktif",    "s.aktif",    "kod",   "Durum", Hizalama: "orta")
        });

    private const int SeriKolonEni = 140;
    private const int SeriDarKolon = 70;

    private static KaynakTanimi EBelgeSeri() => new(
        Ad: "ebelge-seri",
        YetkiKodu: "ebelge_seri",
        Kaynak: """
            public.ebelge_seri e
              left join public.v_kullanici_lookup k on k.id = e.kullanici_id
            """,
        VarsayilanSirala: "e.belge_turu asc, e.sira asc, e.seri asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "e.id",           "sayi",  "Id", Varsayilan: false),
            new("belgeTuru", """
                case e.belge_turu when 1 then 'e-Fatura' when 2 then 'e-Arşiv'
                                  when 7 then 'e-İrsaliye' else '' end
                """,                           "metin", "e-Belge Türü",
                                               Hizalama: "orta", Bicim: "rozet", Genislik: SeriKolonEni),
            new("seri",      "e.seri",         "metin", "Seri", Hizalama: "orta", Genislik: SeriKolonEni),
            // 0 = farketmez: senaryo ayrimi olmayan kural her senaryoda gecerli.
            new("senaryo",   """
                case e.senaryo when 1 then 'Temel' when 2 then 'Ticari'
                               when 8 then 'İlaç / Tıbbi' else '(farketmez)' end
                """,                           "metin", "Senaryo", Genislik: SeriKolonEni),
            new("kullaniciAdi",
                "coalesce(nullif(k.ad, ''), '(tüm kullanıcılar)')",
                                               "metin", "Kullanıcı", Genislik: SeriKolonEni),
            new("sira",      "e.sira",         "sayi",  "Sıra", Hizalama: "orta", Genislik: SeriDarKolon),
            new("durum",     "e.durum",        "kod",   "Durum", Hizalama: "orta", Genislik: SeriDarKolon)
        });

    private static KaynakTanimi NumaraSatis()    => NumaraKaynagi("numara-satis", NumaraSatisTurleri);
    private static KaynakTanimi NumaraAlis()     => NumaraKaynagi("numara-alis", NumaraAlisTurleri);
    private static KaynakTanimi NumaraTahsilat() => NumaraKaynagi("numara-tahsilat", NumaraTahsilatTurleri);
    private static KaynakTanimi NumaraOdeme()    => NumaraKaynagi("numara-odeme", NumaraOdemeTurleri);
}
