namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TELERADYOLOJİ İSTEK KARTI (798) — çalışma listesinin satırını açar.
///
/// Kullanıcı: *"teleradyoloji istek kartını da yap"*. 797 faz 1'de kart yoktu
/// ve listede çift tık hiçbir şey açmıyordu.
///
/// <b>Kart işin ÇEVRESİNİ düzenler, raporu değil.</b> Okuma ve rapor yazma
/// mevcut radyoloji raporlama ekranıyla yapılır (`radyoloji_istem` /
/// `radyoloji_rapor`); burada hangi kurumdan geldiği, hangi tetkik, görüntü
/// durumu, kime atandığı ve teslim/ücret bilgisi durur.
///
/// <b>Hesaplananlar salt okunur:</b> istek numarası, SLA dakikası ve bitişi,
/// aşım işareti, onay/teslim zamanları - hepsini `tg_telerad_istek` yazıyor.
/// Ekrandan yazılabilir yapmak, tetikle ekranı aynı sayıyı iki ayrı yerden
/// hesaplar hale getirirdi.
/// </summary>
public static partial class KartKatalogu
{
    private static readonly Dictionary<string, string> TeleradKartOncelik = new()
        { ["1"] = "Rutin", ["2"] = "Öncelikli", ["3"] = "ACİL" };

    private static readonly Dictionary<string, string> TeleradKartDurum = new()
    {
        ["0"] = "İptal",  ["1"] = "Görüntü bekleniyor", ["2"] = "Sırada",
        ["3"] = "Atandı", ["4"] = "Okunuyor",           ["5"] = "Taslak",
        ["6"] = "Onaylı", ["7"] = "Teslim edildi",      ["8"] = "Ek görüntü istendi",
    };

    private static readonly Dictionary<string, string> TeleradKartGoruntu = new()
        { ["0"] = "Bekleniyor", ["1"] = "Tamam", ["2"] = "Eksik seri", ["3"] = "Hatalı" };

    private static readonly Dictionary<string, string> TeleradKartModalite = new()
    {
        ["1"] = "BT", ["2"] = "MR", ["3"] = "USG", ["4"] = "Röntgen",
        ["5"] = "Mamografi", ["6"] = "DEXA", ["7"] = "Anjiyo", ["8"] = "Skopi",
    };

    private static readonly Dictionary<string, string> TeleradKartTeslim = new()
        { ["0"] = "Bekliyor", ["1"] = "Teslim edildi", ["2"] = "Hata" };

    // YÖN İSTEK BAZINDA İKİ DEĞER: kurumun kendisi "iki yön" olabilir (797),
    //   ama tek bir istek ya bize gelir ya dışarı gider.
    private static readonly Dictionary<string, string> TeleradKartYon = new()
        { ["1"] = "Gelen (biz raporlarız)", ["2"] = "Giden (dışarı gönderiyoruz)" };

