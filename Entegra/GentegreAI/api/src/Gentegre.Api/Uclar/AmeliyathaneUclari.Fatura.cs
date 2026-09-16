using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// AMELİYAT → FATURA ve SARF → STOK (720).
///
/// İKİ AYRI DEFTER, İKİ AYRI BELGE - ve bu yüzden çift sayım yok:
///   ÜCRET   hasta başvurusuna (tür 19) satır olarak yazılır. Tür 19 stok ve
///           muhasebe ETKİLEMEZ (`BelgeTuru`); gerçek hareket faturaya
///           dönüşünce oluşur. Ameliyathane kendi fatura mantığını kurmuyor.
///   MALZEME stok çıkış fişiyle (tür 4) düşer - carisiz, yalnız stok yönü.
/// Tek belgede birleştirseydik, faturalanmayan (pakete dahil) malzeme ya
/// stoktan düşmez ya da hastaya yazılırdı; ikisi de yanlış.
///
/// FATURALANACAK MALZEME DE STOKTAN DÜŞER. "Hastaya yazdık, o hâlde depodan
/// düşmesin" diye bir kural yok: malzeme fiilen kullanıldı. İki işlem farklı
/// defterlere yazıyor, aynı olayı iki kez saymıyor.
///
/// TEKRAR ÇALIŞTIRMAK GÜVENLİ. İşlem ve sarf satırları kendi belge bağlarını
/// taşır; ikinci çağrı yalnız bağsız olanları ekler. Ameliyat bittikten sonra
/// eklenen bir implant, faturalamayı yeniden çalıştırınca kendiliğinden
/// katılır - "ameliyat faturalandı" bayrağı olsaydı görünmez kalırdı.
/// </summary>
public static partial class AmeliyathaneUclari
{
    public sealed class FaturaIstegi
    {
        /// <summary>Başvuru yoksa açılırken ödeyen kurum (pay bölüşümü buna bağlı).</summary>
        public int? OdeyenKurumId { get; set; }
        /// <summary>Malzeme ücret satırı da yazılsın mı (varsayılan evet, `faturaya = 1` olanlar).</summary>
        public bool MalzemeDahil { get; set; } = true;
    }

    public sealed class StokDusumIstegi
    {
        /// <summary>Boşsa ayardan (`ameliyathane.sarf_depo`), o da boşsa varsayılan depo.</summary>
        public int? DepoId { get; set; }
        /// <summary>Boşsa düşülmemiş TÜM sarf satırları; doluysa yalnız seçilenler.</summary>
        public IReadOnlyList<long>? SatirIdler { get; set; }

        /// <summary>
        /// İmplantların ÜTS KULLANIM bildirimi düşümle birlikte denensin mi
        /// (varsayılan evet). Kapatmak bildirimden vazgeçmek değil ertelemek:
        /// satır `uts_durum` bekliyor olarak kalır.
        /// </summary>
        public bool UtsBildir { get; set; } = true;
    }

