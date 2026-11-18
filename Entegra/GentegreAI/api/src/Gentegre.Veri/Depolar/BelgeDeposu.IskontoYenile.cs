using Gentegre.Cekirdek.Katalog;
using Npgsql;

namespace Gentegre.Veri.Depolar;

public sealed partial class BelgeDeposu
{
    /// <summary>
    /// İSKONTO KARARINDAN SONRA SATIR TUTARI (kullanıcı 18.11.2026: "sözlü onaylandı ve kitlendi"; inceleme).
    ///
    /// `fn_iskonto_talep_karar` satıra yalnız ORANI yazıyordu: tutar, ödeme dağılımı ve belgenin dip toplamı kart
    /// yeniden kaydedilene kadar ESKİ kalıyordu - onaylanan %50 iskontolu satır hastaya tam fiyatla "açık" görünüyordu
    /// (dijital onayda da). Oranı satıra yazan her yol (dijital karar, sözlü onay, geri alma) bundan sonra bunu çağırır.
    ///
    /// Para hesabı KART KAYDIYLA AYNI yerden: <see cref="BelgeHesap.SatirTutari"/> (iç yuvarlama, çarpımsal iskonto,
    /// banker's), dağılım `fn_belge_satir_dagilim_tazele`, dip toplam `fn_belge_diptoplam` (ToplamlariYazAsync).
    /// Dağılımı fonksiyonun yeniden bölmediği satırda (elle sabitlenmiş / tahsilatı ya da dönüşümü olan) kovalar
    /// tutarı tutmazdı: fark, kart kaydındaki kuralla HASTA payına yazılır (önce ek katkı, yetmezse provizyon payı).
    /// </summary>
    public async Task IskontoSonrasiYenileAsync(NpgsqlConnection b, NpgsqlTransaction islem, int talepId,
        CancellationToken iptal = default)
    {
        var satirlar = await b.ListeAsync("""
            select s.id, s.belge_id, coalesce(s.adet, 0), coalesce(s.birim_fiyat, 0),
                   coalesce(s.birim_fiyat_kdvli, 0), coalesce(s.doviz_birim_fiyat, 0),
                   coalesce(s.iskonto, 0), coalesce(s.iskonto2, 0), coalesce(s.tutar, 0)
              from public.iskonto_talep_satir ts
              join public.belge_satir s on s.id = ts.belge_satir_id
             where ts.talep_id = @p0
            """, islem, [talepId], o => new
            {
                Id = o.GetInt32(0), BelgeId = o.GetInt32(1), Adet = o.GetDecimal(2), Fiyat = o.GetDecimal(3),
                FiyatKdvli = o.GetDecimal(4), DovizFiyat = o.GetDecimal(5), Isk = o.GetDecimal(6),
                Isk2 = o.GetDecimal(7), EskiTutar = o.GetDecimal(8),
            }, iptal);

        foreach (var s in satirlar)
        {
            var tutar = BelgeHesap.SatirTutari(s.Adet, s.Fiyat, s.Isk, s.Isk2);
            var tutarKdvli = s.FiyatKdvli > 0 ? BelgeHesap.SatirTutari(s.Adet, s.FiyatKdvli, s.Isk, s.Isk2) : 0m;
            var dovizTutar = BelgeHesap.SatirTutari(s.Adet, s.DovizFiyat, s.Isk, s.Isk2);
            // Yalnız tutar kolonları: kilit tetiği (681/1225) oranı / fiyatı korur, tutarın yenilenmesine izin verir.
            await b.CalistirAsync("""
                update public.belge_satir
                   set tutar = @p1, tutar_kdvli = @p2, doviz_tutari = @p3
                 where id = @p0
                """, islem, [s.Id, tutar, tutarKdvli, dovizTutar], iptal);
            await b.CalistirAsync("select public.fn_belge_satir_dagilim_tazele(@p0)", islem, [s.Id], iptal);
            // Fonksiyonun bölmediği satır: fark hasta payına (kart kaydındaki "artan / eksilen hastanındır" kuralı).
            await b.CalistirAsync("""
                update public.belge_satir_dagilim d
                   set hasta_ek_katki  = greatest(d.hasta_ek_katki + f.fark, 0),
                       hasta_provizyon = d.hasta_provizyon + least(d.hasta_ek_katki + f.fark, 0),
                       degistirme_tarihi = now()
                  from (select dg.belge_satir_id,
                               round(s.tutar, 2) - round(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 2) as fark
                          from public.belge_satir_dagilim dg
                          join public.belge_satir s on s.id = dg.belge_satir_id
                         where dg.belge_satir_id = @p0) f
                 where d.belge_satir_id = f.belge_satir_id and abs(f.fark) > 0.005
                """, islem, [s.Id], iptal);
        }

        foreach (var belgeId in satirlar.Select(x => x.BelgeId).Distinct())
            await ToplamlariYazAsync(b, islem, belgeId, iptal);
    }
}
