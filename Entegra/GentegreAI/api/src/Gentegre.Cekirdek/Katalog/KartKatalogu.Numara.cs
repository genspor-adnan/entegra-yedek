namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// NUMARA SABLONU KARTI (152) - Genel Ayarlar › Numaralama.
///
/// Dort kart da AYNI tabloya yazar; tek farklari tur secim kutusunun neyi
/// listeledigi. Satis gridinden "Yeni" diyen kullaniciya alis belgelerini
/// gostermemek icin ayri kod tablolari kullanildi - kart tarafinda ek kural
/// yazmaya gerek kalmadi.
///
/// HANE ve BASLANGIC alanlari YOK: ikisi de "Başlama No"dan turetilir
/// (db/152 generated kolon). Kullanici "00000100" yazar; sistem 100'den baslar
/// ve 8 hane yazar - ayrica hane sormak ayni bilgiyi iki kez sormak olurdu.
///
/// BASLAMA TARIHI bugunle dolu gelir: sablon "bu tarihten itibaren gecerli"
/// demektir ve en sik istenen "bugunden itibaren"dir.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi NumaraKarti(string ad, string kodTablosu, string turBaslik) => new(
        Ad: ad,
        YetkiKodu: "numara_sablonu",
        Tablo: "public.numara_sablonu",
        LogTabloId: 918,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,       // 1 = Aktif (154)
            ["baslamaTarihi"] = "@simdi",
            ["baslamaNo"] = "000001",
        },
        Alanlar: new KartAlani[]
        {
            new("id",  "id",  "sayi", Yazilabilir: false),
            new("tur", "tur", "kod",  Zorunlu: true, KodTablosu: kodTablosu,
                Baslik: turBaslik, Grup: "Numaralama"),
            // Bu tarihten ITIBAREN kesilen belgeler bu satirin numaralamasini
            //   kullanir; daha eski belgeler onceki satiri korur.
            new("baslamaTarihi", "baslama_tarihi", "tarih", Zorunlu: true,
                Baslik: "Başlama", Grup: "Numaralama"),
            // Numaranin onune eklenir ("A-"); bos birakilabilir.
            new("onEk", "on_ek", "metin", EnFazlaUzunluk: 20,
                Baslik: "Ön Ek", Grup: "Numaralama"),
            // Ornek numara: hem baslangic degeri hem hane sayisi.
            new("baslamaNo", "baslama_no", "metin", Zorunlu: true, EnFazlaUzunluk: 30,
                Baslik: "Başlama No", Grup: "Numaralama"),
            // Bos ise tum subeler; sube secilirse o subede bu satir onceliklidir.
            new("subeId", "sube_id", "kod", KodTablosu: "public.sube",
                Baslik: "Şube", Grup: "Numaralama"),
            // NUMARAYI KIM VERIR (358): kapali = sistem uretir (on ek + hane +
            //   sayac), acik = kullanici elle yazar. Hasta dosya no ve basvuru
            //   protokol no ayarlari da burada tutulur - ayri bir "otomatik mi"
            //   ayari yok, numara ile ilgili her sey tek tabloda.
            new("elleGirilir", "elle_girilir", "mantik",
                Baslik: "Numarayı kullanıcı elle yazsın", Grup: "Numaralama"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Numaralama"),
            new("durum", "durum", "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Numaralama")
        });

    /// <summary>
    /// e-BELGE SERI KURALI (156). Delphi'deki "Seri Bilgileri" grid satiri.
    /// Senaryo ve Kullanici BOS birakilabilir: 0 = "farketmez / tum
    /// kullanicilar" demektir, kural o zaman genel gecerli olur.
    /// </summary>
    private static KartTanimi EBelgeSeri() => new(
        Ad: "ebelge-seri",
        YetkiKodu: "ebelge_seri",
        Tablo: "public.ebelge_seri",
        LogTabloId: 919,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["senaryo"] = (short)0,
            ["kullaniciId"] = 0,
            ["sira"] = (short)0,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("belgeTuru", "belge_turu", "kod", Zorunlu: true,
                KodTablosu: "public.v_ebelge_turu_lookup",
                Baslik: "e-Belge Türü", Grup: "Seri"),
            new("seri", "seri", "metin", Zorunlu: true, EnFazlaUzunluk: 10,
                Baslik: "Seri", Grup: "Seri"),
            new("senaryo", "senaryo", "kod", SabitKodlar: EBelgeSenaryoKodlari,
                Baslik: "Senaryo", Grup: "Seri"),
            new("kullaniciId", "kullanici_id", "kod", KodTablosu: "public.v_kullanici_lookup",
                Baslik: "Kullanıcı", Grup: "Seri"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Seri"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Seri"),
            new("durum", "durum", "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Seri")
        });

    private static KartTanimi NumaraHasta() =>
        NumaraKarti("numara-hasta", "public.v_numara_turu_kimlik", "Numara Türü");
    private static KartTanimi NumaraBasvuru() =>
        NumaraKarti("numara-basvuru", "public.v_numara_turu_kimlik", "Numara Türü");
    private static KartTanimi NumaraSatis() =>
        NumaraKarti("numara-satis", "public.v_numara_turu_satis", "Satış Belgesi Türü");
    private static KartTanimi NumaraAlis() =>
        NumaraKarti("numara-alis", "public.v_numara_turu_alis", "Alış Belgesi Türü");
    private static KartTanimi NumaraTahsilat() =>
        NumaraKarti("numara-tahsilat", "public.v_numara_turu_tahsilat", "Tahsilat Türü");
    private static KartTanimi NumaraOdeme() =>
        NumaraKarti("numara-odeme", "public.v_numara_turu_odeme", "Ödeme Türü");
}
