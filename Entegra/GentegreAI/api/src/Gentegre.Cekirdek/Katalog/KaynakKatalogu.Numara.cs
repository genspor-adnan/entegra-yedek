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
