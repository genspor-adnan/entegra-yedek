using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DELPHI AKTARIMI (1086, dokuman/18 §11) - müşteri sunucusundaki ajanın uçları.
/// Kimlik oturum değil MAKİNE ANAHTARI: <c>X-Aktarim-Anahtar</c> başlığı,
/// aktarim_ajan.anahtar_ozet (sha256) ile eşleşir. Sıra, savepoint, hata kuyruğu
/// ve CT versiyonu <c>fn_aktar_paket</c>'te; uç yalnız kimlik + boyut + hata çevirisi.
/// </summary>
public static class AktarimUclari
{
    private const string AnahtarBasligi = "X-Aktarim-Anahtar";

    /// <summary>
    /// Varsayılan paket sınırı. Ayar <c>Aktarim:PaketSiniriMb</c> ile değişir - önündeki
    /// vekilin (nginx client_max_body_size) altında tutulursa 413'ü API verir, ajan
    /// sayfayı yarılar. İlk yükleme sayfalı gelir; tek paket bundan büyükse ajan böler.
    /// </summary>
    public const long PaketSiniri = 64L * 1024 * 1024;

    public static void AktarimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/aktarim").WithTags("Delphi aktarımı (ajan)").AllowAnonymous();
        var mb = yol.ServiceProvider.GetRequiredService<IConfiguration>().GetValue<int?>("Aktarim:PaketSiniriMb");
        var sinir = mb is > 0 ? mb.Value * 1024L * 1024 : PaketSiniri;

        // Ajan kaldığı yeri sorar: tablo başına son uygulanan CT versiyonu, hareket sınırı, açık hatalar.
        grup.MapGet("/durum", async (HttpContext ctx, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            var ajan = await AjanAsync(b, ctx, iptal);
            await b.CalistirAsync("update public.aktarim_ajan set son_nabiz = now(), surum = coalesce(@p1, surum) where id = @p0",
                                  null, [ajan, Kirp(ctx.Request.Headers["X-Aktarim-Surum"].ToString(), 40)], iptal);
            var json = await b.TekDegerAsync<string>("""
                select json_build_object(
                  'hareket_baslangic', (select deger from public.aktarim_ayar where anahtar = 'hareket_baslangic'),
                  'tablolar', (select coalesce(json_agg(json_build_object('tablo', d.tablo, 'versiyon', d.versiyon,
                                                                          'son_paket', d.son_paket) order by d.tablo), '[]')
                                 from public.aktarim_durum d),
                  'adimlar', (select json_agg(json_build_object('sira', a.sira, 'fonksiyon', a.fonksiyon,
                                                                'tablolar', a.tablolar) order by a.sira)
                                from public.fn_aktarim_adimlari() a),
                  'hatalar', (select coalesce(json_agg(json_build_object('adim', h.adim, 'tablolar', h.tablolar,
                                                                         'mesaj', h.mesaj, 'deneme', h.deneme,
                                                                         'son_zaman', h.son_zaman) order by h.id), '[]')
                                from public.aktarim_hata h where h.cozulme is null),
                  -- Ajan Delphi'den YALNIZ bu kolonları okur (stg şeması = fn_aktar_*'ın tanıdığı kolonlar).
                  --   Tablo adı ASCII küçültülür: tr-TR ICU'da lower('FATBASLIK') = 'fatbaslık'.
                  'kolonlar', (select json_object_agg(t.tablo, (select json_agg(c.column_name::text order by c.ordinal_position)
                                                                  from information_schema.columns c
                                                                 where c.table_schema = 'stg'
                                                                   and c.table_name = lower(t.tablo collate "C")))
                                 from (select unnest(a.tablolar) tablo from public.fn_aktarim_adimlari() a) t))::text
                """, null, [], iptal);
            return Results.Content(json, "application/json; charset=utf-8");
        });

