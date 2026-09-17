using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;
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
/// FORM MOTORU (740) — mockuplar Ekranlar/Formlar + Ekranlar/ISG/isg_calisan_formu.
///
/// İki grup uç:
///   /api/form/*        yetkili: gönder (SMS / e-posta / kiosk), istek oku,
///                      iç ekranda doldur, hatırlat, yeniden gönder, iptal,
///                      cevabı kayda aktar (hedefAlan), hasta formları,
///                      kütüphane (resmî şablonlar) ve kuruma kopyalama.
///   /api/acik/form/*   ANONİM: hastanın telefonundan açılan bağlantı. Kimlik
///                      kanıtı TCKN son 4 + doğum yılı (5 deneme → kilit);
///                      doğrulama sonrası 30 dk'lık oturum anahtarı ile taslak
///                      ve gönderim. Ham belirteç DB'de tutulmaz (SHA-256 özeti).
/// </summary>
public static class FormUclari
{
    private const int LogIstek = 1191;
    private const int OturumDakika = 30;
    private const int EnFazlaDeneme = 5;

    public sealed record GonderIstegi(string? SablonKod, int? SablonId, int HastaId, int? KaynakTur, int? KaynakId,
                                      int? Kanal, string? Telefon, string? Eposta, int? GecerlilikSaat, string? Not);
    public sealed record CevapIstegi(JsonObject? Cevap, JsonArray? Imzalar, bool? Tamamla, int? Asama);
    public sealed record KurIstegi(string[] Kodlar);
    public sealed record TanimIstegi(JsonObject Tanim, bool? Yayinla, string? SurumNotu);
    public sealed record AcikDogrulaIstegi(string? TcknSon4, string? DogumYili);
    public sealed record AcikTaslakIstegi(string Oturum, JsonObject? Taslak);
    public sealed record AcikGonderIstegi(string Oturum, JsonObject? Cevap, JsonArray? Imzalar, bool? Riza, bool? Reddetti);

    public static void FormUclariniEkle(this IEndpointRouteBuilder yol)
    {
        YetkiliUclar(yol.MapGroup("/api/form").WithTags("Form").RequireAuthorization());
        AcikUclar(yol.MapGroup("/api/acik/form").WithTags("Form (açık)").AllowAnonymous());
    }

