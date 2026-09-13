namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// e-NABIZ LİSTELERİ — kod eşlemesi ve paket kuyruğu.
///
/// KaynakKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1183 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// e-NABIZ KOD EŞLEME (454) — yerel tanım ile SKRS kodu arasındaki köprü.
    ///
    /// Hasta cinsiyeti, medeni hali gibi alanlar zaten SKRS koduyla tutulur
    /// (340); burası klinik, başvuru türü, geliş şekli, sonuç birimi gibi
    /// KURUMUN KENDİ tanımları içindir. Eşleme yoksa paket "eksik alan" ile
    /// kuyrukta bekler - USS bilmediği kodu reddeder.
    /// </summary>
    private static KaynakTanimi EnabizKodEsleme() => new(
        Ad: "enabiz-kod-esleme",
        YetkiKodu: "entegrasyon",
        Kaynak: "public.enabiz_kod_esleme e "
              + "  left join public.v_randevu_bolum_lookup b on b.id = e.yerel_id",
        SubeKolonu: null,                    // eşleme kurum geneli tanımdır
        VarsayilanSirala: "e.esleme_turu asc, e.yerel_kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "e.id", "sayi", "Id", Varsayilan: false),
            // Ham kod SUZGEC icin durur, ekranda OKUNUR ad gosterilir:
            //   "KLINIK" teknik anahtardir, kullanicinin dili degil.
            new("eslemeTuruAdi",
                "case e.esleme_turu when 'KLINIK' then 'Klinik / Bölüm' "
                + "when 'BASVURU_TURU' then 'Başvuru Türü' else e.esleme_turu end",
                                 "metin", "Eşleme Türü", Genislik: 170,
                                 Filtrelenebilir: false),
            new("eslemeTuru", "e.esleme_turu", "metin", "Tür Kodu", Hizalama: "orta",
                                 Genislik: 130, Varsayilan: false),
            new("yerelAdi", "coalesce(b.ad, e.yerel_kod)", "metin", "Yerel Karşılık",
                                 Genislik: 180),
            new("yerelKod", "e.yerel_kod", "metin", "Yerel Kod", Hizalama: "orta",
                                 Genislik: 120, Varsayilan: false),
            new("yerelId", "e.yerel_id", "sayi", "Yerel Id", Varsayilan: false),
            new("skrsListe", "e.skrs_liste", "metin", "SKRS Listesi", Genislik: 180),
            new("skrsKod", "e.skrs_kod", "metin", "SKRS Kodu", Hizalama: "orta",
                                 Genislik: 120),
            new("skrsAd", "e.skrs_ad", "metin", "SKRS Karşılığı", Genislik: 260),
            new("durumAdi", "case e.aktif when 1 then 'Aktif' else 'Pasif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("aktif", "e.aktif", "kod", "Aktif Kodu", Varsayilan: false),
        });

    private static KaynakTanimi EnabizPaket() => new(
        Ad: "enabiz-paket",
        YetkiKodu: "entegrasyon",
        Kaynak: "public.enabiz_paket p "
              + "  join public.enabiz_paket_turu t on t.id = p.paket_turu_id "
              + "  left join public.taraf h on h.id = p.hasta_id "
              + "  left join public.v_personel_lookup k on k.id = p.hekim_id",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.uretim_tarihi desc, p.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.id",          "sayi",  "Id", Varsayilan: false),
            new("paketNo",   "p.paket_no",    "metin", "Paket No", Hizalama: "orta",
                                              Genislik: 150),
            // USS KODU ROZET (kullanici): 101/102/103/301 kuyrukta en hizli
            //   taranan alan - hangi paket turunun biriktigini renkli rozet
            //   bir bakista soyluyor, duz metin satir satir okutuyordu.
            new("ussPaket",  "t.uss_paket_kodu", "metin", "USS", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 70),
            new("turAdi",    "t.ad",          "metin", "Paket Türü", Genislik: 190),
            new("turKod",    "t.kod",         "metin", "Tür Kodu", Varsayilan: false),
            // PROTOKOL NO hastanin SOLUNDA (kullanici): kuyrukta bir satiri
            //   hastanenin kendi numarasiyla aramak, hasta adiyla aramaktan
            //   daha sik. Numara paketin KAYNAK BELGESINDEN okunur - paket
            //   kendi numarasini (paket_no) zaten tasiyor, o baska sey.
            // PROTOKOL NO IKI KAYNAKTAN: paket dogrudan BASVURUDAN (kaynak_tur 1)
            //   ya da MUAYENEDEN (2) dogar. Muayene kaynaklilarda kaynak_id
            //   muayenenin kendisidir, protokol numarasi ise muayenenin bagli
            //   oldugu belgede. Tek dala bakmak 103/106 satirlarini bos
            //   birakiyordu - oysa kuyrukta bir satiri numarasiyla aramak en
            //   sik yapilan is.
            new("protokolNo",
                "coalesce("
                + "(select b.belge_no from public.belge b "
                + "  where p.kaynak_tur = 1 and b.id = p.kaynak_id), "
                + "(select b.belge_no from public.muayene m "
                + "  join public.belge b on b.id = m.belge_id "
                + "  where p.kaynak_tur = 2 and m.id = p.kaynak_id), '')",
                                              "metin", "Protokol No",
                                              Hizalama: "orta", Genislik: 150),
            new("hastaAdi",  "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 200),
            new("hekimAdi",  "coalesce(k.ad, '')", "metin", "Hekim", Genislik: 170,
                                              Varsayilan: false),
            new("olayTarihi","p.olay_tarihi", "tarih", "Olay", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("durumAdi",
                """
                case p.durum
                     when 0 then 'Eksik Alan' when 1 then 'Bekliyor'
                     when 2 then 'Gönderiliyor' when 3 then 'Gönderildi'
                     when 4 then 'Hatalı' when 5 then 'İptal' when 6 then 'Silindi'
                     else 'Bilinmiyor' end
                """,                          "metin", "Durum", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 120,
                                              Filtrelenebilir: false),
            new("durum",     "p.durum",       "kod",   "Durum Kodu", Varsayilan: false),
            // Eksik alan sayisi: "neyi duzeltmem lazim" sorusunun ilk cevabi.
            new("eksikAlan",
                "(select count(*) from public.enabiz_paket_alan a "
                + "where a.paket_id = p.id and a.gecerli = 0)",
                                              "sayi",  "Eksik", Hizalama: "orta",
                                              Genislik: 70),
            new("deneme",    "p.deneme",      "sayi",  "Deneme", Hizalama: "orta",
                                              Genislik: 80, Varsayilan: false),
            // SURE SINIRI: USS olaydan sonra belli sure icinde bildirim ister;
            //   gecikeni listede one cikarmak icin kalan saat hesaplanir.
            new("kalanSaat",
                "case when p.durum in (3, 5, 6) then null "
                + "else floor(extract(epoch from p.son_tarih - now()) / 3600)::int end",
                                              "sayi",  "Kalan (saat)", Hizalama: "sag",
                                              Genislik: 110),
            new("hataMesaj", "p.hata_mesaj",  "metin", "Hata", Genislik: 300,
                                              Varsayilan: false),
            new("ussPaketId","p.uss_paket_id","metin", "USS Kimlik", Genislik: 200,
                                              Varsayilan: false),
            new("kaynakTur", "p.kaynak_tur",  "sayi",  "Kaynak Tür", Varsayilan: false),
            new("kaynakId",  "p.kaynak_id",   "sayi",  "Kaynak Id", Varsayilan: false),
            new("belgeId",   "coalesce(p.belge_id, 0)", "sayi", "Başvuru Id",
                                              Varsayilan: false)
        });
}