        // Silinen alt satırın üstü (1087): {FATURA: [id]} -> {FATBASLIK: [id]}. Ajan üstü toplamıyla yeniden yollar.
        grup.MapPost("/ust", async (HttpContext ctx, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            await AjanAsync(b, ctx, iptal);
            string govde;
            using (var okuyucu = new StreamReader(ctx.Request.Body))
                govde = await okuyucu.ReadToEndAsync(iptal);
            try
            {
                var json = await b.TekDegerAsync<string>("select public.fn_aktarim_ust(@p0::jsonb)::text", null,
                                                         [string.IsNullOrWhiteSpace(govde) ? "{}" : govde], iptal);
                return Results.Content(json ?? "{}", "application/json; charset=utf-8");
            }
            catch (PostgresException pg) when (pg.SqlState == PostgresErrorCodes.InvalidTextRepresentation)
            {
                throw GentegreHatasi.Dogrulama("İstek geçerli JSON değil.");
            }
        });

        // Paket: tek SQL çağrısı (tek işlem). Yanıt fn_aktar_paket'in sonucu; bir adım
        //   hatalıysa 200 + "hata" doludur (önceki adımlar yazıldı, ajan versiyonu durumdan okur).
        grup.MapPost("/paket", async (HttpContext ctx, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            var ajan = await AjanAsync(b, ctx, iptal);
            if (ctx.Request.ContentLength > sinir)
                return Results.StatusCode(StatusCodes.Status413PayloadTooLarge);

            string govde;
            using (var okuyucu = new StreamReader(ctx.Request.Body))
                govde = await okuyucu.ReadToEndAsync(iptal);
            if (string.IsNullOrWhiteSpace(govde)) throw GentegreHatasi.Dogrulama("Paket boş.");

            try
            {
                await using var komut = b.Komut("select public.fn_aktar_paket(@p0, @p1::jsonb)::text", null, [ajan, govde]);
                komut.CommandTimeout = 600;   // ilk yükleme sayfası (binlerce belge) - yoklama paketi saniyenin altında
                var sonuc = (string?)await komut.ExecuteScalarAsync(iptal);
                return Results.Content(sonuc ?? "{}", "application/json; charset=utf-8");
            }
            catch (PostgresException pg) when (pg.SqlState == PostgresErrorCodes.InvalidTextRepresentation
                                               || pg.MessageText.StartsWith("AKTARIM_TABLO"))
            {
                throw GentegreHatasi.Dogrulama(pg.MessageText.StartsWith("AKTARIM_TABLO")
                    ? pg.MessageText["AKTARIM_TABLO: ".Length..] : "Paket geçerli JSON değil.");
            }
        }).WithMetadata(new RequestSizeLimitAttribute(sinir));

        // MUTABAKAT (1091): Delphi kök kimlikleri -> eksik / fazla. Yazmaz.
        grup.MapPost("/mutabakat", async (MutabakatIstegi g, HttpContext ctx, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            await AjanAsync(b, ctx, iptal);
            try
            {
                await using var k = b.Komut("select public.fn_aktarim_mutabakat(@p0, @p1)::text", null, [g.Tablo, g.Idler ?? []]);
                k.CommandTimeout = 300;
                return Results.Content((string?)await k.ExecuteScalarAsync(iptal) ?? "{}", "application/json; charset=utf-8");
            }
            catch (PostgresException pg) when (pg.MessageText.StartsWith("AKTARIM_TABLO"))
            {
                throw GentegreHatasi.Dogrulama(pg.MessageText["AKTARIM_TABLO: ".Length..]);
            }
        }).WithMetadata(new RequestSizeLimitAttribute(sinir));

