using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BANKA HAREKETLERİ uçları (1157, mockup Ekranlar/ERP/banka_hareketleri.html). Liste genel liste
/// kaynağından (<c>banka-hareket</c>); burada çek / işle / yoksay ve özet şeridi.
/// <list type="bullet">
///   <item><c>GET  /api/banka-hareket/ozet?hesapId=</c> - sayaçlar, banka / sistem bakiyesi, son çekim.</item>
///   <item><c>POST /api/banka-hareket/cek</c> {hesapId?, bas?, bit?} - hesapId yoksa bağlı bütün hesaplar.</item>
///   <item><c>POST /api/banka-hareket/{id}/isle</c> {tur, tarafId, belgeId, hedefHesapId, masrafId, ibanEkle, kural} - karar yoksa öneri.</item>
///   <item><c>POST /api/banka-hareket/isle-toplu</c> {idler} - önerileriyle.</item>
///   <item><c>POST /api/banka-hareket/{id}/yoksay</c> · <c>/{id}/geri-al</c> (yoksayılanı bekleyene döndürür).</item>
///   <item><c>POST /api/banka-hareket/oneri-yenile</c> {hesapId?} - kural / IBAN değişince.</item>
/// </list>
/// Yetki <c>banka.hareket</c>: okuma Gör, çekme Ekle, işleme Değiştir (işlem kasa kaydı da yazar -
/// <c>kasa_islem</c> Ekle ayrıca istenir).
/// </summary>
public static class BankaHareketUclari
{
    private const string Kod = "banka.hareket";
    /// <summary>Olmayan ve kapsam dışı hareket aynı metni alır (K26).</summary>
    private const string HareketYok = "Hareket bulunamadı.";

    public sealed record CekIstegi(int? HesapId, DateTime? Bas, DateTime? Bit);
    public sealed record IsleIstegi(string? Tur, int? TarafId, int? BelgeId, int? HedefHesapId, int? MasrafId,
                                    bool? IbanEkle, string? Kural);
    public sealed record TopluIstegi(long[] Idler);
    public sealed record YenileIstegi(int? HesapId);

    public static void BankaHareketUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/banka-hareket").WithTags("Banka Hareketleri").RequireAuthorization();

