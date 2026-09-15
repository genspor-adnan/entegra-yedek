using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ ÜNİTE PANOSU SAYAÇLARI (mockup
/// <c>Ekranlar/Goz/goz_unite_panosu.html</c> üst şeridi).
///
/// <para><b>Sayılar SUNUCUDA hesaplanır.</b> Kanban yalnız AÇIK istasyonları
/// (<c>v_goz_unite_akis</c>, <c>cikis is null</c>) okuyor; "bugün kaç hasta
/// geldi", "kaçı tamamlandı", "ortalama ziyaret kaç dakika" sorularının cevabı
/// o kümede YOK. İstemci elindeki satırları sayarak bunları üretmeye
/// kalksaydı, tamamlanan hastaları hiç göremediği için panoda hep eksik bir
/// gün görünürdü.</para>
///
/// <para><b>DARBOĞAZ tahmin değil ölçümdür:</b> en uzun bekleyen istasyon adı
/// ve oradaki kişi sayısı döner. "Ünite yoğun" cümlesi kimseye iş yaptırmaz;
/// "görüntülemede 4 kişi, en uzunu 31 dakika" ikinci cihazı ya da randevu
/// aralığını gündeme getirir.</para>
///
/// <para><b>Gün sınırı kurumun saat diliminde:</b> veritabanı UTC çalışıyor,
/// ekran Türkiye saatini gösteriyor. <c>giris::date = current_date</c> deseydik
/// sabahın ilk üç saatindeki kabuller "dünkü" sayılırdı.</para>
/// </summary>
public static partial class GozUclari
{
    private static void UniteOzetiEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/unite-ozet", async (
            DateOnly? gun, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Gor);

            var tarih = gun ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            var dilim = Gentegre.Cekirdek.Saat.Dilim(null);
            var gunBas = TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(tarih.ToDateTime(TimeOnly.MinValue),
                                     DateTimeKind.Unspecified), dilim);
            var gunSon = gunBas.AddDays(1);

            await using var baglanti = await veri.AcAsync(iptal);

            // GÜNÜN ZİYARETLERİ: ziyaret = başvuru (belge). Aynı hasta gün
            //   içinde iki kez gelebilir; sayaç HASTAYI değil ZİYARETİ sayar -
            //   ünitenin yükü ziyaret başına doğuyor.
            var gunOzet = await baglanti.TekAsync("""
                with ziyaret as (
                    select i.belge_id,
                           min(i.giris) as ilk_giris,
                           max(i.cikis) as son_cikis,
                           count(*) filter (where i.cikis is null) as acik
                      from public.goz_ziyaret_istasyon i
                     where i.giris >= @p0 and i.giris < @p1
                     group by i.belge_id
                )
                select count(*)::int                                        as ziyaret,
                       count(*) filter (where acik = 0)::int                as tamamlanan,
                       count(*) filter (where acik > 0)::int                as unitede,
                       -- ORTALAMA ZİYARET yalnız TAMAMLANANLARDAN: hâlâ
                       --   ünitede olan hastayı ortalamaya katmak, günün
                       --   ortasında süreyi olduğundan kısa gösterirdi.
                       coalesce(round(avg(extract(epoch from (son_cikis - ilk_giris)) / 60)
                                      filter (where acik = 0))::int, 0)     as ort_ziyaret_dk
                  from ziyaret
                """, null, [gunBas, gunSon], o => new
            {
                ziyaret = o.GetInt32(0),
                tamamlanan = o.GetInt32(1),
                unitede = o.GetInt32(2),
                ortZiyaretDk = o.GetInt32(3),
            }, iptal);

            // AÇIK İSTASYONLAR: kanbanın gösterdiği küme. Bekleme ölçümleri
            //   buradan - kapanmış satırın beklemesi geçmişte kaldı.
            var acik = await baglanti.TekAsync("""
                select count(*)::int                                          as bekleyen,
                       coalesce(round(avg(extract(epoch from (now() - i.giris)) / 60))::int, 0)
                                                                              as ort_bekleme_dk,
                       coalesce(max(extract(epoch from (now() - i.giris)) / 60)::int, 0)
                                                                              as en_uzun_dk,
                       count(*) filter (where i.dilatasyon_zamani is not null)::int
                                                                              as dilatasyonda,
                       count(*) filter (where i.dilatasyon_zamani is not null
                                          and i.dilatasyon_zamani + interval '20 minutes' <= now())::int
                                                                              as dilatasyon_hazir
                  from public.goz_ziyaret_istasyon i
                 where i.cikis is null
                """, null, [], o => new
            {
                bekleyen = o.GetInt32(0),
                ortBeklemeDk = o.GetInt32(1),
                enUzunDk = o.GetInt32(2),
                dilatasyonda = o.GetInt32(3),
                dilatasyonHazir = o.GetInt32(4),
            }, iptal);

            // EN UZUN BEKLEYEN kim ve nerede: sayının yanında ADI da dursun -
            //   "31 dk" tek başına kimseyi harekete geçirmiyor.
            var enUzun = await baglanti.TekAsync("""
                select t.unvan, i.istasyon,
                       (extract(epoch from (now() - i.giris)) / 60)::int as dk
                  from public.goz_ziyaret_istasyon i
                  join public.taraf t on t.id = i.hasta_id
                 where i.cikis is null
                 order by i.giris
                 limit 1
                """, null, [], o => new
            {
                hasta = o.GetString(0),
                istasyon = (int)o.GetInt16(1),
                dk = o.GetInt32(2),
            }, iptal);

            // İSTASYON KIRILIMI + DARBOĞAZ: hangi masada kaç kişi bekliyor ve
            //   oranın en uzun beklemesi kaç dakika.
            var istasyonlar = await baglanti.ListeAsync("""
                select i.istasyon, count(*)::int as sayi,
                       coalesce(max(extract(epoch from (now() - i.giris)) / 60)::int, 0) as en_uzun_dk
                  from public.goz_ziyaret_istasyon i
                 where i.cikis is null
                 group by i.istasyon
                 order by i.istasyon
                """, null, [], o => new
            {
                istasyon = (int)o.GetInt16(0),
                sayi = o.GetInt32(1),
                enUzunDk = o.GetInt32(2),
            }, iptal);

            // ODA / CİHAZ DOLULUĞU: pano HASTAYI değil KAYNAĞI sayar.
            //   Bekleme çoğu zaman hekimden değil tek cihazdan doğuyor; hasta
            //   bazlı bakan pano bunu gizler ("bugün neden geç kaldık"
            //   sorusunun cevabı burada).
            //
            //   Oda ADI akış satırında metin: ünitede oda ve cihaz aynı alanda
            //   tutuluyor (OCT-1, HFA, Oda 3). Ayrı bir kaynak tablosu
            //   olmadığı için doluluk buradan çıkar - tanım tablosu gelince
            //   sorgu ona bağlanır, ekran değişmez.
            var odalar = await baglanti.ListeAsync("""
                select i.oda,
                       count(*)::int                                   as sayi,
                       -- ODADAKİ İŞ: en son giren hasta o kaynağı KULLANIYOR,
                       --   ötekiler sırada bekliyor.
                       (array_agg(t.unvan order by i.giris desc))[1]    as hasta,
                       (array_agg(i.istasyon order by i.giris desc))[1] as istasyon,
                       (array_agg((extract(epoch from (now() - i.giris)) / 60)::int
                                  order by i.giris desc))[1]            as sure_dk,
                       max((extract(epoch from (now() - i.giris)) / 60)::int) as en_uzun_dk
                  from public.goz_ziyaret_istasyon i
                  join public.taraf t on t.id = i.hasta_id
                 where i.cikis is null and i.oda <> ''
                 group by i.oda
                 order by max(extract(epoch from (now() - i.giris))) desc
                """, null, [], o => new
            {
                oda = o.GetString(0),
                sayi = o.GetInt32(1),
                hasta = o.GetString(2),
                istasyon = (int)o.GetInt16(3),
                sureDk = o.GetInt32(4),
                enUzunDk = o.GetInt32(5),
            }, iptal);

            // HEKİM YÜKÜ: tamamlanan, bekleyen ve ortalama muayene süresi.
            //   TEKNİKER DE BU LİSTEDE (personel_id kim olursa olsun): ön
            //   tetkik ünitenin girişidir, tıkanırsa hekim odası boş kalır.
            //   Yalnız hekim sayılsaydı pano "hekimler yavaş" derdi - oysa
            //   sıra girişte.
            var hekimler = await baglanti.ListeAsync("""
                with gun as (
                    select i.personel_id, i.istasyon, i.giris, i.cikis
                      from public.goz_ziyaret_istasyon i
                     where i.giris >= @p0 and i.giris < @p1
                       and i.personel_id is not null
                )
                select p.unvan,
                       count(*) filter (where g.cikis is not null)::int   as tamamlanan,
                       count(*) filter (where g.cikis is null)::int       as bekleyen,
                       coalesce(round(avg(extract(epoch from (g.cikis - g.giris)) / 60)
                                      filter (where g.cikis is not null))::int, 0)
                                                                          as ort_dk,
                       coalesce(max((extract(epoch from (now() - g.giris)) / 60)::int)
                                filter (where g.cikis is null), 0)        as en_uzun_dk
                  from gun g
                  join public.taraf p on p.id = g.personel_id
                 group by p.unvan
                 order by count(*) filter (where g.cikis is null) desc, p.unvan
                """, null, [gunBas, gunSon], o => new
            {
                personel = o.GetString(0),
                tamamlanan = o.GetInt32(1),
                bekleyen = o.GetInt32(2),
                ortDk = o.GetInt32(3),
                enUzunDk = o.GetInt32(4),
            }, iptal);

            // DARBOĞAZ = en uzun bekleyen istasyon (eşitlikte kalabalık olan).
            var darbogaz = istasyonlar
                .OrderByDescending(i => i.enUzunDk).ThenByDescending(i => i.sayi)
                .FirstOrDefault();

            return Results.Ok(new
            {
                gun = tarih,
                gunOzet,
                acik,
                enUzun,
                istasyonlar,
                darbogaz,
                odalar,
                hekimler,
            });
        });
    }
}
