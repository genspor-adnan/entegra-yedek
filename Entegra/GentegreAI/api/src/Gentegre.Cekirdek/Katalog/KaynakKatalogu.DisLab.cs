namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DIŞ LABORATUVAR LİSTELERİ (445) — gönderimler, dış lab tanımları,
/// test eşlemesi.
///
/// Mockup: lab_sureci.html §10, lab_istem_numune_kabul.html ("Dış Lab'a Gönder").
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// GÖNDERİM LİSTESİ — numune binadan çıktıktan sonraki tek iz.
    ///
    /// <b>Gecikme kolonu bilinçli</b>: hastanın sonucu başka bir binada
    /// bekliyor; sözleşme TAT'ı aşıldığında aranacak yer dış laboratuvardır
    /// ve bunu kimse elle takip edemez.
    /// </summary>
    private static KaynakTanimi LabDisGonderim() => new(
        Ad: "lab-dis-gonderim",
        YetkiKodu: "lab.dislab",
        Kaynak: "public.lab_dis_gonderim g "
              + "  join public.lab_dis_lab d on d.id = g.dis_lab_id "
              + "  left join public.belge b on b.id = g.fatura_belge_id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.gonderim_zamani desc, g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "g.id", "sayi", "Id", Varsayilan: false),
            new("gonderimNo", "g.gonderim_no", "metin", "Gönderim No", Hizalama: "orta",
                                 Genislik: 140),
            new("disLab", "d.kod || ' · ' || d.ad", "metin", "Dış Laboratuvar",
                                 Genislik: 240),
            new("gonderimZamani", "g.gonderim_zamani", "tarih", "Gönderim",
                                 Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm",
                                 Genislik: 130),
            new("tetkikSayisi",
                "(select count(*) from public.lab_dis_gonderim_satir s "
                + "where s.gonderim_id = g.id)",
                                 "sayi", "Tetkik", Hizalama: "orta", Genislik: 70,
                                 Filtrelenebilir: false),
            new("bekleyen",
                "(select count(*) from public.lab_dis_gonderim_satir s "
                + "where s.gonderim_id = g.id and s.durum = 1)",
                                 "sayi", "Bekleyen", Hizalama: "orta", Genislik: 90,
                                 Filtrelenebilir: false),
            // GECİKME: sözleşme TAT'ı aşıldıysa pozitif. Negatif = süre var.
            //   Ham sayı ("-3") ekranda okunmuyordu; sıralama ve süzgeç için
            //   kolon duruyor ama gridde METİN gösterilir.
            new("gecikmeGun",
                "(current_date - g.gonderim_zamani::date) - d.sozlesme_tat_gun",
                                 "sayi", "Gecikme (gün)", Hizalama: "sag", Genislik: 110,
                                 Filtrelenebilir: false, Varsayilan: false),
            new("sureDurum",
                "case when g.durum >= 5 then 'Tamamlandı' "
                + "when (current_date - g.gonderim_zamani::date) - d.sozlesme_tat_gun > 0 "
                + "then ((current_date - g.gonderim_zamani::date) "
                + "      - d.sozlesme_tat_gun)::text || ' gün GECİKTİ' "
                + "when (current_date - g.gonderim_zamani::date) - d.sozlesme_tat_gun = 0 "
                + "then 'bugün dolacak' "
                + "else (d.sozlesme_tat_gun - (current_date - g.gonderim_zamani::date))::text "
                + "     || ' gün var' end",
                                 "metin", "Süre", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false,
                                 Siralanabilir: false),
            new("tasimaAdi",
                "case g.tasima_kosulu when 2 then 'Soğuk (2-8 °C)' "
                + "when 3 then 'Dondurulmuş (-20)' when 4 then 'Kuru buz (-70)' "
                + "else 'Oda sıcaklığı' end",
                                 "metin", "Taşıma", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 150, Filtrelenebilir: false),
            new("tasimaKosulu", "g.tasima_kosulu", "kod", "Taşıma Kodu",
                                 Varsayilan: false),
            new("kurye",
                "trim(coalesce(g.kurye_firma, '') || ' ' || coalesce(g.kurye_ad, ''))",
                                 "metin", "Kurye", Genislik: 180),
            new("teslimZamani", "g.teslim_zamani", "tarih", "Teslim", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("disKabulNo", "g.dis_kabul_no", "metin", "Dış Kabul No",
                                 Hizalama: "orta", Genislik: 120),
            new("durumAdi",
                "case g.durum when 0 then 'İptal' when 1 then 'Hazırlanıyor' "
                + "when 2 then 'Yolda' when 3 then 'Teslim edildi' "
                + "when 4 then 'Kısmi sonuç' else 'Sonuçlandı' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("durum", "g.durum", "kod", "Durum Kodu", Varsayilan: false),
            // FATURA EŞLEŞMESİ: dış lab satın alınan bir hizmet; eşleşmezse
            //   "kime ne ödedik" cevapsız kalır.
            new("faturaNo", "coalesce(b.belge_no, '')", "metin", "Alış Faturası",
                                 Hizalama: "orta", Genislik: 140),
            new("tutar", "g.tutar", "para", "Tutar", Hizalama: "sag",
                                 Bicim: "#,##0.00", Genislik: 110),
            new("aciklama", "g.aciklama", "metin", "Açıklama", Genislik: 260,
                                 Varsayilan: false),
            new("disLabId", "g.dis_lab_id", "sayi", "Dış Lab Id", Varsayilan: false),
        });

    private static KaynakTanimi LabDisLab() => new(
        Ad: "lab-dis-lab",
        YetkiKodu: "lab.dislab",
        Kaynak: "public.lab_dis_lab d join public.taraf t on t.id = d.taraf_id",
        SubeKolonu: null,
        VarsayilanSirala: "d.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "d.id", "sayi", "Id", Varsayilan: false),
            new("kod", "d.kod", "metin", "Kod", Hizalama: "orta", Genislik: 110),
            new("ad", "d.ad", "metin", "Dış Laboratuvar", Genislik: 260),
            new("cari", "t.unvan", "metin", "Cari (tedarikçi)", Genislik: 240),
            new("sonucKanaliAdi",
                "case d.sonuc_kanali when 2 then 'HL7' when 3 then 'Portal' "
                + "when 4 then 'Elden' else 'PDF / e-posta' end",
                                 "metin", "Sonuç Kanalı", Hizalama: "orta",
                                 Bicim: "rozet", Genislik: 140, Filtrelenebilir: false),
            new("sonucKanali", "d.sonuc_kanali", "kod", "Kanal Kodu", Varsayilan: false),
            new("sozlesmeTatGun", "d.sozlesme_tat_gun", "sayi", "Sözleşme TAT (gün)",
                                 Hizalama: "sag", Genislik: 140),
            new("kuryeFirma", "d.kurye_firma", "metin", "Kurye Firması", Genislik: 180),
            new("yetkili", "d.yetkili", "metin", "Yetkili", Genislik: 160,
                                 Varsayilan: false),
            new("telefon", "d.telefon", "metin", "Telefon", Hizalama: "orta",
                                 Genislik: 120),
            new("testSayisi",
                "(select count(*) from public.lab_dis_test x "
                + "where x.dis_lab_id = d.id and x.durum = 0)",
                                 "sayi", "Anlaşmalı Test", Hizalama: "orta",
                                 Genislik: 120, Filtrelenebilir: false),
            new("durumAdi", "case d.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "d.durum", "kod", "Durum Kodu", Varsayilan: false),
        });
}
