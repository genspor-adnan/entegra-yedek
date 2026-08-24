namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kart alani. Yazilabilir olmayan alanlar istek govdesinde gelse bile YOK SAYILMAZ -
/// hata verilir (API §3.2: sessizce yok saymak yok).
/// </summary>
public sealed record KartAlani(
    string Ad,                     // API adi: "faturaUnvan"
    string Kolon,                  // db kolonu: "fatura_unvan"
    string Tip,                    // metin | sayi | para | tarih | kod | mantik
    bool Yazilabilir = true,
    bool Zorunlu = false,
    int? EnFazlaUzunluk = null,
    string? KodListesi = null,     // kod_liste.kod - kodAd sozlugu bundan cozulur
    IReadOnlyDictionary<string, string>? SabitKodlar = null,  // kod listesi DB'de yoksa
    // Kendi tablosu olan (kod_liste/kod_deger'e uymayan) secim kaynagi: "public.kategori".
    //   Tam secenek listesi VeriDeposu.KodTablosuBeyazListe'de whitelist'li tablolardan
    //   "select id, ad from <tablo> where aktif = 1 order by ad" ile cekilir.
    string? KodTablosu = null,
    // BAGLI SECIM: bu alanin secenekleri baska bir alanin degerine gore SUZULUR
    //   (or. Şube -> BagliAlan "bankaId"). Gorunum ust_id kolonunu doner; kart
    //   yalniz ust_id = secili ust olan satirlari gosterir. Ust degisince, artik
    //   gecerli olmayan alt deger TEMIZLENIR - yoksa "Ziraat + Akbank subesi"
    //   gibi tutarsiz kayit olusur.
    string? BagliAlan = null,
    string? Baslik = null,         // form etiketi; bos ise Ad'dan uretilir
    string? Grup = null,           // form bolumu / SEKME: "Kimlik", "Iletisim", "Mali"
    // Sekme DEGIL - ayni sekme icinde mockup'taki gibi kucuk alt-baslik
    //   (or. Genel sekmesinde "Tanım / Sınıflandırma" / "Vergi & Ana Birim").
    string? AltGrup = null,
    // Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
    //   Baska bir alanin Ad'ini gosterir; o alan kendi SATIRINI almaz, buraya eklenir.
    string? EslesAlan = null,
    // ARKA PLAN alani: formda CIZILMEZ ama degeri tasinir (kaydetmede gonderilir).
    //   Cek/senet "Tür" boyle: kagidin turu hangi listeden gelindigiyle belli,
    //   ekranda yer kaplamasi gereksiz - ama kayda dogru deger gitmeli.
    bool Gizli = false
)
{
    /// <summary>Etiket verilmediyse camelCase addan uretilir: faturaUnvan -> "Fatura Unvan".</summary>
    public string Etiket => Baslik ?? AddanEtiket(Ad);

    private static string AddanEtiket(string ad)
    {
        var sonuc = new System.Text.StringBuilder(ad.Length + 4);
        for (var i = 0; i < ad.Length; i++)
        {
            if (i > 0 && char.IsUpper(ad[i])) sonuc.Append(' ');
            sonuc.Append(i == 0 ? char.ToUpperInvariant(ad[i]) : ad[i]);
        }
        return sonuc.ToString();
    }
}

public sealed record DetayTanimi(
    string Ad,                     // "adresler"
    string Tablo,                  // "public.taraf_adres"
    string UstKolon,               // "taraf_id"
    IReadOnlyList<KartAlani> Alanlar,
    string IdKolonu = "id",
    string Sirala = "id",
    // 019'da tum sube_id kolonlari NOT NULL yapildi; detay eklerken oturumun
    //   subesi yazilir. Tabloda sube_id yoksa null verilir.
    string? SubeKolonu = "sube_id",
    // islem_log.tablo_id. 0 ise kartin tablo kodu kullanilir. Detay satirinin
    //   logu ust_tablo_id / ust_kayit_id ile karta baglanir.
    int LogTabloId = 0,
    string? Baslik = null,         // sekme basligi; bos ise Ad'dan uretilir
    bool SaltOkunur = false,       // satir ekle/sil hic gosterilmez (or. hesaplanmis/derlenmis veri)
    // Sekme KOSULLU: verilen mantik alani isaretli degilse sekme hic acilmaz
    //   (or. stok "Paket" sekmesi yalniz paket=1 iken). Bos sekme gostermek,
    //   kullaniciya doldurulacak bir sey varmis izlenimi verir.
    string? KosulAlani = null
)
{
    public string Etiket => Baslik ?? (Ad.Length > 0 ? char.ToUpperInvariant(Ad[0]) + Ad[1..] : Ad);
}

/// <summary>Silmeyi engelleyen bag. Adet > 0 ise 422 IS_KURALI doner (API §3.3).</summary>
public sealed record SilmeEngeli(string Tablo, string Kolon, string Aciklama);

/// <summary>
/// DOVIZ KURALI — karttaki para birimi / kur / tutar ucgeni.
///
/// Yerel para (ayar <c>genel.yerel_para</c>) disinda bir birim secilirse kur
/// islem tarihinin kurundan OTOMATIK gelir ve yerel karsilik hesaplanir.
/// Kullanici kuru elle degistirebilir (banka/anlasma kuru); yerel tutar HER
/// ZAMAN sunucuda tutar x kur olarak yeniden hesaplanir - arayuzden gelen
/// yerel tutara guvenilmez (API §3.2: hesaplanan alan istemciden alinmaz).
///
/// Yerel parada kur 1'e sabitlenir; "TL kaydin kuru 41" gibi bir sey olusamaz.
/// </summary>
public sealed record DovizKurali(
    string CinsAlani,      // "dovizCinsi"
    string KurAlani,       // "dovizKuru"
    string TutarAlani,     // "tutar"
    string YerelAlani,     // "yerelTutar" - Yazilabilir:false olmali
    string? TarihAlani = null);  // kurun okunacagi tarih alani ("tarih")

public sealed record KartTanimi(
    string Ad,                     // yol parcasi: "cari"
    string YetkiKodu,
    string Tablo,                  // "public.taraf"
    IReadOnlyList<KartAlani> Alanlar,
    int LogTabloId,                // ISLEMLOG.TABLOID (eski GENINI -11110 listesi)
    IReadOnlyList<DetayTanimi>? Detaylar = null,
    IReadOnlyList<SilmeEngeli>? SilmeEngelleri = null,
    string IdKolonu = "id",
    string? SabitKosul = null,
    string? SubeKolonu = null,
    string? KapsamKolonu = null,
    IReadOnlyDictionary<string, object?>? YeniKayitVarsayilanlari = null,
    // YENI kayitta acilir acilmaz taraf (cari) secim ekrani acilsin mi - deger,
    //   secimin yazilacagi alan adidir ("tarafId"). Belge kartindaki desenin
    //   generic kartlardaki karsiligi; kullanici isterse sonra degistirir.
    string? AcilistaTarafSecimi = null,
    // Kartta para birimi / kur / tutar ucgeni varsa (cek-senet): yerel para
    //   disinda bir birim secilince kur otomatik gelir, yerel tutar hesaplanir.
    DovizKurali? Doviz = null
)
{
    private Dictionary<string, KartAlani>? _dizin;

    public KartAlani? Alan(string ad)
    {
        _dizin ??= Alanlar.ToDictionary(a => a.Ad, StringComparer.Ordinal);
        return _dizin.TryGetValue(ad, out var a) ? a : null;
    }

    public DetayTanimi? Detay(string ad)
        => Detaylar?.FirstOrDefault(d => d.Ad.Equals(ad, StringComparison.Ordinal));
}

public static class KartKatalogu
{
    private static readonly Dictionary<string, KartTanimi> Kartlar =
        new(StringComparer.OrdinalIgnoreCase);

    public static KartTanimi? Bul(string ad) => Kartlar.TryGetValue(ad, out var k) ? k : null;
    public static IEnumerable<KartTanimi> Tumu => Kartlar.Values;

    static KartKatalogu()
    {
        Ekle(Cari());
        Ekle(Kisi());
        Ekle(Personel());
        Ekle(Hasta());
        Ekle(Rol());
        Ekle(Stok());
        // Kasa alt sistemi ana verileri (071-074). Kasa ISLEMI kart degil - belge
        //   gibi ayri sozlesme (baslik + bacak), KasaUclari ile yazilir.
        Ekle(Hesap());
        Ekle(Proje());
        Ekle(Gorev());
        Ekle(Firsat());
        Ekle(Banka());
        Ekle(MasrafMerkezi());
        Ekle(HesapPlani());
        Ekle(CekSenet());
        Ekle(Depo());
        // Belge KARTI degil, ayri sozlesme (§4 belge kaydetme) - burada yer almaz.
    }

    private static void Ekle(KartTanimi k) => Kartlar[k.Ad] = k;

    // GENINI kod listelerinde (BOLUM -2708 / -2201) 1 = Aktif, 0 = Pasif.
    //   Sema yorumu tersini soyluyordu; verinin 2.487'si 1, 229'u 0 - yani 1 aktif.
    private static readonly Dictionary<string, string> DurumKodlari =
        new() { ["1"] = "Aktif", ["0"] = "Pasif" };

    // STOKLAR.BILDIRIM - GENINI kod listesi degil, sabit 2 secenek (BILIM verisi: 0=3614, 2=1468, 1=1 stray).
    private static readonly Dictionary<string, string> BildirimKodlari =
        new() { ["0"] = "Yok", ["2"] = "ÜTS" };

    // STOKLAR.RAFOMRU_BIRIM - GENINI degil, sabit 3 secenek (mockup: Gun/Ay/Yil, varsayilan Yil).
    private static readonly Dictionary<string, string> RafOmruBirimKodlari =
        new() { ["0"] = "—", ["1"] = "Gün", ["2"] = "Ay", ["3"] = "Yıl" };

    // STOKLAR.KDV - GENINI BOLUM -2790'daki 6 secenek (kod_liste.DEGER bir SIRA numarasi,
    //   stok.kdv kolonu ise DOGRUDAN ORANI tutuyor - kod_liste.AD burada). O yuzden
    //   KodListesi mekanizmasi (deger<->deger eslesir varsayar) DEGIL, GENINI'den elle
    //   alinmis sabit liste kullanildi (deger = etiket = oranin kendisi).
    private static readonly Dictionary<string, string> KdvKodlari =
        new() { ["0"] = "0", ["1"] = "1", ["8"] = "8", ["10"] = "10", ["18"] = "18", ["20"] = "20" };

    // STOKBARKOD.BARKOD_TIPI - GENINI degil, Delphi'de sabit 2 secenek + BARKODAYARLAR
    //   (kullanici tanimli, migrate edilmedi - bkz. Utablo.pas:14136).
    private static readonly Dictionary<string, string> BarkodTipiKodlari =
        new() { ["0"] = "Kullanıcı", ["100"] = "Karekod" };

    // TARAF_ADRES.TUR - yeni tablo (GENINI karsiligi yok), 001_sema_taraf.sql check kisitindan.
    private static readonly Dictionary<string, string> AdresTurKodlari =
        new() { ["1"] = "Fatura", ["2"] = "Sevkiyat", ["3"] = "Merkez", ["4"] = "Şube/Depo", ["9"] = "Diğer" };

