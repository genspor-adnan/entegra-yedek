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
            left join public.radyoloji_cihaz cz on cz.id = rv.cihaz_id
            left join public.taraf gh on gh.id = rv.gonderen_id
            """,
        SubeKolonu: "rv.sube_id",
        // PORTAL (794): hasta KENDI randevusunu gorur (ve alir). Dis doktor /
        //   dis kurum icin kural YOK - randevu kurumun kendi takvimi, gonderen
        //   taraf onu gormez.
        PortalKosullari: PortalKapsam.Kur(hasta: "rv.hasta_id = {kullanici}"),
        VarsayilanSirala: "rv.baslangic desc, rv.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",         "rv.id",        "sayi",  "Id", Varsayilan: false),
            // BOLUM ve HEKIM en basta (kullanici).
            // Görünen Bölüm / Doktor / Gönderen kolonları AYAR KAPISINDA (1121); id kolonları kapısız -
            //   süzgeçler (takvim, doktor combosu) onlarla çalışır.
            new("bolumAdi", RandevuKatalog.BolumAdi, "metin", "Bölüm", Genislik: 130, AyarKapisi: "randevu.bolum_doktor"),
            new("bolum",      "rv.bolum",     "sayi",  "Bölüm Kodu", Varsayilan: false),
            new("hekim",      "coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')", "metin", "Doktor", Genislik: 160,
                AyarKapisi: "randevu.bolum_doktor"),
            // KAYNAK (316): poliklinikte hekim, radyolojide cihaz. Tek kolonda
            //   birlesik gostermek listeyi okunur tutuyor.
            new("cihaz",      "coalesce(cz.ad, '')", "metin", "Cihaz", Genislik: 160),
            new("cihazId",    "rv.cihaz_id",  "sayi",  "Cihaz Id", Varsayilan: false),
            new("hekimId",    "rv.hekim_id",  "sayi",  "Hekim Id", Varsayilan: false),
            new("hasta",      "coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), '')", "metin", "Hasta", Genislik: 170),
            // GÖNDEREN (dış) HEKİM (1120) - görüntüleme merkezinde hastayı gönderen.
            new("gonderen",   "coalesce(public.fn_taraf_ad(gh.unvan, gh.ad, gh.soyad)::varchar(120), '')", "metin", "Gönderen Doktor", Genislik: 160,
                AyarKapisi: "randevu.gonderen_doktor"),
            new("gonderenId", "rv.gonderen_id", "sayi", "Gönderen Id", Varsayilan: false),
            new("hastaId",    "rv.hasta_id",  "sayi",  "Hasta Id", Varsayilan: false),
            // TELEFON / KİMLİK NO İLE ARAMA (kullanıcı 16.10.2026): hastanın ham telefonu (cep + sabit,
            //   yalnız rakam) ve kimlik nosu - listede gizli, hızlı arama bunlarda da bakar.
            new("telefonHam", TarafKatalog.TelefonHam.Replace("t.", "p."), "metin", "Telefon (ham)", Varsayilan: false),
            new("vknoHam",    "p.vkno",       "metin", "Kimlik No (ham)", Varsayilan: false),
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
            // ERTELEME İZİ (1119): ertelenende "neden → yeni saat", yeni randevuda "← eski saat".
            new("erteleme", RandevuKatalog.Erteleme, "metin", "Erteleme", Genislik: 190),
            new("ertelemeNedeni", "rv.erteleme_nedeni", "metin", "Erteleme Nedeni", Varsayilan: false),
            new("oncekiRandevuId", "rv.onceki_randevu_id", "sayi", "Önceki Randevu Id", Varsayilan: false),
            new("baslangic",  "rv.baslangic", "zaman", "Başlama", Varsayilan: false),
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
            "              when 3 then 'Gelmedi'   when 4 then 'İptal' when 5 then 'Ertelendi' else '' end";

        /// <summary>Erteleme izi (1119): eski satırda neden + yeni saat, yeni satırda eski saat.</summary>
        public const string Erteleme =
            "case when rv.durum = 5 then rv.erteleme_nedeni || coalesce(' → ' || (select to_char(y.baslangic, 'DD.MM.YYYY HH24:MI') " +
            "          from public.randevu y where y.onceki_randevu_id = rv.id order by y.id desc limit 1), '') " +
            "     when rv.onceki_randevu_id is not null then '← ' || coalesce((select to_char(o.baslangic, 'DD.MM.YYYY HH24:MI') " +
            "          from public.randevu o where o.id = rv.onceki_randevu_id), '') " +
            "     else '' end";
    }
}
