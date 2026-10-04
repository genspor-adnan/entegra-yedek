using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DUYURULAR (957, mockup Ekranlar/Duyuru/duyuru.html).
///
/// OKUMAK yetki istemez: hedefteki (şube / bölüm / rol / kişi birleşimi ya da
/// herkes) her kullanıcı zilin "Duyurular" sekmesinde görür, okuma onayı
/// istenende "Okudum" der. YAYINLAMAK yetki <c>duyuru</c>; herkese ve SMS
/// ile gönderim ayrıca <c>duyuru.genel</c>.
///
/// METİN HTML'DİR ama herkesin ekranında çizilir - sunucuda beyaz listeyle
/// temizlenir (<see cref="HtmlTemizle"/>): yalnız biçim etiketleri ve http(s) /
/// mailto bağlantısı kalır; betik, stil, olay öznitelikleri düşer.
/// </summary>
public static partial class DuyuruUclari
{
    public sealed record HedefIstegi(short Tur, int Id);
    public sealed record DuyuruIstegi(int? Id, string Baslik, string? Metin, short Onem, bool Herkes,
        List<HedefIstegi>? Hedefler, DateTime? YayinBas, DateTime? YayinBit, bool OkumaOnayi,
        bool Sabit, bool YorumAcik, bool Eposta, bool Sms, string? Adina, string Islem);
    public sealed record SayIstegi(bool Herkes, List<HedefIstegi>? Hedefler);

    private const short KaynakDuyuru = 46;   // bildirim.kaynak_tur

    /// <summary>Yayında: durum 1, başlangıç geçmiş, bitiş gelmemiş.</summary>
    private const string YayindaSql =
        "d.durum = 1 and coalesce(d.yayin_bas, d.ekleme_tarihi) <= now() and (d.yayin_bit is null or d.yayin_bit > now())";

    public static void DuyuruUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/duyuru").WithTags("Duyuru").RequireAuthorization();

