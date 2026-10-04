using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ARIZA BİLDİR / TAKİP (954, mockup Ekranlar/Taleplerim/ariza_bildir.html).
///
/// Bildiren kişi Taleplerim'den: demirbaş arar, aynı arıza açıksa ikinci kayıt
/// yerine TAKİPÇİ olur ("ben de bildiriyorum"), akışı izler, not yazar,
/// çözülünce ONAYLAR ya da YENİDEN AÇAR.
///
/// ERİŞİM: talep eden ya da takipçi kendi kaydında yetki istemez; ekip
/// (yetki <c>ariza</c>) hepsini görür. Başkasının kaydı = bulunamadı
/// (varlık sızdırılmaz).
/// </summary>
public static partial class AriziUclari
{
    public sealed record NotIstegi(string Metin);
    public sealed record NedenIstegi(string? Neden);
    public sealed record UyeIstegi(int KullaniciId, bool Nobetci);

    private const short KaynakAriza = 45;   // bildirim.kaynak_tur: arıza talebi

    /// <summary>Kişinin bu talepteki yeri: 1 talep eden · 2 takipçi · 3 ekip.</summary>
    private static async Task<(short Rol, short Durum)> ErisimAsync(
        NpgsqlConnection b, int id, IstekBaglami baglam, CancellationToken iptal)
    {
        var s = await b.TekAsync("""
            select t.durum,
                   (t.talep_eden = @p1) as sahip,
                   exists (select 1 from public.ariza_talep_takipci k
                            where k.talep_id = t.id and k.taraf_id = @p1) as takipci
              from public.ariza_talep t where t.id = @p0
            """, null, [id, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (s is null) throw GentegreHatasi.Bulunamadi("Arıza kaydı bulunamadı.");
        var durum = Convert.ToInt16(s["durum"]);
        if (s["sahip"] is true) return (1, durum);
        if (s["takipci"] is true) return (2, durum);
        if (baglam.Yetkiler.Var("ariza", Islem.Gor)) return (3, durum);
        var uye = await b.TekDegerAsync<bool>("""
            select exists (select 1 from public.ariza_talep t
                            join public.ariza_ekip_uye u on u.ekip = t.ekip
                                 and u.kullanici_id = @p1 and u.aktif = 1
                           where t.id = @p0)
            """, null, [id, baglam.KullaniciId], iptal);
        if (uye) return (3, durum);
        throw GentegreHatasi.Bulunamadi("Arıza kaydı bulunamadı.");
    }

    /// <summary>
    /// EKİP İŞLEMİ (devral / ata / çöz / kapat): rolünde `ariza` değiştirme
    /// yetkisi olan ya da talebin ekibine ÜYE olan (955) kişi. Üyelik yetkiden
    /// ayrı: Biyomedikal teknisyeni bütün arıza modülünü yönetmeden kendi
    /// ekibinin işini alabilmeli.
    /// </summary>
    private static async Task EkipIsteAsync(NpgsqlConnection b, int id, IstekBaglami baglam,
                                            CancellationToken iptal)
    {
        baglam.YazmaIste();
        if (baglam.Yetkiler.Var("ariza", Islem.Degistir)) return;
        var uye = await b.TekDegerAsync<bool>("""
            select exists (select 1 from public.ariza_talep t
                            join public.ariza_ekip_uye u on u.ekip = t.ekip
                                 and u.kullanici_id = @p1 and u.aktif = 1
                           where t.id = @p0)
            """, null, [id, baglam.KullaniciId], iptal);
        if (!uye) throw GentegreHatasi.Yasak("Bu arıza sizin ekibinize ait değil.");
    }

    /// <summary>Kişi bir ekibe üye mi (yetkisi olmasa da "Bana gelenler" görür).</summary>
    private static Task<bool> UyeMiAsync(NpgsqlConnection b, int kullaniciId, CancellationToken iptal)
        => b.TekDegerAsync<bool>(
            "select exists (select 1 from public.ariza_ekip_uye where kullanici_id = @p0 and aktif = 1)",
            null, [kullaniciId], iptal);

    private static Task HareketYazAsync(NpgsqlConnection b, int id, short tur, string metin,
                                        int yazan, CancellationToken iptal)
        => b.CalistirAsync("""
            insert into public.ariza_talep_hareket (talep_id, tur, metin, yazan)
            values (@p0, @p1, left(@p2, 1000), @p3)
            """, null, [id, tur, metin, yazan], iptal);

    /// <summary>
    /// ACİL: ekibe (rolünde <c>ariza</c> değiştirme yetkisi olan aktif
    /// kullanıcılar) anında haber. SMS önce - acil işte e-posta geç okunur.
    /// Bildirim yazılamazsa kayıt düşmez; günlüğe yazılır.
    /// </summary>
    private static async Task<int> AcilBildirAsync(NpgsqlConnection b, BildirimDeposu bildirim,
        ILogger gunluk, int id, IstekBaglami baglam, CancellationToken iptal)
    {
        try
        {
            var t = await b.TekAsync("""
                select v.talep_no, v.kategori_adi, v.konum, v.aciklama, v.talep_eden_adi, v.telefon
                  from public.v_ariza_talep v where v.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            if (t is null) return 0;
            var alicilar = await b.ListeAsync("""
                select k.id, coalesce(k.cep_tel, ''), coalesce(k.eposta, ''),
                       coalesce(nullif(public.fn_taraf_ad(tr.unvan, tr.ad, tr.soyad)::varchar(120), ''), k.kod)
                  from public.taraf_kullanici k
                  left join public.taraf tr on tr.id = k.id
                 where k.id <> @p0
                   and k.id in (select public.fn_ariza_ekip_alicilari(
                                    (select t.ekip from public.ariza_talep t where t.id = @p1), true))
                """, null, [baglam.KullaniciId, id],
                r => (Id: r.GetInt32(0), Cep: r.GetString(1), Eposta: r.GetString(2), Ad: r.GetString(3)), iptal);

            var d = new Dictionary<string, string>
            {
                ["talepNo"] = t["talep_no"] as string ?? "",
                ["kategori"] = t["kategori_adi"] as string ?? "",
                ["konum"] = t["konum"] as string ?? "",
                ["aciklama"] = t["aciklama"] as string ?? "",
                ["talepEden"] = t["talep_eden_adi"] as string ?? "",
                ["telefon"] = t["telefon"] as string ?? "",
            };
            var n = 0;
            foreach (var a in alicilar)
            {
                var sms = a.Cep.Length > 0;
                if (!sms && a.Eposta.Length == 0) continue;
                var id2 = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                    SablonKodu: sms ? "ariza.acil" : "ariza.acil.eposta",
                    Kanal: sms ? BildirimKanali.Sms : BildirimKanali.Eposta,
                    Alici: sms ? a.Cep : a.Eposta,
                    Degiskenler: new Dictionary<string, string>(d) { ["alici"] = a.Ad },
                    KullaniciId: a.Id, KaynakTur: KaynakAriza, KaynakId: id, Oncelik: 1),
                    baglam.KullaniciId, baglam.SubeId, iptal);
                if (id2 is not null) n++;
            }
            if (n == 0)
                gunluk.LogWarning("Acil arıza {Id}: bildirilecek ekip üyesi yok (cep/e-posta tanımlı değil).", id);
            return n;
        }
        catch (Exception h)
        {
            gunluk.LogWarning(h, "Acil arıza {Id} bildirimi yazılamadı.", id);
            return 0;
        }
    }

    private static void ArizaTakipUclariniEkle(RouteGroupBuilder grup)
    {
        // DEMİRBAŞ ARA / OKUT: kod, barkod, seri no ya da ad. Bildiren kişinin
        //   demirbaş yetkisi yok - yalnız seçim için gereken alanlar döner.
        grup.MapGet("/demirbas-ara", async (string? q, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza.talep", Islem.Gor);
            var a = (q ?? "").Trim();
            if (a.Length < 2) return Results.Ok(new { satirlar = Array.Empty<object>() });
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select d.id, d.kod, d.ad,
                       trim(both ' · ' from coalesce(dp.ad, '') || ' · ' || coalesce(lk.ad, '')) as konum
                  from public.demirbas d
                  left join public.departman dp on dp.id = d.departman_id
                  left join public.kod_liste ll on ll.kod = 'demirbas.lokasyon'
                  left join public.kod_deger lk on lk.liste_id = ll.id and lk.deger = d.lokasyon and lk.dil = 0
                 where (@p1::int = 0 or d.sube_id is null or d.sube_id = @p1)
                   and (d.kod ilike @p0 || '%' or coalesce(d.barkod, '') = @p2
                        or coalesce(d.seri_no, '') = @p2 or d.ad ilike '%' || @p0 || '%')
                 order by (d.kod ilike @p0 || '%' or coalesce(d.barkod, '') = @p2) desc, d.ad
                 limit 15
                """, null, [a, baglam.SubeId ?? 0, a],
                OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // BENZER AÇIK ARIZA: aynı demirbaş ya da (demirbaş yoksa) aynı konum +
        //   kategori. Mükerrer kayıt yerine "ben de bildiriyorum".
        grup.MapGet("/benzer", async (int? demirbasId, short? kategori, string? konum,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza.talep", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select v.id, v.talep_no as "talepNo", left(v.aciklama, 120) as aciklama,
                       v.durum, v.durum_adi as "durumAdi", v.sorumlu_adi as "sorumluAdi",
                       v.ekleme_tarihi as "eklemeTarihi",
                       (v.talep_eden = @p3 or exists (select 1 from public.ariza_talep_takipci k
                                                       where k.talep_id = v.id and k.taraf_id = @p3)) as "benimki"
                  from public.v_ariza_talep v
                 where v.durum in (1, 2, 3)
                   and ((@p0::int is not null and v.demirbas_id = @p0)
                        or (@p0::int is null and @p1::smallint is not null and v.kategori = @p1
                            and btrim(coalesce(@p2, '')) <> '' and lower(v.konum) = lower(btrim(@p2))))
                 order by v.ekleme_tarihi desc
                 limit 5
                """, null, [demirbasId, kategori, konum, baglam.KullaniciId],
                OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // BANA GELENLER (954, kullanıcı: "talep yaptığımız birim / kişinin hızlı
        //   ve pratik şekilde haberi olması ve aksiyon alabilmesi lazım"):
        //   ekip üyesi (yetki ariza) üst şerit 📨 panelinde ve Taleplerim'in
        //   "Bana gelenler" sekmesinde görür - kimseye atanmamış açık arızalar
        //   + bana atanmış olanlar. Başkasına atanmış iş burada kalabalık yapmaz
        //   (ekip listesinde durur). Acil ve eski önce.
        grup.MapGet("/gelen", async (VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            if (!baglam.Yetkiler.Var("ariza", Islem.Gor) && !await UyeMiAsync(b, baglam.KullaniciId, iptal))
                return Results.Ok(new { ekip = false, satirlar = Array.Empty<object>() });
            var satirlar = await b.ListeAsync("""
                select v.id, v.talep_no as "talepNo", v.kategori_adi as "kategoriAdi",
                       v.ekip_adi as "ekipAdi", v.konum, left(v.aciklama, 140) as aciklama,
                       v.oncelik, v.oncelik_adi as "oncelikAdi", v.durum, v.durum_adi as "durumAdi",
                       v.talep_eden_adi as "talepEdenAdi", v.telefon, v.sorumlu_id as "sorumluId",
                       v.sorumlu_adi as "sorumluAdi", v.ekleme_tarihi as "eklemeTarihi",
                       coalesce(v.sorumlu_id = @p0, false) as "benim"
                  from public.v_ariza_talep v
                 where v.durum in (1, 2, 3)
                   and (v.sorumlu_id = @p0
                        or (v.sorumlu_id is null
                            and @p0 in (select public.fn_ariza_ekip_alicilari(v.ekip::smallint))))
                   and (@p1::int = 0 or v.sube_id = @p1)
                 order by v.oncelik desc, v.ekleme_tarihi
                 limit 100
                """, null, [baglam.KullaniciId, baglam.SubeId ?? 0],
                OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { ekip = true, satirlar });
        });

        // ATANABİLİR: talebin ekibine iş düşen kişiler (üyeler; üyesiz ekipte
        //   arıza yetkilileri).
        grup.MapGet("/{id:int}/atanabilir", async (int id, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            await EkipIsteAsync(b, id, baglam, iptal);
            var satirlar = await b.ListeAsync("""
                select k.id, coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod) as ad,
                       coalesce(u.nobetci, 0) as nobetci
                  from public.taraf_kullanici k
                  left join public.taraf t on t.id = k.id
                  left join public.ariza_talep a on a.id = @p0
                  left join public.ariza_ekip_uye u on u.ekip = a.ekip and u.kullanici_id = k.id
                 where k.id in (select public.fn_ariza_ekip_alicilari(
                                    (select x.ekip from public.ariza_talep x where x.id = @p0)))
                 order by 2
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // ---------------------------------------------- EKİP ÜYELERİ (955) --
        //   Ayarlar › Arıza ekipleri. Yetki: ariza (değiştir).
        grup.MapGet("/ekipler", async (VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ekipler = await b.ListeAsync("""
                select d.deger as ekip, d.ad,
                       (select string_agg(kd.ad, ', ' order by kd.deger)
                          from public.ariza_kategori_ekip e
                          join public.kod_liste kl on kl.kod = 'ariza.kategori'
                          join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = e.kategori and kd.dil = 0
                         where e.ekip = d.deger) as kategoriler,
                       (select count(*) from public.ariza_talep t where t.ekip = d.deger and t.durum in (1, 2, 3)) as acik
                  from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                 where l.kod = 'ariza.ekip' and d.dil = 0 and d.deger > 0
                 order by d.deger
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            var uyeler = await b.ListeAsync("""
                select u.ekip, u.kullanici_id as "kullaniciId", u.nobetci, u.aktif,
                       coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod) as ad,
                       coalesce(k.cep_tel, '') <> '' as "cepVar"
                  from public.ariza_ekip_uye u
                  join public.taraf_kullanici k on k.id = u.kullanici_id
                  left join public.taraf t on t.id = k.id
                 order by u.ekip, u.nobetci desc, 5
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { ekipler, uyeler });
        });

        grup.MapGet("/kullanici-ara", async (string? q, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Degistir);
            var a = (q ?? "").Trim();
            if (a.Length < 2) return Results.Ok(new { satirlar = Array.Empty<object>() });
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select k.id, coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod) as ad, k.kod
                  from public.taraf_kullanici k left join public.taraf t on t.id = k.id
                 where k.aktif = 1
                   and (k.kod ilike @p0 || '%' or (coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')) ilike '%' || @p0 || '%')
                 order by 2 limit 15
                """, null, [a], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        grup.MapPost("/ekip/{ekip:int}/uye", async (int ekip, UyeIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("""
                insert into public.ariza_ekip_uye (ekip, kullanici_id, nobetci, aktif, ekleyen)
                values (@p0::smallint, @p1, @p2::smallint, 1, @p3)
                on conflict (ekip, kullanici_id) do update set nobetci = excluded.nobetci, aktif = 1
                """, null, [ekip, istek.KullaniciId, istek.Nobetci ? 1 : 0, baglam.KullaniciId], iptal);
            return Results.Ok(new { ekip, istek.KullaniciId });
        });

        grup.MapDelete("/ekip/{ekip:int}/uye/{kullaniciId:int}", async (int ekip, int kullaniciId,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("delete from public.ariza_ekip_uye where ekip = @p0::smallint and kullanici_id = @p1",
                null, [ekip, kullaniciId], iptal);
            return Results.Ok(new { ekip, kullaniciId });
        });

        // TAKİP: talep + akış + takipçiler (sahip / takipçi / ekip).
        grup.MapGet("/{id:int}/takip", async (int id, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var (rol, _) = await ErisimAsync(b, id, baglam, iptal);
            var talep = await b.TekAsync("""
                select v.id, v.talep_no as "talepNo", v.kategori, v.kategori_adi as "kategoriAdi",
                       v.ekip_adi as "ekipAdi", v.konum, v.aciklama, v.oncelik, v.oncelik_adi as "oncelikAdi",
                       v.demirbas_id as "demirbasId", v.demirbas_adi as "demirbasAdi",
                       (select d.kod from public.demirbas d where d.id = v.demirbas_id) as "demirbasKod",
                       v.talep_eden as "talepEden", v.talep_eden_adi as "talepEdenAdi",
                       v.sorumlu_id as "sorumluId", v.sorumlu_adi as "sorumluAdi",
                       v.durum, v.durum_adi as "durumAdi", v.cozum_notu as "cozumNotu",
                       v.cozum_tarihi as "cozumTarihi", v.kapanis_tarihi as "kapanisTarihi",
                       v.telefon, v.ekleme_tarihi as "eklemeTarihi"
                  from public.v_ariza_talep v where v.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var hareketler = await b.ListeAsync("""
                select h.id, h.tur, h.metin, h.tarih,
                       case when h.yazan = 0 then 'sistem'
                            else coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') end as yazan
                  from public.ariza_talep_hareket h
                  left join public.taraf t on t.id = h.yazan
                 where h.talep_id = @p0 order by h.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var takipciler = await b.ListeAsync("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad
                  from public.ariza_talep_takipci k join public.taraf t on t.id = k.taraf_id
                 where k.talep_id = @p0 order by k.ekleme_tarihi
                """, null, [id], r => r.GetString(0), iptal);
            return Results.Ok(new { talep, hareketler, takipciler, rol, izlemeNo = baglam.IzlemeNo });
        });

        // BEN DE BİLDİRİYORUM: ikinci kayıt açılmaz; kişi takipçi olur, notu
        //   akışa düşer. Kendi kaydına takipçi olunmaz.
        grup.MapPost("/{id:int}/ben-de", async (int id, NedenIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza.talep", Islem.Ekle);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var t = await b.TekAsync("select durum, talep_eden from public.ariza_talep where id = @p0",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Arıza kaydı bulunamadı.");
            if (Convert.ToInt16(t["durum"]) is 0 or 4 or 5)
                throw GentegreHatasi.IsKurali("Bu arıza kapanmış - yeni kayıt açın.");
            if (Convert.ToInt32(t["talep_eden"]) == baglam.KullaniciId)
                throw GentegreHatasi.IsKurali("Bu arızayı zaten siz bildirdiniz.");
            var n = await b.CalistirAsync("""
                insert into public.ariza_talep_takipci (talep_id, taraf_id) values (@p0, @p1)
                on conflict do nothing
                """, null, [id, baglam.KullaniciId], iptal);
            await HareketYazAsync(b, id, 10, istek.Neden?.Trim() ?? "", baglam.KullaniciId, iptal);
            return Results.Ok(new { id, yeni = n > 0, mesaj = "Arıza takibinize eklendi.", izlemeNo = baglam.IzlemeNo });
        });

        // NOT: sahip, takipçi ya da ekip.
        grup.MapPost("/{id:int}/not", async (int id, NotIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YazmaIste();
            if (string.IsNullOrWhiteSpace(istek.Metin)) throw GentegreHatasi.IsKurali("Not boş olamaz.");
            await using var b = await veri.AcAsync(iptal);
            await ErisimAsync(b, id, baglam, iptal);
            await HareketYazAsync(b, id, 9, istek.Metin.Trim(), baglam.KullaniciId, iptal);
            return Results.Ok(new { id, izlemeNo = baglam.IzlemeNo });
        });

        // ONAYLA: talep eden "çözüldü"yü kabul eder → Kapandı.
        grup.MapPost("/{id:int}/onayla", async (int id, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var (rol, durum) = await ErisimAsync(b, id, baglam, iptal);
            if (rol != 1) throw GentegreHatasi.IsKurali("Çözümü yalnız bildiren kişi onaylar.");
            if (durum != 4) throw GentegreHatasi.IsKurali("Talep çözüldü durumunda değil.");
            await b.CalistirAsync("""
                update public.ariza_talep
                   set durum = 5, kapanis_tarihi = now(), degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 4
                """, null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { id, durum = 5, izlemeNo = baglam.IzlemeNo });
        });

        // YENİDEN AÇ: "düzelmedi" - sorumlusu varsa İşlemde, yoksa Açık.
        grup.MapPost("/{id:int}/yeniden-ac", async (int id, NedenIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YazmaIste();
            if (string.IsNullOrWhiteSpace(istek.Neden)) throw GentegreHatasi.IsKurali("Ne düzelmedi, kısaca yazın.");
            await using var b = await veri.AcAsync(iptal);
            var (rol, durum) = await ErisimAsync(b, id, baglam, iptal);
            if (rol != 1) throw GentegreHatasi.IsKurali("Talebi yalnız bildiren kişi yeniden açar.");
            if (durum != 4) throw GentegreHatasi.IsKurali("Yalnız çözüldü durumundaki talep yeniden açılır.");
            await b.CalistirAsync("""
                update public.ariza_talep
                   set durum = case when sorumlu_id is null then 1 else 3 end,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 4
                """, null, [id, baglam.KullaniciId], iptal);
            await HareketYazAsync(b, id, 9, istek.Neden.Trim(), baglam.KullaniciId, iptal);
            return Results.Ok(new { id, izlemeNo = baglam.IzlemeNo });
        });

        // VAZGEÇ: talep eden, iş bitmeden iptal eder.
        grup.MapPost("/{id:int}/vazgec", async (int id, NedenIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var (rol, durum) = await ErisimAsync(b, id, baglam, iptal);
            if (rol != 1) throw GentegreHatasi.IsKurali("Talebi yalnız bildiren kişi iptal eder.");
            if (durum is not (1 or 2 or 3)) throw GentegreHatasi.IsKurali("Çözülmüş ya da kapanmış talep iptal edilemez.");
            await b.CalistirAsync("""
                update public.ariza_talep set durum = 0, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum in (1, 2, 3)
                """, null, [id, baglam.KullaniciId], iptal);
            if (!string.IsNullOrWhiteSpace(istek.Neden))
                await HareketYazAsync(b, id, 9, istek.Neden.Trim(), baglam.KullaniciId, iptal);
            return Results.Ok(new { id, durum = 0, izlemeNo = baglam.IzlemeNo });
        });
    }
}
