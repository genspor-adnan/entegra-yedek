namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// GÖZ MODÜLÜNÜN İKİNCİL LİSTELERİ (691/693): kontakt lens reçetesi, işlem
/// takip protokolleri, cihaz mesaj kuyruğu.
///
/// <para>Ana dosyadan (<c>KaynakKatalogu.Goz.cs</c>) ayrı duruyorlar çünkü
/// günlük akışın parçası değiller: biri reçetenin özel bir hâli, ikisi kurulum
/// ve bakım ekranı. Hepsi tek dosyada olsaydı modülün giriş ekranlarını bulmak
/// için bin satır taranacaktı.</para>
/// </summary>
public static partial class KaynakKatalogu
{
    // ------------------------------------------------------- kontakt lens ----
    /// <summary>
    /// KONTAKT LENS REÇETELERİ / DENEMELERİ.
    ///
    /// <para>Gözlükten AYRI liste: kontakt lens reçetesi bir <b>oturuş
    /// denemesidir</b> — aynı hastaya üç farklı eğrilik denenir ve hangisinin
    /// oturduğu satırda yazar. Gözlük reçetesiyle aynı listede dursaydı
    /// "hangisi verildi" sorusu iki farklı anlama gelirdi.</para>
    /// </summary>
    private static KaynakTanimi GozKontaktLens() => new(
        Ad: "goz-kontakt-lens",
        YetkiKodu: "goz.recete",
        Kaynak: "public.goz_kontakt_lens k "
              + "join public.taraf t on t.id = k.hasta_id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "k.ekleme_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "k.id",            "sayi", "Id", Varsayilan: false),
            new("hastaId",   "k.hasta_id",      "sayi", "Hasta Id", Varsayilan: false),
            new("tarih",     "k.ekleme_tarihi", "tarih", "Tarih", Hizalama: "orta",
                                                Bicim: "dd.MM.yyyy"),
            new("hasta",     "t.unvan",         "metin", "Hasta", Genislik: 220),
            new("goz",
                "case k.goz when 1 then 'OD' when 2 then 'OS' when 3 then 'OU' else '' end",
                                                "metin", "Göz", Hizalama: "orta", Bicim: "rozet",
                                                Genislik: 70, Filtrelenebilir: false),
            new("gozKod",    "k.goz",           "kod",  "Göz Kodu", Varsayilan: false),
            new("lensTurAdi",
                "case k.lens_tur when 1 then 'Yumuşak günlük' when 2 then 'Yumuşak aylık' "
                + "when 3 then 'Torik' when 4 then 'Multifokal' when 5 then 'RGP' "
                + "when 6 then 'Skleral' when 7 then 'Ortokeratoloji' else '' end",
                                                "metin", "Lens Türü", Genislik: 150,
                                                Filtrelenebilir: false),
            new("lensTur",   "k.lens_tur",      "kod",  "Lens Tür Kodu", Varsayilan: false),
            new("markaModel","k.marka_model",   "metin", "Marka / Model", Genislik: 180),
            // Reçete optikte TEK SATIR okunur: "-2.25 / -0.75 x 170".
            //   `FM` biçim öneki olmadan to_char sayıyı boşlukla doldurur.
            new("recete",
                "trim(coalesce(to_char(k.sph, 'FMS990D00'), '') "
                + "|| case when k.cyl is null then '' "
                + "        else ' / ' || to_char(k.cyl, 'FMS990D00') "
                + "             || ' x ' || coalesce(k.aks::text, '') end)",
                                                "metin", "Reçete", Genislik: 160,
                                                Filtrelenebilir: false),
            new("bc",        "k.bc",            "sayi", "BC", Hizalama: "sag", Genislik: 70,
                                                Bicim: "0.00"),
            new("dia",       "k.dia",           "sayi", "DIA", Hizalama: "sag", Genislik: 70,
                                                Bicim: "0.00"),
            new("va",        "k.va",            "sayi", "VA", Hizalama: "sag", Genislik: 70,
                                                Bicim: "0.00"),
            new("oturus",    "k.oturus",        "metin", "Oturuş", Genislik: 200),
            // DENEME ile REÇETE aynı tabloda ama ayrı anlamda: denenen lens
            //   hastaya verilmez, sonucu bir sonraki denemeyi belirler.
            new("deneme",    "k.deneme",        "mantik", "Deneme", Hizalama: "orta", Genislik: 80),
            new("kullanimSaat", "k.kullanim_saat", "sayi", "Kullanım (saat/gün)",
                                                Hizalama: "sag", Varsayilan: false),
        });

    // --------------------------------------------------- işlem protokolleri ----
    /// <summary>
    /// POSTOP / İŞLEM TAKİP PROTOKOLLERİ — "fako sonrası 1. gün, 1. hafta,
    /// 1. ay" gibi kontrol planları.
    ///
    /// <para>Protokol bir <b>şablondur</b>: işleme bağlanınca postop randevular
    /// ve damla şeması ondan üretilir. Hekimin her hastada aynı planı elle
    /// kurması, unutulan birinci gün kontrolü demektir.</para>
    /// </summary>
    private static KaynakTanimi GozIslemProtokol() => new(
        Ad: "goz-islem-protokol",
        YetkiKodu: "goz.islem",
        Kaynak: "public.goz_islem_protokol p",
        VarsayilanSirala: "p.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.id",          "sayi", "Id", Varsayilan: false),
            new("ad",        "p.ad",          "metin", "Protokol", Genislik: 300),
            new("islemTurAdi",
                "case p.islem_tur when 1 then 'İntravitreal enjeksiyon' when 2 then 'Lazer' "
                + "when 3 then 'Ameliyat' when 4 then 'Küçük cerrahi' "
                + "when 5 then 'Perioküler enjeksiyon' else '' end",
                                              "metin", "İşlem Türü", Genislik: 190,
                                              Filtrelenebilir: false),
            new("islemTur",  "p.islem_tur",   "kod",  "İşlem Tür Kodu", Varsayilan: false),
            new("ameliyatTurAdi",
                "case p.ameliyat_tur when 1 then 'Fako + IOL' when 2 then 'ECCE' "
                + "when 3 then 'Sekonder IOL' when 4 then 'Trabekülektomi' when 5 then 'Tüp' "
                + "when 6 then 'PPV' when 7 then 'Skleral çökertme' when 8 then 'Pterjium' "
                + "when 9 then 'DCR' when 10 then 'Pitozis' when 11 then 'Şaşılık' "
                + "when 12 then 'Keratoplasti' when 13 then 'Refraktif' when 14 then 'ICL' "
                + "else '' end",
                                              "metin", "Ameliyat", Genislik: 160,
                                              Filtrelenebilir: false),
            // KONTROL SAYISI listede: protokolün yükünü tek sayı söyler;
            //   planın kendisi (hangi gün, ne bakılacak) kartta okunur.
            new("kontrolSayisi", "coalesce(jsonb_array_length(p.kontroller), 0)",
                                              "sayi", "Kontrol Sayısı", Hizalama: "sag",
                                              Genislik: 120, Filtrelenebilir: false),
            new("ilacSayisi", "coalesce(jsonb_array_length(p.ilaclar), 0)",
                                              "sayi", "Damla Şeması", Hizalama: "sag",
                                              Genislik: 110, Filtrelenebilir: false),
            new("aktif",     "p.aktif",       "mantik", "Aktif", Hizalama: "orta", Genislik: 70),
        });

    // ------------------------------------------------------ cihaz mesajları ----
    /// <summary>
    /// CİHAZ MESAJ KUYRUĞU — ham ölçüm dosyaları ve seri mesajlar.
    ///
    /// <para>Listenin asıl işi <b>SAHİPSİZ satırları</b> göstermek: hasta
    /// eşleşmesi tutmayan ölçüm kimseye yazılmaz ve burada bekler. Tahmin
    /// ederek hastaya yazmak, başkasının ölçümünü o hastanın dosyasına
    /// koymaktır — bu yüzden eşleşmeyen satır <b>hata değil iş kuyruğudur</b>
    /// ve elle sahiplendirilir.</para>
    /// </summary>
    private static KaynakTanimi GozCihazMesaj() => new(
        Ad: "goz-cihaz-mesaj",
        YetkiKodu: "goz.cihaz",
        Kaynak: "public.goz_cihaz_mesaj m "
              + "join public.goz_cihaz c on c.id = m.cihaz_id",
        SubeKolonu: "c.sube_id",
        VarsayilanSirala: "m.zaman desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "m.id",          "sayi", "Id", Varsayilan: false),
            new("zaman",     "m.zaman",       "tarih", "Zaman", Hizalama: "orta",
                                              Bicim: "dd.MM.yyyy HH:mm"),
            new("cihaz",     "c.ad",          "metin", "Cihaz", Genislik: 200),
            new("cihazId",   "m.cihaz_id",    "sayi", "Cihaz Id", Varsayilan: false),
            new("hastaEslesme", "m.hasta_eslesme", "metin", "Hasta Eşleşmesi", Genislik: 180),
            new("durumAdi",
                "case m.islem_durum when 0 then 'Bekliyor' when 1 then 'İşlendi' "
                + "when 2 then 'Sahipsiz' when 3 then 'Hata' else '' end",
                                              "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 110, Filtrelenebilir: false),
            new("durum",     "m.islem_durum", "kod",  "Durum Kodu", Varsayilan: false),
            new("hata",      "m.hata",        "metin", "Hata", Genislik: 260),
            new("dosyaYolu", "m.dosya_yolu",  "metin", "Dosya", Genislik: 240, Varsayilan: false),
            // HAM MESAJ GRIDDE DEĞİL: yüz satırlık bir OCT XML'i listeyi
            //   okunmaz yapar - ilk 120 karakter kimliklendirmeye yeter,
            //   tamamı ayrıntıda görülür.
            new("hamOzet",   "left(m.ham, 120)", "metin", "Ham (ilk 120)", Genislik: 300,
                                              Varsayilan: false, Filtrelenebilir: false),
        });


    // ------------------------------------------------------- hasta özeti ----
    /// <summary>
    /// GÖZ HASTA ÖZETİ — hasta başına TEK satır (mockup
    /// <c>goz_hasta_karti.html</c>).
    ///
    /// <para>Göz hekiminin hastayı ilk gördüğünde sorduğu soru sabittir:
    /// <b>"iki gözde ne kadar görüyor, basınç kaç, hangi takipte?"</b> Cevap
    /// yedi tabloda ve onlarca ziyarette dağılmış; bu liste onu tek satıra
    /// indirir. Ayrıntı (ziyaretler, işlemler, reçeteler, trend) satır
    /// seçilince alt panelde açılır.</para>
    ///
    /// <para>Kaynak <c>goz_hasta_ozet</c> TABLOSU DEĞİL: materyalize özetin
    /// bedeli, onu güncel tutan tetikleyicilerin her ölçüm tablosuna yazılması
    /// ve biri unutulduğunda özetin sessizce eskimesidir. Buradaki değerler
    /// ölçümün kendisinden okunur — yanlış olma ihtimali yok.</para>
    /// </summary>
    private static KaynakTanimi GozHastaOzet() => new(
        Ad: "goz-hasta-ozet",
        YetkiKodu: "goz",
        Kaynak: "public.taraf t",
        // Yalnız GÖZ KAYDI OLAN hastalar: bütün hasta listesini göz ekranında
        //   göstermek, aramayı değersiz kılardı.
        SabitKosul: "t.hasta = 1 and (exists (select 1 from public.goz_muayene gm where gm.hasta_id = t.id) "
                  + "or exists (select 1 from public.goz_hastalik_takip gt where gt.hasta_id = t.id) "
                  + "or exists (select 1 from public.goz_islem gi where gi.hasta_id = t.id))",
        VarsayilanSirala: "t.unvan",
        Kolonlar: new KolonTanimi[]
        {
            new("id",    "t.id",    "sayi",  "Id", Varsayilan: false),
            new("hasta", "t.unvan", "metin", "Hasta", Genislik: 240),
            new("kod",   "coalesce(t.kod, '')", "metin", "Hasta No", Genislik: 110),
            // BCVA ve GİB göz bazlı AYRI kolon: hekim ikisini karşılaştırarak
            //   okur ("sağ 0,3 sol 1,0" tek başına bir bulgudur).
            new("bcvaOd", GozSonOlcum("goz_gorme", "deger_ondalik", 1, "and v.tur = 4"),
                          "sayi", "BCVA OD", Hizalama: "sag", Genislik: 90, Bicim: "0.00",
                          Filtrelenebilir: false),
            new("bcvaOs", GozSonOlcum("goz_gorme", "deger_ondalik", 2, "and v.tur = 4"),
                          "sayi", "BCVA OS", Hizalama: "sag", Genislik: 90, Bicim: "0.00",
                          Filtrelenebilir: false),
            new("gibOd",  GozSonOlcum("goz_tonometri", "gib", 1, ""),
                          "sayi", "GİB OD", Hizalama: "sag", Genislik: 85, Bicim: "0.0",
                          Filtrelenebilir: false),
            new("gibOs",  GozSonOlcum("goz_tonometri", "gib", 2, ""),
                          "sayi", "GİB OS", Hizalama: "sag", Genislik: 85, Bicim: "0.0",
                          Filtrelenebilir: false),
            // AKTİF TAKİPLER tek metinde: "Glokom OD · AMD OS". Hastalık başına
            //   kolon açmak gridi hastalık sayısı kadar genişletirdi.
            new("takipler",
                "coalesce((select string_agg("
                + "     (case tk.hastalik when 1 then 'Glokom' when 2 then 'DR' when 3 then 'AMD' "
                + "      when 4 then 'Üveit' when 5 then 'Keratokonus' when 6 then 'Ambliyopi' "
                + "      else '' end)"
                + "     || ' ' || (case tk.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end),"
                + "     ' · ' order by tk.hastalik)"
                + "   from public.goz_hastalik_takip tk"
                + "  where tk.hasta_id = t.id and tk.durum = 1), '')",
                          "metin", "Aktif Takip", Genislik: 220, Filtrelenebilir: false),
            // GECİKEN KONTROL: "kim gelmedi" sorusunun cevabı. Glokom sessiz
            //   ilerler; kaçırılan kontrol yıllar sonra görme kaybıyla çıkar.
            new("gecikenKontrol",
                "(select max(current_date - tk.sonraki_kontrol) from public.goz_hastalik_takip tk"
                + " where tk.hasta_id = t.id and tk.durum = 1"
                + "   and tk.sonraki_kontrol is not null and tk.sonraki_kontrol < current_date)",
                          "sayi", "Geciken Kontrol (gün)", Hizalama: "sag", Genislik: 140,
                          Filtrelenebilir: false),
            new("sonZiyaret",
                "(select max(m.muayene_tarihi) from public.goz_muayene gm"
                + " join public.muayene m on m.id = gm.muayene_id where gm.hasta_id = t.id)",
                          "tarih", "Son Ziyaret", Hizalama: "orta", Bicim: "dd.MM.yyyy",
                          Filtrelenebilir: false),
            new("ziyaretSayisi",
                "(select count(*) from public.goz_muayene gm where gm.hasta_id = t.id)::int",
                          "sayi", "Ziyaret", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            // ENJEKSİYON SAYISI hekimin kararını doğrudan değiştirir
            //   ("kaçıncı doz" sorusu endikasyon ve geri ödeme sorusudur).
            new("enjeksiyonSayisi",
                "(select count(*) from public.goz_islem gi"
                + " where gi.hasta_id = t.id and gi.tur = 1 and gi.durum = 3)::int",
                          "sayi", "Enjeksiyon", Hizalama: "sag", Genislik: 100,
                          Filtrelenebilir: false),
            new("ameliyatSayisi",
                "(select count(*) from public.goz_islem gi"
                + " where gi.hasta_id = t.id and gi.tur = 3 and gi.durum = 3)::int",
                          "sayi", "Ameliyat", Hizalama: "sag", Genislik: 90,
                          Filtrelenebilir: false),
        });

    /// <summary>
    /// Hastanın bir gözündeki SON ölçüm değeri (BCVA, GİB…).
    ///
    /// <para>Alt sorgu tek yerde kuruluyor: aynı kalıbı dört kolonda elle
    /// yazmak, birinde `order by` unutulduğunda listede sessizce ESKİ değeri
    /// gösterirdi. Parametreler katalogdan gelir - istek metni buraya girmez.</para>
    /// </summary>
    private static string GozSonOlcum(string tablo, string kolon, int goz, string ekKosul)
        => $"(select v.{kolon} from public.{tablo} v "
         + $"  join public.goz_muayene gm on gm.id = v.goz_muayene_id "
         + $" where gm.hasta_id = t.id and v.goz = {goz} {ekKosul} "
         + $" order by v.zaman desc limit 1)";
}
