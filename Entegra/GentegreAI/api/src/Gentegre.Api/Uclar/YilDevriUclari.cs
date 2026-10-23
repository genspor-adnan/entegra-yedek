using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// YIL SONU / YIL BAŞI DEVRİ (1155, mockup Ekranlar/Muhasebe/yil_sonu_devir.html).
///
/// <para>Beş adım, sıralı; iş kuralları veritabanında (fn_yil_devri_*). Uçlar:</para>
/// <list type="bullet">
///   <item><c>GET  /api/yil-devri?yil=</c> - devir durumu, günlük, adımın ürettiği kayıt sayıları.</item>
///   <item><c>GET  /api/yil-devri/kontrol?yil=</c> - ön kontrol listesi (yalnız okur).</item>
///   <item><c>GET  /api/yil-devri/degerleme?yil=</c> - dövizli hesaplar ve kur farkı.</item>
///   <item><c>POST /api/yil-devri/onizle</c> - adımı GERÇEK fonksiyonla çalıştırır, ürettiği fişleri
///         okur, işlemi GERİ ALIR (ROLLBACK). Önizleme ile kesilecek fiş aynı koddan çıkar.</item>
///   <item><c>POST /api/yil-devri/adim</c> - adımı yürütür. <c>POST /api/yil-devri/geri-al</c> - son adımı geri alır.</item>
/// </list>
/// <para>Kapsam oturumun şubesi. Yetki <c>muhasebe.yil_devri</c>: okuma Gör, yürütme Değiştir.</para>
/// </summary>
public static class YilDevriUclari
{
    private const string Kod = "muhasebe.yil_devri";

    public sealed record AdimIstegi(short Yil, short Adim, bool? Cari, bool? Hesap, bool? Bilanco, bool? Izin, bool? Kilit);
    public sealed record GeriIstegi(short Yil);

    public static void YilDevriUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/yil-devri").WithTags("Yıl Devri").RequireAuthorization();

        grup.MapGet("/", async (short? yil, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var kaynak = yil ?? (short)(Saat.Bugun.Month <= 6 ? Saat.Bugun.Year - 1 : Saat.Bugun.Year);
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(await DurumAsync(b, null, baglam.SubeId ?? 0, kaynak, iptal));
        });

        grup.MapGet("/kontrol", async (short yil, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(await b.ListeAsync("""
                select sira, kod, ad, tur, adet, tutar, aciklama, rota
                  from public.fn_yil_devri_kontrol(@p0, @p1::smallint) order by sira
                """, null, [baglam.SubeId ?? 0, yil], OkuyucuGenisletmeleri.Sozluk, iptal));
        });

        grup.MapGet("/degerleme", async (short yil, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(await b.ListeAsync("""
                select kaynak, kaynak_id as "kaynakId", ad, alt, doviz, doviz_bakiye as "dovizBakiye",
                       yerel_bakiye as "yerelBakiye", kur, degerli, fark,
                       (select kod || ' ' || ad from public.hesap_plani where id = x.hesap_plani_id) as hesap
                  from public.fn_yil_devri_degerleme(@p0, @p1::smallint) x
                 order by kaynak, abs(fark) desc
                """, null, [baglam.SubeId ?? 0, yil], OkuyucuGenisletmeleri.Sozluk, iptal));
        });

