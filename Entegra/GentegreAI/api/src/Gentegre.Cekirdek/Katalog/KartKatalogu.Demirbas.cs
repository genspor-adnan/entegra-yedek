namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DEMIRBAS karti (216, Ekranlar/demirbas_karti.html).
///
/// Ilk surum mockup'in kimlik + satin alma cekirdegidir; zimmet gecmisi,
/// bakim ve amortisman gridleri ILERIDE (listeTanimlari yer tutucu sekmeler).
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
        });
}
