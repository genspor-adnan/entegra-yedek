using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

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
///
/// <para><b>TEK UÇ, DOKUZ SORGU - her biri kendi metodunda.</b> Şerit, alt
/// tablolar ve sol panel aynı yanıtı paylaşıyor (üç ayrı uç aynı ekranda üç
/// farklı "4 kişi" üretirdi); hepsini tek lambdaya yazmak üç yüz satırlık bir
/// gövde demekti ve hangi sorgunun hangi kutuyu beslediği okunmuyordu.</para>
/// </summary>
public static partial class GozUclari
{
    // --------------------------------------------------------- yanıt satırları --
    // Anonim tip yerine KAYIT: sorgular ayrı metotlara çıkınca dönüş tipinin
    //   bir adı olması gerekiyor. JSON adları camelCase'e çevrilir (Program.cs).
    private sealed record PanoGunOzeti(int Ziyaret, int Tamamlanan, int Unitede, int OrtZiyaretDk);
    private sealed record PanoAcik(int Bekleyen, int OrtBeklemeDk, int EnUzunDk,
                                   int Dilatasyonda, int DilatasyonHazir);
    private sealed record PanoEnUzun(string Hasta, int Istasyon, int Dk);
    private sealed record PanoIstasyon(int Istasyon, int Sayi, int EnUzunDk);
    /// <summary><c>Oda</c> adı ekranın kolon adıyla aynı kalsın diye korunuyor (tanım geldi, sözleşme değişmedi).</summary>
    private sealed record PanoKaynak(int? KaynakId, string Kod, string Oda, int Tur, string TurAdi,
                                     string Sahip, int Sayi, string Hasta, int Istasyon,
                                     int SureDk, int EnUzunDk, bool Bos, bool Tanimli);
    private sealed record PanoHekim(int PersonelId, string Personel, int Tamamlanan, int Bekleyen,
                                    int OrtDk, int EnUzunDk, int? GecikmeDk, int Randevulu);
    private sealed record PanoPanelKisi(int Id, string Ad, int Sayi);
    private sealed record PanoPanelKaynak(int? KaynakId, string Ad, int Sayi);
    private sealed record PanoVardiya(int Id, string Vardiya);
    private sealed record PanoAntet(string Unvan, string Adres, string Ilce, string Il,
                                    string Telefon, string SubeAd, int? LogoDokumanId);

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

            var gunOzet = await GunOzetiAsync(baglanti, gunBas, gunSon, iptal);
            var acik = await AcikIstasyonOzetiAsync(baglanti, iptal);
            var enUzun = await EnUzunBekleyenAsync(baglanti, iptal);
            var istasyonlar = await IstasyonKirilimiAsync(baglanti, iptal);
            var odalar = await KaynakDolulugaAsync(baglanti, iptal);
            var hekimler = await HekimYukuAsync(baglanti, gunBas, gunSon, iptal);
            var panelHekimler = await PanelHekimleriAsync(baglanti, iptal);
            var vardiyalar = await VardiyalarAsync(baglanti, baglam.SubeId, tarih, iptal);
            var antet = await AntetAsync(baglanti, baglam.SubeId, iptal);

            // SOL PANELİN KAYNAK LİSTESİ doluluktan TÜRETİLİYOR: ikinci bir
            //   sorgu aynı sayıyı iki kez (ve zamanla farklı) hesaplardı.
            var panelKaynaklar = odalar
                .Where(o => o.Sayi > 0)
                .Select(o => new PanoPanelKaynak(o.KaynakId, o.Oda, o.Sayi))
                .ToList();

            // DARBOĞAZ = en uzun bekleyen istasyon (eşitlikte kalabalık olan).
            var darbogaz = istasyonlar
                .OrderByDescending(i => i.EnUzunDk).ThenByDescending(i => i.Sayi)
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

