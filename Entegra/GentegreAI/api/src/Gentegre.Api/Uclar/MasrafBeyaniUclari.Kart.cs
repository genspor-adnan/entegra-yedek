using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MASRAF BEYANI KARTI (961, mockup Ekranlar/IK/masraf_karti.html).
///
/// Bağlam: personel, satırlar (gider kalemi adı, fişi var mı), gider kalemleri
/// (günlük sınırıyla), gönderim öncesi KONTROL (mükerrer belge, eski harcama,
/// günlük sınır, fişsiz satır, âmir), personelin izinleri (ilgili kayıt),
/// son beyanlar, akış. Kaydı DEĞİŞTİRMEZ. Satır düzenleme ayrı uç (PUT).
/// </summary>
public static partial class MasrafBeyaniUclari
{
    private static void MasrafKartUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/masraf-baglam", async (int tarafId, int? beyanId, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIsteKendi(tarafId, "ik.masraf", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var personel = await b.TekAsync("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad,
                       coalesce(p.gorev, '') as gorev, p.yonetici_taraf_id is not null as "amirVar",
                       (select string_agg(d.ad, ', ') from public.departman d
                         where d.id in (select public.fn_kullanici_bolumleri(@p0))) as bolum
                  from public.taraf t left join public.taraf_personel p on p.id = t.id
                 where t.id = @p0
                """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var kalemler = await b.ListeAsync("""
                select m.id, m.ad, m.kod, m.personel_gunluk_sinir as sinir
                  from public.masraf m
                 where coalesce(m.baslik_mi, 0) = 0 and m.durum = 1
                 order by m.ad
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            var gecmisGunMetin = await b.TekDegerAsync<string?>(
                "select deger from public.referans where anahtar = 'ik.masraf_gecmis_gun'", null, [], iptal);
            var gecmisGun = int.TryParse(gecmisGunMetin, out var g) ? g : 60;

            List<IDictionary<string, object?>> satirlar = [];
            List<IDictionary<string, object?>> akis = [];
            List<IDictionary<string, object?>> kontrol = [];
            if (beyanId is > 0)
            {
                satirlar = await b.ListeAsync("""
                    select s.id, s.sira, s.masraf_id as "masrafId", coalesce(m.ad, '') as "masrafAd",
                           s.harcama_tarihi as "harcamaTarihi", s.belge_turu as "belgeTuru", s.belge_no as "belgeNo",
                           s.tutar, s.kdv_tutar as "kdvTutar", s.aciklama,
                           (select d.id from public.dokuman d where d.kaynak = 'masraf-beyan' and d.kaynak_id = s.beyan_id
                              and d.belge_turu = s.belge_no order by d.id limit 1) as "fisId"
                      from public.personel_masraf_satir s
                      left join public.masraf m on m.id = s.masraf_id
                     where s.beyan_id = @p0 order by s.sira
                    """, null, [beyanId.Value], OkuyucuGenisletmeleri.Sozluk, iptal);

                // KONTROL - her satır için uyarı (engel değil; belgesiz satır DB'de engelli).
                kontrol = await b.ListeAsync("""
                    select s.sira, 'mukerrer' as tur,
                           'Aynı belge no başka beyanda: ' || string_agg(coalesce(nullif(o.beyan_no, ''), '#' || o.id), ', ') as metin
                      from public.personel_masraf_satir s
                      join public.personel_masraf_satir x on x.belge_no = s.belge_no and x.beyan_id <> s.beyan_id
                      join public.personel_masraf o on o.id = x.beyan_id and o.durum not in (3, 8)
                     where s.beyan_id = @p0
                     group by s.sira
                    union all
                    select s.sira, 'eski', 'Harcama ' || (b.beyan_tarihi - s.harcama_tarihi) || ' gün önce'
                      from public.personel_masraf_satir s join public.personel_masraf b on b.id = s.beyan_id
                     where s.beyan_id = @p0 and @p1 > 0 and b.beyan_tarihi - s.harcama_tarihi > @p1
                    union all
                    select min(s.sira), 'sinir',
                           m.ad || ' ' || to_char(s.harcama_tarihi, 'DD.MM') || ': ' || sum(s.tutar)::numeric(18,2)
                           || ' ₺ - günlük sınır ' || m.personel_gunluk_sinir::numeric(18,2) || ' ₺'
                      from public.personel_masraf_satir s join public.masraf m on m.id = s.masraf_id
                     where s.beyan_id = @p0 and m.personel_gunluk_sinir is not null
                     group by m.ad, s.harcama_tarihi, m.personel_gunluk_sinir
                    having sum(s.tutar) > m.personel_gunluk_sinir
                     order by 1
                    """, null, [beyanId.Value, gecmisGun], OkuyucuGenisletmeleri.Sozluk, iptal);

                akis = await b.ListeAsync("""
                    select 0 as sira, 'olustu' as tur, a.ekleme_tarihi as zaman,
                           coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as kim, '' as metin
                      from public.personel_masraf a left join public.taraf t on t.id = a.ekleyen
                     where a.id = @p0
                    union all
                    select 1, 'gonderildi', o.baslama, '', (select string_agg(x.ad, ' → ' order by x.sira) from public.onay_adim x where x.onay_id = o.id)
                      from public.onay o where o.kaynak_tur = @p1 and o.kaynak_id = @p0
                    union all
                    select 2 + d.sira, case d.durum when 1 then 'onay' when 2 then 'red' when 3 then 'bilgi'
                                                    when 4 then 'sozlu' when 5 then 'atlandi' end,
                           d.karar_zamani, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                           d.ad || coalesce(' · “' || nullif(d.gerekce, '') || '”', '')
                      from public.onay o join public.onay_adim d on d.onay_id = o.id
                      left join public.taraf t on t.id = d.karar_veren_id
                     where o.kaynak_tur = @p1 and o.kaynak_id = @p0 and d.karar_zamani is not null
                    union all
                    select 99, 'iptal', a.degistirme_tarihi, '', a.iptal_neden
                      from public.personel_masraf a where a.id = @p0 and a.durum = 8
                     order by 3 nulls last, 1
                    """, null, [beyanId.Value, LogBeyan], OkuyucuGenisletmeleri.Sozluk, iptal);
            }

