using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DICOM GÖRÜNTÜLEME (kullanıcı 11.11.2026: ClearCanvas ImageServer + OHIF).
///
/// Akış: radyoloji istemi (study_uid ya da accession) → <c>GET /api/dicom/goruntule</c> (oturum + radyoloji yetkisi)
/// → OHIF adresi: <c>{OHIF}/viewer/dicomjson?url={API}/api/dicom/manifest/{studyUid}?t=…</c>. OHIF manifesti ve
/// görüntüleri anonim ama JETONLU uçlardan okur (tarayıcı JWT başlığı taşıyamaz); jeton çalışma UID'sine bağlı ve
/// süreli (DicomKaynagi). Görüntüler ClearCanvas WADO'dan bu API üzerinden akar (vekil) - CORS / ağ sorunu yok.
/// </summary>
public static class DicomUclari
{
    public static void DicomUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dicom").WithTags("DICOM / OHIF");

        // ------------------------------------------------ görüntüleyici adresi (oturumlu) --
        grup.MapGet("/goruntule", async (int? istemId, string? studyUid, string? accession, DicomKaynagi dicom, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            if (!dicom.Ayar.Aktif) throw GentegreHatasi.IsKurali("DICOM sunucusu tanımlı değil (Dicom:Aktif).");

            var uid = (studyUid ?? "").Trim();
            var acc = (accession ?? "").Trim();
            if (istemId is > 0)
            {
                var k = await veri.TekAsync("select coalesce(study_uid, '') as uid, coalesce(accession_no, '') as acc from public.radyoloji_istem where id = @p0",
                    [istemId.Value], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");
                if (uid.Length == 0) uid = Convert.ToString(k["uid"]) ?? "";
                if (acc.Length == 0) acc = Convert.ToString(k["acc"]) ?? "";
            }
            if (uid.Length == 0 && acc.Length > 0)
            {
                uid = await dicom.AccessionIleStudyAsync(acc, iptal) ?? "";
                // Bulunan UID isteme yazılır - bir sonraki açılış C-FIND'sız.
                if (uid.Length > 0 && istemId is > 0)
                    await veri.CalistirAsync("update public.radyoloji_istem set study_uid = @p1 where id = @p0 and coalesce(study_uid, '') = ''",
                        [istemId.Value, uid], iptal);
            }
            if (uid.Length == 0)
                throw GentegreHatasi.IsKurali("Bu istemin görüntüsü PACS'ta bulunamadı (Study UID / accession eşleşmedi).");

            var jeton = dicom.JetonUret(uid);
            var kok = $"{ctx.Request.Scheme}://{ctx.Request.Host}";
            var manifest = $"{kok}/api/dicom/manifest/{Uri.EscapeDataString(uid)}?t={jeton}";
            var url = $"{dicom.Ayar.GoruntuleyiciUrl.TrimEnd('/')}/viewer/dicomjson?url={Uri.EscapeDataString(manifest)}";
            return Results.Ok(new { url, studyUid = uid, manifest, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ hastanın PACS çalışmaları (oturumlu) --
        //   Hasta kartı "PACS Görüntüleri" sekmesi: ad / kimlik eşlemesiyle C-FIND, her satır için OHIF adresi.
        grup.MapGet("/hasta/{hastaId:int}", async (int hastaId, DicomKaynagi dicom, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            if (!dicom.Ayar.Aktif) return Results.Ok(new { aktif = false, calismalar = Array.Empty<object>(), izlemeNo = baglam.IzlemeNo });
            var h = await veri.TekAsync(
                "select coalesce(ad,'') as ad, coalesce(soyad,'') as soyad, coalesce(unvan,'') as unvan, coalesce(kod,'') as kod, coalesce(vkno,'') as vkno from public.taraf where id = @p0 and hasta = 1",
                [hastaId], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");
            string S(string k) => (Convert.ToString(h[k]) ?? "").Trim();
            var ad = S("ad"); var soyad = S("soyad"); var unvan = S("unvan");
            var desenler = new List<string>();
            if (ad.Length > 0 && soyad.Length > 0) { desenler.Add($"{soyad}^{ad}*"); desenler.Add($"{ad}^{soyad}*"); }
            else if (unvan.Length > 0) desenler.Add(unvan.Replace(' ', '^') + "*");
            var liste = await dicom.HastaCalismalariAsync(desenler, [S("kod"), S("vkno")], iptal);
            var kok = $"{ctx.Request.Scheme}://{ctx.Request.Host}";
            var calismalar = liste.Select(c =>
            {
                var jeton = dicom.JetonUret(c.StudyUid);
                var manifest = $"{kok}/api/dicom/manifest/{Uri.EscapeDataString(c.StudyUid)}?t={jeton}";
                return new
                {
                    studyUid = c.StudyUid, tarih = c.Tarih, saat = c.Saat, modaliteler = c.Modaliteler, aciklama = c.Aciklama,
                    accession = c.Accession, adet = c.Adet, hastaAd = c.HastaAd, hastaNo = c.HastaNo,
                    url = $"{dicom.Ayar.GoruntuleyiciUrl.TrimEnd('/')}/viewer/dicomjson?url={Uri.EscapeDataString(manifest)}",
                };
            }).ToList();
            return Results.Ok(new { aktif = true, calismalar, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ OHIF dicomjson manifesti (jetonlu, anonim) --
        grup.MapGet("/manifest/{studyUid}", async (string studyUid, string? t, DicomKaynagi dicom, HttpContext ctx, CancellationToken iptal) =>
        {
            if (!dicom.Ayar.Aktif || !dicom.JetonGecerli(studyUid, t)) return Results.Unauthorized();
            var kok = $"{ctx.Request.Scheme}://{ctx.Request.Host}";
            var m = await dicom.ManifestAsync(studyUid, $"{kok}/api/dicom/wado", t!, iptal);
            // DICOM anahtar adları OLDUĞU GİBİ (StudyInstanceUID…): varsayılan camelCase OHIF'in beklediği adları bozar.
            return m is null ? Results.NotFound(new { hata = new { kod = "BULUNAMADI", mesaj = "Çalışma PACS'ta yok." } })
                 : Results.Json(m, new System.Text.Json.JsonSerializerOptions { PropertyNamingPolicy = null, DictionaryKeyPolicy = null });
        }).AllowAnonymous();

        // ------------------------------------------------ WADO vekili (jetonlu, anonim) --
        grup.MapGet("/wado", async (string studyUID, string seriesUID, string objectUID, string? t, DicomKaynagi dicom,
            HttpContext ctx, CancellationToken iptal) =>
        {
            if (!dicom.Ayar.Aktif || !dicom.JetonGecerli(studyUID, t)) { ctx.Response.StatusCode = 401; return; }
            using var yanit = await dicom.WadoAsync(studyUID, seriesUID, objectUID, iptal);
            if (!yanit.IsSuccessStatusCode) { ctx.Response.StatusCode = (int)yanit.StatusCode; return; }
            ctx.Response.ContentType = "application/dicom";
            if (yanit.Content.Headers.ContentLength is { } uzunluk) ctx.Response.ContentLength = uzunluk;
            await using var akis = await yanit.Content.ReadAsStreamAsync(iptal);
            await akis.CopyToAsync(ctx.Response.Body, iptal);
        }).AllowAnonymous();
    }
}
