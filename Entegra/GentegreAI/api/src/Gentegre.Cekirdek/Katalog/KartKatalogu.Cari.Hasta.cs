namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HASTA kartı ve ROL kartı.
///
/// KartKatalogu.Cari.cs dosyasindan ayrildi: tek dosyada 1140 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi Hasta()
    {
        var p = Personel();
        var alanlar = p.Alanlar.Select(a => a.Ad switch
        {
            "personel" => new KartAlani("hasta", "hasta", "mantik", Baslik: "Hasta"),
            // 358: numara_sablonu (tur 900) otomatikse bos birakilabilir - DB
            //   trigger'i numarayi verir; elle modda ayni trigger bos birakmayi
            //   reddeder. Kart tarafinda zorunluluk kalkti ki otomatik modda
            //   kullanici gereksiz yere numara uydurmasin.
            "kod" => a with { Baslik = "Dosya No", Zorunlu = false },
            // TCKN DOGRULAMASI (kullanici: "hasta bilgide tckn kontrolü yap"):
            //   hastanin kimlik numarasi MEDULA provizyonuna, e-Nabiz
            //   gonderimine ve e-Belge alici bilgisine gidiyor. Bos
            //   birakilabilir (kimligi belirsiz hasta) ama YAZILDIYSA
            //   tutarli olmali.
            "vkno" => a with { Baslik = "TC No", Grup = "Kimlik", AltGrup = null,
                               EnFazlaUzunluk = 11,
                               Dogrulama = KimlikDogrulama.TcknTuru },
            // Hastada zorunluluklar GEVSEK: gorev/e-posta personel alanlaridir,
            //   hasta kaydi acilirken istenmez (kayit kabul hizli olmali).
            "cepTel" => a with { Baslik = "Telefon", Zorunlu = false },
            "eposta" => a with { Zorunlu = false },
            "gorevId" => a with { Zorunlu = false, Gizli = true },
            "subeId" => a with { Baslik = "Şube" },
            // Hasta durumu dort degerli (266): Aktif / Pasif / Aday / Vefat.
            "durum" => a with { SabitKodlar = HastaDurumKodlari },
            _ => a
        }).Where(a => a.Ad is not ("departman" or "telefon" or "epostaWeb")).ToList();
        var durum = alanlar.FirstOrDefault(a => a.Ad == "durum");
        if (durum is not null)
        {
            alanlar.Remove(durum);
            var vknoIndex = alanlar.FindIndex(a => a.Ad == "vkno");
            alanlar.Insert(vknoIndex >= 0 ? vknoIndex + 1 : alanlar.Count, durum);
        }
        alanlar.AddRange(new[]
        {
            new KartAlani("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new KartAlani("vd", "vd", "metin", EnFazlaUzunluk: 60, Baslik: "Vergi Dairesi", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new KartAlani("efatura", "efatura", "mantik", Baslik: "e-Fatura mukellefi", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            new KartAlani("aliasEposta", "alias_eposta", "metin", EnFazlaUzunluk: 200, Baslik: "Alias / e-Posta", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            // YeniKayitVarsayilanlari'ndaki grup=101 kayda yazılsın; UI'da gizlenir.
            new KartAlani("grup", "grup", "kod", Baslik: "Grup")
        });

        var detaylar = p.Detaylar?.Select(d => d.Ad == "ozluk"
            ? new DetayTanimi("ozluk", "public.taraf_hasta", "id", new KartAlani[]
            {
                new("id",          "id",           "sayi",  Yazilabilir: false),
                // YAS ve CINSIYET ZORUNLU (kullanici): ikisi de sonucun
                //   yorumunu degistirir - referans araligi yasa/cinsiyete gore
                //   secilir, kimi hizmet belli cinsiyete yapilmaz. Bos hasta
                //   kaydi, sonradan yanlis referansla okunan bir sonuc demektir.
                //   KIMLIKSIZ hastada istisna DB tarafinda (acil kaydi durmasin).
                new("dogumTarihi", "dogum_tarihi", "tarih", Zorunlu: true, Baslik: "Dogum Tarihi"),
                new("dogumYeri",   "dogum_yeri",   "metin", EnFazlaUzunluk: 60, Baslik: "Dogum Yeri"),
                new("cinsiyet",    "cinsiyet",     "kod",   Zorunlu: true,
                    KodListesi: "hasta.cinsiyet", Baslik: "Cinsiyet"),
                new("uyruk",       "uyruk",        "kod",   KodTablosu: "public.v_skrs_ulke_lookup",
                    Baslik: "Uyruğu"),
                new("kanGrubu",    "kan_grubu",    "kod",   KodListesi: "taraf.kan_grubu", Baslik: "Kan Grubu"),
                // Meslek listesi elle yazilmis yedi satirdi (Ev Hanimi, Isci,
                //   Memur...); SKRS'nin MESLEKLER listesinde 5461 kayit var.
                //   Liste buyuk oldugu icin acilir kutu degil arama lookup'i.
                new("meslek",      "meslek",       "kod",   KodTablosu: "public.v_skrs_meslek_lookup",
                    Baslik: "Meslek"),
                // Hasta kayit tipi (610): USS 101'in zorunlu alani. Kart
                //   acilisinda VATANDAS_KAYIT gelir, yabanci/kimliksiz
                //   hastada degistirilir.
                new("hastaTipi",   "hasta_tipi",   "kod",   KodListesi: "hasta.tipi",
                    Baslik: "Kayıt Tipi"),
                // Odeyen kurum (266) hastanin kendisinde: cok policeli izleme
                //   ayri sekmede (taraf_hasta_kurum), burada tek alan yeter.
                new("kurumId",     "kurum_id",     "kod",   KodTablosu: "public.v_kurum_lookup",
                    Baslik: "Kurum / Ödeyen"),
                // 335 (Genotıp alan gereksinimleri): SKRS/eNabız icin gereken
                //   kimlik alanlari. Kod listelerinin DEGERI dogrudan SKRS
                //   kodudur - ayri eslestirme tablosu yok (kullanici karari).
                new("pasaportNo",  "pasaport_no",  "metin", EnFazlaUzunluk: 20,
                    Baslik: "Pasaport No"),
                new("medeniHal",   "medeni_hal",   "kod",   KodListesi: "hasta.medeni_hal",
                    Baslik: "Medeni Hal"),
                new("anaAdi",      "ana_adi",      "metin", EnFazlaUzunluk: 60, Baslik: "Ana Adı"),
                new("babaAdi",     "baba_adi",     "metin", EnFazlaUzunluk: 60, Baslik: "Baba Adı"),
                new("anneTckn",    "anne_tckn",    "metin", EnFazlaUzunluk: 11,
                    Baslik: "Anne T.C. No", Dogrulama: KimlikDogrulama.TcknTuru),
                new("babaTckn",    "baba_tckn",    "metin", EnFazlaUzunluk: 11,
                    Baslik: "Baba T.C. No", Dogrulama: KimlikDogrulama.TcknTuru),
                // Kimligi belirsiz hasta: TCKN olmadan kayit acilir.
                new("kimliksiz",   "kimliksiz",    "mantik", Baslik: "Kimliksiz Hasta"),
                new("yabanciHastaTuru", "yabanci_hasta_turu", "kod",
                    KodListesi: "hasta.yabanci_turu", Baslik: "Yabancı Hasta Türü"),
                new("ulkeyeGirisTarihi", "ulkeye_giris_tarihi", "tarih",
                    Baslik: "Ülkeye Giriş Tarihi"),
                new("vefat",       "vefat",        "mantik", Baslik: "Vefat"),
                new("vefatTarihi", "vefat_tarihi", "tarih", Baslik: "Vefat Tarihi"),
                // Dosya acilirken gosterilecek uyari - KLINIK nottan ayri.
                new("mahremiyetNotu", "mahremiyet_notu", "metin", EnFazlaUzunluk: 500,
                    Baslik: "Mahremiyet Notu")
            }, SubeKolonu: null, Baslik: "Hasta Bilgisi", LogTabloId: 907)
            : d)
            // PRIM ROLLERI HASTADA YOK (kullanici): rol "bu kisi hangi isten
            //   prim alir" demektir - isteyen/yapan/uygulayan hep PERSONELDIR.
            //   Sekme yalnizca personel kartindan mirasla geliyordu; hasta
            //   kartinda anlamsiz ve yanlis veri kapisi (hastaya prim rolu
            //   isaretlenirse basvuru hekim combosuna dusebilirdi).
            //   Dis hekimde de yok - orada rol "Çalışma Şekli" ile veriliyor.
            .Where(d => d.Ad != "primRolleri").ToList();

        // KURUM / ÖDEYEN (248, kullanici): hastanin sponsoru - Özel (kendi),
        //   ÖSS (sigorta sirketi) ya da SGK. 1:N: police ZAMANLA DEGISIR, her
        //   basvuruda guncel poliçe girilir, eskisi tarihçe olarak kalir.
        //   "Sonuncusu aktif" kurali DB tetiginde (tg_taraf_hasta_kurum_tek_aktif) -
        //   yeni satir eklenince oncekiler kendiliginden pasife duser.
        // HASTA YAKINI (335): ayri tanim EKLENMEZ - hasta karti personel
        //   kartindan turuyor ve "acilKisiler" detayini ZATEN miras aliyor.
        //   Tablo artik ortak (taraf_acil_kisi), yani hastanin yakini ile
        //   personelin acil kisisi ayni yere yaziliyor.

        detaylar?.Add(new DetayTanimi("kurum", "public.taraf_hasta_kurum", "hasta_id",
        new KartAlani[]
        {
            new("id",         "id",         "sayi",  Yazilabilir: false),
            new("tur",        "tur",        "kod",   Zorunlu: true,
                KodListesi: "taraf.kurum_turu", Baslik: "Kurum Türü"),
            // Anlasmali kurumlar (249) - tum cariler DEGIL: odeyen ancak
            //   sozlesmesi olan bir kurum olabilir.
            new("kurumId",    "kurum_id",   "kod",   KodTablosu: "public.v_kurum_lookup",
                Baslik: "Kurum / Sigorta"),
            new("policeNo",   "police_no",  "metin", EnFazlaUzunluk: 40, Baslik: "Poliçe No"),
            new("gecerlilik", "gecerlilik", "tarih", Baslik: "Geçerlilik"),
            new("kapsam",     "kapsam",     "metin", EnFazlaUzunluk: 200, Baslik: "Kapsam"),
            new("aciklama",   "aciklama",   "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
            // Yazilabilir: eski bir poliçeyi tekrar aktif etmek istenirse tetik
            //   digerlerini pasife ceker. Varsayilan 1 - son giren aktif olur.
            new("aktif",      "aktif",      "mantik", Baslik: "Aktif"),
        }, SubeKolonu: null, Sirala: "aktif desc, id desc",
           Baslik: "Kurum / Ödeyen", LogTabloId: 908));

        return p with
        {
            Ad = "hasta",
            // Ayrı hasta yetkisi seed edilmediği için personel yetkisiyle yönetilir.
            YetkiKodu = "personel",
            LogTabloId = 71,
            SabitKosul = "grup = 101",
            YeniKayitVarsayilanlari = new Dictionary<string, object?>
            {
                ["grup"] = (short)101,
                ["hasta"] = (short)1,
                // Hasta AYNI ZAMANDA MUSTERI: basvuru/fatura cari tarafinda
                //   secilebilsin (HBYS'de hastaya fatura kesilir).
                ["musteri"] = (short)1,
                ["durum"] = (short)1
            },
            Alanlar = alanlar.ToArray(),
            Detaylar = detaylar?.ToArray()
        };
    }

    // ----------------------------------------------------------------- rol ----
    // Kullanici: "eski sistemde rol tablosu ve buna bagli kullanici/personel vardi..
    //   role verdigimiz yetki dogrultusunda menuleri Gorme/Ekleme/Duzeltme/Silme islem
    //   yapabilirdi". Alt mekanizma (rol/yetki/rol_yetki/rol_alan_yetki, backend
    //   dogrulamasi, frontend menu/toolbar gate'i) ZATEN VARDI - eksik olan YONETIM
    //   EKRANIYDI. Bu kart + Yetki Matrisi sekmesi (RolYetkiMatrisi.tsx, ozel bilesen -
    //   generic Detay mekanizmasina UYMAZ, sabit "yetki" satirlari x Gor/Ekle/Degistir/
    //   Sil sutunlu matris; ayri RolYetkiUclari.cs/RolYetkiDeposu.cs).

    // ----------------------------------------------------------------- rol ----
    // Kullanici: "eski sistemde rol tablosu ve buna bagli kullanici/personel vardi..
    //   role verdigimiz yetki dogrultusunda menuleri Gorme/Ekleme/Duzeltme/Silme islem
    //   yapabilirdi". Alt mekanizma (rol/yetki/rol_yetki/rol_alan_yetki, backend
    //   dogrulamasi, frontend menu/toolbar gate'i) ZATEN VARDI - eksik olan YONETIM
    //   EKRANIYDI. Bu kart + Yetki Matrisi sekmesi (RolYetkiMatrisi.tsx, ozel bilesen -
    //   generic Detay mekanizmasina UYMAZ, sabit "yetki" satirlari x Gor/Ekle/Degistir/
    //   Sil sutunlu matris; ayri RolYetkiUclari.cs/RolYetkiDeposu.cs).
    private static KartTanimi Rol() => new(
        Ad: "rol",
        YetkiKodu: "rol",                     // zaten seed'liydi (yetki.id=15, sira 62)
        Tablo: "public.rol",
        LogTabloId: 903,                      // yeni tablo - eski karsiligi yok (bkz. taraf_adres: 901)
        SubeKolonu: null,                     // ana tanim verisi - subeler arasi ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["aktif"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",         "sayi",  Yazilabilir: false),
            // Kod teknik alan: bos birakilirsa ADDAN uretilir, girilirse slug'a
            //   cevrilir (ck_rol_kod dar alfabe istiyor - "Satış Müdürü" patliyordu).
            new("kod",       "kod",        "metin", EnFazlaUzunluk: 40,  Baslik: "Kod", Grup: "Kimlik",
                SlugKaynak: "ad"),
            new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 100, Baslik: "Ad",  Grup: "Kimlik"),
            new("ustRolId",  "ust_rol_id", "kod",   KodTablosu: "public.rol", Baslik: "Üst Rol", Grup: "Kimlik"),
            new("aktif",     "aktif",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Aktif", Grup: "Kimlik"),
            // Sistem rolleri (Yonetici/Salt okuyucu) - kod/ad degistirilemez/silinemez
            //   hale getirmek ayri bir is (SilmeEngeli + Yazilabilir kontrolu); simdilik
            //   sadece salt-okunur GORUNUR, kullanici "sistem" rolu oldugunu bilsin.
            new("sistem",    "sistem",     "mantik", Yazilabilir: false, Baslik: "Sistem Rolü"),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false)
        });

    // --------------------------------------------------------------- stok ----
}
