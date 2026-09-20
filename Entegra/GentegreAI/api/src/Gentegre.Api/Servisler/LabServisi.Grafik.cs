using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GRAFİK TİPLİ SONUÇ (892 — KTS denetim maddesi L10).
///
/// <para>Cihaz elektroforez eğrisini, kromatogramı ya da jel görüntüsünü
/// HL7 OBX-2 = <c>ED</c> (gömülü veri) olarak, noktaları ise <c>NA</c> (sayı
/// dizisi) olarak gönderir. Sonucun yanındaki tek sayı bulgunun tamamı
/// değildir: protein elektroforezinde asıl bilgi eğrinin BİÇİMİDİR.</para>
///
/// <para><b>Görüntü doküman deposunda</b> (hash-dedup, erişim günlüğü,
/// paylaşım orada zaten var), <b>sayı dizisi jsonb olarak</b> durur -
/// seriyi görüntüye çevirip saklamak veriyi kaybetmek olurdu; ekran ve rapor
/// kendisi çizer.</para>
/// </summary>
public sealed partial class LabServisi
{
    /// <summary>
    /// CİHAZ MESAJINDAKİ GRAFİKLERİ SONUCA BAĞLAR.
    ///
    /// <para>Sonuç yazıldıktan SONRA çağrılır: grafik, bir sonucun ekidir.
    /// Kalemde gömülü içerik ya da seri yoksa hiçbir şey yapmaz - her mesaj
    /// grafik taşımaz.</para>
    ///
    /// <para><b>Sessiz başarısız olmaz ama sonucu da düşürmez:</b> görüntü
    /// kaydedilemezse (desteklenmeyen tip) grafik atlanır, sayısal sonuç
    /// yerinde kalır. Eğri yüzünden sonucu kaybetmek, daha büyük zarardır.</para>
    /// </summary>
    public async Task<int> CihazGrafigiBaglaAsync(DokumanDeposu dokumanlar, long mesajId,
        int kalemSira, int satirId, long? sonucId, int cihazId, string tetkikAdi,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var k = await _veri.TekAsync("""
            select deger_tipi, gomulu, gomulu_tip, seri::text, birim
              from public.cihaz_mesaj_kalem
             where mesaj_id = @p0 and sira = @p1
             order by id limit 1
            """, [mesajId, kalemSira],
            o => new { Tip = o.GetString(0),
                       Gomulu = o.IsDBNull(1) ? null : (byte[])o.GetValue(1),
                       GomuluTip = o.GetString(2),
                       Seri = o.IsDBNull(3) ? null : o.GetString(3),
                       Birim = o.GetString(4) }, iptal);

        if (k is null || (k.Gomulu is null && k.Seri is null)) return 0;

        int? dokumanId = null;
        if (k.Gomulu is { Length: > 0 })
        {
            try
            {
                var uzanti = k.GomuluTip switch
                {
                    "image/png" => ".png", "image/jpeg" => ".jpg",
                    "application/pdf" => ".pdf", _ => ".bin",
                };
                var liste = await dokumanlar.EkleAsync("lab-sonuc", satirId,
                    $"{tetkikAdi} grafik{uzanti}", k.GomuluTip, k.Gomulu, false,
                    baglam.Yazma, iptal);
                dokumanId = liste.Count > 0 ? liste[^1].Id : null;
            }
            catch (GentegreHatasi h)
            {
                // Desteklenmeyen tip: grafiği atla, sonucu düşürme.
                _gunluk.LogWarning("Cihaz grafiği kaydedilemedi ({Tip}): {Mesaj}",
                                   k.GomuluTip, h.Message);
            }
        }

        if (dokumanId is null && k.Seri is null) return 0;

        return await _veri.TekDegerAsync<int>("""
            insert into public.lab_sonuc_grafik
                   (sonuc_id, istem_satir_id, tur, baslik, dokuman_id, seri,
                    birim_y, kaynak, cihaz_id, cihaz_mesaj_id, raporda, ekleyen, sube_id)
            select @p0, @p1,
                   -- TÜR CİHAZDAN GELMİYOR: HL7 bunu söylemiyor. "Diğer" (9)
                   --   yazılır; uzman ekrandan düzeltebilir. Uydurma bir tür,
                   --   raporda yanlış başlık üretirdi.
                   9, @p2, @p3, @p4::jsonb, @p5, 1, @p6, @p7, 1, @p8,
                   coalesce(i.sube_id, 0)
              from public.lab_istem_satir s
              join public.lab_istem i on i.id = s.istem_id
             where s.id = @p1
            returning id
            """,
            [sonucId, satirId, $"{tetkikAdi} (cihaz)", dokumanId, k.Seri, k.Birim,
             cihazId, mesajId, baglam.KullaniciId], iptal);
    }
}
