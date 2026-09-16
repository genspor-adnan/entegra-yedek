using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// AMELİYATHANE İŞ AKIŞI UÇLARI (715 tabloları, 719 kuralları).
///
/// Kart ve liste kayıt okuyup yazar; BURADAKİ uçlar zamanı ve durumu
/// ilerletir. Ayrı olmalarının sebebi, her birinin kayıt yazmaktan fazlasını
/// yapması: plan salon çakışmasına bakar ve kontrol listesini kopyalar, kesi
/// time-out'u arar, iptal talebi bekleyene geri döndürür.
///
/// ZAMAN DAMGASI SESSİZCE ÜZERİNE YAZILMAZ. Bir kez yazılan damga `duzelt`
/// bayrağı olmadan değişmez ve düzeltme işlem günlüğüne düşer: masa süresi
/// hem kalite göstergesi hem faturalama girdisidir, "yanlış tıkladım"
/// düzeltmesiyle geriye dönük değişmesi fark edilmeden olmamalı.
///
/// KONTROL LİSTESİ AMELİYAT AÇILIRKEN KOPYALANIR, okurken değil: madde tanımı
/// sonradan değişse de o ameliyatta neyin sorulduğu sabit kalır (715).
/// </summary>
public static partial class AmeliyathaneUclari
{
    /// <summary>islem_log.tablo_id - KartKatalogu.Ameliyathane ile aynı.</summary>
    private const int LogTabloAmeliyat = 1150;
    private const int LogTabloTalep = 1158;

    /// <summary>ameliyat.durum - 0 planlandı · 1 hazırlık · 2 sürüyor · 3 kapanışta · 4 bitti · 8 iptal.</summary>
    private const short DurumPlanlandi = 0;
    private const short DurumHazirlik = 1;
    private const short DurumSuruyor = 2;
    private const short DurumKapanista = 3;
    private const short DurumBitti = 4;
    private const short DurumIptal = 8;

