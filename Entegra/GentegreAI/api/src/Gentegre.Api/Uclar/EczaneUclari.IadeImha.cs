using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ECZANE — İADE, İMHA ve KONTROLLÜ İLAÇ UÇLARI (722).
///
/// İADE KARARI ÜÇ ÖLÇÜTE BAKAR: ambalaj açıldı mı, sulandırıldı mı, soğuk
/// zincir bozuldu mu. Üçünden biri "evet" ise stoğa kabul EDİLMEZ - burada
/// `zorla` yoktur. Diğer kurallarda kaçış bıraktık çünkü orada risk bir
/// süreç ihlâliydi; burada risk hastaya giden ilacın kendisidir.
///
/// İMHA STOK DÜŞÜMÜ DEĞİLDİR, ama düşüm de gerektirir: tutanak kendi
/// kaydıdır (komisyon, atık sınıfı, teslim no), stok hareketi ise ÇIKIŞ FİŞİ
/// (tür 4). İkisini tek kayda sıkıştırsaydık ya tutanağın alanları belgeye
/// sığmazdı ya stok hareketi belge hattının dışında kalırdı.
///
/// KONTROLLÜ DEFTER SATIRI SİLİNMEZ (722 tetiği DELETE'i reddeder). Hatalı
/// satır, TERS hareketli bir düzeltme satırıyla kapatılır (`duzeltilen_id`).
/// Silinebilseydi defter, mevzuatın istediği şey olmaktan çıkardı.
/// </summary>
public static partial class EczaneUclari
{
    // ==================================================== iade ve imha ==
    private static void IadeImhaUclari(RouteGroupBuilder grup)
    {
        // SERVİS İADESİ KARARI.
        grup.MapPost("/iade/{id:long}/karar", async (
            long id, IadeKararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.iade", Islem.Degistir);

            if (istek.Karar is < 1 or > 3)
                throw GentegreHatasi.Dogrulama("Geçersiz karar.",
                    new AlanHatasi("karar", "1 stoğa kabul · 2 imhaya · 3 kasaya"));

            await using var baglanti = await veri.AcAsync(iptal);

            var i = await baglanti.TekAsync("""
                select i.karar, i.stok_id as "stokId", i.seri_lot_id as "seriLotId",
                       i.miktar, i.sube_id as "subeId",
                       coalesce(nullif(i.ad, ''), s.ad, '') as ad,
                       i.ambalaj_acik as "ambalajAcik", i.sulandirildi,
                       i.soguk_zincir_bozuk as "sogukZincirBozuk",
                       coalesce(s.izleme, 0) as izleme,
                       (select l.son_kullanma_tarihi from public.stok_seri_lot l
                         where l.id = i.seri_lot_id) as skt
                  from public.eczane_iade i
                  left join public.stok s on s.id = i.stok_id
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İade kaydı bulunamadı.");

            if (Convert.ToInt16(i["karar"] ?? (short)0) != 0)
                throw GentegreHatasi.IsKurali("Bu iade için karar zaten verilmiş.");

            var engeller = new List<string>();
            if (Convert.ToInt16(i["ambalajAcik"] ?? (short)0) == 1) engeller.Add("ambalaj açıldı");
            if (Convert.ToInt16(i["sulandirildi"] ?? (short)0) == 1) engeller.Add("sulandırıldı");
            if (Convert.ToInt16(i["sogukZincirBozuk"] ?? (short)0) == 1) engeller.Add("soğuk zincir bozuldu");
            if (i["skt"] is DateTime sk && sk.Date < DateTime.Today)
                engeller.Add($"miadı geçti ({sk:dd.MM.yyyy})");

            // KAÇIŞ YOK. Bkz. dosya başlığı.
            if (istek.Karar == 1 && engeller.Count > 0)
                throw GentegreHatasi.IsKurali(
                    "Bu ilaç stoğa kabul edilemez: " + string.Join(", ", engeller) + ".",
                    new { engeller });

            var simdi = DateTime.Now;
            int? girisBelgeId = null;
            var uyarilar = new List<string>();

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            if (istek.Karar == 1)
            {
                // STOĞA GERİ GİRİŞ = GİRİŞ FİŞİ (tür 3, carisiz). Miktarı elle
                //   `stok_durum`a yazsaydık hareket defteri (belge_satir) ile
                //   bakiye ayrışırdı - "bu 3 kutu nereden geldi" sorusu
                //   yanıtsız kalırdı.
                if (i["stokId"] is null)
                    throw GentegreHatasi.IsKurali(
                        "Stok kartı olmayan iade stoğa alınamaz - önce kalemi stok kartına bağlayın.");

                var depoId = istek.DepoId ?? await VarsayilanDepoAsync(baglanti, islem, iptal);

                var fis = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 3,                       // 3 = Stok Giriş Fişi (carisiz)
                    ["tipi"] = 1,
                    ["belgeTarihi"] = simdi,
                    ["belgeDovizi"] = "TL",
                    ["dovizKuru"] = 1m,
                    ["girisDepoId"] = depoId,
                    ["subeId"] = baglam.SubeId ?? i["subeId"],
                    ["aciklama"] = $"Servis iadesi · {i["ad"]}",
                };

                var satir = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 1,
                    ["stokId"] = i["stokId"],
                    ["miktar"] = i["miktar"],
                    ["birimFiyat"] = 0m,
                    ["kdv"] = 0,
                    ["dovizCinsi"] = "TL",
                    ["girisDepoId"] = depoId,
                    ["aciklama"] = $"İade · {i["ad"]}",
                    ["sira"] = 1,
                };
                // LOT YALNIZ İZLEMLİ STOKTA ve yalnız iade satırı lot söylüyorsa.
                //   İzlemsiz karta lot bağlamak belge hattınca reddedilir.
                if (i["seriLotId"] is not null && Convert.ToInt16(i["izleme"] ?? (short)0) != 0)
                    satir["izlemler"] = new List<Dictionary<string, object?>>
                    {
                        new() { ["seriLotId"] = i["seriLotId"], ["miktar"] = i["miktar"] },
                    };

                var (fisId, belgeUyari) = await belgeDepo.KaydetAsync(
                    fis, [BelgeGovdesi.Satir(satir)],
                    new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                    new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

                girisBelgeId = fisId;
                if (belgeUyari is { Count: > 0 }) uyarilar.AddRange(belgeUyari);
            }

            if (istek.Karar == 2 && istek.ImhaId is { } imhaId)
            {
                // İMHA TUTANAĞINA SATIR EKLE. Tutanak açık olmalı: imha edilmiş
                //   bir tutanağa sonradan kalem eklemek, imzalanmış bir belgeye
                //   satır eklemektir.
                var tutanakDurum = await baglanti.TekDegerAsync<int?>(
                    "select durum from public.eczane_imha where id = @p0", islem, [imhaId], iptal)
                    ?? throw GentegreHatasi.Bulunamadi("İmha tutanağı bulunamadı.");
                if (tutanakDurum >= 2)
                    throw GentegreHatasi.IsKurali("İmha edilmiş tutanağa kalem eklenemez.");

                await baglanti.CalistirAsync("""
                    insert into public.eczane_imha_satir
                        (imha_id, stok_id, seri_lot_id, ad, miktar, neden, atik_sinifi,
                         iade_id, aciklama, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, 4, 1, @p5, @p6, @p7)
                    """, islem,
                    [imhaId, i["stokId"], i["seriLotId"], i["ad"], i["miktar"], id,
                     istek.Aciklama ?? "", baglam.KullaniciId], iptal);
            }
            else if (istek.Karar == 2)
            {
                uyarilar.Add("İmha tutanağı seçilmedi - kalem tutanağa elle eklenmeli.");
            }

            if (istek.Karar == 3)
            {
                // KONTROLLÜ İLAÇ KASAYA DÖNER ve DEFTERE YAZILIR: iade hareketi
                //   defterde görünmezse defterle kasa ayrışır.
                await baglanti.CalistirAsync("""
                    insert into public.kontrollu_defter
                        (sube_id, zaman, hareket, stok_id, seri_lot_id, ad, miktar,
                         departman_id, teslim_alan_id, aciklama, ekleyen)
                    values (@p0, @p1, 3, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p7)
                    """, islem,
                    [baglam.SubeId ?? 0, simdi, i["stokId"], i["seriLotId"], i["ad"],
                     i["miktar"], await DepartmanAsync(baglanti, islem, id, iptal),
                     baglam.KullaniciId, istek.Aciklama ?? "Servis iadesi"], iptal);
            }

            await baglanti.CalistirAsync("""
                update public.eczane_iade
                   set karar = @p1, karar_veren_id = @p2, karar_zamani = @p3,
                       belge_id = coalesce(@p4, belge_id),
                       degistiren = @p2, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, istek.Karar, baglam.KullaniciId, simdi, girisBelgeId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogIade, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { karar = istek.Karar, girisBelgeId, imhaId = istek.ImhaId, engeller },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                karar = istek.Karar, kararZamani = simdi, girisBelgeId, uyarilar,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // KOMİSYON ONAYI. İmha tek kişinin işi değil: onaylayan komisyon
        //   yazılmadan tutanak ilerlemez.
        grup.MapPost("/imha/{id:long}/onayla", async (
            long id, ImhaOnayIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.imha", Islem.Degistir);
            baglam.AksiyonIste("eczane.imha_onay");

            if (string.IsNullOrWhiteSpace(istek.Komisyon))
                throw GentegreHatasi.Dogrulama("Komisyon üyeleri zorunlu.",
                    new AlanHatasi("komisyon", "İmha komisyonu yazılmadan onay verilemez."));

            await using var baglanti = await veri.AcAsync(iptal);

            var t = await baglanti.TekAsync("""
                select m.durum,
                       (select count(*) from public.eczane_imha_satir x
                         where x.imha_id = m.id) as "satirSayisi"
                  from public.eczane_imha m where m.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İmha tutanağı bulunamadı.");

            if (Convert.ToInt16(t["durum"] ?? (short)0) >= 2)
                throw GentegreHatasi.IsKurali("İmha edilmiş tutanak yeniden onaylanamaz.");
            if (Convert.ToInt32(t["satirSayisi"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali("Boş tutanak onaylanamaz.");

            await baglanti.CalistirAsync("""
                update public.eczane_imha
                   set durum = 1, komisyon = @p1,
                       aciklama = coalesce(nullif(@p2, ''), aciklama),
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, null, [id, istek.Komisyon, istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogImha, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { durum = 1, komisyon = istek.Komisyon },
                iptal: iptal);

            return Results.Ok(new { durum = 1, izlemeNo = baglam.IzlemeNo });
        });

        // İMHA ET = ÇIKIŞ FİŞİ + tutanak durumu 2.
        grup.MapPost("/imha/{id:long}/imha-et", async (
            long id, ImhaEtIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.imha", Islem.Degistir);
            baglam.AksiyonIste("eczane.imha_onay");
            baglam.YetkiIste("stok", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var t = await baglanti.TekAsync("""
                select m.durum, m.tutanak_no as "tutanakNo", m.sube_id as "subeId",
                       m.belge_id as "belgeId"
                  from public.eczane_imha m where m.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İmha tutanağı bulunamadı.");

            var durum = Convert.ToInt16(t["durum"] ?? (short)0);
            // KOMİSYON ONAYI OLMADAN İMHA YOK: onay basamağını atlarsak
            //   tutanaktaki imza, olmayan bir kararın imzası olur.
            if (durum < 1)
                throw GentegreHatasi.IsKurali("Komisyon onayı olmadan imha edilemez.");
            if (durum >= 2 || t["belgeId"] is not null)
                throw GentegreHatasi.IsKurali("Bu tutanak zaten imha edildi.");

            var satirlar = await baglanti.ListeAsync("""
                select x.id, x.stok_id as "stokId", x.miktar, x.seri_lot_id as "seriLotId",
                       coalesce(nullif(x.ad, ''), s.ad, '') as ad,
                       coalesce(s.izleme, 0) as izleme, x.atik_sinifi as "atikSinifi"
                  from public.eczane_imha_satir x
                  left join public.stok s on s.id = x.stok_id
                 where x.imha_id = @p0 and x.stok_id is not null and x.miktar > 0
                 order by x.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (satirlar.Count == 0)
                throw GentegreHatasi.IsKurali(
                    "Stok kartına bağlı kalem yok - düşülecek bir şey bulunamadı.");

            var depoId = istek.DepoId ?? await VarsayilanDepoAsync(baglanti, null, iptal);

            var fis = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 4,                       // 4 = Stok Çıkış Fişi (carisiz)
                ["tipi"] = 1,
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["cikisDepoId"] = depoId,
                ["subeId"] = baglam.SubeId ?? t["subeId"],
                ["aciklama"] = $"Eczane imha · {t["tutanakNo"]}",
            };

            var govde = new List<Dictionary<string, JsonElement>>();
            var sira = 0;
            foreach (var x in satirlar)
            {
                var alanlar = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 1,
                    ["stokId"] = x["stokId"],
                    ["miktar"] = x["miktar"],
                    ["birimFiyat"] = 0m,
                    ["kdv"] = 0,
                    ["dovizCinsi"] = "TL",
                    ["cikisDepoId"] = depoId,
                    ["aciklama"] = $"İmha · {x["ad"]}",
                    ["sira"] = ++sira,
                };
                if (x["seriLotId"] is not null && Convert.ToInt16(x["izleme"] ?? (short)0) != 0)
                    alanlar["izlemler"] = new List<Dictionary<string, object?>>
                    {
                        new() { ["seriLotId"] = x["seriLotId"], ["miktar"] = x["miktar"] },
                    };
                govde.Add(BelgeGovdesi.Satir(alanlar));
            }

            var (fisId, uyarilar) = await belgeDepo.KaydetAsync(
                fis, govde,
                // Stok kontrolü AÇIK: imha edilen şey elde olmalıydı. Negatif
                //   bakiyede ne olacağı kurum ayarıdır (uyarı ya da engel).
                new BelgeSecenekleri { Taslak = false, StokKontrolu = true },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

            await baglanti.CalistirAsync("""
                update public.eczane_imha
                   set durum = 2, belge_id = @p1,
                       atik_teslim_no = coalesce(nullif(@p2, ''), atik_teslim_no),
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, null, [id, fisId, istek.AtikTeslimNo ?? "", baglam.KullaniciId], iptal);

            // KONTROLLÜ İLAÇ İMHASI DEFTERE DE YAZILIR. Yalnız çıkış fişine
            //   yazsaydık defter eksik kalırdı; defter mevzuatın istediği kayıt.
            // KONTROLLÜ OLAN KALEM `ilac.recete_turu`den bilinir (413):
            //   1 kırmızı (narkotik) · 2 yeşil (psikotrop). Stok kartında ayrı
            //   bir "kontrollü" bayrağı YOK ve uydurmuyoruz - ilaç kataloğu
            //   zaten söylüyor, ikinci bir bayrak iki yerde bakım demekti.
            var kontrolluSatir = await baglanti.CalistirAsync("""
                insert into public.kontrollu_defter
                    (sube_id, zaman, hareket, stok_id, seri_lot_id, ad, miktar,
                     recete_renk, belge_id, aciklama, ekleyen)
                select @p1, now(), 4, x.stok_id, x.seri_lot_id,
                       coalesce(nullif(x.ad, ''), s.ad, ''), x.miktar,
                       il.recete_turu, @p2,
                       'İmha tutanağı ' || coalesce(nullif(@p3, ''), '-'), @p4
                  from public.eczane_imha_satir x
                  join public.stok s on s.id = x.stok_id
                  join public.ilac il on il.stok_id = x.stok_id
                                     and il.recete_turu in (1, 2)
                 where x.imha_id = @p0
                """, null,
                [id, baglam.SubeId ?? 0, fisId, t["tutanakNo"] ?? "", baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogImha, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { durum = 2, belgeId = fisId, satir = satirlar.Count, kontrolluSatir },
                iptal: iptal);

            return Results.Ok(new
            {
                durum = 2, belgeId = fisId, satir = satirlar.Count,
                defterSatiri = kontrolluSatir, uyarilar, izlemeNo = baglam.IzlemeNo
            });
        });
    }

    // ==================================================== kontrollü ilaç ==
    private static void KontrolluUclari(RouteGroupBuilder grup)
    {
        // DEFTER SATIRI. Yalnız EKLENİR; düzeltme ters satırla yapılır.
        grup.MapPost("/defter", async (
            DefterIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.kontrollu", Islem.Ekle);

            if (istek.Hareket is < 1 or > 6)
                throw GentegreHatasi.Dogrulama("Geçersiz hareket.",
                    new AlanHatasi("hareket",
                        "1 giriş · 2 çıkış · 3 iade · 4 artık imha · 5 devir · 6 sayım"));
            if (istek.Miktar <= 0)
                throw GentegreHatasi.Dogrulama("Miktar sıfırdan büyük olmalı.",
                    new AlanHatasi("miktar", "Miktar sıfırdan büyük olmalı."));

            // ÇİFT İMZA. Kontrollü ilaç elden ele geçer: teslim eden ve alan
            //   yazılmadan çıkış/iade satırı defterin işini görmez.
            if (istek.Hareket is 2 or 3
                && (istek.TeslimEdenId is null || istek.TeslimAlanId is null))
                throw GentegreHatasi.Dogrulama("Teslim eden ve teslim alan zorunlu.",
                    new AlanHatasi("teslimAlanId", "Çıkış/iade satırı çift imza ister."));

            // KIRMIZI REÇETE (narkotik) TANIK İSTER: kırmızı reçeteli çıkışta
            //   iki imza yetmez, üçüncü bir kişi olayı görmüş olmalı.
            if (istek.Hareket == 2 && istek.ReceteRenk == 1 && istek.TanikId is null)
                throw GentegreHatasi.Dogrulama("Kırmızı reçeteli çıkışta tanık zorunlu.",
                    new AlanHatasi("tanikId", "Kırmızı reçete (narkotik) tanık ister."));

            await using var baglanti = await veri.AcAsync(iptal);

            // DÜZELTME: düzeltilen satır var mı ve zaten düzeltilmiş mi?
            //   Aynı satırı iki kez düzeltmek, defteri okunamaz hâle getirir.
            if (istek.DuzeltilenId is { } duzeltilen)
            {
                var d = await baglanti.TekAsync("""
                    select f.id,
                           (select count(*) from public.kontrollu_defter x
                             where x.duzeltilen_id = f.id) as "zatenDuzeltildi"
                      from public.kontrollu_defter f where f.id = @p0
                    """, null, [duzeltilen], OkuyucuGenisletmeleri.Sozluk, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Düzeltilecek defter satırı bulunamadı.");
                if (Convert.ToInt32(d["zatenDuzeltildi"] ?? 0) > 0)
                    throw GentegreHatasi.IsKurali("Bu satır zaten bir düzeltme satırıyla kapatılmış.");
                if (string.IsNullOrWhiteSpace(istek.Aciklama))
                    throw GentegreHatasi.Dogrulama("Düzeltme açıklaması zorunlu.",
                        new AlanHatasi("aciklama", "Neyin düzeltildiği yazılmalı."));
            }

            var yeniId = await baglanti.TekDegerAsync<long>("""
                insert into public.kontrollu_defter
                    (sube_id, zaman, hareket, stok_id, seri_lot_id, ad, miktar,
                     recete_renk, recete_no, hasta_id, departman_id,
                     teslim_eden_id, teslim_alan_id, tanik_id, belge_id,
                     aciklama, duzeltilen_id, ekleyen)
                values (@p0, now(), @p1, @p2, @p3,
                        coalesce(nullif(@p4, ''),
                                 (select s.ad from public.stok s where s.id = @p2), ''),
                        @p5, coalesce(@p6, 0), @p7, @p8, @p9, @p10, @p11, @p12, @p13,
                        @p14, @p15, @p16)
                returning id
                """, null,
                [baglam.SubeId ?? 0, istek.Hareket, istek.StokId, istek.SeriLotId,
                 istek.Ad ?? "", istek.Miktar, istek.ReceteRenk, istek.ReceteNo ?? "",
                 istek.HastaId, istek.DepartmanId, istek.TeslimEdenId, istek.TeslimAlanId,
                 istek.TanikId, istek.BelgeId, istek.Aciklama ?? "", istek.DuzeltilenId,
                 baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Ekle, LogDefter, yeniId, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new
                {
                    hareket = istek.Hareket, miktar = istek.Miktar,
                    receteRenk = istek.ReceteRenk, duzeltilenId = istek.DuzeltilenId
                }, iptal: iptal);

            return Results.Ok(new { id = yeniId, izlemeNo = baglam.IzlemeNo });
        });

        // GÜNLÜK SAYIM KAPANIŞI.
        //
        // UYUM TETİKLE HESAPLANIR (722): satır kaydedilirken `uyumlu` yazılır.
        //   Burada yalnız TUTANAĞIN sonucu belirlenir - fark varsa kapatmak
        //   gerekçe ister, çünkü kontrollü ilaç farkı bir olaydır ve
        //   "kapattık, geçti" diye kapanmaz.
        grup.MapPost("/sayim/{id:long}/kapat", async (
            long id, SayimKapatIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("eczane.kontrollu", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var s = await baglanti.TekAsync("""
                select y.durum, y.sayan1_id as "sayan1", y.sayan2_id as "sayan2",
                       (select count(*) from public.kontrollu_sayim_satir x
                         where x.sayim_id = y.id) as "satirSayisi",
                       (select count(*) from public.kontrollu_sayim_satir x
                         where x.sayim_id = y.id and coalesce(x.uyumlu, 0) = 0) as "uyumsuz",
                       (select count(*) from public.kontrollu_sayim_satir x
                         where x.sayim_id = y.id and coalesce(x.uyumlu, 0) = 0
                           and coalesce(x.aciklama, '') = '') as "aciklamasiz"
                  from public.kontrollu_sayim y where y.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Sayım bulunamadı.");

            if (Convert.ToInt16(s["durum"] ?? (short)0) != 0)
                throw GentegreHatasi.IsKurali("Bu sayım zaten kapatılmış.");
            if (Convert.ToInt32(s["satirSayisi"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali("Satırı olmayan sayım kapatılamaz.");

            // İKİ SAYICI BİRBİRİNİ GÖRMEDEN SAYAR. Aynı kişiyse sayım çift
            //   kontrol olmaktan çıkar - burada engelliyoruz çünkü bu, kaydın
            //   kendisinin anlamını belirleyen koşul.
            if (s["sayan1"] is { } a1 && s["sayan2"] is { } a2
                && Convert.ToInt32(a1) == Convert.ToInt32(a2))
                throw GentegreHatasi.IsKurali(
                    "İki sayıcı aynı kişi olamaz - sayım çift kontrol gerektirir.");

            var uyumsuz = Convert.ToInt32(s["uyumsuz"] ?? 0);
            if (uyumsuz > 0)
            {
                if (!istek.FarklaKapat)
                    throw GentegreHatasi.IsKurali(
                        $"{uyumsuz} satırda fark var - fark tutanağı açılmadan kapatılamaz.",
                        new { uyumsuz });
                if (Convert.ToInt32(s["aciklamasiz"] ?? 0) > 0)
                    throw GentegreHatasi.IsKurali(
                        "Farklı satırların hepsinde açıklama olmalı.");
                if (string.IsNullOrWhiteSpace(istek.Aciklama))
                    throw GentegreHatasi.Dogrulama("Fark açıklaması zorunlu.",
                        new AlanHatasi("aciklama", "Fark varken kapatma gerekçesi zorunlu."));
            }

            // 0 açık · 1 uyumlu kapandı · 2 farklı (tutanak açıldı)
            var yeniDurum = (short)(uyumsuz > 0 ? 2 : 1);

            await baglanti.CalistirAsync("""
                update public.kontrollu_sayim
                   set durum = @p1, aciklama = coalesce(nullif(@p2, ''), aciklama),
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, null, [id, yeniDurum, istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogSayim, id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { durum = yeniDurum, uyumsuz, aciklama = istek.Aciklama }, iptal: iptal);

            return Results.Ok(new { durum = yeniDurum, uyumsuz, izlemeNo = baglam.IzlemeNo });
        });
    }

    // ------------------------------------------------------- yardımcılar ----

    /// <summary>
    /// Eczane deposu ayarı yoksa kurumun varsayılan deposu. Depo bulunamazsa
    /// hata - sessizce "0 numaralı depo"ya yazmak, stoğu görünmez bir yere
    /// koymak olurdu.
    /// </summary>
    private static async Task<int> VarsayilanDepoAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, CancellationToken iptal)
    {
        var ayar = await AyarDeposu.MetinAsync(baglanti, islem, "eczane.depo", "", iptal);
        return await baglanti.TekDegerAsync<int?>("""
            select coalesce(nullif(@p0, '')::int,
                   (select min(x.id) from public.depo x
                     where x.varsayilan = 1 and coalesce(x.durum, 1) = 1),
                   (select min(x.id) from public.depo x where coalesce(x.durum, 1) = 1))
            """, islem, [ayar], iptal)
            ?? throw GentegreHatasi.IsKurali(
                "Depo bulunamadı - Genel Ayarlar'dan eczane deposunu seçin.");
    }

    private static async Task<int?> DepartmanAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, long iadeId, CancellationToken iptal)
        => await baglanti.TekDegerAsync<int?>(
            "select departman_id from public.eczane_iade where id = @p0", islem, [iadeId], iptal);
}