        // ÖNİZLEME: adım gerçek fonksiyonla çalışır, üretilenler okunur, ROLLBACK.
        grup.MapPost("/onizle", async (AdimIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var devir = await DevirAcAsync(b, islem, baglam.SubeId ?? 0, i.Yil, baglam.KullaniciId, iptal);
            await AdimCalistirAsync(b, islem, devir, i, baglam.KullaniciId, iptal);
            var fisler = await FislerAsync(b, islem, devir, i.Adim, iptal);
            var kayitlar = await b.ListeAsync("""
                select tur, count(*)::int as adet from public.yil_devri_kayit
                 where devir_id = @p0 and adim = @p1 and tur <> 'fis' group by tur
                """, islem, [devir, i.Adim], o => new { tur = o.GetString(0), adet = o.GetInt32(1) }, iptal);
            var sablonlar = i.Adim == 4 ? await b.ListeAsync("""
                select s.tur, coalesce(t.ad, s.tur::text) as "turAdi", s.on_ek as "onEk", s.baslama_no as "baslamaNo",
                       (select x.baslama_no from public.numara_sablonu x
                         where x.tur = s.tur and coalesce(x.sube_id, 0) = coalesce(s.sube_id, 0) and x.id <> s.id
                         order by x.baslama_tarihi desc, x.id desc limit 1) as "eskiNo"
                  from public.yil_devri_kayit k
                  join public.numara_sablonu s on s.id = k.kayit_id
                  left join public.kasa_islem_turu t on t.kod = s.tur
                 where k.devir_id = @p0 and k.adim = 4 and k.tur = 'numara_sablonu' order by s.tur
                """, islem, [devir], OkuyucuGenisletmeleri.Sozluk, iptal) : [];
            await islem.RollbackAsync(iptal);
            return Results.Ok(new { fisler, kayitlar, sablonlar });
        });

        grup.MapPost("/adim", async (AdimIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var devir = await DevirAcAsync(b, islem, baglam.SubeId ?? 0, i.Yil, baglam.KullaniciId, iptal);
            await AdimCalistirAsync(b, islem, devir, i, baglam.KullaniciId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(await DurumAsync(b, null, baglam.SubeId ?? 0, i.Yil, iptal));
        });

        grup.MapPost("/geri-al", async (GeriIstegi i, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var devir = await b.TekDegerAsync<int?>(
                "select id from public.yil_devri where sube_id = @p0 and kaynak_yil = @p1",
                null, [baglam.SubeId ?? 0, i.Yil], iptal)
                ?? throw GentegreHatasi.IsKurali("Bu yıl için başlatılmış devir yok.");
            await b.CalistirAsync("select public.fn_yil_devri_geri_al(@p0, @p1)", null, [devir, baglam.KullaniciId], iptal);
            return Results.Ok(await DurumAsync(b, null, baglam.SubeId ?? 0, i.Yil, iptal));
        });
    }

    /// <summary>Şube + yıl devrini döndürür; yoksa açar (ilk adım).</summary>
    private static async Task<int> DevirAcAsync(NpgsqlConnection b, NpgsqlTransaction islem, int sube, short yil,
        int kullanici, CancellationToken iptal)
    {
        if (sube <= 0) throw GentegreHatasi.IsKurali("Yıl devri bir şube için yapılır - şube seçin.");
        return await b.TekDegerAsync<int>("""
            insert into public.yil_devri (sube_id, kaynak_yil, hedef_yil, baslatan)
            values (@p0, @p1, @p1 + 1, @p2)
            on conflict (sube_id, kaynak_yil) do update set kaynak_yil = excluded.kaynak_yil
            returning id
            """, islem, [sube, yil, kullanici], iptal);
    }

    private static Task AdimCalistirAsync(NpgsqlConnection b, NpgsqlTransaction islem, int devir, AdimIstegi i,
        int kullanici, CancellationToken iptal) => i.Adim switch
    {
        1 => b.CalistirAsync("select public.fn_yil_devri_adim1(@p0, @p1)", islem, [devir, kullanici], iptal),
        2 => b.CalistirAsync("select public.fn_yil_devri_adim2(@p0, @p1, @p2, @p3)", islem,
                             [devir, kullanici, i.Cari ?? true, i.Hesap ?? true], iptal),
        3 => b.CalistirAsync("select public.fn_yil_devri_adim3(@p0, @p1, @p2)", islem,
                             [devir, kullanici, i.Bilanco ?? true], iptal),
        4 => b.CalistirAsync("select public.fn_yil_devri_adim4(@p0, @p1, @p2)", islem,
                             [devir, kullanici, i.Izin ?? true], iptal),
        5 => b.CalistirAsync("select public.fn_yil_devri_adim5(@p0, @p1, @p2)", islem,
                             [devir, kullanici, i.Kilit ?? true], iptal),
        _ => throw GentegreHatasi.Dogrulama("Adım 1-5 olmalı."),
    };

