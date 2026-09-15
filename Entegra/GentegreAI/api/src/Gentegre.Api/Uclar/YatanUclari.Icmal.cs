using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// YATAN HASTA HİZMET İCMALİ (700, mockup
/// <c>Ekranlar/Yatan/yatan_hizmet_fatura.html</c>).
///
/// <para><b>Satırlar elle girilmez, DÜŞER:</b> yatak ücreti gün sonu
/// tahakkukundan (<c>yatis_tahakkuk</c>), ilaç uygulama kaydından, tetkik ve
/// görüntüleme order'ından. Elle giriş açık bırakılsaydı aynı kalem hem
/// otomatik hem elle iki kez faturalanırdı — yatan hastada en sık görülen
/// fatura hatası budur.</para>
///
/// <para><b>İcmal HESAPLANIR, saklanmaz.</b> Kaynak kayıtlar (tahakkuk, doz,
/// order) zaten duruyor; ikinci bir "icmal tablosu" tutmak, kaynak
/// değiştiğinde sessizce eskiyen bir kopya üretirdi. Faturalama anında
/// satırlar belgeye yazılır ve tahakkuk <c>belge_satir_id</c> ile işaretlenir.</para>
///
/// <para><b>Hasta payı burada UYDURULMAZ.</b> SUT kapsam ve paket kuralları
/// Medula'nın işidir; icmal yalnız <i>kapsam dışı olduğu kesin</i> olanı
/// (refakat, ödeyen kurumu olmayan yatış) hasta payına yazar, gerisini
/// "kurum" sütununda gösterir ve kesin cevabın provizyon/Medula'dan geleceğini
/// ekranda söyler. Tahmini bir yüzde uydurmak, hastaya yanlış rakam söylemenin
/// en kısa yoludur.</para>
/// </summary>
public static partial class YatanUclari
{
    private static void IcmalUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/{yatisId:int}/icmal", async (
            int yatisId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var yatis = await baglanti.TekAsync("""
                select y.dosya_no, t.unvan as hasta, y.giris_tarihi, y.cikis_tarihi,
                       (coalesce(y.cikis_tarihi, now())::date - y.giris_tarihi::date) as gun,
                       coalesce(d.ad, '') as klinik, coalesce(h.unvan, '') as hekim,
                       coalesce(k.unvan, '') as odeyen, y.odeyen_kurum_id,
                       y.provizyon_no, y.cikis_tani_kodu, y.durum
                  from public.yatis y
                  join public.taraf t on t.id = y.hasta_id
                  left join public.departman d on d.id = y.departman_id
                  left join public.taraf h on h.id = y.hekim_id
                  left join public.taraf k on k.id = y.odeyen_kurum_id
                 where y.id = @p0
                """, null, [yatisId], o => new
            {
                dosyaNo = o.GetString(0),
                hasta = o.GetString(1),
                girisTarihi = o.GetDateTime(2),
                cikisTarihi = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3),
                gun = o.GetInt32(4),
                klinik = o.GetString(5),
                hekim = o.GetString(6),
                odeyen = o.GetString(7),
                odeyenKurumId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
                provizyonNo = o.GetString(9),
                cikisTani = o.GetString(10),
                durum = (int)o.GetInt16(11),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

            // ---------------------------------------------- yatak ve refakat ----
            // Tahakkuk satırları GÜN GÜN yazılır; icmalde aynı hizmet/yatak
            //   birleştirilir ("09–11.09 · 2 gün") - kırk günlük yatışta kırk
            //   satır, okunacak bir icmal değildir.
            var yatak = await baglanti.ListeAsync("""
                select th.kaynak, th.hizmet_id, th.aciklama,
                       coalesce(hz.kod, '') as sut,
                       count(*)::int      as adet,
                       min(th.tarih)      as ilk,
                       max(th.tarih)      as son,
                       max(th.birim_fiyat) as birim,
                       sum(th.tutar)      as tutar,
                       count(*) filter (where th.belge_satir_id is null)::int as faturasiz
                  from public.yatis_tahakkuk th
                  left join public.hizmet hz on hz.id = th.hizmet_id
                 where th.yatis_id = @p0
                 group by th.kaynak, th.hizmet_id, th.aciklama, hz.kod
                 order by th.kaynak, min(th.tarih)
                """, null, [yatisId], o => new
            {
                kaynak = (int)o.GetInt16(0),
                hizmetId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                ad = o.GetString(2),
                sut = o.GetString(3),
                adet = o.GetInt32(4),
                ilk = o.GetDateTime(5),
                son = o.GetDateTime(6),
                birim = o.GetDecimal(7),
                tutar = o.GetDecimal(8),
                faturasiz = o.GetInt32(9),
            }, iptal);

            // ------------------------------------------------- ilaç uygulama ----
            // UYGULANMIŞ doz faturalanır, planlanan değil: "verilecekti" ile
            //   "verildi" arasındaki fark, hastaya çıkarılan faturadır.
            var ilac = await baglanti.ListeAsync("""
                select od.ad, coalesce(hz.kod, '') as sut, od.hizmet_id,
                       count(*)::int as adet,
                       min(u.uygulanan) as ilk, max(u.uygulanan) as son,
                       coalesce(max(kf.fiyat), 0) as birim,
                       (count(*) * coalesce(max(kf.fiyat), 0)) as tutar,
                       count(*) filter (where u.elle_dogrulandi = 1)::int as barkodsuz
                  from public.order_uygulama u
                  join public.yatis_order od on od.id = u.order_id
                  left join public.hizmet hz on hz.id = od.hizmet_id
                  left join lateral (
                      select f.fiyat from public.fn_belge_kalem_fiyati(
                          (select y.hasta_id from public.yatis y where y.id = od.yatis_id),
                          2::smallint, null, od.hizmet_id, current_date) f limit 1
                  ) kf on od.hizmet_id is not null
                 where od.yatis_id = @p0 and u.durum = 2
                 group by od.ad, hz.kod, od.hizmet_id
                 order by od.ad
                """, null, [yatisId], o => new
            {
                ad = o.GetString(0),
                sut = o.GetString(1),
                hizmetId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                adet = o.GetInt32(3),
                ilk = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                son = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                birim = o.GetDecimal(6),
                tutar = o.GetDecimal(7),
                barkodsuz = o.GetInt32(8),
            }, iptal);

            // ------------------------------------------ tetkik / görüntüleme ----
            var tetkik = await baglanti.ListeAsync("""
                select od.tur, od.ad, coalesce(hz.kod, '') as sut, od.hizmet_id,
                       od.baslangic, od.durum,
                       coalesce(kf.fiyat, 0) as birim
                  from public.yatis_order od
                  left join public.hizmet hz on hz.id = od.hizmet_id
                  left join lateral (
                      select f.fiyat from public.fn_belge_kalem_fiyati(
                          (select y.hasta_id from public.yatis y where y.id = od.yatis_id),
                          2::smallint, null, od.hizmet_id, current_date) f limit 1
                  ) kf on od.hizmet_id is not null
                 where od.yatis_id = @p0 and od.tur in (3, 4, 5) and od.durum <> 0
                 order by od.baslangic
                """, null, [yatisId], o => new
            {
                tur = (int)o.GetInt16(0),
                ad = o.GetString(1),
                sut = o.GetString(2),
                hizmetId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                tarih = o.GetDateTime(4),
                durum = (int)o.GetInt16(5),
                birim = o.GetDecimal(6),
            }, iptal);

            // ---------------------------------------------------------- toplam ----
            // KURUM / HASTA AYRIMI: ödeyen kurumu olmayan yatışta hepsi hasta
            //   payıdır. Kurumu varsa refakat (kaynak 2) kapsam dışıdır;
            //   gerisinin kesin cevabı Medula provizyonundan gelir - burada
            //   tahmin edilmez, "kurum" sütununda gösterilir.
            var kurumVar = yatis.odeyenKurumId is > 0;
            var yatakToplam = yatak.Sum(y => y.tutar);
            var ilacToplam = ilac.Sum(i => i.tutar);
            var tetkikToplam = tetkik.Sum(t => t.birim);
            var toplam = yatakToplam + ilacToplam + tetkikToplam;
            var hastaPayi = kurumVar
                ? yatak.Where(y => y.kaynak == 2).Sum(y => y.tutar)
                : toplam;

            return Results.Ok(new
            {
                yatis,
                yatak,
                ilac,
                tetkik,
                toplam = new
                {
                    hizmet = toplam,
                    kurum = toplam - hastaPayi,
                    hasta = hastaPayi,
                    faturalanmamis = yatak.Where(y => y.faturasiz > 0).Sum(y => y.tutar)
                                     + ilacToplam,
                    kurumVar,
                    provizyonVar = yatis.provizyonNo.Length > 0,
                },
            });
        });
    }
}