    // Kisi'nin adres tipi Cari'den FARKLI anlam tasir (ayni tur kolonu, ayni check kisiti
    //   1/2/3/4/9 - hangi liste gecerli, o satirin sahibi taraf.kisi'ye gore belirlenir).
    //   Kullanici: "kişi de adres tipleri sadece Ev/İş olabilir".
    private static readonly Dictionary<string, string> KisiAdresTurKodlari =
        new() { ["1"] = "Ev Adresi", ["2"] = "İş Adresi" };

    // TARAF.ROL (kisi_karti.html/kisi_listesi.html "KARAR/ETKİ/MUHS/KULL/TEKN") - GENINI
    //   karsiligi yok, mockup'a ozel sabit liste (040_kisi_rol.sql).
    private static readonly Dictionary<string, string> KisiRolKodlari =
        new() { ["1"] = "Karar Verici", ["2"] = "Etkileyen", ["3"] = "Kullanıcı", ["4"] = "Mali/Muhasebe", ["5"] = "Teknik" };

    // taraf_personel.CINSIYET - GENINI karsiligi yok, yeni tablo (046_personel_kart.sql).
    private static readonly Dictionary<string, string> CinsiyetKodlari =
        new() { ["1"] = "Erkek", ["2"] = "Kadın" };

    // taraf_personel.CALISMA_SEKLI - GENINI karsiligi yok (047_personel_ozluk_ogrenim.sql).
    private static readonly Dictionary<string, string> CalismaSekliKodlari =
        new() { ["1"] = "Tam Zamanlı", ["2"] = "Yarı Zamanlı" };

    // taraf_personel.VARDIYA_TURU - GENINI karsiligi yok (048_personel_ozluk_uyruk_vardiya_sgk.sql).
    private static readonly Dictionary<string, string> VardiyaTuruKodlari =
        new() { ["1"] = "Gündüz", ["2"] = "Gece", ["3"] = "Vardiyalı" };

    // taraf_personel.MEDENI_HAL - GENINI karsiligi yok (049_personel_ozluk_medeni_kan.sql).
    private static readonly Dictionary<string, string> MedeniHalKodlari =
        new() { ["1"] = "Bekar", ["2"] = "Evli", ["3"] = "Boşanmış", ["4"] = "Dul" };

    // taraf_personel.SOZLESME_TURU - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).
    private static readonly Dictionary<string, string> SozlesmeTuruKodlari =
        new() {
            ["1"] = "Belirsiz Süreli", ["2"] = "Belirli Süreli", ["3"] = "Deneme Süreli",
            ["4"] = "Stajyer/Çırak", ["5"] = "Mevsimlik",
        };

    // taraf_personel.DENEME_SURESI - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).
    private static readonly Dictionary<string, string> DenemeSuresiKodlari =
        new() { ["0"] = "Yok", ["1"] = "1 Ay", ["2"] = "2 Ay", ["3"] = "3 Ay", ["4"] = "4 Ay" };

    // PERSONEL_IZIN.TUR/DURUM - ik_karti.html mockup ("Yıllık İzin/Mazeret/...", "Onaylı/
    //   Bekliyor/Reddedildi") - GENINI karsiligi yok (052_personel_izin.sql).
    private static readonly Dictionary<string, string> IzinTuruKodlari =
        new() { ["1"] = "Yıllık İzin", ["2"] = "Mazeret", ["3"] = "Rapor", ["4"] = "Ücretsiz İzin", ["9"] = "Diğer" };
    private static readonly Dictionary<string, string> IzinDurumuKodlari =
        new() { ["1"] = "Bekliyor", ["2"] = "Onaylı", ["3"] = "Reddedildi" };

    // PERSONEL_EGITIM.TUR - ik_karti.html mockup ("Diploma/Sertifika/Eğitim") - GENINI
    //   karsiligi yok (053_personel_egitim.sql).
    private static readonly Dictionary<string, string> EgitimTuruKodlari =
        new() { ["1"] = "Diploma", ["2"] = "Sertifika", ["3"] = "Eğitim" };

    private static readonly Dictionary<string, string> HastaMeslekKodlari =
        new()
        {
            ["1"] = "Ev Hanımı",
            ["2"] = "İşçi",
            ["3"] = "Memur",
            ["4"] = "Öğrenci",
            ["5"] = "Serbest",
            ["6"] = "Emekli",
            ["9"] = "Diğer"
        };

