using System.Net;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BELGE TALEP KARTI (962, mockup Ekranlar/IK/belge_talep_karti.html).
///
/// Bağlam (personel, şablonlar, önceki talepler, akış), e-posta ile teslim ve
/// KİMLİKSİZ doğrulama sayfası: yazıdaki kod `/api/belge-dogrula/{kod}` ile
/// sorgulanır - yalnız belgenin varlığı, türü, numarası, tarihi ve maskeli ad
/// döner; kişisel bilgi (TCKN, maaş) asla.
/// </summary>
public static partial class BelgeTalebiUclari
{
    private const short KaynakBelge = 47;   // bildirim.kaynak_tur

    private static void BelgeKartUclariniEkle(RouteGroupBuilder grup, IEndpointRouteBuilder yol)
    {
        grup.MapGet("/belge-baglam", async (int tarafId, int? talepId, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIsteKendi(tarafId, "ik.belge_talep", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var personel = await b.TekAsync("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad,
                       coalesce(p.gorev, '') as gorev, coalesce(k.eposta, '') as eposta,
                       (select string_agg(d.ad, ', ') from public.departman d
                         where d.id in (select public.fn_kullanici_bolumleri(@p0))) as bolum
                  from public.taraf t left join public.taraf_personel p on p.id = t.id
                  left join public.taraf_kullanici k on k.id = t.id
                 where t.id = @p0
                """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var sablonlar = await b.ListeAsync("""
                select s.id, s.ad, s.tur from public.belge_yazi_sablonu s
                 where s.durum = 1 order by s.tur, s.ad
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            var gecmis = await b.ListeAsync("""
                select coalesce(nullif(g.talep_no, ''), '#' || g.id) as no, g.tur, g.talep_tarihi as tarih, g.durum
                  from public.personel_belge_talep g
                 where g.taraf_id = @p0 and g.id <> coalesce(@p1, 0)
                   and g.talep_tarihi > current_date - interval '12 months'
                 order by g.talep_tarihi desc limit 8
                """, null, [tarafId, talepId], OkuyucuGenisletmeleri.Sozluk, iptal);

            List<IDictionary<string, object?>> akis = [];
            if (talepId is > 0)
                akis = await b.ListeAsync("""
                    select 0 as sira, 'olustu' as tur, g.ekleme_tarihi as zaman,
                           coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as kim, '' as metin
                      from public.personel_belge_talep g left join public.taraf t on t.id = g.ekleyen where g.id = @p0
                    union all
                    select 1, 'otomatik', g.ekleme_tarihi, 'sistem', ''
                      from public.personel_belge_talep g where g.id = @p0 and g.otomatik_onay = 1
                    union all
                    select 2 + d.sira, case d.durum when 1 then 'onay' when 2 then 'red' when 3 then 'bilgi' end,
                           d.karar_zamani, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                           d.ad || coalesce(' · “' || nullif(d.gerekce, '') || '”', '')
                      from public.onay o join public.onay_adim d on d.onay_id = o.id
                      left join public.taraf t on t.id = d.karar_veren_id
                     where o.kaynak_tur = @p1 and o.kaynak_id = @p0 and d.karar_zamani is not null and d.durum in (1, 2, 3)
                    union all
                    select 50, 'hazir', g.hazirlama_tarihi, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                           coalesce(g.dogrulama_kodu, '')
                      from public.personel_belge_talep g left join public.taraf t on t.id = g.hazirlayan_id
                     where g.id = @p0 and g.hazirlama_tarihi is not null
                    union all
                    select 60, 'teslim', g.teslim_tarihi, '', case g.teslim_sekli when 2 then 'e-posta' when 3 then 'kargo' else 'elden' end
                      from public.personel_belge_talep g where g.id = @p0 and g.teslim_tarihi is not null
                    union all
                    select 90, case g.durum when 3 then 'red' else 'iptal' end, g.degistirme_tarihi, '', g.red_neden
                      from public.personel_belge_talep g where g.id = @p0 and g.durum in (3, 8)
                     order by 3 nulls last, 1
                    """, null, [talepId.Value, LogTalep], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { personel, sablonlar, gecmis, akis, izlemeNo = baglam.IzlemeNo });
        });

        // E-POSTA İLE TESLİM: hazırlanmış yazı metni e-postayla gider ve talep
        //   "teslim edildi" olur. Gönderim kuyruğa düşer (bildirim işçisi).
        grup.MapPost("/belge-talep/{id:int}/eposta", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            BildirimDeposu bildirim, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_talep", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            var t = await b.TekAsync("""
                select g.durum, g.teslim_eposta as eposta, g.yazi_baslik as baslik, g.yazi_metin as metin,
                       g.talep_no as no, g.taraf_id as "tarafId", coalesce(g.dogrulama_kodu, '') as kod,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad
                  from public.personel_belge_talep g join public.taraf t on t.id = g.taraf_id where g.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge talebi bulunamadı.");
            if (Convert.ToInt16(t["durum"]) != Hazirlandi)
                throw GentegreHatasi.IsKurali("Yalnız hazırlanmış belge e-postayla gönderilir.");
            var adres = (t["eposta"] as string ?? "").Trim();
            if (adres.Length == 0) throw GentegreHatasi.IsKurali("Teslim e-posta adresi girilmemiş.");

            var govde = $"Sayın {t["ad"]},\n\nTalep ettiğiniz belge aşağıdadır.\n\n{t["baslik"]}\n\n{t["metin"]}\n\n"
                      + (string.IsNullOrEmpty(t["kod"] as string) ? "" : $"Doğrulama kodu: {t["kod"]}\n");
            await bildirim.KuyrugaEkleAsync(new BildirimIstegi(null, BildirimKanali.Eposta, adres,
                Konu: $"{t["baslik"]} - {t["no"]}", Govde: govde, TarafId: Convert.ToInt32(t["tarafId"]),
                KaynakTur: KaynakBelge, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);

            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                update public.personel_belge_talep
                   set durum = @p1, teslim_tarihi = now(), degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, TeslimEdildi, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTalep, id, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { teslim = "e-posta", adres }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = TeslimEdildi, adres, izlemeNo = baglam.IzlemeNo });
        });

        // KİMLİKSİZ DOĞRULAMA: belgeyi alan kurum kodu girer / barkodu okutur.
        yol.MapGet("/api/belge-dogrula/{kod}", async (string kod, VeriKaynagi veri, CancellationToken iptal) =>
        {
            var k = (kod ?? "").Trim().ToUpperInvariant();
            if (k.Length is < 6 or > 20) return Results.Content(DogrulamaSayfasi(null, k), "text/html; charset=utf-8");
            await using var b = await veri.AcAsync(iptal);
            var t = await b.TekAsync("""
                select case g.tur when 1 then 'Çalışma Belgesi' when 2 then 'Maaş Yazısı' when 3 then 'Vize Yazısı'
                                  when 4 then 'SGK Hizmet Dökümü' else 'Belge' end as tur,
                       g.talep_no as no, coalesce(g.hazirlama_tarihi, g.ekleme_tarihi) as tarih, g.durum,
                       coalesce(t.ad, '') as ad, coalesce(t.soyad, '') as soyad, coalesce(s.unvan, '') as kurum
                  from public.personel_belge_talep g
                  join public.taraf t on t.id = g.taraf_id
                  left join public.v_sube_antet s on s.sube_id = g.sube_id
                 where g.dogrulama_kodu = @p0
                """, null, [k], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Content(DogrulamaSayfasi(t, k), "text/html; charset=utf-8");
        }).AllowAnonymous();
    }

    /// <summary>Ad maskeli: "Aslı Demir" → "A*** D****".</summary>
    private static string Maskele(string s) => string.Join(' ', s.Split(' ', StringSplitOptions.RemoveEmptyEntries)
        .Select(p => p[..1] + new string('*', Math.Max(2, p.Length - 1))));

    private static string DogrulamaSayfasi(IDictionary<string, object?>? t, string kod)
    {
        static string e(string? s) => WebUtility.HtmlEncode(s ?? "");
        var govde = t is null
            ? $"<div class='hata'>✖ <b>{e(kod)}</b> koduyla kayıtlı belge bulunamadı.</div>"
            : Convert.ToInt16(t["durum"]) is 3 or 8
                ? $"<div class='hata'>✖ Bu belge <b>geçersiz</b> (iptal / red).</div>"
                : $"""
                   <div class='ok'>✔ Belge geçerli</div>
                   <table><tr><th>Kurum</th><td>{e(t["kurum"] as string ?? "")}</td></tr>
                   <tr><th>Belge</th><td>{e(t["tur"] as string ?? "")}</td></tr>
                   <tr><th>Sayı</th><td>{e(t["no"] as string ?? "")}</td></tr>
                   <tr><th>Tarih</th><td>{(t["tarih"] is DateTime d ? d.ToString("dd.MM.yyyy") : "")}</td></tr>
                   <tr><th>Ad soyad</th><td>{e(Maskele($"{t["ad"]} {t["soyad"]}"))}</td></tr></table>
                   """;
        return $$"""
            <!doctype html><html lang="tr"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Belge doğrulama</title>
            <style>body{font:15px Arial;margin:0;background:#eef1f5;display:flex;justify-content:center;padding:40px 16px}
            .k{background:#fff;border-radius:8px;box-shadow:0 6px 20px rgba(0,0,0,.12);padding:24px;max-width:420px;width:100%}
            h1{font-size:17px;margin:0 0 14px;color:#1d4270} .ok{color:#2e7d46;font-weight:bold;font-size:17px;margin-bottom:12px}
            .hata{color:#b3261e;font-size:15px} table{width:100%;border-collapse:collapse} th,td{text-align:left;padding:6px 4px;border-bottom:1px solid #eee}
            th{color:#667;font-weight:normal;width:38%} small{display:block;margin-top:14px;color:#889}</style>
            <div class='k'><h1>Belge doğrulama · {{e(kod)}}</h1>{{govde}}
            <small>Yalnız belgenin varlığı ve temel bilgileri gösterilir; kişisel bilgiler paylaşılmaz.</small></div></html>
            """;
    }
}
