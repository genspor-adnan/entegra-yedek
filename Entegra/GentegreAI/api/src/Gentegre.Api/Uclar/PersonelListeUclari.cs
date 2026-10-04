using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PERSONEL LİSTESİ (963, mockup Ekranlar/IK/personel_listesi.html).
///
/// Gösterge şeridi (aktif, bugün izinde, raporlu, onay bekleyen talep, deneme
/// süresinde, bu ay doğum günü, eksik özlük) ve bölüm ağacı sayıları; seçili
/// personelin önizleme paneli. Sayılar listenin süzdüğü görünümden
/// (v_personel_durum) gelir - kutuya tıklayınca çıkan satır sayısı kutudaki
/// sayıyla aynıdır.
/// </summary>
public static class PersonelListeUclari
{
    public static void PersonelListeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ik").WithTags("Personel Listesi").RequireAuthorization();

        // GÖSTERGE + BÖLÜM SAYILARI. bolumler: seçili dal ve alt birimleri
        //   (boş = tümü), bolumsuz=1: bölümü atanmamışlar, rol: rol süzgeci.
        grup.MapGet("/personel-gosterge", async (string? bolumler, int? bolumsuz, int? rol, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("personel", Islem.Gor);
            var idler = (bolumler ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(x => int.TryParse(x, out var v) ? v : 0).Where(v => v > 0).ToArray();
            await using var b = await veri.AcAsync(iptal);

            var gosterge = await b.TekAsync("""
                select count(*) filter (where t.durum = 1)                         as aktif,
                       count(*) filter (where pd.bugun_kod = 2)                    as izinde,
                       count(*) filter (where pd.bugun_kod = 3)                    as raporlu,
                       coalesce(sum(pd.onayda_talep) filter (where t.durum = 1), 0) as "onaydaTalep",
                       count(*) filter (where t.durum = 1 and pd.onayda_talep > 0) as "talepliKisi",
                       count(*) filter (where pd.bugun_kod = 4)                    as deneme,
                       count(*) filter (where t.durum = 1 and pd.dogum_bu_ay = 1)  as "dogumBuAy",
                       count(*) filter (where t.durum = 1 and pd.eksik <> '')      as eksik
                  from public.taraf t
                  join public.v_personel_durum pd on pd.taraf_id = t.id
                  left join public.taraf_kullanici tk on tk.id = t.id
                 where t.personel = 1
                   and (cardinality(@p0::int[]) = 0 or t.departman = any(@p0::int[]))
                   and (@p1 = 0 or t.departman is null)
                   and (@p2 = 0 or tk.rol_id = @p2)
                """, null, [idler, bolumsuz ?? 0, rol ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            // BÖLÜM AĞACI: tüm birimler (üst-alt), her birinde AKTİF personel sayısı
            //   (alt birimler hariç - toplamı istemci ağaçta toplar).
            var bolumListesi = await b.ListeAsync("""
                select d.id, d.ad, d.ustbirim_id as ust,
                       (select count(*) from public.taraf t where t.personel = 1 and t.durum = 1 and t.departman = d.id)::int as sayi
                  from public.departman d
                 where d.durum = 1
                 order by d.sira, d.ad
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            var bolumsuzSayi = await b.TekDegerAsync<long>(
                "select count(*) from public.taraf where personel = 1 and durum = 1 and departman is null", null, [], iptal);

            return Results.Ok(new { gosterge, bolumler = bolumListesi, bolumsuz = bolumsuzSayi, izlemeNo = baglam.IzlemeNo });
        });

        // ÖNİZLEME PANELİ: seçili personel - bugün, yönetici, iletişim, izin
        //   bakiyesi, son 3 talep, eksikler.
        grup.MapGet("/personel/{id:int}/onizleme", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIsteKendi(id, "personel", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var kisi = await b.TekAsync($$"""
                select t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad, t.kod as sicil,
                       {{Gentegre.Cekirdek.Katalog.KaynakKatalogu.TarafKatalog.PozisyonAdi}} as gorev,
                       coalesce((select d.ad from public.departman d where d.id = t.departman), '') as bolum,
                       p.ise_giris_tarihi as "iseGiris", pd.bugun, pd.bugun_kod as "bugunKod", pd.kidem,
                       pd.kalan_izin as "kalanIzin", pd.hak_toplam as "hakToplam",
                       coalesce(bk.kullanilan_gun, 0) + coalesce(bk.planlanan_gun, 0) as kullanilan,
                       coalesce(bk.onayda_gun, 0) as onayda, pd.eksik,
                       coalesce(public.fn_taraf_ad(y.unvan, y.ad, y.soyad)::varchar(120), '') as yonetici,
                       {{Gentegre.Cekirdek.Katalog.KaynakKatalogu.TarafKatalog.TelefonMaske}} as telefon,
                       coalesce(t.eposta, '') as eposta, coalesce(r.ad, '') as rol, pd.dogum_bugun as "dogumBugun"
                  from public.taraf t
                  left join public.taraf_personel p on p.id = t.id
                  left join public.v_personel_durum pd on pd.taraf_id = t.id
                  left join public.v_personel_izin_bakiye bk on bk.taraf_id = t.id
                  left join public.taraf y on y.id = p.yonetici_taraf_id
                  left join public.taraf_kullanici tk on tk.id = t.id
                  left join public.rol r on r.id = tk.rol_id
                 where t.id = @p0 and t.personel = 1
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Personel bulunamadı.");

            var talepler = await b.ListeAsync(TaleplerimUclari.TalepSorgusu("true", 3, "t.ekleme_tarihi desc, t.id desc"),
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SÜRESİ GEÇEN / YAKLAŞAN EĞİTİM-SERTİFİKA: geçerlilik tarih olarak
            //   girilmişse (2026-11-30 / 30.11.2026) okunur; yalnız yıl ya da
            //   serbest metin değerlendirilmez.
            var egitim = await b.ListeAsync("""
                select e.ad, g.tarih as gecerlilik
                  from public.personel_egitim e
                  cross join lateral (select case
                       when e.gecerlilik ~ '^\d{4}-\d{2}-\d{2}' then to_date(left(e.gecerlilik, 10), 'YYYY-MM-DD')
                       when e.gecerlilik ~ '^\d{2}\.\d{2}\.\d{4}' then to_date(left(e.gecerlilik, 10), 'DD.MM.YYYY')
                       end as tarih) g
                 where e.taraf_id = @p0 and g.tarih is not null and g.tarih < current_date + 60
                 order by g.tarih
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { kisi, talepler, egitim, izlemeNo = baglam.IzlemeNo });
        });
    }
}
