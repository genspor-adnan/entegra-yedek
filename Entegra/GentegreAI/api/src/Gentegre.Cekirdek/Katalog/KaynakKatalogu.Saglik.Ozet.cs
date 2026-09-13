namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HASTA ÖZET LİSTELERİ — kronik tanı, geçmiş olay, tıbbi özet.
///
/// KaynakKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1183 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// HASTA KRONİK TANILARI (420).
    ///
    /// Muayenede "kronik" işaretlenen tanı buraya TETİKLE düşer. Hekime
    /// "bir de tıbbi özete ekle" dedirtmek, unutulduğunda bir sonraki hekimin
    /// eksik bilgiyle karar vermesi demekti.
    /// </summary>
    private static KaynakTanimi HastaKronikTani() => new(
        Ad: "hasta-kronik",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_kronik_tani k "
              + "  join public.taraf h on h.id = k.hasta_id "
              + "  left join public.v_personel_lookup p on p.id = k.takip_hekim_id",
        VarsayilanSirala: "k.durum asc, k.baslangic asc nulls last",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",       "sayi",  "Id", Varsayilan: false),
            new("hastaAdi", "h.unvan",    "metin", "Hasta", Genislik: 200),
            new("icdKod",   "k.icd_kod",  "metin", "ICD", Hizalama: "orta", Genislik: 90),
            new("taniAd",   "k.tani_ad",  "metin", "Tanı", Genislik: 300),
            new("baslangic","k.baslangic","tarih", "Başlangıç", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy", Genislik: 110),
            new("takipHekim","coalesce(p.ad, '')", "metin", "Takip Eden", Genislik: 170),
            new("durumAdi",
                "case k.durum when 2 then 'Kontrol Altında' when 3 then 'Geçmiş' "
                + "else 'Aktif' end",
                                          "metin", "Durum", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 130,
                                          Filtrelenebilir: false),
            new("durum",    "k.durum",    "kod",   "Durum Kodu", Varsayilan: false),
            new("kaynakAdi",
                "case k.kaynak when 2 then 'Hasta Beyanı' when 3 then 'e-Nabız' "
                + "when 4 then 'Dış Kurum' else 'Hekim' end",
                                          "metin", "Kaynak", Hizalama: "orta",
                                          Genislik: 120, Varsayilan: false),
            new("hastaId",  "k.hasta_id", "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>HASTA GEÇMİŞ OLAYLARI (420) — ameliyat · girişim · yatış · aşı.</summary>
    private static KaynakTanimi HastaGecmisOlay() => new(
        Ad: "hasta-gecmis",
        YetkiKodu: "muayene",
        Kaynak: "public.hasta_gecmis_olay o join public.taraf h on h.id = o.hasta_id",
        VarsayilanSirala: "o.tarih desc nulls last, o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "o.id",       "sayi",  "Id", Varsayilan: false),
            new("hastaAdi", "h.unvan",    "metin", "Hasta", Genislik: 200),
            new("turAdi",
                "case o.tur when 2 then 'Girişim' when 3 then 'Yatış' when 4 then 'Aşı' "
                + "when 5 then 'Travma' when 6 then 'Transfüzyon' else 'Ameliyat' end",
                                          "metin", "Tür", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 120,
                                          Filtrelenebilir: false),
            new("tur",      "o.tur",      "kod",   "Tür Kodu", Varsayilan: false),
            new("ad",       "o.ad",       "metin", "Olay", Genislik: 280),
            new("tarih",    "o.tarih",    "tarih", "Tarih", Hizalama: "orta",
                                          Bicim: "dd.MM.yyyy", Genislik: 110),
            new("kurum",    "o.kurum",    "metin", "Kurum", Genislik: 180),
            new("notMetni", "o.not_metni","metin", "Not", Genislik: 260, Varsayilan: false),
            new("hastaId",  "o.hasta_id", "sayi",  "Hasta Id", Varsayilan: false)
        });

    /// <summary>
    /// HASTA TIBBİ ÖZETİ (420) — tek satırda alerji/kronik/ilaç sayıları.
    ///
    /// Muayene kartının üst şeridi ve Tıbbi Özet ekranı AYNI kaynağı okur:
    /// iki ayrı sorgu, iki farklı "aktif ilaç" tanımı üretirdi.
    /// </summary>
    private static KaynakTanimi HastaTibbiOzet() => new(
        Ad: "hasta-tibbi-ozet",
        YetkiKodu: "muayene",
        Kaynak: "public.v_hasta_tibbi_ozet o join public.taraf h on h.id = o.hasta_id",
        VarsayilanSirala: "o.son_muayene desc nulls last, h.unvan asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "o.hasta_id",     "sayi",  "Id", Varsayilan: false),
            new("hastaAdi",     "h.unvan",        "metin", "Hasta", Genislik: 220),
            new("dosyaNo",      "h.kod",          "metin", "Dosya No", Hizalama: "orta",
                                                  Genislik: 110),
            new("tcNo",         "coalesce(h.vkno, '')", "metin", "T.C. No", Hizalama: "orta",
                                                  Genislik: 110, Varsayilan: false),
            // AGIR ALERJI ayri kolon: listede "1 alerji" ile "anafilaksi"
            //   arasindaki fark, hekimin ilk bakisi icin belirleyici.
            new("agirAlerji",   "o.agir_alerji",  "sayi",  "Ağır Alerji", Hizalama: "orta",
                                                  Genislik: 100),
            new("alerjiSayisi", "o.alerji_sayisi","sayi",  "Alerji", Hizalama: "orta",
                                                  Genislik: 80),
            new("alerjiler",    "coalesce(o.alerjiler, '')", "metin", "Alerjiler",
                                                  Genislik: 240),
            new("kronikSayisi", "o.kronik_sayisi","sayi",  "Kronik", Hizalama: "orta",
                                                  Genislik: 80),
            new("kronikTanilar","coalesce(o.kronik_tanilar, '')", "metin", "Kronik Tanılar",
                                                  Genislik: 300),
            new("aktifIlac",    "o.aktif_ilac",   "sayi",  "Aktif İlaç", Hizalama: "orta",
                                                  Genislik: 100),
            new("gecmisOlay",   "o.gecmis_olay",  "sayi",  "Geçmiş Olay", Hizalama: "orta",
                                                  Genislik: 110, Varsayilan: false),
            new("sonMuayene",   "o.son_muayene",  "tarih", "Son Muayene", Hizalama: "orta",
                                                  Bicim: "dd.MM.yyyy", Genislik: 120)
        });
}
