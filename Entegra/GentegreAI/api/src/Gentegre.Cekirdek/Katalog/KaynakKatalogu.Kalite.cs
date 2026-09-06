namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KALİTE KONTROL LİSTELERİ (442) — İKK ölçümleri, kontrol lotları,
/// Westgard kural seti, dış kalite ve cihaz olayları.
///
/// Mockup: Ekranlar/Lab/lab_kalite_kontrol.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// KK ÖLÇÜMLERİ — laboratuvarın günlük kontrol defteri.
    ///
    /// <b>Z skoru ve ihlal listesi satırda saklandığı gibi gösterilir</b>;
    /// liste yeniden hesaplamaz. Hedef/SD sonradan güncellenirse geçmiş
    /// ölçümün değerlendirmesi değişmemeli.
    /// </summary>
    private static KaynakTanimi LabKkOlcum() => new(
        Ad: "lab-kk-olcum",
        YetkiKodu: "lab.kk",
        Kaynak: "public.lab_kk_olcum o "
              + "  join public.lab_tetkik t on t.id = o.tetkik_id "
              + "  join public.lab_kk_lot l on l.id = o.lot_id "
              + "  left join public.cihaz c on c.id = o.cihaz_id",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.olcum_zamani desc, o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "o.id", "sayi", "Id", Varsayilan: false),
            new("olcumZamani", "o.olcum_zamani", "tarih", "Tarih", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("tetkikKod", "t.kod", "metin", "Test", Hizalama: "orta", Genislik: 90),
            new("tetkikAd", "t.ad", "metin", "Tetkik", Genislik: 200),
            new("seviye", "o.seviye", "sayi", "Sev.", Hizalama: "orta", Genislik: 60),
            new("deger", "o.deger", "sayi", "Sonuç", Hizalama: "sag",
                                 Bicim: "#,##0.###", Genislik: 100),
            new("z", "o.z", "sayi", "Z", Hizalama: "sag", Bicim: "+#,##0.00;-#,##0.00",
                                 Genislik: 80),
            new("hedefSd",
                "case when o.hedef is null then '' "
                + "else trim(to_char(o.hedef, 'FM999999990D99')) || ' ± ' "
                + "     || trim(to_char(o.sd, 'FM999999990D99')) end",
                                 "metin", "Hedef ± SD", Hizalama: "orta", Genislik: 130,
                                 Filtrelenebilir: false),
            new("ihlal", "array_to_string(o.ihlaller, ' · ')", "metin", "Kural",
                                 Hizalama: "orta", Genislik: 140,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("durumAdi",
                "case o.durum when 3 then 'RET' when 2 then 'Uyarı' else 'Kabul' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 100, Filtrelenebilir: false),
            new("durum", "o.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("kaynakAdi",
                "case o.kaynak when 1 then 'Cihaz' else 'Elle' end",
                                 "metin", "Kaynak", Hizalama: "orta", Genislik: 90,
                                 Filtrelenebilir: false),
            new("cihazKod", "coalesce(c.kod, '')", "metin", "Cihaz", Hizalama: "orta",
                                 Genislik: 110),
            new("lotAd", "l.materyal_ad || ' · lot ' || l.lot", "metin",
                                 "Kontrol Materyali", Genislik: 240),
            // RET SATIRINDA AKSİYON BOŞSA denetimde savunulamaz: listede
            //   görünsün ki kapatılmamış ret gözden kaçmasın.
            new("aksiyon", "o.aksiyon", "metin", "Düzeltici Faaliyet", Genislik: 280),
            new("gozdenGecirilen", "o.gozden_gecirilen", "sayi", "Gözden Geçirilen",
                                 Hizalama: "sag", Genislik: 130, Varsayilan: false),
            new("duzeltilen", "o.duzeltilen", "sayi", "Düzeltilen", Hizalama: "sag",
                                 Genislik: 100, Varsayilan: false),
            new("tekrar", "o.tekrar", "mantik", "Tekrar", Hizalama: "orta",
                                 Genislik: 80, Varsayilan: false),
            new("tetkikId", "o.tetkik_id", "sayi", "Tetkik Id", Varsayilan: false),
            new("lotId", "o.lot_id", "sayi", "Lot Id", Varsayilan: false),
        });

    private static KaynakTanimi LabKkLot() => new(
        Ad: "lab-kk-lot",
        YetkiKodu: "lab.kk",
        Kaynak: "public.lab_kk_lot l",
        SubeKolonu: "l.sube_id",
        VarsayilanSirala: "l.durum asc, l.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "l.id", "sayi", "Id", Varsayilan: false),
            new("kod", "l.kod", "metin", "Kod", Hizalama: "orta", Genislik: 120),
            new("materyalAd", "l.materyal_ad", "metin", "Kontrol Materyali",
                                 Genislik: 280),
            new("lot", "l.lot", "metin", "Lot", Hizalama: "orta", Genislik: 110),
            new("uretici", "l.uretici", "metin", "Üretici", Genislik: 160),
            // SKT GEÇMİŞ LOT KULLANILMAZ: listede görünmezse fark edilmez.
            new("skt", "l.skt", "tarih", "SKT", Hizalama: "orta", Bicim: "dd.MM.yyyy",
                                 Genislik: 100),
            new("skmGun",
                "case when l.skt is null then null else (l.skt - current_date) end",
                                 "sayi", "SKT'ye Kalan", Hizalama: "sag", Genislik: 110,
                                 Filtrelenebilir: false),
            new("seviyeSayisi", "l.seviye_sayisi", "sayi", "Seviye", Hizalama: "orta",
                                 Genislik: 80),
            new("hedefSayisi",
                "(select count(*) from public.lab_kk_hedef h where h.lot_id = l.id)",
                                 "sayi", "Tanımlı Test", Hizalama: "orta", Genislik: 110,
                                 Filtrelenebilir: false),
            new("durumAdi", "case l.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "l.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// DIŞ KALİTE (DKK) — dönem bazlı program sonuçları. SDI sunucuda
    /// hesaplanır ve satırda saklanır.
    /// </summary>
    private static KaynakTanimi LabDkk() => new(
        Ad: "lab-dkk",
        YetkiKodu: "lab.kk",
        Kaynak: "public.lab_dkk_sonuc d join public.lab_tetkik t on t.id = d.tetkik_id",
        SubeKolonu: "d.sube_id",
        VarsayilanSirala: "d.donem desc, t.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "d.id", "sayi", "Id", Varsayilan: false),
            new("program", "d.program", "metin", "Program", Hizalama: "orta",
                                 Genislik: 120),
            new("donem", "d.donem", "metin", "Dönem", Hizalama: "orta", Genislik: 100),
            new("tetkikKod", "t.kod", "metin", "Test", Hizalama: "orta", Genislik: 90),
            new("tetkikAd", "t.ad", "metin", "Tetkik", Genislik: 200),
            new("sonucumuz", "d.sonucumuz", "sayi", "Sonucumuz", Hizalama: "sag",
                                 Bicim: "#,##0.###", Genislik: 110),
            new("hedef", "d.hedef", "sayi", "Hedef", Hizalama: "sag",
                                 Bicim: "#,##0.###", Genislik: 100),
            new("grupSd", "d.grup_sd", "sayi", "Grup SD", Hizalama: "sag",
                                 Bicim: "#,##0.###", Genislik: 100, Varsayilan: false),
            new("sdi", "d.sdi", "sayi", "SDI", Hizalama: "sag",
                                 Bicim: "+#,##0.00;-#,##0.00", Genislik: 90),
            new("degerlendirmeAdi",
                "case d.degerlendirme when 3 then 'Kabul edilemez' "
                + "when 2 then 'Uyarı' else 'Kabul' end",
                                 "metin", "Değerlendirme", Hizalama: "orta",
                                 Bicim: "rozet", Genislik: 140, Filtrelenebilir: false),
            new("degerlendirme", "d.degerlendirme", "kod", "Değ. Kodu",
                                 Varsayilan: false),
            new("aksiyon", "d.aksiyon", "metin", "Düzeltici Faaliyet", Genislik: 260),
            new("yontem", "d.yontem", "metin", "Yöntem", Genislik: 180,
                                 Varsayilan: false),
            new("raporTarihi", "d.rapor_tarihi", "tarih", "Rapor Tarihi",
                                 Hizalama: "orta", Bicim: "dd.MM.yyyy", Genislik: 110,
                                 Varsayilan: false),
        });

    /// <summary>
    /// WESTGARD KURAL SETİ — teste özel satır varsa varsayılanı ezer.
    /// </summary>
    private static KaynakTanimi LabKkKural() => new(
        Ad: "lab-kk-kural",
        YetkiKodu: "lab.kk",
        Kaynak: "public.lab_kk_kural k left join public.lab_tetkik t on t.id = k.tetkik_id",
        SubeKolonu: null,
        VarsayilanSirala: "k.tetkik_id nulls first, k.sira",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("kapsam",
                "case when k.tetkik_id is null then 'Varsayılan (tüm testler)' "
                + "else t.kod || ' · ' || t.ad end",
                                 "metin", "Kapsam", Genislik: 240,
                                 Filtrelenebilir: false),
            new("kural", "k.kural", "metin", "Kural", Hizalama: "orta", Genislik: 100),
            new("davranisAdi",
                "case k.davranis when 2 then 'RET' when 1 then 'Uyarı' "
                + "else 'Kapalı' end",
                                 "metin", "Davranış", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 100, Filtrelenebilir: false),
            new("davranis", "k.davranis", "kod", "Davranış Kodu", Varsayilan: false),
            new("sira", "k.sira", "sayi", "Sıra", Hizalama: "orta", Genislik: 70),
            new("aciklama", "k.aciklama", "metin", "Açıklama", Genislik: 400),
            new("tetkikId", "k.tetkik_id", "sayi", "Tetkik Id", Varsayilan: false),
        });

    /// <summary>
    /// CİHAZ OLAYLARI — kalibrasyon, bakım, reaktif lot değişimi, arıza.
    /// Levey-Jennings'teki kaymanın nedeni çoğu zaman bu listededir.
    /// </summary>
    private static KaynakTanimi LabCihazOlay() => new(
        Ad: "lab-cihaz-olay",
        YetkiKodu: "lab.kk",
        Kaynak: "public.lab_cihaz_olay o "
              + "  left join public.cihaz c on c.id = o.cihaz_id "
              + "  left join public.lab_tetkik t on t.id = o.tetkik_id "
              + "  left join public.taraf k on k.id = o.kullanici_id",
        SubeKolonu: "o.sube_id",
        VarsayilanSirala: "o.zaman desc, o.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "o.id", "sayi", "Id", Varsayilan: false),
            new("zaman", "o.zaman", "tarih", "Zaman", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("cihazKod", "coalesce(c.kod, '')", "metin", "Cihaz", Hizalama: "orta",
                                 Genislik: 120),
            new("olayAdi",
                "case o.olay when 2 then 'Bakım' when 3 then 'Reaktif lot değişimi' "
                + "when 4 then 'Arıza' when 5 then 'KK ret sonrası tekrar' "
                + "when 9 then 'Diğer' else 'Kalibrasyon' end",
                                 "metin", "Olay", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 180, Filtrelenebilir: false),
            new("olay", "o.olay", "kod", "Olay Kodu", Varsayilan: false),
            new("tetkikAd", "coalesce(t.kod, '')", "metin", "Test", Hizalama: "orta",
                                 Genislik: 90),
            new("lot", "o.lot", "metin", "Lot", Hizalama: "orta", Genislik: 110),
            new("aciklama", "o.aciklama", "metin", "Açıklama", Genislik: 400),
            new("kullanici", "coalesce(k.unvan, '')", "metin", "Kaydeden",
                                 Genislik: 180, Varsayilan: false),
        });

    /// <summary>
    /// SERUM İNDEKSİ EŞİKLERİ (444) — test bazlı HIL sınırları.
    ///
    /// Potasyum hemolizden 20 indekste etkilenir, sodyum 200'de bile
    /// etkilenmez; tek eşikle bütün paneli reddetmek çalışılabilir
    /// testleri de çöpe atmak olurdu.
    /// </summary>
    private static KaynakTanimi LabIndeksEsik() => new(
        Ad: "lab-indeks-esik",
        YetkiKodu: "lab.tetkik",
        Kaynak: "public.lab_indeks_esik e "
              + "  left join public.lab_tetkik t on t.id = e.tetkik_id",
        SubeKolonu: null,
        VarsayilanSirala: "e.tetkik_id nulls first, e.indeks",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "e.id", "sayi", "Id", Varsayilan: false),
            new("kapsam",
                "case when e.tetkik_id is null then 'Varsayılan (tüm testler)' "
                + "else t.kod || ' · ' || t.ad end",
                                 "metin", "Kapsam", Genislik: 240,
                                 Filtrelenebilir: false),
            new("indeksAdi",
                "case e.indeks when 2 then 'Lipemi (L)' when 3 then 'İkter (İ)' "
                + "else 'Hemoliz (H)' end",
                                 "metin", "İndeks", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 120, Filtrelenebilir: false),
            new("indeks", "e.indeks", "kod", "İndeks Kodu", Varsayilan: false),
            new("uyariEsik", "e.uyari_esik", "sayi", "Uyarı Eşiği", Hizalama: "sag",
                                 Bicim: "#,##0.#", Genislik: 110),
            new("retEsik", "e.ret_esik", "sayi", "Ret Eşiği", Hizalama: "sag",
                                 Bicim: "#,##0.#", Genislik: 110),
            new("etkiAdi",
                "case e.etki when 1 then 'Yalancı yükseklik' "
                + "when 2 then 'Yalancı düşüklük' else 'Belirsiz' end",
                                 "metin", "Etki Yönü", Hizalama: "orta", Genislik: 150,
                                 Filtrelenebilir: false),
            new("etki", "e.etki", "kod", "Etki Kodu", Varsayilan: false),
            new("aciklama", "e.aciklama", "metin", "Açıklama", Genislik: 360),
            new("durumAdi", "case e.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "e.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("tetkikId", "e.tetkik_id", "sayi", "Tetkik Id", Varsayilan: false),
        });
}