    private static KartTanimi TeleradIstek() => new(
        Ad: "telerad-istek",
        // Liste ile AYNI yetki: kart serbest kalırsa liste süzmesi anlamsızlaşır.
        YetkiKodu: "teleradyoloji",
        Tablo: "public.telerad_istek",
        LogTabloId: 941,                 // radyoloji istemi (940) ile komşu
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["oncelik"] = (short)1,      // Rutin
            ["durum"] = (short)1,        // Görüntü bekleniyor
            ["yon"] = (short)1,          // Gelen
        },
        // PORTAL (794/795): gönderen kurum kendi isteğini açabilir, atanan
        //   radyolog kendi işini; başkasının isteği "bulunamadı" döner.
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: "atanan_radyolog_id = {kullanici}",
            disKurum:  "kurum_id in (select k.id from public.telerad_kurum k "
                     + "              where k.taraf_id = {kullanici})",
            hasta:     "false"),
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            // İSTEK NUMARASINI TETİK VERİR (797): elle yazılabilir olsaydı iki
            //   istek aynı numarayı taşıyabilirdi.
            new("istekNo", "istek_no", "metin", Yazilabilir: false,
                Baslik: "İstek No", Grup: "Kimlik"),
            // KURUM LİSTESİ CARİ LİSTESİ DEĞİL (798): her cari teleradyoloji
            //   kurumu değildir; olmayan bir kurumu seçmek sessizce kırık
            //   kayıt üretirdi.
            new("kurumId", "kurum_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_telerad_kurum_lookup",
                Baslik: "Gönderen Kurum", Grup: "Kimlik"),
            // YÖN KARTTA GÖRÜNMELİ: giden iş bizim faturamız değil ONLARIN
            //   faturası, SLA'yı da biz tutmuyoruz - listede iki iş aynı
            //   satır gibi durduğu için kartta ayırt edilebilmeli.
            new("yon", "yon", "kod", SabitKodlar: TeleradKartYon,
                Baslik: "Yön", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: TeleradKartDurum,
                Baslik: "Durum", Grup: "Kimlik"),
            new("oncelik", "oncelik", "kod", SabitKodlar: TeleradKartOncelik,
                Baslik: "Öncelik", Grup: "Kimlik"),

            // ----------------------------------------------------- hasta ----
            // DIŞ HASTA: kurumun hastası bizde minimal kayıt olarak açılabilir
            //   ama zorunlu değil - kimlik ve erişim numarası çoğu işte yeter.
            new("disHastaKimlik", "dis_hasta_kimlik", "metin", EnFazlaUzunluk: 11,
                Baslik: "Kimlik No", Grup: "Hasta"),
            new("hastaId", "hasta_id", "kod", KodTablosu: "public.v_hasta_lookup",
                AramaKaynagi: "hasta", Baslik: "Hasta Kaydı", Grup: "Hasta"),
            new("disErisimNo", "dis_erisim_no", "metin", EnFazlaUzunluk: 40,
                Baslik: "Erişim No", Grup: "Hasta"),
            // PID-3 (816): kurumun KENDİ dosya numarası. TCKN'si olmayan
            //   hastada (yabancı, yenidoğan) görüntüyle eşleşmenin tek yolu.
            new("disHastaNo", "dis_hasta_no", "metin", EnFazlaUzunluk: 30,
                Baslik: "Kurum Dosya No", Grup: "Hasta"),
            new("isteyenHekim", "isteyen_hekim", "metin", EnFazlaUzunluk: 120,
                Baslik: "İsteyen Hekim", Grup: "Hasta"),
            // TCKN AYRI ALAN (810): Bakanlik ORC-12/OBR-16 hekimin TCKN'sini
            //   istiyor ve eksik/hataliysa mesaji reddediyor. Adin icine
            //   yazilirsa iki bilgi de kullanilamaz hale gelir.
            new("isteyenHekimTckn", "isteyen_hekim_tckn", "metin", EnFazlaUzunluk: 11,
                Baslik: "İsteyen Hekim TCKN", Grup: "Hasta"),

            // ----------------------------------------------------- tetkik ---
            new("modalite", "modalite", "kod", SabitKodlar: TeleradKartModalite,
                Baslik: "Modalite", Grup: "Tetkik"),
            new("tetkikHizmetId", "tetkik_hizmet_id", "kod",
                KodTablosu: "public.v_rad_tetkik_lookup",
                Baslik: "Tetkik", Grup: "Tetkik"),
            // KLİNİK BİLGİ RAPORUN YARISIDIR: radyolog "neden çekildi"
            //   bilmeden okursa bulguyu yorumlayamaz.
            new("klinikBilgi", "klinik_bilgi", "metin", EnFazlaUzunluk: 2000,
                Baslik: "Klinik Bilgi", Grup: "Tetkik"),
            new("onam", "onam", "mantik", Baslik: "Paylaşım Onamı", Grup: "Tetkik"),

            // ---------------------------------------------------- görüntü ---
            new("cekimZamani", "cekim_zamani", "zaman", Baslik: "Çekim", Grup: "Görüntü"),
            // SLA GÖRÜNTÜNÜN GELDİĞİ AN BAŞLAR (797): bu alan yazılınca tetik
            //   `sla_bitis`i hesaplar - o yüzden elle de girilebilir.
            new("gelisZamani", "gelis_zamani", "zaman",
                Baslik: "Geliş", Grup: "Görüntü"),
            new("goruntuDurum", "goruntu_durum", "kod", SabitKodlar: TeleradKartGoruntu,
                Baslik: "Durum", Grup: "Görüntü"),
            new("goruntuSayisi", "goruntu_sayisi", "sayi", Baslik: "Görüntü",
                Grup: "Görüntü"),
            new("seriSayisi", "seri_sayisi", "sayi", Baslik: "Seri", Grup: "Görüntü"),
            new("studyUid", "study_uid", "metin", EnFazlaUzunluk: 64,
                Baslik: "Study UID", Grup: "Görüntü"),

            // ------------------------------------------------ atama / SLA ---
            new("atananRadyologId", "atanan_radyolog_id", "kod",
                KodTablosu: "public.v_rad_hekim_lookup",
                Baslik: "Radyolog", Grup: "Atama & SLA"),
            // HESAPLANANLAR SALT OKUNUR: hepsini tetik yazar.
            new("slaDk", "sla_dk", "sayi", Yazilabilir: false,
                Baslik: "SLA (dk)", Grup: "Atama & SLA"),
            new("slaBitis", "sla_bitis", "zaman", Yazilabilir: false,
                Baslik: "SLA Bitişi", Grup: "Atama & SLA"),
            new("slaAsildi", "sla_asildi", "mantik", Yazilabilir: false,
                Baslik: "SLA Aşıldı", Grup: "Atama & SLA"),
            new("okumaBas", "okuma_bas", "zaman", Yazilabilir: false,
                Baslik: "Okuma", Grup: "Atama & SLA"),
            new("onayZamani", "onay_zamani", "zaman", Yazilabilir: false,
                Baslik: "Onay", Grup: "Atama & SLA"),

            // -------------------------------------------- teslim / ücret ----
            new("teslimDurum", "teslim_durum", "kod", Yazilabilir: false,
                SabitKodlar: TeleradKartTeslim, Baslik: "Teslim Durum", Grup: "Teslim & Ücret"),
            new("teslimZamani", "teslim_zamani", "zaman", Yazilabilir: false,
                Baslik: "Teslim", Grup: "Teslim & Ücret"),
            new("teslimHata", "teslim_hata", "metin", Yazilabilir: false,
                EnFazlaUzunluk: 400, Baslik: "Teslim Hata", Grup: "Teslim & Ücret"),
            // ÜCRET İSTEK ANINDA KOPYALANIR (tarife × öncelik): sözleşme
            //   sonradan değişse de geçmiş işin fiyatı değişmesin.
            new("ucret", "ucret", "para", Baslik: "Ücret", Grup: "Teslim & Ücret"),
            new("sozlesmeId", "sozlesme_id", "sayi", Yazilabilir: false,
                Baslik: "Sözleşme Id", Grup: "Teslim & Ücret"),

            // ------------------------------------------------------ bağlar --
            new("radyolojiIstemId", "radyoloji_istem_id", "sayi", Yazilabilir: false,
                Baslik: "İç İstem Id", Grup: "Bağlar"),
            new("raporId", "rapor_id", "sayi", Yazilabilir: false,
                Baslik: "Rapor Id", Grup: "Bağlar"),
            new("faturaBelgeId", "fatura_belge_id", "sayi", Yazilabilir: false,
                Baslik: "Fatura Id", Grup: "Bağlar"),
            // EKLEYEN/EKLEME TARİHİ KARTTA YOK: hiçbir kartta yok - denetim
            //   bilgisi log ekranının işi. Gruba yazılmadıkları için tek
            //   başlarına boş bir "Genel" sekmesi açıyorlardı.
        },
        Detaylar: new[]
        {
            // ATAMA GEÇMİŞİ SALT OKUNUR: satırları tetik yazıyor
            //   (`tg_telerad_atama_izi`). Elle satır eklemek "kim atadı"
            //   sorusunun cevabını uydurulabilir kılardı.
            new DetayTanimi("atamalar", "public.telerad_atama", "istek_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("radyologId", "radyolog_id", "kod", Yazilabilir: false,
                    KodTablosu: "public.v_rad_hekim_lookup", Baslik: "Radyolog"),
                new("atamaZamani", "atama_zamani", "zaman", Yazilabilir: false,
                    Baslik: "Atama"),
                new("neden", "neden", "kod", Yazilabilir: false,
                    SabitKodlar: new Dictionary<string, string>
                    {
                        ["1"] = "Otomatik (kural)", ["2"] = "Elle",
                        ["3"] = "Yeniden atama",    ["4"] = "Nöbet devri",
                    }, Baslik: "Neden"),
                new("birakmaZamani", "birakma_zamani", "zaman", Yazilabilir: false,
                    Baslik: "Bırakma"),
            }, SubeKolonu: null, Baslik: "Atama Geçmişi", SaltOkunur: true),
        });

    // ================================================================= 800 ==
    // KURUM VE SÖZLEŞME KARTLARI. Kullanıcı: *"kurum ve sözleşme kartlarını da
    // yap"*. 797'de iki liste ekranı vardı ama kartı yoktu: iş ilişkisi
    // ekrandan hiç kurulamıyordu, kurum ve sözleşme yalnız göç/betikle
    // açılabiliyordu.
    //
    // İSTEK KARTI İŞİN KENDİSİ, BU İKİSİ ŞARTLARI: kurum "kiminle ve hangi
    // kanalla", sözleşme "hangi dönem, hangi ücret, ne kadar sürede".

    private static readonly Dictionary<string, string> TeleradKartKurumYon = new()
    {
        ["1"] = "Gelen (onlar gönderir, biz raporlarız)",
        ["2"] = "Giden (biz gönderiyoruz)",
        ["3"] = "İki yön",
    };

    private static readonly Dictionary<string, string> TeleradKartKanal = new()
        { ["0"] = "Portal", ["1"] = "HL7 ORU (MLLP)", ["2"] = "REST", ["3"] = "FHIR" };

    // MSH-18 (812): Bakanliga ONCEDEN BILDIRILEN encoding ile ayni olmak
    //   zorunda - yanlis secim Turkce karakterleri bozar, mesaj kabul edilse
    //   bile rapor okunmaz hale gelir.
    private static readonly Dictionary<string, string> TeleradKartEncoding = new()
        { ["1"] = "UTF8", ["2"] = "Windows1254" };

    private static readonly Dictionary<string, string> TeleradKartUcretModeli = new()
        { ["1"] = "Tetkik başı", ["2"] = "Aylık sabit + aşım", ["3"] = "Vaka başı" };

    private static readonly Dictionary<string, string> TeleradKartSozlesmeDurum = new()
        { ["0"] = "Taslak", ["1"] = "Aktif", ["2"] = "Bitti" };

    private static readonly Dictionary<string, string> TeleradKartPeriyot = new()
        { ["1"] = "Aylık", ["2"] = "On beş günlük" };

    private static KartTanimi TeleradKurum() => new(
        Ad: "telerad-kurum",
        YetkiKodu: "teleradyoloji.kurum",
        Tablo: "public.telerad_kurum",
        LogTabloId: 1321,
        SubeKolonu: "sube_id",
        // YENİ KAYIT CARİ SEÇİMİYLE BAŞLAR: teleradyoloji kurumu ayrı bir
        //   müşteri değil, CARİNİN bir özelliğidir (797) - fatura, tahsilat ve
        //   bakiye zaten orada. Önce hangi cari sorulur.
        AcilistaTarafSecimi: "tarafId",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            // ANAHTARLAR ALAN ADI (API adi), kolon adi DEGIL: varsayilanlar
            //   `degerler` sozlugune alan adiyla yaziliyor (KartDeposu.EkleAsync).
            ["yon"] = (short)1,               // gelen
            ["aktif"] = (short)1,
            ["varsayilanOncelik"] = (short)1,
            ["mshEncoding"] = (short)1,      // UTF8
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            new("tarafId", "taraf_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_cari_lookup", AramaKaynagi: "cari",
                Baslik: "Cari", Grup: "Kimlik"),
            new("yon", "yon", "kod", SabitKodlar: TeleradKartKurumYon,
                Baslik: "Yön", Grup: "Kimlik"),
            new("tesisKodu", "tesis_kodu", "metin", EnFazlaUzunluk: 10,
                Baslik: "Tesis Kodu", Grup: "Kimlik"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            // --------------------------------------------------- görüntü ----
            // DICAM AE ADI BENZERSİZ (797, `ux_telerad_kurum_ae`): görüntü
            //   hangi kurumdan geldiğini bu adla söyler; iki kurum aynı adı
            //   taşırsa çalışma yanlış kuruma yazılır.
            new("dicomAeTitle", "dicom_ae_title", "metin", EnFazlaUzunluk: 16,
                Baslik: "DICOM AE", Grup: "Görüntü Bağlantısı"),
            new("dicomHost", "dicom_host", "metin", EnFazlaUzunluk: 120,
                Baslik: "DICOM Sunucu", Grup: "Görüntü Bağlantısı"),
            new("dicomPort", "dicom_port", "sayi",
                Baslik: "DICOM Port", Grup: "Görüntü Bağlantısı"),

            // ---------------------------------------------------- teslim ----
            // KANAL "RAPOR NASIL GERİ GİDİYOR": portal = kurum kendi ekranından
            //   alır (faz 1'de geçerli olan), diğerleri otomatik gönderim
            //   (faz 2 - `dokuman/12_KALAN_ISLER.md`).
            new("hl7Tur", "hl7_tur", "kod", SabitKodlar: TeleradKartKanal,
                Baslik: "Teslim Kanalı", Grup: "Teslim"),
            new("hl7Adres", "hl7_adres", "metin", EnFazlaUzunluk: 120,
                Baslik: "Teslim Adresi", Grup: "Teslim"),
            new("hl7AliciUygulama", "hl7_alici_uygulama", "metin", EnFazlaUzunluk: 30,
                Baslik: "Alıcı Uygulama (MSH-5)", Grup: "Teslim"),
            new("hl7AliciTesis", "hl7_alici_tesis", "metin", EnFazlaUzunluk: 30,
                Baslik: "Alıcı Tesis (MSH-6)", Grup: "Teslim"),

            // ---------------------------------------------------- bakanlık ----
            // BAKANLIK HEDEFI AYRI (812): kurum-kuruma teleradyoloji bu alanlar
            //   olmadan da calisir. Acikken gonderim oncesi kontrol devreye
            //   girer (fn_telerad_bakanlik_eksik).
            new("bakanlikGonderim", "bakanlik_gonderim", "mantik",
                Baslik: "Bakanlığa Bildir", Grup: "Bakanlık"),
            new("skrsKodu", "skrs_kodu", "metin", EnFazlaUzunluk: 10,
                Baslik: "SKRS Kodu (ORC-21)", Grup: "Bakanlık"),
            new("mshUygulama", "msh_uygulama", "metin", EnFazlaUzunluk: 30,
                Baslik: "Firma Kodu (MSH-3)", Grup: "Bakanlık"),
            new("mshTesis", "msh_tesis", "metin", EnFazlaUzunluk: 30,
                Baslik: "Gönderen Tesis (MSH-4)", Grup: "Bakanlık"),
            new("mshEncoding", "msh_encoding", "kod", SabitKodlar: TeleradKartEncoding,
                Baslik: "Encoding (MSH-18)", Grup: "Bakanlık"),
            // WADO ADRESI GORUNTU KAPISI (812/kılavuz §4.2): Bakanlik da
            //   goruntuyu merkeze tasimiyor - kurumun WADO servisinden cekiyor.
            new("wadoAdres", "wado_adres", "metin", EnFazlaUzunluk: 200,
                Baslik: "WADO Adresi", Grup: "Bakanlık"),

            // ------------------------------------------------- raporlama ----
            new("raporSablonId", "rapor_sablon_id", "kod",
                KodTablosu: "public.v_rad_sablon_lookup",
                Baslik: "Rapor Şablonu", Grup: "Raporlama"),
            new("varsayilanOncelik", "varsayilan_oncelik", "kod",
                SabitKodlar: TeleradKartOncelik,
                Baslik: "Vars. Öncelik", Grup: "Raporlama"),
            // GECE NÖBETİ: kurumun işi gece de karşılanıyor mu - otomatik
            //   dağıtım ve nöbet çizelgesi (faz 2) buna bakacak.
            new("geceNobet", "gece_nobet", "mantik",
                Baslik: "Gece Nöbeti", Grup: "Raporlama"),
            // ONAM: kurumun hastasının görüntüsü bize geliyor - paylaşım onamı
            //   zorunlu tutulabilsin (KVKK).
            new("onamZorunlu", "onam_zorunlu", "mantik",
                Baslik: "Onam Zorunlu", Grup: "Raporlama"),
        },
        Detaylar: new[]
        {
            // SÖZLEŞMELER BURADA SALT OKUNUR: yazma yeri sözleşme kartıdır.
            //   İki yerden yazılabilseydi aynı dönem iki farklı SLA ile
            //   kaydedilebilirdi. Burada durması "kurum var ama sözleşmesi
            //   yok" eksikliğini kurumun kendi kartında görünür kılıyor.
            new DetayTanimi("sozlesmeler", "public.telerad_sozlesme", "kurum_id",
                new KartAlani[]
                {
                    new("id", "id", "sayi", Yazilabilir: false),
                    new("baslangic", "baslangic", "tarih", Yazilabilir: false,
                        Baslik: "Başlangıç"),
                    new("bitis", "bitis", "tarih", Yazilabilir: false, Baslik: "Bitiş"),
                    new("ucretModeli", "ucret_modeli", "kod", Yazilabilir: false,
                        SabitKodlar: TeleradKartUcretModeli, Baslik: "Ücret Modeli"),
                    new("slaRutinDk", "sla_rutin_dk", "sayi", Yazilabilir: false,
                        Baslik: "SLA Rutin (dk)"),
                    new("durum", "durum", "kod", Yazilabilir: false,
                        SabitKodlar: TeleradKartSozlesmeDurum, Baslik: "Durum"),
                }, SubeKolonu: null, Sirala: "baslangic desc",
                   Baslik: "Sözleşmeler", SaltOkunur: true),
        });

    private static KartTanimi TeleradSozlesme() => new(
        Ad: "telerad-sozlesme",
        YetkiKodu: "teleradyoloji.sozlesme",
        Tablo: "public.telerad_sozlesme",
        LogTabloId: 1322,
        // ŞUBE KOLONU YOK: sözleşme kurumun sözleşmesidir, şubenin değil -
        //   tabloda `sube_id` de yok (797). Şube süzmesi kurum üzerinden gelir.
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["ucretModeli"] = (short)1,      // tetkik başı
            ["durum"] = (short)0,            // taslak
            ["faturaPeriyodu"] = (short)1,   // aylık
            // SLA VARSAYILANLARI tablodakiyle aynı (797): boş bir sözleşme
            //   "0 dakika" sözü vermiş olmasın - 0 SLA'yı kapatır.
            ["slaAcilDk"] = 30,
            ["slaOncelikliDk"] = 240,
            ["slaRutinDk"] = 1440,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ---------------------------------------------------- kimlik ----
            new("kurumId", "kurum_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_telerad_kurum_lookup",
                Baslik: "Kurum", Grup: "Kimlik"),
            new("baslangic", "baslangic", "tarih", Zorunlu: true,
                Baslik: "Başlangıç", Grup: "Kimlik"),
            // BİTİŞ BOŞ = SÜRESİZ. Boş bırakmak geçerli: çoğu sözleşme
            //   fesih olana kadar işler (`ck_telerad_sozlesme_tarih` yalnız
            //   bitişin başlangıçtan önce olmasını engeller).
            new("bitis", "bitis", "tarih", Baslik: "Bitiş", Grup: "Kimlik"),
            // DURUM "AKTİF" OLAN SÖZLEŞME İSTEĞE KOPYALANIR (797 tetiği):
            //   taslak sözleşme fiyat ve SLA sözü vermez.
            new("durum", "durum", "kod", SabitKodlar: TeleradKartSozlesmeDurum,
                Baslik: "Durum", Grup: "Kimlik"),

            // ----------------------------------------------------- ücret ----
            new("ucretModeli", "ucret_modeli", "kod", SabitKodlar: TeleradKartUcretModeli,
                Baslik: "Ücret Modeli", Grup: "Ücret"),
            // TARİFE = FİYAT LİSTESİ: tetkik başı modelde ücret buradan okunur;
            //   isteğe KOPYALANIR, sonradan değişmesi geçmiş işin fiyatını
            //   değiştirmez.
            new("fiyatListesiId", "fiyat_listesi_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_tarife_lookup",
                Baslik: "Tarife", Grup: "Ücret"),
            new("aylikSabit", "aylik_sabit", "para", Baslik: "Aylık Sabit", Grup: "Ücret"),
            new("aylikAdetSiniri", "aylik_adet_siniri", "sayi",
                Baslik: "Adet Sınırı", Grup: "Ücret"),
            new("acilEkOran", "acil_ek_oran", "ondalik",
                Baslik: "Acil Ek %", Grup: "Ücret"),
            new("oncelikliEkOran", "oncelikli_ek_oran", "ondalik",
                Baslik: "Öncelikli Ek %", Grup: "Ücret"),
            new("faturaPeriyodu", "fatura_periyodu", "kod", SabitKodlar: TeleradKartPeriyot,
                Baslik: "Periyot", Grup: "Ücret"),

            // ------------------------------------------------------- SLA ----
            // SLA DAKİKASI ÖNCELİĞE GÖRE AYRI ve istek açılırken KOPYALANIR
            //   (797): sözleşme sonradan değişince geçmiş isteğin sözü
            //   değişmez.
            new("slaAcilDk", "sla_acil_dk", "sayi", Baslik: "Acil dk", Grup: "SLA"),
            new("slaOncelikliDk", "sla_oncelikli_dk", "sayi",
                Baslik: "Öncelikli dk", Grup: "SLA"),
            new("slaRutinDk", "sla_rutin_dk", "sayi", Baslik: "Rutin dk", Grup: "SLA"),
            new("slaCezaOran", "sla_ceza_oran", "ondalik",
                Baslik: "SLA Ceza %", Grup: "SLA"),
        });
}
