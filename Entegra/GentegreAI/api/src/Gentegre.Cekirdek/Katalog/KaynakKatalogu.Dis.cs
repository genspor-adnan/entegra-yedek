namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DİŞ KLİNİĞİ MODÜLÜ LİSTELERİ (706) — tasarım notu
/// <c>Ekranlar/Dis Klinigi/dis_sureci.html</c>, mockuplar aynı klasörde.
///
/// <para>Modülün iş birimi TEDAVİ PLANIDIR: hasta kartı odontogram + plan
/// (özel sayfa), günlük akış (özel sayfa), planlar / seanslar / lab iş
/// emirleri / ödeme planları ise sıradan listelerdir. Odontogram satırları
/// (<c>dis_odontogram</c>) LİSTE KAYNAĞI DEĞİLDİR: onlar hasta kartında
/// şema olarak çizilir - "36 O çürük" satırlarını gridde okumak kimseye
/// bir şey söylemez.</para>
/// </summary>
public static partial class KaynakKatalogu
{
    private const string DisPlanDurumAdi =
        "case p.durum when 1 then 'Taslak' when 2 then 'Sunuldu' when 3 then 'Onaylı' "
        + "when 4 then 'Sürüyor' when 5 then 'Tamamlandı' when 6 then 'İptal' "
        + "when 7 then 'Süresi doldu' else '' end";

    private const string DisLabAsamaAdi =
        "case i.asama when 1 then 'Ölçü bekliyor' when 2 then 'Gönderildi' when 3 then 'Tasarım onayı' "
        + "when 4 then 'Üretim' when 5 then 'Geldi' when 6 then 'Prova' when 7 then 'Geri gönderildi' "
        + "when 8 then 'Teslim edildi' when 9 then 'İptal' else '' end";

