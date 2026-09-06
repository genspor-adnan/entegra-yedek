namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ÜRETİM LİSTELERİ (429) — ürün ağacı, üretim emri, iş merkezi.
///
/// Mockuplar: Ekranlar/Uretim/urun_agaci_listesi.html,
/// uretim_emri_listesi.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// ÜRÜN AĞAÇLARI (BOM / reçete).
    ///
    /// Aynı kod birden çok SÜRÜMLE listelenir; eski sürüm silinmez, pasifleşir
    /// (açık emirler kendi sürümünde yaşamaya devam eder). Bu yüzden liste
    /// varsayılan olarak koda göre değil, KOD + SÜRÜM sırasıyla gelir.
    /// </summary>
    private static KaynakTanimi UrunAgaci() => new(
        Ad: "urun-agaci",
        YetkiKodu: "uretim",
        Kaynak: "public.urun_agaci a "
              + "  join public.stok s on s.id = a.stok_id "
              + "  left join public.depo md on md.id = a.mamul_depo_id",
        SubeKolonu: "a.sube_id",
        VarsayilanSirala: "a.kod asc, a.surum desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "a.id",   "sayi",  "Id", Varsayilan: false),
            // Gizli ama SART: "Üretim Emri Aç" ve "Nerede Kullanılıyor"
            //   aksiyonlari mamul kartina gore calisir.
            new("stokId",   "a.stok_id", "sayi", "Stok Id", Varsayilan: false),
            new("kod",      "a.kod",  "metin", "Kod", Genislik: 110),
            new("ad",       "a.ad",   "metin", "Ağaç Adı", Genislik: 240),
            new("mamulKod", "s.kod",  "metin", "Mamul Kodu", Genislik: 110,
                                               Varsayilan: false),
            new("mamulAd",  "s.kod || ' · ' || s.ad", "metin", "Mamul (Stok)",
                                               Genislik: 240),
            new("turAdi",
                "case a.tur when 2 then 'Yarı Mamul' when 3 then 'Paket / Set' "
                + "else 'Mamul' end",          "metin", "Tür", Hizalama: "orta",
                                               Bicim: "rozet", Genislik: 110,
                                               Filtrelenebilir: false),
            new("tur",      "a.tur",  "kod",   "Tür Kodu", Varsayilan: false),
            new("ciktiMiktar", "a.cikti_miktar", "sayi", "Çıktı", Hizalama: "sag",
                                               Bicim: "#,##0.##", Genislik: 80),
            new("surum",    "a.surum", "sayi", "Sürüm", Hizalama: "orta", Genislik: 70),
            // BILESEN/OPERASYON SAYISI: "bu ağaç dolu mu" sorusunun tek bakışta
            //   cevabı; boş ağaçtan emir açılırsa malzeme çıkmaz.
            new("bilesenSayisi",
                "(select count(*) from public.urun_agaci_satir x where x.agac_id = a.id)",
                                               "sayi",  "Bileşen", Hizalama: "orta",
                                               Genislik: 80, Filtrelenebilir: false),
            new("operasyonSayisi",
                "(select count(*) from public.urun_agaci_operasyon x where x.agac_id = a.id)",
                                               "sayi",  "Opr.", Hizalama: "orta",
                                               Genislik: 70, Filtrelenebilir: false),
            new("maliyetMalzeme", "a.maliyet_malzeme", "para", "Malzeme Maliyeti",
                                               Hizalama: "sag", Bicim: "#,##0.00",
                                               Genislik: 130),
            new("maliyetIscilik", "a.maliyet_iscilik", "para", "İşçilik",
                                               Hizalama: "sag", Bicim: "#,##0.00",
                                               Genislik: 110),
            new("maliyetToplam",  "a.maliyet_toplam",  "para", "Toplam",
                                               Hizalama: "sag", Bicim: "#,##0.00",
                                               Genislik: 120),
            new("maliyetTarih",   "a.maliyet_tarih",   "tarih", "Son Hesap",
                                               Hizalama: "orta",
                                               Bicim: "dd.MM.yyyy HH:mm",
                                               Genislik: 130, Varsayilan: false),
            new("varsayilan", "a.varsayilan", "mantik", "Varsayılan", Hizalama: "orta",
                                               Genislik: 90),
            new("mamulDepo", "coalesce(md.ad, '')", "metin", "Mamul Deposu",
                                               Genislik: 150, Varsayilan: false),
            new("durumAdi",
                "case a.durum when 1 then 'Pasif' else 'Aktif' end",
                                               "metin", "Durum", Hizalama: "orta",
                                               Bicim: "rozet", Genislik: 90,
                                               Filtrelenebilir: false),
            new("durum",    "a.durum", "kod",  "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// ÜRETİM EMİRLERİ.
    ///
    /// GECİKME SAKLANMAZ, HESAPLANIR: "termin geçti ve durum &lt; 6". Kolon
    /// olarak tutulsaydı her gece bir işin onu güncellemesi gerekirdi ve iş
    /// çalışmadığı gün liste yalan söylerdi.
    /// </summary>
    private static KaynakTanimi UretimEmri() => new(
        Ad: "uretim-emri",
        YetkiKodu: "uretim",
        Kaynak: "public.uretim_emri e "
              + "  join public.stok s on s.id = e.stok_id "
              + "  left join public.urun_agaci a on a.id = e.agac_id "
              + "  left join public.belge kb on kb.id = e.kaynak_belge_id",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.termin asc nulls last, e.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "e.id",   "sayi",  "Id", Varsayilan: false),
            // Fire aksiyonu mamul kartini bilmeli (mamul firesi emre islenir).
            new("stokId", "e.stok_id", "sayi", "Stok Id", Varsayilan: false),
            new("no",     "e.no",   "metin", "Emir No", Genislik: 140),
            new("turAdi",
                "case e.tur when 1 then 'Siparişe' when 3 then 'Fason' "
                + "when 4 then 'Alt Emir' else 'Stoğa' end",
                                             "metin", "Tür", Hizalama: "orta",
                                             Bicim: "rozet", Genislik: 100,
                                             Filtrelenebilir: false),
            new("tur",    "e.tur",  "kod",   "Tür Kodu", Varsayilan: false),
            new("mamulAd", "s.kod || ' · ' || s.ad", "metin", "Mamul", Genislik: 250),
            new("adet",   "e.adet", "sayi",  "Adet", Hizalama: "sag",
                                             Bicim: "#,##0.##", Genislik: 90),
            new("uretilenAdet", "e.uretilen_adet", "sayi", "Üretilen", Hizalama: "sag",
                                             Bicim: "#,##0.##", Genislik: 90),
            new("ilerleme",
                "case when e.adet > 0 "
                + "then round(e.uretilen_adet * 100 / e.adet) else 0 end",
                                             "sayi",  "İlerleme %", Hizalama: "sag",
                                             Genislik: 90, Filtrelenebilir: false),
            new("agacAd",
                "coalesce(a.kod, e.agac_kod) || case when e.agac_surum > 0 "
                + "then ' v' || e.agac_surum::text else '' end",
                                             "metin", "Ağaç / Sürüm", Genislik: 140),
            new("kaynakBelgeNo", "coalesce(kb.belge_no, '')", "metin", "Kaynak Belge",
                                             Hizalama: "orta", Genislik: 140,
                                             Varsayilan: false),
            new("planBas", "e.plan_bas", "tarih", "Başlangıç", Hizalama: "orta",
                                             Bicim: "dd.MM.yyyy", Genislik: 110),
            new("termin",  "e.termin",   "tarih", "Termin", Hizalama: "orta",
                                             Bicim: "dd.MM.yyyy", Genislik: 110),
            // MALZEME HAZIRLIK: emri başlatmadan önceki tek soru. Fonksiyon
            //   deposundaki kullanılabilir miktarı gerekliye böler.
            new("malzemeHazir", "public.fn_uretim_malzeme_hazirlik(e.id)",
                                             "sayi",  "Malz. %", Hizalama: "sag",
                                             Genislik: 85, Filtrelenebilir: false),
            new("gercekToplam", "e.gercek_toplam", "para", "Maliyet", Hizalama: "sag",
                                             Bicim: "#,##0.00", Genislik: 120),
            new("planToplam",   "e.plan_toplam",   "para", "Plan Maliyet",
                                             Hizalama: "sag", Bicim: "#,##0.00",
                                             Genislik: 120, Varsayilan: false),
            new("durumAdi",
                """
                case when e.durum between 1 and 5 and e.termin < current_date
                     then 'Gecikti'
                     else case e.durum when 0 then 'İptal' when 1 then 'Taslak'
                                       when 2 then 'Onaylı' when 3 then 'Planlandı'
                                       when 4 then 'Üretimde' when 5 then 'Kısmi'
                                       when 6 then 'Tamamlandı' else 'Kapatıldı' end
                end
                """,                         "metin", "Durum", Hizalama: "orta",
                                             Bicim: "rozet", Genislik: 120,
                                             Filtrelenebilir: false),
            new("durum",  "e.durum", "kod",  "Durum Kodu", Varsayilan: false),
            new("gecikti",
                "case when e.durum between 1 and 5 and e.termin < current_date "
                + "then 1 else 0 end",       "kod", "Gecikti", Varsayilan: false),
            new("oncelik", "e.oncelik", "kod", "Öncelik", Varsayilan: false),
            new("mamulLot", "e.mamul_lot", "metin", "Lot", Hizalama: "orta",
                                             Genislik: 130, Varsayilan: false),
            new("eklemeTarihi", "e.ekleme_tarihi", "tarih", "Oluşturma",
                                             Hizalama: "orta",
                                             Bicim: "dd.MM.yyyy HH:mm",
                                             Genislik: 130, Varsayilan: false),
        });

    /// <summary>
    /// İŞ MERKEZLERİ — operasyonun yapıldığı yer; saat ücreti işçilik
    /// maliyetinin kaynağıdır.
    /// </summary>
    private static KaynakTanimi IsMerkezi() => new(
        Ad: "is-merkezi",
        YetkiKodu: "uretim",
        Kaynak: "public.is_merkezi m left join public.taraf f on f.id = m.fason_taraf_id",
        SubeKolonu: "m.sube_id",
        VarsayilanSirala: "m.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",  "m.id",  "sayi",  "Id", Varsayilan: false),
            new("kod", "m.kod", "metin", "Kod", Genislik: 110),
            new("ad",  "m.ad",  "metin", "İş Merkezi", Genislik: 240),
            new("lokasyon", "m.lokasyon", "metin", "Lokasyon", Genislik: 160),
            new("gunlukKapasiteSaat", "m.gunluk_kapasite_saat", "sayi",
                                     "Kapasite (saat/gün)", Hizalama: "sag",
                                     Bicim: "#,##0.##", Genislik: 140),
            new("saatUcreti", "m.saat_ucreti", "para", "Saat Ücreti", Hizalama: "sag",
                                     Bicim: "#,##0.00", Genislik: 120),
            new("fason", "m.fason", "mantik", "Fason", Hizalama: "orta", Genislik: 80),
            new("fasonTaraf", "coalesce(f.unvan, '')", "metin", "Fason Tedarikçi",
                                     Genislik: 200, Varsayilan: false),
            new("durumAdi",
                "case m.durum when 1 then 'Pasif' else 'Aktif' end",
                                     "metin", "Durum", Hizalama: "orta",
                                     Bicim: "rozet", Genislik: 90,
                                     Filtrelenebilir: false),
            new("durum", "m.durum", "kod", "Durum Kodu", Varsayilan: false),
        });
}
