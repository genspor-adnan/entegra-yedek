using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// VEZNE / KASA KONSOLİDE İCMALİ (mockup Ekranlar/İcmal/vezne_icmali.html,
/// kullanıcı 10.10.2026: "vezne icmalini kodla").
///
/// Şubenin bütün banko oturumları bir gün (ya da aralık) için TEK yanıtta:
/// oturum başına nakit / POS / havale / iade, beklenen nakit, sayım ve fark;
/// ödeme türü dökümü, POS terminal mutabakatı ve merkez kasaya devir.
///
/// Rakamlar banko oturum kartıyla AYNI kaynaktan (v_banko_oturum_ozet,
/// v_banko_oturum_tur_ozeti, v_banko_oturum_pos) - iki ekran aynı oturum
/// için farklı sayı söyleyemez. İptal makbuz ve fark fişi bu görünümlerde
/// zaten dışarıda. Reddedilen açılış (durum 5) oturum sayılmaz.
///
/// Oturum durumu: 1 açılış onayı bekliyor, 2 açık, 3 kapanış onayı bekliyor,
/// 4 kapandı (devredildi). Yalnız OKUR.
/// </summary>
public static class VezneIcmalUclari
{
    /// <summary>Ekran kodu (1016) - haklarını banko_onay'dan kopyalar.</summary>
    private const string Kod = "banko.vezne_icmal";

    public static void VezneIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/vezne-icmal").WithTags("Vezne İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, short? vardiya, string? oturumlar,
                                VeriKaynagi veri, BaglamCozucu cozucu,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var baslangic = (bas ?? DateTime.Today).Date;
            var sonGun = (bit ?? baslangic).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            var vardiyaKod = vardiya ?? 0;
            // SEÇİLİ OTURUMLAR (mockup: "seçilen oturumlar diğer sekmeleri ve
            //   A4'ü süzer"): boşsa dönemin bütün oturumları.
            var secili = (oturumlar ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => long.TryParse(x, out var n) ? n : 0).Where(n => n > 0).Distinct().ToArray();
            await using var b = await veri.AcAsync(iptal);

