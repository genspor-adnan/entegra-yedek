namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// GÖZ (OFTALMOLOJİ) MODÜLÜ LİSTELERİ (691) — tasarım notu
/// <c>Ekranlar/Goz/goz_sureci.html</c>.
///
/// <para>Modül genel muayenenin ÜSTÜNE oturur: tanı, e-reçete, tahakkuk ve
/// "Tamamla" akışı Muayene modülünde kalır; buradaki listeler gözün kendi
/// sorularını sorar — hasta hangi istasyonda bekliyor, hangi görüntüleme
/// değerlendirilmedi, hangi enjeksiyonun sırası geldi, hangi glokom hastası
/// kontrolünü kaçırdı.</para>
///
/// <para>Ölçüm tabloları (<c>goz_gorme</c>, <c>goz_refraksiyon</c>,
/// <c>goz_tonometri</c>…) LİSTE KAYNAĞI DEĞİLDİR: onlar muayene kartının
/// içinde OD/OS ikili olarak çizilir. Liste olarak açmak, hekimi "hangi
/// satır hangi göz" sorusuna boğardı.</para>
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>OD/OS/OU — her ölçüm ve işlem satırında aynı sözlük.</summary>
    private const string GozTarafIfade =
        "case g.goz when 1 then 'OD' when 2 then 'OS' when 3 then 'OU' else '' end";

    // ----------------------------------------------------------- ünite akışı ----
    /// <summary>
    /// GÖZ ÜNİTESİ AKIŞI — modülün giriş ekranı (mockup
    /// <c>goz_hasta_listesi.html</c>).
    ///
    /// <para>Satır = hastanın AÇIK istasyonu (kabul → ön tetkik → muayene →
    /// görüntüleme → karar). Ünitede iş, hastanın kendisinden çok <b>nerede
    /// beklediğiyle</b> yönetilir: dilatasyon damlası damlatılmış bir hasta
    /// yirmi dakika "görünmez" olur ve o süre hekimin sırasını bozar.</para>
    ///
    /// <para>Kaynak GÖRÜNÜM (<c>v_goz_unite_akis</c>): bekleme süresi ve
    /// dilatasyon hazırlığı hesaplı kolonlardır ve kanban ile grid AYNI
    /// hesabı kullanmalı — iki yerde hesaplanırsa iki farklı "22 dk" çıkar.</para>
    /// </summary>
    private static KaynakTanimi GozAkis() => new(
        Ad: "goz-akis",
        YetkiKodu: "goz",
        Kaynak: "public.v_goz_unite_akis a",
        SubeKolonu: "a.sube_id",
        VarsayilanSirala: "a.istasyon, a.sira_no, a.istasyon_giris",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "a.istasyon_id", "sayi", "Id", Varsayilan: false),
            new("belgeId",   "a.belge_id",    "sayi", "Başvuru Id", Varsayilan: false),
            new("hastaId",   "a.hasta_id",    "sayi", "Hasta Id", Varsayilan: false),
            new("siraNo",    "a.sira_no",     "sayi", "Sıra", Hizalama: "orta", Genislik: 70),
            new("hasta",     "a.hasta_adi",   "metin", "Hasta", Genislik: 220),
            new("istasyonAdi",
                "case a.istasyon when 1 then 'Kabul' when 2 then 'Ön tetkik' "
                + "when 3 then 'Muayene' when 4 then 'Görüntüleme' "
                + "when 5 then 'Karar / İşlem' when 6 then 'Tamamlandı' else '' end",
                                              "metin", "İstasyon", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 130, Filtrelenebilir: false),
            new("istasyon",  "a.istasyon",    "kod",  "İstasyon Kodu", Varsayilan: false),
            new("oda",       "a.oda",         "metin", "Oda", Genislik: 90),
            new("hekim",     "coalesce(a.hekim_adi, '')", "metin", "Hekim", Genislik: 180),
            // BEKLEME SÜRESİ ÜNİTENİN NABZI: darboğaz hangi istasyonda
            //   olduğunu ancak bu kolon söyler.
            new("beklemeDk", "a.bekleme_dk",  "sayi", "Bekleme (dk)", Hizalama: "sag", Genislik: 110),
            new("istasyonGiris", "a.istasyon_giris", "tarih", "Giriş", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm"),
            // Dilatasyon: damla saati + 20 dk. "Hazır" olmadan çağrılan hasta
            //   geri gönderilir; bu, ünitede en sık tekrarlanan kayıptır.
            new("dilatasyonHazirAdi",
                "case when a.dilatasyon_zamani is null then '' "
                + "when a.dilatasyon_hazir = 1 then 'hazır' else 'bekliyor' end",
                                              "metin", "Dilatasyon", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 110, Filtrelenebilir: false),
            new("dilatasyonHazir", "coalesce(a.dilatasyon_hazir, 0)", "mantik", "Dilatasyon Hazır",
                                              Varsayilan: false),
            new("dilatasyonIlac", "a.dilatasyon_ilac", "metin", "Damla", Varsayilan: false),
            // KALAN SÜRE SUNUCUDA: damla 20 dakikada etki eder ve pano bu
            //   sayacı çubukla gösteriyor. İstemci "şimdi - damla zamanı"
            //   hesaplasaydı, tarayıcı saati şaşan bir masada hasta hazır
            //   olmadan çağrılırdı.
            new("dilatasyonKalanDk",
                "case when a.dilatasyon_zamani is null then null "
                + "else greatest(0, 20 - (extract(epoch from (now() - a.dilatasyon_zamani)) "
                + "                       / 60)::int) end",
                                 "sayi", "Dilatasyon kalan (dk)", Hizalama: "sag",
                                 Genislik: 120, Filtrelenebilir: false, Varsayilan: false),
            new("muayeneTuruAdi",
                "case a.muayene_turu when 1 then 'Tam' when 2 then 'Kontrol' "
                + "when 3 then 'Postop' when 4 then 'Acil' when 5 then 'Tarama' "
                + "when 6 then 'Preop' when 7 then 'Refraktif' when 8 then 'Kontakt lens' else '' end",
                                              "metin", "Muayene", Hizalama: "orta", Genislik: 110,
                                              Filtrelenebilir: false),
            new("gozMuayeneId", "a.goz_muayene_id", "sayi", "Göz Muayene Id", Varsayilan: false),
        });

    // ------------------------------------------------------- göz muayeneleri ----
    /// <summary>
    /// GÖZ MUAYENELERİ — yapılmış ziyaretlerin listesi (kart:
    /// <c>goz_detayli_muayene.html</c>).
    ///
    /// <para>Listede OD/OS <b>BCVA ve GİB</b> durur, çünkü göz hekiminin bir
    /// muayeneyi hatırlamasını sağlayan iki sayı bunlardır. Ölçüm tablolarından
    /// "son değer" alt sorguyla çekilir; kolon çifti olarak muayeneye
    /// yazılsaydı aynı veri iki yerde tutulurdu.</para>
    /// </summary>
    private static KaynakTanimi GozMuayene() => new(
        Ad: "goz-muayene",
        YetkiKodu: "goz.muayene",
        Kaynak: "public.goz_muayene gm "
              + "join public.muayene m on m.id = gm.muayene_id "
              + "join public.taraf t on t.id = gm.hasta_id "
              + "left join public.taraf h on h.id = m.personel_id",
        SubeKolonu: "gm.sube_id",
        VarsayilanSirala: "m.muayene_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "gm.id",        "sayi", "Id", Varsayilan: false),
            new("muayeneId", "gm.muayene_id","sayi", "Muayene Id", Varsayilan: false),
            new("hastaId",   "gm.hasta_id",  "sayi", "Hasta Id", Varsayilan: false),
            new("tarih",     "m.muayene_tarihi", "tarih", "Tarih", Hizalama: "orta",
                                             Bicim: "dd.MM.yyyy HH:mm"),
            new("hasta",     "t.unvan",      "metin", "Hasta", Genislik: 220),
            new("hekim",     "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 180),
            new("turAdi",
                "case gm.muayene_turu when 1 then 'Tam' when 2 then 'Kontrol' "
                + "when 3 then 'Postop' when 4 then 'Acil' when 5 then 'Tarama' "
                + "when 6 then 'Preop' when 7 then 'Refraktif' when 8 then 'Kontakt lens' else '' end",
                                             "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                             Genislik: 110, Filtrelenebilir: false),
            new("tur",       "gm.muayene_turu", "kod", "Tür Kodu", Varsayilan: false),
            new("dilate",    "gm.dilate",    "mantik", "Dilate", Hizalama: "orta", Genislik: 80),
            // BCVA: en iyi düzeltilmiş görme (va_tur = 4). Sağ ve sol ayrı
            //   kolon, çünkü göz hekimi ikisini KARŞILAŞTIRARAK okur.
            new("bcvaOd",
                "(select v.deger_ondalik from public.goz_gorme v "
                + " where v.goz_muayene_id = gm.id and v.goz = 1 and v.tur = 4 "
                + " order by v.zaman desc limit 1)",
                                             "sayi", "BCVA OD", Hizalama: "sag", Genislik: 90,
                                             Bicim: "0.00", Filtrelenebilir: false),
            new("bcvaOs",
                "(select v.deger_ondalik from public.goz_gorme v "
                + " where v.goz_muayene_id = gm.id and v.goz = 2 and v.tur = 4 "
                + " order by v.zaman desc limit 1)",
                                             "sayi", "BCVA OS", Hizalama: "sag", Genislik: 90,
                                             Bicim: "0.00", Filtrelenebilir: false),
            new("gibOd",
                "(select o.gib from public.goz_tonometri o "
                + " where o.goz_muayene_id = gm.id and o.goz = 1 order by o.zaman desc limit 1)",
                                             "sayi", "GİB OD", Hizalama: "sag", Genislik: 85,
                                             Bicim: "0.0", Filtrelenebilir: false),
            new("gibOs",
                "(select o.gib from public.goz_tonometri o "
                + " where o.goz_muayene_id = gm.id and o.goz = 2 order by o.zaman desc limit 1)",
                                             "sayi", "GİB OS", Hizalama: "sag", Genislik: 85,
                                             Bicim: "0.0", Filtrelenebilir: false),
            // PANİK BAYRAĞI listede: GİB > 30 olan bir satırı karta girmeden
            //   görmek gerekir (akut glokom krizi saatlerle ölçülür).
            new("gibBayrak",
                "coalesce((select max(o.bayrak) from public.goz_tonometri o "
                + "         where o.goz_muayene_id = gm.id), 0)",
                                             "sayi", "GİB Uyarı", Hizalama: "orta", Genislik: 90,
                                             Varsayilan: false),
            new("kontrolGun", "gm.kontrol_gun", "sayi", "Kontrol (gün)", Hizalama: "sag",
                                             Varsayilan: false),
            new("gozlukReceteId", "gm.gozluk_recete_id", "sayi", "Gözlük Reçetesi", Varsayilan: false),
            new("eklemeTarihi", "gm.ekleme_tarihi", "tarih", "Kayıt", Varsayilan: false,
                                             Bicim: "dd.MM.yyyy HH:mm"),
        });

    // ---------------------------------------------------------- görüntüleme ----
    /// <summary>
    /// GÖRÜNTÜLEME / TANISAL TEST (mockup <c>goz_goruntuleme_cihazlar.html</c>).
    ///
    /// <para>OCT, görme alanı, biyometri, fundus fotoğrafı… hepsi tek listede:
    /// hekimin sorusu "bugün hangi çekimler değerlendirilmedi" — cihaza göre
    /// ayrı listeler bu soruyu cihaz sayısına böler.</para>
    /// </summary>
    private static KaynakTanimi GozGoruntuleme() => new(
        Ad: "goz-goruntuleme",
        YetkiKodu: "goz.goruntuleme",
        Kaynak: "public.goz_goruntuleme g "
              + "join public.taraf t on t.id = g.hasta_id "
              + "left join public.goz_cihaz c on c.id = g.cihaz_id "
              + "left join public.taraf d on d.id = g.degerlendiren_id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.istem_zamani desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "g.id",          "sayi", "Id", Varsayilan: false),
            new("hastaId",   "g.hasta_id",    "sayi", "Hasta Id", Varsayilan: false),
            new("hasta",     "t.unvan",       "metin", "Hasta", Genislik: 220),
            new("goz",       GozTarafIfade,   "metin", "Göz", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 70, Filtrelenebilir: false),
            new("gozKod",    "g.goz",         "kod",  "Göz Kodu", Varsayilan: false),
            new("tetkikAdi",
                "case g.tetkik when 1 then 'OCT maküla' when 2 then 'OCT RNFL/GCC' "
                + "when 3 then 'OCT ön segment' when 4 then 'OCT-A' when 5 then 'FAF' "
                + "when 6 then 'FA / ICGA' when 7 then 'Fundus foto' when 8 then 'Görme alanı' "
                + "when 9 then 'Topografi' when 10 then 'Pakimetri' when 11 then 'Biyometri' "
                + "when 12 then 'Endotel' when 13 then 'UBM' when 14 then 'B-scan USG' "
                + "when 15 then 'ERG / VEP' else '' end",
                                              "metin", "Tetkik", Genislik: 160, Filtrelenebilir: false),
            new("tetkik",    "g.tetkik",      "kod",  "Tetkik Kodu", Varsayilan: false),
            new("cihaz",     "coalesce(c.ad, '')", "metin", "Cihaz", Genislik: 170),
            new("istemZamani", "g.istem_zamani", "tarih", "İstem", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm"),
            new("cekimZamani", "g.cekim_zamani", "tarih", "Çekim", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm"),
            new("durumAdi",
                "case g.durum when 0 then 'İptal' when 1 then 'İstendi' "
                + "when 2 then 'Çekildi' when 3 then 'Değerlendirildi' else '' end",
                                              "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 130, Filtrelenebilir: false),
            new("durum",     "g.durum",       "kod",  "Durum Kodu", Varsayilan: false),
            new("degerlendiren", "coalesce(d.unvan, '')", "metin", "Değerlendiren", Genislik: 170),
            // KALİTE listede: düşük sinyalli OCT'nin ölçümü trende girerse
            //   "incelme" sanılan şey aslında kötü çekimdir.
            new("kalite",    "g.kalite",      "sayi", "Kalite", Hizalama: "orta", Genislik: 80),
            // AI ÖN OKUMA bir TASLAKTIR: kolon "var/yok" der, sonuç demez.
            new("aiOnOkuma", "case when g.ai_on_okuma is null then 0 else 1 end",
                                              "mantik", "AI ön okuma", Hizalama: "orta",
                                              Varsayilan: false),
        });

    // -------------------------------------------------------------- işlemler ----
    /// <summary>
    /// GÖZ İŞLEMLERİ — enjeksiyon, lazer, ameliyat (mockup
    /// <c>goz_islem_planlama.html</c>).
    ///
    /// <para>Üç tür TEK listede: ünitenin günlük planı "bugün on enjeksiyon,
    /// üç lazer, iki fako" diye okunur. Ayrı listeler bu planı üçe bölerdi.</para>
    /// </summary>
    private static KaynakTanimi GozIslem() => new(
        Ad: "goz-islem",
        YetkiKodu: "goz.islem",
        Kaynak: "public.goz_islem g "
              + "join public.taraf t on t.id = g.hasta_id "
              + "left join public.taraf h on h.id = g.hekim_id "
              + "left join public.goz_enjeksiyon e on e.islem_id = g.id "
              + "left join public.goz_lazer l on l.islem_id = g.id "
              + "left join public.goz_ameliyat am on am.islem_id = g.id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.planlanan_tarih desc nulls last",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "g.id",          "sayi", "Id", Varsayilan: false),
            new("hastaId",   "g.hasta_id",    "sayi", "Hasta Id", Varsayilan: false),
            new("hasta",     "t.unvan",       "metin", "Hasta", Genislik: 220),
            new("goz",       GozTarafIfade,   "metin", "Göz", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 70, Filtrelenebilir: false),
            new("gozKod",    "g.goz",         "kod",  "Göz Kodu", Varsayilan: false),
            new("turAdi",
                "case g.tur when 1 then 'İntravitreal enjeksiyon' when 2 then 'Lazer' "
                + "when 3 then 'Ameliyat' when 4 then 'Küçük cerrahi' "
                + "when 5 then 'Perioküler enjeksiyon' else '' end",
                                              "metin", "İşlem", Genislik: 190, Filtrelenebilir: false),
            new("tur",       "g.tur",         "kod",  "İşlem Kodu", Varsayilan: false),
            // TÜRE ÖZEL DETAY tek kolonda özetlenir: "Aflibersept · 4. doz",
            //   "SLT 360°", "Fako + IOL 21.5 D". Üç ayrı kolon, her satırda
            //   ikisini boş bırakırdı.
            new("detay",
                "coalesce("
                + " case when e.id is not null then "
                + "   trim(both ' · ' from "
                + "     (case e.ilac when 1 then 'Aflibersept' when 2 then 'Ranibizumab' "
                + "      when 3 then 'Bevasizumab' when 4 then 'Farisimab' "
                + "      when 5 then 'Deksametazon implant' when 6 then 'Triamsinolon' else '' end)"
                + "     || case when e.doz_no is null then '' else ' · ' || e.doz_no || '. doz' end) end,"
                + " case when l.id is not null then "
                + "   (case l.lazer_tur when 1 then 'SLT' when 2 then 'ALT' "
                + "    when 3 then 'YAG kapsülotomi' when 4 then 'YAG iridotomi' when 5 then 'PRP' "
                + "    when 6 then 'Fokal / grid' when 7 then 'Mikropuls' when 8 then 'Retinopeksi' "
                + "    when 9 then 'Vitreolizis' else '' end)"
                + "   || case when l.alan = '' then '' else ' · ' || l.alan end end,"
                + " case when am.id is not null then "
                + "   (case am.ameliyat_tur when 1 then 'Fako + IOL' when 2 then 'ECCE' "
                + "    when 3 then 'Sekonder IOL' when 4 then 'Trabekülektomi' when 5 then 'Tüp' "
                + "    when 6 then 'PPV' when 7 then 'Skleral çökertme' when 8 then 'Pterjium' "
                + "    when 9 then 'DCR' when 10 then 'Pitozis' when 11 then 'Şaşılık' "
                + "    when 12 then 'Keratoplasti' when 13 then 'Refraktif' when 14 then 'ICL' "
                + "    else '' end)"
                + "   || case when am.iol_guc is null then '' else ' · ' || am.iol_guc || ' D' end end,"
                + " '')",
                                              "metin", "Detay", Genislik: 230, Filtrelenebilir: false),
            new("hekim",     "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 180),
            new("planlananTarih", "g.planlanan_tarih", "tarih", "Planlanan", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm"),
            new("uygulamaZamani", "g.uygulama_zamani", "tarih", "Uygulama", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm"),
            new("salon",     "g.salon",       "metin", "Salon", Genislik: 110),
            new("durumAdi",
                "case g.durum when 0 then 'İptal' when 1 then 'Planlı' when 2 then 'Hazır' "
                + "when 3 then 'Uygulandı' when 4 then 'Ertelendi' else '' end",
                                              "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 110, Filtrelenebilir: false),
            new("durum",     "g.durum",       "kod",  "Durum Kodu", Varsayilan: false),
            new("endikasyon","g.endikasyon_icd", "metin", "Endikasyon", Genislik: 110),
            // KOMPLİKASYON listede görünür: kalite göstergesi (endoftalmi,
            //   PCR oranı) ancak satırda durursa toplanabilir.
            new("komplikasyon",
                "case g.komplikasyon when 0 then '' when 1 then 'PCR' when 2 then 'Zonül diyalizi' "
                + "when 3 then 'Vitreus kaybı' when 4 then 'Endoftalmi' when 5 then 'GİB yükselmesi' "
                + "when 6 then 'Kornea ödemi' when 7 then 'Retina dekolmanı' when 8 then 'Kanama' "
                + "else '' end",
                                              "metin", "Komplikasyon", Genislik: 150,
                                              Filtrelenebilir: false),
            // TIME-OUT: yanlış göz cerrahisi önlenebilir bir olaydır; teyit
            //   yapılmadan "uygulandı" olan satır listede görünmeli.
            new("timeOut",   "case when g.time_out is null then 0 else 1 end",
                                              "mantik", "Time-out", Hizalama: "orta", Genislik: 90),
        });

    // ---------------------------------------------------------- gözlük reçetesi ----
    /// <summary>
    /// GÖZLÜK REÇETELERİ (mockup <c>goz_gozluk_recetesi.html</c>).
    ///
    /// <para>Reçete muayenenin bir alanı değil kendi kaydıdır: hastaya verilir,
    /// optikte kullanılır, geçerlilik süresi vardır ve SGK hakkı ona bağlıdır.
    /// Listede OD/OS değerleri <b>tek okunur metin</b> olarak durur — sekiz
    /// ayrı sayı kolonu, gridi reçete formuna çevirirdi.</para>
    /// </summary>
    private static KaynakTanimi GozGozlukRecete() => new(
        Ad: "goz-gozluk-recete",
        YetkiKodu: "goz.recete",
        Kaynak: "public.goz_gozluk_recetesi r "
              + "join public.taraf t on t.id = r.hasta_id "
              + "left join public.taraf h on h.id = r.hekim_id "
              + "left join public.taraf o on o.id = r.optik_taraf_id",
        SubeKolonu: "r.sube_id",
        VarsayilanSirala: "r.ekleme_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "r.id",          "sayi", "Id", Varsayilan: false),
            new("hastaId",   "r.hasta_id",    "sayi", "Hasta Id", Varsayilan: false),
            new("receteNo",  "r.recete_no",   "metin", "Reçete No", Genislik: 140),
            new("tarih",     "r.ekleme_tarihi", "tarih", "Tarih", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy"),
            new("hasta",     "t.unvan",       "metin", "Hasta", Genislik: 220),
            new("hekim",     "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 170),
            new("turAdi",
                "case r.tur when 1 then 'Uzak' when 2 then 'Yakın' when 3 then 'Bifokal' "
                + "when 4 then 'Progresif' when 5 then 'Ara mesafe' when 6 then 'Güneş' else '' end",
                                              "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 100, Filtrelenebilir: false),
            new("tur",       "r.tur",         "kod",  "Tür Kodu", Varsayilan: false),
            // Reçete yazımı: "-2.25 / -0.75 x 170" — optikte konuşulan biçim.
            //   `FM` biçim öneki ŞART: onsuz to_char sayıyı sağa yaslamak için
            //   boşlukla doldurur ve reçete "-   2.25" diye çıkar.
            new("od",
                "trim(coalesce(to_char(r.od_sph, 'FMS990D00'), '') "
                + "|| case when r.od_cyl is null then '' "
                + "        else ' / ' || to_char(r.od_cyl, 'FMS990D00') "
                + "             || ' x ' || coalesce(r.od_aks::text, '') end "
                + "|| case when r.od_add is null then '' "
                + "        else '  add ' || to_char(r.od_add, 'FMS990D00') end)",
                                              "metin", "OD", Genislik: 190, Filtrelenebilir: false),
            new("os",
                "trim(coalesce(to_char(r.os_sph, 'FMS990D00'), '') "
                + "|| case when r.os_cyl is null then '' "
                + "        else ' / ' || to_char(r.os_cyl, 'FMS990D00') "
                + "             || ' x ' || coalesce(r.os_aks::text, '') end "
                + "|| case when r.os_add is null then '' "
                + "        else '  add ' || to_char(r.os_add, 'FMS990D00') end)",
                                              "metin", "OS", Genislik: 190, Filtrelenebilir: false),
            new("durumAdi",
                "case r.durum when 0 then 'İptal' when 1 then 'Taslak' when 2 then 'İmzalandı' "
                + "when 3 then 'Optiğe verildi' when 4 then 'Teslim edildi' else '' end",
                                              "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 130, Filtrelenebilir: false),
            new("durum",     "r.durum",       "kod",  "Durum Kodu", Varsayilan: false),
            new("optik",     "coalesce(o.unvan, '')", "metin", "Optik", Genislik: 180),
            new("gecerlilikBitis", "r.gecerlilik_bitis", "tarih", "Geçerlilik", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy"),
            new("sgkHak",    "r.sgk_hak",     "mantik", "SGK hakkı", Hizalama: "orta",
                                              Varsayilan: false),
        });

    // ------------------------------------------------------- hastalık takibi ----
    /// <summary>
    /// KRONİK GÖZ HASTALIĞI TAKİBİ — glokom, DR, AMD, üveit, keratokonus.
    ///
    /// <para>Bu liste "bugün kim geldi"yi değil <b>"kim gelmedi"</b>yi sorar:
    /// glokom sessiz ilerler, kaçırılan kontrol yıllar sonra görme kaybıyla
    /// fark edilir. Bu yüzden varsayılan sıralama <c>sonraki_kontrol</c> ve
    /// gecikmiş satırlar listenin başında durur.</para>
    /// </summary>
    private static KaynakTanimi GozTakip() => new(
        Ad: "goz-takip",
        YetkiKodu: "goz.takip",
        Kaynak: "public.goz_hastalik_takip g "
              + "join public.taraf t on t.id = g.hasta_id "
              + "left join public.taraf h on h.id = g.hekim_id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.sonraki_kontrol asc nulls last",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "g.id",          "sayi", "Id", Varsayilan: false),
            new("hastaId",   "g.hasta_id",    "sayi", "Hasta Id", Varsayilan: false),
            new("hasta",     "t.unvan",       "metin", "Hasta", Genislik: 220),
            new("goz",       GozTarafIfade,   "metin", "Göz", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 70, Filtrelenebilir: false),
            new("gozKod",    "g.goz",         "kod",  "Göz Kodu", Varsayilan: false),
            new("hastalikAdi",
                "case g.hastalik when 1 then 'Glokom' when 2 then 'Diyabetik retinopati' "
                + "when 3 then 'AMD' when 4 then 'Üveit' when 5 then 'Keratokonus' "
                + "when 6 then 'Ambliyopi' else '' end",
                                              "metin", "Hastalık", Genislik: 180, Filtrelenebilir: false),
            new("hastalik",  "g.hastalik",    "kod",  "Hastalık Kodu", Varsayilan: false),
            new("evre",      "g.evre",        "metin", "Evre", Genislik: 130),
            new("hekim",     "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 170),
            new("hedefGib",  "g.hedef_gib",   "sayi", "Hedef GİB", Hizalama: "sag", Genislik: 100,
                                              Bicim: "0.0"),
            new("sonrakiKontrol", "g.sonraki_kontrol", "tarih", "Sonraki Kontrol", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy"),
            // GECİKME GÜN SAYISI: "kaç gün gecikti" sorusunun cevabı listede
            //   dursun; tarihe bakıp hesaplamak, yüz satırda yüz hesap demek.
            new("gecikmeGun",
                "case when g.sonraki_kontrol is null or g.durum <> 1 then null "
                + "     else (current_date - g.sonraki_kontrol) end",
                                              "sayi", "Gecikme (gün)", Hizalama: "sag", Genislik: 110,
                                              Filtrelenebilir: false),
            new("progresyonAdi",
                "case g.progresyon_durum when 1 then 'Stabil' when 2 then 'Şüpheli' "
                + "when 3 then 'Progresyon' else '' end",
                                              "metin", "Progresyon", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 120, Filtrelenebilir: false),
            new("progresyon", "g.progresyon_durum", "kod", "Progresyon Kodu", Varsayilan: false),
            new("durum",     "g.durum",       "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
        });

    // ---------------------------------------------------------- dikte sözlüğü ----
    /// <summary>
    /// DİKTE SÖZLÜĞÜ (705) — terim, sesli komut ve sık cümle. Kod değil VERİ:
    /// "see de → C/D" eşlemesi hekimden hekime değişir, yeni bir kısaltma için
    /// sürüm çıkmak gerekmemeli.
    ///
    /// <para>KİŞİSEL SATIRLAR DA LİSTEDE: hekim kendi sözlüğünü buradan görür.
    /// Kimin olduğu kolonda yazar - başkasının kişisel terimini kurum sanıp
    /// silmesin.</para>
    /// </summary>
    private static KaynakTanimi DikteTerim() => new(
        Ad: "dikte-terim",
        YetkiKodu: "goz.dikte_sozluk",
        Kaynak: "public.dikte_terim d "
              + "left join public.taraf k on k.id = d.kullanici_id",
        // ŞUBE SÜZGECİ YOK: sözlük kurum genelinde tek. Şubeye bağlasaydık
        //   merkezde eklenen "gib → GİB" düzeltmesi şubede geçmez, aynı
        //   epikrizde iki yazım olurdu.
        SubeKolonu: null,
        VarsayilanSirala: "d.tur, d.sira, d.soylenen",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "d.id",          "sayi", "Id", Varsayilan: false),
            new("turAdi",
                "case d.tur when 1 then 'Terim' when 2 then 'Komut' "
                + "when 3 then 'Sık cümle' else '' end",
                                              "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 100, Filtrelenebilir: false),
            new("tur",       "d.tur",         "kod",  "Tür Kodu", Varsayilan: false),
            new("soylenen",  "d.soylenen",    "metin", "Söyleniş", Genislik: 200),
            new("yazilan",   "d.yazilan",     "metin", "Yazılan", Genislik: 280),
            new("eylem",     "d.eylem",       "metin", "Komut eylemi", Genislik: 200),
            new("kapsamAdi",
                "case d.kapsam when 1 then 'Kurum' else coalesce(k.unvan, 'Kullanıcı') end",
                                              "metin", "Kapsam", Genislik: 160,
                                              Filtrelenebilir: false),
            new("kapsam",    "d.kapsam",      "kod",  "Kapsam Kodu", Varsayilan: false),
            new("kullaniciId", "d.kullanici_id", "sayi", "Kullanıcı Id", Varsayilan: false),
            new("sira",      "d.sira",        "sayi", "Sıra", Hizalama: "sag", Genislik: 70),
            new("aktif",     "d.aktif",       "mantik", "Aktif", Hizalama: "orta", Genislik: 70),
        });

    // --------------------------------------------------------------- cihazlar ----
    /// <summary>
    /// GÖZ CİHAZLARI — otoref, NCT, OCT, GA, biyometri (Lab cihaz katmanıyla
    /// aynı entegrasyon modeli).
    /// </summary>
    private static KaynakTanimi GozCihaz() => new(
        Ad: "goz-cihaz",
        YetkiKodu: "goz.cihaz",
        Kaynak: "public.goz_cihaz c",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "c.tur, c.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "c.id",          "sayi", "Id", Varsayilan: false),
            new("kod",       "c.kod",         "metin", "Kod", Genislik: 110),
            new("ad",        "c.ad",          "metin", "Cihaz", Genislik: 240),
            new("turAdi",
                "case c.tur when 1 then 'Otoref / keratometre' when 2 then 'Tonometre' "
                + "when 3 then 'Pakimetre' when 4 then 'OCT' when 5 then 'Görme alanı' "
                + "when 6 then 'Fundus kamera' when 7 then 'Topografi' when 8 then 'Biyometri' "
                + "when 9 then 'Endotel' when 10 then 'USG' else '' end",
                                              "metin", "Tür", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 160, Filtrelenebilir: false),
            new("tur",       "c.tur",         "kod",  "Tür Kodu", Varsayilan: false),
            new("uretici",   "c.uretici",     "metin", "Üretici", Genislik: 140),
            new("model",     "c.model",       "metin", "Model", Genislik: 140),
            new("protokolAdi",
                "case c.protokol when 1 then 'DICOM' when 2 then 'Seri metin' "
                + "when 3 then 'Dosya' when 4 then 'API' else '' end",
                                              "metin", "Protokol", Hizalama: "orta", Genislik: 110,
                                              Filtrelenebilir: false),
            new("baglanti",  "c.baglanti",    "metin", "Bağlantı", Genislik: 190),
            new("mwl",       "c.mwl",         "mantik", "MWL", Hizalama: "orta", Genislik: 70),
            // SON MESAJ: "cihaz sessiz mi" sorusunun tek cevabı. Yeşil görünen
            //   ama dört saattir susan cihaz, ancak bu kolonla fark edilir.
            new("sonMesaj",  "c.son_mesaj",   "tarih", "Son Mesaj", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm"),
            new("olcumEslemeVar",
                "case when c.olcum_esleme = '{}'::jsonb then 0 else 1 end",
                                              "mantik", "Eşleme", Hizalama: "orta", Genislik: 80),
            new("aktif",     "c.aktif",       "mantik", "Aktif", Hizalama: "orta", Genislik: 70),
        });
}
