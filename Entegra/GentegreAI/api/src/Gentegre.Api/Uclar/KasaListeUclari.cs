using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KASA LİSTESİ / KARTI V3 (mockup Ekranlar/kasa_listesi_ver3.html + kasa_karti_ver3.html,
/// kullanıcı 24.10.2026: "kasa liste ve kartı koda dök").
///
/// <para>Gösterge şeridi: toplam nakit (TL karşılığı), bugün sayımı yapılmamış (sayım zorunlu
/// kasalar), sayım farkı olan, güvenlik limitini aşan, açık banko oturumu, bugün tahsilat /
/// ödeme. Sayılar listenin kolonlarıyla AYNI görünümden (v_kasa_ozet + v_hesap_bakiye, 1161).</para>
///
/// <para>Kart özeti: özet şeridi (bakiye, günün akışı, son sayım, limit, son yatırma, ay neti,
/// yetkili sayısı) ve Sayım / Gün Sonu sekmesi (sayım geçmişi, fark eğilimi) tek istekten.</para>
/// </summary>
public static class KasaListeUclari
{
    public static void KasaListeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kasa").WithTags("Kasa Listesi").RequireAuthorization();

        grup.MapGet("/gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hesap.tanim", Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu gösterge portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var gosterge = await b.TekAsync("""
                select count(*) filter (where h.durum = 1)                                          as aktif,
                       count(distinct h.sube_id) filter (where h.durum = 1)                         as sube,
                       coalesce(sum(vb.yerel_bakiye) filter (where h.durum = 1), 0)                 as "nakit",
                       count(*) filter (where h.durum = 1 and h.sayim_zorunlu = 1 and o.bugun_sayildi = 0) as "sayimBekleyen",
                       count(*) filter (where h.durum = 1 and abs(coalesce(o.son_fark, 0)) > 0.005)  as "farkli",
                       coalesce(sum(o.son_fark) filter (where h.durum = 1 and abs(coalesce(o.son_fark, 0)) > 0.005), 0) as "farkToplam",
                       count(*) filter (where h.durum = 1 and h.guvenlik_limiti > 0 and vb.bakiye > h.guvenlik_limiti) as "limitAsan",
                       coalesce(sum(o.acik_oturum) filter (where h.durum = 1), 0)                   as "acikOturum",
                       coalesce(sum(o.bugun_giris) filter (where h.durum = 1), 0)                   as "bugunGiris",
                       coalesce(sum(o.bugun_cikis) filter (where h.durum = 1), 0)                   as "bugunCikis",
                       coalesce(sum(o.bugun_adet) filter (where h.durum = 1), 0)                    as "bugunAdet"
                  from public.hesap h
                  left join public.v_kasa_ozet o on o.hesap_id = h.id
                  left join public.v_hesap_bakiye vb on vb.hesap_id = h.id
                 where h.tur = 'K' and (@p0 = 0 or h.sube_id in (0, @p0))
                """, null, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { gosterge, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/{id:int}/ozet", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hesap.tanim", Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            await using var b = await veri.AcAsync(iptal);
            var ozet = await b.TekAsync("""
                select h.id, h.ad, h.doviz_cinsi as doviz, h.durum, h.alt_tur as "altTur",
                       coalesce(vb.bakiye, 0)::numeric as bakiye, coalesce(vb.yerel_bakiye, 0)::numeric as "yerelBakiye",
                       coalesce(o.bugun_giris, 0)::numeric as "bugunGiris", coalesce(o.bugun_cikis, 0)::numeric as "bugunCikis", coalesce(o.bugun_adet, 0)::int as "bugunAdet",
                       coalesce(o.ay_net, 0)::numeric as "ayNet", o.son_yatirma as "sonYatirma",
                       o.son_sayim_zaman as "sonSayim", o.son_sayilan as "sonSayilan", o.son_fark as "sonFark", o.son_fark_aciklama as "sonFarkAciklama",
                       coalesce(o.bugun_sayildi, 0)::int as "bugunSayildi", coalesce(o.acik_oturum, 0)::int as "acikOturum", coalesce(o.oturum_kisiler, '') as "oturumKisiler",
                       h.guvenlik_limiti as "guvenlikLimiti", h.sayim_zorunlu as "sayimZorunlu", h.fark_toleransi as "farkToleransi",
                       case when h.guvenlik_limiti > 0 then round(greatest(coalesce(vb.bakiye, 0), 0) * 100 / h.guvenlik_limiti)::int end as "limitYuzde",
                       (select count(*) from public.hesap_yetki y where y.hesap_id = h.id)::int as "yetkili",
                       coalesce(bh.ad, '') as "bagliHesap", coalesce(hp.kod, '') as "muhHesap"
                  from public.hesap h
                  left join public.v_kasa_ozet o on o.hesap_id = h.id
                  left join public.v_hesap_bakiye vb on vb.hesap_id = h.id
                  left join public.hesap bh on bh.id = h.bagli_hesap_id
                  left join public.hesap_plani hp on hp.id = h.muh_hesap_id
                 where h.id = @p0 and h.tur = 'K'
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Kasa bulunamadı.");

            // Sayım geçmişi: son 40 sayım - sistem bakiyesi o günün sonu itibarıyla, fark ve açıklama.
            var sayimlar = await b.ListeAsync("""
                select s.id, s.tarih, s.sayim_zamani, s.sayilan, s.aciklama,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as sayan,
                       (select coalesce(sum(m.borc - m.alacak), 0) from public.v_mali_hareket_ek m
                         where m.hesap_id = s.hesap_id and m.hesap_ekstre = 1 and m.islem_durum = 2
                           and (m.islem_tarihi at time zone 'Europe/Istanbul')::date <= s.tarih) as sistem,
                       coalesce(f.neden, 0), coalesce(f.aciklama, '')
                  from public.kasa_gun_sayim s
                  left join public.taraf t on t.id = s.sayan_id
                  left join public.kasa_gun_fark f on f.sube_id = s.sube_id and f.tarih = s.tarih and f.kalem = 'kasa:' || s.hesap_id
                 where s.hesap_id = @p0
                 order by s.tarih desc, s.sayim_zamani desc
                 limit 40
                """, null, [id], o => new
                {
                    id = o.GetInt32(0), tarih = o.GetDateTime(1), zaman = o.GetDateTime(2), sayilan = o.GetDecimal(3), aciklama = o.GetString(4),
                    sayan = o.GetString(5), sistem = o.GetDecimal(6), fark = o.GetDecimal(3) - o.GetDecimal(6), neden = o.GetInt16(7), farkAciklama = o.GetString(8),
                }, iptal);

            // Son 5 hareket (Genel sekmesi) - tek Ekstre ekranına bağlantı.
            var hareketler = await b.ListeAsync("""
                select e.id, e.islem_tarihi, coalesce(e.tur_adi, ''), coalesce(e.taraf_unvan, ''), coalesce(e.belge_no, ''), e.borc, e.alacak, e.kasa_islem_id, e.belge_id
                  from public.v_mali_hareket_ek e
                 where e.hesap_id = @p0 and e.hesap_ekstre = 1 and e.islem_durum = 2
                 order by e.islem_tarihi desc, e.id desc
                 limit 5
                """, null, [id], o => new
                {
                    id = o.GetInt32(0), tarih = o.GetDateTime(1), turAdi = o.GetString(2), cari = o.GetString(3), belgeNo = o.GetString(4),
                    giris = o.GetDecimal(5), cikis = o.GetDecimal(6), kasaIslemId = o.IsDBNull(7) ? 0 : o.GetInt32(7), belgeId = o.IsDBNull(8) ? 0 : o.GetInt32(8),
                }, iptal);

            var s30 = sayimlar.Where(s => s.tarih >= Saat.Bugun.AddDays(-30)).ToList();
            var tolerans = Convert.ToDecimal(ozet["farkToleransi"] ?? 0m);
            var egilim = new
            {
                tam = s30.Count(s => Math.Abs(s.fark) <= 0.005m),
                toleransIci = s30.Count(s => Math.Abs(s.fark) > 0.005m && Math.Abs(s.fark) <= Math.Max(tolerans, 0.005m)),
                toleransUstu = s30.Count(s => Math.Abs(s.fark) > Math.Max(tolerans, 0.005m)),
                toplam = s30.Sum(s => s.fark), enBuyuk = s30.OrderByDescending(s => Math.Abs(s.fark)).FirstOrDefault(),
            };
            return Results.Ok(new { ozet, sayimlar, hareketler, egilim, izlemeNo = baglam.IzlemeNo });
        });
    }
}
