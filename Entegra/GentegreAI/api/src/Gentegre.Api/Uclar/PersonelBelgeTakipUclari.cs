using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İK › BELGE TAKİBİ listesinin yan uçları (mockup Ekranlar/IK/personel_belge_takibi.html (2),
/// kullanıcı 22.10.2026 "Belge Takip Listesini mockup'a göre yap").
///
///  · <c>GET  /api/ik/belge-takip/ozet</c>     üst şerit sayaçları (eksik / doldu / yaklaşan; belge ve kişi).
///  · <c>POST /api/ik/belge-takip/hatirlat</c> seçili personele eksik / süresi dolan / yaklaşan belgeleri
///    bildirim kuyruğundan gönderir: e-postası varsa e-posta, yoksa SMS (cep). Aynı personele 24 saat
///    içinde ikinci hatırlatma konmaz - düğmeye iki kez basmak iki mesaj demekti (borç takibi kuralı).
///
/// Sayılar <c>v_personel_belge_durum</c>'dan, listeyle aynı kural (1135-1136).
/// </summary>
public static class PersonelBelgeTakipUclari
{
    /// <summary>bildirim.kaynak_tur - personel belge takibi (40-48 dolu).</summary>
    private const short KaynakBelgeTakip = 49;

    public sealed record HatirlatIstegi(int[] PersonelIds);

    public static void PersonelBelgeTakipUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ik/belge-takip").WithTags("Personel Belge Takibi").RequireAuthorization();

        grup.MapGet("/ozet", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("ik.belge_takip.liste", Islem.Gor) && !baglam.Yetkiler.Var("ik.belge_takip", Islem.Gor))
                baglam.YetkiIste("ik.belge_takip.liste", Islem.Gor);
            var o = await veri.TekAsync("""
                select count(*) filter (where x.zorunlu = 1 and x.durum = 1)::int,
                       count(distinct x.personel_id) filter (where x.zorunlu = 1 and x.durum = 1)::int,
                       count(*) filter (where x.durum = 2)::int,
                       count(distinct x.personel_id) filter (where x.durum = 2)::int,
                       count(*) filter (where x.durum = 3)::int,
                       count(distinct x.personel_id) filter (where x.durum = 3)::int,
                       (select count(*) from public.taraf t where t.personel = 1 and t.durum = 1)::int
                  from public.v_personel_belge_durum x
                """, [], r => new
                {
                    eksik = r.GetInt32(0), eksikKisi = r.GetInt32(1),
                    doldu = r.GetInt32(2), dolduKisi = r.GetInt32(3),
                    yaklasan = r.GetInt32(4), yaklasanKisi = r.GetInt32(5),
                    personel = r.GetInt32(6),
                }, iptal);
            return Results.Ok(o);
        });

        grup.MapPost("/hatirlat", async (HatirlatIstegi istek, VeriKaynagi veri, BildirimDeposu bildirim,
                                         BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_takip", Islem.Degistir);
            var ids = (istek.PersonelIds ?? []).Where(x => x > 0).Distinct().ToArray();
            if (ids.Length == 0) throw GentegreHatasi.Dogrulama("Personel seçilmedi.");
            if (ids.Length > 500) throw GentegreHatasi.Dogrulama("Tek seferde en çok 500 personele hatırlatma gönderilir.");
            await using var b = await veri.AcAsync(iptal);

            // Hatırlatılacak belgeler: zorunlu ve eksik, süresi dolmuş ya da yaklaşan (liste "En acil" ile aynı küme).
            var belgeler = (await b.ListeAsync("""
                select x.personel_id, x.belge, x.durum, x.durum_adi, x.kalan_gun
                  from public.v_personel_belge_durum x
                 where x.personel_id = any(@p0)
                   and ((x.zorunlu = 1 and x.durum = 1) or x.durum in (2, 3))
                 order by x.personel_id, x.durum, x.kalan_gun nulls first, x.belge
                """, null, [ids], r => (pid: r.GetInt32(0), belge: r.GetString(1), durum: r.GetInt16(2),
                    adi: r.GetString(3), kalan: r.IsDBNull(4) ? (int?)null : r.GetInt32(4)), iptal))
                .GroupBy(x => x.pid).ToDictionary(g => g.Key, g => g.Select(x =>
                    x.durum == 3 && x.kalan is { } k ? $"{x.belge} ({k} gün kaldı)"
                    : x.durum == 2 ? $"{x.belge} (süresi doldu)"
                    : $"{x.belge} ({x.adi.ToLowerInvariant()})").ToList());

            var kisiler = await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(t.cep_tel, ''), coalesce(t.eposta, ''),
                       exists (select 1 from public.bildirim n
                                where n.taraf_id = t.id and n.kaynak_tur = @p1 and n.durum <> 5
                                  and n.ekleme_tarihi > now() - interval '24 hours')
                  from public.taraf t where t.id = any(@p0) and t.personel = 1
                """, null, [ids, KaynakBelgeTakip], r => (id: r.GetInt32(0), ad: r.GetString(1), tel: r.GetString(2),
                    eposta: r.GetString(3), yakin: r.GetBoolean(4)), iptal);
            var kurum = await b.TekDegerAsync<string>("""
                select coalesce(nullif(s.unvan, ''), s.ad, '') from public.sube s where s.id = @p0
                """, null, [baglam.SubeId ?? 0], iptal) ?? "";

            var atlanan = new List<object>();
            var konan = 0;
            foreach (var k in kisiler)
            {
                if (!belgeler.TryGetValue(k.id, out var liste)) { atlanan.Add(new { k.ad, neden = "eksik / süresi dolan belgesi yok" }); continue; }
                var eposta = !string.IsNullOrWhiteSpace(k.eposta);
                var alici = eposta ? k.eposta : k.tel;
                if (string.IsNullOrWhiteSpace(alici)) { atlanan.Add(new { k.ad, neden = "e-posta ve cep telefonu yok" }); continue; }
                if (k.yakin) { atlanan.Add(new { k.ad, neden = "son 24 saatte hatırlatıldı" }); continue; }

                var id = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                        SablonKodu: eposta ? "personel.belge.hatirlatma.eposta" : "personel.belge.hatirlatma",
                        Kanal: eposta ? BildirimKanali.Eposta : BildirimKanali.Sms,
                        Alici: alici,
                        Degiskenler: new Dictionary<string, string>
                        {
                            ["personel_ad"] = k.ad,
                            ["belgeler"] = eposta ? string.Join("\n", liste.Select(x => "• " + x)) : string.Join(", ", liste),
                            ["kurum"] = kurum,
                        },
                        TarafId: k.id, KaynakTur: KaynakBelgeTakip, KaynakId: k.id, Oncelik: 7),
                    baglam.KullaniciId, baglam.SubeId, iptal);
                if (id is null) { atlanan.Add(new { k.ad, neden = "hatırlatma şablonu pasif" }); continue; }
                konan++;
            }
            return Results.Ok(new { kuyruga = konan, atlanan });
        });
    }
}
