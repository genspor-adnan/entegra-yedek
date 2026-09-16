using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// LAB İŞ EMRİ AŞAMALARI (706) — mockup <c>dis_lab_isemri.html</c>.
///
/// <para>Aşama sırası sabit: ölçü bekliyor → gönderildi → tasarım onayı →
/// üretim → geldi → prova → teslim edildi. "Geri gönderildi" (7) provadan
/// sonra laba dönüştür; oradan yeniden "gönderildi"ye değil "üretim"e
/// geçilir. Her geçiş zaman damgalı satır yazar; gönderim/teslim tarihleri
/// başlığa da işlenir (liste ve SLA hesabı oradan okur).</para>
/// </summary>
public static partial class DisUclari
{
    public sealed record LabAsamaIstegi(int? Asama, string? Not);

    private static readonly Dictionary<short, short> SonrakiAsama = new()
    {
        [1] = 2, [2] = 3, [3] = 4, [4] = 5, [5] = 6, [6] = 8, [7] = 4,
    };

    private static void LabUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------- pano ----
        // LAB KANBAN (711, mockup dis_lab_kanban.html): kolon = asama. Liste
        //   ekranının "Kanban" ek görünümü. Teslim/iptal yalnız son 30 gün -
        //   pano "açık iş" panosudur, arşiv liste görünümünde.
        grup.MapGet("/lab-pano", async (
            int? labId, int? hekimId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.lab", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kartlar = await b.ListeAsync("""
                select i.id, i.isemri_no, i.hasta_id, t.unvan, coalesce(h.unvan, ''), i.hekim_id, i.lab_id, l.ad, coalesce(l.sla_gun, 0),
                       i.dis_nolar, i.is_turu, i.malzeme, i.renk, i.olcu_tipi, i.ek_istek,
                       i.gonderim_tarihi, i.beklenen_tarih, i.teslim_tarihi, i.asama, i.kalite_kontrol, i.lab_fiyat, i.hasta_fiyat,
                       i.plan_satir_id, coalesce(p.plan_no, ''), coalesce(ps.sira, 0), coalesce(hz.ad, ''),
                       (select r.baslangic from public.randevu r where (r.lab_isemri_id = i.id or (i.plan_satir_id is not null and r.plan_satir_id = i.plan_satir_id))
                          and r.durum in (1, 2) and r.baslangic >= now() order by r.baslangic limit 1) as randevu,
                       (select max(a.zaman) from public.dis_lab_isemri_asama a where a.isemri_id = i.id) as son_asama_zamani,
                       case when i.asama in (8, 9) then 0 when i.beklenen_tarih is not null and i.beklenen_tarih < current_date then 1 else 0 end as gecikti,
                       (select count(*) from public.dis_lab_isemri_asama a where a.isemri_id = i.id and a.asama = 7)::int as geri_sayisi
                  from public.dis_lab_isemri i
                  join public.dis_lab l on l.id = i.lab_id
                  join public.taraf t on t.id = i.hasta_id
                  left join public.taraf h on h.id = i.hekim_id
                  left join public.dis_tedavi_plani_satir ps on ps.id = i.plan_satir_id
                  left join public.dis_tedavi_plani p on p.id = ps.plan_id
                  left join public.hizmet hz on hz.id = ps.hizmet_id
                 where (i.asama not in (8, 9) or coalesce(i.teslim_tarihi, i.degistirme_tarihi::date, i.ekleme_tarihi::date) >= current_date - 30)
                   and (cast(@p0 as integer) is null or i.lab_id = @p0) and (cast(@p1 as integer) is null or i.hekim_id = @p1)
                   and (@p2 = 0 or i.sube_id = @p2)
                 order by case when i.asama in (8, 9) then 1 else 0 end, i.beklenen_tarih nulls last, i.id
                """, null, [labId, hekimId, baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt32(0), isemriNo = o.GetString(1), hastaId = o.GetInt32(2), hasta = o.GetString(3), hekim = o.GetString(4),
                hekimId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5), labId = o.GetInt32(6), lab = o.GetString(7), slaGun = (int)o.GetInt16(8),
                disNolar = o.GetString(9), isTuru = (int)o.GetInt16(10), malzeme = o.GetString(11), renk = o.GetString(12),
                olcuTipi = (int)o.GetInt16(13), ekIstek = o.GetString(14),
                gonderim = o.IsDBNull(15) ? (DateTime?)null : o.GetDateTime(15), beklenen = o.IsDBNull(16) ? (DateTime?)null : o.GetDateTime(16),
                teslim = o.IsDBNull(17) ? (DateTime?)null : o.GetDateTime(17), asama = (int)o.GetInt16(18), kaliteKontrol = (int)o.GetInt16(19),
                labFiyat = o.GetDecimal(20), hastaFiyat = o.GetDecimal(21),
                planSatirId = o.IsDBNull(22) ? (int?)null : o.GetInt32(22), planNo = o.GetString(23), planSira = (int)o.GetInt16(24), islem = o.GetString(25),
                randevu = o.IsDBNull(26) ? (DateTime?)null : o.GetDateTime(26), sonAsamaZamani = o.IsDBNull(27) ? (DateTime?)null : o.GetDateTime(27),
                gecikti = o.GetInt32(28) == 1, geriSayisi = o.GetInt32(29),
            }, iptal);
            var lablar = await b.ListeAsync("select id, ad, coalesce(sla_gun, 0), coalesce(kurye_gunleri, '') from public.dis_lab where aktif = 1 order by ad", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1), slaGun = (int)o.GetInt16(2), kuryeGunleri = o.GetString(3) }, iptal);
            var hekimler = await b.ListeAsync("select id, ad from public.v_hekim_lookup where aktif = 1 order by ad limit 300", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(new { kartlar, lablar, hekimler, bugun = Gentegre.Cekirdek.Saat.Bugun });
        });

        // Aşama geçmişi (sağ panel).
        grup.MapGet("/lab-isemri/{id:int}/asamalar", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.lab", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select a.asama, a.zaman, coalesce(k.ad, ''), a.not_metin from public.dis_lab_isemri_asama a
                  left join public.v_kullanici_lookup k on k.id = a.kullanici_id
                 where a.isemri_id = @p0 order by a.zaman desc, a.id desc limit 40
                """, null, [id], o => new { asama = (int)o.GetInt16(0), zaman = o.GetDateTime(1), kullanici = o.GetString(2), not_ = o.GetString(3) }, iptal);
            return Results.Ok(new { asamalar = liste });
        });

        grup.MapPost("/lab-isemri/{id:int}/asama", async (
            int id, LabAsamaIstegi? istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.lab", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            var i = await baglanti.TekAsync("""
                select i.asama, i.hasta_id, i.isemri_no, l.sla_gun from public.dis_lab_isemri i
                  join public.dis_lab l on l.id = i.lab_id where i.id = @p0
                """, null, [id], o => new { asama = o.GetInt16(0), hastaId = o.GetInt32(1),
                                            no = o.GetString(2), sla = o.GetInt16(3) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İş emri bulunamadı.");
            if (i.asama is 8 or 9) throw GentegreHatasi.IsKurali("Teslim edilmiş / iptal iş emrinin aşaması değişmez.");

            short yeni = istek?.Asama is int a ? (short)a
                : SonrakiAsama.TryGetValue(i.asama, out var n) ? n
                : throw GentegreHatasi.IsKurali("Bu aşamadan sonrası tanımsız.");
            if (yeni is < 1 or > 9) throw GentegreHatasi.Dogrulama("Aşama 1-9 arası olmalı.");
            if (yeni == 7 && i.asama < 5) throw GentegreHatasi.IsKurali("Gelmemiş iş geri gönderilmez.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            await baglanti.CalistirAsync("""
                update public.dis_lab_isemri
                   set asama = @p1,
                       gonderim_tarihi = case when @p1 = 2 and gonderim_tarihi is null then current_date else gonderim_tarihi end,
                       beklenen_tarih  = case when @p1 = 2 and beklenen_tarih is null then current_date + @p3 else beklenen_tarih end,
                       teslim_tarihi   = case when @p1 = 8 then current_date else teslim_tarihi end,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, yeni, baglam.KullaniciId, (int)i.sla], iptal);
            await baglanti.CalistirAsync("""
                insert into public.dis_lab_isemri_asama (isemri_id, asama, kullanici_id, not_metin, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p2)
                """, islem, [id, yeni, baglam.KullaniciId, istek?.Not ?? "", baglam.SubeId ?? 0], iptal);
            // Teslim: bağlı plan satırının lab bekleyişi biter (satır yapıldı
            //   işareti hekimin - simantasyon seansında).
            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloLabIsemri, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { isemri = i.no, asama = $"{i.asama} -> {yeni}" },
                tarafId: i.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { asama = yeni });
        });
    }
}
