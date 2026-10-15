using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KONSÜLTASYON (1107) — isteğin akış adımları. İstek kartı genel kart motorundadır
/// (KartKatalogu.Konsultasyon: taslak ↔ gönderildi); burada kart dışı geçişler var:
/// yanıtla (isteği hekime alır, yanıt muayenesini açar), hastada, sonuç, yönlendir,
/// reddet, gördüm. Yanıt muayenesi tamamlanınca istek "yanıtlandı" olur (DB tetiği).
///
/// Terim "yanıtla"dır - kullanıcı: "üstlenme yerine yanıtlama terimini kullan".
/// Mockup: Ekranlar/Muayene/konsultasyon_listesi.html · konsultasyon_karti.html.
/// </summary>
public static class KonsultasyonUclari
{
    private const int LogKons = 1540;
    private const string Yetki = "muayene.konsultasyon";

    public sealed record YonlendirIstegi(int? HedefBolumId, int? HedefHekimId, string? Gerekce);
    public sealed record GerekceIstegi(string? Gerekce);
    public sealed record SonucIstegi(short Sonuc);

    private static string Kirp(string? s, int n) => (s ?? "").Trim() is var t && t.Length > n ? t[..n] : t;

    private sealed record Istek(int Id, string No, short Durum, int TarafId, int? BelgeId, int SubeId,
                                int? IsteyenMuayeneId, int? IsteyenHekimId, int? HedefBolumId, int? HedefHekimId,
                                int? YanitlayanId, int? YanitMuayeneId, string Soru);