    /// <summary>
    /// GÜNÜN ZİYARETLERİ: ziyaret = başvuru (belge). Aynı hasta gün içinde iki
    /// kez gelebilir; sayaç HASTAYI değil ZİYARETİ sayar - ünitenin yükü
    /// ziyaret başına doğuyor.
    /// </summary>
    private static Task<PanoGunOzeti?> GunOzetiAsync(
        NpgsqlConnection baglanti, DateTime gunBas, DateTime gunSon, CancellationToken iptal)
        => baglanti.TekAsync("""
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
                   -- ORTALAMA ZİYARET yalnız TAMAMLANANLARDAN: hâlâ ünitede
                   --   olan hastayı ortalamaya katmak, günün ortasında süreyi
                   --   olduğundan kısa gösterirdi.
                   coalesce(round(avg(extract(epoch from (son_cikis - ilk_giris)) / 60)
                                  filter (where acik = 0))::int, 0)     as ort_ziyaret_dk
              from ziyaret
            """, null, [gunBas, gunSon], o => new PanoGunOzeti(
                o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3)), iptal);

    /// <summary>
    /// AÇIK İSTASYONLAR: kanbanın gösterdiği küme. Bekleme ölçümleri buradan -
    /// kapanmış satırın beklemesi geçmişte kaldı. Dilatasyon eşiği tek sabitten
    /// (<see cref="DilatasyonDk"/>).
    /// </summary>
    private static Task<PanoAcik?> AcikIstasyonOzetiAsync(
        NpgsqlConnection baglanti, CancellationToken iptal)
        => baglanti.TekAsync($"""
            select count(*)::int                                          as bekleyen,
                   coalesce(round(avg(extract(epoch from (now() - i.giris)) / 60))::int, 0)
                                                                          as ort_bekleme_dk,
                   coalesce(max(extract(epoch from (now() - i.giris)) / 60)::int, 0)
                                                                          as en_uzun_dk,
                   count(*) filter (where i.dilatasyon_zamani is not null)::int
                                                                          as dilatasyonda,
                   count(*) filter (where i.dilatasyon_zamani is not null
                                      and i.dilatasyon_zamani
                                          + make_interval(mins => {DilatasyonDk}) <= now())::int
                                                                          as dilatasyon_hazir
              from public.goz_ziyaret_istasyon i
             where i.cikis is null
            """, null, [], o => new PanoAcik(
                o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3), o.GetInt32(4)), iptal);

    /// <summary>
    /// EN UZUN BEKLEYEN kim ve nerede: sayının yanında ADI da dursun - "31 dk"
    /// tek başına kimseyi harekete geçirmiyor.
    /// </summary>
    private static Task<PanoEnUzun?> EnUzunBekleyenAsync(
        NpgsqlConnection baglanti, CancellationToken iptal)
        => baglanti.TekAsync("""
            select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan, i.istasyon,
                   (extract(epoch from (now() - i.giris)) / 60)::int as dk
              from public.goz_ziyaret_istasyon i
              join public.taraf t on t.id = i.hasta_id
             where i.cikis is null
             order by i.giris
             limit 1
            """, null, [], o => new PanoEnUzun(
                o.GetString(0), o.GetInt16(1), o.GetInt32(2)), iptal);

    /// <summary>
    /// İSTASYON KIRILIMI + DARBOĞAZ: hangi masada kaç kişi bekliyor ve oranın
    /// en uzun beklemesi kaç dakika.
    /// </summary>
    private static Task<List<PanoIstasyon>> IstasyonKirilimiAsync(
        NpgsqlConnection baglanti, CancellationToken iptal)
        => baglanti.ListeAsync("""
            select i.istasyon, count(*)::int as sayi,
                   coalesce(max(extract(epoch from (now() - i.giris)) / 60)::int, 0) as en_uzun_dk
              from public.goz_ziyaret_istasyon i
             where i.cikis is null
             group by i.istasyon
             order by i.istasyon
            """, null, [], o => new PanoIstasyon(
                o.GetInt16(0), o.GetInt32(1), o.GetInt32(2)), iptal);

    /// <summary>
    /// ODA / CİHAZ DOLULUĞU: pano HASTAYI değil KAYNAĞI sayar. Bekleme çoğu
    /// zaman hekimden değil tek cihazdan doğuyor; hasta bazlı bakan pano bunu
    /// gizler ("bugün neden geç kaldık" sorusunun cevabı burada).
    ///
    /// <para>976: kaynak artık TANIMLI (<c>goz_kaynak</c>) ve görünüm BOŞ
    /// kaynağı da döndürüyor. Mockup'ın söylediği cümle - "HFA sırası dört
    /// kişiyken muayene odası boş duruyor" - ancak boş oda da satır üretirse
    /// kurulabiliyor; yalnız dolu odaları saymak, panonun asıl işini (atıl
    /// kaynağı göstermek) imkânsız kılardı.</para>
    /// </summary>
    private static Task<List<PanoKaynak>> KaynakDolulugaAsync(
        NpgsqlConnection baglanti, CancellationToken iptal)
        => baglanti.ListeAsync("""
            select d.kaynak_id, d.kod, d.ad, d.tur, d.tur_adi, d.sahip_adi,
                   d.sayi, d.hasta, d.istasyon, d.sure_dk, d.en_uzun_dk, d.bos, d.tanimli
              from public.v_goz_kaynak_doluluk d
             order by d.bos, d.en_uzun_dk desc, d.sira, d.ad
            """, null, [], o => new PanoKaynak(
                o.IsDBNull(0) ? null : o.GetInt32(0), o.GetString(1), o.GetString(2),
                o.GetInt16(3), o.GetString(4), o.GetString(5), o.GetInt32(6), o.GetString(7),
                o.GetInt16(8), o.GetInt32(9), o.GetInt32(10),
                o.GetInt16(11) == 1, o.GetInt16(12) == 1), iptal);

    /// <summary>
    /// HEKİM YÜKÜ: tamamlanan, bekleyen ve ortalama muayene süresi. TEKNİKER DE
    /// BU LİSTEDE (personel_id kim olursa olsun): ön tetkik ünitenin girişidir,
    /// tıkanırsa hekim odası boş kalır. Yalnız hekim sayılsaydı pano "hekimler
    /// yavaş" derdi - oysa sıra girişte.
    ///
    /// <para>976: GECİKME kolonu eklendi (mockup "+12 dk"). Gecikme, hastanın
    /// randevu saatiyle istasyona GİRİŞİ arasındaki fark - randevusuz hastada
    /// ölçülemez ve NULL kalır; sıfır yazmak "zamanında" demek olurdu ve
    /// panonun en çok bakılan kolonu yanlış cesaret verirdi.</para>
    /// </summary>
    private static Task<List<PanoHekim>> HekimYukuAsync(
        NpgsqlConnection baglanti, DateTime gunBas, DateTime gunSon, CancellationToken iptal)
        => baglanti.ListeAsync("""
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
            """, null, [gunBas, gunSon], o => new PanoHekim(
                o.GetInt32(0), o.GetString(1), o.GetInt32(2), o.GetInt32(3), o.GetInt32(4),
                o.GetInt32(5), o.IsDBNull(6) ? null : o.GetInt32(6), o.GetInt32(7)), iptal);

    /// <summary>
    /// SOL PANEL SÜZGECİ (976, mockup şeridindeki "Hekim ▾"): kimde kaç açık
    /// satır var. Sayılar listenin kendi süzgecinden GEÇMEDEN hesaplanıyor:
    /// panel hekimi seçtikten sonra da öteki hekimlerin yükünü göstermeli,
    /// yoksa seçim yapan kişi kendi dışındaki yığılmayı göremez.
    /// </summary>
    private static Task<List<PanoPanelKisi>> PanelHekimleriAsync(
        NpgsqlConnection baglanti, CancellationToken iptal)
        => baglanti.ListeAsync("""
            select a.hekim_id, a.hekim_adi, count(*)::int as sayi
              from public.v_goz_unite_akis a
             where a.hekim_id is not null
             group by a.hekim_id, a.hekim_adi
             order by count(*) desc, a.hekim_adi
            """, null, [], o => new PanoPanelKisi(
                o.GetInt32(0), o.GetString(1), o.GetInt32(2)), iptal);

    /// <summary>
    /// VARDİYA: mockup şeridinde "🕐 Vardiya 08:00–16:00" yazıyor. Saat çalışma
    /// planından (718) geliyor; panoya elle yazılan bir aralık plan değişince
    /// sessizce yanlışa düşerdi.
    ///
    /// <para>YALNIZ PANODAKİ HEKİMLER: fonksiyon kurumun bütün hekimlerini
    /// döndürüyor (ellisi birden); panoda dördü varken elli satırı her 30
    /// saniyede bir taşımak kullanılmayan veri yollamak olurdu. Saat "09:00:00"
    /// değil "09:00" - saniye panoda gürültü.</para>
    /// </summary>
    private static Task<List<PanoVardiya>> VardiyalarAsync(
        NpgsqlConnection baglanti, int? subeId, DateOnly tarih, CancellationToken iptal)
        => baglanti.ListeAsync("""
            select b.hekim_id,
                   (to_char(min(b.saat_bas), 'HH24:MI') || '-'
                    || to_char(max(b.saat_bit), 'HH24:MI'))::varchar(20) as vardiya
              from public.fn_hekim_calisma_bloklari(@p0, @p1, @p1) b
             where exists (select 1 from public.v_goz_unite_akis a
                            where a.hekim_id = b.hekim_id)
             group by b.hekim_id
            """, null, [subeId, tarih], o => new PanoVardiya(
                o.GetInt32(0), o.GetString(1)), iptal);

    /// <summary>
    /// ANTET TEK KAYNAKTAN (772, <c>v_sube_antet</c>): gün özeti çıktısı kurum
    /// başlığıyla basılıyor. Döküm ucu ('dokum' yetkisi ister) yerine buraya
    /// eklendi - panoyu kullanan teknikerin döküm yetkisi yok.
    /// </summary>
    private static Task<PanoAntet?> AntetAsync(
        NpgsqlConnection baglanti, int? subeId, CancellationToken iptal)
        => baglanti.TekAsync("""
            select a.unvan, a.adres, a.ilce, a.il, a.telefon, a.sube_ad,
                   a.logo_dokuman_id
              from public.v_sube_antet a
             where a.sube_id = coalesce(@p0,
                   (select id from public.sube where varsayilan = 1 limit 1))
            """, null, [subeId], o => new PanoAntet(
                o.IsDBNull(0) ? "" : o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1),
                o.IsDBNull(2) ? "" : o.GetString(2), o.IsDBNull(3) ? "" : o.GetString(3),
                o.IsDBNull(4) ? "" : o.GetString(4), o.IsDBNull(5) ? "" : o.GetString(5),
                o.IsDBNull(6) ? null : o.GetInt32(6)), iptal);
}
