using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HIZLI BUL (kullanıcı 16.10.2026: "ekranlar ve menüler gittikçe artıyor, hızlı / kolay erişim" ·
/// "2: kayıt numarasıyla doğrudan açma"). Komut paletine (Ctrl+K) yazılan NUMARA ile kayıt bulunur:
/// hasta dosya no / TC kimlik, başvuru protokol no, muayene no, reçete no, muayene rapor no, lab istem
/// no. Ekran sorulmadan kartı açılır.
///
/// Her tür KENDİ veri yetkisine bağlı (yetkisi olmayana o türden satır dönmez) ve şube kolonu olan
/// kayıtlar aktif şubeyle süzülür. Eşleşme TAM numara ya da numaranın baştan yazılışıdır (en az 4
/// karakter); ad araması burada yok - o liste ekranlarının işi.
/// </summary>
public static class HizliBulUclari
{
    public static void HizliBulUclariniEkle(this IEndpointRouteBuilder yol)
    {
        yol.MapGet("/api/hizli-bul", async (string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var metin = (q ?? "").Trim();
            if (metin.Length < 4 || metin.Length > 30) return Results.Ok(new { sonuclar = Array.Empty<object>() });
            var bas = metin.ToUpperInvariant() + "%";
            var sube = baglam.SubeId ?? 0;
            var y = baglam.Yetkiler;

            var parcalar = new List<string>();
            if (y.Var("hasta", Islem.Gor))
                parcalar.Add("""
                    (select 'hasta', t.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Hasta · ' || t.kod
                       from public.taraf t
                      where t.grup = 101 and (upper(t.kod) like @p0 or t.vkno = @p1)
                      order by t.id desc limit 5)
                    """);
            if (y.Var("belge", Islem.Gor))
                parcalar.Add("""
                    (select 'basvuru', b.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Başvuru · ' || b.belge_no || ' · ' || to_char(b.belge_tarihi, 'DD.MM.YYYY')
                       from public.belge b join public.taraf t on t.id = b.taraf_id
                      where b.tur = 19 and b.tipi = 30 and upper(b.belge_no) like @p0
                        and (@p2 = 0 or b.sube_id = @p2)
                      order by b.id desc limit 5)
                    """);
            if (y.Var("muayene", Islem.Gor))
            {
                parcalar.Add("""
                    (select 'muayene', m.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Muayene · ' || m.muayene_no
                       from public.muayene m join public.taraf t on t.id = m.taraf_id
                      where upper(m.muayene_no) like @p0 and (@p2 = 0 or m.sube_id = @p2)
                      order by m.id desc limit 5)
                    """);
                parcalar.Add("""
                    (select 'recete', r.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Reçete · ' || r.recete_no
                       from public.recete r join public.taraf t on t.id = r.hasta_id
                      where upper(r.recete_no) like @p0 and (@p2 = 0 or r.sube_id = @p2)
                      order by r.id desc limit 5)
                    """);
                parcalar.Add("""
                    (select 'rapor', r.muayene_id, r.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Rapor · ' || r.rapor_no
                       from public.muayene_rapor r join public.taraf t on t.id = r.hasta_id
                      where upper(r.rapor_no) like @p0 and (@p2 = 0 or r.sube_id = @p2)
                      order by r.id desc limit 5)
                    """);
            }
            if (y.Var("lab", Islem.Gor))
                parcalar.Add("""
                    (select 'lab', l.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Lab istemi · ' || l.istem_no
                       from public.lab_istem l join public.taraf t on t.id = l.taraf_id
                      where upper(l.istem_no) like @p0 and (@p2 = 0 or l.sube_id = @p2)
                      order by l.id desc limit 5)
                    """);
            if (parcalar.Count == 0) return Results.Ok(new { sonuclar = Array.Empty<object>() });

            var sonuclar = await veri.ListeAsync(string.Join(" union all ", parcalar),
                [bas, metin, sube],
                o => new { tur = o.GetString(0), id = o.GetInt32(1), altId = o.GetInt32(2), ad = o.GetString(3), bilgi = o.GetString(4) },
                iptal);
            return Results.Ok(new { sonuclar = sonuclar.Take(15) });
        }).RequireAuthorization().WithTags("Hızlı bul");
    }
}