        // ------------------------------------------------ benim (zil) --
        grup.MapGet("/benim", async (VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync($$"""
                select d.id, d.baslik, left(public.fn_duyuru_duz(d.metin), 180) as ozet, d.onem,
                       d.sabit, d.okuma_onayi as "okumaOnayi", d.yorum_acik as "yorumAcik",
                       coalesce(nullif(d.adina, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as adina,
                       coalesce(d.yayin_bas, d.ekleme_tarihi) as "yayinBas", d.yayin_bit as "yayinBit",
                       d.guncelleme, d.surum,
                       (o.gordu is null or o.gordu_surum < d.surum) as yeni,
                       o.okudu is not null as okudu,
                       (o.okudu is not null and o.okudu_surum < d.surum) as "eskiSurumOkundu",
                       public.fn_duyuru_hedef_ozet(d.id) as "hedefOzet",
                       (select count(*) from public.dokuman k where k.kaynak = 'duyuru' and k.kaynak_id = d.id) as "ekSayisi"
                  from public.duyuru d
                  left join public.taraf t on t.id = d.yayinlayan
                  left join public.duyuru_okuma o on o.duyuru_id = d.id and o.kullanici_id = @p0
                 where {{YayindaSql}} and public.fn_duyuru_gorur(d.id, @p0)
                 order by d.sabit desc, d.onem desc, coalesce(d.yayin_bas, d.ekleme_tarihi) desc
                 limit 100
                """, null, [baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ tek duyuru --
        grup.MapGet("/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var yonetici = baglam.Yetkiler.Var("duyuru", Islem.Gor);
            if (!yonetici && !await GorurAsync(b, id, baglam.KullaniciId, iptal, yalnizYayinda: true))
                throw GentegreHatasi.Bulunamadi("Duyuru bulunamadı.");
            var d = await b.TekAsync("""
                select d.id, d.baslik, d.metin, d.onem, d.herkes, d.yayin_bas as "yayinBas",
                       d.yayin_bit as "yayinBit", d.okuma_onayi as "okumaOnayi", d.sabit,
                       d.yorum_acik as "yorumAcik", d.eposta, d.sms, d.durum, d.surum, d.guncelleme,
                       d.gonderim, d.adina, d.yayinlayan,
                       coalesce(nullif(d.adina, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as "adinaGorunen",
                       public.fn_duyuru_hedef_ozet(d.id) as "hedefOzet",
                       coalesce(d.yayin_bas, d.ekleme_tarihi) as "gorunenBas",
                       -- GÜNCELLENEN duyuruda eski sürümün onayı yetmez: yeniden "Okudum".
                       (o.okudu is not null and o.okudu_surum >= d.surum) as okudu
                  from public.duyuru d
                  left join public.taraf t on t.id = d.yayinlayan
                  left join public.duyuru_okuma o on o.duyuru_id = d.id and o.kullanici_id = @p1
                 where d.id = @p0
                """, null, [id, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Duyuru bulunamadı.");
            var hedefler = yonetici ? await HedeflerAsync(b, id, iptal) : [];
            return Results.Ok(new { duyuru = d, hedefler, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ gördü / okudum --
        grup.MapPost("/{id:int}/gordu", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            if (!await GorurAsync(b, id, baglam.KullaniciId, iptal, yalnizYayinda: true))
                throw GentegreHatasi.Bulunamadi("Duyuru bulunamadı.");
            await b.CalistirAsync("""
                insert into public.duyuru_okuma (duyuru_id, kullanici_id, gordu, gordu_surum)
                select @p0, @p1, now(), d.surum from public.duyuru d where d.id = @p0
                on conflict (duyuru_id, kullanici_id) do update
                   set gordu = now(), gordu_surum = excluded.gordu_surum
                """, null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { id });
        });

        grup.MapPost("/{id:int}/okudum", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            if (!await GorurAsync(b, id, baglam.KullaniciId, iptal, yalnizYayinda: true))
                throw GentegreHatasi.Bulunamadi("Duyuru bulunamadı.");
            await b.CalistirAsync("""
                insert into public.duyuru_okuma (duyuru_id, kullanici_id, gordu, gordu_surum, okudu, okudu_surum)
                select @p0, @p1, now(), d.surum, now(), d.surum from public.duyuru d where d.id = @p0
                on conflict (duyuru_id, kullanici_id) do update
                   set gordu = now(), gordu_surum = excluded.gordu_surum,
                       okudu = now(), okudu_surum = excluded.okudu_surum
                """, null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { id });
        });

        // ------------------------------------------------ yönetim listesi --
        grup.MapGet("/yonetim", async (VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                with a as (
                  select d.*, (select count(*) from public.fn_duyuru_alicilari(d.id)) as kisi
                    from public.duyuru d
                   where d.ekleme_tarihi > now() - interval '1 year' or d.durum = 0
                )
                select a.id, a.baslik, a.onem, a.sabit, a.okuma_onayi as "okumaOnayi", a.eposta, a.sms,
                       a.durum, a.surum, a.guncelleme, a.gonderim,
                       coalesce(a.yayin_bas, a.ekleme_tarihi) as "yayinBas", a.yayin_bit as "yayinBit",
                       case when a.durum = 0 then 'taslak'
                            when a.durum = 9 or (a.yayin_bit is not null and a.yayin_bit <= now()) then 'bitti'
                            when a.yayin_bas > now() then 'zamanlandi'
                            else 'yayinda' end as "durumKod",
                       public.fn_duyuru_hedef_ozet(a.id) as "hedefOzet", a.kisi,
                       (select count(*) from public.duyuru_okuma o where o.duyuru_id = a.id and o.okudu is not null) as okudu,
                       (select count(*) from public.duyuru_okuma o where o.duyuru_id = a.id and o.gordu is not null) as gordu,
                       coalesce(nullif(a.adina, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as adina
                  from a left join public.taraf t on t.id = a.yayinlayan
                 order by a.sabit desc, coalesce(a.yayin_bas, a.ekleme_tarihi) desc
                 limit 300
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // OKUMA DURUMU: kim okudu, kim görmedi (yönetim sağ paneli).
        grup.MapGet("/{id:int}/okuma", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select k.id, coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod) as ad,
                       o.gordu, o.okudu, coalesce(o.okudu_surum, 0) as "okuduSurum"
                  from public.fn_duyuru_alicilari(@p0) a(id)
                  join public.taraf_kullanici k on k.id = a.id
                  left join public.taraf t on t.id = k.id
                  left join public.duyuru_okuma o on o.duyuru_id = @p0 and o.kullanici_id = k.id
                 order by (o.okudu is not null), (o.gordu is not null), 2
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // ------------------------------------------------ hedef ara / say --
        grup.MapGet("/hedef-ara", async (string? q, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", Islem.Ekle);
            var a = (q ?? "").Trim();
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                (select 1 as tur, s.id, s.ad from public.sube s where s.ad ilike '%' || @p0 || '%' order by s.ad limit 8)
                union all
                (select 2, d.id, d.ad from public.departman d where d.durum = 1 and d.ad ilike '%' || @p0 || '%' order by d.ad limit 10)
                union all
                (select 3, r.id, r.ad from public.rol r where r.ad ilike '%' || @p0 || '%' order by r.ad limit 8)
                union all
                (select 4, k.id, coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod)
                   from public.taraf_kullanici k left join public.taraf t on t.id = k.id
                  where k.aktif = 1 and coalesce(k.portal_taraf_id, 0) = 0 and length(@p0) >= 2
                    and (k.kod ilike @p0 || '%' or (coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')) ilike '%' || @p0 || '%')
                  order by 3 limit 10)
                """, null, [a], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        grup.MapPost("/hedef-say", async (SayIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            // Geçici duyuruyla say: kural tek yerde (fn_duyuru_gorur) kalsın.
            await using var islem = await b.BeginTransactionAsync(iptal);
            var id = await b.TekDegerAsync<int>("""
                insert into public.duyuru (baslik, herkes, durum, yayinlayan) values ('sayim', @p0, 0, 0) returning id
                """, islem, [(short)(istek.Herkes ? 1 : 0)], iptal);
            await HedefYazAsync(b, islem, id, istek.Hedefler, iptal);
            var n = await b.TekDegerAsync<long>("select count(*) from public.fn_duyuru_alicilari(@p0)", islem, [id], iptal);
            await islem.RollbackAsync(iptal);
            return Results.Ok(new { kisi = n });
        });

        // ------------------------------------------------ kaydet / yayınla --
        grup.MapPost("/", async (DuyuruIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            BildirimDeposu bildirim, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", istek.Id is > 0 ? Islem.Degistir : Islem.Ekle);
            baglam.YazmaIste();

            var baslik = (istek.Baslik ?? "").Trim();
            if (baslik.Length == 0) throw GentegreHatasi.IsKurali("Başlık zorunlu.");
            if (baslik.Length > 200) throw GentegreHatasi.IsKurali("Başlık en çok 200 karakter.");
            if (istek.Onem is < 1 or > 3) throw GentegreHatasi.IsKurali("Önem: Bilgi, Önemli ya da Kritik.");
            var metin = HtmlTemizle(istek.Metin ?? "");
            var yayinla = istek.Islem == "yayinla";
            if (yayinla && DuzMetin(metin).Trim().Length == 0) throw GentegreHatasi.IsKurali("Duyuru metni boş.");
            var hedefler = (istek.Hedefler ?? []).Where(h => h.Tur is >= 1 and <= 4 && h.Id > 0).Distinct().ToList();
            if (yayinla && !istek.Herkes && hedefler.Count == 0) throw GentegreHatasi.IsKurali("Kime gideceğini seçin.");
            if (istek.Sms && istek.Onem != 3) throw GentegreHatasi.IsKurali("SMS yalnız Kritik duyuruda gönderilir.");
            if ((istek.Herkes || istek.Sms) && !baglam.Yetkiler.Var("duyuru.genel", Islem.Ekle))
                throw GentegreHatasi.Yasak("Herkese ya da SMS ile duyuru için yetkiniz yok.");
            if (istek.YayinBit is { } bit && bit <= (istek.YayinBas ?? DateTime.UtcNow))
                throw GentegreHatasi.IsKurali("Bitiş, başlangıçtan sonra olmalı.");

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            int id;
            short eskiDurum = 0;
            if (istek.Id is > 0)
            {
                var eski = await b.TekAsync("select durum, yayin_bas from public.duyuru where id = @p0 for update",
                    islem, [istek.Id.Value], OkuyucuGenisletmeleri.Sozluk, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Duyuru bulunamadı.");
                eskiDurum = Convert.ToInt16(eski["durum"]);
                if (eskiDurum == 9) throw GentegreHatasi.IsKurali("Yayından kaldırılmış duyuru düzenlenemez.");
                id = istek.Id.Value;
                // YAYINDAKİ DÜZENLEME: sürüm +1, "güncellendi" - okuyanlara yeniden okunmamış görünür.
                await b.CalistirAsync("""
                    update public.duyuru set baslik = @p1, metin = @p2, onem = @p3, herkes = @p4,
                           yayin_bas = @p5, yayin_bit = @p6, okuma_onayi = @p7, sabit = @p8, yorum_acik = @p9,
                           eposta = @p10, sms = @p11, adina = @p12,
                           durum = case when @p13 then 1 else durum end,
                           surum = case when durum = 1 then surum + 1 else surum end,
                           guncelleme = case when durum = 1 then now() else guncelleme end,
                           degistiren = @p14, degistirme_tarihi = now()
                     where id = @p0
                    """, islem,
                    [id, baslik, metin, istek.Onem, (short)(istek.Herkes ? 1 : 0), istek.YayinBas, istek.YayinBit,
                     B(istek.OkumaOnayi), B(istek.Sabit), B(istek.YorumAcik), B(istek.Eposta), B(istek.Sms),
                     istek.Adina?.Trim() ?? "", yayinla, baglam.KullaniciId], iptal);
                await b.CalistirAsync("delete from public.duyuru_hedef where duyuru_id = @p0", islem, [id], iptal);
            }
            else
            {
                id = await b.TekDegerAsync<int>("""
                    insert into public.duyuru (baslik, metin, onem, herkes, yayin_bas, yayin_bit, okuma_onayi,
                           sabit, yorum_acik, eposta, sms, adina, durum, yayinlayan, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p13)
                    returning id
                    """, islem,
                    [baslik, metin, istek.Onem, (short)(istek.Herkes ? 1 : 0), istek.YayinBas, istek.YayinBit,
                     B(istek.OkumaOnayi), B(istek.Sabit), B(istek.YorumAcik), B(istek.Eposta), B(istek.Sms),
                     istek.Adina?.Trim() ?? "", (short)(yayinla ? 1 : 0), baglam.KullaniciId, baglam.SubeId], iptal);
            }
            await HedefYazAsync(b, islem, id, hedefler, iptal);
            await log.YazAsync(b, islem, istek.Id is > 0 ? LogIslemi.Degistir : LogIslemi.Ekle, LogDuyuru, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { baslik, istek.Onem, istek.Herkes, hedef = hedefler.Count, istek.Islem }, iptal: iptal);
            await islem.CommitAsync(iptal);

            // E-POSTA / SMS: yayın başlamışsa ve daha önce gönderilmediyse BİR KEZ.
            //   Zamanlanmış duyuru yayın anında değil - zamanı gelince (zamanlı iş).
            var gonderilen = 0;
            if (yayinla) gonderilen = await DisKanalGonderAsync(b, bildirim, id, baglam, iptal);
            return Results.Ok(new { id, gonderilen, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ kaldır / sil / hatırlat --
        grup.MapPost("/{id:int}/kaldir", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.duyuru set durum = 9, sabit = 0, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 1
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yayında olmayan duyuru kaldırılamaz.");
            return Results.Ok(new { id });
        });

        grup.MapDelete("/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", Islem.Sil);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("delete from public.duyuru where id = @p0 and durum = 0", null, [id], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız taslak silinir; yayındakini yayından kaldırın.");
            return Results.Ok(new { id });
        });

        // HATIRLAT: okumayanlarda duyuru yeniden "okunmamış" olur - zil
        //   rozeti ve anlık bildirim tekrar düşer. Okuyanlara dokunulmaz.
        grup.MapPost("/{id:int}/hatirlat", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("duyuru", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.duyuru_okuma set gordu = null, gordu_surum = 0
                 where duyuru_id = @p0 and okudu is null and gordu is not null
                """, null, [id], iptal);
            var okumayan = await b.TekDegerAsync<long>("""
                select count(*) from public.fn_duyuru_alicilari(@p0) a(id)
                 where not exists (select 1 from public.duyuru_okuma o where o.duyuru_id = @p0
                                     and o.kullanici_id = a.id and o.okudu is not null)
                """, null, [id], iptal);
            return Results.Ok(new { id, okumayan, sifirlanan = n });
        });
    }

    private const int LogDuyuru = 1320;

    private static short B(bool v) => (short)(v ? 1 : 0);

    private static async Task<bool> GorurAsync(NpgsqlConnection b, int id, int kullanici,
                                               CancellationToken iptal, bool yalnizYayinda)
        => await b.TekDegerAsync<bool>($$"""
            select exists (select 1 from public.duyuru d where d.id = @p0
                             {{(yalnizYayinda ? "and " + YayindaSql : "")}}
                             and public.fn_duyuru_gorur(d.id, @p1))
            """, null, [id, kullanici], iptal);

    private static async Task<List<IDictionary<string, object?>>> HedeflerAsync(NpgsqlConnection b, int id,
                                                                               CancellationToken iptal)
        => await b.ListeAsync("""
            select h.tur, h.hedef_id as id,
                   case h.tur when 1 then (select s.ad from public.sube s where s.id = h.hedef_id)
                              when 2 then (select d.ad from public.departman d where d.id = h.hedef_id)
                              when 3 then (select r.ad from public.rol r where r.id = h.hedef_id)
                              else (select coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod)
                                      from public.taraf_kullanici k left join public.taraf t on t.id = k.id
                                     where k.id = h.hedef_id) end as ad
              from public.duyuru_hedef h where h.duyuru_id = @p0 order by h.tur, 3
            """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

    private static async Task HedefYazAsync(NpgsqlConnection b, NpgsqlTransaction islem, int id,
                                            List<HedefIstegi>? hedefler, CancellationToken iptal)
    {
        foreach (var h in hedefler ?? [])
            await b.CalistirAsync("""
                insert into public.duyuru_hedef (duyuru_id, tur, hedef_id) values (@p0, @p1, @p2)
                on conflict do nothing
                """, islem, [id, h.Tur, h.Id], iptal);
    }

    /// <summary>
    /// E-posta / SMS (seçildiyse) - yayın başlamışsa ve daha önce gönderilmediyse.
    /// `gonderim` damgası ikinci gönderimi engeller (düzenleme yeniden göndermez).
    /// </summary>
    internal static async Task<int> DisKanalGonderAsync(NpgsqlConnection b, BildirimDeposu bildirim,
        int id, IstekBaglami? baglam, CancellationToken iptal)
    {
        var d = await b.TekAsync($$"""
            update public.duyuru d set gonderim = now()
             where d.id = @p0 and {{YayindaSql}} and d.gonderim is null and (d.eposta = 1 or d.sms = 1)
            returning d.baslik, d.metin, d.eposta, d.sms,
                      coalesce(nullif(d.adina, ''), (select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)
                                                       from public.taraf t where t.id = d.yayinlayan), 'Kurum') as adina
            """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (d is null) return 0;
        var alicilar = await b.ListeAsync("""
            select k.id, coalesce(k.cep_tel, ''), coalesce(k.eposta, ''),
                   coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod)
              from public.fn_duyuru_alicilari(@p0) a(id)
              join public.taraf_kullanici k on k.id = a.id
              left join public.taraf t on t.id = k.id
            """, null, [id], r => (Id: r.GetInt32(0), Cep: r.GetString(1), Eposta: r.GetString(2), Ad: r.GetString(3)), iptal);
        var degisken = new Dictionary<string, string>
        {
            ["baslik"] = d["baslik"] as string ?? "",
            ["adina"] = d["adina"] as string ?? "",
            ["metin"] = DuzMetin(d["metin"] as string ?? ""),
        };
        var eposta = Convert.ToInt16(d["eposta"]) == 1;
        var sms = Convert.ToInt16(d["sms"]) == 1;
        var n = 0;
        foreach (var a in alicilar)
        {
            var dg = new Dictionary<string, string>(degisken) { ["alici"] = a.Ad };
            if (sms && a.Cep.Length > 0
                && await bildirim.KuyrugaEkleAsync(new BildirimIstegi("duyuru.sms", BildirimKanali.Sms, a.Cep, dg,
                        KullaniciId: a.Id, KaynakTur: KaynakDuyuru, KaynakId: id, Oncelik: 1),
                    baglam?.KullaniciId ?? 0, baglam?.SubeId, iptal) is not null) n++;
            if (eposta && a.Eposta.Length > 0
                && await bildirim.KuyrugaEkleAsync(new BildirimIstegi("duyuru.eposta", BildirimKanali.Eposta, a.Eposta, dg,
                        KullaniciId: a.Id, KaynakTur: KaynakDuyuru, KaynakId: id),
                    baglam?.KullaniciId ?? 0, baglam?.SubeId, iptal) is not null) n++;
        }
        return n;
    }

    // ===================================================== HTML temizleme ==

    private static readonly HashSet<string> IzinliEtiket =
        new(StringComparer.OrdinalIgnoreCase) { "b", "strong", "i", "em", "u", "br", "p", "div", "ul", "ol", "li", "a", "span" };

    [GeneratedRegex(@"<(script|style|iframe|object|embed|noscript|template)\b[\s\S]*?</\1\s*>", RegexOptions.IgnoreCase)]
    private static partial Regex TehlikeliBlok();
    [GeneratedRegex(@"<(/?)([a-zA-Z][a-zA-Z0-9]*)\b([^>]*)>")]
    private static partial Regex Etiket();
    [GeneratedRegex(@"href\s*=\s*(""([^""]*)""|'([^']*)'|([^\s>]+))", RegexOptions.IgnoreCase)]
    private static partial Regex Href();

    /// <summary>
    /// BEYAZ LİSTE: biçim etiketleri özniteliksiz kalır; &lt;a&gt; yalnız
    /// http(s) / mailto href'iyle (yeni sekmede, noopener). Diğer her şey
    /// düşer ya da metne çevrilir. Metin parçaları yeniden kodlanır.
    /// </summary>
    public static string HtmlTemizle(string html)
    {
        html = TehlikeliBlok().Replace(html, "");
        var sb = new StringBuilder();
        var son = 0;
        foreach (Match m in Etiket().Matches(html))
        {
            sb.Append(Kodla(html[son..m.Index]));
            son = m.Index + m.Length;
            var kapanis = m.Groups[1].Value == "/";
            var ad = m.Groups[2].Value.ToLowerInvariant();
            if (!IzinliEtiket.Contains(ad)) continue;
            if (ad == "br") { if (!kapanis) sb.Append("<br>"); continue; }
            if (ad == "a" && !kapanis)
            {
                var h = Href().Match(m.Groups[3].Value);
                var url = h.Success ? WebUtility.HtmlDecode(h.Groups[2].Success && h.Groups[2].Length > 0 ? h.Groups[2].Value
                                     : h.Groups[3].Success && h.Groups[3].Length > 0 ? h.Groups[3].Value : h.Groups[4].Value).Trim() : "";
                if (url.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
                    || url.StartsWith("https://", StringComparison.OrdinalIgnoreCase)
                    || url.StartsWith("mailto:", StringComparison.OrdinalIgnoreCase))
                    sb.Append("<a href=\"").Append(Kodla(url)).Append("\" target=\"_blank\" rel=\"noopener noreferrer\">");
                else sb.Append("<a>");
                continue;
            }
            sb.Append(kapanis ? $"</{ad}>" : $"<{ad}>");
        }
        sb.Append(Kodla(html[son..]));
        return sb.ToString();
    }

    /// <summary>Yalnız HTML'e özel karakterler - Türkçe harfler &#252; olmasın (özet / e-posta düz kalsın).</summary>
    private static string Kodla(string metin) => WebUtility.HtmlDecode(metin)
        .Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");

    /// <summary>E-posta / özet için düz metin.</summary>
    public static string DuzMetin(string html)
    {
        var s = Regex.Replace(html, @"<br\s*/?>|</(p|div|li)>", "\n", RegexOptions.IgnoreCase);
        s = Regex.Replace(s, "<[^>]+>", "");
        return WebUtility.HtmlDecode(s).Trim();
    }
}
