namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MUAYENE ve LABORATUVAR ISTEM kartlari (360).
///
/// UCRET BURADA YOK: fiyat ve odeyen kurum BASVURU belgesinde durur (274/289
/// zinciri) - kart yalniz `belgeId` bagini tasir. Iki yerde fiyat tutmak, biri
/// guncellenip oteki unutuldugunda hangisinin dogru oldugu sorusunu dogurur
/// (radyoloji isteminde de ayni kural).
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>Muayene turu (360): ilk / kontrol / konsultasyon.</summary>
    // SKRS muayene turu (409). "Uzaktan" Teletip'in ayni karti kullandigi
    //   haldir - ayri bir muayene tablosu acmak iki yerde ayni kurali
    //   yasatirdi.
    private static readonly Dictionary<string, string> MuayeneTuruKodlari = new()
    {
        ["1"] = "Yüz Yüze", ["2"] = "Uzaktan", ["3"] = "Konsültasyon", ["4"] = "Kontrol"
    };

    /// <summary>Muayene durumu: acik (devam eden) / tamamlandi / iptal.</summary>
    private static readonly Dictionary<string, string> MuayeneDurumKodlari = new()
    {
        ["1"] = "Açık", ["2"] = "Sonuç Bekliyor", ["3"] = "Tamamlandı",
        ["4"] = "Ek Not Eklendi", ["0"] = "İptal"
    };

    /// <summary>Sablon turu (411).</summary>
    private static readonly Dictionary<string, string> SablonTuruKodlari = new()
    {
        ["1"] = "Fizik Muayene", ["2"] = "Anamnez", ["3"] = "Sistem Sorgusu"
    };

    /// <summary>Sablon alan tipi (409): tip ALAN basinadir, sablon basina degil.</summary>
    private static readonly Dictionary<string, string> SablonAlanTipKodlari = new()
    {
        ["1"] = "Metin", ["2"] = "Sayı", ["3"] = "Seçenekli", ["4"] = "Evet / Hayır",
        ["5"] = "Vücut Şeması"
    };

    /// <summary>Makronun gecerli oldugu alan (411); bos = her alan.</summary>
    private static readonly Dictionary<string, string> MakroAlanKodlari = new()
    {
        [""] = "Tüm alanlar", ["sikayet"] = "Şikayet", ["hikaye"] = "Hikaye",
        ["bulguOzet"] = "Muayene Bulguları", ["karar"] = "Değerlendirme / Plan"
    };

    /// <summary>Tani turu (409): muayene basina TEK ana tani (db kisiti).</summary>
    private static readonly Dictionary<string, string> TaniTuruKodlari = new()
    {
        ["1"] = "Ana Tanı", ["2"] = "Ek Tanı", ["3"] = "Ön Tanı", ["4"] = "Sevk Tanısı"
    };

    private static readonly Dictionary<string, string> TaniKesinlikKodlari = new()
    {
        ["1"] = "Kesin", ["2"] = "Ön", ["3"] = "Şüpheli", ["4"] = "Dışlandı"
    };

    private static readonly Dictionary<string, string> TarafKodlari = new()
    {
        ["0"] = "—", ["1"] = "Sağ", ["2"] = "Sol", ["3"] = "Bilateral"
    };

    /// <summary>Vital olcumun kaynagi: elle mi, cihazdan mi, hasta beyani mi.</summary>
    private static readonly Dictionary<string, string> VitalKaynakKodlari = new()
    {
        ["1"] = "Elle", ["2"] = "Cihaz", ["3"] = "Hasta Beyanı"
    };

    /// <summary>Muayeneden cikan istem turu (409).</summary>
    private static readonly Dictionary<string, string> IstemTuruKodlari = new()
    {
        ["1"] = "Laboratuvar", ["2"] = "Görüntüleme", ["3"] = "Konsültasyon",
        ["4"] = "İşlem", ["5"] = "Dış Tetkik"
    };

    private static readonly Dictionary<string, string> IstemSonucKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Kısmi", ["2"] = "Tamam", ["3"] = "İptal"
    };

    /// <summary>Muayene sonu yonlendirme (409): sevk / yatis / acil.</summary>
    private static readonly Dictionary<string, string> YonlendirmeKodlari = new()
    {
        ["0"] = "Yok", ["1"] = "Kurum İçi Sevk", ["2"] = "Kurum Dışı Sevk",
        ["3"] = "Yatış Önerisi", ["4"] = "Acil"
    };

    /// <summary>Lab bolumu (360).</summary>
    private static readonly Dictionary<string, string> LabBolumKodlari = new()
    {
        ["1"] = "Biyokimya", ["2"] = "Mikrobiyoloji", ["3"] = "Genetik",
        ["4"] = "Patoloji",  ["9"] = "Diğer"
    };

    /// <summary>Lab istem durumu: numune ve calisma akisini izler.</summary>
    private static readonly Dictionary<string, string> LabDurumKodlari = new()
    {
        ["1"] = "İstendi", ["2"] = "Numune Alındı", ["3"] = "Çalışılıyor",
        ["4"] = "Sonuçlandı", ["5"] = "Onaylandı", ["9"] = "İptal"
    };

    /// <summary>Test sonucunun degerlendirmesi - sonuc formunda rozet olur.</summary>
    private static readonly Dictionary<string, string> LabIsaretKodlari = new()
    {
        ["0"] = "Normal", ["1"] = "Düşük", ["2"] = "Yüksek", ["3"] = "Panik"
    };

    /// <summary>
    /// MUAYENE KARTI (409, Faz 1) — hekimin tek ekranı.
    ///
    /// Alanların yapısal olması bir tercih değil zorunluluk: e-Nabız 103,
    /// Medula ve rapor üretimi ana tanıyı, vital ölçümü ve bulguyu AYRI AYRI
    /// ister. Serbest metin taslakta hızlıydı ama gönderim anında reddediliyor
    /// ve hata hekime çok geç dönüyordu.
    ///
    /// Gruplar: Kimlik · Anamnez · Muayene · Tanı/Karar.
    /// Detaylar: Vital Bulgular · Tanılar · Bulgular · İstem &amp; Sonuçlar.
    /// </summary>
    private static KartTanimi MuayeneKarti() => new(
        Ad: "muayene",
        YetkiKodu: "muayene",
        Tablo: "public.muayene",
        LogTabloId: 960,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,             // Yüz yüze
            ["durum"] = (short)1,           // Açık
            ["muayeneTarihi"] = "@simdi",
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            // Hasta binlerce kayit: combo degil ARAMA EKRANI (260).
            new("tarafId", "taraf_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Kimlik"),
            // Basvuru BOS birakilabilir: kontrol muayenesi yeni basvuru
            //   acmadan da yazilabilsin (ucretsiz kontrol).
            new("belgeId", "belge_id", "sayi",
                Baslik: "Başvuru (Protokol Id)", Grup: "Kimlik"),
            new("muayeneNo", "muayene_no", "metin", EnFazlaUzunluk: 30,
                Baslik: "Muayene No", Grup: "Kimlik"),
            new("muayeneTarihi", "muayene_tarihi", "tarih", Zorunlu: true,
                Baslik: "Kayıt Tarihi", Grup: "Kimlik"),
            new("tur", "tur", "kod", SabitKodlar: MuayeneTuruKodlari,
                Baslik: "Tür", Grup: "Kimlik"),
            new("bolumId", "bolum_id", "kod", KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm", Grup: "Kimlik"),
            new("personelId", "personel_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Hekim", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: MuayeneDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // BASLANGIC / BITIS = HEKIMIN suresi (USS Muayene Baslangic-Bitis);
            //   muayeneTarihi kaydin acilisidir, ikisi ayni sey degil. Ekranin
            //   dugmeleri yazar (Muayeneye Al / Tamamla), elle girilmez.
            new("baslangic", "baslangic", "tarih", Yazilabilir: false,
                Baslik: "Muayeneye Alındı", Grup: "Kimlik", AltGrup: "Süre"),
            new("bitis", "bitis", "tarih", Yazilabilir: false,
                Baslik: "Bitiş", Grup: "Kimlik", AltGrup: "Süre"),
            new("randevuId", "randevu_id", "sayi", Baslik: "Randevu Id",
                Grup: "Kimlik", AltGrup: "Süre"),
            new("ustMuayeneId", "ust_muayene_id", "sayi",
                Baslik: "İsteyen Muayene (Konsültasyon)", Grup: "Kimlik", AltGrup: "Süre"),

            // --------------------------------------------------- anamnez ----
            new("sikayet", "sikayet", "metin", Baslik: "Şikayet", Grup: "Anamnez"),
            new("hikaye", "hikaye", "metin", Baslik: "Hikaye", Grup: "Anamnez"),
            // Ozgecmis / soygecmis / aliskanlik BURADA SERBEST NOTTUR; yapisal
            //   karsiliklari hastanin tibbi gecmisinde (Faz 1 ortak platform)
            //   yasar - muayene aninda yazilan not oraya islenir.
            new("ozgecmisNotu", "ozgecmis_notu", "metin", Baslik: "Özgeçmiş",
                Grup: "Anamnez", AltGrup: "Geçmiş"),
            new("soygecmisNotu", "soygecmis_notu", "metin", Baslik: "Soygeçmiş",
                Grup: "Anamnez", AltGrup: "Geçmiş"),
            new("aliskanlikNotu", "aliskanlik_notu", "metin", Baslik: "Alışkanlıklar",
                Grup: "Anamnez", AltGrup: "Geçmiş"),

            // --------------------------------------------- fizik muayene ----
            new("sablonId", "sablon_id", "kod", KodTablosu: "public.v_muayene_sablon_lookup",
                Baslik: "Muayene Şablonu", Grup: "Muayene"),
            // Sablondan DERLENEN metin: rapora ve e-Nabiz pakete giden budur.
            //   Bulgular sekmesindeki alanlardan uretilir, hekim duzeltebilir.
            new("bulguOzet", "bulgu_ozet", "metin", Baslik: "Muayene Bulguları",
                Grup: "Muayene"),

            // ---------------------------------------------- tani / karar ----
            new("karar", "karar", "metin", Baslik: "Değerlendirme / Plan",
                Grup: "Tanı / Karar"),
            new("yonlendirme", "yonlendirme", "kod", SabitKodlar: YonlendirmeKodlari,
                Baslik: "Yönlendirme", Grup: "Tanı / Karar", AltGrup: "Sevk"),
            new("sevkTesisKodu", "sevk_tesis_kodu", "metin", EnFazlaUzunluk: 20,
                Baslik: "Sevk Tesis Kodu", Grup: "Tanı / Karar", AltGrup: "Sevk"),
            new("sevkKlinikKod", "sevk_klinik_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "Sevk Klinik Kodu", Grup: "Tanı / Karar", AltGrup: "Sevk"),
            new("sevkNeden", "sevk_neden", "kod", Baslik: "Sevk Nedeni",
                Grup: "Tanı / Karar", AltGrup: "Sevk"),
            new("kontrolOnerisiGun", "kontrol_onerisi_gun", "sayi",
                Baslik: "Kontrol (gün)", Grup: "Tanı / Karar", AltGrup: "Takip"),
            new("kontrolRandevuId", "kontrol_randevu_id", "sayi",
                Baslik: "Kontrol Randevu Id", Grup: "Tanı / Karar", AltGrup: "Takip"),
            new("vakaTuru", "vaka_turu", "kod", Baslik: "Vaka Türü",
                Grup: "Tanı / Karar", AltGrup: "Takip"),

            // -------------------------------------------------- gönderim ----
            new("enabizDurum", "enabiz_durum", "kod", Yazilabilir: false,
                Baslik: "e-Nabız Durumu", Grup: "Tanı / Karar", AltGrup: "Gönderim"),
            new("tamamlayanId", "tamamlayan_id", "sayi", Yazilabilir: false,
                Baslik: "Tamamlayan", Grup: "Tanı / Karar", AltGrup: "Gönderim"),
            new("tamamlanma", "tamamlanma", "tarih", Yazilabilir: false,
                Baslik: "Tamamlanma", Grup: "Tanı / Karar", AltGrup: "Gönderim")
        },
        Detaylar: new DetayTanimi[]
        {
            // VITAL: bir muayenede BIRDEN COK olcum olur (hemsire girisi,
            //   cihazdan gelen, hekimin tekrari). USS son olcumu ister; tek
            //   satirda tutmak olcum tarihcesini yok ederdi.
            new("vitaller", "public.muayene_vital", "muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("zaman", "zaman", "tarih", Baslik: "Zaman"),
                new("kaynak", "kaynak", "kod", SabitKodlar: VitalKaynakKodlari,
                    Baslik: "Kaynak"),
                new("sistolik", "sistolik", "sayi", Baslik: "Sistolik"),
                new("diyastolik", "diyastolik", "sayi", Baslik: "Diyastolik"),
                new("nabiz", "nabiz", "sayi", Baslik: "Nabız"),
                new("solunum", "solunum", "sayi", Baslik: "Solunum"),
                new("ates", "ates", "sayi", Baslik: "Ateş"),
                new("spo2", "spo2", "sayi", Baslik: "SpO2"),
                new("boyCm", "boy_cm", "sayi", Baslik: "Boy (cm)"),
                new("kiloKg", "kilo_kg", "sayi", Baslik: "Kilo (kg)"),
                // BKI SAKLANIR: boy/kilo sonradan duzeltilse bile o anki
                //   olcumun degeri degismemeli - kayit tarihcedir.
                new("bki", "bki", "sayi", Baslik: "BKİ"),
                new("belCevresiCm", "bel_cevresi_cm", "sayi", Baslik: "Bel (cm)"),
                new("agriVas", "agri_vas", "sayi", Baslik: "Ağrı (VAS)"),
                new("glukozParmak", "glukoz_parmak", "sayi", Baslik: "Parmak Glukoz"),
                new("gks", "gks", "sayi", Baslik: "GKS"),
                new("olcenId", "olcen_id", "sayi", Baslik: "Ölçen"),
            }, SubeKolonu: null, Sirala: "zaman desc, id desc",
               Baslik: "Vital Bulgular", LogTabloId: 962),

            // TANI: ana / ek / on ayrimi ve kronik isareti burada. Muayene
            //   basina TEK ana tani db kisitiyla korunur (ux_tani_ana) - iki
            //   ana tani e-Nabiz ve Medula gonderiminde reddedilir.
            new("tanilar", "public.tani", "muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("icdKod", "icd_kod", "kod", Zorunlu: true,
                    KodTablosu: "public.v_icd_lookup", AramaKaynagi: "icd",
                    Baslik: "ICD-10"),
                new("tur", "tur", "kod", SabitKodlar: TaniTuruKodlari, Baslik: "Tür"),
                new("kesinlik", "kesinlik", "kod", SabitKodlar: TaniKesinlikKodlari,
                    Baslik: "Kesinlik"),
                new("taraf", "taraf", "kod", SabitKodlar: TarafKodlari, Baslik: "Taraf"),
                // KRONIK isareti hastanin tibbi ozetine duser: "bu hastanin
                //   kronik tanilari" sorusu tek yerde cevaplanabilsin.
                new("kronik", "kronik", "mantik", Baslik: "Kronik"),
                new("baslangicTarihi", "baslangic_tarihi", "tarih", Baslik: "Başlangıç"),
                new("notMetni", "not_metni", "metin", EnFazlaUzunluk: 200, Baslik: "Not"),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
            }, SubeKolonu: null, Sirala: "tur asc, sira asc, id asc",
               Baslik: "Tanılar", LogTabloId: 963),

            // BULGULAR: sablon alanlarinin degerleri. Normal isareti AYRI
            //   tutulur - rapora hazir cumle ondan uretilir, hekim her normal
            //   bulgu icin ayni metni yazmasin.
            new("bulgular", "public.muayene_bulgu", "muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sablonAlanId", "sablon_alan_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_muayene_sablon_alan_lookup", Baslik: "Alan"),
                new("normal", "normal", "mantik", Baslik: "Normal"),
                new("degerMetin", "deger_metin", "metin", Baslik: "Bulgu"),
                new("degerSayi", "deger_sayi", "sayi", Baslik: "Değer"),
                new("taraf", "taraf", "kod", SabitKodlar: TarafKodlari, Baslik: "Taraf"),
            }, SubeKolonu: null, Sirala: "id asc",
               Baslik: "Bulgular", LogTabloId: 964),

            // ISTEMLER: asil kayit modul tablosunda (lab_istem, radyoloji_istem,
            //   belge_satir); burasi bag ve durum tablosu - "İstem & Sonuçlar"
            //   sekmesinin ve "sonuc geldi" bildiriminin tek adresi.
            new("istemler", "public.muayene_istem", "muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tur", "tur", "kod", SabitKodlar: IstemTuruKodlari, Baslik: "Tür"),
                new("hedefTablo", "hedef_tablo", "metin", EnFazlaUzunluk: 40,
                    Baslik: "Hedef Tablo", Yazilabilir: false),
                new("hedefId", "hedef_id", "sayi", Baslik: "Hedef Id", Yazilabilir: false),
                new("aciliyet", "aciliyet", "kod", Baslik: "Aciliyet"),
                new("istemZamani", "istem_zamani", "tarih", Baslik: "İstem"),
                new("sonucDurum", "sonuc_durum", "kod", SabitKodlar: IstemSonucKodlari,
                    Baslik: "Sonuç"),
                new("sonucZamani", "sonuc_zamani", "tarih", Baslik: "Sonuç Zamanı",
                    Yazilabilir: false),
                new("hekimGordu", "hekim_gordu", "tarih", Baslik: "Görüldü"),
            }, SubeKolonu: null, Sirala: "istem_zamani desc, id desc",
               Baslik: "İstem & Sonuçlar", LogTabloId: 965)
        });

    /// <summary>
    /// MUAYENE ŞABLONU KARTI (411) — alanlar detayda.
    ///
    /// Alan tipleri (metin / sayı / seçenekli / mantık / vücut şeması) kartın
    /// kendisinde değil ALAN SATIRINDA: bir şablonda farklı tipte alanlar
    /// birlikte bulunur ve tipi şablona bağlamak her sisteme ayrı şablon
    /// açtırırdı.
    /// </summary>
    private static KartTanimi MuayeneSablonKarti() => new(
        Ad: "muayene-sablon",
        YetkiKodu: "muayene",
        Tablo: "public.muayene_sablon",
        LogTabloId: 966,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1,
            ["durum"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 30,
                Baslik: "Kod", Grup: "Tanım"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Şablon Adı", Grup: "Tanım"),
            new("tur", "tur", "kod", SabitKodlar: SablonTuruKodlari,
                Baslik: "Tür", Grup: "Tanım"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Tanım"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Tanım"),
            new("durum", "durum", "mantik", Baslik: "Aktif", Grup: "Tanım"),
            // KAPSAM: hekim dolu = kisisel, bolum dolu = brans, ikisi bos =
            //   kurum. Ucu de tek tabloda - ayni sablon motoru iki kez
            //   yazilmasin.
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Hekim (kişisel)", Grup: "Kapsam"),
            new("bolumId", "bolum_id", "kod", KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm (branş)", Grup: "Kapsam")
        },
        Detaylar: new DetayTanimi[]
        {
            new("alanlar", "public.muayene_sablon_alan", "sablon_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("grup", "grup", "metin", EnFazlaUzunluk: 60, Baslik: "Sistem / Grup"),
                new("kod", "kod", "metin", Zorunlu: true, EnFazlaUzunluk: 30, Baslik: "Kod"),
                new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Alan"),
                new("tip", "tip", "kod", SabitKodlar: SablonAlanTipKodlari, Baslik: "Tip"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                // "Normal" isaretlenince rapora yazilacak hazir cumle: hekim
                //   her normal bulgu icin ayni metni yazmasin.
                new("normalMetni", "normal_metni", "metin", EnFazlaUzunluk: 200,
                    Baslik: "Normal Metni"),
                new("tarafSorulur", "taraf_sorulur", "mantik", Baslik: "Taraf Sorulur"),
                new("zorunlu", "zorunlu", "mantik", Baslik: "Zorunlu"),
            }, SubeKolonu: null, Sirala: "sira asc, id asc",
               Baslik: "Alanlar", LogTabloId: 967)
        });

    /// <summary>METİN MAKROSU KARTI (411) — kısayoldan hazır metin.</summary>
    private static KartTanimi MetinMakroKarti() => new(
        Ad: "metin-makro",
        YetkiKodu: "muayene",
        Tablo: "public.metin_makro",
        LogTabloId: 968,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("kisayol", "kisayol", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                Baslik: "Kısayol", Grup: "Tanım"),
            // Alan bos ise HER alanda gecerli: ayni kisayol karar alaninda
            //   baska, hikayede baska metin uretebilsin.
            new("alan", "alan", "kod", SabitKodlar: MakroAlanKodlari,
                Baslik: "Alan", Grup: "Tanım"),
            new("metin", "metin", "metin", Zorunlu: true, Baslik: "Metin", Grup: "Tanım"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Tanım"),
            new("durum", "durum", "mantik", Baslik: "Aktif", Grup: "Tanım"),
            new("kullanim", "kullanim", "sayi", Yazilabilir: false,
                Baslik: "Kullanım", Grup: "Tanım"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Hekim (kişisel)", Grup: "Kapsam"),
            new("bolumId", "bolum_id", "kod", KodTablosu: "public.v_departman_lookup",
                Baslik: "Bölüm (branş)", Grup: "Kapsam")
        });

    private static KartTanimi LabIstemKarti() => new(
        Ad: "lab-istem",
        YetkiKodu: "lab",
        Tablo: "public.lab_istem",
        LogTabloId: 961,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["bolum"] = (short)1,           // Biyokimya
            ["durum"] = (short)1,           // İstendi
            ["istemTarihi"] = "@simdi",
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            new("tarafId", "taraf_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "İstem"),
            new("belgeId", "belge_id", "sayi",
                Baslik: "Başvuru (Protokol Id)", Grup: "İstem"),
            new("istemNo", "istem_no", "metin", EnFazlaUzunluk: 30,
                Baslik: "İstem No", Grup: "İstem"),
            new("istemTarihi", "istem_tarihi", "tarih", Zorunlu: true,
                Baslik: "İstem Tarihi", Grup: "İstem"),
            new("bolum", "bolum", "kod", SabitKodlar: LabBolumKodlari,
                Baslik: "Bölüm", Grup: "İstem"),
            new("personelId", "personel_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "İsteyen Hekim", Grup: "İstem"),
            new("durum", "durum", "kod", SabitKodlar: LabDurumKodlari,
                Baslik: "Durum", Grup: "İstem"),

            // Numune ve sonuc zamanlari AYRI: "ne zaman alindi / ne zaman cikti"
            //   laboratuvarin temel performans sorusudur.
            new("numuneTarihi", "numune_tarihi", "tarih",
                Baslik: "Numune Alma", Grup: "Süreç"),
            new("sonucTarihi", "sonuc_tarihi", "tarih",
                Baslik: "Sonuç", Grup: "Süreç"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Süreç")
        },
        Detaylar: new DetayTanimi[]
        {
            // TESTLER: istemin satirlari. Sonuc girisi de burada - ayri bir
            //   "sonuc girisi" ekrani, teknisyeni ayni kaydin iki yuzu arasinda
            //   gezdirirdi.
            new("testler", "public.lab_istem_test", "istem_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "kod", KodTablosu: "public.v_hizmet_lookup",
                    AramaKaynagi: "hizmet", Baslik: "Test (Hizmet)"),
                new("kod", "kod", "metin", EnFazlaUzunluk: 30, Baslik: "Kod"),
                new("ad", "ad", "metin", EnFazlaUzunluk: 200, Baslik: "Test Adı"),
                new("sonuc", "sonuc", "metin", EnFazlaUzunluk: 100, Baslik: "Sonuç"),
                new("birim", "birim", "metin", EnFazlaUzunluk: 20, Baslik: "Birim"),
                new("referans", "referans", "metin", EnFazlaUzunluk: 60,
                    Baslik: "Referans Aralığı"),
                new("isaret", "isaret", "kod", SabitKodlar: LabIsaretKodlari,
                    Baslik: "Değerlendirme"),
                new("cihaz", "cihaz", "metin", EnFazlaUzunluk: 60, Baslik: "Cihaz"),
                new("sonucTarihi", "sonuc_tarihi", "tarih", Baslik: "Sonuç Zamanı"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama")
            }, SubeKolonu: null, Sirala: "id", Baslik: "Testler", LogTabloId: 962)
        });
}