            // İLGİLİ: personelin son 3 ay / önümüzdeki 1 ayki izinleri (kongre vb.).
            var izinler = await b.ListeAsync("""
                select i.id, coalesce(nullif(i.izin_no, ''), '#' || i.id) || ' · '
                       || to_char(i.baslangic_tarihi, 'DD.MM') || '–' || to_char(i.bitis_tarihi, 'DD.MM.YYYY')
                       || coalesce(' · ' || nullif(i.aciklama, ''), '') as ad
                  from public.personel_izin i
                 where i.taraf_id = @p0 and i.durum in (1, 2)
                   and i.bitis_tarihi > current_date - interval '3 months'
                   and i.baslangic_tarihi < current_date + interval '1 month'
                 order by i.baslangic_tarihi desc limit 12
                """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var gecmis = await b.ListeAsync("""
                select coalesce(nullif(a.beyan_no, ''), '#' || a.id) as no, a.beyan_tarihi as tarih,
                       a.toplam_tutar as tutar, a.durum
                  from public.personel_masraf a
                 where a.taraf_id = @p0 and a.id <> coalesce(@p1, 0)
                   and a.beyan_tarihi > current_date - interval '12 months'
                 order by a.beyan_tarihi desc limit 8
                """, null, [tarafId, beyanId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { personel, kalemler, gecmisGun, satirlar, kontrol, izinler, gecmis, akis,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // SATIR DÜZENLE: taslakta (tetik zaten engeller); belge no / tutar kuralı ekleme ile aynı.
        grup.MapPut("/masraf/satir/{satirId:int}", async (int satirId, SatirIstegi istek,
            BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await KendiTalebi.IsteAsync(veri, baglam, "select b.taraf_id from public.personel_masraf_satir s join public.personel_masraf b on b.id = s.beyan_id where s.id = @p0", satirId, "ik.masraf", Islem.Degistir, iptal);
            if (string.IsNullOrWhiteSpace(istek.BelgeNo))
                throw GentegreHatasi.Dogrulama("Belge numarası zorunlu.",
                    new AlanHatasi("belgeNo", "Fatura/fiş numarası olmadan harcama beyan edilemez."));
            if (istek.Tutar <= 0)
                throw GentegreHatasi.Dogrulama("Tutar sıfırdan büyük olmalı.", new AlanHatasi("tutar", "Sıfırdan büyük olmalı."));

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var eskiNo = await b.TekDegerAsync<string?>(
                "select belge_no from public.personel_masraf_satir where id = @p0", islem, [satirId], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Satır bulunamadı.");
            await b.CalistirAsync("""
                update public.personel_masraf_satir
                   set masraf_id = @p1, harcama_tarihi = coalesce(@p2, harcama_tarihi), belge_turu = coalesce(@p3, belge_turu),
                       belge_no = btrim(@p4), tutar = @p5, kdv_tutar = coalesce(@p6, 0), aciklama = coalesce(@p7, '')
                 where id = @p0
                """, islem,
                [satirId, istek.MasrafId, istek.HarcamaTarihi?.ToDateTime(TimeOnly.MinValue), istek.BelgeTuru,
                 istek.BelgeNo, istek.Tutar, istek.KdvTutar, istek.Aciklama], iptal);
            // FİŞ BAĞI belge no ile: numara düzeltilince fiş satırdan kopmasın.
            if (eskiNo != istek.BelgeNo!.Trim())
                await b.CalistirAsync("""
                    update public.dokuman d set belge_turu = btrim(@p1)
                      from public.personel_masraf_satir s
                     where s.id = @p2 and d.kaynak = 'masraf-beyan' and d.kaynak_id = s.beyan_id and d.belge_turu = @p0
                    """, islem, [eskiNo, istek.BelgeNo, satirId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogSatir, satirId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { istek.BelgeNo, istek.Tutar }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { satirId, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/masraf/{id:int}/hatirlat", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.OnayBildirimi haber, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await KendiTalebi.IsteAsync(veri, baglam, "select taraf_id from public.personel_masraf where id = @p0",
                id, "ik.masraf", Islem.Degistir, iptal);
            await using var b = await veri.AcAsync(iptal);
            var onayId = await b.TekDegerAsync<long?>("""
                select o.id from public.onay o where o.kaynak_tur = @p0 and o.kaynak_id = @p1 and o.durum = 0
                 order by o.id desc limit 1
                """, null, [LogBeyan, id], iptal)
                ?? throw GentegreHatasi.IsKurali("Bu beyan onayda değil.");
            var n = await haber.SiradakiniBildirAsync(b, onayId, baglam.KullaniciId, baglam.SubeId, iptal);
            return Results.Ok(new { bildirim = n, izlemeNo = baglam.IzlemeNo });
        });
    }
}
