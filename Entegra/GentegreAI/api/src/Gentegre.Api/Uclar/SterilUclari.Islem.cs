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
/// STERİLİZASYON — işlem uçları: döngü (başlat / bitir / indikatör / serbest bırak /
/// iptal / kart), birim olayları (kirli → yıkama → sayım → paketle → yağlama → arıza),
/// seansta paket okutma; izleme: paket zinciri, hasta bazlı, geri çağırma, kayıt defteri.
/// </summary>
public static partial class SterilUclari
{
    private static void IslemUclari(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------- döngü başlat ----
        // Yükleme + program → döngü. Bowie-Dick kuralı: bugün cihazda geçmiş BD yoksa
        //   uyari (serbest) · onay (onay notu zorunlu) · engel. Döner alet yağlanmadan
        //   yüklenemez (kural). Test programı (BD / vakum) paket almaz, durum "test".
        grup.MapPost("/dongu/baslat", async (DonguBaslatIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.dongu", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var k = await KurallarAsync(b, iptal);
            var cihaz = await b.TekAsync("select id, ad, tur, durum, sayac from public.steril_cihaz where id = @p0", null, [g.CihazId],
                o => new { id = o.GetInt32(0), ad = o.GetString(1), tur = o.GetInt16(2), durum = o.GetInt16(3), sayac = o.GetInt32(4) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı.");
            if (cihaz.tur != 1) throw GentegreHatasi.IsKurali("Döngü yalnız otoklavda açılır.");
            if (cihaz.durum != 1) throw GentegreHatasi.IsKurali($"{cihaz.ad} kullanım dışı (bakım gerekli / pasif).");
            if (await b.TekDegerAsync<int?>("select id from public.steril_dongu where cihaz_id = @p0 and durum in (2) limit 1", null, [cihaz.id], iptal) is { } acik)
                throw GentegreHatasi.IsKurali($"{cihaz.ad} üzerinde çalışan döngü var (#{acik}); önce onu bitirin.");
            var program = await b.TekAsync("select id, ad, test, sicaklik, plato_dk from public.steril_program where id = coalesce(@p0, (select id from public.steril_program where varsayilan = 1 and aktif = 1 limit 1)) and aktif = 1", null, [g.ProgramId],
                o => new { id = o.GetInt32(0), ad = o.GetString(1), test = o.GetInt16(2), sicaklik = o.GetDecimal(3), plato = o.GetDecimal(4) }, iptal) ?? throw GentegreHatasi.IsKurali("Program seçin.");
            var testProgrami = program.test == 1;
            var bdOnay = (g.BdOnayNotu ?? "").Trim();
            if (!testProgrami)
            {
                var bdVar = await b.TekDegerAsync<short>("select public.fn_steril_bd_bugun(@p0)", null, [cihaz.id], iptal) == 1;
                if (!bdVar && k.BdKurali == "engel") throw GentegreHatasi.IsKurali($"{cihaz.ad}: bugün Bowie-Dick testi kayıtlı değil; kurum kuralı döngüyü engelliyor.");
                if (!bdVar && k.BdKurali == "onay" && bdOnay == "") throw GentegreHatasi.IsKurali($"{cihaz.ad}: bugün Bowie-Dick testi kayıtlı değil. Devam için sorumlu onay notu zorunlu (bdOnayNotu).", new { kod = "BD_ONAY" });
                var sonBio = await b.TekDegerAsync<DateTime?>("select max(d.baslama) from public.steril_dongu d join public.steril_dongu_indikator i on i.dongu_id = d.id where d.cihaz_id = @p0 and i.tur = 6 and i.sonuc in (1, 2)", null, [cihaz.id], iptal);
                var bioGun = sonBio is null ? 999 : (DateTime.Now - sonBio.Value).Days;
                // Hiç biyolojik yapılmamış kurulumda engel değil uyarı (pano); yapılmış ve gecikmişse engel.
                if (sonBio is not null && bioGun >= k.BioGecikmeEngelGun && string.IsNullOrWhiteSpace(g.BioLot))
                    throw GentegreHatasi.IsKurali($"{cihaz.ad}: biyolojik test {(sonBio is null ? "hiç yapılmadı" : bioGun + " gündür yapılmadı")}; bu döngüye biyolojik indikatör ekleyin (bioLot).");
            }
            var yuk = new List<BirimSatiri>();
            foreach (var y in g.Birimler ?? [])
            {
                var br = await BirimBulAsync(b, y.BirimId, y.Barkod, iptal) ?? throw GentegreHatasi.IsKurali($"Birim bulunamadı: {y.Barkod ?? y.BirimId?.ToString()}");
                if (testProgrami) throw GentegreHatasi.IsKurali("Test programına yük konmaz (boş kazan).");
                if (br.Durum is BirimKirli or BirimYikamada) throw GentegreHatasi.IsKurali($"{br.Ad}: yıkanmadan / sayılmadan yüklenemez (durum: kirli / yıkamada).");
                if (br.Durum is BirimSterilde or BirimKullanimda or BirimArizali) throw GentegreHatasi.IsKurali($"{br.Ad}: şu an yüklenemez (sterilde / kullanımda / arızalı).");
                if (k.YaglamaZorunlu == 1 && br.YaglamaGerekli == 1 && (br.SonYaglama is null || (br.SonKullanim is not null && br.SonYaglama < br.SonKullanim)))
                    throw GentegreHatasi.IsKurali($"{br.Ad}: döner alet son kullanımdan sonra yağlanmadı; yüklemeden önce yağlama kaydı girin.");
                if (yuk.Any(x => x.Id == br.Id)) throw GentegreHatasi.IsKurali($"{br.Ad} yükte iki kez.");
                yuk.Add(br);
            }
            if (!testProgrami && yuk.Count == 0) throw GentegreHatasi.IsKurali("Yük boş: en az bir birim okutun.");
            var implantVar = yuk.Any(x => x.Implant == 1);
            if (implantVar && string.IsNullOrWhiteSpace(g.BioLot)) throw GentegreHatasi.IsKurali("İmplant kiti içeren yükte biyolojik indikatör zorunlu (bioLot).");

            var sayac = cihaz.sayac + 1;
            await b.CalistirAsync("update public.steril_cihaz set sayac = @p1 where id = @p0", null, [cihaz.id, sayac], iptal);
            var id = await b.TekDegerAsync<int>("""
                insert into public.steril_dongu (cihaz_id, sayac_no, program_id, baslama, operator_id, durum, bd_onay_notu, karar_notu, sube_id, ekleyen)
                values (@p0, @p1, @p2, now(), @p3, @p4, @p5, @p6, @p7, @p3) returning id
                """, null, [cihaz.id, sayac, program.id, baglam.KullaniciId, testProgrami ? DonguTest : DonguCalisiyor, Kirp(bdOnay, 300), Kirp(g.Notu, 400), baglam.SubeId ?? 0], iptal);
            await OlayYazAsync(b, null, null, id, OlayYukle, baglam.KullaniciId, $"Döngü #{sayac} başlatıldı · {program.ad}" + (bdOnay != "" ? " · BD onayı: " + bdOnay : ""), iptal);
            if (testProgrami)
            {
                var turler = program.ad.Contains("Vakum", StringComparison.OrdinalIgnoreCase) ? new[] { IndVakum } : new[] { IndBowieDick, IndHelix };
                foreach (var t in turler)
                    await b.CalistirAsync("insert into public.steril_dongu_indikator (dongu_id, tur, lot, konum, sonuc, ekleyen) values (@p0, @p1, @p2, 'boş kazan', 0, @p3)", null, [id, t, Kirp(g.KimyasalLot, 40), baglam.KullaniciId], iptal);
            }
            else
            {
                var n = 0; var tarihKodu = DateTime.Today.ToString("yyMMdd");
                foreach (var br in yuk)
                {
                    n++;
                    var istek = g.Birimler!.First(x => (x.BirimId is { } bi && bi == br.Id) || (x.Barkod is not null && string.Equals(x.Barkod.Trim(), br.Barkod, StringComparison.OrdinalIgnoreCase)));
                    var pid = await b.TekDegerAsync<int>("""
                        insert into public.steril_paket (barkod, birim_id, dongu_id, paket_tur, paketleyen_id, paketleme_zamani, raf, durum, sube_id, ekleyen)
                        values (@p0, @p1, @p2, @p3, @p4, now(), @p5, 1, @p6, @p4) returning id
                        """, null, [$"P-{tarihKodu}-{cihaz.id}-{sayac}-{n:00}", br.Id, id, istek.PaketTur ?? br.PaketTur, baglam.KullaniciId, Kirp(istek.Raf ?? br.Konum, 30), baglam.SubeId ?? 0], iptal);
                    await b.CalistirAsync("update public.steril_birim set durum = 5, durum_zaman = now(), son_dongu_id = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0", null, [br.Id, id, baglam.KullaniciId], iptal);
                    await OlayYazAsync(b, br.Id, pid, id, OlayYukle, baglam.KullaniciId, $"{cihaz.ad} #{sayac} döngüsüne yüklendi", iptal);
                }
                await b.CalistirAsync("insert into public.steril_dongu_indikator (dongu_id, tur, lot, konum, sonuc, ekleyen) values (@p0, 4, @p1, 'kazan ortası', 0, @p2)", null, [id, Kirp(g.KimyasalLot, 40), baglam.KullaniciId], iptal);
                if (!string.IsNullOrWhiteSpace(g.BioLot))
                    await b.CalistirAsync("insert into public.steril_dongu_indikator (dongu_id, tur, lot, konum, sonuc, inkubasyon_bitis, ekleyen) values (@p0, 6, @p1, 'kazan ortası', 3, now() + interval '24 hours', @p2)", null, [id, Kirp(g.BioLot, 40), baglam.KullaniciId], iptal);
            }
            await log.YazAsync(LogIslemi.Ekle, LogDongu, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { cihaz = cihaz.ad, sayac, program = program.ad, paket = yuk.Count, bdOnay }, iptal: iptal);
            return Results.Ok(new { id, sayacNo = sayac, paketSayisi = yuk.Count, test = testProgrami });
        });

        // ---------------------------------------------------- döngü bitir ----
        grup.MapPost("/dongu/{id:int}/bitir", async (int id, DonguBitirIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.dongu", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var d = await b.TekAsync("select durum, sayac_no from public.steril_dongu where id = @p0", null, [id], o => new { durum = o.GetInt16(0), no = o.GetInt32(1) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Döngü bulunamadı.");
            if (d.durum is not (DonguCalisiyor or DonguTest)) throw GentegreHatasi.IsKurali("Döngü çalışmıyor.");
            await b.CalistirAsync("""
                update public.steril_dongu set bitis = now(), tepe_sicaklik = @p1, plato_dk = @p2, tepe_basinc = @p3, kurutma_dk = @p4, hata_kodu = @p5,
                       durum = case when durum = 8 then 8 else 3 end, degistiren = @p6, degistirme_tarihi = now() where id = @p0
                """, null, [id, g.TepeSicaklik, g.PlatoDk, g.TepeBasinc, g.KurutmaDk, Kirp(g.HataKodu, 40), baglam.KullaniciId], iptal);
            await OlayYazAsync(b, null, null, id, OlayBitti, baglam.KullaniciId, $"Döngü #{d.no} bitti · tepe {g.TepeSicaklik}°C · plato {g.PlatoDk} dk · {g.TepeBasinc} bar" + (string.IsNullOrEmpty(g.HataKodu) ? "" : $" · HATA {g.HataKodu}"), iptal);
            return Results.Ok(new { id, durum = d.durum == DonguTest ? DonguTest : DonguIndikator });
        });

        // ------------------------------------------------------ indikatör ----
        // Aynı türden bekleyen satır varsa güncellenir, yoksa eklenir. Biyolojik negatif →
        //   karantinadaki döngü serbest; pozitif → geri çağırma otomatik açılır.
        grup.MapPost("/dongu/{id:int}/indikator", async (int id, IndikatorIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.dongu", Islem.Degistir);
            if (g.Tur is < 1 or > 7) throw GentegreHatasi.IsKurali("İndikatör türü geçersiz.");
            if (g.Sonuc is < 0 or > 3) throw GentegreHatasi.IsKurali("Sonuç 0 bekliyor · 1 geçti · 2 kaldı · 3 inkübasyonda.");
            await using var b = await veri.AcAsync(iptal);
            var d = await b.TekAsync("select durum, sayac_no, cihaz_id from public.steril_dongu where id = @p0", null, [id], o => new { durum = o.GetInt16(0), no = o.GetInt32(1), cihazId = o.GetInt32(2) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Döngü bulunamadı.");
            var mevcut = await b.TekDegerAsync<int?>("select id from public.steril_dongu_indikator where dongu_id = @p0 and tur = @p1 order by id desc limit 1", null, [id, g.Tur], iptal);
            DateTime? inkubasyon = g.Sonuc == SonucInkubasyon ? DateTime.Now.AddHours(g.InkubasyonSaat ?? 24) : null;
            int iid;
            if (mevcut is { } mid)
            {
                await b.CalistirAsync("""
                    update public.steril_dongu_indikator set lot = case when @p1 <> '' then @p1 else lot end, konum = case when @p2 <> '' then @p2 else konum end, sonuc = @p3,
                           okuyan_id = @p4, okuma_zamani = now(), inkubasyon_bitis = coalesce(@p5, inkubasyon_bitis), notu = @p6 where id = @p0
                    """, null, [mid, Kirp(g.Lot, 40), Kirp(g.Konum, 60), g.Sonuc, baglam.KullaniciId, inkubasyon, Kirp(g.Notu, 200)], iptal);
                iid = mid;
            }
            else
                iid = await b.TekDegerAsync<int>("""
                    insert into public.steril_dongu_indikator (dongu_id, tur, lot, konum, sonuc, okuyan_id, okuma_zamani, inkubasyon_bitis, notu, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, now(), @p6, @p7, @p5) returning id
                    """, null, [id, g.Tur, Kirp(g.Lot, 40), Kirp(g.Konum, 60), g.Sonuc, baglam.KullaniciId, inkubasyon, Kirp(g.Notu, 200)], iptal);
            var turAdi = g.Tur switch { 1 => "Bowie-Dick", 2 => "Helix", 3 => "Sınıf 4", 4 => "Sınıf 5", 5 => "Sınıf 6", 6 => "Biyolojik", _ => "Vakum testi" };
            var sonucAdi = g.Sonuc switch { 1 => "GEÇTİ", 2 => "KALDI", 3 => "inkübasyonda", _ => "bekliyor" };
            await OlayYazAsync(b, null, null, id, OlayIndikator, baglam.KullaniciId, $"{turAdi}: {sonucAdi}" + (string.IsNullOrEmpty(g.Lot) ? "" : $" · lot {g.Lot}"), iptal);
            int? geriCagirmaId = null; var mesaj = $"{turAdi}: {sonucAdi}";
            if (g.Tur == IndBiyolojik && g.Sonuc == SonucGecti && d.durum == DonguKarantina)
            {
                await b.CalistirAsync("update public.steril_paket set durum = 3, degistiren = @p1, degistirme_tarihi = now() where dongu_id = @p0 and durum = 2", null, [id, baglam.KullaniciId], iptal);
                await b.CalistirAsync("update public.steril_birim set durum = 7, durum_zaman = now() where id in (select birim_id from public.steril_paket where dongu_id = @p0 and durum = 3) and durum = 6", null, [id], iptal);
                await b.CalistirAsync("update public.steril_dongu set durum = 4, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId], iptal);
                await OlayYazAsync(b, null, null, id, OlaySerbest, baglam.KullaniciId, "Biyolojik negatif: karantina kalktı, paketler steril", iptal);
                mesaj += " · karantina kalktı, paketler steril depoda.";
            }
            if (g.Tur == IndBiyolojik && g.Sonuc == SonucKaldi)
            {
                geriCagirmaId = await GeriCagirmaAcAsync(b, id, "Biyolojik indikatör pozitif (otomatik)", baglam, iptal);
                mesaj += $" · GERİ ÇAĞIRMA #{geriCagirmaId} açıldı, cihaz kullanım dışı.";
            }
            await log.YazAsync(LogIslemi.Degistir, LogDongu, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { indikator = turAdi, sonuc = sonucAdi, g.Lot }, iptal: iptal);
            return Results.Ok(new { id = iid, donguId = id, mesaj, geriCagirmaId });
        });

        // -------------------------------------------------- serbest bırakma ----
        // Karar: serbest · karantina · basarisiz. Serbest için: parametreler program eşiğinde,
        //   sınıf 5/6 geçti, günün Bowie-Dick'i (ya da onay notu), biyolojik bekliyorsa → karantina.
        grup.MapPost("/dongu/{id:int}/serbest", async (int id, SerbestIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.dongu", Islem.Degistir);
            var karar = (g.Karar ?? "").Trim().ToLowerInvariant();
            if (karar is not ("serbest" or "karantina" or "basarisiz")) throw GentegreHatasi.IsKurali("Karar serbest / karantina / basarisiz olmalı.");
            await using var b = await veri.AcAsync(iptal);
            var k = await KurallarAsync(b, iptal);
            var d = await b.TekAsync("""
                select d.durum, d.sayac_no, d.cihaz_id, d.tepe_sicaklik, d.plato_dk, d.bd_onay_notu, d.bitis, pr.sicaklik, pr.plato_dk, c.ad,
                       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur in (4, 5) order by i.id desc limit 1),
                       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur = 6 order by i.id desc limit 1),
                       (select max(coalesce(s.implant, 0)) from public.steril_paket p join public.steril_birim b2 on b2.id = p.birim_id left join public.steril_set s on s.id = b2.set_id where p.dongu_id = d.id)
                  from public.steril_dongu d left join public.steril_program pr on pr.id = d.program_id join public.steril_cihaz c on c.id = d.cihaz_id where d.id = @p0
                """, null, [id], o => new
                {
                    durum = o.GetInt16(0), no = o.GetInt32(1), cihazId = o.GetInt32(2), tepe = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3), plato = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                    bdOnay = o.GetString(5), bitis = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6), hedefSicaklik = o.IsDBNull(7) ? (decimal?)null : o.GetDecimal(7), hedefPlato = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                    cihaz = o.GetString(9), kimyasal = o.IsDBNull(10) ? (short?)null : o.GetInt16(10), bio = o.IsDBNull(11) ? (short?)null : o.GetInt16(11), implant = o.IsDBNull(12) ? 0 : Convert.ToInt32(o.GetValue(12)),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Döngü bulunamadı.");
            if (d.durum is DonguCalisiyor) throw GentegreHatasi.IsKurali("Döngü henüz bitmedi; önce 'Döngü bitti' (parametre) girin.");
            if (d.durum is DonguSerbest or DonguBasarisiz or DonguIptal or DonguTest) throw GentegreHatasi.IsKurali("Döngü zaten sonuçlanmış.");
            var bdOnay = (g.BdOnayNotu ?? "").Trim();
            if (bdOnay != "") await b.CalistirAsync("update public.steril_dongu set bd_onay_notu = @p1 where id = @p0", null, [id, Kirp(bdOnay, 300)], iptal);
            var eksik = new List<string>();
            if (karar == "serbest")
            {
                if (d.tepe is null || d.plato is null) eksik.Add("parametre (tepe sıcaklık / plato süresi) girilmemiş");
                else
                {
                    if (d.hedefSicaklik is { } hs && d.tepe < hs) eksik.Add($"tepe sıcaklık {d.tepe}°C < hedef {hs}°C");
                    if (d.hedefPlato is { } hp && d.plato < hp) eksik.Add($"plato {d.plato} dk < hedef {hp} dk");
                }
                if (d.kimyasal != SonucGecti) eksik.Add(d.kimyasal == SonucKaldi ? "sınıf 5/6 entegratör KALDI" : "sınıf 5/6 entegratör sonucu girilmedi");
                var bdVar = await b.TekDegerAsync<short>("select public.fn_steril_bd_bugun(@p0)", null, [d.cihazId], iptal) == 1;
                if (!bdVar && k.BdKurali != "uyari" && d.bdOnay == "" && bdOnay == "") eksik.Add("günün Bowie-Dick sonucu yok (onay notu gerekir)");
                if (eksik.Count > 0) throw GentegreHatasi.IsKurali("Serbest bırakılamaz: " + string.Join("; ", eksik) + ".", new { kod = "SERBEST_EKSIK", eksik });
                if (d.bio == SonucInkubasyon) { karar = "karantina"; }
                if (d.bio == SonucKaldi) throw GentegreHatasi.IsKurali("Biyolojik indikatör pozitif; döngü serbest bırakılamaz (geri çağırma).");
            }
            var etiketler = new List<object>();
            var operatorAdi = await b.TekDegerAsync<string>("select ad from public.v_kullanici_lookup where id = @p0", null, [baglam.KullaniciId], iptal) ?? "";
            if (karar == "serbest")
            {
                var paketler = await b.ListeAsync("select p.id, p.barkod, p.paket_tur, b.id, b.ad, coalesce(s.raf_omru_ay, 0), coalesce(s.ad, b.ad), b.konum from public.steril_paket p join public.steril_birim b on b.id = p.birim_id left join public.steril_set s on s.id = b.set_id where p.dongu_id = @p0 and p.durum in (1, 2)", null, [id],
                    o => new { id = o.GetInt32(0), barkod = o.GetString(1), tur = o.GetInt16(2), birimId = o.GetInt32(3), birimAd = o.GetString(4), rafAy = o.GetInt16(5), icerik = o.GetString(6), konum = o.GetString(7) }, iptal);
                foreach (var p in paketler)
                {
                    var ay = p.rafAy > 0 ? p.rafAy : (k.RafOmru.TryGetValue(p.tur.ToString(), out var a) ? a : 6);
                    DateTime? skt = ay > 0 ? (d.bitis ?? DateTime.Now).Date.AddMonths(ay) : null;
                    await b.CalistirAsync("update public.steril_paket set durum = 3, skt = @p1, raf = case when raf = '' then @p3 else raf end, degistiren = @p2, degistirme_tarihi = now() where id = @p0", null, [p.id, skt, baglam.KullaniciId, Kirp(p.konum, 30)], iptal);
                    await b.CalistirAsync("update public.steril_birim set durum = 7, durum_zaman = now(), dongu_sayisi = dongu_sayisi + 1 where id = @p0", null, [p.birimId], iptal);
                    await OlayYazAsync(b, p.birimId, p.id, id, OlaySerbest, baglam.KullaniciId, $"Serbest bırakıldı · SKT {skt:dd.MM.yyyy}", iptal);
                    etiketler.Add(new { paketId = p.id, barkod = p.barkod, icerik = p.icerik, cihaz = d.cihaz, donguNo = d.no, tarih = d.bitis ?? DateTime.Now, skt, operatorAdi = operatorAdi, raf = p.konum });
                }
                await b.CalistirAsync("update public.steril_dongu set durum = 4, onaylayan_id = @p1, onay_zamani = now(), karar_notu = @p2, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId, Kirp(g.Notu, 400)], iptal);
                await OlayYazAsync(b, null, null, id, OlaySerbest, baglam.KullaniciId, $"Döngü #{d.no} serbest bırakıldı · {paketler.Count} paket", iptal);
            }
            else if (karar == "karantina")
            {
                await b.CalistirAsync("update public.steril_paket set durum = 2, degistiren = @p1, degistirme_tarihi = now() where dongu_id = @p0 and durum in (1, 2)", null, [id, baglam.KullaniciId], iptal);
                await b.CalistirAsync("update public.steril_birim set durum = 6, durum_zaman = now(), dongu_sayisi = dongu_sayisi + 1 where id in (select birim_id from public.steril_paket where dongu_id = @p0) and durum = 5", null, [id], iptal);
                await b.CalistirAsync("update public.steril_dongu set durum = 5, onaylayan_id = @p1, onay_zamani = now(), karar_notu = @p2, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId, Kirp(g.Notu, 400)], iptal);
                await OlayYazAsync(b, null, null, id, OlayKarantina, baglam.KullaniciId, $"Döngü #{d.no} karantinada" + (d.bio == SonucInkubasyon ? " (biyolojik inkübasyonda)" : ""), iptal);
            }
            else
            {
                await b.CalistirAsync("update public.steril_paket set durum = 5, degistiren = @p1, degistirme_tarihi = now() where dongu_id = @p0 and durum in (1, 2)", null, [id, baglam.KullaniciId], iptal);
                await b.CalistirAsync("update public.steril_birim set durum = 10, durum_zaman = now() where id in (select birim_id from public.steril_paket where dongu_id = @p0) and durum in (5, 6)", null, [id], iptal);
                await b.CalistirAsync("update public.steril_dongu set durum = 6, onaylayan_id = @p1, onay_zamani = now(), karar_notu = @p2, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [id, baglam.KullaniciId, Kirp(g.Notu, 400)], iptal);
                await OlayYazAsync(b, null, null, id, OlayBasarisiz, baglam.KullaniciId, $"Döngü #{d.no} BAŞARISIZ: paketler yeniden işlenecek · {g.Notu}", iptal);
            }
            await log.YazAsync(LogIslemi.Degistir, LogDongu, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { karar, g.Notu, etiket = etiketler.Count }, iptal: iptal);
            return Json(new { id, karar, etiketler, mesaj = karar switch { "serbest" => $"Döngü #{d.no} serbest bırakıldı; {etiketler.Count} etiket hazır.", "karantina" => $"Döngü #{d.no} karantinada; biyolojik sonuç gelince paketler steril olur.", _ => $"Döngü #{d.no} başarısız; paketler yeniden işleme listesinde." } });
        });

        grup.MapPost("/dongu/{id:int}/iptal", async (int id, AciklamaIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.dongu", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("update public.steril_dongu set durum = 7, bitis = coalesce(bitis, now()), karar_notu = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0 and durum in (2, 3, 8)", null, [id, Kirp(g.Aciklama, 400), baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Döngü iptal edilemez (sonuçlanmış).");
            await b.CalistirAsync("update public.steril_paket set durum = 5 where dongu_id = @p0 and durum = 1", null, [id], iptal);
            await b.CalistirAsync("update public.steril_birim set durum = 3, durum_zaman = now() where id in (select birim_id from public.steril_paket where dongu_id = @p0) and durum = 5", null, [id], iptal);
            await OlayYazAsync(b, null, null, id, OlayBasarisiz, baglam.KullaniciId, "Döngü iptal edildi · " + (g.Aciklama ?? ""), iptal);
            return Results.Ok(new { id });
        });

        // ------------------------------------------------------ döngü kartı ----
        grup.MapGet("/dongu/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.dongu", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var dongu = await JsonTekAsync(b, "select row_to_json(d)::text from public.v_steril_dongu d where d.id = @p0", [id], iptal) ?? throw GentegreHatasi.Bulunamadi("Döngü bulunamadı.");
            var paketler = await JsonListeAsync(b, "select row_to_json(p)::text from public.v_steril_paket p where p.dongu_id = @p0 order by p.id", [id], iptal);
            var indikatorler = await JsonListeAsync(b, """
                select json_build_object('id', i.id, 'tur', i.tur, 'turAdi', coalesce(k.ad, ''), 'lot', i.lot, 'konum', i.konum, 'sonuc', i.sonuc, 'okuyanAdi', coalesce(u.ad, ''), 'okumaZamani', i.okuma_zamani, 'inkubasyonBitis', i.inkubasyon_bitis, 'notu', i.notu)::text
                  from public.steril_dongu_indikator i
                  left join public.kod_liste l on l.kod = 'steril.indikator_tur' left join public.kod_deger k on k.liste_id = l.id and k.deger = i.tur
                  left join public.v_kullanici_lookup u on u.id = i.okuyan_id
                 where i.dongu_id = @p0 order by i.tur, i.id
                """, [id], iptal);
            var olaylar = await JsonListeAsync(b, """
                select json_build_object('id', o.id, 'zaman', o.zaman, 'tur', o.tur, 'turAdi', coalesce(k.ad, ''), 'kullaniciAdi', coalesce(u.ad, ''), 'aciklama', o.aciklama, 'birimId', o.birim_id, 'paketId', o.paket_id)::text
                  from public.steril_olay o
                  left join public.kod_liste l on l.kod = 'steril.olay_tur' left join public.kod_deger k on k.liste_id = l.id and k.deger = o.tur
                  left join public.v_kullanici_lookup u on u.id = o.kullanici_id
                 where o.dongu_id = @p0 order by o.zaman, o.id
                """, [id], iptal);
            var k = await KurallarAsync(b, iptal);
            return Json(new { dongu, paketler, indikatorler, olaylar, kurallar = k });
        });

        // ------------------------------------------------------- birim olayı ----
        // kirli · yikama · sayim (sayilan/toplam/eksik) · paketle · yaglama · ariza · depo · not
        grup.MapPost("/birim/olay", async (BirimOlayIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.birim", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var br = await BirimBulAsync(b, g.BirimId, g.Barkod, iptal) ?? throw GentegreHatasi.Bulunamadi("Birim bulunamadı.");
            var islem = (g.Islem ?? "").Trim().ToLowerInvariant();
            string mesaj;
            switch (islem)
            {
                case "kirli":
                    await b.CalistirAsync("update public.steril_birim set durum = 1, durum_zaman = now(), son_kullanim = now(), son_taraf_id = coalesce(@p1, son_taraf_id), son_belge_id = coalesce(@p2, son_belge_id) where id = @p0", null, [br.Id, g.TarafId, g.BelgeId], iptal);
                    await b.CalistirAsync("update public.steril_paket set durum = 4 where birim_id = @p0 and durum in (2, 3, 8)", null, [br.Id], iptal);
                    await OlayYazAsync(b, br.Id, null, null, OlayKirli, baglam.KullaniciId, "Kirli toplandı · " + (g.Notu ?? ""), iptal);
                    mesaj = $"{br.Ad} kirli havuzunda."; break;
                case "yikama":
                    if (br.Durum is not (BirimKirli or BirimYenidenIsle or BirimSayim)) throw GentegreHatasi.IsKurali($"{br.Ad}: yıkamaya yalnız kirli / yeniden işlenecek birim alınır.");
                    await BirimDurumAsync(b, br.Id, BirimYikamada, baglam.KullaniciId, iptal);
                    await OlayYazAsync(b, br.Id, null, null, OlayYikama, baglam.KullaniciId, "Yıkama / dezenfeksiyona alındı · " + (g.Notu ?? ""), iptal);
                    mesaj = $"{br.Ad} yıkamada."; break;
                case "sayim":
                    {
                        var toplam = g.Toplam ?? (short)await b.TekDegerAsync<long>("select coalesce(sum(adet), 0) from public.steril_set_alet where set_id = @p0 and tek_kullanimlik = 0", null, [br.SetId ?? 0], iptal);
                        var sayilan = g.Sayilan ?? toplam;
                        var eksikVar = sayilan < toplam;
                        await BirimDurumAsync(b, br.Id, BirimSayim, baglam.KullaniciId, iptal);
                        if (eksikVar)
                        {
                            await OlayYazAsync(b, br.Id, null, null, OlayAriza, baglam.KullaniciId, $"Sayım EKSİK {sayilan}/{toplam}: {g.Eksik ?? "?"}", iptal);
                            var gid = await b.TekDegerAsync<long>("""
                                insert into public.gorev (konu, aciklama, tur, oncelik, durum, sorumlu_id, acan_id, termin, sube_id, ekleyen)
                                values (@p0, @p1, 1, 2, 0, @p2, @p2, now() + interval '1 day', @p3, @p2) returning id
                                """, null, [$"Sterilizasyon: eksik alet · {br.Ad}", $"Sayım {sayilan}/{toplam}. Eksik: {g.Eksik ?? "?"}. Son kullanım: {br.SonKullanim:dd.MM HH:mm}", baglam.KullaniciId, baglam.SubeId ?? 0], iptal);
                            mesaj = $"{br.Ad}: sayım eksik ({sayilan}/{toplam}); görev #{gid} açıldı. Tamamlanınca yeniden sayın.";
                        }
                        else
                        {
                            await OlayYazAsync(b, br.Id, null, null, OlaySayim, baglam.KullaniciId, $"Sayıldı {sayilan}/{toplam} ✓", iptal);
                            mesaj = $"{br.Ad}: sayım tamam ({sayilan}/{toplam}); paketlemeye hazır.";
                        }
                        break;
                    }
                case "paketle":
                    if (br.Durum is not (BirimSayim or BirimYenidenIsle or BirimDepoda or BirimYikamada)) throw GentegreHatasi.IsKurali($"{br.Ad}: paketleme için sayım / yıkama tamamlanmalı.");
                    if (br.YaglamaGerekli == 1 && (br.SonYaglama is null || (br.SonKullanim is not null && br.SonYaglama < br.SonKullanim)))
                        throw GentegreHatasi.IsKurali($"{br.Ad}: döner alet yağlanmadan paketlenemez.");
                    await BirimDurumAsync(b, br.Id, BirimPaketlendi, baglam.KullaniciId, iptal);
                    await OlayYazAsync(b, br.Id, null, null, OlayPaketle, baglam.KullaniciId, "Paketlendi (sınıf 4 şerit) · " + (g.Notu ?? ""), iptal);
                    mesaj = $"{br.Ad} paketlendi; döngüye yüklenebilir."; break;
                case "yaglama":
                    await b.CalistirAsync("update public.steril_birim set yaglama_sayisi = yaglama_sayisi + 1, son_yaglama = now(), durum = case when durum in (1, 2) then 3 else durum end, durum_zaman = now() where id = @p0", null, [br.Id], iptal);
                    await OlayYazAsync(b, br.Id, null, null, OlayYaglama, baglam.KullaniciId, "Yağlandı · " + (g.Notu ?? ""), iptal);
                    mesaj = $"{br.Ad} yağlandı."; break;
                case "ariza":
                    await BirimDurumAsync(b, br.Id, BirimArizali, baglam.KullaniciId, iptal);
                    await OlayYazAsync(b, br.Id, null, null, OlayAriza, baglam.KullaniciId, "Arızalı / bakıma: " + (g.Notu ?? ""), iptal);
                    mesaj = $"{br.Ad} bakımda."; break;
                case "depo":
                    await BirimDurumAsync(b, br.Id, BirimDepoda, baglam.KullaniciId, iptal);
                    await OlayYazAsync(b, br.Id, null, null, OlayNot, baglam.KullaniciId, "Steril depoya alındı (elle) · " + (g.Notu ?? ""), iptal);
                    mesaj = $"{br.Ad} steril depoda."; break;
                case "not":
                    await OlayYazAsync(b, br.Id, null, null, OlayNot, baglam.KullaniciId, g.Notu ?? "", iptal);
                    mesaj = "Not eklendi."; break;
                default: throw GentegreHatasi.IsKurali("İşlem: kirli · yikama · sayim · paketle · yaglama · ariza · depo · not");
            }
            await log.YazAsync(LogIslemi.Degistir, LogPaket, br.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { birim = br.Barkod, islem, g.Notu }, iptal: iptal);
            return Results.Ok(new { birimId = br.Id, islem, mesaj });
        });

        // ---------------------------------------------------- paket okut ----
        // Seansta kullanım: paket (ya da birim) barkodu → hasta / seans / hekim bağlanır, paket
        //   kapanır, birim kirliye düşer. Karantina paketi kural "uyari" ise zorla ile geçer.
        grup.MapPost("/paket/okut", async (OkutIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.kullanim", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var k = await KurallarAsync(b, iptal);
            var barkod = (g.Barkod ?? "").Trim();
            if (barkod == "") throw GentegreHatasi.IsKurali("Barkod okutun.");
            var p = await b.TekAsync("""
                select p.id, p.barkod, p.durum, p.skt, b.id, b.ad, coalesce(s.ad, b.ad), coalesce(s.implant, 0), public.fn_steril_paket_kullanilabilir(p.id), p.dongu_id
                  from public.steril_paket p join public.steril_birim b on b.id = p.birim_id left join public.steril_set s on s.id = b.set_id
                 where upper(p.barkod) = upper(@p0) or (upper(b.barkod) = upper(@p0) and p.durum in (2, 3, 7, 8))
                 order by case when upper(p.barkod) = upper(@p0) then 0 else 1 end, p.id desc limit 1
                """, null, [barkod], o => new { id = o.GetInt32(0), barkod = o.GetString(1), durum = o.GetInt16(2), skt = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3), birimId = o.GetInt32(4), birimAd = o.GetString(5), icerik = o.GetString(6), implant = o.GetInt16(7), kullanilabilir = o.GetInt16(8), donguId = o.GetInt32(9) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Bu barkodla steril paket bulunamadı.");
            if (p.kullanilabilir == 0)
            {
                var neden = p.durum switch { 1 => "döngü henüz serbest bırakılmadı", 4 => "paket daha önce kullanıldı", 5 => "başarısız döngü / iptal", 6 => "raf ömrü doldu", 7 => "geri çağırma ile BLOKE", 8 => "etiket bekliyor", 2 => "karantina (implant kiti kullanılamaz)", _ => $"durum {p.durum}" };
                if (p.durum == 3 && p.skt is { } s && s < DateTime.Today) neden = $"raf ömrü doldu ({s:dd.MM.yyyy})";
                throw GentegreHatasi.IsKurali($"{p.barkod} ({p.icerik}) KULLANILAMAZ: {neden}.");
            }
            if (p.kullanilabilir == 2)
            {
                if (k.KarantinaKullanim == "engel") throw GentegreHatasi.IsKurali($"{p.barkod} karantinada (biyolojik sonuç bekleniyor); kurum kuralı kullanımı engelliyor.");
                if (g.Zorla != true) throw GentegreHatasi.IsKurali($"{p.barkod} karantinada (biyolojik sonuç bekleniyor). Kullanmak için onaylayın.", new { kod = "KARANTINA" });
            }
            var kid = await b.TekDegerAsync<int>("""
                insert into public.steril_paket_kullanim (paket_id, taraf_id, belge_id, hekim_id, unite, okutan_id, notu, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p5) returning id
                """, null, [p.id, g.TarafId, g.BelgeId, g.HekimId, Kirp(g.Unite, 40), baglam.KullaniciId, Kirp(g.Notu, 200) + (p.kullanilabilir == 2 ? " [karantina onayı]" : ""), baglam.SubeId ?? 0], iptal);
            await b.CalistirAsync("update public.steril_paket set durum = 4, degistiren = @p1, degistirme_tarihi = now() where id = @p0", null, [p.id, baglam.KullaniciId], iptal);
            await b.CalistirAsync("update public.steril_birim set durum = 1, durum_zaman = now(), son_kullanim = now(), son_taraf_id = @p1, son_belge_id = @p2, degistiren = @p3, degistirme_tarihi = now() where id = @p0", null, [p.birimId, g.TarafId, g.BelgeId, baglam.KullaniciId], iptal);
            var hasta = g.TarafId is null ? "" : await b.TekDegerAsync<string>("select unvan from public.taraf where id = @p0", null, [g.TarafId], iptal) ?? "";
            await OlayYazAsync(b, p.birimId, p.id, p.donguId, OlayKullanim, baglam.KullaniciId, $"Kullanıldı · {hasta}{(string.IsNullOrEmpty(g.Unite) ? "" : " · " + g.Unite)}", iptal);
            await log.YazAsync(LogIslemi.Ekle, LogKullanim, kid, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { paket = p.barkod, g.BelgeId, g.Unite }, tarafId: g.TarafId, iptal: iptal);
            return Results.Ok(new { id = kid, paketId = p.id, barkod = p.barkod, icerik = p.icerik, karantina = p.kullanilabilir == 2, mesaj = $"{p.icerik} kullanıldı olarak kaydedildi{(hasta == "" ? "" : " · " + hasta)}." });
        });
    }

    // ================================================================ izleme ====
    private static void IzlemeUclari(RouteGroupBuilder grup)
    {
        // Paket / birim barkodu → zincir (kirli → yıkama → paket → döngü → kullanım).
        grup.MapGet("/paket/{barkod}", async (string barkod, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.izleme", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var paket = await JsonTekAsync(b, "select row_to_json(p)::text from public.v_steril_paket p where upper(p.barkod) = upper(@p0) or (upper(p.birim_barkod) = upper(@p0)) order by case when upper(p.barkod) = upper(@p0) then 0 else 1 end, p.id desc limit 1", [barkod.Trim()], iptal);
            if (paket is null)
            {
                var birim = await JsonTekAsync(b, "select row_to_json(x)::text from public.v_steril_birim x where upper(x.barkod) = upper(@p0)", [barkod.Trim()], iptal) ?? throw GentegreHatasi.Bulunamadi("Barkod bulunamadı.");
                var bolaylar = await JsonListeAsync(b, OlaySql + " where o.birim_id = @p0 order by o.zaman desc, o.id desc limit 60", [birim["id"]!.GetValue<int>()], iptal);
                return Json(new { paket = (object?)null, birim, olaylar = bolaylar, kullanimlar = Array.Empty<object>() });
            }
            var pid = paket["id"]!.GetValue<int>(); var bid = paket["birim_id"]!.GetValue<int>(); var did = paket["dongu_id"]!.GetValue<int>();
            var olaylar = await JsonListeAsync(b, OlaySql + """
                 where o.paket_id = @p0 or (o.dongu_id = @p2 and o.birim_id is null and o.paket_id is null)
                    or (o.birim_id = @p1 and o.paket_id is null and o.zaman >= coalesce((select p.paketleme_zamani - interval '3 days' from public.steril_paket p where p.id = @p0), now() - interval '3 days')
                        and o.zaman <= coalesce((select min(k.zaman) from public.steril_paket_kullanim k where k.paket_id = @p0), now()))
                 order by o.zaman, o.id
                """, [pid, bid, did], iptal);
            var kullanimlar = await JsonListeAsync(b, "select row_to_json(k)::text from public.v_steril_paket_kullanim k where k.paket_id = @p0 order by k.id", [pid], iptal);
            var dongu = await JsonTekAsync(b, "select row_to_json(d)::text from public.v_steril_dongu d where d.id = @p0", [did], iptal);
            var birimJ = await JsonTekAsync(b, "select row_to_json(x)::text from public.v_steril_birim x where x.id = @p0", [bid], iptal);
            return Json(new { paket, birim = birimJ, dongu, olaylar, kullanimlar });
        });

        grup.MapGet("/izleme", async (int? tarafId, int? belgeId, string? bas, string? bit, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.izleme", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            DateTime? t1 = DateTime.TryParse(bas, out var a) ? a : null, t2 = DateTime.TryParse(bit, out var c) ? c.AddDays(1) : null;
            var satirlar = await JsonListeAsync(b, """
                select row_to_json(k)::text from public.v_steril_paket_kullanim k
                 where (@p0::int is null or k.taraf_id = @p0) and (@p1::int is null or k.belge_id = @p1)
                   and (@p2::timestamp is null or k.zaman >= @p2) and (@p3::timestamp is null or k.zaman < @p3)
                 order by k.zaman desc limit 500
                """, [tarafId, belgeId, t1, t2], iptal);
            return Json(new { satirlar });
        });

        // ------------------------------------------------------ geri çağırma ----
        grup.MapPost("/geri-cagirma", async (GeriCagirmaIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.izleme", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var id = await GeriCagirmaAcAsync(b, g.DonguId, g.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { id });
        });

        grup.MapGet("/geri-cagirma/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.izleme", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kayit = await JsonTekAsync(b, "select row_to_json(g)::text from public.v_steril_geri_cagirma g where g.id = @p0", [id], iptal) ?? throw GentegreHatasi.Bulunamadi("Geri çağırma bulunamadı.");
            var cihazId = kayit["cihaz_id"]!.GetValue<int>(); var tetik = kayit["tetik_dongu_id"]!.GetValue<int>();
            var dongular = await JsonListeAsync(b, "select row_to_json(d)::text from public.v_steril_dongu d where d.id in (select dongu_id from public.fn_steril_geri_cagirma_dongular(@p0, @p1)) order by d.baslama", [cihazId, tetik], iptal);
            var paketler = await JsonListeAsync(b, "select row_to_json(p)::text from public.v_steril_paket p where p.dongu_id in (select dongu_id from public.fn_steril_geri_cagirma_dongular(@p0, @p1)) order by p.durum, p.id", [cihazId, tetik], iptal);
            var hastalar = await JsonListeAsync(b, """
                select (row_to_json(k)::jsonb || jsonb_build_object('riskSinifi', case when k.set_adi ilike '%cerrahi%' or k.set_adi ilike '%implant%' then 'kritik' else 'yarı kritik' end,
                        'cepTel', coalesce((select coalesce(nullif(t.cep_tel, ''), t.telefon, '') from public.taraf t where t.id = k.taraf_id), '')))::text
                  from public.v_steril_paket_kullanim k
                 where k.dongu_id in (select dongu_id from public.fn_steril_geri_cagirma_dongular(@p0, @p1)) order by k.zaman
                """, [cihazId, tetik], iptal);
            return Json(new { kayit, dongular, paketler, hastalar });
        });

        grup.MapPost("/geri-cagirma/{id:int}/kapat", async (int id, AciklamaIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.izleme", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("update public.steril_geri_cagirma set durum = 2, kapatan_id = @p1, kapanis = now(), aciklama = aciklama || case when @p2 <> '' then E'\n' || @p2 else '' end, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 1", null, [id, baglam.KullaniciId, Kirp(g.Aciklama, 300)], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Geri çağırma açık değil.");
            await b.CalistirAsync("update public.steril_cihaz set durum = 1 where id = (select cihaz_id from public.steril_geri_cagirma where id = @p0) and durum = 2", null, [id], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogGeriCagirma, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { kapat = true, g.Aciklama }, iptal: iptal);
            return Results.Ok(new { id, durum = 2 });
        });

        // Hasta bilgilendirmesi (hekim onayı sonrası): bildirim kuyruğuna SMS. Kendi seçtiği hastalara.
        grup.MapPost("/geri-cagirma/{id:int}/bildir", async (int id, JsonNode g, VeriKaynagi veri, BildirimDeposu bildirim, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.izleme", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var tarafIdleri = (g["tarafIdleri"] as JsonArray)?.Select(x => x!.GetValue<int>()).Distinct().ToArray() ?? [];
            if (tarafIdleri.Length == 0) throw GentegreHatasi.IsKurali("Bilgilendirilecek hasta seçin.");
            var kurum = baglam.AktifSube?.Ad ?? "GenoTIP";
            var telefon = await b.TekDegerAsync<string>("select coalesce(telefon, '') from public.sube where id = @p0", null, [baglam.SubeId ?? 0], iptal) ?? "";
            int gonderilen = 0, hata = 0;
            foreach (var t in tarafIdleri)
            {
                var kisi = await b.TekAsync("select coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), coalesce(nullif(t.cep_tel, ''), t.telefon, ''), (select to_char(max(k.zaman), 'DD.MM.YYYY') from public.steril_paket_kullanim k where k.taraf_id = t.id) from public.taraf t where t.id = @p0", null, [t],
                    o => new { ad = o.GetString(0), tel = o.GetString(1), tarih = o.IsDBNull(2) ? "" : o.GetString(2) }, iptal);
                if (kisi is null || kisi.tel == "") { hata++; continue; }
                try
                {
                    await bildirim.KuyrugaEkleAsync(new BildirimIstegi("steril.geri_cagirma", BildirimKanali.Sms, kisi.tel, new Dictionary<string, string> { ["ad"] = kisi.ad, ["tarih"] = kisi.tarih, ["kurum"] = kurum, ["telefon"] = telefon },
                        TarafId: t, KaynakTur: 44, KaynakId: id), baglam.KullaniciId, baglam.SubeId, iptal);
                    gonderilen++;
                }
                catch (InvalidOperationException) { hata++; }
            }
            await log.YazAsync(LogIslemi.Degistir, LogGeriCagirma, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { bildir = true, gonderilen, hata }, iptal: iptal);
            return Results.Ok(new { gonderilen, hata });
        });

        // ------------------------------------------------------ kayıt defteri ----
        grup.MapGet("/kayit-defteri", async (string? ay, int? cihazId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.izleme", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var bas = DateTime.TryParse((ay ?? "") + "-01", out var t) ? new DateTime(t.Year, t.Month, 1) : new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var satirlar = await JsonListeAsync(b, """
                select row_to_json(d)::text from public.v_steril_dongu d
                 where d.baslama >= @p0 and d.baslama < @p1 and d.durum in (4, 5, 6, 8) and (@p2::int is null or d.cihaz_id = @p2)
                 order by d.baslama, d.id
                """, [bas, bas.AddMonths(1), cihazId], iptal);
            var ozet = await b.TekAsync("""
                select count(*) filter (where durum <> 8), count(*) filter (where durum = 6), count(*) filter (where durum = 8),
                       (select count(*) from public.steril_paket p join public.steril_dongu d2 on d2.id = p.dongu_id where d2.baslama >= @p0 and d2.baslama < @p1),
                       (select count(*) from public.steril_paket_kullanim k where k.zaman >= @p0 and k.zaman < @p1),
                       (select count(*) from public.steril_geri_cagirma g where g.ekleme_tarihi >= @p0 and g.ekleme_tarihi < @p1)
                  from public.steril_dongu d where d.baslama >= @p0 and d.baslama < @p1 and (@p2::int is null or d.cihaz_id = @p2)
                """, null, [bas, bas.AddMonths(1), cihazId], o => new { dongu = o.GetInt64(0), basarisiz = o.GetInt64(1), test = o.GetInt64(2), paket = o.GetInt64(3), kullanilan = o.GetInt64(4), geriCagirma = o.GetInt64(5) }, iptal);
            return Json(new { ay = bas.ToString("yyyy-MM"), satirlar, ozet });
        });
    }

    private const string OlaySql = """
        select json_build_object('id', o.id, 'zaman', o.zaman, 'tur', o.tur, 'turAdi', coalesce(k.ad, ''), 'kullaniciAdi', coalesce(u.ad, ''), 'aciklama', o.aciklama, 'birimId', o.birim_id, 'paketId', o.paket_id, 'donguId', o.dongu_id)::text
          from public.steril_olay o
          left join public.kod_liste l on l.kod = 'steril.olay_tur' left join public.kod_deger k on k.liste_id = l.id and k.deger = o.tur
          left join public.v_kullanici_lookup u on u.id = o.kullanici_id
        """;

    /// <summary>Geri çağırma: son negatif biyolojikten bu yana aynı cihazın döngüleri; depodakiler bloke, cihaz bakım gerekli, tetik döngü başarısız.</summary>
    private static async Task<int> GeriCagirmaAcAsync(NpgsqlConnection b, int donguId, string aciklama, IstekBaglami baglam, CancellationToken iptal)
    {
        var d = await b.TekAsync("select cihaz_id, sayac_no from public.steril_dongu where id = @p0", null, [donguId], o => new { cihazId = o.GetInt32(0), no = o.GetInt32(1) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Döngü bulunamadı.");
        if (await b.TekDegerAsync<int?>("select id from public.steril_geri_cagirma where tetik_dongu_id = @p0 and durum = 1", null, [donguId], iptal) is { } var_) return var_;
        var dongular = await b.ListeAsync("select dongu_id from public.fn_steril_geri_cagirma_dongular(@p0, @p1)", null, [d.cihazId, donguId], o => o.GetInt32(0), iptal);
        if (!dongular.Contains(donguId)) dongular.Add(donguId);
        var idler = dongular.ToArray();
        var bloke = await b.CalistirAsync("update public.steril_paket set durum = 7, degistiren = @p1, degistirme_tarihi = now() where dongu_id = any(@p0) and durum in (2, 3, 8)", null, [idler, baglam.KullaniciId], iptal);
        await b.CalistirAsync("update public.steril_birim set durum = 10, durum_zaman = now() where id in (select birim_id from public.steril_paket where dongu_id = any(@p0) and durum = 7) and durum in (6, 7)", null, [idler], iptal);
        var sayim = await b.TekAsync("""
            select (select count(*) from public.steril_paket p where p.dongu_id = any(@p0)),
                   (select count(*) from public.steril_paket p where p.dongu_id = any(@p0) and p.durum = 4),
                   (select count(distinct k.taraf_id) from public.steril_paket_kullanim k join public.steril_paket p on p.id = k.paket_id where p.dongu_id = any(@p0) and k.taraf_id is not null)
            """, null, [idler], o => new { paket = o.GetInt64(0), kullanilan = o.GetInt64(1), hasta = o.GetInt64(2) }, iptal);
        var id = await b.TekDegerAsync<int>("""
            insert into public.steril_geri_cagirma (cihaz_id, tetik_dongu_id, bas_dongu_id, etkilenen_dongu, etkilenen_paket, kullanilan_paket, hasta_sayisi, durum, aciklama, acan_id, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, 1, @p7, @p8, @p9, @p8) returning id
            """, null, [d.cihazId, donguId, idler.Min(), idler.Length, sayim!.paket, sayim.kullanilan, sayim.hasta, Kirp(aciklama, 600), baglam.KullaniciId, baglam.SubeId ?? 0], iptal);
        await b.CalistirAsync("update public.steril_cihaz set durum = 2 where id = @p0", null, [d.cihazId], iptal);
        await b.CalistirAsync("update public.steril_dongu set durum = 6, karar_notu = 'Biyolojik pozitif · geri çağırma #' || @p1 where id = @p0 and durum <> 6", null, [donguId, id], iptal);
        foreach (var x in idler)
            await OlayYazAsync(b, null, null, x, OlayBloke, baglam.KullaniciId, $"Geri çağırma #{id}: depodaki paketler bloke ({bloke})", iptal);
        return id;
    }
}
