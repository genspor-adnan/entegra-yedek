namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ACİL SERVİS (716) — üç liste:
///   `acilBasvuru` triyaj bekleyen + acil içindeki hastalar (tek kaynak, çiple ayrılır)
///   `acilCagri`   konsültasyon ve kod çağrıları
///   `acilYatak`   acil yatak tanımları (ayar)
///
/// TRİYAJ SIRALAMASI VARSAYILAN. Acil servisin tek kuralı budur; geliş sırasına
/// göre sıralasaydık ekran, yapılması gereken işin tersini gösterirdi.
///
/// SÜRELER `v_acil_sure` GÖRÜNÜMÜNDEN OKUNUR, burada yeniden hesaplanmaz.
/// Hesap iki yerde olsaydı "kapı-hekim" panoda 16, dökümde 18 dakika çıkardı.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi AcilBasvuru() => new(
        Ad: "acilBasvuru",
        YetkiKodu: "acil.triyaj",
        Kaynak: "public.acil_basvuru b" +
                " join public.v_acil_sure v on v.basvuru_id = b.id" +
                " left join public.taraf h on h.id = b.hasta_id" +
                " left join public.acil_yatak y on y.id = b.yatak_id" +
                " left join public.taraf d on d.id = b.hekim_id",
        SubeKolonu: "b.sube_id",
        // Triyaj 0 (henüz triyajlanmamış) en başta: sıralamada 0 zaten en küçük.
        VarsayilanSirala: "b.triyaj, b.giris_zamani",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "b.id",          "sayi",  "Id", Varsayilan: false),
            new("protokolNo", "b.protokol_no", "metin", "Protokol", Genislik: 130),
            // KİMLİKSİZ hastada taraf kaydı yok; geçici ad gösterilir. İki ayrı
            //   kolon yapsaydık listede biri hep boş dururdu.
            new("hastaAd",
                "case when b.kimliksiz = 1 then coalesce(nullif(b.gecici_ad, ''), 'Kimliksiz')" +
                " else coalesce(h.unvan, '') end",
                "metin", "Hasta", Genislik: 200,
                Siralanabilir: false, Filtrelenebilir: false),
            new("hastaId",    "b.hasta_id",    "sayi",  "Hasta Id", Varsayilan: false),
            new("kimliksiz",  "b.kimliksiz",   "kod",   "Kimliksiz", Hizalama: "orta",
                Genislik: 95, Kodlar: AcEvetHayirKodlari),
            new("triyaj",     "b.triyaj",      "kod",   "Triyaj", Hizalama: "orta",
                Genislik: 90, Kodlar: AcTriyajKodlari),
            new("triyajAdi",
                "case b.triyaj when 1 then 'Kırmızı' when 2 then 'Turuncu'" +
                " when 3 then 'Sarı' when 4 then 'Yeşil' when 5 then 'Mavi'" +
                " else 'Triyaj bekliyor' end",
                "metin", "Triyaj Adı", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Siralanabilir: false, Filtrelenebilir: false),
            new("sikayet",    "b.sikayet",     "metin", "Şikâyet", Genislik: 330),
            new("gelisAdi",
                "case b.gelis_sekli when 1 then 'Kendi imkânı' when 2 then '112 ambulans'" +
                " when 3 then 'Özel ambulans' when 4 then 'Polis/Jandarma'" +
                " when 5 then 'Sevk' else 'Diğer' end",
                "metin", "Geliş", Hizalama: "orta", Genislik: 120,
                Siralanabilir: false, Filtrelenebilir: false),
            new("gelisSekli", "b.gelis_sekli", "kod",   "Geliş Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AcGelisKodlari),
            new("girisZamani","b.giris_zamani","zaman", "Geliş Saati", Hizalama: "orta",
                Bicim: "dd.MM HH:mm", Genislik: 115),
            new("yatakKod",   "coalesce(y.kod, '')", "metin", "Yatak", Hizalama: "orta",
                Genislik: 85, Siralanabilir: false, Filtrelenebilir: false),
            new("hekimAd",    "coalesce(d.unvan, '')", "metin", "Hekim", Genislik: 150,
                Siralanabilir: false, Filtrelenebilir: false),
            // v_acil_sure'den - burada yeniden hesaplanmaz (bkz sınıf başlığı).
            new("toplamDk",   "v.toplam_dk",   "sayi",  "Süre (dk)", Hizalama: "sag",
                Genislik: 95, Siralanabilir: false, Filtrelenebilir: false),
            new("kapiHekimDk","v.kapi_hekim_dk","sayi", "Kapı→Hekim", Hizalama: "sag",
                Genislik: 105, Siralanabilir: false, Filtrelenebilir: false),
            new("hedefDk",    "v.hedef_dk",    "sayi",  "Hedef (dk)", Hizalama: "sag",
                Genislik: 95, Siralanabilir: false, Filtrelenebilir: false),
            // HEDEF DURUMU: hekim görmediyse "bekliyor / aşıldı" ayrımı, gördüyse
            //   uyuldu mu. Tek bayrak olsaydı henüz görülmemiş hasta "uyulmadı"
            //   sayılır ve daha ilk dakikada kırmızı görünürdü.
            new("hedefDurum",
                "case when v.hedefe_uyuldu = 1 then 'Uyuldu'" +
                "     when v.hedefe_uyuldu = 0 then 'Aşıldı'" +
                "     when v.hedef_dk is null then ''" +
                "     when v.toplam_dk > v.hedef_dk then 'Aşıldı'" +
                "     else 'Bekliyor' end",
                "metin", "Hedef Durumu", Hizalama: "orta", Genislik: 115, Bicim: "rozet",
                Siralanabilir: false, Filtrelenebilir: false),
            new("adliVaka",   "b.adli_vaka",   "kod",   "Adli", Hizalama: "orta",
                Genislik: 80, Kodlar: AcEvetHayirKodlari),
            new("cikisAdi",
                "case b.cikis_sekli when 0 then '' when 1 then 'Taburcu'" +
                " when 2 then 'Servise yatış' when 3 then 'Yoğun bakım' when 4 then 'Sevk'" +
                " when 5 then 'Ölüm' when 6 then 'Kendi isteğiyle' when 7 then 'Ameliyathane'" +
                " else '' end",
                "metin", "Çıkış", Hizalama: "orta", Genislik: 120,
                Siralanabilir: false, Filtrelenebilir: false),
            new("cikisSekli", "b.cikis_sekli", "kod",   "Çıkış Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AcCikisKodlari),
            new("cikisZamani","b.cikis_zamani","zaman", "Çıkış Saati", Hizalama: "orta",
                Bicim: "dd.MM HH:mm", Varsayilan: false),
            new("cikisTani",  "b.cikis_tani",  "metin", "Çıkış Tanısı", Hizalama: "orta",
                Genislik: 110, Varsayilan: false),
            // Açık/kapalı ayrımı çiple süzülür; "acil içinde" listesi bu.
            new("acik",
                "case when b.cikis_zamani is null then 1 else 0 end",
                "kod", "Açık", Hizalama: "orta", Varsayilan: false,
                Siralanabilir: false, Kodlar: AcEvetHayirKodlari),
            new("subeId",     "b.sube_id",     "sayi",  "Şube", Varsayilan: false),
        });

    /// <summary>Konsültasyon ve kod çağrıları — yanıt süresiyle.</summary>
    private static KaynakTanimi AcilCagri() => new(
        Ad: "acilCagri",
        YetkiKodu: "acil.pano",
        Kaynak: "public.acil_cagri c" +
                " left join public.acil_basvuru b on b.id = c.basvuru_id" +
                " left join public.taraf h on h.id = b.hasta_id" +
                " left join public.departman d on d.id = c.hedef_bolum_id",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.cagri_zamani desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "c.id",           "sayi",  "Id", Varsayilan: false),
            new("turAdi",
                "case c.tur when 1 then 'Konsültasyon' when 2 then 'Mavi Kod'" +
                " when 3 then 'Beyaz Kod' when 4 then 'Pembe Kod' when 5 then 'Kateter Lab'" +
                " when 6 then 'Ameliyathane' when 7 then 'Yoğun Bakım' else '' end",
                "metin", "Çağrı", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tur",       "c.tur",          "kod",   "Çağrı Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AcCagriTurKodlari),
            new("protokolNo","coalesce(b.protokol_no, '')", "metin", "Protokol",
                Genislik: 130, Siralanabilir: false, Filtrelenebilir: false),
            new("hastaAd",
                "case when b.kimliksiz = 1 then coalesce(nullif(b.gecici_ad, ''), 'Kimliksiz')" +
                " else coalesce(h.unvan, '') end",
                "metin", "Hasta", Genislik: 185,
                Siralanabilir: false, Filtrelenebilir: false),
            new("bolumAd",   "coalesce(d.ad, '')", "metin", "Hedef Bölüm", Genislik: 160,
                Siralanabilir: false, Filtrelenebilir: false),
            new("cagriZamani","c.cagri_zamani", "zaman", "Çağrı", Hizalama: "orta",
                Bicim: "dd.MM HH:mm", Genislik: 115),
            // YANIT SÜRESİ çağrının asıl ölçüsü: "çağırdık" ile "geldi"
            //   arasındaki fark ölçülmedikçe 85 dakikalık bekleme kimsenin
            //   sorunu olmuyor. Yanıt yoksa şimdiye kadar geçen süre yazılır.
            new("yanitDk",
                "round(extract(epoch from (coalesce(c.yanit_zamani, now()) - c.cagri_zamani)) / 60)",
                "sayi", "Yanıt (dk)", Hizalama: "sag", Genislik: 100,
                Siralanabilir: false, Filtrelenebilir: false),
            new("durumAdi",
                "case c.durum when 0 then 'Bekliyor' when 1 then 'Yanıtlandı'" +
                " when 2 then 'Kapandı' when 3 then 'Yanıt yok' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum",     "c.durum",        "kod",   "Durum Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AcCagriDurumKodlari),
            new("tekrarSayi","c.tekrar_sayi",  "sayi",  "Tekrar", Hizalama: "sag",
                Genislik: 80),
            new("notMetni",  "c.not_metni",    "metin", "Not", Genislik: 240,
                Varsayilan: false),
            new("subeId",    "c.sube_id",      "sayi",  "Şube", Varsayilan: false),
        });

    private static KaynakTanimi AcilYatak() => new(
        Ad: "acilYatak",
        YetkiKodu: "acil.yatak",
        Kaynak: "public.acil_yatak y",
        SubeKolonu: "y.sube_id",
        VarsayilanSirala: "y.alan, y.sira, y.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "y.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",    "y.kod",  "metin", "Yatak", Genislik: 100),
            new("ad",     "y.ad",   "metin", "Ad", Genislik: 180),
            new("alanAdi",
                "case y.alan when 1 then 'Resüsitasyon' when 2 then 'Müşahede'" +
                " when 3 then 'Yeşil alan' when 4 then 'İzolasyon' when 5 then 'Travma'" +
                " else '' end",
                "metin", "Alan", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("alan",   "y.alan", "kod",   "Alan Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AcAlanKodlari),
            new("durumAdi",
                "case y.durum when 0 then 'Boş' when 1 then 'Dolu'" +
                " when 2 then 'Temizlikte' when 3 then 'Arızalı' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum",  "y.durum","kod",   "Durum Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AcYatakDurumKodlari),
            new("sira",   "y.sira", "sayi",  "Sıra", Hizalama: "sag", Genislik: 70),
            new("aktif",  "y.aktif","kod",   "Aktif", Hizalama: "orta", Genislik: 80,
                Kodlar: AcEvetHayirKodlari),
            new("subeId", "y.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    private static readonly Dictionary<string, string> AcTriyajKodlari = new()
    {
        ["1"] = "1 Kırmızı (resüsitasyon)", ["2"] = "2 Turuncu (acil)",
        ["3"] = "3 Sarı (acele)", ["4"] = "4 Yeşil (az acil)", ["5"] = "5 Mavi (acil değil)",
        ["0"] = "Triyaj bekliyor",
    };

    private static readonly Dictionary<string, string> AcGelisKodlari = new()
    {
        ["1"] = "Kendi imkânı", ["2"] = "112 ambulans", ["3"] = "Özel ambulans",
        ["4"] = "Polis/Jandarma", ["5"] = "Sevk", ["9"] = "Diğer",
    };

    private static readonly Dictionary<string, string> AcCikisKodlari = new()
    {
        ["1"] = "Taburcu", ["2"] = "Servise yatış", ["3"] = "Yoğun bakım", ["4"] = "Sevk",
        ["5"] = "Ölüm", ["6"] = "Kendi isteğiyle", ["7"] = "Ameliyathane",
    };

    private static readonly Dictionary<string, string> AcCagriTurKodlari = new()
    {
        ["1"] = "Konsültasyon", ["2"] = "Mavi Kod", ["3"] = "Beyaz Kod",
        ["4"] = "Pembe Kod", ["5"] = "Kateter Lab", ["6"] = "Ameliyathane",
        ["7"] = "Yoğun Bakım",
    };

    private static readonly Dictionary<string, string> AcCagriDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Yanıtlandı", ["2"] = "Kapandı", ["3"] = "Yanıt yok",
    };

    private static readonly Dictionary<string, string> AcAlanKodlari = new()
    {
        ["1"] = "Resüsitasyon", ["2"] = "Müşahede", ["3"] = "Yeşil alan",
        ["4"] = "İzolasyon", ["5"] = "Travma",
    };

    private static readonly Dictionary<string, string> AcYatakDurumKodlari = new()
    {
        ["0"] = "Boş", ["1"] = "Dolu", ["2"] = "Temizlikte", ["3"] = "Arızalı",
    };

    private static readonly Dictionary<string, string> AcEvetHayirKodlari = new()
    {
        ["1"] = "Evet", ["0"] = "Hayır",
    };
}
