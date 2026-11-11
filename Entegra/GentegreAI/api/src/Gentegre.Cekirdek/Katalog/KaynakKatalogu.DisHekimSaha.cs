namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DIŞ DOKTOR SAHA LİSTELERİ (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §1 / §2): ziyaretler ve
/// doktor talepleri. Görünümler ad / kod çözümünü taşır (v_dis_hekim_ziyaret, v_dis_hekim_talep).
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Ziyaret kaynağının tanımı - plan uçları "dar kapsam mı" sorusunu bunun kurallarıyla sorar (ad metniyle değil).</summary>
    public static KaynakTanimi DisHekimZiyaretTanimi { get; } = DisHekimZiyaret();

    private static KaynakTanimi DisHekimZiyaret() => new(
        Ad: "dis-hekim-ziyaret",
        YetkiKodu: "dis_doktor.ziyaret",
        Kaynak: "public.v_dis_hekim_ziyaret z",
        SubeKolonu: "z.sube_id",
        VarsayilanSirala: "z.tarih desc",
        RolKosullari: new Dictionary<string, string> { [RolKapsami.SahaTemsilci] = "z.temsilci_id = {kullanici}" },
        Kolonlar:
        [
            new("id",          "z.id",            "sayi",  "Id", Varsayilan: false),
            new("tarih",       "z.tarih",         "tarih", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("hekimAd",     "z.hekim_ad",      "metin", "Dış Doktor", Genislik: 220, BaslikErp: "Müşteri"),
            new("hekimKurum",  "z.hekim_kurum",   "metin", "Kurum", Genislik: 180),
            new("hekimIlce",   "z.hekim_ilce",    "metin", "İlçe", Genislik: 110),
            new("temsilciAd",  "z.temsilci_ad",   "metin", "Temsilci", Genislik: 160),
            new("subeAd",      "z.sube_ad",       "metin", "Şube", Genislik: 120, Varsayilan: false),
            new("turAd",       "z.tur_ad",        "metin", "Tür", Hizalama: "orta", Genislik: 110, Filtrelenebilir: false),
            new("amacAd",      "z.amac_ad",       "metin", "Amaç", Genislik: 150, Filtrelenebilir: false),
            new("sonucAd",     "z.sonuc_ad",      "metin", "Sonuç", Hizalama: "orta", Genislik: 130, Bicim: "rozet", Filtrelenebilir: false),
            new("sureDk",      "z.sure_dk",       "sayi",  "Süre (dk)", Hizalama: "sag", Genislik: 90, Varsayilan: false),
            new("notu",        "left(z.notu, 200)", "metin", "Not", Genislik: 320, Filtrelenebilir: false),
            new("konularAd",   "z.konular_ad",    "metin", "Konular", Genislik: 200, Filtrelenebilir: false),
            new("talepSayisi", "z.talep_sayisi",  "sayi",  "Talep", Hizalama: "sag", Genislik: 70, Filtrelenebilir: false),
            new("acikTalep",   "z.acik_talep",    "sayi",  "Açık Talep", Hizalama: "sag", Genislik: 90),
            new("sonrakiTarih","z.sonraki_tarih", "tarih", "Sonraki", Hizalama: "orta", Genislik: 100),
            new("yorumSayisi", "z.yorum_sayisi",  "sayi",  "Yorum", Hizalama: "sag", Genislik: 70, Varsayilan: false),
            new("gorulduAd",   "z.goruldu_ad",    "metin", "Gören", Genislik: 140, Varsayilan: false),
            new("goruldu",     "case when z.goruldu_id is null then 0 else 1 end", "mantik", "Görüldü",
                Hizalama: "orta", Genislik: 80),
            new("mobil",       "z.mobil",         "mantik", "Mobil", Hizalama: "orta", Genislik: 70, Varsayilan: false),
            new("tur",         "z.tur",           "kod",   "Tür Kodu", Varsayilan: false),
            new("amac",        "z.amac",          "kod",   "Amaç Kodu", Varsayilan: false),
            new("sonuc",       "z.sonuc",         "kod",   "Sonuç Kodu", Varsayilan: false),
            new("durum",       "z.durum",         "kod",   "Durum Kodu", Varsayilan: false, Kodlar: KartKatalogu.ZiyaretDurumKodlari),
            new("hekimId",     "z.hekim_id",      "sayi",  "Doktor Id", Varsayilan: false, BaslikErp: "Müşteri Id"),
            new("temsilciId",  "z.temsilci_id",   "sayi",  "Temsilci Id", Varsayilan: false),
            new("gorulduId",   "z.goruldu_id",    "sayi",  "Gören Id", Varsayilan: false),
        ]);

    /// <summary>
    /// ZİYARET VADESİ (1290, mockup §1 "Temsilci Paneli" ve §3 "Planı Üret" ölçütleri): hekim × şube × temsilci; sıklık,
    /// son ziyaret, vade, gecikme, planlı ziyaret, açık talep, gönderim düşüşü, sessiz gün. Buradan "Ziyaret Planla".
    /// Satır kimliği hekim id'dir (görünümde id yok) - kart açılmaz, aksiyonlar hekimId okur.
    /// </summary>
    private static KaynakTanimi DisHekimVade() => new(
        Ad: "dis-hekim-vade",
        YetkiKodu: "dis_doktor.vade",
        Kaynak: "public.v_dis_hekim_ziyaret_vade v",
        SubeKolonu: "v.sube_id",
        // Vade: satırın temsilcisi benim YA DA hekim benim (BenimHekimim, şube-bağımsız - hekim listesiyle aynı küme).
        RolKosullari: new Dictionary<string, string> { [RolKapsami.SahaTemsilci] = "v.temsilci_id = {kullanici} or " + RolKapsami.BenimHekimim("v.hekim_id") },
        VarsayilanSirala: "v.gecikme_gun desc, v.vade_tarihi nulls last, v.hekim_ad",
        Kolonlar:
        [
            new("id",            "v.hekim_id",       "sayi",  "Id", Varsayilan: false),
            new("hekimId",       "v.hekim_id",       "sayi",  "Doktor Id", Varsayilan: false, BaslikErp: "Müşteri Id"),
            new("hekimAd",       "v.hekim_ad",       "metin", "Dış Doktor", Genislik: 220, BaslikErp: "Müşteri"),
            new("hekimKurum",    "v.hekim_kurum",    "metin", "Kurum", Genislik: 170),
            new("hekimIlce",     "v.hekim_ilce",     "metin", "İlçe", Genislik: 100),
            new("temsilciAd",    "v.temsilci_ad",    "metin", "Temsilci", Genislik: 150),
            new("subeAd",        "v.sube_ad",        "metin", "Şube", Genislik: 110, Varsayilan: false),
            new("siklikHafta",   "v.siklik_hafta",   "sayi",  "Sıklık (hf)", Hizalama: "sag", Genislik: 90),
            new("sonZiyaret",    "v.son_ziyaret",    "tarih", "Son Ziyaret", Hizalama: "orta", Genislik: 110),
            new("vadeTarihi",    "v.vade_tarihi",    "tarih", "Sıradaki Ziyaret", Hizalama: "orta", Genislik: 100),
            new("gecikmeGun",    "v.gecikme_gun",    "sayi",  "Gecikme (gün)", Hizalama: "sag", Genislik: 100),
            new("planliTarih",   "v.planli_tarih",   "tarih", "Planlı", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 120),
            new("planliZiyaretId", "v.planli_ziyaret_id", "sayi", "Planlı Ziyaret Id", Varsayilan: false),
            new("acikTalep",     "v.acik_talep",     "sayi",  "Açık Talep", Hizalama: "sag", Genislik: 90),
            new("son30Istem",    "v.son30_istem",    "sayi",  "30 gün ist.", Hizalama: "sag", Genislik: 90, BaslikErp: "30 gün satış"),
            new("onceki30Istem", "v.onceki30_istem", "sayi",  "Önceki 30", Hizalama: "sag", Genislik: 90, Varsayilan: false),
            new("gonderimDusen", "v.gonderim_dusen", "mantik", "Gönderim ↓", Hizalama: "orta", Genislik: 90, BaslikErp: "Satış ↓"),
            new("sessizGun",     "v.sessiz_gun",     "sayi",  "Sessiz (gün)", Hizalama: "sag", Genislik: 100),
            new("yeniHekim",     "v.yeni_hekim",     "mantik", "Yeni", Hizalama: "orta", Genislik: 60, Varsayilan: false),
            new("satirRengi",    "case when v.gecikme_gun > 0 then 'kritik' when v.gonderim_dusen = 1 then 'uyari' else '' end",
                "metin", "Satır Rengi", Varsayilan: false, Filtrelenebilir: false),
            new("temsilciId",    "v.temsilci_id",    "sayi",  "Temsilci Id", Varsayilan: false),
            new("subeId",        "v.sube_id",        "sayi",  "Şube Id", Varsayilan: false),
        ]);

    private static KaynakTanimi DisHekimTalep() => new(
        Ad: "dis-hekim-talep",
        YetkiKodu: "dis_doktor.talep",
        Kaynak: "public.v_dis_hekim_talep t",
        SubeKolonu: "t.sube_id",
        RolKosullari: new Dictionary<string, string> { [RolKapsami.SahaTemsilci] = "t.temsilci_id = {kullanici} or " + RolKapsami.BenimHekimim("t.hekim_id") },
        VarsayilanSirala: "case when t.durum in (1, 2) then 0 else 1 end, t.termin nulls last, t.id desc",
        Kolonlar:
        [
            new("id",          "t.id",            "sayi",  "Id", Varsayilan: false),
            new("hekimAd",     "t.hekim_ad",      "metin", "Dış Doktor", Genislik: 220, BaslikErp: "Müşteri"),
            new("hekimKurum",  "t.hekim_kurum",   "metin", "Kurum", Genislik: 160, Varsayilan: false),
            new("turAd",       "t.tur_ad",        "metin", "Tür", Hizalama: "orta", Genislik: 110, Filtrelenebilir: false),
            new("talep",       "t.talep",         "metin", "Talep", Genislik: 320),
            new("oncelikAd",   "t.oncelik_ad",    "metin", "Öncelik", Hizalama: "orta", Genislik: 90, Bicim: "rozet", Filtrelenebilir: false),
            new("sorumluAd",   "t.sorumlu_ad",    "metin", "Sorumlu", Genislik: 160),
            new("termin",      "t.termin",        "tarih", "Termin", Hizalama: "orta", Genislik: 100),
            new("gecikmeGun",  "t.gecikme_gun",   "sayi",  "Gecikme (gün)", Hizalama: "sag", Genislik: 100),
            // TERMİNİ GEÇEN KIRMIZI (mockup): satır rengi sunucudan.
            new("satirRengi",  "case when t.gecikme_gun > 0 then 'kritik' when t.oncelik = 3 and t.durum in (1, 2) then 'uyari' else '' end",
                "metin", "Satır Rengi", Varsayilan: false, Filtrelenebilir: false),
            new("durumAdi",    "t.durum_ad",      "metin", "Durum", Hizalama: "orta", Genislik: 100, Bicim: "rozet", Filtrelenebilir: false),
            new("temsilciAd",  "t.temsilci_ad",   "metin", "Temsilci", Genislik: 150),
            new("sonuc",       "t.sonuc",         "metin", "Sonuç / Yanıt", Genislik: 240),
            new("ziyaretTarihi","t.ziyaret_tarihi","tarih", "Ziyaret", Hizalama: "orta", Bicim: "dd.MM.yyyy", Genislik: 100, Varsayilan: false),
            new("gorevId",     "t.gorev_id",      "sayi",  "Görev", Hizalama: "sag", Genislik: 80, Varsayilan: false),
            new("tur",         "t.tur",           "kod",   "Tür Kodu", Varsayilan: false),
            new("durum",       "t.durum",         "kod",   "Durum Kodu", Varsayilan: false),
            new("oncelik",     "t.oncelik",       "kod",   "Öncelik Kodu", Varsayilan: false, Kodlar: KartKatalogu.TalepOncelikKodlari),
            new("hekimId",     "t.hekim_id",      "sayi",  "Doktor Id", Varsayilan: false, BaslikErp: "Müşteri Id"),
            new("ziyaretId",   "t.ziyaret_id",    "sayi",  "Ziyaret Id", Varsayilan: false),
            new("sorumluId",   "t.sorumlu_id",    "sayi",  "Sorumlu Id", Varsayilan: false),
        ]);

    /// <summary>
    /// ZİYARET EDİLEN TARAF (1297, kullanıcı: "hbys de dış doktorlar, erp de ise müşteriler ziyaret edilir"): ziyaret /
    /// talep kartının arama kaynağı ve plan ekranının seçimi. Kip DB'de çözülür (fn_urun_modu): HBYS dış doktor,
    /// ERP müşteri, 3 ikisi. Temsilci yalnız kendi hedeflerini arar (RolKapsami.BenimHekimim).
    /// </summary>
    private static KaynakTanimi SahaHedef() => new(
        Ad: "saha-hedef",
        YetkiKodu: "dis_doktor.ziyaret",
        Kaynak: """
            public.taraf t
            left join public.taraf_personel po on po.id = t.id
            left join public.taraf k on k.id = t.bag_id
            """,
        SabitKosul: "coalesce(t.durum, 1) = 1 and ((coalesce(po.dis_hekim, 0) = 1 and public.fn_urun_modu(0) <> 1)"
                  + " or (t.musteri = 1 and t.personel = 0 and public.fn_urun_modu(0) <> 2))",
        VarsayilanSirala: "public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) asc",
        SubeKolonu: null,
        RolKosullari: new Dictionary<string, string> { [RolKapsami.SahaTemsilci] = RolKapsami.BenimHekimim("t.id") },
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "t.id",  "sayi",  "Id", Varsayilan: false),
            new("kod",     "t.kod", "metin", "Kod", Varsayilan: false),
            new("unvan",
                "coalesce(nullif(btrim(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)), ''), "
                + "btrim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')))",
                "metin", "Dış Doktor", Genislik: 240, BaslikErp: "Müşteri"),
            new("kurum",   "coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), '')", "metin", "Kurum", Genislik: 200),
            new("ilce",
                "coalesce((select a.ilce from public.taraf_adres a where a.taraf_id = t.id and coalesce(a.aktif, 1) = 1"
                + " order by a.varsayilan desc, a.id limit 1), '')",
                "metin", "İlçe", Genislik: 120),
            new("cepTel",  "coalesce(t.cep_tel, t.telefon, '')", "metin", "Telefon", Genislik: 130),
            new("temsilci",
                "coalesce((select public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120) from public.taraf p"
                + " where p.id = public.fn_dis_hekim_temsilci(t.id, t.sube_id, current_date)), '')",
                "metin", "Temsilci", Genislik: 160, Filtrelenebilir: false, Siralanabilir: false),
        });
}
