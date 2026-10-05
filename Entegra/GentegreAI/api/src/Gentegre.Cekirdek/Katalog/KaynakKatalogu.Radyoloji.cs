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
                "left join public.taraf s on s.id = c.sorumlu_id " +
                "left join public.v_radyoloji_cihaz_durum d on d.cihaz_id = c.id",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.modalite, c.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "c.id",    "sayi",  "Id", Varsayilan: false),
            new("kod",      "c.kod",   "metin", "Kod", Genislik: 80),
            // 967 (mockup radyoloji_cihaz_listesi_v2.html): ad + altında marka / model / AE Title.
            new("ad",       "c.ad",    "metin", "Cihaz", Genislik: 260, Bicim: "alt:cihazAlt"),
            new("cihazAlt",
                "concat_ws(' · ', nullif(trim(c.marka || ' ' || c.model), ''), nullif('AE ' || c.ae_title, 'AE '))",
                                       "metin", "Marka / model", Varsayilan: false),
            new("modaliteAdi",
                RadyolojiIfadeleri.ModaliteAdi("c.modalite"),
                                       "metin", "Modalite", Hizalama: "orta",
                                       Bicim: "rozet", Genislik: 100, Filtrelenebilir: false),
            new("modalite", "c.modalite", "kod", "Modalite Kodu", Varsayilan: false),
            new("oda",      "coalesce(c.oda, '')", "metin", "Oda", Genislik: 130),
            // ŞU AN: kapatma aralığındaysa bakım / arıza / kapalı (v_radyoloji_cihaz_durum).
            new("suAn",     "coalesce(d.su_an, '')", "metin", "Şu an", Bicim: "rozet", Genislik: 110),
            new("suAnKod",  "coalesce(d.su_an_kod, 1)", "sayi", "Şu an kodu", Varsayilan: false),
            new("bugun",
                "case when coalesce(d.bugun_randevu, 0) > 0 then d.bugun_cekim || ' / ' || d.bugun_randevu " +
                "     else coalesce(d.bugun_cekim, 0) || ' / —' end",
                                       "metin", "Bugün (çekim / randevu)", Hizalama: "sag", Genislik: 120,
                                       Filtrelenebilir: false, Siralanabilir: false),
            new("sirada",   "coalesce(d.sirada, 0)", "sayi", "Sırada", Hizalama: "orta", Genislik: 70, Bicim: "sayac"),
            new("doluluk",
                "case when coalesce(d.hafta_kapasite, 0) > 0 then round(100.0 * d.hafta_randevu / d.hafta_kapasite) end",
                                       "ondalik", "Doluluk % (hafta)", Genislik: 120, Bicim: "cubuk:yuzTavan"),
            new("yuzTavan", "100", "sayi", "Tavan", Varsayilan: false),
            new("protokolSayisi", "coalesce(d.protokol_sayisi, 0)", "sayi", "Protokol", Hizalama: "orta", Genislik: 80),
            new("baglanti",
                "concat_ws(' · ', case when c.mwl = 1 then 'MWL' end, case when c.mpps = 1 then 'MPPS' end, " +
                "          case when coalesce(d.goruntu_eksik, 0) > 0 then 'görüntü eksik: ' || d.goruntu_eksik end)",
                                       "metin", "Bağlantı", Genislik: 150, Filtrelenebilir: false),
            new("qa",
                "case when coalesce(d.qa_geciken, 0) > 0 then 'Gecikti: ' || d.qa_geciken_ad " +
                "     when coalesce(d.qa_yaklasan, 0) > 0 then d.qa_yaklasan || ' test 30 gün içinde' else '' end",
                                       "metin", "QA / lisans", Bicim: "uyari", Genislik: 180),
            new("qaGeciken", "coalesce(d.qa_geciken, 0)", "sayi", "QA geciken", Varsayilan: false),
            new("goruntuEksik", "coalesce(d.goruntu_eksik, 0)", "sayi", "Görüntü eksik", Varsayilan: false),
            new("sorumlu",  "coalesce(public.fn_taraf_ad(s.unvan, s.ad, s.soyad)::varchar(120), '')", "metin", "Sorumlu",
                Genislik: 160, Varsayilan: false),
            new("aeTitle",  "c.ae_title", "metin", "AE Title", Varsayilan: false),
            // Mesai iki kolon yerine TEK okunur metin.
            new("mesai",
                "case when c.randevu_verilir = 1 and c.baslangic_saat <> '' " +
                "     then c.baslangic_saat || '-' || c.bitis_saat else '' end",
                                       "metin", "Mesai", Hizalama: "orta", Genislik: 110,
                                       Filtrelenebilir: false, Varsayilan: false),
            new("slotDk",   "c.slot_dk", "sayi", "Slot (dk)", Hizalama: "sag", Varsayilan: false),
            new("randevuVerilir", "c.randevu_verilir", "mantik", "Randevu", Hizalama: "orta", Varsayilan: false),
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
            new("tetkikKodu", "coalesce(hz.kod, '')", "metin", "Kod", Varsayilan: false),
            // 965 (mockup radyoloji_protokol_listesi.html): seri ayrı kolonda.
            new("tetkikAdi",  "coalesce(hz.ad, '')",  "metin", "Tetkik (hizmet)", Genislik: 280),
            // SERİ: tip kod listesinden (515), metni seri_tarifi.
            new("seriAdi",    "coalesce(left(p.seri_tarifi, 40), '')", "metin", "Seri", Genislik: 160),
            new("modaliteAdi",
                RadyolojiIfadeleri.ModaliteAdi("coalesce(p.modalite, hz.modalite)"),
                                             "metin", "Modalite", Hizalama: "orta",
                                             Bicim: "rozet", Genislik: 100, Filtrelenebilir: false),
            new("modalite",   "coalesce(p.modalite, hz.modalite)", "kod", "Modalite Kodu", Varsayilan: false),
            new("bolge",      "p.bolge",     "kod",   "Bölge Kodu", Varsayilan: false),
            new("sureDk",     "p.sure_dk",   "sayi",  "Süre (dk)", Hizalama: "sag", Genislik: 80),
            new("kontrastAdi",
                "case p.kontrast when 1 then 'İV' when 2 then 'Oral' when 3 then 'İV + Oral' when 4 then 'Rektal' else 'Yok' end",
                                             "metin", "Kontrast", Hizalama: "orta", Bicim: "rozet", Genislik: 100,
                                             Filtrelenebilir: false),
            new("kontrast",   "p.kontrast",  "kod",   "Kontrast Kodu", Varsayilan: false),
            new("seriKodu",   "p.seri_kodu", "kod", "Seri Tipi Kodu", Varsayilan: false),
            new("hazirlik",
                "coalesce(left(p.hazirlik_metni, 40), '')",
                                             "metin", "Hazırlık", Genislik: 160),
            new("kontrolSayisi",
                "(select count(*) from public.radyoloji_protokol_kontrol k where k.protokol_id = p.id)",
                                             "sayi", "Kontrol", Hizalama: "orta", Genislik: 80, Bicim: "sayac"),
            new("malzemeSayisi",
                "(select count(*) from public.radyoloji_protokol_malzeme m where m.protokol_id = p.id)",
                                             "sayi", "Malzeme", Hizalama: "orta", Genislik: 80),
            new("cihazlar",
                "coalesce((select string_agg(c.kod, ', ' order by c.kod) from public.radyoloji_protokol_cihaz pc " +
                "          join public.radyoloji_cihaz c on c.id = pc.cihaz_id where pc.protokol_id = p.id), '')",
                                             "metin", "Cihaz", Genislik: 120, Filtrelenebilir: false),
            // UYARI ŞERİDİ: eksik hazırlık / malzemesiz kontrastlı protokol.
            new("eksik",
                "concat_ws(', ', case when coalesce(p.hazirlik_metni, '') = '' and p.kontrast > 0 then 'hazırlık metni yok' end, " +
                "          case when p.kontrast > 0 and not exists (select 1 from public.radyoloji_protokol_malzeme m where m.protokol_id = p.id) " +
                "               then 'malzemesiz kontrastlı' end)",
                                             "metin", "Eksik", Bicim: "uyari", Genislik: 180),
            new("hazirlikVar",
                "case when coalesce(p.hazirlik_metni, '') <> '' then 1 else 0 end",
                                             "mantik", "Hazırlık var", Varsayilan: false),
            new("hazirlikMetni", "coalesce(p.hazirlik_metni, '')", "metin", "Hazırlık Talimatı", Varsayilan: false),
            new("ozelUyari",  "coalesce(p.ozel_uyari, '')", "metin", "Özel Uyarı", Varsayilan: false),
            new("seriTarifi", "coalesce(p.seri_tarifi, '')", "metin", "Seri / Pozisyon", Varsayilan: false),
            new("durum",      "p.durum",     "mantik", "Aktif", Hizalama: "orta", Genislik: 70),
        });

    private static KaynakTanimi RadyolojiIstem() => new(
        Ad: "radyoloji-istem",
        // DAR YETKI (796): calisma listesi `radyoloji-istem` yetkisine bagli,
        //   `radyoloji`ye degil. `radyoloji` YEDI kaynagi birden aciyor
        //   (cihaz, sablon, protokol, kritik, konsultasyon, teslim) - dis
        //   hekime "sonuc gorsun" demek icin kurumun butun radyoloji
        //   ayarlarini acmak gerekiyordu. Yetki zaten vardi ama hicbir
        //   kaynaga bagli degildi (10 rolde duruyor, bir ise yaramiyordu).
        YetkiKodu: "radyoloji-istem",
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
        // BANKO KAPISI (912): poliklinik muayene isteği banko ücretlendirmesi
        //   beklerken (serbest=0) çekim listesinde GÖRÜNMEZ. Banko serbest
        //   bırakınca (POST /api/basvuru/{id}/istem-serbest) düşer. Acil/yatan/
        //   dış/banko kaynaklı istemler zaten serbest=1 gelir.
        SabitKosul: "i.serbest = 1",
        // ACİL en üstte, sonra en eski bekleyen: liste açılınca "önce neye
        //   bakmalıyım" sorusu sıralamayla cevaplanır.
        // PORTAL (796): radyolojide bag DOGRUDAN istemin uzerinde -
        //   `istek_hekim_id` / `istek_kurum_id`. Dis hekim kendi istedigi
        //   tetkiki ve raporunu, hasta kendi tetkikini gorur.
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: "i.istek_hekim_id = {kullanici}",
            disKurum:  "i.istek_kurum_id = {kullanici}",
            hasta:     "i.hasta_id = {kullanici}"),
        VarsayilanSirala: "i.oncelik desc, coalesce(i.cekim_tarihi, i.ekleme_tarihi) asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "i.id",              "sayi",  "Id",            Varsayilan: false),
            new("saat",          "coalesce(i.cekim_tarihi, i.ekleme_tarihi)",
                                                      "tarih", "Saat",          Hizalama: "orta",
                                                                                Bicim: "dd.MM.yyyy HH:mm",
                                                                                Genislik: 130),
            new("modaliteAdi",
                RadyolojiIfadeleri.ModaliteAdi("i.modalite"),
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
            new("hastaAdi",      "coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')", "metin", "Hasta",     Genislik: 190),
            new("tetkikKodu",    "coalesce(hz.kod, '')",  "metin", "Tetkik Kodu", Varsayilan: false),
            new("tetkikAdi",     "coalesce(hz.ad, '')",   "metin", "Tetkik",    Genislik: 230),
            // İsteyen: iç hekim kayıtlıysa adı, değilse dış hekim serbest alanı.
            new("isteyen",
                "coalesce(nullif(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::varchar(120), ''), nullif(i.dis_hekim_ad, ''), '')",
                                                      "metin", "İstem Yapan",   Genislik: 170,
                                                                                Filtrelenebilir: false),
            // Ham hekim id (305): dis hekim kartinin "Gönderim Geçmişi" gridi
            //   bu kolonla suzuluyor - gridde gizli.
            new("istekHekimId",  "i.istek_hekim_id", "sayi", "İstem Hekim Id",
                Varsayilan: false),
            new("isteyenKurum",  "coalesce(public.fn_taraf_ad(ik.unvan, ik.ad, ik.soyad)::varchar(120), '')", "metin", "İsteyen Kurum",
                                                                                Genislik: 160, Varsayilan: false),
            new("odeyenKurum",   "coalesce(public.fn_taraf_ad(ok.unvan, ok.ad, ok.soyad)::varchar(120), '')", "metin", "Ödeyen Kurum",
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
            new("raporlayan",    "coalesce(public.fn_taraf_ad(ry.unvan, ry.ad, ry.soyad)::varchar(120), '')", "metin", "Radyolog", Genislik: 160,
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
                "left join public.hizmet hz on hz.id = s.hizmet_id " +
                "left join public.taraf sh on sh.id = s.sahip_id",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "s.modalite, s.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "s.id",   "sayi",  "Id", Varsayilan: false),
            // 965 (mockup radyoloji_sablon_listesi_v2.html): ⭐ varsayılan en solda.
            new("yildiz",     "case when s.varsayilan = 1 then '⭐' else '' end", "metin", "⭐",
                Hizalama: "orta", Genislik: 36, Filtrelenebilir: false, Siralanabilir: false),
            new("kod",        "s.kod",  "metin", "Kod", Genislik: 110),
            new("ad",         "s.ad",   "metin", "Şablon", Genislik: 240, Bicim: "alt:sahibi"),
            new("sahibi",
                "case when s.sahip_id is null then 'Kurum şablonu' " +
                "     else 'Kişisel · ' || public.fn_taraf_ad(sh.unvan, sh.ad, sh.soyad)::varchar(120) end",
                                        "metin", "Sahibi", Varsayilan: false),
            new("sahipId",    "s.sahip_id", "sayi", "Sahip Id", Varsayilan: false),
            new("modaliteAdi",
                RadyolojiIfadeleri.ModaliteAdi("s.modalite"),
                                        "metin", "Modalite", Hizalama: "orta", Bicim: "rozet",
                                                 Genislik: 90, Filtrelenebilir: false),
            new("modalite",   "s.modalite", "kod", "Modalite Kodu", Varsayilan: false),
            new("bolge",      "s.bolge", "kod", "Bölge Kodu", Varsayilan: false),
            new("tetkik",
                "coalesce(hz.ad, '')", "metin", "Bağlı hizmet", Genislik: 200, Bicim: "alt:ekHizmet",
                Filtrelenebilir: false),
            new("ekHizmet",
                "case when (select count(*) from public.radyoloji_sablon_hizmet x where x.sablon_id = s.id) > 0 " +
                "     then '+' || (select count(*) from public.radyoloji_sablon_hizmet x where x.sablon_id = s.id) || ' hizmet' else '' end",
                                        "metin", "Ek hizmet", Varsayilan: false),
            new("hizmetsiz",
                "case when s.hizmet_id is null and not exists (select 1 from public.radyoloji_sablon_hizmet x where x.sablon_id = s.id) " +
                "     then 1 else 0 end", "sayi", "Hizmetsiz", Varsayilan: false),
            new("bolumSayisi",
                "(select count(*) from public.radyoloji_sablon_bolum b where b.sablon_id = s.id)",
                                        "sayi",  "Bölüm", Hizalama: "orta", Genislik: 70, Filtrelenebilir: false),
            new("alanSayisi",
                "(select count(*) from public.radyoloji_sablon_alan a where a.sablon_id = s.id)",
                                        "sayi",  "Alan", Hizalama: "orta", Genislik: 70, Filtrelenebilir: false),
            new("makroSayisi",
                "(select count(*) from public.radyoloji_sablon_makro m where m.sablon_id = s.id)",
                                        "sayi",  "Makro", Hizalama: "orta", Genislik: 70, Filtrelenebilir: false),
            new("surumAdi",   "'v' || s.surum", "metin", "Sürüm", Hizalama: "orta", Genislik: 70, Siralanabilir: false),
            // KULLANIM SON 30 GÜN: rapor kaydından sayılır (eski "kullanim" sayacı birikimli).
            new("kullanim30",
                "(select count(*) from public.radyoloji_rapor r where r.sablon_id = s.id and r.ekleme_tarihi > now() - interval '30 days')",
                                        "sayi", "Kullanım (30 gün)", Hizalama: "sag", Genislik: 110),
            new("kullanim",   "s.kullanim", "sayi", "Kullanım (toplam)", Hizalama: "sag", Varsayilan: false),
            new("varsayilan", "s.varsayilan", "mantik", "Varsayılan", Varsayilan: false),
            new("durum",      "s.durum", "mantik", "Aktif", Hizalama: "orta", Genislik: 70),
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
                RadyolojiIfadeleri.ModaliteAdi("k.modalite"),
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
            new("bildirimZamani","k.bildirim_zamani", "tarih", "Bildirim", Genislik: 140, Bicim: "dd.MM.yyyy HH:mm"),
            new("teyitAlindi",  "k.teyit_alindi", "mantik", "Teyit", Hizalama: "orta",
                                                  Genislik: 80),
            new("gecenDk",      "k.gecen_dk",     "sayi",  "Geçen (dk)", Hizalama: "sag",
                                                  Genislik: 100),
            new("cekimTarihi",  "k.cekim_tarihi", "tarih", "Çekim", Varsayilan: false, Bicim: "dd.MM.yyyy HH:mm"),
            new("onayTarihi",   "k.onay_tarihi",  "tarih", "Rapor Onayı", Varsayilan: false, Bicim: "dd.MM.yyyy HH:mm"),
            new("kapatmaZamani","k.kapatma_zamani","tarih","Kapatma", Varsayilan: false, Bicim: "dd.MM.yyyy HH:mm"),
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
            new("gonderimZamani","ks.gonderim_zamani", "tarih", "İstek", Genislik: 140, Bicim: "dd.MM.yyyy HH:mm"),
            new("modaliteAdi",
                RadyolojiIfadeleri.ModaliteAdi("i.modalite"),
                                                  "metin", "Mod.", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 80,
                                                  Filtrelenebilir: false),
            new("accessionNo",  "i.accession_no", "metin", "Accession", Genislik: 150),
            new("hasta",        "coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')", "metin", "Hasta", Genislik: 180),
            new("hastaId",      "i.hasta_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("tetkik",       "coalesce(hz.ad, '')", "metin", "Tetkik", Genislik: 210),
            new("isteyen",      "coalesce(public.fn_taraf_ad(iste.unvan, iste.ad, iste.soyad)::varchar(120), '')", "metin", "İsteyen", Genislik: 160),
            new("istenen",
                "coalesce(nullif(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::varchar(120), ''), nullif(public.fn_taraf_ad(ku.unvan, ku.ad, ku.soyad)::varchar(120), ''), '')",
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
            new("donusZamani",  "ks.donus_zamani","tarih", "Cevap Zamanı", Genislik: 140, Bicim: "dd.MM.yyyy HH:mm"),
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
            new("onayTarihi",   "t.onay_tarihi",  "tarih", "Rapor Onayı", Genislik: 140, Bicim: "dd.MM.yyyy HH:mm"),
            new("modaliteAdi",
                RadyolojiIfadeleri.ModaliteAdi("t.modalite"),
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
            new("teslimZamani", "t.teslim_zamani","tarih", "Teslim", Genislik: 140, Bicim: "dd.MM.yyyy HH:mm"),
            new("beklemeDk",    "t.bekleme_dk",   "sayi",  "Bekleme (dk)", Hizalama: "sag",
                                                  Genislik: 110),
        });
}
