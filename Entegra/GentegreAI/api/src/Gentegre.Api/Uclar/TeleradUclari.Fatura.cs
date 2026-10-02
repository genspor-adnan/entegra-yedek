using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TELERADYOLOJİ DÖNEM FATURASI (803).
///
/// Teleradyoloji işi tek tek faturalanmaz: dönem sonunda o kuruma ait
/// onaylanmış/teslim edilmiş isteklerin tamamı <b>tek satış faturasına</b>
/// girer (tasarım `telerad_sureci.html` adım 8).
///
/// <b>Yeni bir para mantığı yazılmıyor.</b> Ücret zaten istek açılırken
/// sözleşme tarifesinden kopyalanmıştı (`telerad_istek.ucret`, 797); burada
/// yapılan iş onu satırlara toplamak. Tutarı mevcut belge hattı hesaplar
/// (`BelgeHesap` / `fn_belge_diptoplam`) - satır toplamı, iskonto ve KDV
/// ikinci kez burada hesaplanmaz.
///
/// <b>SLA cezası satır İSKONTOSUDUR:</b> sözleşmedeki ceza oranı, süresi
/// kaçan işlerin satırına indirim olarak yazılır. Ayrı bir "ceza" kalemi
/// üretmek, eksi tutarlı satır ya da modüle özel bir indirim mantığı demekti.
///
/// <b>İki kez faturalanamaz:</b> faturaya giren istek `fatura_belge_id` ile
/// işaretlenir, önizleme ve üretim yalnız işaretsizleri alır.
/// </summary>
public static partial class TeleradUclari
{
    public sealed class FaturaIstegi
    {
        public int KurumId { get; set; }
        public DateTime Baslangic { get; set; }
        public DateTime Bitis { get; set; }
    }

    /// <summary>
    /// Faturalanabilir işler + faturaya GİREMEYEN işlerin sebebi.
    ///
    /// Eksikleri sessizce atlamak, kuruma eksik fatura kesmek demekti:
    /// "tetkik eşleşmesi yok" ya da "ücreti 0" olan iş ekranda görünür ve
    /// düzeltilir.
    /// </summary>
    // TESTE ACIK (public): onizleme, uretim ve TEST ayni SQL'i kullanir -
    //   kural uc yerde uc kez yazilmasin. `internal` yetmiyor: test ayri
    //   derleme (InternalsVisibleTo tasimak icin tek sabit degmez).
    public const string SatirSql = """
        select hz.id                                   as "hizmetId",
               coalesce(hz.ad, '')                     as "hizmetAdi",
               coalesce(hz.kdv, 0)                     as "kdv",
               i.ucret                                 as "birimFiyat",
               (i.sla_asildi = 1)                      as "slaAsildi",
               count(*)                                as "adet",
               sum(i.ucret)                            as "tutar",
               array_agg(i.id order by i.id)           as "istekler"
          from public.telerad_istek i
          left join public.hizmet hz on hz.id = i.tetkik_hizmet_id
         where i.kurum_id = @p0
           and i.durum in (6, 7)
           and i.fatura_belge_id is null
           and i.onay_zamani >= @p1 and i.onay_zamani < (@p2::date + 1)
           and i.tetkik_hizmet_id is not null
           and i.ucret > 0
         group by hz.id, hz.ad, hz.kdv, i.ucret, (i.sla_asildi = 1)
         order by hz.ad, i.ucret
        """;

    public const string EksikSql = """
        select i.id, i.istek_no as "istekNo", i.ucret,
               case when i.tetkik_hizmet_id is null then 'Tetkik eşleşmesi yok'
                    when i.ucret <= 0 then 'Ücret yazılmamış (sözleşme/tarife eksik)'
                    else '' end                        as "sebep"
          from public.telerad_istek i
         where i.kurum_id = @p0
           and i.durum in (6, 7)
           and i.fatura_belge_id is null
           and i.onay_zamani >= @p1 and i.onay_zamani < (@p2::date + 1)
           and (i.tetkik_hizmet_id is null or i.ucret <= 0)
         order by i.id
        """;

