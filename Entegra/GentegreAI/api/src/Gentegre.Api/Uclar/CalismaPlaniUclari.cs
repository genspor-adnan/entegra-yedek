using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HEKİM ÇALIŞMA PLANI (711) - türetilen haftalık plan ve "bugün çalışanlar".
/// Şablon/istisna kayıtları generic kartla (kart hesapları: CalismaPlaniUclari.Kart,
/// listeler: CalismaPlaniUclari.Liste); burada türetme (<c>fn_hekim_calisma_bloklari</c>),
/// Çalışma Planları sayfasının ek verisi (mockup <c>Ekranlar/Randevu/calisma_planlari.html</c>)
/// ve kayıt kabulün bugün listesi.
///
/// Randevu anları (timestamptz) bloklarla şubenin DUVAR SAATİNDE karşılaştırılır
/// (<see cref="YerelSql"/>, 946 kuralı) - eskiden UTC karşılaştırılıyordu, sayılar 3 saat kayıktı.
/// </summary>
public static partial class CalismaPlaniUclari
{
    public static void CalismaPlaniUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/calisma-plani").WithTags("CalismaPlani").RequireAuthorization();
        KartUclariniEkle(grup);
        ListeUclariniEkle(grup);

        // Haftalık (ya da verilen aralık) türetilmiş bloklar. sube 0 = tüm şubeler.
        //   ozet=1 (Çalışma Planları sayfası): onay bekleyen istisnalar + işlem
        //   bekleyen randevu da döner; takvim / uygun saatler bunları istemez.
        grup.MapGet("/", async (
            DateOnly? bas, DateOnly? bit, int? hekimId, int? departmanId, int? sube, int? ozet,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            var b0 = bas ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            var b1 = bit ?? b0.AddDays(6);
            if (b1 < b0) b1 = b0;
            if (b1.DayNumber - b0.DayNumber > 62) b1 = b0.AddDays(62);
            var subeId = sube ?? baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            // randevu: bloğa düşen planlı/gelen randevu sayısı · dolu: kapladığı slot
            //   (20 dk'lık randevu 15 dk'lık blokta iki slot kapatır).
            var bloklar = await b.ListeAsync($"""
                select f.hekim_id, f.hekim, f.sube_id, f.departman_id, f.departman, f.gun, f.saat_bas, f.saat_bit, f.slot_dk, f.kanallar,
                       f.kaynak, f.istisna_tur, f.sablon_id, f.istisna_id, f.aciklama, coalesce(rr.adet, 0)::int, coalesce(rr.slot, 0)::int,
                       coalesce(s.ad, '')
                  from public.fn_hekim_calisma_bloklari(@p0, @p1, @p2, @p3, @p4) f
                  left join public.hekim_calisma_sablon s on s.id = f.sablon_id
                  left join lateral (
                      select count(*) as adet, sum(ceil(greatest(r.sure_dk, 1)::numeric / greatest(f.slot_dk, 1))) as slot
                        from public.randevu r
                       where f.saat_bas is not null and r.hekim_id = f.hekim_id and r.durum in (1, 2)
                         and {YerelSql}::date = f.gun
                         and {YerelSql}::time >= f.saat_bas and {YerelSql}::time < f.saat_bit) rr on true
                """, null, [subeId, b0, b1, hekimId, departmanId], o => new
            {
                hekimId = o.GetInt32(0), hekim = o.GetString(1), subeId = o.GetInt32(2), departmanId = o.GetInt32(3), departman = o.GetString(4),
                gun = o.GetFieldValue<DateOnly>(5), saatBas = o.IsDBNull(6) ? null : o.GetFieldValue<TimeOnly>(6).ToString("HH:mm"),
                saatBit = o.IsDBNull(7) ? null : o.GetFieldValue<TimeOnly>(7).ToString("HH:mm"), slotDk = (int)o.GetInt16(8),
                kanallar = o.GetString(9), kaynak = (int)o.GetInt16(10), istisnaTur = o.IsDBNull(11) ? (int?)null : o.GetInt16(11),
                sablonId = o.IsDBNull(12) ? (int?)null : o.GetInt32(12), istisnaId = o.IsDBNull(13) ? (int?)null : o.GetInt32(13),
                aciklama = o.GetString(14), randevu = o.GetInt32(15), dolu = o.GetInt32(16), sablon = o.GetString(17),
            }, iptal);
            var hekimler = await b.ListeAsync("""
                select distinct t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan, coalesce(t.departman::integer, 0)
                  from public.hekim_calisma_sablon s join public.taraf t on t.id = s.hekim_id
                 where s.aktif = 1 order by public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1), departmanId = o.GetInt32(2) }, iptal);
            var bolumler = await b.ListeAsync("""
                select d.id, d.ad, d.randevusuz_kabul from public.departman d
                 where d.durum = 1 and (public.fn_bolum_planli(d.id) = 1 or d.randevusuz_kabul = 1) order by d.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1), randevusuz = o.GetInt16(2) == 1 }, iptal);
            var subeler = await b.ListeAsync("select id, ad from public.sube where aktif = 1 order by ad", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            if (ozet != 1) return Results.Ok(new { bas = b0, bit = b1, subeId, bloklar, hekimler, bolumler, subeler });

            // ONAY BEKLEYEN İSTİSNALAR: plan onları henüz uygulamaz (fn yalnız onaylıyı
            //   okur) ama sayfada görünmeli - kapanacak günler ve işlem bekleyecek randevu.
            var bekleyenIstisnalar = await b.ListeAsync($"""
                select i.id, i.hekim_id, i.tur, i.bas_tarih, i.bit_tarih, i.aciklama, i.saat_bas, i.saat_bit,
                       (select count(*) from public.randevu r
                         where r.hekim_id = i.hekim_id and r.durum = 1 and i.tur <> 4
                           and {YerelSql}::date between greatest(i.bas_tarih, current_date) and i.bit_tarih
                           and (i.departman_id is null or r.bolum = i.departman_id)
                           and {EtkiSql("i")})::int
                  from public.hekim_calisma_istisna i
                 where i.durum = 0 and i.bit_tarih >= @p0 and i.bas_tarih <= @p1
                   and (@p2::integer is null or i.hekim_id = @p2)
                """, null, [b0, b1, hekimId], o => new
            {
                id = o.GetInt32(0), hekimId = o.GetInt32(1), tur = (int)o.GetInt16(2), bas = o.GetFieldValue<DateOnly>(3),
                bit = o.GetFieldValue<DateOnly>(4), aciklama = o.GetString(5),
                saatBas = o.IsDBNull(6) ? null : o.GetString(6), saatBit = o.IsDBNull(7) ? null : o.GetString(7), randevu = o.GetInt32(8),
            }, iptal);
            // İŞLEM BEKLEYEN RANDEVU (İzin & İstisnalar listesinin özetiyle aynı hesap).
            var islemBekleyen = await b.TekDegerAsync<long>($"""
                select coalesce(sum((select count(*) from public.randevu r
                         where r.hekim_id = i.hekim_id and r.durum = 1
                           and {YerelSql}::date between greatest(i.bas_tarih, current_date) and i.bit_tarih
                           and (i.departman_id is null or r.bolum = i.departman_id)
                           and {EtkiSql("i")})), 0)
                  from public.hekim_calisma_istisna i
                 where i.durum <> 2 and i.tur in (1, 2, 3, 5) and i.bit_tarih >= current_date
                """, null, [], iptal);
            return Results.Ok(new { bas = b0, bit = b1, subeId, bloklar, hekimler, bolumler, subeler, bekleyenIstisnalar, islemBekleyen });
        });

        // Seçili hücre: doktorun o günkü randevuları (şube saatinde).
        grup.MapGet("/gun", async (int hekimId, DateOnly gun, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var randevular = await b.ListeAsync($"""
                select r.id, to_char({YerelSql}, 'HH24:MI'), r.sure_dk, r.durum,
                       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), coalesce(kd.ad, '')
                  from public.randevu r
                  join public.taraf t on t.id = r.hasta_id
                  left join public.kod_liste kl on kl.kod = 'randevu.tip'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = r.tip
                 where r.hekim_id = @p0 and r.durum in (1, 2) and {YerelSql}::date = @p1
                 order by r.baslangic
                """, null, [hekimId, gun], o => new
            {
                id = o.GetInt32(0), saat = o.GetString(1), sureDk = (int)o.GetInt16(2), durum = (int)o.GetInt16(3),
                hasta = o.GetString(4), tip = o.GetString(5),
            }, iptal);
            return Results.Ok(new { randevular });
        });

        // Kayıt kabul + "Bugün çalışanlar": bugün açık bloğu olan doktorlar (şimdi
        //   muayenede mi, sıradaki boş saat), bugün olmayanlar (izin / kongre / İK)
        //   ve aktarılmamış randevuları, randevusuz bölümler.
        grup.MapGet("/bugun", async (
            DateOnly? gun, int? sube, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            var dilimAdi = baglam.ZamanDilimi == "" ? null : baglam.ZamanDilimi;
            var simdi = Gentegre.Cekirdek.Saat.SimdiDilim(dilimAdi);
            var g = gun ?? DateOnly.FromDateTime(simdi);
            var simdiDk = g == DateOnly.FromDateTime(simdi) ? simdi.Hour * 60 + simdi.Minute : -1;
            var subeId = sube ?? baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var bloklar = await b.ListeAsync("""
                select f.departman_id, f.departman, f.hekim_id, f.hekim, to_char(f.saat_bas, 'HH24:MI'), to_char(f.saat_bit, 'HH24:MI'),
                       f.slot_dk, f.kanallar, f.kaynak, f.istisna_tur, f.aciklama
                  from public.fn_hekim_calisma_bloklari(@p0, @p1, @p1) f
                 order by f.departman, f.hekim, f.saat_bas
                """, null, [subeId, g], o => new
            {
                departmanId = o.GetInt32(0), departman = o.GetString(1), hekimId = o.GetInt32(2), hekim = o.GetString(3),
                bas = o.IsDBNull(4) ? null : o.GetString(4), bit = o.IsDBNull(5) ? null : o.GetString(5),
                slot = Math.Max((int)o.GetInt16(6), 5), kanallar = o.GetString(7), kaynak = (int)o.GetInt16(8),
                istisnaTur = o.IsDBNull(9) ? (int?)null : o.GetInt16(9), aciklama = o.GetString(10),
            }, iptal);
            var hekimIdler = bloklar.Select(x => x.hekimId).Distinct().ToArray();
            var randevular = hekimIdler.Length == 0 ? [] : await b.ListeAsync($"""
                select r.hekim_id, extract(hour from {YerelSql})::int * 60 + extract(minute from {YerelSql})::int, r.sure_dk, r.durum
                  from public.randevu r
                 where r.hekim_id = any(@p0) and r.durum in (1, 2) and {YerelSql}::date = @p1
                """, null, [hekimIdler, g], o => (hekim: o.GetInt32(0), dk: o.GetInt32(1), sure: (int)o.GetInt16(2), durum: (int)o.GetInt16(3)), iptal);

            var satirlar = new List<object>();
            foreach (var grp in bloklar.GroupBy(x => (x.hekimId, x.departmanId)))
            {
                var acik = grp.Where(x => x.kaynak is 1 or 2 && x.bas is not null).ToList();
                var kapali = grp.FirstOrDefault(x => x.kaynak is 3 or 4);
                var rv = randevular.Where(r => r.hekim == grp.Key.hekimId).ToList();
                var ilk = grp.First();
                if (acik.Count == 0)
                {
                    if (kapali is null) continue;
                    satirlar.Add(new
                    {
                        ilk.departmanId, ilk.departman, ilk.hekimId, ilk.hekim, durum = "yok",
                        neden = kapali.kaynak == 4 ? (kapali.aciklama == "" ? "İK izni" : kapali.aciklama) : IstisnaAd(kapali.istisnaTur),
                        ik = kapali.kaynak == 4, bloklar = Array.Empty<object>(), kanallar = "",
                        randevu = rv.Count(r => r.durum == 1), gelen = 0, slot = 0, siradakiBos = (string?)null,
                    });
                    continue;
                }
                int Dk(string s) => int.Parse(s[..2]) * 60 + int.Parse(s[3..5]);
                var simdiIcinde = simdiDk >= 0 && acik.Any(x => simdiDk >= Dk(x.bas!) && simdiDk < Dk(x.bit!));
                var kapasite = acik.Sum(x => (Dk(x.bit!) - Dk(x.bas!)) / x.slot);
                string? bos = null;
                foreach (var x in acik.OrderBy(x => x.bas))
                {
                    for (var t = Dk(x.bas!); t + x.slot <= Dk(x.bit!) && bos is null; t += x.slot)
                        if ((simdiDk < 0 || t >= simdiDk) && !rv.Any(r => r.dk < t + x.slot && t < r.dk + Math.Max(r.sure, 1)))
                            bos = $"{t / 60:00}:{t % 60:00}";
                    if (bos is not null) break;
                }
                var sonBit = acik.Max(x => Dk(x.bit!));
                satirlar.Add(new
                {
                    ilk.departmanId, ilk.departman, ilk.hekimId, ilk.hekim,
                    durum = simdiIcinde ? "muayenede" : simdiDk >= 0 && simdiDk >= sonBit ? "bitti" : "saat-disi",
                    neden = (string?)null, ik = false,
                    bloklar = acik.Select(x => new { x.bas, x.bit, istisna = x.kaynak == 2 }).ToArray(),
                    kanallar = acik.First().kanallar,
                    randevu = rv.Count, gelen = rv.Count(r => r.durum == 2), slot = kapasite, siradakiBos = bos,
                });
            }
            var randevusuz = await b.ListeAsync("select id, ad from public.departman where durum = 1 and randevusuz_kabul = 1 order by ad", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(new { gun = g, subeId, simdi = simdiDk >= 0 ? $"{simdiDk / 60:00}:{simdiDk % 60:00}" : null, satirlar, randevusuz });
        });
    }

    private static string IstisnaAd(int? tur) => tur switch
    {
        1 => "İzin", 2 => "Kongre / eğitim", 3 => "Saat değişikliği", 4 => "Ek mesai", 5 => "Kapalı", _ => "Kapalı",
    };
}
