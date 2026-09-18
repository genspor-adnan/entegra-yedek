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
                AramaKaynagi: "hasta", Baslik: "Hasta Kaydı (varsa)", Grup: "Hasta"),
            new("disErisimNo", "dis_erisim_no", "metin", EnFazlaUzunluk: 40,
                Baslik: "Erişim No (accession)", Grup: "Hasta"),
            new("isteyenHekim", "isteyen_hekim", "metin", EnFazlaUzunluk: 120,
                Baslik: "İsteyen Hekim", Grup: "Hasta"),

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
            new("onam", "onam", "mantik", Baslik: "Paylaşım onamı alındı", Grup: "Tetkik"),

            // ---------------------------------------------------- görüntü ---
            new("cekimZamani", "cekim_zamani", "zaman", Baslik: "Çekim", Grup: "Görüntü"),
            // SLA GÖRÜNTÜNÜN GELDİĞİ AN BAŞLAR (797): bu alan yazılınca tetik
            //   `sla_bitis`i hesaplar - o yüzden elle de girilebilir.
            new("gelisZamani", "gelis_zamani", "zaman",
                Baslik: "Görüntü Geliş", Grup: "Görüntü"),
            new("goruntuDurum", "goruntu_durum", "kod", SabitKodlar: TeleradKartGoruntu,
                Baslik: "Görüntü Durumu", Grup: "Görüntü"),
            new("goruntuSayisi", "goruntu_sayisi", "sayi", Baslik: "Görüntü Sayısı",
                Grup: "Görüntü"),
            new("seriSayisi", "seri_sayisi", "sayi", Baslik: "Seri Sayısı", Grup: "Görüntü"),
            new("studyUid", "study_uid", "metin", EnFazlaUzunluk: 64,
                Baslik: "Study UID", Grup: "Görüntü"),

            // ------------------------------------------------ atama / SLA ---
            new("atananRadyologId", "atanan_radyolog_id", "kod",
                KodTablosu: "public.v_rad_hekim_lookup",
                Baslik: "Atanan Radyolog", Grup: "Atama & SLA"),
            // HESAPLANANLAR SALT OKUNUR: hepsini tetik yazar.
            new("slaDk", "sla_dk", "sayi", Yazilabilir: false,
                Baslik: "SLA (dk)", Grup: "Atama & SLA"),
            new("slaBitis", "sla_bitis", "zaman", Yazilabilir: false,
                Baslik: "SLA Bitişi", Grup: "Atama & SLA"),
            new("slaAsildi", "sla_asildi", "mantik", Yazilabilir: false,
                Baslik: "SLA Aşıldı", Grup: "Atama & SLA"),
            new("okumaBas", "okuma_bas", "zaman", Yazilabilir: false,
                Baslik: "Okumaya Başlandı", Grup: "Atama & SLA"),
            new("onayZamani", "onay_zamani", "zaman", Yazilabilir: false,
                Baslik: "Onay", Grup: "Atama & SLA"),

            // -------------------------------------------- teslim / ücret ----
            new("teslimDurum", "teslim_durum", "kod", Yazilabilir: false,
                SabitKodlar: TeleradKartTeslim, Baslik: "Teslim Durumu", Grup: "Teslim & Ücret"),
            new("teslimZamani", "teslim_zamani", "zaman", Yazilabilir: false,
                Baslik: "Teslim", Grup: "Teslim & Ücret"),
            new("teslimHata", "teslim_hata", "metin", Yazilabilir: false,
                EnFazlaUzunluk: 400, Baslik: "Teslim Hatası", Grup: "Teslim & Ücret"),
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
                Baslik: "Fatura Belge Id", Grup: "Bağlar"),
            new("ekleyen", "ekleyen", "sayi", Yazilabilir: false),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false),
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
}
