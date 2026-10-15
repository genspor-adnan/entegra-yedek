namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// SEVK LİSTESİ (1110) — mockup Ekranlar/Muayene/sevk_listesi_v2.html (sade).
///
/// Altı sütun: saat, hasta, tür, nereye, not, durum. "Giden / Gelen" sekmeleri ekranın
/// süzgecidir (hekimId / bolumId / hedefBolumId gizli kolonlarına; kullanıcı ve bölümleri
/// /api/sevk/kapsam'dan). Yeni üstte.
/// </summary>
public static partial class KaynakKatalogu
{
    internal static readonly Dictionary<string, string> SevkTurKodlari = new()
        { ["1"] = "Kurum dışı", ["2"] = "Kurum içi", ["3"] = "Yatış" };

    internal static readonly Dictionary<string, string> SevkDurumKodlari = new()
        { ["1"] = "Taslak", ["2"] = "Gönderildi", ["3"] = "Sonuç döndü", ["9"] = "Gönderilemedi", ["0"] = "İptal" };

    internal static readonly Dictionary<string, string> SevkUlasimKodlari = new()
        { ["1"] = "Kendi", ["2"] = "Ambulans", ["3"] = "112" };

    /// <summary>Muayenenin sevk nedeni kodlarıyla aynı (465).</summary>
    internal static readonly Dictionary<string, string> SevkNedenKodlari = new()
    {
        ["1"] = "İleri tetkik / tedavi", ["2"] = "Yatak yok", ["3"] = "Uzman hekim yok",
        ["4"] = "Cihaz yok / arızalı", ["5"] = "Hasta / yakını talebi", ["9"] = "Diğer",
    };

    /// <summary>Nereye: kurum dışında "tesis · klinik", kurum içinde / yatışta bölüm.</summary>
    public const string SevkNereyeSql =
        "case when s.tur = 1 then nullif(trim(coalesce(nullif(s.tesis_ad, ''), s.tesis_kodu) "
        + "  || coalesce(' · ' || (select d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id "
        + "                         where l.kod = 'klinik.kod' and d.dil = 0 and d.deger = s.klinik_id), '')), '') "
        + "else (select x.ad from public.departman x where x.id = s.hedef_bolum_id) end";

    private static KaynakTanimi Sevk() => new(
        Ad: "sevk",
        YetkiKodu: "muayene.sevk",
        Kaynak: "public.sevk s "
              + "  join public.taraf h on h.id = s.taraf_id "
              + "  left join public.taraf_hasta th on th.id = h.id "
              + "  left join public.taraf hk on hk.id = s.hekim_id "
              + "  left join public.departman b on b.id = s.bolum_id",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "s.sevk_zamani desc, s.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "s.id",          "sayi",  "Id", Varsayilan: false),
            new("no",         "s.no",          "metin", "No", Hizalama: "orta", Genislik: 110, Varsayilan: false),
            // SAAT OTURUMUN (şube) DİLİMİNDE metin (konsültasyon listesi gibi).
            new("saat",       "to_char(s.sevk_zamani, 'DD.MM HH24:MI')", "metin", "Saat", Hizalama: "orta", Genislik: 90,
                Filtrelenebilir: false, Siralanabilir: false),
            new("sevkZamani", "s.sevk_zamani", "tarih", "Sevk Zamanı", Hizalama: "orta", Bicim: "dd.MM HH:mm", Varsayilan: false),
            new("hastaAdi",
                "public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120) || "
                + "coalesce(' · ' || nullif(trim(case coalesce(th.cinsiyet, 0) when 1 then 'E' when 2 then 'K' else '' end || ' ' || "
                + "coalesce(extract(year from age(th.dogum_tarihi))::int::text, '')), ''), '')",
                "metin", "Hasta", Genislik: 170),
            new("tarafId",    "s.taraf_id",    "sayi",  "Hasta Id", Varsayilan: false),
            new("turAdi",
                "case s.tur when 1 then 'Kurum dışı' when 2 then 'Kurum içi' else 'Yatış' end",
                "metin", "Tür", Hizalama: "orta", Genislik: 95, Filtrelenebilir: false),
            new("tur",        "s.tur",         "kod",   "Tür Kodu", Varsayilan: false, Kodlar: SevkTurKodlari),
            new("nereye",     "coalesce(" + SevkNereyeSql + ", '')", "metin", "Nereye", Genislik: 220, Filtrelenebilir: false),
            new("notu",       "s.notu",        "metin", "Not", Genislik: 260),
            new("durumAdi",
                "case s.durum when 1 then 'Taslak' when 2 then 'Gönderildi' when 3 then 'Sonuç döndü' "
                + "when 9 then 'Gönderilemedi' when 0 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet", Filtrelenebilir: false),
            new("durum",      "s.durum",       "kod",   "Durum Kodu", Varsayilan: false, Kodlar: SevkDurumKodlari),
            new("hekim",      "coalesce(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::varchar(120), '')", "metin", "Hekim", Genislik: 150, Varsayilan: false),
            new("bolum",      "coalesce(b.ad, '')", "metin", "Bölüm", Genislik: 130, Varsayilan: false),
            new("ulasimAdi",  "case s.ulasim when 3 then '112' when 2 then 'Ambulans' else 'Kendi' end", "metin", "Ulaşım",
                Hizalama: "orta", Varsayilan: false, Filtrelenebilir: false),
            new("medulaSevkNo", "s.medula_sevk_no", "metin", "Medula Sevk No", Varsayilan: false),
            new("hekimId",      "s.hekim_id",       "sayi", "Hekim Id", Varsayilan: false),
            new("bolumId",      "s.bolum_id",       "sayi", "Bölüm Id", Varsayilan: false),
            new("hedefBolumId", "s.hedef_bolum_id", "sayi", "Hedef Bölüm Id", Varsayilan: false),
            new("muayeneId",    "s.muayene_id",     "sayi", "Muayene Id", Varsayilan: false),
            new("acik",         "(s.durum in (1, 2, 9))::int", "sayi", "Açık", Varsayilan: false),
            // SATIR RENGİ: gönderilemedi kırmızı, taslak sarı, kapanan soluk.
            new("satirRengi",
                "case when s.durum = 9 then 'kritik' when s.durum = 1 then 'uyari' when s.durum in (3, 0) then 'pasif' else '' end",
                "metin", "", Varsayilan: false, Filtrelenebilir: false),
        });
}
