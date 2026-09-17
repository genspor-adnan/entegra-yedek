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
