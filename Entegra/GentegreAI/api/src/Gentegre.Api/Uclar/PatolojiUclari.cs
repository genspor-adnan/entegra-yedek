using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PATOLOJİ (1104) — vaka ve dış lab gönderimi adımları. Vaka ve tanımların
/// kartı genel kart motorundadır (KartKatalogu.Patoloji); burada yalnız DURUM
/// ilerleten adımlar var: durum serbest düzenlenseydi TAT ve kayıp numune izi
/// (kim, ne zaman, hangi pakette) güvenilmez olurdu.
///
/// Mockup: Ekranlar/Patoloji/patoloji_vakalar.html, patoloji_gonderim.html.
/// Entegrasyon (API / HL7 / FHIR / portal) aşama 3; şimdilik "elle" yolu:
/// laba iletim basılı form / portal, lab kabul ve rapor elle girilir.
/// </summary>
public static class PatolojiUclari
{
    private const int LogVaka = 1390, LogGonderim = 1394;

    public sealed record LabKabulIstegi(string? LabVakaNo);
    public sealed record PaketIstegi(int[] Idler);
    public sealed record RetIstegi(int? RetNedeniId, string? Aciklama);
    public sealed record KuryeIstegi(string? Kurye);
    public sealed record TeslimIstegi(string? TeslimAlan);

    /// <summary>Başvuru kapısı (1105): hekim istemi bankoda ücretlendirilip başvuru kaydedilmeden çalışılmaz.</summary>
    private const string BankoBekliyor = "Vaka başvuru kaydı bekliyor: bankoda ücretlendirilip başvuru kaydedilmeden çalışılamaz.";

    private static string Kirp(string? s, int n) => (s ?? "").Trim() is var t && t.Length > n ? t[..n] : (s ?? "").Trim();

    public static void PatolojiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/patoloji").WithTags("Patoloji").RequireAuthorization();

