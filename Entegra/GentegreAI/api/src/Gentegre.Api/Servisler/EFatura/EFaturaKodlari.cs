namespace Gentegre.Api.Servisler.EFatura;

/// <summary>
/// GİDEN e-FATURA SABİTLERİ ve DURUM KURALLARI - tek yer.
///
/// KAYNAK: Delphi UEBelgeOlusturucu (SenaryoProfilKodu, FaturaTipKodu,
/// GonderilmisEngeli) ve UFaturalar e-Fatura menüsünün enable kuralları.
/// Menü (web), liste kombosu (AksiyonUclari) ve servis aynı kuralı buradan
/// okur - üç yerde ayrı yazılınca "menüde açık, sunucu reddediyor" oluyordu.
///
/// belge.efatura_durum: 0 hazırlanmadı · 1 e-Fatura hazır · 2 e-Fatura gönderildi ·
///                      11 e-Arşiv hazır · 12 e-Arşiv gönderildi (51/52 e-İrsaliye).
/// belge.efatura_sonuc (Delphi EFATURASONUC): 0 yeni · 3 hata · 9 GİB'e gönderildi.
/// e_belge.belge_turu: 1 e-Fatura · 2 e-Arşiv.
/// </summary>
public static class EFaturaKodlari
{
    public const short TurEFatura = 1;
    public const short TurEArsiv = 2;

    public const short SonucYeni = 0;
    public const short SonucHata = 3;
    public const short SonucGonderildi = 9;

    /// <summary>e-Fatura kesilen belge türleri: satış faturası (15).</summary>
    public static bool FaturaMi(int tur) => tur == 15;

    public static bool Hazir(int durum) => durum is 1 or 11;
    public static bool Gonderildi(int durum) => durum is 2 or 12 or 52;

    public static short HazirDurum(short eTur) => eTur == TurEArsiv ? (short)11 : (short)1;
    public static short GonderildiDurum(short eTur) => eTur == TurEArsiv ? (short)12 : (short)2;
    public static short ETur(int durum) => durum is 11 or 12 ? TurEArsiv : TurEFatura;

    public static string TurAdi(int durum) => durum switch
    {
        1 or 2 => "e-Fatura",
        11 or 12 => "e-Arşiv",
        51 or 52 => "e-İrsaliye",
        _ => "e-Fatura",
    };

    public static string DurumAdi(int durum, int sonuc) => durum switch
    {
        0 => "Taslak",
        1 or 11 => sonuc == SonucHata ? "Hazır · gönderim hatası" : "Hazır",
        2 or 12 => "Gönderildi",
        _ => "",
    };

    /// <summary>
    /// MENÜ KURALI (Delphi MenuHazirla / MenuGonder / MenuSifirla / MenuSeriDegistir /
    /// MenuDosyaKaydet). Pasif maddenin SEBEBİ döner; null = aktif.
    /// </summary>
    public static string? Engel(string kod, int tur, int belgeDurum, int efaturaDurum)
    {
        if (!FaturaMi(tur)) return "e-Fatura yalnız satış faturasında kesilir.";
        var adi = TurAdi(efaturaDurum);
        var hazir = Hazir(efaturaDurum);
        var gonderildi = Gonderildi(efaturaDurum);
        return kod switch
        {
            "ebelge.hazirla" when gonderildi => $"{adi} zaten gönderilmiş.",
            "ebelge.hazirla" when hazir => $"{adi} zaten hazırlanmış. Değiştirmek için \"Seri Değiştir\" ya da \"Hazırı Geri Al\".",
            "ebelge.hazirla" or "ebelge.onizle" when belgeDurum == 2 => "İptal edilmiş belge için e-Fatura hazırlanamaz.",
            "ebelge.gonder" when gonderildi => $"{adi} zaten gönderilmiş.",
            "ebelge.gonder" when !hazir => "Önce \"Hazırla\" ile e-Fatura oluşturun.",
            "ebelge.seri" when gonderildi => $"{adi} gönderilmiş; serisi değiştirilemez.",
            "ebelge.seri" when belgeDurum == 2 => "İptal edilmiş belge.",
            "ebelge.sifirla" when gonderildi => $"{adi} gönderilmiş; geri alınamaz. Düzeltme iade faturasıyla yapılır.",
            "ebelge.sifirla" when !hazir => "Hazırlanmış e-Fatura yok.",
            "ebelge.pdf" or "ebelge.html" or "ebelge.xml" when efaturaDurum == 0 => "Önce \"Hazırla\" ile e-Fatura oluşturun.",
            _ => null,
        };
    }

    /// <summary>Delphi SenaryoProfilKodu.</summary>
    public static string Profil(bool arsiv, int senaryo) => arsiv
        ? "EARSIVFATURA"
        : senaryo switch
        {
            2 => "TICARIFATURA",
            3 => "IHRACAT",
            7 => "KAMU",
            8 => "ILAC_TIBBICIHAZ",
            _ => "TEMELFATURA",
        };

