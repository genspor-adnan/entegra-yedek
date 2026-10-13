using Gentegre.Cekirdek.Sozlesme;
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

    /// <summary>İlk yükleme sayfalı gelir; tek paket bundan büyükse ajan bölmeli.</summary>
    public const long PaketSiniri = 64L * 1024 * 1024;

    public static void AktarimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/aktarim").WithTags("Delphi aktarımı (ajan)").AllowAnonymous();

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
            if (ctx.Request.ContentLength > PaketSiniri)
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
        }).WithMetadata(new RequestSizeLimitAttribute(PaketSiniri));
    }

    private static async Task<int> AjanAsync(NpgsqlConnection b, HttpContext ctx, CancellationToken iptal)
        => await b.TekDegerAsync<int?>("select public.fn_aktarim_ajan_bul(@p0)", null,
                                       [ctx.Request.Headers[AnahtarBasligi].ToString()], iptal)
           ?? throw GentegreHatasi.Yetkisiz("Aktarım ajanı anahtarı geçersiz.");

    private static string? Kirp(string s, int n) => string.IsNullOrWhiteSpace(s) ? null : s.Length > n ? s[..n] : s.Trim();
}
