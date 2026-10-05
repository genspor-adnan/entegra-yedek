using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE TAMAMLAMA — bkz. <c>MuayeneUclari</c>.
///
/// <para>Tamamla kaydı kilitler, başvuruyu tahakkuka döndürür ve e-Nabız
/// kuyruğuna atar; bu yüzden eksik kayıtta reddedilir (ana tanı, şikâyet,
/// karar). Kontrolü gönderim anına bırakmak, hatayı hekim ekrandan
/// ayrıldıktan çok sonra geri getirirdi. Kontrol listesi AYNI uçtan da
/// okunabiliyor - ekran "neden tamamlanmıyor" sorusunu kendi cevaplıyor.</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void TamamlaUclariniEkle(RouteGroupBuilder grup)
    {
        // GET /api/muayene/{id}/tamamlama-kontrol - ozet sekmesinin kontrol
        //   listesi (kullanici, mockup muayene_karti_v2). "Tamamla"nin
        //   reddedecegi maddeler ONCEDEN, tamam olanlarla birlikte: hekim
        //   neyin eksik oldugunu Tamamla'ya basmadan gorur. Kural istemcide
        //   tekrar yazilmaz - ayni yardimci.
        grup.MapGet("/{id:int}/tamamlama-kontrol", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            var m = await TamamlamaVerisiAsync(baglanti, null, id, kilitle: false, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadi.");
            var kontroller = await TamamlamaKontrolleriAsync(baglanti, null, id, m, iptal);
            return Results.Ok(new
            {
                muayeneId = id, tamamlandi = m.Durum == 3,
                kontroller = kontroller.Select(k => new { alan = k.Alan, ad = k.Ad, tamam = k.Tamam, mesaj = k.Mesaj, zorunlu = k.Zorunlu }),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/muayene/{id}/tamamla
        grup.MapPost("/{id:int}/tamamla", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.EnabizPaketUretici enabiz,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await TamamlamaVerisiAsync(baglanti, islem, id, kilitle: true, iptal);

            if (m is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });
            if (m.Durum == 3)
                throw GentegreHatasi.IsKurali("Muayene zaten tamamlanmis.");

            // TAMAMLAMA KURALI (muayene sureci, adim 10). Eksikler TEK SEFERDE
            //   sayilir: hekime "once tani gir", sonra "sikayet de lazim"
            //   demek ekrani iki kez kapattirirdi.
            //   Kural TEK YERDE (TamamlamaKontrolleriAsync): ozet sekmesinin
            //   kontrol listesi de ayni listeyi gosterir.
            var eksikler = (await TamamlamaKontrolleriAsync(baglanti, islem, id, m, iptal))
                .Where(k => k.Zorunlu && !k.Tamam).Select(k => new AlanHatasi(k.Alan, k.Mesaj)).ToList();
            if (eksikler.Count > 0)
                throw GentegreHatasi.Dogrulama(
                    "Muayene tamamlanamaz: " + string.Join(" ", eksikler.Select(x => x.Mesaj)),
                    [.. eksikler]);

            await baglanti.CalistirAsync("""
                update public.muayene
                   set durum = 3, bitis = coalesce(bitis, now()), tamamlanma = now(),
                       tamamlayan_id = @p1, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            // e-NABIZ 103 + 106 KUYRUGA (415). Gonderim USS kapisi acilinca;
            //   uretim simdi yapilir, yoksa kapi acildiginda gecmis veri
            //   kaybolurdu. Paket uretimi muayeneyi TAMAMLAMAYI DUSURMEZ:
            //   e-Nabiz bir bildirim yoludur, klinik kaydin sarti degil.
            // BZBH TASLAGI (882, KTS H5): tanilar bildirimi zorunlu bulasici
            //   hastalik listesiyle eslesiyorsa BEKLEYEN bildirim satiri acilir.
            //   Paket burada URETILMEZ - 214'un iki zorunlu alani (vaka tipi,
            //   belirti baslangici) tanidan cikarilamaz, hekim bildirim
            //   kartinda girer. Sessizdir: taslak acilamazsa muayene
            //   tamamlanmasi dusmez.
            int bzbhTaslak = 0;
            try
            {
                bzbhTaslak = await BzbhUclari.TaslakAcAsync(baglanti, id, baglam.KullaniciId, iptal);
            }
            catch (Exception h)
            {
                ctx.RequestServices.GetRequiredService<ILoggerFactory>()
                   .CreateLogger("bzbh").LogError(h, "BZBH taslagi acilamadi (muayene {Id})", id);
            }

            var paketler = new List<object>();
            try
            {
                // KONSULTASYON MUAYENESI ISE 252 DE URETILIR (880, KTS H2).
                //   Konsultasyon bizde ust muayeneye bagli bir MUAYENE
                //   satiridir; tamamlandiginda soru + yanit + tani dolmus
                //   olur - paketin gonderilebilir hali tam o andir.
                //   Konsultasyon muayenesi HASTA_CIKIS uretmez: hasta cikisi
                //   ASIL muayenenin isidir, konsultasyon ayri bir basvuru
                //   degildir; iki cikis bildirimi gondermek hastanin ayni
                //   basvurusunu iki kez kapatmak olurdu.
                var konsMu = await baglanti.TekDegerAsync<int>(
                    "select count(*)::int from public.muayene "
                    + " where id = @p0 and ust_muayene_id is not null",
                    null, [id], iptal) > 0;
                var kodlar = konsMu
                    ? new[] { "MUAYENE", "KONSULTASYON" }
                    : new[] { "MUAYENE", "HASTA_CIKIS" };
                foreach (var kod in kodlar)
                {
                    var s = await enabiz.UretAsync(kod, id, baglam.KullaniciId, iptal);
                    if (s is not null)
                        paketler.Add(new { kod, s.PaketNo, s.Durum, s.Eksikler });
                }
            }
            catch (Exception h)
            {
                ctx.RequestServices.GetRequiredService<ILoggerFactory>()
                   .CreateLogger("enabiz").LogError(h,
                       "e-Nabiz paketi uretilemedi (muayene {Id})", id);
            }

            // UYARILAR: ENGEL DEGIL, cunku ikisi de HEKIMIN ELINDE DEGIL.
            //
            // · Bekleyen istem: sonuc gelmeden kapanan muayenede tetkik
            //   sahipsiz kalir - ama sonucu bekletmek hekimin isi degil.
            // · SYS takip numarasi: 103/106 paketleri onu TASIMAK ZORUNDA
            //   (USS "E1004 SYSTakipNo bos olamaz" der) ve numara hasta
            //   kaydinin (101) USS'ye GONDERILMESIYLE gelir. Gonderim ayri
            //   bir is; muayeneyi kilitlemek, klinik kaydi e-Nabiz kuyruguna
            //   bagimli yapardi. Paketler uretilir, numara gelince
            //   gonderilir - hekim yalnizca BILIR.
            var uyarilar = new List<string>();
            if (m.BekleyenIstem > 0)
                uyarilar.Add($"{m.BekleyenIstem} istem hala sonuc bekliyor.");
            if (m.Takip.Length == 0)
                uyarilar.Add("Hasta kaydi (101) henuz e-Nabiz'a gonderilmemis - "
                           + "muayene ve cikis paketleri takip numarasi gelene kadar "
                           + "kuyrukta bekler.");
            // BZBH: taslak acildiysa hekim BILSIN. Bildirimi o gondermeyebilir
            //   (enfeksiyon kontrol birimi gonderir) ama tanisinin bildirimi
            //   zorunlu bir hastalik oldugunu ogrenmeli.
            if (bzbhTaslak > 0)
                uyarilar.Add($"{bzbhTaslak} tani bildirimi zorunlu bulasici hastalik listesinde - "
                           + "BZBH bildirimi acildi, vaka tipi ve belirti tarihi girilmeli.");
            var uyari = uyarilar.Count > 0 ? string.Join(" ", uyarilar) : null;
            return Results.Ok(new { id, m.BelgeId, uyari, paketler, bzbhTaslak,
                                    mesaj = "Muayene tamamlandi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
