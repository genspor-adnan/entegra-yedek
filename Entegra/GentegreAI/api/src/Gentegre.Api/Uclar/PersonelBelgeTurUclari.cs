using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İK › BELGE TÜRLERİ liste + kart yan uçları (mockup Ekranlar/IK/personel_belge_turu.html,
/// kullanıcı 22.10.2026 "mockup'a göre yap, öneriler hariç").
///
///  · <c>GET  /api/ik/belge-takip/tur/ozet</c>                 liste sayaç kartları.
///  · <c>GET  /api/ik/belge-takip/tur/{id}/personel</c>         kart "👥 Personel durumu": türün kurum geneli durumu.
///  · <c>POST /api/ik/belge-takip/tur/{id}/kapsam-onizleme</c>  kart "🎯 Kime zorunlu": KAYDEDİLMEMİŞ kurallarla
///    eşleşen personel - kural başına eşleşen / eksik, kapsama yeni giren eksik, kapsamdan çıkacak, birim dağılımı.
///  · <c>GET  /api/ik/belge-takip/tur/{id}/kart-ozet</c>        kart "Genel" sağ sütunu.
///  · <c>GET  /api/ik/belge-takip/tur/{id}/hareketler</c>       kart "🕘 Hareketler": tür + kapsam logu (1600 / 1601).
///  · <c>POST /api/ik/belge-takip/tur/{id}/kopyala</c>          kapsamıyla birlikte "Kopya ..." türü.
///  · <c>POST /api/ik/belge-takip/tur/{id}/durum</c>            aktif ⇄ pasif (kullanımdaki tür silinmez).
///  · <c>POST /api/ik/belge-takip/tur/sira</c>                  "↕ Sırayı düzenle" - grup içi sıra.
///
/// Durum kuralı <c>v_personel_belge_durum</c>'la aynı (1135-1136, 1138).
/// </summary>
public static class PersonelBelgeTurUclari
{
    private const short KaynakBelgeTakip = 49;
    private const int LogTur = 1600, LogKapsam = 1601;

    public sealed record KapsamKurali(int? DepartmanId, int? GorevId);
    public sealed record KapsamOnizlemeIstegi(KapsamKurali[]? Satirlar);
    public sealed record SiraIstegi(int[]? Idler);

    /// <summary>Log alan adları (kart farkı alan adıyla, detay silme yedeği kolon adıyla gelir).</summary>
    private static readonly Dictionary<string, string> AlanAdlari = new(StringComparer.Ordinal)
    {
        ["ad"] = "Belge adı", ["grup"] = "Grup", ["sira"] = "Sıra", ["aktif"] = "Durum", ["aciklama"] = "Açıklama",
        ["gecerlilikAy"] = "Geçerlilik (ay)", ["gecerlilik_ay"] = "Geçerlilik (ay)",
        ["hatirlatGun"] = "Uyarı günü", ["hatirlat_gun"] = "Uyarı günü",
        ["dosyaZorunlu"] = "Dosyası zorunlu", ["dosya_zorunlu"] = "Dosyası zorunlu",
    };

    public static void PersonelBelgeTurUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ik/belge-takip/tur").WithTags("Personel Belge Takibi").RequireAuthorization();

        static void GorIste(IstekBaglami b)
        {
            if (!b.Yetkiler.Var("ik.belge_takip.liste", Islem.Gor) && !b.Yetkiler.Var("ik.belge_takip", Islem.Gor))
                b.YetkiIste("ik.belge_takip.liste", Islem.Gor);
        }

        // ------------------------------------------------------- sayaçlar --
        grup.MapGet("/ozet", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            GorIste(baglam);
            var o = await veri.TekAsync("""
                select count(*) filter (where t.aktif = 1)::int,
                       count(*) filter (where t.aktif = 1 and t.kapsamli = 1)::int,
                       count(*) filter (where t.aktif = 1 and t.sureli = 1)::int,
                       count(*) filter (where t.aktif = 1 and t.eksik + t.doldu > 0)::int,
                       count(*) filter (where t.aktif = 1 and t.kapsamli = 0)::int,
                       count(*) filter (where t.aktif <> 1)::int
                  from public.v_personel_belge_turu t
                 where t.sube_id = 0 or t.sube_id = @p0
                """, [baglam.SubeId ?? 0], r => new
                {
                    aktif = r.GetInt32(0), zorunlu = r.GetInt32(1), sureli = r.GetInt32(2),
                    eksigiOlan = r.GetInt32(3), istegeBagli = r.GetInt32(4), pasif = r.GetInt32(5),
                }, iptal);
            return Results.Ok(o);
        });

        // ----------------------------------------------- personel durumu --
        // Satır = bu türün zorunlu olduğu ya da belgesini girmiş aktif personel. Sıra mockup'taki gibi:
        //   süresi dolan, eksik, yaklaşan, tamam. Son hatırlatma bildirim kuyruğundan (kaynak_tur 49).
        grup.MapGet("/{id:int}/personel", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            GorIste(baglam);
            var satirlar = await veri.ListeAsync("""
                select x.personel_id, x.ad, x.birim, x.gorev, x.belge_tarihi, x.gecerlilik_tarihi, x.kalan_gun,
                       x.dosya_sayisi, x.durum, x.durum_adi, x.zorunlu, x.belge_id,
                       h.ekleme_tarihi, h.kanal
                  from public.v_personel_belge_durum x
                  left join lateral (
                        select n.ekleme_tarihi, n.kanal from public.bildirim n
                         where n.taraf_id = x.personel_id and n.kaynak_tur = @p1 and n.durum <> 5
                         order by n.ekleme_tarihi desc limit 1) h on true
                 where x.belge_turu_id = @p0
                 order by case x.durum when 2 then 0 when 1 then 1 when 3 then 2 else 3 end,
                          x.kalan_gun nulls first, x.ad
                """, [id, KaynakBelgeTakip], r => new
                {
                    personelId = r.GetInt32(0), ad = r.GetString(1), birim = r.GetString(2), gorev = r.GetString(3),
                    belgeTarihi = r.IsDBNull(4) ? (DateTime?)null : r.GetDateTime(4),
                    gecerlilikTarihi = r.IsDBNull(5) ? (DateTime?)null : r.GetDateTime(5),
                    kalanGun = r.IsDBNull(6) ? (int?)null : r.GetInt32(6),
                    dosyaSayisi = r.GetInt32(7), durum = r.GetInt16(8), durumAdi = r.GetString(9),
                    zorunlu = r.GetInt16(10) == 1, belgeVar = !r.IsDBNull(11),
                    sonHatirlatma = r.IsDBNull(12) ? (DateTimeOffset?)null : r.GetFieldValue<DateTimeOffset>(12),
                    sonHatirlatmaKanal = r.IsDBNull(13) ? "" : r.GetInt16(13) == 2 ? "e-posta" : "SMS",
                }, iptal);
            return Results.Ok(satirlar);
        });

        // ---------------------------------------------- kapsam önizleme --
        // Kart kaydedilmeden: gride girilen kurallar (birim / görev, boş = hepsi) hangi aktif personeli
        //   kapsar? "Eksik" = belgesi yok, dosyası zorunluyken yok ya da süresi dolmuş (durum 1-2).
        grup.MapPost("/{id:int}/kapsam-onizleme", async (int id, KapsamOnizlemeIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            GorIste(baglam);
            var kurallar = istek.Satirlar ?? [];
            if (kurallar.Length > 200) throw GentegreHatasi.Dogrulama("En çok 200 kural önizlenir.");
            var deps = kurallar.Select(k => k.DepartmanId is > 0 ? k.DepartmanId : null).ToArray();
            var gors = kurallar.Select(k => k.GorevId is > 0 ? k.GorevId : null).ToArray();

            await using var b = await veri.AcAsync(iptal);
            const string Ortak = """
                with kural as (
                  select u.ord::int as ord, u.dep, u.gor
                    from unnest(@p1::int[], @p2::int[]) with ordinality as u(dep, gor, ord)
                ), pers as (
                  select t.id, t.departman, t.gorev_id from public.taraf t where t.personel = 1 and t.durum = 1
                ), es as (
                  select k.ord, p.id from kural k
                    join pers p on (k.dep is null or k.dep = p.departman) and (k.gor is null or k.gor = p.gorev_id)
                ), mevcut as (
                  select distinct p.id from pers p
                    join public.personel_belge_kapsam k on k.belge_turu_id = @p0
                     and (k.departman_id is null or k.departman_id = p.departman)
                     and (k.gorev_id is null or k.gorev_id = p.gorev_id)
                ), dz as (
                  select coalesce((select bt.dosya_zorunlu from public.personel_belge_turu bt where bt.id = @p0), 0) as v
                ), durum as (
                  select p.id,
                         case when s.id is null then 1
                              when dz.v = 1 and not exists (select 1 from public.dokuman d
                                                             where d.kaynak = 'personel-belge' and d.kaynak_id = s.id) then 1
                              when s.gecerlilik_tarihi is not null and s.gecerlilik_tarihi < current_date then 2
                              else 0 end as d
                    from (select distinct id from es) p
                    cross join dz
                    left join lateral (
                          select b.id, b.gecerlilik_tarihi from public.personel_belge b
                           where b.taraf_id = p.id and b.belge_turu_id = @p0
                           order by coalesce(b.gecerlilik_tarihi, 'infinity'::date) desc, b.belge_tarihi desc nulls last, b.id desc
                           limit 1) s on true
                )
                """;
            object[] p = [id, deps, gors];
            var satirlar = await b.ListeAsync(Ortak + """
                select k.ord, count(es.id)::int, count(es.id) filter (where du.d > 0)::int
                  from kural k left join es on es.ord = k.ord left join durum du on du.id = es.id
                 group by k.ord order by k.ord
                """, null, p, r => new { sira = r.GetInt32(0), eslesen = r.GetInt32(1), eksik = r.GetInt32(2) }, iptal);
            var toplam = await b.TekAsync(Ortak + """
                select (select count(distinct id) from es)::int,
                       (select count(*) from durum where d > 0)::int,
                       (select count(*) from durum du where du.d > 0 and not exists (select 1 from mevcut m where m.id = du.id))::int,
                       (select count(*) from mevcut m where not exists (select 1 from es where es.id = m.id))::int
                """, null, p, r => new { kapsama = r.GetInt32(0), eksik = r.GetInt32(1), yeniEksik = r.GetInt32(2), cikacak = r.GetInt32(3) }, iptal);
            var birimler = await b.ListeAsync(Ortak + """
                select coalesce(d.ad, '(birimsiz)'), count(*)::int
                  from (select distinct id from es) x
                  join public.taraf t on t.id = x.id
                  left join public.departman d on d.id = t.departman
                 group by 1 order by 2 desc, 1
                """, null, p, r => new { ad = r.GetString(0), sayi = r.GetInt32(1) }, iptal);
            return Results.Ok(new { satirlar, toplam, birimler });
        });

        // ------------------------------------------------------ hareketler --
        grup.MapGet("/{id:int}/hareketler", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            GorIste(baglam);
            var satirlar = await veri.ListeAsync("""
                select l.tarih, l.islem_tipi, l.tablo_id, coalesce(l.bilgi::text, ''), l.kullanici_id,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       case when l.tablo_id = @p2 then
                         concat_ws(' · ', coalesce(d.ad, '(tüm birimler)'), coalesce(g.ad, '(tüm görevler)')) end
                  from public.islem_log l
                  left join public.taraf t on t.id = l.kullanici_id
                  left join public.departman d
                         on d.id::text = coalesce(l.bilgi->>'departmanId', l.bilgi->>'departman_id')
                  left join public.personel_gorev g
                         on g.id::text = coalesce(l.bilgi->>'gorevId', l.bilgi->>'gorev_id')
                 where (l.tablo_id = @p1 and l.kayit_id = @p0)
                    or (l.tablo_id = @p2 and l.ust_tablo_id = @p1 and l.ust_kayit_id = @p0)
                 order by l.tarih desc
                 limit 200
                """, [id, LogTur, LogKapsam], r => new
                {
                    zaman = r.GetFieldValue<DateTimeOffset>(0), tip = r.GetInt16(1), tablo = r.GetInt32(2),
                    bilgi = r.GetString(3), kullaniciId = r.GetInt32(4), kullanici = r.GetString(5),
                    kapsam = r.IsDBNull(6) ? null : r.GetString(6),
                }, iptal);
            return Results.Ok(satirlar.Select(s => new
            {
                s.zaman,
                islem = s.tablo == LogKapsam
                    ? s.tip switch { 1 => "Kapsam eklendi", 0 => "Kapsam silindi", _ => "Kapsam değişti" }
                    : s.tip switch { 1 => "Eklendi", 0 => "Silindi", _ => "Değiştirildi" },
                ayrinti = s.tablo == LogKapsam ? s.kapsam ?? "" : Ayrinti(s.tip, s.bilgi),
                kullanici = s.kullaniciId == 0 ? "Sistem" : s.kullanici,
            }));
        });

        // ------------------------------------------------------- şablonlar --
        // Kart "🔔 Hatırlatma": hatırlatmanın gerçek metni (1137 şablonları, kurum değiştirmiş olabilir).
        grup.MapGet("/sablonlar", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            GorIste(baglam);
            return Results.Ok(await veri.ListeAsync("""
                select s.id, s.kod, s.ad, s.kanal, coalesce(s.konu, ''), coalesce(s.govde, ''), s.durum
                  from public.bildirim_sablon s
                 where s.kod in ('personel.belge.hatirlatma', 'personel.belge.hatirlatma.eposta')
                 order by s.kanal desc
                """, [], r => new
                {
                    id = r.GetInt32(0), kod = r.GetString(1), ad = r.GetString(2), kanal = r.GetInt16(3),
                    konu = r.GetString(4), govde = r.GetString(5), aktif = r.GetInt16(6) == 1,
                }, iptal));
        });

        // ------------------------------------------------------ kart özeti --
        // Kart "Genel" sekmesinin sağ sütunu: kime zorunlu, sayılar, kim ekledi / değiştirdi.
        grup.MapGet("/{id:int}/kart-ozet", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            GorIste(baglam);
            var o = await veri.TekAsync("""
                select v.kapsam, v.personel, v.tamam, v.eksik, v.doldu, v.yaklasan, v.sube_id,
                       bt.ekleme_tarihi, bt.degistirme_tarihi,
                       case when bt.ekleyen = 0 then 'Sistem (kurulum)' else coalesce((select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)
                                                                                        from public.taraf t where t.id = bt.ekleyen), '') end,
                       case when bt.degistiren = 0 then '' else coalesce((select public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120)
                                                                          from public.taraf t where t.id = bt.degistiren), '') end,
                       coalesce((select s.ad from public.sube s where s.id = v.sube_id), '')
                  from public.v_personel_belge_turu v
                  join public.personel_belge_turu bt on bt.id = v.id
                 where v.id = @p0
                """, [id], r => new
                {
                    kapsam = r.GetString(0), personel = r.GetInt32(1), tamam = r.GetInt32(2), eksik = r.GetInt32(3),
                    doldu = r.GetInt32(4), yaklasan = r.GetInt32(5), subeId = r.GetInt32(6),
                    eklemeTarihi = r.GetFieldValue<DateTimeOffset>(7),
                    degistirmeTarihi = r.IsDBNull(8) ? (DateTimeOffset?)null : r.GetFieldValue<DateTimeOffset>(8),
                    ekleyen = r.GetString(9), degistiren = r.GetString(10), sube = r.GetString(11),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Belge türü bulunamadı.");
            return Results.Ok(o);
        });

        // --------------------------------------------------------- kopyala --
        grup.MapPost("/{id:int}/kopyala", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_takip", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var yeni = await b.TekAsync("""
                with k as (
                  insert into public.personel_belge_turu
                         (ad, grup, gecerlilik_ay, hatirlat_gun, sira, aktif, aciklama, sube_id, dosya_zorunlu, ekleyen)
                  select left('Kopya ' || ad, 150), grup, gecerlilik_ay, hatirlat_gun, sira, aktif, aciklama, sube_id,
                         dosya_zorunlu, @p1
                    from public.personel_belge_turu where id = @p0 and (sube_id = 0 or sube_id = @p2)
                  returning id, ad
                ), ks as (
                  insert into public.personel_belge_kapsam (belge_turu_id, departman_id, gorev_id, ekleyen)
                  select k.id, x.departman_id, x.gorev_id, @p1
                    from k join public.personel_belge_kapsam x on x.belge_turu_id = @p0
                  returning 1
                )
                select k.id, k.ad, (select count(*) from ks)::int from k
                """, null, [id, baglam.KullaniciId, baglam.SubeId ?? 0],
                r => new { id = r.GetInt32(0), ad = r.GetString(1), kapsam = r.GetInt32(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge türü bulunamadı.");
            await log.YazAsync(LogIslemi.Ekle, LogTur, yeni.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { ad = yeni.ad, kopyalanan = id, kapsam = yeni.kapsam }, iptal: iptal);
            return Results.Ok(yeni);
        });

        // -------------------------------------------------- aktif / pasif --
        grup.MapPost("/{id:int}/durum", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_takip", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var aktif = await b.TekDegerAsync<short?>("""
                update public.personel_belge_turu
                   set aktif = case when aktif = 1 then 0 else 1 end, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and (sube_id = 0 or sube_id = @p2)
                returning aktif
                """, null, [id, baglam.KullaniciId, baglam.SubeId ?? 0], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge türü bulunamadı.");
            await log.YazAsync(LogIslemi.Degistir, LogTur, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["aktif"] = aktif == 1 ? "0 -> 1" : "1 -> 0" }, iptal: iptal);
            return Results.Ok(new { aktif = aktif == 1 });
        });

        // ------------------------------------------------------------ sıra --
        // Gelen sırayla 10, 20, 30 ... yazılır (gruplar listede ayrı; sıra grup içinde anlamlı).
        //   Değişmeyen satıra dokunulmaz, değişenin logu alan farkıyla.
        grup.MapPost("/sira", async (SiraIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_takip", Islem.Degistir);
            var idler = (istek.Idler ?? []).Where(x => x > 0).Distinct().ToArray();
            if (idler.Length == 0 || idler.Length > 1000) throw GentegreHatasi.Dogrulama("Sıralanacak tür yok.");
            var siralar = idler.Select((_, i) => (short)((i + 1) * 10)).ToArray();
            await using var b = await veri.AcAsync(iptal);
            var degisen = await b.ListeAsync("""
                with yeni as (select * from unnest(@p0::int[], @p1::smallint[]) as u(id, sira)),
                eski as (select t.id, t.sira from public.personel_belge_turu t join yeni y on y.id = t.id
                          where t.sira <> y.sira and (t.sube_id = 0 or t.sube_id = @p3) for update of t)
                update public.personel_belge_turu t
                   set sira = y.sira, degistiren = @p2, degistirme_tarihi = now()
                  from yeni y join eski e on e.id = y.id
                 where t.id = y.id
                returning t.id, e.sira, t.sira
                """, null, [idler, siralar, baglam.KullaniciId, baglam.SubeId ?? 0],
                r => (id: r.GetInt32(0), eski: r.GetInt16(1), yeni: r.GetInt16(2)), iptal);
            foreach (var d in degisen)
                await log.YazAsync(LogIslemi.Degistir, LogTur, d.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string> { ["sira"] = $"{d.eski} -> {d.yeni}" }, iptal: iptal);
            return Results.Ok(new { degisen = degisen.Count });
        });
    }

    /// <summary>Log bilgisini satıra çevirir: değişiklikte "Uyarı günü: 30 → 60", eklemede belge adı.</summary>
    private static string Ayrinti(short tip, string bilgi)
    {
        if (string.IsNullOrEmpty(bilgi)) return "";
        try
        {
            using var j = JsonDocument.Parse(bilgi);
            if (j.RootElement.ValueKind != JsonValueKind.Object) return "";
            if (tip != LogIslemi.Degistir)
            {
                var ad = j.RootElement.TryGetProperty("ad", out var a) ? a.ToString() : "";
                return j.RootElement.TryGetProperty("kopyalanan", out _) ? $"{ad} (kopyalandı)" : ad;
            }
            return string.Join(" · ", j.RootElement.EnumerateObject().Select(p =>
            {
                var etiket = AlanAdlari.GetValueOrDefault(p.Name, p.Name);
                var deger = p.Value.ToString().Replace(" -> ", " → ");
                if (p.Name is "aktif") deger = deger.Replace("1", "Aktif").Replace("0", "Pasif");
                if (p.Name is "dosyaZorunlu" or "dosya_zorunlu") deger = deger.Replace("1", "Evet").Replace("0", "Hayır");
                if (deger.StartsWith(" → ")) deger = "(boş)" + deger;
                if (deger.EndsWith(" → ")) deger += "(boş)";
                return $"{etiket}: {deger}";
            }));
        }
        catch (JsonException) { return ""; }
    }
}
