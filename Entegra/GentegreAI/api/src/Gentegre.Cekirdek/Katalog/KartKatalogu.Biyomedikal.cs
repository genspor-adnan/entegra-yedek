namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// BİYOMEDİKAL KARTLARI (723) — kalibrasyon kaydı ve iş emri.
///
/// CİHAZ KARTI BURADA DEĞİL: klinik mühendislik künyesi (risk sınıfı, periyot,
/// ÜTS/UDI, sözleşme) mevcut `demirbas` kartına `UrunModu: 2` alanlar olarak
/// eklendi. İkinci envanter kartı, aynı satır için iki düzenleme ekranı ve iki
/// log tablo kodu demek olurdu.
///
/// HAREKET KARTI YOK: `demirbas_hareket` zimmet/lokasyon geçmişidir, uçtan
/// yazılır. Elle düzenlenebilen bir geçmiş, geçmiş sayılmaz.
/// </summary>
public static partial class KartKatalogu
{
    // --------------------------------------------------- kalibrasyon ----
    private static KartTanimi DemirbasKalibrasyon() => new(
        Ad: "demirbasKalibrasyon",
        YetkiKodu: "demirbas.kalibrasyon",
        Tablo: "public.demirbas_kalibrasyon",
        LogTabloId: 1222,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("demirbasId", "demirbas_id", "sayi", Zorunlu: true, Baslik: "Cihaz",
                Grup: "Kayıt"),
            new("kayitNo", "kayit_no", "metin", Baslik: "Kayıt No", Grup: "Kayıt",
                EnFazlaUzunluk: 30),
            // KALİBRASYON ve ELEKTRİKSEL GÜVENLİK aynı tabloda, türle ayrılır:
            //   ikisi de "ölçüm noktası + sınır + sonuç" yapısında ama ayrı
            //   soruları yanıtlar - "doğru ölçüyor mu" / "hastayı çarpar mı".
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "Tür", Grup: "Kayıt",
                SabitKodlar: KaynakKatalogu.DbKalibTurKodlari),
            new("tarih", "tarih", "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Kayıt"),
            new("sonuc", "sonuc", "kod", Baslik: "Sonuç", Grup: "Kayıt",
                SabitKodlar: KaynakKatalogu.DbKalibSonucKodlari),
            // GEÇERLİLİK CİHAZA YAZILIR (723 tetiği): kart kaydedilince
            //   demirbaş künyesi güncellenir, kullanılabilirlik ona bakar.
            new("gecerlilik", "gecerlilik", "tarih", Baslik: "Geçerlilik", Grup: "Kayıt"),
            // AYAR ÖNCESİ/SONRASI AYRI KAYIT: "ne kadar sapmıştı" sorusu ancak
            //   ayar öncesi ölçüm saklanırsa yanıtlanır.
            new("ayarSonrasi", "ayar_sonrasi", "mantik", Baslik: "Ayar sonrası ölçüm",
                Grup: "Kayıt"),
            new("ayarOncesiId", "ayar_oncesi_id", "sayi", Baslik: "Ayar Öncesi Kayıt",
                Grup: "Kayıt"),

            new("yapanId", "yapan_id", "sayi", Baslik: "Yapan", Grup: "Yapan",
                KodTablosu: "public.v_personel_lookup"),
            new("firmaId", "firma_id", "sayi", Baslik: "Firma", Grup: "Yapan",
                KodTablosu: "public.v_cari_lookup"),

            // REFERANS CİHAZIN KENDİ SERTİFİKASI GEÇERLİ OLMALI: geçersiz
            //   referansla yapılan kalibrasyon ölçüm değil, tahmindir.
            new("referansCihaz", "referans_cihaz", "metin", Baslik: "Referans Cihaz",
                Grup: "Referans", EnFazlaUzunluk: 120),
            new("referansSeri", "referans_seri", "metin", Baslik: "Referans Seri",
                Grup: "Referans", EnFazlaUzunluk: 60),
            new("referansSertifika", "referans_sertifika", "metin",
                Baslik: "Referans Sertifika", Grup: "Referans", EnFazlaUzunluk: 60),
            new("referansGecerlilik", "referans_gecerlilik", "tarih",
                Baslik: "Referans Geçerlilik", Grup: "Referans"),
            new("belirsizlik", "belirsizlik", "ondalik", Baslik: "Belirsizlik",
                Grup: "Referans"),
            new("belirsizlikBirim", "belirsizlik_birim", "metin", Baslik: "Birim",
                Grup: "Referans", EnFazlaUzunluk: 20),
            new("ortamSicaklik", "ortam_sicaklik", "ondalik", Baslik: "Ortam Sıcaklık (°C)",
                Grup: "Referans"),
            new("ortamNem", "ortam_nem", "ondalik", Baslik: "Ortam Nem (%)", Grup: "Referans"),