        // ------------------------------------------------------------ vaka ----
        // HAZIRLANDI: kaplar etiketlendi. Materyalsiz vaka hazırlanamaz; dış labda lab seçili olmalı.
        grup.MapPost("/vaka/{id:int}/hazirlandi", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.vaka", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var v = await b.TekAsync("select durum, calisma_yeri, dis_lab_id, (select count(*) from public.pat_materyal m where m.vaka_id = v.id)::int, serbest from public.pat_vaka v where id = @p0",
                null, [id], o => new { durum = o.GetInt16(0), yer = o.GetInt16(1), lab = o.IsDBNull(2) ? (int?)null : o.GetInt32(2), kap = o.GetInt32(3), serbest = o.GetInt16(4) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Vaka bulunamadı.");
            if (v.serbest == 0) throw GentegreHatasi.IsKurali(BankoBekliyor);
            if (v.durum != 1) throw GentegreHatasi.IsKurali("Yalnız 'İstendi' durumundaki vaka hazırlanabilir.");
            if (v.kap == 0) throw GentegreHatasi.IsKurali("Vakada materyal (kap) yok - önce materyal ekleyin.");
            if (v.yer == 1 && v.lab is null) throw GentegreHatasi.IsKurali("Dış laboratuvar seçilmemiş.");
            await b.CalistirAsync("update public.pat_vaka set durum = 2, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogVaka, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Hazırlandı" }, iptal: iptal);
            return Results.Ok(new { id, mesaj = "Vaka hazırlandı - gönderim paketine eklenebilir." });
        });

        // PAKETE EKLE: aynı laba gidecek vakalar tek pakette. O labın şubedeki AÇIK
        //   paketi (hazırlanıyor) varsa ona, yoksa yeni paket. Bir vaka bir pakete.
        grup.MapPost("/vaka/pakete-ekle", async (PaketIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.gonderim", Islem.Degistir);
            if (g.Idler is not { Length: > 0 }) throw GentegreHatasi.Dogrulama("Vaka seçilmedi.");
            await using var b = await veri.AcAsync(iptal);
            var vakalar = await b.ListeAsync(
                "select id, vaka_no, durum, calisma_yeri, dis_lab_id, gonderim_id, serbest from public.pat_vaka where id = any(@p0)",
                null, [g.Idler], o => new { id = o.GetInt32(0), no = o.GetString(1), durum = o.GetInt16(2), yer = o.GetInt16(3),
                                            lab = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), paket = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
                                            serbest = o.GetInt16(6) }, iptal);
            var eklenen = new List<string>(); var atlanan = new List<string>(); var paketler = new HashSet<string>();
            foreach (var v in vakalar)
            {
                if (v.serbest == 0) { atlanan.Add($"{v.no} (başvuru kaydı bekliyor)"); continue; }
                if (v.yer != 1 || v.lab is null) { atlanan.Add($"{v.no} (kurum içi / lab yok)"); continue; }
                if (v.paket is not null) { atlanan.Add($"{v.no} (zaten pakette)"); continue; }
                if (v.durum is not (1 or 2)) { atlanan.Add($"{v.no} (durum uygun değil)"); continue; }
                var paketId = await b.TekDegerAsync<int?>(
                    "select id from public.pat_gonderim where dis_lab_id = @p0 and durum = 1 and sube_id = @p1 order by id desc limit 1",
                    null, [v.lab, baglam.SubeId], iptal);
                if (paketId is null)
                {
                    paketId = await b.TekDegerAsync<int>(
                        "insert into public.pat_gonderim (dis_lab_id, sube_id, ekleyen) values (@p0, @p1, @p2) returning id",
                        null, [v.lab, baglam.SubeId, baglam.KullaniciId], iptal);
                    await log.YazAsync(LogIslemi.Ekle, LogGonderim, paketId.Value, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { otomatik = true }, iptal: iptal);
                }
                await b.CalistirAsync("update public.pat_vaka set gonderim_id = @p1, durum = 2, degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                    null, [v.id, paketId, baglam.KullaniciId], iptal);
                paketler.Add(await b.TekDegerAsync<string>("select gonderim_no from public.pat_gonderim where id = @p0", null, [paketId], iptal) ?? "");
                eklenen.Add(v.no);
            }
            var mesaj = eklenen.Count > 0 ? $"{eklenen.Count} vaka pakete eklendi ({string.Join(", ", paketler)})." : "Pakete eklenen vaka yok.";
            if (atlanan.Count > 0) mesaj += " Atlanan: " + string.Join(", ", atlanan) + ".";
            return Results.Ok(new { mesaj });
        });

        grup.MapPost("/vaka/{id:int}/paketten-cikar", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.gonderim", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync(
                "update public.pat_vaka v set gonderim_id = null, degistiren = @p1, degistirme_tarihi = now() " +
                " where v.id = @p0 and exists (select 1 from public.pat_gonderim g where g.id = v.gonderim_id and g.durum = 1)",
                null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Vaka açık bir pakette değil (paket yola çıktıysa çıkarılamaz).");
            return Results.Ok(new { id, mesaj = "Vaka paketten çıkarıldı." });
        });

        // LAB KABUL: lab "teslim aldım" der, kendi vaka numarasını döner - TAT başlar.
        grup.MapPost("/vaka/{id:int}/lab-kabul", async (int id, LabKabulIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.vaka", Islem.Degistir);
            var no = Kirp(g.LabVakaNo, 40);
            if (no == "") throw GentegreHatasi.Dogrulama("Lab vaka numarası girilmedi.");
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync(
                "update public.pat_vaka set durum = 4, lab_vaka_no = @p1, kabul_zamani = coalesce(kabul_zamani, now()), degistiren = @p2, degistirme_tarihi = now() " +
                " where id = @p0 and calisma_yeri = 1 and durum in (2, 3) and serbest = 1", null, [id, no, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Lab kabulü yalnız başvurusu kaydedilmiş, hazırlanmış / gönderilmiş dış lab vakasında girilir.");
            await log.YazAsync(LogIslemi.Degistir, LogVaka, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Lab kabul etti", labVakaNo = no }, iptal: iptal);
            return Results.Ok(new { id, mesaj = $"Lab kabul etti · {no} - TAT başladı." });
        });

        grup.MapPost("/vaka/{id:int}/ret", async (int id, RetIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.vaka", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync(
                "update public.pat_vaka set durum = 90, ret_nedeni_id = @p1, aciklama = case when @p2 = '' then aciklama else @p2 end, " +
                " degistiren = @p3, degistirme_tarihi = now() where id = @p0 and durum between 1 and 4",
                null, [id, g.RetNedeniId, Kirp(g.Aciklama, 600), baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Rapor aşamasına geçmiş vaka reddedilemez.");
            await log.YazAsync(LogIslemi.Degistir, LogVaka, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Reddedildi", g.RetNedeniId, g.Aciklama }, iptal: iptal);
            return Results.Ok(new { id, mesaj = "Vaka reddedildi - isteyen hekime bildirilmeli." });
        });

        // İPTAL: hekim istemden vazgeçti (muayeneden "🗑"). Yalnız hazırlanmamış, pakete
        //   girmemiş vaka; başvuruya düşen ücret satırı bankoda ayrıca kaldırılır.
        grup.MapPost("/vaka/{id:int}/iptal", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("patoloji.vaka", Islem.Degistir) && !baglam.Yetkiler.Var("muayene", Islem.Degistir))
                throw GentegreHatasi.Yasak();
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync(
                "update public.pat_vaka set durum = 0, degistiren = @p1, degistirme_tarihi = now() " +
                " where id = @p0 and durum = 1 and gonderim_id is null", null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Hazırlanmış / gönderilmiş vaka iptal edilemez.");
            await log.YazAsync(LogIslemi.Degistir, LogVaka, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "İptal" }, iptal: iptal);
            return Results.Ok(new { id, mesaj = "Patoloji istemi iptal edildi." });
        });

        // GÖRDÜM: isteyen hekim raporu açtı / okudu. Raporsuz vaka "görülemez".
        grup.MapPost("/vaka/{id:int}/gordum", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.vaka", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync(
                "update public.pat_vaka set durum = 12, gordu_zamani = now(), gordu_id = @p1 where id = @p0 and durum = 11",
                null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Raporu gelmemiş (ya da zaten görülmüş) vaka.");
            await log.YazAsync(LogIslemi.Degistir, LogVaka, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Hekim gördü" }, iptal: iptal);
            return Results.Ok(new { id, mesaj = "Rapor görüldü olarak işaretlendi." });
        });

        // EK İNCELEME ONAYI: lab "İHK / özel boya gerekli" dediyse ek ücrettir.
        //   Onay bekleyen satırların hepsine karar verilir; onaysız ek inceleme
        //   faturaya giremez (mutabakatta yakalanır).
        grup.MapPost("/vaka/{id:int}/ek-{karar}", async (int id, string karar, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.ek-onay", Islem.Gor);
            if (karar is not ("onayla" or "reddet")) throw GentegreHatasi.Bulunamadi();
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync(
                "update public.pat_ek_inceleme set onay = @p1, onaylayan_id = @p2, onay_zamani = now(), degistiren = @p2, degistirme_tarihi = now() " +
                " where vaka_id = @p0 and onay = 1", null, [id, (short)(karar == "onayla" ? 2 : 3), baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Bu vakada onay bekleyen ek inceleme yok.");
            await log.YazAsync(LogIslemi.Degistir, LogVaka, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { ekInceleme = karar, adet = n }, iptal: iptal);
            return Results.Ok(new { id, mesaj = karar == "onayla" ? $"{n} ek inceleme onaylandı." : $"{n} ek inceleme reddedildi." });
        });

        // ------------------------------------------------------- gönderim ----
        // LABA İLET: istem bilgisi kap yola çıkmadan laba gider. Entegrasyon (aşama 3)
        //   gelene kadar elle: basılı istem formu kapla / portal.
        grup.MapPost("/gonderim/{id:int}/ilet", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.gonderim", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var vaka = await b.TekDegerAsync<long>("select count(*) from public.pat_vaka where gonderim_id = @p0", null, [id], iptal);
            if (vaka == 0) throw GentegreHatasi.IsKurali("Pakette vaka yok.");
            var n = await b.CalistirAsync(
                "update public.pat_gonderim set iletim_durumu = 1, iletim_zamani = now(), " +
                " iletim_mesaji = 'Elle iletildi (basılı istem formu / portal)', degistiren = @p1, degistirme_tarihi = now() " +
                " where id = @p0 and durum in (1, 2)", null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Gönderim kapanmış.");
            await log.YazAsync(LogIslemi.Degistir, LogGonderim, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { iletim = "elle", vaka }, iptal: iptal);
            return Results.Ok(new { id, mesaj = $"{vaka} vakanın istemi laba iletildi (elle)." });
        });

        // KURYE TESLİM ALDI: paket binadan çıktı - vakalar "Gönderildi".
        grup.MapPost("/gonderim/{id:int}/kurye", async (int id, KuryeIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.gonderim", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var vaka = await b.TekDegerAsync<long>("select count(*) from public.pat_vaka where gonderim_id = @p0", null, [id], iptal);
            if (vaka == 0) throw GentegreHatasi.IsKurali("Pakette vaka yok.");
            var n = await b.CalistirAsync(
                "update public.pat_gonderim set durum = 2, kurye_zamani = now(), kurye = case when @p1 = '' then kurye else @p1 end, " +
                " degistiren = @p2, degistirme_tarihi = now() where id = @p0 and durum = 1", null, [id, Kirp(g.Kurye, 120), baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız hazırlanan paket kuryeye verilir.");
            await b.CalistirAsync("update public.pat_vaka set durum = 3, degistiren = @p1, degistirme_tarihi = now() where gonderim_id = @p0 and durum in (1, 2)",
                null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogGonderim, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Yolda", g.Kurye }, iptal: iptal);
            return Results.Ok(new { id, mesaj = $"Paket yola çıktı · {vaka} vaka gönderildi." });
        });

        grup.MapPost("/gonderim/{id:int}/lab-teslim", async (int id, TeslimIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("patoloji.gonderim", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync(
                "update public.pat_gonderim set durum = 3, teslim_zamani = now(), teslim_alan = case when @p1 = '' then teslim_alan else @p1 end, " +
                " degistiren = @p2, degistirme_tarihi = now() where id = @p0 and durum = 2", null, [id, Kirp(g.TeslimAlan, 120), baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız yoldaki paket teslim edilir.");
            await log.YazAsync(LogIslemi.Degistir, LogGonderim, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Lab teslim aldı", g.TeslimAlan }, iptal: iptal);
            return Results.Ok(new { id, mesaj = "Lab paketi teslim aldı - vakaların lab kabulü (lab vaka no) bekleniyor." });
        });
    }
}
