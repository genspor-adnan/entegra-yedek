using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İZİN TALEP KARTI (959, mockup Ekranlar/IK/izin_talep_karti.html).
///
/// Kartın yan bilgileri tek uçta: gün sayısı ve işe dönüş, ay takvimi
/// (resmî tatil), bakiye, bölümde aynı günler kim yok + kalan kişi uyarısı,
/// randevu etkisi, akış. Kart verisinin kendisi generic kart uçlarından
/// (personelIzin); bu uç yalnız okur ve kaydı DEĞİŞTİRMEZ.
/// </summary>
public static partial class IzinUclari
{
    private static void IzinKartUclariniEkle(RouteGroupBuilder grup)
    {
        // BAĞLAM: tarih / saat değiştikçe kart yeniden sorar (kayıt gerekmez).
        grup.MapGet("/izin-baglam", async (int tarafId, DateOnly? bas, DateOnly? bit,
            bool? isGunu, string? saatBas, string? saatBit, int? izinId,
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIsteKendi(tarafId, "ik.izin", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var personel = await b.TekAsync("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad,
                       coalesce(p.gorev, '') as gorev, p.sube_id as "subeId",
                       (select string_agg(d.ad, ', ') from public.departman d
                         where d.id in (select public.fn_kullanici_bolumleri(@p0))) as bolum
                  from public.taraf t left join public.taraf_personel p on p.id = t.id
                 where t.id = @p0
                """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var bakiye = await BakiyeAsync(b, tarafId, null, iptal);

            object? sure = null;
            List<IDictionary<string, object?>> tatiller = [];
            object? ekip = null;
            var randevu = 0;
            if (bas is { } b0 && bit is { } b1 && b1 >= b0 && b1.DayNumber - b0.DayNumber <= 62)
            {
                var saatli = !string.IsNullOrWhiteSpace(saatBas) && !string.IsNullOrWhiteSpace(saatBit);
                var sube = personel?["subeId"] as int?;
                // GÜN: tetikle aynı kural - saatli tek gün ≤ 4,5 saat 0,5, üstü 1.
                var gun = saatli
                    ? await b.TekDegerAsync<decimal>("""
                        select case when (@p1::time - @p0::time) <= interval '4 hours 30 minutes' then 0.5 else 1 end
                        """, null, [saatBas!, saatBit!], iptal)
                    : await b.TekDegerAsync<decimal>(
                        "select public.fn_izin_gun(@p0::date, @p1::date, @p2::smallint, @p3)",
                        null, [b0.ToDateTime(TimeOnly.MinValue), b1.ToDateTime(TimeOnly.MinValue),
                               (short)(isGunu == true ? 1 : 0), sube], iptal);
                // İŞE DÖNÜŞ: bitişten sonraki ilk iş günü (hafta sonu ve tam gün tatil değil).
                var donus = await b.TekDegerAsync<DateTime>("""
                    select g::date from generate_series(@p0::date + 1, @p0::date + 20, interval '1 day') g
                     where extract(isodow from g) < 6
                       and not exists (select 1 from public.resmi_tatil r
                                        where r.tarih = g::date and r.aktif = 1 and coalesce(r.yarim_gun, 0) = 0
                                          and (r.sube_id is null or r.sube_id = coalesce(@p1, r.sube_id)))
                     order by g limit 1
                    """, null, [b1.ToDateTime(TimeOnly.MinValue), sube], iptal);
                sure = new { gun, donus = DateOnly.FromDateTime(donus), saatli };

                // TAKVİM: başlangıç ayının başından bitiş ayının sonuna resmî tatiller.
                tatiller = await b.ListeAsync("""
                    select r.tarih, r.ad, coalesce(r.yarim_gun, 0) as yarim
                      from public.resmi_tatil r
                     where r.aktif = 1 and r.tarih between date_trunc('month', @p0::date)::date
                                                     and (date_trunc('month', @p1::date) + interval '1 month - 1 day')::date
                       and (r.sube_id is null or r.sube_id = coalesce(@p2, r.sube_id))
                     order by r.tarih
                    """, null, [b0.ToDateTime(TimeOnly.MinValue), b1.ToDateTime(TimeOnly.MinValue), sube],
                    OkuyucuGenisletmeleri.Sozluk, iptal);

                // EKİPTE AYNI GÜNLER: bölüm arkadaşları, izin (taslak hariç) ve kapanan istisna.
                var gunler = Enumerable.Range(0, b1.DayNumber - b0.DayNumber + 1).Select(i => b0.AddDays(i))
                                       .Where(d => d.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday)).Take(15).ToList();
                var kisiler = await b.ListeAsync("""
                    select k.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), k.kod) as ad
                      from public.fn_bolum_arkadaslari(@p0) a(id)
                      join public.taraf_kullanici k on k.id = a.id
                      left join public.taraf t on t.id = k.id
                     order by 2 limit 30
                    """, null, [tarafId], r => (Id: r.GetInt32(0), Ad: r.GetString(1)), iptal);
                var yokluk = await b.ListeAsync("""
                    select i.taraf_id as kisi, i.baslangic_tarihi as bas, i.bitis_tarihi as bit,
                           'izin' as neden, i.durum
                      from public.personel_izin i
                     where i.taraf_id = any(@p0) and i.durum in (1, 2) and i.id <> coalesce(@p3, 0)
                       and i.baslangic_tarihi <= @p2::date and i.bitis_tarihi >= @p1::date
                    union all
                    select s.hekim_id, s.bas_tarih, s.bit_tarih,
                           case s.tur when 2 then 'kongre' when 5 then 'kapalı' else 'istisna' end, s.durum
                      from public.hekim_calisma_istisna s
                     where s.hekim_id = any(@p0) and s.tur in (1, 2, 5) and s.durum = 1
                       and s.bas_tarih <= @p2::date and s.bit_tarih >= @p1::date
                    """, null,
                    [kisiler.Select(k => k.Id).Append(tarafId).ToArray(), b0.ToDateTime(TimeOnly.MinValue),
                     b1.ToDateTime(TimeOnly.MinValue), izinId], OkuyucuGenisletmeleri.Sozluk, iptal);
                string? Neden(int kisi, DateOnly g) => yokluk.FirstOrDefault(y =>
                    Convert.ToInt32(y["kisi"]) == kisi
                    && DateOnly.FromDateTime(Convert.ToDateTime(y["bas"])) <= g
                    && DateOnly.FromDateTime(Convert.ToDateTime(y["bit"])) >= g)?["neden"] as string;
                var enAzMetin = await b.TekDegerAsync<string?>(
                    "select deger from public.referans where anahtar = 'ik.izin_bolum_en_az'", null, [], iptal);
                var enAz = int.TryParse(enAzMetin, out var e) ? e : 2;
                var toplam = kisiler.Count + 1;
                ekip = new
                {
                    gunler,
                    enAz,
                    toplam,
                    kisiler = kisiler.Select(k => new { k.Id, k.Ad, durumlar = gunler.Select(g => Neden(k.Id, g)).ToList() }),
                    // Bu talep onaylanırsa o gün kalan: toplam - (kişinin kendisi) - diğer yoklar.
                    kalan = gunler.Select(g => toplam - 1 - kisiler.Count(k => Neden(k.Id, g) is not null)).ToList(),
                };
                randevu = await RandevuSayisiAsync(b, tarafId, b0, b1, iptal);
            }

            // AKIŞ: oluşturma + onay basamakları (kimin, ne zaman, gerekçe).
            List<IDictionary<string, object?>> akis = [];
            if (izinId is > 0)
                akis = await b.ListeAsync("""
                    select 0 as sira, 'olustu' as tur, i.ekleme_tarihi as zaman,
                           coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as kim, '' as metin
                      from public.personel_izin i left join public.taraf t on t.id = i.ekleyen
                     where i.id = @p0
                    union all
                    select 1, 'gonderildi', o.baslama, '', (select string_agg(a.ad, ' → ' order by a.sira) from public.onay_adim a where a.onay_id = o.id)
                      from public.onay o where o.kaynak_tur = @p1 and o.kaynak_id = @p0
                    union all
                    select 2 + a.sira, case a.durum when 1 then 'onay' when 2 then 'red' when 3 then 'bilgi'
                                                    when 4 then 'sozlu' when 5 then 'atlandi' end,
                           a.karar_zamani, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                           a.ad || coalesce(' · “' || nullif(a.gerekce, '') || '”', '')
                      from public.onay o join public.onay_adim a on a.onay_id = o.id
                      left join public.taraf t on t.id = a.karar_veren_id
                     where o.kaynak_tur = @p1 and o.kaynak_id = @p0 and a.karar_zamani is not null
                    union all
                    select 90, 'iptal', i.degistirme_tarihi, '', i.iptal_neden
                      from public.personel_izin i where i.id = @p0 and i.durum = 4
                     order by 3 nulls last, 1
                    """, null, [izinId.Value, LogIzin], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { personel, bakiye, sure, tatiller, ekip, randevu, akis, izlemeNo = baglam.IzlemeNo });
        });

        // HATIRLAT: sıradaki basamağa bildirimi yeniden gönder (talep eden ya da İK).
        grup.MapPost("/izin/{id:int}/hatirlat", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.OnayBildirimi haber, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await KendiTalebi.IsteAsync(veri, baglam, "select taraf_id from public.personel_izin where id = @p0",
                id, "ik.izin", Islem.Degistir, iptal);
            await using var b = await veri.AcAsync(iptal);
            var onayId = await b.TekDegerAsync<long?>("""
                select o.id from public.onay o where o.kaynak_tur = @p0 and o.kaynak_id = @p1 and o.durum = 0
                 order by o.id desc limit 1
                """, null, [LogIzin, id], iptal)
                ?? throw GentegreHatasi.IsKurali("Bu talep onayda değil.");
            var n = await haber.SiradakiniBildirAsync(b, onayId, baglam.KullaniciId, baglam.SubeId, iptal);
            return Results.Ok(new { bildirim = n, izlemeNo = baglam.IzlemeNo });
        });
    }
}