            var liste = await b.ListeAsync("""
                select o.id, o.banko_id, o.banko_kod, o.banko_ad, o.durum, o.vardiya_kod,
                       coalesce(o.vardiya, ''),
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(o.acilis_ts, o.acilis_talep_ts), o.kapanis_ts,
                       coalesce(o.devir_tutar, 0),
                       coalesce(z.nakit, 0), coalesce(z.iade, 0),
                       coalesce(z.pos, 0), coalesce(z.havale, 0), coalesce(z.diger, 0),
                       coalesce(z.adet, 0),
                       -- KAPANIŞ ALANLARI açık oturumda 0 tutulur (boş değil): sayım /
                       --   fark yalnız kapanışa gelmiş (3, 4), teslim yalnız kapanmış (4)
                       --   oturumda anlamlı; açık oturumun beklenen nakdi canlı hesaptan.
                       case when o.durum in (3, 4) then o.kapanis_beklenen else o.beklenen_nakit end,
                       case when o.durum in (3, 4) then o.kapanis_sayim end,
                       case when o.durum in (3, 4) then o.kapanis_fark end,
                       coalesce(o.fark_aciklama, ''),
                       case when o.durum = 4 then o.teslim_edilen end,
                       case when o.durum = 4 then o.kasada_birakilan end,
                       coalesce(public.fn_taraf_ad(ta.unvan, ta.ad, ta.soyad)::varchar(120), ''),
                       o.kapanis_onay_ts, coalesce(o.tutanak_no, '')
                  from public.v_banko_oturum_ozet o
                  left join public.taraf t  on t.id  = o.kullanici_id
                  left join public.taraf ta on ta.id = o.teslim_alan_id
                  -- TUTARLAR TÜR ÖZETİNDEN: tahsilat ve iade yönü ayrı - nakit +
                  --   POS + havale + diğer - iade = net her satırda tutar
                  --   (oturum özetinin POS / banka toplamı yönü ayırmıyor).
                  left join lateral (
                      select sum(case when z.kasa_durumu = 1 then z.tahsilat else 0 end) as nakit,
                             sum(case when z.kasa_durumu = 2 and z.hesap_turu = 'P' then z.tahsilat else 0 end) as pos,
                             sum(case when z.kasa_durumu = 2 and z.hesap_turu = 'B' then z.tahsilat else 0 end) as havale,
                             -- çek / senet, kupon ve hesap türü tanımsız kalanlar
                             sum(case when z.kasa_durumu = 1
                                        or (z.kasa_durumu = 2 and z.hesap_turu in ('P', 'B'))
                                      then 0 else z.tahsilat end) as diger,
                             sum(z.iade) as iade, sum(z.net) as net, sum(z.adet) as adet
                        from public.v_banko_oturum_tur_ozeti z
                       where z.oturum_id = o.id) z on true
                 where o.sube_id = @p0 and o.durum in (1, 2, 3, 4)
                   and coalesce(o.acilis_ts, o.acilis_talep_ts) >= @p1
                   and coalesce(o.acilis_ts, o.acilis_talep_ts) < @p2
                   and (@p3 = 0 or o.vardiya_kod = @p3)
                 order by coalesce(o.acilis_ts, o.acilis_talep_ts), o.banko_kod
                """, null, [sube, baslangic, bitis, vardiyaKod], r =>
            {
                var nakit = r.GetDecimal(11);
                var iade = r.GetDecimal(12);
                var pos = r.GetDecimal(13);
                var havale = r.GetDecimal(14);
                var diger = r.GetDecimal(15);
                return new
                {
                    id = r.GetInt64(0), bankoId = r.GetInt32(1), bankoKod = r.GetString(2),
                    banko = r.GetString(3), durum = r.GetInt16(4), vardiyaKod = r.GetInt16(5),
                    vardiya = r.GetString(6), gorevli = r.GetString(7),
                    acilis = r.IsDBNull(8) ? (DateTime?)null : r.GetDateTime(8),
                    kapanis = r.IsDBNull(9) ? (DateTime?)null : r.GetDateTime(9),
                    devir = r.GetDecimal(10),
                    nakit, iade, pos, havale, diger,
                    net = nakit - iade + pos + havale + diger,
                    adet = r.GetInt64(16),
                    beklenenNakit = r.IsDBNull(17) ? 0m : r.GetDecimal(17),
                    sayim = r.IsDBNull(18) ? (decimal?)null : r.GetDecimal(18),
                    fark = r.IsDBNull(19) ? (decimal?)null : r.GetDecimal(19),
                    farkAciklama = r.GetString(20),
                    teslimEdilen = r.IsDBNull(21) ? (decimal?)null : r.GetDecimal(21),
                    kasadaBirakilan = r.IsDBNull(22) ? (decimal?)null : r.GetDecimal(22),
                    teslimAlan = r.GetString(23),
                    teslimZamani = r.IsDBNull(24) ? (DateTime?)null : r.GetDateTime(24),
                    tutanakNo = r.GetString(25),
                };
            }, iptal);

            // Süzülen küme: seçim varsa yalnız seçili (ve bu dönemde olan) oturumlar.
            var kume = liste.Where(o => secili.Length == 0 || secili.Contains(o.id)).ToList();
            var idler = kume.Select(o => o.id).ToArray();

            var turler = await b.ListeAsync("""
                select tur, tur_adi, tur_grup, hesap_turu, kasa_durumu,
                       sum(adet), sum(tahsilat), sum(iade), sum(net)
                  from public.v_banko_oturum_tur_ozeti
                 where oturum_id = any(@p0)
                 group by tur, tur_adi, tur_grup, hesap_turu, kasa_durumu
                 order by kasa_durumu, sum(net) desc
                """, null, [idler], r => new
            {
                tur = r.GetInt16(0), turAdi = r.GetString(1), turGrup = r.GetString(2),
                hesapTuru = r.GetString(3), kasaDurumu = r.GetInt32(4),
                adet = r.GetInt64(5), tahsilat = r.GetDecimal(6), iade = r.GetDecimal(7), net = r.GetDecimal(8),
            }, iptal);

