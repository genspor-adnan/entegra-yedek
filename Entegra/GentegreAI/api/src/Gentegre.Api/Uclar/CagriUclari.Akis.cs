using System.Text.Json.Nodes;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇAĞRI MERKEZİ — operatör akışı: pano, agent durumu, arayan tanıma, çağrı
/// başlat / üstlen / kapat / ilgili / not / mesaj, çağrı kartı, kalite, özet.
/// </summary>
public static partial class CagriUclari
{
    private static void AkisUclari(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------------- pano ----
        grup.MapGet("/pano", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            await IslemSonrasiKapatAsync(b, baglam.KullaniciId, iptal);
            var ben = new object?[] { baglam.KullaniciId };
            var agent = await JsonTekAsync(b, "select row_to_json(a)::text from public.v_cagri_agent a where a.kullanici_id = @p0", ben, iptal);
            var kuyruklar = await JsonListeAsync(b, "select row_to_json(q)::text from public.v_cagri_kuyruk q where q.aktif = 1 order by q.sira", [], iptal);
            var bekleyen = await JsonListeAsync(b, "select row_to_json(c)::text from public.v_cagri c where c.durum in (1, 3, 7) order by c.baslama limit 30", [], iptal);
            var bugun = await JsonListeAsync(b, "select row_to_json(c)::text from public.v_cagri c where c.agent_id = @p0 and c.baslama >= current_date order by c.baslama desc limit 40", ben, iptal);
            var aktif = await JsonTekAsync(b, "select row_to_json(c)::text from public.v_cagri c where c.agent_id = @p0 and c.durum in (2, 3, 4) order by c.baslama desc limit 1", ben, iptal);
            var ozet = await b.TekAsync("""
                select count(*), coalesce(avg(sure_sn) filter (where sure_sn > 0), 0)::int,
                       count(*) filter (where durum = 6),
                       (select count(*) from public.cagri where durum in (1, 3, 7)),
                       (select count(*) from public.cagri x where x.baslama >= current_date and x.cevap is not null),
                       (select count(*) from public.cagri x where x.baslama >= current_date and x.cevap is not null and x.bekleme_sn <= 20)
                  from public.cagri c where c.agent_id = @p0 and c.baslama >= current_date
                """, null, ben, o => new
            {
                cagri = o.GetInt64(0), ortSureSn = o.GetInt32(1), kacan = o.GetInt64(2), bekleyen = o.GetInt64(3),
                gunCevaplanan = o.GetInt64(4), gunSla = o.GetInt64(5),
            }, iptal);
            var konular = await JsonListeAsync(b, "select row_to_json(k)::text from public.v_cagri_konu k where k.aktif = 1 order by coalesce(k.ust_id, k.id), k.ust_id nulls first, k.sira", [], iptal);
            return Json(new { agent, kuyruklar, bekleyen, bugun, aktif, ozet, konular });
        });

        // Agent durumu: hazır / mola / çıkış (çağrıda ve işlem sonrası sistem koyar).
        grup.MapPost("/agent/durum", async (AgentDurumIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.pano", Islem.Gor);
            if (g.Durum is not (AgentHazir or AgentMola or AgentCikis)) throw GentegreHatasi.IsKurali("Durum yalnız Hazır / Mola / Çıkış seçilebilir.");
            if (g.Durum == AgentMola && (g.MolaSebep ?? 0) == 0) throw GentegreHatasi.IsKurali("Mola sebebi zorunlu.");
            await using var b = await veri.AcAsync(iptal);
            await AgentSaglaAsync(b, baglam, iptal);
            await b.CalistirAsync("update public.cagri_agent set durum = @p1, mola_sebep = @p2, durum_zaman = now(), degistiren = @p0, degistirme_tarihi = now() where kullanici_id = @p0",
                null, [baglam.KullaniciId, g.Durum, g.Durum == AgentMola ? g.MolaSebep ?? (short)0 : (short)0], iptal);
            return Results.Ok(new { durum = g.Durum });
        });