    private static void FaturaUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------ önizleme ----
        // "Bu dönemde ne faturalanacak" sorusunun cevabı, fatura üretmeden
        //   (kurum icmalindeki desenin aynısı, 289).
        grup.MapGet("/fatura-onizleme", async (
            int kurumId, DateTime baslangic, DateTime bitis, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonGorIste("telerad.faturala");

            await using var baglanti = await veri.AcAsync(iptal);
            return Results.Ok(await OzetAsync(baglanti, kurumId, baslangic, bitis, iptal));
        });

        // ------------------------------------------------- fatura üretimi ----
        grup.MapPost("/fatura", async (
            FaturaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("telerad.faturala");
            // FATURA YAZMA YETKİSİ DE İSTENİR: dönem faturası sıradan bir
            //   satış faturasıdır, teleradyolojiye özel bir belge değil.
            baglam.YetkiIste("belge", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            var ozet = await OzetAsync(baglanti, istek.KurumId, istek.Baslangic,
                                       istek.Bitis, iptal);

            if (ozet.Satirlar.Count == 0)
                throw GentegreHatasi.IsKurali(
                    "Bu dönemde faturalanacak iş yok. Yalnız onaylanmış/teslim edilmiş "
                    + "ve daha önce faturalanmamış istekler faturaya girer.");

            // AYLIK SABİT + AŞIM MODELİ HENÜZ YOK: sabit ücretin hangi hizmet
            //   kalemine yazılacağı tanımlı değil. Uydurma bir kalem üretmek
            //   yerine açıkça reddediliyor - tetkik başı ve vaka başı modeller
            //   ücreti isteğin üstünde taşıdığı için burada çalışıyor.
            if (ozet.UcretModeli == 2)
                throw GentegreHatasi.IsKurali(
                    "Aylık sabit + aşım modeli için dönem faturası henüz üretilemiyor "
                    + "(sabit ücret kalemi tanımlı değil). Sözleşme tetkik başı ya da "
                    + "vaka başı ise fatura üretilebilir.");

            var yazma = new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip);
            var donem = $"{istek.Baslangic:dd.MM.yyyy} - {istek.Bitis:dd.MM.yyyy}";

            var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = BelgeTuru.SatisFaturasi,
                ["tipi"] = 1,
                ["tarafId"] = ozet.TarafId,
                ["tarafUnvan"] = ozet.KurumAdi,
                ["tarafVkno"] = ozet.Vkno,
                ["tarafVd"] = ozet.Vd,
                // BELGE TARİHİ DÖNEMİN SONU: fatura o dönemin işidir, üretildiği
                //   günün değil - gecikmeli kesilen fatura yanlış aya düşerdi.
                //   AMA İLERİ TARİH OLAMAZ (belge hattının kuralı): dönem
                //   kapanmadan ara fatura kesilirse bugünün tarihi kullanılır.
                ["belgeTarihi"] = istek.Bitis.Date > DateTime.Today
                    ? DateTime.Today : istek.Bitis.Date,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["subeId"] = baglam.SubeId,
                ["aciklama"] = $"Teleradyoloji dönem faturası · {donem}",
            };

            var satirlar = new List<Dictionary<string, JsonElement>>();
            var sira = 0;
            foreach (var s in ozet.Satirlar)
            {
                satirlar.Add(BelgeGovdesi.Satir(new Dictionary<string, object?>
                {
                    ["tur"] = 2,                    // hizmet kalemi
                    ["hizmetId"] = s.HizmetId,
                    ["miktar"] = (decimal)s.Adet,
                    ["birimFiyat"] = s.BirimFiyat,
                    // SLA CEZASI SATIR İSKONTOSU: ayrı "ceza" kalemi üretmek
                    //   eksi tutarlı satır ya da modüle özel indirim mantığı
                    //   demekti. Hesabı belge hattı yapar.
                    ["iskonto"] = s.CezaOrani,
                    ["kdv"] = s.Kdv,
                    ["dovizCinsi"] = "TL",
                    ["aciklama"] = s.SlaAsildi
                        ? $"{s.HizmetAdi} · SLA aşımı (%{s.CezaOrani:0.##} ceza)"
                        : s.HizmetAdi,
                    ["sira"] = ++sira,
                }));
            }

            var (belgeId, uyarilar) = await belgeDepo.KaydetAsync(belge, satirlar,
                // Stok kontrolü yok: satırlar hizmet kalemi.
                new BelgeSecenekleri { Taslak = false, StokKontrolu = false }, yazma, iptal);

            // İŞARETLEME FATURADAN SONRA ve YALNIZ İŞARETSİZLERE: aynı istek
            //   ikinci bir faturaya giremesin. Koşul burada da tekrarlanıyor
            //   (id listesi yetmez) - iki kullanıcı aynı anda üretirse ikincisi
            //   boş döner, çift fatura olmaz.
            var isaretlenen = await baglanti.CalistirAsync("""
                update public.telerad_istek
                   set fatura_belge_id = @p1, degistiren = @p2
                 where id = any(@p0) and fatura_belge_id is null
                """, null, [ozet.IstekIdler, belgeId, baglam.KullaniciId], iptal);

            // İŞ HANGİ SATIRDA (807): raporlayan payı satır bazında dağıtılır -
            //   "bu satırı kim okudu" sorusu tahminle (hizmet + ücret
            //   eşleştirmesi) değil, işin kendi kaydıyla cevaplanmalı. Satır
            //   id'si belge yazıldıktan sonra bilinir; eşleşme GRUPLAMA
            //   ANAHTARIYLA yapılır (hizmet + birim fiyat + iskonto) ve o
            //   anahtar satır başına benzersizdir.
            foreach (var s in ozet.Satirlar)
                await baglanti.CalistirAsync("""
                    update public.telerad_istek i
                       set fatura_satir_id = bs.id
                      from public.belge_satir bs
                     where bs.belge_id = @p1 and bs.hizmet_id = @p2
                       and bs.birim_fiyat = @p3 and bs.iskonto = @p4
                       and i.id = any(@p0)
                    """, null,
                    [s.Istekler, belgeId, s.HizmetId, s.BirimFiyat, s.CezaOrani], iptal);

            // ROLÜ VE PRİMİ VERİTABANI YAZAR (807): teleradyolojiye özel bir
            //   hakediş hesabı yok - `fn_telerad_fatura_rol` raporlayan payını
            //   adede göre dağıtıp mevcut prim hattını çalıştırıyor.
            var rolSayisi = await baglanti.TekDegerAsync<int>(
                "select public.fn_telerad_fatura_rol(@p0)", null, [belgeId], iptal);

            // DIŞ RADYOLOG DA PAY ALIR (808): "dış hekim yalnız Gönderen
            //   rolünde prim alabilir" kuralı, dış hekimin hasta GÖNDEREN
            //   taraf olduğu varsayımıyla yazılmıştı. Teleradyolojide işi
            //   dışarıdan çalışan radyolog YAPIYOR - kural daraltıldı
            //   (Gönderen + Raporlayan), burada ayrı bir istisna kalmadı.

            await log.YazAsync(LogIslemi.Ekle, LogTabloTeleradFatura, belgeId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.KurumId, donem, satir = satirlar.Count, isaretlenen, rolSayisi },
                iptal: iptal);

