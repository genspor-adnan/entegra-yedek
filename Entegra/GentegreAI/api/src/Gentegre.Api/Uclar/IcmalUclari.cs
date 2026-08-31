using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KURUM DÖNEM İCMALİ (289) - SGK payının toplu faturalanması.
///
/// SGK payı tek tek faturalanmaz: dönem sonunda o kuruma ait tüm açık kurum
/// payları toplanır ve TEK fatura kesilir. İcmal, hangi başvurunun hangi
/// faturada olduğunu tutar; satırların kurum payı ancak fatura kesilince
/// kapanır.
/// </summary>
public static class IcmalUclari
{
    /// <summary>islem_log.tablo_id - icmal.</summary>
    private const int LogTabloIcmal = 943;

    public sealed record IcmalIstegi(int KurumId, DateTime DonemBas, DateTime DonemBit,
                                     string? Aciklama);

    /// <summary>
    /// DÖNEMDE FATURALANACAK SATIR ölçüsü. Önizleme ile icmal oluşturma AYNI
    /// kümeyi görmek ZORUNDA: filtre iki yerde ayrı yazıldığında biri
    /// güncellenip diğeri unutulursa kullanıcı önizlemede gördüğünden başkasını
    /// faturalar.
    ///
    /// Kurallar: kesin belge (durum 0), dönem içinde, kurum payı henüz
    /// kapanmamış, satır KAYNAK satır (pay = 0 - hasta tahakkuku / kurum
    /// faturası gibi türetilmiş pay satırları ikinci kez faturalanamaz) ve
    /// satır başka bir icmalde değil.
    ///
    /// Parametre sırası SABİT: @p0 kurum, @p1 dönem başı, @p2 dönem sonu.
    /// </summary>
    private const string AcikKurumPayiKosulu = """
                 where bb.odeyen_kurum_id = @p0
                   and b.durum = 0
                   and b.belge_tarihi >= @p1 and b.belge_tarihi < (@p2::date + 1)
                   and s.kurum_tutar > s.kurum_kapatilan
                   and coalesce(s.pay, 0) = 0
                   and not exists (select 1 from public.kurum_icmal_satir ks
                                    where ks.belge_satir_id = s.id)
        """;

    public static void IcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kurum-icmal").WithTags("Kurum İcmali").RequireAuthorization();