        // ------------------------------------------------ arayan tanıma ----
        grup.MapGet("/arayan", async (string? telefon, int? tarafId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var adaylar = string.IsNullOrWhiteSpace(telefon) ? [] :
                await JsonListeAsync(b, "select row_to_json(x)::text from public.fn_cagri_arayan_bul(@p0) x", [telefon], iptal);
            var secili = tarafId ?? adaylar.FirstOrDefault()?["taraf_id"]?.GetValue<int>();
            object? ozet = secili is null ? null : await KisiOzetiAsync(b, secili.Value, iptal);
            var sonCagrilar = await JsonListeAsync(b, """
                select row_to_json(c)::text from public.v_cagri c
                 where (@p0::int is not null and c.taraf_id = @p0) or (@p1 <> '' and public.fn_cagri_tel_anahtar(c.arayan_no) = @p1)
                 order by c.baslama desc limit 5
                """, [secili, TelAnahtar(telefon)], iptal);
            return Json(new { adaylar, tarafId = secili, ozet, sonCagrilar });
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
            var tarafId = g.TarafId ?? await TarafBulAsync(b, tel, iptal);
            if (tel == "" && tarafId is not null)
                tel = await b.TekDegerAsync<string>($"select {TarafTel} from public.taraf t where t.id = @p0", null, [tarafId], iptal) ?? "";
            var id = await b.TekDegerAsync<int>("""
                insert into public.cagri (kanal, yon, arayan_no, taraf_id, kuyruk_id, agent_id, baslama, cevap, durum, kampanya_kisi_id, kampanya_id, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, now(), now(), 2, @p6,
                        (select kampanya_id from public.cagri_kampanya_kisi where id = @p6), @p7, @p5) returning id
                """, null, [g.Kanal ?? (short)1, g.Yon ?? (short)2, tel, tarafId, g.KuyrukId, baglam.KullaniciId, g.KampanyaKisiId, baglam.SubeId ?? 0], iptal);
            await OlayYazAsync(b, id, 2, baglam.KullaniciId, g.Yon == 1 ? "Elle kaydedildi" : "Tıkla-ara", "", iptal);
            if (g.KampanyaKisiId is not null)
                await b.CalistirAsync("update public.cagri_kampanya_kisi set deneme = deneme + 1, son_deneme = now(), cagri_id = @p1 where id = @p0", null, [g.KampanyaKisiId, id], iptal);
            await AgentDurumAsync(b, baglam.KullaniciId, AgentCagrida, iptal);
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
            await AgentDurumAsync(b, baglam.KullaniciId, AgentCagrida, iptal);
            return Results.Ok(new { id });
        });