    private static void FaturaUclari(RouteGroupBuilder grup)
    {
        // -------------------------------------------------- fatura durumu ----
        // "Ne faturalanacak, ne faturalandı, ne stoktan düştü" tek istekte.
        //   Ekran bunu göstermeden düğmeyi basmak, kullanıcıyı sonucu
        //   görmeden imzalamaya zorlamak olurdu.
        grup.MapGet("/ameliyat/{id:long}/fatura", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ameliyathane.ameliyat", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var a = await baglanti.TekAsync("""
                select a.id, a.ameliyat_no as "ameliyatNo", a.hasta_id as "hastaId",
                       a.belge_id as "belgeId", a.yatis_id as "yatisId", a.durum,
                       coalesce(h.unvan, '') as "hastaAd",
                       coalesce(b.belge_no, '') as "belgeNo",
                       (select y.belge_id from public.yatis y where y.id = a.yatis_id) as "yatisBelgeId"
                  from public.ameliyat a
                  left join public.taraf h on h.id = a.hasta_id
                  left join public.belge b on b.id = a.belge_id
                 where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat bulunamadı.");

            var islemler = await baglanti.ListeAsync("""
                select i.id, i.sira, i.tur, i.taraf,
                       coalesce(hz.ad, i.aciklama) as ad,
                       coalesce(hz.kod, '') as "sutKodu",
                       i.hizmet_id as "hizmetId", i.belge_satir_id as "belgeSatirId",
                       coalesce((select f.fiyat
                                   from public.fn_belge_kalem_fiyati(
                                            @p1, 2::smallint, null, i.hizmet_id, current_date) f
                                  limit 1), 0) as fiyat
                  from public.ameliyat_islem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                 where i.ameliyat_id = @p0
                 order by i.sira, i.id
                """, null, [id, a["hastaId"]], OkuyucuGenisletmeleri.Sozluk, iptal);

            var sarflar = await baglanti.ListeAsync("""
                select f.id, coalesce(nullif(f.ad, ''), s.ad, f.barkod) as ad,
                       f.stok_id as "stokId", f.miktar, f.lot, f.seri_no as "seriNo",
                       f.implant, f.uts_durum as "utsDurum", f.faturaya,
                       f.belge_satir_id as "belgeSatirId",
                       f.cikis_belge_id as "cikisBelgeId", f.depo_id as "depoId",
                       coalesce((select p.fiyat
                                   from public.fn_belge_kalem_fiyati(
                                            @p1, 2::smallint, f.stok_id, null, current_date) p
                                  limit 1), 0) as fiyat
                  from public.ameliyat_sarf f
                  left join public.stok s on s.id = f.stok_id
                 where f.ameliyat_id = @p0
                 order by f.id
                """, null, [id, a["hastaId"]], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                ameliyat = a, islemler, sarflar,
                ozet = new
                {
                    faturasizIslem = islemler.Count(x => x["belgeSatirId"] is null),
                    faturasizSarf = sarflar.Count(x => x["belgeSatirId"] is null
                                                    && Convert.ToInt16(x["faturaya"] ?? (short)0) == 1),
                    dusulmemisSarf = sarflar.Count(x => x["cikisBelgeId"] is null && x["stokId"] is not null),
                    // Stok kartı olmayan malzeme HİÇ düşülemez: serbest metin
                    //   girilmiş kalem depoda karşılığı olmayan bir şeydir.
                    stoksuzSarf = sarflar.Count(x => x["stokId"] is null),
                    // BİLDİRİLMEMİŞ İMPLANT: düşüldü ama ÜTS'ye geçmedi (1) ya da
                    //   ÜTS reddetti (3). Ekran "tekrar dene" düğmesini buna bakarak
                    //   gösterir - düşüm bir daha çalışmaz, bildirimin ayrı kapısı var.
                    utsBekleyen = sarflar.Count(x =>
                        Convert.ToInt16(x["implant"] ?? (short)0) == 1
                        && Convert.ToInt16(x["utsDurum"] ?? (short)0) is 1 or 3),
                },
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------- faturala ----
        grup.MapPost("/ameliyat/{id:long}/faturala", async (
            long id, FaturaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ameliyathane.faturala");
            baglam.YetkiIste("belge", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var a = await baglanti.TekAsync("""
                select a.hasta_id as "hastaId", a.sube_id as "subeId",
                       a.belge_id as "belgeId", a.yatis_id as "yatisId",
                       a.ameliyat_no as "ameliyatNo", a.durum,
                       (select y.belge_id from public.yatis y where y.id = a.yatis_id) as "yatisBelgeId"
                  from public.ameliyat a where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat bulunamadı.");

            if (Convert.ToInt16(a["durum"] ?? (short)0) == DurumIptal)
                throw GentegreHatasi.IsKurali("İptal edilmiş ameliyat faturalanamaz.");

            // BELGE SIRASI: ameliyatın kendi belgesi > yatışın belgesi > yeni
            //   başvuru. Yatan hastanın ameliyatı yatış faturasına girmeli -
            //   ayrı başvuru açsaydık aynı yatışın parası iki belgeye bölünür,
            //   hasta iki fatura alırdı.
            var belgeId = a["belgeId"] as int? ?? a["yatisBelgeId"] as int?;
            var yeniBasvuru = false;

            var yazma = new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip);
            if (belgeId is null)
            {
                belgeId = await BasvuruAcAsync(baglanti, belgeDepo, a, istek.OdeyenKurumId,
                                               yazma, iptal);
                yeniBasvuru = true;
            }

            // ------------------------------------------- faturalanacaklar ----
            // YALNIZ BAĞSIZ SATIRLAR: ikinci çağrı aynı kalemi tekrar yazmaz.
            var islemler = await baglanti.ListeAsync("""
                select i.id, i.hizmet_id as "hizmetId", i.taraf,
                       coalesce(hz.ad, i.aciklama) as ad, coalesce(hz.kdv, 0) as kdv
                  from public.ameliyat_islem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                 where i.ameliyat_id = @p0 and i.belge_satir_id is null
                   and i.hizmet_id is not null
                 order by i.sira, i.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var sarflar = istek.MalzemeDahil
                ? await baglanti.ListeAsync("""
                    select f.id, f.stok_id as "stokId", f.miktar,
                           coalesce(nullif(f.ad, ''), s.ad, f.barkod) as ad,
                           coalesce(s.kdv, 0) as kdv
                      from public.ameliyat_sarf f
                      left join public.stok s on s.id = f.stok_id
                     where f.ameliyat_id = @p0 and f.belge_satir_id is null
                       and f.faturaya = 1 and f.stok_id is not null and f.miktar > 0
                     order by f.id
                    """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                : [];

            if (islemler.Count == 0 && sarflar.Count == 0)
                throw GentegreHatasi.IsKurali(
                    "Faturalanacak yeni kalem yok - işlemler ve malzemeler zaten aktarılmış.");

            var (belge, satirlar) = await BelgeGovdesi.OkuAsync(baglanti, belgeId.Value, iptal);
            var sira = satirlar.Count;

            // SATIR AÇIKLAMASI EŞLEŞTİRME ANAHTARI: belge yazma hattı satır
            //   id'si döndürmüyor (belgeyi bütün olarak yazıyor), bağı sonradan
            //   açıklamadan kuruyoruz. Anahtar benzersiz olmalı - ameliyat no +
            //   satır id kullanılıyor, iki ameliyatın aynı hizmeti karışmasın.
            var anahtar = new Dictionary<long, string>();

            foreach (var i in islemler)
            {
                var iid = Convert.ToInt64(i["id"]);
                anahtar[iid] = $"AML:{id}:I{iid}";
                satirlar.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>
                {
                    ["tur"] = 2,                        // 2 = hizmet kalemi
                    ["hizmetId"] = i["hizmetId"],
                    ["miktar"] = 1m,
                    ["birimFiyat"] = await FiyatAsync(baglanti, belgeId.Value, a["hastaId"],
                                                      null, i["hizmetId"], iptal),
                    ["kdv"] = i["kdv"],
                    ["dovizCinsi"] = "TL",
                    ["aciklama"] = anahtar[iid],
                    ["sira"] = ++sira,
                }));
            }

            foreach (var f in sarflar)
            {
                var fid = Convert.ToInt64(f["id"]);
                anahtar[-fid] = $"AML:{id}:S{fid}";
                satirlar.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>
                {
                    // 1 = stok kalemi. BAŞVURUDA (tür 19) STOK HAREKETİ YOK -
                    //   düşüm ayrı fişle yapılır (bkz sınıf başlığı).
                    ["tur"] = 1,
                    ["stokId"] = f["stokId"],
                    ["miktar"] = f["miktar"],
                    ["birimFiyat"] = await FiyatAsync(baglanti, belgeId.Value, a["hastaId"],
                                                      f["stokId"], null, iptal),
                    ["kdv"] = f["kdv"],
                    ["dovizCinsi"] = "TL",
                    ["aciklama"] = anahtar[-fid],
                    ["sira"] = ++sira,
                }));
            }

            var (_, uyarilar) = await belgeDepo.GuncelleAsync(belgeId.Value, belge, satirlar,
                // Stok kontrolü KAPALI: tür 19 stoğa dokunmuyor, kontrol
                //   açılsaydı henüz düşülmemiş malzeme için boş yere engel çıkardı.
                new BelgeSecenekleri { Taslak = false, StokKontrolu = false }, yazma, iptal);

            // Üretilen satırlar kaleme BAĞLANIR: "bu işlem faturalandı mı"
            //   sorusu tek join ile, tekrar faturalama da bu bağla engelleniyor.
            await baglanti.CalistirAsync("""
                update public.ameliyat_islem i
                   set belge_satir_id = s.id
                  from public.belge_satir s
                 where s.belge_id = @p0 and s.aciklama = 'AML:' || @p1 || ':I' || i.id
                   and i.ameliyat_id = @p1 and i.belge_satir_id is null
                """, null, [belgeId, id], iptal);

            await baglanti.CalistirAsync("""
                update public.ameliyat_sarf f
                   set belge_satir_id = s.id
                  from public.belge_satir s
                 where s.belge_id = @p0 and s.aciklama = 'AML:' || @p1 || ':S' || f.id
                   and f.ameliyat_id = @p1 and f.belge_satir_id is null
                """, null, [belgeId, id], iptal);

            if (a["belgeId"] is null)
                await baglanti.CalistirAsync("""
                    update public.ameliyat set belge_id = @p1, degistiren = @p2,
                           degistirme_tarihi = (now())::timestamp
                     where id = @p0
                    """, null, [id, belgeId, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloAmeliyat, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { belgeId, islem = islemler.Count, malzeme = sarflar.Count, yeniBasvuru },
                iptal: iptal);

            return Results.Ok(new
            {
                belgeId, yeniBasvuru,
                islemSatiri = islemler.Count, malzemeSatiri = sarflar.Count,
                uyarilar, izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------ stok düş ----
        // MEVCUT BELGE HATTINDAN stok çıkış fişi (tür 4) üretilir - stok_durum,
        //   lot bakiyesi ve maliyet orada çözülüyor. Ameliyathaneye ikinci bir
        //   stok mantığı yazılmaz (radyoloji sarfıyla aynı karar).
        grup.MapPost("/ameliyat/{id:long}/stok-dus", async (
            long id, StokDusumIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, Servisler.UtsServisi uts,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ameliyathane.stok_dus");
            baglam.YetkiIste("stok", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var a = await baglanti.TekAsync("""
                select a.ameliyat_no as "ameliyatNo", a.sube_id as "subeId", a.durum
                  from public.ameliyat a where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ameliyat bulunamadı.");

            if (Convert.ToInt16(a["durum"] ?? (short)0) == DurumIptal)
                throw GentegreHatasi.IsKurali("İptal edilmiş ameliyatın malzemesi düşülmez.");

            var secim = istek.SatirIdler is { Count: > 0 } ? istek.SatirIdler.ToArray() : null;
            var satirlar = await baglanti.ListeAsync("""
                select f.id, f.stok_id as "stokId", f.miktar, f.lot, f.seri_no as "seriNo",
                       coalesce(nullif(f.ad, ''), s.ad, f.barkod) as ad,
                       -- LOT METİNDEN ÇÖZÜLÜR: sarf satırı lot NUMARASI tutuyor,
                       --   belge hattı ise lot KAYDININ id'sini istiyor. Bulunamazsa
                       --   null kalır ve satır izlemsiz gider - uydurma bir lot
                       --   bağlamak, sayımı düzeltmek yerine yanlış yere yazardı.
                       --
                       -- YALNIZ İZLEMLİ STOKTA (stok.izleme: 1 seri, 2 lot, 3 ikisi).
                       --   İzlemsiz karta lot bağlamak belge hattı tarafından
                       --   REDDEDİLİYOR ("bu stok için lot/seri tutulmuyor") -
                       --   sarf satırında lot yazması, stok kartının onu izlediği
                       --   anlamına gelmiyor.
                       (select l.id from public.stok_seri_lot l
                         where coalesce(s.izleme, 0) <> 0
                           and l.stok_id = f.stok_id
                           -- SATIR LOT/SERİ SÖYLEMİYORSA EŞLEŞME YAPILMAZ.
                           --   "boşsa herhangi biri" yazsaydık (ve bir süre öyleydi)
                           --   sistem, kimse söylemeden rastgele bir lotu düşerdi:
                           --   bakiye toplamı doğru çıkar ama hangi lotun hastaya
                           --   gittiği UYDURULMUŞ olurdu - geri çağırmada aranan
                           --   tam da bu bilgi.
                           and (nullif(f.lot, '') is not null
                                or nullif(f.seri_no, '') is not null)
                           and (nullif(f.lot, '') is null or l.lot_no = f.lot)
                           and (nullif(f.seri_no, '') is null or l.seri_no = f.seri_no)
                         order by l.id limit 1) as "seriLotId"
                  from public.ameliyat_sarf f
                  left join public.stok s on s.id = f.stok_id
                 where f.ameliyat_id = @p0 and f.cikis_belge_id is null
                   and f.stok_id is not null and f.miktar > 0
                   and (@p1::bigint[] is null or f.id = any(@p1::bigint[]))
                 order by f.id
                """, null, [id, secim], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (satirlar.Count == 0)
                throw GentegreHatasi.IsKurali(
                    "Düşülecek malzeme yok - stok kartı olmayan kalemler düşülemez.");

            var depoAyar = await AyarDeposu.MetinAsync(baglanti, null,
                                                       "ameliyathane.sarf_depo", "", iptal);
            var depoId = istek.DepoId
                ?? await baglanti.TekDegerAsync<int?>("""
                    select coalesce(nullif(@p0, '')::int,
                           (select min(x.id) from public.depo x
                             where x.varsayilan = 1 and coalesce(x.durum, 1) = 1),
                           (select min(x.id) from public.depo x
                             where coalesce(x.durum, 1) = 1))
                    """, null, [depoAyar], iptal)
                ?? throw GentegreHatasi.IsKurali(
                    "Sarf çıkışı için depo bulunamadı - Genel Ayarlar'dan ameliyathane "
                    + "sarf deposunu seçin.");

            var fis = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 4,                        // 4 = Stok Çıkış Fişi (carisiz)
                ["tipi"] = 1,
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["cikisDepoId"] = depoId,
                ["subeId"] = baglam.SubeId ?? a["subeId"],
                ["aciklama"] = $"Ameliyathane sarf · {a["ameliyatNo"]}",
            };

            var govde = new List<Dictionary<string, JsonElement>>();
            var sira = 0;
            foreach (var f in satirlar)
            {
                var alanlar = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 1,
                    ["stokId"] = f["stokId"],
                    ["miktar"] = f["miktar"],
                    ["birimFiyat"] = 0m,            // maliyet stok tarafında
                    ["kdv"] = 0,
                    ["dovizCinsi"] = "TL",
                    ["cikisDepoId"] = depoId,
                    ["aciklama"] = $"{a["ameliyatNo"]} · {f["ad"]}",
                    ["sira"] = ++sira,
                };
                if (f["seriLotId"] is not null)
                    alanlar["izlemler"] = new List<Dictionary<string, object?>>
                    {
                        new() { ["seriLotId"] = f["seriLotId"], ["miktar"] = f["miktar"] },
                    };
                govde.Add(BelgeGovdesi.Satir(alanlar));
            }

            var (fisId, uyarilar) = await belgeDepo.KaydetAsync(
                fis, govde,
                // Stok kontrolü AÇIK. Negatif bakiyede ne olacağı KURUM AYARI
                //   (Genel Ayarlar > Stok: negatif stok) - uyarı ya da engel.
                //   Ameliyathane bunu kendisi kararlaştırmaz: malzeme fiilen
                //   kullanıldı, kaydı reddetmek gerçek tüketimi gizlerdi; negatif
                //   bakiye zaten "depo kayıtları geride" demektir ve uyarı olarak
                //   çağırana döner.
                new BelgeSecenekleri { Taslak = false, StokKontrolu = true },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

            await baglanti.CalistirAsync("""
                update public.ameliyat_sarf
                   set cikis_belge_id = @p1, depo_id = @p2
                 where ameliyat_id = @p0 and id = any(@p3)
                """, null, [id, fisId, depoId,
                            satirlar.Select(x => Convert.ToInt64(x["id"])).ToArray()], iptal);

            // KRİTİK STOK: düşümden sonra kalan min_stok altına indiyse uyarı -
            //   satın alma talebini kullanıcı açar, biz sessizce geçmeyiz.
            var kritik = await baglanti.ListeAsync("""
                select coalesce(s.ad, '') as ad, sd.kalan, sd.min_stok as "minStok"
                  from public.stok_durum sd
                  join public.stok s on s.id = sd.stok_id
                 where sd.depo_id = @p0 and sd.stok_id = any(@p1)
                   and coalesce(sd.min_stok, 0) > 0 and sd.kalan <= sd.min_stok
                """, null, [depoId, satirlar.Select(x => Convert.ToInt32(x["stokId"])).ToArray()],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            // ÜTS: implant bildirimi düşümün ARDINDAN (bkz UtsBildirAsync).
            var (utsSonuc, utsMesaj) = istek.UtsBildir
                ? await UtsBildirAsync(baglanti, uts, baglam, id, fisId, iptal)
                : ([], "");

            // Bildirimden SONRA sayılır: ekranda kalan gerçek bekleyen görünsün.
            var utsBekleyen = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.ameliyat_sarf f
                 where f.ameliyat_id = @p0 and f.implant = 1 and f.uts_durum in (1, 3)
                """, null, [id], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloAmeliyat, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { fisId, depoId, satir = satirlar.Count,
                      uts = utsSonuc.Count, utsMesaj }, iptal: iptal);

            return Results.Ok(new
            {
                fisId, depoId, dusulen = satirlar.Count,
                izlemsiz = satirlar.Count(x => x["seriLotId"] is null),
                uyarilar, kritik, utsBekleyen,
                uts = utsSonuc, utsMesaj, izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------- ÜTS tekrar dene ----
        // BİLDİRİM DÜŞÜMLE BİRLİKTE YAPILIR ama ÜTS reddedebilir ya da hesap
        //   o an tanımsız olabilir. Düşüm bir daha çalışmaz (malzeme zaten
        //   düşüldü), dolayısıyla bildirimin kendi kapısı olmalı - yoksa
        //   `uts_durum = 3` kalan implant ameliyat tarafında sonsuza kadar
        //   "hata" olarak durur ve yalnız ÜTS ekranından, ameliyatla bağı
        //   görünmeden yeniden gönderilebilirdi.
        grup.MapPost("/ameliyat/{id:long}/uts-bildir", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, Servisler.UtsServisi uts,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ameliyathane.stok_dus");

            await using var baglanti = await veri.AcAsync(iptal);
            var (sonuc, mesaj) = await UtsBildirAsync(baglanti, uts, baglam, id, null, iptal);

            if (sonuc.Count == 0 && mesaj.Length == 0)
                throw GentegreHatasi.IsKurali(
                    "Bildirilecek implant yok - bildirilmemiş implant, düşülmüş olmalı.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloAmeliyat, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "ÜTS tekrar", satir = sonuc.Count, mesaj }, iptal: iptal);

            return Results.Ok(new { uts = sonuc, utsMesaj = mesaj, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Ameliyatın hastası için HASTA BAŞVURUSU (tür 19 / tipi 30) açar.
    ///
    /// Fiyat listesi ve kampanya belgenin KİMLİĞİDİR (274/302): sırası tek
    /// yerde (fn) çözülür. Başlığa yazılmazsa "bu tutar hangi anlaşmayla
    /// oluştu" izi kaybolur ve sonradan eklenen kalem indirimsiz fiyatlanır.
    ///
    /// KALEMSİZ AÇILIR: satırlar hemen ardından ekleniyor ve açıklamayla
    /// eşleştiriliyor; burada eklersek iki yerde satır kurmuş olurduk.
    /// </summary>
    private static async Task<int> BasvuruAcAsync(
        NpgsqlConnection baglanti, BelgeDeposu belgeDepo, IDictionary<string, object?> a,
        int? odeyenKurumId, YazmaBaglami yazma, CancellationToken iptal)
    {
        var hasta = await baglanti.TekAsync("""
            select coalesce(unvan, '') as unvan, coalesce(vkno, '') as vkno,
                   coalesce(vd, '') as vd
              from public.taraf where id = @p0
            """, null, [a["hastaId"]], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

        var listeId = await baglanti.TekDegerAsync<int?>("""
            select public.fn_belge_varsayilan_liste(19, @p0, current_date, @p1)
            """, null, [a["hastaId"], odeyenKurumId], iptal);

        var kampanyaId = await baglanti.TekDegerAsync<int?>("""
            select public.fn_taraf_kampanya(coalesce(@p1, @p0), current_date)
            """, null, [a["hastaId"], odeyenKurumId], iptal);

        var basvuru = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["tur"] = 19,
            ["tipi"] = 30,                          // 30 = Hasta Başvurusu (301)
            ["tarafId"] = a["hastaId"],
            ["tarafUnvan"] = hasta["unvan"],
            ["tarafVkno"] = hasta["vkno"],
            ["tarafVd"] = hasta["vd"],
            ["belgeTarihi"] = DateTime.Now,
            ["belgeDovizi"] = "TL",
            ["dovizKuru"] = 1m,
            ["fiyatListesiId"] = listeId,
            ["kampanyaId"] = kampanyaId,
            ["odeyenKurumId"] = odeyenKurumId,
            ["subeId"] = a["subeId"],
            ["aciklama"] = $"Ameliyat · {a["ameliyatNo"]}",
        };

        var (id, _) = await belgeDepo.KaydetAsync(basvuru, [],
            new BelgeSecenekleri { Taslak = false, StokKontrolu = false }, yazma, iptal);
        return id;
    }

    /// <summary>
    /// İMPLANTLARIN ÜTS KULLANIM BİLDİRİMİ.
    ///
    /// DÜŞÜMDEN SONRA ÇAĞRILIR, ÖNCE DEĞİL. Sıra tersine olsaydı ÜTS'nin bir
    /// hatası stok hareketini de geri alırdı: malzeme fiilen kullanıldı, depo
    /// kaydı dış servisin keyfine bağlanamaz. Bu yüzden bildirim hatası çağrıyı
    /// DÜŞÜRMEZ - satır `uts_durum = 3` ile kalır ve tekrar denenir.
    ///
    /// KULLANIM bildirimi, verme değil: implant hastaya takıldı, başka bir
    /// kuruma devredilmedi. Verme bildirseydik ürün ÜTS'de hâlâ dolaşımda
    /// görünürdü.
    ///
    /// NEDEN DÜŞÜMLE BİRLİKTE: 715'in kendi notu - "sonradan bildirim, hasta
    /// çıkınca seri numarası kaybolduğu için çoğu zaman yapılamıyor". Düşümü
    /// yapan kişi elindeki kutuya bakıyor; bildirimin en doğru anı bu.
    /// </summary>
    /// <param name="fisId">
    /// Verilirse yalnız o çıkış fişiyle düşülenler; null ise ameliyatın
    /// DÜŞÜLMÜŞ ama bildirilememiş bütün implantları (tekrar deneme).
    /// </param>
    private static async Task<(List<object> Sonuc, string Mesaj)> UtsBildirAsync(
        NpgsqlConnection baglanti, Servisler.UtsServisi uts, IstekBaglami baglam,
        long ameliyatId, int? fisId, CancellationToken iptal)
    {
        var sonuc = new List<object>();
        var implantlar = await baglanti.ListeAsync(UtsSatirSql, null,
            [ameliyatId, fisId], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (implantlar.Count == 0) return (sonuc, "");

        // HESAP BİR KEZ SORULUR. Tanımlı değilse satırları "hata" (3) YAPMIYORUZ:
        //   kayıtta sorun yok, kurulumda var. Hepsini 3 işaretleseydik ÜTS ekranı
        //   gerçek reddedilmelerle kurulum eksiğini aynı kutuda gösterirdi.
        try { await uts.HesapDurumAsync(baglam.SubeId, iptal); }
        catch (GentegreHatasi h) { return (sonuc, h.Message); }

        var yazma = new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip);
        foreach (var im in implantlar)
        {
            var sarfId = Convert.ToInt64(im["id"]);
            short durum;
            string mesaj;
            try
            {
                var y = await uts.KullanimBildirSonucAsync(
                    uno: im["urunNo"] as string,
                    lotNo: im["lot"] as string,
                    seriNo: im["seriNo"] as string,
                    adet: Convert.ToDecimal(im["miktar"] ?? 0m),
                    git: im["kullanimTarihi"] as DateTime?,
                    hastaTckn: im["hastaTckn"] as string,
                    hastaAdi: im["hastaAd"] as string,
                    hastaSoyadi: im["hastaSoyad"] as string,
                    stokId: im["stokId"] as int?,
                    seriLotId: im["seriLotId"] as int?,
                    belgeId: im["cikisBelgeId"] as int?,
                    belgeSatirId: im["belgeSatirId"] as int?,
                    subeId: baglam.SubeId,
                    baglam: yazma,
                    iptal: iptal);
                mesaj = y.Mesaj;
                durum = (short)(y.Basarili ? 2 : 3);
            }
            catch (GentegreHatasi h) { durum = 3; mesaj = h.Message; }

            await baglanti.CalistirAsync(
                "update public.ameliyat_sarf set uts_durum = @p1 where id = @p0",
                null, [sarfId, durum], iptal);

            sonuc.Add(new
            {
                sarfId, ad = im["ad"], lot = im["lot"], seriNo = im["seriNo"],
                basarili = durum == 2, mesaj,
            });
        }
        return (sonuc, "");
    }

    /// <summary>
    /// Bu fişle düşülen İMPLANT satırları + ÜTS'nin istediği her şey.
    ///
    /// `uts_durum = 2` OLANLAR DIŞARIDA: bildirilmiş implant ikinci kez
    /// bildirilmez (ÜTS'de mükerrer kullanım kaydı doğardı). 0/1/3 tekrar
    /// denenir - 3 zaten "hata, tekrar denenecek" demek.
    ///
    /// BELGE SATIRI ÇIKIŞ FİŞİNDEN eşleştirilir: bildirim kaydı hangi hareketin
    /// karşılığı olduğunu taşımalı, yoksa ÜTS ekranında "bu bildirim neyin
    /// bildirimi" sorusu yanıtsız kalır. Eşleşme stok + miktar üzerinden, çünkü
    /// fiş satırı ile sarf satırı birebir yazıldı.
    ///
    /// KULLANIM TARİHİ ameliyatın kendi saatinden gelir (kesi > salona alma >
    /// plan), düşümün yapıldığı andan değil: implant dün takıldıysa ÜTS'ye
    /// bugünün tarihini yazmak kaydı yanlışlar.
    /// </summary>
    private const string UtsSatirSql = @"
        select f.id, f.stok_id as ""stokId"", f.miktar,
               coalesce(nullif(f.ad, ''), s.ad, f.barkod) as ad,
               nullif(f.lot, '') as lot, nullif(f.seri_no, '') as ""seriNo"",
               nullif(s.urun_no, '') as ""urunNo"",
               (select l.id from public.stok_seri_lot l
                 where coalesce(s.izleme, 0) <> 0 and l.stok_id = f.stok_id
                   and (nullif(f.lot, '') is not null or nullif(f.seri_no, '') is not null)
                   and (nullif(f.lot, '') is null or l.lot_no = f.lot)
                   and (nullif(f.seri_no, '') is null or l.seri_no = f.seri_no)
                 order by l.id limit 1) as ""seriLotId"",
               f.cikis_belge_id as ""cikisBelgeId"",
               (select bs.id from public.belge_satir bs
                 where bs.belge_id = f.cikis_belge_id and bs.stok_id = f.stok_id
                   and bs.miktar = f.miktar
                 order by bs.sira limit 1) as ""belgeSatirId"",
               coalesce(a.kesi_zamani, a.salona_alma, a.plan_baslangic,
                        (now())::timestamp)::date as ""kullanimTarihi"",
               nullif(t.vkno, '') as ""hastaTckn"",
               nullif(t.ad, '') as ""hastaAd"",
               nullif(t.soyad, '') as ""hastaSoyad""
          from public.ameliyat_sarf f
          join public.ameliyat a on a.id = f.ameliyat_id
          left join public.stok s on s.id = f.stok_id
          left join public.taraf t on t.id = a.hasta_id
         where f.ameliyat_id = @p0
           -- @p1 verilirse o fisle dusulenler; null ise DUSULMUS ama
           --   bildirilememis hepsi (tekrar deneme). Dusulmemis implant
           --   bildirilmez: ortada henuz stok hareketi yok.
           and (case when @p1::int is null then f.cikis_belge_id is not null
                     else f.cikis_belge_id = @p1::int end)
           and f.implant = 1 and coalesce(f.uts_durum, 0) <> 2
         order by f.id";

    /// <summary>
    /// Kalem fiyatı: önce BELGENİN KENDİ listesinden (başvuruya sözleşme
    /// listesi işlenmiş olabilir), yoksa carinin kuralından; kampanya varsa
    /// indirim uygulanır.
    ///
    /// Zincir radyolojiyle aynı - ekranda gösterilen tutarla faturaya geçen
    /// tutar aynı yoldan gelmeli, hastaya söylenen rakam birebir tutmalı.
    /// </summary>
    private static async Task<decimal> FiyatAsync(
        NpgsqlConnection baglanti, int belgeId, object? tarafId,
        object? stokId, object? hizmetId, CancellationToken iptal)
    {
        var fiyat = await baglanti.TekDegerAsync<decimal>("""
            select coalesce(
                (select fs.fiyat
                   from public.fiyat_listesi_satir fs
                   join public.belge b on b.id = @p3
                  where fs.liste_id = b.fiyat_listesi_id
                    and (@p1::int is null or fs.stok_id = @p1::int)
                    and (@p2::int is null or fs.hizmet_id = @p2::int)
                  limit 1),
                (select f.fiyat
                   from public.fn_belge_kalem_fiyati(
                            @p0, 2::smallint, @p1::int, @p2::int, current_date) f
                  limit 1),
                0)
            """, null, [tarafId, stokId, hizmetId, belgeId], iptal);

        var kampanya = await baglanti.TekDegerAsync<int?>(
            "select kampanya_id from public.belge where id = @p0", null, [belgeId], iptal);

        if (kampanya is int kid && kid > 0 && fiyat > 0)
            fiyat = await baglanti.TekDegerAsync<decimal>("""
                select coalesce(f.fiyat, @p4)
                  from public.fn_kampanya_fiyat(@p0, @p1::int, @p2::int, @p3) f
                 limit 1
                """, null, [kid, stokId, hizmetId, fiyat, fiyat], iptal);

        return fiyat;
    }
}
