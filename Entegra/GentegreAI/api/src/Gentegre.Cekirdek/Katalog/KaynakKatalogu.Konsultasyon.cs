namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KONSÜLTASYON ÇALIŞMA LİSTESİ (1107) — mockup Ekranlar/Muayene/konsultasyon_listesi.html.
///
/// Konsültan hekimin listesi: "bana / bölümüme gelen", "istediklerim", "bölüm geneli"
/// sekmeleri ekranın süzgecidir (hedefHekimId / hedefBolumId / isteyenHekimId gizli
/// kolonlarına). Kalan süre ve satır rengi SUNUCUDA - liste ile özet kutuları aynı
/// "şimdi"yi kullanır. Terim "yanıtla"dır (kullanıcı: "üstlenme yerine yanıtlama").
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> KonsAciliyetKodlari = new()
        { ["1"] = "Rutin", ["2"] = "Acil", ["3"] = "Çok acil" };

    internal static readonly Dictionary<string, string> KonsDurumKodlari = new()
    {
        ["6"] = "Taslak", ["1"] = "Yanıt bekliyor", ["2"] = "Yanıtlanıyor", ["3"] = "Yanıtlandı",
        ["4"] = "İsteyen gördü", ["9"] = "Reddedildi", ["0"] = "İptal",
    };

    internal static readonly Dictionary<string, string> KonsKarsilamaKodlari = new()
    {
        ["1"] = "Yatak başı", ["2"] = "Konsültan polikliniği", ["3"] = "İsteyen poliklinik",
        ["4"] = "Acil servis", ["5"] = "Görüntüleme / tetkik odası", ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> KonsNedenKodlari = new()
    {
        ["1"] = "Tanı / tedavi önerisi", ["2"] = "Ameliyat öncesi değerlendirme",
        ["3"] = "Devir / nakil değerlendirmesi", ["4"] = "Görüntüleme / tetkik yorumu",
        ["5"] = "Acil değerlendirme", ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> KonsSonucKodlari = new()
    {
        ["0"] = "—", ["1"] = "Engel yok / önerilerle", ["2"] = "Ertelenmeli",
        ["3"] = "Devralınmalı (nakil)", ["4"] = "Takip edeceğim",
    };

    internal static readonly Dictionary<string, string> KonsMerkezKodlari = new()
        { ["1"] = "Kurum içi", ["2"] = "Dış merkez" };

    /// <summary>Açık istem: yanıt bekliyor ya da yanıtlanıyor.</summary>
    private const string KonsAcik = "k.durum in (1, 2)";

    /// <summary>Kalan (açık) ya da geçen (kapalı: istek → yanıt) süre metni.</summary>
    private const string KonsSureSql =
        "case when k.durum in (1, 2) then "
        + "  case when k.son_zaman < now() then '+' else '' end || "
        + "  public.fn_kons_sure_metni(abs(extract(epoch from (k.son_zaman - now())) / 60)::int) "
        + "when k.yanit_zamani is not null then "
        + "  public.fn_kons_sure_metni((extract(epoch from (k.yanit_zamani - k.istek_zamani)) / 60)::int) "
        + "else '' end";

    private static KaynakTanimi Konsultasyon() => new(
        Ad: "konsultasyon",
        // KAYIT KAPSAMI (kod inceleme 30.10.2026 K42): kullanici_kapsam tanimli kullanici yalniz kapsamindaki hastayi gorur.
        KapsamKolonu: "k.taraf_id",
        YetkiKodu: "muayene.konsultasyon",
        Kaynak: "public.konsultasyon k "
              + "  join public.taraf h on h.id = k.taraf_id "
              + "  left join public.taraf_hasta th on th.id = h.id "
              + "  left join public.taraf ih on ih.id = k.isteyen_hekim_id "
              + "  left join public.taraf hh on hh.id = k.hedef_hekim_id "
              + "  left join public.taraf yh on yh.id = k.yanitlayan_id "
              + "  left join public.departman ib on ib.id = k.istek_bolum_id "
              + "  left join public.departman hb on hb.id = k.hedef_bolum_id",
        SubeKolonu: "k.sube_id",
        // AÇIK ÖNCE, ACİLİYET VE KALAN SÜREYE GÖRE (mockup notu: eski üründe istek
        //   saatine göre sıralıydı, çok acil istem rutinlerin altında kalıyordu).
        VarsayilanSirala: "case when k.durum in (1, 2) then 0 else 1 end, k.aciliyet desc, k.son_zaman, k.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "k.id",           "sayi",  "Id", Varsayilan: false),
            new("no",          "k.no",           "metin", "No", Hizalama: "orta", Genislik: 115, Varsayilan: false),
            new("aciliyetAdi",
                "case k.aciliyet when 3 then 'Çok acil' when 2 then 'Acil' else 'Rutin' end",
                "metin", "Aciliyet", Hizalama: "orta", Genislik: 90, Bicim: "rozet", Filtrelenebilir: false),
            new("aciliyet",    "k.aciliyet",     "kod",   "Aciliyet Kodu", Varsayilan: false, Kodlar: KonsAciliyetKodlari),
            new("sure",        KonsSureSql,      "metin", "Kalan / geçen", Hizalama: "orta", Genislik: 100,
                Filtrelenebilir: false, Siralanabilir: false),
            // KALAN DAKİKA eksiye düşebilir - gecikme saklanmaz.
            new("kalanDk",     "case when " + KonsAcik + " then (extract(epoch from (k.son_zaman - now())) / 60)::int end",
                "sayi", "Kalan (dk)", Hizalama: "sag", Varsayilan: false),
            // SAAT OTURUMUN (şube) DİLİMİNDE metin: tarih kolonu ham UTC damgasını keserek gösterirdi.
            new("istekSaat",   "to_char(k.istek_zamani, 'DD.MM HH24:MI')", "metin", "İstek", Hizalama: "orta", Genislik: 90,
                Filtrelenebilir: false, Siralanabilir: false),
            new("istekZamani", "k.istek_zamani", "tarih", "İstek Zamanı", Hizalama: "orta", Bicim: "dd.MM HH:mm", Genislik: 95, Varsayilan: false),
            new("hastaAdi",
                "public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120) || "
                + "coalesce(' · ' || nullif(trim(case coalesce(th.cinsiyet, 0) when 1 then 'E' when 2 then 'K' else '' end || ' ' || "
                + "coalesce(extract(year from age(th.dogum_tarihi))::int::text, '')), ''), '')",
                "metin", "Hasta", Genislik: 170),
            new("tarafId",     "k.taraf_id",     "sayi",  "Hasta Id", Varsayilan: false),
            new("nerede",      "coalesce(ib.ad, '')", "metin", "Nerede", Genislik: 130),
            new("isteyen",
                "coalesce(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::varchar(120), '')",
                "metin", "İsteyen", Genislik: 150),
            new("soru",        "k.soru",         "metin", "Soru", Genislik: 240),
            // HEDEF: hekim seçildiyse hekim, değilse bölüm ("· bölüm").
            new("hedef",
                "case when k.merkez = 2 then '🏥 ' || k.dis_merkez "
                + "when k.hedef_hekim_id is not null then public.fn_taraf_ad(hh.unvan, hh.ad, hh.soyad)::varchar(120) "
                + "else coalesce(hb.ad, '') || ' · bölüm' end",
                "metin", "Hedef", Genislik: 160, Filtrelenebilir: false),
            new("karsilamaYeriAdi",
                "case k.karsilama_yeri when 1 then 'Yatak başı' when 2 then 'Konsültan polikliniği' "
                + "when 3 then 'İsteyen poliklinik' when 4 then 'Acil servis' when 5 then 'Görüntüleme / tetkik odası' else 'Diğer' end",
                "metin", "Karşılama yeri", Genislik: 130, Filtrelenebilir: false),
            new("durumAdi",
                "case k.durum when 6 then 'Taslak' when 1 then 'Yanıt bekliyor' "
                + "when 2 then 'Yanıtlanıyor · ' || to_char(k.yanitlama_zamani, 'HH24:MI') "
                + "     || coalesce(' (' || public.fn_taraf_ad(yh.unvan, yh.ad, yh.soyad)::varchar(120) || ')', '') "
                + "when 3 then 'Yanıtlandı · ' || coalesce(to_char(k.yanit_zamani, 'HH24:MI'), '') "
                + "when 4 then 'İsteyen gördü' when 9 then 'Reddedildi' when 0 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 175, Bicim: "rozet", Filtrelenebilir: false),
            new("durum",       "k.durum",        "kod",   "Durum Kodu", Varsayilan: false, Kodlar: KonsDurumKodlari),
            new("enabiz",
                "(exists (select 1 from public.enabiz_paket p join public.enabiz_paket_turu t on t.id = p.paket_turu_id "
                + "where t.kod = 'KONSULTASYON' and p.kaynak_id = k.yanit_muayene_id and p.durum = 3))::int",
                "mantik", "e-Nabız", Hizalama: "orta", Genislik: 70, Varsayilan: false),
            new("hedefBolumId",   "k.hedef_bolum_id",   "sayi", "Hedef Bölüm Id", Varsayilan: false),
            new("hedefHekimId",   "k.hedef_hekim_id",   "sayi", "Hedef Hekim Id", Varsayilan: false),
            new("isteyenHekimId", "k.isteyen_hekim_id", "sayi", "İsteyen Hekim Id", Varsayilan: false),
            new("yanitlayanId",   "k.yanitlayan_id",    "sayi", "Yanıtlayan Id", Varsayilan: false),
            new("yanitMuayeneId", "k.yanit_muayene_id", "sayi", "Yanıt Muayene Id", Varsayilan: false),
            new("isteyenMuayeneId", "k.isteyen_muayene_id", "sayi", "İsteyen Muayene Id", Varsayilan: false),
            new("merkez",         "k.merkez",           "kod",  "Merkez", Varsayilan: false, Kodlar: KonsMerkezKodlari),
            new("acik",           "(" + KonsAcik + ")::int", "sayi", "Açık", Varsayilan: false),
            new("sureGecti",      "(" + KonsAcik + " and k.son_zaman < now())::int", "sayi", "Süresi geçen", Varsayilan: false),
            // SATIR RENGİ (mockup): süre geçti kırmızı, son çeyrek sarı; kapanan iş soluk.
            new("satirRengi",
                "case when k.durum in (3, 4, 9, 0) then 'pasif' "
                + "when k.durum = 6 then '' "
                + "when k.son_zaman < now() then 'kritik' "
                + "when (k.son_zaman - now()) * 4 <= (k.son_zaman - k.istek_zamani) then 'uyari' else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });
}