        // Kaydet & kapat: konu/sonuç/not; geri arama → görev (tur 2); şikayet → görev (tur 1).
        grup.MapPost("/{id:int}/kapat", async (int id, KapatIstegi g, VeriKaynagi veri, LogDeposu log, BildirimDeposu bildirim, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cagri.kayit", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("select durum, taraf_id, arayan_no, kampanya_kisi_id, agent_id, gorev_id from public.cagri where id = @p0", null, [id],
                o => new { durum = o.GetInt16(0), tarafId = SayiN(o, 1), tel = o.GetString(2), kisiId = SayiN(o, 3), agentId = SayiN(o, 4), gorevId = SayiN(o, 5) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            if (g.KonuId is null) throw GentegreHatasi.IsKurali("Konu seçilmeden çağrı kapatılamaz.");
            var geriAranacak = g.Sonuc == 2;
            if (geriAranacak && g.GeriArama is null) throw GentegreHatasi.IsKurali("\"Geri aranacak\" için tarih/saat zorunlu.");
            var tarafId = g.TarafId ?? c.tarafId;
            var ad = tarafId is null ? c.tel : await b.TekDegerAsync<string>($"select {TarafAdi} from public.taraf t where t.id = @p0", null, [tarafId], iptal) ?? c.tel;
            int? gorevId = c.gorevId;
            if (geriAranacak)
            {
                // gorev.termin/hatirlatma timestamptz: istemci yerel saat gönderir (offset yok) -> UTC'ye çevrilir.
                var geriUtc = DateTime.SpecifyKind(g.GeriArama!.Value, DateTimeKind.Local).ToUniversalTime();
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
                    """, null, [g.GorevKonu.Trim(), $"Çağrı #{id} · {ad} · {c.tel}\n{g.Notu ?? ""}", baglam.KullaniciId, tarafId, baglam.SubeId ?? 0], iptal);
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
                """, null, [id, g.KonuId, g.AltKonuId, g.Sonuc ?? (short)1, Kirp(g.Notu, 1200), g.Oncelik, tarafId,
                            g.GeriArama is null ? null : DateTime.SpecifyKind(g.GeriArama.Value, DateTimeKind.Unspecified), gorevId, g.Memnuniyet, baglam.KullaniciId], iptal);
            await OlayYazAsync(b, id, 9, baglam.KullaniciId, "Kayıt tamamlandı", "", iptal);
            if (c.kisiId is not null)
            {
                short kd = g.Sonuc switch { 7 or 1 or 6 => 5, 4 => 3, 8 => 6, 2 => 1, _ => 4 };
                await b.CalistirAsync("update public.cagri_kampanya_kisi set durum = @p1, sonuc = @p2, cagri_id = @p3 where id = @p0", null, [c.kisiId, kd, Kirp(g.Notu, 200), id], iptal);
            }
            if (geriAranacak && tarafId is not null && c.tel != "")
            {
                try
                {
                    await bildirim.KuyrugaEkleAsync(new BildirimIstegi("cagri.geri_arama", BildirimKanali.Sms, c.tel,
                        new Dictionary<string, string> { ["ad"] = ad, ["saat"] = g.GeriArama!.Value.ToString("dd.MM HH:mm"), ["kurum"] = KurumAdi(baglam) },
                        TarafId: tarafId, KaynakTur: KaynakTurCagri, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
                }
                catch (InvalidOperationException) { /* şablon pasif / kanal yok: sessiz */ }
            }
            if (c.agentId == baglam.KullaniciId) await AgentIslemSonrasinaAlAsync(b, baglam.KullaniciId, iptal);
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
                o => new { tarafId = SayiN(o, 0), tel = o.GetString(1), ad = o.GetString(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            var tel = string.IsNullOrWhiteSpace(g.Telefon) ? c.tel : g.Telefon.Trim();
            if (tel == "") throw GentegreHatasi.IsKurali("Telefon numarası yok.");
            var sablon = g.Sablon switch { "odeme_linki" => "cagri.odeme_linki", "yol_tarifi" => "cagri.yol_tarifi", "anket" => "cagri.anket", "geri_arama" => "cagri.geri_arama", _ => throw GentegreHatasi.IsKurali("Bilinmeyen mesaj şablonu.") };
            var adres = await b.TekDegerAsync<string>("select coalesce(adres, '') from public.sube where id = @p0", null, [baglam.SubeId ?? 0], iptal) ?? "";
            long? bid;
            try
            {
                bid = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(sablon, null, tel, new Dictionary<string, string>
                {
                    ["ad"] = c.ad == "" ? "Sayın müşterimiz" : c.ad, ["kurum"] = KurumAdi(baglam), ["tutar"] = g.Tutar ?? "", ["baglanti"] = g.Baglanti ?? "",
                    ["saat"] = g.Saat ?? "", ["adres"] = adres, ["konum"] = g.Baglanti ?? "",
                }, TarafId: c.tarafId, KaynakTur: KaynakTurCagri, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
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
            var cagri = await JsonTekAsync(b, "select row_to_json(c)::text from public.v_cagri c where c.id = @p0", [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            var olaylar = await JsonListeAsync(b, """
                select json_build_object('id', o.id, 'tur', o.tur, 'turAdi', coalesce(k.ad, ''), 'zaman', o.zaman, 'agentId', o.agent_id, 'agentAdi', coalesce(u.ad, ''), 'aciklama', o.aciklama)::text
                  from public.cagri_olay o
                  left join public.kod_liste l on l.kod = 'cagri.olay_tur' left join public.kod_deger k on k.liste_id = l.id and k.deger = o.tur
                  left join public.v_kullanici_lookup u on u.id = o.agent_id
                 where o.cagri_id = @p0 order by o.zaman, o.id
                """, [id], iptal);
            var ilgili = await JsonListeAsync(b, "select json_build_object('id', i.id, 'kaynakTur', i.kaynak_tur, 'kaynakId', i.kaynak_id, 'aciklama', i.aciklama, 'zaman', i.ekleme_tarihi)::text from public.cagri_ilgili i where i.cagri_id = @p0 order by i.id", [id], iptal);
            var kalite = await JsonTekAsync(b, "select row_to_json(k)::text from public.v_cagri_kalite k where k.cagri_id = @p0", [id], iptal);
            var tarafId = cagri["taraf_id"]?.GetValue<int?>();
            var tel = cagri["arayan_no"]?.ToString() ?? "";
            var gecmis = await JsonListeAsync(b, """
                select row_to_json(c)::text from public.v_cagri c
                 where c.id <> @p0 and ((@p1::int is not null and c.taraf_id = @p1) or (@p2 <> '' and public.fn_cagri_tel_anahtar(c.arayan_no) = @p2))
                 order by c.baslama desc limit 10
                """, [id, tarafId, TelAnahtar(tel)], iptal);
            object? ozet = tarafId is null ? null : await KisiOzetiAsync(b, tarafId.Value, iptal);
            return Json(new { cagri, olaylar, ilgili, kalite, gecmis, ozet });
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
                """, null, [id, baglam.KullaniciId, g.Puan, g.Olcutler?.ToJsonString() ?? "[]", Kirp(g.Notu, 600)], iptal);
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
            var cagri = await JsonTekAsync(b, "select row_to_json(c)::text from public.v_cagri c where c.id = @p0", [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");
            var ilgili = await b.ListeAsync("select kaynak_tur || ' #' || kaynak_id || case when aciklama <> '' then ' (' || aciklama || ')' else '' end from public.cagri_ilgili where cagri_id = @p0 order by id", null, [id], o => o.GetString(0), iptal);
            var ozet = KuralOzeti(cagri, ilgili);
            await b.CalistirAsync("""
                insert into public.cagri_kalite (cagri_id, ozet_ai, ekleyen) values (@p0, @p1, @p2)
                on conflict (cagri_id) do update set ozet_ai = excluded.ozet_ai, degistiren = excluded.ekleyen, degistirme_tarihi = now()
                """, null, [id, Kirp(ozet, 1500), baglam.KullaniciId], iptal);
            return Results.Ok(new { ozet, kaynak = "kural" });
        });
    }

    /// <summary>v_cagri satırı + ilgili kayıt etiketlerinden kural tabanlı özet cümlesi.</summary>
    private static string KuralOzeti(JsonNode cagri, IReadOnlyList<string> ilgili)
    {
        string Alan(string ad) => cagri[ad]?.ToString() ?? "";
        var parcalar = new List<string>();
        var kisi = Alan("taraf_adi"); if (kisi == "") kisi = Alan("arayan_no");
        parcalar.Add($"{Alan("yon_adi")} {Alan("kanal_adi").ToLowerInvariant()} çağrısı · {kisi}");
        var konu = Alan("konu_adi"); var alt = Alan("alt_konu_adi");
        if (konu != "") parcalar.Add($"Konu: {konu}{(alt == "" ? "" : " › " + alt)}");
        var sonuc = Alan("sonuc_adi"); if (sonuc != "") parcalar.Add($"Sonuç: {sonuc}");
        var notu = Alan("notu"); if (notu != "") parcalar.Add($"Not: {notu}");
        if (ilgili.Count > 0) parcalar.Add("Açılan kayıtlar: " + string.Join(", ", ilgili));
        var bekleme = cagri["bekleme_sn"]?.GetValue<int>() ?? 0; var sure = cagri["sure_sn"]?.GetValue<int>() ?? 0;
        parcalar.Add($"Bekleme {bekleme} sn · konuşma {sure / 60}:{sure % 60:00}" + (bekleme > 60 ? " · UZUN BEKLEME" : ""));
        var ga = Alan("geri_arama"); if (ga != "") parcalar.Add($"Aksiyon: geri arama {ga}");
        return string.Join(". ", parcalar) + ".";
    }
}
