using System.Text.Json;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇAĞRI MERKEZİ — anonim santral webhook'u. Sağlayıcıdan gelen olay; anahtar
/// cagri_santral.webhook_anahtar (herhangi bir şube). Olaylar: ringing ·
/// answered · hold · unhold · transfer · hangup · voicemail. <c>ref</c> santralin
/// çağrı kimliği - aynı ref ikinci kez gelirse mevcut kayıt güncellenir.
/// </summary>
public static partial class CagriUclari
{
    private static void WebhookUclari(RouteGroupBuilder grup)
    {
        grup.MapPost("/olay/{saglayici}", async (string saglayici, string? anahtar, OlayIstegi g, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            var sube = string.IsNullOrWhiteSpace(anahtar) ? null :
                await b.TekDegerAsync<int?>("select sube_id from public.cagri_santral where webhook_anahtar = @p0 and webhook_anahtar <> ''", null, [anahtar], iptal);
            if (sube is null) return Results.Unauthorized();
            await b.CalistirAsync("update public.cagri_santral set son_olay = now(), durum = 1 where sube_id = @p0", null, [sube], iptal);
            var olay = (g.Olay ?? "").Trim().ToLowerInvariant();
            var reff = (g.Ref ?? "").Trim();
            var kuyrukId = await KuyrukBulAsync(b, g.Kuyruk, iptal);
            var agentId = await AgentBulAsync(b, g.Dahili, iptal);
            int? id = reff == "" ? null : await b.TekDegerAsync<int?>("select id from public.cagri where dis_ref = @p0", null, [reff], iptal);
            var ham = Kirp(JsonSerializer.Serialize(g), 1000);
            switch (olay)
            {
                case "ringing":
                    if (id is null) id = await SantralCagriAcAsync(b, g, sube.Value, kuyrukId, null, reff, cevaplandi: false, iptal);
                    else await b.CalistirAsync("update public.cagri set kuyruk_id = coalesce(@p1, kuyruk_id), durum = case when durum in (5, 6) then durum else 1 end where id = @p0", null, [id, kuyrukId], iptal);
                    await OlayYazAsync(b, id.Value, 1, null, $"Çaldı → {g.Kuyruk ?? ""}", ham, iptal);
                    break;
                case "answered":
                    if (id is null)
                    {
                        // Çalma olayı gelmeden cevaplandı: kayıt doğrudan "çağrıda" açılır.
                        id = await SantralCagriAcAsync(b, g, sube.Value, kuyrukId, agentId, reff, cevaplandi: true, iptal);
                        await OlayYazAsync(b, id.Value, 2, agentId, "Cevaplandı (çalma olayı gelmedi)", ham, iptal);
                    }
                    else
                    {
                        await b.CalistirAsync("""
                            update public.cagri set agent_id = coalesce(@p1, agent_id), cevap = coalesce(cevap, now()), bekleme_sn = extract(epoch from (coalesce(cevap, now()) - baslama))::int, durum = 2 where id = @p0
                            """, null, [id, agentId], iptal);
                        await OlayYazAsync(b, id.Value, 2, agentId, $"Cevaplandı · dahili {g.Dahili ?? ""}", ham, iptal);
                    }
                    await AgentDurumAsync(b, agentId, AgentCagrida, iptal);
                    break;
                case "hold":
                case "unhold":
                    if (id is null) return Results.NotFound();
                    var beklet = olay == "hold";
                    await b.CalistirAsync("update public.cagri set durum = @p1 where id = @p0 and durum in (2, 3)", null, [id, beklet ? (short)3 : (short)2], iptal);
                    await OlayYazAsync(b, id.Value, beklet ? (short)3 : (short)4, agentId, beklet ? "Beklet" : "Bekletme bitti", ham, iptal);
                    break;
                case "transfer":
                    if (id is null) return Results.NotFound();
                    var hedefAgent = await AgentBulAsync(b, g.Hedef, iptal);
                    var hedefKuyruk = await KuyrukBulAsync(b, g.Hedef, iptal);
                    await b.CalistirAsync("update public.cagri set agent_id = coalesce(@p1, agent_id), kuyruk_id = coalesce(@p2, kuyruk_id), durum = case when @p1 is null and @p2 is not null then 1 else 2 end where id = @p0", null, [id, hedefAgent, hedefKuyruk], iptal);
                    await OlayYazAsync(b, id.Value, 5, agentId, $"Aktarıldı → {g.Hedef ?? ""}", ham, iptal);
                    break;
                case "hangup":
                    if (id is null) return Results.NotFound();
                    var cevaplandi = await b.TekDegerAsync<bool>("select cevap is not null from public.cagri where id = @p0", null, [id], iptal);
                    await b.CalistirAsync("""
                        update public.cagri
                           set bitis = now(), sure_sn = case when cevap is null then 0 else coalesce(@p1, extract(epoch from (now() - cevap))::int) end,
                               bekleme_sn = case when cevap is null then extract(epoch from (now() - baslama))::int else bekleme_sn end,
                               kayit_url = coalesce(nullif(@p2, ''), kayit_url),
                               durum = case when cevap is null then 6 when konu_id is null then 4 else 5 end
                         where id = @p0 and durum not in (5)
                        """, null, [id, g.SureSn, g.KayitUrl ?? ""], iptal);
                    await OlayYazAsync(b, id.Value, 6, agentId, cevaplandi ? "Kapandı" : "Kaçan çağrı", ham, iptal);
                    if (cevaplandi)
                        await AgentIslemSonrasinaAlAsync(b, await b.TekDegerAsync<int?>("select agent_id from public.cagri where id = @p0", null, [id], iptal), iptal);
                    break;
                case "voicemail":
                    if (id is null) return Results.NotFound();
                    await b.CalistirAsync("update public.cagri set durum = 7, bitis = now(), kayit_url = coalesce(nullif(@p1, ''), kayit_url) where id = @p0", null, [id, g.KayitUrl ?? ""], iptal);
                    await OlayYazAsync(b, id.Value, 6, null, "Sesli mesaj bırakıldı", ham, iptal);
                    break;
                default:
                    return Results.BadRequest(new { hata = "Bilinmeyen olay: " + olay });
            }
            return Results.Ok(new { id, olay });
        });
    }

    /// <summary>Santral olayından gelen çağrı kaydı: arayan tanınır; cevaplanmışsa doğrudan "çağrıda" (2), yoksa "çalıyor" (1).</summary>
    private static async Task<int> SantralCagriAcAsync(NpgsqlConnection b, OlayIstegi g, int sube, int? kuyrukId, int? agentId, string reff, bool cevaplandi, CancellationToken iptal)
    {
        var tel = (g.Arayan ?? "").Trim();
        var tarafId = await TarafBulAsync(b, tel, iptal);
        return await b.TekDegerAsync<int>("""
            insert into public.cagri (kanal, yon, arayan_no, aranan_no, taraf_id, kuyruk_id, agent_id, dis_ref, baslama, cevap, durum, sube_id)
            values (1, 1, @p0, @p1, @p2, @p3, @p4, @p5, now(), case when @p6 then now() end, case when @p6 then 2 else 1 end, @p7) returning id
            """, null, [tel, (g.Aranan ?? "").Trim(), tarafId, kuyrukId, agentId, reff, cevaplandi, sube], iptal);
    }
}
