namespace Gentegre.Cekirdek.Sigorta;

/// <summary>
/// ÖZEL SAĞLIK SİGORTASI — KANONİK SÖZLEŞME (430).
///
/// <para><b>Sağlayıcının sözlüğü buraya girmez.</b> Her şirket kendi enum'unu
/// konuşuyor (Anadolu <c>OUTPATIENT_TREATMENT</c> derken bir başkası "A", "2"
/// ya da "AYAKTA" diyecek). Uygulamanın tamamı yalnız bu DTO'ları görür;
/// çeviri <c>sigorta_kod_esleme</c> + adapter'da yapılır. Aynı disiplin ÜTS
/// (223-230) ve e-Belge sağlayıcılarında da var - dördüncü bir desen icat
/// edilmiyor.</para>
///
/// <para><b>Tutarlar sağlayıcıdan geldiği gibi taşınır.</b> Yuvarlama ve pay
/// dağıtımı tek yerde (<c>fn_sigorta_pay_dagit</c>); adapter hesap yapmaz,
/// yalnız alan adı çevirir.</para>
/// </summary>
public static class SigortaKanonik
{
    // Kanonik kod uzayları - kod eşlemesindeki `yerel_kod` bunlardır.
    public static class ProvizyonTipi
    {
        public const short Ayakta = 1, Yatarak = 2, Kontrol = 3;
    }

    public static class TalepTuru
    {
        public const short Provizyon = 1, OnProvizyon = 2;
    }

    public static class Durum
    {
        public const short Taslak = 1, Gonderildi = 2, Onayli = 3,
                           Kismi = 4, Red = 5, Iptal = 6;
    }

    public static class SatirTuru
    {
        public const short Islem = 1, Sarf = 2;
    }

    /// <summary>Kod eşleme tablosundaki <c>alan</c> değerleri.</summary>
    public static class Alan
    {
        public const string ProvizyonTipi = "provizyon_tipi";
        public const string YatisTuru     = "yatis_turu";
        public const string HizmetTipi    = "hizmet_tipi";
        public const string VakaTipi      = "vaka_tipi";
        public const string TalepTuru     = "talep_turu";
        public const string HekimUnvani   = "hekim_unvani";
        public const string KimlikTipi    = "kimlik_tipi";
        public const string PoliceTipi    = "police_tipi";
        public const string PoliceTuru    = "police_turu";
        public const string IslemKaynagi  = "islem_kaynagi";
        public const string MalzemeTipi   = "malzeme_tipi";
        public const string IptalNedeni   = "iptal_nedeni";
        public const string DokumanTipi   = "dokuman_tipi";
    }
}

/// <summary>
/// Sağlayıcının neyi desteklediği. Ekranı da bu sürer: paketleme
/// desteklemeyen şirkette "Sigortaya Gönder" düğmesi ÇİZİLMEZ - pasif düğme
/// "neden çalışmıyor" sorusu doğurur.
/// </summary>
public sealed record SaglayiciYetenek(bool Police, bool Provizyon, bool Iptal,
                                      bool Dokuman, bool Paket, bool Ekstre);

/// <summary>Sağlayıcı hesabının çözülmüş hâli (kimlik + adres).</summary>
public sealed record SigortaHesabi(
    int HesapId, short SaglayiciId, string SaglayiciKod, int KurumId,
    string Adres, string KullaniciAdi, string Parola,
    string IstemciId, string IstemciSifre, string KurumKodu, bool TestMi);

// ---------------------------------------------------------------- poliçe ---

public sealed record PoliceIstegi(
    string KimlikNo, short KimlikTipi, string PoliceNo, DateTime Tarih,
    HekimBilgisi Hekim);

public sealed record PoliceSonucu(
    bool Gecerli, string PoliceNo, string PoliceAdi, short PoliceTipi,
    short PoliceTuru, string KartNo, string MusteriNo, string AgKodu,
    IReadOnlyList<string> Notlar, string HamYanit);

// ------------------------------------------------------------- provizyon ---

/// <summary>
/// Hekim, provizyona KOPYALANIR: şirkete gönderilen hâli kayıtta donar,
/// hekim kartı sonradan değişse gönderilen bilgi değişmez.
/// </summary>
public sealed record HekimBilgisi(
    string Ad, string Soyad, string Tckn, string DiplomaNo,
    string BransKodu, string BransAdi, short? Unvan,
    bool Kadro, bool SgkAnlasmasi);

public sealed record SigortaliBilgisi(
    string Ad, string Soyad, DateOnly? DogumTarihi, short Cinsiyet,
    string KimlikNo, short KimlikTipi, string KartNo, string MusteriNo);

public sealed record HastaBilgisi(
    string Sikayet, DateOnly? SikayetTarihi, string Ozgecmis, string FizikMuayene,
    DateOnly? SonAdetTarihi, bool Gebelik,
    DateTime? PlananYatis, DateTime? PlananCikis, DateTime? KabulTarihi);

public sealed record TaniBilgisi(string Kod, string Ad);

/// <summary>
/// Provizyon satırı: işlem ya da sarf. <paramref name="KurumSiraNo"/>
/// (hospitalRowNumber) BİZİM satır kimliğimizdir - yanıttaki kırılım bununla
/// eşleştirilir, sıraya güvenilmez (şirket satırları farklı sırada dönebilir).
/// </summary>
public sealed record ProvizyonSatiri(
    short SatirTuru, string KurumSiraNo, string Kod, string Ad,
    short? Kaynak, short? MalzemeTipi, DateOnly? IslemTarihi,
    decimal Adet, decimal TalepTutar, decimal SgkTutar, decimal KdvOran);

