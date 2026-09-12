using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// EKRAN ÖZETİ, muayene sonuçları ve etiket.
///
/// Uclar LabUclari.cs dosyasindan ayrildi: tek dosyada 2103 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class LabUclari
{
    private static void OzetVeSonuclarEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------ ekran özeti ---

        // GET /api/lab/ozet - Sonuç Onay ekranının ÜST ŞERİDİ
        //   (mockup Ekranlar/Lab/lab_biyokimya_sonuc_onay.html ".ozet").
        //
        // <b>Neden tek uç:</b> altı sayaç için altı istek atmak hem yavaş hem
        // de şeridin yarısı dolu yarısı boş görünür. Radyoloji panosuyla (320)
        // aynı desen.
        //
        // <b>Sayaçlar İŞE GİRİŞ KAPISIDIR</b>, süs değil: her biri listenin
        // bir çipine karşılık gelir; tıklanınca o süzgeç açılır.
        grup.MapGet("/ozet", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var sayaclar = await baglanti.TekAsync("""
                select
                  -- CIHAZDA: numunesi kabul edilmiş, çalışılan tetkik.
                  (select count(*) from public.lab_istem_satir s
                     join public.lab_istem i on i.id = s.istem_id
                    where s.durum = 2
                      and (@p0::int is null or i.sube_id = @p0))       as "cihazda",
                  -- ONAY BEKLEYEN: girilmiş ama uzman onayı görmemiş sonuç
                  --   (1 girildi · 2 teknik onaylı). İptal (4) sayılmaz.
                  (select count(*) from public.lab_sonuc ls
                    where ls.durum in (1, 2)
                      and (@p0::int is null or ls.sube_id = @p0))      as "onayBekleyen",
                  -- BUGÜN ONAYLANAN ve bunların kaçı OTO-ONAY: oran, kural
                  --   motorunun ne kadar iş çıkardığını söyler.
                  (select count(*) from public.lab_sonuc ls
                    where ls.onay_zamani::date = current_date
                      and (@p0::int is null or ls.sube_id = @p0))      as "bugunOnaylanan",
                  (select count(*) from public.lab_sonuc ls
                    where ls.onay_zamani::date = current_date and ls.oto_onay = 1
                      and (@p0::int is null or ls.sube_id = @p0))      as "bugunOtoOnay",
                  -- PANİK AÇIK: bildirilmiş ama okuma-geri TEYİDİ alınmamış
                  --   ya da hiç bildirilmemiş panik değer. İkisi de açıktır.
                  (select count(*) from public.lab_sonuc ls
                    where ls.panik = 1 and ls.durum <> 4
                      and not exists (select 1 from public.lab_panik_bildirim b
                                       where b.sonuc_id = ls.id
                                         and b.teyit_zamani is not null)
                      and (@p0::int is null or ls.sube_id = @p0))      as "panikAcik",
                  -- TAT AŞIMI: hedef bitişi geçmiş, hâlâ onaylanmamış istem.
                  (select count(*) from public.lab_istem i
                    where i.hedef_bitis is not null and i.hedef_bitis < now()
                      and i.durum between 1 and 4
                      and (@p0::int is null or i.sube_id = @p0))       as "tatAsimi",
                  -- TEKRAR NUMUNE: serum indeksi ya da dış lab reddi yüzünden
                  --   hastadan yeniden numune bekleyen tetkik.
                  (select count(*) from public.lab_istem_satir s
                     join public.lab_istem i on i.id = s.istem_id
                    where s.durum = 6
                      and (@p0::int is null or i.sube_id = @p0))       as "tekrarNumune"
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // CIHAZ DURUMU: mockup'taki yeşil/kırmızı rozetler. Cihaz sessizce
            //   durduğunda sonuçlar gelmez ve bu ekranda "onay bekleyen
            //   azaldı" gibi görünür - bağı burada kuruyoruz.
            var cihazlar = await baglanti.ListeAsync("""
                select c.kod, c.ad, c.durum, c.son_mesaj as "sonMesaj",
                       c.son_hata as "sonHata",
                       (select count(*) from public.cihaz_mesaj m
                         where m.cihaz_id = c.id
                           and m.ekleme_tarihi::date = current_date) as "bugunMesaj"
                  from public.cihaz c
                 where c.tur = 1 and c.durum = 0
                   and (@p0::int is null or c.sube_id = @p0)
                 order by c.kod
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { sayaclar, cihazlar, izlemeNo = baglam.IzlemeNo });
        });

        // --------------------------------------------- muayene istem & sonuç ---

        // GET /api/lab/muayene/{id}/sonuclar - muayene kartının
        //   "İstem & Sonuçlar" sekmesi.
        //
        // <b>Bağ satırı yetmez.</b> muayene_istem yalnız "şu istem açıldı"
        // der; hekimin görmesi gereken SONUCUN KENDİSİDİR. Sekmede yalnız
        // bağ gösterilirse hekim her sonuç için laboratuvar ekranına gitmek
        // zorunda kalır - muayene sırasında olmayacak bir şey.
        //
        // <b>Aynı başvurunun laboratuvardan açılmış istemleri de gelir</b>:
        // muayeneden değil bankodan istenen tetkik de o hastanın o
        // başvurusuna aittir ve hekimi ilgilendirir.
        grup.MapGet("/muayene/{id:int}/sonuclar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            var m = await veri.TekAsync("""
                select m.id, m.belge_id, m.taraf_id, m.durum
                  from public.muayene m where m.id = @p0
                """, [id],
                o => new { Id = o.GetInt32(0),
                           BelgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                           HastaId = o.GetInt32(2), Durum = o.GetInt16(3) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            // Bağ satırları: hekimin "gördüm" işareti bunlarda durur.
            var baglar = await veri.ListeAsync("""
                select mi.id, mi.tur, mi.hedef_tablo as "hedefTablo", mi.hedef_id as "hedefId",
                       mi.aciliyet, mi.istem_zamani as "istemZamani",
                       mi.sonuc_durum as "sonucDurum", mi.sonuc_zamani as "sonucZamani",
                       mi.hekim_gordu as "hekimGordu"
                  from public.muayene_istem mi
                 where mi.muayene_id = @p0
                 order by mi.istem_zamani desc, mi.id desc
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // LAB İSTEMLERİ: muayeneden açılanlar + aynı başvurunun diğerleri.
            var istemler = await veri.ListeAsync("""
                select i.id, i.istem_no as "istemNo", i.istem_tarihi as "istemTarihi",
                       i.durum, i.oncelik, i.klinik_bilgi as "klinikBilgi",
                       i.hedef_bitis as "hedefBitis",
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum <> 0) as tetkik,
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum = 5) as onayli,
                       (select mi.id from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'lab_istem'
                           and mi.hedef_id = i.id limit 1) as "bagId",
                       (select mi.hekim_gordu from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'lab_istem'
                           and mi.hedef_id = i.id limit 1) as "hekimGordu"
                  from public.lab_istem i
                 where i.durum <> 9
                   and (i.belge_id = @p1
                        or exists (select 1 from public.muayene_istem mi
                                    where mi.muayene_id = @p0
                                      and mi.hedef_tablo = 'lab_istem'
                                      and mi.hedef_id = i.id))
                 order by i.istem_tarihi desc, i.id desc
                """, [id, m.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SONUÇ SATIRLARI: yalnız ONAYLI olanlar. Onaylanmamış değeri
            //   hekime göstermek, laboratuvarın henüz doğrulamadığı bir
            //   sayıya göre tedavi başlatılmasına yol açar.
            var sonuclar = await veri.ListeAsync("""
                select s.istem_id as "istemId", t.kod, t.ad, t.bolum, t.tur as "tetkikTur",
                       ls.deger_metin as deger, ls.birim, ls.bayrak, ls.panik,
                       ls.delta_uyari as "deltaUyari", ls.referans_alt as "referansAlt",
                       ls.referans_ust as "referansUst", ls.referans_metin as "referansMetin",
                       ls.olcum_zamani as "olcumZamani", ls.onay_zamani as "onayZamani",
                       ls.yorum, s.durum as "satirDurum"
                  from public.lab_istem_satir s
                  join public.lab_tetkik t on t.id = s.tetkik_id
                  left join lateral (
                        select * from public.lab_sonuc x
                         where x.istem_satir_id = s.id and x.durum = 3
                         order by x.id desc limit 1) ls on true
                 where s.durum <> 0
                   and s.istem_id in (
                        select i2.id from public.lab_istem i2
                         where i2.durum <> 9
                           and (i2.belge_id = @p1
                                or exists (select 1 from public.muayene_istem mi
                                            where mi.muayene_id = @p0
                                              and mi.hedef_tablo = 'lab_istem'
                                              and mi.hedef_id = i2.id)))
                 order by s.istem_id desc, t.bolum, s.sira
                """, [id, m.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Kültür ve genetik ÖZETİ: ayrıntı laboratuvar ekranında, hekime
            //   sonuç cümlesi ve raporlanan bulgular yeter.
            var kulturler = await veri.ListeAsync("""
                select k.id, k.istem_id as "istemId", t.ad as tetkik, k.durum,
                       public.fn_lab_kultur_ozet(k.id) as ozet,
                       k.on_rapor as "onRapor", k.uzman_yorum as "uzmanYorum",
                       k.kritik, k.onay_zamani as "onayZamani",
                       (select count(*) from public.lab_antibiyogram g
                          join public.lab_kultur_ureme u on u.id = g.ureme_id
                         where u.kultur_id = k.id and g.bildir = 1) as "abSayisi"
                  from public.lab_kultur k
                  join public.lab_tetkik t on t.id = k.tetkik_id
                 where k.durum <> 0
                   and k.istem_id in (
                        select i2.id from public.lab_istem i2
                         where i2.belge_id = @p1
                            or exists (select 1 from public.muayene_istem mi
                                        where mi.muayene_id = @p0
                                          and mi.hedef_tablo = 'lab_istem'
                                          and mi.hedef_id = i2.id))
                 order by k.id desc
                """, [id, m.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var vakalar = await veri.ListeAsync("""
                select g.id, g.istem_id as "istemId", g.vaka_no as "vakaNo",
                       coalesce(p.ad, t.ad) as test, g.durum,
                       public.fn_lab_genetik_ozet(g.id) as ozet,
                       g.uzman_yorum as "uzmanYorum", g.oneriler,
                       g.onay_zamani as "onayZamani",
                       (select count(*) from public.lab_varyant v
                         where v.vaka_id = g.id and v.raporla = 1) as "varyantSayisi"
                  from public.lab_genetik_vaka g
                  join public.lab_tetkik t on t.id = g.tetkik_id
                  left join public.lab_genetik_panel p on p.id = g.panel_id
                 where g.durum <> 0
                   and g.istem_id in (
                        select i2.id from public.lab_istem i2
                         where i2.belge_id = @p1
                            or exists (select 1 from public.muayene_istem mi
                                        where mi.muayene_id = @p0
                                          and mi.hedef_tablo = 'lab_istem'
                                          and mi.hedef_id = i2.id))
                 order by g.id desc
                """, [id, m.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // RADYOLOJİ: aynı sekmede görünür - hekim için "istem" tek
            //   kavramdır, modülü değil sonucu arar.
            var radyoloji = await veri.ListeAsync("""
                select ri.id, hz.ad as tetkik, ri.durum, ri.cekim_tarihi as "cekimTarihi",
                       coalesce(r.rapor_no, '') as "raporNo", r.onay_tarihi as "onayTarihi",
                       coalesce((select string_agg(b.metin, ' ' order by b.sira)
                                   from public.radyoloji_rapor_bolum b
                                  where b.rapor_id = r.id
                                    and lower(b.baslik) like '%sonu%'), '') as sonuc,
                       (select mi.id from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'radyoloji_istem'
                           and mi.hedef_id = ri.id limit 1) as "bagId",
                       (select mi.hekim_gordu from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'radyoloji_istem'
                           and mi.hedef_id = ri.id limit 1) as "hekimGordu"
                  from public.radyoloji_istem ri
                  left join public.hizmet hz on hz.id = ri.hizmet_id
                  left join public.radyoloji_rapor r
                         on r.istem_id = ri.id and r.ust_rapor_id is null
                 where ri.belge_id = @p1
                    or exists (select 1 from public.muayene_istem mi
                                where mi.muayene_id = @p0
                                  and mi.hedef_tablo = 'radyoloji_istem'
                                  and mi.hedef_id = ri.id)
                 order by ri.id desc
                """, [id, m.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { muayeneId = id, belgeId = m.BelgeId, baglar,
                                    istemler, sonuclar, kulturler, vakalar, radyoloji,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ----------------------------------------------------------- etiket ---

        // GET /api/lab/etiket?istemId=... | numuneId=...
        //
        // TÜP ETİKETİ: kan alma bankosunun bastığı fiziksel etiket. Barkod
        // numunenin kimliğidir; cihaz da, kabul ekranı da onu okur.
        //
        // <b>Etikette hasta adı KISALTILIR</b> (35 mm'lik tüp etiketine tam
        // ad sığmaz) ama yaş ve cinsiyet KALIR: yanlış tüpü fark etmenin en
        // hızlı yolu budur. Doğum tarihi de gider - aynı adlı iki hasta
        // laboratuvarın klasik kazasıdır.
        grup.MapGet("/etiket", async (
            int? istemId, int? numuneId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Gor);

            if (istemId is not > 0 && numuneId is not > 0)
                throw GentegreHatasi.Dogrulama("İstem ya da numune belirtilmeli.",
                    [new("istemId", "İstem ya da numune id'si verin.")]);

            var etiketler = await veri.ListeAsync("""
                select n.id, n.barkod, n.numune_tipi as "numuneTipi",
                       n.tup_tipi as "tupTipi", n.durum, n.alim_zamani as "alimZamani",
                       i.id as "istemId", i.istem_no as "istemNo",
                       i.istem_tarihi as "istemTarihi", i.oncelik,
                       i.klinik_bilgi as "klinikBilgi",
                       h.id as "hastaId",
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan) as hasta,
                       coalesce(h.kod, '') as "hastaNo",
                       hs.dogum_tarihi as "dogumTarihi",
                       coalesce(hs.cinsiyet, 0) as cinsiyet,
                       coalesce(b.belge_no, '') as protokol,
                       coalesce(p.unvan, '') as hekim,
                       -- Tüpteki tetkikler: teknisyen "bu tüpe ne çalışılacak"
                       --   sorusunu etiketten cevaplayabilmeli.
                       coalesce((select string_agg(t2.kod, ', ' order by s2.sira)
                                   from public.lab_istem_satir s2
                                   join public.lab_tetkik t2 on t2.id = s2.tetkik_id
                                  where s2.numune_id = n.id and s2.durum <> 0), '') as tetkikler,
                       coalesce((select string_agg(distinct
                                    case t3.bolum when 2 then 'Hematoloji'
                                         when 3 then 'Hormon' when 4 then 'Mikrobiyoloji'
                                         when 5 then 'Seroloji' when 6 then 'Koagülasyon'
                                         when 7 then 'İdrar' when 9 then 'Diğer'
                                         else 'Biyokimya' end, ' · ')
                                   from public.lab_istem_satir s3
                                   join public.lab_tetkik t3 on t3.id = s3.tetkik_id
                                  where s3.numune_id = n.id and s3.durum <> 0), '') as bolumler,
                       -- HASTA HAZIRLIĞI (açlık vb.) etikette değil, ekranda
                       --   uyarı olarak gösterilir; tüpe basmak yer kaplar.
                       coalesce((select string_agg(distinct t4.hazirlik_notu, ' · ')
                                   from public.lab_istem_satir s4
                                   join public.lab_tetkik t4 on t4.id = s4.tetkik_id
                                  where s4.numune_id = n.id and s4.durum <> 0
                                    and t4.hazirlik_notu <> ''), '') as hazirlik
                  from public.lab_numune n
                  join public.lab_istem i on i.id = n.istem_id
                  join public.taraf h on h.id = n.hasta_id
                  left join public.taraf_hasta hs on hs.id = n.hasta_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.taraf p on p.id = i.personel_id
                 where (@p0::int is null or n.istem_id = @p0)
                   and (@p1::int is null or n.id = @p1)
                 order by n.id
                """, [istemId, numuneId], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (etiketler.Count == 0)
                throw GentegreHatasi.Bulunamadi("Etiket basılacak numune bulunamadı.");

            var kurum = await veri.TekAsync("""
                select coalesce(nullif(s.unvan, ''), s.ad) as unvan
                  from public.sube s
                 where s.id = coalesce(
                        (select n.sube_id from public.lab_numune n
                          where (@p0::int is null or n.istem_id = @p0)
                            and (@p1::int is null or n.id = @p1) limit 1),
                        (select id from public.sube where varsayilan = 1 limit 1))
                """, [istemId, numuneId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { etiketler, kurum, izlemeNo = baglam.IzlemeNo });
        });
    }
}
