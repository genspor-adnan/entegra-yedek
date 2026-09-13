namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DOKÜMAN KARTLARI — kategori, klasör, dokümanın kendisi.
///
/// KartKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1448 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>
    /// DOKÜMAN KATEGORİSİ KARTI (431) — ağaç yapılı, stok/hizmet kategorisiyle
    /// aynı desen.
    ///
    /// <para><b>Kullanılan kategori silinemez.</b> Silinseydi dokümanlar
    /// kategorisiz kalır, sürümlü olup olmadıkları ve gizlilik sınıfları
    /// belirsizleşirdi - gizlilik doküman düzeyinde de saklanıyor ama
    /// "neden gizli" cevabı kaybolurdu.</para>
    /// </summary>
    private static KartTanimi DokumanKategoriKarti() => new(
        Ad: "dokuman-kategori",
        YetkiKodu: "dokuman",
        Tablo: "public.dokuman_kategori",
        LogTabloId: 1002,
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1,
            ["gizlilik"] = (short)2,          // Kurum içi
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.dokuman", "kategori_id",
                "Bu kategoride doküman var."),
            new("public.dokuman_kategori", "ust_id",
                "Bu kategorinin altında başka kategori var."),
            new("public.dokuman_klasor", "varsayilan_kategori_id",
                "Bu kategori bir klasörün varsayılanı."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                Baslik: "Kategori", Grup: "Kimlik"),
            new("kisaltma", "kisaltma", "metin", EnFazlaUzunluk: 10,
                Baslik: "Kod", Grup: "Kimlik"),
            // Boş ise KÖK kategori; seçilirse altına geçer (sınırsız derinlik).
            //   Kendi altına taşıma tetikte engellenir (fn_dokuman_kategori_yol).
            new("ustId", "ust_id", "kod", KodTablosu: "public.v_dokuman_kategori_lookup",
                Baslik: "Üst Kategori", Grup: "Kimlik"),
            new("yol", "yol", "metin", Yazilabilir: false,
                Baslik: "Yol", Grup: "Kimlik"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            // Davranış: bu kategorideki dokümanların varsayılanı.
            new("surumlu", "surumlu", "mantik",
                Baslik: "Sürümlü (onaydan geçer)", Grup: "Davranış"),
            new("akisId", "akis_id", "kod", KodTablosu: "public.v_dokuman_akis_lookup",
                Baslik: "Onay Akışı", Grup: "Davranış"),
            new("gizlilik", "gizlilik", "kod", SabitKodlar: DokumanGizlilikKodlari,
                Baslik: "Gizlilik Sınıfı", Grup: "Davranış"),
            new("gozdenGecirmeAy", "gozden_gecirme_ay", "sayi",
                Baslik: "Gözden Geçirme (ay)", Grup: "Davranış"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Davranış"),
        });

    /// <summary>
    /// DOKÜMAN KLASÖRÜ KARTI (431) — kurumsal ağaç.
    ///
    /// KAYNAK KLASÖRLERİ (taraf / stok / hasta) burada YOK: onlar sanaldır,
    /// kaynak + kaynak_id'den türer. Her personel için klasör açmak gerekmesin
    /// diye böyle kuruldu (419).
    /// </summary>
    private static KartTanimi DokumanKlasorKarti() => new(
        Ad: "dokuman-klasor",
        YetkiKodu: "dokuman",
        Tablo: "public.dokuman_klasor",
        LogTabloId: 1003,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1,
            ["varsayilan_gizlilik"] = (short)2,
        },
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.dokuman", "klasor_id", "Bu klasörde doküman var."),
            new("public.dokuman_klasor", "ust_id",
                "Bu klasörün altında başka klasör var."),
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 100,
                Baslik: "Klasör", Grup: "Kimlik"),
            new("ustId", "ust_id", "kod", KodTablosu: "public.v_dokuman_klasor_lookup",
                Baslik: "Üst Klasör", Grup: "Kimlik"),
            new("yol", "yol", "metin", Yazilabilir: false, Baslik: "Yol", Grup: "Kimlik"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kimlik"),

            new("varsayilanKategoriId", "varsayilan_kategori_id", "kod",
                KodTablosu: "public.v_dokuman_kategori_lookup",
                Baslik: "Varsayılan Kategori", Grup: "Varsayılanlar"),
            new("varsayilanGizlilik", "varsayilan_gizlilik", "kod",
                SabitKodlar: DokumanGizlilikKodlari,
                Baslik: "Varsayılan Gizlilik", Grup: "Varsayılanlar"),
            // Doküman kodu bu şablondan üretilir (419): {YIL}, {SIRA} gibi.
            new("kodSablonu", "kod_sablonu", "metin", EnFazlaUzunluk: 40,
                Baslik: "Kod Şablonu", Grup: "Varsayılanlar"),
            new("sira", "sira", "sayi", Baslik: "Sıra", Grup: "Varsayılanlar"),
        });

    private static KartTanimi DokumanKarti() => new(
        Ad: "dokuman",
        YetkiKodu: "dokuman",
        Tablo: "public.dokuman",
        LogTabloId: 975,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // META ALANLARI SEKMELERIN USTUNDE (mockup dokuman_karti.html,
            //   kullanici): kart acilinca ad/kod/tur/klasor/gizlilik hemen
            //   gorunmeli. GenForm "Kimlik" grubunu SERIT olarak cizer,
            //   otekileri sekme yapar - bu yuzden meta alanlari Kimlik'te.
            //   Sekmede duran bir "Ad" alani, dokumani tanimak icin sekme
            //   degistirtirdi.
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Doküman Adı", Grup: "Kimlik"),
            new("kod", "kod", "metin", EnFazlaUzunluk: 30, Baslik: "Kod", Grup: "Kimlik"),
            new("kategoriId", "kategori_id", "kod",
                KodTablosu: "public.v_dokuman_kategori_lookup", Baslik: "Kategori",
                Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: DokumanDurumKodlari, Yazilabilir: false,
                Baslik: "Durum", Grup: "Kimlik"),
            new("klasorId", "klasor_id", "kod", KodTablosu: "public.v_dokuman_klasor_lookup",
                Baslik: "Klasör", Grup: "Kimlik"),
            new("sahipId", "sahip_id", "kod", KodTablosu: "public.v_kullanici_lookup",
                Baslik: "Sahip", Grup: "Kimlik"),
            // GIZLILIK sinifi izinden BAGIMSIZ ust kisittir: ozel nitelikli
            //   dokumanda gerekce zorunlu, erisim gunluge yazilir - bu yuzden
            //   ustte, gozden kacmayacak yerde.
            new("gizlilik", "gizlilik", "kod", SabitKodlar: DokumanGizlilikKodlari,
                Baslik: "Gizlilik Sınıfı", Grup: "Kimlik"),
            new("etiketMetni", "array_to_string(etiketler, ', ')", "metin",
                EnFazlaUzunluk: 300, Baslik: "Etiketler", Grup: "Kimlik",
                Yazilabilir: false),
            new("gecerliBas", "gecerli_bas", "tarih", Baslik: "Geçerlilik Başlangıcı",
                Grup: "Kimlik"),
            new("gecerliBit", "gecerli_bit", "tarih", Baslik: "Geçerlilik Bitişi",
                Grup: "Kimlik"),

            // SAKLAMA / IMHA (mockup ust blok): kural tablosu Faz 2'de
            //   (dokuman_saklama); simdilik GIZLILIK SINIFINDAN turetilen
            //   bilgi metni. Alani hic gostermemek, KVKK acisindan en kritik
            //   sorunun ("bu dosya ne kadar sure saklanacak") kartta hic
            //   sorulmamasi olurdu.
            new("saklamaBilgi",
                "case gizlilik when 4 then 'Özel nitelikli · KVKK süresi (kural Faz 2)' "
                + "when 3 then 'Gizli · kurum saklama politikası' "
                + "when 1 then 'Herkese açık · süre sınırı yok' "
                + "else 'Kurum içi · süresiz (kalite kaydı)' end",
                "metin", Yazilabilir: false, Baslik: "Saklama / İmha", Grup: "Kimlik"),
            new("dil", "dil", "metin", EnFazlaUzunluk: 5, Baslik: "Dil", Grup: "Kimlik"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama",
                Grup: "Kimlik"),

            // ----------------------------------------------------- içerik ----
            // Dosyanin kendisine ait, DEGISTIRILEMEZ bilgiler ayri sekmede:
            //   onlari degistiren sey surum/onay dongusudur, elle yazmak
            //   basligi gercek dosyadan koparirdi.
            new("surumNo", "surum_no", "sayi", Yazilabilir: false, Baslik: "Yayındaki Sürüm",
                Grup: "İçerik"),
            new("onaydakiSurum",
                "coalesce((select s.surum_no from public.dokuman_surum s "
                + "where s.dokuman_id = dokuman.id and s.durum = 2 "
                + "order by s.surum_no desc limit 1), 0)",
                "sayi", Yazilabilir: false, Baslik: "Onaydaki Sürüm", Grup: "İçerik"),
            new("surumlu", "surumlu", "mantik", Baslik: "Sürüm Takibi", Grup: "İçerik"),
            new("contentType", "content_type", "metin", Yazilabilir: false,
                EnFazlaUzunluk: 100, Baslik: "Dosya Türü", Grup: "İçerik"),
            // BOYUT KB (kullanici): bayt cinsinden 318.464 gibi bir sayi
            //   dosyanin buyuklugunu anlatmiyor; KB okunabilir olan.
            new("boyutKb", "((boyut + 1023) / 1024)", "sayi", Yazilabilir: false,
                Baslik: "Boyut (KB)", Grup: "İçerik"),
            new("hash", "hash", "metin", Yazilabilir: false, EnFazlaUzunluk: 64,
                Baslik: "İçerik Hash", Grup: "İçerik"),
            // Birincil bag: dosyanin NEREDEN yuklendigi. Degistirilemez -
            //   degisirse kart galerisi dosyayi kaybeder.
            new("kaynak", "kaynak", "metin", Yazilabilir: false, EnFazlaUzunluk: 20,
                Baslik: "Bağlı Kaynak", Grup: "İçerik"),
            new("kaynakId", "kaynak_id", "sayi", Yazilabilir: false,
                Baslik: "Kaynak Id", Grup: "İçerik"),
            // GOZDEN GECIRME PERIYODU KARTTAN KALDIRILDI (kullanici).
            //   Kolon (dokuman.gozden_gecirme_ay) ve turdeki varsayilan
            //   DURUYOR: periyot belge turunden gelir, dokuman basina elle
            //   girilmesi gerekmiyordu. Kolonu dusurmek, Faz 2'deki gozden
            //   gecirme gorevini kaynaksiz birakirdi.
            new("sonGozdenGecirme", "son_gozden_gecirme", "tarih",
                Baslik: "Son Gözden Geçirme", Grup: "İçerik"),
            new("sonrakiGozdenGecirme", "sonraki_gozden_gecirme", "tarih",
                Baslik: "Sonraki Gözden Geçirme", Grup: "İçerik"),
            new("ozet", "ozet", "metin", EnFazlaUzunluk: 1000, Baslik: "Özet",
                Grup: "İçerik")
        },
        Detaylar: new DetayTanimi[]
        {
            // SURUMLER SALT OKUNUR: surum acmak ve yayinlamak bir DUGMENIN isi
            //   (dokuman-yonetim uclari). Satiri elle "yayinda" yapmak, iki
            //   yayin surumu dogurup "hangisi gecerli"yi cevapsiz birakirdi.
            new("surumler", "public.dokuman_surum", "dokuman_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("surumNo", "surum_no", "sayi", Yazilabilir: false, Baslik: "Sürüm"),
                new("durum", "durum", "kod", SabitKodlar: DokumanSurumDurumKodlari,
                    Yazilabilir: false, Baslik: "Durum"),
                new("degisiklikNotu", "degisiklik_notu", "metin", EnFazlaUzunluk: 400,
                    Baslik: "Değişiklik Notu"),
                new("yukleme", "yukleme", "tarih", Yazilabilir: false, Baslik: "Yükleme"),
                new("yukleyenId", "yukleyen_id", "kod",
                    KodTablosu: "public.v_kullanici_lookup", Yazilabilir: false,
                    Baslik: "Yükleyen"),
                // HASH gorunur: mockupta "icerik v3 ile ayni (dedup)" bilgisi
                //   buradan okunuyor - ayni hash, ayni dosya demek.
                new("hash", "hash", "metin", Yazilabilir: false, EnFazlaUzunluk: 64,
                    Baslik: "İçerik Hash"),
                new("contentType", "content_type", "metin", Yazilabilir: false,
                    EnFazlaUzunluk: 100, Baslik: "Dosya Türü"),
                new("yayinTarihi", "yayin_tarihi", "tarih", Yazilabilir: false,
                    Baslik: "Yayın"),
                new("arsivTarihi", "arsiv_tarihi", "tarih", Yazilabilir: false,
                    Baslik: "Arşiv"),
                new("boyutKb", "((boyut + 1023) / 1024)", "sayi", Yazilabilir: false,
                    Baslik: "Boyut (KB)"),
            }, SubeKolonu: null, Sirala: "surum_no desc",
               Baslik: "Sürümler", SaltOkunur: true, LogTabloId: 976),

            // BAGLANTILAR (423): birincil (dokuman.kaynak) + ek baglar tek
            //   listede. Bir sozlesme hem cari kartinda hem "Sozlesmeler"
            //   klasorunde gorunmeli - ikinci kopya yuklemek ayni dosyayi iki
            //   yerde ayri ayri surumlemek olurdu.
            //   SALT OKUNUR: birincil satir dokumanin kendi kaynagidir,
            //   silinemez; ek bag ekleme/kaldirma ayri uctan yurur.
            new("baglantilar", "public.v_dokuman_baglanti", "dokuman_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("kaynak", "kaynak", "metin", Yazilabilir: false, EnFazlaUzunluk: 20,
                    Baslik: "Kaynak"),
                new("kaynakId", "kaynak_id", "sayi", Yazilabilir: false, Baslik: "Kayıt Id"),
                new("birincil", "birincil", "mantik", Yazilabilir: false, Baslik: "Birincil"),
                new("rol", "rol", "metin", Yazilabilir: false, EnFazlaUzunluk: 60,
                    Baslik: "Rol"),
                new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false,
                    Baslik: "Eklendi"),
            }, SubeKolonu: null, Sirala: "birincil desc, ekleme_tarihi asc",
               Baslik: "Bağlantılar", SaltOkunur: true, LogTabloId: 979),

            // ONAY AKISI (mockup): adimlar, kararlar, notlar. SALT OKUNUR -
            //   karar vermek bir DUGMENIN isi; satiri elle "onaylandi" yapmak
            //   onay zincirini anlamsiz kilardi.
            new("onayAkisi", "public.v_dokuman_onay_adim", "dokuman_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("surumNo", "surum_no", "sayi", Yazilabilir: false, Baslik: "Sürüm"),
                new("sira", "sira", "sayi", Yazilabilir: false, Baslik: "Adım"),
                new("ad", "ad", "metin", Yazilabilir: false, Baslik: "Aşama"),
                new("karar", "karar", "kod", SabitKodlar: OnayKararKodlari,
                    Yazilabilir: false, Baslik: "Karar"),
                new("kararVerenId", "karar_veren_id", "kod",
                    KodTablosu: "public.v_kullanici_lookup", Yazilabilir: false,
                    Baslik: "Karar Veren"),
                new("kararZamani", "karar_zamani", "tarih", Yazilabilir: false,
                    Baslik: "Tarih"),
                new("notMetni", "not_metni", "metin", Yazilabilir: false,
                    EnFazlaUzunluk: 400, Baslik: "Not"),
            }, SubeKolonu: null, Sirala: "surum_no desc, sira asc",
               Baslik: "Onay Akışı", SaltOkunur: true, LogTabloId: 978),

            // ERISIM (425): izin UC KATMANDAN gelir - klasor izni (devralinir),
            //   dokumana ozel istisna ve SAHIP. Kaynak kolonu "bu izin nereden
            //   geliyor" sorusunu cevaplar; tek tabloya sikistirmak o cevabi
            //   yok ederdi.
            //   GIZLILIK SINIFI burada YOK: izinden bagimsiz ust kisittir
            //   (ozel nitelikli dokumanda izin olsa bile gerekce zorunlu) ve
            //   dokumanin kendisinde durur.
            new("erisimler", "public.v_dokuman_erisim", "dokuman_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("rolId", "rol_id", "kod", KodTablosu: "public.v_rol_lookup",
                    Yazilabilir: false, Baslik: "Rol"),
                new("kullaniciId", "kullanici_id", "kod",
                    KodTablosu: "public.v_kullanici_lookup", Yazilabilir: false,
                    Baslik: "Kullanıcı"),
                new("oku", "oku", "mantik", Yazilabilir: false, Baslik: "Oku"),
                new("indir", "indir", "mantik", Yazilabilir: false, Baslik: "İndir"),
                new("duzenle", "duzenle", "mantik", Yazilabilir: false, Baslik: "Düzenle"),
                new("paylas", "paylas", "mantik", Yazilabilir: false, Baslik: "Paylaş"),
                new("sil", "sil", "mantik", Yazilabilir: false, Baslik: "Sil"),
                new("onayla", "onayla", "mantik", Yazilabilir: false, Baslik: "Onayla"),
                new("kaynak", "kaynak", "metin", Yazilabilir: false, EnFazlaUzunluk: 20,
                    Baslik: "Kaynak"),
                new("gecerliBit", "gecerli_bit", "tarih", Yazilabilir: false,
                    Baslik: "Süreli İzin"),
            }, SubeKolonu: null, Sirala: "kaynak asc, id asc",
               Baslik: "Erişim", SaltOkunur: true, LogTabloId: 981),

            // PAYLASIM LINKLERI (424). SALT OKUNUR: link URETMEK kod uretimi
            //   ister (tahmin edilemez 128 bit) ve iptal bir DUGMEDIR -
            //   satiri elle duzenlemek, kodu bilen birine erisimi sessizce
            //   geri vermek olurdu.
            new("paylasimlar", "public.v_dokuman_paylasim", "dokuman_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("kod", "kod", "metin", Yazilabilir: false, EnFazlaUzunluk: 40,
                    Baslik: "Link Kodu"),
                new("olusturanId", "olusturan_id", "kod",
                    KodTablosu: "public.v_kullanici_lookup", Yazilabilir: false,
                    Baslik: "Oluşturan"),
                new("olusturma", "olusturma", "tarih", Yazilabilir: false,
                    Baslik: "Oluşturma"),
                new("sonKullanma", "son_kullanma", "tarih", Yazilabilir: false,
                    Baslik: "Son Kullanma"),
                new("indirmeIzni", "indirme_izni", "mantik", Yazilabilir: false,
                    Baslik: "İndirilebilir"),
                new("acilmaSayisi", "acilma_sayisi", "sayi", Yazilabilir: false,
                    Baslik: "Açılma"),
                new("azamiAcilma", "azami_acilma", "sayi", Yazilabilir: false,
                    Baslik: "Azami Açılma"),
                new("aliciEposta", "alici_eposta", "metin", Yazilabilir: false,
                    EnFazlaUzunluk: 120, Baslik: "Alıcı"),
                new("durum", "durum", "kod", SabitKodlar: PaylasimDurumKodlari,
                    Yazilabilir: false, Baslik: "Durum"),
            }, SubeKolonu: null, Sirala: "olusturma desc",
               Baslik: "Paylaşım", SaltOkunur: true, LogTabloId: 980),

            // GUNLUK SILINMEZ (KVKK erisim kaydi) - bu yuzden salt okunur.
            new("gunluk", "public.dokuman_olay", "dokuman_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("zaman", "zaman", "tarih", Yazilabilir: false, Baslik: "Zaman"),
                new("olay", "olay", "kod", SabitKodlar: DokumanOlayKodlari,
                    Yazilabilir: false, Baslik: "Olay"),
                new("kullaniciId", "kullanici_id", "kod",
                    KodTablosu: "public.v_kullanici_lookup", Yazilabilir: false,
                    Baslik: "Kullanıcı"),
                new("gerekce", "gerekce", "metin", Yazilabilir: false, EnFazlaUzunluk: 200,
                    Baslik: "Gerekçe"),
                new("ip", "ip", "metin", Yazilabilir: false, EnFazlaUzunluk: 45,
                    Baslik: "IP"),
                new("kanal", "kanal", "kod", SabitKodlar: DokumanKanalKodlari,
                    Yazilabilir: false, Baslik: "Kanal"),
            }, SubeKolonu: null, Sirala: "zaman desc, id desc",
               Baslik: "Günlük", SaltOkunur: true, LogTabloId: 977)
        });
}
