namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PRİM / HAKEDİŞ listeleri (324).
///
/// Prim TAHSİL EDİLDİKÇE doğar: hakediş satırı bir tahsilat dağıtımından
/// (321) üretilir, tarihi tahsilatın işlem tarihidir ve tabanı KDV hariç
/// matrahtır (323). Listeler bu üç kararı görünür kılar - "neden bu tutar"
/// sorusu taban + oran + rol ile satırda cevaplanır.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Prim planları - kapsam ve baz; satırlar kartın detayında.</summary>
    private static KaynakTanimi PrimPlani() => new(
        Ad: "prim-plani",
        YetkiKodu: "prim",
        Kaynak: "public.prim_plani p " +
                "left join public.taraf hk on hk.id = p.hekim_id " +
                "left join public.taraf ku on ku.id = p.odeyen_kurum_id",
        // Planin subesi BOS birakilabilir = "tüm şubeler" (kurum geneli prim
        //   politikasi). Duz esitlik boyle planlari listeden dusuruyordu.
        SubeKosulu: "(p.sube_id is null or p.sube_id = {sube})",
        VarsayilanSirala: "p.durum desc, p.oncelik desc, p.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.id",        "sayi",  "Id", Varsayilan: false),
            new("kod",       "p.kod",       "metin", "Kod", Genislik: 120),
            new("ad",        "p.ad",        "metin", "Plan Adı", Genislik: 260),
            new("baslangic", "p.baslangic", "tarih", "Başlangıç", Genislik: 110),
            new("bitis",     "p.bitis",     "tarih", "Bitiş", Genislik: 110),
            new("hekim",     "coalesce(hk.unvan, '')", "metin", "Hekim", Genislik: 180),
            new("hekimTipiAdi",
                "case p.hekim_tipi when 1 then 'İç hekim' when 2 then 'Dış hekim' else 'Tümü' end",
                                           "metin", "Hekim Tipi", Hizalama: "orta",
                                           Genislik: 110, Filtrelenebilir: false),
            new("hekimTipi", "p.hekim_tipi", "sayi", "Hekim Tipi Kodu", Varsayilan: false),
            new("kurum",     "coalesce(ku.unvan, '')", "metin", "Ödeyen Kurum", Genislik: 190),
            new("bazAdi",
                "case p.baz when 1 then 'Liste fiyatı' when 2 then 'Net tutar' " +
                "when 3 then 'Kurum payı' else 'Tahsil edilen (matrah)' end",
                                           "metin", "Baz", Genislik: 180,
                                           Filtrelenebilir: false),
            new("baz",       "p.baz",       "kod",   "Baz Kodu", Varsayilan: false),
            new("kdvHaric",  "p.kdv_haric", "mantik","KDV Hariç", Hizalama: "orta", Genislik: 90),
            new("primZamaniAdi",
                "case p.prim_zamani when 2 then 'Faturalamada' else 'Tahsilatta' end",
                                           "metin", "Prim Zamanı", Genislik: 130,
                                           Filtrelenebilir: false),
            new("primZamani", "p.prim_zamani", "sayi", "Zaman Kodu", Varsayilan: false),
            new("satirSayisi",
                "(select count(*) from public.prim_plani_satir s where s.plan_id = p.id)",
                                           "sayi",  "Satır", Hizalama: "sag", Genislik: 70,
                                           Filtrelenebilir: false),
            new("oncelik",   "p.oncelik",   "sayi",  "Öncelik", Hizalama: "sag", Genislik: 80),
            new("durum",     "p.durum",     "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("aciklama",  "p.aciklama",  "metin", "Açıklama", Varsayilan: false),
        });

    /// <summary>
    /// Hakediş SATIRLARI - "hangi tahsilattan, hangi kaleme, hangi rolle".
    /// Dönem kapanmamış satırlar başlıksızdır (açık hakediş).
    /// </summary>
    private static KaynakTanimi HakedisSatir() => new(
        Ad: "hakedis-satir",
        YetkiKodu: "prim",
        // Belge turu ve tahsilat turu adlari GORUNUMDEN gelir (330).
        Kaynak: "public.v_hakedis_satir v",
        SubeKolonu: "v.sube_id",
        VarsayilanSirala: "v.tarih desc, v.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "v.id",        "sayi",  "Id", Varsayilan: false),
            new("tarih",     "v.tarih",     "tarih", "Tarih", Genislik: 110),
            new("kisi",      "v.kisi",      "metin", "Kişi", Genislik: 200),
            new("tarafId",   "v.taraf_id",  "sayi",  "Kişi Id", Varsayilan: false),
            new("rolAdi",    "v.rol_adi",   "metin", "Rol", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 120,
                                           Filtrelenebilir: false),
            new("rol",       "v.rol",       "kod",   "Rol Kodu", Varsayilan: false),
            new("hasta",     "v.hasta",     "metin", "Hasta / Cari", Genislik: 190),
            new("kalem",     "v.kalem",     "metin", "Kalem", Genislik: 240),
            new("payAdi",    "v.pay_adi",   "metin", "Pay", Hizalama: "orta", Genislik: 100,
                                           Filtrelenebilir: false),
            new("pay",       "v.pay",       "sayi",  "Pay Kodu", Varsayilan: false),
            new("belgeTurAdi", "v.belge_tur_adi", "metin", "Belge Türü",
                                           Genislik: 130, Filtrelenebilir: false),
            // Tahsilatin turu (330): oran nakitte ve POS'ta farkli olabilir,
            //   "neden bu tutar" sorusunun bir parcasi.
            // Prim NEREDEN dogdu (332): tahsilattan mi, faturalamadan mi.
            new("kaynakAdi", "v.kaynak_adi", "metin", "Kaynak", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("kaynakTur", "v.kaynak_tur", "sayi", "Kaynak Kodu", Varsayilan: false),
            new("tahsilatTuruAdi", "v.tahsilat_turu_adi", "metin", "Tahsilat",
                                           Genislik: 150, Filtrelenebilir: false),
            new("tahsilatTuru", "v.tahsilat_turu", "sayi", "Tahsilat Kodu",
                                           Varsayilan: false),
            new("belgeTur",  "v.belge_tur", "sayi",  "Tür Kodu", Hizalama: "orta",
                                           Genislik: 90, Varsayilan: false),
            // Taban KDV HARIC matrah (323) - "neden bu tutar" sorusunun ilk yarisi.
            new("taban",     "v.taban",     "para",  "Taban (matrah)", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 130),
            new("deger",     "v.deger",     "para",  "Oran / Tutar", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 110),
            new("payYuzde",  "v.pay_yuzde", "para",  "Kişi Payı %", Hizalama: "sag",
                                           Varsayilan: false),
            new("tutar",     "v.tutar",     "para",  "Prim", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 110),
            // Durum (330): 1 taslak · 2 kesin · 3 onaylı (kilitli) · 4 ödendi.
            new("durumAdi",  "v.durum_adi", "metin", "Durum", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("durum",     "v.durum",     "sayi",  "Durum Kodu", Varsayilan: false),
            new("hakedisId", "v.hakedis_id","sayi",  "Hakediş", Varsayilan: false),
            new("belgeSatirId", "v.belge_satir_id", "sayi", "Kalem Id", Varsayilan: false),
            new("belgeId",   "v.belge_id",  "sayi",  "Belge Id", Varsayilan: false),
        });

    /// <summary>Hakediş başlıkları - kapatılmış dönemler.</summary>
    private static KaynakTanimi Hakedis() => new(
        Ad: "hakedis",
        YetkiKodu: "prim",
        Kaynak: "public.hakedis h left join public.taraf t on t.id = h.taraf_id",
        SubeKolonu: "h.sube_id",
        VarsayilanSirala: "h.donem_bitis desc, h.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "h.id",        "sayi",  "Id", Varsayilan: false),
            new("kisi",      "coalesce(t.unvan, '')", "metin", "Kişi", Genislik: 220),
            new("tarafId",   "h.taraf_id",  "sayi",  "Kişi Id", Varsayilan: false),
            new("donemBaslangic", "h.donem_baslangic", "tarih", "Dönem Başı", Genislik: 120),
            new("donemBitis",     "h.donem_bitis",     "tarih", "Dönem Sonu", Genislik: 120),
            new("satirSayisi",
                "(select count(*) from public.hakedis_satir s where s.hakedis_id = h.id)",
                                           "sayi",  "Satır", Hizalama: "sag", Genislik: 70,
                                           Filtrelenebilir: false),
            new("toplam",    "h.toplam",    "para",  "Toplam", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 130),
            new("durumAdi",
                "case h.durum when 3 then 'Ödendi' when 2 then 'Kesinleşti' " +
                "when 0 then 'İptal' else 'Taslak' end",
                                           "metin", "Durum", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("durum",     "h.durum",     "sayi",  "Durum Kodu", Varsayilan: false),
            new("kasaIslemId", "h.kasa_islem_id", "sayi", "Ödeme İşlemi", Varsayilan: false),
            new("aciklama",  "h.aciklama",  "metin", "Açıklama", Varsayilan: false),
            new("eklemeTarihi", "h.ekleme_tarihi", "tarih", "Oluşturma", Varsayilan: false),
        });
}
