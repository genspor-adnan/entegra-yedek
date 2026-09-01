namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// RADYOLOJİ ÇALIŞMA LİSTESİ (283) - modülün giriş ekranı.
///
/// Satır = istem kaydı. Rapor yazma, PACS açma ve onay buradan başlar; bu
/// yüzden liste hem klinik (modalite, çekim, rapor durumu) hem idari
/// (ödeyen kurum, protokol no) bilgiyi tek satırda gösterir.
///
/// Kaynak DOĞRUDAN TABLO (view değil): görünüm kolonları filtrelenebilir
/// olmalı ve şube süzmesi SubeKolonu ile yapılıyor - v_radyoloji_worklist
/// raporlama/dış sorgu için duruyor.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// CİHAZLAR (283/315) - modalite cihazları ve randevu ayarları.
    ///
    /// Cihaz radyolojinin KAYNAĞIDIR: randevu ona verilir, MWL ona iner,
    /// çekim onda yapılır. Liste "bugün kaç iş, ne kadar dolu" sorusunu
    /// cevaplasın diye günün istem sayısını da taşır.
    /// </summary>
    private static KaynakTanimi RadyolojiCihaz() => new(
        Ad: "radyoloji-cihaz",
        YetkiKodu: "radyoloji",
        Kaynak: "public.radyoloji_cihaz c " +
                "left join public.taraf s on s.id = c.sorumlu_id",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.modalite, c.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "c.id",    "sayi",  "Id", Varsayilan: false),
            new("kod",      "c.kod",   "metin", "Kod", Genislik: 110),
            new("ad",       "c.ad",    "metin", "Cihaz", Genislik: 260),
            new("modaliteAdi",
                "case c.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' " +
                "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' " +
                "when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                                       "metin", "Modalite", Hizalama: "orta",
                                       Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("modalite", "c.modalite", "kod", "Modalite Kodu", Varsayilan: false),
            new("aeTitle",  "c.ae_title", "metin", "AE Title", Genislik: 130),
            new("oda",      "c.oda",   "metin", "Oda", Genislik: 150),
            new("sorumlu",  "coalesce(s.unvan, '')", "metin", "Sorumlu", Genislik: 160),
            // Mesai iki kolon yerine TEK okunur metin: listede "08:00-18:00"
            //   bir bakışta anlaşılır, iki ayrı kolon yer harcardı.
            new("mesai",
                "case when c.randevu_verilir = 1 and c.baslangic_saat <> '' " +
                "     then c.baslangic_saat || '-' || c.bitis_saat else '' end",
                                       "metin", "Mesai", Hizalama: "orta", Genislik: 110,
                                       Filtrelenebilir: false),
            new("slotDk",   "c.slot_dk", "sayi", "Slot (dk)", Hizalama: "sag", Genislik: 90),
            new("randevuVerilir", "c.randevu_verilir", "mantik", "Randevu", Hizalama: "orta",
                Genislik: 90),
            // BUGUNKU IS: cihazin doluluk hissini veren tek sayi.
            new("bugun",
                "(select count(*) from public.radyoloji_istem i " +
                " where i.cihaz_id = c.id and i.durum > 0 " +
                "   and coalesce(i.cekim_tarihi, i.ekleme_tarihi)::date = current_date)",
                                       "sayi",  "Bugün", Hizalama: "sag", Genislik: 80,
                                       Filtrelenebilir: false),
            new("durum",    "c.durum", "kod",   "Durum", Hizalama: "orta"),
            new("subeId",   "c.sube_id", "sayi", "Şube", Varsayilan: false),
        });

    /// <summary>
    /// ÇEKİM PROTOKOLÜ (283/314) - tetkikin NASIL çekileceği.
    ///
    /// Süre randevu kapasitesini, hazırlık metni hastaya verilen talimatı,
    /// özel uyarı da kabul masasının sorması gerekeni besler. Protokolü olmayan
    /// tetkikte modalite varsayılanı (311) kullanılır - liste bunu "modaliteden"
    /// diye gösterir ki eksik protokol görünür olsun.
    /// </summary>
    private static KaynakTanimi RadyolojiProtokol() => new(
        Ad: "radyoloji-protokol",
        YetkiKodu: "radyoloji",
        Kaynak: "public.radyoloji_protokol p " +
                "join public.hizmet hz on hz.id = p.hizmet_id",
        SubeKolonu: null,
        VarsayilanSirala: "hz.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "p.id",        "sayi",  "Id", Varsayilan: false),
            new("hizmetId",   "p.hizmet_id", "sayi",  "Tetkik Id", Varsayilan: false),
            new("tetkikKodu", "coalesce(hz.kod, '')", "metin", "Kod", Genislik: 110),
            new("tetkikAdi",  "coalesce(hz.ad, '')",  "metin", "Tetkik", Genislik: 280),
            new("modaliteAdi",
                "case coalesce(p.modalite, hz.modalite) when 1 then 'BT' when 2 then 'MR' " +
                "when 3 then 'USG' when 4 then 'Röntgen' when 5 then 'Mamografi' " +
                "when 6 then 'DEXA' when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                                             "metin", "Modalite", Hizalama: "orta",
                                             Bicim: "rozet", Genislik: 100, Filtrelenebilir: false),
            new("modalite",   "coalesce(p.modalite, hz.modalite)", "kod", "Modalite Kodu",
                Varsayilan: false),
            new("sureDk",     "p.sure_dk",   "sayi",  "Süre (dk)", Hizalama: "sag", Genislik: 90),
            new("kontrast",   "p.kontrast",  "kod",   "Kontrast", Hizalama: "orta", Genislik: 110),
            // Metnin KENDISI listede yer kaplar; "var mı" sorusu yeter - eksik
            //   protokol tek bakista gorunur.
            new("hazirlikVar",
                "case when coalesce(p.hazirlik_metni, '') <> '' then 1 else 0 end",
                                             "mantik", "Hazırlık", Hizalama: "orta", Genislik: 90),
            new("uyariVar",
                "case when coalesce(p.ozel_uyari, '') <> '' then 1 else 0 end",
                                             "mantik", "Uyarı", Hizalama: "orta", Genislik: 80),
            new("hazirlikMetni", "coalesce(p.hazirlik_metni, '')", "metin", "Hazırlık Talimatı",
                Varsayilan: false),
            new("ozelUyari",  "coalesce(p.ozel_uyari, '')", "metin", "Özel Uyarı", Varsayilan: false),
            new("seriTarifi", "coalesce(p.seri_tarifi, '')", "metin", "Seri / Pozisyon",
                Genislik: 260),
        });

    private static KaynakTanimi RadyolojiIstem() => new(
        Ad: "radyoloji-istem",
        YetkiKodu: "radyoloji",
        Kaynak: "public.radyoloji_istem i " +
                "left join public.taraf  h  on h.id  = i.hasta_id " +
                "left join public.hizmet hz on hz.id = i.hizmet_id " +
                "left join public.taraf  ih on ih.id = i.istek_hekim_id " +
                "left join public.taraf  ik on ik.id = i.istek_kurum_id " +
                "left join public.belge  b  on b.id  = i.belge_id " +
                "left join public.belge_basvuru bb on bb.id = b.id " +
                "left join public.taraf  ok on ok.id = bb.odeyen_kurum_id " +
                "left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id " +
                "left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null " +
                "left join public.taraf  ry on ry.id = coalesce(r.onaylayan_id, r.yazan_id)",
        SubeKolonu: "i.sube_id",
        // ACİL en üstte, sonra en eski bekleyen: liste açılınca "önce neye
        //   bakmalıyım" sorusu sıralamayla cevaplanır.
        VarsayilanSirala: "i.oncelik desc, coalesce(i.cekim_tarihi, i.ekleme_tarihi) asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "i.id",              "sayi",  "Id",            Varsayilan: false),
            new("saat",          "coalesce(i.cekim_tarihi, i.ekleme_tarihi)",
                                                      "tarih", "Saat",          Hizalama: "orta",
                                                                                Bicim: "dd.MM.yyyy HH:mm",
                                                                                Genislik: 130),
            new("modaliteAdi",
                "case i.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' " +
                "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' " +
                "when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                                                      "metin", "Mod.",          Hizalama: "orta",
                                                                                Bicim: "rozet", Genislik: 80,
                                                                                Filtrelenebilir: false),
            new("modalite",      "i.modalite",        "kod",   "Modalite Kodu", Varsayilan: false),
            new("accessionNo",   "i.accession_no",    "metin", "Accession",     Genislik: 150),
            new("hastaAdi",      "coalesce(h.unvan, '')", "metin", "Hasta",     Genislik: 190),
            new("tetkikKodu",    "coalesce(hz.kod, '')",  "metin", "Tetkik Kodu", Varsayilan: false),
            new("tetkikAdi",     "coalesce(hz.ad, '')",   "metin", "Tetkik",    Genislik: 230),
            // İsteyen: iç hekim kayıtlıysa adı, değilse dış hekim serbest alanı.
            new("isteyen",
                "coalesce(nullif(ih.unvan, ''), nullif(i.dis_hekim_ad, ''), '')",
                                                      "metin", "İstem Yapan",   Genislik: 170,
                                                                                Filtrelenebilir: false),
            // Ham hekim id (305): dis hekim kartinin "Gönderim Geçmişi" gridi
            //   bu kolonla suzuluyor - gridde gizli.
            new("istekHekimId",  "i.istek_hekim_id", "sayi", "İstem Hekim Id",
                Varsayilan: false),
            new("isteyenKurum",  "coalesce(ik.unvan, '')", "metin", "İsteyen Kurum",
                                                                                Genislik: 160, Varsayilan: false),
            new("odeyenKurum",   "coalesce(ok.unvan, '')", "metin", "Ödeyen Kurum",
                                                                                Genislik: 170,
                                                                                Filtrelenebilir: false),
            new("oncelikAdi",
                "case i.oncelik when 2 then 'ACİL' else 'Normal' end",
                                                      "metin", "Öncelik",       Hizalama: "orta",
                                                                                Bicim: "rozet", Genislik: 85,
                                                                                Filtrelenebilir: false),
            new("oncelik",       "i.oncelik",         "kod",   "Öncelik Kodu",  Varsayilan: false),
            new("durumAdi",
                "case i.durum when 0 then 'İptal' when 1 then 'Bekliyor' " +
                "when 2 then 'Çekildi' when 3 then 'Raporlanıyor' when 4 then 'Ön Rapor' " +
                "when 5 then 'Onaylandı' when 6 then 'Teslim Edildi' else '' end",
                                                      "metin", "Durum",         Hizalama: "orta",
                                                                                Bicim: "rozet", Genislik: 110,
                                                                                Filtrelenebilir: false),
            new("durum",         "i.durum",           "kod",   "Durum Kodu",    Varsayilan: false),
            new("raporlayan",    "coalesce(ry.unvan, '')", "metin", "Radyolog", Genislik: 160,
                                                                                Filtrelenebilir: false),
            // Bekleme süresi kalite göstergesidir: acil bir tetkik ne kadar
            //   beklemiş, ekranı açan hemen görmeli.
            new("beklemeDk",
                "round(extract(epoch from (now()::timestamp " +
                "  - coalesce(i.cekim_tarihi, i.ekleme_tarihi))) / 60)::integer",
                                                      "sayi",  "Bekleme (dk)",  Hizalama: "sag",
                                                                                Genislik: 110,
                                                                                Filtrelenebilir: false),
            new("cihazAdi",      "coalesce(cz.ad, '')", "metin", "Cihaz",       Genislik: 150, Varsayilan: false),
            new("belgeNo",       "coalesce(b.belge_no, '')", "metin", "Protokol", Genislik: 120, Varsayilan: false),
            new("onTani",        "i.on_tani",         "metin", "Ön Tanı",       Genislik: 100, Varsayilan: false),
            new("studyUid",      "i.study_uid",       "metin", "Study UID",     Varsayilan: false),
            new("kritik",        "i.kritik",          "mantik","Kritik",        Hizalama: "orta",
                                                                                Varsayilan: false),
            new("hastaId",       "i.hasta_id",        "sayi",  "Hasta Id",      Varsayilan: false),
            new("belgeId",       "i.belge_id",        "sayi",  "Belge Id",      Varsayilan: false),
            new("raporId",       "r.id",              "sayi",  "Rapor Id",      Varsayilan: false),
            new("raporDurum",    "coalesce(r.durum, 0)", "kod", "Rapor Durum Kodu", Varsayilan: false),
        });

    // ------------------------------------------------- radyoloji-sablon ----
    /// <summary>
    /// Rapor sablonlari listesi (283). "Kullanim" sayaci hangi sablonun
    /// gercekten ise yaradigini gosterir; kullanilmayan sablon pasife cekilir.
    /// </summary>
    private static KaynakTanimi RadyolojiSablon() => new(
        Ad: "radyoloji-sablon",
        YetkiKodu: "radyoloji",
        Kaynak: "public.radyoloji_sablon s " +
                "left join public.hizmet hz on hz.id = s.hizmet_id",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "s.modalite, s.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "s.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",        "s.kod",  "metin", "Kod", Genislik: 120),
            new("modaliteAdi",
                "case s.modalite when 1 then \'BT\' when 2 then \'MR\' when 3 then \'USG\' " +
                "when 4 then \'Röntgen\' when 5 then \'Mamografi\' when 6 then \'DEXA\' " +
                "when 7 then \'Anjiyo\' when 8 then \'Skopi\' else \'\' end",
                                        "metin", "Mod.", Hizalama: "orta", Bicim: "rozet",
                                                 Genislik: 80, Filtrelenebilir: false),
            new("modalite",   "s.modalite", "kod", "Modalite Kodu", Varsayilan: false),
            new("ad",         "s.ad",   "metin", "Sablon Adi", Genislik: 240),
            new("tetkik",
                "coalesce(nullif(hz.kod, \'\') || \' · \', \'\') || coalesce(hz.ad, \'\')",
                                        "metin", "Bagli Tetkik", Genislik: 240,
                                                 Filtrelenebilir: false),
            new("bolum",      "s.bolum", "metin", "Bolum", Genislik: 130),
            new("bolumSayisi",
                "(select count(*) from public.radyoloji_sablon_bolum b where b.sablon_id = s.id)",
                                        "sayi",  "Bolum", Hizalama: "sag", Genislik: 80,
                                                 Filtrelenebilir: false),
            new("kullanim",   "s.kullanim", "sayi", "Kullanim", Hizalama: "sag", Genislik: 90),
            new("varsayilan", "s.varsayilan", "mantik", "Varsayilan", Hizalama: "orta"),
            new("durum",      "s.durum", "mantik", "Aktif", Hizalama: "orta"),
        });
}
