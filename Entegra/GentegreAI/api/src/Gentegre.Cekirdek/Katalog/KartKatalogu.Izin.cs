namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// İZİN KARTLARI (743) — izin talebi ve yıllık izin hakkı.
///
/// GÜN KARTTAN YAZILMAZ: başlangıç/bitişten hesaplanır (`fn_izin_gun`).
/// Elle girilebilseydi ekranın gösterdiği ile bakiyeden düşen farklı
/// olabilir ve fark kimsenin dikkatini çekmeden bakiyeyi eritirdi.
///
/// DURUM DA KARTTAN YAZILMAZ: izin onay omurgasından (738) geçer - karta
/// "Onaylı" yazmak, imzasız bir onay üretmekti. Eski `personel_izin` tam
/// olarak buydu: durum kolonu vardı, onaylayanı yoktu.
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>personel_izin.durum (743 ile onay omurgasına hizalandı).</summary>
    private static readonly Dictionary<string, string> IzinDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylı",
        ["3"] = "Reddedildi", ["4"] = "İptal",
    };

    private static readonly Dictionary<string, string> IzinTurKodlari = new()
    {
        ["1"] = "Yıllık İzin", ["2"] = "Mazeret", ["3"] = "Rapor",
        ["4"] = "Ücretsiz İzin", ["9"] = "Diğer",
    };

    // ------------------------------------------------------ izin talebi ----
    private static KartTanimi PersonelIzin() => new(
        Ad: "personelIzin",
        YetkiKodu: "ik.izin",
        Tablo: "public.personel_izin",
        LogTabloId: 904,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("izinNo", "izin_no", "metin", Yazilabilir: false, Baslik: "İzin No",
                Grup: "İzin", EnFazlaUzunluk: 30),
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Personel",
                Grup: "İzin", KodTablosu: "public.v_personel_lookup"),
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "İzin Türü", Grup: "İzin",
                SabitKodlar: IzinTurKodlari),
            new("baslangicTarihi", "baslangic_tarihi", "tarih", Zorunlu: true,
                Baslik: "Başlangıç", Grup: "İzin"),
            new("bitisTarihi", "bitis_tarihi", "tarih", Zorunlu: true, Baslik: "Bitiş",
                Grup: "İzin"),
            // İŞ GÜNÜ Mü TAKVİM GÜNÜ Mü: izin TÜRÜNE göre değişir (rapor
            //   takvim günüdür, mazeret çoğu kurumda iş günü).
            new("isGunu", "is_gunu", "mantik", Baslik: "İş günü say", Grup: "İzin"),
            new("gun", "gun", "ondalik", Yazilabilir: false, Baslik: "Gün", Grup: "İzin"),
            new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                Grup: "İzin", SabitKodlar: IzinDurumKodlari),

            // YERİNE BAKAN: izindeyken işi kimin devraldığı. Onay vekâleti
            //   (746) imza yetkisinin devri; bu işin devri - aynı kişi
            //   olmayabilir ve ikisi ayrı sorudur.
            new("yerineId", "yerine_id", "sayi", Baslik: "Yerine Bakan", Grup: "Gerekçe",
                KodTablosu: "public.v_personel_lookup"),
            new("belgeNo", "belge_no", "metin", Baslik: "Rapor / Belge No",
                Grup: "Gerekçe", EnFazlaUzunluk: 60),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Gerekçe",
                EnFazlaUzunluk: 300),
            new("redNeden", "red_neden", "metin", Yazilabilir: false,
                Baslik: "Red Nedeni", Grup: "Gerekçe", EnFazlaUzunluk: 400),
            new("iptalNeden", "iptal_neden", "metin", Yazilabilir: false,
                Baslik: "İptal Nedeni", Grup: "Gerekçe", EnFazlaUzunluk: 400),
            new("talepTarihi", "talep_tarihi", "tarih", Yazilabilir: false,
                Baslik: "Talep Tarihi", Grup: "Gerekçe"),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = 1, ["durum"] = 0, ["is_gunu"] = 0,
            ["talep_tarihi"] = "@simdi",
        });

    /// <summary>resmi_tatil.tur</summary>
    private static readonly Dictionary<string, string> TatilTuruKodlari = new()
    {
        ["1"] = "Millî", ["2"] = "Dinî", ["3"] = "İdarî",
    };

    /// <summary>personel_avans.durum</summary>
    private static readonly Dictionary<string, string> AvansDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylandı",
        ["3"] = "Reddedildi", ["4"] = "Ödendi", ["5"] = "Kapandı", ["8"] = "İptal",
    };

    private static readonly Dictionary<string, string> AvansKesintiDurumKodlari = new()
    {
        ["0"] = "Planlandı", ["1"] = "Kesildi", ["2"] = "Ertelendi", ["3"] = "İptal",
    };

    // ------------------------------------------------------------ avans ----
    // TUTAR VE TAKSİT KARTTAN, KESİNTİ PLANI UÇTAN. Plan ödemeyle birlikte
    //   doğar (ödenmemiş avansın kesintisini takvimlemek, olmayan bir borcu
    //   planlamaktır) ve sekme SALT OKUNUR: satırı elle eklemek "kesildi"
    //   demenin kolay yolu olurdu.
    private static KartTanimi PersonelAvans() => new(
        Ad: "personelAvans",
        YetkiKodu: "ik.avans",
        Tablo: "public.personel_avans",
        // 1257 (755): 907 Hasta Bilgisi'nin, 908 Kasa İşlemi'nin -
        //   753 ikisini de gasp etmişti ve avansın denetim izi hasta
        //   kaydı gibi görünüyordu.
        LogTabloId: 1257,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("avansNo", "avans_no", "metin", Yazilabilir: false, Baslik: "Avans No",
                Grup: "Avans", EnFazlaUzunluk: 30),
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Personel",
                Grup: "Avans", KodTablosu: "public.v_personel_lookup"),
            new("talepTarihi", "talep_tarihi", "tarih", Baslik: "Talep Tarihi",
                Grup: "Avans"),
            new("tutar", "tutar", "para", Zorunlu: true, Baslik: "Tutar", Grup: "Avans"),
            new("taksitSayisi", "taksit_sayisi", "sayi", Baslik: "Taksit Sayısı",
                Grup: "Avans"),
            // DÖNEM 'yyyy-AA': mahsup bir güne değil bir maaş dönemine aittir.
            new("ilkDonem", "ilk_donem", "metin", Baslik: "İlk Kesinti Dönemi",
                Grup: "Avans", EnFazlaUzunluk: 7),
            new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                Grup: "Avans", SabitKodlar: AvansDurumKodlari),
            new("gerekce", "gerekce", "metin", Baslik: "Gerekçe", Grup: "Gerekçe",
                EnFazlaUzunluk: 400),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Gerekçe",
                EnFazlaUzunluk: 300),
            new("redNeden", "red_neden", "metin", Yazilabilir: false,
                Baslik: "Red Nedeni", Grup: "Gerekçe", EnFazlaUzunluk: 400),
            new("iptalNeden", "iptal_neden", "metin", Yazilabilir: false,
                Baslik: "İptal Nedeni", Grup: "Gerekçe", EnFazlaUzunluk: 400),
            // ÖDEME BAĞI SALT OKUNUR: para kasadan çıkar, karttan değil.
            new("odemeTarihi", "odeme_tarihi", "tarih", Yazilabilir: false,
                Baslik: "Ödeme Tarihi", Grup: "Ödeme"),
            new("odemeIslemId", "odeme_islem_id", "sayi", Yazilabilir: false,
                Baslik: "Kasa İşlemi", Grup: "Ödeme"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("kesintiler", "public.personel_avans_kesinti", "avans_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Yazilabilir: false, Baslik: "Sıra"),
                new("donem", "donem", "metin", Yazilabilir: false, Baslik: "Dönem"),
                new("tutar", "tutar", "para", Yazilabilir: false, Baslik: "Tutar"),
                new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                    SabitKodlar: AvansKesintiDurumKodlari),
                new("kesintiTarihi", "kesinti_tarihi", "tarih", Yazilabilir: false,
                    Baslik: "Kesinti Tarihi"),
                new("aciklama", "aciklama", "metin", Yazilabilir: false, Baslik: "Not"),
            }, Sirala: "sira, id", Baslik: "Kesinti Planı",
               SubeKolonu: null, LogTabloId: 1258, SaltOkunur: true),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0, ["taksit_sayisi"] = 1, ["talep_tarihi"] = "@simdi",
        });

    // ------------------------------------------------------ resmî tatil ----
    // DİNÎ BAYRAM ELLE GİRİLİR: hicrî takvim algoritmayla üretilmiyor - bir
    //   gün kayan hesap izin gününü ve bordroyu yanlış hesaplar, üstelik
    //   "yaklaşık doğru" bir takvimi kimse kontrol etmez. Millî tatiller
    //   listeden tek düğmeyle üretilir.
    private static KartTanimi ResmiTatil() => new(
        Ad: "resmiTatil",
        YetkiKodu: "ik.tatil",
        Tablo: "public.resmi_tatil",
        LogTabloId: 906,
        // KURUM GENELİ: şube alanı doldurulursa YEREL tatil olur (kurtuluş
        //   günü), boşsa bütün kurumu bağlar.
        SubeKolonu: null,
        Alanlar: new KartAlani[]
        {
            new("tarih", "tarih", "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Tatil"),
            new("ad", "ad", "metin", Zorunlu: true, Baslik: "Tatil Adı", Grup: "Tatil",
                EnFazlaUzunluk: 80),
            new("tur", "tur", "kod", Baslik: "Tür", Grup: "Tatil",
                SabitKodlar: TatilTuruKodlari),
            // YARIM GÜN: arife 13:00'ten sonra. İzin hesabında 0,5 sayılır -
            //   tam gün saymak çalışanın yarım gününü yer, hiç saymamak
            //   kurumun yarım gününü.
            new("yarimGun", "yarim_gun", "mantik", Baslik: "Yarım gün", Grup: "Tatil"),
            // SAĞLIK KURUMUNDA TATİL "KAPALI" DEMEK DEĞİLDİR: acil, yatan ve
            //   nöbet sürer. Varsayılan "çalışma sürer".
            new("calismaVar", "calisma_var", "mantik", Baslik: "Çalışma sürer",
                Grup: "Tatil"),
            // DOĞRULANDI (751): dinî bayram tohumu takvim hesabıdır, Diyanet
            //   ilanı değil. Kurum ilan çıkınca tarihi kontrol edip işaretler -
            //   bayrak olmasaydı hesaplanan tarihe kesin gözüyle bakılırdı.
            new("dogrulandi", "dogrulandi", "mantik", Baslik: "Doğrulandı",
                Grup: "Tatil"),
            // YEREL TATİL: şube doldurulursa yalnız o şubeyi bağlar
            //   (kurtuluş günü). Boşsa bütün kurum.
            new("subeId", "sube_id", "sayi", Baslik: "Yalnız Bu Şube", Grup: "Tatil",
                KodTablosu: "public.v_sube_lookup"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Tatil"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Tatil",
                EnFazlaUzunluk: 200),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = 2, ["yarim_gun"] = 0, ["calisma_var"] = 1, ["aktif"] = 1,
        });

    // -------------------------------------------------- izin hakedişi ----
    // HAK TABLODA TUTULUR, her açılışta yeniden türetilmez: kurum fazladan
    //   gün verebilir (toplu sözleşme, kıdem ödülü) ve hesaplanan değere
    //   dönmek o kararı silerdi.
    private static KartTanimi PersonelIzinHak() => new(
        Ad: "personelIzinHak",
        YetkiKodu: "ik.izin_hak",
        Tablo: "public.personel_izin_hak",
        LogTabloId: 905,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Personel",
                Grup: "Hakediş", KodTablosu: "public.v_personel_lookup"),
            new("yil", "yil", "sayi", Zorunlu: true, Baslik: "Yıl", Grup: "Hakediş"),
            new("hakGun", "hak_gun", "ondalik", Baslik: "Kanunî Hak (gün)",
                Grup: "Hakediş"),
            new("devirGun", "devir_gun", "ondalik", Baslik: "Devreden (gün)",
                Grup: "Hakediş"),
            new("ekGun", "ek_gun", "ondalik", Baslik: "Ek Gün", Grup: "Hakediş"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Hakediş",
                EnFazlaUzunluk: 300),
        });
}
