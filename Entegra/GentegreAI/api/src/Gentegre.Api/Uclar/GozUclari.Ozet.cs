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
                select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan, i.istasyon,
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
            //   976: kaynak artık TANIMLI (goz_kaynak) ve görünüm BOŞ kaynağı
            //   da döndürüyor. Mockup'ın söylediği cümle - "HFA sırası dört
            //   kişiyken muayene odası boş duruyor" - ancak boş oda da satır
            //   üretirse kurulabiliyor; yalnız dolu odaları saymak, panonun
            //   asıl işini (atıl kaynağı göstermek) imkânsız kılardı.
            var odalar = await baglanti.ListeAsync("""
                select d.kaynak_id, d.kod, d.ad, d.tur, d.tur_adi, d.sahip_adi,
                       d.sayi, d.hasta, d.istasyon, d.sure_dk, d.en_uzun_dk, d.bos, d.tanimli
                  from public.v_goz_kaynak_doluluk d
                 order by d.bos, d.en_uzun_dk desc, d.sira, d.ad
                """, null, [], o => new
            {
                kaynakId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0),
                kod = o.GetString(1),
                // "oda" adı KORUNUYOR: ekranın kolon adı değişmesin diye -
                //   tanım geldi, sözleşme değişmedi.
                oda = o.GetString(2),
                tur = (int)o.GetInt16(3),
                turAdi = o.GetString(4),
                sahip = o.GetString(5),
                sayi = o.GetInt32(6),
                hasta = o.GetString(7),
                istasyon = (int)o.GetInt16(8),
                sureDk = o.GetInt32(9),
                enUzunDk = o.GetInt32(10),
                bos = (int)o.GetInt16(11) == 1,
                tanimli = (int)o.GetInt16(12) == 1,
            }, iptal);

            // HEKİM YÜKÜ: tamamlanan, bekleyen ve ortalama muayene süresi.
            //   TEKNİKER DE BU LİSTEDE (personel_id kim olursa olsun): ön
            //   tetkik ünitenin girişidir, tıkanırsa hekim odası boş kalır.
            //   Yalnız hekim sayılsaydı pano "hekimler yavaş" derdi - oysa
            //   sıra girişte.
            //
            //   976: GECİKME kolonu eklendi (mockup "+12 dk"). Gecikme, hastanın
            //   randevu saatiyle istasyona GİRİŞİ arasındaki fark - randevusuz
            //   hastada ölçülemez ve NULL kalır; sıfır yazmak "zamanında" demek
            //   olurdu ve panonun en çok bakılan kolonu yanlış cesaret verirdi.
            var hekimler = await baglanti.ListeAsync("""
                with gun as (
                    select i.personel_id, i.istasyon, i.giris, i.cikis, i.belge_id
                      from public.goz_ziyaret_istasyon i
                     where i.giris >= @p0 and i.giris < @p1
                       and i.personel_id is not null
                )
                select g.personel_id,
                       public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120) as unvan,
                       count(*) filter (where g.cikis is not null)::int   as tamamlanan,
                       count(*) filter (where g.cikis is null)::int       as bekleyen,
                       coalesce(round(avg(extract(epoch from (g.cikis - g.giris)) / 60)
                                      filter (where g.cikis is not null))::int, 0)
                                                                          as ort_dk,
                       coalesce(max((extract(epoch from (now() - g.giris)) / 60)::int)
                                filter (where g.cikis is null), 0)        as en_uzun_dk,
                       round(avg(extract(epoch from (g.giris - r.baslangic)) / 60))::int
                                                                          as gecikme_dk,
                       count(r.baslangic)::int                            as randevulu
                  from gun g
                  join public.taraf p on p.id = g.personel_id
                  left join lateral (
                      select rr.baslangic
                        from public.randevu rr
                       where rr.belge_id = g.belge_id
                       order by rr.baslangic
                       limit 1
                  ) r on true
                 group by g.personel_id, public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120)
                 order by count(*) filter (where g.cikis is null) desc, public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120)
                """, null, [gunBas, gunSon], o => new
            {
                personelId = o.GetInt32(0),
                personel = o.GetString(1),
                tamamlanan = o.GetInt32(2),
                bekleyen = o.GetInt32(3),
                ortDk = o.GetInt32(4),
                enUzunDk = o.GetInt32(5),
                gecikmeDk = o.IsDBNull(6) ? (int?)null : o.GetInt32(6),
                randevulu = o.GetInt32(7),
            }, iptal);

            // SOL PANEL SÜZGEÇLERİ (976, mockup şeridindeki "Hekim ▾ / Ünite ▾"):
            //   kimde kaç açık satır var ve hangi kaynakta kaç kişi bekliyor.
            //   Sayılar listenin kendi süzgecinden GEÇMEDEN hesaplanıyor: panel
            //   hekimi seçtikten sonra da öteki hekimlerin yükünü göstermeli,
            //   yoksa seçim yapan kişi kendi dışındaki yığılmayı göremez.
            var panelHekimler = await baglanti.ListeAsync("""
                select a.hekim_id, a.hekim_adi, count(*)::int as sayi
                  from public.v_goz_unite_akis a
                 where a.hekim_id is not null
                 group by a.hekim_id, a.hekim_adi
                 order by count(*) desc, a.hekim_adi
                """, null, [], o => new
            {
                id = o.GetInt32(0),
                ad = o.GetString(1),
                sayi = o.GetInt32(2),
            }, iptal);

            // VARDİYA: mockup şeridinde "🕐 Vardiya 08:00–16:00" yazıyor. Saat
            //   çalışma planından (718) geliyor; panoya elle yazılan bir aralık
            //   plan değişince sessizce yanlışa düşerdi.
            //   YALNIZ PANODAKİ HEKİMLER: fonksiyon kurumun bütün hekimlerini
            //   döndürüyor (ellisi birden); panoda dördü varken elli satır
            //   taşımak, kullanılmayan veriyi her 30 saniyede bir yollamak olurdu.
            //   Saat "09:00:00" değil "09:00" - saniye panoda gürültü.
            var vardiyalar = await baglanti.ListeAsync("""
                select b.hekim_id,
                       (to_char(min(b.saat_bas), 'HH24:MI') || '-'
                        || to_char(max(b.saat_bit), 'HH24:MI'))::varchar(20) as vardiya
                  from public.fn_hekim_calisma_bloklari(@p0, @p1, @p1) b
                 where exists (select 1 from public.v_goz_unite_akis a
                                where a.hekim_id = b.hekim_id)
                 group by b.hekim_id
                """, null, [baglam.SubeId, tarih], o => new
            {
                id = o.GetInt32(0),
                vardiya = o.GetString(1),
            }, iptal);

            // ANTET TEK KAYNAKTAN (772, v_sube_antet): gun ozeti ciktisi kurum
            //   basligiyla basiliyor. Dokum ucu ('dokum' yetkisi ister) yerine
            //   buraya eklendi - panoyu kullanan teknikerin dokum yetkisi yok.
            var antet = await baglanti.TekAsync("""
                select a.unvan, a.adres, a.ilce, a.il, a.telefon, a.sube_ad,
                       a.logo_dokuman_id
                  from public.v_sube_antet a
                 where a.sube_id = coalesce(@p0,
                       (select id from public.sube where varsayilan = 1 limit 1))
                """, null, [baglam.SubeId], o => new
            {
                unvan = o.IsDBNull(0) ? "" : o.GetString(0),
                adres = o.IsDBNull(1) ? "" : o.GetString(1),
                ilce = o.IsDBNull(2) ? "" : o.GetString(2),
                il = o.IsDBNull(3) ? "" : o.GetString(3),
                telefon = o.IsDBNull(4) ? "" : o.GetString(4),
                subeAd = o.IsDBNull(5) ? "" : o.GetString(5),
                logoDokumanId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6),
            }, iptal);

            var panelKaynaklar = odalar
                .Where(o => o.sayi > 0)
                .Select(o => new { o.kaynakId, ad = o.oda, o.sayi })
                .ToList();

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
                panelHekimler,
                panelKaynaklar,
                vardiyalar,
                antet,
            });
        });
    }
}
