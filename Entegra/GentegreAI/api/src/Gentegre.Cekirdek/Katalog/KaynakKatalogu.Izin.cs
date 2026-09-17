namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// İZİN LİSTELERİ (743) — talepler ve bakiye.
///
/// BAKİYE AYRI LİSTE: "kimin kaç günü kaldı" sorusu izin taleplerinin
/// listesinden okunamaz - orada yalnız istenenler var. İK'nın yıl başında
/// ve izin döneminde baktığı asıl ekran budur.
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> IzinTurKodlari = new()
    {
        ["1"] = "Yıllık İzin", ["2"] = "Mazeret", ["3"] = "Rapor",
        ["4"] = "Ücretsiz İzin", ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> IzinDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylı",
        ["3"] = "Reddedildi", ["4"] = "İptal",
    };

    // ------------------------------------------------------- talepler ----
    private static KaynakTanimi PersonelIzinKaynagi() => new(
        Ad: "personelIzin",
        YetkiKodu: "ik.izin",
        Kaynak: "public.v_personel_izin v",
        SubeKolonu: "v.sube_id",
        // AÇIK OLANLAR ÖNCE: izin listesi bir arşiv değil, bir takvimdir.
        VarsayilanSirala: "case when v.durum in (0, 1) then 0 else 1 end," +
                          " v.baslangic_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("izinNo", "v.izin_no", "metin", "İzin No", Genislik: 120,
                Varsayilan: false),
            new("personelAd", "v.personel_ad", "metin", "Personel", Genislik: 200),
            new("gorevAd", "v.gorev_ad", "metin", "Görev", Genislik: 160,
                Varsayilan: false),
            new("amirAd", "v.amir_ad", "metin", "Âmiri", Genislik: 170,
                Varsayilan: false),
            new("turAdi",
                "case v.tur when 1 then 'Yıllık İzin' when 2 then 'Mazeret'" +
                " when 3 then 'Rapor' when 4 then 'Ücretsiz İzin' else 'Diğer' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 120, Bicim: "rozet",
                Filtrelenebilir: false),
            new("tur", "v.tur", "kod", "Tür Kodu", Varsayilan: false,
                Kodlar: IzinTurKodlari),
            new("baslangicTarihi", "v.baslangic_tarihi", "tarih", "Başlangıç",
                Hizalama: "orta", Genislik: 110),
            new("bitisTarihi", "v.bitis_tarihi", "tarih", "Bitiş", Hizalama: "orta",
                Genislik: 110),
            new("gun", "v.gun", "ondalik", "Gün", Hizalama: "sag", Genislik: 80),
            new("isGunu", "v.is_gunu", "mantik", "İş günü", Hizalama: "orta",
                Genislik: 80, Varsayilan: false),
            new("durumAdi",
                "case v.durum when 0 then 'Taslak' when 1 then 'Onayda'" +
                " when 2 then 'Onaylı' when 3 then 'Reddedildi'" +
                " when 4 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum", "v.durum", "kod", "Durum Kodu", Varsayilan: false,
                Kodlar: IzinDurumKodlari),
            // BEKLEYEN BASAMAK: "onayda" demek yetmez, kimde beklediği görünmeli.
            new("bekleyenBasamak", "coalesce(v.bekleyen_basamak, '')", "metin",
                "Bekleyen", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("onayGecikmeGun", "v.onay_gecikme_gun", "sayi", "Onay Gecikmesi",
                Hizalama: "sag", Genislik: 120),
            // ÇAKIŞAN İZİN: onaylayanın sorusu "bu kişi gidebilir mi" değil,
            //   "ekip ayakta kalır mı".
            new("cakisanIzin", "v.cakisan_izin", "sayi", "Çakışan", Hizalama: "sag",
                Genislik: 90),
            new("yerineAd", "v.yerine_ad", "metin", "Yerine Bakan", Genislik: 170,
                Varsayilan: false),
            new("belgeNo", "v.belge_no", "metin", "Belge No", Genislik: 120,
                Varsayilan: false),
            new("aciklama", "v.aciklama", "metin", "Açıklama", Genislik: 240,
                Varsayilan: false),
            new("talepTarihi", "v.talep_tarihi", "tarih", "Talep", Hizalama: "orta",
                Genislik: 110, Varsayilan: false),
            new("tarafId", "v.taraf_id", "sayi", "Personel Id", Varsayilan: false),
        });

    // --------------------------------------------------------- bakiye ----
    private static KaynakTanimi IzinBakiyeKaynagi() => new(
        Ad: "izinBakiye",
        YetkiKodu: "ik.izin",
        Kaynak: "public.v_personel_izin_bakiye v",
        SubeKolonu: "v.sube_id",
        VarsayilanSirala: "v.personel_ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.taraf_id", "sayi", "Id", Varsayilan: false),
            new("tarafId", "v.taraf_id", "sayi", "Personel Id", Varsayilan: false),
            new("personelAd", "v.personel_ad", "metin", "Personel", Genislik: 220),
            new("iseGirisTarihi", "v.ise_giris_tarihi", "tarih", "İşe Giriş",
                Hizalama: "orta", Genislik: 110),
            // YIL METİN: sayı olarak binlik ayracı alıyor ve "2.026" diye
            //   görünüyordu. Yıl bir miktar değil, bir etikettir.
            new("yil", "v.yil::text", "metin", "Yıl", Hizalama: "orta", Genislik: 70),
            new("hakGun", "v.hak_gun", "ondalik", "Hak", Hizalama: "sag", Genislik: 90),
            new("devirGun", "v.devir_gun", "ondalik", "Devir", Hizalama: "sag",
                Genislik: 90),
            new("ekGun", "v.ek_gun", "ondalik", "Ek", Hizalama: "sag", Genislik: 80,
                Varsayilan: false),
            new("kullanilanGun", "v.kullanilan_gun", "ondalik", "Kullanılan",
                Hizalama: "sag", Genislik: 110),
            // PLANLANAN AYRI: onaylı ama başlamamış izin bakiyeden düşer,
            //   "kullanıldı" değildir - tek sayı gösterseydik personel
            //   "iznim duruyor" sanıp ikinci kez talep ederdi.
            new("planlananGun", "v.planlanan_gun", "ondalik", "Planlanan",
                Hizalama: "sag", Genislik: 110),
            new("onaydaGun", "v.onayda_gun", "ondalik", "Onayda", Hizalama: "sag",
                Genislik: 100),
            new("kalan",
                "coalesce(v.hak_gun, 0) + v.devir_gun + v.ek_gun" +
                " - v.kullanilan_gun - v.planlanan_gun - v.onayda_gun",
                "ondalik", "Kalan", Hizalama: "sag", Genislik: 100),
            // HESAPLANAMIYOR: işe giriş tarihi girilmemiş personelin hakkı
            //   sıfır DEĞİL, bilinmiyor. İkisini aynı göstermek "hakkı bitti"
            //   demek olurdu.
            new("durumAdi",
                "case when v.hak_gun is null then 'İşe giriş yok'" +
                " when v.hak_gun = 0 then 'Hak doğmadı'" +
                " when coalesce(v.hak_gun, 0) + v.devir_gun + v.ek_gun" +
                "      - v.kullanilan_gun - v.planlanan_gun - v.onayda_gun <= 0" +
                " then 'Bakiye bitti' else 'Kullanılabilir' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 130, Bicim: "rozet",
                Filtrelenebilir: false),
            new("hakYok", "case when v.hak_gun is null then 1 else 0 end", "sayi",
                "Hak Hesaplanamıyor", Varsayilan: false),
        });
}
