namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// GENETİK LİSTELERİ (439) — vaka çalışma alanı, varyantlar, run'lar,
/// gen ve panel katalogları.
///
/// Mockup: Ekranlar/Lab/lab_genetik.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// GENETİK VAKA LİSTESİ — laboratuvarın günlük ekranı.
    ///
    /// <b>Onam kolonu ilk sıralarda</b>: onamı eksik vaka çalışılabilir ama
    /// RAPORLANAMAZ (KVKK md. 6). Eksikliğin analiz bittikten sonra fark
    /// edilmesi, haftalarca süren işin rapor aşamasında beklemesi demektir.
    /// </summary>
    private static KaynakTanimi LabGenetikVaka() => new(
        Ad: "lab-genetik-vaka",
        YetkiKodu: "lab.genetik",
        Kaynak: "public.lab_genetik_vaka g "
              + "  join public.taraf h on h.id = g.hasta_id "
              + "  join public.lab_tetkik t on t.id = g.tetkik_id "
              + "  left join public.lab_genetik_panel p on p.id = g.panel_id "
              + "  left join public.lab_genetik_run r on r.id = g.run_id "
              + "  left join public.lab_numune n on n.id = g.numune_id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.ekleme_tarihi desc, g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "g.id", "sayi", "Id", Varsayilan: false),
            new("vakaNo", "g.vaka_no", "metin", "Vaka No", Hizalama: "orta",
                                 Genislik: 140),
            new("hastaAdi",
                "coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan)",
                                 "metin", "Hasta", Genislik: 200),
            new("endikasyon", "g.endikasyon", "metin", "Endikasyon", Genislik: 260),
            new("taniIcd", "g.tani_icd", "metin", "ICD", Hizalama: "orta", Genislik: 80),
            new("testAdi", "coalesce(nullif(p.ad, ''), t.ad)", "metin", "Test / Panel",
                                 Genislik: 220),
            // ONAM: 0 belirtilmedi (eksik!) · 1 istiyor · 2 istemiyor.
            new("onamAdi",
                "case g.tesadufi_bulgu when 1 then 'Onam ✔ · tesadüfi: istiyor' "
                + "when 2 then 'Onam ✔ · tesadüfi: istemiyor' else 'ONAM EKSİK' end",
                                 "metin", "Onam", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 210, Filtrelenebilir: false),
            new("tesadufiBulgu", "g.tesadufi_bulgu", "kod", "Onam Kodu",
                                 Varsayilan: false),
            new("barkod", "coalesce(n.barkod, '')", "metin", "Numune", Hizalama: "orta",
                                 Genislik: 130),
            // DNA metrikleri: düşük saflık yanlış negatif üretir, listede görünmeli.
            new("dna",
                "case when g.dna_konsantrasyon is null then '' "
                + "else trim(to_char(g.dna_konsantrasyon, 'FM9990D99')) || ' ng/µL · ' "
                + "     || trim(to_char(g.dna_saflik, 'FM90D999')) end",
                                 "metin", "DNA (ng/µL · 260/280)", Hizalama: "orta",
                                 Genislik: 170, Filtrelenebilir: false),
            new("runKodu", "coalesce(r.kod, '')", "metin", "Run", Hizalama: "orta",
                                 Genislik: 110),
            new("kapsamaYuzde", "g.kapsama_yuzde", "sayi", "Kapsama %", Hizalama: "sag",
                                 Bicim: "#,##0.0", Genislik: 100),
            // RAPORLANAN varyant sayısı: toplam varyant değil - hekimi
            //   ilgilendiren, filtreden geçip rapora girecek olandır.
            new("varyantSayisi",
                "(select count(*) from public.lab_varyant v "
                + "  where v.vaka_id = g.id and v.raporla = 1)",
                                 "sayi", "Varyant", Hizalama: "orta", Genislik: 90,
                                 Filtrelenebilir: false),
            new("patojenikSayisi",
                "(select count(*) from public.lab_varyant v "
                + "  where v.vaka_id = g.id and v.raporla = 1 and v.sinif >= 4)",
                                 "sayi", "P/LP", Hizalama: "orta", Genislik: 70,
                                 Filtrelenebilir: false),
            new("sonucOzeti", "public.fn_lab_genetik_ozet(g.id)", "metin", "Sonuç",
                                 Genislik: 320, Filtrelenebilir: false,
                                 Siralanabilir: false),
            new("tatGun",
                "case when g.hedef_bitis is null then null "
                + "else ceil(extract(epoch from (g.hedef_bitis - now())) / 86400)::int end",
                                 "sayi", "Kalan (gün)", Hizalama: "sag", Genislik: 100,
                                 Filtrelenebilir: false),
            new("durumAdi",
                "case g.durum when 0 then 'İptal' when 1 then 'Numune' "
                + "when 2 then 'İzolasyon' when 3 then 'Run''da' when 4 then 'Analiz' "
                + "when 5 then 'Doğrulama' when 6 then 'Rapor bekliyor' "
                + "else 'Onaylı' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("durum", "g.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("uzmanYorum", "g.uzman_yorum", "metin", "Uzman Yorumu", Genislik: 300,
                                 Varsayilan: false),
            new("istemId", "g.istem_id", "sayi", "İstem Id", Varsayilan: false),
            new("istemSatirId", "g.istem_satir_id", "sayi", "Satır Id",
                                 Varsayilan: false),
            new("hastaId", "g.hasta_id", "sayi", "Hasta Id", Varsayilan: false),
        });

    /// <summary>
    /// VARYANT LİSTESİ — laboratuvarın varyant havuzu. ACMG kanıtları ve
    /// sınıf birlikte durur: "neden patojenik" sorusu listeden cevaplanır.
    /// </summary>
    private static KaynakTanimi LabVaryant() => new(
        Ad: "lab-varyant",
        YetkiKodu: "lab.genetik",
        Kaynak: "public.lab_varyant v "
              + "  join public.lab_genetik_vaka g on g.id = v.vaka_id "
              + "  join public.taraf h on h.id = g.hasta_id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "v.sinif desc, v.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "v.id", "sayi", "Id", Varsayilan: false),
            new("vakaNo", "g.vaka_no", "metin", "Vaka", Hizalama: "orta", Genislik: 130),
            new("hastaAdi",
                "coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan)",
                                 "metin", "Hasta", Genislik: 180),
            new("genSembol", "v.gen_sembol", "metin", "Gen", Hizalama: "orta",
                                 Genislik: 100),
            new("hgvsC", "v.hgvs_c", "metin", "HGVS c.", Genislik: 190),
            new("hgvsP", "v.hgvs_p", "metin", "HGVS p.", Genislik: 170),
            new("zigositeAdi",
                "case v.zigosite when 2 then 'Homozigot' when 3 then 'Hemizigot' "
                + "when 4 then 'Mozaik' else 'Heterozigot' end",
                                 "metin", "Zigosite", Hizalama: "orta", Genislik: 120,
                                 Filtrelenebilir: false),
            new("vaf", "v.vaf", "sayi", "VAF", Hizalama: "sag", Bicim: "#,##0.00",
                                 Genislik: 80),
            new("derinlik", "v.derinlik", "sayi", "Derinlik", Hizalama: "sag",
                                 Genislik: 90),
            new("gnomadAf", "v.gnomad_af", "sayi", "gnomAD AF", Hizalama: "sag",
                                 Bicim: "#,##0.00000", Genislik: 110),
            new("clinvar", "v.clinvar", "metin", "ClinVar", Hizalama: "orta",
                                 Genislik: 150),
            new("acmg", "array_to_string(v.acmg_kriterler, ' · ')", "metin",
                                 "ACMG Kanıtları", Genislik: 240,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("sinifAdi",
                "case v.sinif when 1 then 'Benign' when 2 then 'Olası benign' "
                + "when 4 then 'Olası patojenik' when 5 then 'Patojenik' "
                + "else 'VUS' end",
                                 "metin", "Sınıf", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("sinif", "v.sinif", "kod", "Sınıf Kodu", Varsayilan: false),
            new("sinifElle", "v.sinif_elle", "mantik", "Uzman Kararı", Hizalama: "orta",
                                 Genislik: 110, Varsayilan: false),
            new("raporla", "v.raporla", "mantik", "Raporda", Hizalama: "orta",
                                 Genislik: 90),
            new("dogrulamaAdi",
                "case v.dogrulama when 1 then 'İstendi' when 2 then 'Doğrulandı' "
                + "when 3 then 'Doğrulanamadı' else '—' end",
                                 "metin", "Doğrulama", Hizalama: "orta", Genislik: 120,
                                 Filtrelenebilir: false),
            new("ikincilBulgu", "v.ikincil_bulgu", "mantik", "İkincil Bulgu",
                                 Hizalama: "orta", Genislik: 110, Varsayilan: false),
            new("yorum", "v.yorum", "metin", "Yorum", Genislik: 300, Varsayilan: false),
            new("vakaId", "v.vaka_id", "sayi", "Vaka Id", Varsayilan: false),
        });

    /// <summary>DİZİLEME RUN'LARI — kalite metrikleri ve kontroller.</summary>
    private static KaynakTanimi LabGenetikRun() => new(
        Ad: "lab-genetik-run",
        YetkiKodu: "lab.genetik",
        Kaynak: "public.lab_genetik_run r",
        SubeKolonu: "r.sube_id",
        VarsayilanSirala: "r.tarih desc, r.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "r.id", "sayi", "Id", Varsayilan: false),
            new("kod", "r.kod", "metin", "Run", Hizalama: "orta", Genislik: 120),
            new("cihazAdi", "r.cihaz_adi", "metin", "Cihaz", Genislik: 160),
            new("tarih", "r.tarih", "tarih", "Tarih", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("kit", "r.kit", "metin", "Kit / Panel", Genislik: 200),
            new("kitLot", "r.kit_lot", "metin", "Kit Lot", Hizalama: "orta",
                                 Genislik: 110, Varsayilan: false),
            new("ornekSayisi", "r.ornek_sayisi", "sayi", "Örnek", Hizalama: "orta",
                                 Genislik: 70),
            new("q30", "r.q30", "sayi", "Q30 %", Hizalama: "sag", Bicim: "#,##0.0",
                                 Genislik: 80),
            new("ortDerinlik", "r.ort_derinlik", "sayi", "Ort. Derinlik",
                                 Hizalama: "sag", Bicim: "#,##0", Genislik: 110),
            // KONTROLLER: pozitif kontrol tutmayan dizilemede hastanın
            //   negatif sonucu da güvenilmezdir - run raporlanamaz.
            new("kontrolAdi",
                "case when r.pozitif_kontrol = 1 and r.negatif_kontrol = 1 "
                + "     then 'PK ✔ NK ✔' "
                + "when r.pozitif_kontrol = 2 or r.negatif_kontrol = 2 "
                + "     then 'KONTROL KALDI' else 'Bekliyor' end",
                                 "metin", "Kontroller", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("durumAdi",
                "case r.durum when 0 then 'İptal' when 1 then 'Hazırlanıyor' "
                + "when 2 then 'Dizilemede' when 3 then 'Analizde' "
                + "else 'Tamamlandı' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false),
            new("durum", "r.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("pipeline", "r.pipeline", "metin", "Pipeline", Genislik: 260,
                                 Varsayilan: false),
            new("referansGenom", "r.referans_genom", "metin", "Referans Genom",
                                 Hizalama: "orta", Genislik: 120, Varsayilan: false),
        });

    private static KaynakTanimi LabGen() => new(
        Ad: "lab-gen",
        YetkiKodu: "lab.gen",
        Kaynak: "public.lab_gen g",
        SubeKolonu: null,
        VarsayilanSirala: "g.sembol asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "g.id", "sayi", "Id", Varsayilan: false),
            new("sembol", "g.sembol", "metin", "Gen", Hizalama: "orta", Genislik: 110),
            new("ad", "g.ad", "metin", "Adı", Genislik: 260),
            // TRANSKRİPT ZORUNLU: HGVS gösterimi transkripte göredir.
            new("transkript", "g.transkript", "metin", "Transkript", Hizalama: "orta",
                                 Genislik: 150),
            new("kalitimAdi",
                "case g.kalitim when 2 then 'Otozomal resesif' "
                + "when 3 then 'X''e bağlı' when 4 then 'Mitokondriyal' "
                + "when 9 then 'Diğer' else 'Otozomal dominant' end",
                                 "metin", "Kalıtım", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 160, Filtrelenebilir: false),
            new("hastalik", "g.hastalik", "metin", "İlişkili Hastalık", Genislik: 260),
            new("omim", "g.omim", "metin", "OMIM", Hizalama: "orta", Genislik: 90,
                                 Varsayilan: false),
            new("panelSayisi",
                "(select count(*) from public.lab_genetik_panel_gen x "
                + "  where x.gen_id = g.id)",
                                 "sayi", "Panel", Hizalama: "orta", Genislik: 70,
                                 Filtrelenebilir: false),
            new("durumAdi", "case g.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "g.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    private static KaynakTanimi LabGenetikPanel() => new(
        Ad: "lab-genetik-panel",
        YetkiKodu: "lab.gen",
        Kaynak: "public.lab_genetik_panel p",
        SubeKolonu: null,
        VarsayilanSirala: "p.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "p.id", "sayi", "Id", Varsayilan: false),
            new("kod", "p.kod", "metin", "Kod", Genislik: 140),
            new("ad", "p.ad", "metin", "Panel", Genislik: 280),
            new("yontemAdi",
                "case p.yontem when 2 then 'WES' when 3 then 'WGS' "
                + "when 4 then 'PCR / RT-PCR' when 5 then 'Sanger' "
                + "when 6 then 'Karyotip' when 7 then 'MLPA' "
                + "when 8 then 'Mikroarray' else 'NGS panel' end",
                                 "metin", "Yöntem", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("kaynakTipiAdi",
                "case p.kaynak_tipi when 2 then 'Somatik' else 'Germline' end",
                                 "metin", "Kaynak", Hizalama: "orta", Genislik: 100,
                                 Filtrelenebilir: false),
            new("genSayisi",
                "(select count(*) from public.lab_genetik_panel_gen x "
                + "  where x.panel_id = p.id)",
                                 "sayi", "Gen", Hizalama: "orta", Genislik: 70,
                                 Filtrelenebilir: false),
            new("hedefTatGun", "p.hedef_tat_gun", "sayi", "TAT (gün)", Hizalama: "sag",
                                 Genislik: 90),
            new("referansGenom", "p.referans_genom", "metin", "Referans Genom",
                                 Hizalama: "orta", Genislik: 130),
            new("pipeline", "p.pipeline", "metin", "Pipeline", Genislik: 280,
                                 Varsayilan: false),
            new("durumAdi", "case p.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "p.durum", "kod", "Durum Kodu", Varsayilan: false),
        });
}
