namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MUAYENE ve LABORATUVAR listeleri (360).
///
/// Ikisi de kayit kabul zincirinin devamidir: basvuru (belge 19 / tipi 30)
/// acilir, ucret girilir, sonra hekim MUAYENE yazar ya da LAB ISTEMI acilir.
/// O yuzden listeler hastayi, protokolu ve hekimi tek satirda gosterir -
/// "kimin, hangi basvurudan" sorusu listede cevaplanabilsin.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi Muayene() => new(
        Ad: "muayene",
        YetkiKodu: "muayene",
        Kaynak: "public.muayene m "
              + "  join public.taraf h on h.id = m.taraf_id "
              + "  left join public.belge b on b.id = m.belge_id "
              + "  left join public.v_personel_lookup p on p.id = m.personel_id "
              + "  left join public.v_departman_lookup d on d.id = m.bolum_id",
        SubeKolonu: "m.sube_id",
        VarsayilanSirala: "m.muayene_tarihi desc, m.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "m.id",             "sayi",  "Id", Varsayilan: false),
            new("muayeneNo",     "m.muayene_no",     "metin", "Muayene No", Hizalama: "orta",
                                                     Genislik: 120),
            new("muayeneTarihi", "m.muayene_tarihi", "tarih", "Tarih / Saat", Hizalama: "orta",
                                                     Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            // Protokol: muayene hangi basvurudan dogdu - kabul ile klinigin bagi.
            new("protokolNo",    "coalesce(b.belge_no, '')", "metin", "Protokol",
                                                     Hizalama: "orta", Genislik: 120),
            new("hastaAdi",      "h.unvan",          "metin", "Hasta", Genislik: 220),
            new("dosyaNo",       "h.kod",            "metin", "Dosya No", Hizalama: "orta",
                                                     Genislik: 110, Varsayilan: false),
            new("tcNo",          "coalesce(h.vkno, '')", "metin", "T.C. No", Hizalama: "orta",
                                                     Genislik: 110, Varsayilan: false),
            new("bolumAdi",      "coalesce(d.ad, '')", "metin", "Bölüm", Genislik: 150),
            new("hekimAdi",      "coalesce(p.ad, '')", "metin", "Hekim", Genislik: 180),
            new("turAdi",
                "case m.tur when 2 then 'Uzaktan' when 3 then 'Konsültasyon' "
                + "when 4 then 'Kontrol' else 'Yüz Yüze' end",
                                                     "metin", "Tür", Hizalama: "orta",
                                                     Bicim: "rozet", Genislik: 120,
                                                     Filtrelenebilir: false),
            new("tur",           "m.tur",            "kod",   "Tür Kodu", Varsayilan: false),
            // TANI ARTIK SATIRDA (409): listede ANA tanı gösterilir - hekim
            //   listeye "hangi hasta neyle geldi" diye bakar, tanı kümesine
            //   değil. Ek tanılar kartın Tanı sekmesinde.
            new("anaTani",
                "coalesce((select i.ad from public.tani t "
                + "join public.icd i on i.kod = t.icd_kod "
                + "where t.muayene_id = m.id and t.tur = 1 limit 1), '')",
                                                     "metin", "Ana Tanı", Genislik: 240),
            new("anaTaniKodu",
                "coalesce((select t.icd_kod from public.tani t "
                + "where t.muayene_id = m.id and t.tur = 1 limit 1), '')",
                                                     "metin", "ICD", Hizalama: "orta",
                                                     Genislik: 100, Varsayilan: false),
            new("taniSayisi",
                "(select count(*) from public.tani t where t.muayene_id = m.id)",
                                                     "sayi",  "Tanı", Hizalama: "orta",
                                                     Genislik: 70, Varsayilan: false),
            // Bekleyen istem: "sonuç bekliyor" durumunun görünür karşılığı.
            new("bekleyenIstem",
                "(select count(*) from public.muayene_istem s "
                + "where s.muayene_id = m.id and s.sonuc_durum in (0, 1))",
                                                     "sayi",  "Bekleyen İstem", Hizalama: "orta",
                                                     Genislik: 120, Varsayilan: false),
            new("durumAdi",
                "case m.durum when 0 then 'İptal' when 2 then 'Sonuç Bekliyor' "
                + "when 3 then 'Tamamlandı' when 4 then 'Ek Not' else 'Açık' end",
                                                     "metin", "Durum", Hizalama: "orta",
                                                     Bicim: "rozet", Genislik: 130,
                                                     Filtrelenebilir: false),
            new("durum",         "m.durum",          "kod",   "Durum Kodu", Varsayilan: false),
            new("tarafId",       "m.taraf_id",       "sayi",  "Hasta Id", Varsayilan: false),
            new("belgeId",       "m.belge_id",       "sayi",  "Başvuru Id", Varsayilan: false),
            new("baslangic",     "m.baslangic",      "tarih", "Muayeneye Alındı",
                                                     Hizalama: "orta", Bicim: "HH:mm",
                                                     Genislik: 110, Varsayilan: false),
            new("tamamlanma",    "m.tamamlanma",     "tarih", "Tamamlandı", Hizalama: "orta",
                                                     Bicim: "HH:mm", Genislik: 110,
                                                     Varsayilan: false)
        });

    private static KaynakTanimi LabIstem() => new(
        Ad: "lab-istem",
        YetkiKodu: "lab",
        Kaynak: "public.lab_istem i "
              + "  join public.taraf h on h.id = i.taraf_id "
              + "  left join public.belge b on b.id = i.belge_id "
              + "  left join public.v_personel_lookup p on p.id = i.personel_id",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.istem_tarihi desc, i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "i.id",           "sayi",  "Id", Varsayilan: false),
            new("istemNo",      "i.istem_no",     "metin", "İstem No", Hizalama: "orta",
                                                  Genislik: 120),
            new("istemTarihi",  "i.istem_tarihi", "tarih", "İstem Tarihi", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("protokolNo",   "coalesce(b.belge_no, '')", "metin", "Protokol",
                                                  Hizalama: "orta", Genislik: 120),
            new("hastaAdi",     "h.unvan",        "metin", "Hasta", Genislik: 220),
            new("dosyaNo",      "h.kod",          "metin", "Dosya No", Hizalama: "orta",
                                                  Genislik: 110, Varsayilan: false),
            new("bolumAdi",
                "case i.bolum when 2 then 'Mikrobiyoloji' when 3 then 'Genetik' "
                + "when 4 then 'Patoloji' when 9 then 'Diğer' else 'Biyokimya' end",
                                                  "metin", "Bölüm", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 130,
                                                  Filtrelenebilir: false),
            new("bolum",        "i.bolum",        "kod",   "Bölüm Kodu", Varsayilan: false),
            new("hekimAdi",     "coalesce(p.ad, '')", "metin", "İsteyen Hekim", Genislik: 180),
            // Kac test var / kaci sonuclandi: teknisyen listede "bitti mi" gorsun.
            new("testSayisi",
                "(select count(*) from public.lab_istem_test t where t.istem_id = i.id)",
                                                  "sayi",  "Test", Hizalama: "sag", Genislik: 70,
                                                  Filtrelenebilir: false),
            new("sonuclanan",
                "(select count(*) from public.lab_istem_test t "
                + " where t.istem_id = i.id and t.sonuc <> '')",
                                                  "sayi",  "Sonuçlanan", Hizalama: "sag",
                                                  Genislik: 100, Filtrelenebilir: false),
            new("durumAdi",
                "case i.durum when 2 then 'Numune Alındı' when 3 then 'Çalışılıyor' "
                + "when 4 then 'Sonuçlandı' when 5 then 'Onaylandı' when 9 then 'İptal' "
                + "else 'İstendi' end",
                                                  "metin", "Durum", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 130,
                                                  Filtrelenebilir: false),
            new("durum",        "i.durum",        "kod",   "Durum Kodu", Varsayilan: false),
            new("sonucTarihi",  "i.sonuc_tarihi", "tarih", "Sonuç", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                                  Varsayilan: false),
            new("tarafId",      "i.taraf_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("belgeId",      "i.belge_id",     "sayi",  "Başvuru Id", Varsayilan: false)
        });

    /// <summary>
    /// PRIM ROL ADAYLARI (361) - "kim hangi rolde prim alabilir".
    ///
    /// Isaret kisinin kartinda durur (taraf_prim_rol); burasi onu listeler.
    /// Yonetim ekraninda tum roller gorunur, basvuru combosu ise asagidaki
    /// BasvuruHekim kaynagini kullanir.
    /// </summary>
    private static KaynakTanimi PrimRolAday() => new(
        Ad: "prim-rol-aday",
        // YETKI "belge": basvuru karti da bu listeden hekim combosunu dolduruyor
        //   (364) - kayit kabul memurunda prim yetkisi olmak zorunda degil.
        //   Liste yalniz ad + rol tasir, prim TUTARI icermez.
        YetkiKodu: "belge",
        Kaynak: "public.v_prim_rol_aday a",
        SubeKolonu: null,
        VarsayilanSirala: "a.rol, a.ad",
        Kolonlar: PrimRolKolonlari());

    private static KolonTanimi[] PrimRolKolonlari() =>
    [
        new("id",         "a.id",         "sayi",  "Id", Varsayilan: false),
        new("ad",         "a.ad",         "metin", "Kişi", Genislik: 240),
        new("rol",        "a.rol",        "kod",   "Rol Kodu", Varsayilan: false),
        new("rolAdi",
            "case a.rol when 1 then 'Gönderen' when 2 then 'İsteyen' "
            + "when 3 then 'Uygulayan' when 4 then 'Yapan' when 5 then 'Raporlayan' "
            + "when 6 then 'Onaylayan' when 7 then 'Anestezi' when 8 then 'Asistan' "
            + "when 9 then 'Teknisyen' else '' end",
                                          "metin", "Prim Rolü", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 130,
                                          Filtrelenebilir: false),
        // Dis hekim YALNIZ Gonderen olabilir (361) - listede ayrimi gorunsun.
        new("disMi",      "a.dis_mi",     "mantik", "Dış Hekim", Hizalama: "orta",
                                          Genislik: 100),
        new("varsayilan", "a.varsayilan", "mantik", "Önerilen", Hizalama: "orta",
                                          Genislik: 100),
        new("bolumId",    "a.bolum_id",   "sayi",  "Bölüm Id", Varsayilan: false),
        new("durum",      "a.durum",      "kod",   "Durum", Hizalama: "orta", Varsayilan: false)
    ];
}
