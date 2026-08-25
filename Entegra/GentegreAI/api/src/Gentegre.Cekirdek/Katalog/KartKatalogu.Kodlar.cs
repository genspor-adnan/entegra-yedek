namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kart alanlarinda kullanilan SABIT kod listeleri - kod_liste'de karsiligi olmayan, uygulamaya gomulu kucuk kumeler (durum, KDV, cinsiyet, cek/senet yonu...).
/// </summary>
public static partial class KartKatalogu
{
    // GENINI kod listelerinde (BOLUM -2708 / -2201) 1 = Aktif, 0 = Pasif.
    //   Sema yorumu tersini soyluyordu; verinin 2.487'si 1, 229'u 0 - yani 1 aktif.
    private static readonly Dictionary<string, string> DurumKodlari =
        new() { ["1"] = "Aktif", ["0"] = "Pasif" };

    // STOKLAR.BILDIRIM - GENINI kod listesi degil, sabit 2 secenek (BILIM verisi: 0=3614, 2=1468, 1=1 stray).

    // STOKLAR.BILDIRIM - GENINI kod listesi degil, sabit 2 secenek (BILIM verisi: 0=3614, 2=1468, 1=1 stray).
    private static readonly Dictionary<string, string> BildirimKodlari =
        new() { ["0"] = "Yok", ["2"] = "ÜTS" };

    // STOKLAR.RAFOMRU_BIRIM - GENINI degil, sabit 3 secenek (mockup: Gun/Ay/Yil, varsayilan Yil).

    // STOKLAR.RAFOMRU_BIRIM - GENINI degil, sabit 3 secenek (mockup: Gun/Ay/Yil, varsayilan Yil).
    private static readonly Dictionary<string, string> RafOmruBirimKodlari =
        new() { ["0"] = "—", ["1"] = "Gün", ["2"] = "Ay", ["3"] = "Yıl" };

    // STOKLAR.KDV - GENINI BOLUM -2790'daki 6 secenek (kod_liste.DEGER bir SIRA numarasi,
    //   stok.kdv kolonu ise DOGRUDAN ORANI tutuyor - kod_liste.AD burada). O yuzden
    //   KodListesi mekanizmasi (deger<->deger eslesir varsayar) DEGIL, GENINI'den elle
    //   alinmis sabit liste kullanildi (deger = etiket = oranin kendisi).

    // STOKLAR.KDV - GENINI BOLUM -2790'daki 6 secenek (kod_liste.DEGER bir SIRA numarasi,
    //   stok.kdv kolonu ise DOGRUDAN ORANI tutuyor - kod_liste.AD burada). O yuzden
    //   KodListesi mekanizmasi (deger<->deger eslesir varsayar) DEGIL, GENINI'den elle
    //   alinmis sabit liste kullanildi (deger = etiket = oranin kendisi).
    private static readonly Dictionary<string, string> KdvKodlari =
        new() { ["0"] = "0", ["1"] = "1", ["8"] = "8", ["10"] = "10", ["18"] = "18", ["20"] = "20" };

    // BARKOD TIPI kod listesi KALKTI (145): stok_barkod tablosu dusuruldu,
    //   barkod artik ambalaj birimi satirinin bir alani (stok_birim.barkod).

    // TARAF_ADRES.TUR - yeni tablo (GENINI karsiligi yok), 001_sema_taraf.sql check kisitindan.

    // TARAF_ADRES.TUR - yeni tablo (GENINI karsiligi yok), 001_sema_taraf.sql check kisitindan.
    private static readonly Dictionary<string, string> AdresTurKodlari =
        new() { ["1"] = "Fatura", ["2"] = "Sevkiyat", ["3"] = "Merkez", ["4"] = "Şube/Depo", ["9"] = "Diğer" };

    // Kisi'nin adres tipi Cari'den FARKLI anlam tasir (ayni tur kolonu, ayni check kisiti
    //   1/2/3/4/9 - hangi liste gecerli, o satirin sahibi taraf.kisi'ye gore belirlenir).
    //   Kullanici: "kişi de adres tipleri sadece Ev/İş olabilir".

    // Kisi'nin adres tipi Cari'den FARKLI anlam tasir (ayni tur kolonu, ayni check kisiti
    //   1/2/3/4/9 - hangi liste gecerli, o satirin sahibi taraf.kisi'ye gore belirlenir).
    //   Kullanici: "kişi de adres tipleri sadece Ev/İş olabilir".
    private static readonly Dictionary<string, string> KisiAdresTurKodlari =
        new() { ["1"] = "Ev Adresi", ["2"] = "İş Adresi" };

    // TARAF.ROL (kisi_karti.html/kisi_listesi.html "KARAR/ETKİ/MUHS/KULL/TEKN") - GENINI
    //   karsiligi yok, mockup'a ozel sabit liste (040_kisi_rol.sql).

    // TARAF.ROL (kisi_karti.html/kisi_listesi.html "KARAR/ETKİ/MUHS/KULL/TEKN") - GENINI
    //   karsiligi yok, mockup'a ozel sabit liste (040_kisi_rol.sql).
    private static readonly Dictionary<string, string> KisiRolKodlari =
        new() { ["1"] = "Karar Verici", ["2"] = "Etkileyen", ["3"] = "Kullanıcı", ["4"] = "Mali/Muhasebe", ["5"] = "Teknik" };

