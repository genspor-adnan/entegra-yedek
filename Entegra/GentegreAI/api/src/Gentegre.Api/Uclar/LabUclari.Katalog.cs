using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// LABORATUVAR KATALOĞU VE ÇALIŞMA TAKVİMİ — bkz. <c>LabUclari</c>.
///
/// <para>Hizmet-tetkik eşlemesi, tetkik ağacı, tetkik özeti ve çalışma takvimi.
/// <b>Katalog okuması YAZMAZ:</b> buradaki uçlar istem açmaz, yalnız
/// "hangi tetkik var, hangi gün çalışılıyor" sorusunu cevaplar - takvim
/// bilgisi istem ekranında "sonuç ne zaman çıkar" olarak görünüyor.</para>
/// </summary>
public static partial class LabUclari
{
    private static void KatalogUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------ katalog sol panel ---
        // GET /api/lab/tetkik/agac - Tetkik Katalogu SOL PANELI (492, mockup
        //   lab_tetkik_katalogu.html "Bölüm / Çalışma Grubu" + "Paneller").
        //
        //   Sayimlar SUNUCUDA: istemci sayfali listeden sayamaz (gordugu 50
        //   satir tum katalog degil). Panel uyeleri de burada doner - panele
        //   tiklayinca liste o tetkik kimlikleriyle suzulur; istemci uyelik
        //   kuralini kendisi kurmaz.
        // GET /api/lab/hizmet/{id}/tetkik - HIZMETIN laboratuvar karsiligi.
        //
        //   Istem kartinda tetkik JENERIK HIZMET ARAMASIYLA seciliyor
        //   (kullanici): kabul masasi SUT kodunu/adini biliyor, laboratuvarin
        //   ic tetkik kodunu degil. Secilen hizmet bir PANEL olabilir
        //   (hemogram 23 parametre) ya da tek tetkik; ekran hangisi oldugunu
        //   bilmeden satiri yazamaz.
        //
        //   PANEL ONCELIKLI: ayni hizmete hem panel hem tetkik baglanmis
        //   olsaydi (kurulum hatasi) tek tetkik yazmak panelin oteki
        //   parametrelerini sessizce dusururdu.
        grup.MapGet("/hizmet/{id:int}/tetkik", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var bulunan = await veri.TekAsync("""
                select p.id as panel_id, null::integer as tetkik_id, p.kod, p.ad
                  from public.lab_panel p
                 where p.hizmet_id = @p0 and p.durum = 0
                union all
                select null, t.id, t.kod, t.ad
                  from public.lab_tetkik t
                 where t.hizmet_id = @p0 and t.durum = 0
                 order by 1 nulls last
                 limit 1
                """, [id],
                o => new { PanelId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0),
                           TetkikId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                           Kod = o.GetString(2), Ad = o.GetString(3) }, iptal);

            if (bulunan is null)
                throw GentegreHatasi.IsKurali(
                    "Bu hizmetin laboratuvar karşılığı tanımlı değil - tetkik "
                    + "kartındaki \"Hizmet (fiyat/fatura)\" alanını doldurun.");