    // ------------------------------------------------------------ hastalar ----
    /// <summary>
    /// DİŞ HASTALARI — hasta kartına (odontogram + plan) giriş listesi.
    /// Satır bir HASTADIR; çift tık özel sayfayı açar (<c>/dis-hasta/{id}</c>).
    /// Aktif plan ve son seans listede durur: "kim yarım kaldı" sorusu
    /// kartı açmadan cevaplansın.
    /// </summary>
    private static KaynakTanimi DisHasta() => new(
        Ad: "dis-hasta",
        YetkiKodu: "dis.hasta",
        Kaynak: "public.v_dis_hasta h",
        SubeKolonu: null,
        VarsayilanSirala: "h.son_seans desc nulls last, h.unvan",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "h.id",            "sayi",  "Id", Varsayilan: false),
            new("hasta",        "h.unvan",         "metin", "Hasta", Genislik: 220),
            new("yas",          "h.yas",           "sayi",  "Yaş", Hizalama: "orta", Genislik: 60),
            new("cepTel",       "h.cep_tel",       "metin", "Cep Tel", Genislik: 120),
            new("aktifPlanNo",  "coalesce(h.aktif_plan_no, '')", "metin", "Aktif Plan",
                Hizalama: "orta", Bicim: "rozet", Genislik: 120),
            new("bulguSayisi",  "h.bulgu_sayisi",  "sayi",  "Bulgu", Hizalama: "sag", Genislik: 70),
            new("sonMuayene",   "h.son_muayene",   "tarih", "Son Muayene", Hizalama: "orta"),
            new("sonSeans",     "h.son_seans",     "tarih", "Son Seans", Hizalama: "orta",
                Bicim: "dd.MM.yyyy HH:mm"),
        });

    // ------------------------------------------------------ tedavi planları ----
    private static KaynakTanimi DisPlan() => new(
        Ad: "dis-plan",
        YetkiKodu: "dis.plan",
        Kaynak: "public.v_dis_tedavi_plani p",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.id",         "sayi",  "Id", Varsayilan: false),
            new("planNo",    "p.plan_no",    "metin", "Plan No", Genislik: 110),
            new("hasta",     "p.hasta_adi",  "metin", "Hasta", Genislik: 200),
            new("hastaId",   "p.hasta_id",   "sayi",  "Hasta Id", Varsayilan: false),
            new("hekim",     "coalesce(p.hekim_adi, '')", "metin", "Hekim", Genislik: 160),
            new("tarih",     "p.tarih",      "tarih", "Tarih", Hizalama: "orta"),
            new("varyant",   "p.varyant",    "metin", "Varyant", Hizalama: "orta", Genislik: 70),
            new("durumAdi",  DisPlanDurumAdi, "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                Genislik: 110, Filtrelenebilir: false),
            new("durum",     "p.durum",      "kod",   "Durum Kodu", Varsayilan: false),
            // "3/7": planın neresindeyiz - hekim listede bunu okur.
            new("ilerleme",  "p.yapilan_sayisi || ' / ' || p.satir_sayisi", "metin", "Yapılan",
                Hizalama: "orta", Genislik: 80, Filtrelenebilir: false, Siralanabilir: false),
            new("toplam",    "p.toplam",     "para",  "Toplam", Hizalama: "sag"),
            new("indirim",   "p.indirim",    "para",  "İndirim", Hizalama: "sag"),
            new("net",       "p.net",        "para",  "Net", Hizalama: "sag"),
            new("yapilanTutar", "p.yapilan_tutar", "para", "Yapılan Tutar", Hizalama: "sag"),
            new("tahsil",    "p.tahsil",     "para",  "Tahsil", Hizalama: "sag"),
            // BAKİYE = yapılan − tahsil (mockup): yapılmamış işin parası borç
            //   değildir; plan toplamından bakiye hesaplamak hastayı daha
            //   ilk gün borçlu gösterirdi.
            new("bakiye",    "p.yapilan_tutar - p.tahsil", "para", "Bakiye", Hizalama: "sag"),
            new("gecerlilik","p.gecerlilik_bitis", "tarih", "Geçerlilik", Hizalama: "orta", Varsayilan: false),
            new("onayZamani","p.hasta_onay_zamani", "tarih", "Hasta Onayı", Hizalama: "orta",
                Bicim: "dd.MM.yyyy HH:mm", Varsayilan: false),
        });

    // ------------------------------------------------------------- seanslar ----
    private static KaynakTanimi DisSeans() => new(
        Ad: "dis-seans",
        YetkiKodu: "dis.seans",
        Kaynak: "public.v_dis_seans s",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "s.baslangic desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "s.id",          "sayi",  "Id", Varsayilan: false),
            new("baslangic", "s.baslangic",   "tarih", "Başlangıç", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("hasta",     "s.hasta_adi",   "metin", "Hasta", Genislik: 200),
            new("hastaId",   "s.hasta_id",    "sayi",  "Hasta Id", Varsayilan: false),
            new("hekim",     "coalesce(s.hekim_adi, '')", "metin", "Hekim", Genislik: 150),
            new("unit",      "coalesce(s.unit_adi, '')",  "metin", "Ünit", Genislik: 100),
            new("planNo",    "coalesce(s.plan_no, '')",   "metin", "Plan", Genislik: 110),
            new("islemler",  "coalesce(s.islemler, '')",  "metin", "İşlemler", Genislik: 260,
                Filtrelenebilir: false, Siralanabilir: false),
            new("sureDk",    "s.sure_dk",     "sayi",  "Süre (dk)", Hizalama: "sag", Genislik: 80),
            new("durumAdi",  "case s.durum when 1 then 'Açık' when 2 then 'Bitti' when 3 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 90, Filtrelenebilir: false),
            new("durum",     "s.durum",       "kod",   "Durum Kodu", Varsayilan: false),
            new("belgeId",   "s.belge_id",    "sayi",  "Başvuru Id", Varsayilan: false),
        });

    // ------------------------------------------------------- lab iş emirleri ----
    private static KaynakTanimi DisLabIsemri() => new(
        Ad: "dis-lab-isemri",
        YetkiKodu: "dis.lab",
        Kaynak: "public.v_dis_lab_isemri i",
        SubeKolonu: "i.sube_id",
        VarsayilanSirala: "i.gecikti desc, i.beklenen_tarih nulls last, i.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "i.id",           "sayi",  "Id", Varsayilan: false),
            new("isemriNo",  "i.isemri_no",    "metin", "İş Emri", Genislik: 110),
            new("hasta",     "i.hasta_adi",    "metin", "Hasta", Genislik: 180),
            new("hastaId",   "i.hasta_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("disNolar",  "i.dis_nolar",    "metin", "Diş", Hizalama: "orta", Genislik: 90),
            new("isTuruAdi", "case i.is_turu when 1 then 'Kron' when 2 then 'Köprü' when 3 then 'İmplant üstü' "
                           + "when 4 then 'Total protez' when 5 then 'Parsiyel protez' when 6 then 'Ortodonti apareyi' "
                           + "when 7 then 'Gece plağı' else 'Diğer' end",
                "metin", "İş", Genislik: 120, Filtrelenebilir: false),
            new("isTuru",    "i.is_turu",      "kod",   "İş Türü Kodu", Varsayilan: false),
            new("malzeme",   "i.malzeme || case when i.renk <> '' then ' · ' || i.renk else '' end",
                "metin", "Malzeme · Renk", Genislik: 150, Filtrelenebilir: false),
            new("lab",       "i.lab_adi",      "metin", "Lab", Genislik: 150),
            new("gonderim",  "i.gonderim_tarihi", "tarih", "Gönderim", Hizalama: "orta"),
            new("beklenen",  "i.beklenen_tarih",  "tarih", "Beklenen", Hizalama: "orta"),
            new("asamaAdi",  DisLabAsamaAdi,   "metin", "Aşama", Hizalama: "orta", Bicim: "rozet",
                Genislik: 120, Filtrelenebilir: false),
            new("asama",     "i.asama",        "kod",   "Aşama Kodu", Varsayilan: false),
            new("gecikti",   "i.gecikti",      "mantik", "Gecikti", Hizalama: "orta", Genislik: 70),
            new("sonrakiRandevu", "i.sonraki_randevu", "tarih", "Sonraki Randevu", Hizalama: "orta",
                Bicim: "dd.MM.yyyy HH:mm"),
            new("labFiyat",  "i.lab_fiyat",    "para",  "Lab Maliyeti", Hizalama: "sag"),
            new("hekim",     "coalesce(i.hekim_adi, '')", "metin", "Hekim", Genislik: 140, Varsayilan: false),
        });

    // ------------------------------------------------------------ ünitler ----
    private static KaynakTanimi DisUnit() => new(
        Ad: "dis-unit",
        YetkiKodu: "dis.unit",
        Kaynak: "public.dis_unit u left join public.taraf h on h.id = u.varsayilan_hekim_id",
        SubeKolonu: "u.sube_id",
        VarsayilanSirala: "u.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "u.id",   "sayi",  "Id", Varsayilan: false),
            new("kod",    "u.kod",  "metin", "Kod", Genislik: 80),
            new("ad",     "u.ad",   "metin", "Ad", Genislik: 180),
            new("turAdi", "case u.tur when 1 then 'Genel' when 2 then 'Cerrahi' when 3 then 'Hijyen' when 4 then 'Pedodonti' else '' end",
                "metin", "Tür", Hizalama: "orta", Bicim: "rozet", Filtrelenebilir: false),
            new("hekim",  "coalesce(h.unvan, '')", "metin", "Varsayılan Hekim", Genislik: 160),
            new("aktif",  "u.aktif", "mantik", "Aktif", Hizalama: "orta"),
        });

    // -------------------------------------------------------- laboratuvarlar ----
    private static KaynakTanimi DisLab() => new(
        Ad: "dis-lab",
        YetkiKodu: "dis.unit",
        Kaynak: "public.dis_lab l join public.taraf t on t.id = l.taraf_id",
        SubeKolonu: "l.sube_id",
        VarsayilanSirala: "l.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "l.id",       "sayi",  "Id", Varsayilan: false),
            new("ad",       "l.ad",       "metin", "Laboratuvar", Genislik: 200),
            new("cari",     "t.unvan",    "metin", "Tedarikçi Cari", Genislik: 200),
            new("slaGun",   "l.sla_gun",  "sayi",  "SLA (gün)", Hizalama: "sag", Genislik: 80),
            new("dijital",  "l.dijital",  "mantik", "Dijital", Hizalama: "orta"),
            new("kurye",    "l.kurye_gunleri", "metin", "Kurye Günleri", Genislik: 120),
            new("aktif",    "l.aktif",    "mantik", "Aktif", Hizalama: "orta"),
        });

    // ---------------------------------------------------------- ödeme planı ----
    private static KaynakTanimi DisOdemePlani() => new(
        Ad: "dis-odeme-plani",
        YetkiKodu: "dis.odeme",
        Kaynak: """
            public.dis_odeme_plani o
            join public.dis_tedavi_plani p on p.id = o.plan_id
            join public.taraf t on t.id = p.hasta_id
            """,
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "o.id",       "sayi",  "Id", Varsayilan: false),
            new("planNo",    "p.plan_no",  "metin", "Plan", Genislik: 110),
            new("hasta",     "t.unvan",    "metin", "Hasta", Genislik: 200),
            new("hastaId",   "p.hasta_id", "sayi",  "Hasta Id", Varsayilan: false),
            new("toplam",    "o.toplam",   "para",  "Toplam", Hizalama: "sag"),
            new("pesinat",   "o.pesinat",  "para",  "Peşinat", Hizalama: "sag"),
            new("taksitSayisi", "o.taksit_sayisi", "sayi", "Taksit", Hizalama: "orta", Genislik: 70),
            new("taksitTutar",  "o.taksit_tutar",  "para", "Taksit Tutarı", Hizalama: "sag"),
            new("ilkVade",   "o.ilk_vade", "tarih", "İlk Vade", Hizalama: "orta"),
            new("odenen",    "(select coalesce(sum(k.odenen), 0) from public.dis_odeme_taksit k where k.odeme_plani_id = o.id)",
                "para", "Ödenen", Hizalama: "sag", Filtrelenebilir: false),
            new("geciken",   "(select count(*) from public.dis_odeme_taksit k where k.odeme_plani_id = o.id and k.durum <> 2 and k.vade < current_date)",
                "sayi", "Geciken Taksit", Hizalama: "orta", Filtrelenebilir: false, Siralanabilir: false),
            new("durumAdi",  "case o.durum when 1 then 'Açık' when 2 then 'Tamamlandı' when 3 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Filtrelenebilir: false),
            new("durum",     "o.durum",    "kod",   "Durum Kodu", Varsayilan: false),
        });
}