    // taraf_personel.CINSIYET - GENINI karsiligi yok, yeni tablo (046_personel_kart.sql).

    // taraf_personel.CINSIYET - GENINI karsiligi yok, yeni tablo (046_personel_kart.sql).
    private static readonly Dictionary<string, string> CinsiyetKodlari =
        new() { ["1"] = "Erkek", ["2"] = "Kadın" };

    // taraf_personel.CALISMA_SEKLI - GENINI karsiligi yok (047_personel_ozluk_ogrenim.sql).

    // taraf_personel.CALISMA_SEKLI - GENINI karsiligi yok (047_personel_ozluk_ogrenim.sql).
    private static readonly Dictionary<string, string> CalismaSekliKodlari =
        new() { ["1"] = "Tam Zamanlı", ["2"] = "Yarı Zamanlı" };

    // taraf_personel.VARDIYA_TURU - GENINI karsiligi yok (048_personel_ozluk_uyruk_vardiya_sgk.sql).

    // taraf_personel.VARDIYA_TURU - GENINI karsiligi yok (048_personel_ozluk_uyruk_vardiya_sgk.sql).
    private static readonly Dictionary<string, string> VardiyaTuruKodlari =
        new() { ["1"] = "Gündüz", ["2"] = "Gece", ["3"] = "Vardiyalı" };

    // taraf_personel.MEDENI_HAL - GENINI karsiligi yok (049_personel_ozluk_medeni_kan.sql).

    // taraf_personel.MEDENI_HAL - GENINI karsiligi yok (049_personel_ozluk_medeni_kan.sql).
    private static readonly Dictionary<string, string> MedeniHalKodlari =
        new() { ["1"] = "Bekar", ["2"] = "Evli", ["3"] = "Boşanmış", ["4"] = "Dul" };

    // taraf_personel.SOZLESME_TURU - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).

    // taraf_personel.SOZLESME_TURU - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).
    private static readonly Dictionary<string, string> SozlesmeTuruKodlari =
        new() {
            ["1"] = "Belirsiz Süreli", ["2"] = "Belirli Süreli", ["3"] = "Deneme Süreli",
            ["4"] = "Stajyer/Çırak", ["5"] = "Mevsimlik",
        };

    // taraf_personel.DENEME_SURESI - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).

    // taraf_personel.DENEME_SURESI - GENINI karsiligi yok (050_personel_ozluk_sozlesme_deneme.sql).
    private static readonly Dictionary<string, string> DenemeSuresiKodlari =
        new() { ["0"] = "Yok", ["1"] = "1 Ay", ["2"] = "2 Ay", ["3"] = "3 Ay", ["4"] = "4 Ay" };

    // PERSONEL_IZIN.TUR/DURUM - ik_karti.html mockup ("Yıllık İzin/Mazeret/...", "Onaylı/
    //   Bekliyor/Reddedildi") - GENINI karsiligi yok (052_personel_izin.sql).

    // PERSONEL_IZIN.TUR/DURUM - ik_karti.html mockup ("Yıllık İzin/Mazeret/...", "Onaylı/
    //   Bekliyor/Reddedildi") - GENINI karsiligi yok (052_personel_izin.sql).
    private static readonly Dictionary<string, string> IzinTuruKodlari =
        new() { ["1"] = "Yıllık İzin", ["2"] = "Mazeret", ["3"] = "Rapor", ["4"] = "Ücretsiz İzin", ["9"] = "Diğer" };

    private static readonly Dictionary<string, string> IzinDurumuKodlari =
        new() { ["1"] = "Bekliyor", ["2"] = "Onaylı", ["3"] = "Reddedildi" };

    // PERSONEL_EGITIM.TUR - ik_karti.html mockup ("Diploma/Sertifika/Eğitim") - GENINI
    //   karsiligi yok (053_personel_egitim.sql).

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

    // hesap.tur - tek tabloda kasa/banka/POS/kredi karti/kredi/kupon (K1, 071).
    //   Harfler mali_hareket.hesap_turu ile AYNI kod uzayindan gelir.
    private static readonly Dictionary<string, string> HesapTuruKodlari =
        new() { ["K"] = "Kasa", ["B"] = "Banka", ["P"] = "POS",
                ["V"] = "Kredi Kartı", ["R"] = "Kredi", ["H"] = "Kupon Kasası" };

    // POS komisyonunun ne zaman kesildigi (eski POS.MASRAFCIKIS).

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

    /// <summary>
    /// Kartlarda kullanilan para birimleri. doviz_kur tablosundaki kodlarla ayni
    /// (TL yerel, digerleri kur tablosundan okunur) - elle metin girilince
    /// "TRY"/"tl" gibi varyantlar olusup kur eslesmesi kaciyordu.
    /// </summary>
    private static readonly Dictionary<string, string> DovizKodlari =
        new() { ["TL"] = "TL", ["USD"] = "USD", ["EUR"] = "EUR",
                ["GBP"] = "GBP", ["CHF"] = "CHF", ["JPY"] = "JPY" };

    // --------------------------------------------------------------- gorev ----

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
}
