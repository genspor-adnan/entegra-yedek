using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MÜŞTERİ LİSTESİ VER3 (mockup Ekranlar/musteri_listesi_ver3.html).
///
/// Gösterge şeridi: aktif müşteri, toplam alacak, vadesi geçen, risk limiti
/// aşan, 90 gündür satış yapılmayan, bu yıl ciro. Sayılar listenin kolonlarıyla
/// AYNI görünümden (v_cari_ozet, 1150) - kutuya tıklayınca açılan çipin satır
/// sayısı kutudaki sayıyla aynıdır.
///
/// Kayıt kapsamı (kullanici_kapsam) listedeki gibi uygulanır; portal
/// kullanıcısına kapalı (şerit kurum genelini sayar).
/// </summary>
public static class CariListeUclari
{
    public static void CariListeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/cari").WithTags("Müşteri Listesi").RequireAuthorization();

        grup.MapGet("/musteri-gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu gösterge portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);

            var gosterge = await b.TekAsync("""
                select count(*) filter (where t.durum = 1)                                       as aktif,
                       count(*) filter (where t.durum = 1
                                          and t.ekleme_tarihi >= date_trunc('month', now()))    as "yeniBuAy",
                       count(*) filter (where o.bakiye > 0.005)                                  as borclu,
                       coalesce(sum(o.bakiye) filter (where o.bakiye > 0.005), 0)                as alacak,
                       count(*) filter (where o.vadesi_gecen > 0.005)                            as vadeli,
                       coalesce(sum(o.vadesi_gecen), 0)                                          as "vadesiGecen",
                       count(*) filter (where tm.risk_limiti > 0
                                          and round(greatest(o.bakiye, 0) * 100 / tm.risk_limiti) > 100) as "limitAsan",
                       count(*) filter (where t.durum = 1
                                          and o.son_satis < now() - interval '90 days')         as uyuyan,
                       coalesce(sum(o.ciro_12ay) filter (where t.durum = 1
                                          and o.son_satis < now() - interval '90 days'), 0)     as "uyuyanCiro",
                       coalesce(sum(o.ciro_bu_yil), 0)                                           as "ciroBuYil",
                       coalesce(sum(o.ciro_gecen_yil), 0)                                        as "ciroGecenYil"
                  from public.taraf t
                  left join public.v_cari_ozet o on o.taraf_id = t.id
                  left join public.taraf_musteri tm on tm.id = t.id
                 where t.musteri = 1
                   and (cardinality(@p0::int[]) = 0 or t.id = any(@p0::int[]))
                """, null, [baglam.Kapsam.ToArray()], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { gosterge, izlemeNo = baglam.IzlemeNo });
        });

        // KART ÖZETİ (mockup Ekranlar/musteri_karti_ver3.html): özet şeridi, sağ sütun
        //   (dikkat, yaşlandırma) ve Finansal sekmesi TEK istekten. Bakiye / vade / ciro
        //   listeyle aynı görünümden (v_cari_ozet); yaşlandırma aynı FIFO kuralıyla burada
        //   belge belge açılır - toplamı v_cari_ozet.vadesi_gecen'e eşittir.
        grup.MapGet("/{id:int}/kart-ozet", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cari", Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu özet portalda kullanılamaz.");
            if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(id)) throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
            await using var b = await veri.AcAsync(iptal);

            var ozet = await b.TekAsync("""
                select t.id, coalesce(o.bakiye, 0) as bakiye, coalesce(o.vadesi_gecen, 0) as "vadesiGecen",
                       coalesce(tm.risk_limiti, 0) as "riskLimiti", coalesce(tm.vade_gun, 0) as "vadeGun",
                       case when coalesce(tm.risk_limiti, 0) > 0
                            then round(greatest(coalesce(o.bakiye, 0), 0) * 100 / tm.risk_limiti) end as "riskYuzde",
                       coalesce(o.ciro_bu_yil, 0) as "ciroBuYil", coalesce(o.ciro_gecen_yil, 0) as "ciroGecenYil",
                       coalesce(o.ciro_12ay, 0) as "ciro12Ay", coalesce(o.ciro_egri, '') as "ciroEgri",
                       o.son_satis as "sonSatis", o.son_tahsilat as "sonTahsilat", t.durum,
                       coalesce(t.notlar, '') as notlar, t.degistirme_tarihi as "notTarihi",
                       (select count(*) from public.belge s
                         where s.taraf_id = t.id and s.tur = 19 and s.tipi = 1 and s.durum <> 2
                           and coalesce(s.kapanma_durum, 0) < 2)                       as "acikSiparisAdet",
                       (select coalesce(sum(s.genel_toplam), 0) from public.belge s
                         where s.taraf_id = t.id and s.tur = 19 and s.tipi = 1 and s.durum <> 2
                           and coalesce(s.kapanma_durum, 0) < 2)                       as "acikSiparis",
                       (select count(*) from public.cek_senet c
                         where c.taraf_id = t.id and c.yon = 1 and c.durum in (10, 30, 40)) as "cekAdet",
                       (select coalesce(sum(c.yerel_tutar), 0) from public.cek_senet c
                         where c.taraf_id = t.id and c.yon = 1 and c.durum in (10, 30, 40)) as "cekTutar",
                       (select min(c.vade) from public.cek_senet c
                         where c.taraf_id = t.id and c.yon = 1 and c.durum in (10, 30, 40)) as "cekIlkVade",
                       -- SATIS & RISK (1152): sevk edilmis ama faturalanmamis satis irsaliyesi (14).
                       (select coalesce(sum(s.genel_toplam), 0) from public.belge s
                         where s.taraf_id = t.id and s.tur = 14 and s.durum <> 2
                           and coalesce(s.kapanma_durum, 0) < 2)                       as "irsaliyeAcik"
                  from public.taraf t
                  left join public.v_cari_ozet o on o.taraf_id = t.id
                  left join public.taraf_musteri tm on tm.id = t.id
                 where t.id = @p0 and (t.musteri = 1 or t.tedarikci = 1 or t.aday = 1 or t.kurum = 1)
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");

            // Para birimi bazında hesap özeti (ekstrenin kendi kümesi).
            var dovizler = await b.ListeAsync("""
                select e.doviz_cinsi as doviz, sum(e.borc) as borc, sum(e.alacak) as alacak,
                       sum(e.borc - e.alacak) as bakiye, sum(e.yerel_borc - e.yerel_alacak) as yerel
                  from public.v_cari_ekstre e
                 where e.taraf_id = @p0 and e.bakiye_dahil = 1
                 group by e.doviz_cinsi
                 order by (e.doviz_cinsi <> public.fn_yerel_para()), e.doviz_cinsi
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // YAŞLANDIRMA (FIFO): alacak önce vadesi en eski borcu kapatır; kalan borç
            //   vadesine göre dilime düşer. Vade = plan tarihi, yoksa işlem + vade günü.
            var vadeGun = Convert.ToInt32(ozet["vadeGun"] ?? 0);
            var hareket = await b.ListeAsync("""
                select e.islem_tarihi, coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => @p1)),
                       e.yerel_borc, e.yerel_alacak, coalesce(e.belge_no, ''), coalesce(e.tur_adi, ''),
                       coalesce(e.belge_id, 0)
                  from public.v_cari_ekstre e
                 where e.taraf_id = @p0 and e.bakiye_dahil = 1
                """, null, [id, vadeGun], o => (tarih: o.GetDateTime(0), vade: o.GetDateTime(1),
                    borc: o.GetDecimal(2), alacak: o.GetDecimal(3), no: o.GetString(4), tur: o.GetString(5),
                    belgeId: o.GetInt32(6)), iptal);
            var bugun = Saat.Bugun.Date;
            var enEski = 0;
            var kalanAlacak = hareket.Sum(h => h.alacak);
            var dilim = new decimal[4];   // gelmemiş · 0-30 · 31-60 · 60+
            var gecenler = new List<object>();
            foreach (var h in hareket.Where(h => h.borc > 0).OrderBy(h => h.vade).ThenBy(h => h.tarih))
            {
                var kapanan = Math.Min(kalanAlacak, h.borc);
                kalanAlacak -= kapanan;
                var kalan = h.borc - kapanan;
                if (kalan < 0.005m) continue;
                var gecikme = (int)(bugun - h.vade.Date).TotalDays;
                dilim[gecikme <= 0 ? 0 : gecikme <= 30 ? 1 : gecikme <= 60 ? 2 : 3] += kalan;
                if (gecikme > 0) enEski = Math.Max(enEski, gecikme);
                if (gecikme > 0)
                    gecenler.Add(new { h.tarih, h.vade, belgeNo = h.no, turAdi = h.tur, h.belgeId, gecikme, kalan });
            }

            var cekler = await b.ListeAsync("""
                select c.id, c.tur, c.seri_no as "seriNo", coalesce(nullif(c.banka_adi, ''), c.kesideci, '') as banka,
                       c.vade, c.durum, c.yerel_tutar as tutar, c.doviz_cinsi as doviz, c.tutar as "dovizTutar"
                  from public.cek_senet c
                 where c.taraf_id = @p0 and c.yon = 1 and c.durum in (10, 30, 40)
                 order by c.vade
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // DİKKAT: kural sunucuda - ekran yalnız metni gösterir.
            var uyarilar = new List<object>();
            decimal D(string k) => Convert.ToDecimal(ozet[k] ?? 0m);
            if (ozet["riskYuzde"] is { } ry && Convert.ToDecimal(ry) > 100)
                uyarilar.Add(new { seviye = "kirmizi", metin = $"Risk limiti %{Convert.ToDecimal(ry):0} — yeni sevkiyat onaya düşer." });
            if (D("vadesiGecen") > 0.005m)
                uyarilar.Add(new { seviye = "kirmizi", metin = $"{D("vadesiGecen"):N2} vadesi geçmiş" + (enEski > 0 ? $" · en eski {enEski} gün." : ".") });
            if (D("ciroGecenYil") > 0 && D("ciroBuYil") < D("ciroGecenYil") * 0.8m)
                uyarilar.Add(new { seviye = "sari", metin = $"Bu yıl ciro geçen yılın aynı dönemine göre %{(1 - D("ciroBuYil") / D("ciroGecenYil")) * 100:0} düşük." });
            if (cekler.Count > 0 && cekler[0]["vade"] is DateTime ilk && ilk.Date < bugun)
                uyarilar.Add(new { seviye = "sari", metin = "Vadesi geçmiş ama portföyde duran çek var." });

            return Results.Ok(new
            {
                ozet, dovizler,
                yaslandirma = new { gelmemis = dilim[0], d30 = dilim[1], d60 = dilim[2], d90 = dilim[3] },
                vadesiGecenler = gecenler, cekler, uyarilar, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