    // =========================================================== yetkili ====
    private static void YetkiliUclar(RouteGroupBuilder grup)
    {
        // Şablon tanımı (kurum kopyası ya da resmî) — doldurma ekranı ve editör.
        grup.MapGet("/sablon/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.sablon", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync("select row_to_json(s)::text from public.v_form_sablon s where s.id = @p0", null, [id], o => o.GetString(0), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Şablon bulunamadı.");
            return Results.Content(s, "application/json");
        });

        // TANIM KAYDET (görsel editör): taslak kaydı ya da yayın (sürüm +1).
        //   Yayınlanan sürüm değişmez: dolduranlar kendi sürümüyle saklanır.
        grup.MapPut("/sablon/{id:int}/tanim", async (int id, TanimIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.sablon", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var resmi = await b.TekDegerAsync<short?>("select resmi from public.form_sablon where id = @p0", null, [id], iptal) ?? throw GentegreHatasi.Bulunamadi("Şablon bulunamadı.");
            if (resmi == 1) throw GentegreHatasi.IsKurali("Resmî kütüphane kopyası düzenlenmez; 'Kuruma kopyala' ile kendi sürümünüzü açın.");
            var yayinla = g.Yayinla == true;
            var surum = await b.TekDegerAsync<int>("""
                update public.form_sablon
                   set tanim = cast(@p1 as jsonb), surum = case when @p2 then surum + 1 else surum end,
                       aciklama = case when @p2 and coalesce(@p3, '') <> '' then @p3 else aciklama end,
                       degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0 returning surum
                """, null, [id, g.Tanim.ToJsonString(), yayinla, g.SurumNotu, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, 1190, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { tanim = yayinla ? "yayınlandı" : "taslak", surum }, iptal: iptal);
            return Results.Ok(new { id, surum });
        });

        // GÖNDER: SMS / e-posta bağlantısı ya da kiosk/iç ekran isteği açar.
        grup.MapPost("/gonder", async (GonderIstegi g, VeriKaynagi veri, BildirimDeposu bildirim, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.gonder", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var sablon = await SablonBulAsync(b, g.SablonId, g.SablonKod, iptal);
            var hasta = await HastaOkuAsync(b, g.HastaId, iptal) ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");
            var kanal = (short)(g.Kanal ?? sablon.kanal);
            var saat = g.GecerlilikSaat ?? sablon.gecerlilikSaat;
            if (saat <= 0) saat = 72;

            // Uzaktan kanalda alıcı zorunlu.
            var alici = kanal == 3 ? (g.Telefon ?? hasta.cepTel) : kanal == 4 ? (g.Eposta ?? hasta.eposta) : "";
            if ((kanal == 3 || kanal == 4) && string.IsNullOrWhiteSpace(alici))
                throw GentegreHatasi.IsKurali(kanal == 3 ? "Hastanın cep telefonu yok; hasta kartına yazın ya da kiosk kanalını seçin."
                                                         : "Hastanın e-posta adresi yok.");

            var (kod, ozet) = BelirtecUret();
            var id = await b.TekDegerAsync<int>("""
                insert into public.form_istek (sablon_id, surum, hasta_id, kaynak_tur, kaynak_id, kanal, belirtec_ozet, son_gecerlilik,
                                               gonderim, durum, aciklama, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, now() + make_interval(hours => @p7), now(), 1, @p8, @p9, @p10) returning id
                """, null, [sablon.id, (short)sablon.surum, g.HastaId, (short)(g.KaynakTur ?? sablon.baglam), g.KaynakId, kanal, ozet, saat,
                            g.Not ?? "", baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

            var baglanti = BaglantiKur(ctx, kod);
            long? bildirimId = null;
            if (kanal is 3 or 4)
            {
                var kurum = baglam.Subeler.FirstOrDefault(s => s.Id == baglam.SubeId)?.Ad ?? "GenoTIP";
                bildirimId = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                    kanal == 3 ? "form.baglanti" : "form.baglanti.eposta", kanal == 3 ? BildirimKanali.Sms : BildirimKanali.Eposta, alici,
                    new Dictionary<string, string>
                    {
                        ["kurum"] = kurum, ["form"] = sablon.ad, ["baglanti"] = baglanti, ["saat"] = saat.ToString(),
                        ["gonderen"] = baglam.Subeler.Count > 0 ? kurum : "", ["hasta"] = hasta.ad,
                    }, TarafId: g.HastaId, KaynakTur: 40, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
                await b.CalistirAsync("update public.form_istek set bildirim_id = @p1 where id = @p0", null, [id, bildirimId], iptal);
            }
            await log.YazAsync(LogIslemi.Ekle, LogIstek, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { sablon = sablon.kod, kanal, alici = kanal is 3 or 4 ? Maskele(alici) : "", saat }, tarafId: g.HastaId, iptal: iptal);
            // Kiosk / iç ekranda kod ekrana verilir (QR / tablet); uzaktan kanalda verilmez.
            return Results.Ok(new { id, kod = kanal is 1 or 2 ? kod : null, baglanti = kanal is 1 or 2 ? baglanti : null, bildirimId });
        });

        // İSTEK: tanım + cevap + imzalar (yetkili; içerik yalnız form.istek yetkisiyle).
        grup.MapGet("/istek/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.istek", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var y = await IstekOkuAsync(b, id, iptal) ?? throw GentegreHatasi.Bulunamadi("Form isteği bulunamadı.");
            return Results.Content(y, "application/json");
        });

        // İÇ EKRAN / TABLET DOLDURMA (klinik rol): taslak ya da tamamla.
        grup.MapPut("/istek/{id:int}/cevap", async (int id, CevapIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.doldur", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var d = await b.TekAsync("select i.durum, i.sablon_id, s.tanim::text, i.hasta_id, i.asama, coalesce(s.asamali, 0), i.kaynak_tur from public.form_istek i join public.form_sablon s on s.id = i.sablon_id where i.id = @p0",
                null, [id], o => new { durum = o.GetInt16(0), sablonId = o.GetInt32(1), tanim = o.GetString(2), hastaId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), asama = o.GetInt16(4), asamali = o.GetInt16(5), kaynakTur = (int)o.GetInt16(6) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Form isteği bulunamadı.");
            if (d.durum is 4 or 6 or 7 or 8) throw GentegreHatasi.IsKurali("Bu form tamamlanmış ya da kapatılmış; yeni istek açın.");
            var cevap = (g.Cevap ?? new JsonObject()).ToJsonString();
            var imzalar = (g.Imzalar ?? new JsonArray()).ToJsonString();
            var tamamla = g.Tamamla == true;
            // Aşamalı form: tamamla = bu aşamayı kapat; son aşama kapanınca form biter.
            var sonAsama = AsamaSayisi(d.tanim);
            var yeniAsama = d.asama;
            if (d.asamali == 1 && tamamla && d.asama < sonAsama) { yeniAsama = (short)(d.asama + 1); tamamla = false; }
            var (skor, sonuc) = tamamla ? SkorHesapla(d.tanim, cevap) : (null, "");
            await b.CalistirAsync("""
                update public.form_istek
                   set taslak = case when @p2 then '{}'::jsonb else cast(@p1 as jsonb) end,
                       cevap = case when @p2 or @p6 = 1 then cast(@p1 as jsonb) else cevap end,
                       imzalar = cast(@p3 as jsonb), durum = case when @p2 then 4 else 3 end,
                       tamamlanma = case when @p2 then now() else tamamlanma end, dolduran_id = @p4,
                       skor = @p7, sonuc = case when @p2 then @p8 else sonuc end, asama = @p5,
                       ip = @p9, degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, cevap, tamamla, imzalar, baglam.KullaniciId, yeniAsama, d.asamali, skor, sonuc, baglam.Ip], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogIstek, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { tamamla, asama = yeniAsama, skor, sonuc }, tarafId: d.hastaId, iptal: iptal);
            // İSG (741): Ek-2 tamamlanınca kanaat isg_muayene'ye akar.
            object? isg = null;
            if (tamamla && d.kaynakTur == 8) isg = await IsgUclari.MuayeneyiIsleAsync(b, id, baglam.KullaniciId, iptal);
            return Results.Ok(new { id, durum = tamamla ? 4 : 3, asama = yeniAsama, skor, sonuc, isg });
        });

        grup.MapPost("/istek/{id:int}/hatirlat", async (int id, VeriKaynagi veri, BildirimDeposu bildirim, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.gonder", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var i = await b.TekAsync("""
                select i.durum, i.kanal, i.hasta_id, s.ad, (i.son_gecerlilik is not null and i.son_gecerlilik < now()), i.bildirim_id
                  from public.form_istek i join public.form_sablon s on s.id = i.sablon_id where i.id = @p0
                """, null, [id], o => new { durum = o.GetInt16(0), kanal = o.GetInt16(1), hastaId = o.IsDBNull(2) ? 0 : o.GetInt32(2), ad = o.GetString(3), doldu = o.GetBoolean(4), bildirimId = o.IsDBNull(5) ? (long?)null : o.GetInt64(5) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            if (i.durum is not (1 or 2 or 3)) throw GentegreHatasi.IsKurali("Bu istek beklemede değil.");
            if (i.doldu) throw GentegreHatasi.IsKurali("Bağlantının süresi dolmuş; 'Yeniden gönder' kullanın.");
            if (i.kanal is not (3 or 4)) throw GentegreHatasi.IsKurali("Hatırlatma yalnız SMS / e-posta isteklerinde.");
            // Aynı metin yeniden: önceki bildirim gövdesi kopyalanır (bağlantı aynı).
            var eski = i.bildirimId is null ? null : await b.TekAsync("select alici, govde, konu from public.bildirim where id = @p0", null, [i.bildirimId],
                o => new { alici = o.GetString(0), govde = o.GetString(1), konu = o.GetString(2) }, iptal);
            if (eski is null) throw GentegreHatasi.IsKurali("Önceki gönderim bulunamadı; 'Yeniden gönder' kullanın.");
            var yeni = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(null, i.kanal == 3 ? BildirimKanali.Sms : BildirimKanali.Eposta, eski.alici,
                Konu: eski.konu, Govde: "Hatırlatma: " + eski.govde, TarafId: i.hastaId, KaynakTur: 40, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
            return Results.Ok(new { bildirimId = yeni });
        });

        // YENİDEN GÖNDER: eski belirteç geçersiz, yeni istek (aynı hasta/şablon/bağlam).
        grup.MapPost("/istek/{id:int}/yeniden", async (int id, VeriKaynagi veri, BildirimDeposu bildirim, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.gonder", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var i = await b.TekAsync("select sablon_id, hasta_id, kaynak_tur, kaynak_id, kanal, durum from public.form_istek where id = @p0", null, [id],
                o => new { sablonId = o.GetInt32(0), hastaId = o.IsDBNull(1) ? 0 : o.GetInt32(1), kaynakTur = (int)o.GetInt16(2), kaynakId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), kanal = (int)o.GetInt16(4), durum = o.GetInt16(5) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            if (i.durum == 4) throw GentegreHatasi.IsKurali("Tamamlanmış form yeniden gönderilmez; yeni istek açın.");
            await b.CalistirAsync("update public.form_istek set durum = 8, belirtec_ozet = '', oturum_anahtari = '', degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogIstek, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { iptal = "yeniden gönderildi" }, tarafId: i.hastaId, iptal: iptal);
            // Yeni istek: /gonder ile aynı yol (kod üretimi + bildirim).
            ctx.Items["form.yeniden"] = true;
            var g = new GonderIstegi(null, i.sablonId, i.hastaId, i.kaynakTur, i.kaynakId, i.kanal, null, null, null, $"yeniden (#{id})");
            return await GonderCalistir(g, b, bildirim, log, baglam, ctx, iptal);
        });

        grup.MapPost("/istek/{id:int}/iptal", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.gonder", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("update public.form_istek set durum = 8, belirtec_ozet = '', oturum_anahtari = '', degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum in (1, 2, 3, 5, 6)", null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız bekleyen istek iptal edilir.");
            await log.YazAsync(LogIslemi.Degistir, LogIstek, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { iptal = true }, iptal: iptal);
            return Results.Ok(new { id, durum = 8 });
        });

        // AKTAR: cevaptaki hedefAlan'lı alanları bağlam kaydına yazar (beyaz liste).
        grup.MapPost("/istek/{id:int}/aktar", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.aktar", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var d = await b.TekAsync("select i.durum, s.tanim::text, i.cevap::text, i.kaynak_tur, i.kaynak_id, i.hasta_id from public.form_istek i join public.form_sablon s on s.id = i.sablon_id where i.id = @p0",
                null, [id], o => new { durum = o.GetInt16(0), tanim = o.GetString(1), cevap = o.GetString(2), kaynakTur = o.GetInt16(3), kaynakId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), hastaId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            if (d.durum != 4) throw GentegreHatasi.IsKurali("Yalnız tamamlanmış form aktarılır.");
            var yazilan = new List<string>();
            var atlanan = new List<string>();
            var cevap = JsonNode.Parse(d.cevap) as JsonObject ?? new JsonObject();
            foreach (var (alanKod, hedef, etiket) in HedefAlanlar(d.tanim))
            {
                var deger = cevap[alanKod]?.ToString();
                if (string.IsNullOrWhiteSpace(deger)) { atlanan.Add($"{etiket}: boş"); continue; }
                var (tablo, kolon) = hedef.Split('.') is [var t, var k] ? (t, k) : ("", "");
                if (tablo == "muayene" && d.kaynakTur == 3 && d.kaynakId is int mid && MuayeneKolonlari.Contains(kolon))
                {
                    // Mevcut metnin ÜSTÜNE değil, sonuna: hekimin yazdığı kaybolmasın.
                    await b.CalistirAsync($"update public.muayene set {kolon} = case when coalesce({kolon}, '') = '' then @p1 else {kolon} || E'\\n' || @p1 end, degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                        null, [mid, $"[Hasta beyanı] {deger}", baglam.KullaniciId], iptal);
                    yazilan.Add($"{etiket} → muayene.{kolon}");
                }
                else atlanan.Add($"{etiket} → {hedef}: bu bağlamda hedef yok");
            }
            await b.CalistirAsync("update public.form_istek set aktarim_zamani = now(), degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogIstek, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { aktarim = yazilan, atlanan }, tarafId: d.hastaId, iptal: iptal);
            return Results.Ok(new { yazilan, atlanan });
        });

        // HASTANIN FORMLARI (hasta kartı › Formlar): istekler + zorunlu eksikler.
        grup.MapGet("/hasta/{hastaId:int}", async (int hastaId, int? kaynakTur, int? kaynakId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.istek", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var hasta = await HastaOkuAsync(b, hastaId, iptal) ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");
            var istekler = await b.ListeAsync("""
                select row_to_json(i)::text from public.v_form_istek i
                 where i.hasta_id = @p0 and i.durum <> 8 and (@p1::int is null or (i.kaynak_tur = @p1 and i.kaynak_id = @p2))
                 order by i.ekleme_tarihi desc
                """, null, [hastaId, kaynakTur, kaynakId], o => o.GetString(0), iptal);
            var sablonlar = await b.ListeAsync("select id, kod, ad, aile, baglam, kanal, imza_yontem, tekrar_saat, asamali from public.form_sablon where resmi = 0 and durum = 1 order by aile, ad",
                null, [], o => new { id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), aile = (int)o.GetInt16(3), baglam = (int)o.GetInt16(4), kanal = (int)o.GetInt16(5), imzaYontem = (int)o.GetInt16(6), tekrarSaat = o.GetInt32(7), asamali = (int)o.GetInt16(8) }, iptal);
            return Results.Content(JsonSerializer.Serialize(new
            {
                hasta = new { hasta.id, hasta.ad, hasta.cepTel, hasta.eposta },
                istekler = istekler.Select(x => JsonNode.Parse(x)).ToArray(),
                sablonlar,
            }), "application/json");
        });

        // KÜTÜPHANE: resmî şablonlar + kurumda kurulu mu (ust_sablon_id ile).
        grup.MapGet("/kutuphane", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.kutuphane", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kurumTipi = await b.TekDegerAsync<string>("select coalesce(kurum_tipi, '') from public.kurum_profil order by sube_id limit 1", null, [], iptal) ?? "";
            var liste = await b.ListeAsync("""
                select r.id, r.kod, r.ad, r.aile, r.baglam, r.kanal, r.kaynak, r.kaynak_kod, r.kurum_tipleri, r.surum, r.aciklama, r.tekrar_saat, r.asamali, r.imza_yontem,
                       k.id, k.surum, k.durum, r.gecerlilik_saat, r.saklama_yil
                  from public.form_sablon r
                  left join public.form_sablon k on k.ust_sablon_id = r.id and k.resmi = 0
                 where r.resmi = 1 order by r.aile, r.kaynak, r.ad
                """, null, [], o => new
            {
                id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), aile = (int)o.GetInt16(3), baglam = (int)o.GetInt16(4), kanal = (int)o.GetInt16(5),
                kaynak = o.GetString(6), kaynakKod = o.GetString(7), kurumTipleri = o.GetString(8), surum = (int)o.GetInt16(9), aciklama = o.GetString(10),
                tekrarSaat = o.GetInt32(11), asamali = (int)o.GetInt16(12), imzaYontem = (int)o.GetInt16(13),
                kuruluId = o.IsDBNull(14) ? (int?)null : o.GetInt32(14), kuruluSurum = o.IsDBNull(15) ? (int?)null : (int)o.GetInt16(15),
                kuruluDurum = o.IsDBNull(16) ? (int?)null : (int)o.GetInt16(16), gecerlilikSaat = (int)o.GetInt16(17), saklamaYil = (int)o.GetInt16(18),
            }, iptal);
            return Results.Ok(new { kurumTipi, liste });
        });

        // KURUMA KOPYALA: resmî → kurum kopyası (yeni sürüm gelmişse tanım tazelenir).
        grup.MapPost("/kutuphane/kur", async (KurIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.sablon", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var kurulan = new List<string>(); var guncellenen = new List<string>();
            foreach (var kod in g.Kodlar.Distinct())
            {
                var var_ = await b.TekAsync("select k.id, k.surum, r.surum from public.form_sablon r left join public.form_sablon k on k.ust_sablon_id = r.id and k.resmi = 0 where r.resmi = 1 and r.kod = @p0",
                    null, [kod], o => new { kuruluId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), kuruluSurum = o.IsDBNull(1) ? 0 : (int)o.GetInt16(1), resmiSurum = (int)o.GetInt16(2) }, iptal);
                if (var_ is null) continue;
                if (var_.kuruluId is null)
                {
                    await b.CalistirAsync("""
                        insert into public.form_sablon (kod, ad, aile, baglam, kanal, imza_yontem, kaynak, kaynak_kod, kurum_tipleri, resmi, ust_sablon_id, surum, tanim,
                                                        gecerlilik_saat, saklama_yil, tekrar_saat, asamali, durum, aciklama, sube_id, ekleyen)
                        select r.kod, r.ad, r.aile, r.baglam, r.kanal, r.imza_yontem, r.kaynak, r.kaynak_kod, r.kurum_tipleri, 0, r.id, r.surum, r.tanim,
                               r.gecerlilik_saat, r.saklama_yil, r.tekrar_saat, r.asamali, 1, r.aciklama, 0, @p1
                          from public.form_sablon r where r.resmi = 1 and r.kod = @p0
                        """, null, [kod, baglam.KullaniciId], iptal);
                    kurulan.Add(kod);
                }
                else if (var_.resmiSurum > var_.kuruluSurum)
                {
                    await b.CalistirAsync("""
                        update public.form_sablon k set tanim = r.tanim, surum = r.surum, ad = r.ad, aciklama = r.aciklama, degistiren = @p1, degistirme_tarihi = now()
                          from public.form_sablon r where r.id = k.ust_sablon_id and r.resmi = 1 and r.kod = @p0 and k.resmi = 0
                        """, null, [kod, baglam.KullaniciId], iptal);
                    guncellenen.Add(kod);
                }
            }
            await log.YazAsync(LogIslemi.Ekle, 1190, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { kutuphane = true, kurulan, guncellenen }, iptal: iptal);
            return Results.Ok(new { kurulan, guncellenen });
        });

        // KOPYALA: kurum şablonundan yeni kod ile kopya (kurumun kendi varyantı).
        grup.MapPost("/sablon/{id:int}/kopyala", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("form.sablon", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var yeniId = await b.TekDegerAsync<int>("""
                insert into public.form_sablon (kod, ad, aile, baglam, kanal, imza_yontem, kaynak, kaynak_kod, kurum_tipleri, resmi, ust_sablon_id, surum, tanim,
                                                gecerlilik_saat, saklama_yil, tekrar_saat, asamali, durum, aciklama, sube_id, ekleyen)
                select s.kod || '_' || to_char(now(), 'MMDDHH24MI'), s.ad || ' (kopya)', s.aile, s.baglam, s.kanal, s.imza_yontem, 'Kurum', '', s.kurum_tipleri, 0, null, 1, s.tanim,
                       s.gecerlilik_saat, s.saklama_yil, s.tekrar_saat, s.asamali, 0, s.aciklama, s.sube_id, @p1
                  from public.form_sablon s where s.id = @p0 returning id
                """, null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { id = yeniId });
        });
    }

    // =============================================================== açık ====
    private static void AcikUclar(RouteGroupBuilder grup)
    {
        // Bağlantı açıldı: form adı, kurum, hasta kısa adı, doğrulama gerekli.
        grup.MapGet("/{kod}", async (string kod, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            OranSiniri(ctx);
            await using var b = await veri.AcAsync(iptal);
            var i = await AcikIstekBulAsync(b, kod, iptal);
            if (i is null) return Results.Ok(new { gecerli = false, neden = "Bağlantı geçersiz ya da kullanılmış." });
            if (i.durum is 4) return Results.Ok(new { gecerli = false, neden = "Bu form daha önce gönderildi; bağlantı kapandı." });
            if (i.durum is 6) return Results.Ok(new { gecerli = false, neden = "Çok sayıda hatalı deneme; bağlantı kilitlendi. Kurumunuzla görüşün." });
            if (i.durum is 7 or 8) return Results.Ok(new { gecerli = false, neden = "Bağlantı iptal edilmiş." });
            if (i.suresiDoldu)
            {
                await b.CalistirAsync("update public.form_istek set durum = 5 where id = @p0 and durum in (1, 2, 3)", null, [i.id], iptal);
                return Results.Ok(new { gecerli = false, neden = "Bağlantının süresi dolmuş; kurumunuz yeniden gönderebilir." });
            }
            if (i.durum == 1) await b.CalistirAsync("update public.form_istek set durum = 2, acilis = now(), ip = @p1, ua = @p2 where id = @p0", null, [i.id, BaglamCozucu.IpCoz(ctx), Ua(ctx)], iptal);
            var sube = await b.TekDegerAsync<string>("select ad from public.sube where id = @p0", null, [i.subeId], iptal) ?? "";
            return Results.Ok(new
            {
                gecerli = true, form = i.sablonAd, aile = i.aile, kurum = sube, hasta = KisaAd(i.hastaAd), gonderim = i.gonderim, son = i.son,
                dogrulamaGerekli = true, kalanDeneme = EnFazlaDeneme - i.deneme, dakika = 5,
            });
        });

        // KİMLİK DOĞRULAMA: TCKN son 4 + doğum yılı → oturum anahtarı + tanım + taslak.
        grup.MapPost("/{kod}/dogrula", async (string kod, AcikDogrulaIstegi g, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            OranSiniri(ctx);
            await using var b = await veri.AcAsync(iptal);
            var i = await AcikIstekBulAsync(b, kod, iptal) ?? throw GentegreHatasi.Bulunamadi("Bağlantı geçersiz.");
            if (i.durum is not (1 or 2 or 3)) throw GentegreHatasi.IsKurali("Bu bağlantı artık kullanılamaz.");
            if (i.suresiDoldu) throw GentegreHatasi.IsKurali("Bağlantının süresi dolmuş.");
            var son4 = (g.TcknSon4 ?? "").Trim();
            var yil = (g.DogumYili ?? "").Trim();
            var dogru = son4.Length == 4 && i.tckn.Length >= 4 && i.tckn.EndsWith(son4, StringComparison.Ordinal)
                        && (i.dogumYili is null || string.IsNullOrEmpty(yil) || yil == i.dogumYili.Value.ToString());
            // Hasta kartında doğum tarihi yoksa yıl istenmez; TCKN yoksa (kimliksiz)
            //   yalnız telefon sahipliği yeter (bağlantı zaten SMS ile geldi).
            if (string.IsNullOrEmpty(i.tckn)) dogru = true;
            if (!dogru)
            {
                var deneme = i.deneme + 1;
                await b.CalistirAsync("update public.form_istek set dogrulama_deneme = @p1, durum = case when @p1 >= @p2 then 6 else durum end where id = @p0", null, [i.id, (short)deneme, (short)EnFazlaDeneme], iptal);
                if (deneme >= EnFazlaDeneme) throw GentegreHatasi.IsKurali("Çok sayıda hatalı deneme; bağlantı kilitlendi.");
                throw GentegreHatasi.Dogrulama($"Bilgiler eşleşmedi. Kalan deneme: {EnFazlaDeneme - deneme}");
            }
            var oturum = Convert.ToHexString(RandomNumberGenerator.GetBytes(24));
            await b.CalistirAsync("update public.form_istek set oturum_anahtari = @p1, dogrulandi = now(), dogrulama_deneme = 0, ip = @p2, ua = @p3 where id = @p0",
                null, [i.id, oturum, BaglamCozucu.IpCoz(ctx), Ua(ctx)], iptal);
            var sube = await b.TekDegerAsync<string>("select ad from public.sube where id = @p0", null, [i.subeId], iptal) ?? "";
            var tanim = HastaBolumleri(i.tanim, i.cevap);
            return Results.Ok(new
            {
                oturum, dakika = OturumDakika, form = i.sablonAd, aile = i.aile, kurum = sube, hasta = i.hastaAd,
                tanim, taslak = JsonNode.Parse(i.taslak), parametreler = Parametreler(i.hastaAd, sube, i.cevap),
                rizaVar = i.rizaZamani is not null,
            });
        });

        grup.MapPost("/{kod}/taslak", async (string kod, AcikTaslakIstegi g, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            OranSiniri(ctx);
            await using var b = await veri.AcAsync(iptal);
            var i = await AcikOturumAsync(b, kod, g.Oturum, iptal);
            await b.CalistirAsync("update public.form_istek set taslak = cast(@p1 as jsonb), durum = 3 where id = @p0 and durum in (1, 2, 3)",
                null, [i.id, (g.Taslak ?? new JsonObject()).ToJsonString()], iptal);
            return Results.Ok(new { kaydedildi = DateTime.Now });
        });

        // GÖNDER: rıza + cevap + (beyan imzası) → tamamlandı, bağlantı kapanır.
        grup.MapPost("/{kod}/gonder", async (string kod, AcikGonderIstegi g, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            OranSiniri(ctx);
            await using var b = await veri.AcAsync(iptal);
            var i = await AcikOturumAsync(b, kod, g.Oturum, iptal);
            if (g.Reddetti == true)
            {
                await b.CalistirAsync("update public.form_istek set durum = 7, tamamlanma = now(), oturum_anahtari = '', belirtec_ozet = '' where id = @p0", null, [i.id], iptal);
                return Results.Ok(new { durum = 7 });
            }
            if (g.Riza != true) throw GentegreHatasi.Dogrulama("Açık rıza onayı gerekli.");
            var cevap = (g.Cevap ?? new JsonObject()).ToJsonString();
            var eksik = ZorunluEksikler(HastaBolumleri(i.tanim, i.cevap), g.Cevap ?? new JsonObject());
            if (eksik.Count > 0) throw GentegreHatasi.Dogrulama("Zorunlu alanlar boş: " + string.Join(", ", eksik));
            // Hekim bölümü cevapları korunur: hasta yalnız kendi bölümlerini yazar.
            var birlesik = Birlestir(i.cevap, cevap, i.tanim);
            var imzalar = g.Imzalar ?? new JsonArray();
            imzalar.Add(new JsonObject { ["rol"] = "hasta", ["ad"] = i.hastaAd, ["yontem"] = 5, ["zaman"] = DateTime.Now, ["ip"] = BaglamCozucu.IpCoz(ctx) });
            var (skor, sonuc) = SkorHesapla(i.tanim, birlesik);
            // Hekim/hemşire bölümü olan form (Ek-2 gibi) hastanın gönderimiyle BİTMEZ:
            //   beyan alındı (durum 3), bağlantı kapanır, personel iç ekranda tamamlar.
            var personelBolumuVar = PersonelBolumuVar(i.tanim);
            var yeniDurum = personelBolumuVar ? (short)3 : (short)4;
            await b.CalistirAsync("""
                update public.form_istek
                   set cevap = cast(@p1 as jsonb), taslak = '{}'::jsonb, imzalar = cast(@p2 as jsonb), riza_zamani = coalesce(riza_zamani, now()),
                       riza_metin_surum = @p3, durum = @p8, tamamlanma = case when @p8 = 4 then now() else tamamlanma end, skor = @p4, sonuc = @p5, ip = @p6, ua = @p7,
                       oturum_anahtari = '', belirtec_ozet = ''
                 where id = @p0
                """, null, [i.id, birlesik, imzalar.ToJsonString(), $"v{i.surum}", skor, sonuc, BaglamCozucu.IpCoz(ctx), Ua(ctx), yeniDurum], iptal);
            return Results.Ok(new { durum = (int)yeniDurum, tamamlanma = DateTime.Now, skor, sonuc, personelBolumuVar });
        });
    }

    // ============================================================ yardımcı ====
    private sealed record SablonSatiri(int id, string kod, string ad, int aile, int baglam, int kanal, int surum, int gecerlilikSaat);
    private sealed record HastaSatiri(int id, string ad, string cepTel, string eposta, string tckn, int? dogumYili);
    private sealed record AcikIstek(int id, short durum, DateTime? son, int subeId, string sablonAd, int aile, string hastaAd, string tckn, int? dogumYili,
                                    short deneme, string tanim, string taslak, string cevap, int surum, DateTime? gonderim, DateTime? rizaZamani,
                                    string oturum, DateTime? dogrulandi, bool suresiDoldu, bool oturumGecerli);

    private static readonly HashSet<string> MuayeneKolonlari = ["sikayet", "hikaye", "sistem_sorgusu", "ozgecmis_notu", "soygecmis_notu", "aliskanlik_notu", "bulgu_ozet"];

    private static async Task<SablonSatiri> SablonBulAsync(NpgsqlConnection b, int? id, string? kod, CancellationToken iptal)
        => await b.TekAsync("""
            select id, kod, ad, aile, baglam, kanal, surum, gecerlilik_saat from public.form_sablon
             where resmi = 0 and durum = 1 and ((@p0::int is not null and id = @p0) or (@p0::int is null and kod = @p1))
             order by id limit 1
            """, null, [id, kod], o => new SablonSatiri(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetInt16(3), o.GetInt16(4), o.GetInt16(5), o.GetInt16(6), o.GetInt16(7)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Aktif form şablonu bulunamadı (kütüphaneden kurun).");

    private static Task<HastaSatiri?> HastaOkuAsync(NpgsqlConnection b, int hastaId, CancellationToken iptal)
        => b.TekAsync("""
            select t.id, coalesce(nullif(trim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')), ''), t.unvan, ''),
                   coalesce(t.cep_tel, ''), coalesce(t.eposta, ''), coalesce(t.vkno, ''), extract(year from h.dogum_tarihi)::int
              from public.taraf t left join public.taraf_hasta h on h.id = t.id where t.id = @p0
            """, null, [hastaId], o => new HastaSatiri(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3), o.GetString(4), o.IsDBNull(5) ? null : o.GetInt32(5)), iptal);

    private static async Task<string?> IstekOkuAsync(NpgsqlConnection b, int id, CancellationToken iptal)
    {
        var istek = await b.TekAsync("select row_to_json(i)::text from public.v_form_istek i where i.id = @p0", null, [id], o => o.GetString(0), iptal);
        if (istek is null) return null;
        var d = await b.TekAsync("select s.tanim::text, i.taslak::text, i.cevap::text, i.imzalar::text, s.ad, i.hasta_id, s.imza_yontem, s.asamali from public.form_istek i join public.form_sablon s on s.id = i.sablon_id where i.id = @p0",
            null, [id], o => new { tanim = o.GetString(0), taslak = o.GetString(1), cevap = o.GetString(2), imzalar = o.GetString(3), ad = o.GetString(4), hastaId = o.IsDBNull(5) ? 0 : o.GetInt32(5), imzaYontem = (int)o.GetInt16(6), asamali = (int)o.GetInt16(7) }, iptal);
        var hasta = d!.hastaId > 0 ? await HastaOkuAsync(b, d.hastaId, iptal) : null;
        var sube = await b.TekDegerAsync<string>("select ad from public.sube order by id limit 1", null, [], iptal) ?? "";
        return $"{{\"istek\":{istek},\"tanim\":{d.tanim},\"taslak\":{d.taslak},\"cevap\":{d.cevap},\"imzalar\":{d.imzalar},\"imzaYontem\":{d.imzaYontem},\"asamali\":{d.asamali},"
             + $"\"parametreler\":{JsonSerializer.Serialize(Parametreler(hasta?.ad ?? "", sube, d.cevap))}}}";
    }

    public sealed record GonderSonucu(int id, string? kod, string? baglanti, long? bildirimId);

    private static async Task<IResult> GonderCalistir(GonderIstegi g, NpgsqlConnection b, BildirimDeposu bildirim, LogDeposu log, IstekBaglami baglam, HttpContext ctx, CancellationToken iptal)
        => Results.Ok(await GonderCalistirAsync(g, b, bildirim, log, baglam, ctx, iptal));

    /// <summary>Gönderimin çekirdeği - İSG (741) Ek-2 muayenesi de buradan istek açar.</summary>
    public static async Task<GonderSonucu> GonderCalistirAsync(GonderIstegi g, NpgsqlConnection b, BildirimDeposu bildirim, LogDeposu log, IstekBaglami baglam, HttpContext ctx, CancellationToken iptal)
    {
        var sablon = await SablonBulAsync(b, g.SablonId, g.SablonKod, iptal);
        var hasta = await HastaOkuAsync(b, g.HastaId, iptal) ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");
        var kanal = (short)(g.Kanal ?? sablon.kanal);
        var saat = g.GecerlilikSaat ?? sablon.gecerlilikSaat; if (saat <= 0) saat = 72;
        var alici = kanal == 3 ? hasta.cepTel : kanal == 4 ? hasta.eposta : "";
        if ((kanal == 3 || kanal == 4) && string.IsNullOrWhiteSpace(alici)) throw GentegreHatasi.IsKurali("Hastanın iletişim bilgisi yok.");
        var (kod, ozet) = BelirtecUret();
        var id = await b.TekDegerAsync<int>("""
            insert into public.form_istek (sablon_id, surum, hasta_id, kaynak_tur, kaynak_id, kanal, belirtec_ozet, son_gecerlilik, gonderim, durum, aciklama, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, now() + make_interval(hours => @p7), now(), 1, @p8, @p9, @p10) returning id
            """, null, [sablon.id, (short)sablon.surum, g.HastaId, (short)(g.KaynakTur ?? sablon.baglam), g.KaynakId, kanal, ozet, saat, g.Not ?? "", baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
        var baglanti = BaglantiKur(ctx, kod);
        long? bildirimId = null;
        if (kanal is 3 or 4)
        {
            var kurum = baglam.Subeler.FirstOrDefault(s => s.Id == baglam.SubeId)?.Ad ?? "GenoTIP";
            bildirimId = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(kanal == 3 ? "form.baglanti" : "form.baglanti.eposta", kanal == 3 ? BildirimKanali.Sms : BildirimKanali.Eposta, alici,
                new Dictionary<string, string> { ["kurum"] = kurum, ["form"] = sablon.ad, ["baglanti"] = baglanti, ["saat"] = saat.ToString(), ["gonderen"] = kurum, ["hasta"] = hasta.ad },
                TarafId: g.HastaId, KaynakTur: 40, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
            await b.CalistirAsync("update public.form_istek set bildirim_id = @p1 where id = @p0", null, [id, bildirimId], iptal);
        }
        await log.YazAsync(LogIslemi.Ekle, LogIstek, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { sablon = sablon.kod, kanal, not_ = g.Not }, tarafId: g.HastaId, iptal: iptal);
        return new GonderSonucu(id, kanal is 1 or 2 ? kod : null, kanal is 1 or 2 ? baglanti : null, bildirimId);
    }

    private static async Task<AcikIstek?> AcikIstekBulAsync(NpgsqlConnection b, string kod, CancellationToken iptal)
    {
        var temiz = new string((kod ?? "").Where(char.IsLetterOrDigit).ToArray()).ToUpperInvariant();
        if (temiz.Length < 8) return null;
        var ozet = Ozet(temiz);
        return await b.TekAsync("""
            select i.id, i.durum, i.son_gecerlilik, i.sube_id, s.ad, s.aile,
                   coalesce(nullif(trim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')), ''), t.unvan, ''), coalesce(t.vkno, ''), extract(year from h.dogum_tarihi)::int,
                   i.dogrulama_deneme, s.tanim::text, i.taslak::text, i.cevap::text, i.surum, i.gonderim, i.riza_zamani, i.oturum_anahtari, i.dogrulandi,
                   (i.son_gecerlilik is not null and i.son_gecerlilik < now()),
                   (i.oturum_anahtari <> '' and i.dogrulandi is not null and i.dogrulandi > now() - make_interval(mins => @p1))
              from public.form_istek i join public.form_sablon s on s.id = i.sablon_id
              left join public.taraf t on t.id = i.hasta_id left join public.taraf_hasta h on h.id = t.id
             where i.belirtec_ozet = @p0
            """, null, [ozet, OturumDakika], o => new AcikIstek(o.GetInt32(0), o.GetInt16(1), o.IsDBNull(2) ? null : o.GetDateTime(2), o.GetInt32(3), o.GetString(4), o.GetInt16(5),
                o.GetString(6), o.GetString(7), o.IsDBNull(8) ? null : o.GetInt32(8), o.GetInt16(9), o.GetString(10), o.GetString(11), o.GetString(12), o.GetInt16(13),
                o.IsDBNull(14) ? null : o.GetDateTime(14), o.IsDBNull(15) ? null : o.GetDateTime(15), o.GetString(16), o.IsDBNull(17) ? null : o.GetDateTime(17),
                o.GetBoolean(18), o.GetBoolean(19)), iptal);
    }

    private static async Task<AcikIstek> AcikOturumAsync(NpgsqlConnection b, string kod, string oturum, CancellationToken iptal)
    {
        var i = await AcikIstekBulAsync(b, kod, iptal) ?? throw GentegreHatasi.Bulunamadi("Bağlantı geçersiz.");
        if (i.durum is not (1 or 2 or 3)) throw GentegreHatasi.IsKurali("Bu bağlantı artık kullanılamaz.");
        if (!i.oturumGecerli || i.oturum != oturum)
            throw GentegreHatasi.Yetkisiz("Oturum süresi doldu; kimliğinizi yeniden doğrulayın.");
        return i;
    }

    /// <summary>Kısa kod (Crockford Base32, 16 karakter) + SHA-256 özeti. Ham kod yalnız bağlantıda yaşar.</summary>
    private static (string kod, string ozet) BelirtecUret()
    {
        const string abc = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";
        var bayt = RandomNumberGenerator.GetBytes(10);
        var sb = new StringBuilder(16);
        ulong biriktir = 0; int bit = 0;
        foreach (var b in bayt)
        {
            biriktir = (biriktir << 8) | b; bit += 8;
            while (bit >= 5) { bit -= 5; sb.Append(abc[(int)((biriktir >> bit) & 31)]); }
        }
        var kod = sb.ToString();
        return (kod, Ozet(kod));
    }
    private static string Ozet(string kod) => Convert.ToHexString(SHA256.HashData(Encoding.ASCII.GetBytes("form:" + kod))).ToLowerInvariant();

    /// <summary>Açık sayfa adresi: web'in kökü (Origin / Referer) + /f/{kod}; yoksa istek adresi.</summary>
    private static string BaglantiKur(HttpContext ctx, string kod)
    {
        var kok = ctx.Request.Headers.Origin.ToString();
        if (string.IsNullOrEmpty(kok) && Uri.TryCreate(ctx.Request.Headers.Referer.ToString(), UriKind.Absolute, out var r)) kok = r.GetLeftPart(UriPartial.Authority) + (r.AbsolutePath.StartsWith("/ai") ? "/ai" : "");
        if (string.IsNullOrEmpty(kok)) kok = $"{ctx.Request.Scheme}://{ctx.Request.Host}";
        return $"{kok.TrimEnd('/')}/f/{kod}";
    }

    private static string Maskele(string s) => s.Length <= 4 ? "****" : new string('*', s.Length - 4) + s[^4..];
    private static string Ua(HttpContext ctx) { var u = ctx.Request.Headers.UserAgent.ToString(); return u.Length > 200 ? u[..200] : u; }
    private static string KisaAd(string ad)
    {
        var p = ad.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        return p.Length == 0 ? "" : p.Length == 1 ? p[0] : $"{p[0]} {p[^1][0]}.";
    }

    // ---------------------------------------------------- oran sınırı (IP) ----
    private static readonly ConcurrentDictionary<string, (DateTime dk, int sayi)> _oran = new();
    private static void OranSiniri(HttpContext ctx)
    {
        var ip = BaglamCozucu.IpCoz(ctx);
        var simdi = DateTime.UtcNow;
        var v = _oran.AddOrUpdate(ip, _ => (simdi, 1), (_, e) => e.dk.AddMinutes(1) < simdi ? (simdi, 1) : (e.dk, e.sayi + 1));
        if (v.sayi > 40) throw GentegreHatasi.IsKurali("Çok sık istek; bir dakika bekleyin.");
        if (_oran.Count > 5000) foreach (var k in _oran.Where(x => x.Value.dk.AddMinutes(2) < simdi).Select(x => x.Key).ToList()) _oran.TryRemove(k, out _);
    }

    // ----------------------------------------------------------- tanım işleri ----
    /// <summary>Hastanın / çalışanın doldurduğu bölümler (sahip = hasta | calisan).</summary>
    private static JsonObject HastaBolumleri(string tanimJson, string cevapJson)
    {
        var tanim = JsonNode.Parse(tanimJson) as JsonObject ?? new JsonObject();
        var sonuc = new JsonObject();
        var bolumler = new JsonArray();
        foreach (var bn in (tanim["bolumler"] as JsonArray) ?? [])
        {
            if (bn is not JsonObject bo) continue;
            var sahip = bo["sahip"]?.ToString() ?? "hasta";
            if (sahip is "hasta" or "calisan") bolumler.Add(JsonNode.Parse(bo.ToJsonString()));
        }
        sonuc["bolumler"] = bolumler;
        if (tanim["imzalar"] is JsonArray im) sonuc["imzalar"] = JsonNode.Parse(im.ToJsonString());
        if (tanim["hesap"] is JsonObject he) sonuc["hesap"] = JsonNode.Parse(he.ToJsonString());
        return sonuc;
    }

    /// <summary>Metin bloklarındaki {hasta.ad} {kurum.ad} ve hekim bölümü cevapları ({islem} gibi).</summary>
    private static Dictionary<string, string> Parametreler(string hastaAd, string kurum, string cevapJson)
    {
        var p = new Dictionary<string, string> { ["hasta.ad"] = hastaAd, ["kurum.ad"] = kurum, ["tarih"] = DateTime.Today.ToString("dd.MM.yyyy") };
        if (JsonNode.Parse(cevapJson) is JsonObject c)
            foreach (var (k, v) in c) if (v is JsonValue) p[k] = v.ToString();
        return p;
    }

    private static List<string> ZorunluEksikler(JsonObject tanim, JsonObject cevap)
    {
        var eksik = new List<string>();
        foreach (var bn in (tanim["bolumler"] as JsonArray) ?? [])
            foreach (var an in ((bn as JsonObject)?["alanlar"] as JsonArray) ?? [])
            {
                if (an is not JsonObject a || a["zorunlu"]?.GetValue<bool>() != true) continue;
                var kod = a["kod"]?.ToString() ?? "";
                var v = cevap[kod];
                var bos = v is null || (v is JsonValue jv && (jv.ToString() is "" or "false" or "null"));
                if (bos) eksik.Add(a["etiket"]?.ToString() ?? kod);
            }
        return eksik;
    }

    /// <summary>Hasta cevabı hekim bölümlerinin üstüne yazmaz: hekim alanları eski cevaptan korunur.</summary>
    private static string Birlestir(string eskiJson, string yeniJson, string tanimJson)
    {
        var eski = JsonNode.Parse(eskiJson) as JsonObject ?? new JsonObject();
        var yeni = JsonNode.Parse(yeniJson) as JsonObject ?? new JsonObject();
        var hastaAlanlari = new HashSet<string>();
        foreach (var bn in ((JsonNode.Parse(tanimJson) as JsonObject)?["bolumler"] as JsonArray) ?? [])
        {
            if (bn is not JsonObject bo) continue;
            var sahip = bo["sahip"]?.ToString() ?? "hasta";
            if (sahip is not ("hasta" or "calisan")) continue;
            foreach (var an in (bo["alanlar"] as JsonArray) ?? []) if (an is JsonObject a && a["kod"] is not null) hastaAlanlari.Add(a["kod"]!.ToString());
        }
        foreach (var (k, v) in yeni.ToList()) if (hastaAlanlari.Contains(k) || !eski.ContainsKey(k)) eski[k] = v is null ? null : JsonNode.Parse(v.ToJsonString());
        return eski.ToJsonString();
    }

    private static bool PersonelBolumuVar(string tanimJson)
    {
        foreach (var bn in ((JsonNode.Parse(tanimJson) as JsonObject)?["bolumler"] as JsonArray) ?? [])
            if (bn is JsonObject bo && (bo["sahip"]?.ToString() ?? "hasta") is not ("hasta" or "calisan")) return true;
        return false;
    }

    private static int AsamaSayisi(string tanimJson)
    {
        var enBuyuk = 1;
        foreach (var bn in ((JsonNode.Parse(tanimJson) as JsonObject)?["bolumler"] as JsonArray) ?? [])
            if (bn is JsonObject bo && bo["asama"] is JsonValue v && int.TryParse(v.ToString(), out var a) && a > enBuyuk) enBuyuk = a;
        return enBuyuk;
    }

    private static IEnumerable<(string kod, string hedef, string etiket)> HedefAlanlar(string tanimJson)
    {
        foreach (var bn in ((JsonNode.Parse(tanimJson) as JsonObject)?["bolumler"] as JsonArray) ?? [])
            foreach (var an in ((bn as JsonObject)?["alanlar"] as JsonArray) ?? [])
                if (an is JsonObject a && a["hedefAlan"] is JsonValue h && !string.IsNullOrEmpty(h.ToString()))
                    yield return (a["kod"]?.ToString() ?? "", h.ToString(), a["etiket"]?.ToString() ?? a["kod"]?.ToString() ?? "");
    }

    /// <summary>
    /// SKOR: skor tablosu alanlarında seçilen satır puanları toplanır; `hesap.kaynak`
    /// verilmişse o ölçek alanının değeri; `hesap.ortalama` ise ölçek alanlarının
    /// ortalaması. Eşik listesi sonucu (ad) verir. Sunucuda hesaplanır - istemci
    /// gösterir ama yazmaz.
    /// </summary>
    public static (decimal? skor, string sonuc) SkorHesapla(string tanimJson, string cevapJson)
    {
        var tanim = JsonNode.Parse(tanimJson) as JsonObject;
        var cevap = JsonNode.Parse(cevapJson) as JsonObject ?? new JsonObject();
        if (tanim is null) return (null, "");
        var hesap = tanim["hesap"] as JsonObject;
        decimal toplam = 0; var var_ = false; var olcekler = new List<decimal>();
        var kaynak = hesap?["kaynak"]?.ToString();
        foreach (var bn in (tanim["bolumler"] as JsonArray) ?? [])
            foreach (var an in ((bn as JsonObject)?["alanlar"] as JsonArray) ?? [])
            {
                if (an is not JsonObject a) continue;
                var tip = a["tip"]?.ToString(); var kod = a["kod"]?.ToString() ?? "";
                if (tip == "skor" && cevap[kod] is JsonObject secimler)
                    foreach (var sn in (a["satirlar"] as JsonArray) ?? [])
                    {
                        if (sn is not JsonObject satir) continue;
                        var sk = satir["kod"]?.ToString() ?? "";
                        if (secimler[sk] is JsonValue sv && int.TryParse(sv.ToString(), out var idx))
                        {
                            var secenek = (satir["secenek"] as JsonArray)?.ElementAtOrDefault(idx) as JsonObject;
                            if (secenek?["puan"] is JsonValue pv && decimal.TryParse(pv.ToString(), out var puan)) { toplam += puan; var_ = true; }
                        }
                    }
                else if (tip == "olcek" && cevap[kod] is JsonValue ov && decimal.TryParse(ov.ToString(), out var od))
                {
                    olcekler.Add(od);
                    if (kaynak == kod) { toplam = od; var_ = true; }
                }
            }
        if (!var_ && hesap?["ortalama"]?.GetValue<bool>() == true && olcekler.Count > 0) { toplam = Math.Round(olcekler.Average(), 2); var_ = true; }
        if (!var_) return (null, "");
        var sonuc = "";
        foreach (var en in (hesap?["esikler"] as JsonArray) ?? [])
            if (en is JsonObject e && decimal.TryParse(e["min"]?.ToString(), out var mn) && decimal.TryParse(e["max"]?.ToString(), out var mx) && toplam >= mn && toplam <= mx)
            { sonuc = e["ad"]?.ToString() ?? ""; break; }
        return (toplam, sonuc);
    }
}
