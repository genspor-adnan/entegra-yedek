using System.Text.Json;
using System.Text.Json.Nodes;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇAĞRI MERKEZİ (839) — liste/kart dışı uçlar. Mockuplar Ekranlar/CagriMerkezi.
///
///   /api/cagri/pano            operatör panosu: agent durumu, kuyruk, bugünkü çağrılar, aktif çağrı
///   /api/cagri/arayan          arayan tanıma: numara → taraf adayları + seçili kişinin özeti
///   /api/cagri/baslat|{id}/ustlen|{id}/kapat|{id}/ilgili|{id}/not|{id}/mesaj   çağrı akışı
///   /api/cagri/{id}            çağrı kartı (olaylar, ilgili kayıtlar, kalite, kişinin geçmişi)
///   /api/cagri/{id}/kalite|ozet   kalite değerlendirme, kural tabanlı özet (model bağlı değil)
///   /api/cagri/geri-arama      geri arama listesi: söz + kaçan + kampanya adımı
///   /api/cagri/kampanya/{id}/uret|calistir|durdur, /kampanya-kisi/{id}/sonuc
///   /api/cagri/supervizor      canlı KPI, agentlar, kuyruklar, saatlik, konu dağılımı, kalite
///   /api/cagri/santral         şubenin santral / kanal ayarı
///   /api/acik/cagri/olay/{saglayici}?anahtar=   ANONİM santral webhook'u (ringing/answered/hold/
///                              unhold/transfer/hangup); anahtar cagri_santral.webhook_anahtar.
///
/// Softphone yok: masaüstü telefon çalar, santral olayı ekranı açar. Şikayet =
/// GÖREV (tur 1, kategori "Şikayet"); geri arama = GÖREV (tur 2) + cagri.geri_arama.
/// </summary>
public static class CagriUclari
{
    private const int LogCagri = 1330;
    private const int LogKampanya = 1336;
    private const int LogKalite = 1338;

    public sealed record AgentDurumIstegi(short Durum, short? MolaSebep);
    public sealed record BaslatIstegi(short? Kanal, short? Yon, string? ArayanNo, int? TarafId, int? KuyrukId, int? KampanyaKisiId);
    public sealed record KapatIstegi(int? KonuId, int? AltKonuId, short? Sonuc, string? Notu, short? Oncelik, int? TarafId,
                                     DateTime? GeriArama, string? GorevKonu, short? Memnuniyet);
    public sealed record IlgiliIstegi(string KaynakTur, int KaynakId, string? Aciklama);
    public sealed record NotIstegi(string Metin);
    public sealed record MesajIstegi(string Sablon, string? Telefon, string? Tutar, string? Baglanti, string? Saat);
    public sealed record KaliteIstegi(short Puan, JsonNode? Olcutler, string? Notu);
    public sealed record KisiSonucIstegi(short Durum, string? Sonuc, int? CagriId);
    public sealed record SantralIstegi(string? Saglayici, string? ApiAdres, string? Kimlik, string? Gizli, string? KayitKaynak, short? KvkkAnons,
                                       int? KayitSaklamaAy, JsonNode? Ivr, JsonNode? Calisma, string? MesaiDisiMesaj, string? WhatsappNo,
                                       string? WhatsappToken, string? BotIlkYanit, string? EpostaAdres, int? IslemSonrasiSn);
    public sealed record OlayIstegi(string Olay, string? Ref, string? Arayan, string? Aranan, string? Kuyruk, string? Dahili, int? SureSn, string? KayitUrl, string? Hedef);

    public static void CagriUclariniEkle(this IEndpointRouteBuilder yol)
    {
        YetkiliUclar(yol.MapGroup("/api/cagri").WithTags("Çağrı Merkezi").RequireAuthorization());
        AcikUclar(yol.MapGroup("/api/acik/cagri").WithTags("Çağrı Merkezi (santral)").AllowAnonymous());
    }

    // =========================================================== yetkili ====
    private static void YetkiliUclar(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------------- pano ----
        grup.MapGet("/pano", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            await IslemSonrasiKapatAsync(b, baglam.KullaniciId, iptal);
            var agent = await b.TekAsync("select row_to_json(a)::text from public.v_cagri_agent a where a.kullanici_id = @p0", null, [baglam.KullaniciId], o => o.GetString(0), iptal);
            var kuyruklar = await b.ListeAsync("select row_to_json(q)::text from public.v_cagri_kuyruk q where q.aktif = 1 order by q.sira", null, [], o => o.GetString(0), iptal);
            var bekleyen = await b.ListeAsync("select row_to_json(c)::text from public.v_cagri c where c.durum in (1, 3, 7) order by c.baslama limit 30", null, [], o => o.GetString(0), iptal);
            var bugun = await b.ListeAsync("select row_to_json(c)::text from public.v_cagri c where c.agent_id = @p0 and c.baslama >= current_date order by c.baslama desc limit 40",
                null, [baglam.KullaniciId], o => o.GetString(0), iptal);
            var aktif = await b.TekAsync("select row_to_json(c)::text from public.v_cagri c where c.agent_id = @p0 and c.durum in (2, 3, 4) order by c.baslama desc limit 1",
                null, [baglam.KullaniciId], o => o.GetString(0), iptal);
            var ozet = await b.TekAsync("""
                select count(*), coalesce(avg(sure_sn) filter (where sure_sn > 0), 0)::int,
                       count(*) filter (where durum = 6),
                       (select count(*) from public.cagri where durum in (1, 3, 7)),
                       (select count(*) from public.cagri x where x.baslama >= current_date and x.cevap is not null),
                       (select count(*) from public.cagri x where x.baslama >= current_date and x.cevap is not null and x.bekleme_sn <= 20)
                  from public.cagri c where c.agent_id = @p0 and c.baslama >= current_date
                """, null, [baglam.KullaniciId], o => new
            {
                cagri = o.GetInt64(0), ortSureSn = o.GetInt32(1), kacan = o.GetInt64(2), bekleyen = o.GetInt64(3),
                gunCevaplanan = o.GetInt64(4), gunSla = o.GetInt64(5),
            }, iptal);
            var konular = await b.ListeAsync("select row_to_json(k)::text from public.v_cagri_konu k where k.aktif = 1 order by coalesce(k.ust_id, k.id), k.ust_id nulls first, k.sira", null, [], o => o.GetString(0), iptal);
            return Json(new
            {
                agent = Parse(agent), kuyruklar = ParseList(kuyruklar), bekleyen = ParseList(bekleyen), bugun = ParseList(bugun), aktif = Parse(aktif), ozet,
                konular = ParseList(konular),
            });
        });

        // Agent durumu: hazır / mola / çıkış (çağrıda ve işlem sonrası sistem koyar).
        grup.MapPost("/agent/durum", async (AgentDurumIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.pano", Islem.Gor);
            if (g.Durum is not (1 or 4 or 5)) throw GentegreHatasi.IsKurali("Durum yalnız Hazır / Mola / Çıkış seçilebilir.");
            if (g.Durum == 4 && (g.MolaSebep ?? 0) == 0) throw GentegreHatasi.IsKurali("Mola sebebi zorunlu.");
            await using var b = await veri.AcAsync(iptal);
            await AgentSaglaAsync(b, baglam, iptal);
            await b.CalistirAsync("update public.cagri_agent set durum = @p1, mola_sebep = @p2, durum_zaman = now(), degistiren = @p0, degistirme_tarihi = now() where kullanici_id = @p0",
                null, [baglam.KullaniciId, g.Durum, g.Durum == 4 ? g.MolaSebep ?? (short)0 : (short)0], iptal);
            return Results.Ok(new { durum = g.Durum });
        });

