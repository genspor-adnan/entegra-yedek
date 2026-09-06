namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MİKROBİYOLOJİ LİSTELERİ (436) — kültür çalışma listesi ve katalogları.
///
/// Mockup: Ekranlar/Lab/lab_mikrobiyoloji.html.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// KÜLTÜR ÇALIŞMA LİSTESİ — mikrobiyolojinin günlük ekranı.
    ///
    /// <b>"Okuma zamanı geldi" kolonu bilinçli</b>: 24 saatlik plakayı 3.
    /// günde okumak negatif raporu güvenilmez yapar. Gecikme listede
    /// görünmezse kimse fark etmez.
    /// </summary>
    private static KaynakTanimi LabKultur() => new(
        Ad: "lab-kultur",
        YetkiKodu: "lab.kultur",
        Kaynak: "public.lab_kultur k "
              + "  join public.lab_tetkik t on t.id = k.tetkik_id "
              + "  join public.lab_istem i on i.id = k.istem_id "
              + "  join public.taraf h on h.id = k.hasta_id "
              + "  left join public.lab_numune n on n.id = k.numune_id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "k.ekim_zamani desc, k.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("barkod", "coalesce(n.barkod, '')", "metin", "Barkod", Hizalama: "orta",
                                 Genislik: 140),
            new("hastaAdi",
                "coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan)",
                                 "metin", "Hasta", Genislik: 200),
            new("tetkikAd", "t.ad", "metin", "Tetkik", Genislik: 200),
            new("ekimZamani", "k.ekim_zamani", "tarih", "Ekim", Hizalama: "orta",
                                 Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("besiyeriler",
                "(select string_agg(b.kod, ' · ' order by kb.sira) "
                + "   from public.lab_kultur_besiyeri kb "
                + "   join public.lab_besiyeri b on b.id = kb.besiyeri_id "
                + "  where kb.kultur_id = k.id)",
                                 "metin", "Besiyeri", Genislik: 160,
                                 Filtrelenebilir: false),
            new("gramSonuc", "k.gram_sonuc", "metin", "Gram / Direkt", Genislik: 180),
            // OKUMA GECİKMESİ: negatif sayı "daha var", pozitif "gecikti".
            //   FİLTRELENEBİLİR olmak zorunda: ekranın varsayılan çipi
            //   ("Okuma Zamanı Geldi") bu alana >= 0 koşulu koyuyor. Kapalı
            //   bırakılınca liste açılır açılmaz "bu alanda filtre
            //   kullanılamaz" hatası veriyordu.
            new("okumaGecikmeDk",
                "case when k.sonraki_okuma is null then null "
                + "else floor(extract(epoch from (now() - k.sonraki_okuma)) / 60)::int end",
                                 "sayi", "Okuma (dk)", Hizalama: "sag", Genislik: 100,
                                 Varsayilan: false),
            // OKUMA ZAMANI okunur biçimde: ham dakika ("-1.214") ekranda
            //   anlamsız - teknisyen "ne zaman bakacağım" sorusunu saat
            //   cinsinden sorar. Ham dakika kolonu çip filtresi için
            //   duruyor ama gridde varsayılan gösterilmez.
            new("okumaDurum",
                "case when k.sonraki_okuma is null then '—' "
                + "when k.sonraki_okuma <= now() then 'ZAMANI GELDİ' "
                + "when k.sonraki_okuma < now() + interval '1 hour' then 'birazdan' "
                + "else ceil(extract(epoch from (k.sonraki_okuma - now())) / 3600)::int "
                + "     || ' sa sonra' end",
                                 "metin", "Okuma", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 120, Filtrelenebilir: false,
                                 Siralanabilir: false),
            new("sonrakiOkuma", "k.sonraki_okuma", "tarih", "Sonraki Okuma",
                                 Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm",
                                 Genislik: 130),
            new("ureme", "public.fn_lab_kultur_ozet(k.id)", "metin",
                                 "Üreme / Organizma", Genislik: 260,
                                 Filtrelenebilir: false, Siralanabilir: false),
            new("antibiyogramSayisi",
                "(select count(*) from public.lab_antibiyogram g "
                + "   join public.lab_kultur_ureme u on u.id = g.ureme_id "
                + "  where u.kultur_id = k.id)",
                                 "sayi", "AB", Hizalama: "orta", Genislik: 60,
                                 Filtrelenebilir: false),
            new("kritik", "k.kritik", "mantik", "Kritik", Hizalama: "orta",
                                 Genislik: 80),
            new("ekkBildirim", "k.ekk_bildirim", "mantik", "EKK", Hizalama: "orta",
                                 Genislik: 70),
            new("durumAdi",
                "case k.durum when 0 then 'İptal' when 1 then 'Ekim' "
                + "when 2 then 'İnkübasyon' when 3 then 'Üreme' "
                + "when 4 then 'İdentifikasyon' when 5 then 'Antibiyogram' "
                + "when 6 then 'Rapor bekliyor' else 'Onaylı' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 140, Filtrelenebilir: false),
            new("durum", "k.durum", "kod", "Durum Kodu", Varsayilan: false),
            new("oncelikAdi",
                "case i.oncelik when 2 then 'Öncelikli' when 3 then 'Acil' "
                + "else 'Normal' end",
                                 "metin", "Öncelik", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 100, Filtrelenebilir: false),
            new("onRapor", "k.on_rapor", "metin", "Ön Rapor", Genislik: 240,
                                 Varsayilan: false),
            new("uzmanYorum", "k.uzman_yorum", "metin", "Uzman Yorumu", Genislik: 260,
                                 Varsayilan: false),
            new("istemId", "k.istem_id", "sayi", "İstem Id", Varsayilan: false),
            new("istemSatirId", "k.istem_satir_id", "sayi", "Satır Id",
                                 Varsayilan: false),
            new("hastaId", "k.hasta_id", "sayi", "Hasta Id", Varsayilan: false),
        });

    private static KaynakTanimi LabBesiyeri() => new(
        Ad: "lab-besiyeri",
        YetkiKodu: "lab.mikro",
        Kaynak: "public.lab_besiyeri b",
        SubeKolonu: null,                     // katalog - şubeler arası ortak
        VarsayilanSirala: "b.kod asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "b.id", "sayi", "Id", Varsayilan: false),
            new("kod", "b.kod", "metin", "Kod", Genislik: 100),
            new("ad", "b.ad", "metin", "Besiyeri", Genislik: 260),
            new("turAdi",
                "case b.tur when 2 then 'Sıvı (buyyon)' when 3 then 'Kan kültür şişesi' "
                + "when 9 then 'Diğer' else 'Katı (agar)' end",
                                 "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 150, Filtrelenebilir: false),
            new("sicaklik", "b.sicaklik", "sayi", "°C", Hizalama: "sag", Genislik: 60),
            new("atmosferAdi",
                "case b.atmosfer when 2 then 'Anaerob' when 3 then '%5 CO₂' "
                + "when 4 then 'Mikroaerofil' else 'Aerob' end",
                                 "metin", "Atmosfer", Hizalama: "orta", Genislik: 120,
                                 Filtrelenebilir: false),
            new("ilkOkuma", "b.ilk_okuma_saat", "sayi", "İlk Okuma (s)", Hizalama: "sag",
                                 Genislik: 110),
            new("sonOkuma", "b.son_okuma_saat", "sayi", "Son Okuma (s)", Hizalama: "sag",
                                 Genislik: 110),
            new("aciklama", "b.aciklama", "metin", "Açıklama", Genislik: 260),
            new("durumAdi", "case b.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "b.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// ORGANİZMA KATALOĞU — rapor ve direnç sürveyansı buna dayanır.
    /// Serbest metin yazılsaydı "E.coli" ile "E. coli" iki ayrı etken sayılırdı.
    /// </summary>
    private static KaynakTanimi LabOrganizma() => new(
        Ad: "lab-organizma",
        YetkiKodu: "lab.mikro",
        Kaynak: "public.lab_organizma o",
        SubeKolonu: null,
        VarsayilanSirala: "o.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "o.id", "sayi", "Id", Varsayilan: false),
            new("kod", "o.kod", "metin", "Kod", Genislik: 110),
            new("ad", "o.ad", "metin", "Organizma", Genislik: 280),
            new("kisaAd", "o.kisa_ad", "metin", "Kısa Ad", Genislik: 140),
            new("turAdi",
                "case o.tur when 2 then 'Mantar' when 3 then 'Virüs' "
                + "when 4 then 'Parazit' when 9 then 'Durum satırı' "
                + "else 'Bakteri' end",
                                 "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 120, Filtrelenebilir: false),
            new("gramAdi",
                "case o.gram when 1 then 'Gram (+)' when 2 then 'Gram (−)' else '' end",
                                 "metin", "Gram", Hizalama: "orta", Genislik: 90,
                                 Filtrelenebilir: false),
            new("morfolojiAdi",
                "case o.morfoloji when 1 then 'Kok' when 2 then 'Basil' "
                + "when 3 then 'Kokobasil' when 4 then 'Maya' when 5 then 'Küf' "
                + "when 9 then 'Diğer' else '' end",
                                 "metin", "Morfoloji", Hizalama: "orta", Genislik: 110,
                                 Filtrelenebilir: false),
            new("bildirimiZorunlu", "o.bildirimi_zorunlu", "mantik",
                                 "Bildirimi Zorunlu", Hizalama: "orta", Genislik: 130),
            new("sonucSatiri", "o.sonuc_satiri", "mantik", "Durum Satırı",
                                 Hizalama: "orta", Genislik: 110, Varsayilan: false),
            new("snomed", "o.snomed", "metin", "SNOMED", Hizalama: "orta", Genislik: 110,
                                 Varsayilan: false),
            new("skrsKod", "o.skrs_kod", "metin", "SKRS", Hizalama: "orta", Genislik: 100,
                                 Varsayilan: false),
            new("durumAdi", "case o.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "o.durum", "kod", "Durum Kodu", Varsayilan: false),
        });

    /// <summary>
    /// ANTİBİYOTİK KATALOĞU — "basamak" kolonu kademeli bildirimi yönetir:
    /// geniş spektrumlu ajan yalnız alt basamakta duyarlı seçenek yoksa
    /// raporlanır (Akılcı Antibiyotik Kullanımı).
    /// </summary>
    private static KaynakTanimi LabAntibiyotik() => new(
        Ad: "lab-antibiyotik",
        YetkiKodu: "lab.mikro",
        Kaynak: "public.lab_antibiyotik a",
        SubeKolonu: null,
        VarsayilanSirala: "a.basamak asc, a.ad asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "a.id", "sayi", "Id", Varsayilan: false),
            new("kod", "a.kod", "metin", "Kod", Genislik: 90),
            new("ad", "a.ad", "metin", "Antibiyotik", Genislik: 240),
            new("grup", "a.grup", "metin", "Grup", Genislik: 160),
            new("basamakAdi",
                "case a.basamak when 2 then '2 · Alternatif' "
                + "when 3 then '3 · Kısıtlı / geniş spektrum' "
                + "else '1 · Her zaman raporlanır' end",
                                 "metin", "Bildirim Basamağı", Hizalama: "orta",
                                 Bicim: "rozet", Genislik: 200, Filtrelenebilir: false),
            new("basamak", "a.basamak", "kod", "Basamak Kodu", Varsayilan: false),
            new("uygulamaAdi",
                "case a.uygulama when 1 then 'Oral' when 2 then 'Parenteral' "
                + "else 'Oral / parenteral' end",
                                 "metin", "Uygulama", Hizalama: "orta", Genislik: 140,
                                 Filtrelenebilir: false),
            new("yalnizUriner", "a.yalniz_uriner", "mantik", "Yalnız İdrar",
                                 Hizalama: "orta", Genislik: 110),
            new("atc", "a.atc", "metin", "ATC", Hizalama: "orta", Genislik: 90,
                                 Varsayilan: false),
            new("durumAdi", "case a.durum when 1 then 'Pasif' else 'Aktif' end",
                                 "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                 Genislik: 90, Filtrelenebilir: false),
            new("durum", "a.durum", "kod", "Durum Kodu", Varsayilan: false),
        });
}