    /// <summary>Adımın kestiği fişler, hesap bazında satırlarıyla.</summary>
    private static async Task<List<object>> FislerAsync(NpgsqlConnection b, NpgsqlTransaction? islem, int devir,
        short adim, CancellationToken iptal)
    {
        var basliklar = await b.ListeAsync("""
            select f.id, f.fis_no, f.fis_tarihi, f.tur, f.aciklama, f.toplam_borc, f.toplam_alacak
              from public.yil_devri_kayit k join public.muhasebe_fis f on f.id = k.kayit_id
             where k.devir_id = @p0 and k.adim = @p1 and k.tur = 'fis' order by f.id
            """, islem, [devir, adim], o => (id: o.GetInt32(0), no: o.GetString(1), tarih: o.GetDateTime(2),
                tur: o.GetInt16(3), aciklama: o.GetString(4), borc: o.GetDecimal(5), alacak: o.GetDecimal(6)), iptal);
        var sonuc = new List<object>();
        foreach (var f in basliklar)
        {
            var satirlar = await b.ListeAsync("""
                select h.kod, h.ad, sum(s.borc) as borc, sum(s.alacak) as alacak, count(*)::int as adet
                  from public.muhasebe_fis_satir s join public.hesap_plani h on h.id = s.hesap_plani_id
                 where s.fis_id = @p0 group by h.kod, h.ad order by h.kod
                """, islem, [f.id], OkuyucuGenisletmeleri.Sozluk, iptal);
            sonuc.Add(new { adim, f.id, fisNo = f.no, tarih = f.tarih, f.tur, f.aciklama, f.borc, f.alacak, satirlar });
        }
        return sonuc;
    }

    private static async Task<object> DurumAsync(NpgsqlConnection b, NpgsqlTransaction? islem, int sube, short yil,
        CancellationToken iptal)
    {
        var devir = await b.TekAsync("""
            select d.id, d.kaynak_yil as "kaynakYil", d.hedef_yil as "hedefYil", d.tamam_adim as "tamamAdim",
                   d.durum, d.secenekler::text as secenekler, d.baslama, d.bitis,
                   coalesce((select coalesce(nullif(t.ad || ' ' || coalesce(t.soyad, ''), ' '), t.unvan)
                               from public.taraf t where t.id = d.baslatan), '') as baslatan
              from public.yil_devri d where d.sube_id = @p0 and d.kaynak_yil = @p1
            """, islem, [sube, yil], OkuyucuGenisletmeleri.Sozluk, iptal);
        var donem = await b.ListeAsync("""
            select yil, durum from public.mali_donem where sube_id = @p0 and yil in (@p1, @p1 + 1)
            """, islem, [sube, yil], o => new { yil = o.GetInt16(0), durum = o.GetInt16(1) }, iptal);
        if (devir is null) return new { yil, devir = (object?)null, gunluk = Array.Empty<object>(), fisler = Array.Empty<object>(), donem };

        var id = Convert.ToInt32(devir["id"]);
        devir["secenekler"] = JsonDocument.Parse(Convert.ToString(devir["secenekler"]) ?? "{}").RootElement.Clone();
        var gunluk = await b.ListeAsync("""
            select g.adim, g.islem, g.aciklama, g.zaman,
                   coalesce((select coalesce(nullif(t.ad || ' ' || coalesce(t.soyad, ''), ' '), t.unvan)
                               from public.taraf t where t.id = g.kullanici_id), '') as kullanici
              from public.yil_devri_gunluk g where g.devir_id = @p0 order by g.id desc
            """, islem, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
        var fisler = new List<object>();
        for (short a = 2; a <= 5; a++) fisler.AddRange(await FislerAsync(b, islem, id, a, iptal));
        return new { yil, devir, gunluk, fisler, donem };
    }
}
