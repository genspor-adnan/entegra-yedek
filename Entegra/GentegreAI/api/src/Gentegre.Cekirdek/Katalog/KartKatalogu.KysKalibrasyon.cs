namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — KALİBRASYON kartı (1058, sade). Kart cihazın kendisidir
/// (public.demirbas): künye Sabit Varlıklar'dan gelir, burada salt okunur;
/// yalnız periyot yazılır. "Kalibrasyon Gir" = Kalibrasyon kayıtları
/// sekmesine satır (public.demirbas_kalibrasyon, tür 1). Sonuç / geçerlilik
/// 723 tetiğiyle cihaza yazılır - kartın son / sonraki tarihleri oradan gelir.
/// Ölçüm noktaları, referans cihaz zinciri Sabit Varlıklar ekranında kalır.
/// Log 1480 (kart) · 1481 (kayıt satırı).
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysKalibrasyon = 1480;
    private const int LogKysKalibrasyonKayit = 1481;

    private static KartTanimi KysKalibrasyonKarti() => new(
        Ad: "kys-kalibrasyon",
        YetkiKodu: "kys.kalibrasyon",
        Tablo: "public.demirbas",
        LogTabloId: LogKysKalibrasyon,
        SubeKolonu: "sube_id",
        // Cihaz kaydı Sabit Varlıklar'ındır: buradan silinmez, hurda açılmaz.
        SilmeYok: true,
        SabitKosul: "durum <> 4",
        Alanlar: new KartAlani[]
        {
            new("kod",                   "kod",                    "metin", Yazilabilir: false, Baslik: "Cihaz No", Grup: "Cihaz"),
            new("ad",                    "ad",                     "metin", Yazilabilir: false, Baslik: "Cihaz", Grup: "Cihaz"),
            new("seriNo",                "seri_no",                "metin", Yazilabilir: false, Baslik: "Seri No", Grup: "Cihaz"),
            new("departmanId",           "departman_id",           "sayi",  Yazilabilir: false, Baslik: "Birim", Grup: "Cihaz",
                KodTablosu: "public.v_departman_lookup"),
            new("kalibrasyonPeriyotAy",  "kalibrasyon_periyot_ay", "sayi",  Baslik: "Periyot (ay)", Grup: "Cihaz",
                Ipucu: "0 = kalibrasyona tâbi değil"),
            new("sonKalibrasyon",        "son_kalibrasyon",        "tarih", Yazilabilir: false, Baslik: "Son kalibrasyon", Grup: "Cihaz"),
            new("kalibrasyonGecerlilik", "kalibrasyon_gecerlilik", "tarih", Yazilabilir: false, Baslik: "Geçerlilik (sonraki)", Grup: "Cihaz"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("kayitlar", "public.demirbas_kalibrasyon", "demirbas_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tarih",      "tarih",       "tarih", Zorunlu: true, Baslik: "Tarih"),
                new("tur",        "tur",         "kod",   Yazilabilir: false, Baslik: "Tür",
                    SabitKodlar: KaynakKatalogu.DbKalibTurKodlari),
                new("sonuc",      "sonuc",       "kod",   Zorunlu: true, Baslik: "Sonuç",
                    SabitKodlar: KaynakKatalogu.DbKalibSonucKodlari),
                new("gecerlilik", "gecerlilik",  "tarih", Baslik: "Geçerlilik"),
                new("kayitNo",    "kayit_no",    "metin", Baslik: "Sertifika No", EnFazlaUzunluk: 30),
                new("firmaId",    "firma_id",    "sayi",  Baslik: "Firma", KodTablosu: "public.v_cari_lookup"),
                new("aciklama",   "aciklama",    "metin", Baslik: "Açıklama", EnFazlaUzunluk: 400),
            },
            Sirala: "tarih desc, id desc", LogTabloId: LogKysKalibrasyonKayit, Baslik: "Kalibrasyon kayıtları",
            YeniSatirVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1 }),
        });
}
