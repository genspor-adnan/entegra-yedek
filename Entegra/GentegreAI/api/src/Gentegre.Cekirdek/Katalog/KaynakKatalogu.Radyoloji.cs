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
            // Randevu suresi (316): tetkikin cekim protokolu (314) - modal bunu
            //   onden doldurur, kullanici gerekirse ezer.
            new("protokolSure",
                "(select coalesce(p.sure_dk, 0) from public.radyoloji_protokol p " +
                " where p.hizmet_id = i.hizmet_id)",
                                                      "sayi", "Protokol Süre", Varsayilan: false),
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

    /// <summary>
    /// KRİTİK BULGU TAKİBİ (318) - hasta güvenliği listesi.
    ///
    /// Satır bildirim kaydı DEĞİL, kritik işaretli İSTEMDİR: listenin var oluş
    /// sebebi "işaretlendi ama haber verilmedi" boşluğunu göstermek. Geçen süre
    /// rapor/çekim anından bildirime (yoksa şimdiye) kadar sayılır.
    /// </summary>
    private static KaynakTanimi RadyolojiKritik() => new(
        Ad: "radyoloji-kritik",
        YetkiKodu: "radyoloji",
        Kaynak: "public.v_radyoloji_kritik_takip k",
        SubeKolonu: "k.sube_id",
        // Once BILDIRILMEYEN, sonra en uzun bekleyen: listenin ilk satiri her
        //   zaman "en acil is" olmali.
        VarsayilanSirala: "k.takip_durum, k.gecen_dk desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "k.istem_id",     "sayi",  "Id", Varsayilan: false),
            new("istemId",      "k.istem_id",     "sayi",  "İstem", Varsayilan: false),
            new("modaliteAdi",
                "case k.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' " +
                "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' " +
                "when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                                                  "metin", "Mod.", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 80,
                                                  Filtrelenebilir: false),
            new("modalite",     "k.modalite",     "kod",   "Modalite Kodu", Varsayilan: false),
            new("accessionNo",  "k.accession_no", "metin", "Accession", Genislik: 150),
            new("hasta",        "k.hasta",        "metin", "Hasta", Genislik: 190),
            new("hastaId",      "k.hasta_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("tetkik",       "k.tetkik",       "metin", "Tetkik", Genislik: 230),
            new("bulgu",        "k.bulgu",        "metin", "Kritik Bulgu", Genislik: 300),
            new("durumAdi",
                "case k.takip_durum when 1 then 'Bildirilmedi' when 2 then 'Teyit bekliyor' " +
                "when 3 then 'Teyitli' else 'Kapatıldı' end",
                                                  "metin", "Durum", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 120,
                                                  Filtrelenebilir: false),
            new("takipDurum",   "k.takip_durum",  "sayi",  "Durum Kodu", Varsayilan: false),
            new("bildirilen",   "k.bildirilen_ad","metin", "Bildirilen Hekim", Genislik: 200),
            new("bildiren",     "k.bildiren",     "metin", "Bulan Radyolog", Genislik: 170),
            new("yolAdi",
                "case k.yol when 1 then 'Telefon' when 2 then 'Yüz yüze' " +
                "when 3 then 'Mesaj / sistem' else '' end",
                                                  "metin", "Yol", Hizalama: "orta",
                                                  Genislik: 110, Filtrelenebilir: false),
            new("bildirimZamani","k.bildirim_zamani", "zaman", "Bildirim", Genislik: 140),
            new("teyitAlindi",  "k.teyit_alindi", "mantik", "Teyit", Hizalama: "orta",
                                                  Genislik: 80),
            new("gecenDk",      "k.gecen_dk",     "sayi",  "Geçen (dk)", Hizalama: "sag",
                                                  Genislik: 100),
            new("cekimTarihi",  "k.cekim_tarihi", "zaman", "Çekim", Varsayilan: false),
            new("onayTarihi",   "k.onay_tarihi",  "zaman", "Rapor Onayı", Varsayilan: false),
            new("kapatmaZamani","k.kapatma_zamani","zaman","Kapatma", Varsayilan: false),
            new("bildirimId",   "k.bildirim_id",  "sayi",  "Bildirim Id", Varsayilan: false),
        });

    /// <summary>
    /// KONSÜLTASYON TAKİBİ (318) - istenen ikinci görüşlerin listesi.
    ///
    /// İki yönlü okunur: "bana gelenler" (cevap yazmam gereken) ve "benim
    /// istediklerim" (beklediğim). Cevaplanmayan konsültasyon raporu da askıda
    /// tutar - bekleme süresi bu yüzden kolon.
    /// </summary>
    private static KaynakTanimi RadyolojiKonsultasyon() => new(
        Ad: "radyoloji-konsultasyon",
        YetkiKodu: "radyoloji",
        Kaynak: "public.radyoloji_konsultasyon ks " +
                "join public.radyoloji_istem i on i.id = ks.istem_id " +
                "left join public.taraf h on h.id = i.hasta_id " +
                "left join public.hizmet hz on hz.id = i.hizmet_id " +
                "left join public.taraf hk on hk.id = ks.hekim_id " +
                "left join public.taraf ku on ku.id = ks.kurum_id " +
                "left join public.taraf iste on iste.id = ks.ekleyen",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "ks.durum, ks.gonderim_zamani",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "ks.id",          "sayi",  "Id", Varsayilan: false),
            new("istemId",      "ks.istem_id",    "sayi",  "İstem", Varsayilan: false),
            new("gonderimZamani","ks.gonderim_zamani", "zaman", "İstek", Genislik: 140),
            new("modaliteAdi",
                "case i.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' " +
                "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' " +
                "when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                                                  "metin", "Mod.", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 80,
                                                  Filtrelenebilir: false),
            new("accessionNo",  "i.accession_no", "metin", "Accession", Genislik: 150),
            new("hasta",        "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 180),
            new("hastaId",      "i.hasta_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("tetkik",       "coalesce(hz.ad, '')", "metin", "Tetkik", Genislik: 210),
            new("isteyen",      "coalesce(iste.unvan, '')", "metin", "İsteyen", Genislik: 160),
            new("istenen",
                "coalesce(nullif(hk.unvan, ''), nullif(ku.unvan, ''), '')",
                                                  "metin", "İstenen", Genislik: 180),
            new("hekimId",      "ks.hekim_id",    "sayi",  "Hekim Id", Varsayilan: false),
            new("tipAdi",
                "case ks.tip when 2 then 'İkinci okuma' when 3 then 'Klinik korelasyon' " +
                "else 'Görüş' end",               "metin", "Tip", Hizalama: "orta",
                                                  Genislik: 130, Filtrelenebilir: false),
            new("tip",          "ks.tip",         "kod",   "Tip Kodu", Varsayilan: false),
            new("gerekce",      "ks.gerekce",     "metin", "Soru / Gerekçe", Genislik: 280),
            new("gorus",        "ks.gorus",       "metin", "Cevap", Genislik: 280),
            new("durumAdi",
                "case ks.durum when 2 then 'Cevaplandı' when 0 then 'İptal' " +
                "else 'Bekliyor' end",            "metin", "Durum", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 110,
                                                  Filtrelenebilir: false),
            new("durum",        "ks.durum",       "sayi",  "Durum Kodu", Varsayilan: false),
            new("acil",         "ks.acil",        "mantik","Acil", Hizalama: "orta", Genislik: 70),
            new("donusZamani",  "ks.donus_zamani","zaman", "Cevap Zamanı", Genislik: 140),
            // BEKLEME: cevaplanmadiysa SIMDIYE kadar - listenin sirasi bu.
            new("beklemeDk",
                "(extract(epoch from (coalesce(ks.donus_zamani, now()::timestamp) " +
                " - ks.gonderim_zamani)) / 60)::int",
                                                  "sayi",  "Bekleme (dk)", Hizalama: "sag",
                                                  Genislik: 110, Filtrelenebilir: false),
        });

    /// <summary>
    /// SONUÇ TESLİM TAKİBİ (318) - raporu onaylı ama teslim edilmemiş işler.
    ///
    /// Satır teslim kaydı değil İSTEMDİR: teslim satırı yoksa "hazır" olarak
    /// listede durur. "Hastanın raporu alındı mı" sorusu bugün ancak istem
    /// istem bakılarak cevaplanabiliyordu.
    /// </summary>
    private static KaynakTanimi RadyolojiTeslim() => new(
        Ad: "radyoloji-teslim",
        YetkiKodu: "radyoloji",
        Kaynak: "public.v_radyoloji_teslim_takip t",
        SubeKolonu: "t.sube_id",
        VarsayilanSirala: "t.takip_durum, t.bekleme_dk desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "t.istem_id",     "sayi",  "Id", Varsayilan: false),
            new("istemId",      "t.istem_id",     "sayi",  "İstem", Varsayilan: false),
            new("onayTarihi",   "t.onay_tarihi",  "zaman", "Rapor Onayı", Genislik: 140),
            new("modaliteAdi",
                "case t.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' " +
                "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' " +
                "when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                                                  "metin", "Mod.", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 80,
                                                  Filtrelenebilir: false),
            new("modalite",     "t.modalite",     "kod",   "Modalite Kodu", Varsayilan: false),
            new("accessionNo",  "t.accession_no", "metin", "Accession", Genislik: 150),
            new("hasta",        "t.hasta",        "metin", "Hasta", Genislik: 190),
            new("hastaId",      "t.hasta_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("telefon",      "t.telefon",      "metin", "Telefon", Genislik: 130),
            new("tetkik",       "t.tetkik",       "metin", "Tetkik", Genislik: 230),
            new("radyolog",     "t.radyolog",     "metin", "Radyolog", Genislik: 160),
            new("durumAdi",
                "case when t.takip_durum = 1 then 'Hazır' else 'Teslim edildi' end",
                                                  "metin", "Durum", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 120,
                                                  Filtrelenebilir: false),
            new("takipDurum",   "t.takip_durum",  "sayi",  "Durum Kodu", Varsayilan: false),
            // Teslim edilen KALEMLER tek okunur metin: dort ayri evet/hayir
            //   kolonu listede yer harcar, "Rapor + Film" bir bakista anlasilir.
            new("kalemler",
                "trim(both ' +' from " +
                " case when t.rapor_verildi = 1 then 'Rapor + ' else '' end || " +
                " case when t.film_verildi = 1 then 'Film + ' else '' end || " +
                " case when t.cd_verildi = 1 then 'CD + ' else '' end || " +
                " case when t.dijital_verildi = 1 then 'Dijital + ' else '' end)",
                                                  "metin", "Teslim Kalemleri", Genislik: 190,
                                                  Filtrelenebilir: false),
            new("cdIstendi",    "t.cd_istendi",   "mantik","CD İstendi", Hizalama: "orta",
                                                  Genislik: 100),
            new("alanAd",       "t.alan_ad",      "metin", "Teslim Alan", Genislik: 180),
            new("alanYakinlik", "t.alan_yakinlik","metin", "Yakınlık", Genislik: 110),
            new("teslimEden",   "t.teslim_eden",  "metin", "Teslim Eden", Genislik: 160),
            new("teslimZamani", "t.teslim_zamani","zaman", "Teslim", Genislik: 140),
            new("beklemeDk",    "t.bekleme_dk",   "sayi",  "Bekleme (dk)", Hizalama: "sag",
                                                  Genislik: 110),
        });
}
