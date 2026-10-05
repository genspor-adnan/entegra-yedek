using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// YATIŞ KABULÜ VE YATAK DURUMU — bkz. <c>YatanUclari</c>.
///
/// <para>Yatak seçenekleri, kabul, "yatakta" işareti ve yatağın temizlendiği bildirimi.
///
/// <para><b>YATAK DURUMU YATIŞLA BİRLİKTE DEĞİŞİR, ELLE DEĞİL:</b> kabul yatağı
/// rezerve eder, "yatakta" dolu yapar. Hepsi tek işlemde yazılır - yatış açılıp
/// yatağın güncellenmediği bir ara hâl yok. Hangi yatağın verilebilir olduğu
/// (oda cinsiyet kuralı, temizlik, kapalı yatak) <c>YatakEngeli</c>'nde, yani
/// tek yerde hesaplanır.</para></para>
/// </summary>
public static partial class YatanUclari
{
    private static void KabulUclariniEkle(RouteGroupBuilder grup)
    {
        // -------------------------------------------------- yatak seçenekleri ----
        // Kabul ve nakil ekranının yatak listesi. UYGUN OLMAYAN YATAK DA DÖNER,
        //   gerekçesiyle: gizlenen yatak "neden görünmüyor" sorusunu telefona
        //   taşır, soluk görünen yatak cevabı ekranda verir.
        grup.MapGet("/yatak-secenekleri", async (
            int hastaId, int? departmanId, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var hastaCinsiyet = await baglanti.TekDegerAsync<short?>(
                "select coalesce(cinsiyet, 0) from public.taraf_hasta where id = @p0",
                null, [hastaId], iptal) ?? 0;

            var satirlar = await baglanti.ListeAsync("""
                select yk.id, yk.kod, yk.tip, yk.durum, yk.durum_notu,
                       o.id as oda_id, o.kod as oda_kod, o.ad as oda_ad, o.tur as oda_tur,
                       o.cinsiyet_kurali, o.izolasyon, o.bina, o.kat,
                       o.departman_id, coalesce(d.ad, '') as klinik,
                       coalesce(hz.ad, '') as ucret_hizmet,
                       -- ODADAKİ MEVCUT HASTA cinsiyeti: "ilk yatana göre
                       --   kilitlenir" kuralının girdisi.
                       (select min(th.cinsiyet) from public.yatis y2
                          join public.yatak yk2 on yk2.id = y2.yatak_id
                          left join public.taraf_hasta th on th.id = y2.hasta_id
                         where yk2.oda_id = o.id and y2.durum in (1, 2, 3)) as oda_cinsiyet
                  from public.yatak yk
                  join public.oda o on o.id = yk.oda_id
                  left join public.departman d on d.id = o.departman_id
                  left join public.hizmet hz on hz.id = o.ucret_hizmet_id
                 where yk.aktif = 1 and o.aktif = 1
                   and (@p0::int is null or o.departman_id = @p0)
                 order by o.bina, o.kat, o.kod, yk.kod
                """, null, [departmanId], o => new
            {
                id = o.GetInt32(0),
                yatak = o.GetString(1),
                tip = (int)o.GetInt16(2),
                durum = o.GetInt16(3),
                durumNotu = o.GetString(4),
                odaId = o.GetInt32(5),
                oda = o.GetString(6),
                odaAd = o.GetString(7),
                odaTur = (int)o.GetInt16(8),
                cinsiyetKurali = o.GetInt16(9),
                izolasyon = (int)o.GetInt16(10),
                bina = o.GetString(11),
                kat = o.GetString(12),
                departmanId = o.IsDBNull(13) ? (int?)null : o.GetInt32(13),
                klinik = o.GetString(14),
                ucretHizmet = o.GetString(15),
                odaCinsiyet = o.IsDBNull(16) ? (short?)null : o.GetInt16(16),
            }, iptal);

            var sonuc = satirlar.Select(s =>
            {
                var engel = YatakEngeli(s.durum, s.durumNotu, s.cinsiyetKurali,
                                        s.odaCinsiyet, hastaCinsiyet);
                return new
                {
                    s.id, s.yatak, s.tip, durum = (int)s.durum, s.durumNotu,
                    s.odaId, s.oda, s.odaAd, s.odaTur,
                    cinsiyetKurali = (int)s.cinsiyetKurali, s.izolasyon,
                    s.bina, s.kat, s.departmanId, s.klinik, s.ucretHizmet,
                    uygun = engel is null, engel = engel ?? "",
                };
            }).ToList();

            return Results.Ok(new { hastaCinsiyet = (int)hastaCinsiyet, yataklar = sonuc });
        });

        // ------------------------------------------------------- yatış kabul ----
        // AÇIK YATIŞ TEKTİR: aynı hastanın ikinci yatışı açılırsa yatak, order
        //   ve fatura ikiye bölünür ve hangisinin gerçek olduğu anlaşılmaz.
        //   Kural veritabanında da duruyor (ux_yatis_yatak_aktif) ama kullanıcı
        //   "duplicate key" değil, ne olduğunu anlatan bir cümle görmeli.
        grup.MapPost("/kabul", async (
            YatisKabulIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.kabul");

            if (istek.HastaId <= 0)
                throw GentegreHatasi.Dogrulama("Hasta seçilmeli.",
                    new AlanHatasi("hastaId", "Zorunlu."));
            if (istek.YatakId <= 0)
                throw GentegreHatasi.Dogrulama("Yatak seçilmeli.",
                    new AlanHatasi("yatakId", "Zorunlu."));

            var subeId = baglam.SubeId ?? 0;

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var hasta = await baglanti.TekAsync("""
                select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan, coalesce(th.cinsiyet, 0) as cinsiyet
                  from public.taraf t
                  left join public.taraf_hasta th on th.id = t.id
                 where t.id = @p0
                """, islem, [istek.HastaId], o => new
            {
                unvan = o.GetString(0),
                cinsiyet = o.GetInt16(1),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

            var acik = await baglanti.TekDegerAsync<int?>("""
                select id from public.yatis
                 where hasta_id = @p0 and durum in (1, 2, 3)
                 order by id desc limit 1
                """, islem, [istek.HastaId], iptal);
            if (acik is int acikId)
                throw GentegreHatasi.IsKurali(
                    $"Hastanın açık yatışı var (#{acikId}). Önce taburcu edilmeli.",
                    new { yatisId = acikId });

            // YATAK SATIRI KİLİTLENİR: iki kabul masası aynı yatağı aynı anda
            //   verebilir. Benzersiz indeks ikincisini zaten reddeder, ama
            //   kilit hatayı ANLAŞILIR cümleye çevirmemizi sağlıyor.
            var yatak = await baglanti.TekAsync("""
                select yk.id, yk.kod, yk.durum, yk.durum_notu,
                       o.id as oda_id, o.kod as oda_kod, o.cinsiyet_kurali, o.departman_id,
                       (select min(th.cinsiyet) from public.yatis y2
                          join public.yatak yk2 on yk2.id = y2.yatak_id
                          left join public.taraf_hasta th on th.id = y2.hasta_id
                         where yk2.oda_id = o.id and y2.durum in (1, 2, 3)) as oda_cinsiyet
                  from public.yatak yk
                  join public.oda o on o.id = yk.oda_id
                 where yk.id = @p0 and yk.aktif = 1 and o.aktif = 1
                 for no key update of yk
                """, islem, [istek.YatakId], o => new
            {
                id = o.GetInt32(0),
                kod = o.GetString(1),
                durum = o.GetInt16(2),
                durumNotu = o.GetString(3),
                odaId = o.GetInt32(4),
                odaKod = o.GetString(5),
                cinsiyetKurali = o.GetInt16(6),
                departmanId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                odaCinsiyet = o.IsDBNull(8) ? (short?)null : o.GetInt16(8),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatak bulunamadı.");

            var engel = YatakEngeli(yatak.durum, yatak.durumNotu, yatak.cinsiyetKurali,
                                    yatak.odaCinsiyet, hasta.cinsiyet);
            if (engel is not null)
                throw GentegreHatasi.IsKurali(
                    $"{yatak.odaKod} / {yatak.kod} verilemez: {engel}.");

            // DOSYA NO yatışın kimliğidir (dosya, bileklik, epikriz üstü).
            //   Yıl + sıra: elle yazılan dosya no kaçınılmaz olarak tekrarlar.
            var dosyaNo = await baglanti.TekDegerAsync<string>("""
                select 'Y-' || to_char(now(), 'YYYY') || '-' ||
                       lpad((coalesce(max(nullif(split_part(dosya_no, '-', 3), '')::int), 0) + 1)::text,
                            4, '0')
                  from public.yatis
                 where sube_id = @p0
                   and dosya_no like 'Y-' || to_char(now(), 'YYYY') || '-%'
                """, islem, [subeId], iptal) ?? "";

            var yatisId = await baglanti.TekDegerAsync<int>("""
                insert into public.yatis
                    (sube_id, belge_id, hasta_id, dosya_no, departman_id, hekim_id,
                     yatak_id, giris_tarihi, yatis_turu, gelis_sekli, yatis_tani_kodu,
                     odeyen_kurum_id, provizyon_no, provizyon_tarihi,
                     refakatci_ad, refakatci_tckn, tahmini_cikis, durum, ekleyen)
                values (@p0, @p1, @p2, @p3, coalesce(@p4, @p5), @p6,
                        @p7, now(), coalesce(@p8, 1), coalesce(@p9, 1), coalesce(@p10, ''),
                        @p11, coalesce(@p12, ''), case when coalesce(@p12, '') = ''
                                                       then null else now() end,
                        coalesce(@p13, ''), coalesce(@p14, ''), @p15, 1, @p16)
                returning id
                """, islem, [subeId, istek.BelgeId, istek.HastaId, dosyaNo,
                             istek.DepartmanId, yatak.departmanId, istek.HekimId,
                             istek.YatakId, istek.YatisTuru, istek.GelisSekli,
                             istek.YatisTaniKodu, istek.OdeyenKurumId, istek.ProvizyonNo,
                             istek.RefakatciAd, istek.RefakatciTckn, istek.TahminiCikis,
                             baglam.KullaniciId], iptal);

            // YATAK HAREKETİ İLK GÜNDEN AÇILIR: fatura bu tablodan hesaplanır,
            //   "ilk yatak" satırı yoksa yatışın ilk günleri ücretsiz görünür.
            await baglanti.CalistirAsync("""
                insert into public.yatis_yatak (yatis_id, yatak_id, baslangic, neden, ekleyen)
                values (@p0, @p1, now(), 1, @p2)
                """, islem, [yatisId, istek.YatakId, baglam.KullaniciId], iptal);

            // KABUL YATAĞI REZERVE EDER, DOLU YAPMAZ: hasta henüz yatağında
            //   değil (evrak, provizyon, transfer). Panoda "rezerve" görünmesi,
            //   ikinci bir hastaya verilmesini de engeller.
            await baglanti.CalistirAsync("""
                update public.yatak
                   set durum = 3, durum_notu = '', degistiren = @p1,
                       degistirme_tarihi = now()
                 where id = @p0
                """, islem, [istek.YatakId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloYatis, yatisId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { dosyaNo, hasta = hasta.unvan, yatak = yatak.kod, oda = yatak.odaKod },
                tarafId: istek.HastaId, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = yatisId, dosyaNo, yatak = yatak.kod, oda = yatak.odaKod });
        });

        // -------------------------------------------------- hasta yatağında ----
        // Kabul ile "hasta yatağında" AYRI adımdır: arada provizyon, dosya ve
        //   transfer var. Rezerve yatak hastanın; ama yatak ücreti ve hemşire
        //   izlemi hasta geldiğinde başlar.
        grup.MapPost("/{id:int}/yatakta", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.kabul");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var yatis = await baglanti.TekAsync("""
                select durum, yatak_id from public.yatis where id = @p0 for no key update
                """, islem, [id], o => new
            {
                durum = o.GetInt16(0),
                yatakId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

            if (yatis.durum != 1)
                throw GentegreHatasi.IsKurali("Yalnız 'Yatış kabul' durumundaki yatış yatağa alınır.");
            if (yatis.yatakId is null)
                throw GentegreHatasi.IsKurali("Yatışın yatağı yok; önce yatak verilmeli.");

            await baglanti.CalistirAsync("""
                update public.yatis set durum = 2, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.yatak
                   set durum = 2, durum_notu = '', degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [yatis.yatakId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Yatış kabul -> Yatakta" }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, durum = 2 });
        });

        // -------------------------------------------------- yatak temizlendi ----
        // Temizlik biten yatağı BOŞ'a döndürmek ayrı bir olaydır ve kim yaptığı
        //   loglanır: "yatak hazır" bilgisi kabul masasının hasta yollama
        //   kararıdır, tahminle verilmez.
        grup.MapPost("/yatak/{id:int}/temizlendi", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.yatak", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var etkilenen = await baglanti.CalistirAsync("""
                update public.yatak
                   set durum = 1, durum_notu = '', degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 4
                """, null, [id, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Yatak temizlik bekleyen durumda değil.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatak, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Temizlik bekliyor -> Boş" }, iptal: iptal);

            return Results.Ok(new { id, durum = 1 });
        });
    }
}