        // Mutabakat sonucu (ekranın "Mutabakat" paneli).
        grup.MapPost("/mutabakat/kayit", async (MutabakatKaydi g, HttpContext ctx, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            var ajan = await AjanAsync(b, ctx, iptal);
            await b.CalistirAsync("""
                insert into public.aktarim_mutabakat (ajan_id, tablo, delphi, web, eksik, fazla, giderilen, atlanan, ornek)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8::jsonb)
                """, null, [ajan, g.Tablo, g.Delphi, g.Web, g.Eksik, g.Fazla, g.Giderilen, g.Atlanan,
                            System.Text.Json.JsonSerializer.Serialize(g.Ornek ?? new())], iptal);
            return Results.Ok(new { tamam = true });
        });
    }

    public sealed record MutabakatIstegi(string Tablo, long[]? Idler);
    public sealed record MutabakatKaydi(string Tablo, int Delphi, int Web, int Eksik, int Fazla, int Giderilen, int Atlanan,
                                        Dictionary<string, long[]>? Ornek);

    /// <summary>Aktarım Durumu ekranı (1090, mockup Ekranlar/aktarim_durumu.html) - kullanıcı oturumuyla.</summary>
    public const string EkranKodu = "aktarim.durum";

    public static void AktarimYonetimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/aktarim-yonetim").WithTags("Delphi aktarımı (ekran)").RequireAuthorization();

        // Tek çağrı: özet kutuları + adım tablosu + hata kuyruğu + son paketler.
        grup.MapGet("/durum", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            (await cozucu.CozAsync(ctx, iptal)).YetkiIste(EkranKodu, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var json = await b.TekDegerAsync<string>("""
                with bugun as (
                    select p.* from public.aktarim_paket p
                     where p.alinma >= date_trunc('day', now() at time zone 'Europe/Istanbul') at time zone 'Europe/Istanbul')
                select json_build_object(
                  'veriKaynagi', (select k.veri_kaynagi from public.kurum_profil k where k.sube_id = 0),
                  'hareketBaslangic', (select deger from public.aktarim_ayar where anahtar = 'hareket_baslangic'),
                  'ajanlar', (select coalesce(json_agg(json_build_object('id', a.id, 'ad', a.ad, 'aktif', a.aktif,
                                  'olusturma', a.olusturma, 'sonNabiz', a.son_nabiz, 'surum', a.surum) order by a.aktif desc, a.id), '[]')
                                from public.aktarim_ajan a),
                  'bugun', (select json_build_object('paket', count(*),
                                  'satir', coalesce(sum((select sum((v->>'U')::int + (v->>'D')::int) from jsonb_each(b.ozet) e(k, v))), 0),
                                  'silme', coalesce(sum((select sum((v->>'D')::int) from jsonb_each(b.ozet) e(k, v))), 0),
                                  'ortMs', coalesce(round(avg(b.sure_ms)), 0),
                                  'hatali', count(*) filter (where b.durum <> 1))
                              from bugun b),
                  'sonPaket', (select max(alinma) from public.aktarim_paket),
                  'adimlar', (select json_agg(json_build_object(
                                  'sira', a.sira, 'fonksiyon', a.fonksiyon, 'tablolar', a.tablolar,
                                  'versiyon', (select min(d.versiyon) from public.aktarim_durum d where d.tablo = any (a.tablolar)),
                                  'eksikTablo', (select count(*) from unnest(a.tablolar) t
                                                  where not exists (select 1 from public.aktarim_durum d where d.tablo = t)),
                                  'sonPaket', (select max(d.son_paket) from public.aktarim_durum d where d.tablo = any (a.tablolar)),
                                  'bugunSatir', (select coalesce(sum((b.ozet->t->>'U')::int + (b.ozet->t->>'D')::int), 0)
                                                   from bugun b, unnest(a.tablolar) t where b.ozet ? t),
                                  'hata', exists (select 1 from public.aktarim_hata h where h.adim = a.fonksiyon and h.cozulme is null))
                                  order by a.sira)
                                from public.fn_aktarim_adimlari() a),
                  'hatalar', (select coalesce(json_agg(json_build_object('id', h.id, 'adim', h.adim, 'tablolar', h.tablolar,
                                  'mesaj', h.mesaj, 'deneme', h.deneme, 'ilk', h.ilk_zaman, 'son', h.son_zaman,
                                  'sira', (select a.sira from public.fn_aktarim_adimlari() a where a.fonksiyon = h.adim)) order by h.id), '[]')
                                from public.aktarim_hata h where h.cozulme is null),
                  -- Son mutabakat: tablo başına en son satır (1091).
                  'mutabakat', (select coalesce(json_agg(json_build_object('tablo', m.tablo, 'zaman', m.zaman,
                                    'delphi', m.delphi, 'web', m.web, 'eksik', m.eksik, 'fazla', m.fazla,
                                    'giderilen', m.giderilen, 'atlanan', m.atlanan, 'ornek', m.ornek) order by m.tablo), '[]')
                                  from (select distinct on (tablo) * from public.aktarim_mutabakat order by tablo, zaman desc) m),
                  'sonPaketler', (select coalesce(json_agg(x order by x.alinma desc), '[]') from (
                                  select p.alinma, p.sure_ms as "sureMs", p.durum, p.ozet,
                                         p.sonuc->'hata'->>'mesaj' as hata,
                                         (select coalesce(sum(v::numeric), 0) from jsonb_each(coalesce(p.sonuc->'sonuc', '{}')) s(f, o),
                                                 jsonb_each_text(o) e(k, v)
                                           where k not in ('eski', 'tursuz', 'kalemsiz', 'mamulsuz', 'kod_ekli', 'cikti_satiri',
                                                           'sube_atlandi', 'web_sahipli', 'cakisma', 'kur112', 'eslesmeyen',
                                                           'izlem_atlanan', 'barkod_cakisma', 'seri_lot_cakisma', 'fiyat_web_sahipli',
                                                           'varsayilan', 'yari_mamul', 'bilesensiz', 'irsaliye', 'bicim')
                                             and v ~ '^[0-9]+$') as yazilan
                                    from public.aktarim_paket p order by p.alinma desc limit 50) x)
                )::text
                """, null, [], iptal);
            return Results.Content(json!, "application/json; charset=utf-8");
        });

        // Hatalı paketin o adıma ait kısmı (inceleme) - Delphi kimlikleri buradan okunur.
        grup.MapGet("/hata/{id:long}/ham", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            (await cozucu.CozAsync(ctx, iptal)).YetkiIste(EkranKodu, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var json = await b.TekDegerAsync<string>("select ham::text from public.aktarim_hata where id = @p0", null, [id], iptal)
                       ?? throw GentegreHatasi.Bulunamadi("Hata kaydı bulunamadı.");
            return Results.Content(json, "application/json; charset=utf-8");
        });

        // "Çözüldü say": yalnız kaydı kapatır, VERİ ATLANMAZ (kullanıcı kararı - "Atla" yok).
        //   Adım hâlâ hatalıysa ajanın bir sonraki denemesi kaydı yeniden açar.
        grup.MapPost("/hata/{id:long}/cozuldu", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            (await cozucu.CozAsync(ctx, iptal)).YetkiIste(EkranKodu, Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("update public.aktarim_hata set cozulme = now() where id = @p0 and cozulme is null", null, [id], iptal);
            if (n == 0) throw GentegreHatasi.Bulunamadi("Açık hata kaydı bulunamadı.");
            return Results.Ok(new { id });
        });
    }

    public sealed record AktarimProfilIstegi(string? VeriKaynagi, DateTime? HareketBaslangic);
    public sealed record AjanIstegi(string? Ad);

    /// <summary>Hareket tabloları: başlangıç tarihi değişince yeniden (tam) yüklenir.</summary>
    private static readonly string[] HareketTablolari = ["FATBASLIK", "FATURA", "STOKIZLEME", "KASA"];

    /// <summary>
    /// GenProfil / Kurum Profili › Veri Kaynağı (adım 6d, mockup sekme 3). Yetki kurum
    /// profilinin yazımlarıyla aynı: "ayar". Ajan anahtarı yalnız üretildiği yanıtta görünür.
    /// </summary>
    public static void AktarimProfilUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kurum-profil/aktarim").WithTags("KurumProfil").RequireAuthorization();

        grup.MapGet("/", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            (await cozucu.CozAsync(ctx, iptal)).YetkiIste("ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var json = await b.TekDegerAsync<string>("""
                select json_build_object(
                  'veriKaynagi', (select k.veri_kaynagi from public.kurum_profil k where k.sube_id = 0),
                  'hareketBaslangic', (select deger from public.aktarim_ayar where anahtar = 'hareket_baslangic'),
                  'subeEsleme', (select coalesce(json_agg(json_build_object('delphiSube', e.delphi_sube_id, 'subeId', e.sube_id,
                                     'subeAd', s.ad) order by e.delphi_sube_id), '[]')
                                   from public.aktarim_sube_esleme e join public.sube s on s.id = e.sube_id),
                  'varsayilanSube', (select s.ad from public.sube s where s.id = public.fn_aktarim_sube(null)),
                  'ajanlar', (select coalesce(json_agg(json_build_object('id', a.id, 'ad', a.ad, 'aktif', a.aktif,
                                  'olusturma', a.olusturma, 'sonNabiz', a.son_nabiz, 'surum', a.surum)
                                  order by a.aktif desc, a.id desc), '[]') from public.aktarim_ajan a))::text
                """, null, [], iptal);
            return Results.Content(json!, "application/json; charset=utf-8");
        });

        grup.MapPut("/", async (AktarimProfilIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            (await cozucu.CozAsync(ctx, iptal)).YetkiIste("ayar", Islem.Degistir);
            if (g.VeriKaynagi is not null and not ("web" or "delphi"))
                throw GentegreHatasi.Dogrulama("Veri kaynağı 'web' ya da 'delphi' olmalı.", new AlanHatasi("veriKaynagi", "Geçersiz değer."));
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            if (g.VeriKaynagi is { } vk)
            {
                await b.CalistirAsync("update public.kurum_profil set veri_kaynagi = @p0 where sube_id = 0", t, [vk], iptal);
                // Web'e dönen kurumda ajan yazamasın: anahtarlar pasifleşir (geri açmak = yeni anahtar).
                if (vk == "web")
                    await b.CalistirAsync("update public.aktarim_ajan set aktif = 0 where aktif = 1", t, [], iptal);
            }
            if (g.HareketBaslangic is { } hb)
            {
                var yeni = hb.ToString("yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
                var eski = await b.TekDegerAsync<string>(
                    "select deger from public.aktarim_ayar where anahtar = 'hareket_baslangic'", t, [], iptal);
                if (eski != yeni)
                {
                    await b.CalistirAsync("""
                        insert into public.aktarim_ayar (anahtar, deger, aciklama) values ('hareket_baslangic', @p0,
                               'Belge / kasa / stok izleme bu tarihten aktarılır')
                        on conflict (anahtar) do update set deger = excluded.deger
                        """, t, [yeni], iptal);
                    // Ajan bir sonraki turda hareket tablolarını yeni tarihle TAM yükler.
                    await b.CalistirAsync("delete from public.aktarim_durum where tablo = any (@p0)", t, [HareketTablolari], iptal);
                }
            }
            await t.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });

        // Yeni ajan anahtarı: düz değer YALNIZ bu yanıtta - sistemde özeti kalır.
        grup.MapPost("/ajan", async (AjanIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            (await cozucu.CozAsync(ctx, iptal)).YetkiIste("ayar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var anahtar = await b.TekDegerAsync<string>("select public.fn_aktarim_ajan_ekle(@p0)", null, [g.Ad ?? ""], iptal);
            return Results.Ok(new { anahtar });
        });

        grup.MapPost("/ajan/{id:int}/pasif", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            (await cozucu.CozAsync(ctx, iptal)).YetkiIste("ayar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            if (await b.CalistirAsync("update public.aktarim_ajan set aktif = 0 where id = @p0", null, [id], iptal) == 0)
                throw GentegreHatasi.Bulunamadi("Ajan bulunamadı.");
            return Results.Ok(new { id });
        });
    }

    private static async Task<int> AjanAsync(NpgsqlConnection b, HttpContext ctx, CancellationToken iptal)
        => await b.TekDegerAsync<int?>("select public.fn_aktarim_ajan_bul(@p0)", null,
                                       [ctx.Request.Headers[AnahtarBasligi].ToString()], iptal)
           ?? throw GentegreHatasi.Yetkisiz("Aktarım ajanı anahtarı geçersiz.");

    private static string? Kirp(string s, int n) => string.IsNullOrWhiteSpace(s) ? null : s.Length > n ? s[..n] : s.Trim();
}
