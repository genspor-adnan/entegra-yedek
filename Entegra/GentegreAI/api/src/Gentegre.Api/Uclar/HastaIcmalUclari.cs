using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HASTA İCMALİ (mockup Ekranlar/Kayıt Kabul/hasta_icmal.html, kullanıcı
/// 10.10.2026: "hasta icmal ekranını kodla").
///
/// Hastanın bir dönemdeki başvuruları (belge tipi 30), hizmet satırları,
/// tahsilat / iadeleri ve SGK provizyonları TEK yanıtta. Hesap kuralları
/// banko açık borç sorgusuyla AYNI (BankoOturumUclari):
///   toplam  = belge.genel_toplam (fn_belge_diptoplam'ın yazdığı)
///   kurum   = satır dağılımındaki SGK + özel sigorta payı (belge_satir_dagilim)
///   hasta   = toplam - kurum
///   tahsil  = kasa_islem net (iade düşülür, iptal 9 sayılmaz)
///   kalan   = hasta - tahsil  (eksi ise fazla tahsilat)
/// Kurum payı icmalde BİLGİ amaçlıdır; hastaya söylenen rakam kalan borçtur.
/// İptal başvuru (durum 6) listede görünür, toplamlara girmez.
/// </summary>
public static class HastaIcmalUclari
{
    private const short IptalBasvuru = 6;

    public static void HastaIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/hasta-icmal").WithTags("Hasta İcmali").RequireAuthorization();

        grup.MapGet("/{hastaId:int}", async (int hastaId, DateTime? bas, DateTime? bit,
                                             VeriKaynagi veri, BaglamCozucu cozucu,
                                             HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hasta", Islem.Gor);
            baglam.YetkiIste("belge", Islem.Gor);
            var baslangic = (bas ?? DateTime.Today.AddMonths(-12)).Date;
            var bitis = (bit ?? DateTime.Today).Date.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var hasta = await b.TekAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(t.vkno, ''), coalesce(t.kod, ''), th.dogum_tarihi, coalesce(th.cinsiyet, 0)
                  from public.taraf t
                  left join public.taraf_hasta th on th.id = t.id
                 where t.id = @p0
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1),
                // TC MASKELİ: icmal yazdırılıp hastaya verilir, ekranda da tam
                //   numara gerekmez (son 2 hane hasta doğrulaması için yeter).
                tc = Maskele(o.GetString(2)), dosyaNo = o.GetString(3),
                dogumTarihi = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                cinsiyet = o.GetInt16(5),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

            var basvurular = await b.ListeAsync("""
                with bsv as (
                    select be.id, be.belge_no, be.belge_tarihi, be.durum, be.genel_toplam,
                           bb.bolum_id, bb.personel_id, bb.odeyen_kurum_id
                      from public.belge be
                      join public.belge_basvuru bb on bb.id = be.id
                     where be.tipi = 30 and coalesce(bb.hasta_id, be.taraf_id) = @p0
                       and be.belge_tarihi >= @p1 and be.belge_tarihi < @p2
                       and (@p3 = 0 or be.sube_id is null or be.sube_id = @p3))
                select s.id, s.belge_no, s.belge_tarihi, s.durum, s.genel_toplam,
                       coalesce(d.ad, ''),
                       coalesce(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::varchar(120), ''),
                       coalesce(public.fn_taraf_ad(ok.unvan, ok.ad, ok.soyad)::varchar(120), 'Ücretli'),
                       coalesce(p.kurum, 0), coalesce(p.iskonto, 0), coalesce(k.net, 0)
                  from bsv s
                  left join public.departman d on d.id = s.bolum_id
                  left join public.taraf hk on hk.id = s.personel_id
                  left join public.taraf ok on ok.id = s.odeyen_kurum_id
                  left join lateral (
                      select sum(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0)) as kurum,
                             round(sum(greatest(st.adet * st.birim_fiyat - st.tutar, 0)), 2) as iskonto
                        from public.belge_satir st
                        left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                       where st.belge_id = s.id) p on true
                  left join lateral (
                      select sum(case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end) as net
                        from public.kasa_islem ki
                        join public.kasa_islem_turu kt on kt.kod = ki.tur
                       where ki.belge_id = s.id and ki.durum <> 9) k on true
                 order by s.belge_tarihi, s.id
                """, null, [hastaId, baslangic, bitis, sube], o =>
            {
                var toplam = o.GetDecimal(4);
                var kurum = Math.Min(o.GetDecimal(8), toplam);
                var tahsil = o.GetDecimal(10);
                return new
                {
                    id = o.GetInt32(0), no = o.GetString(1),
                    tarih = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                    iptal = o.GetInt16(3) == IptalBasvuru,
                    bolum = o.GetString(5), hekim = o.GetString(6), kurum = o.GetString(7),
                    toplam, iskonto = o.GetDecimal(9), kurumPayi = kurum,
                    hastaPayi = toplam - kurum, tahsil, kalan = toplam - kurum - tahsil,
                };
            }, iptal);

            var idler = basvurular.Select(x => x.id).ToArray();

            var hizmetler = await b.ListeAsync("""
                select st.belge_id, be.belge_no, be.belge_tarihi,
                       coalesce(nullif(h.sut_kodu, ''), h.kod, sk.kod, ''), coalesce(h.ad, sk.ad, ''),
                       st.adet, st.birim_fiyat, st.tutar,
                       coalesce(dg.sgk, 0) + coalesce(dg.oss, 0)
                  from public.belge_satir st
                  join public.belge be on be.id = st.belge_id
                  left join public.hizmet h on h.id = st.hizmet_id
                  left join public.stok sk on sk.id = st.stok_id
                  left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                 where st.belge_id = any(@p0)
                 order by be.belge_tarihi, st.belge_id, st.id
                """, null, [idler], o => new
            {
                basvuruId = o.GetInt32(0), basvuruNo = o.GetString(1),
                tarih = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                kod = o.GetString(3), ad = o.GetString(4), adet = o.GetDecimal(5),
                birimFiyat = o.GetDecimal(6), tutar = o.GetDecimal(7), kurumPayi = o.GetDecimal(8),
                hastaPayi = o.GetDecimal(7) - o.GetDecimal(8),
            }, iptal);

            var tahsilatlar = await b.ListeAsync("""
                select ki.id, ki.islem_no, ki.islem_tarihi, ki.belge_id, coalesce(be.belge_no, ''),
                       kt.ad, coalesce(kt.grup, ''), kt.yon, ki.yerel_tutar, ki.durum,
                       coalesce((select bn.kod || ' · ' || bn.ad from public.banko_oturum o
                                   join public.banko bn on bn.id = o.banko_id
                                  where o.id = ki.oturum_id), ''),
                       coalesce(h.tur, '')
                  from public.kasa_islem ki
                  join public.kasa_islem_turu kt on kt.kod = ki.tur
                  left join public.belge be on be.id = ki.belge_id
                  left join public.hesap h on h.id = ki.hesap_id
                 where ki.belge_id = any(@p0)
                 order by ki.islem_tarihi, ki.id
                """, null, [idler], o => new
            {
                id = o.GetInt32(0), makbuzNo = o.GetString(1),
                tarih = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                basvuruId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), basvuruNo = o.GetString(4),
                tur = o.GetString(5), grup = o.GetString(6),
                iade = o.GetInt16(7) <= 0, tutar = o.GetDecimal(8),
                iptal = o.GetInt16(9) == 9, banko = o.GetString(10), hesapTuru = o.GetString(11),
            }, iptal);

            var provizyonlar = await b.ListeAsync("""
                select st.belge_id, be.belge_no, coalesce(dg.sgk_provizyon_no, ''),
                       coalesce(dg.sgk_provizyon_durum, 0),
                       sum(coalesce(dg.sgk, 0)), sum(coalesce(dg.oss, 0)), count(*)
                  from public.belge_satir st
                  join public.belge be on be.id = st.belge_id
                  join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                 where st.belge_id = any(@p0) and (coalesce(dg.sgk, 0) <> 0 or coalesce(dg.oss, 0) <> 0)
                 group by st.belge_id, be.belge_no, dg.sgk_provizyon_no, dg.sgk_provizyon_durum
                 order by st.belge_id
                """, null, [idler], o => new
            {
                basvuruId = o.GetInt32(0), basvuruNo = o.GetString(1), provizyonNo = o.GetString(2),
                durum = o.GetInt16(3), sgk = o.GetDecimal(4), ozelSigorta = o.GetDecimal(5),
                satir = o.GetInt64(6),
            }, iptal);

            // AVANS: başvuruya bağlanmamış avans tahsilatı (kasa_islem.avans = 1)
            //   eksi avanstan yapılan mahsup (tür 27). Kalan borçtan KENDİLİĞİNDEN
            //   düşülmez - mahsup ayrı işlemdir (mockup kuralı).
            var avans = await b.TekDegerAsync<decimal?>("""
                select coalesce(sum(case when ki.avans = 1 then ki.yerel_tutar else 0 end), 0)
                     - coalesce(sum(case when ki.tur = 27 then ki.yerel_tutar else 0 end), 0)
                  from public.kasa_islem ki
                 where ki.taraf_id = @p0 and ki.durum <> 9
                """, null, [hastaId], iptal) ?? 0m;

            var gecerli = basvurular.Where(x => !x.iptal).ToList();
            var ozet = new
            {
                basvuru = gecerli.Count, kalem = hizmetler.Count(h => gecerli.Any(g => g.id == h.basvuruId)),
                toplam = gecerli.Sum(x => x.toplam), kurumPayi = gecerli.Sum(x => x.kurumPayi),
                hastaPayi = gecerli.Sum(x => x.hastaPayi), iskonto = gecerli.Sum(x => x.iskonto),
                tahsil = tahsilatlar.Where(t => !t.iptal && !t.iade).Sum(t => t.tutar),
                iade = tahsilatlar.Where(t => !t.iptal && t.iade).Sum(t => t.tutar),
                kalan = gecerli.Sum(x => Math.Max(x.kalan, 0)),
                avans = Math.Max(avans, 0),
            };

            return Results.Ok(new
            {
                hasta, donem = new { bas = baslangic, bit = bitis.AddDays(-1) },
                ozet, basvurular, hizmetler, tahsilatlar, provizyonlar,
            });
        });
    }

    private static string Maskele(string tc)
        => tc.Length >= 4 ? tc[..3] + new string('*', tc.Length - 5) + tc[^2..] : tc;
}