        grup.MapGet("/ozet", async (int? hesapId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var sayac = await b.TekAsync("""
                select count(*)::int as cekilen,
                       count(*) filter (where durum in (0, 1, 4))::int as bekleyen,
                       count(*) filter (where durum = 1)::int as "oneriHazir",
                       count(*) filter (where durum = 4)::int as "secimBekleyen",
                       count(*) filter (where durum = 2)::int as islendi,
                       count(*) filter (where durum = 3)::int as yoksayilan,
                       coalesce(sum(tutar) filter (where durum in (0, 1, 4)), 0) as "bekleyenTutar"
                  from public.banka_hareket h
                 where (@p0::int is null or h.hesap_id = @p0) and h.sube_id = @p1
                """, null, [hesapId, baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);
            var hesap = hesapId is null ? null : await b.TekAsync("""
                select x.id, x.ad, coalesce(x.iban, '') as iban, coalesce(x.doviz_cinsi, 'TL') as doviz, x.banka_kaynak as kaynak,
                       x.banka_bakiye as "bankaBakiye", x.banka_son_cekim as "sonCekim", coalesce(x.banka_son_sonuc, '') as "sonSonuc",
                       x.banka_cekme_dk as "cekmeDk", x.banka_onay_bitis as "onayBitis", coalesce(e.ad, '') as entegrasyon,
                       coalesce(e.test_mi, 0) = 1 as test,
                       (select coalesce(sum(m.borc - m.alacak), 0) from public.mali_hareket m
                         where m.hesap_turu <> 'C' and m.hesap_id = x.id) as "sistemBakiye"
                  from public.hesap x left join public.entegrasyon_hesap e on e.id = x.banka_entegrasyon_id
                 where x.id = @p0
                """, null, [hesapId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var hesaplar = await b.ListeAsync("""
                select x.id, x.ad, coalesce(x.iban, '') as iban, x.banka_kaynak as kaynak
                  from public.hesap x where x.tur = 'B' and coalesce(x.durum, 1) = 1 and (x.sube_id is null or x.sube_id = @p0)
                 order by (x.banka_kaynak = 0), x.ad
                """, null, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { sayac, hesap, hesaplar });
        });

        // BANKA HESABI LİSTESİ özet şeridi (mockup): hesap · bağlı (API) · dosyadan · bekleyen · dikkat · toplam.
        //   Yetki listenin kendisi - bankadan hareket yetkisi olmayan da sayıları görür.
        grup.MapGet("/hesap-ozet", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hesap.tanim.banka.liste", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                with x as (
                    select h.id, h.banka_kaynak, coalesce(nullif(h.doviz_cinsi, ''), 'TL') as doviz,
                           coalesce(nullif(bk.ad, ''), nullif(h.banka_adi, ''), split_part(h.ad, '_', 1)) as banka,
                           (h.banka_kaynak = 1 and (h.banka_onay_bitis < current_date or h.banka_son_sonuc like 'Hata%')) as dikkat,
                           coalesce(vb.yerel_bakiye, 0) as yerel
                      from public.hesap h
                      left join public.banka bk on bk.id = h.banka_id
                      left join public.v_hesap_bakiye vb on vb.hesap_id = h.id
                     where h.tur = 'B' and coalesce(h.durum, 1) = 1 and (h.sube_id is null or h.sube_id = @p0))
                select count(*)::int as hesap,
                       count(*) filter (where doviz in ('TL', 'TRY'))::int as tl,
                       count(*) filter (where doviz not in ('TL', 'TRY'))::int as doviz,
                       count(*) filter (where banka_kaynak = 1)::int as api,
                       coalesce((select string_agg(banka || ' ' || n, ' · ') from (select banka, count(*) n from x
                                  where banka_kaynak = 1 group by banka order by count(*) desc, banka) a), '') as "apiBankalar",
                       count(*) filter (where banka_kaynak = 2)::int as dosya,
                       coalesce((select string_agg(distinct banka, ' · ') from x where banka_kaynak = 2), '') as "dosyaBankalar",
                       (select count(*)::int from public.banka_hareket bh join x on x.id = bh.hesap_id where bh.durum in (0, 1, 4)) as bekleyen,
                       count(*) filter (where dikkat)::int as dikkat,
                       coalesce(sum(yerel), 0) as toplam
                  from x
                """, null, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(o);
        });

        // Tek hareket: banka bilgisi, öneri, seçenekler (hesaplar / masraf kalemleri) - yan panel.
        grup.MapGet("/{id:long}", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var h = await b.TekAsync("""
                select h.id, h.hesap_id as "hesapId", h.hesap_ad as "hesapAd", h.banka_islem_no as "bankaIslemNo",
                       h.islem_tarihi as "islemTarihi", h.valor_tarihi as "valorTarihi", h.tutar, h.doviz_cinsi as "dovizCinsi",
                       h.bakiye, h.aciklama, h.karsi_ad as "karsiAd", h.karsi_iban as "karsiIban", h.karsi_vkn as "karsiVkn",
                       h.fatura_metni as "faturaMetni", h.sinif, h.durum, h.kaynak, coalesce(h.oneri::text, '{}') as oneri,
                       h.kasa_islem_id as "kasaIslemId", h.kasa_islem_no as "kasaIslemNo", h.sube_id as "subeId"
                  from public.v_banka_hareket h where h.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
            if (baglam.SubeId is { } s && Convert.ToInt32(h["subeId"]) != s) throw GentegreHatasi.Bulunamadi("Hareket bulunamadı.");
            h["oneri"] = System.Text.Json.JsonDocument.Parse(Convert.ToString(h["oneri"]) ?? "{}").RootElement.Clone();
            var hesaplar = await b.ListeAsync("""
                select x.id, x.ad, x.tur from public.hesap x
                 where x.tur in ('K', 'B', 'P') and coalesce(x.durum, 1) = 1 and (x.sube_id is null or x.sube_id = @p0)
                 order by x.tur, x.ad
                """, null, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);
            var masraflar = await b.ListeAsync(
                "select id, ad from public.v_masraf_lookup where coalesce(aktif, 1) = 1 order by ad", null, [],
                OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { hareket = h, hesaplar, masraflar });
        });

        grup.MapPost("/cek", async (CekIstegi i, BankaHareketServisi servis, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Ekle);
            var idler = i.HesapId is { } tek ? [tek] : await veri.ListeAsync(
                "select id from public.hesap where tur = 'B' and banka_kaynak = 1 and (sube_id is null or sube_id = @p0) order by id",
                [baglam.SubeId ?? 0], o => o.GetInt32(0), iptal);
            var sonuclar = new List<object>();
            foreach (var id in idler)
            {
                try { sonuclar.Add(await servis.CekAsync(id, i.Bas, i.Bit, baglam.KullaniciId, iptal)); }
                catch (GentegreHatasi hata) when (i.HesapId is null) { sonuclar.Add(new { hesap = id, hata = hata.Message }); }
            }
            return Results.Ok(new { sonuclar });
        });

