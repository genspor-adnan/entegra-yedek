namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AMELİYATHANE (715) — üç liste:
///   `ameliyat`       günlük plan / ameliyat listesi (salon × saat ekranının verisi)
///   `ameliyatTalep`  bekleyen ameliyat talepleri
///   `ameliyatSalon`  salon tanımları (ayar)
///
/// SÜRELER SQL'DE HESAPLANIR. Plan-gerçek sapması ve cerrahi süre, zaman
/// damgalarından türetilir; istemci hesaplasaydı liste ile kart farklı dakika
/// gösterirdi ve "kaç dakika geciktik" sorusu ekrana göre değişirdi.
///
/// ÖN HAZIRLIK EKSİĞİ METİN OLARAK ÜRETİLİR. Talep listesinde dört ayrı bayrağı
/// dört kolon yapmak satırı okunmaz hale getiriyordu; eksik olanların adı tek
/// hücrede birleştirilir - kullanıcının sorusu "hazır mı" değil, "nesi eksik".
/// </summary>
public static partial class KaynakKatalogu
{
    /// <summary>Ameliyat listesi — günlük plan ve gerçekleşme.</summary>
    private static KaynakTanimi Ameliyat() => new(
        Ad: "ameliyat",
        YetkiKodu: "ameliyathane.plan",
        Kaynak: "public.ameliyat a" +
                " left join public.ameliyat_salon s on s.id = a.salon_id" +
                " left join public.taraf h on h.id = a.hasta_id" +
                " left join public.taraf c on c.id = a.cerrah_id",
        SubeKolonu: "a.sube_id",
        VarsayilanSirala: "a.plan_baslangic, s.sira",
        Kolonlar: new KolonTanimi[]
        {
            new("id",        "a.id",          "sayi",  "Id", Varsayilan: false),
            new("ameliyatNo","a.ameliyat_no", "metin", "Ameliyat No", Genislik: 130),
            new("salonAd",   "coalesce(s.kod || ' · ' || s.ad, '')", "metin", "Salon",
                Genislik: 150, Siralanabilir: false, Filtrelenebilir: false),
            new("salonId",   "a.salon_id",    "sayi",  "Salon Id", Varsayilan: false),
            new("hastaAd",   "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 190,
                Siralanabilir: false, Filtrelenebilir: false),
            new("hastaId",   "a.hasta_id",    "sayi",  "Hasta Id", Varsayilan: false),
            // Ana islem adi: bir ameliyatta birden cok islem olabilir, listede
            //   ANA olan gosterilir - hepsini yazmak satiri tasirdi.
            new("islemAd",
                "coalesce((select hz.ad from public.ameliyat_islem ai" +
                " join public.hizmet hz on hz.id = ai.hizmet_id" +
                " where ai.ameliyat_id = a.id and ai.tur = 1" +
                " order by ai.sira limit 1), '')",
                "metin", "İşlem", Genislik: 300,
                Siralanabilir: false, Filtrelenebilir: false),
            new("tarafAdi",
                "coalesce((select case ai.taraf when 1 then 'Sağ' when 2 then 'Sol'" +
                " when 3 then 'Bilateral' else '' end from public.ameliyat_islem ai" +
                " where ai.ameliyat_id = a.id and ai.tur = 1 order by ai.sira limit 1), '')",
                "metin", "Taraf", Hizalama: "orta", Genislik: 90,
                Siralanabilir: false, Filtrelenebilir: false),
            new("cerrahAd",  "coalesce(c.unvan, '')", "metin", "Cerrah", Genislik: 160,
                Siralanabilir: false, Filtrelenebilir: false),
            new("planBaslangic", "a.plan_baslangic", "zaman", "Plan", Hizalama: "orta",
                Bicim: "dd.MM HH:mm", Genislik: 110),
            new("planSure",  "a.plan_sure_dk", "sayi", "Plan (dk)", Hizalama: "sag",
                Genislik: 85, Varsayilan: false),
            new("kesiZamani","a.kesi_zamani",  "zaman", "Kesi", Hizalama: "orta",
                Bicim: "HH:mm", Genislik: 80),
            // GEÇEN SÜRE: bitmişse kesi→bitiş, sürüyorsa kesi→şimdi. Cerrahi
            //   süreyi ölçer; salona alma-çıkış arası MASA süresidir, başka soru.
            new("cerrahiDk",
                "case when a.kesi_zamani is null then null" +
                " else round(extract(epoch from (coalesce(a.bitis_zamani, now()) - a.kesi_zamani)) / 60) end",
                "sayi", "Cerrahi (dk)", Hizalama: "sag", Genislik: 105,
                Siralanabilir: false, Filtrelenebilir: false),
            // SAPMA plan SAATİNE göre: günü kaydıran şey geç başlamaktır,
            //   uzun sürmek değil.
            new("sapmaDk",
                "case when a.salona_alma is null or a.plan_baslangic is null then null" +
                " else round(extract(epoch from (a.salona_alma - a.plan_baslangic)) / 60) end",
                "sayi", "Sapma (dk)", Hizalama: "sag", Genislik: 100,
                Siralanabilir: false, Filtrelenebilir: false),
            new("durumAdi",
                "case a.durum when 0 then 'Planlandı' when 1 then 'Hazırlık'" +
                " when 2 then 'Sürüyor' when 3 then 'Kapanışta' when 4 then 'Bitti'" +
                " when 8 then 'İptal' else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 110, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum",     "a.durum",       "kod",   "Durum Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AmDurumKodlari),
            new("anesteziAdi",
                "case a.anestezi_tipi when 1 then 'Genel' when 2 then 'Spinal'" +
                " when 3 then 'Epidural' when 4 then 'Bölgesel' when 5 then 'Lokal'" +
                " when 6 then 'Sedasyon' else '' end",
                "metin", "Anestezi", Hizalama: "orta", Genislik: 100,
                Siralanabilir: false, Filtrelenebilir: false),
            new("anesteziTipi", "a.anestezi_tipi", "kod", "Anestezi Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AmAnesteziKodlari),
            new("planDisi",  "a.plan_disi",   "kod",   "Plan Dışı", Hizalama: "orta",
                Genislik: 90, Kodlar: AmEvetHayirKodlari),
            // GÜVENLİ CERRAHİ: kaç zorunlu madde işaretli / kaç madde var.
            //   Sayı olarak verilir ki "3/6" diye gösterilebilsin; tek bayrak
            //   olsaydı hangi aşamada kalındığı görünmezdi.
            new("kontrolTamam",
                "(select count(*) from public.ameliyat_kontrol k" +
                " where k.ameliyat_id = a.id and k.isaretli = 1)",
                "sayi", "Kontrol ✓", Hizalama: "sag", Genislik: 90,
                Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false),
            new("kontrolToplam",
                "(select count(*) from public.ameliyat_kontrol k where k.ameliyat_id = a.id)",
                "sayi", "Kontrol Σ", Hizalama: "sag", Genislik: 90,
                Siralanabilir: false, Filtrelenebilir: false, Varsayilan: false),
            // ÜTS bekleyen implant: ameliyat kapanışının ön koşulu.
            new("utsBekleyen",
                "(select count(*) from public.ameliyat_sarf sf" +
                " where sf.ameliyat_id = a.id and sf.implant = 1 and sf.uts_durum in (1, 3))",
                "sayi", "ÜTS Bekleyen", Hizalama: "sag", Genislik: 110,
                Siralanabilir: false, Filtrelenebilir: false),
            new("gecikmeNeden", "a.gecikme_neden", "metin", "Gecikme Nedeni",
                Genislik: 200, Varsayilan: false),
            new("subeId",    "a.sube_id",     "sayi",  "Şube", Varsayilan: false),
        });

    /// <summary>Bekleyen ameliyat talepleri.</summary>
    private static KaynakTanimi AmeliyatTalep() => new(
        Ad: "ameliyatTalep",
        YetkiKodu: "ameliyathane.talep",
        Kaynak: "public.ameliyat_talep t" +
                " left join public.taraf h on h.id = t.hasta_id" +
                " left join public.taraf i on i.id = t.isteyen_id" +
                " left join public.hizmet hz on hz.id = t.hizmet_id",
        SubeKolonu: "t.sube_id",
        VarsayilanSirala: "t.oncelik desc, t.ekleme_tarihi",
        Kolonlar: new KolonTanimi[]
        {
            new("id",       "t.id",       "sayi",  "Id", Varsayilan: false),
            new("talepNo",  "t.talep_no", "metin", "Talep No", Genislik: 130),
            new("hastaAd",  "coalesce(h.unvan, '')", "metin", "Hasta", Genislik: 190,
                Siralanabilir: false, Filtrelenebilir: false),
            new("hastaId",  "t.hasta_id", "sayi",  "Hasta Id", Varsayilan: false),
            new("islemAd",  "coalesce(hz.ad, '')", "metin", "İşlem", Genislik: 300,
                Siralanabilir: false, Filtrelenebilir: false),
            new("sutKodu",  "coalesce(hz.sut_kodu, '')", "metin", "SUT", Hizalama: "orta",
                Genislik: 90, Siralanabilir: false, Filtrelenebilir: false),
            new("isteyenAd","coalesce(i.unvan, '')", "metin", "İsteyen Hekim", Genislik: 160,
                Siralanabilir: false, Filtrelenebilir: false),
            new("oncelikAdi",
                "case t.oncelik when 1 then 'Normal' when 2 then 'Tarihli'" +
                " when 3 then 'Onkolojik' when 4 then 'Acil' else '' end",
                "metin", "Öncelik", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("oncelik",  "t.oncelik",  "kod",   "Öncelik Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AmOncelikKodlari),
            new("tahminiSure", "t.tahmini_sure_dk", "sayi", "Süre (dk)", Hizalama: "sag",
                Genislik: 90),
            new("anesteziAdi",
                "case t.anestezi_tipi when 1 then 'Genel' when 2 then 'Spinal'" +
                " when 3 then 'Epidural' when 4 then 'Bölgesel' when 5 then 'Lokal'" +
                " when 6 then 'Sedasyon' else '' end",
                "metin", "Anestezi", Hizalama: "orta", Genislik: 100,
                Siralanabilir: false, Filtrelenebilir: false),
            // NESİ EKSİK - bkz sınıf başlığı. Hepsi tamsa boş döner.
            new("eksikler",
                "trim(both ', ' from " +
                " case when t.anestezi_onay = 0 then 'anestezi onayı, ' else '' end ||" +
                " case when t.tetkik_tamam  = 0 then 'tetkik, ' else '' end ||" +
                " case when t.kan_hazir     = 0 then 'kan hazırlığı, ' else '' end ||" +
                " case when t.onam_alindi   = 0 then 'onam, ' else '' end)",
                "metin", "Eksik Hazırlık", Genislik: 220,
                Siralanabilir: false, Filtrelenebilir: false),
            new("hazir",
                "case when t.anestezi_onay = 1 and t.tetkik_tamam = 1" +
                "       and t.kan_hazir = 1 and t.onam_alindi = 1 then 1 else 0 end",
                "kod", "Hazır", Hizalama: "orta", Genislik: 80,
                Siralanabilir: false, Kodlar: AmEvetHayirKodlari),
            new("beklemeGun",
                "greatest(0, (current_date - t.ekleme_tarihi::date))",
                "sayi", "Bekleme (gün)", Hizalama: "sag", Genislik: 110,
                Siralanabilir: false, Filtrelenebilir: false),
            new("istenenTarih", "t.istenen_tarih", "tarih", "İstenen Tarih",
                Hizalama: "orta", Varsayilan: false),
            new("durumAdi",
                "case t.durum when 0 then 'Bekliyor' when 1 then 'Planlandı'" +
                " when 2 then 'Yapıldı' when 8 then 'İptal' when 9 then 'Vazgeçildi'" +
                " else '' end",
                "metin", "Durum", Hizalama: "orta", Genislik: 100, Bicim: "rozet",
                Filtrelenebilir: false),
            new("durum",    "t.durum",    "kod",   "Durum Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AmTalepDurumKodlari),
            new("subeId",   "t.sube_id",  "sayi",  "Şube", Varsayilan: false),
        });

    /// <summary>Salon tanımları (ayar ekranı).</summary>
    private static KaynakTanimi AmeliyatSalon() => new(
        Ad: "ameliyatSalon",
        YetkiKodu: "ameliyathane.salon",
        Kaynak: "public.ameliyat_salon s",
        SubeKolonu: "s.sube_id",
        VarsayilanSirala: "s.sira, s.kod",
        Kolonlar: new KolonTanimi[]
        {
            new("id",      "s.id",      "sayi",  "Id", Varsayilan: false),
            new("kod",     "s.kod",     "metin", "Kod", Genislik: 90),
            new("ad",      "s.ad",      "metin", "Salon", Genislik: 200),
            new("ozellik", "s.ozellik", "metin", "Donanım", Genislik: 260),
            new("acilAyrilmis", "s.acil_ayrilmis", "kod", "Acile Ayrılmış",
                Hizalama: "orta", Genislik: 120, Kodlar: AmEvetHayirKodlari),
            new("sira",    "s.sira",    "sayi",  "Sıra", Hizalama: "sag", Genislik: 70),
            new("aktifAdi","case s.aktif when 1 then 'Aktif' else 'Pasif' end", "metin",
                "Durum", Hizalama: "orta", Genislik: 90, Bicim: "rozet", Filtrelenebilir: false),
            new("aktif",   "s.aktif",   "kod",   "Durum Kodu", Hizalama: "orta",
                Varsayilan: false, Kodlar: AmAktifKodlari),
            new("subeId",  "s.sube_id", "sayi",  "Şube", Varsayilan: false),
        });

    private static readonly Dictionary<string, string> AmDurumKodlari = new()
    {
        ["0"] = "Planlandı", ["1"] = "Hazırlık", ["2"] = "Sürüyor",
        ["3"] = "Kapanışta", ["4"] = "Bitti", ["8"] = "İptal",
    };

    private static readonly Dictionary<string, string> AmAnesteziKodlari = new()
    {
        ["1"] = "Genel", ["2"] = "Spinal", ["3"] = "Epidural",
        ["4"] = "Bölgesel", ["5"] = "Lokal", ["6"] = "Sedasyon",
    };

    private static readonly Dictionary<string, string> AmOncelikKodlari = new()
    {
        ["1"] = "Normal", ["2"] = "Tarihli", ["3"] = "Onkolojik", ["4"] = "Acil",
    };

    private static readonly Dictionary<string, string> AmTalepDurumKodlari = new()
    {
        ["0"] = "Bekliyor", ["1"] = "Planlandı", ["2"] = "Yapıldı",
        ["8"] = "İptal", ["9"] = "Vazgeçildi",
    };

    private static readonly Dictionary<string, string> AmEvetHayirKodlari = new()
    {
        ["1"] = "Evet", ["0"] = "Hayır",
    };

    private static readonly Dictionary<string, string> AmAktifKodlari = new()
    {
        ["1"] = "Aktif", ["0"] = "Pasif",
    };
}
