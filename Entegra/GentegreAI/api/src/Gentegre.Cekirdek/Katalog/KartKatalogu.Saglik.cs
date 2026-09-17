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

    /// <summary>Dokuman durumu (419).</summary>
    private static readonly Dictionary<string, string> DokumanDurumKodlari = new()
    {
        ["1"] = "Taslak", ["2"] = "Onayda", ["3"] = "Yayında", ["4"] = "Arşiv",
        ["5"] = "İmha Edildi", ["0"] = "Silindi"
    };

    private static readonly Dictionary<string, string> DokumanSurumDurumKodlari = new()
    {
        ["1"] = "Taslak", ["2"] = "Onayda", ["3"] = "Yayında", ["4"] = "Arşiv",
        ["5"] = "Reddedildi"
    };

    /// <summary>KVKK erisim sinifi (419): izinden BAGIMSIZ ust kisit.</summary>
    private static readonly Dictionary<string, string> DokumanGizlilikKodlari = new()
    {
        ["1"] = "Herkese Açık", ["2"] = "Kurum İçi", ["3"] = "Gizli",
        ["4"] = "Özel Nitelikli (KVKK)"
    };

    /// <summary>Erisim kanali (419): KVKK kaydinda "nereden" sorusunun cevabi.</summary>
    private static readonly Dictionary<string, string> DokumanKanalKodlari = new()
    {
        ["1"] = "Uygulama", ["2"] = "Portal", ["3"] = "Paylaşım Linki", ["4"] = "API"
    };

    /// <summary>Paylasim linkinin YASAYAN durumu (424).</summary>
    private static readonly Dictionary<string, string> PaylasimDurumKodlari = new()
    {
        ["1"] = "Aktif", ["2"] = "Süresi Geçti / Kota Doldu", ["3"] = "İptal"
    };

    /// <summary>Onay adimi karari (419).</summary>
    private static readonly Dictionary<string, string> OnayKararKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Uygun / Onay", ["2"] = "Düzelt / Ret",
        ["3"] = "Geri Gönderildi"
    };

    private static readonly Dictionary<string, string> DokumanOlayKodlari = new()
    {
        ["1"] = "Yükleme", ["2"] = "Görüntüleme", ["3"] = "İndirme", ["4"] = "Düzenleme",
        ["5"] = "Yeni Sürüm", ["6"] = "Onaya Gönderme", ["7"] = "Onay", ["8"] = "Ret",
        ["9"] = "Yayın", ["10"] = "Arşiv", ["11"] = "Paylaşım", ["12"] = "Link Açılma",
        ["13"] = "İmha", ["14"] = "Erişim Reddi"
    };

    /// <summary>Kronik tani durumu (420).</summary>
    private static readonly Dictionary<string, string> KronikDurumKodlari = new()
    {
        ["1"] = "Aktif", ["2"] = "Kontrol Altında", ["3"] = "Geçmiş (remisyon)"
    };

    /// <summary>Tibbi gecmis kaydinin kaynagi (420).</summary>
    private static readonly Dictionary<string, string> TibbiKaynakKodlari = new()
    {
        ["1"] = "Hekim", ["2"] = "Hasta Beyanı", ["3"] = "e-Nabız", ["4"] = "Dış Kurum"
    };

    /// <summary>Gecmis olay turu (420).</summary>
    private static readonly Dictionary<string, string> GecmisOlayTuruKodlari = new()
    {
        ["1"] = "Ameliyat", ["2"] = "Girişim", ["3"] = "Yatış", ["4"] = "Aşı",
        ["5"] = "Travma", ["6"] = "Transfüzyon"
    };

    /// <summary>Recete turu (413) - ilac.recete_turu ile ayni kodlar.</summary>
    private static readonly Dictionary<string, string> ReceteTuruKodlari = new()
    {
        ["0"] = "Normal", ["1"] = "Kırmızı", ["2"] = "Yeşil", ["3"] = "Mor", ["4"] = "Turuncu"
    };

    /// <summary>Recete durumu (413): Medula kapisi acilana kadar 3'e gecilmez.</summary>
    private static readonly Dictionary<string, string> ReceteDurumKodlari = new()
    {
        ["1"] = "Taslak", ["2"] = "İmzalı", ["3"] = "Medula Kabul", ["4"] = "İptal"
    };

    private static readonly Dictionary<string, string> AlerjiTuruKodlari = new()
    {
        ["1"] = "İlaç", ["2"] = "Gıda", ["3"] = "Çevresel", ["4"] = "Lateks", ["5"] = "Kontrast"
    };

    private static readonly Dictionary<string, string> AlerjiSiddetKodlari = new()
    {
        ["1"] = "Hafif", ["2"] = "Orta", ["3"] = "Şiddetli", ["4"] = "Anafilaksi"
    };

    private static readonly Dictionary<string, string> KayitKaynakKodlari = new()
    {
        ["1"] = "Hasta Beyanı", ["2"] = "Hekim", ["3"] = "e-Nabız"
    };

    private static readonly Dictionary<string, string> IlacKaynakKodlari = new()
    {
        ["1"] = "Reçete", ["2"] = "Hasta Beyanı", ["3"] = "e-Nabız", ["4"] = "Dış Kurum"
    };

    private static readonly Dictionary<string, string> IlacUyumKodlari = new()
    {
        ["1"] = "Düzenli", ["2"] = "Aralıklı", ["3"] = "Bırakmış"
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
    /// <summary>SKRS sevk nedeni (465) - kodun kendisi e-Nabiz'a gider.</summary>
    private static readonly Dictionary<string, string> SevkNedenKodlari = new()
    {
        ["0"] = "—", ["1"] = "İleri tetkik / tedavi", ["2"] = "Yatak yok",
        ["3"] = "Uzman hekim yok", ["4"] = "Cihaz yok / arızalı",
        ["5"] = "Hasta / yakını talebi", ["9"] = "Diğer",
    };

    /// <summary>Sevk ulasimi (465).</summary>
    private static readonly Dictionary<string, string> AmbulansKodlari = new()
    {
        ["0"] = "—", ["1"] = "112 çağrıldı", ["2"] = "Kurum ambulansı",
        ["3"] = "Hasta kendi imkânı",
    };

    /// <summary>Vaka turu (SKRS): adli/kaza ayrimi bildirim ve fatura kurallarini degistirir.</summary>
    private static readonly Dictionary<string, string> VakaTuruKodlari = new()
    {
        ["0"] = "Normal", ["1"] = "Adli vaka", ["2"] = "İş kazası",
        ["3"] = "Trafik kazası", ["4"] = "Meslek hastalığı", ["9"] = "Diğer",
    };

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

    /// <summary>`lab_istem.oncelik` (433) - cihazda STAT sirasini belirler.</summary>
    private static readonly Dictionary<string, string> LabOncelikKodlari = new()
    {
        ["1"] = "Normal", ["2"] = "Öncelikli", ["3"] = "ACİL"
    };

    /// <summary>`lab_istem.kaynak` (433) - istem NEREDEN acildi.</summary>
    private static readonly Dictionary<string, string> LabKaynakKodlari = new()
    {
        ["1"] = "Muayene istemi", ["2"] = "Teletıp", ["3"] = "Banko",
        ["4"] = "Dış kurum", ["5"] = "Check-up"
    };

    /// <summary>`lab_numune.durum` (433).</summary>
    private static readonly Dictionary<string, string> LabNumuneDurumKodlari = new()
    {
        ["0"] = "Ret", ["1"] = "Etiketlendi", ["2"] = "Alındı", ["3"] = "Kabul",
        ["4"] = "Çalışıldı"
    };

    /// <summary>
    /// `lab_numune.kalite` (433) - ret nedeniyle AYNI kod uzayi. Tek liste
    /// olmasi bilincli: "hemolizli ama calisildi" ile "hemolizli, reddedildi"
    /// ayni gozlemdir; farki `ret` bayragi soyler.
    /// </summary>
    private static readonly Dictionary<string, string> LabKaliteKodlari = new()
    {
        ["1"] = "Uygun", ["2"] = "Hemolizli", ["3"] = "Lipemik", ["4"] = "İkterik",
        ["5"] = "Yetersiz miktar", ["6"] = "Pıhtılı", ["7"] = "Yanlış tüp",
        ["8"] = "Etiketsiz", ["9"] = "Diğer"
    };

    /// <summary>`lab_numune.alim_yeri` (433).</summary>
    private static readonly Dictionary<string, string> LabAlimYeriKodlari = new()
    {
        ["1"] = "Kan alma", ["2"] = "Servis", ["3"] = "Ev", ["4"] = "Dış"
    };

    /// <summary>
    /// Lab istem SATIRI durumu (433/434). Servis, katalog ve ekran ayni
    /// listeye bakmali - yoksa listede "onayli" gorunen satirin sonucu
    /// bekliyor olur.
    /// </summary>
    private static readonly Dictionary<string, string> LabSatirDurumKodlari = new()
    {
        ["0"] = "İptal", ["1"] = "İstendi", ["2"] = "Çalışılıyor",
        ["3"] = "Sonuçlandı", ["4"] = "Teknik Onay", ["5"] = "Onaylı",
        ["6"] = "Tekrar numune bekliyor",
    };

    /// <summary>Test sonucunun degerlendirmesi - sonuc formunda rozet olur.</summary>
    private static readonly Dictionary<string, string> LabIsaretKodlari = new()
    {
        // OK ISARETI ETIKETTE (kullanici: "dusuk / yuksek durumunda saginda
        //   ok ikonu da olsun"): grid hucresi tek kelime; yon okunmadan
        //   anlasilmiyordu. Panikte yon degil ACILIYET onemli - uyari
        //   isareti tasir.
        ["0"] = "Normal", ["1"] = "Düşük ↓", ["2"] = "Yüksek ↑",
        ["3"] = "Panik ⚠"
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
            // BOLUM ve HEKIM MUAYENE KARTINDAN DEGISTIRILEMEZ (kullanici).
            //   Ikisi de basvurunun yonlendirmesidir: muayene "Muayeneye Al"
            //   ile o bolumun/hekimin adina acilir, tahakkuk ve e-Nabiz paketi
            //   bu ikisine baglidir. Kart uzerinden degistirmek, acilmis
            //   istemleri ve tahakkuku baska bir bolume tasirdi - hekim
            //   degisimi ayri bir surectir (yeniden yonlendirme).
            //   Kural SUNUCUDA: yazilamaz alan istekte gelirse 400 doner,
            //   istemci yalnizca kapali cizer.
            new("bolumId", "bolum_id", "kod", KodTablosu: "public.v_departman_lookup",
                Yazilabilir: false, Baslik: "Bölüm", Grup: "Kimlik"),
            new("personelId", "personel_id", "kod", KodTablosu: "public.v_personel_lookup",
                Yazilabilir: false, Baslik: "Hekim", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: MuayeneDurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),
            // BASLANGIC / BITIS = HEKIMIN suresi (USS Muayene Baslangic-Bitis);
            //   muayeneTarihi kaydin acilisidir, ikisi ayni sey degil. Ekranin
            //   dugmeleri yazar (Muayeneye Al / Tamamla), elle girilmez.
            // TIP "zaman": muayenenin gun ici SAATI onemli - "28 sa 45 dk acik"
            //   suresi bu iki damgadan cikar, gun cozunurlugu onu olcemez.
            new("baslangic", "baslangic", "zaman", Yazilabilir: false,
                Baslik: "Başlama", Grup: "Kimlik", AltGrup: "Süre"),
            new("bitis", "bitis", "zaman", Yazilabilir: false,
                Baslik: "Bitiş", Grup: "Kimlik", AltGrup: "Süre"),
            new("randevuId", "randevu_id", "sayi", Baslik: "Randevu Id",
                Grup: "Kimlik", AltGrup: "Süre"),
            new("ustMuayeneId", "ust_muayene_id", "sayi",
                Baslik: "İsteyen Muayene (Konsültasyon)", Grup: "Kimlik", AltGrup: "Süre"),

            // --------------------------------------------------- anamnez ----
            // SIKAYET/HIKAYE COK SATIRLI (mockup muayene_karti.html): kolon `text`
            //   ama sinir verilmedigi icin kart TEK SATIRLIK kutu ciziyordu -
            //   hekim yazdiginin son kelimesini goruyordu. 4000 sinir hem
            //   dogrulama hem cok satirli kutu (uzun-metin kurali).
            new("sikayet", "sikayet", "metin", EnFazlaUzunluk: 4000,
                Baslik: "Şikâyet", Grup: "Anamnez"),
            new("hikaye", "hikaye", "metin", EnFazlaUzunluk: 4000,
                Baslik: "Hikâye", Grup: "Anamnez"),
            // Ozgecmis / soygecmis / aliskanlik BURADA SERBEST NOTTUR; yapisal
            //   karsiliklari hastanin tibbi gecmisinde (Faz 1 ortak platform)
            //   yasar - muayene aninda yazilan not oraya islenir.
            new("ozgecmisNotu", "ozgecmis_notu", "metin", Baslik: "Özgeçmiş",
                Grup: "Anamnez"),
            new("soygecmisNotu", "soygecmis_notu", "metin", Baslik: "Soygeçmiş",
                Grup: "Anamnez"),
            new("aliskanlikNotu", "aliskanlik_notu", "metin", Baslik: "Alışkanlıklar",
                Grup: "Anamnez"),

            // --------------------------------------------- fizik muayene ----
            new("sablonId", "sablon_id", "kod", KodTablosu: "public.v_muayene_sablon_lookup",
                Baslik: "Muayene Şablonu", Grup: "Fizik Muayene"),
            // Sablondan DERLENEN metin: rapora ve e-Nabiz pakete giden budur.
            //   Bulgular sekmesindeki alanlardan uretilir, hekim duzeltebilir.
            new("bulguOzet", "bulgu_ozet", "metin", Baslik: "Muayene Bulguları",
                Grup: "Fizik Muayene"),

            // ---------------------------------------------- tani / karar ----
            // Degerlendirme/plan SERBEST METIN: rapora ve e-Nabiz'a giden
            //   karar cumlesi tek satirlik kutuya sigmiyordu (uzun metin
            //   kurali >= 400 karakterde cok satirli kutu cizer).
            new("karar", "karar", "metin", EnFazlaUzunluk: 4000,
                Baslik: "Değerlendirme / Plan", Grup: "Tanı (ICD-10)"),
            // CIKIS SEKLI (627): hastanin muayene sonundaki durumu - USS 106'nin
            //   ZORUNLU alani. Varsayilani "iyilesderek cikis"; sevk, olum,
            //   tedaviyi reddetme gibi haller burada secilir. Liste SKRS'nin
            //   kendisi (609), ayri bir esleme yok.
            new("cikisSekli", "cikis_sekli", "kod", KodListesi: "cikis.sekli",
                Baslik: "Çıkış Şekli", Grup: "Tanı (ICD-10)"),
            // Mockup etiketleri: "Karar" · "Sevk edilen tesis" · "Klinik" ·
            //   "Sevk nedeni / notu" · "Ambulans".
            new("yonlendirme", "yonlendirme", "kod", SabitKodlar: YonlendirmeKodlari,
                Baslik: "Karar", Grup: "Sevk / Konsültasyon", AltGrup: "Sevk"),
            new("sevkTesisKodu", "sevk_tesis_kodu", "metin", EnFazlaUzunluk: 20,
                Baslik: "Sevk edilen tesis", Grup: "Sevk / Konsültasyon", AltGrup: "Sevk"),
            new("sevkKlinikKod", "sevk_klinik_kod", "metin", EnFazlaUzunluk: 20,
                Baslik: "Klinik", Grup: "Sevk / Konsültasyon", AltGrup: "Sevk"),
            // SEVK NEDENI KODLU (SKRS): serbest cumle NOT alanina yazilir -
            //   koda cumle yazilinca e-Nabiz'a gecersiz deger gidiyordu.
            new("sevkNeden", "sevk_neden", "kod", SabitKodlar: SevkNedenKodlari,
                Baslik: "Sevk nedeni", Grup: "Sevk / Konsültasyon", AltGrup: "Sevk"),
            new("sevkNotu", "sevk_notu", "metin", EnFazlaUzunluk: 500,
                Baslik: "Sevk notu (karşı hekime)", Grup: "Sevk / Konsültasyon",
                AltGrup: "Sevk"),
            // AMBULANS sevkin parcasi: hastanin kendi imkaniyla mi gittigi
            //   yoksa 112 ile mi tasindigi sevk kagidinda sorulan ilk sey.
            new("ambulans", "ambulans", "kod", SabitKodlar: AmbulansKodlari,
                Baslik: "Ambulans", Grup: "Sevk / Konsültasyon", AltGrup: "Sevk"),
            new("ambulansZaman", "ambulans_zaman", "zaman",
                Baslik: "Ambulans saati", Grup: "Sevk / Konsültasyon", AltGrup: "Sevk"),
            new("kontrolOnerisiGun", "kontrol_onerisi_gun", "sayi",
                Baslik: "Kontrol (gün)", Grup: "Sevk / Konsültasyon", AltGrup: "Takip"),
            new("kontrolRandevuId", "kontrol_randevu_id", "sayi",
                Baslik: "Kontrol Randevu Id", Grup: "Sevk / Konsültasyon", AltGrup: "Takip"),
            new("vakaTuru", "vaka_turu", "kod", SabitKodlar: VakaTuruKodlari,
                Baslik: "Vaka Türü",
                Grup: "Sevk / Konsültasyon", AltGrup: "Takip"),
            new("konsultasyonSoru", "konsultasyon_soru", "metin", EnFazlaUzunluk: 500,
                Baslik: "Konsültasyon sorusu", Grup: "Sevk / Konsültasyon",
                AltGrup: "Konsültasyon"),

            // -------------------------------------------------- gönderim ----
            new("enabizDurum", "enabiz_durum", "kod", Yazilabilir: false,
                Baslik: "e-Nabız Durumu", Grup: "Tanı (ICD-10)", AltGrup: "Gönderim"),
            new("tamamlayanId", "tamamlayan_id", "sayi", Yazilabilir: false,
                Baslik: "Tamamlayan", Grup: "Tanı (ICD-10)", AltGrup: "Gönderim"),
            new("tamamlanma", "tamamlanma", "tarih", Yazilabilir: false,
                Baslik: "Tamamlanma", Grup: "Tanı (ICD-10)", AltGrup: "Gönderim")
        },
        Detaylar: new DetayTanimi[]
        {
            // VITAL: bir muayenede BIRDEN COK olcum olur (hemsire girisi,
            //   cihazdan gelen, hekimin tekrari). USS son olcumu ister; tek
            //   satirda tutmak olcum tarihcesini yok ederdi.
            new("vitaller", "public.muayene_vital", "muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                // SIRA MOCKUP'TAN (muayene_karti.html vital izgarasi): tansiyon,
                //   nabiz, SpO2, ates, solunum, agri, boy/kilo, BKI, bel. Klinik
                //   okuma sirasi budur - alfabetik ya da tablo sirasi degil.
                //   Birim ETIKETTE: kutuya birim yazilamaz, ama hangi birimde
                //   girilecegi belli olmazsa 36,8 ile 98,2 ayni kutuya duser.
                // TANSIYON TEK ETIKET, IKI KUTU (mockup ".ikili"): sistolik ve
                //   diyastolik ayri okunmaz, "158 / 96" birlikte anlam tasir.
                new("sistolik", "sistolik", "sayi", EslesAlan: "diyastolik",
                    Baslik: "Tansiyon (mmHg)"),
                new("diyastolik", "diyastolik", "sayi", Baslik: "Diyastolik (mmHg)"),
                new("nabiz", "nabiz", "sayi", Baslik: "Nabız (/dk)"),
                new("spo2", "spo2", "sayi", Baslik: "SpO₂ (%)"),
                new("ates", "ates", "ondalik", Baslik: "Ateş (°C)"),
                new("solunum", "solunum", "sayi", Baslik: "Solunum (/dk)"),
                new("agriVas", "agri_vas", "sayi", Baslik: "Ağrı (VAS 0-10)"),
                new("boyCm", "boy_cm", "ondalik", EslesAlan: "kiloKg",
                    Baslik: "Boy / Kilo (cm/kg)"),
                new("kiloKg", "kilo_kg", "ondalik", Baslik: "Kilo (kg)"),
                // BKI SAKLANIR: boy/kilo sonradan duzeltilse bile o anki
                //   olcumun degeri degismemeli - kayit tarihcedir.
                new("bki", "bki", "ondalik", Baslik: "BKİ"),
                new("belCevresiCm", "bel_cevresi_cm", "sayi", Baslik: "Bel çevresi (cm)"),
                new("glukozParmak", "glukoz_parmak", "sayi", Baslik: "Parmak glukoz (mg/dL)"),
                new("gks", "gks", "sayi", Baslik: "GKS"),
                // Olcum kimligi EN SONDA: hekimin okudugu deger yukarida,
                //   "kim, ne zaman, nereden" altta.
                new("zaman", "zaman", "zaman", Baslik: "Ölçüm zamanı"),
                new("kaynak", "kaynak", "kod", SabitKodlar: VitalKaynakKodlari,
                    Baslik: "Kaynak"),
                new("olcenId", "olcen_id", "kod", KodTablosu: "public.v_personel_lookup",
                    Baslik: "Ölçen"),
            }, SubeKolonu: null, Sirala: "zaman desc, id desc",
               Baslik: "Vital Bulgular", LogTabloId: 962),

            // TANI: ana / ek / on ayrimi ve kronik isareti burada. Muayene
            //   basina TEK ana tani db kisitiyla korunur (ux_tani_ana) - iki
            //   ana tani e-Nabiz ve Medula gonderiminde reddedilir.
            new("tanilar", "public.tani", "muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                // ICD KODU DEGISTIRILEMEZ (kullanici): tani satiri "＋ ICD-10
                //   Ekle" ucuyla acilir; kodu kartta degistirmek ayni satiri
                //   baska bir hastaliga cevirip gecmisi bozardi - yanlis tani
                //   kaldirilir, dogrusu eklenir.
                new("icdKod", "icd_kod", "kod", Zorunlu: true, Yazilabilir: false,
                    KodTablosu: "public.v_icd_lookup", AramaKaynagi: "icd",
                    Baslik: "ICD-10"),
                // TANI ADI: kod tek basina okunmuyor ("I21.0" kimseye bir sey
                //   soylemiyor). Katalogdan COZULUR, tani satirinda saklanmaz -
                //   ICD adi guncellenirse kayit da guncel kalir. Yazilamaz.
                new("taniAd", "(select x.ad from public.icd x where x.kod = tani.icd_kod)",
                    "metin", Yazilabilir: false, Baslik: "Tanı"),
                // TANI TURU SKRS LISTESINDEN (625): elle yazilmis listenin dorduncu
                //   degeri "Sevk Tanisi" idi, SKRS'de 4 = "AYIRICI TANI". e-Nabiz
                //   103 bu alani SKRS kodu olarak ister; ayrisan bir deger sevk
                //   tanisi secilen her muayeneyi yanlis bildirirdi.
                new("tur", "tur", "kod", KodListesi: "tani.turu", Baslik: "Tür"),
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
                // Mockup basligi "Sistem" (muayene_karti.html fizik muayene
                //   tablosu): satirlar branş şablonunun sistem alanlaridir.
                new("sablonAlanId", "sablon_alan_id", "kod", Zorunlu: true,
                    KodTablosu: "public.v_muayene_sablon_alan_lookup", Baslik: "Sistem"),
                new("normal", "normal", "mantik", Baslik: "Normal"),
                new("degerMetin", "deger_metin", "metin", Baslik: "Bulgu"),
                new("degerSayi", "deger_sayi", "sayi", Baslik: "Değer"),
                new("taraf", "taraf", "kod", SabitKodlar: TarafKodlari, Baslik: "Taraf"),
            }, SubeKolonu: null, Sirala: "id asc",
               Baslik: "Bulgular", LogTabloId: 964),

            // RAPOR (462): muayeneden çıkan istirahat / durum / ilaç kullanım
            //   raporları. Rapor muayenenin ÇIKTISIDIR ve kendi numarası,
            //   tarih aralığı, onayı olan ayrı bir kayıttır.
            new("raporlar", "public.muayene_rapor", "muayene_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tur", "tur", "kod", SabitKodlar: RaporTuruKodlari, Baslik: "Tür"),
                // ALT TUR (mockup): "Istirahat"in SGK karsiligi is goremezlik
                //   mi refakat mi - tur tek basina Medula'ya yetmiyor.
                new("altTur", "alt_tur", "kod", SabitKodlar: RaporAltTuruKodlari,
                    Baslik: "Alt tür"),
                new("raporNo", "rapor_no", "metin", EnFazlaUzunluk: 20, Baslik: "Rapor No"),
                new("baslangic", "baslangic", "tarih", Baslik: "Başlangıç"),
                // BITIS baslangic + gunden HESAPLANIR (db/464); elle girilen
                //   deger korunur, o yuzden alan duruyor ama gridde gizli.
                new("bitis", "bitis", "tarih", Baslik: "Bitiş"),
                // GUN HEKIMIN YAZDIGIDIR: is gunu/tatil kurali kuruma gore
                //   degisir, tarih farkindan otomatik uretmek yanlis rapor
                //   verirdi.
                new("gun", "gun", "sayi", Baslik: "Süre (gün)"),
                new("icdKod", "icd_kod", "kod", KodTablosu: "public.v_icd_lookup",
                    AramaKaynagi: "icd", Baslik: "Tanı (ICD-10)"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 500,
                    Baslik: "Açıklama"),
                // IMZA raporun kilidi: imzalanan rapor degismez (SGK'ya giden
                //   metin odur). Dugmenin yazdigi alanlar - elle girilmez.
                new("imzaZamani", "imza_zamani", "zaman", Yazilabilir: false,
                    Baslik: "İmza"),
                new("durum", "durum", "kod", SabitKodlar: RaporDurumKodlari,
                    Yazilabilir: false, Baslik: "Durum"),
            }, SubeKolonu: "sube_id", Sirala: "id desc",
               Baslik: "Rapor", LogTabloId: 966,
               // Yeni satirda hasta muayeneden gelir: rapor hastaya baglidir,
               //   hasta secimi kullaniciya sorulacak bir sey degil.
               YeniSatirVarsayilanlari: new Dictionary<string, object?> { ["durum"] = 1 }),

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
        LogTabloId: 1292,
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

}
