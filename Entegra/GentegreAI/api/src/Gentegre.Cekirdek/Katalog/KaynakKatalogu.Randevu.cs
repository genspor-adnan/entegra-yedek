namespace Gentegre.Cekirdek.Katalog;

public static partial class KaynakKatalogu
{
    // --------------------------------------------------------------- randevu ----
    // Kullanici: "hasta menusu altina Randevu liste ve karti ekle... bolum ve
    //   kime (yani hekim) gridde BASTA olsun". Kolon sirasi bu istege gore:
    //   Bölüm | Hekim | Hasta | Tarih | Saat | ...
    private static KaynakTanimi Randevu() => new(
        Ad: "randevu",
        YetkiKodu: "randevu",
        Kaynak: """
            public.randevu rv
            left join public.taraf h  on h.id = rv.hekim_id
            left join public.taraf p  on p.id = rv.hasta_id
            left join public.belge b  on b.id = rv.belge_id
            left join public.hizmet hz on hz.id = rv.hizmet_id
            """,
        SubeKolonu: "rv.sube_id",
        VarsayilanSirala: "rv.baslangic desc, rv.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "rv.id",        "sayi",  "Id", Varsayilan: false),
            // BOLUM ve HEKIM en basta (kullanici).
            new("bolumAdi", RandevuKatalog.BolumAdi, "metin", "Bölüm", Genislik: 130),
            new("bolum",      "rv.bolum",     "sayi",  "Bölüm Kodu", Varsayilan: false),
            new("hekim",      "coalesce(h.unvan, '')", "metin", "Hekim", Genislik: 160),
            new("hekimId",    "rv.hekim_id",  "sayi",  "Hekim Id", Varsayilan: false),
            new("hasta",      "coalesce(p.unvan, '')", "metin", "Hasta", Genislik: 170),
            new("hastaId",    "rv.hasta_id",  "sayi",  "Hasta Id", Varsayilan: false),
            new("tarih",      "rv.baslangic::date", "tarih", "Tarih", Hizalama: "orta"),
            new("saat",       "to_char(rv.baslangic, 'HH24:MI')", "metin", "Saat",
                Hizalama: "orta", Genislik: 70),
            new("bitis",
                "to_char(rv.baslangic + (rv.sure_dk || ' minutes')::interval, 'HH24:MI')",
                                            "metin", "Bitiş", Hizalama: "orta", Genislik: 70),
            new("sureDk",     "rv.sure_dk",   "sayi",  "Süre (dk)", Hizalama: "sag"),
            // Durum SURENIN SAGINDA (kullanici): randevunun akibeti saat/sure
            //   bilgisinin hemen yaninda okunsun.
            new("durumAdi", RandevuKatalog.DurumAdi, "metin", "Durum", Hizalama: "orta",
                Bicim: "rozet"),
            new("durum",      "rv.durum",     "sayi",  "Durum Kodu", Varsayilan: false),
            new("baslangic",  "rv.baslangic", "zaman", "Başlangıç", Varsayilan: false),
            new("hizmet",     "coalesce(hz.ad, '')", "metin", "Hizmet", Genislik: 180),
            new("hizmetId",   "rv.hizmet_id", "sayi", "Hizmet Id", Varsayilan: false),
            new("tipAdi", RandevuKatalog.TipAdi, "metin", "Tip", Hizalama: "orta",
                Varsayilan: false),
            new("kaynakAdi", RandevuKatalog.KaynakAdi, "metin", "Kaynak", Hizalama: "orta",
                Varsayilan: false),
            new("aciklama",   "rv.aciklama",  "metin", "Açıklama", Genislik: 220),
            new("belgeNo",    "coalesce(b.belge_no, '')", "metin", "Başvuru", Varsayilan: false),
            new("subeId",     "rv.sube_id",   "sayi",  "Şube", Varsayilan: false),
        });

    /// <summary>Randevu listesinde tekrar eden kod çözümleri.</summary>
    internal static class RandevuKatalog
    {
        public const string BolumAdi =
            "coalesce((select dp.ad from public.departman dp where dp.id = rv.bolum), '')";

        /// <summary>Tip/kaynak kod listeleri (261) - ad cozumu tek yerde.</summary>
        public const string TipAdi =
            "coalesce((select d.ad from public.kod_deger d " +
            "           join public.kod_liste l on l.id = d.liste_id " +
            "          where l.kod = 'randevu.tip' and d.deger = rv.tip), '')";

        public const string KaynakAdi =
            "coalesce((select d.ad from public.kod_deger d " +
            "           join public.kod_liste l on l.id = d.liste_id " +
            "          where l.kod = 'randevu.kaynak' and d.deger = rv.kaynak), '')";

        public const string DurumAdi =
            "case rv.durum when 1 then 'Planlandı' when 2 then 'Geldi' " +
            "              when 3 then 'Gelmedi'   when 4 then 'İptal' else '' end";
    }
}
