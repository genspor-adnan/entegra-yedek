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
        new("durum",         "n.durum",           "kod",   "Durum", Hizalama: "orta", Varsayilan: false)
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

    private static KaynakTanimi NumaraSatis()    => NumaraKaynagi("numara-satis", NumaraSatisTurleri);
    private static KaynakTanimi NumaraAlis()     => NumaraKaynagi("numara-alis", NumaraAlisTurleri);
    private static KaynakTanimi NumaraTahsilat() => NumaraKaynagi("numara-tahsilat", NumaraTahsilatTurleri);
    private static KaynakTanimi NumaraOdeme()    => NumaraKaynagi("numara-odeme", NumaraOdemeTurleri);
}