            // POS: aynı terminal birden çok oturumda (ör. sabah + akşam) kullanılır;
            //   terminal başına toplanır. İşlemi olup cihaz toplamı girilmemiş
            //   oturum varsa terminal "eksik" sayılır - kısmi cihaz toplamı yanlış
            //   fark üretir.
            var pos = await b.ListeAsync("""
                select p.banko_pos_id, p.terminal_no, p.hesap_adi,
                       string_agg(distinct o.banko_kod, ', '),
                       count(distinct p.oturum_id) filter (where p.sistem_toplam <> 0 or p.cihaz_toplam is not null),
                       sum(p.sistem_toplam),
                       case when coalesce(bool_and(p.cihaz_toplam is not null)
                                          filter (where p.sistem_toplam <> 0 or p.cihaz_toplam is not null), false)
                            then sum(p.cihaz_toplam) end,
                       coalesce((select count(*) from public.kasa_islem k
                                  where k.oturum_id = any(@p0) and k.banko_pos_id = p.banko_pos_id
                                    and k.durum <> 9 and k.kaynak_tur is distinct from 1385), 0),
                       coalesce(bool_or(p.cihaz_toplam is null and p.sistem_toplam <> 0), false)
                  from public.v_banko_oturum_pos p
                  join public.v_banko_oturum_ozet o on o.id = p.oturum_id
                 where p.oturum_id = any(@p0)
                 group by p.banko_pos_id, p.terminal_no, p.hesap_adi
                -- işlemi olmayan terminal (o gün hiç kullanılmamış) listeye girmez
                having sum(p.sistem_toplam) <> 0 or count(p.cihaz_toplam) > 0
                 order by p.terminal_no
                """, null, [idler], r =>
            {
                var sistem = r.GetDecimal(5);
                decimal? cihaz = r.IsDBNull(6) ? null : r.GetDecimal(6);
                return new
                {
                    bankoPosId = r.GetInt32(0), terminalNo = r.GetString(1), banka = r.GetString(2),
                    bankolar = r.GetString(3), oturum = r.GetInt64(4),
                    kasaToplami = sistem, cihazToplami = cihaz,
                    fark = cihaz is null ? (decimal?)null : cihaz.Value - sistem,
                    adet = r.GetInt64(7), eksik = r.GetBoolean(8),
                };
            }, iptal);

            // Terminale bağlanmamış POS tahsilatı (banko kartındaki uyarının toplamı).
            var posAtanmamis = await b.TekDegerAsync<decimal?>("""
                select coalesce(sum(toplam), 0) from public.v_banko_oturum_pos_atanmamis
                 where oturum_id = any(@p0)
                """, null, [idler], iptal) ?? 0m;

            var kapali = kume.Where(o => o.durum == 4).ToList();
            var ozet = new
            {
                oturum = kume.Count,
                banko = kume.Select(o => o.bankoId).Distinct().Count(),
                acik = kume.Count(o => o.durum == 2),
                onayBekleyen = kume.Count(o => o.durum is 1 or 3),
                makbuz = kume.Sum(o => o.adet),
                nakit = kume.Sum(o => o.nakit), pos = kume.Sum(o => o.pos),
                havale = kume.Sum(o => o.havale), diger = kume.Sum(o => o.diger),
                iade = kume.Sum(o => o.iade), net = kume.Sum(o => o.net),
                tahsilat = kume.Sum(o => o.nakit + o.pos + o.havale + o.diger),
                beklenenNakit = kume.Sum(o => o.beklenenNakit),
                sayim = kume.Sum(o => o.sayim ?? 0),
                kasaFarki = kume.Sum(o => o.fark ?? 0),
                farkliOturum = kume.Count(o => (o.fark ?? 0) != 0),
                posFarki = pos.Sum(p => p.fark ?? 0),
                posAtanmamis,
                devredilen = kapali.Sum(o => o.teslimEdilen ?? 0),
                devredilenOturum = kapali.Count,
                // Henüz devredilmemiş nakit: kapanış onayı bekleyenin sayımı,
                //   açık oturumun beklenen nakdi (sayımı yok).
                bekleyenDevir = kume.Where(o => o.durum == 3).Sum(o => o.sayim ?? o.beklenenNakit)
                              + kume.Where(o => o.durum is 1 or 2).Sum(o => o.beklenenNakit),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun },
                secili, ozet, oturumlar = liste, turler, pos,
            });
        });
    }
}