            return Results.Ok(new
            {
                belgeId, satir = satirlar.Count, istek = isaretlenen,
                // RAPORLAYAN PAYI (807): kaç satıra rol yazıldı - hiç
                //   yazılmadıysa (0) radyolog atanmamış demektir, ekranda
                //   görünsün.
                raporlayanPayi = rolSayisi,
                tutar = ozet.Toplam, uyarilar, izlemeNo = baglam.IzlemeNo,
            });
        });
    }

    /// <summary>islem_log.tablo_id — teleradyoloji dönem faturası.</summary>
    private const int LogTabloTeleradFatura = 1325;

    private sealed record FaturaSatiri(
        int HizmetId, string HizmetAdi, decimal Kdv, decimal BirimFiyat,
        bool SlaAsildi, int Adet, decimal Tutar, decimal CezaOrani,
        // HANGİ İŞLER BU SATIRDA: raporlayan payı (807) satır bazında
        //   dağıtılıyor - "bu satırı kim okudu" sorusu tahminle değil, işin
        //   kendi kaydıyla cevaplanmalı.
        int[] Istekler);

    private sealed record FaturaOzeti(
        int TarafId, string KurumAdi, string Vkno, string Vd, short UcretModeli,
        decimal CezaOrani, IReadOnlyList<FaturaSatiri> Satirlar,
        IReadOnlyList<object> Eksikler, int[] IstekIdler, decimal Toplam);

    /// <summary>
    /// Dönemin özeti: satırlar, faturaya giremeyenler ve sözleşme bilgisi.
    /// Önizleme ile üretim AYNI sorguyu kullanır - ekranda gördüğü ile
    /// faturaya giren farklı olmasın.
    /// </summary>
    private static async Task<FaturaOzeti> OzetAsync(
        Npgsql.NpgsqlConnection baglanti, int kurumId, DateTime baslangic,
        DateTime bitis, CancellationToken iptal)
    {
        var kurum = await baglanti.TekAsync("""
            select k.taraf_id as "tarafId", coalesce(t.unvan, '') as unvan,
                   coalesce(t.vkno, '') as vkno, coalesce(t.vd, '') as vd,
                   -- DÖNEMDE GEÇERLİ SÖZLEŞME: ücret modeli ve ceza oranı
                   --   oradan okunur (istekteki ücret zaten kopyalanmıştı).
                   coalesce((select s.ucret_modeli from public.telerad_sozlesme s
                              where s.kurum_id = k.id and s.durum = 1
                                and s.baslangic <= @p2
                                and (s.bitis is null or s.bitis >= @p1)
                              order by s.baslangic desc limit 1), 1) as "ucretModeli",
                   coalesce((select s.sla_ceza_oran from public.telerad_sozlesme s
                              where s.kurum_id = k.id and s.durum = 1
                                and s.baslangic <= @p2
                                and (s.bitis is null or s.bitis >= @p1)
                              order by s.baslangic desc limit 1), 0) as "cezaOrani"
              from public.telerad_kurum k
              left join public.taraf t on t.id = k.taraf_id
             where k.id = @p0
            """, null, [kurumId, baslangic, bitis], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Teleradyoloji kurumu bulunamadı.");

        var cezaOrani = Convert.ToDecimal(kurum["cezaOrani"] ?? 0m);

        var ham = await baglanti.ListeAsync(SatirSql, null, [kurumId, baslangic, bitis],
                                            OkuyucuGenisletmeleri.Sozluk, iptal);

        var satirlar = ham.Select(x => new FaturaSatiri(
            HizmetId: Convert.ToInt32(x["hizmetId"]),
            HizmetAdi: (string)(x["hizmetAdi"] ?? ""),
            Kdv: Convert.ToDecimal(x["kdv"] ?? 0m),
            BirimFiyat: Convert.ToDecimal(x["birimFiyat"] ?? 0m),
            SlaAsildi: (bool)(x["slaAsildi"] ?? false),
            Adet: Convert.ToInt32(x["adet"] ?? 0),
            Tutar: Convert.ToDecimal(x["tutar"] ?? 0m),
            // Ceza YALNIZ süresi kaçan satıra: zamanında biten işten indirim
            //   yapmak sözleşmeye aykırı olurdu.
            CezaOrani: (bool)(x["slaAsildi"] ?? false) ? cezaOrani : 0m,
            Istekler: (int[])(x["istekler"] ?? Array.Empty<int>()))).ToList();

        var idler = satirlar.SelectMany(x => x.Istekler).ToArray();

        var eksikler = await baglanti.ListeAsync(EksikSql, null,
            [kurumId, baslangic, bitis], OkuyucuGenisletmeleri.Sozluk, iptal);

        return new FaturaOzeti(
            TarafId: Convert.ToInt32(kurum["tarafId"]),
            KurumAdi: (string)(kurum["unvan"] ?? ""),
            Vkno: (string)(kurum["vkno"] ?? ""),
            Vd: (string)(kurum["vd"] ?? ""),
            UcretModeli: Convert.ToInt16(kurum["ucretModeli"] ?? (short)1),
            CezaOrani: cezaOrani,
            Satirlar: satirlar,
            Eksikler: eksikler.Cast<object>().ToList(),
            IstekIdler: idler,
            Toplam: satirlar.Sum(s => s.Tutar));
    }
}