    public sealed class PlanlamaIstegi
    {
        public int SalonId { get; set; }
        public DateTime PlanBaslangic { get; set; }
        public short PlanSureDk { get; set; }
        public int? CerrahId { get; set; }
        public int? AnesteziId { get; set; }
        public short? AnesteziTipi { get; set; }
        /// <summary>Plan dışı (acil eklenen) vaka - masa kullanımı raporunda ayrı sayılır.</summary>
        public short? PlanDisi { get; set; }
        /// <summary>Ön hazırlık eksik olsa da planla (acil). Gerekçe günlüğe yazılır.</summary>
        public bool EksigeRagmen { get; set; }
        /// <summary>Salonda çakışma olsa da planla. Gerekçe günlüğe yazılır.</summary>
        public bool CakismayaRagmen { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class AdimIstegi
    {
        /// <summary>salona-alma · anestezi · kesi · kapanis · bitis · cikis</summary>
        public string Adim { get; set; } = "";
        /// <summary>Boşsa şimdi. Geç girişte gerçek saat yazılabilsin diye var.</summary>
        public DateTime? Zaman { get; set; }
        /// <summary>Yazılmış damgayı DÜZELT (günlüğe düşer).</summary>
        public bool Duzelt { get; set; }
        /// <summary>Time-out tamamlanmadan kesi (acil). Gerekçe zorunlu.</summary>
        public bool Zorla { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class KontrolYaniti
    {
        public long? Id { get; set; }
        public short Asama { get; set; }
        public short Sira { get; set; }
        public short Isaretli { get; set; }
        public string? NotMetni { get; set; }
    }

    public sealed class KontrolIstegi2
    {
        public IReadOnlyList<KontrolYaniti>? Yanitlar { get; set; }
    }

    public sealed class IptalIstegi
    {
        public string Neden { get; set; } = "";
        /// <summary>Talep bekleyene geri dönsün mü (varsayılan evet).</summary>
        public bool TalebiGeriAl { get; set; } = true;
    }

    public static void AmeliyathaneUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ameliyathane").WithTags("Ameliyathane")
                      .RequireAuthorization();

        TalepUclari(grup);
        AmeliyatUclari(grup);
        KontrolUclari(grup);
        CizelgeUclari(grup);
        FaturaUclari(grup);
    }

    // ====================================================== oda x saat ==
    private static void CizelgeUclari(RouteGroupBuilder grup)
    {
        // GÜNLÜK MASA ÇİZELGESİ (mockup ameliyat_plani.html "Masa Çizelgesi").
        //
        // GENERIC LİSTE BUNU ÇİZEMEZ: satır başına bir kayıt çizer, oysa buradaki
        //   soru "hangi masa ne zaman boş". Aynı veri liste ekranında da var;
        //   burada SALON × ZAMAN olarak yerleşiyor.
        //
        // BLOK GERÇEK SAATTE DURUR, PLANDA DEĞİL. Başlamış vaka `salona_alma` -
        //   `salondan_cikis` (bitmediyse şimdi) aralığını kaplar; başlamamış vaka
        //   planını. Hep planı çizseydik çizelge, ameliyathanenin o anki hâlini
        //   değil sabah verilen sözü gösterirdi - geciken vakanın bir sonraki
        //   vakayı ittiğini göremezdik.
        //
        // GÜN PENCERESİ VERİDEN TÜRER (en erken başlangıç - en geç bitiş), en az
        //   08-18. Sabit 08-18 olsaydı gece devam eden acil vaka çizelgeden
        //   taşardı; tamamen veriden türeseydi boş günde pencere hiç olmazdı.
        grup.MapGet("/cizelge", async (
            DateTime? gun, string? salonId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ameliyathane.plan", Islem.Gor);

            // SALON SUZGECI METIN OLARAK ALINIR: "salonId=" (bos) gonderen bir
            //   istemci `int?` baglamasini 400 ile dusuruyordu - bos deger
            //   "suzgec yok" demektir, hata degil.
            int? salon = int.TryParse(salonId, out var sid) && sid > 0 ? sid : null;

            var g = (gun ?? DateTime.Today).Date;
            var subeId = baglam.SubeId ?? 0;

            await using var baglanti = await veri.AcAsync(iptal);

            var salonlar = await baglanti.ListeAsync(SalonSql, null,
                [subeId, salon], OkuyucuGenisletmeleri.Sozluk, iptal);

            var ameliyatlar = await baglanti.ListeAsync(CizelgeSql, null,
                [subeId, salon, g], OkuyucuGenisletmeleri.Sozluk, iptal);

            // BEKLEYEN TALEP çizelgenin dışında ama başlığında: "masa boş ama
            //   sırada 11 kişi var" ikisi yan yana görülmeden anlaşılmıyor.
            var bekleyenTalep = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.ameliyat_talep t "
                + "where t.durum = 0 and (@p0 = 0 or t.sube_id = @p0)",
                null, [subeId], iptal);

            // --- GÜN PENCERESİ ve MASA KULLANIMI (bkz başlık).
            var bas = new DateTime(g.Year, g.Month, g.Day, 8, 0, 0);
            var son = new DateTime(g.Year, g.Month, g.Day, 18, 0, 0);
            var dolu = 0d;
            foreach (var a in ameliyatlar)
            {
                if (Convert.ToInt16(a["durum"] ?? (short)0) == DurumIptal) continue;
                if (a["bas"] is not DateTime hamB || a["bit"] is not DateTime hamT) continue;

                // YEREL SAATE CEVRILIR. Kolonlar timestamptz (UTC doner), pencere
                //   ise duvar saati (08-18). Karsilastirmayi cevirmeden yapsaydik
                //   gece yarisina sarkan vaka pencereyi uzatmaz ve ekranda
                //   kirpilirdi - UTC+3'te ogleden sonraki her vaka icin gecerli
                //   bir hata olurdu.
                var b = hamB.Kind == DateTimeKind.Utc ? hamB.ToLocalTime() : hamB;
                var t = hamT.Kind == DateTimeKind.Utc ? hamT.ToLocalTime() : hamT;

                if (b < bas) bas = new DateTime(b.Year, b.Month, b.Day, b.Hour, 0, 0);
                if (t > son) son = new DateTime(t.Year, t.Month, t.Day, t.Hour, 0, 0).AddHours(1);
                dolu += (t - b).TotalMinutes;
            }

            var pencereDk = (son - bas).TotalMinutes;
            var kapasite = pencereDk * Math.Max(salonlar.Count, 1);

            return Results.Ok(new
            {
                gun = g,
                saatBas = bas,
                saatSon = son,
                salonlar,
                ameliyatlar,
                ozet = new
                {
                    planlanan = ameliyatlar.Count(a => Convert.ToInt16(a["durum"] ?? (short)0) != DurumIptal),
                    tamamlanan = ameliyatlar.Count(a => Convert.ToInt16(a["durum"] ?? (short)0) == DurumBitti),
                    suren = ameliyatlar.Count(a =>
                    {
                        var d = Convert.ToInt16(a["durum"] ?? (short)0);
                        return d is DurumHazirlik or DurumSuruyor or DurumKapanista;
                    }),
                    // GECİKMELİ = 15 dakikadan fazla geç başlamış. Sıfırdan büyük
                    //   her sapmayı saysaydık, iki dakikalık olağan oynama günlük
                    //   raporu "hep gecikmeli" gösterirdi.
                    gecikmeli = ameliyatlar.Count(a => a["gecikmeDk"] is int gd && gd > 15),
                    iptal = ameliyatlar.Count(a => Convert.ToInt16(a["durum"] ?? (short)0) == DurumIptal),
                    planDisi = ameliyatlar.Count(a => Convert.ToInt16(a["planDisi"] ?? (short)0) == 1),
                    bekleyenTalep,
                    kullanimYuzde = kapasite > 0 ? (int)Math.Round(dolu / kapasite * 100) : 0
                },
                izlemeNo = baglam.IzlemeNo
            });
        });
    }

    private const string SalonSql = @"
        select s.id, s.kod, s.ad, s.ozellik,
               s.acil_ayrilmis as ""acilAyrilmis"",
               coalesce(d.ad, '') as ""departmanAd""
          from public.ameliyat_salon s
          left join public.departman d on d.id = s.departman_id
         where s.aktif = 1
           and (@p0 = 0 or s.sube_id = @p0 or s.sube_id = 0)
           and (@p1::int is null or s.id = @p1::int)
         order by s.sira, s.kod";

    /// <summary>
    /// GÜNÜN VAKALARI: planı bugüne düşenler VE bugün salona alınanlar. Yalnız
    /// plana baksaydık plansız (acil eklenen) vaka çizelgede hiç görünmezdi -
    /// oysa masayı çoğu zaman en çok o işgal ediyor.
    /// </summary>
    private const string CizelgeSql = @"
        select a.id, a.ameliyat_no as ""ameliyatNo"", a.salon_id as ""salonId"",
               a.durum, a.plan_disi as ""planDisi"",
               a.plan_baslangic as ""planBaslangic"", a.plan_sure_dk as ""planSureDk"",
               a.salona_alma as ""salonaAlma"", a.kesi_zamani as ""kesiZamani"",
               a.bitis_zamani as ""bitisZamani"", a.salondan_cikis as ""salondanCikis"",
               coalesce(h.unvan, '') as ""hastaAd"",
               coalesce(c.unvan, '') as ""cerrahAd"",
               coalesce(a.iptal_neden, '') as ""iptalNeden"",
               coalesce(a.gecikme_neden, '') as ""gecikmeNeden"",
               coalesce(a.salona_alma, a.plan_baslangic) as bas,
               coalesce(a.salondan_cikis, a.bitis_zamani,
                        case when a.durum between 1 and 3 then now() end,
                        coalesce(a.salona_alma, a.plan_baslangic)
                          + (coalesce(nullif(a.plan_sure_dk, 0), 60) || ' minutes')::interval
               ) as bit,
               case when a.salona_alma is null or a.plan_baslangic is null then null
                    else round(extract(epoch from
                         (a.salona_alma - a.plan_baslangic)) / 60)::int end as ""gecikmeDk"",
               (select string_agg(coalesce(hz.ad, i.aciklama), ' + ' order by i.sira, i.id)
                  from public.ameliyat_islem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                 where i.ameliyat_id = a.id) as ""islemAd"",
               (select count(*) from public.ameliyat_kontrol k
                 join public.ameliyat_kontrol_madde m on m.id = k.madde_id
                where k.ameliyat_id = a.id and k.asama = 2
                  and m.zorunlu = 1 and k.isaretli = 0) as ""timeoutEksik""
          from public.ameliyat a
          left join public.taraf h on h.id = a.hasta_id
          left join public.taraf c on c.id = a.cerrah_id
         where (@p0 = 0 or a.sube_id = @p0)
           and (@p1::int is null or a.salon_id = @p1::int)
           and (a.plan_baslangic::date = @p2 or a.salona_alma::date = @p2)
         order by a.salon_id, coalesce(a.salona_alma, a.plan_baslangic)";

    // ====================================================== talep -> plan ==
    private static void TalepUclari(RouteGroupBuilder grup)
    {
        // --------------------------------------------------- talebi planla ----
        // Talep AMELİYATA DÖNÜŞMEZ, ameliyat DOĞURUR: talep bekleme listesinin
        //   kaydıdır (ne zaman istendi, ne kadar bekledi) ve ameliyat iptal
        //   olursa geri dönecek yer odur. Tek satır olsaydı iptalde ya bekleme
        //   geçmişi ya iptal kaydı kaybolurdu.
        grup.MapPost("/talep/{id:long}/planla", async (
            long id, PlanlamaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ameliyathane.plan", Islem.Ekle);

            if (istek.SalonId <= 0)
                throw GentegreHatasi.Dogrulama("Salon seçilmedi.",
                    new AlanHatasi("salonId", "Salon seçilmedi."));
            if (istek.PlanBaslangic == default)
                throw GentegreHatasi.Dogrulama("Planlanan saat girilmedi.",
                    new AlanHatasi("planBaslangic", "Planlanan saat girilmedi."));

            await using var baglanti = await veri.AcAsync(iptal);

            var talep = await baglanti.TekAsync("""
                select t.id, t.sube_id as "subeId", t.hasta_id as "hastaId",
                       t.hizmet_id as "hizmetId", t.taraf, t.durum,
                       t.isteyen_id as "isteyenId", t.anestezi_tipi as "anesteziTipi",
                       t.tahmini_sure_dk as "tahminiSureDk", t.aciklama,
                       t.anestezi_onay as "anesteziOnay", t.tetkik_tamam as "tetkikTamam",
                       t.kan_hazir as "kanHazir", t.onam_alindi as "onamAlindi"
                  from public.ameliyat_talep t where t.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat talebi bulunamadı.");

            // Planlanmış talebi ikinci kez planlamak aynı hastayı iki masaya
            //   yazar; durum 0 (bekleyen) dışındaki talep açıkça reddedilir.
            var talepDurum = Convert.ToInt16(talep["durum"] ?? (short)0);
            if (talepDurum != 0)
                throw GentegreHatasi.IsKurali(
                    "Bu talep zaten planlanmış ya da kapanmış; bekleyen talep değil.");

            // --- ÖN HAZIRLIK. Eksik talep planlanabilir ama SESSİZCE değil:
            //     masaya alınıp orada iptal edilmek en pahalı hatadır.
            var eksikler = new List<string>();
            if (Convert.ToInt16(talep["anesteziOnay"] ?? (short)0) == 0) eksikler.Add("anestezi onayı");
            if (Convert.ToInt16(talep["tetkikTamam"] ?? (short)0) == 0) eksikler.Add("tetkikler");
            if (Convert.ToInt16(talep["kanHazir"] ?? (short)0) == 0) eksikler.Add("kan hazırlığı");
            if (Convert.ToInt16(talep["onamAlindi"] ?? (short)0) == 0) eksikler.Add("onam");

            if (eksikler.Count > 0 && !istek.EksigeRagmen)
                throw GentegreHatasi.IsKurali(
                    "Ön hazırlık tamamlanmadan planlanamaz - eksik: "
                    + string.Join(", ", eksikler) + ".",
                    new { eksikler });

            var sure = istek.PlanSureDk > 0 ? istek.PlanSureDk
                     : Convert.ToInt16(talep["tahminiSureDk"] ?? (short)0);

            // --- SALON ÇAKIŞMASI. 719'daki tek fonksiyon; engellemiyoruz
            //     (acil vaka planlının üstüne alınır ve bu meşru), soruyoruz.
            var cakisanlar = await baglanti.ListeAsync("""
                select c.id, c.ameliyat_no as "ameliyatNo", c.plan_baslangic as "planBaslangic",
                       c.bitis, c.hasta_ad as "hastaAd"
                  from public.fn_ameliyat_salon_cakisma(@p0, @p1, @p2, null) c
                """, null, [istek.SalonId, istek.PlanBaslangic, (int)sure],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            if (cakisanlar.Count > 0 && !istek.CakismayaRagmen)
                throw GentegreHatasi.IsKurali(
                    $"Bu salonda aynı saatte {cakisanlar.Count} ameliyat var.",
                    new { cakisanlar });

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var subeId = baglam.SubeId ?? Convert.ToInt32(talep["subeId"] ?? 0);

            // AMELİYAT NO BURADA ÜRETİLMEZ: 719'daki tetik yazar. Ameliyat iki
            //   yoldan doğuyor (buradan ve doğrudan karttan); numarayı uca
            //   koysaydık karttan açılan kayıt numarasız kalırdı.
            var ameliyatId = await baglanti.TekDegerAsync<long>("""
                insert into public.ameliyat
                    (sube_id, talep_id, hasta_id, salon_id,
                     cerrah_id, anestezi_id, anestezi_tipi,
                     plan_baslangic, plan_sure_dk, durum, plan_disi, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, 0, @p9, @p10)
                returning id
                """, islem,
                [subeId, id, talep["hastaId"], istek.SalonId,
                 istek.CerrahId ?? talep["isteyenId"], istek.AnesteziId,
                 istek.AnesteziTipi ?? Convert.ToInt16(talep["anesteziTipi"] ?? (short)0),
                 istek.PlanBaslangic, sure, istek.PlanDisi ?? 0,
                 baglam.KullaniciId], iptal);

            // PLANLANAN İŞLEM AMELİYATA TAŞINIR: talebin hizmeti ana işlem
            //   satırı olur. Boş bırakılsaydı kullanıcı aynı bilgiyi ikinci kez
            //   girer, taraf (sağ/sol) yeniden seçilirken de hata olasılığı doğardı.
            if (talep["hizmetId"] is not null)
                await baglanti.CalistirAsync("""
                    insert into public.ameliyat_islem
                        (ameliyat_id, hizmet_id, sira, tur, taraf, cerrah_id, aciklama)
                    values (@p0, @p1, 1, 1, @p2, @p3, @p4)
                    """, islem,
                    [ameliyatId, talep["hizmetId"], talep["taraf"] ?? (short)0,
                     istek.CerrahId ?? talep["isteyenId"], talep["aciklama"] ?? ""], iptal);

            await KontrolListesiKopyalaAsync(baglanti, islem, ameliyatId, iptal);

            await baglanti.CalistirAsync("""
                update public.ameliyat_talep
                   set durum = 1, degistiren = @p1, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloAmeliyat,
                ameliyatId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    kaynak = "talep", talepId = id, salonId = istek.SalonId,
                    // Zorlamalar GÜNLÜĞE yazılır: "neden eksik hazırlıkla
                    //   masaya alındı" sorusunun yanıtı sonradan aranır.
                    eksikler = eksikler.Count > 0 ? eksikler : null,
                    cakisan = cakisanlar.Count > 0 ? cakisanlar.Count : (int?)null,
                    gerekce = istek.Gerekce
                }, iptal: iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloTalep, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = 1, ameliyatId }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var no = await baglanti.TekDegerAsync<string>(
                "select ameliyat_no from public.ameliyat where id = @p0",
                null, [ameliyatId], iptal) ?? "";

            return Results.Ok(new
            {
                ameliyatId, ameliyatNo = no,
                eksikler, cakisan = cakisanlar.Count, izlemeNo = baglam.IzlemeNo
            });
        });
    }