        // ------------------------------------------------ arayan tanıma ----
        grup.MapGet("/arayan", async (string? telefon, int? tarafId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var adaylar = string.IsNullOrWhiteSpace(telefon) ? [] :
                await b.ListeAsync("select row_to_json(x)::text from public.fn_cagri_arayan_bul(@p0) x", null, [telefon], o => o.GetString(0), iptal);
            var secili = tarafId ?? (adaylar.Count > 0 ? (int?)JsonNode.Parse(adaylar[0])!["taraf_id"]!.GetValue<int>() : null);
            object? ozet = secili is null ? null : await KisiOzetiAsync(b, secili.Value, iptal);
            var sonCagrilar = await b.ListeAsync("""
                select row_to_json(c)::text from public.v_cagri c
                 where (@p0::int is not null and c.taraf_id = @p0) or (@p1 <> '' and public.fn_cagri_tel_anahtar(c.arayan_no) = @p1)
                 order by c.baslama desc limit 5
                """, null, [secili, TelAnahtar(telefon)], o => o.GetString(0), iptal);
            return Json(new { adaylar = ParseList(adaylar), tarafId = secili, ozet, sonCagrilar = ParseList(sonCagrilar) });
        });

        // ---------------------------------------------------- çağrı akışı ----
        // Elle başlatılan çağrı (tıkla-ara, WhatsApp/e-posta kaydı, santralsiz kurulum).
        grup.MapPost("/baslat", async (BaslatIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            await AgentSaglaAsync(b, baglam, iptal);
            var acik = await b.TekDegerAsync<int?>("select id from public.cagri where agent_id = @p0 and durum in (2, 3) order by id desc limit 1", null, [baglam.KullaniciId], iptal);
            if (acik is not null) throw GentegreHatasi.IsKurali($"Açık çağrınız var (#{acik}); önce onu kapatın.");
            var tel = (g.ArayanNo ?? "").Trim();
            int? tarafId = g.TarafId;
            if (tarafId is null && tel != "")
                tarafId = await b.TekDegerAsync<int?>("select taraf_id from public.fn_cagri_arayan_bul(@p0) limit 1", null, [tel], iptal);
            if (tel == "" && tarafId is not null)
                tel = await b.TekDegerAsync<string>("select coalesce(nullif(cep_tel, ''), telefon, '') from public.taraf where id = @p0", null, [tarafId], iptal) ?? "";
            var id = await b.TekDegerAsync<int>("""
                insert into public.cagri (kanal, yon, arayan_no, taraf_id, kuyruk_id, agent_id, baslama, cevap, durum, kampanya_kisi_id, kampanya_id, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, now(), now(), 2, @p6,
                        (select kampanya_id from public.cagri_kampanya_kisi where id = @p6), @p7, @p5) returning id
                """, null, [g.Kanal ?? (short)1, g.Yon ?? (short)2, tel, tarafId, g.KuyrukId, baglam.KullaniciId, g.KampanyaKisiId, baglam.SubeId ?? 0], iptal);
            await OlayYazAsync(b, id, 2, baglam.KullaniciId, g.Yon == 1 ? "Elle kaydedildi" : "Tıkla-ara", "", iptal);
            if (g.KampanyaKisiId is not null)
                await b.CalistirAsync("update public.cagri_kampanya_kisi set deneme = deneme + 1, son_deneme = now(), cagri_id = @p1 where id = @p0", null, [g.KampanyaKisiId, id], iptal);
            await b.CalistirAsync("update public.cagri_agent set durum = 2, durum_zaman = now() where kullanici_id = @p0", null, [baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Ekle, LogCagri, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { kanal = g.Kanal, yon = g.Yon, tel }, tarafId: tarafId, iptal: iptal);
            return Results.Ok(new { id, tarafId });
        });

        // Kuyruktaki çağrıyı üstlen (santral cevaplama olayı gelmediyse ya da elle).
        grup.MapPost("/{id:int}/ustlen", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await AgentSaglaAsync(b, baglam, iptal);
            var n = await b.CalistirAsync("""
                update public.cagri set agent_id = @p1, cevap = coalesce(cevap, now()), bekleme_sn = extract(epoch from (coalesce(cevap, now()) - baslama))::int,
                       durum = 2, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum in (1, 3, 7)
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Çağrı beklemede değil.");
            await OlayYazAsync(b, id, 2, baglam.KullaniciId, "Üstlenildi", "", iptal);
            await b.CalistirAsync("update public.cagri_agent set durum = 2, durum_zaman = now() where kullanici_id = @p0", null, [baglam.KullaniciId], iptal);
            return Results.Ok(new { id });
        });

        // Kaydet & kapat: konu/sonuç/not; geri arama → görev (tur 2); şikayet → görev (tur 1).
        grup.MapPost("/{id:int}/kapat", async (int id, KapatIstegi g, VeriKaynagi veri, LogDeposu log, BildirimDeposu bildirim, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("select durum, taraf_id, arayan_no, kampanya_kisi_id, agent_id, gorev_id from public.cagri where id = @p0", null, [id],
                o => new { durum = o.GetInt16(0), tarafId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), tel = o.GetString(2), kisiId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), agentId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), gorevId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            if (g.KonuId is null) throw GentegreHatasi.IsKurali("Konu seçilmeden çağrı kapatılamaz.");
            if (g.Sonuc == 2 && g.GeriArama is null) throw GentegreHatasi.IsKurali("\"Geri aranacak\" için tarih/saat zorunlu.");
            var tarafId = g.TarafId ?? c.tarafId;
            var ad = tarafId is null ? c.tel : await b.TekDegerAsync<string>("select coalesce(nullif(trim(coalesce(ad,'')||' '||coalesce(soyad,'')),''), unvan, '') from public.taraf where id = @p0", null, [tarafId], iptal) ?? c.tel;
            int? gorevId = c.gorevId;
            if (g.Sonuc == 2 && g.GeriArama is not null)
            {
                // gorev.termin/hatirlatma timestamptz: istemci yerel saat gönderir (offset yok) -> UTC'ye çevrilir.
                var geriUtc = DateTime.SpecifyKind(g.GeriArama.Value, DateTimeKind.Local).ToUniversalTime();
                gorevId = (int)await b.TekDegerAsync<long>("""
                    insert into public.gorev (konu, aciklama, tur, oncelik, durum, sorumlu_id, acan_id, taraf_id, termin, hatirlatma, sube_id, ekleyen)
                    values (@p0, @p1, 2, @p2, 0, @p3, @p3, @p4, @p5, @p5, @p6, @p3) returning id
                    """, null, [$"Geri ara: {ad} · {c.tel}", $"Çağrı #{id}. {g.Notu ?? ""}", (short)(g.Oncelik ?? 1), c.agentId ?? baglam.KullaniciId, tarafId, geriUtc, baglam.SubeId ?? 0], iptal);
                await IlgiliEkleAsync(b, id, "gorev", gorevId.Value, "Geri arama görevi", baglam.KullaniciId, iptal);
            }
            if (!string.IsNullOrWhiteSpace(g.GorevKonu))
            {
                var sid = (int)await b.TekDegerAsync<long>("""
                    insert into public.gorev (konu, aciklama, tur, oncelik, durum, sorumlu_id, acan_id, taraf_id, termin, sube_id, ekleyen)
                    values (@p0, @p1, 1, 2, 0, @p2, @p2, @p3, now() + interval '2 days', @p4, @p2) returning id
                    """, null, [g.GorevKonu!.Trim(), $"Çağrı #{id} · {ad} · {c.tel}\n{g.Notu ?? ""}", baglam.KullaniciId, tarafId, baglam.SubeId ?? 0], iptal);
                await IlgiliEkleAsync(b, id, "gorev", sid, "Şikayet / öneri görevi (48 saat)", baglam.KullaniciId, iptal);
                gorevId ??= sid;
            }
            await b.CalistirAsync("""
                update public.cagri
                   set konu_id = @p1, alt_konu_id = @p2, sonuc = @p3, notu = @p4, oncelik = coalesce(@p5, oncelik), taraf_id = @p6,
                       geri_arama = @p7, gorev_id = @p8, memnuniyet = coalesce(@p9, memnuniyet),
                       bitis = coalesce(bitis, now()), sure_sn = case when cevap is null then sure_sn else extract(epoch from (coalesce(bitis, now()) - cevap))::int end,
                       islem_sonrasi_sn = case when bitis is null then 0 else extract(epoch from (now() - bitis))::int end,
                       durum = 5, degistiren = @p10, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.KonuId, g.AltKonuId, g.Sonuc ?? (short)1, (g.Notu ?? "")[..Math.Min(1200, (g.Notu ?? "").Length)], g.Oncelik, tarafId,
                            g.GeriArama is null ? null : DateTime.SpecifyKind(g.GeriArama.Value, DateTimeKind.Unspecified), gorevId, g.Memnuniyet, baglam.KullaniciId], iptal);
            await OlayYazAsync(b, id, 9, baglam.KullaniciId, "Kayıt tamamlandı", "", iptal);
            if (c.kisiId is not null)
            {
                short kd = g.Sonuc switch { 7 or 1 or 6 => 5, 4 => 3, 8 => 6, 2 => 1, _ => 4 };
                await b.CalistirAsync("update public.cagri_kampanya_kisi set durum = @p1, sonuc = @p2, cagri_id = @p3 where id = @p0", null,
                    [c.kisiId, kd, (g.Notu ?? "")[..Math.Min(200, (g.Notu ?? "").Length)], id], iptal);
            }
            if (g.Sonuc == 2 && g.GeriArama is not null && tarafId is not null && c.tel != "")
            {
                var kurum = baglam.AktifSube?.Ad ?? "GenoTIP";
                try
                {
                    await bildirim.KuyrugaEkleAsync(new BildirimIstegi("cagri.geri_arama", BildirimKanali.Sms, c.tel,
                        new Dictionary<string, string> { ["ad"] = ad, ["saat"] = g.GeriArama.Value.ToString("dd.MM HH:mm"), ["kurum"] = kurum },
                        TarafId: tarafId, KaynakTur: 41, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
                }
                catch (InvalidOperationException) { /* şablon pasif / kanal yok: sessiz */ }
            }
            if (c.agentId == baglam.KullaniciId)
                await b.CalistirAsync("update public.cagri_agent set durum = 3, durum_zaman = now() where kullanici_id = @p0 and durum = 2", null, [baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogCagri, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { g.KonuId, g.Sonuc, g.GeriArama, gorevId }, tarafId: tarafId, iptal: iptal);
            return Results.Ok(new { id, gorevId, durum = 5 });
        });

        grup.MapPost("/{id:int}/ilgili", async (int id, IlgiliIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var iid = await IlgiliEkleAsync(b, id, g.KaynakTur, g.KaynakId, g.Aciklama ?? "", baglam.KullaniciId, iptal);
            return Results.Ok(new { id = iid });
        });

        grup.MapPost("/{id:int}/not", async (int id, NotIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await OlayYazAsync(b, id, 7, baglam.KullaniciId, g.Metin.Trim(), "", iptal);
            return Results.Ok(new { id });
        });

        // Hızlı mesaj: ödeme linki / yol tarifi / anket / geri arama bilgisi (bildirim kuyruğu).
        grup.MapPost("/{id:int}/mesaj", async (int id, MesajIstegi g, VeriKaynagi veri, BildirimDeposu bildirim, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("select taraf_id, arayan_no, taraf_adi from public.v_cagri where id = @p0", null, [id],
                o => new { tarafId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), tel = o.GetString(1), ad = o.GetString(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            var tel = string.IsNullOrWhiteSpace(g.Telefon) ? c.tel : g.Telefon!.Trim();
            if (tel == "") throw GentegreHatasi.IsKurali("Telefon numarası yok.");
            var sablon = g.Sablon switch { "odeme_linki" => "cagri.odeme_linki", "yol_tarifi" => "cagri.yol_tarifi", "anket" => "cagri.anket", "geri_arama" => "cagri.geri_arama", _ => throw GentegreHatasi.IsKurali("Bilinmeyen mesaj şablonu.") };
            var kurum = baglam.AktifSube?.Ad ?? "GenoTIP";
            var adres = await b.TekDegerAsync<string>("select coalesce(adres, '') from public.sube where id = @p0", null, [baglam.SubeId ?? 0], iptal) ?? "";
            long? bid;
            try
            {
                bid = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(sablon, null, tel, new Dictionary<string, string>
                {
                    ["ad"] = c.ad == "" ? "Sayın müşterimiz" : c.ad, ["kurum"] = kurum, ["tutar"] = g.Tutar ?? "", ["baglanti"] = g.Baglanti ?? "",
                    ["saat"] = g.Saat ?? "", ["adres"] = adres, ["konum"] = g.Baglanti ?? "",
                }, TarafId: c.tarafId, KaynakTur: 41, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (InvalidOperationException h) { throw GentegreHatasi.IsKurali(h.Message); }
            if (bid is not null) await IlgiliEkleAsync(b, id, "bildirim", (int)bid.Value, $"{g.Sablon} → {tel}", baglam.KullaniciId, iptal);
            await OlayYazAsync(b, id, 8, baglam.KullaniciId, $"{g.Sablon} gönderildi ({tel})", "", iptal);
            return Results.Ok(new { bildirimId = bid });
        });

        // ------------------------------------------------------ çağrı kartı ----
        grup.MapGet("/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("select row_to_json(c)::text from public.v_cagri c where c.id = @p0", null, [id], o => o.GetString(0), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            var cj = JsonNode.Parse(c)!;
            var olaylar = await b.ListeAsync("""
                select json_build_object('id', o.id, 'tur', o.tur, 'turAdi', coalesce(k.ad, ''), 'zaman', o.zaman, 'agentId', o.agent_id, 'agentAdi', coalesce(u.ad, ''), 'aciklama', o.aciklama)::text
                  from public.cagri_olay o
                  left join public.kod_liste l on l.kod = 'cagri.olay_tur' left join public.kod_deger k on k.liste_id = l.id and k.deger = o.tur
                  left join public.v_kullanici_lookup u on u.id = o.agent_id
                 where o.cagri_id = @p0 order by o.zaman, o.id
                """, null, [id], o => o.GetString(0), iptal);
            var ilgili = await b.ListeAsync("select json_build_object('id', i.id, 'kaynakTur', i.kaynak_tur, 'kaynakId', i.kaynak_id, 'aciklama', i.aciklama, 'zaman', i.ekleme_tarihi)::text from public.cagri_ilgili i where i.cagri_id = @p0 order by i.id",
                null, [id], o => o.GetString(0), iptal);
            var kalite = await b.TekAsync("select row_to_json(k)::text from public.v_cagri_kalite k where k.cagri_id = @p0", null, [id], o => o.GetString(0), iptal);
            var tarafId = cj["taraf_id"]?.GetValue<int?>();
            var tel = cj["arayan_no"]?.ToString() ?? "";
            var gecmis = await b.ListeAsync("""
                select row_to_json(c)::text from public.v_cagri c
                 where c.id <> @p0 and ((@p1::int is not null and c.taraf_id = @p1) or (@p2 <> '' and public.fn_cagri_tel_anahtar(c.arayan_no) = @p2))
                 order by c.baslama desc limit 10
                """, null, [id, tarafId, TelAnahtar(tel)], o => o.GetString(0), iptal);
            object? ozet = tarafId is null ? null : await KisiOzetiAsync(b, tarafId.Value, iptal);
            return Json(new { cagri = cj, olaylar = ParseList(olaylar), ilgili = ParseList(ilgili), kalite = Parse(kalite), gecmis = ParseList(gecmis), ozet });
        });

        grup.MapPost("/{id:int}/kalite", async (int id, KaliteIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kalite", Islem.Ekle);
            if (g.Puan is < 0 or > 100) throw GentegreHatasi.IsKurali("Puan 0-100 arası olmalı.");
            await using var b = await veri.AcAsync(iptal);
            var kid = await b.TekDegerAsync<int>("""
                insert into public.cagri_kalite (cagri_id, degerlendiren, puan, olcutler, notu, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p1)
                on conflict (cagri_id) do update set degerlendiren = excluded.degerlendiren, puan = excluded.puan, olcutler = excluded.olcutler, notu = excluded.notu,
                                                     degistiren = excluded.ekleyen, degistirme_tarihi = now()
                returning id
                """, null, [id, baglam.KullaniciId, g.Puan, g.Olcutler?.ToJsonString() ?? "[]", (g.Notu ?? "")[..Math.Min(600, (g.Notu ?? "").Length)]], iptal);
            await b.CalistirAsync("update public.cagri set kalite_puan = @p1 where id = @p0", null, [id, g.Puan], iptal);
            await log.YazAsync(LogIslemi.Ekle, LogKalite, kid, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { cagriId = id, g.Puan }, iptal: iptal);
            return Results.Ok(new { id = kid, g.Puan });
        });

        // KURAL TABANLI ÖZET (model bağlı DEĞİL): konu, sonuç, not, ilgili kayıtlar ve
        //   sürelerden özet metni üretir; cagri_kalite.ozet_ai'ye yazar. Model
        //   anahtarı/kontör bağlandığında aynı alan doldurulur.
        grup.MapPost("/{id:int}/ozet", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kalite", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("select row_to_json(c)::text from public.v_cagri c where c.id = @p0", null, [id], o => o.GetString(0), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            var cj = JsonNode.Parse(c)!;
            var ilgili = await b.ListeAsync("select kaynak_tur || ' #' || kaynak_id || case when aciklama <> '' then ' (' || aciklama || ')' else '' end from public.cagri_ilgili where cagri_id = @p0 order by id", null, [id], o => o.GetString(0), iptal);
            var parcalar = new List<string>();
            var kisi = cj["taraf_adi"]?.ToString(); if (string.IsNullOrEmpty(kisi)) kisi = cj["arayan_no"]?.ToString();
            parcalar.Add($"{cj["yon_adi"]} {cj["kanal_adi"]?.ToString()?.ToLowerInvariant()} çağrısı · {kisi}");
            var konu = cj["konu_adi"]?.ToString(); var alt = cj["alt_konu_adi"]?.ToString();
            if (!string.IsNullOrEmpty(konu)) parcalar.Add($"Konu: {konu}{(string.IsNullOrEmpty(alt) ? "" : " › " + alt)}");
            var sonuc = cj["sonuc_adi"]?.ToString(); if (!string.IsNullOrEmpty(sonuc)) parcalar.Add($"Sonuç: {sonuc}");
            var notu = cj["notu"]?.ToString(); if (!string.IsNullOrEmpty(notu)) parcalar.Add($"Not: {notu}");
            if (ilgili.Count > 0) parcalar.Add("Açılan kayıtlar: " + string.Join(", ", ilgili));
            var bekleme = cj["bekleme_sn"]?.GetValue<int>() ?? 0; var sure = cj["sure_sn"]?.GetValue<int>() ?? 0;
            parcalar.Add($"Bekleme {bekleme} sn · konuşma {sure / 60}:{sure % 60:00}" + (bekleme > 60 ? " · UZUN BEKLEME" : ""));
            var ga = cj["geri_arama"]?.ToString(); if (!string.IsNullOrEmpty(ga)) parcalar.Add($"Aksiyon: geri arama {ga}");
            var ozet = string.Join(". ", parcalar) + ".";
            await b.CalistirAsync("""
                insert into public.cagri_kalite (cagri_id, ozet_ai, ekleyen) values (@p0, @p1, @p2)
                on conflict (cagri_id) do update set ozet_ai = excluded.ozet_ai, degistiren = excluded.ekleyen, degistirme_tarihi = now()
                """, null, [id, ozet[..Math.Min(1500, ozet.Length)], baglam.KullaniciId], iptal);
            return Results.Ok(new { ozet, kaynak = "kural" });
        });

        // ------------------------------------------------- geri arama listesi ----
        // Üç kaynak tek listede: (a) "geri aranacak" sözü (cagri.geri_arama), (b) kaçan çağrı
        //   (durum 6, aynı numara sonradan aranmamış), (c) kampanya kişisi (aranacak = 1).
        grup.MapGet("/geri-arama", async (string? tur, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.giden", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var suzgec = tur ?? "bugun";
            var satirlar = await b.ListeAsync("""
                with l as (
                  select 'soz' as kaynak, c.id as cagri_id, null::int as kisi_id, null::int as kampanya_id, c.taraf_id, c.taraf_adi as ad, c.arayan_no as telefon,
                         coalesce(c.konu_adi, '') || case when c.alt_konu_adi <> '' then ' › ' || c.alt_konu_adi else '' end as konu, c.notu as notu,
                         c.geri_arama as zaman, c.agent_id, c.agent_adi, 'Geri arama sözü' as kaynak_adi, c.gorev_id
                    from public.v_cagri c where c.sonuc = 2 and c.geri_arama is not null and c.geri_arama_tamam = 0
                  union all
                  select 'kacan', c.id, null, null, c.taraf_id, c.taraf_adi, c.arayan_no, coalesce(c.kuyruk_adi, ''),
                         'Kaçan çağrı · ' || c.bekleme_sn || ' sn bekledi', c.baslama, null, '', 'Kaçan çağrı', null
                    from public.v_cagri c
                   where c.durum = 6 and c.geri_arama_tamam = 0 and c.baslama >= current_date - 2
                     and not exists (select 1 from public.cagri g where g.yon = 2 and g.baslama > c.baslama and public.fn_cagri_tel_anahtar(g.arayan_no) = public.fn_cagri_tel_anahtar(c.arayan_no))
                  union all
                  select 'kampanya', x.cagri_id, x.id, p.id, x.taraf_id, x.ad, x.telefon, 'Kampanya › ' || x.kampanya_adi, x.ozet,
                         coalesce(x.son_deneme, x.ekleme_tarihi), null, '', 'Kampanya adımı', null
                    from public.v_cagri_kampanya_kisi x join public.cagri_kampanya p on p.id = x.kampanya_id
                   where p.durum = 1 and x.aranacak = 1
                )
                select json_build_object('kaynak', l.kaynak, 'kaynakAdi', l.kaynak_adi, 'cagriId', l.cagri_id, 'kisiId', l.kisi_id, 'kampanyaId', l.kampanya_id, 'tarafId', l.taraf_id, 'ad', l.ad,
                                         'telefon', l.telefon, 'konu', l.konu, 'notu', l.notu, 'zaman', l.zaman, 'agentId', l.agent_id, 'agentAdi', l.agent_adi,
                                         'gecikmis', case when l.zaman < now() - interval '1 hour' then 1 else 0 end, 'gorevId', l.gorev_id)::text
                  from l
                 where case @p0 when 'gecikmis' then l.zaman < now() - interval '1 hour'
                                when 'benim' then l.agent_id = @p1
                                when 'tumu' then true
                                else l.zaman < current_date + 1 end
                 order by l.zaman
                 limit 300
                """, null, [suzgec, baglam.KullaniciId], o => o.GetString(0), iptal);
            var ozet = await b.TekAsync("""
                select (select count(*) from public.cagri c where c.sonuc = 2 and c.geri_arama is not null and c.geri_arama_tamam = 0 and c.geri_arama < current_date + 1)
                     + (select count(*) from public.v_cagri_kampanya_kisi x join public.cagri_kampanya p on p.id = x.kampanya_id where p.durum = 1 and x.aranacak = 1),
                       (select count(*) from public.cagri where yon = 2 and baslama >= current_date),
                       (select count(*) from public.cagri where yon = 2 and baslama >= current_date and durum = 8),
                       (select count(*) from public.cagri where sonuc = 2 and baslama >= current_date),
                       (select count(*) from public.cagri where durum = 6 and baslama >= current_date and geri_arama_tamam = 0)
                """, null, [], o => new { aranacak = o.GetInt64(0), arandi = o.GetInt64(1), ulasilamadi = o.GetInt64(2), soz = o.GetInt64(3), kacan = o.GetInt64(4) }, iptal);
            return Json(new { ozet, satirlar = ParseList(satirlar) });
        });

        grup.MapPost("/geri-arama/{cagriId:int}/tamam", async (int cagriId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.giden", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("update public.cagri set geri_arama_tamam = 1, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [cagriId, baglam.KullaniciId], iptal);
            await b.CalistirAsync("update public.gorev set durum = 2, tamamlanma = now() where id = (select gorev_id from public.cagri where id = @p0) and tur = 2 and durum < 2", null, [cagriId], iptal);
            return Results.Ok(new { cagriId });
        });

        // ------------------------------------------------------- kampanya ----
        grup.MapGet("/kampanyalar", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var l = await b.ListeAsync("select row_to_json(p)::text from public.v_cagri_kampanya p order by p.durum, p.id desc limit 200", null, [], o => o.GetString(0), iptal);
            return Results.Content("[" + string.Join(",", l) + "]", "application/json");
        });
        grup.MapGet("/kampanya/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var p = await b.TekAsync("select row_to_json(p)::text from public.v_cagri_kampanya p where p.id = @p0", null, [id], o => o.GetString(0), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kampanya bulunamadı.");
            var kisiler = await b.ListeAsync("select row_to_json(x)::text from public.v_cagri_kampanya_kisi x where x.kampanya_id = @p0 order by x.durum, x.id limit 500", null, [id], o => o.GetString(0), iptal);
            return Json(new { kampanya = Parse(p), kisiler = ParseList(kisiler) });
        });

