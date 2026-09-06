namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// SİGORTA LİSTELERİ (430) — provizyonlar, kurum hesapları, kod eşleme.
///
/// Mockuplar: Sigorta/mockup/sigorta_provizyon.html, sigorta_ayarlari.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// PROVİZYONLAR — hangi başvuruya hangi şirketten ne çıktı.
    ///
    /// Tutar kırılımı ÖZET olarak listede: "kurum ne ödeyecek, hastadan ne
    /// tahsil edilecek" sorusu vezne için listede cevaplanmalı, kart açmadan.
    /// </summary>
    private static KaynakTanimi SigortaProvizyon() => new(
        Ad: "sigorta-provizyon",
        YetkiKodu: "sigorta",
        Kaynak: "public.sigorta_provizyon p "
              + "  join public.sigorta_saglayici sg on sg.id = p.saglayici_id "
              + "  left join public.sigorta_hesap sh on sh.id = p.hesap_id "
              + "  left join public.taraf kr on kr.id = sh.kurum_id "
              + "  left join public.belge b on b.id = p.belge_id "
              + "  left join public.taraf h on h.id = b.taraf_id",
        SubeKolonu: "p.sube_id",
        VarsayilanSirala: "p.provizyon_tarihi desc, p.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "p.id",       "sayi",  "Id", Varsayilan: false),
            new("belgeId",  "p.belge_id", "sayi",  "Başvuru Id", Varsayilan: false),
            new("provizyonNo", "p.provizyon_no", "metin", "Provizyon No",
                                          Hizalama: "orta", Genislik: 150),
            new("kurumRefNo",  "p.kurum_ref_no", "metin", "Kurum Ref.",
                                          Hizalama: "orta", Genislik: 150,
                                          Varsayilan: false),
            new("hastaAd",  "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 220),
            new("kurumAd",  "coalesce(kr.unvan, '')", "metin", "Sigorta Şirketi",
                                          Genislik: 200),
            new("saglayici","sg.ad",      "metin", "Sağlayıcı", Genislik: 160,
                                          Varsayilan: false),
            new("tipAdi",
                "case p.tip when 2 then 'Yatarak' when 3 then 'Kontrol' "
                + "else 'Ayakta' end",    "metin", "Tip", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 100,
                                          Filtrelenebilir: false),
            new("tip",      "p.tip",      "kod",   "Tip Kodu", Varsayilan: false),
            new("provizyonTarihi", "p.provizyon_tarihi", "tarih", "Tarih",
                                          Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm",
                                          Genislik: 130),
            new("talepToplam", "p.talep_toplam", "para", "Talep", Hizalama: "sag",
                                          Bicim: "#,##0.00", Genislik: 120),
            new("sirketPayi",  "p.sirket_payi",  "para", "Kurum Payı", Hizalama: "sag",
                                          Bicim: "#,##0.00", Genislik: 120),
            new("hastaPayi",   "p.hasta_payi",   "para", "Hasta Payı", Hizalama: "sag",
                                          Bicim: "#,##0.00", Genislik: 120),
            new("durumAdi",
                """
                case p.durum when 1 then 'Taslak' when 2 then 'Gönderildi'
                             when 3 then 'Onaylı' when 4 then 'Kısmi'
                             when 5 then 'Red' when 6 then 'İptal' else '' end
                """,                      "metin", "Durum", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 110,
                                          Filtrelenebilir: false),
            new("durum",    "p.durum",    "kod",   "Durum Kodu", Varsayilan: false),
            new("kararTipi","p.karar_tipi","metin","Karar", Hizalama: "orta",
                                          Genislik: 110, Varsayilan: false),
            new("redNedeni","p.red_nedeni","metin","Red Nedeni", Genislik: 300,
                                          Varsayilan: false),
            new("satirSayisi",
                "(select count(*) from public.sigorta_provizyon_satir s "
                + "where s.provizyon_id = p.id)",
                                          "sayi",  "Kalem", Hizalama: "orta",
                                          Genislik: 70, Filtrelenebilir: false),
            new("dokumanSayisi",
                "(select count(*) from public.sigorta_dokuman d "
                + "where d.provizyon_id = p.id and d.durum = 2)",
                                          "sayi",  "Belge", Hizalama: "orta",
                                          Genislik: 70, Filtrelenebilir: false),
            new("eklemeTarihi", "p.ekleme_tarihi", "tarih", "Oluşturma",
                                          Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm",
                                          Genislik: 130, Varsayilan: false),
        });

    /// <summary>
    /// KURUM HESAPLARI — hangi sigorta şirketi hangi sağlayıcı üzerinden.
    /// Parola ve istemci sırrı BURADA GÖRÜNMEZ: kimlik bilgisi
    /// entegrasyon_hesap kartında durur, liste yalnız bağı gösterir.
    /// </summary>
    private static KaynakTanimi SigortaHesap() => new(
        Ad: "sigorta-hesap",
        YetkiKodu: "sigorta",
        Kaynak: "public.sigorta_hesap h "
              + "  join public.sigorta_saglayici s on s.id = h.saglayici_id "
              + "  join public.entegrasyon_hesap e on e.id = h.hesap_id "
              + "  left join public.taraf k on k.id = h.kurum_id "
              + "  left join public.sube sb on sb.id = h.sube_id",
        VarsayilanSirala: "s.ad asc, k.unvan asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "h.id",   "sayi",  "Id", Varsayilan: false),
            new("saglayici", "s.ad",   "metin", "Sağlayıcı", Genislik: 200),
            new("kurumAd",   "coalesce(k.unvan, '')", "metin", "Sigorta Şirketi",
                                       Genislik: 240),
            new("hesapKod",  "e.kod",  "metin", "Entegrasyon Hesabı", Genislik: 160),
            new("ortam",
                "case when e.test_mi = 1 then 'Test' else 'Canlı' end",
                                       "metin", "Ortam", Hizalama: "orta",
                                       Bicim: "rozet", Genislik: 90,
                                       Filtrelenebilir: false),
            new("subeAd",    "coalesce(sb.ad, 'Tüm şubeler')", "metin", "Şube",
                                       Genislik: 150),
            new("varsayilan","h.varsayilan", "mantik", "Varsayılan", Hizalama: "orta",
                                       Genislik: 90),
            new("durumAdi",
                "case h.durum when 1 then 'Pasif' else 'Aktif' end",
                                       "metin", "Durum", Hizalama: "orta",
                                       Bicim: "rozet", Genislik: 90,
                                       Filtrelenebilir: false),
            new("durum",     "h.durum","kod",   "Durum Kodu", Varsayilan: false),
            new("aciklama",  "h.aciklama", "metin", "Açıklama", Genislik: 260,
                                       Varsayilan: false),
        });

    /// <summary>
    /// KOD EŞLEME — kanonik değer ↔ sağlayıcı değeri. Yeni şirket bağlarken
    /// doldurulan tek tablo; şema ve ekran değişmez.
    /// </summary>
    private static KaynakTanimi SigortaKodEsleme() => new(
        Ad: "sigorta-kod-esleme",
        YetkiKodu: "sigorta",
        Kaynak: "public.sigorta_kod_esleme e "
              + "  join public.sigorta_saglayici s on s.id = e.saglayici_id",
        VarsayilanSirala: "s.ad asc, e.alan asc, e.sira asc, e.yerel_kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",           "e.id",   "sayi",  "Id", Varsayilan: false),
            new("saglayici",    "s.ad",   "metin", "Sağlayıcı", Genislik: 180),
            new("alan",         "e.alan", "metin", "Sözlük", Genislik: 160),
            new("yerelKod",     "e.yerel_kod", "metin", "Yerel Kod", Hizalama: "orta",
                                        Genislik: 100),
            new("ad",           "e.ad",   "metin", "Anlamı", Genislik: 220),
            new("saglayiciKod", "e.saglayici_kod", "metin", "Sağlayıcı Kodu",
                                        Genislik: 240),
            new("sira",         "e.sira", "sayi",  "Sıra", Hizalama: "orta",
                                        Genislik: 70, Varsayilan: false),
        });

    /// <summary>
    /// İSTEK GÜNLÜĞÜ — "biz ne gönderdik, onlar ne dedi". İhtilafta kanıt,
    /// hata ayıklamada tek bakılacak yer.
    /// </summary>
    private static KaynakTanimi SigortaIstekLog() => new(
        Ad: "sigorta-istek-log",
        YetkiKodu: "sigorta",
        Kaynak: "public.sigorta_istek_log l "
              + "  left join public.sigorta_saglayici s on s.id = l.saglayici_id",
        SubeKolonu: "l.sube_id",
        VarsayilanSirala: "l.tarih desc, l.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "l.id",     "sayi",  "Id", Varsayilan: false),
            new("tarih",     "l.tarih",  "tarih", "Zaman", Hizalama: "orta",
                                         Bicim: "dd.MM.yyyy HH:mm:ss", Genislik: 150),
            new("saglayici", "coalesce(s.ad, '')", "metin", "Sağlayıcı", Genislik: 170),
            new("uc",        "l.uc",     "metin", "Servis", Genislik: 180),
            new("kayitTuru", "l.kayit_turu", "metin", "Kayıt", Hizalama: "orta",
                                         Genislik: 100),
            new("kayitId",   "l.kayit_id", "sayi", "Kayıt Id", Hizalama: "orta",
                                         Genislik: 90),
            new("sonucAdi",
                "case when l.basarili = 1 then 'Başarılı' else 'Hata' end",
                                         "metin", "Sonuç", Hizalama: "orta",
                                         Bicim: "rozet", Genislik: 90,
                                         Filtrelenebilir: false),
            new("basarili",  "l.basarili", "kod",  "Sonuç Kodu", Varsayilan: false),
            new("hata",      "l.hata",   "metin", "Hata", Genislik: 320),
            new("yanitMetni","coalesce(l.yanit::text, '')", "metin", "Yanıt",
                                         Varsayilan: false, Filtrelenebilir: false),
            new("istekMetni","coalesce(l.istek::text, '')", "metin", "İstek",
                                         Varsayilan: false, Filtrelenebilir: false),
        });
}
