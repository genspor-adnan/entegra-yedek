using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// CTRL+K "VKN + MÜŞTERİ / TEDARİKÇİ KARTI" (kullanıcı 25.10.2026: "ctrl k arama prompt'a '3850065757 müş kart
/// aç' / 'ted kartı oluştur' yazarsam izibiz'den bilgi alıp oluştur"; "o vkno ile kart varsa uyarı verecek ve
/// kartı açacak"). İki uç:
///   · <c>GET /api/hizli-bul/cari?vkn=</c> - o VKN / TCKN ile KAYITLI cariler (yazarken; yalnız DB, ucuz).
///   · <c>GET /api/kart/cari/gib-bilgi?vkn=</c> - kart oluşturmadan hemen önce: kayıtlı cari yeniden bakılır
///     (varsa web oluşturmaz, uyarıp kartı açar) ve entegratörden (izibiz) unvan, vergi dairesi, adres, e-Fatura
///     posta kutusu alınır. Kart, kartın NORMAL yeni kayıt ucuyla açılır (doğrulama, kod, log) - burada yazma yok.
/// </summary>
public static class CariVknUclari
{
    private sealed record Kayitli(int Id, string Ad, string Kod, bool Musteri, bool Tedarikci, int Durum);

    private static string Rakam(string? v) => new((v ?? "").Where(char.IsAsciiDigit).ToArray());

    /// <summary>Kayıtlı cariler (müşteri / tedarikçi / aday, pasif dahil - mükerrer açtırmamak için).
    ///   Kayıt kapsamı (baglam.Kapsam) olan kullanıcı yalnız kendi carilerini görür.</summary>
    private static async Task<List<Kayitli>> KayitlilarAsync(VeriKaynagi veri, IstekBaglami baglam, string vkn,
        CancellationToken iptal)
    {
        var l = await veri.ListeAsync("""
            select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''), coalesce(t.kod, ''),
                   t.musteri = 1, t.tedarikci = 1, coalesce(t.durum, 1)::int
              from public.taraf t
             where regexp_replace(coalesce(t.vkno, ''), '[^0-9]', '', 'g') = @p0
               and (t.musteri = 1 or t.tedarikci = 1 or t.aday = 1)
             order by (t.durum = 1) desc, t.id
             limit 5
            """, [vkn], o => new Kayitli(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetBoolean(3), o.GetBoolean(4),
                                         o.GetInt32(5)), iptal);
        return baglam.Kapsam.Count > 0 ? l.Where(k => baglam.Kapsam.Contains(k.Id)).ToList() : l;
    }

    /// <summary>"0000000000", "11111111111", "2222222222": nihai tüketici / yer tutucu numaralar - mükerrer sayılmaz.</summary>
    private static bool YerTutucu(string v) => v.Distinct().Count() == 1;