        // Kişi listesini kaynaktan üret (yeni kişiler eklenir; var olanlar korunur).
        grup.MapPost("/kampanya/{id:int}/uret", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await b.TekAsync("select kaynak, parametre, sube_id from public.cagri_kampanya where id = @p0", null, [id],
                o => new { kaynak = o.GetString(0), parametre = o.GetString(1), subeId = o.GetInt32(2) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Kampanya bulunamadı.");
            var esik = decimal.TryParse(p.parametre.Replace(',', '.'), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var e) ? e : 500m;
            var sql = p.kaynak switch
            {
                "randevu_yarin" => """
                    select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, ''), coalesce(nullif(t.cep_tel,''), t.telefon, ''), 'randevu', r.id,
                           to_char(r.baslangic, 'DD.MM HH24:MI') || ' ' || coalesce(d.ad, '') || case when h.ad is not null then ' · ' || h.ad else '' end
                      from public.randevu r join public.taraf t on t.id = r.hasta_id
                      left join public.v_departman_lookup d on d.id = r.bolum left join public.v_hekim_lookup h on h.id = r.hekim_id
                     where r.baslangic::date = current_date + 1 and r.durum = 1
                    """,
                "sonuc_hazir" => """
                    select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, ''), coalesce(nullif(t.cep_tel,''), t.telefon, ''), 'lab_istem', li.id,
                           'Lab sonucu hazır · ' || coalesce(li.istem_no, '') || ' · ' || to_char(li.sonuc_tarihi, 'DD.MM')
                      from public.lab_istem li join public.taraf t on t.id = li.taraf_id
                     where li.sonuc_tarihi >= now() - interval '7 days'
                    """,
                "taburcu_anket" => """
                    select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, ''), coalesce(nullif(t.cep_tel,''), t.telefon, ''), 'randevu', r.id,
                           'Ziyaret ' || to_char(r.baslangic, 'DD.MM') || ' ' || coalesce(d.ad, '')
                      from public.randevu r join public.taraf t on t.id = r.hasta_id left join public.v_departman_lookup d on d.id = r.bolum
                     where r.durum = 2 and r.baslangic >= current_date - 3
                    """,
                "vadesi_gecen" => """
                    select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, ''), coalesce(nullif(t.cep_tel,''), t.telefon, ''), 'taraf', t.id,
                           'Bakiye ' || to_char(b.bakiye, 'FM999G999G990D00') || ' TL'
                      from (select e.taraf_id, sum(e.yerel_borc) - sum(e.yerel_alacak) as bakiye from public.v_cari_ekstre e group by e.taraf_id) b
                      join public.taraf t on t.id = b.taraf_id
                     where b.bakiye > @p1
                    """,
                "isg_periyodik" => """
                    select c.hasta_id, c.calisan_adi, c.cep_tel, 'isg_calisan', c.id,
                           'Periyodik muayene vadesi ' || to_char(c.vade, 'DD.MM.YYYY') || ' · ' || c.firma_adi
                      from public.v_isg_calisan c where c.durum = 1 and c.kalan_gun <= 30
                    """,
                _ => null,
            };
            if (sql is null) return Results.Ok(new { eklenen = 0, atlanan = 0, not_ = "Serbest liste: kişiler kartın 'Kişiler' detayından eklenir." });
            var adaylar = await b.ListeAsync(sql, null, [id, esik], o => new
            {
                tarafId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), ad = o.GetString(1), tel = o.GetString(2), kaynakTur = o.GetString(3), kaynakId = o.GetInt32(4), ozet = o.GetString(5),
            }, iptal);
            int eklenen = 0, atlanan = 0;
            foreach (var a in adaylar)
            {
                if (string.IsNullOrWhiteSpace(a.tel)) { atlanan++; continue; }
                var n = await b.CalistirAsync("""
                    insert into public.cagri_kampanya_kisi (kampanya_id, taraf_id, ad, telefon, kaynak_tur, kaynak_id, ozet, durum, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, 1, @p7, @p8)
                    on conflict (kampanya_id, kaynak_tur, kaynak_id) where kaynak_id > 0 do nothing
                    """, null, [id, a.tarafId, a.ad[..Math.Min(150, a.ad.Length)], a.tel[..Math.Min(30, a.tel.Length)], a.kaynakTur, a.kaynakId, a.ozet[..Math.Min(200, a.ozet.Length)], p.subeId, baglam.KullaniciId], iptal);
                if (n > 0) eklenen++; else atlanan++;
            }
            await log.YazAsync(LogIslemi.Degistir, LogKampanya, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { uret = true, eklenen, atlanan }, iptal: iptal);
            return Results.Ok(new { eklenen, atlanan, not_ = "" });
        });

