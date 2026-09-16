using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÜNLÜK AKIŞ (706) — mockup <c>dis_gunluk_akis.html</c>.
///
/// <para><b>Bu ekran ayrı bir randevu takvimi DEĞİLDİR:</b> genel Randevu
/// modülünün diş görünümü. Satır = diş randevusu (bölüm 2 ya da ünitli) +
/// plan satırı + açık seans + bakiye. Randevu verme/iptal genel kartta;
/// burada yalnız "yeniden planla" (gelmeyen hastaya aynı plan satırıyla
/// yeni randevu) ve seans açma var.</para>
///
/// <para><b>Sayaçlar sunucuda</b> (göz panosuyla aynı gerekçe): "bugün ciro"
/// ve "lab teslim bekleyen" listedeki satırlardan çıkmaz.</para>
/// </summary>
public static partial class DisUclari
{
    public sealed record YenidenPlanlaIstegi(DateTime Baslangic, int? UnitId, int? HekimId, int? SureDk);

    private static void AkisUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/gunluk-akis", async (
            DateOnly? gun, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis", Islem.Gor);

            var tarih = gun ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            var dilim = Gentegre.Cekirdek.Saat.Dilim(baglam.ZamanDilimi == "" ? null : baglam.ZamanDilimi);
            var gunBas = TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(tarih.ToDateTime(TimeOnly.MinValue), DateTimeKind.Unspecified), dilim);
            var gunSon = gunBas.AddDays(1);
            var sube = baglam.SubeId ?? 0;

            await using var baglanti = await veri.AcAsync(iptal);

            var unitler = await baglanti.ListeAsync("""
                select u.id, u.kod, u.ad, u.tur, coalesce(h.unvan, '') as hekim
                  from public.dis_unit u left join public.taraf h on h.id = u.varsayilan_hekim_id
                 where u.aktif = 1 and (u.sube_id = @p0 or @p0 = 0)
                 order by u.kod
                """, null, [sube], o => new
            {
                id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2),
                tur = (int)o.GetInt16(3), hekim = o.GetString(4),
            }, iptal);

            var satirlar = await baglanti.ListeAsync("""
                select a.id, a.baslangic, a.sure_dk, a.randevu_durum, a.hasta_id, a.hasta_adi, a.yas,
                       a.hekim_id, coalesce(a.hekim_adi, ''), a.unit_id, coalesce(a.unit_kod, ''),
                       a.plan_satir_id, a.plan_id, coalesce(a.plan_no, ''), a.plan_sira,
                       coalesce(a.planli_islem, ''), a.dis_no, a.seans_sayisi, a.yapilan_seans,
                       a.lab_isemri_id, a.lab_asama, a.plan_durum, a.plan_yapilan, a.plan_toplam_satir,
                       a.bakiye, a.seans_id, a.seans_baslangic, a.seans_durum, a.belge_id,
                       (select string_agg(coalesce(nullif(x.etken, ''), x.etken_madde), ', ')
                          from public.hasta_alerji x where x.hasta_id = a.hasta_id and x.aktif = 1) as alerji
                  from public.v_dis_gunluk_akis a
                 where a.baslangic >= @p0 and a.baslangic < @p1
                   and (a.sube_id = @p2 or @p2 = 0)
                 order by a.baslangic, a.unit_id nulls last
                """, null, [gunBas, gunSon, sube], o => new
            {
                id = o.GetInt32(0), baslangic = o.GetDateTime(1), sureDk = (int)o.GetInt16(2),
                randevuDurum = (int)o.GetInt16(3), hastaId = o.GetInt32(4), hasta = o.GetString(5),
                yas = o.IsDBNull(6) ? (int?)null : o.GetInt32(6),
                hekimId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7), hekim = o.GetString(8),
                unitId = o.IsDBNull(9) ? (int?)null : o.GetInt32(9), unitKod = o.GetString(10),
                planSatirId = o.IsDBNull(11) ? (int?)null : o.GetInt32(11),
                planId = o.IsDBNull(12) ? (int?)null : o.GetInt32(12), planNo = o.GetString(13),
                planSira = o.IsDBNull(14) ? (int?)null : (int)o.GetInt16(14),
                planliIslem = o.GetString(15),
                disNo = o.IsDBNull(16) ? (int?)null : (int)o.GetInt16(16),
                seansSayisi = o.IsDBNull(17) ? (int?)null : (int)o.GetInt16(17),
                yapilanSeans = o.IsDBNull(18) ? (int?)null : (int)o.GetInt16(18),
                labIsemriId = o.IsDBNull(19) ? (int?)null : o.GetInt32(19),
                labAsama = o.IsDBNull(20) ? (int?)null : (int)o.GetInt16(20),
                planDurum = o.IsDBNull(21) ? (int?)null : (int)o.GetInt16(21),
                planYapilan = o.GetInt32(22), planToplamSatir = o.GetInt32(23),
                bakiye = o.GetDecimal(24),
                seansId = o.IsDBNull(25) ? (int?)null : o.GetInt32(25),
                seansBaslangic = o.IsDBNull(26) ? (DateTime?)null : o.GetDateTime(26),
                seansDurum = o.IsDBNull(27) ? (int?)null : (int)o.GetInt16(27),
                belgeId = o.IsDBNull(28) ? (int?)null : o.GetInt32(28),
                alerji = o.Metin("alerji"),
            }, iptal);

            // Sayaçlar: ünit doluluk = randevulu dakika / (ünit × 9 saat); ciro =
            //   bugün diş seansından doğan başvuru satırları; lab bekleyen =
            //   gelmemiş iş emirleri; onay bekleyen = sunulmuş planlar.
            var ozet = await baglanti.TekAsync("""
                select (select count(*) from public.randevu r where r.baslangic >= @p0 and r.baslangic < @p1
                          and (r.bolum = 2 or r.unit_id is not null) and r.durum <> 4 and (r.sube_id = @p2 or @p2 = 0))::int as randevu,
                       (select count(*) from public.dis_seans s where s.baslangic >= @p0 and s.baslangic < @p1
                          and s.randevu_id is null and (s.sube_id = @p2 or @p2 = 0))::int as randevusuz,
                       (select coalesce(sum(r.sure_dk), 0) from public.randevu r where r.baslangic >= @p0 and r.baslangic < @p1
                          and r.unit_id is not null and r.durum <> 4 and (r.sube_id = @p2 or @p2 = 0))::int as randevu_dk,
                       (select count(*) from public.dis_unit u where u.aktif = 1 and (u.sube_id = @p2 or @p2 = 0))::int as unit_sayisi,
                       (select coalesce(round(avg(s.sure_dk)), 0) from public.dis_seans s where s.baslangic >= @p0 and s.baslangic < @p1
                          and s.durum = 2 and s.sure_dk > 0)::int as ort_seans_dk,
                       (select coalesce(sum(bs.tutar_kdvli), 0) from public.belge_satir bs
                          join public.dis_seans s on s.id = bs.seans_id
                         where s.baslangic >= @p0 and s.baslangic < @p1) as ciro,
                       (select count(*) from public.dis_lab_isemri i where i.asama in (2, 3, 4) and (i.sube_id = @p2 or @p2 = 0))::int as lab_bekleyen,
                       (select count(*) from public.dis_lab_isemri i where i.asama in (2, 3, 4) and i.beklenen_tarih < current_date
                          and (i.sube_id = @p2 or @p2 = 0))::int as lab_gecikti,
                       (select count(*) from public.dis_tedavi_plani p where p.durum = 2 and (p.sube_id = @p2 or @p2 = 0))::int as onay_bekleyen,
                       (select count(*) from public.dis_seans s where s.baslangic >= @p0 and s.baslangic < @p1 and s.durum = 1
                          and (s.sube_id = @p2 or @p2 = 0))::int as unitte,
                       (select count(*) from public.dis_seans s where s.baslangic >= @p0 and s.baslangic < @p1 and s.durum = 2
                          and (s.sube_id = @p2 or @p2 = 0))::int as tamamlanan
                """, null, [gunBas, gunSon, sube], o => new
            {
                randevu = o.GetInt32(0), randevusuz = o.GetInt32(1), randevuDk = o.GetInt32(2),
                unitSayisi = o.GetInt32(3), ortSeansDk = o.GetInt32(4), ciro = o.GetDecimal(5),
                labBekleyen = o.GetInt32(6), labGecikti = o.GetInt32(7), onayBekleyen = o.GetInt32(8),
                unitte = o.GetInt32(9), tamamlanan = o.GetInt32(10),
            }, iptal);

            var doluluk = ozet is null || ozet.unitSayisi == 0 ? 0
                : (int)Math.Round(100.0 * ozet.randevuDk / (ozet.unitSayisi * 9 * 60));

            return Results.Ok(new { gun = tarih, unitler, satirlar, ozet, doluluk, simdi = DateTime.UtcNow });
        });

        // ------------------------------------------------- yeniden planla ----
        // Gelmeyen hastaya aynı plan satırı / ünit / hekimle yeni randevu.
        //   Eski randevu "gelmedi" (3) kalır - gelmeme sayısı raporda görünür.
        grup.MapPost("/randevu/{id:int}/yeniden-planla", async (
            int id, YenidenPlanlaIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Ekle);
            await using var baglanti = await veri.AcAsync(iptal);
            var eski = await baglanti.TekAsync("""
                select r.sube_id, r.bolum, r.hekim_id, r.hasta_id, r.sure_dk, r.aciklama, r.hizmet_id,
                       r.unit_id, r.plan_satir_id, r.lab_isemri_id, r.durum, t.unvan
                  from public.randevu r join public.taraf t on t.id = r.hasta_id where r.id = @p0
                """, null, [id], o => new
            {
                subeId = o.GetInt32(0), bolum = o.GetInt16(1),
                hekimId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2), hastaId = o.GetInt32(3),
                sureDk = o.GetInt16(4), aciklama = o.GetString(5),
                hizmetId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6),
                unitId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                planSatirId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
                labIsemriId = o.IsDBNull(9) ? (int?)null : o.GetInt32(9),
                durum = o.GetInt16(10), hasta = o.GetString(11),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Randevu bulunamadı.");

            if (istek.Baslangic <= DateTime.UtcNow.AddMinutes(-5))
                throw GentegreHatasi.Dogrulama("Yeni randevu geçmişe verilemez.");

            // Lab kısıtı (mockup notu): prova/teslim randevusu iş emrinin
            //   beklenen tarihinden önce verilemez.
            if (eski.labIsemriId is int lid)
            {
                var beklenen = await baglanti.TekDegerAsync<DateTime?>(
                    "select beklenen_tarih from public.dis_lab_isemri where id = @p0", null, [lid], iptal);
                if (beklenen is DateTime b && istek.Baslangic.Date < b.Date)
                    throw GentegreHatasi.IsKurali($"Lab işi {b:dd.MM.yyyy} tarihinde bekleniyor; prova/teslim randevusu ondan önce verilemez.");
            }

            var yeniId = await baglanti.TekDegerAsync<int>("""
                insert into public.randevu
                       (sube_id, bolum, hekim_id, hasta_id, baslangic, sure_dk, durum, aciklama, hizmet_id,
                        unit_id, plan_satir_id, lab_isemri_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 1, @p6, @p7, @p8, @p9, @p10, @p11)
                returning id
                """, null, [eski.subeId, eski.bolum, istek.HekimId ?? eski.hekimId, eski.hastaId,
                            istek.Baslangic, (short)(istek.SureDk ?? eski.sureDk),
                            eski.aciklama, eski.hizmetId, istek.UnitId ?? eski.unitId, eski.planSatirId,
                            eski.labIsemriId, baglam.KullaniciId], iptal);
            // Eski randevu planlandı durumundaysa "gelmedi"ye çekilir; zaten
            //   gelmedi/iptal ise dokunulmaz.
            if (eski.durum == 1)
                await baglanti.CalistirAsync(
                    "update public.randevu set durum = 3, degistiren = @p1, degistirme_tarihi = now() where id = @p0",
                    null, [id, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Ekle, 243, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { yenidenPlanla = id, hasta = eski.hasta, baslangic = istek.Baslangic },
                tarafId: eski.hastaId, iptal: iptal);
            return Results.Ok(new { id = yeniId, hasta = eski.hasta });
        });
    }
}
