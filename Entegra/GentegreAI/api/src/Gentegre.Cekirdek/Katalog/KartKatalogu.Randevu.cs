namespace Gentegre.Cekirdek.Katalog;

public static partial class KartKatalogu
{
    /// <summary>
    /// RANDEVU KARTI (243). Bitiş saati alan DEĞİL: süreden hesaplanır, listede
    /// gösterilir. Hekim ve hasta lookup görünümlerinden gelir (v_personel_lookup /
    /// v_hasta_lookup) - randevu için ayrı "hekim" tablosu açılmadı, aynı kişi
    /// hem personel hem hekim olabilir.
    /// </summary>
    private static KartTanimi Randevu() => new(
        Ad: "randevu",
        YetkiKodu: "randevu",
        Tablo: "public.randevu",
        LogTabloId: 905,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,          // Planlandı
            ["sureDk"] = (short)15,
            ["baslangic"] = "@simdi",
        },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",        "sayi",  Yazilabilir: false),
            // Bölüm ve hekim kartın da BAŞINDA (listeyle aynı sıra).
            new("bolum",     "bolum",     "kod",   Zorunlu: true,
                // Yalniz randevu_verilebilir departmanlar (251) - Muhasebe'ye
                //   randevu verilmez.
                KodTablosu: "public.v_randevu_bolum_lookup", Baslik: "Bölüm", Grup: "Kimlik"),
            new("hekimId",   "hekim_id",  "kod",   Zorunlu: true,
                KodTablosu: "public.v_personel_lookup", Baslik: "Hekim", Grup: "Kimlik"),
            new("hastaId",   "hasta_id",  "kod",   Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", Baslik: "Hasta", Grup: "Kimlik"),
            new("baslangic", "baslangic", "zaman", Zorunlu: true,
                Baslik: "Başlangıç", Grup: "Kimlik"),
            new("sureDk",    "sure_dk",   "sayi",  Zorunlu: true,
                Baslik: "Süre (dk)", Grup: "Kimlik"),
            new("durum",     "durum",     "kod",   KodListesi: "randevu.durum",
                Baslik: "Durum", Grup: "Kimlik"),
            new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Genel"),
            new("belgeId",   "belge_id",  "sayi",  Yazilabilir: false, Gizli: true),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false),
        });
}
