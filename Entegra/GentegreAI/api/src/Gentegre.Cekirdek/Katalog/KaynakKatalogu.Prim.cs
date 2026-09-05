namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PRİM / HAKEDİŞ listeleri (324).
///
/// Prim TAHSİL EDİLDİKÇE doğar: hakediş satırı bir tahsilat dağıtımından
/// (321) üretilir, tarihi tahsilatın işlem tarihidir ve tabanı KDV hariç
/// matrahtır (323). Listeler bu üç kararı görünür kılar - "neden bu tutar"
/// sorusu taban + oran + rol ile satırda cevaplanır.
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>
    /// PRİM ROLÜ ADAYLARI (383) - "Prim Alanlar" sekmesindeki arama kaynağı.
    ///
    /// Plana eklenecek kişi, PLANIN ROLÜNDE aday olmalı: rolü işaretlenmemiş
    /// birine yazılan satır `belge_satir_rol`'de hiç görünmez, hakediş hiç
    /// doğmaz ve eksik prim ancak ay sonunda fark edilir. Arama bu yüzden
    /// doğrudan aday listesini tarar - kullanıcı uygun olmayanı görmez bile.
    ///
    /// `v_prim_rol_aday` iki kaynağı birleştirir: prim rolü işaretli İÇ
    /// personel ve çalışma şekli "Primli" olan DIŞ hekimler (onların tek rolü
    /// Gönderen'dir - "dış hekim yalnız Gönderen planına" kuralı bu listeden
    /// kendiliğinden çıkar, ayrı bir istisna yazmaya gerek yok).
    /// </summary>
    private static KaynakTanimi PrimAday() => new(
        Ad: "prim-aday",
        YetkiKodu: "prim",
        Kaynak: "public.v_prim_rol_aday a join public.taraf t on t.id = a.id",
        SabitKosul: "coalesce(a.durum, 1) = 1",
        VarsayilanSirala: "t.unvan asc",
        SubeKolonu: null,
        Kolonlar: new KolonTanimi[]
        {
            new("id",    "a.id",  "sayi",  "Id", Varsayilan: false),
            // KOD arama icin gerekli: jenerik arama serbest metni "kod icerir"
            //   kosuluyla da ariyor - kolon yoksa "Bilinmeyen alan: kod".
            new("kod",   "t.kod", "metin", "Kod", Genislik: 110),
            new("unvan", "t.unvan", "metin", "Ad Soyad", Genislik: 260),
            // ROL: arama BU KOLONLA suzuluyor (ekFiltre) - planin rolu.
            new("rol",   "a.rol", "sayi",  "Rol Kodu", Varsayilan: false),
            new("tip",
                "case when coalesce(a.dis_mi, 0) = 1 then 'Dış Hekim' else 'Personel' end",
                                 "metin", "Tipi", Hizalama: "orta", Genislik: 110),
            new("departmanAdi", TarafKatalog.DepartmanAdi, "metin", "Bölüm", Genislik: 160),
            new("gorev", TarafKatalog.PozisyonAdi, "metin", "Görev", Genislik: 160),
            new("telefonHam", TarafKatalog.TelefonHam, "metin", "Telefon (ham)",
                Varsayilan: false),
            new("cepTel", "t.cep_tel", "metin", "Cep", Genislik: 130),
        });

    /// <summary>Prim planları - kapsam ve baz; satırlar kartın detayında.</summary>
    private static KaynakTanimi PrimPlani() => new(
        Ad: "prim-plani",
        YetkiKodu: "prim",
        Kaynak: "public.prim_plani p " +
                "left join public.taraf ku on ku.id = p.odeyen_kurum_id",
        // Planin subesi BOS birakilabilir = "tüm şubeler" (kurum geneli prim
        //   politikasi). Duz esitlik boyle planlari listeden dusuruyordu.
        SubeKosulu: "(p.sube_id is null or p.sube_id = {sube})",
        VarsayilanSirala: "p.durum desc, p.oncelik desc, p.ad",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "p.id",        "sayi",  "Id", Varsayilan: false),

            // KOLON SIRASI = KART SIRASI (kullanici): once planin KIMLIGI
            //   (Kod · Plan Adı · Prim Rolü · Prim Zamanı · Durum), sonra
            //   KAPSAM (Ödeyen Tipi · Şube · Başlangıç · Bitiş). Ayni bilgiyi
            //   iki ekranda farkli sirada okumak, kullaniciyi her gecis
            //   sonrasi yeniden yer aramaya zorluyordu.
            new("kod",       "p.kod",       "metin", "Kod", Genislik: 120),
            new("ad",        "p.ad",        "metin", "Plan Adı", Genislik: 260),
            // ROL (379): plan TEK rol icin calisir.
            new("rolAdi",
                "coalesce((select kd.ad from public.kod_liste kl"
                + " join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = p.rol"
                + " where kl.kod = 'prim.rol'), '')",
                                           "metin", "Prim Rolü", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 120,
                                           Filtrelenebilir: false),
            new("rol",       "p.rol",       "sayi",  "Rol Kodu", Varsayilan: false),
            // ILK KAPI (333): planin nasil okunacagini belirler.
            new("primZamaniAdi",
                "case p.prim_zamani when 2 then 'Faturalamada' else 'Tahsilatta' end",
                                           "metin", "Prim Zamanı", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 130,
                                           Filtrelenebilir: false),
            new("primZamani", "p.prim_zamani", "sayi", "Zaman Kodu", Varsayilan: false),
            new("durumAdi",
                "case when coalesce(p.durum, 1) = 1 then 'Aktif' else 'Pasif' end",
                                           "metin", "Durum", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 90,
                                           Filtrelenebilir: false),
            new("durum",     "p.durum",     "sayi",  "Durum Kodu", Varsayilan: false),

            // --------------------------------------------------- kapsam ----
            // Kartta artik TIP soruluyor (380); kurum adi kolonu duruyor ama
            //   varsayilan degil.
            new("odeyenTipiAdi",
                "case coalesce(p.odeyen_tipi, 0) when 1 then 'Özel (Ücretli)' "
                + "when 2 then 'ÖSS' when 3 then 'SGK' else 'Tümü' end",
                                           "metin", "Ödeyen Tipi", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 130,
                                           Filtrelenebilir: false),
            new("odeyenTipi", "p.odeyen_tipi", "sayi", "Ödeyen Tipi Kodu",
                                           Varsayilan: false),
            new("kurum",     "coalesce(ku.unvan, '')", "metin", "Ödeyen Kurum",
                                           Genislik: 190, Varsayilan: false),
            new("baslangic", "p.baslangic", "tarih", "Başlangıç", Genislik: 110),
            new("bitis",     "p.bitis",     "tarih", "Bitiş", Genislik: 110),

            // ------------------------------------------------ ozet / sayac --
            // KIM KAPSANIYOR (375): isimler kartin "Prim Alanlar" sekmesinde,
            //   listede sayisi yeter.
            new("kapsananlar",
                "case when exists (select 1 from public.prim_plani_taraf t"
                + " where t.plan_id = p.id)"
                + " then (select count(*)::text || ' kişi' from public.prim_plani_taraf t"
                + " where t.plan_id = p.id) else 'Tümü' end",
                                           "metin", "Kapsanan", Hizalama: "orta",
                                           Genislik: 110, Filtrelenebilir: false),
            new("satirSayisi",
                "(select count(*) from public.prim_plani_satir s where s.plan_id = p.id)",
                                           "sayi",  "Satır", Hizalama: "sag", Genislik: 70,
                                           Filtrelenebilir: false),

            // ------------------------------- kartta sorulmayan (gizli) -----
            //   Hepsi kolon menusunden acilabilir; veri kaybolmuyor.
            new("bazAdi",
                "case p.baz when 1 then 'Liste fiyatı' when 2 then 'Net tutar' " +
                "when 3 then 'Kurum payı' else 'Tahsil edilen (matrah)' end",
                                           "metin", "Baz", Genislik: 180,
                                           Filtrelenebilir: false, Varsayilan: false),
            new("baz",       "p.baz",       "kod",   "Baz Kodu", Varsayilan: false),
            new("kdvAdi",
                "case when coalesce(p.kdv_haric, 1) = 1 then 'Hariç' else 'Dahil' end",
                                           "metin", "KDV", Hizalama: "orta",
                                           Genislik: 80, Filtrelenebilir: false,
                                           Varsayilan: false),
            new("kdvHaric",  "p.kdv_haric", "sayi",  "KDV Kodu", Varsayilan: false),
            new("oncelik",   "p.oncelik",   "sayi",  "Öncelik", Hizalama: "sag",
                                            Genislik: 80, Varsayilan: false),
            new("aciklama",  "p.aciklama",  "metin", "Açıklama", Varsayilan: false),
        });

    /// <summary>
    /// Hakediş SATIRLARI - "hangi tahsilattan, hangi kaleme, hangi rolle".
    /// Dönem kapanmamış satırlar başlıksızdır (açık hakediş).
    /// </summary>
    private static KaynakTanimi HakedisSatir() => new(
        Ad: "hakedis-satir",
        YetkiKodu: "prim",
        // Belge turu ve tahsilat turu adlari GORUNUMDEN gelir (330).
        Kaynak: "public.v_hakedis_satir v",
        SubeKolonu: "v.sube_id",
        VarsayilanSirala: "v.tarih desc, v.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "v.id",        "sayi",  "Id", Varsayilan: false),
            new("tarih",     "v.tarih",     "tarih", "Tarih", Genislik: 110),
            new("kisi",      "v.kisi",      "metin", "Kişi", Genislik: 200),
            new("tarafId",   "v.taraf_id",  "sayi",  "Kişi Id", Varsayilan: false),
            new("rolAdi",    "v.rol_adi",   "metin", "Prim Rolü", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 120,
                                           Filtrelenebilir: false),
            new("rol",       "v.rol",       "kod",   "Rol Kodu", Varsayilan: false),
            // ROL ISARETI KONTROLU (363): kisi BUGUN bu rolde isaretli mi
            //   (361/362 - personelde "Prim Rolleri" gridi, dis hekimde
            //   Calisma Sekli "Gönderen"). Satir TARIHSEL kayittir; isaret
            //   sonradan kalkinca silinmez, burada gorunur - kullanici ya
            //   isareti geri koyar ya satiri iptal eder.
            new("isaretAdi", "v.isaret_adi", "metin", "Rol İşareti", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 120,
                                           Filtrelenebilir: false),
            new("rolIsaretli", "v.rol_isaretli", "kod", "İşaretli", Varsayilan: false),
            new("hasta",     "v.hasta",     "metin", "Hasta / Cari", Genislik: 190),
            new("kalem",     "v.kalem",     "metin", "Kalem", Genislik: 240),
            new("payAdi",    "v.pay_adi",   "metin", "Pay", Hizalama: "orta", Genislik: 100,
                                           Filtrelenebilir: false),
            new("pay",       "v.pay",       "sayi",  "Pay Kodu", Varsayilan: false),
            new("belgeTurAdi", "v.belge_tur_adi", "metin", "Belge Türü",
                                           Genislik: 130, Filtrelenebilir: false),
            // Tahsilatin turu (330): oran nakitte ve POS'ta farkli olabilir,
            //   "neden bu tutar" sorusunun bir parcasi.
            // Prim NEREDEN dogdu (332): tahsilattan mi, faturalamadan mi.
            new("kaynakAdi", "v.kaynak_adi", "metin", "Kaynak", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("kaynakTur", "v.kaynak_tur", "sayi", "Kaynak Kodu", Varsayilan: false),
            new("tahsilatTuruAdi", "v.tahsilat_turu_adi", "metin", "Tahsilat",
                                           Genislik: 150, Filtrelenebilir: false),
            new("tahsilatTuru", "v.tahsilat_turu", "sayi", "Tahsilat Kodu",
                                           Varsayilan: false),
            new("belgeTur",  "v.belge_tur", "sayi",  "Tür Kodu", Hizalama: "orta",
                                           Genislik: 90, Varsayilan: false),
            // Taban KDV HARIC matrah (323) - "neden bu tutar" sorusunun ilk yarisi.
            new("taban",     "v.taban",     "para",  "Taban (matrah)", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 130),
            new("deger",     "v.deger",     "para",  "Oran / Tutar", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 110),
            new("payYuzde",  "v.pay_yuzde", "para",  "Kişi Payı %", Hizalama: "sag",
                                           Varsayilan: false),
            new("tutar",     "v.tutar",     "para",  "Prim", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 110),
            // Durum (330): 1 taslak · 2 kesin · 3 onaylı (kilitli) · 4 ödendi.
            new("durumAdi",  "v.durum_adi", "metin", "Durum", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("durum",     "v.durum",     "sayi",  "Durum Kodu", Varsayilan: false),
            new("hakedisId", "v.hakedis_id","sayi",  "Hakediş", Varsayilan: false),
            new("belgeSatirId", "v.belge_satir_id", "sayi", "Kalem Id", Varsayilan: false),
            new("belgeId",   "v.belge_id",  "sayi",  "Belge Id", Varsayilan: false),
        });

    /// <summary>Hakediş başlıkları - kapatılmış dönemler.</summary>
    /// <summary>
    /// PRIM ROLU COMBOSU (391) - hakedis satirlari seridindeki suzgec.
    ///
    /// Roller sabit dokuz deger; tek dogruluk kaynagi `v_prim_rol_lookup`
    /// (rol adinin yaninda o rolde ISARETLI kisi sayisi da gelir). Istemciye
    /// kopyalanirsa iki liste zamanla birbirinden kayar.
    /// </summary>
    private static KaynakTanimi PrimRol() => new(
        Ad: "prim-rol",
        YetkiKodu: "prim",
        Kaynak: "public.v_prim_rol_lookup l",
        SubeKolonu: null,
        VarsayilanSirala: "l.sira",
        Kolonlar: new KolonTanimi[]
        {
            new("id",    "l.id",    "sayi",  "Id"),
            new("ad",    "l.ad",    "metin", "Prim Rolü"),
            new("aktif", "l.aktif", "mantik","Aktif", Varsayilan: false),
            new("sira",  "l.sira",  "sayi",  "Sıra",  Varsayilan: false),
        });

    private static KaynakTanimi Hakedis() => new(
        Ad: "hakedis",
        YetkiKodu: "prim",
        Kaynak: "public.hakedis h left join public.taraf t on t.id = h.taraf_id",
        SubeKolonu: "h.sube_id",
        VarsayilanSirala: "h.donem_bitis desc, h.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "h.id",        "sayi",  "Id", Varsayilan: false),
            new("kisi",      "coalesce(t.unvan, '')", "metin", "Kişi", Genislik: 220),
            new("tarafId",   "h.taraf_id",  "sayi",  "Kişi Id", Varsayilan: false),
            new("donemBaslangic", "h.donem_baslangic", "tarih", "Dönem Başı", Genislik: 120),
            new("donemBitis",     "h.donem_bitis",     "tarih", "Dönem Sonu", Genislik: 120),
            new("satirSayisi",
                "(select count(*) from public.hakedis_satir s where s.hakedis_id = h.id)",
                                           "sayi",  "Satır", Hizalama: "sag", Genislik: 70,
                                           Filtrelenebilir: false),
            new("toplam",    "h.toplam",    "para",  "Toplam", Hizalama: "sag",
                                           Bicim: "#,##0.00", Genislik: 130),
            new("durumAdi",
                "case h.durum when 3 then 'Ödendi' when 2 then 'Kesinleşti' " +
                "when 0 then 'İptal' else 'Taslak' end",
                                           "metin", "Durum", Hizalama: "orta",
                                           Bicim: "rozet", Genislik: 110,
                                           Filtrelenebilir: false),
            new("durum",     "h.durum",     "sayi",  "Durum Kodu", Varsayilan: false),
            new("kasaIslemId", "h.kasa_islem_id", "sayi", "Ödeme İşlemi", Varsayilan: false),
            new("aciklama",  "h.aciklama",  "metin", "Açıklama", Varsayilan: false),
            new("eklemeTarihi", "h.ekleme_tarihi", "tarih", "Oluşturma", Varsayilan: false),
        });
}
