namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// LABORATUVAR LİSTELERİ (433/434) — tetkik kataloğu, panel, numune,
/// sonuç ve cihaz test eşlemesi.
///
/// Mockup: Ekranlar/Lab/lab_sureci.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// TETKİK KATALOĞU — hizmetle 1:1. Fiyat/faturalama hizmet kartında,
    /// laboratuvar davranışı (numune, TAT, panik, delta) burada.
    /// </summary>
    private static KaynakTanimi LabTetkik() => new(
        Ad: "lab-tetkik",
        YetkiKodu: "lab.tetkik",
        Kaynak: "public.lab_tetkik t "
              + "  left join public.stok h on h.id = t.hizmet_id "
              + "  left join public.cihaz c on c.id = t.varsayilan_cihaz_id",
        // ANA VERI - subeler arasi ORTAK: tetkik katalogu kurumun tanimidir,
        //   sube basina ayri katalog tutmak ayni tetkigin iki farkli panik
        //   sinirini dogururdu.
        SubeKolonu: null,
        VarsayilanSirala: "t.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",  "t.id",  "sayi",  "Id", Varsayilan: false),
            new("kod", "t.kod", "metin", "Kod", Genislik: 100),
            new("ad",  "t.ad",  "metin", "Tetkik", Genislik: 240),
            new("bolumAdi",
                "case t.bolum when 2 then 'Hematoloji' when 3 then 'Hormon' "
                + "when 4 then 'Mikrobiyoloji' when 5 then 'Seroloji' "
                + "when 6 then 'Koagülasyon' when 7 then 'İdrar' "
                + "when 9 then 'Diğer' else 'Biyokimya' end",
                                 "metin", "Bölüm", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false),
            new("bolum", "t.bolum", "kod", "Bölüm Kodu", Varsayilan: false),
            new("turAdi",
                "case t.tur when 2 then 'Metin' when 3 then 'Seçenek' "
                + "when 4 then 'Kültür' else 'Sayısal' end",
                                 "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 100, Filtrelenebilir: false),
            new("tur", "t.tur", "kod", "Tür Kodu", Varsayilan: false),
            new("numuneTipiAdi",
                "case t.numune_tipi when 2 then 'Plazma' when 3 then 'Tam Kan' "
                + "when 4 then 'İdrar' when 5 then 'Gaita' when 6 then 'BOS' "
                + "when 7 then 'Swab' when 9 then 'Diğer' else 'Serum' end",
                                 "metin", "Numune", Hizalama: "orta", Genislik: 110,
                                 Filtrelenebilir: false),
            new("tupTipiAdi",
                "case t.tup_tipi when 2 then 'Mor (EDTA)' when 3 then 'Mavi (Sitrat)' "
                + "when 4 then 'Gri (Florür)' when 5 then 'Yeşil (Heparin)' "
                + "when 6 then 'İdrar Kabı' when 9 then 'Diğer' "
                + "else 'Sarı (Jelli)' end",
                                 "metin", "Tüp", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false),
            new("birim", "t.birim", "metin", "Birim", Hizalama: "orta", Genislik: 80),
            // TAT: sözü verilen süre. Listede görünmezse gecikme fark edilmez.
            new("hedefTat", "t.hedef_tat_dk", "sayi", "TAT (dk)", Hizalama: "sag",
                                 Genislik: 90),
            new("acilTat", "t.acil_tat_dk", "sayi", "Acil TAT", Hizalama: "sag",
                                 Genislik: 90, Varsayilan: false),
            new("panikAlt", "t.panik_alt", "sayi", "Panik Alt", Hizalama: "sag",
                                 Bicim: "#,##0.##", Genislik: 100),
            new("panikUst", "t.panik_ust", "sayi", "Panik Üst", Hizalama: "sag",
                                 Bicim: "#,##0.##", Genislik: 100),
            new("deltaYuzde", "t.delta_yuzde", "sayi", "Delta %", Hizalama: "sag",
                                 Bicim: "#,##0.#", Genislik: 90, Varsayilan: false),
            new("otoOnay", "t.oto_onay", "mantik", "Oto Onay", Hizalama: "orta",
                                 Genislik: 90),
            // Referans satırı OLMAYAN tetkik bayrak üretemez - katalog eksikliği
            //   listede görünmezse sonuç sessizce "normal" çıkar.
            new("referansSayisi",
                "(select count(*) from public.lab_tetkik_referans r "
                + "where r.tetkik_id = t.id)",
                                 "sayi", "Referans", Hizalama: "orta", Genislik: 90,
                                 Filtrelenebilir: false),
            new("hizmetAdi", "coalesce(h.kod || ' · ' || h.ad, '')", "metin", "Hizmet",
                                 Genislik: 220, Varsayilan: false),
            new("hizmetId", "t.hizmet_id", "sayi", "Hizmet Id", Varsayilan: false),
            new("cihazAdi", "coalesce(c.kod, '')", "metin", "Varsayılan Cihaz",
                                 Hizalama: "orta", Genislik: 130, Varsayilan: false),
            new("loinc", "t.loinc", "metin", "LOINC", Hizalama: "orta", Genislik: 100,
                                 Varsayilan: false),
            new("durumAdi", "case t.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "t.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>PANELLER — istemde tek kalemde açılan tetkik grupları.</summary>
    private static KaynakTanimi LabPanel() => new(
        Ad: "lab-panel",
        YetkiKodu: "lab.tetkik",
        Kaynak: "public.lab_panel p left join public.stok h on h.id = p.hizmet_id",
        SubeKolonu: null,                     // ana veri - ortak (tetkik gibi)
        VarsayilanSirala: "p.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",  "p.id",  "sayi",  "Id", Varsayilan: false),
            new("kod", "p.kod", "metin", "Kod", Genislik: 120),
            new("ad",  "p.ad",  "metin", "Panel", Genislik: 260),
            new("tetkikSayisi",
                "(select count(*) from public.lab_panel_satir s where s.panel_id = p.id)",
                                 "sayi", "Tetkik", Hizalama: "orta", Genislik: 80,
                                 Filtrelenebilir: false),
            new("hizmetAdi", "coalesce(h.kod || ' · ' || h.ad, '')", "metin", "Hizmet",
                                 Genislik: 220, Varsayilan: false),
            new("durumAdi", "case p.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "p.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// NUMUNE KABUL LİSTESİ — barkod, tüp, kabul/ret ve GECİKME.
    ///
    /// Bekleme süresi kolonu bilinçli: kabul edilmemiş tüp laboratuvarda
    /// bekliyorsa (pıhtılaşma, hemoliz) sonuç zaten güvenilmez olur.
    /// </summary>
    private static KaynakTanimi LabNumune() => new(
        Ad: "lab-numune",
        YetkiKodu: "lab.numune",
        Kaynak: "public.lab_numune n "
              + "  join public.lab_istem i on i.id = n.istem_id "
              + "  join public.taraf h on h.id = n.hasta_id",
        SubeKolonu: "n.sube_id",
        VarsayilanSirala: "n.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",     "n.id",     "sayi",  "Id", Varsayilan: false),
            new("barkod", "n.barkod", "metin", "Barkod", Hizalama: "orta", Genislik: 140),
            new("istemNo", "i.istem_no", "metin", "İstem No", Hizalama: "orta",
                                 Genislik: 130),
            new("hastaAdi",
                "coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan)",
                                 "metin", "Hasta", Genislik: 220),
            new("dosyaNo", "coalesce(h.kod, '')", "metin", "Dosya No", Hizalama: "orta",
                                 Genislik: 110, Varsayilan: false),
            new("tupTipiAdi",
                "case n.tup_tipi when 2 then 'Mor (EDTA)' when 3 then 'Mavi (Sitrat)' "
                + "when 4 then 'Gri (Florür)' when 5 then 'Yeşil (Heparin)' "
                + "when 6 then 'İdrar Kabı' when 9 then 'Diğer' "
                + "else 'Sarı (Jelli)' end",
                                 "metin", "Tüp", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 130, Filtrelenebilir: false),
            new("tetkikSayisi",
                "(select count(*) from public.lab_istem_satir s "
                + "where s.numune_id = n.id and s.durum <> 0)",
                                 "sayi", "Tetkik", Hizalama: "orta", Genislik: 80,
                                 Filtrelenebilir: false),
            new("oncelikAdi",
                "case i.oncelik when 2 then 'Öncelikli' when 3 then 'Acil' "
                + "else 'Normal' end",
                                 "metin", "Öncelik", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 100, Filtrelenebilir: false),
            new("alimZamani", "n.alim_zamani", "tarih", "Alındı", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("kabulZamani", "n.kabul_zamani", "tarih", "Kabul", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("beklemeDk",
                "case when n.kabul_zamani is null and n.alim_zamani is not null "
                + "then floor(extract(epoch from (now() - n.alim_zamani)) / 60)::int "
                + "else null end",
                                 "sayi", "Bekleme (dk)", Hizalama: "sag", Genislik: 110,
                                 Filtrelenebilir: false),
            // Kalite kodlari db/433: 1 uygun · 2 hemoliz · 3 lipemi · 4 ikter ·
            //   5 yetersiz · 6 pihti · 7 yanlis tup · 8 etiketsiz.
            new("kaliteAdi",
                "case n.kalite when 2 then 'Hemolizli' when 3 then 'Lipemik' "
                + "when 4 then 'İkterik' when 5 then 'Yetersiz' when 6 then 'Pıhtılı' "
                + "when 7 then 'Yanlış Tüp' when 8 then 'Etiketsiz' "
                + "else 'Uygun' end",
                                 "metin", "Kalite", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 110, Filtrelenebilir: false),
            new("durumAdi",
                "case n.durum when 0 then 'Reddedildi' when 2 then 'Alındı' "
                + "when 3 then 'Kabul' when 4 then 'Cihazda' when 5 then 'Saklamada' "
                + "when 6 then 'İmha' else 'Etiketlendi' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 110, Filtrelenebilir: false),
            new("durum", "n.durum", "kod", "Durum Kodu", Varsayilan: false),
            // SERUM İNDEKSLERİ (444): kabul ekranında "uygun" görünen numune
            //   cihazda hemolizli çıkabilir - indeksler ölçümle gelir ve
            //   hangi testin etkilendiğini kural belirler.
            new("indeksler",
                "case when n.hemoliz_idx is null and n.lipemi_idx is null "
                + "          and n.ikter_idx is null then '' else "
                + "concat_ws(' · ', "
                + "  case when n.hemoliz_idx is not null then 'H ' || n.hemoliz_idx end, "
                + "  case when n.lipemi_idx is not null then 'L ' || n.lipemi_idx end, "
                + "  case when n.ikter_idx is not null then 'İ ' || n.ikter_idx end) end",
                                 "metin", "HIL İndeks", Hizalama: "orta", Genislik: 130,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("retAciklama", "n.ret_aciklama", "metin", "Ret Nedeni", Genislik: 220,
                                 Varsayilan: false),
            new("istemId", "n.istem_id", "sayi", "İstem Id", Varsayilan: false),
            new("hastaId", "n.hasta_id", "sayi", "Hasta Id", Varsayilan: false),
        });

    /// <summary>
    /// SONUÇ LİSTESİ — onay kuyruğu.
    ///
    /// Bayrak/panik/delta sonucun KENDİSİNDEN okunur (yazılırken hesaplandı);
    /// listede yeniden hesaplamak, referans değişince eski raporu değiştirirdi.
    /// </summary>
    private static KaynakTanimi LabSonuc() => new(
        Ad: "lab-sonuc",
        YetkiKodu: "lab.sonuc",
        Kaynak: "public.lab_sonuc ls "
              + "  join public.lab_istem_satir s on s.id = ls.istem_satir_id "
              + "  join public.lab_istem i on i.id = s.istem_id "
              + "  join public.lab_tetkik t on t.id = ls.tetkik_id "
              + "  join public.taraf h on h.id = i.taraf_id "
              + "  left join public.lab_numune n on n.id = ls.numune_id "
              + "  left join public.cihaz c on c.id = ls.cihaz_id",
        SubeKolonu: "ls.sube_id",
        VarsayilanSirala: "ls.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "ls.id", "sayi", "Id", Varsayilan: false),
            new("barkod", "coalesce(n.barkod, '')", "metin", "Barkod", Hizalama: "orta",
                                 Genislik: 140),
            new("istemNo", "i.istem_no", "metin", "İstem No", Hizalama: "orta",
                                 Genislik: 130, Varsayilan: false),
            new("hastaAdi",
                "coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan)",
                                 "metin", "Hasta", Genislik: 200),
            new("tetkikKod", "t.kod", "metin", "Kod", Hizalama: "orta", Genislik: 90),
            new("tetkikAd", "t.ad", "metin", "Tetkik", Genislik: 200),
            new("deger", "ls.deger_metin", "metin", "Sonuç", Hizalama: "sag",
                                 Genislik: 110),
            new("birim", "ls.birim", "metin", "Birim", Hizalama: "orta", Genislik: 80),
            new("bayrak",
                "case ls.bayrak when 'LL' then '↓↓ Panik Düşük' "
                + "when 'HH' then '↑↑ Panik Yüksek' when 'L' then '↓ Düşük' "
                + "when 'H' then '↑ Yüksek' else 'Normal' end",
                                 "metin", "Değerlendirme", Hizalama: "orta",
                                 Bicim: "rozet", Genislik: 140, Filtrelenebilir: false),
            // REFERANS okunur biçimde: ham numeric ::text "0.000000 - 33.000000"
            //   diye çıkıyordu ve kolona sığmayıp kırpılıyordu. trim_scale
            //   gereksiz sıfırları atar, ondalık ayraç Türkçe.
            //   Tek taraflı sınır "≤ 35" / "≥ 60" yazılır: "0 - 35" alt sınır
            //   varmış gibi görünürdü.
            new("referans",
                "case when ls.referans_metin <> '' then ls.referans_metin "
                + "when ls.referans_alt is not null and ls.referans_ust is not null "
                + "then replace(trim_scale(ls.referans_alt)::text, '.', ',') || ' – ' "
                + "     || replace(trim_scale(ls.referans_ust)::text, '.', ',') "
                + "when ls.referans_ust is not null "
                + "then '≤ ' || replace(trim_scale(ls.referans_ust)::text, '.', ',') "
                + "when ls.referans_alt is not null "
                + "then '≥ ' || replace(trim_scale(ls.referans_alt)::text, '.', ',') "
                + "else '' end",
                                 "metin", "Referans", Hizalama: "orta", Genislik: 140,
                                 Filtrelenebilir: false),
            new("panik", "ls.panik", "mantik", "Panik", Hizalama: "orta", Genislik: 80),
            // ONCEKI DEGER ve DELTA (mockup: "Önceki (12.03.25)" ve "Δ"):
            //   uzman sonuca degil DEGISIME bakar - 142 mg/dL tek basina bir
            //   sey soylemez, 98'den 142'ye cikmis olmasi soyler.
            new("deltaOnceki",
                "case when ls.delta_onceki is null then '' "
                + "else replace(trim_scale(ls.delta_onceki)::text, '.', ',') end",
                                 "metin", "Önceki", Hizalama: "sag", Genislik: 90,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("deltaYuzdeMetin",
                "case when ls.delta_yuzde is null then '' "
                + "else case when ls.delta_yuzde > 0 then '+' else '' end "
                + "     || replace(trim_scale(round(ls.delta_yuzde))::text, '.', ',') "
                + "     || '%' end",
                                 "metin", "Δ", Hizalama: "sag", Genislik: 80,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("deltaUyari", "ls.delta_uyari", "mantik", "Delta", Hizalama: "orta",
                                 Genislik: 80),
            new("olcumZamani", "ls.olcum_zamani", "tarih", "Ölçüm", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("cihazAdi", "coalesce(c.kod, 'Elle')", "metin", "Kaynak", Hizalama: "orta",
                                 Genislik: 110),
            new("durumAdi",
                "case ls.durum when 2 then 'Teknik Onay' when 3 then 'Onaylı' "
                + "when 4 then 'İptal (düzeltildi)' else 'Bekliyor' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("durum", "ls.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("otoOnay", "ls.oto_onay", "mantik", "Oto", Hizalama: "orta", Genislik: 70,
                                 Varsayilan: false),
            new("onayZamani", "ls.onay_zamani", "tarih", "Onay", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                 Varsayilan: false),
            // İNDEKS UYARISI sonucun yanında durur: "K yüksek" ile "hemoliz
            //   yüzünden yüksek görünüyor" bambaşka iki şey.
            new("indeksUyari", "ls.indeks_uyari", "metin", "Numune Kalitesi Uyarısı",
                                 Genislik: 280),
            new("indeksDurum", "ls.indeks_durum", "kod", "İndeks Durumu",
                                 Varsayilan: false),
            new("yorum", "ls.yorum", "metin", "Yorum", Genislik: 240, Varsayilan: false),
            new("istemId", "s.istem_id", "sayi", "İstem Id", Varsayilan: false),
            new("istemSatirId", "ls.istem_satir_id", "sayi", "Satır Id",
                                 Varsayilan: false),
        });

    /// <summary>
    /// CİHAZ TEST EŞLEME (434) — cihazın kendi kodu ile tetkik arasındaki köprü.
    /// Kayıt yoksa kod eşitliği kullanılır; tablo yalnız istisnalar için.
    /// </summary>
    private static KaynakTanimi LabCihazEsleme() => new(
        Ad: "lab-cihaz-esleme",
        YetkiKodu: "lab.cihaz",
        Kaynak: "public.lab_cihaz_test_esleme e "
              + "  join public.cihaz c on c.id = e.cihaz_id "
              + "  join public.lab_tetkik t on t.id = e.tetkik_id",
        SubeKolonu: null,                     // cihaz zaten subeli; esleme tanim
        VarsayilanSirala: "c.kod asc, e.cihaz_test_kodu asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "e.id", "sayi", "Id", Varsayilan: false),
            new("cihazAdi", "c.kod || ' · ' || c.ad", "metin", "Cihaz", Genislik: 220),
            new("cihazTestKodu", "e.cihaz_test_kodu", "metin", "Cihaz Kodu",
                                 Hizalama: "orta", Genislik: 130),
            new("altKod", "e.alt_kod", "metin", "Alt Kod", Hizalama: "orta",
                                 Genislik: 90, Varsayilan: false),
            new("tetkikAdi", "t.kod || ' · ' || t.ad", "metin", "Tetkik", Genislik: 240),
            new("cihazBirim", "e.cihaz_birim", "metin", "Cihaz Birimi", Hizalama: "orta",
                                 Genislik: 110),
            new("tetkikBirim", "t.birim", "metin", "Rapor Birimi", Hizalama: "orta",
                                 Genislik: 110),
            new("carpan", "e.carpan", "sayi", "Çarpan", Hizalama: "sag",
                                 Bicim: "#,##0.####", Genislik: 100),
            new("ofset", "e.ofset", "sayi", "Ofset", Hizalama: "sag",
                                 Bicim: "#,##0.####", Genislik: 100),
            new("durumAdi", "case e.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "e.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("cihazId", "e.cihaz_id", "sayi", "Cihaz Id", Varsayilan: false),
            new("tetkikId", "e.tetkik_id", "sayi", "Tetkik Id", Varsayilan: false),
        });
}
