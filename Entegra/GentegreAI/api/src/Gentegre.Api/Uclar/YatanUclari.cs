using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// YATAN HASTA (695) — yatış özeti + yatışın YAŞAM DÖNGÜSÜ (kabul → nakil →
/// taburcu) ve yatak durumu senkronu.
///
/// <para><b>Kimlik ve son vitaller sekmelerin DIŞINDA durur.</b> Yatan hastada
/// "kim, nerede, kaçıncı gün, nasıl" her kararın önkoşuludur; sekmeye
/// gömülürse hekim her seferinde tıklar. Mockup da bu yüzden iki şeridi
/// sekmelerin üstüne koyuyor.</para>
///
/// <para><b>Açık işler tek sorguda:</b> geciken doz, imzasız sözel order,
/// süresi geçmiş risk değerlendirmesi. Bunlar taburcu ekranının da sorduğu
/// listedir — "çıkışta bir şey kalmış mıydı" sorusunun cevabı, hasta yatarken
/// de aynı yerde durmalı. Altı ayrı istek, şeridin yarısını boş gösterirdi.</para>
///
/// <para><b>YATAK DURUMU YATIŞLA BİRLİKTE DEĞİŞİR, ELLE DEĞİL.</b> Kabul
/// yatağı rezerve eder, "yatakta" dolu yapar, nakil eskisini TEMİZLİĞE düşürür,
/// taburcu da öyle. Yatak durumunu ayrı bir ekrana bırakmak, panoyu gerçeğin
/// yarım saat gerisinde tutar: kabul masası yapılmamış yatağa hasta yollar.
/// Bu yüzden hepsi tek işlemde (transaction) yazılır — yatış açılıp yatağın
/// güncellenmediği bir ara hâl yok.</para>
///
/// <para><b>Kurallar SUNUCUDA.</b> Hangi yatağın verilebilir olduğu (oda
/// cinsiyet kuralı, temizlik, kapalı yatak) ve taburcuyu neyin engellediği
/// tek yerde hesaplanır: <see cref="YatakEngeli"/> ve <c>/cikis-kontrol</c>.
/// Ekran aynı listeyi gösterir, kendi kuralını kurmaz — iki yerde iki ayrı
/// kural, ikisinin sessizce ayrışması demektir.</para>
/// </summary>
public static partial class YatanUclari
{
    private const int LogTabloYatis = 950;
    private const int LogTabloYatak = 951;
    /// <summary>Order kendi kaydıdır: imza logu yatışa değil order'a düşer.</summary>
    private const int LogTabloYatisOrder = 952;

    /// <summary>Yatış kabul (mockup <c>Ekranlar/Yatan/yatis_kabul.html</c>).</summary>
    public sealed record YatisKabulIstegi(
        int HastaId, int YatakId, int? DepartmanId, int? HekimId,
        short? YatisTuru, short? GelisSekli, string? YatisTaniKodu,
        int? OdeyenKurumId, string? ProvizyonNo, string? RefakatciAd,
        string? RefakatciTckn, DateTime? TahminiCikis, int? BelgeId);

    /// <summary>Nakil / yatak değişimi (mockup <c>nakil_yatak_degisim.html</c>).</summary>
    public sealed record NakilIstegi(int YatakId, short? Neden, string? Aciklama,
                                     int? DepartmanId, int? HekimId);

    /// <summary>
    /// Taburcu (mockup <c>taburcu_epikriz.html</c>).
    ///
    /// <para><b>TakipHekimId</b>: sonucu bekleyen tetkik varken taburcu ancak
    /// sonucu TAKİP EDECEK hekim seçilirse tamamlanır. Hasta çıkınca bekleyen
    /// sonuç çalışma listesinden de düşer; sahipsiz kalan sonuç, bulunmamış
    /// sonuçtur. Engeli tamamen kaldırmak sonucu kimsesiz bırakır, hiç
    /// geçirmemek ise hekimi sistemi aşmaya iter.</para>
    /// </summary>
    public sealed record TaburcuIstegi(short CikisSekli, string? CikisTaniKodu,
                                       DateTime? CikisTarihi, int? TakipHekimId);

    public sealed record TaburcuPlanIstegi(DateTime? TahminiCikis);

