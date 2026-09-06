namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// SİGORTA KARTLARI (430) — kurum hesabı ve kod eşleme.
///
/// <para><b>Provizyonun kartı yok.</b> Provizyon bir BELGE DEĞİL, dış servisin
/// yanıtıdır: alanları elle düzenlenirse şirketin dediği ile bizdeki kayıt
/// ayrışır. Başvuru kartından alınır, listede ve okuma ucunda görülür.</para>
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> SigortaDurumKodlari = new()
        { ["0"] = "Aktif", ["1"] = "Pasif" };

    /// <summary>
    /// KURUM HESABI — hangi sigorta şirketi hangi sağlayıcı ve hangi
    /// entegrasyon hesabı üzerinden.
    ///
    /// Parola/istemci sırrı BURADA TUTULMAZ: kimlik bilgisi entegrasyon hesabı
    /// kartındadır. İki yerde saklamak, birini değiştirip ötekini unutmak
    /// demekti.
    /// </summary>
    private static KartTanimi SigortaHesapKarti() => new(
        Ad: "sigorta-hesap",
        YetkiKodu: "sigorta",
        Tablo: "public.sigorta_hesap",
        LogTabloId: 1000,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)0,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("saglayiciId", "saglayici_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_sigorta_saglayici_lookup",
                Baslik: "Sağlayıcı", Grup: "Kimlik"),
            new("kurumId", "kurum_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_kurum_lookup",
                Baslik: "Sigorta Şirketi (Kurum)", Grup: "Kimlik"),
            new("hesapId", "hesap_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_entegrasyon_hesap_lookup",
                Baslik: "Entegrasyon Hesabı", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: SigortaDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // Boş = tüm şubeler. Çok şubeli kurumda her şubenin ayrı kurum
            //   kodu varsa şube seçilir.
            new("subeId", "sube_id", "kod", KodTablosu: "public.sube",
                Baslik: "Şube (boş = tümü)", Grup: "Tanım"),
            new("varsayilan", "varsayilan", "mantik",
                Baslik: "Varsayılan", Grup: "Tanım"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Tanım"),
        });

    /// <summary>
    /// KOD EŞLEME — yeni şirket bağlarken doldurulan tek tablo.
    ///
    /// <c>alan</c> serbest metin DEĞİL, kanonik sözlük adıdır; yanlış yazılan
    /// bir alan adı sessizce hiçbir şeye eşleşmez, o yüzden sabit listeden
    /// seçilir.
    /// </summary>
    private static KartTanimi SigortaKodEslemeKarti() => new(
        Ad: "sigorta-kod-esleme",
        YetkiKodu: "sigorta",
        Tablo: "public.sigorta_kod_esleme",
        LogTabloId: 1001,
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("saglayiciId", "saglayici_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_sigorta_saglayici_lookup",
                Baslik: "Sağlayıcı", Grup: "Kimlik"),
            new("alan", "alan", "kod", Zorunlu: true, SabitKodlar: SigortaAlanKodlari,
                Baslik: "Sözlük", Grup: "Kimlik"),
            new("yerelKod", "yerel_kod", "metin", Zorunlu: true, EnFazlaUzunluk: 40,
                Baslik: "Yerel Kod", Grup: "Kimlik"),
            new("saglayiciKod", "saglayici_kod", "metin", Zorunlu: true,
                EnFazlaUzunluk: 60, Baslik: "Sağlayıcı Kodu", Grup: "Kimlik"),
            new("ad", "ad", "metin", EnFazlaUzunluk: 120,
                Baslik: "Anlamı", Grup: "Kimlik"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Kimlik"),
        });

    /// <summary>Kod eşleme sözlükleri - db/430'daki <c>alan</c> değerleri.</summary>
    private static readonly Dictionary<string, string> SigortaAlanKodlari = new()
    {
        ["provizyon_tipi"] = "Provizyon tipi",
        ["yatis_turu"]     = "Yatış türü",
        ["hizmet_tipi"]    = "Hizmet (alt) tipi",
        ["vaka_tipi"]      = "Vaka tipi",
        ["talep_turu"]     = "Talep türü",
        ["hekim_unvani"]   = "Hekim unvanı",
        ["kimlik_tipi"]    = "Kimlik tipi",
        ["police_tipi"]    = "Poliçe tipi",
        ["police_turu"]    = "Poliçe türü",
        ["islem_kaynagi"]  = "İşlem kaynağı",
        ["malzeme_tipi"]   = "Malzeme tipi",
        ["iptal_nedeni"]   = "İptal nedeni",
        ["dokuman_tipi"]   = "Doküman tipi",
    };
}