    /// <summary>Delphi FaturaTipKodu (belge.tipi -> GİB fatura tipi). İhracat profili ISTISNA.</summary>
    public static string FaturaTipi(int tipi, string profil) => profil == "IHRACAT"
        ? "ISTISNA"
        : tipi switch
        {
            2 => "IADE",
            9 => "IHRACKAYITLI",
            22 => "TEVKIFAT",
            24 => "ISTISNA",
            25 => "SGK",
            _ => "SATIS",
        };

    /// <summary>Birim -> UN/ECE rec 20 (eski fn_ebelge_birim_kodu ile aynı eşleme).</summary>
    public static string BirimKodu(int birim) => birim switch
    {
        10 => "MIN", 11 => "HUR", 12 => "DAY", 51 => "C62", 52 => "MTR", 53 => "CS",
        54 or 55 => "SET", 56 => "BX", 57 => "KGM", 58 => "MTK", 59 => "PF",
        _ => "C62",
    };

    /// <summary>Delphi ParaBirimiTRYmi + sembol normalleştirme.</summary>
    public static string ParaKodu(string? doviz) => (doviz ?? "").Trim().ToUpperInvariant() switch
    {
        "" or "TL" or "₺" or "TRL" or "YTL" => "TRY",
        "$" => "USD",
        "€" => "EUR",
        "£" => "GBP",
        var k => k,
    };

    /// <summary>10 hane VKN, 11 hane TCKN (Delphi şema seçimi hane sayısından).</summary>
    public static string KimlikSemasi(string vkno) => Rakam(vkno).Length == 11 ? "TCKN" : "VKN";

    public static string Rakam(string? s) => new((s ?? "").Where(char.IsDigit).ToArray());

    /// <summary>
    /// Delphi KisiAdSoyadAyir: son kelime soyad, kalanı ad.
    /// </summary>
    public static (string Ad, string Soyad) AdSoyad(string adSoyad)
    {
        var p = (adSoyad ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries);
        return p.Length switch
        {
            0 => ("", ""),
            1 => (p[0], p[0]),
            _ => (string.Join(' ', p[..^1]), p[^1]),
        };
    }

    // ------------------------------------------------- ihracat kod listeleri --
    /// <summary>INCOTERMS 2020 (GİB DeliveryTerms schemeID=INCOTERMS).</summary>
    public static readonly (string Kod, string Ad)[] TeslimSartlari =
    [
        ("EXW", "EXW - İşyerinde Teslim"), ("FCA", "FCA - Taşıyıcıya Teslim"),
        ("FAS", "FAS - Gemi Doğrultusunda Teslim"), ("FOB", "FOB - Gemide Teslim"),
        ("CFR", "CFR - Masraflar ve Navlun Ödenmiş"), ("CIF", "CIF - Masraflar, Sigorta ve Navlun Ödenmiş"),
        ("CPT", "CPT - Taşıma Ücreti Ödenmiş"), ("CIP", "CIP - Taşıma ve Sigorta Ödenmiş"),
        ("DAP", "DAP - Belirlenen Yerde Teslim"), ("DPU", "DPU - Boşaltılmış Olarak Teslim"),
        ("DDP", "DDP - Gümrük Vergileri Ödenmiş Teslim"),
    ];

    /// <summary>GİB taşıma şekli (TransportModeCode).</summary>
    public static readonly (int Kod, string Ad)[] TasimaSekilleri =
    [
        (1, "1 - Denizyolu"), (2, "2 - Demiryolu"), (3, "3 - Karayolu"), (4, "4 - Havayolu"),
        (5, "5 - Posta"), (6, "6 - Çok Araçlı"), (7, "7 - Sabit Taşıma Tesisleri"),
        (8, "8 - İç Su Taşımacılığı"), (9, "9 - Geçerli Taşıma Şekli Yok"),
    ];

    /// <summary>Kap cinsi (UN/ECE rec 21, GİB PackagingTypeCode) - sık kullanılanlar.</summary>
    public static readonly (string Kod, string Ad)[] KapCinsleri =
    [
        ("BX", "BX - Kutu"), ("CT", "CT - Karton"), ("PK", "PK - Paket"), ("PX", "PX - Palet"),
        ("BG", "BG - Torba"), ("SA", "SA - Çuval"), ("CR", "CR - Sandık"), ("CS", "CS - Kasa"),
        ("DR", "DR - Varil"), ("BA", "BA - Fıçı"), ("BL", "BL - Balya"), ("RO", "RO - Rulo"),
        ("CN", "CN - Konteyner"), ("NE", "NE - Ambalajsız"),
    ];

    /// <summary>SGK fatura ilave tipi (GİB SGK senaryosu AccountingCost).</summary>
    public static readonly (string Kod, string Ad)[] SgkTipleri =
    [
        ("SAGLIK_ECZ", "Sağlık - Eczane"), ("SAGLIK_HAS", "Sağlık - Hastane"),
        ("SAGLIK_OPT", "Sağlık - Optik"), ("SAGLIK_MED", "Sağlık - Medikal"),
        ("ABONELIK", "Abonelik"), ("MAL_HIZMET", "Mal / Hizmet"), ("DIGER", "Diğer"),
    ];
}