    /// <summary>
    /// YATAK VERİLEBİLİR Mİ — tek kural yeri.
    ///
    /// Boş yatak her hastaya açık değildir: <b>kuralı ODA koyar</b> (kadın
    /// odasındaki boş yatak erkek hasta için boş değildir) ve temizlik ayrı bir
    /// durumdur — taburcu olan yatağı anında "boş" saymak, kabul masasının
    /// hastayı yapılmamış yatağa göndermesidir.
    ///
    /// Engel yoksa <c>null</c>, varsa GEREKÇE döner: ekran yatağı gizlemez,
    /// SOLUK gösterip nedenini yazar. Gizlenen yatak "neden yok" sorusunu
    /// telefona taşır.
    /// </summary>
    private static string? YatakEngeli(short durum, string durumNotu,
                                       short cinsiyetKurali, short? odaCinsiyet,
                                       short hastaCinsiyet)
    {
        var not = durumNotu.Length > 0 ? " · " + durumNotu : "";
        switch (durum)
        {
            case 2: return "Dolu";
            case 3: return "Rezerve" + not;
            case 4: return "Temizlik bekliyor" + not;
            case 5: return "Kapalı (arıza/tadilat)" + not;
        }

        // 1 Yalnız kadın · 2 Yalnız erkek · 3 İlk yatana göre kilitlenir
        //   (hasta cinsiyeti 1 erkek / 2 kadın).
        if (cinsiyetKurali == 1 && hastaCinsiyet != 2) return "Yalnız kadın odası";
        if (cinsiyetKurali == 2 && hastaCinsiyet != 1) return "Yalnız erkek odası";
        if (cinsiyetKurali == 3 && odaCinsiyet is short c && c > 0
            && hastaCinsiyet > 0 && c != hastaCinsiyet)
            return c == 2 ? "Odada kadın hasta var" : "Odada erkek hasta var";

        return null;
    }

    public static void YatanUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/yatan").WithTags("Yatan Hasta").RequireAuthorization();

        // eMAR (doz çizelgesi ve uygulama) ayrı dosyada: bu dosya yatışın
        //   yaşam döngüsünü tutuyor, o ise günün ilaç akışını.
        EmarUclariniEkle(grup);
        IzlemUclariniEkle(grup);
        IcmalUclariniEkle(grup);
        EpikrizUclariniEkle(grup);