            // GERİYE DÖNÜK DEĞERLENDİRME: cihaz ne zamandır sapıyordu, o
            //   sürede kaç hastada kullanıldı. Uygunsuz sonucun asıl sorusu bu.
            new("geriyeDonukDeger", "geriye_donuk_deger", "metin",
                Baslik: "Geriye Dönük Değerlendirme", Grup: "Referans"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Referans"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("olcumler", "public.demirbas_kalibrasyon_olcum", "kalibrasyon_id",
                new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("nokta", "nokta", "metin", Zorunlu: true, Baslik: "Ölçüm Noktası",
                    EnFazlaUzunluk: 80),
                new("birim", "birim", "metin", Baslik: "Birim", EnFazlaUzunluk: 20),
                new("nominal", "nominal", "ondalik", Baslik: "Nominal"),
                new("olculen", "olculen", "ondalik", Baslik: "Ölçülen"),
                // SAPMA ve SONUÇ TETİKLE HESAPLANIR (723): elle yazılan bir
                //   "uygun" işareti, ölçümü kanıt olmaktan çıkarır.
                new("sapma", "sapma", "ondalik", Yazilabilir: false, Baslik: "Sapma"),
                new("sapmaYuzde", "sapma_yuzde", "ondalik", Yazilabilir: false,
                    Baslik: "Sapma %"),
                new("altSinir", "alt_sinir", "ondalik", Baslik: "Alt Sınır"),
                new("ustSinir", "ust_sinir", "ondalik", Baslik: "Üst Sınır"),
                new("sinirMetin", "sinir_metin", "metin", Baslik: "Sınır (metin)",
                    EnFazlaUzunluk: 60),
                new("sonuc", "sonuc", "kod", Yazilabilir: false, Baslik: "Sonuç",
                    SabitKodlar: DbKartOlcumSonucKodlari),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 200),
            }, Sirala: "sira, id", Baslik: "Ölçümler", SubeKolonu: null, LogTabloId: 1223),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = 1, ["sonuc"] = 0, ["ayar_sonrasi"] = 0,
        });

    // ------------------------------------------------------- iş emri ----
    // BAKIM ve ARIZA TEK TABLODA (tür ayırır): ikisi de "cihazda yapılan
    //   iş"tir - aynı duruş, aynı parça, aynı geçmiş. Ayırsaydık "bu cihaz ne
    //   sıklıkla bozuluyor" sorusu iki tablodan toplanırdı.
    private static KartTanimi DemirbasIsEmri() => new(
        Ad: "demirbasIsEmri",
        YetkiKodu: "demirbas.isemri",
        Tablo: "public.demirbas_is_emri",
        LogTabloId: 1224,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("isEmriNo", "is_emri_no", "metin", Baslik: "İş Emri No", Grup: "İş Emri",
                EnFazlaUzunluk: 30),
            new("demirbasId", "demirbas_id", "sayi", Zorunlu: true, Baslik: "Cihaz",
                Grup: "İş Emri"),
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "Tür", Grup: "İş Emri",
                SabitKodlar: KaynakKatalogu.DbIsEmriTurKodlari),
            new("oncelik", "oncelik", "kod", Baslik: "Öncelik", Grup: "İş Emri",
                SabitKodlar: KaynakKatalogu.DbOncelikKodlari),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "İş Emri",
                SabitKodlar: KaynakKatalogu.DbIsEmriDurumKodlari),
            new("departmanId", "departman_id", "sayi", Baslik: "Bölüm", Grup: "İş Emri",
                KodTablosu: "public.v_departman_lookup"),
            new("ustIsEmriId", "ust_is_emri_id", "sayi", Baslik: "Üst İş Emri",
                Grup: "İş Emri"),

            new("bildirimZamani", "bildirim_zamani", "zaman", Baslik: "Bildirim",
                Grup: "Bildirim"),
            new("bildirenId", "bildiren_id", "sayi", Baslik: "Bildiren", Grup: "Bildirim",
                KodTablosu: "public.v_personel_lookup"),
            new("arizaMetni", "ariza_metni", "metin", Baslik: "Arıza / Talep",
                Grup: "Bildirim"),
            // İLK MÜDAHALE ve TAMAMLANMA: yanıt süresi ve duruş süresi bu iki
            //   damgadan hesaplanır - ayrı "süre" alanı tutulmaz, yoksa
            //   damgayla çelişir.
            new("ilkMudahale", "ilk_mudahale", "zaman", Baslik: "İlk Müdahale",
                Grup: "Bildirim"),
            new("tamamlanma", "tamamlanma", "zaman", Baslik: "Tamamlanma", Grup: "Bildirim"),
            new("planlanan", "planlanan", "tarih", Baslik: "Planlanan Tarih",
                Grup: "Bildirim"),
            new("planliDurusDk", "planli_durus_dk", "sayi", Baslik: "Planlı Duruş (dk)",
                Grup: "Bildirim"),

            new("yapanId", "yapan_id", "sayi", Baslik: "Yapan", Grup: "Müdahale",
                KodTablosu: "public.v_personel_lookup"),
            new("firmaId", "firma_id", "sayi", Baslik: "Dış Firma", Grup: "Müdahale",
                KodTablosu: "public.v_cari_lookup"),
            // YEDEK CİHAZ: "cihaz durdu" ile "hizmet durdu" ayrı sorular.
            new("yedekDemirbasId", "yedek_demirbas_id", "sayi", Baslik: "Yerine Konan Cihaz",
                Grup: "Müdahale"),
            new("yapilanIs", "yapilan_is", "metin", Baslik: "Yapılan İş", Grup: "Müdahale"),
            new("kapsam", "kapsam", "metin", Baslik: "Kapsam (garanti/sözleşme)",
                Grup: "Müdahale", EnFazlaUzunluk: 120),
            new("maliyet", "maliyet", "para", Baslik: "Maliyet", Grup: "Müdahale"),

            // HASTA ETKİLENDİYSE bu bir iş emri değil, aynı zamanda olay
            //   bildirimidir. Bağı burada tutuyoruz ki iki kayıt ayrışmasın.
            new("hastaEtkilendi", "hasta_etkilendi", "mantik", Baslik: "Hasta etkilendi",
                Grup: "Müdahale"),
            new("olayBildirimNo", "olay_bildirim_no", "metin", Baslik: "Olay Bildirim No",
                Grup: "Müdahale", EnFazlaUzunluk: 60),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Müdahale"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("maddeler", "public.demirbas_is_emri_madde", "is_emri_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("madde", "madde", "metin", Zorunlu: true, Baslik: "Madde",
                    EnFazlaUzunluk: 200),
                new("zorunlu", "zorunlu", "mantik", Baslik: "Zorunlu"),
                new("sonuc", "sonuc", "kod", Baslik: "Sonuç",
                    SabitKodlar: DbKartMaddeSonucKodlari),
                new("olcum", "olcum", "metin", Baslik: "Ölçüm", EnFazlaUzunluk: 60),
                new("yapanId", "yapan_id", "sayi", Baslik: "Yapan",
                    KodTablosu: "public.v_personel_lookup"),
                new("zaman", "zaman", "zaman", Baslik: "Zaman"),
                new("notMetni", "not_metni", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "sira, id", Baslik: "Bakım Maddeleri",
               SubeKolonu: null, LogTabloId: 1225),

            new("parcalar", "public.demirbas_is_emri_parca", "is_emri_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "sayi", Baslik: "Stok",
                    AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
                new("parcaNo", "parca_no", "metin", Baslik: "Parça No", EnFazlaUzunluk: 60),
                new("ad", "ad", "metin", Baslik: "Ad", EnFazlaUzunluk: 200),
                new("miktar", "miktar", "ondalik", Baslik: "Miktar"),
                new("birimFiyat", "birim_fiyat", "para", Baslik: "Birim Fiyat"),
                // KAPSAM parçanın kime fatura edileceğini belirler - garanti
                //   kapsamındaki parçanın maliyeti hastaneye yazılmaz.
                new("kapsam", "kapsam", "kod", Baslik: "Kapsam",
                    SabitKodlar: DbKartParcaKapsamKodlari),
                new("belgeId", "belge_id", "sayi", Yazilabilir: false, Baslik: "Çıkış Fişi"),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 200),
            }, Sirala: "id", Baslik: "Kullanılan Parçalar",
               SubeKolonu: null, LogTabloId: 1226),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = 2, ["oncelik"] = 3, ["durum"] = 0, ["hasta_etkilendi"] = 0,
        });



    private static readonly Dictionary<string, string> DbKartOlcumSonucKodlari = new()
    {
        ["0"] = "Değerlendirilmedi", ["1"] = "Uygun", ["2"] = "Sınır dışı",
    };




    private static readonly Dictionary<string, string> DbKartMaddeSonucKodlari = new()
    {
        ["0"] = "Yapılmadı", ["1"] = "Uygun", ["2"] = "Bulgu var",
        ["3"] = "Atlandı (gerekçeli)",
    };

    private static readonly Dictionary<string, string> DbKartParcaKapsamKodlari = new()
    {
        ["0"] = "Kurum ödüyor", ["1"] = "Sözleşme", ["2"] = "Garanti",
    };
}