        // ------------------------------------------------------- önizleme ----
        // "Bu dönemde ne faturalanacak" sorusunun cevabı: icmal oluşturmadan
        //   önce tutar ve satır sayısı görülsün.
        grup.MapGet("/onizleme", async (
            int kurumId, DateTime donemBas, DateTime donemBit,
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kurum", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var satirlar = await baglanti.ListeAsync("""
                select s.id as "satirId", b.id as "belgeId", b.belge_no as "belgeNo",
                       b.belge_tarihi as "belgeTarihi",
                       coalesce(h.unvan, '') as "hasta",
                       coalesce(hz.ad, st.ad, '') as "kalem",
                       s.tutar, s.kurum_tutar as "kurumTutar",
                       s.kurum_kapatilan as "kurumKapatilan",
                       (s.kurum_tutar - s.kurum_kapatilan) as "kalan"
                  from public.belge_satir s
                  join public.belge b on b.id = s.belge_id
                  join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf  h  on h.id  = b.taraf_id
                  left join public.hizmet hz on hz.id = s.hizmet_id
                  left join public.stok   st on st.id = s.stok_id
                """ + AcikKurumPayiKosulu + """
                 order by b.belge_tarihi, b.id, s.sira
                """, null, [kurumId, donemBas, donemBit], Satir, iptal);

            return Results.Ok(new
            {
                satirlar,
                toplam = satirlar.Sum(x => Convert.ToDecimal(x["kalan"] ?? 0m)),
            });
        });

        // -------------------------------------------------- icmal oluştur ----
        grup.MapPost("/", async (
            IcmalIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kurum", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var icmalId = await baglanti.TekDegerAsync<int>("""
                insert into public.kurum_icmal (kurum_id, donem_bas, donem_bit, durum,
                                                aciklama, sube_id, ekleyen)
                values (@p0, @p1, @p2, 1, @p3, @p4, @p5)
                returning id
                """, islem,
                [istek.KurumId, istek.DonemBas, istek.DonemBit, istek.Aciklama ?? "",
                 baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

            // Satırlar TEK sorguyla toplanır: aynı satır iki icmale giremez
            //   (ux_kurum_icmal_satir); yarış durumunda ikinci istek düşer.
            // Parametre sırası koşulun beklediği gibi (kurum, dönem başı, dönem
            //   sonu); icmal kimliği SONA alındı ki filtre önizlemeyle harfiyen
            //   aynı metin olsun.
            var adet = await baglanti.CalistirAsync("""
                insert into public.kurum_icmal_satir (icmal_id, belge_satir_id, tutar)
                select @p3, s.id, s.kurum_tutar - s.kurum_kapatilan
                  from public.belge_satir s
                  join public.belge b on b.id = s.belge_id
                  join public.belge_basvuru bb on bb.id = b.id
                """ + AcikKurumPayiKosulu,
                islem, [istek.KurumId, istek.DonemBas, istek.DonemBit, icmalId], iptal);

            if (adet == 0)
                throw GentegreHatasi.IsKurali(
                    "Bu dönemde faturalanacak açık kurum payı bulunamadı.");

            await baglanti.CalistirAsync("""
                update public.kurum_icmal
                   set toplam = coalesce((select sum(tutar) from public.kurum_icmal_satir
                                           where icmal_id = @p0), 0)
                 where id = @p0
                """, islem, [icmalId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloIcmal, icmalId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["satir"] = adet.ToString() }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { icmalId, satir = adet });
        });

        // ------------------------------------------------------- faturala ----
        // İcmal TEK faturaya döner; cari KURUMDUR. Satırlar kalem kalem
        //   yazılır ki kurum icmalde neyin parasını ödediğini görsün.
        grup.MapPost("/{id:int}/faturala", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, BelgeDeposu belgeDepo,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);

            var icmal = await baglanti.TekAsync("""
                select i.id, i.kurum_id as "kurumId", i.durum, i.toplam,
                       i.donem_bas as "donemBas", i.donem_bit as "donemBit",
                       coalesce(t.unvan, '') as "kurumAdi", i.sube_id as "subeId"
                  from public.kurum_icmal i
                  left join public.taraf t on t.id = i.kurum_id
                 where i.id = @p0
                """, null, [id], Satir, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İcmal bulunamadı.");

            if (Convert.ToInt32(icmal["durum"] ?? 0) != 1)
                throw GentegreHatasi.IsKurali("Yalnız hazırlanan icmal faturalanabilir.");

            var kalemler = await baglanti.ListeAsync("""
                select ks.belge_satir_id as "satirId", ks.tutar,
                       s.hizmet_id as "hizmetId", s.stok_id as "stokId", s.kdv,
                       coalesce(hz.ad, st.ad, '') as "ad", b.belge_no as "belgeNo"
                  from public.kurum_icmal_satir ks
                  join public.belge_satir s on s.id = ks.belge_satir_id
                  join public.belge b on b.id = s.belge_id
                  left join public.hizmet hz on hz.id = s.hizmet_id
                  left join public.stok   st on st.id = s.stok_id
                 where ks.icmal_id = @p0 order by ks.id
                """, null, [id], Satir, iptal);

            if (kalemler.Count == 0)
                throw GentegreHatasi.IsKurali("İcmalde satır yok.");

            // Fatura gövdesi: her icmal satırı bir kalem; kaynak bağı
            //   (kaynak_tur 30 + pay 2) kurum payını kapatır.
            var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 15,
                ["tarafId"] = icmal["kurumId"],
                ["tarafUnvan"] = icmal["kurumAdi"],
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["kdvDurum"] = "Haric",
                ["subeId"] = icmal["subeId"],
                ["aciklama"] = $"Dönem icmali: {Convert.ToDateTime(icmal["donemBas"]):dd.MM.yyyy}"
                             + $" – {Convert.ToDateTime(icmal["donemBit"]):dd.MM.yyyy}",
            };

            var satirlar = new List<Dictionary<string, System.Text.Json.JsonElement>>();
            var sira = 1;
            foreach (var k in kalemler)
            {
                var tutar = Convert.ToDecimal(k["tutar"] ?? 0m);
                var govde = new Dictionary<string, object?>
                {
                    ["tur"] = k["hizmetId"] is not null ? 2 : 1,
                    ["hizmetId"] = k["hizmetId"],
                    ["stokId"] = k["stokId"],
                    ["aciklama"] = $"{k["ad"]} · {k["belgeNo"]}",
                    ["adet"] = 1m,
                    ["miktar"] = 1m,
                    ["birimFiyat"] = tutar,
                    ["kdv"] = k["kdv"],
                    ["dovizCinsi"] = "TL",
                    ["kaynakTur"] = 30,
                    ["kaynakId"] = k["satirId"],
                    // Kurum payını kapatan satır (289).
                    ["pay"] = 2,
                    ["kurumTutar"] = tutar,
                    ["hastaTutar"] = 0m,
                    ["sira"] = sira++,
                };
                var json = System.Text.Json.JsonSerializer.SerializeToElement(govde);
                var sozluk = new Dictionary<string, System.Text.Json.JsonElement>(StringComparer.Ordinal);
                foreach (var alan in json.EnumerateObject()) sozluk[alan.Name] = alan.Value;
                satirlar.Add(sozluk);
            }

            // Secenekler ZORUNLU: null gecilince kayit hatti "Taslak" bayragini
            //   okurken patliyor. Icmal faturasi KESIN belgedir.
            var (belgeId, uyarilar) = await belgeDepo.KaydetAsync(belge, satirlar,
                new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                baglam.Yazma, iptal);

            await baglanti.CalistirAsync("""
                update public.kurum_icmal
                   set durum = 2, belge_id = @p1, degistiren = @p2,
                       degistirme_tarihi = now()::timestamp
                 where id = @p0
                """, null, [id, belgeId, baglam.KullaniciId], iptal);

            return Results.Ok(new { belgeId, satir = kalemler.Count, uyarilar });
        });
    }

    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }
}
