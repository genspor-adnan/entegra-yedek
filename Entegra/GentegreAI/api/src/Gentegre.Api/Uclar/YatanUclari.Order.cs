using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ORDER LİSTESİ + KARTI (968, mockup Ekranlar/Yatan/order_listesi_v2.html · order_karti_v2.html).
///
/// Gösterge şeridi + sol panel (servis / oda / tür) sayıları, önizleme ve kartın
/// hasta şeridi / güvenlik kontrolleri, doz planı ızgarası, geçmiş, kopyala
/// (Tekrarla / Doz değiştir). Satır başı bilgiler v_yatis_order_ozet'ten: liste
/// kolonu ile kutu aynı tanımı okur.
///
/// ZAMAN: doz saati kurum (Europe/Istanbul) duvar saatidir (969); gün ve saat
/// yerel okunur - eMAR ile aynı.
/// </summary>
public static partial class YatanUclari
{
    private static void OrderEkranUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/order-gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var gosterge = await b.TekAsync("""
                select count(*) filter (where od.durum = 1)                                                as aktif,
                       count(*) filter (where od.durum = 1 and od.sozel_order = 1 and od.onay_tarihi is null) as imzasiz,
                       coalesce(sum(v.bugun_doz) filter (where od.durum = 1), 0)                           as "bugunDoz",
                       coalesce(sum(v.geciken_doz) filter (where od.durum = 1), 0)                         as geciken,
                       count(*) filter (where od.durum = 1 and v.bugun_bitiyor = 1)                        as biten,
                       count(*) filter (where od.durum = 1 and v.yuksek_risk = 1)                          as "yuksekRisk"
                  from public.yatis_order od join public.v_yatis_order_ozet v on v.order_id = od.id
                 where (@p0::int is null or od.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            // SOL PANEL: servis > oda ağacı ve tür sayıları (aktif order'lar).
            var odalar = await b.ListeAsync("""
                select v.servis, v.oda, count(*) as sayi
                  from public.yatis_order od join public.v_yatis_order_ozet v on v.order_id = od.id
                 where od.durum = 1 and (@p0::int is null or od.sube_id = @p0)
                 group by 1, 2 order by 1, 2
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var turler = await b.ListeAsync("""
                select od.tur, count(*) as sayi from public.yatis_order od
                 where od.durum = 1 and (@p0::int is null or od.sube_id = @p0)
                 group by 1 order by 1
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { gosterge, odalar, turler, izlemeNo = baglam.IzlemeNo });
        });

        // ÖZET: önizleme paneli + kartın hasta şeridi / Order sekmesi özeti / Güvenlik kontrolleri.
        grup.MapGet("/order/{id:int}/ozet", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                select od.id, od.ad, od.tur, od.durum, od.siklik, od.sozel_order as "sozelOrder",
                       (od.onay_tarihi is not null) as imzali, od.baslangic, od.bitis, od.stat, od.prn,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as hekim,
                       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as hasta,
                       coalesce(yk.kod, '') as yatak, v.servis, v.oda, v.yas, v.cinsiyet, v.alerjiler,
                       ((now() at time zone 'Europe/Istanbul')::date - (y.giris_tarihi at time zone 'Europe/Istanbul')::date) + 1 as "yatisGunu",
                       coalesce(nullif(ic.ad, ''), y.yatis_tani_kodu, '') as tani,
                       v.gun_no as "gunNo", v.gun_toplam as "gunToplam", v.toplam_doz as "toplamDoz",
                       v.verilen_doz as "verilenDoz", v.geciken_doz as "gecikenDoz",
                       to_char(v.sonraki at time zone 'Europe/Istanbul', 'DD.MM.YYYY HH24:MI') as sonraki,
                       v.yuksek_risk as "yuksekRisk", v.risk_anahtar as "riskAnahtar",
                       v.alerji_eslesen as "alerjiEslesen", v.mukerrer, coalesce(i.etken_madde, '') as etken,
                       (select count(*) from public.yatis_order x where x.yatis_id = od.yatis_id and x.durum = 1 and x.id <> od.id) as "digerAktif"
                  from public.yatis_order od
                  join public.yatis y on y.id = od.yatis_id
                  join public.taraf t on t.id = y.hasta_id
                  left join public.yatak yk on yk.id = y.yatak_id
                  left join public.taraf h on h.id = od.hekim_id
                  left join public.ilac i on i.id = od.ilac_id
                  left join public.v_icd_lookup ic on ic.id::text = y.yatis_tani_kodu
                  join public.v_yatis_order_ozet v on v.order_id = od.id
                 where od.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Order bulunamadı.");
            var bugun = await b.ListeAsync("""
                select to_char(u.planlanan at time zone 'Europe/Istanbul', 'HH24:MI') as saat,
                       case when u.durum = 1 and u.planlanan < now() - interval '30 minutes' then 5 else u.durum end as durum,
                       to_char(u.uygulanan at time zone 'Europe/Istanbul', 'HH24:MI') as uygulanan,
                       coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), '') as uygulayan
                  from public.order_uygulama u left join public.taraf p on p.id = u.uygulayan_id
                 where u.order_id = @p0
                   and (u.planlanan at time zone 'Europe/Istanbul')::date = (now() at time zone 'Europe/Istanbul')::date
                 order by u.planlanan
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // GÜVENLİK KONTROLLERİ: sunucunun bildiği kadar; bilinmeyen "kontrol edilmedi" der.
            var ilacMi = Convert.ToInt32(o["tur"]) is 1 or 2 or 8;
            var guvenlik = new List<object>();
            void K(string kontrol, string durum, string sonuc, string ayrinti) => guvenlik.Add(new { kontrol, durum, sonuc, ayrinti });
            var alerjiler = (string?)o["alerjiler"] ?? "";
            var eslesen = (string?)o["alerjiEslesen"] ?? "";
            if (!ilacMi) K("Alerji", "gri", "Gerekmez", "ilaç order'ı değil");
            else if (eslesen != "") K("Alerji", "hata", "Eşleşme", $"kayıtlı alerji: {eslesen}");
            else K("Alerji", "ok", "Uygun", alerjiler == "" ? "kayıtlı alerji yok" : $"kayıtlı alerjilerle eşleşme yok ({alerjiler})");
            K("Mükerrer order", Convert.ToInt32(o["mukerrer"]) == 1 ? "uyari" : "ok",
              Convert.ToInt32(o["mukerrer"]) == 1 ? "Var" : "Yok",
              Convert.ToInt32(o["mukerrer"]) == 1 ? "aynı ilaç / hizmet bu yatışta aktif" : $"aktif {o["digerAktif"]} order ile karşılaştırıldı");
            K("Yüksek riskli ilaç", Convert.ToInt32(o["yuksekRisk"]) == 1 ? "uyari" : "gri",
              Convert.ToInt32(o["yuksekRisk"]) == 1 ? "Evet" : "Değil",
              Convert.ToInt32(o["yuksekRisk"]) == 1 ? $"{o["riskAnahtar"]} - uygulamada çift kontrol" : "çift kontrol gerekmez");
            K("Sözel order onayı", Convert.ToInt32(o["sozelOrder"]) != 1 ? "gri" : (bool)o["imzali"]! ? "ok" : "uyari",
              Convert.ToInt32(o["sozelOrder"]) != 1 ? "Yazılı" : (bool)o["imzali"]! ? "Onaylı" : "Bekliyor",
              Convert.ToInt32(o["sozelOrder"]) != 1 ? "order sistemden yazıldı" : "sözel order 24 saat içinde hekim onayı ister");
            K("Doz aralığı / böbrek ayarı", "gri", "Kontrol edilmedi", "ilaç doz bilgisi tanımlı değil - hekim kararı");
            return Results.Ok(new { order = o, bugun, guvenlik, izlemeNo = baglam.IzlemeNo });
        });

        // DOZ PLANI: gün x saat; gerçekleşen satırlar order_uygulama'dan, henüz
        //   üretilmemiş günler order saatlerinden (planlı).
        grup.MapGet("/order/{id:int}/plan", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                select (od.baslangic at time zone 'Europe/Istanbul')::date as bas,
                       (od.bitis at time zone 'Europe/Istanbul')::date as bit, coalesce(od.saatler::text, '[]') as saatler,
                       od.durum, od.tur, (now() at time zone 'Europe/Istanbul')::date as bugun,
                       to_char(now() at time zone 'Europe/Istanbul', 'HH24:MI') as simdi
                  from public.yatis_order od where od.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Order bulunamadı.");
            var satirlar = await b.ListeAsync("""
                select (u.planlanan at time zone 'Europe/Istanbul')::date as gun,
                       to_char(u.planlanan at time zone 'Europe/Istanbul', 'HH24:MI') as saat,
                       case when u.durum = 1 and u.planlanan < now() - interval '30 minutes' then 5 else u.durum end as durum,
                       to_char(u.uygulanan at time zone 'Europe/Istanbul', 'HH24:MI') as uygulanan
                  from public.order_uygulama u where u.order_id = @p0 order by u.planlanan
                """, null, [id], o => (Gun: DateOnly.FromDateTime(o.GetDateTime(0)), Saat: o.GetString(1),
                                       Durum: Convert.ToInt32(o.GetValue(2)), Uygulanan: o.IsDBNull(3) ? null : o.GetString(3)), iptal);
            var saatler = new List<string>();
            try { saatler = JsonSerializer.Deserialize<List<string>>((string)o["saatler"]!) ?? []; } catch (JsonException) { }
            // Order saatleri "planlı" hücre üretir; yalnız gerçekleşmiş satırlarda geçen
            //   saatler (saat değişmiş, 969 öncesi UTC satırı) yalnız kendi hücresini gösterir.
            var orderSaatleri = saatler.ToHashSet();
            var simdi = (string)o["simdi"]!;
            saatler = saatler.Union(satirlar.Select(s => s.Saat)).Distinct().OrderBy(x => x).ToList();

            var bas = DateOnly.FromDateTime((DateTime)o["bas"]!);
            var bugun = DateOnly.FromDateTime((DateTime)o["bugun"]!);
            var bit = o["bit"] is DateTime bt ? DateOnly.FromDateTime(bt) : bugun.AddDays(3);
            if (satirlar.Count > 0 && satirlar[^1].Gun > bit) bit = satirlar[^1].Gun;
            // En çok 14 gün: uzun order'da son iki hafta (bugün içinde) görünür.
            if (bit.DayNumber - bas.DayNumber > 13) bas = bit.AddDays(-13);
            var aktif = Convert.ToInt32(o["durum"]) == 1;
            var gunler = Enumerable.Range(0, bit.DayNumber - bas.DayNumber + 1).Select(i => bas.AddDays(i)).ToList();
            var izgara = saatler.Select(sa => new
            {
                saat = sa,
                hucreler = gunler.Select(g =>
                {
                    var s = satirlar.FirstOrDefault(x => x.Gun == g && x.Saat == sa);
                    if (s.Saat is not null) return new { durum = s.Durum, uygulanan = s.Uygulanan };
                    // Üretilmemiş: aktif order'ın saatinde, henüz gelmemiş an "planlı" (0); gerisi boş (-1).
                    var gelecek = g > bugun || (g == bugun && string.CompareOrdinal(sa, simdi) > 0);
                    var planli = aktif && gelecek && orderSaatleri.Contains(sa) && (o["bit"] is not DateTime || g <= bit);
                    return new { durum = planli ? 0 : -1, uygulanan = (string?)null };
                }).ToArray(),
            }).ToList();
            return Results.Ok(new { gunler, izgara, bugun, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/order/{id:int}/gecmis", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            // İki kaynak: kayıt günlüğü (verildi / değişti / imza / durdur) ve uygulamalar.
            var satirlar = await b.ListeAsync("""
                select * from (
                    select g.tarih, coalesce(k.ad, '') as kullanici,
                           case g.islem_tipi when 1 then 'Order verildi' when 0 then 'Silindi' else 'Değiştirildi' end as islem,
                           coalesce(g.bilgi::text, '') as bilgi
                      from public.islem_log g left join public.v_kullanici_lookup k on k.id = g.kullanici_id
                     where g.tablo_id in (@p1, @p2) and (g.kayit_id = @p0 or g.ust_kayit_id = @p0)
                    union all
                    select u.uygulanan, coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), ''),
                           case u.durum when 2 then 'Doz verildi' when 3 then 'Doz atlandı' when 4 then 'Hasta reddetti' else 'Doz' end,
                           concat_ws(' · ', 'planlanan ' || to_char(u.planlanan at time zone 'Europe/Istanbul', 'DD.MM HH24:MI'),
                                     case when u.elle_dogrulandi = 1 then 'elle doğrulandı' end,
                                     nullif(u.atlama_nedeni, ''), nullif(u.gecikme_nedeni, ''))
                      from public.order_uygulama u left join public.taraf p on p.id = u.uygulayan_id
                     where u.order_id = @p0 and u.uygulanan is not null and u.durum in (2, 3, 4)
                ) x order by 1 desc limit 100
                """, null, [id, LogTabloYatisOrder, 1124],
                o => new { tarih = o.GetDateTime(0), kullanici = o.GetString(1), islem = o.GetString(2), bilgi = o.GetString(3) }, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // TEKRARLA / DOZ DEĞİŞTİR: order kopyalanır (başlangıç şimdi, süre korunur).
        //   Doz değiştirmede eski order DURDURULUR - aynı talimatın iki sürümü
        //   aynı anda aktif kalmasın, değişikliğin izi kalsın.
        grup.MapPost("/order/{id:int}/kopyala", async (int id, bool? durdur, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Ekle);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var yeni = await b.TekDegerAsync<int?>("""
                insert into public.yatis_order
                    (sube_id, yatis_id, tur, ilac_id, hizmet_id, ad, doz, birim, yol, siklik, saatler,
                     baslangic, bitis, hekim_id, sozel_order, durum, aciklama,
                     stat, prn, prn_kosul, infuzyon_dk, seyreltme, ekleyen, ekleme_tarihi)
                select sube_id, yatis_id, tur, ilac_id, hizmet_id, ad, doz, birim, yol, siklik, saatler,
                       now(), case when bitis is null then null else now() + (bitis - baslangic) end,
                       hekim_id, 0, 1, aciklama, 0, prn, prn_kosul, infuzyon_dk, seyreltme, @p1, now()
                  from public.yatis_order where id = @p0
                returning id
                """, islem, [id, baglam.KullaniciId], iptal) ?? throw GentegreHatasi.Bulunamadi("Order bulunamadı.");
            if (durdur == true)
            {
                await b.CalistirAsync("""
                    update public.yatis_order set durum = 2, degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0 and durum = 1
                    """, islem, [id, baglam.KullaniciId], iptal);
                await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloYatisOrder, id, baglam.KullaniciId, baglam.SubeId,
                    baglam.Ip, new { durum = "Durduruldu", neden = "Doz değiştirildi", yeniOrder = yeni }, iptal: iptal);
            }
            await log.YazAsync(b, islem, LogIslemi.Ekle, LogTabloYatisOrder, yeni, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { kaynakOrder = id, islem = durdur == true ? "Doz değiştir" : "Tekrarla" }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = yeni, izlemeNo = baglam.IzlemeNo });
        });
    }
}
