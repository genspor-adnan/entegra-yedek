namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// TÜRKİYE KLİNİK KALİTE PROGRAMI (711) — üç liste:
///   `klinikGosterge`     rehberin gösterge kataloğu (16 olgu · 217 gösterge)
///   `klinikGostergeDonem` kurumun şube + dönem ölçümü
///   `klinikGostergeKod`  kod havuzu: bir ICD/SUT/ATC kodu hangi göstergeyi besliyor
///
/// KATALOG ŞUBESİZDİR: gösterge tanımı Bakanlığın, kurumun değil. Şube kolonu
/// koysaydık her şube kendi gösterge listesini düzenleyebilir ve kurumlar arası
/// kıyaslama - programın tek varlık sebebi - biterdi. Şube yalnız ÖLÇÜMDE var.
///
/// KOD SAYILARI SQL'DE ÜRETİLİR (alt sorgu), istemci saymaz: liste sayfalı
/// geldiği için istemci yalnız gördüğü satırları sayabilirdi ve "bu göstergede
/// kaç ICD kodu var" sorusu sayfa değiştikçe farklı yanıt verirdi.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Gösterge kataloğu. Hedef hem rehber metni hem ayrıştırılmış değer.</summary>
    private static KaynakTanimi KlinikGosterge() => new(
        Ad: "klinikGosterge",
        YetkiKodu: "klinik_kalite",
        Kaynak: "public.klinik_gosterge g join public.klinik_olgu o on o.id = g.olgu_id",
        VarsayilanSirala: "o.sira, g.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "g.id",   "sayi",  "Id", Varsayilan: false),
            new("olguId",   "o.id",   "sayi",  "Olgu Id", Varsayilan: false),
            new("olguKod",  "o.kod",  "metin", "Olgu", Hizalama: "orta", Genislik: 60),
            new("olguAd",   "o.ad",   "metin", "Sağlık Olgusu", Genislik: 190),
            new("kod",      "g.kod",  "metin", "Gösterge Kodu", Genislik: 110),
            new("ad",       "g.ad",   "metin", "Gösterge", Genislik: 430),
            new("izlem",    "g.izlem", "metin", "İzlem", Hizalama: "orta", Genislik: 70),
            new("standartMetin", "g.standart_metin", "metin", "Standart",
                Genislik: 320, Varsayilan: false),
            new("hedefMetin", "g.hedef_metin", "metin", "Hedef", Hizalama: "orta", Genislik: 90),
            // Kurum kendi hedefini girmediyse rehberin hedefi gecerlidir; liste
            //   hangisinin yururlukte oldugunu gostersin diye birlestirilir.
            new("gecerliHedef",
                // FM maskesi ondalik kismi bos olan sayida sondaki NOKTAYI birakiyor
                //   ("95." gibi); okunmasi rahatsiz, kirpiliyor.
                "case when g.kurum_hedef_deger is not null" +
                " then g.kurum_hedef_yon || ' ' ||" +
                "      rtrim(trim(to_char(g.kurum_hedef_deger, 'FM999990.99')), '.')" +
                " else coalesce(g.hedef_metin, '') end",
                "metin", "Geçerli Hedef", Hizalama: "orta", Genislik: 110,
                Siralanabilir: false, Filtrelenebilir: false),
            new("icdSayi",
                "(select count(*) from public.klinik_gosterge_kod k" +
                " where k.gosterge_id = g.id and k.tip = 'icd10')",
                "sayi", "ICD", Hizalama: "sag", Genislik: 55,
                Siralanabilir: false, Filtrelenebilir: false),
            new("sutSayi",
                "(select count(*) from public.klinik_gosterge_kod k" +
                " where k.gosterge_id = g.id and k.tip = 'sut')",
                "sayi", "SUT", Hizalama: "sag", Genislik: 55,
                Siralanabilir: false, Filtrelenebilir: false),
            new("atcSayi",
                "(select count(*) from public.klinik_gosterge_kod k" +
                " where k.gosterge_id = g.id and k.tip = 'atc')",
                "sayi", "ATC", Hizalama: "sag", Genislik: 55,
                Siralanabilir: false, Filtrelenebilir: false),
            new("veriKaynagiAdi",
                "case g.otomatik when 1 then 'Otomatik' else 'Elle giriş' end",
                "metin", "Veri Kaynağı", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("otomatik", "g.otomatik", "kod", "Veri Kaynağı Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkOtomatikKodlari),
            new("periyotAdi",
                "case g.periyot when 3 then '3 aylık' when 6 then '6 aylık'" +
                " when 12 then 'Yıllık' else '' end",
                "metin", "Periyot", Hizalama: "orta", Genislik: 90,
                Siralanabilir: false, Filtrelenebilir: false),
            new("periyot", "g.periyot", "kod", "Periyot Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkPeriyotKodlari),
            new("rehberSurum", "g.rehber_surum", "metin", "Rehber", Hizalama: "orta",
                Genislik: 80, Varsayilan: false),
            new("aktif", "g.aktif", "kod", "Durum Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkAktifKodlari),
        });

    /// <summary>
    /// Dönem ölçümü. `durum` SQL'de hedefle karşılaştırılarak üretilir -
    /// istemci eşiği yeniden uygulamaz, yoksa liste ile kart farklı renk gösterirdi.
    /// "Sınırda" hedefin %5'i içinde kalanlar: hedefi henüz aşmamış ama aşmak
    /// üzere olanı yeşile boyamak iyileştirme fırsatını gizler.
    /// </summary>
    private static KaynakTanimi KlinikGostergeDonem() => new(
        Ad: "klinikGostergeDonem",
        YetkiKodu: "klinik_kalite.donem",
        Kaynak: "public.klinik_gosterge_donem d" +
                " join public.klinik_gosterge g on g.id = d.gosterge_id" +
                " join public.klinik_olgu o on o.id = g.olgu_id",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.donem_yil desc, d.donem_no desc, o.sira, g.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "d.id",   "sayi",  "Id", Varsayilan: false),
            new("gostergeId", "d.gosterge_id", "sayi", "Gösterge Id", Varsayilan: false),
            new("olguKod",    "o.kod",  "metin", "Olgu", Hizalama: "orta", Genislik: 60),
            new("olguAd",     "o.ad",   "metin", "Sağlık Olgusu", Genislik: 170),
            new("kod",        "g.kod",  "metin", "Gösterge Kodu", Genislik: 110),
            new("ad",         "g.ad",   "metin", "Gösterge", Genislik: 380),
            new("donemYil",   "d.donem_yil", "sayi", "Yıl", Hizalama: "orta", Genislik: 65),
            new("donemNo",    "d.donem_no",  "sayi", "Dönem", Hizalama: "orta", Genislik: 65),
            new("periyotAdi",
                "case d.periyot when 3 then '3 aylık' when 6 then '6 aylık'" +
                " when 12 then 'Yıllık' else '' end",
                "metin", "Periyot", Hizalama: "orta", Genislik: 85,
                Siralanabilir: false, Filtrelenebilir: false),
            new("periyot",  "d.periyot", "kod", "Periyot Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkPeriyotKodlari),
            new("pay",      "d.pay",    "sayi", "Pay",   Hizalama: "sag", Bicim: "#,##0.##"),
            new("payda",    "d.payda",  "sayi", "Payda", Hizalama: "sag", Bicim: "#,##0.##"),
            new("sonuc",    "d.sonuc",  "sayi", "Sonuç", Hizalama: "sag", Bicim: "#,##0.##"),
            new("hedefMetin",
                "case when d.hedef_deger is null then ''" +
                " else d.hedef_yon || ' ' ||" +
                "      rtrim(trim(to_char(d.hedef_deger, 'FM999990.99')), '.') end",
                "metin", "Hedef", Hizalama: "orta", Genislik: 90,
                Siralanabilir: false, Filtrelenebilir: false),
            new("durumAdi",
                // PAYDA 0 ONCE BAKILIR: o donem hic vaka yoksa sonuc 0 cikar ve
                //   ">= %95" hedefi otomatik olarak "hedef disi" gorunurdu -
                //   kurum hicbir sey yapmadigi icin kirmiziya boyanmis olurdu.
                "case when d.payda = 0 then 'Vaka yok'" +
                "     when d.hedef_deger is null then 'Hedefsiz'" +
                "     when (d.hedef_yon = '<=' and d.sonuc <= d.hedef_deger)" +
                "       or (d.hedef_yon = '<'  and d.sonuc <  d.hedef_deger)" +
                "       or (d.hedef_yon = '>=' and d.sonuc >= d.hedef_deger)" +
                "       or (d.hedef_yon = '>'  and d.sonuc >  d.hedef_deger)" +
                "     then case when abs(d.sonuc - d.hedef_deger)" +
                "                  <= abs(d.hedef_deger) * 0.05 then 'Sınırda' else 'Hedefte' end" +
                "     else 'Hedef dışı' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Siralanabilir: false, Filtrelenebilir: false),
            new("kayitDurumAdi",
                "case d.durum when 1 then 'Kesinleşti' else 'Taslak' end",
                "metin", "Kayıt", Hizalama: "orta", Genislik: 95, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum",  "d.durum",  "kod", "Kayıt Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkDonemDurumKodlari),
            new("kaynakAdi",
                "case d.kaynak when 1 then 'Elle' else 'Otomatik' end",
                "metin", "Kaynak", Hizalama: "orta", Genislik: 90,
                Siralanabilir: false, Filtrelenebilir: false),
            new("kaynak",   "d.kaynak", "kod", "Kaynak Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkOlcumKaynakKodlari),
            new("aciklama", "d.aciklama", "metin", "Açıklama", Genislik: 220, Varsayilan: false),
            new("subeId",   "d.sube_id",  "sayi", "Şube", Varsayilan: false),
        });

    /// <summary>
    /// KOD HAVUZU — ters yön: "bu ICD kodu hangi göstergeleri besliyor".
    /// Gösterge kartından bakmak "bu göstergede hangi kodlar var" sorusunu
    /// yanıtlıyor; kodlama ekibinin sorusu bunun tersi ve tek satırda görünmeli.
    /// </summary>
    private static KaynakTanimi KlinikGostergeKod() => new(
        Ad: "klinikGostergeKod",
        YetkiKodu: "klinik_kalite",
        Kaynak: "public.klinik_gosterge_kod k" +
                " join public.klinik_gosterge g on g.id = k.gosterge_id" +
                " join public.klinik_olgu o on o.id = g.olgu_id",
        VarsayilanSirala: "k.tip, k.kod, g.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",  "k.id", "sayi", "Id", Varsayilan: false),
            new("tipAdi",
                "case k.tip when 'icd10' then 'ICD-10' when 'sut' then 'SUT'" +
                " when 'atc' then 'ATC' else k.tip end",
                "metin", "Tip", Hizalama: "orta", Genislik: 80,
                Siralanabilir: false, Filtrelenebilir: false),
            new("tip",      "k.tip", "kod", "Tip Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkKodTipiKodlari),
            new("kod",      "k.kod", "metin", "Kod", Genislik: 110),
            new("aciklama", "k.aciklama", "metin", "Ad", Genislik: 380),
            new("rolAdi",
                "case k.rol when 'pay' then 'Pay' when 'payda' then 'Payda' else k.rol end",
                "metin", "Rol", Hizalama: "orta", Genislik: 80,
                Siralanabilir: false, Filtrelenebilir: false),
            new("rol",      "k.rol", "kod", "Rol Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: KkRolKodlari),
            new("gostergeKod", "g.kod", "metin", "Gösterge", Genislik: 110),
            new("gostergeAd",  "g.ad",  "metin", "Gösterge Adı", Genislik: 340, Varsayilan: false),
            new("olguKod",  "o.kod", "metin", "Olgu", Hizalama: "orta", Genislik: 60),
            new("olguAd",   "o.ad",  "metin", "Sağlık Olgusu", Genislik: 180, Varsayilan: false),
            new("kaynakSurum", "k.kaynak_surum", "metin", "Rehber", Hizalama: "orta",
                Genislik: 80, Varsayilan: false),
            new("gostergeId", "k.gosterge_id", "sayi", "Gösterge Id", Varsayilan: false),
        });

    // Kod sozlukleri tek yerde: liste ustundeki suzme combosu ve kart metasi
    //   AYNI haritayi okusun (492 deseni).
    private static readonly Dictionary<string, string> KkPeriyotKodlari = new()
    {
        ["3"] = "3 aylık", ["6"] = "6 aylık", ["12"] = "Yıllık",
    };

    private static readonly Dictionary<string, string> KkOtomatikKodlari = new()
    {
        ["1"] = "Otomatik (kod listesi var)", ["0"] = "Elle giriş",
    };

    private static readonly Dictionary<string, string> KkAktifKodlari = new()
    {
        ["1"] = "Yürürlükte", ["0"] = "Kaldırıldı",
    };

    private static readonly Dictionary<string, string> KkDonemDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Kesinleşti",
    };

    private static readonly Dictionary<string, string> KkOlcumKaynakKodlari = new()
    {
        ["0"] = "Otomatik", ["1"] = "Elle",
    };

    private static readonly Dictionary<string, string> KkKodTipiKodlari = new()
    {
        ["icd10"] = "ICD-10 tanı", ["sut"] = "SUT işlem", ["atc"] = "ATC ilaç",
    };

    private static readonly Dictionary<string, string> KkRolKodlari = new()
    {
        ["pay"] = "Pay", ["payda"] = "Payda",
    };
}
