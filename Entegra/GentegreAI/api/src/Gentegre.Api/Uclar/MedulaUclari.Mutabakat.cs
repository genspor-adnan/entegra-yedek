using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MEDULA MUTABAKAT İCMALİ (mockup Ekranlar/İcmal/medula_mutabakat.html,
/// kullanıcı 10.10.2026: "medula mutabakat icmalini kodla").
///
/// <para>SGK dönemi bir HUNİ olarak: takip alınan → hizmeti Medula'ya kabul
/// edilen → çıkışı verilen → faturalanan → döneme alınan → ödenen. Her
/// adımda düşen takip kaçak gelirdir; "Faturasız Takipler" nedeniyle
/// listelenir. Kaynak Fatura &amp; Dönem ekranıyla AYNI (v_medula_takip,
/// medula_fatura, medula_kesinti, medula_donem) - iki ekran aynı dönem için
/// farklı sayı söyleyemez. Fatura durumu kod listesi medula.fatura_durum:
/// 1 taslak, 2 kaydedildi, 3 dönemde, 4 dönem kapandı, 5 incelendi,
/// 6 ödendi, 7 iptal.</para>
///
/// <para>Yalnız OKUR. Faturalama Fatura &amp; Dönem uçlarıyla
/// (<c>/fatura/toplu</c>, <c>/basvuru/{id}/fatura-kaydet</c>) yapılır.</para>
/// </summary>
public static partial class MedulaUclari
{
    /// <summary>Ekran kodu (1017) - haklarını medula.fatura'dan kopyalar.</summary>
    private const string MutabakatKodu = "medula.mutabakat";

    private static void MutabakatUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/mutabakat", async (
            int? yil, int? ay, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(MutabakatKodu, Islem.Gor);
            // Varsayılan dönem: geçen ay - SGK faturası ay kapanınca kesilir.
            var buAy = new DateTime(Gentegre.Cekirdek.Saat.Bugun.Year, Gentegre.Cekirdek.Saat.Bugun.Month, 1);
            var bas = yil is > 0 && ay is >= 1 and <= 12 ? new DateTime(yil.Value, ay.Value, 1) : buAy.AddMonths(-1);
            var son = bas.AddMonths(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var esik = (decimal)await MedulaServisi.AyarAsync(b, "medula.tutar_fark_esigi", 0, iptal);

            var takipler = await b.ListeAsync("""
                select v.belge_id, v.belge_no, v.belge_tarihi, v.hasta_id, coalesce(v.hasta_adi, ''),
                       coalesce(v.bolum_adi, ''), coalesce(v.hekim_adi, ''), coalesce(v.sgk_takip_no, ''),
                       coalesce(v.sgk_takip_turu, 0)::smallint, v.sgk_cikis_zaman is not null,
                       coalesce(v.kabul_islem, 0), coalesce(v.hatali_islem, 0), coalesce(v.satir_sayisi, 0),
                       coalesce(v.yerel_tutar, 0), v.medula_fatura_id, coalesce(v.medula_fatura_no, ''),
                       v.medula_tutar, coalesce(v.fatura_durum, 0)::smallint,
                       (select f.hasta_katilim from public.medula_fatura f where f.id = v.medula_fatura_id)
                  from public.v_medula_takip v
                 where v.belge_tarihi >= @p0 and v.belge_tarihi < @p1
                   and (@p2 = 0 or coalesce(v.sube_id, 0) in (0, @p2)) and v.sgk_durum = 1
                 order by v.belge_tarihi, v.belge_id
                """, null, [bas, son, sube], o =>
            {
                var faturaDurum = (int)o.GetInt16(17);
                var faturali = faturaDurum is >= 2 and <= 6;
                var kabul = o.GetInt32(10); var hatali = o.GetInt32(11); var satir = o.GetInt32(12);
                var cikis = o.GetBoolean(9);
                return new
                {
                    belgeId = o.GetInt32(0), protokolNo = o.GetString(1), tarih = o.GetDateTime(2),
                    hastaId = o.GetInt32(3), hasta = o.GetString(4), bolum = o.GetString(5), hekim = o.GetString(6),
                    takipNo = o.GetString(7), takipTuru = (int)o.GetInt16(8), cikis,
                    kabulIslem = kabul, hataliIslem = hatali, satirSayisi = satir,
                    yerelTutar = o.GetDecimal(13),
                    faturaId = o.IsDBNull(14) ? (int?)null : o.GetInt32(14), faturaNo = o.GetString(15),
                    medulaTutar = o.IsDBNull(16) ? (decimal?)null : o.GetDecimal(16),
                    faturaDurum, faturali,
                    katilim = o.IsDBNull(18) ? (decimal?)null : o.GetDecimal(18),
                    // FATURASIZ NEDENİ: huninin hangi adımında kaldı. "hazir" =
                    //   engel yok, toplu faturalamaya girer (/fatura/toplu kuralı).
                    neden = faturali ? ""
                          : satir == 0 ? "hizmet_yok"
                          : hatali > 0 ? "hizmet_hatali"
                          : kabul == 0 ? "hizmet_gonderilmedi"
                          : !cikis ? "cikis_yok"
                          : faturaDurum == 1 ? "taslak"
                          : "hazir",
                };
            }, iptal);

            var idler = takipler.Select(t => t.belgeId).ToArray();
            var kesintiler = await b.ListeAsync("""
                select k.id, f.belge_id, coalesce(be.belge_no, ''), f.takip_no, coalesce(f.medula_fatura_no, ''),
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(k.sut_kodu, ''), coalesce(k.kesinti_kodu, ''), coalesce(k.aciklama, ''),
                       k.tutar, coalesce(k.itiraz_durum, 0)::smallint, coalesce(k.iade_tutar, 0)
                  from public.medula_kesinti k
                  join public.medula_fatura f on f.id = k.medula_fatura_id
                  left join public.belge be on be.id = f.belge_id
                  left join public.taraf t on t.id = f.hasta_id
                 where f.belge_id = any(@p0)
                 order by k.id
                """, null, [idler], o => new
            {
                id = o.GetInt32(0), belgeId = o.GetInt32(1), protokolNo = o.GetString(2), takipNo = o.GetString(3),
                faturaNo = o.GetString(4), hasta = o.GetString(5), sutKodu = o.GetString(6), kod = o.GetString(7),
                aciklama = o.GetString(8), tutar = o.GetDecimal(9), itirazDurum = (int)o.GetInt16(10),
                iade = o.GetDecimal(11), net = o.GetDecimal(9) - o.GetDecimal(11),
            }, iptal);

            var donem = await b.TekAsync("""
                select id, fatura_sayisi, toplam, kesinti, odenen, odeme_tarihi, sonlandirma,
                       coalesce(icmal_no, ''), durum
                  from public.medula_donem
                 where (@p0 = 0 or coalesce(sube_id, 0) in (0, @p0)) and yil = @p1 and ay = @p2 and fatura_turu = 0
                 order by id limit 1
                """, null, [sube, (short)bas.Year, (short)bas.Month], o => new
            {
                id = o.GetInt32(0), faturaSayisi = o.GetInt32(1), toplam = o.GetDecimal(2), kesinti = o.GetDecimal(3),
                odenen = o.GetDecimal(4), odemeTarihi = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                sonlandirma = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6), icmalNo = o.GetString(7),
                durum = (int)o.GetInt16(8),
            }, iptal);

            var faturali = takipler.Where(t => t.faturali).ToList();
            var farklar = faturali
                .Where(t => Math.Abs(t.yerelTutar - (t.medulaTutar ?? 0)) > esik)
                .Select(t => new
                {
                    t.belgeId, t.protokolNo, t.hasta, t.takipNo, t.faturaNo, t.yerelTutar,
                    medulaTutar = t.medulaTutar ?? 0, fark = t.yerelTutar - (t.medulaTutar ?? 0), t.katilim,
                })
                .ToList();

            // HUNİ: her adım bir öncekinin alt kümesi; tutar HBYS (yerel) tutarı.
            var huni = new[]
            {
                ("takip", "Takip alınan", takipler.AsEnumerable()),
                ("hizmet", "Hizmeti kabul edilen", takipler.Where(t => t.kabulIslem > 0)),
                ("cikis", "Çıkışı verilen", takipler.Where(t => t.kabulIslem > 0 && t.cikis)),
                ("fatura", "Faturalanan", faturali.AsEnumerable()),
                ("donem", "Döneme alınan", takipler.Where(t => t.faturaDurum is >= 3 and <= 6)),
                ("odendi", "Ödenen", takipler.Where(t => t.faturaDurum == 6)),
            }.Select(x => new { kod = x.Item1, ad = x.Item2, adet = x.Item3.Count(), tutar = x.Item3.Sum(t => t.yerelTutar) })
             .ToList();

            var medulaTutar = faturali.Sum(t => t.medulaTutar ?? 0);
            var kesintiNet = kesintiler.Sum(k => k.net);
            var odenen = donem?.odenen ?? 0;
            var ozet = new
            {
                takip = takipler.Count,
                faturali = faturali.Count,
                faturasiz = takipler.Count - faturali.Count,
                faturasizTutar = takipler.Where(t => !t.faturali).Sum(t => t.yerelTutar),
                hazir = takipler.Count(t => t.neden == "hazir"),
                yerelTutar = takipler.Sum(t => t.yerelTutar),
                faturaliYerel = faturali.Sum(t => t.yerelTutar),
                medulaTutar,
                farkli = farklar.Count,
                farkTutari = farklar.Sum(f => f.fark),
                kesinti = kesintiNet,
                kesintiKalem = kesintiler.Count,
                itirazBekleyen = kesintiler.Where(k => k.itirazDurum == 1).Sum(k => k.tutar),
                itirazBekleyenKalem = kesintiler.Count(k => k.itirazDurum == 1),
                odenen,
                // AÇIK ALACAK: Medula'nın kabul ettiği - kesinti - ödenen. Dönem
                //   ödemesi girilmediyse ödenen 0, alacak tamamı açıktır.
                acik = medulaTutar - kesintiNet - odenen,
            };

            return Results.Ok(new
            {
                yil = bas.Year, ay = bas.Month, esik, donem, ozet, huni,
                faturasiz = takipler.Where(t => !t.faturali).ToList(),
                farklar, kesintiler,
                faturalar = faturali,
            });
        });
    }
}