    // =========================================================== ameliyat ==
    private static void AmeliyatUclari(RouteGroupBuilder grup)
    {
        // ----------------------------------------------------- akış şeridi ----
        // Kart başlığındaki şerit (mockup ameliyat_karti.html): damgalar,
        //   kontrol listesi ilerlemesi, sayım uyumu ve ÜTS bekleyen implant.
        //   Tek istek, çünkü bunlar birlikte okunmadıkça "başlatılabilir mi"
        //   sorusu yanıtlanamıyor.
        grup.MapGet("/ameliyat/{id:long}/akis", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ameliyathane.ameliyat", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var akis = await baglanti.TekAsync("""
                select a.id, a.ameliyat_no as "ameliyatNo", a.durum,
                       a.plan_baslangic as "planBaslangic", a.plan_sure_dk as "planSureDk",
                       a.salona_alma as "salonaAlma", a.anestezi_bas as "anesteziBas",
                       a.kesi_zamani as "kesiZamani", a.kapanis_bas as "kapanisBas",
                       a.bitis_zamani as "bitisZamani", a.salondan_cikis as "salondanCikis",
                       a.plan_disi as "planDisi", a.iptal_neden as "iptalNeden",
                       coalesce(s.kod || ' · ' || s.ad, '') as salon,
                       coalesce(h.unvan, '') as "hastaAd",
                       coalesce(c.unvan, '') as "cerrahAd",
                       -- Cerrahi süre KESİDEN bitişe; masa süresiyle karıştırılmasın.
                       case when a.kesi_zamani is null then null
                            else round(extract(epoch from
                                 (coalesce(a.bitis_zamani, now()) - a.kesi_zamani)) / 60)::int
                       end as "cerrahiDk",
                       case when a.salona_alma is null or a.plan_baslangic is null then null
                            else round(extract(epoch from
                                 (a.salona_alma - a.plan_baslangic)) / 60)::int
                       end as "sapmaDk",
                       (select count(*) from public.ameliyat_kontrol k
                         where k.ameliyat_id = a.id) as "kontrolToplam",
                       (select count(*) from public.ameliyat_kontrol k
                         where k.ameliyat_id = a.id and k.isaretli = 1) as "kontrolTamam",
                       -- Time-out (aşama 2) zorunlu maddelerinden eksik: kesinin kapısı.
                       (select count(*) from public.ameliyat_kontrol k
                         join public.ameliyat_kontrol_madde m on m.id = k.madde_id
                        where k.ameliyat_id = a.id and k.asama = 2
                          and m.zorunlu = 1 and k.isaretli = 0) as "timeoutEksik",
                       (select count(*) from public.ameliyat_sayim y
                         where y.ameliyat_id = a.id and y.uyumlu = 0) as "sayimUyumsuz",
                       (select count(*) from public.ameliyat_sayim y
                         where y.ameliyat_id = a.id and y.kapanis is null) as "sayimBekleyen",
                       (select count(*) from public.ameliyat_sarf f
                         where f.ameliyat_id = a.id and f.implant = 1
                           and f.uts_durum in (1, 3)) as "utsBekleyen",
                       (select count(*) from public.ameliyat_not n
                         where n.ameliyat_id = a.id and n.imza_zamani is not null) as "notImzali"
                  from public.ameliyat a
                  left join public.ameliyat_salon s on s.id = a.salon_id
                  left join public.taraf h on h.id = a.hasta_id
                  left join public.taraf c on c.id = a.cerrah_id
                 where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat bulunamadı.");

            return Results.Ok(akis);
        });