            return Results.Ok(new { bulunan.PanelId, bulunan.TetkikId,
                                    bulunan.Kod, bulunan.Ad,
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/tetkik/agac", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.tetkik", Islem.Gor);

            var bolumler = await veri.ListeAsync("""
                select t.bolum as kod,
                       case t.bolum when 2 then 'Hematoloji' when 3 then 'Hormon'
                            when 4 then 'Mikrobiyoloji' when 5 then 'Seroloji'
                            when 6 then 'Koagülasyon' when 7 then 'İdrar'
                            when 9 then 'Diğer' else 'Biyokimya' end as ad,
                       case t.bolum when 2 then '🩸' when 3 then '🧪' when 4 then '🦠'
                            when 5 then '🧫' when 6 then '🩸' when 7 then '💧'
                            when 9 then '🔬' else '🧪' end as ikon,
                       count(*) as adet,
                       count(*) filter (where t.durum = 0) as aktif
                  from public.lab_tetkik t
                 group by t.bolum
                 order by t.bolum
                """, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            // PANEL UYELERI: panel basina tetkik kimlikleri. Paneller kucuktur
            //   (onlarca tetkik), tek istekte tasinmasi listeyi yavaslatmaz.
            var paneller = await veri.ListeAsync("""
                select p.id, p.kod, p.ad, p.durum,
                       coalesce(array_agg(s.tetkik_id order by s.sira)
                                filter (where s.tetkik_id is not null), '{}') as "tetkikIdleri"
                  from public.lab_panel p
                  left join public.lab_panel_satir s on s.panel_id = p.id
                 group by p.id, p.kod, p.ad, p.durum
                 order by p.ad
                """, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            var toplam = await veri.TekDegerAsync<long>(
                "select count(*) from public.lab_tetkik", [], iptal);

            return Results.Ok(new { toplam, bolumler, paneller, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ secili tetkik ozeti --
        // GET /api/lab/tetkik/{id}/ozet - Tetkik Katalogu listesinin SAG
        //   PANELI (492, mockup lab_tetkik_katalogu.html "Seçili Tetkik").
        //
        //   Panel dort soruyu cevaplar: tetkigin kimligi (LOINC/SKRS, olculebilir
        //   aralik, panik degeri), hangi referans kurallari var, hangi panellerde
        //   kullaniliyor ve simdi istenirse sonuc ne zaman cikar. Hepsi TEK
        //   istekte doner - satir secildikce dort ayri cagri yapmak listeyi
        //   yavaslatirdi.
        grup.MapGet("/tetkik/{id:int}/ozet", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.tetkik", Islem.Gor);

            // ALAN YETKISI KOLONU SORGUDAN CIKARIR, yanittan sonradan silmez
            //   (API sozlesmesi §3.1): yetkisiz deger ne SQL'e ne log'a duser.
            //   Ad -> SQL eslemesi SABIT; istekten gelen hicbir metin buraya
            //   girmez.
            (string Ad, string Sql)[] alanlar =
            [
                ("kod",             "t.kod"),
                ("ad",              "t.ad"),
                ("kisaAd",          "t.kisa_ad"),
                ("birim",           "t.birim"),
                ("loinc",           "t.loinc"),
                ("skrsKod",         "t.skrs_tetkik_kod"),
                ("yontem",          "t.yontem"),
                ("olculebilirAlt",  "t.olculebilir_alt"),
                ("olculebilirUst",  "t.olculebilir_ust"),
                // SONUÇ DOĞRULAMA (893, KTS L1): tetkik özetinde hangi
                //   sınırların tanımlı olduğu görünsün - "neden reddedildi"
                //   sorusu tetkik kartına gitmeden cevaplanabilmeli.
                ("mantikAlt",       "t.mantik_alt"),
                ("mantikUst",       "t.mantik_ust"),
                ("degerDeseni",     "t.deger_deseni"),
                ("panikAlt",        "t.panik_alt"),
                ("panikUst",        "t.panik_ust"),
                ("hedefTatDk",      "t.hedef_tat_dk"),
                ("acilTatDk",       "t.acil_tat_dk"),
                ("bolumAdi",
                 "case t.bolum when 2 then 'Hematoloji' when 3 then 'Hormon' "
                 + "when 4 then 'Mikrobiyoloji' when 5 then 'Seroloji' "
                 + "when 6 then 'Koagülasyon' when 7 then 'İdrar' "
                 + "when 9 then 'Diğer' else 'Biyokimya' end"),
                ("sonucZamani",
                 "public.fn_lab_tetkik_sonuc_zamani(t.id, now()::timestamp, 0::smallint)"),
            ];
            var secilen = alanlar
                .Where(a => baglam.Yetkiler.AlanOkunur("lab-tetkik", a.Ad)).ToList();
            // Kimlik alanlari bile gizlenmisse panelde gosterilecek bir sey yok.
            if (secilen.Count == 0) throw GentegreHatasi.Yasak("Tetkik alanları görüntülenemiyor.");

            var tetkik = await veri.TekAsync(
                "select " + string.Join(", ", secilen.Select(a => $"{a.Sql} as \"{a.Ad}\""))
                + " from public.lab_tetkik t where t.id = @p0",
                [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Tetkik bulunamadı.");

            // REFERANS ARALIKLARI: "kime" metni DB'de uretiliyor (488) - liste
            //   ile kart ayni cumleyi yazsin.
            var referanslar = await veri.ListeAsync("""
                select r.alt, r.ust, r.metin,
                       public.fn_lab_referans_kime(r.cinsiyet, r.yas_alt_gun,
                                                   r.yas_ust_gun, r.gebelik) as kime,
                       -- CIHAZ/YONTEM (888): tetkik panelinde hangi araligin
                       --   hangi cihaza ait oldugu gorunmeli - "iki farkli
                       --   aralik" bilgisi kendi basina yanilticidir.
                       coalesce(c.ad, '') as cihaz, r.yontem
                  from public.lab_tetkik_referans r
                  left join public.cihaz c on c.id = r.cihaz_id
                 where r.tetkik_id = @p0
                 order by (r.cihaz_id is not null), r.sira, r.yas_alt_gun
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var paneller = await veri.ListeAsync("""
                select p.id, p.ad
                  from public.lab_panel_satir s
                  join public.lab_panel p on p.id = s.panel_id
                 where s.tetkik_id = @p0
                 order by p.ad
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SON 30 GUN ISTEM SAYISI: katalogda "bu tetkik gercekten
            //   kullaniliyor mu" sorusunun cevabi.
            var istemAdedi = await veri.TekDegerAsync<long>("""
                select count(*) from public.lab_istem_satir s
                 where s.tetkik_id = @p0 and s.ekleme_tarihi >= now() - interval '30 days'
                """, [id], iptal);

            return Results.Ok(new { tetkik, referanslar, paneller, istemAdedi,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // -------------------------------------------------- calisma takvimi ---
        // GET /api/lab/calisma-takvimi - tetkik kartinin "Çalışma Zamanları"
        //   sekmesindeki HAFTALIK TAKVIM ve UC OZET KUTUSU (487).
        //
        // Duzen PARAMETRE olarak gelir, tetkik id ile degil: kullanici
        //   ekranda duzeni degistirirken onizleme ANINDA guncellensin -
        //   kaydetmeden once "bu ayarla sonuc ne zaman cikar" gorulmeli.
        //   Hesabi yine SUNUCU yapar (fn_lab_calisma_sonuc_zamani): ayni kural
        //   kayitli tetkik icin de calisiyor, iki ayri hesap iki farkli saat
        //   soylerdi.
        grup.MapGet("/calisma-takvimi", async (
            short? duzen, short? gunler, string? saatler, int? kabulSonDk,
            int? tatDk, int? acilTatDk, short? acilBeklemez, DateTime? kabul,
            BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var d   = duzen ?? 0;
            var g   = gunler ?? 0;
            var sa  = saatler ?? "";
            var ksd = kabulSonDk ?? 0;
            var tat = tatDk ?? 0;
            var atat = acilTatDk ?? 0;
            var ab  = acilBeklemez ?? 1;
            var an  = kabul ?? DateTime.Now;

            // Deger NULL olabilir ("tanim eksik, bilmiyorum") - TekDegerAsync
            //   struct'ta da null donebilsin diye nullable T ile cagrilir.
            async Task<DateTime?> ZamanAsync(DateTime kabulAn, short acil)
                => await veri.TekDegerAsync<DateTime?>(
                    "select public.fn_lab_calisma_sonuc_zamani(" +
                    "  @p0::smallint, @p1::smallint, @p2, @p3, @p4, @p5, @p6::smallint, " +
                    "  @p7, @p8::smallint)",
                    [d, g, sa, ksd, tat, atat, ab, kabulAn, acil], iptal);

            // HAFTALIK TAKVIM: saat satiri x gun sutunu. Her hucre o gun o
            //   saatte CALISILIR mi, ve kabul son saati kacta biter.
            var saatListesi = sa.Split(',', StringSplitOptions.RemoveEmptyEntries |
                                            StringSplitOptions.TrimEntries)
                                .Where(x => TimeOnly.TryParse(x, out _))
                                .Select(x => TimeOnly.Parse(x))
                                .OrderBy(x => x).ToList();
            // Sürekli / mesai düzeninde seri saati yoktur - takvim çizilmez.
            var hafta = new List<object>();
            if (d == 2)
                foreach (var saat in saatListesi)
                {
                    var gunler7 = new List<object>();
                    for (var i = 0; i < 7; i++)
                    {
                        var acikMi = (g & (1 << i)) > 0;
                        gunler7.Add(new
                        {
                            acik = acikMi,
                            // Sonuç saati o günün serisine göre: çalışma + TAT.
                            sonuc = acikMi ? saat.AddMinutes(tat).ToString("HH:mm") : null,
                        });
                    }
                    hafta.Add(new
                    {
                        saat = saat.ToString("HH:mm"),
                        kabulSon = saat.AddMinutes(-ksd).ToString("HH:mm"),
                        gunler = gunler7,
                    });
                }

            // ÜÇ ÖZET: mockup'taki kutular. Hepsi AYNI kuraldan geçer.
            var simdi = await ZamanAsync(an, 0);
            // "Kabul son saatinden sonra": bir sonraki seriye kalan numune.
            //   Bir dakika sonrası sorulur - sınırın hangi tarafına düştüğü
            //   kullanıcının en çok yanıldığı yerdir.
            var kacan = await ZamanAsync(
                (simdi is { } ilk && d == 2 ? ilk.AddMinutes(-tat) : an).AddMinutes(-ksd + 1), 0);
            var acilZaman = await ZamanAsync(an, 1);

            return Results.Ok(new
            {
                duzen = d, hafta,
                ozet = new
                {
                    simdiKabul = an,
                    simdi,
                    kacirilan = kacan,
                    acil = acilZaman,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
