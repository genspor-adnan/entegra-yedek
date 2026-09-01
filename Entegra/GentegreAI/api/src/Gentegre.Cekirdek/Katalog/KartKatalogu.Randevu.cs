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
            ["tip"] = (short)1,             // Muayene
            ["kaynak"] = (short)1,          // Telefon
        },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",        "sayi",  Yazilabilir: false),
            // KIMLIK SERIDI (Ekranlar/randevu_karti.html): Hasta / Tarih-Saat /
            //   Durum her sekmede sabit ust seritte durur - kart standardi.
            //   Hasta JENERIK ARAMA EKRANINDAN secilir (260), yalniz hastalar.
            new("hastaId",   "hasta_id",  "kod",   Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Kimlik"),
            new("baslangic", "baslangic", "zaman", Zorunlu: true,
                Baslik: "Tarih / Saat", Grup: "Kimlik"),
            new("durum",     "durum",     "kod",   KodListesi: "randevu.durum",
                Baslik: "Durum", Grup: "Kimlik"),

            // RANDEVU kutusu - mockup'taki alan sirasi.
            // KAYNAK ZORUNLULUGU TETIKTE (316): randevu ya HEKIME ya CIHAZA
            //   verilir - alan bayragi ikisini birden zorunlu tutamazdi
            //   (radyolojide hekim yok, poliklinikte cihaz yok). Kural
            //   tg_randevu_cakisma icinde, uc yazma yolunda da gecerli.
            new("bolum",     "bolum",     "kod",
                // Yalniz randevu_verilebilir departmanlar (251) - Muhasebe'ye
                //   randevu verilmez.
                KodTablosu: "public.v_randevu_bolum_lookup",
                Baslik: "Bölüm / Poliklinik", Grup: "Randevu"),
            new("hekimId",   "hekim_id",  "kod",
                // Tum personel DEGIL: yalniz "randevu verilebilir" isaretli
                //   olanlar (252) - muhasebeciye randevu verilmez.
                KodTablosu: "public.v_hekim_lookup", Baslik: "Hekim", Grup: "Randevu"),
            // RADYOLOJI randevusunun kaynagi (316): cihaz doluysa hekim/bolum
            //   bos kalir, takvimde cihaz sutununda cizilir.
            new("cihazId",   "cihaz_id",  "kod",
                KodTablosu: "public.v_radyoloji_cihaz_lookup",
                Baslik: "Cihaz (radyoloji)", Grup: "Randevu"),
            // Hizmet de jenerik stok/hizmet aramasindan, yalniz hizmetler (260).
            new("hizmetId",  "hizmet_id", "kod",
                KodTablosu: "public.v_hizmet_lookup", AramaKaynagi: "hizmet",
                Baslik: "Hizmet / İşlem", Grup: "Randevu"),
            new("sureDk",    "sure_dk",   "sayi",  Zorunlu: true,
                Baslik: "Süre (dk)", Grup: "Randevu"),
            new("tip",       "tip",       "kod",   KodListesi: "randevu.tip",
                Baslik: "Randevu Tipi", Grup: "Randevu"),
            new("kaynak",    "kaynak",    "kod",   KodListesi: "randevu.kaynak",
                Baslik: "Kaynak", Grup: "Randevu"),
            new("aciklama",  "aciklama",  "metin", EnFazlaUzunluk: 300,
                Baslik: "Açıklama", Grup: "Randevu"),

            // Basvuruya donusunce (265) buraya belge id yazilir - kart
            //   ekraninda gorunmez ama yazilabilir olmali.
            new("belgeId",   "belge_id",  "sayi",  Gizli: true),
            new("eklemeTarihi", "ekleme_tarihi", "tarih", Yazilabilir: false),
        });
}
