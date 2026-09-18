namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TELERADYOLOJİ (797) — dış kurumun görüntüsünü bizim radyologumuzun
/// okuduğu akış. Tasarım: `Ekranlar/Teleradyoloji/telerad_sureci.html`.
///
/// <b>Okuma işi iç akışın aynısıdır</b> (`radyoloji_istem` + `radyoloji_rapor`);
/// teleradyolojiye özel olan işin ÇEVRESİDİR: hangi kurumdan geldi, hangi
/// sözleşmeyle, SLA ne zaman doluyor, görüntü ulaştı mı, kime atandı, teslim
/// edildi mi, kaç para. Bu yüzden liste `v_telerad_istek` görünümünden
/// beslenir - kalan SLA dakikası ve risk işareti SUNUCUDA hesaplanır, iki
/// ekran iki farklı "şimdi" kullanıp listeyi kendi içinde çelişkiye
/// düşürmesin.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Öncelik · durum · görüntü durumu kod listeleri (mockup'taki adlar).</summary>
    private static readonly Dictionary<string, string> TeleradOncelik = new()
        { ["1"] = "Rutin", ["2"] = "Öncelikli", ["3"] = "ACİL" };

    private static readonly Dictionary<string, string> TeleradDurum = new()
    {
        ["0"] = "İptal",        ["1"] = "Görüntü bekleniyor", ["2"] = "Sırada",
        ["3"] = "Atandı",       ["4"] = "Okunuyor",           ["5"] = "Taslak",
        ["6"] = "Onaylı",       ["7"] = "Teslim edildi",      ["8"] = "Ek görüntü istendi",
    };

    private static readonly Dictionary<string, string> TeleradGoruntu = new()
        { ["0"] = "Bekleniyor", ["1"] = "Tamam", ["2"] = "Eksik seri", ["3"] = "Hatalı" };

    private static readonly Dictionary<string, string> TeleradYon = new()
        { ["1"] = "Gelen", ["2"] = "Giden", ["3"] = "İki yön" };

    /// <summary>ÇALIŞMA LİSTESİ — mockup `telerad_calisma_listesi.html` kolonları.</summary>
    private static KaynakTanimi TeleradIstek() => new(
        Ad: "telerad-istek",
        YetkiKodu: "teleradyoloji",
        Kaynak: "public.v_telerad_istek i",
        SubeKolonu: "i.sube_id",
        // ACİL ÖNCE, SONRA SLA'SI DOLMAK ÜZERE OLAN: çalışma listesinin sırası
        //   bir tercih değil işin kendisidir - radyolog listenin başından alır.
        VarsayilanSirala: "i.oncelik desc, i.sla_bitis nulls last, i.id",
        // PORTAL (794): gönderen kurum kendi isteklerini, gönderen hekim kendi
        //   istediklerini görür. Kurum bağı `telerad_kurum.taraf_id` üzerinden -
        //   portal kullanıcısı kurumun CARİ kaydıdır.
        PortalKosullari: PortalKapsam.Kur(
            disDoktor: "i.atanan_radyolog_id = {kullanici}",
            disKurum:  "i.kurum_taraf_id = {kullanici}",
            hasta:     "false"),
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "i.id",          "sayi",  "Id", Varsayilan: false),
            new("istekNo",     "i.istek_no",    "metin", "İstek No", Genislik: 130),
            // ETIKET KOLONU + HAM KOD: rozet METNI cizer (gridHucre), kod
            //   tipi sayidir. Radyoloji kaynaklarindaki desenin aynisi -
            //   suzme ham kodla yapilir, etiket degisince filtre kaymaz.
            new("oncelikAdi",
                "case i.oncelik when 3 then 'ACİL' when 2 then 'Öncelikli' else 'Rutin' end",
                "metin", "Öncelik", Hizalama: "orta", Genislik: 95, Bicim: "rozet",
                Filtrelenebilir: false),
            new("oncelik",     "i.oncelik",     "kod",   "Öncelik Kodu", Varsayilan: false,
                Kodlar: TeleradOncelik),
            new("kurumAdi",    "i.kurum_adi",   "metin", "Kurum", Genislik: 190),
            new("hastaAdi",    "i.hasta_adi",   "metin", "Hasta", Genislik: 170),
            new("erisimNo",    "i.dis_erisim_no", "metin", "Erişim No", Genislik: 130,
                                                   Varsayilan: false),
            // MODALITE ADI radyoloji kaynaklarindaki ifadeyle AYNI
            //   (KaynakKatalogu.Radyoloji) - iki liste ayni tetkike iki ad
            //   yazmasin. Ham kod da gizli kolon olarak durur: suzme kodla
            //   yapilir, ad degisince filtre kaymaz.
            new("modaliteAdi",
                "case i.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' "
                + "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' "
                + "when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end",
                "metin", "Modalite", Hizalama: "orta", Bicim: "rozet", Genislik: 100,
                Filtrelenebilir: false),
            new("modalite",    "i.modalite",    "kod",   "Modalite Kodu", Varsayilan: false),
            new("tetkikAdi",   "i.tetkik_adi",  "metin", "Tetkik", Genislik: 200),
            new("cekimZamani", "i.cekim_zamani", "tarih", "Çekim", Hizalama: "orta",
                                                   Bicim: "dd.MM HH:mm"),
            new("gelisZamani", "i.gelis_zamani", "tarih", "Geldi", Hizalama: "orta",
                                                   Bicim: "dd.MM HH:mm"),
            new("slaDk",       "i.sla_dk",      "sayi",  "SLA (dk)", Hizalama: "sag",
                                                   Genislik: 90, Varsayilan: false),
            // KALAN DAKİKA EKSİYE DÜŞEBİLİR: gecikmeyi saklamak, listeye bakan
            //   kişiye "yetişiyoruz" dedirtirdi.
            new("kalanDk",     "i.kalan_dk",    "sayi",  "Kalan (dk)", Hizalama: "sag",
                                                   Genislik: 95),
            new("slaRiskli",   "i.sla_riskli",  "mantik", "SLA aşımı", Hizalama: "orta"),
            new("klinikBilgi", "i.klinik_bilgi", "metin", "Klinik Bilgi", Genislik: 260),
            new("radyologAdi", "i.radyolog_adi", "metin", "Radyolog", Genislik: 160),
            new("goruntuSayisi", "i.goruntu_sayisi", "sayi", "Görüntü", Hizalama: "sag",
                                                   Genislik: 90),
            new("goruntuDurumAdi",
                "case i.goruntu_durum when 1 then 'Tamam' when 2 then 'Eksik seri' "
                + "when 3 then 'Hatalı' else 'Bekleniyor' end",
                "metin", "Görüntü Durumu", Hizalama: "orta", Genislik: 130,
                Bicim: "rozet", Filtrelenebilir: false, Varsayilan: false),
            new("goruntuDurum", "i.goruntu_durum", "kod", "Görüntü Durum Kodu",
                Varsayilan: false, Kodlar: TeleradGoruntu),
            new("durumAdi",
                "case i.durum when 0 then 'İptal' when 1 then 'Görüntü bekleniyor' "
                + "when 2 then 'Sırada' when 3 then 'Atandı' when 4 then 'Okunuyor' "
                + "when 5 then 'Taslak' when 6 then 'Onaylı' when 7 then 'Teslim edildi' "
                + "when 8 then 'Ek görüntü istendi' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 150, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum",       "i.durum",       "kod",   "Durum Kodu", Varsayilan: false,
                Kodlar: TeleradDurum),
            new("onayZamani",  "i.onay_zamani", "tarih", "Onay", Hizalama: "orta",
                                                   Bicim: "dd.MM HH:mm", Varsayilan: false),
            new("teslimZamani", "i.teslim_zamani", "tarih", "Teslim", Hizalama: "orta",
                                                   Bicim: "dd.MM HH:mm", Varsayilan: false),
            new("ucret",       "i.ucret",       "para",  "Ücret", Hizalama: "sag",
                                                   Varsayilan: false),
            new("slaAsildi",   "i.sla_asildi",  "mantik", "SLA Aşıldı", Hizalama: "orta",
                                                   Varsayilan: false),
            new("kurumId",     "i.kurum_id",    "sayi",  "Kurum Id", Varsayilan: false),
            new("radyolojiIstemId", "i.radyoloji_istem_id", "sayi", "İstem Id", Varsayilan: false),
            new("raporId",     "i.rapor_id",    "sayi",  "Rapor Id", Varsayilan: false),
            // SLA'SI KAÇAN SATIR RENKLENİR (`satirRengi` sözleşmesi, mockup
            //   `telerad_calisma_listesi.html`): tasarımda geciken iş kırmızı
            //   satırdır - "Kalan" sütunundaki eksi sayıyı fark etmeyi beklemek
            //   yoğun bir günde kaçırmak demektir.
            //   EŞİK SUNUCUDA: istemci kural yazmaz, liste ile pano aynı işe
            //   iki farklı renk vermez. Süresi dolmuş = kritik, son çeyreğe
            //   girmiş = uyarı; onaylanmış işte (durum >= 6) renk YOK - iş
            //   bitti, geçmiş gecikme listeyi kırmızıya boğmasın.
            new("satirRengi",
                "case when i.durum >= 6 or i.durum = 0 then '' "
                + "when i.kalan_dk is null then '' "
                + "when i.kalan_dk < 0 then 'kritik' "
                + "when i.sla_dk > 0 and i.kalan_dk * 4 <= i.sla_dk then 'uyari' "
                + "else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });

    /// <summary>KURUMLAR — cari kartına bağlı teleradyoloji ilişkisi.</summary>
    private static KaynakTanimi TeleradKurum() => new(
        Ad: "telerad-kurum",
        YetkiKodu: "teleradyoloji.kurum",
        Kaynak: "public.telerad_kurum k "
              + "  join public.taraf t on t.id = k.taraf_id "
              + "  left join public.radyoloji_sablon s on s.id = k.rapor_sablon_id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "t.unvan",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "k.id",        "sayi",  "Id", Varsayilan: false),
            new("unvan",     "t.unvan",     "metin", "Kurum", Genislik: 240),
            new("yonAdi",
                "case k.yon when 2 then 'Giden' when 3 then 'İki yön' else 'Gelen' end",
                "metin", "Yön", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("yon",       "k.yon",       "kod",   "Yön Kodu", Varsayilan: false,
                Kodlar: TeleradYon),
            new("tesisKodu", "k.tesis_kodu", "metin", "Tesis Kodu", Hizalama: "orta",
                                                Genislik: 110),
            new("aeTitle",   "k.dicom_ae_title", "metin", "DICOM AE", Genislik: 130),
            new("hl7TurAdi",
                "case k.hl7_tur when 1 then 'HL7 ORU' when 2 then 'REST' "
                + "when 3 then 'FHIR' else 'Portal' end",
                "metin", "Teslim Kanalı", Hizalama: "orta", Genislik: 130,
                Filtrelenebilir: false),
            new("sablonAdi", "coalesce(s.ad, '')", "metin", "Rapor Şablonu", Genislik: 180,
                                                Varsayilan: false),
            new("geceNobet", "k.gece_nobet", "mantik", "Gece", Hizalama: "orta"),
            // AÇIK SÖZLEŞME SAYISI: "kurum var ama sözleşmesi yok" en sık
            //   karşılaşılan eksiklik - listede görünsün.
            new("sozlesme",
                "(select count(*) from public.telerad_sozlesme sz "
                + " where sz.kurum_id = k.id and sz.durum = 1)", "sayi", "Aktif Sözleşme",
                Hizalama: "orta", Genislik: 120),
            new("aktif",     "k.aktif",     "mantik", "Aktif", Hizalama: "orta"),
            new("tarafId",   "k.taraf_id",  "sayi",  "Cari Id", Varsayilan: false),
            // "KURUM VAR AMA SÖZLEŞMESİ YOK" en sık karşılaşılan eksiklik
            //   (797 yorumu): sayıya bakıp fark etmeyi beklemek yerine satır
            //   uyarı rengiyle gelsin - sözleşmesiz kurumun isteği SLA'sız ve
            //   ücretsiz doğar. Pasif kurum soluk satır.
            new("satirRengi",
                "case when k.aktif = 0 then 'pasif' "
                + "when not exists (select 1 from public.telerad_sozlesme sz "
                + "                  where sz.kurum_id = k.id and sz.durum = 1) then 'uyari' "
                + "else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });

    /// <summary>SÖZLEŞMELER — dönem, ücret modeli, SLA.</summary>
    private static KaynakTanimi TeleradSozlesme() => new(
        Ad: "telerad-sozlesme",
        YetkiKodu: "teleradyoloji.sozlesme",
        Kaynak: "public.telerad_sozlesme s "
              + "  join public.telerad_kurum k on k.id = s.kurum_id "
              + "  join public.taraf t on t.id = k.taraf_id "
              + "  left join public.fiyat_listesi f on f.id = s.fiyat_listesi_id",
        VarsayilanSirala: "s.baslangic desc, t.unvan",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "s.id",        "sayi",  "Id", Varsayilan: false),
            new("kurumAdi",  "t.unvan",     "metin", "Kurum", Genislik: 220),
            new("baslangic", "s.baslangic", "tarih", "Başlangıç", Hizalama: "orta"),
            new("bitis",     "s.bitis",     "tarih", "Bitiş", Hizalama: "orta"),
            new("ucretModeliAdi",
                "case s.ucret_modeli when 2 then 'Aylık sabit + aşım' "
                + "when 3 then 'Vaka başı' else 'Tetkik başı' end",
                "metin", "Ücret Modeli", Genislik: 165, Filtrelenebilir: false),
            new("tarife",    "coalesce(f.ad, '')", "metin", "Tarife", Genislik: 170),
            new("aylikSabit", "s.aylik_sabit", "para", "Aylık Sabit", Hizalama: "sag",
                                                   Varsayilan: false),
            new("slaAcil",   "s.sla_acil_dk", "sayi", "SLA Acil (dk)", Hizalama: "sag",
                                                   Genislik: 110),
            new("slaOncelikli", "s.sla_oncelikli_dk", "sayi", "SLA Öncelikli", Hizalama: "sag",
                                                   Genislik: 120, Varsayilan: false),
            new("slaRutin",  "s.sla_rutin_dk", "sayi", "SLA Rutin", Hizalama: "sag",
                                                   Genislik: 110, Varsayilan: false),
            new("acilEkOran", "s.acil_ek_oran", "sayi", "Acil Ek %", Hizalama: "sag",
                                                   Genislik: 100, Varsayilan: false),
            new("durumAdi",
                "case s.durum when 1 then 'Aktif' when 2 then 'Bitti' else 'Taslak' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum",     "s.durum",     "kod",   "Durum Kodu", Varsayilan: false),
            new("kurumId",   "s.kurum_id",  "sayi",  "Kurum Id", Varsayilan: false),
        });
}