    // --------------------------------------------------------------- cari ----
    private static KartTanimi Cari() => new(
        Ad: "cari",
        YetkiKodu: "cari",
        Tablo: "public.taraf",
        LogTabloId: 71,                       // GENINI -11110: 71 = Cari
        // ADAY (122) da bu kartla acilir: sabit kosul adayi disarida birakirsa
        //   kayit yazilir ama geri OKUNAMAZ ("Nullable object must have a
        //   value") - kisi kartinda ayni tuzak yasanmisti.
        SabitKosul: "(musteri = 1 or tedarikci = 1 or aday = 1)",
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK (019 modeli)
        KapsamKolonu: "id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["musteri"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("kod",         "kod",          "metin", EnFazlaUzunluk: 20,  Baslik: "Kod",            Grup: "Kimlik"),
            new("unvan",       "unvan",        "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan",  Grup: "Kimlik"),
            // idstrip'ten kaldirildi (mockup'ta da yok, sadece Unvan var) - Fatura Bilgileri'ne dustu.
            new("ad",          "ad",           "metin", EnFazlaUzunluk: 50,  Baslik: "Ad"),
            new("soyad",       "soyad",        "metin", EnFazlaUzunluk: 60,  Baslik: "Soyad"),
            // Roller SEKMESI KALDIRILDI (mockup'ta yok) - Musteri/Tedarikci toolbar'a tasindi
            //   (bkz. GenForm.tsx kaynak==='cari'), Kisi Genel sekmesinde kaldi.
            new("musteri",     "musteri",      "mantik", Baslik: "Musteri"),
            new("tedarikci",   "tedarikci",    "mantik", Baslik: "Tedarikci"),
            // ADAY (122): henuz musteri olmayan firma. Anlasma saglaninca
            //   musteri=1 / aday=0 olur - AYNI kayit, gecmisi (firsat, gorev,
            //   adres, ilgili kisi) yerinde kalir.
            new("aday",        "aday",         "mantik", Baslik: "Aday"),
            new("kisi",        "kisi",         "mantik", Baslik: "Kisi"),
            // "Mali" -> "Fatura Bilgileri" (mockup adi birebir; AltGrup ile mockup'un iki
            //   kutusuna ayrildi: Fatura / Vergi Kimligi + e-Belge Ayarlari. Mockup'taki XSLT/
            //   Alias alanlari (E-Fatura XSLT, E-Irsaliye XSLT, E-Arsiv XSLT, Alias/e-Posta)
            //   backend'de kolon karsiligi yok (taraf tablosunda yok) - eklenmedi.
            new("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani", Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new("vkno",        "vkno",         "metin", EnFazlaUzunluk: 20,  Baslik: "VKN / TCKN",     Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new("vd",          "vd",           "metin", EnFazlaUzunluk: 60,  Baslik: "Vergi Dairesi",  Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new("efatura",     "efatura",      "mantik", Baslik: "e-Fatura mukellefi", Grup: "Fatura Bilgileri", AltGrup: "e-Belge Ayarlari"),
            new("aliasEposta", "alias_eposta", "metin", EnFazlaUzunluk: 200, Baslik: "Alias / e-Posta", Grup: "Fatura Bilgileri", AltGrup: "e-Belge Ayarlari"),
            // "Iletisim"/"Siniflandirma"/"Diger" SEKME DEGIL - mockup'ta Genel'in alt-kutulari
            //   (Kart Bilgileri / İletişim / Notlar). Grup kaldirildi, AltGrup ile Genel'e katlandi.
            new("telefon",     "telefon",      "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon",        AltGrup: "İletişim"),
            new("cepTel",      "cep_tel",      "metin", EnFazlaUzunluk: 30,  Baslik: "Cep Telefonu",   AltGrup: "İletişim"),
            new("eposta",      "eposta",       "metin", EnFazlaUzunluk: 120, Baslik: "E-posta",        AltGrup: "İletişim"),
            new("epostaWeb",   "eposta_web",   "metin", EnFazlaUzunluk: 200, Baslik: "Web", AltGrup: "İletişim"),
            // "Grup" YERINE Kategori/İlk Temas + Sektor/Alt Sektor + Sinif/Bolge (kullanici)
            //   - GenForm.tsx bu ciftleri AYNI SATIRDA yan yana render eder, sirayla:
            //   Kategori/İlk Temas, Sektör/Alt Sektör, Sınıf/Bölge, Temsilci/Özel Kod.
            new("kategori",    "kategori",     "kod",   KodListesi: "taraf.kategori",   Baslik: "Kategori",   AltGrup: "Tanımlama"),
            new("ilkTemas",    "ilk_temas",    "kod",   KodListesi: "taraf.ilk_temas",  Baslik: "İlk Temas",  AltGrup: "Tanımlama"),
            new("sektor",      "sektor",       "kod",   KodListesi: "taraf.sektor",     Baslik: "Sektör",     AltGrup: "Tanımlama"),
            new("altSektor",   "alt_sektor",   "kod",   KodListesi: "taraf.alt_sektor", Baslik: "Alt Sektör", AltGrup: "Tanımlama"),
            new("sinif",       "sinif",        "kod",   KodListesi: "taraf.sinif",      Baslik: "Sınıf",      AltGrup: "Tanımlama"),
            new("bolge",       "bolge",        "kod",   KodListesi: "taraf.bolge",      Baslik: "Bölge",      AltGrup: "Tanımlama"),
            // TEMSILCI kimlik seridinde (Unvan'in saginda): "bu cari kimin"
            //   sorusu kartin en ustunde cevaplanmali. Deger PERSONEL taraf
            //   id'sidir - eskiden kod listesi bagli degildi ve ekranda ham
            //   sayi goruluyordu.
            new("temsilci",    "temsilci",     "kod",   KodTablosu: "public.v_personel_lookup",
                                                        Baslik: "Temsilci", Grup: "Kimlik"),
            new("ozelKod",     "ozel_kod",     "metin", EnFazlaUzunluk: 20,  Baslik: "Ozel Kod",       AltGrup: "Tanımlama"),
            new("notlar",      "notlar",       "metin", EnFazlaUzunluk: 1000, Baslik: "Notlar",        AltGrup: "Notlar"),
            new("durum",       "durum",        "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum",    Grup: "Kimlik"),
            new("subeId",      "sube_id",      "sayi",  Yazilabilir: false),
            new("eklemeTarihi","ekleme_tarihi","tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: AdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                // Il ONCE, Ilce SONRA (kullanici: "İl önce ... İlçe sonra") - Ilce'nin
                //   secimi zaten Il'e bagli (cascading), sira da mantiksal olarak boyle.
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901)   // yeni tablo - eski karsiligi yok
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge",        "taraf_id", "Bu cariye ait belge var, silinemez."),
            new SilmeEngeli("public.mali_hareket", "taraf_id", "Bu cariye ait kasa/banka hareketi var, silinemez."),
            new SilmeEngeli("public.taraf_kullanici",    "id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

    // --------------------------------------------------------------- kisi ----
    // kisi_karti.html mockup - kapsam kullaniciyla netlestirildi: TEMEL kimlik/iletisim.
    // Rol/yetki seviyesi/raporladigi kisi/dogum-cinsiyet-medeni durum/dil/iliski skoru/
    // etiket/foto/iletisim gecmisi/ilgili kayitlar/KVKK-izin/notlar-ekler EKLENMEDI -
    // DB'de hicbirinin karsiligi yoktu, tam kapsamli ayri, cok daha buyuk bir is olurdu.
    // Ayni taraf tablosu (kisi=1, bag_id ile sirkete bagli) - unvan (Ad Soyad gorunen adi)
    // 037_kisi_karti.sql'deki trigger ile ad+soyad'dan OTOMATIK uretiliyor, alanda YOK.
    private static KartTanimi Kisi() => new(
        Ad: "kisi",
        YetkiKodu: "cari",                    // ayri yetki kodu yok - cari yetkisiyle yonetiliyor
        Tablo: "public.taraf",
        LogTabloId: 71,                       // ayni fiziksel tablo - cari ile ayni GENINI kodu
        SabitKosul: "kisi = 1",
        KapsamKolonu: "bag_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["kisi"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            // Ad/Soyad DEGIL, Cari ile ayni desen: "Unvan" tek goruntulenen alan. Ad/Soyad
            //   ayrimi BILEREK yapilmadi - kullanici bunu ileride IK (personel) ve hasta
            //   kartlarina sakladi, kisi kartinda degil (038_kisi_karti_unvan_geri_al.sql).
            // idstrip sirasi kullanici tarafindan belirlendi: Kod, Unvan, Departman, Gorev.
            //   Durum idstrip'ten CIKARILDI (kullanici sonradan Durum'suz istedi) - Is
            //   Bilgileri kutusuna tasindi (Bagli Cari ile birlikte).
            new("id",        "id",         "sayi",  Yazilabilir: false),
            // YeniKayitVarsayilanlari'ndaki "kisi"=1 buraya yazilabilsin diye (alan
            //   tanimsizsa EkleAsync kolonu atlar, DB varsayilanina - 0/false - duser,
            //   sonra SabitKosul "kisi = 1" yeni kaydi bulamaz -> "Nullable ... value" hatasi).
            //   UI'da gorunmez (gizli Set, GenForm.tsx).
            new("kisi",      "kisi",       "mantik", Baslik: "Kisi"),
            new("kod",       "kod",        "metin", EnFazlaUzunluk: 20, Baslik: "Kisi Kodu", Grup: "Kimlik"),
            new("unvan",     "unvan",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan", Grup: "Kimlik"),
            new("departman", "departman",  "kod",   KodListesi: "taraf.departman", Baslik: "Departman", Grup: "Kimlik"),
            new("gorev",     "gorev",      "metin", EnFazlaUzunluk: 100, Baslik: "Gorev", Grup: "Kimlik"),
            // "Is Bilgileri" kutu basligi IPTAL edildi (kullanici) - Bagli Cari/Rol/Durum
            //   AltGrup'suz (adsiz) duz alan olarak kaliyor, idstrip'in hemen altinda.
            new("bagId",     "bag_id",     "kod",   KodTablosu: "public.v_cari_lookup", Baslik: "Bagli Cari"),
            new("rol",       "rol",        "kod",   SabitKodlar: KisiRolKodlari, Baslik: "Rol"),
            new("durum",     "durum",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum"),
            new("telefon",   "telefon",    "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon",         AltGrup: "İletişim"),
            new("cepTel",    "cep_tel",    "metin", EnFazlaUzunluk: 30,  Baslik: "Cep Telefonu",    AltGrup: "İletişim"),
            new("eposta",    "eposta",     "metin", EnFazlaUzunluk: 120, Baslik: "E-posta",         AltGrup: "İletişim"),
            new("epostaWeb", "eposta_web", "metin", EnFazlaUzunluk: 200, Baslik: "2. E-posta",      AltGrup: "İletişim"),
            new("subeId",        "sube_id",       "sayi",  Yazilabilir: false),
            new("eklemeTarihi",  "ekleme_tarihi", "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // kisi_karti.html mockup'taki "Adres" kutusu - Cari ile AYNI taraf_adres tablosu
            //   (taraf_id = bu kisi satirinin id'si, kişi de bir taraf). Ayni LogTabloId (901).
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: KisiAdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901),
            // "Geçmiş" sekmesi (kullanici) - SALT OKUNUR, elle satir eklenmez/silinmez;
            //   KisiDeposu.BaglaAsync/KoparAsync yonetir (041_taraf_gecmis.sql).
            new DetayTanimi("gecmis", "public.taraf_gecmis", "kisi_id", new KartAlani[]
            {
                new("id",             "id",              "sayi", Yazilabilir: false),
                new("cariId",         "cari_id",         "kod",  KodTablosu: "public.v_cari_lookup", Baslik: "Cari"),
                new("baslamaTarihi",  "baslama_tarihi",  "tarih", Baslik: "Başlama"),
                new("bitisTarihi",    "bitis_tarihi",    "tarih", Baslik: "Bitiş")
            }, Sirala: "bitis_tarihi desc nulls first, baslama_tarihi desc", SubeKolonu: null,
               Baslik: "Geçmiş", SaltOkunur: true)
        });

    // ----------------------------------------------------------- personel ----
    // Kisi'den FARKLI: Ad/Soyad KULLANILIYOR (kullanici bunu bilerek IK/hasta kartlarina
    //   saklamisti - 038_kisi_karti_unvan_geri_al.sql yorumu). "unvan" kolonu (taraf'ta
    //   NOT NULL) UI'da hic gorunmez - GenForm.tsx Kaydet'te ad+soyad'dan birlestirilip
    //   gonderilir (KişI'deki gibi bir DB trigger DEGIL - Kişi'de trigger user'in elle
    //   yazdigi Unvan'i sessizce ezme riski tasiyordu; burada unvan zaten hic gosterilip
    //   duzenlenmedigi icin risk yok, DB seviyesinde tetikleyici gerekmiyor).
    private static KartTanimi Personel() => new(
        Ad: "personel",
        YetkiKodu: "personel",
        Tablo: "public.taraf",
        LogTabloId: 73,                       // eski GENINI TABLOID: IK = 73 (bkz. silme-geri-al-tuzaklari)
        SabitKosul: "personel = 1",
        SubeKolonu: null,                     // Kisi liste kaynagiyla tutarli - ana veri, ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["personel"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",         "sayi",  Yazilabilir: false),
            // Kisi'deki "kisi" alani ile ayni sebep: YeniKayitVarsayilanlari'ndaki
            //   "personel"=1 buraya yazilabilsin diye tanimli, UI'da gizli (GenForm.tsx).
            new("personel",  "personel",   "mantik", Baslik: "Personel"),
            // "unvan" da UI'da GIZLI (gizli Set, GenForm.tsx) - ad+soyad'dan turetilir,
            //   ayrica DUZENLENMEZ, sadece DB NOT NULL kisitini karsilamak icin gonderilir.
            new("unvan",     "unvan",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan"),
            new("kod",       "kod",        "metin", EnFazlaUzunluk: 20, Baslik: "Sicil No", Grup: "Kimlik"),
            new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 50, Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",     "soyad",      "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Soyad", Grup: "Kimlik"),
            new("departman", "departman",  "kod",   KodListesi: "taraf.departman", Baslik: "Departman", Grup: "Kimlik"),
            new("durum",     "durum",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // ik_karti.html mockup'ta idstrip'te DEGIL - Görev "Pozisyon" adiyla Genel
            //   sekmesinin "Özet" kutusunda (PersonelKimlikOzet.tsx). TCKN de "Kimlik
            //   Bilgileri" kutusunda - ikisi de adsiz (Grup yok), gizli Set (GenForm.tsx)
            //   ile genel/duz render'dan cikarilip ozel bilesene props olarak geciyor.
            new("gorev",     "gorev",      "metin", EnFazlaUzunluk: 100, Baslik: "Pozisyon"),
            new("vkno",      "vkno",       "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "T.C. Kimlik No"),
            // ik_karti.html mockup'ta İletişim AYRI SEKME (Genel'e gomulu AltGrup DEGIL) -
            //   Grup:"İletişim" bu yuzden AltGrup degil.
            new("telefon",   "telefon",    "metin", EnFazlaUzunluk: 30,  Baslik: "Ev Telefonu",         Grup: "İletişim"),
            new("cepTel",    "cep_tel",    "metin", EnFazlaUzunluk: 30,  Baslik: "Cep",                 Grup: "İletişim"),
            new("eposta",    "eposta",     "metin", EnFazlaUzunluk: 120, Baslik: "E-posta (İş)",        Grup: "İletişim"),
            new("epostaWeb", "eposta_web", "metin", EnFazlaUzunluk: 200, Baslik: "E-posta (Kişisel)",   Grup: "İletişim"),
            // Diger kartlarda subeId salt-okunur/gizli meta alan - Personel'de kullanici
            //   isteğiyle GERCEK VERI: "Çalıştığı Şube" (kullanici: "taraf subeid de
            //   personelin Çalıştığı Şube yi tut"). Yazilabilir + KodTablosu ile secilebilir;
            //   bos birakilirsa oturumun subesi otomatik yazilir (KartDeposu.EkleAsync).
            new("subeId",        "sube_id",       "kod",   KodTablosu: "public.sube", Baslik: "Çalıştığı Şube"),
            new("eklemeTarihi",  "ekleme_tarihi", "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // Kisi ile AYNI taraf_adres tablosu, AYNI Ev/İş tur listesi (kisisel adres).
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: KisiAdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901),
            // ik_karti.html İletişim sekmesi: "Acil Durumda Aranacak Kişiler"
            // REHBERILETISIM (1:N) mockup karsiligi. Ayrı sekme degil, İletişim
            // sekmesinde Ev Adresi'nin altina gomulu grid olarak render edilir.
            new DetayTanimi("acilKisiler", "public.personel_acil_kisi", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("varsayilan", "varsayilan",  "mantik", Baslik: "★"),
                new("adSoyad",    "ad_soyad",    "metin", EnFazlaUzunluk: 120, Baslik: "Ad Soyad", Zorunlu: true),
                new("yakinlik",   "yakinlik",    "metin", EnFazlaUzunluk: 60,  Baslik: "Yakınlık"),
                new("telefon",    "telefon",     "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon")
            }, Sirala: "varsayilan desc, sira, id", LogTabloId: 906, Baslik: "Acil Durumda Aranacak Kişiler"),
            // Ozluk - taraf_personel 1:1 (id = taraf.id). Kisi'nin TekAdres'i gibi TEK SATIR gosterilir
            //   (TekOzluk.tsx) - satir ekle/sil YOK, tek satir hep var/yok.
            new DetayTanimi("ozluk", "public.taraf_personel", "id", new KartAlani[]
            {
                new("id",                 "id",                  "sayi",  Yazilabilir: false),
                new("dogumTarihi",        "dogum_tarihi",        "tarih", Zorunlu: true, Baslik: "Doğum Tarihi"),
                new("dogumYeri",          "dogum_yeri",          "metin", EnFazlaUzunluk: 60, Baslik: "Doğum Yeri"),
                new("cinsiyet",           "cinsiyet",            "kod",   SabitKodlar: CinsiyetKodlari, Baslik: "Cinsiyet"),
                new("iseGirisTarihi",     "ise_giris_tarihi",    "tarih", Baslik: "İşe Giriş Tarihi"),
                new("istenCikisTarihi",   "isten_cikis_tarihi",  "tarih", Baslik: "İşten Çıkış Tarihi"),
                new("calismaSekli",       "calisma_sekli",       "kod",   SabitKodlar: CalismaSekliKodlari, Baslik: "Çalışma Şekli"),
                // Uyruk (ulke) - TekOzluk.tsx'te TekAdres'teki Ulke ile AYNI mekanizma
                //   (yerlerHook.useYerler, serbest SabitKodlar DEGIL - ulke.ad metin olarak
                //   yazilir), varsayilan TC (yerlerHook.VARSAYILAN_ULKE).
                new("uyruk",              "uyruk",               "metin", EnFazlaUzunluk: 60, Baslik: "Uyruğu"),
                new("vardiyaTuru",        "vardiya_turu",        "kod",   SabitKodlar: VardiyaTuruKodlari, Baslik: "Vardiya Türü"),
                new("sgkBaslamaTarihi",   "sgk_baslama_tarihi",  "tarih", Baslik: "SGK Başlama Tarihi"),
                new("medeniHal",          "medeni_hal",          "kod",   SabitKodlar: MedeniHalKodlari, Baslik: "Medeni Hal"),
                // taraf.kan_grubu ile AYNI kod_liste (hasta hazirligi icin bosti, 8 standart
                //   kan grubuyla dolduruldu, 049) - ileride Hasta karti da bunu kullanacak.
                new("kanGrubu",           "kan_grubu",           "kod",   KodListesi: "taraf.kan_grubu", Baslik: "Kan Grubu"),
                new("sozlesmeTuru",       "sozlesme_turu",       "kod",   SabitKodlar: SozlesmeTuruKodlari, Baslik: "Sözleşme Türü"),
                new("denemeSuresi",       "deneme_suresi",       "kod",   SabitKodlar: DenemeSuresiKodlari, Baslik: "Deneme Süresi"),
                // ik_karti.html mockup uyum turu (054): SGK Sicil No/Meslek Kodu/Yonetici.
                new("sgkSicilNo",         "sgk_sicil_no",        "metin", EnFazlaUzunluk: 30, Baslik: "SGK Sicil No"),
                new("meslekKodu",         "meslek_kodu",         "metin", EnFazlaUzunluk: 60, Baslik: "Meslek Kodu"),
                new("yoneticiId",         "yonetici_taraf_id",   "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Yönetici")
            }, Baslik: "Özlük"),
            // ik_karti.html mockup "İzinler" sekmesi (IZIN 1:N) - GERCEK COKLU-SATIR grid,
            //   generic GenDetayTablo (satir ekle/sil) yeterli, ozel bilesen gerekmiyor.
            new DetayTanimi("izinler", "public.personel_izin", "taraf_id", new KartAlani[]
            {
                new("id",               "id",                "sayi",  Yazilabilir: false),
                new("tur",              "tur",               "kod",   SabitKodlar: IzinTuruKodlari, Baslik: "Tür", Zorunlu: true),
                new("baslangicTarihi",  "baslangic_tarihi",  "tarih", Baslik: "Başlangıç"),
                new("bitisTarihi",      "bitis_tarihi",      "tarih", Baslik: "Bitiş"),
                new("gun",              "gun",               "sayi",  Baslik: "Gün"),
                new("aciklama",         "aciklama",          "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
                new("durum",            "durum",             "kod",   SabitKodlar: IzinDurumuKodlari, Baslik: "Durum")
            }, Sirala: "baslangic_tarihi desc, id desc", LogTabloId: 904, Baslik: "İzinler"),
            // ik_karti.html mockup "Eğitim / Sertifika" sekmesi (PERSONELEGITIM 1:N).
            new DetayTanimi("egitimler", "public.personel_egitim", "taraf_id", new KartAlani[]
            {
                new("id",          "id",          "sayi",  Yazilabilir: false),
                new("tur",         "tur",         "kod",   SabitKodlar: EgitimTuruKodlari, Baslik: "Tür", Zorunlu: true),
                new("ad",          "ad",          "metin", EnFazlaUzunluk: 200, Baslik: "Ad", Zorunlu: true),
                new("kurum",       "kurum",       "metin", EnFazlaUzunluk: 150, Baslik: "Kurum"),
                // Yalnız yıl (2024) veya normal tarih metni (2024-06-15 / 15.06.2024)
                // tutulabilir; DB kolonu 055 ile varchar(10) yapıldı.
                new("tarih",       "tarih",       "metin", EnFazlaUzunluk: 10, Baslik: "Tarih/Yıl"),
                new("gecerlilik",  "gecerlilik",  "metin", EnFazlaUzunluk: 60, Baslik: "Geçerlilik")
            }, Sirala: "tarih desc nulls last, id desc", LogTabloId: 905, Baslik: "Eğitim / Sertifika")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.taraf_kullanici", "id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

    private static KartTanimi Hasta()
    {
        var p = Personel();
        var alanlar = p.Alanlar.Select(a => a.Ad switch
        {
            "personel" => new KartAlani("hasta", "hasta", "mantik", Baslik: "Hasta"),
            "kod" => a with { Baslik = "Dosya No" },
            "vkno" => a with { Baslik = "TC No", Grup = "Kimlik", AltGrup = null },
            "cepTel" => a with { Baslik = "Telefon" },
            "subeId" => a with { Baslik = "Şube" },
            _ => a
        }).Where(a => a.Ad is not ("departman" or "telefon" or "epostaWeb")).ToList();
        var durum = alanlar.FirstOrDefault(a => a.Ad == "durum");
        if (durum is not null)
        {
            alanlar.Remove(durum);
            var vknoIndex = alanlar.FindIndex(a => a.Ad == "vkno");
            alanlar.Insert(vknoIndex >= 0 ? vknoIndex + 1 : alanlar.Count, durum);
        }
        alanlar.AddRange(new[]
        {
            new KartAlani("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani", Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new KartAlani("vd", "vd", "metin", EnFazlaUzunluk: 60, Baslik: "Vergi Dairesi", Grup: "Fatura Bilgileri", AltGrup: "Fatura / Vergi Kimligi"),
            new KartAlani("efatura", "efatura", "mantik", Baslik: "e-Fatura mukellefi", Grup: "Fatura Bilgileri", AltGrup: "e-Belge Ayarlari"),
            new KartAlani("aliasEposta", "alias_eposta", "metin", EnFazlaUzunluk: 200, Baslik: "Alias / e-Posta", Grup: "Fatura Bilgileri", AltGrup: "e-Belge Ayarlari"),
            // YeniKayitVarsayilanlari'ndaki grup=101 kayda yazılsın; UI'da gizlenir.
            new KartAlani("grup", "grup", "kod", Baslik: "Grup")
        });

        var detaylar = p.Detaylar?.Select(d => d.Ad == "ozluk"
            ? new DetayTanimi("ozluk", "public.taraf_hasta", "id", new KartAlani[]
            {
                new("id",          "id",           "sayi",  Yazilabilir: false),
                new("dogumTarihi", "dogum_tarihi", "tarih", Baslik: "Dogum Tarihi"),
                new("dogumYeri",   "dogum_yeri",   "metin", EnFazlaUzunluk: 60, Baslik: "Dogum Yeri"),
                new("cinsiyet",    "cinsiyet",     "kod",   SabitKodlar: CinsiyetKodlari, Baslik: "Cinsiyet"),
                new("uyruk",       "uyruk",        "metin", EnFazlaUzunluk: 60, Baslik: "Uyrugu"),
                new("kanGrubu",    "kan_grubu",    "kod",   KodListesi: "taraf.kan_grubu", Baslik: "Kan Grubu"),
                new("meslek",      "meslek",       "kod",   SabitKodlar: HastaMeslekKodlari, Baslik: "Meslek")
            }, SubeKolonu: null, Baslik: "Hasta Bilgisi", LogTabloId: 907)
            : d).ToArray();

        return p with
        {
            Ad = "hasta",
            // Ayrı hasta yetkisi seed edilmediği için personel yetkisiyle yönetilir.
            YetkiKodu = "personel",
            LogTabloId = 71,
            SabitKosul = "grup = 101",
            YeniKayitVarsayilanlari = new Dictionary<string, object?>
            {
                ["grup"] = (short)101,
                ["hasta"] = (short)1,
                ["durum"] = (short)1
            },
            Alanlar = alanlar.ToArray(),
            Detaylar = detaylar
        };
    }

    // ----------------------------------------------------------------- rol ----
    // Kullanici: "eski sistemde rol tablosu ve buna bagli kullanici/personel vardi..
    //   role verdigimiz yetki dogrultusunda menuleri Gorme/Ekleme/Duzeltme/Silme islem
    //   yapabilirdi". Alt mekanizma (rol/yetki/rol_yetki/rol_alan_yetki, backend
    //   dogrulamasi, frontend menu/toolbar gate'i) ZATEN VARDI - eksik olan YONETIM
    //   EKRANIYDI. Bu kart + Yetki Matrisi sekmesi (RolYetkiMatrisi.tsx, ozel bilesen -
    //   generic Detay mekanizmasina UYMAZ, sabit "yetki" satirlari x Gor/Ekle/Degistir/
    //   Sil sutunlu matris; ayri RolYetkiUclari.cs/RolYetkiDeposu.cs).
    private static KartTanimi Rol() => new(
        Ad: "rol",
        YetkiKodu: "rol",                     // zaten seed'liydi (yetki.id=15, sira 62)
        Tablo: "public.rol",
        LogTabloId: 903,                      // yeni tablo - eski karsiligi yok (bkz. taraf_adres: 901)
        SubeKolonu: null,                     // ana tanim verisi - subeler arasi ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",         "sayi",  Yazilabilir: false),
            new("kod",       "kod",        "metin", Zorunlu: true, EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik"),
            new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 100, Baslik: "Ad",  Grup: "Kimlik"),
            new("ustRolId",  "ust_rol_id", "kod",   KodTablosu: "public.rol", Baslik: "Üst Rol", Grup: "Kimlik"),
            new("aktif",     "aktif",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Aktif", Grup: "Kimlik"),
            // Sistem rolleri (Yonetici/Salt okuyucu) - kod/ad degistirilemez/silinemez
            //   hale getirmek ayri bir is (SilmeEngeli + Yazilabilir kontrolu); simdilik
            //   sadece salt-okunur GORUNUR, kullanici "sistem" rolu oldugunu bilsin.
            new("sistem",    "sistem",     "mantik", Yazilabilir: false, Baslik: "Sistem Rolü"),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false)
        });

    // --------------------------------------------------------------- stok ----
    private static KartTanimi Stok() => new(
        Ad: "stok",
        YetkiKodu: "stok",
        Tablo: "public.stok",
        LogTabloId: 88,                       // GENINI -11110: 88 = Stoklar
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",              "sayi",  Yazilabilir: false),
            new("kod",           "kod",             "metin", Zorunlu: true, EnFazlaUzunluk: 30, Baslik: "Stok Kodu", Grup: "Kimlik"),
            new("ad",            "ad",              "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Stok Adi", Grup: "Kimlik"),
            // mockup idstrip: Stok Kodu / Stok Adi / Tur / Durum - Tur (STOKLAR.TIPI) daha once hic acilmamisti.
            new("tipi",          "tipi",            "kod",   Zorunlu: true, KodListesi: "stok.tipi", Baslik: "Tur", Grup: "Kimlik"),
            // mockup "Genel" sekmesi 3 alt-bolume ayrilir: Tanım / Sınıflandırma · Vergi & Ana Birim · Resim
            //   (Resim - IMAJ→DOSYA - hic acilmadi, alan yok). Ayri Mali/Diger SEKMESI YOK -
            //   mockup'ta da yok, KDV/OTV/Min Stok buraya katlandi (eskiden ayri sekmelerdi).
            new("kategori",      "kategori",        "kod",   Zorunlu: true, KodTablosu: "public.kategori", Baslik: "Kategori", AltGrup: "Tanım / Sınıflandırma"),
            new("marka",         "marka",           "kod",   KodListesi: "stok.marka",     Baslik: "Marka",     AltGrup: "Tanım / Sınıflandırma"),
            new("model",         "model",           "metin", EnFazlaUzunluk: 60, AltGrup: "Tanım / Sınıflandırma"),
            new("grup",          "grubu",           "kod",   KodListesi: "stok.grubu",     Baslik: "Grup",      AltGrup: "Tanım / Sınıflandırma"),
            new("izleme",        "izleme",          "kod",   KodListesi: "stok.izleme", Baslik: "Izleme",       AltGrup: "Tanım / Sınıflandırma"),
            new("bildirim",      "bildirim",        "kod",   SabitKodlar: BildirimKodlari, Baslik: "Bildirim",  AltGrup: "Tanım / Sınıflandırma"),
            new("urunNo",        "urun_no",         "metin", EnFazlaUzunluk: 60, Baslik: "Urun No",             AltGrup: "Vergi & Ana Birim"),
            new("gtipKodu",      "gtip_kodu",       "metin", EnFazlaUzunluk: 30, Baslik: "GTIP Kodu",           AltGrup: "Vergi & Ana Birim"),
            new("anaBirim",      "ana_birim",       "kod",   KodListesi: "stok.ana_birim",  Baslik: "Ana Birim",AltGrup: "Vergi & Ana Birim"),
            new("kdv",           "kdv",             "kod",   Zorunlu: true, SabitKodlar: KdvKodlari, Baslik: "KDV %", AltGrup: "Vergi & Ana Birim"),
            new("otvYuzde",      "otv_yuzde",       "para", Baslik: "OTV %",  AltGrup: "Vergi & Ana Birim"),
            new("internetSatis", "internet_satis",  "mantik", Baslik: "İnternet Satış", AltGrup: "Diğer",
                                                     EslesAlan: "paket"),
            // PAKET (124): isaretlenince kartta "Paket" sekmesi acilir, icerik
            //   orada tanimlanir. Internet Satis'in SAGINDA (ayni satirda).
            new("paket",         "paket",           "mantik", Baslik: "Paket", AltGrup: "Diğer"),
            // Mockup'ta 3. kutu "Resim" - bu alanlarin orada karsiligi yok, ust-satirin
            //   ALTINDA adsiz/duz bolum olarak kalsinlar (kasira'nin 2 kutusunu bozmasin).
            new("rafKonum",      "raf_konum",       "metin", EnFazlaUzunluk: 30, Baslik: "Raf / Konum",         AltGrup: "Diğer"),
            new("rafOmruSure",   "raf_omru_sure",   "sayi",  Baslik: "Raf Ömrü", AltGrup: "Diğer", EslesAlan: "rafOmruBirim"),
            new("rafOmruBirim",  "raf_omru_birim",  "kod",   SabitKodlar: RafOmruBirimKodlari, AltGrup: "Diğer"),
            // MINIMUM STOK karttan KALDIRILDI (kullanici karari): esik DEPO
            //   BAZINDA tutulur (stok_durum.min_stok, Stok Durumu sekmesi) -
            //   ayni urunun ana depodaki ve konsinye depodaki esigi ayni olmaz.
            //   Kolon veri olarak duruyor; eski degerler panel kritik listesinde
            //   depo esigi tanimlanmamis stoklar icin yedek olarak kullanilir.
            new("ozelKod",       "ozel_kod",        "metin", EnFazlaUzunluk: 20, AltGrup: "Diğer"),
            new("faturaStokAdi", "fatura_stok_adi", "metin", EnFazlaUzunluk: 200, Baslik: "Faturadaki Ad", AltGrup: "Diğer"),
            new("durum",         "durum",           "kod",   Zorunlu: true, SabitKodlar: DurumKodlari, Grup: "Kimlik"),
            new("subeId",        "sube_id",         "sayi",  Yazilabilir: false),
            new("eklemeTarihi",  "ekleme_tarihi",   "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            new DetayTanimi("barkodlar", "public.stok_barkod", "stok_id", new KartAlani[]
            {
                new("id",           "id",             "sayi", Yazilabilir: false),
                new("barkod",       "barkod",         "metin", Zorunlu: true, EnFazlaUzunluk: 50),
                // GENINI degil - Delphi kaynaginda BILE yorumlu ("tipleri programa gomdum"),
                //   asil kaynak BARKODAYARLAR (kullanici tanimli, bize hic migrate edilmedi,
                //   BILIM'de de bos) + 2 sabit secenek. O ikisi kondu, kullanici-tanimli
                //   tipler (nadir - 1419 satirin 1'i) EKLENMEDI.
                new("barkodTipi",   "barkod_tipi",    "kod", SabitKodlar: BarkodTipiKodlari, Baslik: "Barkod Tipi"),
                // Ayri GENINI bolumu yok - barkod_birimi/stok_fiyat.birim stok.ana_birim ile
                //   AYNI birim listesini paylasiyor (veride dogrulandi: 12=Gun,51=Adet,57=Kg...).
                new("barkodBirimi", "barkod_birimi",  "kod", KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("varsayilan",   "varsayilan",     "mantik")
            }, Sirala: "varsayilan desc, id", SubeKolonu: null, LogTabloId: 340,   // stok_barkodta sube_id YOK
                                                                                   // (GENINI -11110: Stok Barkod)
               Baslik: "Birim / Barkod"),                                         // mockup: "Birim / Barkod" sekmesi

            new DetayTanimi("fiyatlar", "public.stok_fiyat", "stok_id", new KartAlani[]
            {
                new("id",          "id",           "sayi", Yazilabilir: false),
                new("fiyatAdi",    "fiyat_adi",    "kod"),
                new("birim",       "birim",        "kod", KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("fiyat",       "fiyat",        "para", Zorunlu: true),
                new("dovizCinsi",  "doviz_cinsi",  "kod"),
                new("satis",       "satis",        "mantik")
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 346),  // stok_fiyatta sube_id YOK
                                                                   // (GENINI -11110: Stok Fiyat)

            // PAKET ICERIGI (124) - yalniz paket isaretliyse acilir. Kod
            //   secilir, ad otomatik gorunur; birim ve adet elle girilir.
            new DetayTanimi("paket", "public.stok_paket", "paket_stok_id", new KartAlani[]
            {
                new("id",            "id",             "sayi",  Yazilabilir: false),
                // SIRA alani kullaniciya SORULMAZ: pakette satir sirasi anlam
                //   tasimiyor, bos birakilinca da NOT NULL kolonu patlatiyordu.
                //   Gosterim sirasi ekleme sirasidir (id).
                new("icerikStokId",  "icerik_stok_id", "kod",   Zorunlu: true,
                    KodTablosu: "public.v_stok_lookup", Baslik: "Stok"),
                // Kod ve ad SALT OKUNUR: stok kartindan gelir, burada
                //   kopyalanmaz (stok adi degisirse bayatlardi).
                new("kod",           "(select s.kod from public.stok s where s.id = stok_paket.icerik_stok_id)",
                                                       "metin", Yazilabilir: false, Baslik: "Kod"),
                // Ad SALT OKUNUR: kod secilince kendi gelir, iki yerde ad
                //   tutmanin anlami yok (stok adi degisirse burasi bayatlardi).
                new("ad",            "(select s.ad from public.stok s where s.id = stok_paket.icerik_stok_id)",
                                                       "metin", Yazilabilir: false, Baslik: "Ad"),
                new("birim",         "birim",          "kod",   KodListesi: "stok.ana_birim", Baslik: "Birim"),
                new("adet",          "adet",           "para",  Zorunlu: true, Baslik: "Adet"),
                // Birim fiyat + doviz (125): paketin bedelinin icerige nasil
                //   dagildigi kart uzerinde okunsun. Belgeye paket eklenirken
                //   KULLANILMAZ (tutar paket satirinda durur).
                new("birimFiyat",    "birim_fiyat",    "para",  Baslik: "Birim Fiyat"),
                new("dovizCinsi",    "doviz_cinsi",    "kod",   SabitKodlar: DovizKodlari, Baslik: "Döviz")
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 920,
               Baslik: "Paket", KosulAlani: "paket"),

            // ÜTS / medikal bilgileri (119) - stok_uts 1:1 uzanti. Tek satirlik
            //   form olarak cizilir (grid degil): bir stokun BIR ÜTS kaydi olur.
            //   Alan sirasi mockup'takiyle (stok_karti.html "ÜTS Bilgileri" =
            //   Delphi UStokWizard.TabSheetUTS) ayni.
            new DetayTanimi("uts", "public.stok_uts", "stok_id", new KartAlani[]
            {
                new("id",            "id",             "sayi",  Yazilabilir: false),
                new("sutKodu",       "sut_kodu",       "metin", EnFazlaUzunluk: 50,  Baslik: "SUT Kodu"),
                new("bransKodu",     "brans_kodu",     "metin", EnFazlaUzunluk: 100, Baslik: "Branş Kodu"),
                new("utsRef",        "uts_ref",        "metin", EnFazlaUzunluk: 100, Baslik: "ÜTS REF (Katalog No)"),
                new("ftn",           "ftn",            "metin", EnFazlaUzunluk: 100, Baslik: "FTN"),
                new("gmdn",          "gmdn",           "metin", EnFazlaUzunluk: 100, Baslik: "GMDN"),
                new("gmdnAdi",       "gmdn_adi",       "metin", EnFazlaUzunluk: 300, Baslik: "GMDN Adı"),
                new("digerUrunAdi",  "diger_urun_adi", "metin", EnFazlaUzunluk: 300, Baslik: "Diğer Ürün Adı"),
                new("medikalSinif",  "medikal_sinif",  "kod",   KodListesi: "stok.medikal_sinif", Baslik: "Sınıf"),
                new("ithalImal",     "ithal_imal",     "kod",   KodListesi: "stok.ithal_imal", Baslik: "İthal / İmal"),
                new("menseiUlke",    "mensei_ulke",    "kod",   KodTablosu: "public.v_ulke_lookup", Baslik: "Menşei Ülke"),
                new("ihaleSiraNo",   "ihale_sira_no",  "metin", EnFazlaUzunluk: 100, Baslik: "İhale Sıra No"),
                new("dmoKodu",       "dmo_kodu",       "metin", EnFazlaUzunluk: 40,  Baslik: "DMO Şartname Kodu"),
                new("smKodu",        "sm_kodu",        "metin", EnFazlaUzunluk: 40,  Baslik: "SM Kodu")
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 903, Baslik: "ÜTS Bilgileri"),

            // "Seri / Lot" AYRI SEKME DEGIL (kullanici karari, 115): lot dokumu
            //   artik Stok Durumu sekmesinde DEPO BAZINDA, master-detail olarak.
            //   Ayri sekme lotlari depodan bagimsiz tek liste halinde gosteriyordu
            //   ve "hangi depoda hangi lottan ne kadar var" sorusunu
            //   cevaplamiyordu. Lotlar belge kaydiyla olusur, elle acilmaz.
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge_satir", "stok_id", "Bu stok belgelerde kullanilmis, silinemez."),
            new SilmeEngeli("public.stok_izleme", "stok_id", "Bu stokun hareket kaydi var, silinemez.")
        });

    // ======================================================== KASA ANA VERI ====

    // hesap.tur - tek tabloda kasa/banka/POS/kredi karti/kredi/kupon (K1, 071).
    //   Harfler mali_hareket.hesap_turu ile AYNI kod uzayindan gelir.
    private static readonly Dictionary<string, string> HesapTuruKodlari =
        new() { ["K"] = "Kasa", ["B"] = "Banka", ["P"] = "POS",
                ["V"] = "Kredi Kartı", ["R"] = "Kredi", ["H"] = "Kupon Kasası" };

    // POS komisyonunun ne zaman kesildigi (eski POS.MASRAFCIKIS).
    private static readonly Dictionary<string, string> KomisyonZamaniKodlari =
        new() { ["1"] = "Bankaya aktarımda", ["2"] = "Tahsilat anında" };

    private static readonly Dictionary<string, string> ProjeDurumKodlari =
        new() { ["1"] = "Açık", ["2"] = "Tamamlandı", ["0"] = "İptal" };

    private static readonly Dictionary<string, string> HesapSinifKodlari =
        new() { ["1"] = "Aktif", ["2"] = "Pasif", ["3"] = "Gelir",
                ["4"] = "Gider", ["5"] = "Maliyet", ["6"] = "Nazım" };

    private static readonly Dictionary<string, string> CekSenetTurKodlari =
        new() { ["1"] = "Çek", ["2"] = "Senet" };

    private static readonly Dictionary<string, string> CekSenetYonKodlari =
        new() { ["1"] = "Alınan", ["2"] = "Verilen" };

    private static readonly Dictionary<string, string> CekSenetDurumKodlari =
        new() { ["10"] = "Portföyde", ["20"] = "Ciro Edildi", ["30"] = "Bankada Tahsilde",
                ["40"] = "Teminatta", ["50"] = "Tahsil Edildi / Ödendi", ["60"] = "Karşılıksız",
                ["70"] = "İade Edildi", ["0"] = "İptal" };

    // --------------------------------------------------------------- hesap ----
    // Tur-ozel alanlar (Banka / POS-Kart) AltGrup ile ayrilir; GenForm bunlari
    //   ayri kutularda cizer. Bos kalmalari normaldir (kasa hesabinda IBAN yok).
    private static KartTanimi Hesap() => new(
        Ad: "hesap",
        YetkiKodu: "hesap",
        Tablo: "public.hesap",
        LogTabloId: 909,
        SubeKolonu: "sube_id",                // K11: her hesap tek subeye ait
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["dovizCinsi"] = "TL", ["tur"] = "K" },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",                "sayi",  Yazilabilir: false),
            new("tur",             "tur",               "kod",   Zorunlu: true, SabitKodlar: HesapTuruKodlari, Baslik: "Hesap Türü", Grup: "Kimlik"),
            new("kod",             "kod",               "metin", EnFazlaUzunluk: 40,  Baslik: "Kod",  Grup: "Kimlik"),
            new("ad",              "ad",                "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Ad", Grup: "Kimlik"),
            new("dovizCinsi",      "doviz_cinsi",       "kod",   Zorunlu: true, SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Kimlik"),
            new("durum",           "durum",             "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // --- Genel
            new("sorumluId",       "sorumlu_id",        "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Tanımlama"),
            new("bagliHesapId",    "bagli_hesap_id",    "kod",   KodTablosu: "public.v_hesap_lookup", Baslik: "Bağlı Hesap", Grup: "Genel", AltGrup: "Tanımlama"),
            new("altTur",          "alt_tur",           "kod",   KodListesi: "hesap.alt_tur", Baslik: "Alt Tür", Grup: "Genel", AltGrup: "Tanımlama"),
            new("aciklama",        "aciklama",          "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Tanımlama"),
            // Banka ve sube artik TANIM tablosundan secilir (109): elle yazilinca ayni
            //   banka uc farkli yazimla kaydediliyordu ("Ziraat", "T.C. Ziraat...").
            new("bankaId",         "banka_id",          "kod",   KodTablosu: "public.v_banka_lookup", Baslik: "Banka", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("bankaSubeId",     "banka_sube_id",     "kod",   KodTablosu: "public.v_banka_sube_lookup", BagliAlan: "bankaId", Baslik: "Şube", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("hesapNo",         "hesap_no",          "metin", EnFazlaUzunluk: 30, Baslik: "Hesap No", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("iban",            "iban",              "metin", EnFazlaUzunluk: 34, Baslik: "IBAN", Grup: "Genel", AltGrup: "Banka Bilgileri"),
            new("komisyonOrani",   "komisyon_orani",    "para",  Baslik: "Komisyon %", Grup: "Genel", AltGrup: "POS / Kart"),
            new("komisyonMasrafId","komisyon_masraf_id","kod",   KodTablosu: "public.v_masraf_lookup", Baslik: "Komisyon Gider Kalemi", Grup: "Genel", AltGrup: "POS / Kart"),
            new("komisyonZamani",  "komisyon_zamani",   "kod",   SabitKodlar: KomisyonZamaniKodlari, Baslik: "Komisyon Kesimi", Grup: "Genel", AltGrup: "POS / Kart"),
            new("valorGun",        "valor_gun",         "sayi",  Baslik: "Valör (gün)", Grup: "Genel", AltGrup: "POS / Kart"),
            new("hesapKesimGunu",  "hesap_kesim_gunu",  "sayi",  Baslik: "Hesap Kesim Günü", Grup: "Genel", AltGrup: "POS / Kart"),
            new("sonOdemeGunu",    "son_odeme_gunu",    "sayi",  Baslik: "Son Ödeme Günü", Grup: "Genel", AltGrup: "POS / Kart"),
            new("limitTutar",      "limit_tutar",       "para",  Baslik: "Limit", Grup: "Genel", AltGrup: "POS / Kart"),
            new("acilisBakiye",    "acilis_bakiye",     "para",  Baslik: "Açılış Bakiyesi", Grup: "Genel", AltGrup: "Muhasebe"),
            new("acilisTarihi",    "acilis_tarihi",     "tarih", Baslik: "Açılış Tarihi", Grup: "Genel", AltGrup: "Muhasebe"),
            new("muhHesapId",      "muh_hesap_id",      "kod",   KodTablosu: "public.v_hesap_plani_lookup", Baslik: "Muhasebe Hesabı", Grup: "Genel", AltGrup: "Muhasebe"),
            new("subeId",          "sube_id",           "sayi",  Yazilabilir: false, Baslik: "Şube"),
            new("eklemeTarihi",    "ekleme_tarihi",     "tarih", Yazilabilir: false)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.mali_hareket", "hesap_id", "Bu hesabin hareketi var, silinemez."),
            new SilmeEngeli("public.kasa_islem",   "hesap_id", "Bu hesaba ait kasa islemi var, silinemez.")
        });


    /// <summary>
    /// Kartlarda kullanilan para birimleri. doviz_kur tablosundaki kodlarla ayni
    /// (TL yerel, digerleri kur tablosundan okunur) - elle metin girilince
    /// "TRY"/"tl" gibi varyantlar olusup kur eslesmesi kaciyordu.
    /// </summary>
    private static readonly Dictionary<string, string> DovizKodlari =
        new() { ["TL"] = "TL", ["USD"] = "USD", ["EUR"] = "EUR",
                ["GBP"] = "GBP", ["CHF"] = "CHF", ["JPY"] = "JPY" };

    // --------------------------------------------------------------- gorev ----
    private static readonly Dictionary<string, string> GorevTurKodlari =
        new() { ["1"] = "Görev", ["2"] = "Hatırlatma", ["3"] = "Görüşme / Aktivite",
                ["4"] = "Toplantı", ["9"] = "Diğer" };

    private static readonly Dictionary<string, string> GorevDurumKodlari =
        new() { ["0"] = "Bekliyor", ["1"] = "Devam Ediyor",
                ["2"] = "Tamamlandı", ["3"] = "İptal" };

    private static readonly Dictionary<string, string> GorevOncelikKodlari =
        new() { ["1"] = "Düşük", ["2"] = "Normal", ["3"] = "Yüksek", ["4"] = "Acil" };

    private static readonly Dictionary<string, string> GorevKategoriKodlari =
        new() { ["0"] = "Genel", ["1"] = "Satış", ["2"] = "Muhasebe",
                ["3"] = "Depo", ["4"] = "İK", ["5"] = "Teknik" };

    /// <summary>
    /// Gorev / hatirlatma / takvim karti (108). Mockup: gorev_karti.html -
    /// Konu, Tur, Kategori, Oncelik, Durum, Ilerleme, Sorumlu, Baslangic,
    /// Termin, Hatirlatma, Ilgili Cari / Proje.
    /// </summary>
    private static KartTanimi Gorev() => new(
        Ad: "gorev",
        YetkiKodu: "gorev",
        Tablo: "public.gorev",
        LogTabloId: 918,                      // yeni tablo - eski karsiligi yok
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["tur"] = (short)1, ["durum"] = (short)0, ["oncelik"] = (short)2 },
        Alanlar: new KartAlani[]
        {
            new("id",         "id",         "sayi",  Yazilabilir: false),
            new("gorevNo",    "gorev_no",   "metin", EnFazlaUzunluk: 20, Baslik: "Görev No",
                                            Yazilabilir: false, Grup: "Kimlik"),
            new("konu",       "konu",       "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                                            Baslik: "Konu", Grup: "Kimlik"),
            new("oncelik",    "oncelik",    "kod",   SabitKodlar: GorevOncelikKodlari,
                                            Baslik: "Öncelik", Grup: "Kimlik"),
            new("durum",      "durum",      "kod",   SabitKodlar: GorevDurumKodlari,
                                            Baslik: "Durum", Grup: "Kimlik"),

            new("tur",        "tur",        "kod",   SabitKodlar: GorevTurKodlari,
                                            Baslik: "Tür", Grup: "Genel", AltGrup: "Görev Bilgileri"),
            new("kategori",   "kategori",   "kod",   SabitKodlar: GorevKategoriKodlari,
                                            Baslik: "Kategori", Grup: "Genel", AltGrup: "Görev Bilgileri"),
            new("sorumluId",  "sorumlu_id", "kod",   KodTablosu: "public.v_personel_lookup",
                                            Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Görev Bilgileri"),
            new("ilerleme",   "ilerleme",   "sayi",  Baslik: "İlerleme %",
                                            Grup: "Genel", AltGrup: "Görev Bilgileri"),

            new("baslangic",  "baslangic",  "tarih", Baslik: "Başlangıç",
                                            Grup: "Genel", AltGrup: "Zaman"),
            new("termin",     "termin",     "tarih", Baslik: "Termin",
                                            Grup: "Genel", AltGrup: "Zaman"),
            new("hatirlatma", "hatirlatma", "tarih", Baslik: "Hatırlatma",
                                            Grup: "Genel", AltGrup: "Zaman"),
            new("tumGun",     "tum_gun",    "mantik", Baslik: "Tüm Gün",
                                            Grup: "Genel", AltGrup: "Zaman"),

            new("tarafId",    "taraf_id",   "kod",   KodTablosu: "public.v_cari_lookup",
                                            Baslik: "İlgili Cari", Grup: "Genel", AltGrup: "İlgili Kayıt"),
            new("projeId",    "proje_id",   "kod",   KodTablosu: "public.v_proje_lookup",
                                            Baslik: "İlgili Proje", Grup: "Genel", AltGrup: "İlgili Kayıt"),
            new("aciklama",   "aciklama",   "metin", EnFazlaUzunluk: 4000, Baslik: "Açıklama",
                                            Grup: "Genel", AltGrup: "İlgili Kayıt"),

            new("tamamlanma", "tamamlanma", "tarih", Yazilabilir: false),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false)
        });


    // --------------------------------------------------------------- banka ----
    /// <summary>
    /// Banka tanimi ve SUBELERI (109). Subeler ayri bir ekran degil, bankanin
    /// detay tablosu: sube tek basina anlamsizdir, hep bir bankaya aittir.
    /// </summary>
    private static KartTanimi Banka() => new(
        Ad: "banka",
        YetkiKodu: "hesap",                   // banka tanimi kasa/banka ekibinin isi
        Tablo: "public.banka",
        LogTabloId: 919,
        SubeKolonu: null,                     // ana veri - subeler arasi ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",      "id",      "sayi",  Yazilabilir: false),
            new("kod",     "kod",     "metin", EnFazlaUzunluk: 10, Baslik: "EFT Kodu", Grup: "Kimlik"),
            new("ad",      "ad",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Banka Adı", Grup: "Kimlik"),
            new("kisaAd",  "kisa_ad", "metin", EnFazlaUzunluk: 40, Baslik: "Kısa Ad", Grup: "Kimlik"),
            new("aktif",   "aktif",   "mantik", Baslik: "Aktif", Grup: "Kimlik"),
            new("swift",   "swift",   "metin", EnFazlaUzunluk: 15, Baslik: "SWIFT / BIC", Grup: "Genel"),
            new("sira",    "sira",    "sayi",  Baslik: "Sıra", Grup: "Genel"),
        },
        Detaylar: new[]
        {
            new DetayTanimi("subeler", "public.banka_sube", "banka_id", new KartAlani[]
            {
                new("id",      "id",      "sayi",  Yazilabilir: false),
                new("kod",     "kod",     "metin", EnFazlaUzunluk: 10, Baslik: "Kod"),
                new("ad",      "ad",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Şube Adı"),
                new("il",      "il",      "metin", EnFazlaUzunluk: 60, Baslik: "İl"),
                new("ilce",    "ilce",    "metin", EnFazlaUzunluk: 60, Baslik: "İlçe"),
                new("telefon", "telefon", "metin", EnFazlaUzunluk: 30, Baslik: "Telefon"),
                new("aktif",   "aktif",   "mantik", Baslik: "Aktif"),
            }, Sirala: "ad", SubeKolonu: null, LogTabloId: 920, Baslik: "Şubeler")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.hesap",     "banka_id", "Bu bankaya bagli hesap var, silinemez."),
            new SilmeEngeli("public.cek_senet", "banka_id", "Bu bankaya bagli cek/senet var, silinemez."),
        });

    // --------------------------------------------------------------- proje ----
    private static KartTanimi Proje() => new(
        Ad: "proje",
        YetkiKodu: "proje",
        Tablo: "public.proje",
        LogTabloId: 913,
        SubeKolonu: null,                     // ana veri - subeler arasi ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["butceDovizi"] = "TL" },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("kod",         "kod",          "metin", EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik"),
            new("ad",          "ad",           "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Proje Adı", Grup: "Kimlik"),
            new("durum",       "durum",        "kod",   SabitKodlar: ProjeDurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            new("ustId",       "ust_id",       "kod",   KodTablosu: "public.v_proje_lookup", Baslik: "Üst Proje", Grup: "Genel", AltGrup: "Tanımlama"),
            new("tarafId",     "taraf_id",     "kod",   KodTablosu: "public.v_cari_lookup", Baslik: "Müşteri", Grup: "Genel", AltGrup: "Tanımlama"),
            new("sorumluId",   "sorumlu_id",   "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Tanımlama"),
            new("baslangic",   "baslangic",    "tarih", Baslik: "Başlangıç", Grup: "Genel", AltGrup: "Süre"),
            new("bitis",       "bitis",        "tarih", Baslik: "Bitiş", Grup: "Genel", AltGrup: "Süre"),
            new("butceTutar",  "butce_tutar",  "para",  Baslik: "Bütçe", Grup: "Genel", AltGrup: "Bütçe"),
            new("butceDovizi", "butce_dovizi", "metin", EnFazlaUzunluk: 6, Baslik: "Bütçe Dövizi", Grup: "Genel", AltGrup: "Bütçe"),
            new("aciklama",    "aciklama",     "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Bütçe"),
            new("eklemeTarihi","ekleme_tarihi","tarih", Yazilabilir: false)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.kasa_islem",   "proje_id", "Bu projeye ait kasa islemi var, silinemez."),
            new SilmeEngeli("public.mali_hareket", "proje_id", "Bu projeye ait hareket var, silinemez."),
            new SilmeEngeli("public.belge",        "proje_id", "Bu projeye ait belge var, silinemez.")
        });

    // ------------------------------------------------------ masraf merkezi ----
    private static KartTanimi MasrafMerkezi() => new(
        Ad: "masraf-merkezi",
        YetkiKodu: "masraf_merkezi",
        Tablo: "public.masraf_merkezi",
        LogTabloId: 915,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",    "id",     "sayi",  Yazilabilir: false),
            new("kod",   "kod",    "metin", EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik"),
            new("ad",    "ad",     "metin", Zorunlu: true, EnFazlaUzunluk: 100, Baslik: "Ad", Grup: "Kimlik"),
            new("ustId", "ust_id", "kod",   KodTablosu: "public.v_masraf_merkezi_lookup", Baslik: "Üst Merkez", Grup: "Kimlik"),
            new("durum", "durum",  "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.mali_hareket", "merkez_id", "Bu merkeze ait hareket var, silinemez.")
        });

    // ----------------------------------------------------------------- depo ----
    // Stok Ayarlari ekraninin "Depolar" sekmesi. Varsayilan depo TEKTIR
    //   (ux_depo_varsayilan); ikinci bir depo varsayilan yapilinca eskisini
    //   trg_depo_varsayilan_tek (db/090) birakir - kart ozel kod tasimaz.
    private static KartTanimi Depo() => new(
        Ad: "depo",
        YetkiKodu: "stok",
        Tablo: "public.depo",
        LogTabloId: 918,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["maliyetiEtkilesin"] = (short)1, ["varsayilan"] = (short)0,
              ["tip"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            // Alan sirasi = GRID kolon sirasi (kullanici istegi): ekranda gorulen
            //   duzenle karta girince degismesin.
            new("id",                 "id",                 "sayi",  Yazilabilir: false),
            new("ad",                 "ad",                 "metin", Zorunlu: true, EnFazlaUzunluk: 50,
                Baslik: "Depo Adı", Grup: "Genel"),
            new("tip",                "tip",                "kod",   Zorunlu: true, KodListesi: "depo.tip",
                Baslik: "Tipi", Grup: "Genel"),
            new("durum",              "durum",              "kod",   Zorunlu: true, SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Genel"),
            new("maliyetiEtkilesin",  "maliyeti_etkilesin", "mantik", Baslik: "Maliyeti Etkilesin", Grup: "Genel"),
            new("varsayilan",         "varsayilan",         "mantik", Baslik: "Varsayılan Depo", Grup: "Genel")
            // son_sayim_tarihi kartta YOK: sayim modulu henuz olmadigi icin hep bos
            //   duruyordu; kolon tabloda kaliyor, sayim gelince geri eklenir.
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.stok_durum",  "depo_id",        "Bu depoda stok bakiyesi var, silinemez."),
            new SilmeEngeli("public.belge",       "cikis_depo_id",  "Bu depodan cikisli belge var, silinemez."),
            new SilmeEngeli("public.belge",       "giris_depo_id",  "Bu depoya girisli belge var, silinemez."),
            new SilmeEngeli("public.belge_satir", "cikis_depo_id",  "Bu depodan cikisli belge satiri var, silinemez."),
            new SilmeEngeli("public.belge_satir", "giris_depo_id",  "Bu depoya girisli belge satiri var, silinemez.")
        });

    // ---------------------------------------------------------- hesap plani ----
    private static KartTanimi HesapPlani() => new(
        Ad: "hesap-plani",
        YetkiKodu: "hesap_plani",
        Tablo: "public.hesap_plani",
        LogTabloId: 914,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["dovizCinsi"] = "TL", ["calisirMi"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",             "sayi",  Yazilabilir: false),
            new("kod",          "kod",            "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Hesap Kodu", Grup: "Kimlik"),
            new("ad",           "ad",             "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Hesap Adı", Grup: "Kimlik"),
            new("sinif",        "sinif",          "kod",   SabitKodlar: HesapSinifKodlari, Baslik: "Sınıf", Grup: "Kimlik"),
            new("durum",        "durum",          "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            new("ustId",        "ust_id",         "kod",   KodTablosu: "public.v_hesap_plani_lookup", Baslik: "Üst Hesap", Grup: "Genel"),
            new("seviye",       "seviye",         "sayi",  Baslik: "Seviye", Grup: "Genel"),
            // calisir_mi: yalniz YAPRAK hesaplar fis satiri alabilir (ara hesaba kayit yasak)
            new("calisirMi",    "calisir_mi",     "mantik", Baslik: "Fiş satırı alabilir", Grup: "Genel"),
            new("cariAltHesap", "cari_alt_hesap", "mantik", Baslik: "Cari alt hesabı açılsın", Grup: "Genel"),
            new("dovizCinsi",   "doviz_cinsi",    "kod",   SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Genel")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.muhasebe_fis_satir", "hesap_plani_id", "Bu hesaba fis satiri yazilmis, silinemez.")
        });

    // --------------------------------------------------------------- firsat ----
    // CRM satis firsati karti (121, mockup firsat_karti.html). Kimlik seridi
    //   mockup'takiyle ayni: Fırsat No · Konu · Aşama · Durum.
    //
    // FIRSAT NO kullanici bos birakirsa DB tetigi uretir (FRS.<yil>-<id>) -
    //   sayac tablosuna gerek yok, numara id'den turedigi icin mukerrer olmaz.
    // AGIRLIKLI TUTAR kartta YOK: listede hesaplanan bir kolon, kartta ikinci
    //   kez gostermek "girilebilir" izlenimi verirdi.
    private static KartTanimi Firsat() => new(
        Ad: "firsat",
        YetkiKodu: "firsat",
        Tablo: "public.firsat",
        LogTabloId: 918,
        SubeKolonu: "sube_id",
        KapsamKolonu: "taraf_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1, ["asama"] = (short)1, ["oncelik"] = (short)2,
              ["dovizCinsi"] = "TL", ["dovizKuru"] = 1m, ["olasilik"] = (short)10 },
        // Yeni firsatta ilk is MUSTERIYI/ADAYI secmektir (cek-senet deseni).
        AcilistaTarafSecimi: "tarafId",
        Doviz: new DovizKurali("dovizCinsi", "dovizKuru", "tahminiTutar", "", "beklenenKapanis"),
        Alanlar: new KartAlani[]
        {
            new("id",               "id",                "sayi",  Yazilabilir: false),
            new("firsatNo",         "firsat_no",         "metin", EnFazlaUzunluk: 30, Baslik: "Fırsat No", Grup: "Kimlik"),
            new("konu",             "konu",              "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Konu", Grup: "Kimlik"),
            new("asama",            "asama",             "kod",   Zorunlu: true, KodListesi: "firsat.asama", Baslik: "Aşama", Grup: "Kimlik"),
            new("durum",            "durum",             "kod",   Zorunlu: true, KodListesi: "firsat.durum", Baslik: "Durum", Grup: "Kimlik"),

            new("tarafId",          "taraf_id",          "kod",   Zorunlu: true, KodTablosu: "public.v_cari_lookup", Baslik: "Müşteri / Aday", Grup: "Genel", AltGrup: "Fırsat"),
            new("kaynak",           "kaynak",            "kod",   KodListesi: "firsat.kaynak", Baslik: "Kaynak", Grup: "Genel", AltGrup: "Fırsat"),
            new("tur",              "tur",               "kod",   KodListesi: "firsat.tur", Baslik: "Tür", Grup: "Genel", AltGrup: "Fırsat"),
            new("oncelik",          "oncelik",           "kod",   KodListesi: "firsat.oncelik", Baslik: "Öncelik", Grup: "Genel", AltGrup: "Fırsat"),
            new("sorumluId",        "sorumlu_id",        "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Genel", AltGrup: "Fırsat"),

            new("tahminiTutar",     "tahmini_tutar",     "para",  Baslik: "Tahmini Tutar", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("dovizCinsi",       "doviz_cinsi",       "kod",   SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("dovizKuru",        "doviz_kuru",        "para",  Baslik: "Kur", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("olasilik",         "olasilik",          "sayi",  Baslik: "Olasılık %", Grup: "Genel", AltGrup: "Tutar / Tahmin"),
            new("beklenenKapanis",  "beklenen_kapanis",  "tarih", Baslik: "Beklenen Kapanış", Grup: "Genel", AltGrup: "Tutar / Tahmin"),

            new("sonTemas",         "son_temas",         "tarih", Baslik: "Son Temas", Grup: "Genel", AltGrup: "Takip"),
            new("sonrakiAksiyon",   "sonraki_aksiyon",   "metin", EnFazlaUzunluk: 200, Baslik: "Sonraki Aksiyon", Grup: "Genel", AltGrup: "Takip"),
            new("kapanisTarihi",    "kapanis_tarihi",    "tarih", Baslik: "Kapanış Tarihi", Grup: "Genel", AltGrup: "Takip"),
            new("kayipNedeni",      "kayip_nedeni",      "metin", EnFazlaUzunluk: 200, Baslik: "Kayıp Nedeni", Grup: "Genel", AltGrup: "Takip"),
            new("aciklama",         "aciklama",          "metin", Baslik: "Açıklama", Grup: "Genel", AltGrup: "Notlar"),

            new("subeId",           "sube_id",           "sayi",  Yazilabilir: false, Baslik: "Şube"),
            new("eklemeTarihi",     "ekleme_tarihi",     "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // "Ürünler": talep edilen kalemler - TAHMIN, belge degil (stok/cari
            //   etkilemez). Firsat kazanilinca teklif/siparise donusturulur.
            new DetayTanimi("urunler", "public.firsat_urun", "firsat_id", new KartAlani[]
            {
                new("id",          "id",          "sayi",  Yazilabilir: false),
                new("sira",        "sira",        "sayi",  Baslik: "Sıra"),
                new("stokId",      "stok_id",     "kod",   KodTablosu: "public.v_stok_lookup", Baslik: "Stok"),
                new("aciklama",    "aciklama",    "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
                new("miktar",      "miktar",      "para",  Baslik: "Miktar"),
                new("birimFiyat",  "birim_fiyat", "para",  Baslik: "Birim Fiyat"),
                new("tutar",       "tutar",       "para",  Baslik: "Tutar")
            }, Sirala: "sira, id", SubeKolonu: null, LogTabloId: 919, Baslik: "Ürünler"),

            // "Aktiviteler": firsata bagli gorusme/toplanti/hatirlatma. Ayri
            //   tablo YOK - gorev (108) tablosundaki firsat_id ile baglanir.
            new DetayTanimi("aktiviteler", "public.gorev", "firsat_id", new KartAlani[]
            {
                new("id",         "id",         "sayi",  Yazilabilir: false),
                new("tur",        "tur",        "kod",   KodListesi: "gorev.tur", Baslik: "Tür"),
                new("konu",       "konu",       "metin", EnFazlaUzunluk: 200, Baslik: "Konu"),
                new("sorumluId",  "sorumlu_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu"),
                new("baslangic",  "baslangic",  "tarih", Baslik: "Başlangıç"),
                new("termin",     "termin",     "tarih", Baslik: "Termin"),
                new("durum",      "durum",      "kod",   KodListesi: "gorev.durum", Baslik: "Durum")
            }, Sirala: "coalesce(baslangic, ekleme_tarihi) desc, id desc", LogTabloId: 108, Baslik: "Aktiviteler")
        },
        SilmeEngelleri: Array.Empty<SilmeEngeli>());

    // ------------------------------------------------------------ cek/senet ----
    // durum Yazilabilir:false - portfoy durumu ELLE degil, yalnizca aksiyonlarla
    //   (tahsil / ciro / bozdur / iade) degisir; her degisim cek_senet_hareket'e
    //   iz birakir. Elle degistirilebilse defter ile durum tutarsizlasirdi.
    private static KartTanimi CekSenet() => new(
        Ad: "cek-senet",
        YetkiKodu: "cek_senet",
        Tablo: "public.cek_senet",
        LogTabloId: 910,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)10, ["tur"] = (short)1, ["yon"] = (short)1,
              ["dovizCinsi"] = "TL", ["dovizKuru"] = 1m },
        // Yeni cek/senette ilk is kimin kagidi oldugunu secmektir.
        AcilistaTarafSecimi: "tarafId",
        // TL disi bir para birimi secilirse kur cek tarihinin kurundan gelir ve
        //   yerel karsilik (yerelTutar) hesaplanir - portfoy toplami tek para
        //   biriminde okunabilsin diye.
        Doviz: new DovizKurali("dovizCinsi", "dovizKuru", "tutar", "yerelTutar", "tarih"),
        Alanlar: new KartAlani[]
        {
            new("id",            "id",              "sayi",  Yazilabilir: false),
            // TUR kimlik seridinde DEGIL (kullanici karari): kagidin cek mi senet mi
            //   oldugu zaten hangi listeden gelindigiyle belli - seride kimin
            //   kagidi oldugu (CARI) daha degerli. Alan yine var, "Genel"de.
            new("tarafId",       "taraf_id",        "kod",   KodTablosu: "public.v_cari_lookup", Baslik: "Cari", Grup: "Kimlik"),
            new("yon",           "yon",             "kod",   Zorunlu: true, SabitKodlar: CekSenetYonKodlari, Baslik: "Yön", Grup: "Kimlik"),
            new("seriNo",        "seri_no",         "metin", EnFazlaUzunluk: 30, Baslik: "Seri No", Grup: "Kimlik"),
            new("durum",         "durum",           "kod",   Yazilabilir: false, SabitKodlar: CekSenetDurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // Tür ARKA PLANDA: hangi listeden gelindiyse o deger yazilir (Cek/Senet
            //   listesi varsayilani), ekranda hic gorunmez.
            new("tur",           "tur",             "kod",   Zorunlu: true, SabitKodlar: CekSenetTurKodlari, Baslik: "Tür", Gizli: true),
            new("kesideci",      "kesideci",        "metin", EnFazlaUzunluk: 150, Baslik: "Keşideci", Grup: "Genel", AltGrup: "Taraf"),
            new("ciroTarafId",   "ciro_taraf_id",   "kod",   Yazilabilir: false, KodTablosu: "public.v_cari_lookup", Baslik: "Ciro Edilen", Grup: "Genel", AltGrup: "Taraf"),
            new("tarih",         "tarih",           "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("vade",          "vade",            "tarih", Zorunlu: true, Baslik: "Vade", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("tutar",         "tutar",           "para",  Zorunlu: true, Baslik: "Tutar", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("dovizCinsi",    "doviz_cinsi",     "kod",   SabitKodlar: DovizKodlari, Baslik: "Para Birimi", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("dovizKuru",     "doviz_kuru",      "para",  Baslik: "Kur", Grup: "Genel", AltGrup: "Tutar / Vade"),
            // Yerel karsilik SUNUCUDA hesaplanir (tutar x kur) - kullanici
            //   yazamaz; yoksa kurla tutarsiz bir yerel tutar kaydedilebilirdi.
            new("yerelTutar",    "yerel_tutar",     "para",  Yazilabilir: false, Baslik: "Yerel Tutar", Grup: "Genel", AltGrup: "Tutar / Vade"),
            new("bankaId",       "banka_id",        "kod",   KodTablosu: "public.v_banka_lookup", Baslik: "Banka", Grup: "Genel", AltGrup: "Banka"),
            new("bankaSubeId",   "banka_sube_id",   "kod",   KodTablosu: "public.v_banka_sube_lookup", BagliAlan: "bankaId", Baslik: "Şube", Grup: "Genel", AltGrup: "Banka"),
            new("hesapNo",       "hesap_no",        "metin", EnFazlaUzunluk: 30, Baslik: "Hesap No", Grup: "Genel", AltGrup: "Banka"),
            new("hesapId",       "hesap_id",        "kod",   Yazilabilir: false, KodTablosu: "public.v_hesap_lookup", Baslik: "Bulunduğu Hesap", Grup: "Genel", AltGrup: "Banka"),
            new("projeId",       "proje_id",        "kod",   KodTablosu: "public.v_proje_lookup", Baslik: "Proje", Grup: "Genel", AltGrup: "Diğer"),
            new("makbuzNo",      "makbuz_no",       "metin", EnFazlaUzunluk: 30, Baslik: "Makbuz No", Grup: "Genel", AltGrup: "Diğer"),
            new("aciklama",      "aciklama",        "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama", Grup: "Genel", AltGrup: "Diğer"),
            new("subeId",        "sube_id",         "sayi",  Yazilabilir: false, Baslik: "Şube"),
            new("eklemeTarihi",  "ekleme_tarihi",   "tarih", Yazilabilir: false)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.mali_hareket", "cek_senet_id", "Bu cek/senedin hareketi var, silinemez.")
        });
}



