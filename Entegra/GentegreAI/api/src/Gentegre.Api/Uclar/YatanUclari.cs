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
        // UÇLAR YAŞAM DÖNGÜSÜNE GÖRE AYRI DOSYADA (partial): ana dosyada
        //   12 uç ve 1068 satır vardı. Kabul/yatak ile taburcu/iptal kendi
        //   dosyalarında; özet, nakil, order durdurma ve tahakkuk burada.
        KabulUclariniEkle(grup);
        CikisUclariniEkle(grup);
        EmarUclariniEkle(grup);
        IzlemUclariniEkle(grup);
        IcmalUclariniEkle(grup);
        EpikrizUclariniEkle(grup);
        OrderEkranUclariniEkle(grup);

        // ------------------------------------------------------- yatış özeti ----
        grup.MapGet("/{yatisId:int}/ozet", async (
            int yatisId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Gor);

            var ozet = await veri.TekAsync("""
                select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)                                   as hasta,
                       case when th.dogum_tarihi is null then null
                            else extract(year from age(th.dogum_tarihi))::int end as yas,
                       coalesce(th.cinsiyet, 0)                  as cinsiyet,
                       coalesce(yk.kod, '')                      as yatak,
                       coalesce(o.kod, '')                       as oda,
                       coalesce(o.izolasyon, 0)                  as izolasyon,
                       coalesce(d.ad, '')                        as klinik,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')                     as hekim,
                       coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), '')                     as odeyen,
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
