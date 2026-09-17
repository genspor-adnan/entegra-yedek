namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DOKÜMAN LİSTELERİ — doküman, kategori, klasör, onay kuyruğu.
///
/// KaynakKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1183 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// DOKÜMAN LİSTESİ (419) — kaynak üstü görünüm.
    ///
    /// Kart galerileri aynı tabloyu görmeye devam eder; burası klasör/tür/
    /// sürüm/durum ile KURUM GENELİNDE bakılan liste. Ayrı bir "kurumsal
    /// doküman" tablosu açmak, aynı dosyanın iki kopyasını ve iki farklı izin
    /// modelini doğururdu.
    /// </summary>
    private static KaynakTanimi Dokuman() => new(
        Ad: "dokuman",
        YetkiKodu: "dokuman",
        Kaynak: "public.dokuman d "
              + "  left join public.dokuman_kategori t on t.id = d.kategori_id "
              + "  left join public.dokuman_klasor k on k.id = d.klasor_id "
              + "  left join public.v_kullanici_lookup u on u.id = d.sahip_id",
        SubeKolonu: "d.sube_id",
        SabitKosul: "d.durum <> 0",
        VarsayilanSirala: "d.ekleme_tarihi desc, d.id desc",
        Kolonlar: new KolonTanimi[]
        {
            // KOLON SIRASI MOCKUPTAN (Ekranlar/Dokuman/dokuman_listesi.html):
            //   tip · Ad · Kategori · Kaynak · Sürüm · Boyut · Etiket ·
            //   Gizlilik · Geçerlilik · Sahip · Değişti · Paylaşım · Durum.
            new("id",        "d.id",        "sayi",  "Id", Varsayilan: false),
            // DOSYA TIPI IKONU: "bu pdf mi word mü" sorusu dosya adının
            //   uzantısı kesikse cevapsız kalıyordu; kural sunucuda
            //   (fn_dokuman_tipi), istemci yalnız ikonu seçer.
            new("dosyaTipi", "public.fn_dokuman_tipi(d.ad, d.content_type)",
                                            "metin", "Tip", Hizalama: "orta",
                                            Bicim: "ikon", Genislik: 55,
                                            Filtrelenebilir: false),
            new("ad",        "d.ad",        "metin", "Ad", Genislik: 300),
            new("kategoriAdi", "coalesce(nullif(t.yol, ''), t.ad, d.belge_turu)",
                                            "metin", "Kategori", Genislik: 170),
            // KAYNAK TEK KOLON (mockup): kurumsal dokümanda klasör yolu,
            //   karta bağlı dokümanda "cari · 1234". İki ayrı kolon, satırın
            //   yarısında biri boş demekti.
            new("kaynakYolu",
                "case when d.klasor_id is not null then coalesce(k.yol, '') "
                + "else d.kaynak || case when d.kaynak_id > 0 "
                + "then ' · ' || d.kaynak_id::text else '' end end",
                                            "metin", "Kaynak", Genislik: 200,
                                            Filtrelenebilir: false),
            new("surumNo",   "d.surum_no",  "sayi",  "Sürüm", Hizalama: "orta",
                                            Genislik: 70),
            // TAM SAYI BOLME 300 baytlik dosyayi "0 KB" gosteriyordu; en az
            //   1 KB yazilir - dosya var ama boyutu yok gibi gorunmesin.
            new("boyutKb",   "greatest(1, round(d.boyut / 1024.0))", "sayi", "Boyut (KB)",
                                            Hizalama: "sag", Genislik: 100),
            new("etiketler", "array_to_string(d.etiketler, ', ')", "metin", "Etiket",
                                            Genislik: 150),
            new("gizlilikAdi",
                "case d.gizlilik when 1 then 'Herkese Açık' when 3 then 'Gizli' "
                + "when 4 then 'Özel Nitelikli' else 'Kurum İçi' end",
                                            "metin", "Gizlilik", Hizalama: "orta",
                                            Bicim: "rozet", Genislik: 130,
                                            Filtrelenebilir: false),
            new("gecerliBit","d.gecerli_bit","tarih", "Geçerlilik", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy", Genislik: 110),
            new("sahipAdi",  "coalesce(u.ad, '')", "metin", "Sahip", Genislik: 150),
            new("degistirmeTarihi",
                "coalesce(d.degistirme_tarihi, d.ekleme_tarihi)", "tarih", "Değişti",
                                            Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            // PAYLASIM: acik (iptal edilmemis, suresi dolmamis) link sayisi.
            //   "Bu dokuman disariya acik mi" sorusu listede cevaplanmali.
            new("paylasimSayisi",
                // `iptal` bayrak DEGIL, IPTAL ZAMANI (timestamp): "= 0"
                //   yazmak "timestamp = integer" ile listeyi 500 dusuruyordu.
                "(select count(*) from public.dokuman_paylasim p "
                + "where p.dokuman_id = d.id and p.iptal is null "
                + "and (p.son_kullanma is null or p.son_kullanma > now()))",
                                            "sayi",  "Paylaşım", Hizalama: "orta",
                                            Genislik: 90),
            new("durumAdi",
                "case d.durum when 1 then 'Taslak' when 2 then 'Onayda' "
                + "when 3 then 'Yayında' when 4 then 'Arşiv' "
                + "when 5 then 'İmha Edildi' else 'Silindi' end",
                                            "metin", "Durum", Hizalama: "orta",
                                            Bicim: "rozet", Genislik: 110,
                                            Filtrelenebilir: false),

            // --------------------------------------------- gizli / teknik ---
            new("kod",       "d.kod",       "metin", "Kod", Hizalama: "orta",
                                            Genislik: 110, Varsayilan: false),
            new("kategoriId", "coalesce(d.kategori_id, 0)", "sayi", "Kategori Id",
                                            Varsayilan: false),
            // SOL PANEL FILTRESI bu alandan gecer (419): kurumsal klasor
            //   `klasorId` ile, kaynak klasoru `kaynak` ile suzulur - ikisi
            //   ayri alan cunku kaynak klasoru SANALDIR.
            new("klasorId",  "coalesce(d.klasor_id, 0)", "sayi", "Klasör Id",
                                            Varsayilan: false),
            new("klasorYolu","coalesce(k.yol, '')", "metin", "Klasör", Genislik: 180,
                                            Varsayilan: false),
            new("kaynak",    "d.kaynak",    "metin", "Kaynak Kodu", Varsayilan: false),
            new("kaynakId",  "d.kaynak_id", "sayi",  "Kaynak Id", Varsayilan: false),
            new("durum",     "d.durum",     "kod",   "Durum Kodu", Varsayilan: false),
            new("gizlilik",  "d.gizlilik",  "kod",   "Gizlilik Kodu", Varsayilan: false),
            // Icerik tipi listede gorunmez ama AKSIYON okur: onizlenebilir
            //   tipler yeni sekmede acilir, otekiler indirilir.
            new("contentType", "d.content_type", "metin", "Dosya Türü", Genislik: 140,
                                            Varsayilan: false),
            new("eklemeTarihi", "d.ekleme_tarihi", "tarih", "Yükleme", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm", Genislik: 130,
                                            Varsayilan: false),
            new("surumlu",   "d.surumlu",   "mantik","Sürümlü", Hizalama: "orta",
                                            Genislik: 90, Varsayilan: false),
            // Bekleyen onay: "onay kuyrugu" cipinin dayanagi.
            new("onaydaSurum",
                "(select count(*) from public.dokuman_surum s "
                + "where s.dokuman_id = d.id and s.durum = 2)",
                                            "sayi",  "Onayda", Hizalama: "orta",
                                            Genislik: 80, Varsayilan: false)
        });

    /// <summary>
    /// DOKÜMAN KATEGORİLERİ (419/431) — ağaç yapılı; sürümlü mü, hangi onay
    /// akışı, hangi gizlilik sınıfı.
    ///
    /// Stok/hizmet kategorisiyle aynı desen: sınırsız derinlik, kod + ad,
    /// listede YOL gösterimi ("Kalite › Prosedür"). Aynı adlı iki alt kategori
    /// ancak yoluyla ayırt edilir.
    /// </summary>
    private static KaynakTanimi DokumanKategori() => new(
        Ad: "dokuman-kategori",
        YetkiKodu: "dokuman",
        // AKIŞ ADI OMURGADAN (758): `dokuman_akis` artık yazılmıyor,
        //   kategorinin akis_id'si `onay_akis`i gösteriyor.
        Kaynak: "public.dokuman_kategori t "
              + "  left join public.onay_akis a on a.id = t.akis_id "
              + "  left join public.dokuman_kategori ust on ust.id = t.ust_id",
        VarsayilanSirala: "t.yol asc, t.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "t.id",       "sayi",  "Id", Varsayilan: false),
            new("kisaltma", "t.kisaltma", "metin", "Kod", Hizalama: "orta", Genislik: 90),
            new("ad",       "t.ad",       "metin", "Kategori", Genislik: 200),
            new("yol",      "t.yol",      "metin", "Yol", Genislik: 280),
            new("ustAdi",   "coalesce(ust.ad, '')", "metin", "Üst Kategori",
                                          Genislik: 180),
            new("ustId",    "coalesce(t.ust_id, 0)", "sayi", "Üst Id", Varsayilan: false),
            new("surumlu",  "t.surumlu",  "mantik","Sürümlü", Hizalama: "orta", Genislik: 90),
            new("akisAdi",  "coalesce(a.ad, '')", "metin", "Onay Akışı", Genislik: 170),
            new("gizlilikAdi",
                "case t.gizlilik when 1 then 'Herkese Açık' when 3 then 'Gizli' "
                + "when 4 then 'Özel Nitelikli' else 'Kurum İçi' end",
                                          "metin", "Gizlilik", Hizalama: "orta",
                                          Bicim: "rozet", Genislik: 130,
                                          Filtrelenebilir: false),
            new("gizlilik", "t.gizlilik", "kod",   "Gizlilik Kodu", Varsayilan: false),
            new("gozdenGecirmeAy", "t.gozden_gecirme_ay", "sayi", "Gözden Geçirme (ay)",
                                          Hizalama: "orta", Genislik: 150, Varsayilan: false),
            // KULLANIM SAYISI: silinebilir mi sorusunun cevabi listede gorunsun -
            //   kullanicinin silmeyi deneyip hata almasi gerekmesin.
            new("dokumanSayisi",
                "(select count(*) from public.dokuman d "
                + "where d.kategori_id = t.id and d.durum <> 0)",
                                          "sayi",  "Doküman", Hizalama: "orta",
                                          Genislik: 90, Filtrelenebilir: false),
            new("aktif",    "t.aktif",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("sira",     "t.sira",     "sayi",  "Sıra", Hizalama: "orta", Genislik: 70,
                                          Varsayilan: false)
        });

    /// <summary>DOKÜMAN KLASÖRLERİ (419) — kurumsal ağaç (kaynak klasörleri sanal).</summary>
    private static KaynakTanimi DokumanKlasor() => new(
        Ad: "dokuman-klasor",
        YetkiKodu: "dokuman",
        Kaynak: "public.dokuman_klasor k "
              + "  left join public.dokuman_klasor ust on ust.id = k.ust_id "
              + "  left join public.dokuman_kategori t on t.id = k.varsayilan_kategori_id",
        VarsayilanSirala: "k.yol asc, k.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "k.id",       "sayi",  "Id", Varsayilan: false),
            new("ad",       "k.ad",       "metin", "Klasör", Genislik: 220),
            new("yol",      "k.yol",      "metin", "Yol", Genislik: 300),
            new("ustAdi",   "coalesce(ust.ad, '')", "metin", "Üst Klasör", Genislik: 180),
            new("varsayilanKategoriAdi", "coalesce(nullif(t.yol, ''), t.ad, '')", "metin",
                                          "Varsayılan Kategori",
                                          Genislik: 160),
            new("dokumanSayisi",
                "(select count(*) from public.dokuman d "
                + "where d.klasor_id = k.id and d.durum <> 0)",
                                          "sayi",  "Doküman", Hizalama: "orta", Genislik: 90),
            new("aktif",    "k.aktif",    "mantik","Aktif", Hizalama: "orta", Genislik: 80),
            new("sira",     "k.sira",     "sayi",  "Sıra", Hizalama: "orta", Genislik: 70,
                                          Varsayilan: false)
        });

    /// <summary>
    /// ONAY KUYRUĞU (419 · 758'de omurgaya taşındı) — bekleyen onay adımları.
    ///
    /// Satır = ADIM, doküman değil: aynı doküman iki adımda iki farklı kişiyi
    /// bekliyor olabilir ve herkes yalnız kendi adımını görmeli.
    ///
    /// KAYNAK ARTIK OMURGA (`v_onay_bekleyen`, kaynak_tur 976): doküman kendi
    /// `dokuman_onay` tablolarını bıraktı. O görünüm zaten YALNIZ SIRASI GELEN
    /// basamağı döndürür (745) - eski sorgudaki `a.sira = o.guncel_adim`
    /// koşulunun karşılığı orada.
    ///
    /// `surumId` KOLONU ŞART: karar ucu artık sürüm id ile çağrılıyor
    /// (`/api/onay/kayit/976/{surumId}/karar`), eski `onayId` ile değil.
    /// </summary>
    private static KaynakTanimi DokumanOnayKuyrugu() => new(
        Ad: "dokuman-onay",
        YetkiKodu: "dokuman.onayla",
        Kaynak: "public.v_onay_bekleyen v "
              + "  join public.dokuman_surum s on s.id = v.kaynak_id "
              + "  join public.dokuman d on d.id = s.dokuman_id "
              + "  left join public.dokuman_kategori t on t.id = d.kategori_id "
              + "  left join public.v_kullanici_lookup u on u.id = v.atanan_kullanici_id",
        SabitKosul: "v.kaynak_tur = 976",
        SubeKolonu: null,
        VarsayilanSirala: "v.baslama asc, v.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "v.adim_id",   "sayi",  "Id", Varsayilan: false),
            new("onayId",    "v.onay_id",   "sayi",  "Onay Id", Varsayilan: false),
            new("surumId",   "s.id",        "sayi",  "Sürüm Id", Varsayilan: false),
            new("dokumanId", "d.id",        "sayi",  "Doküman Id", Varsayilan: false),
            new("dokumanAd", "d.ad",        "metin", "Doküman", Genislik: 280),
            new("kod",       "d.kod",       "metin", "Kod", Hizalama: "orta", Genislik: 110),
            new("turAdi",    "coalesce(t.ad, '')", "metin", "Tür", Genislik: 150),
            new("surumNo",   "coalesce(s.surum_no, 0)", "sayi", "Sürüm", Hizalama: "orta",
                                            Genislik: 70),
            new("adimAd",    "v.adim_ad",   "metin", "Adım", Hizalama: "orta", Genislik: 120),
            new("atananAdi", "coalesce(u.ad, '')", "metin", "Atanan", Genislik: 160),
            new("baslama",   "v.baslama",   "tarih", "Başlama", Hizalama: "orta",
                                            Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            // BEKLEME GUNU: onay kuyrugunda gecikeni one cikarmanin tek yolu.
            new("beklemeGun",
                "greatest(0, (extract(epoch from now() - v.baslama) / 86400)::int)",
                                            "sayi",  "Bekleme (gün)", Hizalama: "sag",
                                            Genislik: 110),
            // TERMİN / GECİKME omurgadan geliyor - eski kuyrukta yoktu.
            new("gecikmeGun", "v.gecikme_gun", "sayi", "Gecikme (gün)", Hizalama: "sag",
                                            Genislik: 110)
        });
}