public sealed record ProvizyonIstegi(
    string ProvizyonNo, string KurumRefNo, string TakipNo,
    DateTime ProvizyonTarihi, short Tip, short? AltTip, short? HizmetTipi,
    short VakaTipi, short TalepTuru, bool Acil,
    SigortaliBilgisi Sigortali, string PoliceNo, string PoliceAdi,
    short PoliceTipi, short PoliceTuru, string KartNo,
    HastaBilgisi Hasta, HekimBilgisi Hekim,
    IReadOnlyList<TaniBilgisi> Tanilar,
    IReadOnlyList<ProvizyonSatiri> Satirlar,
    string Not);

/// <summary>Yanıttaki satır kırılımı - belgenin pay dağılımının kaynağı.</summary>
public sealed record ProvizyonSatirSonucu(
    string KurumSiraNo, string Kod, string Ad,
    decimal TalepTutar, decimal SirketTutar, decimal KatilimPayi,
    decimal IstisnaTutar, decimal MuafiyetTutar, decimal LimitUstu,
    decimal Faturalanmaz, decimal UyumsuzTutar, decimal Tevkifat,
    decimal Odenecek, decimal KdvOran, decimal Adet,
    string KapsamKodu, string Kapsam, string KararTipi, string Aciklama);

public sealed record ProvizyonNotu(string Tip, string Metin);

public sealed record ProvizyonSonucu(
    bool Basarili, string ProvizyonNo, string KurumRefNo, short Durum,
    string KararTipi, string RedNedeni, DateTime? Gecerlilik,
    IReadOnlyList<ProvizyonSatirSonucu> Satirlar,
    IReadOnlyList<ProvizyonNotu> Notlar,
    string HamIstek, string HamYanit, string Hata);

public sealed record IptalIstegi(string ProvizyonNo, short NedenKodu,
                                 string Aciklama, string KullaniciKimlikNo);

public sealed record IptalSonucu(bool Basarili, string Aciklama, string HamYanit);

// -------------------------------------------------------------- doküman ---

public sealed record DokumanIstegi(
    string ProvizyonNo, string TipKodu, string DosyaAdi, string Mime,
    byte[] Icerik, int Sira);

public sealed record DokumanSonucu(bool Basarili, string SaglayiciRef,
                                   string Hata, string HamYanit);

/// <summary>
/// SAĞLAYICI ARAYÜZÜ. Her şirket için bir uygulama; HTTP/JSON biçimini,
/// kimlik akışını ve alan adlarını yalnız o sınıf bilir.
///
/// Desteklenmeyen yetenek <see cref="NotSupportedException"/> atmaz -
/// <see cref="Yetenekler"/> zaten söylüyor; uç düğmeyi hiç göstermez.
/// </summary>
public interface ISigortaSaglayici
{
    string Kod { get; }
    SaglayiciYetenek Yetenekler { get; }

    /// <summary>
    /// BAĞLANTI TESTİ: yalnız kimlik akışını doğrular (jeton alır), İŞ ÇAĞRISI
    /// YAPMAZ. Sahte veriyle poliçe sorgusu denemek yanıltıcı: ASMED test
    /// ortamı sıfırlardan oluşan bir kimlik numarasına hiç yanıt vermiyor,
    /// istek zaman aşımına düşüyor - "servis çalışmıyor" sanılırdı.
    /// </summary>
    Task<string> BaglantiTestAsync(SigortaHesabi hesap, CancellationToken iptal);

    Task<PoliceSonucu> PoliceSorgulaAsync(SigortaHesabi hesap, PoliceIstegi istek,
                                          CancellationToken iptal);

    /// <summary>Oluştur + güncelle: provizyon no doluysa güncelleme sayılır.</summary>
    Task<ProvizyonSonucu> ProvizyonYazAsync(SigortaHesabi hesap, ProvizyonIstegi istek,
                                            CancellationToken iptal);

    Task<ProvizyonSonucu> ProvizyonOkuAsync(SigortaHesabi hesap, string provizyonNo,
                                            string kurumRefNo, CancellationToken iptal);

    Task<IptalSonucu> ProvizyonIptalAsync(SigortaHesabi hesap, IptalIstegi istek,
                                          CancellationToken iptal);

    Task<DokumanSonucu> DokumanGonderAsync(SigortaHesabi hesap, DokumanIstegi istek,
                                           CancellationToken iptal);
}

/// <summary>
/// Kanonik kod ↔ sağlayıcı kodu çevirisi. Uygulaması veri katmanında
/// (<c>sigorta_kod_esleme</c>); arayüz Çekirdek'te ki adapter'lar veri
/// katmanına bağımlı olmasın.
/// </summary>
public interface ISigortaKodCevirici
{
    /// <summary>Kanonik -> sağlayıcı. Eşleme yoksa boş döner (alan gönderilmez).</summary>
    string Uzak(short saglayiciId, string alan, short? yerelKod);

    /// <summary>Sağlayıcı -> kanonik. Eşleme yoksa null.</summary>
    short? Yerel(short saglayiciId, string alan, string? saglayiciKod);
}
