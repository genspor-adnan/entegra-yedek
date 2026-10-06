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
    /// <summary>
    /// Dilatasyon süresi (dk) — kalan süre kolonu bunu sayıyor. Uç tarafındaki
    /// karşılığı <c>GozUclari.DilatasyonDk</c>; çekirdek projesi API'ye bağımlı
    /// olmadığı için değer burada tekrar yazılıyor, ikisi birlikte değişir.
    /// </summary>
    private const int GozDilatasyonDk = 20;

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
            // SÜREÇ v2 (goz_sureci_v2): ziyaretin göz muayene kaydı - açılmadı / #id açık / tamamlandı.
            new("muayeneDurum",
                "case when a.goz_muayene_id is null then 'açılmadı' "
                + "when exists (select 1 from public.goz_muayene g join public.muayene m on m.id = g.muayene_id "
                + "              where g.id = a.goz_muayene_id and m.tamamlanma is not null) then 'tamamlandı' "
                + "else '#' || a.goz_muayene_id || ' açık' end",
                                              "metin", "Muayene", Hizalama: "orta", Bicim: "rozet", Genislik: 120, Filtrelenebilir: false),
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
                + $"else greatest(0, {GozDilatasyonDk} - (extract(epoch from (now() - a.dilatasyon_zamani)) "
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
            // 976 (mockup goz_unite_panosu.html): panonun ŞERİT ÇİPLERİ ve KANBAN
            //   KARTI bu kolonlardan çiziliyor. Hepsi görünümde hesaplanıyor çünkü
            //   grid ile kanban aynı satırı okuyor - "çağrıldı mı" iki yerde
            //   hesaplanırsa iki ekran iki farklı cevap verir.
            new("cagrildi",     "a.cagrildi",     "mantik", "Çağrıldı",     Varsayilan: false),
            new("cagriZamani",  "a.cagri_zamani", "zaman",  "Çağrı",        Hizalama: "orta",
                                                  Bicim: "HH:mm", Varsayilan: false),
            // İŞLEMDE: çağrılmış + kaynağı atanmış satır "şu an masada" (mockup
            //   bu kartı vurguluyor) - bekleyenle aynı görünen kart, sırayı
            //   olduğundan uzun gösterir.
            new("islemde",      "a.islemde",      "mantik", "İşlemde",      Varsayilan: false),
            new("gecikti",      "a.gecikti",      "mantik", "Geciken",      Varsayilan: false),
            new("dilatasyonda", "a.dilatasyonda", "mantik", "Dilatasyonda", Varsayilan: false),
            new("acil",         "a.acil",         "mantik", "Acil",         Varsayilan: false),
            new("cocuk",        "a.cocuk",        "mantik", "Çocuk",        Varsayilan: false),
            new("yas",          "a.yas",          "sayi",   "Yaş", Hizalama: "orta", Genislik: 60,
                                                  Varsayilan: false),
            new("cinsiyet",     "coalesce(a.cinsiyet, 0)", "kod", "Cinsiyet", Varsayilan: false),
            new("kaynakId",     "a.kaynak_id",    "sayi",   "Kaynak Id",    Varsayilan: false),
            new("hekimId",      "a.hekim_id",     "sayi",   "Hekim Id",     Varsayilan: false),
            // ÖN TETKİK TAMAMLANMASI: hastayı hekime almadan önce bakılan tek
            //   şey bu (mockup: "Otoref ✔ · Tonometri —").
            new("onTetkik",
                "case when a.goz_muayene_id is null then '' else "
                + "'Otoref ' || case when a.otoref_var = 1 then '✔' else '—' end "
                + "|| ' · Tonometri ' || case when a.tono_var = 1 then '✔' else '—' end end",
                                              "metin", "Ön tetkik", Hizalama: "orta", Genislik: 160,
                                              Filtrelenebilir: false),
            new("otorefVar",    "a.otoref_var",   "mantik", "Otoref alındı", Varsayilan: false),
            new("tonoVar",      "a.tono_var",     "mantik", "Tonometri alındı", Varsayilan: false),
            // ÖLÇÜM ÖZETİ: bir göz hastasını hatırlatan iki sayı GİB ve otoref.
            //   Ondalık ayıracı yerel ayara bırakılmıyor (to_char + replace).
            new("olcumOzet",
                "concat_ws(' · ', "
                + "case when a.gib_od is not null or a.gib_os is not null "
                + "     then 'GİB ' || coalesce(round(a.gib_od)::text, '—') || '/' "
                + "          || coalesce(round(a.gib_os)::text, '—') end, "
                + "case when a.ref_od_sph is not null or a.ref_os_sph is not null "
                + "     then 'otoref ' || coalesce(replace(to_char(a.ref_od_sph, 'FM990.00'), '.', ','), '—') "
                + "          || ' / ' || coalesce(replace(to_char(a.ref_os_sph, 'FM990.00'), '.', ','), '—') end)",
                                              "metin", "Ölçüm", Genislik: 200, Filtrelenebilir: false),
            // RANDEVU GECİKMESİ: hekim yükü tablosundaki "+12 dk" buradan çıkıyor;
            //   randevusuz hastada BOŞ kalır - gecikme ölçülemez, sıfır değildir.
            new("randevuSaat",  "a.randevu_saat", "zaman", "Randevu", Hizalama: "orta",
                                                  Bicim: "HH:mm", Varsayilan: false),
            new("randevuGecikmeDk", "a.randevu_gecikme_dk", "sayi", "Randevu gecikmesi (dk)",
                                                  Hizalama: "sag", Genislik: 120, Varsayilan: false),
        });

    // ------------------------------------------------------- oda / cihaz tanımı ----
    /// <summary>
    /// GÖZ ÜNİTESİ ODA / CİHAZ TANIMI (976) — panonun "Oda ve cihaz doluluğu"
    /// tablosunun kaynağı.
    ///
    /// <para><b>Serbest metin oda bir kaynak sayılmaz:</b> 976'ya kadar atama
    /// <c>goz_ziyaret_istasyon.oda</c> metniydi ve "OCT-1" ile "OCT1" iki ayrı
    /// satır üretiyordu; doluluk ikiye bölününce darboğaz görünmez oluyordu.</para>
    ///
    /// <para><b>Liste BOŞ kaynağı da gösterir</b> (<c>v_goz_kaynak_doluluk</c>):
    /// panonun söylediği şey "HFA sırası dört kişiyken muayene odası boş
    /// duruyor" - yalnız dolu kaynakları saymak bu cümleyi kurmayı imkânsız
    /// kılardı.</para>
    /// </summary>
    private static KaynakTanimi GozKaynak() => new(
        Ad: "goz-kaynak",
        YetkiKodu: "goz.kaynak",
        Kaynak: "public.goz_kaynak k "
              + "left join public.goz_cihaz c on c.id = k.cihaz_id "
              + "left join public.taraf p on p.id = k.personel_id "
              + "left join public.v_goz_kaynak_doluluk d on d.kaynak_id = k.id",
        SubeKolonu: "k.sube_id",
        VarsayilanSirala: "k.sira, k.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",   "k.id",  "sayi",  "Id", Varsayilan: false),
            new("kod",  "k.kod", "metin", "Kod", Genislik: 90),
            new("ad",   "k.ad",  "metin", "Oda / cihaz", Genislik: 200),
            new("turAdi",
                "case k.tur when 1 then 'Muayene odası' when 2 then 'Cihaz' "
                + "when 3 then 'İşlem odası' when 4 then 'Ön tetkik' else '' end",
                                 "metin", "Tür", Hizalama: "orta", Bicim: "rozet", Genislik: 130,
                                 Filtrelenebilir: false),
            new("tur",  "k.tur", "kod",   "Tür Kodu", Varsayilan: false),
            new("istasyonAdi",
                "case k.istasyon when 1 then 'Kabul' when 2 then 'Ön tetkik' "
                + "when 3 then 'Muayene' when 4 then 'Görüntüleme' "
                + "when 5 then 'Karar / İşlem' else 'Tümü' end",
                                 "metin", "İstasyon", Hizalama: "orta", Genislik: 120,
                                 Filtrelenebilir: false),
            new("istasyon", "k.istasyon", "kod", "İstasyon Kodu", Varsayilan: false),
            new("cihaz",  "coalesce(c.ad, '')", "metin", "Bağlı cihaz", Genislik: 160),
            new("cihazId", "k.cihaz_id", "sayi", "Cihaz Id", Varsayilan: false),
            new("sahip",
                "coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), '')",
                                 "metin", "Sabit sahibi", Genislik: 170),
            // ŞU AN: doluluk görünümünden - tanım ekranı aynı zamanda panonun
            //   küçük hâli olsun, kurulumda "doğru yeri mi tanımladım" sorusu
            //   başka ekran açmadan cevaplanabilsin.
            new("sayi",   "coalesce(d.sayi, 0)", "sayi", "Sırada", Hizalama: "orta",
                                 Bicim: "sayac", Genislik: 80),
            new("suAn",   "coalesce(d.hasta, '')", "metin", "Şu an", Genislik: 180,
                                 Filtrelenebilir: false),
            new("sureDk", "coalesce(d.sure_dk, 0)", "sayi", "Süre (dk)", Hizalama: "sag",
                                 Genislik: 90, Varsayilan: false),
            new("sira",   "k.sira", "sayi", "Sıra", Hizalama: "orta", Genislik: 70, Varsayilan: false),
            new("aktif",  "k.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 70),
            new("notMetin", "k.not_metin", "metin", "Not", Genislik: 200, Varsayilan: false),
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
              + "left join public.taraf h on h.id = m.personel_id "
              // 970: görme / GİB sağ-sol + bayraklar, tanı, kontrol, takip (liste + gösterge aynı tanım).
              + "left join public.v_goz_muayene_ozet v on v.goz_muayene_id = gm.id",
        SubeKolonu: "gm.sube_id",
        VarsayilanSirala: "m.muayene_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "gm.id",        "sayi", "Id", Varsayilan: false),
            new("muayeneId", "gm.muayene_id","sayi", "Muayene Id", Varsayilan: false),
            new("hastaId",   "gm.hasta_id",  "sayi", "Hasta Id", Varsayilan: false),
            new("tarih",     "m.muayene_tarihi", "tarih", "Tarih", Hizalama: "orta",
                                             Bicim: "dd.MM.yyyy HH:mm"),
            // SAAT + ALT METİN (mockup: "09:10" / altında "dilate 09:35").
            //   Gün ve saat birlikte: liste bir günle sınırlı değil (dönem
            //   çipleri hafta / tümü de seçiyor), yalnız saat yazmak hangi
            //   güne ait olduğunu belirsiz bırakırdı.
            new("saat", "to_char(m.muayene_tarihi at time zone 'Europe/Istanbul', 'DD.MM HH24:MI')",
                                             "metin", "Saat", Hizalama: "orta", Genislik: 100,
                                             Filtrelenebilir: false, Bicim: "alt:saatAlt"),
            // DAMLA SAATİ istasyon kaydından (goz_ziyaret_istasyon.dilatasyon_zamani):
            //   dilate bayrağı "damla verildi" demiyor, saati verilmiş olanda var.
            //   Süre dolmadıysa "damla HH:MM", dolduysa yalnız "dilate".
            new("saatAlt",
                // Damla saati YALNIZ dilate muayenede: hastanın o gün başka bir
                //   ziyarette damlası olabilir, dilate OLMAYAN muayenenin altına
                //   saat yazmak o muayenede damla yapıldığı anlamına gelirdi.
                "case when gm.dilate = 1 then concat_ws(' ', 'dilate', "
                + "(select to_char(zi.dilatasyon_zamani at time zone 'Europe/Istanbul', 'HH24:MI') "
                + "   from public.goz_ziyaret_istasyon zi "
                + "  where zi.hasta_id = gm.hasta_id and zi.dilatasyon_zamani is not null "
                + "    and zi.dilatasyon_zamani::date = m.muayene_tarihi::date "
                + "  order by zi.dilatasyon_zamani desc limit 1)) else '' end",
                                             "metin", "Saat Notu", Varsayilan: false, Filtrelenebilir: false),
            new("hasta",     "public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)",      "metin", "Hasta", Genislik: 200,
                Bicim: "alt:hastaAlt"),
            // 970 (mockup goz_muayene_listesi_v2): hastanın altında yaş / cinsiyet / takip / protokol.
            new("hastaAlt",
                "concat_ws(' · ', v.yas::text || case v.cinsiyet when 1 then ' E' when 2 then ' K' else '' end, "
                + "nullif(v.takip_hastaliklar, ''), nullif(v.protokol, ''))",
                                             "metin", "Hasta Bilgisi", Varsayilan: false, Filtrelenebilir: false),
            new("hekim",     "coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')", "metin", "Hekim", Genislik: 160),
            new("hekimId",   "m.personel_id", "sayi", "Hekim Id", Varsayilan: false),
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
            // GÖRME / GİB SAĞ-SOL TEK HÜCREDE (970, hücre biçimi "odos"): göz hekimi
            //   ikisini karşılaştırarak okur; bayrak biti (1 OD, 2 OS) kırmızı çizer.
            new("bcvaOd", "v.bcva_od", "sayi", "Görme (düz.)", Hizalama: "orta", Genislik: 100,
                                             Bicim: "odos:bcvaOs:gormeDusus", Filtrelenebilir: false),
            new("bcvaOs", "v.bcva_os", "sayi", "Görme OS", Varsayilan: false, Filtrelenebilir: false),
            new("gormeDusus", "coalesce(v.gorme_dusus, 0)", "sayi", "Görme Düşüşü", Varsayilan: false),
            new("gibOd", "v.gib_od", "sayi", "GİB", Hizalama: "orta", Genislik: 90,
                                             Bicim: "odos:gibOs:gibYuksek", Filtrelenebilir: false),
            new("gibOs", "v.gib_os", "sayi", "GİB OS", Varsayilan: false, Filtrelenebilir: false),
            new("gibYuksek", "coalesce(v.gib_yuksek, 0)", "sayi", "GİB Yüksek", Varsayilan: false),
            new("tani", "coalesce(v.tani, '')", "metin", "Tanı", Genislik: 200),
            new("kontrol",
                "case when v.kontrol_tarihi is null then '' else to_char(v.kontrol_tarihi, 'DD.MM.YYYY') end",
                                             "metin", "Kontrol", Hizalama: "orta", Genislik: 100, Filtrelenebilir: false),
            new("kontrolGecikmis", "coalesce(v.kontrol_gecikmis, 0)", "mantik", "Kontrol Gecikmiş", Varsayilan: false),
            new("dilatasyonBekliyor", "coalesce(v.dilatasyon_bekliyor, 0)", "mantik", "Dilatasyon Bekliyor", Varsayilan: false),
            new("tamamlandi", "case when m.tamamlanma is null then 0 else 1 end", "mantik", "Tamamlandı", Varsayilan: false),
            new("durumAdi", "case when m.tamamlanma is null then 'Taslak' else 'Tamamlandı' end",
                                             "metin", "Durum", Hizalama: "orta", Bicim: "rozet", Genislik: 100, Filtrelenebilir: false),
            new("glokom", "coalesce(v.glokom, 0)", "mantik", "Glokom Takibi", Varsayilan: false),
            new("retina", "coalesce(v.retina, 0)", "mantik", "Retina Takibi", Varsayilan: false),
            new("bugun", "case when (m.muayene_tarihi at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date then 1 else 0 end",
                                             "mantik", "Bugün", Varsayilan: false),
            new("son30", "case when m.muayene_tarihi >= now() - interval '30 days' then 1 else 0 end",
                                             "mantik", "Son 30 Gün", Varsayilan: false),
            new("buHafta", "case when m.muayene_tarihi >= date_trunc('week', now()) then 1 else 0 end",
                                             "mantik", "Bu Hafta", Varsayilan: false),
            // GÖRÜNTÜLEME İSTEMİ aksiyonu satırda `gozMuayeneId` arıyor (pano
            //   ile AYNI kod yolu): burada göz muayenesinin kendisi o kayıttır.
            new("gozMuayeneId", "gm.id", "sayi", "Göz Muayene Id", Varsayilan: false),
            new("uyari",
                "concat_ws(' · ', "
                + "case v.gib_yuksek when 1 then 'Sağ GİB hedef üstü' when 2 then 'Sol GİB hedef üstü' when 3 then 'İki göz GİB hedef üstü' end, "
                + "case v.gorme_dusus when 1 then 'Sağ görme düştü' when 2 then 'Sol görme düştü' when 3 then 'İki göz görme düştü' end, "
                + "case when v.dilatasyon_bekliyor = 1 then 'dilatasyon bekliyor' end, "
                + "case when v.kontrol_gecikmis = 1 then 'kontrol gecikti' end)",
                                             "metin", "Uyarı", Genislik: 190, Filtrelenebilir: false, Bicim: "uyari"),
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
              + "left join public.taraf d on d.id = g.degerlendiren_id "
              // 974: H / P, ana ölçüm, bekleme, uyarı (liste + gösterge aynı tanım).
              + "left join public.taraf ih on ih.id = g.istek_hekim_id "
              + "left join public.v_goz_goruntuleme_ozet v on v.goruntuleme_id = g.id",
        SubeKolonu: "g.sube_id",
        VarsayilanSirala: "g.istem_zamani desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "g.id",          "sayi", "Id", Varsayilan: false),
            new("hastaId",   "g.hasta_id",    "sayi", "Hasta Id", Varsayilan: false),
            // 974 (mockup goz_goruntuleme_listesi_v2): istem saati altında isteyen hekim.
            new("istemSaat", "to_char(g.istem_zamani at time zone 'Europe/Istanbul', 'DD.MM HH24:MI')",
                                              "metin", "İstem", Genislik: 110, Filtrelenebilir: false, Bicim: "alt:istekHekim"),
            new("istekHekim", "coalesce(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::varchar(120), '')", "metin", "İsteyen", Varsayilan: false),
            new("hasta",     "public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)",       "metin", "Hasta", Genislik: 200,
                Bicim: "alt:hastaAlt"),
            new("hastaAlt",
                "concat_ws(' · ', v.yas::text || case v.cinsiyet when 1 then ' E' when 2 then ' K' else '' end, "
                + "nullif('H ' || v.hasta_no, 'H '), nullif('P ' || v.protokol, 'P '))",
                                              "metin", "Hasta Bilgisi", Varsayilan: false, Filtrelenebilir: false),
            new("goz",       GozTarafIfade,   "metin", "Göz", Hizalama: "orta",
                                              Bicim: "rozet", Genislik: 60, Filtrelenebilir: false),
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
                                              "metin", "Durum", Hizalama: "orta", Bicim: "alt:durumAlt",
                                              Genislik: 130, Filtrelenebilir: false),
            new("durumAlt",
                "case when g.durum = 1 and g.serbest = 0 then 'ödeme bekliyor' "
                + "when g.cekim_zamani is not null then concat_ws(' · ', to_char(g.cekim_zamani at time zone 'Europe/Istanbul', 'HH24:MI'), nullif(c.ad, '')) "
                + "else '' end", "metin", "Durum Ayrıntısı", Varsayilan: false, Filtrelenebilir: false),
            new("anaOd", "v.ana_od", "sayi", "Ana ölçüm", Hizalama: "orta", Genislik: 110,
                Bicim: "odos:anaOs:anaBayrak", Filtrelenebilir: false),
            new("anaOs", "v.ana_os", "sayi", "Ana Ölçüm OS", Varsayilan: false, Filtrelenebilir: false),
            // Bit: 1 OD · 2 OS - yalnız eşik dışı ölçümü olan göz kırmızı.
            new("anaBayrak",
                "(case when exists (select 1 from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id and o.goz = 1 and o.bayrak >= 1) then 1 else 0 end"
                + " + case when exists (select 1 from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id and o.goz = 2 and o.bayrak >= 1) then 2 else 0 end)",
                "sayi", "Bayrak", Varsayilan: false),
            new("beklemeDk", "v.bekleme_dk", "sayi", "Bekleme (dk)", Hizalama: "orta", Genislik: 90),
            new("uyari", "coalesce(v.uyari, '')", "metin", "Uyarı", Genislik: 180, Filtrelenebilir: false, Bicim: "uyari"),
            new("serbest", "g.serbest", "mantik", "Ödendi", Varsayilan: false),
            new("bugun", "case when (g.istem_zamani at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date then 1 else 0 end",
                                              "mantik", "Bugün", Varsayilan: false),
            new("buHafta", "case when g.istem_zamani >= date_trunc('week', now()) then 1 else 0 end", "mantik", "Bu Hafta", Varsayilan: false),
            new("kaliteDusuk", "case when g.kalite is not null and g.kalite < 6 then 1 else 0 end", "mantik", "Kalite Düşük", Varsayilan: false),
            new("esikDisi", "case when coalesce(v.bayrak, 0) >= 1 then 1 else 0 end", "mantik", "Eşik Dışı", Varsayilan: false),
            new("yzDikkat", "coalesce(v.yz_dikkat, 0)", "mantik", "YZ Dikkat", Varsayilan: false),
            // MOCKUP ② ŞERİDİ: dilate · glokom takibi · retina / anti-VEGF.
            //   Takip bayrakları HASTANIN AÇIK TAKİP KAYDINDAN okunur, tetkik
            //   türünden çıkarılmaz: OCT maküla hem retina hem üveit izleminde
            //   çekiliyor, tetkike bakan bir kural yanlış hastayı listeler.
            //   (hastalık 1 glokom · 2 diyabetik retinopati · 3 AMD -
            //   anti-VEGF alan iki grup bunlar.)
            new("dilate", "coalesce(g.dilate, 0)", "mantik", "Dilate", Varsayilan: false),
            new("glokomTakip",
                "case when exists (select 1 from public.goz_hastalik_takip k "
                + "where k.hasta_id = g.hasta_id and k.hastalik = 1 and k.durum = 1) then 1 else 0 end",
                "mantik", "Glokom Takibi", Varsayilan: false),
            new("retinaTakip",
                "case when exists (select 1 from public.goz_hastalik_takip k "
                + "where k.hasta_id = g.hasta_id and k.hastalik in (2, 3) and k.durum = 1) then 1 else 0 end",
                "mantik", "Retina / anti-VEGF", Varsayilan: false),
            new("cihazId", "g.cihaz_id", "sayi", "Cihaz Id", Varsayilan: false),
            new("muayeneId", "g.muayene_id", "sayi", "Muayene Id", Varsayilan: false),
            new("degerlendirenId", "g.degerlendiren_id", "sayi", "Değerlendiren Id", Varsayilan: false),
            new("durum",     "g.durum",       "kod",  "Durum Kodu", Varsayilan: false),
            new("degerlendiren", "coalesce(public.fn_taraf_ad(d.unvan, d.ad, d.soyad)::varchar(120), '')", "metin", "Değerlendiren", Genislik: 170),
            // KALİTE listede: düşük sinyalli OCT'nin ölçümü trende girerse
            //   "incelme" sanılan şey aslında kötü çekimdir.
            // KALİTE altında "güven düşük" (mockup): görme alanında yanlış pozitif oranı
            //   yüksek çekimin ölçümü trende girerse "kötüleşme" sanılır.
            new("kalite",    "g.kalite",      "sayi", "Kalite", Hizalama: "orta", Genislik: 80,
                                              Bicim: "alt:kaliteAlt"),
            new("kaliteAlt", "case when g.kalite is not null and g.kalite < 6 then 'güven düşük' else '' end",
                                              "metin", "Kalite Notu", Varsayilan: false, Filtrelenebilir: false),
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
            new("hasta",     "public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)",       "metin", "Hasta", Genislik: 220),
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
            new("hekim",     "coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')", "metin", "Hekim", Genislik: 180),
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
              + "left join public.taraf o on o.id = r.optik_taraf_id "
              // 973: H / P no, SGK 2 yıl, anizometropi, dilate, uyarı (liste + gösterge aynı tanım).
              + "left join public.v_goz_gozluk_ozet v on v.recete_id = r.id",
        SubeKolonu: "r.sube_id",
        VarsayilanSirala: "r.ekleme_tarihi desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "r.id",          "sayi", "Id", Varsayilan: false),
            new("hastaId",   "r.hasta_id",    "sayi", "Hasta Id", Varsayilan: false),
            new("receteNo",  "coalesce(r.recete_no, '')", "metin", "Reçete No", Varsayilan: false),
            // 973 (mockup goz_gozluk_recete_listesi_v2): tarih altında reçete no, hasta altında yaş / H / P.
            new("tarihMetin", "to_char(r.ekleme_tarihi at time zone 'Europe/Istanbul', 'DD.MM.YYYY HH24:MI')",
                                              "metin", "Tarih", Genislik: 130, Filtrelenebilir: false, Bicim: "alt:receteNo"),
            new("tarih",     "r.ekleme_tarihi", "tarih", "Tarih (gün)", Varsayilan: false, Bicim: "dd.MM.yyyy"),
            new("hasta",     "public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)",       "metin", "Hasta", Genislik: 200,
                Bicim: "alt:hastaAlt"),
            new("hastaAlt",
                "concat_ws(' · ', v.yas::text || case v.cinsiyet when 1 then ' E' when 2 then ' K' else '' end, "
                + "nullif('H ' || v.hasta_no, 'H '), nullif('P ' || v.protokol, 'P '))",
                                              "metin", "Hasta Bilgisi", Varsayilan: false, Filtrelenebilir: false),
            new("addMetin", "coalesce(to_char(coalesce(r.od_add, r.os_add), 'FMS990D00'), '—')", "metin", "Add",
                                              Hizalama: "orta", Genislik: 70, Filtrelenebilir: false),
            new("pdMetin", "replace(concat_ws(' / ', case when r.od_pd is not null or r.os_pd is not null "
                + "then to_char(coalesce(r.od_pd, 0) + coalesce(r.os_pd, 0), 'FM990.0') end, to_char(r.pd_yakin, 'FM990.0')), '.', ',')", "metin", "PD",
                                              Hizalama: "orta", Genislik: 80, Filtrelenebilir: false),
            new("uyari", "coalesce(v.uyari, '')", "metin", "Uyarı", Genislik: 170, Filtrelenebilir: false, Bicim: "uyari"),
            new("bugun", "case when (r.ekleme_tarihi at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date then 1 else 0 end",
                                              "mantik", "Bugün", Varsayilan: false),
            new("buHafta", "case when r.ekleme_tarihi >= date_trunc('week', now()) then 1 else 0 end", "mantik", "Bu Hafta", Varsayilan: false),
            new("bitecek", "coalesce(v.bitecek, 0)", "mantik", "Geçerlilik Bitiyor", Varsayilan: false),
            new("sgkErken", "coalesce(v.sgk_erken, 0)", "mantik", "SGK Erken", Varsayilan: false),
            new("sgkHakDogdu", "coalesce(v.sgk_hak_dogdu, 0)", "mantik", "SGK Hakkı Doğdu", Varsayilan: false),
            new("cocuk", "case when v.yas < 18 then 1 else 0 end", "mantik", "Çocuk", Varsayilan: false),
            new("optikId", "r.optik_taraf_id", "sayi", "Optik Id", Varsayilan: false),
            new("muayeneId", "r.muayene_id", "sayi", "Muayene Id", Varsayilan: false),
            new("hekim",     "coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')", "metin", "Hekim", Genislik: 170),
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
                + "             || ' × ' || coalesce(r.od_aks::text, '') end)",
                                              "metin", "OD", Genislik: 190, Filtrelenebilir: false),
            new("os",
                "trim(coalesce(to_char(r.os_sph, 'FMS990D00'), '') "
                + "|| case when r.os_cyl is null then '' "
                + "        else ' / ' || to_char(r.os_cyl, 'FMS990D00') "
                + "             || ' × ' || coalesce(r.os_aks::text, '') end)",
                                              "metin", "OS", Genislik: 190, Filtrelenebilir: false),
            new("durumAdi",
                "case r.durum when 0 then 'İptal' when 1 then 'Taslak' when 2 then 'İmzalandı' "
                + "when 3 then 'Optikte' when 4 then 'Teslim edildi' else '' end",
                                              "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 130, Filtrelenebilir: false),
            new("durum",     "r.durum",       "kod",  "Durum Kodu", Varsayilan: false),
            new("optik",     "coalesce(public.fn_taraf_ad(o.unvan, o.ad, o.soyad)::varchar(120), '')", "metin", "Optik", Genislik: 180),
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
            new("hasta",     "public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)",       "metin", "Hasta", Genislik: 220),
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
            new("hekim",     "coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')", "metin", "Hekim", Genislik: 170),
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
                "case d.kapsam when 1 then 'Kurum' else coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), 'Kullanıcı') end",
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
        // 978: sayılar ve kalibrasyon durumu v_goz_cihaz_ozet'ten - gösterge
        //   ile liste AYNI tanımı okuyor (ayrı sorgu = ayrı sayı).
        Kaynak: "public.goz_cihaz c "
              + "join public.v_goz_cihaz_ozet v on v.cihaz_id = c.id "
              + "left join public.taraf s on s.id = c.sorumlu_id",
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

            // ---------------------------------------------------- 978 v2 ----
            new("seriNo",    "coalesce(c.seri_no, '')", "metin", "Seri No", Genislik: 120),
            new("oda",       "coalesce(c.oda, '')",     "metin", "Yer / oda", Genislik: 140),
            new("sorumlu",
                "coalesce(public.fn_taraf_ad(s.unvan, s.ad, s.soyad)::varchar(120), '')",
                                              "metin", "Sorumlu", Genislik: 160, Varsayilan: false),
            new("bugunCekim", "v.bugun_cekim", "sayi", "Bugün çekim", Hizalama: "orta", Genislik: 100),
            new("bekleyen",   "v.bekleyen",    "sayi", "Sonuç bekleyen", Hizalama: "orta", Genislik: 110),
            // EŞLENMEYEN kırmızı okunmalı: ölçüm geldi ama hangi hastaya ait
            //   olduğu kurulamadı - o ölçüm hiçbir ekranda görünmüyor.
            new("eslenmeyen", "v.eslenmeyen",  "sayi", "Eşlenmeyen", Hizalama: "orta", Genislik: 100),
            new("hatali",     "v.hatali",      "sayi", "Hatalı mesaj", Hizalama: "orta", Genislik: 100,
                                              Varsayilan: false),
            new("tetkikSay",  "v.tetkik_say",  "sayi", "Tetkik eşlemesi", Hizalama: "orta",
                                              Genislik: 110, Varsayilan: false),
            // KALİBRASYON DEMİRBAŞTAN (kullanıcı kararı 05.10.2026): cihaz
            //   demirbaşa bağlı değilse boş gelir - "kalibrasyonu yok" değil
            //   "takip edilmiyor" demektir.
            new("kalibrasyonGecerlilik", "v.kalibrasyon_gecerlilik", "tarih",
                                              "Kalibrasyon geçerlilik", Hizalama: "orta",
                                              Genislik: 130, Bicim: "dd.MM.yyyy"),
            new("kalibrasyonGecikmis", "v.kalibrasyon_gecikmis", "mantik",
                                              "Kalibrasyon Gecikmiş", Varsayilan: false),
            new("demirbasKod", "coalesce(v.demirbas_kod, '')", "metin", "Demirbaş No",
                                              Genislik: 110, Varsayilan: false),
            // "Demirbaş kartı" aksiyonu satırdaki id'ye gidiyor; bağ yoksa
            //   aksiyon "takip edilmiyor" diyerek durur.
            new("demirbasId", "c.demirbas_id", "sayi", "Demirbaş Id", Varsayilan: false),
            new("sonSinama", "c.son_sinama", "tarih", "Son sınama", Hizalama: "orta",
                                              Genislik: 120, Varsayilan: false, Bicim: "dd.MM.yyyy HH:mm"),
            new("sonSinamaSonuc", "coalesce(c.son_sinama_sonuc, '')", "metin", "Sınama sonucu",
                                              Genislik: 220, Varsayilan: false, Filtrelenebilir: false),
            // DURUM tek kolonda: pasif · dinliyor · bağlantı yok · uyarı.
            //   Üç ayrı mantık kolonunu gridde okumak, bir rozeti okumaktan zor.
            new("durumAdi",
                "case when c.aktif = 0 then 'Pasif' "
                + "when c.dinleyici_durum = 2 then 'Bağlantı yok' "
                + "when c.dinleyici_durum = 1 then 'Dinliyor' "
                + "when v.kalibrasyon_gecikmis = 1 or v.eslenmeyen > 0 then 'Uyarı' "
                + "else 'Çalışıyor' end",
                                              "metin", "Durum", Hizalama: "orta", Bicim: "rozet",
                                              Genislik: 120, Filtrelenebilir: false),
            new("dinleyiciDurum", "c.dinleyici_durum", "kod", "Dinleyici Kodu", Varsayilan: false),
            new("eslenmeyenVar", "case when v.eslenmeyen > 0 then 1 else 0 end", "mantik",
                                              "Eşlenmeyen Var", Varsayilan: false),
        });
}
