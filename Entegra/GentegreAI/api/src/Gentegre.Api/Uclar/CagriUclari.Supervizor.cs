using System.Text.Json.Nodes;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇAĞRI MERKEZİ — süpervizör canlı panosu (KPI, agentlar, kuyruklar, saatlik,
/// konu dağılımı, kalite) ve şubenin santral / kanal ayarı.
/// </summary>
public static partial class CagriUclari
{
    private static void SupervizorUclari(RouteGroupBuilder grup)
    {
        grup.MapGet("/supervizor", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.supervizor", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kpi = await b.TekAsync("""
                select (select count(*) from public.cagri where durum in (1, 3, 7)),
                       (select coalesce(max(extract(epoch from (now() - baslama)))::int, 0) from public.cagri where durum = 1),
                       count(*) filter (where c.yon = 1), count(*) filter (where c.yon = 1 and c.cevap is not null), count(*) filter (where c.durum = 6),
                       count(*) filter (where c.yon = 1 and c.cevap is not null and c.bekleme_sn <= coalesce(q.sla_sn, 20)),
                       coalesce(avg(c.sure_sn) filter (where c.sure_sn > 0), 0)::int,
                       coalesce(avg(c.memnuniyet) filter (where c.memnuniyet > 0), 0)::numeric(4,2),
                       (select count(*) from public.cagri where durum in (2, 3) and kanal = 2)
                  from public.cagri c left join public.cagri_kuyruk q on q.id = c.kuyruk_id
                 where c.baslama >= current_date
                """, null, [], o => new
            {
                bekleyen = o.GetInt64(0), enUzunBeklemeSn = o.GetInt32(1), gelen = o.GetInt64(2), cevaplanan = o.GetInt64(3), kacan = o.GetInt64(4),
                slaIcinde = o.GetInt64(5), ortKonusmaSn = o.GetInt32(6), memnuniyet = o.GetDecimal(7), whatsappAcik = o.GetInt64(8),
            }, iptal);
            var agentlar = await JsonListeAsync(b, "select row_to_json(a)::text from public.v_cagri_agent a where a.aktif = 1 order by a.durum, a.dahili", [], iptal);
            var kuyruklar = await JsonListeAsync(b, """
                select json_build_object('id', q.id, 'ad', q.ad, 'bekleyen', q.bekleyen, 'enUzunSn', q.en_uzun_bekleme_sn, 'hazirAgent', q.hazir_agent, 'cevaplanan', q.cevaplanan_bugun, 'kacan', q.kacan_bugun,
                    'slaSn', q.sla_sn, 'slaHedef', q.sla_hedef, 'tasmaAdi', q.tasma_adi,
                    'slaYuzde', coalesce((select round(100.0 * count(*) filter (where c.bekleme_sn <= q.sla_sn) / nullif(count(*), 0)) from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.cevap is not null), 0),
                    'ortBeklemeSn', coalesce((select avg(c.bekleme_sn)::int from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.cevap is not null), 0),
                    'ortKonusmaSn', coalesce((select avg(c.sure_sn)::int from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.sure_sn > 0), 0))::text
                  from public.v_cagri_kuyruk q where q.aktif = 1 order by q.sira
                """, [], iptal);
            var saatlik = await JsonListeAsync(b, """
                select json_build_object('saat', s, 'gelen', (select count(*) from public.cagri c where c.baslama >= current_date and extract(hour from c.baslama) = s),
                                         'kacan', (select count(*) from public.cagri c where c.baslama >= current_date and extract(hour from c.baslama) = s and c.durum = 6))::text
                  from generate_series(8, 18) s
                """, [], iptal);
            var konular = await JsonListeAsync(b, """
                select json_build_object('konu', coalesce(k.ad, '(konu yok)'), 'bugun', count(*) filter (where c.baslama >= current_date), 'hafta', count(*),
                                         'cozum', count(*) filter (where c.sonuc in (1, 6, 7)), 'geriArama', count(*) filter (where c.sonuc = 2), 'gorev', count(*) filter (where c.sonuc = 3),
                                         'ortSureSn', coalesce(avg(c.sure_sn) filter (where c.sure_sn > 0), 0)::int)::text
                  from public.cagri c left join public.cagri_konu k on k.id = c.konu_id
                 where c.baslama >= current_date - 7 group by k.ad order by count(*) desc
                """, [], iptal);
            var kalite = await JsonListeAsync(b, """
                select json_build_object('hafta', to_char(k.ekleme_tarihi, 'IYYY-IW'), 'sayi', count(*), 'ortPuan', avg(k.puan)::int, 'enDusuk', min(k.puan))::text
                  from public.cagri_kalite k where k.puan > 0 and k.ekleme_tarihi >= current_date - 28 group by to_char(k.ekleme_tarihi, 'IYYY-IW') order by 1 desc
                """, [], iptal);
            var aktif = await JsonListeAsync(b, "select row_to_json(c)::text from public.v_cagri c where c.durum in (2, 3) order by c.baslama", [], iptal);
            var agentGun = await JsonListeAsync(b, """
                select json_build_object('agentId', a.kullanici_id, 'ad', a.agent_adi, 'cagri', count(c.id), 'cevaplanan', count(c.id) filter (where c.cevap is not null),
                        'ortKonusmaSn', coalesce(avg(c.sure_sn) filter (where c.sure_sn > 0), 0)::int, 'ortIslemSn', coalesce(avg(c.islem_sonrasi_sn) filter (where c.islem_sonrasi_sn > 0), 0)::int,
                        'randevu', count(c.id) filter (where c.sonuc = 7), 'geriArama', count(c.id) filter (where c.sonuc = 2), 'gorev', count(c.id) filter (where c.sonuc = 3),
                        'kalite', (select avg(x.puan)::int from public.cagri_kalite x join public.cagri y on y.id = x.cagri_id where y.agent_id = a.kullanici_id and x.puan > 0 and x.ekleme_tarihi >= current_date - 7))::text
                  from public.v_cagri_agent a left join public.cagri c on c.agent_id = a.kullanici_id and c.baslama >= current_date
                 where a.aktif = 1 group by a.kullanici_id, a.agent_adi order by a.agent_adi
                """, [], iptal);
            return Json(new { kpi, agentlar, kuyruklar, saatlik, konular, kalite, aktif, agentGun });
        });

        // Süpervizör: agent durumunu değiştir (mola bitir, çıkışa al) ya da kuyruğa ekle.
        grup.MapPost("/supervizor/agent/{kullaniciId:int}", async (int kullaniciId, JsonNode g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.supervizor", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            if (g["durum"] is JsonValue d)
                await b.CalistirAsync("update public.cagri_agent set durum = @p1, durum_zaman = now(), degistiren = @p2, degistirme_tarihi = now() where kullanici_id = @p0", null, [kullaniciId, (short)d.GetValue<int>(), baglam.KullaniciId], iptal);
            if (g["kuyrukId"] is JsonValue k)
                await b.CalistirAsync("update public.cagri_agent set kuyruklar = (coalesce(nullif(kuyruklar, ''), '[]')::jsonb || to_jsonb(array[@p1::int]))::text where kullanici_id = @p0 and not (coalesce(nullif(kuyruklar, ''), '[]')::jsonb @> to_jsonb(array[@p1::int]))", null, [kullaniciId, k.GetValue<int>()], iptal);
            return Results.Ok(new { kullaniciId });
        });
    }

    private static void SantralUclari(RouteGroupBuilder grup)
    {
        grup.MapGet("/santral", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var sube = baglam.SubeId ?? 0;
            await SantralSaglaAsync(b, sube, iptal);
            var ayar = await JsonTekAsync(b, """
                select json_build_object('subeId', sube_id, 'saglayici', saglayici, 'apiAdres', api_adres, 'kimlik', kimlik, 'gizliVar', gizli <> '', 'webhookAnahtar', webhook_anahtar,
                        'kayitKaynak', kayit_kaynak, 'kvkkAnons', kvkk_anons, 'kayitSaklamaAy', kayit_saklama_ay, 'ivr', ivr::json, 'calisma', calisma::json, 'mesaiDisiMesaj', mesai_disi_mesaj,
                        'whatsappNo', whatsapp_no, 'whatsappTokenVar', whatsapp_token <> '', 'botIlkYanit', bot_ilk_yanit, 'epostaAdres', eposta_adres, 'islemSonrasiSn', islem_sonrasi_sn,
                        'durum', durum, 'sonOlay', son_olay)::text
                  from public.cagri_santral where sube_id = @p0
                """, [sube], iptal);
            var agentlar = await JsonListeAsync(b, "select row_to_json(a)::text from public.v_cagri_agent a order by a.dahili", [], iptal);
            var kuyruklar = await JsonListeAsync(b, "select row_to_json(q)::text from public.v_cagri_kuyruk q order by q.sira", [], iptal);
            var istek = ctx.Request;
            var webhookUrl = $"{istek.Scheme}://{istek.Host}/api/acik/cagri/olay/{{saglayici}}?anahtar=…";
            return Json(new { ayar, agentlar, kuyruklar, webhookUrl });
        });

        // Boş / null gelen alan değişmez; gizli anahtarlar yalnız dolu gelince yazılır.
        grup.MapPost("/santral", async (SantralIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.ayar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sube = baglam.SubeId ?? 0;
            await SantralSaglaAsync(b, sube, iptal);
            await b.CalistirAsync("""
                update public.cagri_santral
                   set saglayici = coalesce(@p1::text, saglayici), api_adres = coalesce(@p2::text, api_adres), kimlik = coalesce(@p3::text, kimlik),
                       gizli = case when @p4::text is null or @p4::text = '' then gizli else @p4::text end, kayit_kaynak = coalesce(@p5::text, kayit_kaynak), kvkk_anons = coalesce(@p6::smallint, kvkk_anons),
                       kayit_saklama_ay = coalesce(@p7::int, kayit_saklama_ay), ivr = coalesce(@p8::text, ivr), calisma = coalesce(@p9::text, calisma), mesai_disi_mesaj = coalesce(@p10::text, mesai_disi_mesaj),
                       whatsapp_no = coalesce(@p11::text, whatsapp_no), whatsapp_token = case when @p12::text is null or @p12::text = '' then whatsapp_token else @p12::text end,
                       bot_ilk_yanit = coalesce(@p13::text, bot_ilk_yanit), eposta_adres = coalesce(@p14::text, eposta_adres), islem_sonrasi_sn = coalesce(@p15::int, islem_sonrasi_sn),
                       degistiren = @p16, degistirme_tarihi = now()
                 where sube_id = @p0
                """, null, [sube, g.Saglayici, g.ApiAdres, g.Kimlik, g.Gizli, g.KayitKaynak, g.KvkkAnons, g.KayitSaklamaAy, g.Ivr?.ToJsonString(), g.Calisma?.ToJsonString(),
                            g.MesaiDisiMesaj, g.WhatsappNo, g.WhatsappToken, g.BotIlkYanit, g.EpostaAdres, g.IslemSonrasiSn, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogCagri, sube, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { santral = true, g.Saglayici }, iptal: iptal);
            return Results.Ok(new { subeId = sube });
        });

        // Bağlantı sınama: sağlayıcıya göre gerekli alanlar dolu mu; gerçek ağ çağrısı sürücü
        //   eklenince (3CX HTTP API / Asterisk AMI). Şimdilik yapılandırma doğrulaması.
        grup.MapPost("/santral/sina", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.ayar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sube = baglam.SubeId ?? 0;
            await SantralSaglaAsync(b, sube, iptal);
            var s = await b.TekAsync("select saglayici, api_adres, kimlik, gizli, webhook_anahtar, son_olay from public.cagri_santral where sube_id = @p0", null, [sube],
                o => new { saglayici = o.GetString(0), adres = o.GetString(1), kimlik = o.GetString(2), gizli = o.GetString(3), anahtar = o.GetString(4), sonOlay = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Santral ayarı bulunamadı.");
            var eksik = new List<string>();
            var apiliSaglayici = s.saglayici is "3cx" or "asterisk";
            if (s.saglayici == "yok") eksik.Add("sağlayıcı seçilmedi");
            if (apiliSaglayici && s.adres == "") eksik.Add("API adresi");
            if (apiliSaglayici && (s.kimlik == "" || s.gizli == "")) eksik.Add("kimlik / gizli anahtar");
            if (s.anahtar == "") eksik.Add("webhook anahtarı");
            var bagli = eksik.Count == 0;
            await b.CalistirAsync("update public.cagri_santral set durum = @p1 where sube_id = @p0", null, [sube, bagli ? (short)1 : (short)0], iptal);
            return Results.Ok(new { bagli, eksik, sonOlay = s.sonOlay, not_ = bagli ? "Yapılandırma tam; santralden ilk olay gelince 'son olay' dolar." : "Eksik alanlar var." });
        });

        grup.MapPost("/santral/anahtar-yenile", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.ayar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sube = baglam.SubeId ?? 0;
            await SantralSaglaAsync(b, sube, iptal);
            var anahtar = AnahtarUret();
            await b.CalistirAsync("update public.cagri_santral set webhook_anahtar = @p1, degistiren = @p2, degistirme_tarihi = now() where sube_id = @p0", null, [sube, anahtar, baglam.KullaniciId], iptal);
            return Results.Ok(new { webhookAnahtar = anahtar });
        });
    }
}