    /// <summary>
    /// AYNI VKN İLE İKİNCİ CARİ KARTI AÇILAMAZ (kullanıcı 25.10.2026: "aynı vkno ile kart açılamaz"). Cari
    /// kartının yeni kayıt ve güncelleme ucu çağırır (HastaUclari.KimlikMukerrerKuraliAsync'in carideki karşılığı).
    /// Müşteri / tedarikçi / aday rolündeki bütün cariler (PASİF DAHİL - pasif kayıt yeniden etkinleştirilir,
    /// ikinci kart açılmaz); aynı firma müşteri + tedarikçi ise TEK kayıttır (iki rol bayrağı). Güncellemede yalnız
    /// numara DEĞİŞİYORSA bakılır - eski (aktarılmış) mükerrerlerin başka alanı düzeltilebilsin.
    /// </summary>
    public static async Task VknMukerrerKuraliAsync(Gentegre.Cekirdek.Katalog.KartTanimi tanim,
        IDictionary<string, object?> degerler, VeriKaynagi veri, long? haricId, CancellationToken iptal)
    {
        if (tanim.Ad != "cari" || !degerler.TryGetValue("vkno", out var ham)) return;
        var v = Rakam(ham?.ToString());
        if (v.Length is not (10 or 11) || YerTutucu(v)) return;
        if (haricId is { } id)
        {
            var eski = Rakam(await veri.TekDegerAsync<string>("select coalesce(vkno, '') from public.taraf where id = @p0",
                                                              [(int)id], iptal));
            if (eski == v) return;
        }
        var mevcut = (await veri.ListeAsync("""
            select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''), coalesce(t.kod, ''),
                   coalesce(t.durum, 1)::int
              from public.taraf t
             where regexp_replace(coalesce(t.vkno, ''), '[^0-9]', '', 'g') = @p0
               and (t.musteri = 1 or t.tedarikci = 1 or t.aday = 1)
               and (@p1::int is null or t.id <> @p1)
             order by (t.durum = 1) desc, t.id
             limit 1
            """, [v, haricId is null ? null : (int?)(int)haricId],
            o => (id: o.GetInt32(0), ad: o.GetString(1), kod: o.GetString(2), durum: o.GetInt32(3)), iptal)).FirstOrDefault();
        if (mevcut.id == 0) return;
        throw GentegreHatasi.Dogrulama(
            $"Bu vergi / kimlik numarası ile kayıtlı cari var: {mevcut.ad}" + (mevcut.kod.Length > 0 ? $" ({mevcut.kod})" : "")
            + $" #{mevcut.id}{(mevcut.durum == 1 ? "" : " - PASİF")}. Aynı numarayla ikinci kart açılmaz; mevcut kartı kullanın"
            + (mevcut.durum == 1 ? "" : " (pasifse etkinleştirin)") + ". Firma hem müşteri hem tedarikçiyse aynı kartta iki rolü işaretleyin.",
            new AlanHatasi("vkno", $"Kayıtlı: {mevcut.ad} (#{mevcut.id})"));
    }

    public static void CariVknUclariniEkle(this IEndpointRouteBuilder yol)
    {
        yol.MapGet("/api/hizli-bul/cari", async (string? vkn, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Gor);
            var v = Rakam(vkn);
            if (v.Length is not (10 or 11)) return Results.Ok(new { vkn = v, kayitlar = Array.Empty<object>() });
            return Results.Ok(new { vkn = v, kayitlar = await KayitlilarAsync(veri, baglam, v, iptal) });
        }).RequireAuthorization().WithTags("Hızlı bul");

        yol.MapGet("/api/kart/cari/gib-bilgi", async (string? vkn, BaglamCozucu cozucu, VeriKaynagi veri,
            EBelgeSorgu sorgu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Ekle);
            var v = Rakam(vkn);
            if (v.Length is not (10 or 11))
                throw GentegreHatasi.Dogrulama("VKN 10, TC kimlik no 11 hane olmalı.", new AlanHatasi("vkn", "10 ya da 11 hane."));

            // KAYITLI VARSA SORGU YOK: web oluşturmaz, uyarıp kartı açar (yazarkenki bakıştan sonra eklenmiş olabilir).
            var kayitlar = await KayitlilarAsync(veri, baglam, v, iptal);
            if (kayitlar.Count > 0) return Results.Ok(new { vkn = v, kayitlar, gib = (object?)null, izlemeNo = baglam.IzlemeNo });

            // ENTEGRATÖR HATASI KARTI ENGELLEMEZ: hesap tanımsız / servis kapalıysa web kartı VKN dolu açar,
            //   nedeni gösterir. (Yalnız iş kuralı hataları - beklenmeyen hata yine 500 + izleme no.)
            try
            {
                var m = await sorgu.MukellefSorgulaAsync(v, baglam.SubeId, iptal);
                return Results.Ok(new
                {
                    vkn = v, kayitlar,
                    gib = new
                    {
                        bulundu = m.Unvan.Length > 0, mukellef = m.Mukellef, durum = m.Durum,
                        unvan = m.Unvan, vergiDairesi = m.VergiDairesi, il = m.Il, ilce = m.Ilce, adres = m.Adres,
                        alias = m.Alias, irsaliyeAlias = m.IrsaliyeAlias, eirsaliye = m.IrsaliyeKullanicisi,
                    },
                    izlemeNo = baglam.IzlemeNo,
                });
            }
            catch (GentegreHatasi h) when (h.Kod is "IS_KURALI" or "DOGRULAMA" or "BULUNAMADI")
            {
                return Results.Ok(new { vkn = v, kayitlar, gib = (object?)null, gibHata = h.Message, izlemeNo = baglam.IzlemeNo });
            }
        }).RequireAuthorization().WithTags("Kart");
    }
}