        // 1. adım: bekleyen kişilere şablon mesajı (bildirim kuyruğu); şablonsuz kampanyada
        //   kişiler doğrudan geri arama listesine düşer. Kampanya "çalışıyor" olur.
        grup.MapPost("/kampanya/{id:int}/calistir", async (int id, VeriKaynagi veri, BildirimDeposu bildirim, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await b.TekAsync("select sablon_kodu, tur from public.cagri_kampanya where id = @p0", null, [id], o => new { sablon = o.GetString(0), tur = o.GetInt16(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kampanya bulunamadı.");
            await b.CalistirAsync("update public.cagri_kampanya set durum = 1, baslama = coalesce(baslama, current_date), degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId], iptal);
            int gonderilen = 0, hata = 0;
            if (p.sablon != "")
            {
                var kurum = baglam.AktifSube?.Ad ?? "GenoTIP";
                var kisiler = await b.ListeAsync("select id, taraf_id, ad, telefon, ozet from public.cagri_kampanya_kisi where kampanya_id = @p0 and durum = 1 order by id", null, [id],
                    o => new { id = o.GetInt32(0), tarafId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), ad = o.GetString(2), tel = o.GetString(3), ozet = o.GetString(4) }, iptal);
                foreach (var k in kisiler)
                {
                    try
                    {
                        var bid = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(p.sablon, null, k.tel, new Dictionary<string, string>
                        {
                            ["ad"] = k.ad, ["kurum"] = kurum, ["tarih"] = k.ozet, ["bolum"] = "", ["tetkik"] = k.ozet, ["baglanti"] = "", ["tutar"] = k.ozet, ["saat"] = "",
                        }, TarafId: k.tarafId, KaynakTur: 42, KaynakId: k.id), baglam.KullaniciId, baglam.SubeId, iptal);
                        await b.CalistirAsync("update public.cagri_kampanya_kisi set durum = 2, deneme = deneme + 1, son_deneme = now(), bildirim_id = @p1 where id = @p0", null, [k.id, bid], iptal);
                        gonderilen++;
                    }
                    catch (InvalidOperationException) { hata++; }
                }
            }
            await log.YazAsync(LogIslemi.Degistir, LogKampanya, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { calistir = true, gonderilen, hata }, iptal: iptal);
            return Results.Ok(new { gonderilen, hata, dogrudanArama = p.sablon == "" });
        });

        grup.MapPost("/kampanya/{id:int}/durdur", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kampanya", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("update public.cagri_kampanya set durum = 2, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 1", null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { id, durum = 2 });
        });

        grup.MapPost("/kampanya-kisi/{id:int}/sonuc", async (int id, KisiSonucIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.giden", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("""
                update public.cagri_kampanya_kisi
                   set durum = @p1, sonuc = @p2, cagri_id = coalesce(@p3, cagri_id), deneme = case when @p1 = 3 then deneme + 1 else deneme end, son_deneme = now(),
                       degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.Durum, (g.Sonuc ?? "")[..Math.Min(200, (g.Sonuc ?? "").Length)], g.CagriId, baglam.KullaniciId], iptal);
            // Randevu hatırlatmada "onayladı" → randevu onaylı kalır; "iptal etti" → randevu iptal (4).
            if (g.Durum == 6)
                await b.CalistirAsync("update public.randevu set durum = 4 where id = (select kaynak_id from public.cagri_kampanya_kisi where id = @p0 and kaynak_tur = 'randevu') and durum = 1", null, [id], iptal);
            return Results.Ok(new { id, g.Durum });
        });

        // ------------------------------------------------------- süpervizör ----
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
            var agentlar = await b.ListeAsync("select row_to_json(a)::text from public.v_cagri_agent a where a.aktif = 1 order by a.durum, a.dahili", null, [], o => o.GetString(0), iptal);
            var kuyruklar = await b.ListeAsync("""
                select json_build_object('id', q.id, 'ad', q.ad, 'bekleyen', q.bekleyen, 'enUzunSn', q.en_uzun_bekleme_sn, 'hazirAgent', q.hazir_agent, 'cevaplanan', q.cevaplanan_bugun, 'kacan', q.kacan_bugun,
                    'slaSn', q.sla_sn, 'slaHedef', q.sla_hedef, 'tasmaAdi', q.tasma_adi,
                    'slaYuzde', coalesce((select round(100.0 * count(*) filter (where c.bekleme_sn <= q.sla_sn) / nullif(count(*), 0)) from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.cevap is not null), 0),
                    'ortBeklemeSn', coalesce((select avg(c.bekleme_sn)::int from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.cevap is not null), 0),
                    'ortKonusmaSn', coalesce((select avg(c.sure_sn)::int from public.cagri c where c.kuyruk_id = q.id and c.baslama >= current_date and c.sure_sn > 0), 0))::text
                  from public.v_cagri_kuyruk q where q.aktif = 1 order by q.sira
                """, null, [], o => o.GetString(0), iptal);
            var saatlik = await b.ListeAsync("""
                select json_build_object('saat', s, 'gelen', (select count(*) from public.cagri c where c.baslama >= current_date and extract(hour from c.baslama) = s),
                                         'kacan', (select count(*) from public.cagri c where c.baslama >= current_date and extract(hour from c.baslama) = s and c.durum = 6))::text
                  from generate_series(8, 18) s
                """, null, [], o => o.GetString(0), iptal);
            var konular = await b.ListeAsync("""
                select json_build_object('konu', coalesce(k.ad, '(konu yok)'), 'bugun', count(*) filter (where c.baslama >= current_date), 'hafta', count(*),
                                         'cozum', count(*) filter (where c.sonuc in (1, 6, 7)), 'geriArama', count(*) filter (where c.sonuc = 2), 'gorev', count(*) filter (where c.sonuc = 3),
                                         'ortSureSn', coalesce(avg(c.sure_sn) filter (where c.sure_sn > 0), 0)::int)::text
                  from public.cagri c left join public.cagri_konu k on k.id = c.konu_id
                 where c.baslama >= current_date - 7 group by k.ad order by count(*) desc
                """, null, [], o => o.GetString(0), iptal);
            var kalite = await b.ListeAsync("""
                select json_build_object('hafta', to_char(k.ekleme_tarihi, 'IYYY-IW'), 'sayi', count(*), 'ortPuan', avg(k.puan)::int, 'enDusuk', min(k.puan))::text
                  from public.cagri_kalite k where k.puan > 0 and k.ekleme_tarihi >= current_date - 28 group by to_char(k.ekleme_tarihi, 'IYYY-IW') order by 1 desc
                """, null, [], o => o.GetString(0), iptal);
            var aktif = await b.ListeAsync("select row_to_json(c)::text from public.v_cagri c where c.durum in (2, 3) order by c.baslama", null, [], o => o.GetString(0), iptal);
            var agentGun = await b.ListeAsync("""
                select json_build_object('agentId', a.kullanici_id, 'ad', a.agent_adi, 'cagri', count(c.id), 'cevaplanan', count(c.id) filter (where c.cevap is not null),
                        'ortKonusmaSn', coalesce(avg(c.sure_sn) filter (where c.sure_sn > 0), 0)::int, 'ortIslemSn', coalesce(avg(c.islem_sonrasi_sn) filter (where c.islem_sonrasi_sn > 0), 0)::int,
                        'randevu', count(c.id) filter (where c.sonuc = 7), 'geriArama', count(c.id) filter (where c.sonuc = 2), 'gorev', count(c.id) filter (where c.sonuc = 3),
                        'kalite', (select avg(x.puan)::int from public.cagri_kalite x join public.cagri y on y.id = x.cagri_id where y.agent_id = a.kullanici_id and x.puan > 0 and x.ekleme_tarihi >= current_date - 7))::text
                  from public.v_cagri_agent a left join public.cagri c on c.agent_id = a.kullanici_id and c.baslama >= current_date
                 where a.aktif = 1 group by a.kullanici_id, a.agent_adi order by a.agent_adi
                """, null, [], o => o.GetString(0), iptal);
            return Json(new { kpi, agentlar = ParseList(agentlar), kuyruklar = ParseList(kuyruklar), saatlik = ParseList(saatlik), konular = ParseList(konular), kalite = ParseList(kalite), aktif = ParseList(aktif), agentGun = ParseList(agentGun) });
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

        // ---------------------------------------------------------- santral ----
        grup.MapGet("/santral", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var sube = await SantralSubesiAsync(b, baglam.SubeId ?? 0, iptal);
            var s = await b.TekAsync("""
                select json_build_object('subeId', sube_id, 'saglayici', saglayici, 'apiAdres', api_adres, 'kimlik', kimlik, 'gizliVar', gizli <> '', 'webhookAnahtar', webhook_anahtar,
                        'kayitKaynak', kayit_kaynak, 'kvkkAnons', kvkk_anons, 'kayitSaklamaAy', kayit_saklama_ay, 'ivr', ivr::json, 'calisma', calisma::json, 'mesaiDisiMesaj', mesai_disi_mesaj,
                        'whatsappNo', whatsapp_no, 'whatsappTokenVar', whatsapp_token <> '', 'botIlkYanit', bot_ilk_yanit, 'epostaAdres', eposta_adres, 'islemSonrasiSn', islem_sonrasi_sn,
                        'durum', durum, 'sonOlay', son_olay)::text
                  from public.cagri_santral where sube_id = @p0
                """, null, [sube], o => o.GetString(0), iptal);
            var agentlar = await b.ListeAsync("select row_to_json(a)::text from public.v_cagri_agent a order by a.dahili", null, [], o => o.GetString(0), iptal);
            var kuyruklar = await b.ListeAsync("select row_to_json(q)::text from public.v_cagri_kuyruk q order by q.sira", null, [], o => o.GetString(0), iptal);
            var istek = ctx.Request;
            var webhook = $"{istek.Scheme}://{istek.Host}/api/acik/cagri/olay/{{saglayici}}?anahtar=…";
            return Json(new { ayar = Parse(s), agentlar = ParseList(agentlar), kuyruklar = ParseList(kuyruklar), webhookUrl = webhook });
        });

        grup.MapPost("/santral", async (SantralIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.ayar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sube = await SantralSubesiAsync(b, baglam.SubeId ?? 0, iptal);
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
            var sube = await SantralSubesiAsync(b, baglam.SubeId ?? 0, iptal);
            var s = await b.TekAsync("select saglayici, api_adres, kimlik, gizli, webhook_anahtar, son_olay from public.cagri_santral where sube_id = @p0", null, [sube],
                o => new { saglayici = o.GetString(0), adres = o.GetString(1), kimlik = o.GetString(2), gizli = o.GetString(3), anahtar = o.GetString(4), sonOlay = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5) }, iptal)!;
            var eksik = new List<string>();
            if (s.saglayici == "yok") eksik.Add("sağlayıcı seçilmedi");
            if (s.saglayici is "3cx" or "asterisk" && s.adres == "") eksik.Add("API adresi");
            if (s.saglayici is "3cx" or "asterisk" && (s.kimlik == "" || s.gizli == "")) eksik.Add("kimlik / gizli anahtar");
            if (s.anahtar == "") eksik.Add("webhook anahtarı");
            var durum = eksik.Count == 0 ? (short)1 : (short)0;
            await b.CalistirAsync("update public.cagri_santral set durum = @p1 where sube_id = @p0", null, [sube, durum], iptal);
            return Results.Ok(new { bagli = durum == 1, eksik, sonOlay = s.sonOlay, not_ = durum == 1 ? "Yapılandırma tam; santralden ilk olay gelince 'son olay' dolar." : "Eksik alanlar var." });
        });

        grup.MapPost("/santral/anahtar-yenile", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.ayar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sube = await SantralSubesiAsync(b, baglam.SubeId ?? 0, iptal);
            var anahtar = Convert.ToHexString(System.Security.Cryptography.RandomNumberGenerator.GetBytes(12)).ToLowerInvariant();
            await b.CalistirAsync("update public.cagri_santral set webhook_anahtar = @p1, degistiren = @p2, degistirme_tarihi = now() where sube_id = @p0", null, [sube, anahtar, baglam.KullaniciId], iptal);
            return Results.Ok(new { webhookAnahtar = anahtar });
        });
    }

    // ============================================================= açık ====
    private static void AcikUclar(RouteGroupBuilder grup)
    {
        // SANTRAL WEBHOOK'U: sağlayıcıdan gelen olay. Anahtar cagri_santral.webhook_anahtar
        //   (herhangi bir şube). Olaylar: ringing · answered · hold · unhold · transfer · hangup.
        //   `ref` santralin çağrı kimliği - aynı ref ikinci kez gelirse mevcut kayıt güncellenir.
        grup.MapPost("/olay/{saglayici}", async (string saglayici, string? anahtar, OlayIstegi g, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            var sube = string.IsNullOrWhiteSpace(anahtar) ? null :
                await b.TekDegerAsync<int?>("select sube_id from public.cagri_santral where webhook_anahtar = @p0 and webhook_anahtar <> ''", null, [anahtar], iptal);
            if (sube is null) return Results.Unauthorized();
            await b.CalistirAsync("update public.cagri_santral set son_olay = now(), durum = 1 where sube_id = @p0", null, [sube], iptal);
            var olay = (g.Olay ?? "").Trim().ToLowerInvariant();
            var reff = (g.Ref ?? "").Trim();
            var kuyrukId = string.IsNullOrWhiteSpace(g.Kuyruk) ? null :
                await b.TekDegerAsync<int?>("select id from public.cagri_kuyruk where santral_kodu = @p0 or lower(ad) = lower(@p0) limit 1", null, [g.Kuyruk!.Trim()], iptal);
            var agentId = string.IsNullOrWhiteSpace(g.Dahili) ? null :
                await b.TekDegerAsync<int?>("select kullanici_id from public.cagri_agent where dahili = @p0 and aktif = 1 limit 1", null, [g.Dahili!.Trim()], iptal);
            int? id = reff == "" ? null : await b.TekDegerAsync<int?>("select id from public.cagri where dis_ref = @p0", null, [reff], iptal);
            var veriMetni = JsonSerializer.Serialize(g)[..Math.Min(1000, JsonSerializer.Serialize(g).Length)];
            switch (olay)
            {
                case "ringing":
                    if (id is null)
                    {
                        var tel = (g.Arayan ?? "").Trim();
                        var tarafId = tel == "" ? null : await b.TekDegerAsync<int?>("select taraf_id from public.fn_cagri_arayan_bul(@p0) limit 1", null, [tel], iptal);
                        id = await b.TekDegerAsync<int>("""
                            insert into public.cagri (kanal, yon, arayan_no, aranan_no, taraf_id, kuyruk_id, dis_ref, baslama, durum, sube_id)
                            values (1, 1, @p0, @p1, @p2, @p3, @p4, now(), 1, @p5) returning id
                            """, null, [tel, (g.Aranan ?? "").Trim(), tarafId, kuyrukId, reff, sube], iptal);
                    }
                    else await b.CalistirAsync("update public.cagri set kuyruk_id = coalesce(@p1, kuyruk_id), durum = case when durum in (5, 6) then durum else 1 end where id = @p0", null, [id, kuyrukId], iptal);
                    await OlayYazAsync(b, id.Value, 1, null, $"Çaldı → {g.Kuyruk ?? ""}", veriMetni, iptal);
                    break;
                case "answered":
                    if (id is null) goto case "ringing_then_answer";
                    await b.CalistirAsync("""
                        update public.cagri set agent_id = coalesce(@p1, agent_id), cevap = coalesce(cevap, now()), bekleme_sn = extract(epoch from (coalesce(cevap, now()) - baslama))::int, durum = 2 where id = @p0
                        """, null, [id, agentId], iptal);
                    await OlayYazAsync(b, id.Value, 2, agentId, $"Cevaplandı · dahili {g.Dahili ?? ""}", veriMetni, iptal);
                    if (agentId is not null) await b.CalistirAsync("update public.cagri_agent set durum = 2, durum_zaman = now() where kullanici_id = @p0", null, [agentId], iptal);
                    break;
                case "ringing_then_answer":
                    {
                        var tel = (g.Arayan ?? "").Trim();
                        var tarafId = tel == "" ? null : await b.TekDegerAsync<int?>("select taraf_id from public.fn_cagri_arayan_bul(@p0) limit 1", null, [tel], iptal);
                        id = await b.TekDegerAsync<int>("""
                            insert into public.cagri (kanal, yon, arayan_no, aranan_no, taraf_id, kuyruk_id, agent_id, dis_ref, baslama, cevap, durum, sube_id)
                            values (1, 1, @p0, @p1, @p2, @p3, @p4, @p5, now(), now(), 2, @p6) returning id
                            """, null, [tel, (g.Aranan ?? "").Trim(), tarafId, kuyrukId, agentId, reff, sube], iptal);
                        await OlayYazAsync(b, id.Value, 2, agentId, "Cevaplandı (çalma olayı gelmedi)", veriMetni, iptal);
                        if (agentId is not null) await b.CalistirAsync("update public.cagri_agent set durum = 2, durum_zaman = now() where kullanici_id = @p0", null, [agentId], iptal);
                        break;
                    }
                case "hold":
                case "unhold":
                    if (id is null) return Results.NotFound();
                    await b.CalistirAsync("update public.cagri set durum = @p1 where id = @p0 and durum in (2, 3)", null, [id, olay == "hold" ? (short)3 : (short)2], iptal);
                    await OlayYazAsync(b, id.Value, olay == "hold" ? (short)3 : (short)4, agentId, olay == "hold" ? "Beklet" : "Bekletme bitti", veriMetni, iptal);
                    break;
                case "transfer":
                    if (id is null) return Results.NotFound();
                    var hedefAgent = string.IsNullOrWhiteSpace(g.Hedef) ? null : await b.TekDegerAsync<int?>("select kullanici_id from public.cagri_agent where dahili = @p0 and aktif = 1 limit 1", null, [g.Hedef!.Trim()], iptal);
                    var hedefKuyruk = string.IsNullOrWhiteSpace(g.Hedef) ? null : await b.TekDegerAsync<int?>("select id from public.cagri_kuyruk where santral_kodu = @p0 or lower(ad) = lower(@p0) limit 1", null, [g.Hedef!.Trim()], iptal);
                    await b.CalistirAsync("update public.cagri set agent_id = coalesce(@p1, agent_id), kuyruk_id = coalesce(@p2, kuyruk_id), durum = case when @p1 is null and @p2 is not null then 1 else 2 end where id = @p0", null, [id, hedefAgent, hedefKuyruk], iptal);
                    await OlayYazAsync(b, id.Value, 5, agentId, $"Aktarıldı → {g.Hedef ?? ""}", veriMetni, iptal);
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
                    await OlayYazAsync(b, id.Value, 6, agentId, cevaplandi ? "Kapandı" : "Kaçan çağrı", veriMetni, iptal);
                    if (cevaplandi)
                        await b.CalistirAsync("update public.cagri_agent set durum = 3, durum_zaman = now() where kullanici_id = (select agent_id from public.cagri where id = @p0) and durum = 2", null, [id], iptal);
                    break;
                case "voicemail":
                    if (id is null) return Results.NotFound();
                    await b.CalistirAsync("update public.cagri set durum = 7, bitis = now(), kayit_url = coalesce(nullif(@p1, ''), kayit_url) where id = @p0", null, [id, g.KayitUrl ?? ""], iptal);
                    await OlayYazAsync(b, id.Value, 6, null, "Sesli mesaj bırakıldı", veriMetni, iptal);
                    break;
                default:
                    return Results.BadRequest(new { hata = "Bilinmeyen olay: " + olay });
            }
            return Results.Ok(new { id, olay });
        });
    }

    // ============================================================ yardımcı ====
    private static IResult Json(object o) => Results.Content(JsonSerializer.Serialize(o), "application/json");
    private static JsonNode? Parse(string? s) => s is null ? null : JsonNode.Parse(s);
    private static JsonNode?[] ParseList(IReadOnlyList<string> s) => s.Select(x => JsonNode.Parse(x)).ToArray();
    private static string TelAnahtar(string? tel)
    {
        var d = new string((tel ?? "").Where(char.IsDigit).ToArray());
        return d.Length > 10 ? d[^10..] : d;
    }

    private static async Task OlayYazAsync(NpgsqlConnection b, int cagriId, short tur, int? agentId, string aciklama, string veri, CancellationToken iptal)
        => await b.CalistirAsync("insert into public.cagri_olay (cagri_id, tur, zaman, agent_id, aciklama, veri) values (@p0, @p1, now(), @p2, @p3, @p4)", null,
            [cagriId, tur, agentId, aciklama[..Math.Min(300, aciklama.Length)], veri[..Math.Min(1000, veri.Length)]], iptal);

    private static async Task<int> IlgiliEkleAsync(NpgsqlConnection b, int cagriId, string kaynakTur, int kaynakId, string aciklama, int kullaniciId, CancellationToken iptal)
    {
        var id = await b.TekDegerAsync<int>("insert into public.cagri_ilgili (cagri_id, kaynak_tur, kaynak_id, aciklama, ekleyen) values (@p0, @p1, @p2, @p3, @p4) returning id", null,
            [cagriId, kaynakTur[..Math.Min(30, kaynakTur.Length)], kaynakId, aciklama[..Math.Min(200, aciklama.Length)], kullaniciId], iptal);
        await OlayYazAsync(b, cagriId, 9, kullaniciId, $"{kaynakTur} #{kaynakId} {aciklama}", "", iptal);
        return id;
    }

    /// <summary>Kullanıcının agent satırı yoksa açar (dahili boş; ayarlardan doldurulur).</summary>
    private static async Task AgentSaglaAsync(NpgsqlConnection b, IstekBaglami baglam, CancellationToken iptal)
        => await b.CalistirAsync("""
            insert into public.cagri_agent (kullanici_id, dahili, durum, durum_zaman, sube_id, ekleyen)
            values (@p0, '', 1, now(), @p1, @p0) on conflict (kullanici_id) do nothing
            """, null, [baglam.KullaniciId, baglam.SubeId ?? 0], iptal);

    /// <summary>İşlem sonrası süresi dolan agent kendiliğinden hazır olur (santral ayarı, vars. 45 sn).</summary>
    private static async Task IslemSonrasiKapatAsync(NpgsqlConnection b, int kullaniciId, CancellationToken iptal)
        => await b.CalistirAsync("""
            update public.cagri_agent a set durum = 1, durum_zaman = now()
             where a.kullanici_id = @p0 and a.durum = 3
               and a.durum_zaman < now() - make_interval(secs => coalesce((select s.islem_sonrasi_sn from public.cagri_santral s where s.sube_id = a.sube_id), 45))
               and not exists (select 1 from public.cagri c where c.agent_id = a.kullanici_id and c.durum in (2, 3, 4))
            """, null, [kullaniciId], iptal);

    private static async Task<int> SantralSubesiAsync(NpgsqlConnection b, int subeId, CancellationToken iptal)
    {
        var var_ = await b.TekDegerAsync<bool>("select exists (select 1 from public.cagri_santral where sube_id = @p0)", null, [subeId], iptal);
        if (!var_)
            await b.CalistirAsync("insert into public.cagri_santral (sube_id, saglayici, webhook_anahtar) values (@p0, 'yok', @p1) on conflict do nothing", null,
                [subeId, Convert.ToHexString(System.Security.Cryptography.RandomNumberGenerator.GetBytes(12)).ToLowerInvariant()], iptal);
        return subeId;
    }

    /// <summary>Arayan kişinin özeti: kimlik, son ziyaret, yaklaşan randevu, bekleyen/hazır sonuç, bakiye.</summary>
    private static async Task<object?> KisiOzetiAsync(NpgsqlConnection b, int tarafId, CancellationToken iptal)
    {
        var s = await b.TekAsync("""
            select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, ''), coalesce(t.kod, ''), coalesce(t.vkno, ''), coalesce(t.cep_tel, ''), coalesce(t.telefon, ''),
                   t.hasta, t.musteri, t.personel, t.kurum, h.dogum_tarihi, h.cinsiyet,
                   (select to_char(r.baslangic, 'DD.MM.YYYY') || ' · ' || coalesce(d.ad, '') || coalesce(' · ' || hk.ad, '') from public.randevu r
                      left join public.v_departman_lookup d on d.id = r.bolum left join public.v_hekim_lookup hk on hk.id = r.hekim_id
                     where r.hasta_id = t.id and r.baslangic < now() and r.durum = 2 order by r.baslangic desc limit 1),
                   (select json_build_object('id', r.id, 'metin', to_char(r.baslangic, 'DD.MM.YYYY HH24:MI') || ' · ' || coalesce(d.ad, '') || coalesce(' · ' || hk.ad, ''))::text from public.randevu r
                      left join public.v_departman_lookup d on d.id = r.bolum left join public.v_hekim_lookup hk on hk.id = r.hekim_id
                     where r.hasta_id = t.id and r.baslangic >= now() and r.durum = 1 order by r.baslangic limit 1),
                   (select count(*) from public.lab_istem li where li.taraf_id = t.id and li.sonuc_tarihi is null and li.istem_tarihi >= now() - interval '30 days'),
                   (select count(*) from public.lab_istem li where li.taraf_id = t.id and li.sonuc_tarihi >= now() - interval '7 days'),
                   (select coalesce(sum(e.yerel_borc) - sum(e.yerel_alacak), 0) from public.v_cari_ekstre e where e.taraf_id = t.id),
                   (select count(*) from public.gorev g where g.taraf_id = t.id and g.durum < 2)
              from public.taraf t left join public.taraf_hasta h on h.id = t.id
             where t.id = @p0
            """, null, [tarafId], o => new
        {
            tarafId = o.GetInt32(0), ad = o.GetString(1), kod = o.GetString(2), tckn = o.GetString(3), cepTel = o.GetString(4), telefon = o.GetString(5),
            hasta = o.GetInt16(6), musteri = o.GetInt16(7), personel = o.GetInt16(8), kurum = o.GetInt16(9),
            dogumTarihi = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10), cinsiyet = o.IsDBNull(11) ? (int?)null : Convert.ToInt32(o.GetValue(11)),
            sonZiyaret = o.IsDBNull(12) ? "" : o.GetString(12), yaklasanRandevu = o.IsDBNull(13) ? null : JsonNode.Parse(o.GetString(13)),
            bekleyenSonuc = o.GetInt64(14), hazirSonuc = o.GetInt64(15), bakiye = o.GetDecimal(16), acikGorev = o.GetInt64(17),
        }, iptal);
        return s;
    }
}
