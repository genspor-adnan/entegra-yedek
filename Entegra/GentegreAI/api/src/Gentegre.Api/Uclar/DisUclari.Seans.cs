using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SEANS UÇLARI (706) — mockup <c>dis_seans_kaydi.html</c>.
///
/// <para><b>Seans aç:</b> randevudan (ünit, hekim, hasta, başvuru, plan satırı
/// taşınır) ya da doğrudan hastadan. Randevu "geldi"ye çekilir. Aynı
/// randevuya ikinci açık seans açılmaz.</para>
///
/// <para><b>Seansı bitir:</b> işlem satırlarından <c>tamamlandi = 1</c>
/// olanların plan satırı "yapıldı" olur (ücret + odontogram); tamamlanmayan
/// ama plan satırlı olanlar bir seans ilerler (kanal 1/3 → 2/3) ve kural
/// "seans başına oran" ise o seansın payı ücretlenir. Süre başlangıç-bitiş
/// farkından.</para>
/// </summary>
public static partial class DisUclari
{
    public sealed record SeansAcIstegi(int? RandevuId, int? HastaId, int? UnitId, int? HekimId,
                                       int? PlanId, int? PlanSatirId, int? BelgeId);

    private static void SeansUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapPost("/seans/ac", async (
            SeansAcIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.seans", Islem.Ekle);
            await using var baglanti = await veri.AcAsync(iptal);

            int hastaId; int? unitId = istek.UnitId, hekimId = istek.HekimId, belgeId = istek.BelgeId,
                planId = istek.PlanId, planSatirId = istek.PlanSatirId;

            if (istek.RandevuId is int rid)
            {
                var r = await baglanti.TekAsync("""
                    select r.hasta_id, r.unit_id, r.hekim_id, r.belge_id, r.plan_satir_id, ps.plan_id
                      from public.randevu r left join public.dis_tedavi_plani_satir ps on ps.id = r.plan_satir_id
                     where r.id = @p0
                    """, null, [rid], o => new
                {
                    hastaId = o.GetInt32(0),
                    unitId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    hekimId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                    belgeId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                    planSatirId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                    planId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Randevu bulunamadı.");
                var acik = await baglanti.TekDegerAsync<int?>(
                    "select id from public.dis_seans where randevu_id = @p0 and durum = 1", null, [rid], iptal);
                if (acik is int a) return Results.Ok(new { id = a, mevcut = true });
                hastaId = r.hastaId; unitId ??= r.unitId; hekimId ??= r.hekimId; belgeId ??= r.belgeId;
                planSatirId ??= r.planSatirId; planId ??= r.planId;
            }
            else
                hastaId = istek.HastaId ?? throw GentegreHatasi.Dogrulama("Hasta ya da randevu gerekli.");

            // Başvuru: randevuda yoksa hastanın günün açık başvurusu.
            belgeId ??= await baglanti.TekDegerAsync<int?>("""
                select b.id from public.belge b
                 where b.tur = @p1 and b.taraf_id = @p0 and b.durum = 0 and b.belge_tarihi >= current_date - 1
                 order by b.id desc limit 1
                """, null, [hastaId, BasvuruTuru], iptal);
            planId ??= await baglanti.TekDegerAsync<int?>("""
                select id from public.dis_tedavi_plani where hasta_id = @p0 and durum in (3, 4) order by id desc limit 1
                """, null, [hastaId], iptal);

            // BAŞVURU YOKSA AÇ (kullanıcı: "diş için önce kimlik ve başvuru mu
            //   açılmalı" → başvuru ziyaret başına, ücret için şart). Kayıt
            //   Kabul'e gitmeden burada açılır; ödeyen hastanın kayıtlı kurumu.
            AcilanBasvuru? acilan = null;
            if (belgeId is null)
            {
                acilan = await BasvuruAcAsync(baglanti, null, log, baglam, hastaId, hekimId, iptal);
                belgeId = acilan.BelgeId;
            }

            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.dis_seans
                       (sube_id, randevu_id, belge_id, hasta_id, hekim_id, unit_id, plan_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7) returning id
                """, null, [baglam.SubeId ?? 0, istek.RandevuId, belgeId, hastaId, hekimId, unitId, planId,
                            baglam.KullaniciId], iptal);

            // Plan satırı biliniyorsa ilk işlem satırı hazır gelir: hekim
            //   "bugün ne yapıyorum"u yeniden seçmesin.
            if (planSatirId is int psid)
                await baglanti.CalistirAsync("""
                    insert into public.dis_seans_islem (seans_id, plan_satir_id, hizmet_id, dis_no, yuzeyler, seans_no, sube_id, ekleyen)
                    select @p0, s.id, s.hizmet_id, s.dis_no, s.yuzeyler, s.yapilan_seans + 1, @p2, @p3
                      from public.dis_tedavi_plani_satir s where s.id = @p1
                    """, null, [id, psid, baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

            if (istek.RandevuId is int rid2)
                await baglanti.CalistirAsync(
                    "update public.randevu set durum = 2, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 1",
                    null, [rid2, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Ekle, LogTabloSeans, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { randevuId = istek.RandevuId, planSatirId, basvuru = belgeId }, tarafId: hastaId, iptal: iptal);
            // Randevu başvuruya bağlanır: aynı ziyaretin ikinci seansı yeni başvuru açmasın.
            if (istek.RandevuId is int rid3 && acilan is not null)
                await baglanti.CalistirAsync("update public.randevu set belge_id = @p1 where id = @p0 and belge_id is null",
                    null, [rid3, belgeId], iptal);

            return Results.Ok(new
            {
                id, mevcut = false, belgeId,
                basvuruAcildi = acilan is not null,
                basvuruNo = acilan?.BelgeNo, odeyen = acilan?.Odeyen, provizyonBekliyor = acilan?.Sgk ?? false,
            });
        });

        grup.MapPost("/seans/{id:int}/bitir", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.seans", Islem.Degistir);
            baglam.AksiyonIste("dis.seans.bitir");
            await using var baglanti = await veri.AcAsync(iptal);
            var seans = await baglanti.TekAsync("""
                select s.hasta_id, s.durum, s.belge_id, s.randevu_id from public.dis_seans s where s.id = @p0
                """, null, [id], o => new
            {
                hastaId = o.GetInt32(0), durum = o.GetInt16(1),
                belgeId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                randevuId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");
            if (seans.durum != 1) throw GentegreHatasi.IsKurali("Seans zaten kapanmış.");

            var islemler = await baglanti.ListeAsync("""
                select i.id, i.plan_satir_id, i.tamamlandi, i.hizmet_id, i.dis_no, i.yuzeyler
                  from public.dis_seans_islem i where i.seans_id = @p0 order by i.id
                """, null, [id], o => new
            {
                id = o.GetInt32(0), planSatirId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                tamamlandi = o.GetInt16(2) == 1, hizmetId = o.GetInt32(3),
                disNo = (int)o.GetInt16(4), yuzeyler = o.GetString(5),
            }, iptal);
            if (islemler.Count == 0)
                throw GentegreHatasi.IsKurali("Seansta yapılan işlem yok; önce işlem satırı ekleyin.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var uyarilar = new List<string>(); decimal ucret = 0; var yapilan = 0; var ilerleyen = 0;
            foreach (var i in islemler)
            {
                if (i.planSatirId is not int psid) continue;
                var s = await SatirOkuAsync(baglanti, islem, psid, iptal);
                if (s.durum == 3) continue;
                var sonSeans = s.yapilanSeans + 1 >= s.seansSayisi;
                if (i.tamamlandi || sonSeans)
                {
                    var sonuc = await SatirYapildiAsync(baglanti, islem, log, baglam, psid, id, seans.belgeId, iptal);
                    ucret += sonuc.ucret; yapilan++;
                    if (sonuc.uyari is not null && !uyarilar.Contains(sonuc.uyari)) uyarilar.Add(sonuc.uyari);
                }
                else
                {
                    // Ara seans: bir seans ilerler, satır "sürüyor". Kural 2
                    //   (seans başına oran) ise bu seansın payı ücretlenir.
                    await baglanti.CalistirAsync("""
                        update public.dis_tedavi_plani_satir
                           set yapilan_seans = yapilan_seans + 1, durum = 2, degistiren = @p1, degistirme_tarihi = now()
                         where id = @p0
                        """, islem, [psid, baglam.KullaniciId], iptal);
                    ilerleyen++;
                    if (s.kural == 2 && seans.belgeId is int bid)
                    {
                        var pay = Math.Round(s.net / s.seansSayisi, 2, MidpointRounding.ToEven);
                        await baglanti.CalistirAsync("""
                            insert into public.belge_satir
                                   (belge_id, sira, tur, hizmet_id, aciklama, miktar, adet, birim,
                                    birim_fiyat, kdv, tutar, tutar_kdvli, birim_fiyat_kdvli,
                                    doviz_cinsi, doviz_birim_fiyat, doviz_tutari, doviz_kuru, teslim_tarihi,
                                    plan_satir_id, seans_id, dis_no, sube_id, ekleyen)
                            values (@p0, coalesce((select max(bs.sira) from public.belge_satir bs where bs.belge_id = @p0), 0) + 1,
                                    2, @p1, @p2, 1, 1, 0,
                                    round(@p3 / (1 + @p4 / 100.0), 6), @p4, round(@p3 / (1 + @p4 / 100.0), 2), @p3, round(@p3, 4),
                                    'TL', round(@p3 / (1 + @p4 / 100.0), 6), round(@p3 / (1 + @p4 / 100.0), 2), 1, now(),
                                    @p5, @p6, @p7, @p8, @p9)
                            """, islem, [bid, s.hizmetId, $"Diş {s.disNo} · seans {s.yapilanSeans + 1}/{s.seansSayisi}",
                                         pay, s.kdv, psid, id, s.disNo > 0 ? (short?)s.disNo : null,
                                         baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
                        await baglanti.CalistirAsync("""
                            update public.belge b
                               set matrah = k.matrah, kdv_tutari = k.kdv, genel_toplam = k.brut, degistiren = @p1, degistirme_tarihi = now()
                              from (select coalesce(sum(tutar), 0) as matrah,
                                           coalesce(sum(tutar_kdvli), 0) - coalesce(sum(tutar), 0) as kdv,
                                           coalesce(sum(tutar_kdvli), 0) as brut
                                      from public.belge_satir where belge_id = @p0) k
                             where b.id = @p0
                            """, islem, [bid, baglam.KullaniciId], iptal);
                        ucret += pay;
                    }
                    await baglanti.CalistirAsync(
                        "update public.dis_tedavi_plani set durum = 4, degistirme_tarihi = now() where id = @p0 and durum in (1, 2, 3)",
                        islem, [s.planId], iptal);
                }
            }

            await baglanti.CalistirAsync("""
                update public.dis_seans
                   set durum = 2, bitis = now(),
                       sure_dk = greatest(1, extract(epoch from (now() - baslangic))::int / 60),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            if (seans.randevuId is int rid)
                await baglanti.CalistirAsync(
                    "update public.randevu set durum = 2 where id = @p0 and durum = 1", islem, [rid], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloSeans, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { bitti = true, yapilan, ilerleyen, ucret }, tarafId: seans.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { yapilan, ilerleyen, ucret, uyari = uyarilar.Count == 0 ? null : string.Join(" ", uyarilar) });
        });
    }
}
