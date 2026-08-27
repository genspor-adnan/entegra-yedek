using Gentegre.Api.AraKatman;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇEVİRİ SÖZLÜĞÜ (194) - ana menü ve ekran etiketleri.
///
/// TEK KAYNAK: sözlük veritabanında (`ceviri`), arayüz girişte bir kez indirir.
/// İki ayrı sözlük (biri koda gömülü, biri DB'de) zamanla ayrışırdı; yeni
/// çeviri eklemek için sürüm çıkmak da gerekmemeli.
///
/// ANAHTAR TÜRKÇE METNİN KENDİSİ: çevirisi olmayan metin Türkçe görünür, ekran
/// boş kalmaz - sözlük kademeli doldurulabilir.
/// </summary>
public static class CeviriUclari
{
    public static void CeviriUclariniEkle(this IEndpointRouteBuilder yol)
    {
        // Oturum ACILMADAN da gerekir (giris ekrani da cevrilecekse) - bu yuzden
        //   yetki istemez; icerik zaten arayuz metinleri.
        yol.MapGet("/api/ceviri/{dil:int}", async (
            int dil, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = new Npgsql.NpgsqlCommand(
                "select kapsam, anahtar, metin from public.fn_ceviri_sozluk(@p0)", baglanti);
            komut.Parameters.AddWithValue("p0", (short)dil);

            // Kapsam -> { anahtar: metin }. Arayuz c('menu', 'Satış Faturaları')
            //   ile okur; ayni kelimenin baglama gore farkli karsiligi olabilir.
            var sozluk = new Dictionary<string, Dictionary<string, string>>(StringComparer.Ordinal);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
            {
                var kapsam = o.GetString(0);
                if (!sozluk.TryGetValue(kapsam, out var iç))
                    sozluk[kapsam] = iç = new Dictionary<string, string>(StringComparer.Ordinal);
                iç[o.GetString(1)] = o.GetString(2);
            }

            return Results.Ok(new { dil, sozluk });
        }).WithTags("Ceviri");
    }
}