        // ------------------------------------------------- akış adımı yaz ----
        // TEK UÇ, ALTI DAMGA. Her damga için ayrı uç yazmak aynı sıra ve yetki
        //   kontrolünün altı kopyasını üretirdi; kural bir yerde durunca
        //   "kesiden önce salona alınmış olmalı" her yolda geçerli.
        grup.MapPost("/ameliyat/{id:long}/adim", async (
            long id, AdimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ameliyathane.baslat");

            var adim = (istek.Adim ?? "").Trim().ToLowerInvariant();
            var (kolon, yeniDurum) = adim switch
            {
                "salona-alma" => ("salona_alma", DurumHazirlik),
                "anestezi" => ("anestezi_bas", DurumHazirlik),
                "kesi" => ("kesi_zamani", DurumSuruyor),
                "kapanis" => ("kapanis_bas", DurumKapanista),
                "bitis" => ("bitis_zamani", DurumBitti),
                "cikis" => ("salondan_cikis", DurumBitti),
                _ => throw GentegreHatasi.Dogrulama("Bilinmeyen akış adımı.",
                        new AlanHatasi("adim", "Bilinmeyen akış adımı."))
            };

            await using var baglanti = await veri.AcAsync(iptal);

            var a = await baglanti.TekAsync("""
                select a.durum, a.salona_alma as "salonaAlma", a.kesi_zamani as "kesiZamani",
                       a.bitis_zamani as "bitisZamani", a.salondan_cikis as "salondanCikis",
                       a.anestezi_bas as "anesteziBas", a.kapanis_bas as "kapanisBas",
                       (select count(*) from public.ameliyat_kontrol k
                         join public.ameliyat_kontrol_madde m on m.id = k.madde_id
                        where k.ameliyat_id = a.id and k.asama = 2
                          and m.zorunlu = 1 and k.isaretli = 0) as "timeoutEksik",
                       (select count(*) from public.ameliyat_sayim y
                         where y.ameliyat_id = a.id and y.uyumlu = 0) as "sayimUyumsuz",
                       (select count(*) from public.ameliyat_sayim y
                         where y.ameliyat_id = a.id and y.kapanis is null) as "sayimBekleyen"
                  from public.ameliyat a where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat bulunamadı.");

            if (Convert.ToInt16(a["durum"] ?? (short)0) == DurumIptal)
                throw GentegreHatasi.IsKurali("İptal edilmiş ameliyatta akış ilerletilemez.");

            // --- SIRA. Yalnız OMURGA zorunlu: salona alma -> kesi -> bitiş ->
            //     çıkış. Anestezi ve kapanış damgaları atlanabilir (lokal
            //     anestezi, kapanışı ayrı damgalamayan ekip); onları da zorunlu
            //     kılmak, gerçekte olmayan bir adımı uydurmaya zorlardı.
            (string? Alan, string? Mesaj) oncekiGerekli = adim switch
            {
                "anestezi" or "kesi" => ("salonaAlma", "Hasta salona alınmadan"),
                "kapanis" or "bitis" => ("kesiZamani", "Kesi yapılmadan"),
                "cikis" => ("bitisZamani", "Ameliyat bitmeden"),
                _ => (null, null)
            };
            if (oncekiGerekli.Alan is not null && a[oncekiGerekli.Alan] is null)
                throw GentegreHatasi.IsKurali($"{oncekiGerekli.Mesaj} bu adım kaydedilemez.");

            var uyarilar = new List<string>();

            // --- ZATEN YAZILMIŞ MI? EN ÖNDE SORULUR. Yanlışlıkla ikinci kez
            //     tıklanan bir adımda önce time-out sorulsaydı, kullanıcı
            //     olmayan bir engeli gerekçeyle geçer ve günlüğe asılsız bir
            //     "time-out atlandı" satırı düşerdi.
            var mevcut = a[kolon switch
            {
                "salona_alma" => "salonaAlma",
                "anestezi_bas" => "anesteziBas",
                "kesi_zamani" => "kesiZamani",
                "kapanis_bas" => "kapanisBas",
                "bitis_zamani" => "bitisZamani",
                _ => "salondanCikis"
            }];
            if (mevcut is not null && !istek.Duzelt)
                throw GentegreHatasi.IsKurali(
                    "Bu adım zaten kaydedilmiş. Düzeltmek için düzeltme onayı gerekir.",
                    new { mevcut });

            // --- TIME-OUT KAPISI. DSÖ kontrol listesinin bütün amacı kesiden
            //     ÖNCE durmaktır; sonradan işaretlenen liste yalnız kâğıt olur.
            //     Acil için `zorla` var ama gerekçesiz değil - gerekçe günlüğe
            //     yazılır, çünkü atlanan time-out kurumun cevap vermesi gereken
            //     bir olaydır.
            if (adim == "kesi" && Convert.ToInt32(a["timeoutEksik"] ?? 0) > 0)
            {
                var eksik = Convert.ToInt32(a["timeoutEksik"] ?? 0);
                if (!istek.Zorla)
                    throw GentegreHatasi.IsKurali(
                        $"Time-out tamamlanmadı: {eksik} zorunlu madde işaretsiz.",
                        new { timeoutEksik = eksik });
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Time-out atlanıyorsa gerekçe zorunlu.",
                        new AlanHatasi("gerekce", "Time-out atlanıyorsa gerekçe zorunlu."));
                uyarilar.Add($"Time-out atlandı ({eksik} madde işaretsiz).");
            }

            // --- SAYIM. Kapanışta uyuşmazlık ENGEL DEĞİL, UYARIDIR: kaydı
            //     engellemek ekibi damgayı hiç yazmamaya iter, oysa uyuşmayan
            //     sayımın kayda geçmesi tam da istediğimiz şeydir (716'daki
            //     "engellemek yerine görünür kılmak" kuralı).
            if (adim is "bitis" or "cikis")
            {
                if (Convert.ToInt32(a["sayimUyumsuz"] ?? 0) > 0)
                    uyarilar.Add("Sayım uyuşmuyor - kapanış sayımı tekrarlanmalı.");
                if (Convert.ToInt32(a["sayimBekleyen"] ?? 0) > 0)
                    uyarilar.Add("Kapanış sayımı girilmemiş kalem var.");
            }

            var zaman = istek.Zaman ?? DateTime.Now;

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // DURUM GERİ GİTMEZ: geç girilen bir "anestezi" damgası, bitmiş
            //   ameliyatı "hazırlık"a döndürmemeli.
            //
            // YANITTA GERÇEKTE YAZILAN DURUM DÖNER, adımın "hedef" durumu
            //   değil: bitmiş bir vakada salona alma saati düzeltilince
            //   `durum = 1` demek, ekrana ameliyatın hazırlığa döndüğünü
            //   söylemek olurdu.
            var sonDurum = await baglanti.TekDegerAsync<int>($"""
                update public.ameliyat
                   set {kolon} = @p1,
                       durum = greatest(durum, @p2),
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                returning durum
                """, islem, [id, zaman, yeniDurum, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloAmeliyat, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    adim, zaman, duzeltme = istek.Duzelt ? mevcut : null,
                    timeoutAtlandi = istek.Zorla ? istek.Gerekce : null,
                    uyarilar = uyarilar.Count > 0 ? uyarilar : null
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { adim, zaman, durum = sonDurum, uyarilar, izlemeNo = baglam.IzlemeNo });
        });

        // --------------------------------------------------------- iptal ----
        // AMELİYAT SİLİNMEZ, İPTAL EDİLİR: kayda bağlı sarf, ekip ve kontrol
        //   satırları var ve "bu vaka planlanmıştı, olmadı" bilgisinin kendisi
        //   masa kullanımı raporunun girdisi.
        grup.MapPost("/ameliyat/{id:long}/iptal", async (
            long id, IptalIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ameliyathane.iptal");

            if (string.IsNullOrWhiteSpace(istek.Neden))
                throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                    new AlanHatasi("neden", "İptal nedeni zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var a = await baglanti.TekAsync("""
                select a.durum, a.talep_id as "talepId", a.kesi_zamani as "kesiZamani"
                  from public.ameliyat a where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat bulunamadı.");

            // Kesi yapılmış vaka İPTAL DEĞİL, olmuş bir ameliyattır - yarıda
            //   kesilmişse bile notu ve komplikasyonu yazılmalı. İptal
            //   edilebilseydi gerçekleşmiş cerrahi kayıtlardan düşerdi.
            if (a["kesiZamani"] is not null)
                throw GentegreHatasi.IsKurali(
                    "Kesi yapılmış ameliyat iptal edilemez; durumu 'bitti' olarak kapatın "
                    + "ve ameliyat notuna yazın.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.ameliyat
                   set durum = @p1, iptal_neden = @p2,
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, DurumIptal, istek.Neden.Trim(), baglam.KullaniciId], iptal);

            // TALEP BEKLEYENE DÖNER (715 kuralı): hasta hâlâ ameliyat bekliyor;
            //   talep kapalı kalsaydı listeden düşer ve unutulurdu.
            var talepId = a["talepId"];
            if (istek.TalebiGeriAl && talepId is not null)
            {
                await baglanti.CalistirAsync("""
                    update public.ameliyat_talep
                       set durum = 0, degistiren = @p1, degistirme_tarihi = (now())::timestamp
                     where id = @p0
                    """, islem, [talepId, baglam.KullaniciId], iptal);

                await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloTalep,
                    Convert.ToInt64(talepId), baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { durum = 0, neden = "ameliyat iptal" }, iptal: iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloAmeliyat, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = DurumIptal, neden = istek.Neden.Trim() }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                durum = DurumIptal,
                talepGeriAlindi = istek.TalebiGeriAl && talepId is not null,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // -------------------------------------------------- notu imzala ----
        // İMZA KAYDI KİLİTLER (719 tetiği). Uç yalnız ön koşulları arar; asıl
        //   kilit veritabanında, çünkü imzanın anlamı "bu metin benimdir" ve
        //   uçtaki bir kontrol doğrudan SQL ile atlanabilirdi.
        grup.MapPost("/ameliyat/{id:long}/not-imzala", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ameliyathane.not_imzala");

            await using var baglanti = await veri.AcAsync(iptal);

            var n = await baglanti.TekAsync("""
                select n.imza_zamani as "imzaZamani", n.bulgu, n.islem_metni as "islemMetni",
                       a.durum, a.bitis_zamani as "bitisZamani"
                  from public.ameliyat a
                  left join public.ameliyat_not n on n.ameliyat_id = a.id
                 where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat bulunamadı.");

            if (n["bulgu"] is null && n["islemMetni"] is null)
                throw GentegreHatasi.IsKurali("Ameliyat notu henüz yazılmamış.");
            if (n["imzaZamani"] is not null)
                throw GentegreHatasi.IsKurali("Bu not zaten imzalanmış.");
            if (n["bitisZamani"] is null)
                throw GentegreHatasi.IsKurali("Ameliyat bitmeden not imzalanamaz.");
            if (string.IsNullOrWhiteSpace(n["islemMetni"]?.ToString()))
                throw GentegreHatasi.Dogrulama("Yapılan işlem yazılmadan imzalanamaz.",
                    new AlanHatasi("islemMetni", "Yapılan işlem yazılmadan imzalanamaz."));

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.ameliyat_not
                   set imzalayan_id = @p1, imza_zamani = (now())::timestamp,
                       degistiren = @p1, degistirme_tarihi = (now())::timestamp
                 where ameliyat_id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloAmeliyat, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "not imzalandı" }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { imzalandi = true, izlemeNo = baglam.IzlemeNo });
        });
    }

    // =================================================== kontrol listesi ==
    private static void KontrolUclari(RouteGroupBuilder grup)
    {
        // Kartta liste SALT OKUNUR (KartKatalogu): madde metni kopyadır ve
        //   işaretleyen/zaman elle yazılmamalı. İşaretleme buradan geçer -
        //   böylece "kim, ne zaman işaretledi" gerçekten doğru olur.
        grup.MapGet("/ameliyat/{id:long}/kontrol", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ameliyathane.ameliyat", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // Ameliyat kontrol satırı olmadan açıldıysa (kart üzerinden elle
            //   eklenen vaka) liste burada doğar: boş kontrol listesi,
            //   doldurulmamış listeyle aynı şey değildir.
            await KontrolListesiKopyalaAsync(baglanti, null, id, iptal);

            var maddeler = await baglanti.ListeAsync("""
                select k.id, k.asama, k.sira, k.madde_metin as "maddeMetin",
                       k.isaretli, k.not_metni as "notMetni",
                       k.isaret_zamani as "isaretZamani",
                       coalesce(p.unvan, '') as "isaretleyen",
                       coalesce(m.zorunlu, 1) as zorunlu
                  from public.ameliyat_kontrol k
                  left join public.ameliyat_kontrol_madde m on m.id = k.madde_id
                  left join public.taraf p on p.id = k.isaretleyen
                 where k.ameliyat_id = @p0
                 order by k.asama, k.sira
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { maddeler });
        });

        // TOPLU YAZILIR: ekip listeyi bir oturuşta okur. Madde başına istek
        //   atsaydık yarım işaretlenmiş time-out bırakan bir ağ kesintisi,
        //   kesiyi haksız yere serbest bırakabilirdi.
        grup.MapPost("/ameliyat/{id:long}/kontrol", async (
            long id, KontrolIstegi2 istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ameliyathane.ameliyat", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var sayi = 0;
            foreach (var y in istek.Yanitlar ?? [])
            {
                // İŞARETİ KALDIRMAK da meşru (yanlış işaretlendi): işaretleyen
                //   ve zaman birlikte SİLİNİR, yoksa "işaretsiz ama Ali
                //   işaretlemiş" satırı kalırdı.
                sayi += await baglanti.CalistirAsync("""
                    update public.ameliyat_kontrol
                       set isaretli = @p2,
                           isaretleyen = case when @p2 = 1 then @p3 else null end,
                           isaret_zamani = case when @p2 = 1 then (now())::timestamp else null end,
                           not_metni = coalesce(@p4, not_metni)
                     where ameliyat_id = @p0
                       and (id = @p1 or (@p1 is null and asama = @p5 and sira = @p6))
                    """, islem,
                    [id, y.Id, y.Isaretli == 1 ? (short)1 : (short)0,
                     baglam.KullaniciId, y.NotMetni, y.Asama, y.Sira], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloAmeliyat, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "kontrol listesi", satir = sayi }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { kaydedildi = sayi, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Aktif kontrol maddelerini ameliyata KOPYALAR (metniyle birlikte).
    /// Zaten kopyalanmışsa dokunmaz - benzersiz indeks (ameliyat_id, asama,
    /// sira) ikinci kopyayı engeller, ama sessiz çakışma yerine açıkça
    /// atlıyoruz ki sonradan eklenen bir madde de yakalansın.
    /// </summary>
    private static async Task KontrolListesiKopyalaAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        long ameliyatId, CancellationToken iptal)
    {
        await baglanti.CalistirAsync("""
            insert into public.ameliyat_kontrol
                (ameliyat_id, madde_id, asama, sira, madde_metin)
            select @p0, m.id, m.asama, m.sira, m.metin
              from public.ameliyat_kontrol_madde m
             where m.aktif = 1
               and not exists (select 1 from public.ameliyat_kontrol k
                                where k.ameliyat_id = @p0
                                  and k.asama = m.asama and k.sira = m.sira)
            """, islem, [ameliyatId], iptal);
    }
}
