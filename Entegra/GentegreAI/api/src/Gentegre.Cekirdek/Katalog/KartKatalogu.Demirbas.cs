namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DEMIRBAS karti (216, Ekranlar/demirbas_karti.html).
///
/// Ilk surum mockup'in kimlik + satin alma cekirdegidir; zimmet gecmisi,
/// bakim ve amortisman gridleri ILERIDE (listeTanimlari yer tutucu sekmeler).
///
/// KLINIK MUHENDISLIK KATMANI (723) AYNI KARTA EKLENDI, ikinci kart acilmadi:
/// hastanedeki cihaz da bir demirbas. Ayri kart acsaydik ayni satirin iki
/// duzenleme ekrani ve iki log tablo kodu olurdu - denetimde "bu alani kim
/// degistirdi" sorusu iki yerden toplanirdi. Alanlar `UrunModu: 2` ile yalniz
/// HBYS kurulumunda cizilir; ERP demirbas karti oldugu gibi kalir.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi Demirbas() => new(
        Ad: "demirbas",
        YetkiKodu: "demirbas",
        Tablo: "public.demirbas",
        LogTabloId: 925,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
            { ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",   "id",   "sayi",  Yazilabilir: false),
            // STANDART BASLIK SERIDI: Demirbas No / Adi / Durum her sekmede sabit.
            new("kod",  "kod",  "metin", EnFazlaUzunluk: 40,
                Baslik: "Demirbaş No", Grup: "Kimlik"),
            new("ad",   "ad",   "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Adı", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            new("kategori", "kategori", "kod", KodListesi: "demirbas.kategori",
                Baslik: "Kategori", Grup: "Genel", AltGrup: "Kimlik Bilgileri"),
            new("marka",    "marka",    "metin", EnFazlaUzunluk: 80,
                Baslik: "Marka", Grup: "Genel", AltGrup: "Kimlik Bilgileri"),
            new("model",    "model",    "metin", EnFazlaUzunluk: 80,
                Baslik: "Model", Grup: "Genel", AltGrup: "Kimlik Bilgileri"),
            new("modelYili", "model_yili", "sayi",
                Baslik: "Model Yılı", Grup: "Genel", AltGrup: "Kimlik Bilgileri"),
            new("seriNo",   "seri_no",  "metin", EnFazlaUzunluk: 60,
                Baslik: "Seri No", Grup: "Genel", AltGrup: "Kimlik Bilgileri"),
            new("barkod",   "barkod",   "metin", EnFazlaUzunluk: 40,
                Baslik: "Barkod / Etiket", Grup: "Genel", AltGrup: "Kimlik Bilgileri"),

            new("lokasyon", "lokasyon", "kod", KodListesi: "demirbas.lokasyon",
                Baslik: "Lokasyon", Grup: "Genel", AltGrup: "Konum / Zimmet"),
            new("zimmetTarafId", "zimmet_taraf_id", "kod",
                KodTablosu: "public.v_personel_lookup",
                Baslik: "Zimmet (Personel)", Grup: "Genel", AltGrup: "Konum / Zimmet"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 400,
                Baslik: "Açıklama", Grup: "Genel", AltGrup: "Konum / Zimmet"),

            new("alisTarihi",  "alis_tarihi",  "tarih",
                Baslik: "Alış Tarihi", Grup: "Genel", AltGrup: "Satın Alma"),
            new("tedarikciId", "tedarikci_id", "kod", KodTablosu: "public.v_cari_lookup",
                Baslik: "Tedarikçi", Grup: "Genel", AltGrup: "Satın Alma"),
            new("alisTutari",  "alis_tutari",  "para",
                Baslik: "Alış Tutarı", Grup: "Genel", AltGrup: "Satın Alma"),
            new("garantiBitis", "garanti_bitis", "tarih",
                Baslik: "Garanti Bitiş", Grup: "Genel", AltGrup: "Satın Alma"),

            new("subeId", "sube_id", "sayi", Yazilabilir: false, Baslik: "Şube"),

            // ---- Klinik mühendislik (723) - yalnız HBYS kurulumunda ----
            // RİSK SINIFI PERİYODU BELİRLER: yaşam destek cihazı yılda değil
            //   altı ayda bakım ister. Sınıf, plan üreten bir girdidir - etiket
            //   değil.
            new("riskSinifi", "risk_sinifi", "kod", SabitKodlar: KaynakKatalogu.DbRiskKodlari,
                Baslik: "Risk Sınıfı", Grup: "Biyomedikal", AltGrup: "Sınıflandırma",
                UrunModu: 2),
            new("korumaSinifi", "koruma_sinifi", "metin", EnFazlaUzunluk: 20,
                Baslik: "Koruma Sınıfı", Grup: "Biyomedikal", AltGrup: "Sınıflandırma",
                UrunModu: 2),
            new("uygulamaTipi", "uygulama_tipi", "metin", EnFazlaUzunluk: 20,
                Baslik: "Uygulama Tipi (B/BF/CF)", Grup: "Biyomedikal",
                AltGrup: "Sınıflandırma", UrunModu: 2),
            // ÜTS/UDI CİHAZIN KÜRESEL KİMLİĞİ: geri çağırma duyurusu UDI ile
            //   gelir; "bizde var mı" sorusu ancak bu alan doluysa yanıtlanır.
            new("utsUdi", "uts_udi", "metin", EnFazlaUzunluk: 60,
                Baslik: "ÜTS / UDI", Grup: "Biyomedikal", AltGrup: "Sınıflandırma",
                UrunModu: 2),
            new("departmanId", "departman_id", "kod",
                KodTablosu: "public.v_departman_lookup",
                Baslik: "Sorumlu Birim", Grup: "Biyomedikal", AltGrup: "Sınıflandırma",
                UrunModu: 2),
            // ENTEGRASYON UCU AYRI KAVRAM (432 `cihaz`): burası fiziksel
            //   varlık, orası HL7/DICOM adresi. Bağ tek yönlü ve isteğe bağlı.
            new("cihazId", "cihaz_id", "sayi",
                Baslik: "Entegrasyon Cihazı", Grup: "Biyomedikal",
                AltGrup: "Sınıflandırma", UrunModu: 2),

            new("kalibrasyonPeriyotAy", "kalibrasyon_periyot_ay", "sayi",
                Baslik: "Kalibrasyon Periyodu (ay)", Grup: "Biyomedikal",
                AltGrup: "Periyot & Geçerlilik", UrunModu: 2),
            new("bakimPeriyotAy", "bakim_periyot_ay", "sayi",
                Baslik: "Bakım Periyodu (ay)", Grup: "Biyomedikal",
                AltGrup: "Periyot & Geçerlilik", UrunModu: 2),
            // SON KALİBRASYON / GEÇERLİLİK / SON BAKIM KAYITTAN TÜRER (723
            //   tetikleri). Elle yazılabilseydi "geçerli" görünen ama
            //   sertifikası olmayan cihaz üretilebilirdi.
            new("sonKalibrasyon", "son_kalibrasyon", "tarih", Yazilabilir: false,
                Baslik: "Son Kalibrasyon", Grup: "Biyomedikal",
                AltGrup: "Periyot & Geçerlilik", UrunModu: 2),
            new("kalibrasyonGecerlilik", "kalibrasyon_gecerlilik", "tarih",
                Yazilabilir: false, Baslik: "Kalibrasyon Geçerliliği",
                Grup: "Biyomedikal", AltGrup: "Periyot & Geçerlilik", UrunModu: 2),
            new("sonBakim", "son_bakim", "tarih", Yazilabilir: false,
                Baslik: "Son Bakım", Grup: "Biyomedikal",
                AltGrup: "Periyot & Geçerlilik", UrunModu: 2),
            new("sonrakiBakim", "sonraki_bakim", "tarih",
                Baslik: "Sonraki Bakım", Grup: "Biyomedikal",
                AltGrup: "Periyot & Geçerlilik", UrunModu: 2),

            // SÖZLEŞME GARANTİDEN AYRI: garanti biter, bakım sözleşmesi devam
            //   eder. İş emri maliyetinin "kapsamda mı" sorusu buradan yanıtlanır.
            new("sozlesmeBitis", "sozlesme_bitis", "tarih",
                Baslik: "Bakım Sözleşmesi Bitiş", Grup: "Biyomedikal",
                AltGrup: "Sözleşme & Ömür", UrunModu: 2),
            new("sozlesmeKapsam", "sozlesme_kapsam", "metin", EnFazlaUzunluk: 200,
                Baslik: "Sözleşme Kapsamı", Grup: "Biyomedikal",
                AltGrup: "Sözleşme & Ömür", UrunModu: 2),
            // YEDEK HAVUZ: "arıza anında yerine ne konacak" sorusunun yanıtı.
            new("yedekHavuz", "yedek_havuz", "mantik",
                Baslik: "Yedek havuzunda", Grup: "Biyomedikal",
                AltGrup: "Sözleşme & Ömür", UrunModu: 2),
            new("ekonomikOmurYil", "ekonomik_omur_yil", "sayi",
                Baslik: "Ekonomik Ömür (yıl)", Grup: "Biyomedikal",
                AltGrup: "Sözleşme & Ömür", UrunModu: 2),
        },
        Detaylar: new DetayTanimi[]
        {
            // BELGE SEKMESİ ERP'DE DE AÇIK: fatura/garanti belgesi hastaneye
            //   özgü değil. Türler ikisini birden kapsıyor.
            new("belgeler", "public.demirbas_belge", "demirbas_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("tur", "tur", "kod", Zorunlu: true, Baslik: "Belge Türü",
                    SabitKodlar: DbBelgeTuruKodlari),
                new("ad", "ad", "metin", Baslik: "Ad", EnFazlaUzunluk: 200),
                new("tarih", "tarih", "tarih", Baslik: "Tarih"),
                // GEÇERLİLİK: sertifika ve ruhsat süreli. Süresi dolmuş belge
                //   "var" sayılırsa denetimde cihaz belgesiz çıkar.
                new("gecerlilik", "gecerlilik", "tarih", Baslik: "Geçerlilik"),
                new("dokumanId", "dokuman_id", "sayi", Baslik: "Doküman"),
                new("aciklama", "aciklama", "metin", Baslik: "Not", EnFazlaUzunluk: 300),
            }, Sirala: "tarih desc nulls last, id", Baslik: "Belgeler",
               SubeKolonu: null, LogTabloId: 1220),
        });


    private static readonly Dictionary<string, string> DbBelgeTuruKodlari = new()
    {
        ["1"] = "Kalibrasyon kaydı", ["2"] = "Referans sertifikası",
        ["3"] = "EST raporu", ["4"] = "Kullanım kılavuzu",
        ["5"] = "Servis el kitabı", ["6"] = "Fatura / satın alma",
        ["7"] = "Servis raporu", ["8"] = "Eğitim kaydı",
        ["9"] = "ÜTS / CE belgesi", ["99"] = "Diğer",
    };
}
