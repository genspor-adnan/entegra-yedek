namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BANKA HAREKETLERİ (1157, mockup Ekranlar/ERP/banka_hareketleri.html): bankadan çekilen hareketler
/// ve öneri kuralları. Hareket listesi hesaba süzülür (urlFiltre hesapId); öneri ve kasa işlemi bağı
/// görünümde (v_banka_hareket).
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi BankaHareket() => new(
        Ad: "banka-hareket",
        YetkiKodu: "banka.hareket",
        Kaynak: "public.v_banka_hareket h",
        SubeKolonu: "h.sube_id",
        VarsayilanSirala: "h.islem_tarihi desc, h.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",          "h.id",           "sayi",  "Id", Varsayilan: false),
            new("hesapId",     "h.hesap_id",     "sayi",  "Hesap Id", Varsayilan: false),
            new("hesapAd",     "h.hesap_ad",     "metin", "Banka Hesabı", Varsayilan: false),
            new("islemTarihi", "h.islem_tarihi", "zaman", "Tarih", Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm", Genislik: 125),
            new("valorTarihi", "h.valor_tarihi", "tarih", "Valör", Hizalama: "orta", Bicim: "dd.MM.yyyy", Varsayilan: false),
            new("aciklama",    "h.aciklama",     "metin", "Açıklama (banka)", Genislik: 300),
            new("karsiAd",     "h.karsi_ad",     "metin", "Karşı Taraf", Genislik: 180),
            new("karsiIban",   "h.karsi_iban",   "metin", "Karşı IBAN", Varsayilan: false),
            new("karsiVkn",    "h.karsi_vkn",    "metin", "Karşı VKN / TCKN", Varsayilan: false),
            new("faturaMetni", "h.fatura_metni", "metin", "Fatura Metni", Varsayilan: false),
            new("tutar",       "h.tutar",        "para",  "Tutar", Hizalama: "sag", Bicim: "#,##0.00"),
            new("gelen",       "h.gelen",        "para",  "Gelen", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("giden",       "h.giden",        "para",  "Giden", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("bakiye",      "h.bakiye",       "para",  "Bakiye", Hizalama: "sag", Bicim: "#,##0.00", Filtrelenebilir: false),
            new("dovizCinsi",  "h.doviz_cinsi",  "metin", "Döviz", Hizalama: "orta", Varsayilan: false),
            new("oneriTur",    "h.oneri_tur",    "metin", "Öneri", Varsayilan: false),
            new("oneriMetni",  "case h.oneri_tur when 'tahsilat' then 'Tahsilat' when 'tediye' then 'Tediye' when 'virman' then 'Virman'"
                               + " when 'pos' then 'POS aktarımı' when 'masraf' then 'Masraf' when 'yoksay' then 'Yoksay' else '' end"
                               + " || case when h.oneri_hedef <> '' then ' · ' || h.oneri_hedef else '' end",
                                                 "metin", "Öneri", Genislik: 220, Siralanabilir: false),
            new("oneriNeden",  "h.oneri_neden",  "metin", "Gerekçe", Genislik: 220),
            new("oneriGuven",  "h.oneri_guven",  "sayi",  "Güven", Hizalama: "sag", Varsayilan: false),
            new("durumAdi",    "case h.durum when 0 then 'Bekliyor' when 1 then 'Öneri hazır' when 2 then 'İşlendi'"
                               + " when 3 then 'Yoksayıldı' else 'Seçim bekliyor' end",
                                                 "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet", Filtrelenebilir: false),
            new("durum",       "h.durum",        "sayi",  "Durum Kodu", Varsayilan: false),
            new("kasaIslemId", "h.kasa_islem_id","sayi",  "Kasa İşlemi", Varsayilan: false),
            new("kasaIslemNo", "h.kasa_islem_no","metin", "Makbuz", Varsayilan: false),
            new("bankaIslemNo","h.banka_islem_no","metin","Banka Ref", Varsayilan: false),
            new("kaynak",      "h.kaynak",       "sayi",  "Kaynak", Varsayilan: false),
            new("subeId",      "h.sube_id",      "sayi",  "Şube", Varsayilan: false),
        });

    private static KaynakTanimi BankaKural() => new(
        Ad: "banka-kural",
        YetkiKodu: "banka.kural",
        Kaynak: """
            public.banka_kural k
            left join public.hesap hh on hh.id = k.hedef_hesap_id
            left join public.masraf mm on mm.id = k.hedef_masraf_id
            left join public.taraf tt on tt.id = k.hedef_taraf_id
            left join public.hesap kh on kh.id = k.hesap_id
            """,
        SubeKolonu: null,
        VarsayilanSirala: "k.sira, k.id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "k.id",   "sayi",  "Id", Varsayilan: false),
            new("sira",      "k.sira", "sayi",  "Sıra", Hizalama: "sag", Genislik: 60),
            new("ad",        "k.ad",   "metin", "Kural", Genislik: 260),
            new("kosul",     "case k.kosul_tur when 'iban' then 'Karşı IBAN carinin listesinde' when 'vkn' then 'Karşı VKN / TCKN cari kaydında'"
                             + " when 'fatura' then 'Açıklamada açık fatura no' when 'kendi_hesap' then 'Karşı IBAN kendi hesabımız'"
                             + " else 'Açıklama içerir \"' || k.kosul_metin || '\"' end",
                                       "metin", "Koşul", Genislik: 260, Siralanabilir: false),
            new("yonAdi",    "case k.yon when 1 then 'Gelen' when -1 then 'Giden' else 'İkisi' end", "metin", "Yön", Hizalama: "orta"),
            new("sonucAdi",  "case k.sonuc when 'tahsilat_tediye' then 'Tahsilat / Tediye' when 'cari' then 'Cariye tahsilat / tediye'"
                             + " when 'virman' then 'Virman' when 'pos' then 'POS aktarımı' when 'masraf' then 'Masraf' else 'Yoksay' end",
                                       "metin", "Sonuç"),
            new("hedef",     "coalesce(nullif(tt.unvan, ''), hh.ad, mm.ad, '')", "metin", "Hedef", Genislik: 200),
            new("hesap",     "coalesce(kh.ad, 'Bütün hesaplar')", "metin", "Banka Hesabı"),
            new("son30",     "(select count(*) from public.banka_hareket b where (b.oneri ->> 'kuralId')::int = k.id"
                             + " and b.islem_tarihi > now() - interval '30 day')", "sayi", "Son 30 gün", Hizalama: "sag",
                             Siralanabilir: false, Filtrelenebilir: false),
            new("tipAdi",    "case k.sistem when 1 then 'Sistem' else 'Kullanıcı' end", "metin", "Tip", Hizalama: "orta"),
            new("durumAdi",  "case k.aktif when 1 then 'Aktif' else 'Pasif' end", "metin", "Durum", Hizalama: "orta"),
            new("aktif",     "k.aktif", "sayi", "Aktif Kodu", Varsayilan: false),
        });
}