    private static async Task<Istek> OkuAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int id, CancellationToken iptal, bool kilitle = true)
        => await b.TekAsync($"""
            select id, no, durum, taraf_id, belge_id, sube_id, isteyen_muayene_id, isteyen_hekim_id,
                   hedef_bolum_id, hedef_hekim_id, yanitlayan_id, yanit_muayene_id, soru
              from public.konsultasyon where id = @p0 {(kilitle ? "for update" : "")}
            """, tx, [id], o => new Istek(o.GetInt32(0), o.GetString(1), o.GetInt16(2), o.GetInt32(3),
                o.IsDBNull(4) ? null : o.GetInt32(4), o.GetInt32(5),
                o.IsDBNull(6) ? null : o.GetInt32(6), o.IsDBNull(7) ? null : o.GetInt32(7),
                o.IsDBNull(8) ? null : o.GetInt32(8), o.IsDBNull(9) ? null : o.GetInt32(9),
                o.IsDBNull(10) ? null : o.GetInt32(10), o.IsDBNull(11) ? null : o.GetInt32(11), o.GetString(12)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Konsültasyon bulunamadı.");

    /// <summary>Kart dışı durum geçişi: DB tetiğinin kapısı (yalnız bu işlemde).</summary>
    private static Task KapiAc(NpgsqlConnection b, NpgsqlTransaction tx, CancellationToken iptal)
        => b.CalistirAsync("select set_config('kons.uc', '1', true)", tx, [], iptal);

    private static Task HareketAsync(NpgsqlConnection b, NpgsqlTransaction tx, int id, short tur, string aciklama,
                                     int kullanici, CancellationToken iptal, int? eskiBolum = null, int? yeniBolum = null)
        => b.CalistirAsync("""
            insert into public.konsultasyon_hareket (konsultasyon_id, tur, aciklama, eski_bolum_id, yeni_bolum_id, kullanici_id)
            values (@p0, @p1, @p2, @p3, @p4, @p5)
            """, tx, [id, tur, aciklama, eskiBolum, yeniBolum, kullanici], iptal);

    /// <summary>Açık (tamamlanmamış) yanıt muayenesi iptal edilir - yönlendirme / ret sonrası yarım kalmasın.</summary>
    private static Task YanitMuayenesiniKapat(NpgsqlConnection b, NpgsqlTransaction tx, int? muayeneId, int kullanici, CancellationToken iptal)
        => muayeneId is null ? Task.CompletedTask : b.CalistirAsync("""
            update public.muayene set durum = 0, degistiren = @p1, degistirme_tarihi = now()
             where id = @p0 and durum not in (3, 0)
            """, tx, [muayeneId, kullanici], iptal);

    public static void KonsultasyonUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/konsultasyon").WithTags("Konsültasyon").RequireAuthorization();

        // ÖZET (mockup kutuları) - sekmenin kapsamında: gelen (bana / bölümüme) · istedigim · bolum.
        //   Sekme süzgecinin kendisi de buradan: kullanıcı ve bölümleri istemci bilmez.
        grup.MapGet("/ozet", async (string? kapsam, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Gor);
            var ben = baglam.KullaniciId;
            var bolumler = (await veri.ListeAsync("select * from public.fn_kullanici_bolumleri(@p0)", [ben],
                o => o.GetInt32(0), iptal)).Distinct().ToArray();
            var kapsamSql = kapsam switch
            {
                "istedigim" => "k.isteyen_hekim_id = @p0",
                "bolum" => bolumler.Length > 0 ? "k.hedef_bolum_id = any(@p1)" : "true",
                _ => "(k.hedef_hekim_id = @p0 or (k.hedef_hekim_id is null and k.hedef_bolum_id = any(@p1)))",
            };
            var o = await veri.TekAsync($"""
                select count(*) filter (where k.durum in (1, 2) and k.son_zaman < now())::int,
                       count(*) filter (where k.durum = 1)::int,
                       count(*) filter (where k.durum = 2 and k.yanitlayan_id = @p0)::int,
                       count(*) filter (where k.durum in (3, 4) and k.yanit_zamani::date = current_date)::int,
                       coalesce(avg(extract(epoch from (k.yanit_zamani - k.istek_zamani)) / 60)
                                filter (where k.durum in (3, 4) and k.yanit_zamani::date = current_date), 0)::int,
                       count(*) filter (where k.durum in (3, 4) and exists (select 1 from public.enabiz_paket p
                                          join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                                         where t.kod = 'KONSULTASYON' and p.kaynak_id = k.yanit_muayene_id and p.durum = 3))::int,
                       count(*) filter (where k.durum in (3, 4))::int,
                       count(*) filter (where k.merkez = 2 and k.durum in (1, 2))::int,
                       count(*) filter (where k.durum in (1, 2))::int
                  from public.konsultasyon k
                 where {kapsamSql} and (@p2::int is null or k.sube_id = @p2)
                   and (k.durum in (1, 2) or k.istek_zamani > now() - interval '30 days')
                """, [ben, bolumler, baglam.SubeId], r => new
                {
                    suresiGecen = r.GetInt32(0), yanitBekleyen = r.GetInt32(1), yanitladiklarim = r.GetInt32(2),
                    bugunYanitlanan = r.GetInt32(3), ortalamaDk = r.GetInt32(4),
                    enabizGonderilen = r.GetInt32(5), enabizToplam = r.GetInt32(6), disMerkez = r.GetInt32(7), acik = r.GetInt32(8),
                }, iptal);
            return Results.Ok(new { ben, bolumler, ozet = o });
        });

        // ÖN İZLEME (mockup alt paneli): "neden çağrıldım" tek bakışta.
        grup.MapGet("/{id:int}/onizleme", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var k = await b.TekAsync("""
                select k.no, k.soru, coalesce(public.fn_taraf_ad(ih.unvan, ih.ad, ih.soyad)::varchar(120), ''),
                       coalesce(public.fn_taraf_ad(sh.unvan, sh.ad, sh.soyad)::varchar(120), ''),
                       k.istek_zamani, k.aciliyet, k.karsilama_yeri, coalesce(bl.belge_no, ''), coalesce(ib.ad, ''),
                       k.taraf_id, k.isteyen_muayene_id, k.durum, k.hedef_bolum_id, k.sonuc,
                       k.yanitlama_zamani, k.hastada_zamani, k.yanit_zamani, k.gordu_zamani, k.yanit_muayene_id,
                       coalesce(public.fn_taraf_ad(yh.unvan, yh.ad, yh.soyad)::varchar(120), ''), coalesce(hb.ad, ''),
                       k.ret_gerekce, k.yonlendirme_notu,
                       -- HASTA (kullanıcı 15.10.2026: "isteyen dr ve hastanın adları otomatik yeni ekrana geçmeli")
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''), coalesce(h.kod, '')
                  from public.konsultasyon k
                  left join public.taraf h on h.id = k.taraf_id
                  left join public.taraf ih on ih.id = k.isteyen_hekim_id
                  left join public.taraf sh on sh.id = k.sorumlu_hekim_id
                  left join public.taraf yh on yh.id = k.yanitlayan_id
                  left join public.belge bl on bl.id = k.belge_id
                  left join public.departman ib on ib.id = k.istek_bolum_id
                  left join public.departman hb on hb.id = k.hedef_bolum_id
                 where k.id = @p0
                """, null, [id], o => new
                {
                    no = o.GetString(0), soru = o.GetString(1), isteyen = o.GetString(2), sorumlu = o.GetString(3),
                    istekZamani = o.GetDateTime(4), aciliyet = (int)o.GetInt16(5), karsilamaYeri = (int)o.GetInt16(6),
                    basvuruNo = o.GetString(7), istekBolum = o.GetString(8), tarafId = o.GetInt32(9),
                    isteyenMuayeneId = o.IsDBNull(10) ? (int?)null : o.GetInt32(10), durum = (int)o.GetInt16(11),
                    hedefBolumId = o.IsDBNull(12) ? (int?)null : o.GetInt32(12), sonuc = (int)o.GetInt16(13),
                    yanitlamaZamani = o.IsDBNull(14) ? (DateTime?)null : o.GetDateTime(14),
                    hastadaZamani = o.IsDBNull(15) ? (DateTime?)null : o.GetDateTime(15),
                    yanitZamani = o.IsDBNull(16) ? (DateTime?)null : o.GetDateTime(16),
                    gorduZamani = o.IsDBNull(17) ? (DateTime?)null : o.GetDateTime(17),
                    yanitMuayeneId = o.IsDBNull(18) ? (int?)null : o.GetInt32(18),
                    yanitlayan = o.GetString(19), hedefBolum = o.GetString(20),
                    retGerekce = o.GetString(21), yonlendirmeNotu = o.GetString(22),
                    hasta = o.GetString(23), hastaKod = o.GetString(24),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Konsültasyon bulunamadı.");

            var tanilar = k.isteyenMuayeneId is null ? new List<string>() : await b.ListeAsync("""
                select t.icd_kod || coalesce(' ' || i.ad, '') || case when t.tur = 1 then '' else ' (ek)' end
                  from public.tani t left join public.icd i on i.kod = t.icd_kod
                 where t.muayene_id = @p0 order by t.tur, t.sira, t.id
                """, null, [k.isteyenMuayeneId], o => o.GetString(0), iptal);
            var lab = await b.ListeAsync("""
                select coalesce(nullif(lt.kisa_ad, ''), lt.ad, s.ad) || ' ' ||
                       coalesce(trim(to_char(r.deger_sayisal, 'FM999999990.##')), r.deger_metin, '') ||
                       case when coalesce(r.bayrak::text, '') in ('H', 'HH') then ' ↑' when coalesce(r.bayrak::text, '') in ('L', 'LL') then ' ↓' else '' end
                  from public.lab_sonuc r
                  join public.lab_istem_satir s on s.id = r.istem_satir_id
                  join public.lab_istem li on li.id = s.istem_id
                  left join public.lab_tetkik lt on lt.id = r.tetkik_id
                 where li.taraf_id = @p0 and r.onay_zamani is not null
                 order by r.onay_zamani desc limit 6
                """, null, [k.tarafId], o => o.GetString(0), iptal);
            var ilaclar = await b.ListeAsync("""
                select ilac_ad || coalesce(' ' || nullif(trim(doz || ' ' || periyot), ''), '')
                  from public.hasta_ilac where hasta_id = @p0 and aktif = 1 order by id desc limit 8
                """, null, [k.tarafId], o => o.GetString(0), iptal);
            var alerjiler = await b.ListeAsync("""
                select coalesce(nullif(etken, ''), etken_madde, '') from public.hasta_alerji
                 where hasta_id = @p0 and aktif = 1 order by id
                """, null, [k.tarafId], o => o.GetString(0), iptal);
            var gecmis = await b.ListeAsync("""
                select x.id, coalesce(public.fn_taraf_ad(yh.unvan, yh.ad, yh.soyad)::varchar(120), ''),
                       coalesce(x.yanit_zamani, x.istek_zamani), coalesce(m.karar, ''), coalesce(hb.ad, '')
                  from public.konsultasyon x
                  left join public.muayene m on m.id = x.yanit_muayene_id
                  left join public.taraf yh on yh.id = x.yanitlayan_id
                  left join public.departman hb on hb.id = x.hedef_bolum_id
                 where x.taraf_id = @p0 and x.id <> @p1 and x.durum in (3, 4)
                 order by x.yanit_zamani desc nulls last limit 3
                """, null, [k.tarafId, id], o => new
                {
                    id = o.GetInt32(0), yanitlayan = o.GetString(1), zaman = o.GetDateTime(2),
                    yanit = o.GetString(3), bolum = o.GetString(4),
                }, iptal);
            var akis = await b.ListeAsync("""
                select h.tur, h.zaman, h.aciklama, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '')
                  from public.konsultasyon_hareket h left join public.taraf t on t.id = h.kullanici_id
                 where h.konsultasyon_id = @p0 order by h.zaman, h.id
                """, null, [id], o => new { tur = (int)o.GetInt16(0), zaman = o.GetDateTime(1), aciklama = o.GetString(2), kim = o.GetString(3) }, iptal);
            var enabiz = k.yanitMuayeneId is not null && await b.TekDegerAsync<int>("""
                select count(*)::int from public.enabiz_paket p join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                 where t.kod = 'KONSULTASYON' and p.kaynak_id = @p0 and p.durum = 3
                """, null, [k.yanitMuayeneId], iptal) > 0;
            return Results.Ok(new { id, k, tanilar, lab, ilaclar, alerjiler, gecmis, akis, enabiz });
        });

        // YANIT MUAYENESİNDEN İSTEK: muayene kartı (tür 3) üstte soru + akış şeridi çizsin.
        grup.MapGet("/yanit/{muayeneId:int}", async (int muayeneId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            var id = await veri.TekDegerAsync<int?>("select id from public.konsultasyon where yanit_muayene_id = @p0", [muayeneId], iptal);
            return Results.Ok(new { id });
        });

        // YANITLA: isteği bana al ve yanıt muayenesini aç (yoksa). Mockuptaki "üstlen" budur;
        //   bölüme düşen istekte bölümün hekimi, hekime yönelende o hekim alır.
        grup.MapPost("/{id:int}/yanitla", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            var ben = baglam.KullaniciId;
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var k = await OkuAsync(b, tx, id, iptal);
            if (k.Durum is 6) throw GentegreHatasi.IsKurali("Taslak istek henüz gönderilmedi.");
            if (k.Durum is not (1 or 2)) throw GentegreHatasi.IsKurali("Bu konsültasyon artık açık değil.");
            if (k.Durum == 2 && k.YanitlayanId is { } y && y != ben)
            {
                var ad = await b.TekDegerAsync<string>("select public.fn_taraf_ad(unvan, ad, soyad)::varchar(120) from public.taraf where id = @p0", tx, [y], iptal);
                throw GentegreHatasi.IsKurali($"Bu konsültasyonu {ad} yanıtlıyor.");
            }
            if (k.HedefHekimId is { } h && h != ben)
                throw GentegreHatasi.IsKurali("Konsültasyon başka bir hekime yönlendirilmiş - önce size yönlendirilmeli.");

            var muayeneId = k.YanitMuayeneId;
            if (muayeneId is null || await b.TekDegerAsync<int>("select durum from public.muayene where id = @p0", tx, [muayeneId], iptal) == 0)
            {
                muayeneId = await b.TekDegerAsync<int>("""
                    insert into public.muayene (belge_id, taraf_id, sube_id, bolum_id, personel_id, muayene_tarihi,
                                                tur, durum, ekleyen, ust_muayene_id, konsultasyon_soru, muayene_no)
                    values (@p0, @p1, @p2, @p3, @p4, now(), 3, 1, @p4, @p5, @p6,
                            public.fn_numara_kimlik_uret(902, @p2, 'muayene', 'muayene_no', current_date))
                    returning id
                    """, tx, [k.BelgeId, k.TarafId, k.SubeId, k.HedefBolumId, ben, k.IsteyenMuayeneId, k.Soru], iptal);
            }
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("""
                update public.konsultasyon
                   set durum = 2, yanitlayan_id = @p1, yanitlama_zamani = coalesce(yanitlama_zamani, now()),
                       yanit_muayene_id = @p2, degistiren = @p1
                 where id = @p0
                """, tx, [id, ben, muayeneId], iptal);
            if (k.Durum == 1) await HareketAsync(b, tx, id, 2, "", ben, iptal);
            await tx.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogKons, id, ben, baglam.SubeId, baglam.Ip, new { durum = "Yanıtlanıyor", yanitMuayeneId = muayeneId }, iptal: iptal);
            return Results.Ok(new { id, yanitMuayeneId = muayeneId, mesaj = $"{k.No}: yanıt muayenesi açıldı." });
        });

        // HASTADA: konsültan hastanın yanında (akış şeridinin "Hastada" adımı).
        grup.MapPost("/{id:int}/hastada", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var k = await OkuAsync(b, tx, id, iptal);
            if (k.Durum != 2) throw GentegreHatasi.IsKurali("Önce 'Yanıtla' ile konsültasyonu alın.");
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("update public.konsultasyon set hastada_zamani = coalesce(hastada_zamani, now()), degistiren = @p1 where id = @p0",
                tx, [id, baglam.KullaniciId], iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, mesaj = "Hastada olarak işaretlendi." });
        });

        // SONUÇ (yapısal): engel yok / ertelenmeli / devralınmalı / takip.
        grup.MapPost("/{id:int}/sonuc", async (int id, SonucIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            if (g.Sonuc is < 0 or > 4) throw GentegreHatasi.Dogrulama("Geçersiz sonuç.");
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var k = await OkuAsync(b, tx, id, iptal);
            if (k.Durum is not (2 or 3)) throw GentegreHatasi.IsKurali("Sonuç yalnız yanıtlanan konsültasyona yazılır.");
            if (k.YanitlayanId != baglam.KullaniciId) throw GentegreHatasi.IsKurali("Sonucu konsültasyonu yanıtlayan hekim yazar.");
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("update public.konsultasyon set sonuc = @p1, degistiren = @p2 where id = @p0", tx, [id, g.Sonuc, baglam.KullaniciId], iptal);
            await tx.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogKons, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { sonuc = g.Sonuc }, iptal: iptal);
            return Results.Ok(new { id, sonuc = g.Sonuc, mesaj = "Sonuç kaydedildi." });
        });

        // YÖNLENDİR: istek kapanmaz, yeni hedefe taşınır; süre sayacı sıfırlanmaz. Gerekçe zorunlu.
        grup.MapPost("/{id:int}/yonlendir", async (int id, YonlendirIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            var gerekce = Kirp(g.Gerekce, 400);
            if (gerekce.Length == 0) throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.", new AlanHatasi("gerekce", "Gerekçe yazın."));
            if (g.HedefBolumId is not > 0) throw GentegreHatasi.Dogrulama("Yeni hedef bölüm seçilmeli.", new AlanHatasi("hedefBolumId", "Bölüm seçin."));
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var k = await OkuAsync(b, tx, id, iptal);
            if (k.Durum is not (1 or 2)) throw GentegreHatasi.IsKurali("Yalnız açık konsültasyon yönlendirilebilir.");
            await YanitMuayenesiniKapat(b, tx, k.YanitMuayeneId, baglam.KullaniciId, iptal);
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("""
                update public.konsultasyon
                   set hedef_bolum_id = @p1, hedef_hekim_id = @p2, durum = 1, yanitlayan_id = null,
                       yanitlama_zamani = null, hastada_zamani = null, yanit_muayene_id = null,
                       yonlendirme_notu = @p3, degistiren = @p4
                 where id = @p0
                """, tx, [id, g.HedefBolumId, g.HedefHekimId is > 0 ? g.HedefHekimId : null, gerekce, baglam.KullaniciId], iptal);
            await HareketAsync(b, tx, id, 3, gerekce, baglam.KullaniciId, iptal, k.HedefBolumId, g.HedefBolumId);
            await tx.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogKons, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { yonlendirildi = g.HedefBolumId, hekim = g.HedefHekimId, gerekce }, iptal: iptal);
            return Results.Ok(new { id, mesaj = $"{k.No} yönlendirildi - isteyen hekim bilgilenir." });
        });

        // REDDET (gerekçeli): istem sessizce kapanmaz.
        grup.MapPost("/{id:int}/reddet", async (int id, GerekceIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Degistir);
            var gerekce = Kirp(g.Gerekce, 400);
            if (gerekce.Length == 0) throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.", new AlanHatasi("gerekce", "Gerekçe yazın."));
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var k = await OkuAsync(b, tx, id, iptal);
            if (k.Durum is not (1 or 2)) throw GentegreHatasi.IsKurali("Yalnız açık konsültasyon reddedilebilir.");
            await YanitMuayenesiniKapat(b, tx, k.YanitMuayeneId, baglam.KullaniciId, iptal);
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("""
                update public.konsultasyon set durum = 9, ret_gerekce = @p1, yanitlayan_id = coalesce(yanitlayan_id, @p2),
                       yanit_zamani = now(), degistiren = @p2
                 where id = @p0
                """, tx, [id, gerekce, baglam.KullaniciId], iptal);
            await HareketAsync(b, tx, id, 4, gerekce, baglam.KullaniciId, iptal);
            await tx.CommitAsync(iptal);
            await log.YazAsync(LogIslemi.Degistir, LogKons, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Reddedildi", gerekce }, iptal: iptal);
            return Results.Ok(new { id, mesaj = $"{k.No} reddedildi - isteyen hekim bilgilenir." });
        });

        // GÖRDÜM: isteyen hekim yanıtı gördü (akışın "İsteyen gördü" adımı).
        grup.MapPost("/{id:int}/gordum", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var k = await OkuAsync(b, tx, id, iptal);
            if (k.Durum is not (3 or 9)) throw GentegreHatasi.IsKurali("Henüz yanıtlanmadı.");
            await KapiAc(b, tx, iptal);
            await b.CalistirAsync("""
                update public.konsultasyon set durum = case when durum = 3 then 4 else durum end,
                       gordu_zamani = coalesce(gordu_zamani, now()), degistiren = @p1
                 where id = @p0
                """, tx, [id, baglam.KullaniciId], iptal);
            await HareketAsync(b, tx, id, 6, "", baglam.KullaniciId, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, mesaj = "Yanıt görüldü." });
        });

        // MUAYENEDEN İSTEK: hasta, başvuru, isteyen bölüm ve hekim muayeneden; TASLAK açılır,
        //   hekim kartta hedefi ve soruyu yazıp gönderir.
        yol.MapPost("/api/muayene/{muayeneId:int}/konsultasyon", async (int muayeneId, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Yetki, Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var m = await b.TekAsync("select taraf_id, belge_id, sube_id, bolum_id, personel_id, durum from public.muayene where id = @p0",
                null, [muayeneId], o => new
                {
                    taraf = o.GetInt32(0), belge = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), sube = o.GetInt32(2),
                    bolum = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), hekim = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                    durum = o.GetInt16(5),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");
            if (m.durum == 0) throw GentegreHatasi.IsKurali("İptal edilmiş muayeneden konsültasyon istenemez.");
            var id = await b.TekDegerAsync<int>("""
                insert into public.konsultasyon (sube_id, belge_id, taraf_id, isteyen_muayene_id, isteyen_hekim_id,
                                                 istek_bolum_id, durum, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 6, @p6) returning id
                """, null, [m.sube, m.belge, m.taraf, muayeneId, m.hekim ?? baglam.KullaniciId, m.bolum, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Ekle, LogKons, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { muayeneId, durum = "Taslak" }, iptal: iptal);
            return Results.Ok(new { id, mesaj = "Konsültasyon isteği açıldı (taslak)." });
        }).WithTags("Konsültasyon").RequireAuthorization();
    }
}
