namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// GÖZ MODÜLÜNÜN İKİNCİL KARTLARI (691/693): kontakt lens reçetesi ve işlem
/// takip protokolü.
///
/// <para>Cihaz mesaj kuyruğunun KARTI YOK: satır cihazdan gelen ham bir
/// kayıttır, elle düzenlenecek bir veri değil. Eşleşmeyen mesaj karttan
/// "düzeltilseydi", başkasının ölçümü eliyle bir hastanın dosyasına
/// yazılabilirdi — sahiplendirme ayrı bir aksiyon olmalı.</para>
/// </summary>
public static partial class KartKatalogu
{
    // 1304/1305 (757): 1108 goz cizimi, 1109 dikte sozlugu (Goz.cs) -
    //   iki dosya ayni iki numarayi paylasiyordu.
    private const int LogGozKontaktLens = 1304;
    private const int LogGozProtokol    = 1305;

    // ------------------------------------------------------- kontakt lens ----
    private static KartTanimi GozKontaktLensKarti() => new(
        Ad: "goz-kontakt-lens",
        YetkiKodu: "goz.recete",
        Tablo: "public.goz_kontakt_lens",
        LogTabloId: LogGozKontaktLens,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["goz"] = (short)1,     // OD
            ["deneme"] = (short)1,  // ilk kayıt genellikle denemedir
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Genel"),
            new("goz", "goz", "kod", Zorunlu: true, SabitKodlar: GozTarafKodlari,
                Baslik: "Göz", Grup: "Genel"),
            new("lensTur", "lens_tur", "kod", KodListesi: "goz.lens_tur",
                Baslik: "Lens Türü", Grup: "Genel"),
            new("markaModel", "marka_model", "metin", EnFazlaUzunluk: 80,
                Baslik: "Marka / Model", Grup: "Genel"),
            // DENEME kaydı reçete DEĞİLDİR: denenen lens hastaya verilmez,
            //   sonucu bir sonraki denemeyi belirler. İkisini ayırmayan bir
            //   kayıt, "hangisi verildi" sorusunu cevapsız bırakır.
            new("deneme", "deneme", "mantik", Baslik: "Deneme lensi", Grup: "Genel"),
            new("durum", "durum", "kod", KodListesi: "goz.recete_durum",
                Baslik: "Durum", Grup: "Genel"),

            new("sph", "sph", "ondalik", Baslik: "Sph", Grup: "Lens Değerleri"),
            new("cyl", "cyl", "ondalik", Baslik: "Cyl", Grup: "Lens Değerleri"),
            new("aks", "aks", "sayi", Baslik: "Aks", Grup: "Lens Değerleri"),
            new("addYakin", "add_yakin", "ondalik", Baslik: "Add", Grup: "Lens Değerleri"),
            // BC / DIA lensin GEOMETRİSİDİR ve gözlükte karşılığı yoktur:
            //   oturuşu belirleyen asıl iki ölçü bunlar.
            new("bc", "bc", "ondalik", Baslik: "BC (eğrilik)", Grup: "Lens Değerleri"),
            new("dia", "dia", "ondalik", Baslik: "DIA (çap)", Grup: "Lens Değerleri"),
            new("va", "va", "ondalik", Baslik: "Bu lensle VA", Grup: "Lens Değerleri"),

            new("oturus", "oturus", "metin", EnFazlaUzunluk: 600,
                Baslik: "Oturuş Değerlendirmesi", Grup: "Kullanım"),
            new("kullanimSaat", "kullanim_saat", "sayi",
                Baslik: "Günlük Kullanım (saat)", Grup: "Kullanım"),
            new("bakimNotu", "bakim_notu", "metin", EnFazlaUzunluk: 600,
                Baslik: "Bakım / Hasta Bilgilendirmesi", Grup: "Kullanım"),
        });

    // --------------------------------------------------- işlem protokolleri ----
    private static KartTanimi GozIslemProtokolKarti() => new(
        Ad: "goz-islem-protokol",
        YetkiKodu: "goz.islem",
        Tablo: "public.goz_islem_protokol",
        LogTabloId: LogGozProtokol,
        SubeKolonu: null,                 // protokol kurum genelidir, şubeye bağlı değil
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1,
            ["kontroller"] = "[]",
            ["ilaclar"] = "[]",
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 120,
                Baslik: "Protokol Adı", Grup: "Genel"),
            new("islemTur", "islem_tur", "kod", KodListesi: "goz.islem_tur",
                Baslik: "İşlem Türü", Grup: "Genel"),
            // Ameliyat ve lazer türü İSTEĞE BAĞLI daraltmadır: "fako sonrası"
            //   protokolü yalnız fakoya, "SLT sonrası" yalnız SLT'ye önerilir.
            //   Boş bırakılırsa işlem türünün tamamına uygulanır.
            new("ameliyatTur", "ameliyat_tur", "kod", KodListesi: "goz.ameliyat_tur",
                Baslik: "Ameliyat Türü", Grup: "Genel"),
            new("lazerTur", "lazer_tur", "kod", KodListesi: "goz.lazer_tur",
                Baslik: "Lazer Türü", Grup: "Genel"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Genel"),

            // KONTROL PLANI JSON: [{"gun":1,"icerik":"VA, GİB, ön kamara"}, …]
            //   Detay tablosu yapmadık çünkü plan bir ŞABLONDUR - satır satır
            //   düzenlenen bir kayıt değil, kopyalanan bir metin. Postop
            //   randevular bundan üretilir.
            new("kontroller", "kontroller", "json", EnFazlaUzunluk: 4000,
                Baslik: "Kontrol Planı (JSON)", Grup: "Plan"),
            new("ilaclar", "ilaclar", "json", EnFazlaUzunluk: 4000,
                Baslik: "Damla Şeması (JSON)", Grup: "Plan"),
        });
}