        // ------------------------------------------------------- yatış özeti ----
        grup.MapGet("/{yatisId:int}/ozet", async (
            int yatisId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Gor);

            var ozet = await veri.TekAsync("""
                select t.unvan                                   as hasta,
                       case when th.dogum_tarihi is null then null
                            else extract(year from age(th.dogum_tarihi))::int end as yas,
                       coalesce(th.cinsiyet, 0)                  as cinsiyet,
                       coalesce(yk.kod, '')                      as yatak,
                       coalesce(o.kod, '')                       as oda,
                       coalesce(o.izolasyon, 0)                  as izolasyon,
                       coalesce(d.ad, '')                        as klinik,
                       coalesce(h.unvan, '')                     as hekim,
                       coalesce(k.unvan, '')                     as odeyen,
                       y.provizyon_no, y.giris_tarihi, y.cikis_tarihi,
                       (coalesce(y.cikis_tarihi, now())::date - y.giris_tarihi::date) as gun,
                       y.durum, y.yatis_turu, y.gelis_sekli,
                       y.yatis_tani_kodu, y.cikis_tani_kodu,
                       y.refakatci_ad, y.tahmini_cikis,
                       -- SON VİTAL: kartın açıldığı ilk saniyede "hasta nasıl"
                       --   sorusunun cevabı.
                       v.zaman as vital_zaman, v.sistolik, v.diyastolik, v.nabiz,
                       v.ates, v.spo2, v.solunum, v.erken_uyari,
                       -- AÇIK İŞLER: taburcunun beklediği liste.
                       (select count(*) from public.order_uygulama u
                          join public.yatis_order od on od.id = u.order_id
                         where od.yatis_id = y.id and u.durum in (1, 5)
                           and u.planlanan < now() - interval '30 minutes')::int as geciken_doz,
                       (select count(*) from public.yatis_order od
                         where od.yatis_id = y.id and od.sozel_order = 1
                           and od.onay_tarihi is null and od.durum = 1)::int      as imzasiz_order,
                       (select count(*) from public.yatis_order od
                         where od.yatis_id = y.id and od.durum = 1
                           and od.tur in (3, 4))::int                             as bekleyen_tetkik,
                       (select count(*) from public.yatis_order od
                         where od.yatis_id = y.id and od.durum = 1
                           and od.tur = 5)::int                                   as bekleyen_konsultasyon,
                       -- HASTA ID ŞERİTTE GÖRÜNMEZ ama nakil ekranının yatak
                       --   listesi ona bağlı: uygunluk hastanın cinsiyetiyle
                       --   hesaplanır. Ayrı bir istek, aynı yatışı ikinci kez
                       --   okumak olurdu.
                       y.hasta_id, y.yatak_id
                  from public.yatis y
                  join public.taraf t on t.id = y.hasta_id
                  left join public.taraf_hasta th on th.id = y.hasta_id
                  left join public.yatak yk on yk.id = y.yatak_id
                  left join public.oda o on o.id = yk.oda_id
                  left join public.departman d on d.id = y.departman_id
                  left join public.taraf h on h.id = y.hekim_id
                  left join public.taraf k on k.id = y.odeyen_kurum_id
                  left join lateral (
                      select i.* from public.yatis_izlem i
                       where i.yatis_id = y.id order by i.zaman desc limit 1
                  ) v on true
                 where y.id = @p0
                """, new object?[] { yatisId }, o => new
            {
                hasta = o.GetString(0),
                yas = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                cinsiyet = (int)o.GetInt16(2),
                yatak = o.GetString(3),
                oda = o.GetString(4),
                izolasyon = (int)o.GetInt16(5),
                klinik = o.GetString(6),
                hekim = o.GetString(7),
                odeyen = o.GetString(8),
                provizyonNo = o.GetString(9),
                girisTarihi = o.GetDateTime(10),
                cikisTarihi = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
                gun = o.GetInt32(12),
                durum = (int)o.GetInt16(13),
                yatisTuru = (int)o.GetInt16(14),
                gelisSekli = (int)o.GetInt16(15),
                yatisTani = o.GetString(16),
                cikisTani = o.GetString(17),
                refakatci = o.GetString(18),
                tahminiCikis = o.IsDBNull(19) ? (DateTime?)null : o.GetDateTime(19),
                vitalZaman = o.IsDBNull(20) ? (DateTime?)null : o.GetDateTime(20),
                sistolik = o.IsDBNull(21) ? (int?)null : (int)o.GetInt16(21),
                diyastolik = o.IsDBNull(22) ? (int?)null : (int)o.GetInt16(22),
                nabiz = o.IsDBNull(23) ? (int?)null : (int)o.GetInt16(23),
                ates = o.IsDBNull(24) ? (decimal?)null : o.GetDecimal(24),
                spo2 = o.IsDBNull(25) ? (int?)null : (int)o.GetInt16(25),
                solunum = o.IsDBNull(26) ? (int?)null : (int)o.GetInt16(26),
                erkenUyari = o.IsDBNull(27) ? (int?)null : (int)o.GetInt16(27),
                gecikenDoz = o.GetInt32(28),
                imzasizOrder = o.GetInt32(29),
                bekleyenTetkik = o.GetInt32(30),
                bekleyenKonsultasyon = o.GetInt32(31),
                hastaId = o.GetInt32(32),
                yatakId = o.IsDBNull(33) ? (int?)null : o.GetInt32(33),
            }, iptal);

            if (ozet is null) return Results.NotFound();

            // RİSK ÖLÇEKLERİ dönemseldir (yatışta + her 24 saatte): son değer
            //   YAŞIYLA birlikte döner, ekran "süresi geçti" diyebilsin.
            //   Tek seferlik alan olsaydı üçüncü günü düşen hastanın puanı
            //   hâlâ yatış günündeki puan olurdu.
            var riskler = await veri.ListeAsync("""
                select distinct on (r.olcek) r.olcek, r.puan, r.risk_duzeyi, r.zaman, r.onlem
                  from public.yatis_risk r
                 where r.yatis_id = @p0
                 order by r.olcek, r.zaman desc
                """, new object?[] { yatisId }, o => new
            {
                olcek = (int)o.GetInt16(0),
                puan = o.IsDBNull(1) ? (int?)null : (int)o.GetInt16(1),
                duzey = o.IsDBNull(2) ? (int?)null : (int)o.GetInt16(2),
                zaman = o.GetDateTime(3),
                onlem = o.GetString(4),
            }, iptal);

            // GÜNLÜK SIVI DENGESİ hesaplıdır: hemşire toplamı elle yazsaydı,
            //   gün ortasında eklenen bir serum toplamı sessizce bozardı.
            var sivi = await veri.TekAsync("""
                select coalesce(sum(case when s.yon = 1 then s.miktar_ml else 0 end), 0) as aldi,
                       coalesce(sum(case when s.yon = 2 then s.miktar_ml else 0 end), 0) as cikardi
                  from public.yatis_sivi s
                 where s.yatis_id = @p0 and s.zaman::date = current_date
                """, new object?[] { yatisId }, o => new
            {
                aldi = o.GetDecimal(0),
                cikardi = o.GetDecimal(1),
            }, iptal);

            return Results.Ok(new { ozet, riskler, sivi });
        });

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
                select t.unvan, coalesce(th.cinsiyet, 0) as cinsiyet
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

        // ------------------------------------------------ nakil / yatak değişimi ----
        // ÜÇ YAZMA TEK İŞLEMDE: eski hareket kapanır, yeni hareket açılır, iki
        //   yatağın durumu değişir. Biri olmazsa ya hasta iki yatakta görünür
        //   ya da eski yatak sonsuza kadar dolu kalır.
        //
        // ESKİ YATAK "BOŞ" DEĞİL "TEMİZLİK BEKLİYOR" olur: nakil de taburcu
        //   gibi arkasında yapılmamış bir yatak bırakır.
        grup.MapPost("/{id:int}/nakil", async (
            int id, NakilIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.nakil");

            if (istek.YatakId <= 0)
                throw GentegreHatasi.Dogrulama("Hedef yatak seçilmeli.",
                    new AlanHatasi("yatakId", "Zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var yatis = await baglanti.TekAsync("""
                select y.durum, y.yatak_id, y.hasta_id, coalesce(th.cinsiyet, 0) as cinsiyet,
                       coalesce(eyk.kod, '') as eski_yatak,
                       coalesce(eo.kod, '')  as eski_oda,
                       coalesce(eo.tur, 0)   as eski_oda_tur,
                       -- ÜCRET SINIFI ADI: hizmet kartı bağlanmamış kurumda
                       --   "— -> —" diye anlamsız bir uyarı çıkıyordu; oda
                       --   türü her zaman dolu ve kullanıcının okuduğu şey.
                       coalesce(ehz.ad, eot.ad, '') as eski_ucret
                  from public.yatis y
                  left join public.taraf_hasta th on th.id = y.hasta_id
                  left join public.yatak eyk on eyk.id = y.yatak_id
                  left join public.oda eo on eo.id = eyk.oda_id
                  left join public.hizmet ehz on ehz.id = eo.ucret_hizmet_id
                  left join public.kod_deger eot
                    on eot.deger = eo.tur
                   and eot.liste_id = (select l.id from public.kod_liste l
                                        where l.kod = 'yatan.oda_tur')
                 where y.id = @p0
                 for no key update of y
                """, islem, [id], o => new
            {
                durum = o.GetInt16(0),
                yatakId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                hastaId = o.GetInt32(2),
                cinsiyet = o.GetInt16(3),
                eskiYatak = o.GetString(4),
                eskiOda = o.GetString(5),
                eskiOdaTur = (int)o.GetInt16(6),
                eskiUcret = o.GetString(7),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

            if (yatis.durum is not (1 or 2 or 3))
                throw GentegreHatasi.IsKurali("Kapanmış yatışta nakil yapılamaz.");
            if (yatis.yatakId == istek.YatakId)
                throw GentegreHatasi.Dogrulama("Hasta zaten bu yatakta.",
                    new AlanHatasi("yatakId", "Farklı bir yatak seçin."));

            var yeni = await baglanti.TekAsync("""
                select yk.id, yk.kod, yk.durum, yk.durum_notu,
                       o.kod as oda_kod, o.tur as oda_tur, o.cinsiyet_kurali, o.departman_id,
                       coalesce(hz.ad, ot.ad, '') as ucret,
                       (select min(th.cinsiyet) from public.yatis y2
                          join public.yatak yk2 on yk2.id = y2.yatak_id
                          left join public.taraf_hasta th on th.id = y2.hasta_id
                         where yk2.oda_id = o.id and y2.durum in (1, 2, 3)
                           and y2.id <> @p1) as oda_cinsiyet
                  from public.yatak yk
                  join public.oda o on o.id = yk.oda_id
                  left join public.hizmet hz on hz.id = o.ucret_hizmet_id
                  left join public.kod_deger ot
                    on ot.deger = o.tur
                   and ot.liste_id = (select l.id from public.kod_liste l
                                       where l.kod = 'yatan.oda_tur')
                 where yk.id = @p0 and yk.aktif = 1 and o.aktif = 1
                 for no key update of yk
                """, islem, [istek.YatakId, id], o => new
            {
                id = o.GetInt32(0),
                kod = o.GetString(1),
                durum = o.GetInt16(2),
                durumNotu = o.GetString(3),
                odaKod = o.GetString(4),
                odaTur = (int)o.GetInt16(5),
                cinsiyetKurali = o.GetInt16(6),
                departmanId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                ucret = o.GetString(8),
                odaCinsiyet = o.IsDBNull(9) ? (short?)null : o.GetInt16(9),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hedef yatak bulunamadı.");

            var engel = YatakEngeli(yeni.durum, yeni.durumNotu, yeni.cinsiyetKurali,
                                    yeni.odaCinsiyet, yatis.cinsiyet);
            if (engel is not null)
                throw GentegreHatasi.IsKurali($"{yeni.odaKod} / {yeni.kod} verilemez: {engel}.");

            // AÇIK HAREKET KAPANIR: bitişi yazılmayan satır, yatak ücretini iki
            //   yatakta birden işletir.
            await baglanti.CalistirAsync("""
                update public.yatis_yatak
                   set bitis = now(), degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and bitis is null
                """, islem, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                insert into public.yatis_yatak
                    (yatis_id, yatak_id, baslangic, neden, aciklama, ekleyen)
                values (@p0, @p1, now(), coalesce(@p2, 2), coalesce(@p3, ''), @p4)
                """, islem, [id, istek.YatakId, istek.Neden, istek.Aciklama,
                             baglam.KullaniciId], iptal);

            if (yatis.yatakId is int eskiId)
                await baglanti.CalistirAsync("""
                    update public.yatak
                       set durum = 4, durum_notu = 'Nakil sonrası', degistiren = @p1,
                           degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [eskiId, baglam.KullaniciId], iptal);

            // Hasta henüz yatağına gelmediyse (durum 1) yeni yatak da REZERVE
            //   kalır: nakil kararı yatağı doldurmaz, hastanın gelişi doldurur.
            await baglanti.CalistirAsync("""
                update public.yatak
                   set durum = case when @p2 = 2 then 2 else 3 end,
                       durum_notu = '', degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [istek.YatakId, baglam.KullaniciId, (short)yatis.durum], iptal);

            await baglanti.CalistirAsync("""
                update public.yatis
                   set yatak_id = @p1,
                       departman_id = coalesce(@p2, @p3, departman_id),
                       hekim_id = coalesce(@p4, hekim_id),
                       degistiren = @p5, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, istek.YatakId, istek.DepartmanId, yeni.departmanId,
                             istek.HekimId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    yatak = $"{yatis.eskiOda}/{yatis.eskiYatak} -> {yeni.odaKod}/{yeni.kod}",
                    neden = istek.Neden,
                    aciklama = istek.Aciklama ?? "",
                }, tarafId: yatis.hastaId, iptal: iptal);

            await islem.CommitAsync(iptal);

            // ÜCRET SINIFI DEĞİŞİMİ UYARIDIR, ENGEL DEĞİL: yoğun bakıma çıkan
            //   hastanın yatak ücreti elbette değişir. Sessiz kalmak, farkı
            //   faturada gören hastaya bırakmak olurdu.
            var ucretDegisti = yatis.eskiOdaTur != yeni.odaTur
                               || !string.Equals(yatis.eskiUcret, yeni.ucret, StringComparison.Ordinal);
            return Results.Ok(new
            {
                id,
                yatak = yeni.kod,
                oda = yeni.odaKod,
                ucretDegisti,
                uyari = ucretDegisti
                    ? $"Yatak ücreti sınıfı değişti: {(yatis.eskiUcret.Length > 0 ? yatis.eskiUcret : "—")}"
                      + $" -> {(yeni.ucret.Length > 0 ? yeni.ucret : "—")}"
                    : "",
            });
        });

        // ---------------------------------------------------- taburcu planlama ----
        // "Taburcu planlandı" AYRI DURUM: hekim sabah karar verir, çıkış öğleden
        //   sonra olur. Arada yatak dolu ama panoda "bugün boşalacak" görünmeli -
        //   yatak planlaması bu bilgiyle yapılır.
        grup.MapPost("/{id:int}/taburcu-planla", async (
            int id, TaburcuPlanIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.taburcu");

            await using var baglanti = await veri.AcAsync(iptal);

            var etkilenen = await baglanti.CalistirAsync("""
                update public.yatis
                   set durum = 3, tahmini_cikis = coalesce(@p1::date, current_date),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and durum in (1, 2, 3)
                """, null, [id, istek.TahminiCikis, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Yatış bulunamadı ya da kapanmış.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Taburcu planlandı", tahminiCikis = istek.TahminiCikis },
                iptal: iptal);

            return Results.Ok(new { id, durum = 3 });
        });

        // --------------------------------------------------- çıkış kontrol listesi ----
        // TABURCU EKRANI BU LİSTEYİ SORAR, yatış kartındaki "Açık işler" kutusu
        //   da aynı sayıları okur: iki yerde iki ayrı "açık iş" tanımı olsaydı,
        //   taburcuda görünmeyen bir eksik hastayla birlikte çıkardı.
        //
        // ENGEL / UYARI AYRIMI: sonucu gelmemiş tetkik ve imzasız sözel order
        //   sahipsiz kalır - bunlar taburcuyu durdurur. Yanıtlanmamış
        //   konsültasyon ve geciken doz görünür ama hekimin kararıyla geçilir.
        grup.MapGet("/{id:int}/cikis-kontrol", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var liste = await CikisKontrolAsync(baglanti, null, id, iptal);
            return Results.Ok(new
            {
                maddeler = liste,
                engelVar = liste.Any(m => m.engel && !m.tamam),
            });
        });

        // ------------------------------------------------------------ taburcu ----
        grup.MapPost("/{id:int}/taburcu", async (
            int id, TaburcuIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.taburcu");

            // ÇIKIŞ ŞEKLİ ZORUNLU ve SKRS kodludur: tek "taburcu" alanı ölüm
            //   vakasını da taburcu gösterirdi. e-Nabız, Medula ve kurum
            //   istatistiği bu ayrımı ister.
            if (istek.CikisSekli is < 1 or > 7)
                throw GentegreHatasi.Dogrulama("Çıkış şekli seçilmeli.",
                    new AlanHatasi("cikisSekli", "Zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var yatis = await baglanti.TekAsync("""
                select durum, yatak_id, hasta_id, dosya_no
                  from public.yatis where id = @p0 for no key update
                """, islem, [id], o => new
            {
                durum = o.GetInt16(0),
                yatakId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                hastaId = o.GetInt32(2),
                dosyaNo = o.GetString(3),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

            if (yatis.durum is not (1 or 2 or 3))
                throw GentegreHatasi.IsKurali("Yatış zaten kapanmış.");

            var kontrol = await CikisKontrolAsync(baglanti, islem, id, iptal);
            // SONUCU TAKİP EDECEK HEKİM seçildiyse "sonuç bekleyen tetkik"
            //   engeli aşılır - ama kim aştığı ve kimin takip edeceği loga
            //   yazılır. Sessizce geçilen bir engel, engel değildir.
            var engeller = kontrol
                .Where(m => m.engel && !m.tamam)
                .Where(m => !(m.kod == "tetkik" && istek.TakipHekimId is > 0))
                .ToList();
            if (engeller.Count > 0)
                throw GentegreHatasi.IsKurali(
                    "Taburcu engelleri var: " + string.Join(", ", engeller.Select(m => m.ad)),
                    new { engeller });

            // SEVK AYRI DURUM: "kurum dışına sevk" edilen hasta taburcu
            //   sayılmaz - gittiği kurumla ilişki sürer, istatistik ayrıdır.
            var yeniDurum = istek.CikisSekli == 3 ? (short)5 : (short)4;

            await baglanti.CalistirAsync("""
                update public.yatis
                   set durum = @p1, cikis_tarihi = coalesce(@p2, now()),
                       cikis_sekli = @p3, cikis_tani_kodu = coalesce(@p4, cikis_tani_kodu),
                       degistiren = @p5, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, yeniDurum, istek.CikisTarihi, istek.CikisSekli,
                             istek.CikisTaniKodu, baglam.KullaniciId], iptal);

            // AÇIK ORDER KAPANIR: taburcu olan hastanın "aktif" ilacı eMAR
            //   kuyruğunda doz üretmeye devam ederdi.
            await baglanti.CalistirAsync("""
                update public.yatis_order
                   set durum = 3, degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and durum = 1
                """, islem, [id, baglam.KullaniciId], iptal);

            // BEKLEYEN DOZ SİLİNMEZ, "atlandı" olarak NEDENİYLE kapanır:
            //   silinen satır "verilmedi mi, hiç planlanmadı mı" sorusunu
            //   cevapsız bırakır.
            await baglanti.CalistirAsync("""
                update public.order_uygulama u
                   set durum = 3, atlama_nedeni = 'Taburcu', degistiren = @p1,
                       degistirme_tarihi = now()
                  from public.yatis_order od
                 where od.id = u.order_id and od.yatis_id = @p0
                   and u.durum in (1, 5)
                """, islem, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.yatis_yatak
                   set bitis = now(), degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and bitis is null
                """, islem, [id, baglam.KullaniciId], iptal);

            // YATAK TEMİZLİĞE DÜŞER: taburcu olan yatak anında "boş" sayılsaydı
            //   kabul masası hastayı yapılmamış yatağa gönderirdi.
            if (yatis.yatakId is int yatakId)
                await baglanti.CalistirAsync("""
                    update public.yatak
                       set durum = 4, durum_notu = 'Taburcu sonrası', degistiren = @p1,
                           degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [yatakId, baglam.KullaniciId], iptal);

            // KONTROL RANDEVUSU TABURCUYLA AÇILIR: "on gün sonra gelin" denip
            //   randevu verilmeyen hastanın yarısı gelmiyor. Epikrizde kontrol
            //   tarihi yoksa randevu da yok - uydurulmaz.
            var randevuId = await KontrolRandevusuAcAsync(
                baglanti, islem, id, yatis.hastaId, baglam.SubeId ?? 0,
                baglam.KullaniciId, iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    durum = yeniDurum == 5 ? "Kurum dışına sevk" : "Taburcu",
                    cikisSekli = istek.CikisSekli,
                    dosyaNo = yatis.dosyaNo,
                    takipHekimId = istek.TakipHekimId,
                    kontrolRandevusu = randevuId,
                }, tarafId: yatis.hastaId, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                id,
                durum = yeniDurum,
                kontrolRandevusu = randevuId,
                uyarilar = kontrol.Where(m => !m.engel && !m.tamam).ToList(),
            });
        });

        // ------------------------------------------------------ yatış iptali ----
        // YATIŞ SİLİNMEZ, İPTAL EDİLİR (durum 0). Yatışa order, izlem, doz ve
        //   tahakkuk bağlı; silinen yatış bunları da götürür ve "bu hasta
        //   yatmış mıydı" sorusu cevapsız kalır. Yanlış açılan yatışın doğru
        //   karşılığı iptaldir: kayıt kalır, yatak serbest kalır.
        //
        // HASTA YATAĞA ÇIKTIYSA İPTAL YOK: o artık bir yatıştır ve çıkışı
        //   taburcudur. İptal yalnız "yanlış kayıt" içindir.
        grup.MapPost("/{id:int}/iptal", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.kabul");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var yatis = await baglanti.TekAsync("""
                select durum, yatak_id, hasta_id, dosya_no
                  from public.yatis where id = @p0 for no key update
                """, islem, [id], o => new
            {
                durum = o.GetInt16(0),
                yatakId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                hastaId = o.GetInt32(2),
                dosyaNo = o.GetString(3),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

            if (yatis.durum != 1)
                throw GentegreHatasi.IsKurali(
                    "Yalnız 'Yatış kabul' durumundaki yatış iptal edilir; "
                    + "yatağa alınmış hasta TABURCU edilir.");

            // UYGULANMIŞ DOZU OLAN YATIŞ İPTAL EDİLMEZ: iptal "hiç olmadı"
            //   demektir, oysa ilaç verilmiş.
            var verilenDoz = await baglanti.TekDegerAsync<int>("""
                select count(*)::int from public.order_uygulama u
                  join public.yatis_order od on od.id = u.order_id
                 where od.yatis_id = @p0 and u.durum = 2
                """, islem, [id], iptal);
            if (verilenDoz > 0)
                throw GentegreHatasi.IsKurali(
                    $"Bu yatışta {verilenDoz} doz uygulanmış: iptal edilemez, taburcu edilir.");

            await baglanti.CalistirAsync("""
                update public.yatis
                   set durum = 0, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.yatis_yatak
                   set bitis = now(), degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and bitis is null
                """, islem, [id, baglam.KullaniciId], iptal);

            // YATAK BOŞA DÖNER (temizliğe değil): hasta yatağa hiç çıkmadı.
            if (yatis.yatakId is int yatakId)
                await baglanti.CalistirAsync("""
                    update public.yatak
                       set durum = 1, durum_notu = '', degistiren = @p1,
                           degistirme_tarihi = now()
                     where id = @p0 and durum = 3
                    """, islem, [yatakId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "İptal", dosyaNo = yatis.dosyaNo }, tarafId: yatis.hastaId,
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, durum = 0 });
        });

        // ----------------------------------------------------- order durdur ----
        // ORDER SİLİNMEZ, DURDURULUR: uygulanmış dozu olan bir talimatı silmek
        //   "bu ilaç neden verildi" sorusunu cevapsız bırakır. Durdurma
        //   gelecekteki bekleyen dozları düşürür (698 tetikleyicisi), geçmişi
        //   bırakır.
        grup.MapPost("/order/{id:int}/durdur", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync("""
                update public.yatis_order
                   set durum = 2, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 1
                """, new object?[] { id, baglam.KullaniciId }, iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Order bulunamadı ya da zaten kapalı.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatisOrder, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Durduruldu" }, iptal: iptal);

            return Results.Ok(new { id, durum = 2 });
        });

        // ------------------------------------------- tahakkuku yeniden üret ----
        // GÜN SONU İŞİ ATLADIYSA (servis kapalıydı, gün sonradan düzeltildi)
        //   o günü elle kapatmak gerekir. Tahakkuk ELLE GİRİLMEZ - aynı
        //   fonksiyon çalıştırılır ve mükerrer yazmaz (gün başına tek satır).
        grup.MapPost("/tahakkuk-hesapla", async (
            DateOnly? gun, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Degistir);

            var tarih = gun ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun.AddDays(-1));

            var sonuc = await veri.TekDegerAsync<string>(
                "select aciklama from public.fn_yatak_ucreti_tahakkuk(@p0)",
                new object?[] { tarih }, iptal) ?? "";

            return Results.Ok(new { gun = tarih, mesaj = sonuc });
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

    private sealed record KontrolMaddesi(string kod, string ad, int sayi, bool engel,
                                         bool tamam, string not);

    /// <summary>
    /// ÇIKIŞ KONTROL LİSTESİ — taburcu ucu ve taburcu ekranı AYNI listeyi okur.
    ///
    /// İki ayrı yerde iki ayrı "açık iş" tanımı olsaydı, ekranda görünmeyen bir
    /// eksik hastayla birlikte çıkardı.
    /// </summary>
    private static async Task<List<KontrolMaddesi>> CikisKontrolAsync(
        Npgsql.NpgsqlConnection baglanti, Npgsql.NpgsqlTransaction? islem, int yatisId,
        CancellationToken iptal)
    {
        var s = await baglanti.TekAsync("""
            select (select count(*) from public.yatis_order od
                     where od.yatis_id = @p0 and od.durum = 1 and od.tur in (3, 4))::int,
                   (select count(*) from public.yatis_order od
                     where od.yatis_id = @p0 and od.sozel_order = 1
                       and od.onay_tarihi is null and od.durum = 1)::int,
                   (select count(*) from public.yatis_order od
                     where od.yatis_id = @p0 and od.durum = 1 and od.tur = 5)::int,
                   (select count(*) from public.order_uygulama u
                      join public.yatis_order od on od.id = u.order_id
                     where od.yatis_id = @p0 and u.durum in (1, 5)
                       and u.planlanan < now() - interval '30 minutes')::int,
                   (select count(*) from public.yatis_order od
                     where od.yatis_id = @p0 and od.durum = 1 and od.tur in (1, 2))::int,
                   (select count(*) from public.epikriz e where e.yatis_id = @p0)::int,
                   (select count(*) from public.epikriz e
                     where e.yatis_id = @p0 and e.imza_durum = 1)::int,
                   (select count(*) from public.yatis_risk r where r.yatis_id = @p0)::int
            """, islem, [yatisId], o => new
        {
            tetkik = o.GetInt32(0),
            sozel = o.GetInt32(1),
            konsultasyon = o.GetInt32(2),
            gecikenDoz = o.GetInt32(3),
            acikOrder = o.GetInt32(4),
            epikriz = o.GetInt32(5),
            epikrizImza = o.GetInt32(6),
            risk = o.GetInt32(7),
        }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

        return
        [
            // ---- ENGELLER: sahipsiz kalacak iş.
            new("tetkik", "Sonuç bekleyen tetkik / görüntüleme", s.tetkik, true,
                s.tetkik == 0, "Sonuç gelmeden taburcu, sonucu sahipsiz bırakır."),
            new("sozel", "İmzasız sözel order", s.sozel, true, s.sozel == 0,
                "Hekim imzası olmadan uygulanmış ilaç kaydı açıkta kalır."),
            new("epikriz", "Epikriz", s.epikriz, true, s.epikriz > 0,
                "Epikriz yazılmadan taburcu, hastayı kontrol hekimine kayıtsız gönderir."),

            // ---- UYARILAR: hekim kararıyla geçilir.
            new("epikriz_imza", "Epikriz imzası", s.epikrizImza, false,
                s.epikriz == 0 || s.epikrizImza > 0,
                "Taslak epikriz taburcuyu durdurmaz; imza sonradan atılabilir."),
            new("konsultasyon", "Yanıtlanmamış konsültasyon", s.konsultasyon, false,
                s.konsultasyon == 0, "Hekim onayıyla geçilebilir."),
            new("geciken_doz", "Geciken ilaç dozu", s.gecikenDoz, false, s.gecikenDoz == 0,
                "Taburcuda 'atlandı' olarak kapanır."),
            new("acik_order", "Açık ilaç / sıvı order'ı", s.acikOrder, false,
                s.acikOrder == 0, "Taburcuda otomatik kapanır."),
            new("risk", "Risk değerlendirmesi", s.risk, false, s.risk > 0,
                "Yatış boyunca hiç ölçek doldurulmamış."),
        ];
    }
}