        grup.MapPost("/{id:long}/isle", async (long id, IsleIstegi i, BankaHareketServisi servis, BaglamCozucu cozucu,
            KayitErisimi erisim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);
            // KAYIT KAPSAMI (K26): hareket aktif şubenin olmalı (liste kuralı).
            await erisim.IsteAsync(baglam, "banka-hareket", id, HareketYok, iptal);
            var karar = string.IsNullOrEmpty(i.Tur) ? null
                : new BankaHareketServisi.Karar(i.Tur, i.TarafId, i.BelgeId, i.HedefHesapId, i.MasrafId, i.IbanEkle ?? false, i.Kural);
            var kasaId = await servis.IsleAsync(id, karar, baglam.KullaniciId, baglam.SubeId ?? 0, iptal);
            return Results.Ok(new { kasaIslemId = kasaId });
        });

        grup.MapPost("/isle-toplu", async (TopluIstegi i, BankaHareketServisi servis, BaglamCozucu cozucu,
            KayitErisimi erisim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);
            int islenen = 0; var hatalar = new List<string>();
            foreach (var id in i.Idler.Distinct())
            {
                try
                {
                    // KAYIT KAPSAMI (K26): şube dışı kimlik hata listesine düşer, ötekiler sürer.
                    await erisim.IsteAsync(baglam, "banka-hareket", id, HareketYok, iptal);
                    await servis.OneriyiIsleAsync(id, baglam.KullaniciId, baglam.SubeId ?? 0, iptal); islenen++;
                }
                catch (GentegreHatasi h) { hatalar.Add($"#{id}: {h.Message}"); }
            }
            return Results.Ok(new { islenen, hatalar });
        });

        grup.MapPost("/{id:long}/yoksay", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            // KAYIT KAPSAMI (K26): hareket aktif şubenin olmalı.
            await erisim.IsteAsync(baglam, "banka-hareket", id, HareketYok, iptal);
            var n = await veri.CalistirAsync("""
                update public.banka_hareket set durum = 3, isleyen = @p1, isleme_zamani = now()
                 where id = @p0 and durum in (0, 1, 4)
                """, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız işlenmemiş hareket yoksayılır.");
            return Results.Ok(new { tamam = true });
        });

        grup.MapPost("/{id:long}/geri-al", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            // KAYIT KAPSAMI (K26): hareket aktif şubenin olmalı.
            await erisim.IsteAsync(baglam, "banka-hareket", id, HareketYok, iptal);
            var n = await veri.CalistirAsync("""
                update public.banka_hareket set durum = 0, isleyen = null, isleme_zamani = null where id = @p0 and durum = 3
                """, [id], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız yoksayılan hareket geri alınır - işlenmiş hareket için kasa işlemini iptal edin.");
            await veri.CalistirAsync("select public.fn_banka_oneri(@p0)", [id], iptal);
            return Results.Ok(new { tamam = true });
        });

        grup.MapPost("/oneri-yenile", async (YenileIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            var n = await veri.TekDegerAsync<int>("select public.fn_banka_oneri_yenile(@p0)", [i.HesapId], iptal);
            return Results.Ok(new { yenilenen = n });
        });
    }
}

/// <summary>
/// OTOMATİK ÇEKME (1157): beş dakikada bir, "Banka API" kaynaklı ve çekme sıklığı verilmiş hesaplardan
/// süresi dolanları (son çekimden bu yana ≥ sıklık) 08:00-20:00 arasında çeker. Hata hesabın
/// "son sonuç"una yazılır, öteki hesaplar sürer.
/// </summary>
public sealed class BankaCekmeIscisi(IServiceProvider servisler, ILogger<BankaCekmeIscisi> gunluk) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        await Task.Delay(TimeSpan.FromSeconds(90), iptal).ContinueWith(_ => { }, CancellationToken.None);
        while (!iptal.IsCancellationRequested)
        {
            try { await TurAsync(iptal); }
            catch (OperationCanceledException) when (iptal.IsCancellationRequested) { break; }
            catch (Exception h) { gunluk.LogError(h, "Banka çekme turu hata verdi."); }
            await Task.Delay(TimeSpan.FromMinutes(5), iptal).ContinueWith(_ => { }, CancellationToken.None);
        }
    }

    private async Task TurAsync(CancellationToken iptal)
    {
        var saat = Gentegre.Cekirdek.Saat.Simdi.Hour;
        if (saat < 8 || saat >= 20) return;
        await using var kapsam = servisler.CreateAsyncScope();
        var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();
        var servis = kapsam.ServiceProvider.GetRequiredService<BankaHareketServisi>();
        var hesaplar = await veri.ListeAsync("""
            select id from public.hesap
             where tur = 'B' and banka_kaynak = 1 and banka_cekme_dk > 0 and banka_entegrasyon_id is not null
               and (banka_son_cekim is null or banka_son_cekim <= now() - make_interval(mins => banka_cekme_dk))
            """, [], o => o.GetInt32(0), iptal);
        foreach (var id in hesaplar)
        {
            try { await servis.CekAsync(id, null, null, 0, iptal); }
            catch (Exception h) { gunluk.LogWarning("Banka hesabı {Id} çekilemedi: {Mesaj}", id, h.Message); }
        }
    }
}
