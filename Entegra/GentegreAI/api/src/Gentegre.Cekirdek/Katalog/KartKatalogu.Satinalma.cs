namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// SATINALMA KARTLARI (724).
///
/// SİPARİŞ ve FATURA KARTI YOK: onlar `belge` (tür 9 / 11) ve kendi belge
/// ekranlarından düzenlenir. `belge_satinalma` 1:1 uzantısı yalnız SÜRECİ
/// taşır (teslim taahhüdü, gecikme, ceza, sözleşme bağı) - para matematiği
/// tek yerde, `fn_belge_diptoplam`da kalır.
///
/// ONAY SATIRI KARTTAN YAZILMAZ: `satinalma_onay` talep kartında SALT OKUNUR
/// sekmedir. Onayı kart üzerinden elle eklemek, imza zincirini "kim ne zaman"
/// olmaktan çıkarıp "kim ne yazdı"ya çevirirdi - basamaklar uçtan işlenir.
/// </summary>
public static partial class KartKatalogu
{
    // -------------------------------------------------- bütçe kalemi ----
    private static KartTanimi SatinalmaButce() => new(
        Ad: "satinalmaButce",
        YetkiKodu: "satinalma.butce",
        Tablo: "public.butce_kalem",
        LogTabloId: 1240,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("yil", "yil", "sayi", Zorunlu: true, Baslik: "Yıl", Grup: "Bütçe"),
            new("kod", "kod", "metin", Zorunlu: true, Baslik: "Kalem Kodu", Grup: "Bütçe",
                EnFazlaUzunluk: 30),
            new("ad", "ad", "metin", Zorunlu: true, Baslik: "Adı", Grup: "Bütçe",
                EnFazlaUzunluk: 200),
            new("grupKodu", "grup_kodu", "metin", Baslik: "Grup", Grup: "Bütçe",
                EnFazlaUzunluk: 30),
            new("tutar", "tutar", "para", Zorunlu: true, Baslik: "Bütçe Tutarı",
                Grup: "Bütçe"),
            // AŞIM DAVRANIŞI KALEMİN KENDİ AYARI: bazı kalemler (ilaç, acil sarf)
            //   aşılırsa uyarır, bazıları (yatırım) durdurur. Tek genel kural
            //   koysaydık ya acil alım dururdu ya bütçe anlamsızlaşırdı.
            new("asimDavranis", "asim_davranis", "kod", Baslik: "Aşım Davranışı",
                Grup: "Bütçe", SabitKodlar: SaKartAsimKodlari),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Bütçe"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Bütçe",
                EnFazlaUzunluk: 400),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["asim_davranis"] = 1, ["aktif"] = 1,
        });

    // -------------------------------------------------------- talep ----
    // TALEP `belge` DEĞİL: tür 105 (Stoktan Talep) servis -> eczane gibi İÇ
    //   taleptir, karşılığı transferdir. Satınalma talebi dışarı çıkar, bütçe
    //   ve onay zinciri taşır, henüz belge değildir.
    private static KartTanimi SatinalmaTalep() => new(
        Ad: "satinalmaTalep",
        YetkiKodu: "satinalma.talep",
        Tablo: "public.satinalma_talep",
        LogTabloId: 1241,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("talepNo", "talep_no", "metin", Yazilabilir: false, Baslik: "Talep No",
                Grup: "Talep"),
            new("tarih", "tarih", "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Talep"),
            // KAYNAK: elle mi açıldı, kritik stok mu doğurdu, arıza mı. Otomatik
            //   doğan talebin gerekçesi zaten kaydında - elle yazdırmak tekrar olur.
            new("kaynak", "kaynak", "kod", Baslik: "Kaynak", Grup: "Talep",
                SabitKodlar: KaynakKatalogu.SaKaynakKodlari),
            new("kaynakTur", "kaynak_tur", "sayi", Yazilabilir: false,
                Baslik: "Kaynak Tür", Grup: "Talep", Gizli: true),
            new("kaynakId", "kaynak_id", "sayi", Yazilabilir: false, Baslik: "Kaynak Kayıt",
                Grup: "Talep", Gizli: true),
            new("isteyenId", "isteyen_id", "sayi", Baslik: "İsteyen", Grup: "Talep",
                KodTablosu: "public.v_personel_lookup"),
            new("departmanId", "departman_id", "sayi", Zorunlu: true, Baslik: "Birim",
                Grup: "Talep", KodTablosu: "public.v_departman_lookup"),
            new("oncelik", "oncelik", "kod", Baslik: "Öncelik", Grup: "Talep",
                SabitKodlar: KaynakKatalogu.SaOncelikKodlari),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Talep",
                SabitKodlar: KaynakKatalogu.SaTalepDurumKodlari),

            // BÜTÇE KALEMİ ZORUNLU DEĞİL ama boşsa onay zinciri "bütçe dışı"
            //   basamağı ekler: parasız talep diye bir şey yok, kaynağı
            //   belirsiz talep var.
            new("butceKalemId", "butce_kalem_id", "sayi", Baslik: "Bütçe Kalemi",
                Grup: "Gerekçe"),
            new("tahminiTutar", "tahmini_tutar", "para", Baslik: "Tahmini Tutar",
                Grup: "Gerekçe"),
            new("gerekce", "gerekce", "metin", Zorunlu: true, Baslik: "Gerekçe",
                Grup: "Gerekçe"),
            // HESAP NOTU: "neden 200 adet" sorusunun yanıtı (tüketim/hasta
            //   sayısı hesabı). Miktarın kendisi yanıt değildir.
            new("hesapNotu", "hesap_notu", "metin", Baslik: "Miktar Hesabı",
                Grup: "Gerekçe"),
            new("birlestirilenId", "birlestirilen_id", "sayi", Yazilabilir: false,
                Baslik: "Birleştirildiği Talep", Grup: "Gerekçe"),
            new("redNeden", "red_neden", "metin", Baslik: "Red Nedeni", Grup: "Gerekçe",
                EnFazlaUzunluk: 400),
        },
        Detaylar: new DetayTanimi[]
        {
            new("satirlar", "public.satinalma_talep_satir", "talep_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("stokId", "stok_id", "sayi", Baslik: "Stok",
                    AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
                new("hizmetId", "hizmet_id", "sayi", Baslik: "Hizmet",
                    KodTablosu: "public.v_hizmet_lookup"),
                new("ad", "ad", "metin", Zorunlu: true, Baslik: "Talep Edilen",
                    EnFazlaUzunluk: 200),
                new("miktar", "miktar", "ondalik", Zorunlu: true, Baslik: "Miktar"),
                new("birim", "birim", "metin", Baslik: "Birim", EnFazlaUzunluk: 20),
                // SON ALIŞ FİYATI TAHMİN İÇİNDİR, taahhüt değil: teklifi
                //   bağlamaz ama bütçe kontrolünü çalıştırır.
                new("sonAlisFiyat", "son_alis_fiyat", "para", Baslik: "Son Alış Fiyatı"),
                new("tahminiTutar", "tahmini_tutar", "para", Baslik: "Tahmini Tutar"),
                new("sartname", "sartname", "metin", Baslik: "Teknik Şartname"),
                new("belgeSatirId", "belge_satir_id", "sayi", Yazilabilir: false,
                    Baslik: "Sipariş Satırı"),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "sira, id", Baslik: "Talep Satırları",
               SubeKolonu: null, LogTabloId: 1242),

            // ONAY ZİNCİRİ SALT OKUNUR: basamaklar uçtan işlenir (onayla/reddet).
            //   Elle satır eklemek imza zincirini anlamsız kılardı.
            //
            //   OMURGA ÜZERİNDE (738): satırlar artık `satinalma_onay`da
            //   değil, modülden bağımsız `onay_adim`da. Görünüm talebin
            //   zincirini `kaynak_tur = 1241` ile süzer - izin ve avans da
            //   aynı tabloyu kullanacak, sekme kodu değişmeyecek.
            new("onaylar", "public.v_satinalma_talep_onay", "talep_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("basamak", "basamak", "sayi", Baslik: "Basamak"),
                new("adimAd", "adim_ad", "metin", Baslik: "Basamak Adı"),
                new("rol", "rol", "kod", Baslik: "Onay Rolü",
                    SabitKodlar: SaKartOnayRolKodlari),
                new("onaylayanId", "onaylayan_id", "sayi", Baslik: "Onaylayan",
                    KodTablosu: "public.v_personel_lookup"),
                new("durum", "durum", "kod", Baslik: "Durum",
                    SabitKodlar: SaKartOnayDurumKodlari),
                new("kararZamani", "karar_zamani", "zaman", Baslik: "Karar"),
                new("gerekce", "gerekce", "metin", Baslik: "Gerekçe", EnFazlaUzunluk: 400),
                // SÖZLÜ ONAYIN YAZILI TAMAMLANMA SÜRESİ: acil alım sözlü
                //   onayla başlar, yazılı tamamlanmazsa askıda kalır.
                new("yaziliSon", "yazili_son", "zaman", Baslik: "Yazılı Son"),
                // TERMİN: basamak bu tarihe kadar karara bağlanmalı. Süre
                //   dolunca KİMSE otomatik onaylanmaz - sessiz onay, onayın
                //   kendisini ortadan kaldırırdı; hatırlatma içindir.
                new("termin", "termin", "zaman", Baslik: "Termin"),
            }, Sirala: "basamak, id", Baslik: "Onay Zinciri",
               SubeKolonu: null, LogTabloId: 1243, SaltOkunur: true),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["kaynak"] = 1, ["oncelik"] = 3, ["durum"] = 0,
        });

    // ------------------------------------------------------- teklif ----
    private static KartTanimi SatinalmaTeklif() => new(
        Ad: "satinalmaTeklif",
        YetkiKodu: "satinalma.teklif",
        Tablo: "public.satinalma_teklif",
        LogTabloId: 1244,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("teklifNo", "teklif_no", "metin", Yazilabilir: false, Baslik: "Teklif No",
                Grup: "Teklif"),
            new("talepId", "talep_id", "sayi", Baslik: "Talep", Grup: "Teklif"),
            new("konu", "konu", "metin", Zorunlu: true, Baslik: "Konu", Grup: "Teklif",
                EnFazlaUzunluk: 300),
            new("usul", "usul", "kod", Zorunlu: true, Baslik: "Usul", Grup: "Teklif",
                SabitKodlar: KaynakKatalogu.SaUsulKodlari),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Teklif",
                SabitKodlar: KaynakKatalogu.SaTeklifDurumKodlari),
            new("davetTarihi", "davet_tarihi", "tarih", Baslik: "Davet Tarihi",
                Grup: "Teklif"),
            new("sonTarih", "son_tarih", "zaman", Baslik: "Son Teklif Zamanı",
                Grup: "Teklif"),
            // AÇILMA ZAMANI: teklifler bu andan önce görülmez. Damga yoksa
            //   "kim ne zaman gördü" sorusu yanıtsız kalır.
            new("acilmaZamani", "acilma_zamani", "zaman", Baslik: "Açılma", Grup: "Teklif"),
            new("tahminiBedel", "tahmini_bedel", "para", Baslik: "Yaklaşık Maliyet",
                Grup: "Teklif"),

            // AĞIRLIKLAR DAVETTEN SONRA KİLİTLİ (724 tetiği): sonradan ağırlık
            //   değiştirmek, kazananı seçip gerekçeyi sonra yazmaktır.
            new("agirlikFiyat", "agirlik_fiyat", "sayi", Baslik: "Fiyat Ağırlığı",
                Grup: "Değerlendirme"),
            new("agirlikTeslim", "agirlik_teslim", "sayi", Baslik: "Teslim Ağırlığı",
                Grup: "Değerlendirme"),
            new("agirlikGaranti", "agirlik_garanti", "sayi", Baslik: "Garanti Ağırlığı",
                Grup: "Değerlendirme"),
            new("agirlikPerformans", "agirlik_performans", "sayi",
                Baslik: "Performans Ağırlığı", Grup: "Değerlendirme"),
            new("agirlikKilit", "agirlik_kilit", "mantik", Yazilabilir: false,
                Baslik: "Ağırlıklar kilitli", Grup: "Değerlendirme"),

            new("kararFirmaId", "karar_firma_id", "sayi", Baslik: "Kazanan Firma", Grup: "Karar",
                KodTablosu: "public.v_cari_lookup"),
            // EN DÜŞÜK ALINMADIYSA GEREKÇE ŞART: "neden pahalısı" sorusu
            //   denetimin ilk sorusudur.
            new("kararGerekce", "karar_gerekce", "metin", Baslik: "Karar Gerekçesi",
                Grup: "Karar"),
            new("kararZamani", "karar_zamani", "zaman", Baslik: "Karar Zamanı",
                Grup: "Karar"),
            new("kurul", "kurul", "metin", Baslik: "Komisyon Üyeleri", Grup: "Karar",
                EnFazlaUzunluk: 300),
        },
        Detaylar: new DetayTanimi[]
        {
            new("kriterler", "public.satinalma_teklif_kriter", "teklif_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("madde", "madde", "metin", Zorunlu: true, Baslik: "Şartname Maddesi",
                    EnFazlaUzunluk: 400),
                // ZORUNLU MADDE ELEME SEBEBİDİR: karşılamayan firma puanlamaya
                //   girmez - puanla telafi edilebilseydi şartname tavsiye olurdu.
                new("zorunlu", "zorunlu", "mantik", Baslik: "Zorunlu"),
            }, Sirala: "sira, id", Baslik: "Şartname Kriterleri",
               SubeKolonu: null, LogTabloId: 1245),

            new("firmalar", "public.satinalma_teklif_firma", "teklif_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("firmaId", "firma_id", "sayi", Zorunlu: true, Baslik: "Firma",
                    KodTablosu: "public.v_cari_lookup"),
                new("davetZamani", "davet_zamani", "zaman", Baslik: "Davet"),
                new("durum", "durum", "kod", Baslik: "Durum",
                    SabitKodlar: SaKartFirmaDurumKodlari),
                new("teklifZamani", "teklif_zamani", "zaman", Baslik: "Teklif Zamanı"),
                new("tutar", "tutar", "para", Baslik: "Teklif Tutarı"),
                new("doviz", "doviz", "metin", Baslik: "Döviz", EnFazlaUzunluk: 3),
                new("teslimGun", "teslim_gun", "sayi", Baslik: "Teslim (gün)"),
                new("garantiAy", "garanti_ay", "sayi", Baslik: "Garanti (ay)"),
                new("odemeGun", "odeme_gun", "sayi", Baslik: "Ödeme (gün)"),
                // PUANLAR AĞIRLIKTAN HESAPLANIR: elle puan girmek,
                //   değerlendirmeyi ağırlıklardan koparırdı.
                new("puanFiyat", "puan_fiyat", "ondalik", Yazilabilir: false,
                    Baslik: "Fiyat Puanı"),
                new("puanTeslim", "puan_teslim", "ondalik", Yazilabilir: false,
                    Baslik: "Teslim Puanı"),
                new("puanGaranti", "puan_garanti", "ondalik", Yazilabilir: false,
                    Baslik: "Garanti Puanı"),
                new("puanPerformans", "puan_performans", "ondalik", Yazilabilir: false,
                    Baslik: "Performans Puanı"),
                new("puanToplam", "puan_toplam", "ondalik", Yazilabilir: false,
                    Baslik: "Toplam Puan"),
                new("elemeNeden", "eleme_neden", "metin", Baslik: "Eleme Nedeni",
                    EnFazlaUzunluk: 300),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "puan_toplam desc nulls last, id", Baslik: "Davet Edilen Firmalar",
               SubeKolonu: null, LogTabloId: 1246),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["usul"] = 2, ["durum"] = 0, ["agirlik_fiyat"] = 60, ["agirlik_teslim"] = 15,
            ["agirlik_garanti"] = 10, ["agirlik_performans"] = 15, ["agirlik_kilit"] = 0,
        });

    // --------------------------------------------------- mal kabul ----
    private static KartTanimi SatinalmaKabul() => new(
        Ad: "satinalmaKabul",
        YetkiKodu: "satinalma.kabul",
        Tablo: "public.satinalma_kabul",
        LogTabloId: 1247,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("tutanakNo", "tutanak_no", "metin", Baslik: "Tutanak No", Grup: "Kabul",
                EnFazlaUzunluk: 30),
            new("tarih", "tarih", "tarih", Zorunlu: true, Baslik: "Tarih", Grup: "Kabul"),
            // İRSALİYE ve SİPARİŞ AYRI ALAN: mal kabul ikisini KARŞILAŞTIRIR.
            //   Tek belgeye bağlasaydık "sipariş dışı gelen" görünmezdi.
            //
            //   SEÇİLİR, YAZILMAZ (737): alan `sayi` idi ve kullanıcıdan
            //   belgenin İÇ NUMARASINI bekliyordu - kimsenin ezberinde olmayan
            //   bir sayı. Yanlış yazılırsa muayene başka bir sevkiyatla
            //   karşılaştırılır ve hata kendini hiç belli etmez. Görünümler
            //   belge no · tarih · tedarikçi gösterir, son bir yılla sınırlı.
            new("belgeId", "belge_id", "sayi", Baslik: "İrsaliye", Grup: "Kabul",
                KodTablosu: "public.v_kabul_irsaliye_lookup"),
            new("siparisBelgeId", "siparis_belge_id", "sayi", Baslik: "Sipariş",
                Grup: "Kabul", KodTablosu: "public.v_kabul_siparis_lookup"),
            new("sonuc", "sonuc", "kod", Baslik: "Sonuç", Grup: "Kabul",
                SabitKodlar: SaKartKabulSonucKodlari),
            new("komisyon", "komisyon", "metin", Baslik: "Komisyon", Grup: "Kabul",
                EnFazlaUzunluk: 300),
            new("uygunsuzluk", "uygunsuzluk", "metin", Baslik: "Uygunsuzluk", Grup: "Kabul"),
            // KULLANICI BİRİM ONAYI AYRI: komisyon "sipariş ettiğimiz mi" der,
            //   kullanan birim "işimizi görüyor mu" der. İkisi aynı soru değil.
            new("kullaniciBirimOnay", "kullanici_birim_onay", "mantik",
                Baslik: "Kullanıcı birim onayladı", Grup: "Kabul"),
            new("kullaniciBirimId", "kullanici_birim_id", "sayi", Baslik: "Kullanıcı Birim",
                Grup: "Kabul", KodTablosu: "public.v_departman_lookup"),

            // SOĞUK ZİNCİR SEVKİYATIN TAMAMINA AİT (733): aracın/kutunun
            //   sıcaklığı kaleme değil gönderiye özgüdür. Satıra koysaydık
            //   aynı ölçüm on satıra kopyalanırdı.
            new("sogukZincir", "soguk_zincir", "mantik",
                Baslik: "Soğuk zincir gerekli", Grup: "Soğuk Zincir"),
            new("sogukZincirUygun", "soguk_zincir_uygun", "kod", Baslik: "Ölçüm Sonucu",
                Grup: "Soğuk Zincir", SabitKodlar: SaKartSogukKodlari),
            new("sicaklik", "sicaklik", "ondalik", Baslik: "Sıcaklık (°C)",
                Grup: "Soğuk Zincir"),
            new("tasimaKosulu", "tasima_kosulu", "metin", Baslik: "Taşıma Koşulu",
                Grup: "Soğuk Zincir", EnFazlaUzunluk: 80),
        },
        Detaylar: new DetayTanimi[]
        {
            // MUAYENE SATIRLARI. ÜÇ MİKTAR AYRI: sipariş · irsaliye · sayılan.
            //   Tedarikçi 100 sipariş edilene 90 irsaliye kesip 85 gönderebilir;
            //   hangi farkın kime ait olduğu ancak üçü birden yazılırsa anlaşılır.
            new("satirlar", "public.satinalma_kabul_satir", "kabul_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("stokId", "stok_id", "sayi", Baslik: "Stok",
                    AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
                new("ad", "ad", "metin", Baslik: "Kalem", EnFazlaUzunluk: 200),
                new("birim", "birim", "metin", Baslik: "Birim", EnFazlaUzunluk: 20),
                new("siparisMiktar", "siparis_miktar", "ondalik", Baslik: "Sipariş"),
                new("irsaliyeMiktar", "irsaliye_miktar", "ondalik", Baslik: "İrsaliye"),
                new("sayilan", "sayilan", "ondalik", Baslik: "Sayılan"),
                new("birimFiyat", "birim_fiyat", "para", Baslik: "Birim Fiyat"),
                // LOT ve MİAD KALEM BAŞINA: aynı kalem iki lot hâlinde gelebilir
                //   ve miadı kısa olan kabul edilmeyebilir (sözleşme raf ömrü).
                new("lot", "lot", "metin", Baslik: "Lot", EnFazlaUzunluk: 60),
                new("skt", "skt", "tarih", Baslik: "SKT"),
                // SONUÇ BAŞLIĞI AŞAĞI ÇEKER (733 tetiği): bir satır reddedilirse
                //   tutanak "tam kabul" olamaz. Yukarı çekmez - komisyon kalem
                //   dışı sebeple (belge eksiği) yine de reddedebilir.
                new("sonuc", "sonuc", "kod", Baslik: "Sonuç",
                    SabitKodlar: SaKartKabulSatirKodlari),
                new("uygunsuzluk", "uygunsuzluk", "metin", Baslik: "Uygunsuzluk",
                    EnFazlaUzunluk: 300),
                new("belgeSatirId", "belge_satir_id", "sayi", Yazilabilir: false,
                    Baslik: "İrsaliye Satırı"),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "sira, id", Baslik: "Muayene Satırları",
               SubeKolonu: null, LogTabloId: 1253),

            // KAREKOD / SERİ (734). SALT OKUNUR: kutular okuyucudan gelir,
            //   elle satır eklemek serileştirmenin anlamını bozar (kutuyu
            //   okutmadan "okutuldu" demek). Yanlış okutulan kutu
            //   `/kabul/{id}/karekod-sil` ucundan silinir - o uç bildirilmiş
            //   satırı korur, kart bu ayrımı ifade edemez.
            //
            //   TABLO `its_bildirim_satir`: okutulan kod ile İTS'e
            //   bildirilecek kod AYNI koddur (427), ikinci bir tablo açsaydık
            //   aynı kutunun iki kaydı olurdu.
            new("karekodlar", "public.its_bildirim_satir", "kabul_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("gtin", "gtin", "metin", Yazilabilir: false, Baslik: "GTIN"),
                new("seriNo", "seri_no", "metin", Yazilabilir: false, Baslik: "Seri No"),
                new("partiNo", "parti_no", "metin", Yazilabilir: false, Baslik: "Lot / Parti"),
                new("sonKullanma", "son_kullanma", "tarih", Yazilabilir: false,
                    Baslik: "SKT"),
                new("stokId", "stok_id", "sayi", Yazilabilir: false, Baslik: "Stok"),
                // DOĞRULAMA: 0 sorulmadı · 1 geçerli · 2 bu tutanakta beklenmiyor.
                new("dogrulama", "dogrulama", "kod", Yazilabilir: false, Baslik: "Durum",
                    SabitKodlar: SaKartKarekodKodlari),
                new("dogrulamaNot", "dogrulama_not", "metin", Yazilabilir: false,
                    Baslik: "Not"),
                new("karekod", "karekod", "metin", Yazilabilir: false, Baslik: "Ham Kod"),
            }, Sirala: "id", Baslik: "Karekod / Seri",
               SubeKolonu: null, LogTabloId: 1254, SaltOkunur: true),

            // İTS BİLDİRİMİ (736). SALT OKUNUR ve GÖRÜNÜM ÜZERİNDE: bildirim
            //   belgeye bağlı, satır muayeneye - tutanağın bildirimi
            //   satırlarından TÜRER (`v_kabul_its_bildirim`). Karta yazılabilir
            //   bir alan koysaydık, kullanıcı gönderilmiş bir bildirimin
            //   durumunu elle değiştirebilirdi; gönderim durumu bizim değil
            //   İTS'in söylediği şeydir.
            //
            //   Kuyruğa alma / iptal kendi uçlarından geçer - orada
            //   "reddedilen kalemin kutusu bildirilmez" kuralı uygulanıyor.
            new("itsBildirimleri", "public.v_kabul_its_bildirim", "kabul_id",
                new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false, Baslik: "Bildirim"),
                new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                    SabitKodlar: SaKartItsDurumKodlari),
                new("kutu", "kutu", "sayi", Yazilabilir: false, Baslik: "Kutu"),
                new("kalem", "kalem", "sayi", Yazilabilir: false, Baslik: "Kalem"),
                new("karsiGln", "karsi_gln", "metin", Yazilabilir: false,
                    Baslik: "Gönderen (GLN)"),
                new("itsBildirimNo", "its_bildirim_no", "metin", Yazilabilir: false,
                    Baslik: "İTS Bildirim No"),
                // TEST BAYRAĞI GÖRÜNÜR: test ortamına gitmiş bir bildirimi
                //   gerçek sanmak, yapılmamış bir bildirimi yapılmış saymaktır.
                new("testMi", "test_mi", "mantik", Yazilabilir: false, Baslik: "Test"),
                new("deneme", "deneme", "sayi", Yazilabilir: false, Baslik: "Deneme"),
                new("hataKodu", "hata_kodu", "metin", Yazilabilir: false, Baslik: "Hata Kodu"),
                new("hataMesaj", "hata_mesaj", "metin", Yazilabilir: false, Baslik: "Hata"),
                new("aciklama", "aciklama", "metin", Yazilabilir: false, Baslik: "Not"),
            }, Sirala: "id", Baslik: "İTS Bildirimi",
               SubeKolonu: null, LogTabloId: 1255, SaltOkunur: true),
        },
        // OKUTULMUŞ KUTUSU OLAN TUTANAK SİLİNEMEZ (737). Kutu okutulduysa
        //   sayım yapılmıştır ve o sayım kanıttır; silinince kutular belgenin
        //   taslak bildiriminde sahipsiz kalıyor ve başka bir tutanağın
        //   bildirimine karışabiliyordu. Gerçekten silmek isteyen önce
        //   kutuları siler - o da bilinçli bir karardır.
        SilmeEngelleri: new SilmeEngeli[]
        {
            new("public.its_bildirim_satir", "kabul_id",
                "Bu tutanakta okutulmuş karekod var, silinemez - önce kutuları silin."),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            // TARİH BUGÜN DOĞAR (737): alan zorunluydu ama boş açılıyordu;
            //   her yeni tutanakta ilk kaydetme "Tarih zorunlu" ile dönüyordu.
            //   Muayene tarihi sevkiyatın geldiği gündür - başka bir gün
            //   girmek istisnadır, kural değil.
            ["tarih"] = "@simdi",
            ["sonuc"] = 0, ["kullanici_birim_onay"] = 0,
            ["soguk_zincir"] = 0, ["soguk_zincir_uygun"] = 0,
        });

    // --------------------------------------------- tedarikçi sözleşme ----
    private static KartTanimi TedarikciSozlesme() => new(
        Ad: "tedarikciSozlesme",
        YetkiKodu: "satinalma.sozlesme",
        Tablo: "public.tedarikci_sozlesme",
        LogTabloId: 1248,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("sozlesmeNo", "sozlesme_no", "metin", Zorunlu: true, Baslik: "Sözleşme No",
                Grup: "Sözleşme", EnFazlaUzunluk: 40),
            new("firmaId", "firma_id", "sayi", Zorunlu: true, Baslik: "Tedarikçi",
                Grup: "Sözleşme", KodTablosu: "public.v_cari_lookup"),
            new("konu", "konu", "metin", Baslik: "Konu", Grup: "Sözleşme",
                EnFazlaUzunluk: 300),
            new("tip", "tip", "kod", Baslik: "Tip", Grup: "Sözleşme",
                SabitKodlar: SaKartSozlesmeTipKodlari),
            new("baslangic", "baslangic", "tarih", Baslik: "Başlangıç", Grup: "Sözleşme"),
            new("bitis", "bitis", "tarih", Baslik: "Bitiş", Grup: "Sözleşme"),
            new("ongorulenTutar", "ongorulen_tutar", "para", Baslik: "Öngörülen Tutar",
                Grup: "Sözleşme"),
            new("durum", "durum", "kod", Baslik: "Durum", Grup: "Sözleşme",
                SabitKodlar: SaKartSozlesmeDurumKodlari),

            new("teslimGun", "teslim_gun", "sayi", Baslik: "Teslim Süresi (gün)",
                Grup: "Yükümlülük"),
            // ACİL TESLİM SAATİ ayrı: ilaç sözleşmesinde "acil" saatle ölçülür,
            //   günle değil.
            new("acilTeslimSaat", "acil_teslim_saat", "sayi",
                Baslik: "Acil Teslim (saat)", Grup: "Yükümlülük"),
            new("cezaBinde", "ceza_binde", "ondalik", Baslik: "Gecikme Cezası (binde/gün)",
                Grup: "Yükümlülük"),
            new("cezaUstYuzde", "ceza_ust_yuzde", "ondalik", Baslik: "Ceza Üst Sınırı (%)",
                Grup: "Yükümlülük"),
            // ASGARİ RAF ÖMRÜ: miadına üç ay kalmış ilaç teslim edilirse
            //   hastane imhayı da satın almış olur.
            new("asgariRafOmruAy", "asgari_raf_omru_ay", "sayi",
                Baslik: "Asgari Raf Ömrü (ay)", Grup: "Yükümlülük"),
            new("sogukZincir", "soguk_zincir", "mantik", Baslik: "Soğuk zincir zorunlu",
                Grup: "Yükümlülük"),
            new("fesihGecikmeAdet", "fesih_gecikme_adet", "sayi",
                Baslik: "Fesih Eşiği - Gecikme", Grup: "Yükümlülük"),
            new("fesihUygunsuzlukAdet", "fesih_uygunsuzluk_adet", "sayi",
                Baslik: "Fesih Eşiği - Uygunsuzluk", Grup: "Yükümlülük"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Yükümlülük"),
        },
        Detaylar: new DetayTanimi[]
        {
            // SÖZLEŞME FİYATI SİPARİŞİ BAĞLAR: sipariş satırındaki fiyat
            //   buradan gelir, elle girilmez. İki fiyat olsaydı hangisinin
            //   geçerli olduğu faturada tartışılırdı.
            new("fiyatlar", "public.tedarikci_sozlesme_fiyat", "sozlesme_id",
                new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("stokId", "stok_id", "sayi", Baslik: "Stok",
                    AramaKaynagi: "stok", KodTablosu: "public.v_stok_lookup"),
                new("hizmetId", "hizmet_id", "sayi", Baslik: "Hizmet",
                    KodTablosu: "public.v_hizmet_lookup"),
                new("ad", "ad", "metin", Baslik: "Kalem", EnFazlaUzunluk: 200),
                new("birimFiyat", "birim_fiyat", "para", Zorunlu: true,
                    Baslik: "Birim Fiyat"),
                new("doviz", "doviz", "metin", Baslik: "Döviz", EnFazlaUzunluk: 3),
                new("gecerliBas", "gecerli_bas", "tarih", Baslik: "Geçerli Başlangıç"),
                new("gecerliSon", "gecerli_son", "tarih", Baslik: "Geçerli Bitiş"),
            }, Sirala: "id", Baslik: "Sözleşme Fiyatları",
               SubeKolonu: null, LogTabloId: 1249),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tip"] = 1, ["durum"] = 0, ["soguk_zincir"] = 0,
        });

    // ----------------------------------------------- tedarikçi olayı ----
    // SKOR GİRİLMEZ, HESAPLANIR: her gecikme/uygunsuzluk/fatura farkı bir OLAY
    //   satırıdır, `v_tedarikci_skor` son 12 aydan türetir. Elle puan alanı
    //   olsaydı skor bir kanı olurdu, kayıt değil.
    private static KartTanimi TedarikciOlay() => new(
        Ad: "tedarikciOlay",
        YetkiKodu: "satinalma.tedarikci",
        Tablo: "public.tedarikci_olay",
        LogTabloId: 1250,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("firmaId", "firma_id", "sayi", Zorunlu: true, Baslik: "Tedarikçi",
                Grup: "Olay", KodTablosu: "public.v_cari_lookup"),
            new("zaman", "zaman", "zaman", Zorunlu: true, Baslik: "Zaman", Grup: "Olay"),
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "Olay Türü", Grup: "Olay",
                SabitKodlar: SaKartOlayKodlari),
            new("belgeId", "belge_id", "sayi", Baslik: "İlgili Belge", Grup: "Olay"),
            new("sozlesmeId", "sozlesme_id", "sayi", Baslik: "Sözleşme", Grup: "Olay"),
            // SKOR ETKİSİ olayın AĞIRLIĞIDIR: bir günlük gecikme ile miadı
            //   geçmiş teslimat aynı ağırlıkta sayılamaz.
            new("skorEtki", "skor_etki", "ondalik", Baslik: "Skor Etkisi", Grup: "Olay"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Olay"),
        },
        Detaylar: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = 1, ["skor_etki"] = 0,
        });

    // 724 semasi: 0 uyar - 1 ek onay ister - 2 engeller.
    private static readonly Dictionary<string, string> SaKartAsimKodlari = new()
    {
        ["0"] = "Uyar, geçir", ["1"] = "Ek onay ister", ["2"] = "Engeller",
    };




    private static readonly Dictionary<string, string> SaKartOnayRolKodlari = new()
    {
        ["1"] = "Birim sorumlusu", ["2"] = "Satınalma", ["3"] = "Başhekim / müdür",
        ["4"] = "Mali işler", ["5"] = "Yönetim kurulu",
    };

    private static readonly Dictionary<string, string> SaKartOnayDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Onayladı", ["2"] = "Reddetti",
        ["3"] = "Bilgi istedi", ["4"] = "Sözlü onay",
    };



    private static readonly Dictionary<string, string> SaKartFirmaDurumKodlari = new()
    {
        ["0"] = "Davet edildi", ["1"] = "Teklif verdi", ["2"] = "Teklif vermedi",
        ["3"] = "Teknik elendi", ["4"] = "Değerlendirildi", ["5"] = "Kazandı",
    };

    // its_bildirim.durum (427): 0 hazırlanıyor · 1 bekliyor · 2 gönderiliyor
    //   · 3 gönderildi · 4 hatalı · 5 iptal.
    private static readonly Dictionary<string, string> SaKartItsDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Kuyrukta", ["2"] = "Gönderiliyor",
        ["3"] = "Gönderildi", ["4"] = "Hatalı", ["5"] = "İptal",
    };

    private static readonly Dictionary<string, string> SaKartKarekodKodlari = new()
    {
        ["0"] = "Okutuldu", ["1"] = "İTS doğruladı", ["2"] = "Beklenmeyen kutu",
    };

    private static readonly Dictionary<string, string> SaKartSogukKodlari = new()
    {
        ["0"] = "Ölçülmedi", ["1"] = "Uygun", ["2"] = "Uygunsuz",
    };

    // Satır sonucu başlıktakiyle aynı ölçek - başlık satırlardan türüyor.
    private static readonly Dictionary<string, string> SaKartKabulSatirKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Kabul", ["2"] = "Kısmi kabul", ["3"] = "Ret",
    };

    private static readonly Dictionary<string, string> SaKartKabulSonucKodlari = new()
    {
        ["0"] = "Açık", ["1"] = "Kabul", ["2"] = "Kısmi kabul", ["3"] = "Ret",
    };

    private static readonly Dictionary<string, string> SaKartSozlesmeTipKodlari = new()
    {
        ["1"] = "Çerçeve (birim fiyat)", ["2"] = "Tek seferlik",
        ["3"] = "Bakım / servis", ["4"] = "Kiralama",
    };

    private static readonly Dictionary<string, string> SaKartSozlesmeDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Yürürlükte", ["2"] = "Sona erdi",
        ["3"] = "Feshedildi",
    };

    private static readonly Dictionary<string, string> SaKartOlayKodlari = new()
    {
        ["1"] = "Gecikme", ["2"] = "Kalite uygunsuzluğu", ["3"] = "Fatura farkı",
        ["4"] = "Belge eksiği", ["5"] = "Olumlu (taahhüdün üstünde)", ["9"] = "Diğer",
    };
}
