using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İSKONTO ONAYI (662) — kayıt kabul talep eder, yetkili zilden onaylar.
///
/// İki taraf, iki yetki:
///   · talep açmak  — başvuru satırını görebilen herkes (indirim İSTEMEK
///     yetki gerektirmez; yetki gereken şey onu VERMEKtir),
///   · onay / ret   — `basvuru.iskonto` ve TAVANI talebi karşılayan kullanıcı.
///     Tavanı yetmeyen kişi talebi listesinde HİÇ görmez: göremediği bir şeyi
///     onaylayamaz, gördüğü ama basamadığı düğme ise onu sunucudan ret yemeye
///     gönderirdi.
///
/// ============ KARAR BURADA DEĞİL (754) ===============================
/// Talep artık onay omurgasında yürüyor (`belge.iskonto`, kaynak_tur 1256)
/// ve karar `/api/onay/kayit/1256/{id}/karar` ucundan veriliyor. Burada
/// ikinci bir karar ucu BIRAKMADIK: iki yol olsaydı biri zinciri yürütüp
/// öteki doğrudan `fn_iskonto_talep_karar` çağırır, sıradaki basamak hiç
/// sorulmadan talep kapanırdı.
///
/// Talep AÇMAK burada kalıyor - zinciri o başlatıyor.
/// </summary>
public static class IskontoOnayUclari
{
    /// <summary>`islem_log.tablo_id` — omurganın kaynak türü (754).</summary>
    public const int KaynakIskonto = 1256;

    /// <summary>Kalem bazli oran (673): her satirin kendi yuzdesi.</summary>
    public sealed record TalepKalemi(int SatirId, decimal Oran);
    public sealed record TalepIstegi(int BelgeId, decimal Oran, string Gerekce,
                                     IReadOnlyList<TalepKalemi> Kalemler);
    /// <summary>SÖZLÜ ONAY (1375): talep + sözünü veren yönetici.</summary>
    public sealed record SozluIstegi(int BelgeId, string Gerekce, IReadOnlyList<TalepKalemi> Kalemler,
                                     int OnaylayanId);
    public sealed record YontemIstegi(short Yontem);
    /// <summary>Onayı geri al (1377): neden zorunlu.</summary>
    public sealed record GeriAlIstegi(string Neden);

    /// <summary>İskonto onaycısı: dijital zincirin herhangi bir basamağını imzalayabilen (OnayBildirimi.AksiyonKodu).</summary>
    private static bool OnayciMi(IstekBaglami b) =>
        b.Yetkiler.AksiyonVar("belge.iskonto_onay_birim") || b.Yetkiler.AksiyonVar("belge.iskonto_onay_mali")
        || b.Yetkiler.AksiyonVar("belge.iskonto_onay_ust");

    /// <summary>Şube onay yöntemi (1375): 1 dijital · 2 sözlü · 3 ikisi de.</summary>
    public const short YontemDijital = 1, YontemSozlu = 2, YontemIkisi = 3;

    /// <summary>islem_log tablo kimliği - şube kartı (KartKatalogu.Firma LogTabloId).</summary>
    private const int LogTabloSube = 1276;

    public static void IskontoOnayUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/iskonto-talep").WithTags("İskonto")
                      .RequireAuthorization();

        // Belgenin talepleri (ücret sekmesinde durum rozetleri için).
        grup.MapGet("/belge/{belgeId:int}", async (
            int belgeId, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(await depo.BelgeTalepleriAsync(belgeId, iptal));
        });

        // ZİL: bu kullanıcının onayına düşen bekleyen talepler.
        grup.MapGet("/bekleyenler", async (
            BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Yetkisi olmayana BOŞ liste - hata değil: zil herkeste var.
            if (baglam.Yetkiler.AksiyonDegeri("basvuru.iskonto") <= 0)
                return Results.Ok(Array.Empty<object>());
            // SÜZGEÇ OMURGADAN (754): yalnız sırası bu kullanıcıda olan talep.
            return Results.Ok(await depo.BekleyenlerAsync(
                baglam.SubeId ?? 0, baglam.KullaniciId, iptal));
        });

        // ISKONTO ONAY EKRANI (666): sonuclanan talepler - denetim izi.
        grup.MapGet("/gecmis", async (
            int? gun, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // ONAY EKRANININ KENDI YETKISI (685): denetim izini gormek belge
            //   gormekten ayri bir istir - kayit kabul gorevlisi basvuruyu
            //   gorur ama kimin neyi onayladigini gormesi gerekmez.
            baglam.YetkiIste("iskonto_onay", Islem.Gor);
            return Results.Ok(await depo.GecmisAsync(
                baglam.SubeId ?? 0, Math.Clamp(gun ?? 1, 1, 90), iptal));
        });

        // YETKI LIMITLERI (666): rol tavanlari - onay ekraninin limit sekmesi.
        grup.MapGet("/limitler", async (
            BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("iskonto_onay", Islem.Gor);
            return Results.Ok(await depo.LimitlerAsync(iptal));
        });

        // TALEP AÇMAK = ZİNCİRİ BAŞLATMAK (754): ikisi aynı işlemde olur.
        grup.MapPost("/", async (
            TalepIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.OnayMotoru onay, Servisler.OnayBildirimi haber,
            KayitErisimi erisim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            // ŞUBE KAPISI (K32): istemciden gelen belgeId aktif şubenin / kapsamın
            //   belgesi olmalı - başka şubenin başvurusuna talep açılamaz.
            await erisim.IsteAsync(baglam, "belge", istek.BelgeId, "Belge bulunamadı.", iptal);
            if (istek.Kalemler.Count == 0)
                throw GentegreHatasi.Dogrulama("Onaya gönderilecek satır seçilmeli.",
                    new AlanHatasi("kalemler", "En az bir satır seçin."));
            if (!(istek.Oran > 0))
                throw GentegreHatasi.Dogrulama("İskonto oranı sıfırdan büyük olmalı.",
                    new AlanHatasi("oran", "Sıfırdan büyük olmalı."));
            if (istek.Gerekce.Trim().Length == 0)
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                    new AlanHatasi("gerekce", "Zorunlu."));

            // BASLIK ORANI = en yuksek kalem orani: eşik kontrolü onunla
            //   olculur, istemcinin gonderdigi degere guvenilmez.
            var enYuksek = istek.Kalemler.Max(k => k.Oran);
            var satirIdler = istek.Kalemler.Select(k => k.SatirId).ToList();

            await using var baglanti = await veri.AcAsync(iptal);

            // ŞUBE KAPISI (K32): talebin şubesi BELGENİN şubesidir, başlıktan
            //   gelen değil - zil ve geçmiş o şubeye süzülür.
            var belgeSube = await baglanti.TekDegerAsync<int?>(
                "select sube_id from public.belge where id = @p0", null, [istek.BelgeId], iptal)
                ?? baglam.SubeId ?? 0;

            var bayraklar = new List<string>();
            if (await IskontoTalepDeposu.TekrarIndirimMiAsync(
                    baglanti, null, satirIdler, iptal))
                bayraklar.Add("tekrar_iskonto");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var id = await IskontoTalepDeposu.TalepAcAsync(baglanti, islem,
                istek.BelgeId, enYuksek, istek.Gerekce,
                istek.Kalemler.Select(k => (k.SatirId, k.Oran)).ToList(),
                baglam.KullaniciId, belgeSube, iptal);
            await SatirlarTamMiAsync(baglanti, islem, id, istek.Kalemler.Select(k => k.SatirId).Distinct().Count(), iptal);

            // ÖLÇÜ = ORAN (yüzde), tutar değil: aynı %30 küçük ve büyük
            //   başvuruda kurumun fiyat politikasına aynı ölçüde dokunur.
            var zincir = await onay.BaslatAsync(baglanti, islem, "belge.iskonto",
                id, enYuksek, bayraklar, baglam, iptal);

            await islem.CommitAsync(iptal);

            try
            {
                await haber.SiradakiniBildirAsync(baglanti, zincir.OnayId,
                    baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (Exception) { /* zincir kuruldu; bildirim hatası onu düşürmez */ }

            return Results.Ok(new
            {
                id, oran = enYuksek, bayraklar,
                basamaklar = zincir.Adimlar.Select(a => new { a.Sira, a.Ad, a.Rol }),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ================================================= SÖZLÜ ONAY (1375) ===
        // Kullanıcı 18.11.2026: "bir çok müşterimiz sözlü onay kullanıyor.. banko ilgili yöneticinin sözüyle yüksek
        //   oranlarda indirim yapabiliyor" · "sözlü onay / dijital onay opsiyonlu olabilmeli". Şube ayarı yöntemi
        //   seçer; sözlü onayda banko yöneticiyi seçer + gerekçe, iskonto HEMEN uygulanır (oran sınırı yok - kullanıcı
        //   kararı), talep "sözlü" damgasıyla seçilen yönetici adına onaylı yazılır ve yöneticinin zilinde hatırlatma
        //   açılır. Oranı satırlara yazan yine `fn_iskonto_talep_karar` - ikinci bir yazma yolu yok.

        // Başvuru kartının iskonto penceresi: bu belgenin şubesindeki yöntem + seçilebilecek yöneticiler.
        grup.MapGet("/sozlu-bilgi", async (
            int belgeId, BaglamCozucu cozucu, VeriKaynagi veri, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            await erisim.IsteAsync(baglam, "belge", belgeId, "Belge bulunamadı.", iptal);
            await using var b = await veri.AcAsync(iptal);
            var sube = await b.TekDegerAsync<int?>("select sube_id from public.belge where id = @p0", null, [belgeId], iptal)
                       ?? baglam.SubeId ?? 0;
            var yontem = await YontemAsync(b, null, sube, iptal);
            var onaycilar = yontem == YontemDijital
                ? []
                : await b.ListeAsync("select id, ad from public.fn_iskonto_sozlu_onaycilar(@p0, @p1)", null,
                      [sube, baglam.KullaniciId], o => new SozluOnayci(o.GetInt32(0), o.GetString(1)), iptal);
            return Results.Ok(new { yontem, onaycilar, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/sozlu", async (
            SozluIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log, BelgeDeposu belgeDeposu,
            KayitErisimi erisim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            baglam.YazmaIste();
            await erisim.IsteAsync(baglam, "belge", istek.BelgeId, "Belge bulunamadı.", iptal);
            var kalemler = (istek.Kalemler ?? []).Where(k => k.SatirId > 0 && k.Oran > 0).ToList();
            if (kalemler.Count == 0)
                throw GentegreHatasi.Dogrulama("İskonto uygulanacak satır seçilmeli.",
                    new AlanHatasi("kalemler", "En az bir satır seçin."));
            if (kalemler.Any(k => k.Oran > 100))
                throw GentegreHatasi.Dogrulama("İskonto oranı %100'ü aşamaz.", new AlanHatasi("oran", "En çok 100."));
            var gerekce = (istek.Gerekce ?? "").Trim();
            if (gerekce.Length == 0)
                throw GentegreHatasi.Dogrulama("Sözlü onayda gerekçe zorunlu.", new AlanHatasi("gerekce", "Zorunlu."));

            await using var b = await veri.AcAsync(iptal);
            var belge = await b.TekAsync("""
                select coalesce(be.sube_id, 0), coalesce(be.belge_no, ''),
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')
                  from public.belge be left join public.taraf h on h.id = be.taraf_id
                 where be.id = @p0
                """, null, [istek.BelgeId], o => new SozluBelge(o.GetInt32(0), o.GetString(1), o.GetString(2)), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");

            if (await YontemAsync(b, null, belge.Sube, iptal) == YontemDijital)
                throw GentegreHatasi.IsKurali("Bu şubede iskonto yalnız dijital onayla verilir (Başvuru Ayarları › İskonto Onay Yöntemi).");
            // Seçilen kişi gerçekten onaycı mı - istemcinin gönderdiği kimliğe güvenilmez.
            var yonetici = (await b.ListeAsync(
                    "select ad from public.fn_iskonto_sozlu_onaycilar(@p0, @p1) where id = @p2",
                    null, [belge.Sube, baglam.KullaniciId, istek.OnaylayanId], o => o.GetString(0), iptal)).FirstOrDefault()
                ?? throw GentegreHatasi.IsKurali("Seçilen kişi bu şubede iskonto onayı veremez.");

            var enYuksek = kalemler.Max(k => k.Oran);
            var banko = await b.TekDegerAsync<string>(
                "select coalesce(public.fn_taraf_ad(unvan, ad, soyad)::varchar(120), '') from public.taraf where id = @p0",
                null, [baglam.KullaniciId], iptal) ?? "";
            var tr = System.Globalization.CultureInfo.GetCultureInfo("tr-TR");

            await using var islem = await b.BeginTransactionAsync(iptal);
            var id = await IskontoTalepDeposu.TalepAcAsync(b, islem, istek.BelgeId, enYuksek, gerekce,
                kalemler.Select(k => (k.SatirId, k.Oran)).ToList(), baglam.KullaniciId, belge.Sube, iptal);
            await SatirlarTamMiAsync(b, islem, id, kalemler.Select(k => k.SatirId).Distinct().Count(), iptal);
            // KARAR YÖNETİCİ ADINA: onay_id = sözünü veren; isteyen = beyan eden banko (783 "kendi talebini
            //   onaylayamaz" kuralı bu yüzden kendiliğinden işler). Oranı satırlara kilitli yazan tek yer.
            await b.CalistirAsync("select public.fn_iskonto_talep_karar(@p0, 1::smallint, @p1, @p2, @p3)", islem,
                [id, enYuksek, $"Sözlü onay - beyan eden: {banko}", istek.OnaylayanId], iptal);
            await b.CalistirAsync("""
                update public.iskonto_talep set onay_yontemi = 2, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            // Tutar / dağılım / dip toplam - karar oranı yazdı, para hesabı kart kaydıyla aynı yerden.
            await belgeDeposu.IskontoSonrasiYenileAsync(b, islem, id, iptal);

            await log.YazAsync(b, islem, LogIslemi.Ekle, KaynakIskonto, id, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new Dictionary<string, string>
                {
                    ["islem"] = "Sözlü onayla iskonto",
                    ["belge"] = belge.No,
                    ["oran"] = enYuksek.ToString(System.Globalization.CultureInfo.InvariantCulture),
                    ["onaylayan"] = yonetici,
                    ["gerekce"] = gerekce,
                }, iptal: iptal);

            // BİLDİRİM = YÖNETİCİNİN ZİLİ: hatırlatma, başvuruya bağlı (↗ Kaydı aç). Yönetici okuyup kapatır.
            await b.CalistirAsync("""
                insert into public.hatirlatma (sahip_id, baslik, notu, zaman, uyar_dk, oncelik, kanal_uygulama,
                                               kaynak, kaynak_id, kaynak_ad, sube_id, ekleyen)
                values (@p0, @p1, @p2, now(), 0, 2, 1, 'basvuru', @p3, @p4, @p5, @p6)
                """, islem,
                [istek.OnaylayanId,
                 $"Sözlü onayınızla %{enYuksek.ToString("0.##", tr)} iskonto uygulandı",
                 $"{banko} sözlü onayınızı beyan ederek {belge.Hasta} ({belge.No}) başvurusunda {kalemler.Count} kaleme "
                 + $"iskonto uyguladı. Gerekçe: {gerekce}",
                 istek.BelgeId, string.Join(" · ", new[] { belge.No, belge.Hasta }.Where(x => x.Length > 0)),
                 belge.Sube, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, oran = enYuksek, onaylayan = yonetici, izlemeNo = baglam.IzlemeNo });
        });

        // ============================================== ONAYI GERİ AL (1377) ===
        // Kullanıcı 18.11.2026: "sözlü onaylandı ve kitlendi.. banko nasıl değişebilir?" Kararlar: SÖZLÜ onayı uygulayan
        //   banko (ya da onaycı) geri alır, DİJİTAL onayı yalnız onaycı; belgeye dönüşmüş satırda geri alma yok,
        //   tahsilat varsa izin (açık tutar artar). Oran onay öncesine döner, kilit açılır; tutar yeniden hesaplanır.
        grup.MapPost("/{id:int}/geri-al", (
            int id, GeriAlIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            BelgeDeposu belgeDeposu, KayitErisimi erisim, HttpContext ctx, CancellationToken iptal) =>
            GeriAlAsync(id, istek, cozucu, veri, log, belgeDeposu, erisim, ctx, iptal));

        // SATIRDAN GERİ AL: ekranda görülen kilitli SATIR - onu kilitleyen en son onaylı talep geri alınır.
        grup.MapPost("/satir/{satirId:int}/geri-al", async (
            int satirId, GeriAlIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            BelgeDeposu belgeDeposu, KayitErisimi erisim, HttpContext ctx, CancellationToken iptal) =>
        {
            var talepId = await veri.TekDegerAsync<int?>("""
                select t.id from public.iskonto_talep_satir ts
                  join public.iskonto_talep t on t.id = ts.talep_id and t.durum = 1
                 where ts.belge_satir_id = @p0
                 order by t.id desc limit 1
                """, [satirId], iptal)
                ?? throw GentegreHatasi.IsKurali("Bu satırda geri alınacak onaylı iskonto yok.");
            return await GeriAlAsync(talepId, istek, cozucu, veri, log, belgeDeposu, erisim, ctx, iptal);
        });

        // ŞUBE AYARI: aktif şubenin yöntemi (Başvuru Ayarları). Okuma serbest - pencere davranışı buna bağlı.
        grup.MapGet("/onay-yontemi", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(new { yontem = await YontemAsync(b, null, baglam.SubeId ?? 0, iptal), subeId = baglam.SubeId });
        });

        grup.MapPut("/onay-yontemi", async (
            YontemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Başvuru Ayarları ekranının yetkisi (ya da genel ayar) - AyarUclari ile aynı kapı.
            if (!baglam.Yetkiler.Var("kayit_kabul.ayar", Islem.Degistir)) baglam.YetkiIste("ayar", Islem.Degistir);
            baglam.YazmaIste();
            if (istek.Yontem is not (YontemDijital or YontemSozlu or YontemIkisi))
                throw GentegreHatasi.Dogrulama("Geçersiz onay yöntemi.", new AlanHatasi("yontem", "1, 2 ya da 3."));
            var sube = baglam.SubeId ?? 0;
            if (sube <= 0) throw GentegreHatasi.IsKurali("Aktif şube yok.");
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var eski = await YontemAsync(b, islem, sube, iptal);
            if (eski != istek.Yontem)
            {
                await b.CalistirAsync("update public.sube set iskonto_onay_yontemi = @p1 where id = @p0", islem,
                    [sube, istek.Yontem], iptal);
                await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloSube, sube, baglam.KullaniciId, baglam.SubeId,
                    baglam.Ip, new Dictionary<string, string>
                    {
                        ["İskonto Onay Yöntemi"] = $"{YontemAdi(eski)} → {YontemAdi(istek.Yontem)}",
                    }, iptal: iptal);
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { yontem = istek.Yontem, subeId = sube });
        });

        // KARAR UCU YOK: `/api/onay/kayit/1256/{id}/karar` (754). Kısmi onay
        //   orada `olcu` alanıyla verilir - ölçü düşünce gerekmeyen ileri
        //   basamaklar atlanır.
    }

    private sealed record SozluOnayci(int Id, string Ad);
    private sealed record SozluBelge(int Sube, string No, string Hasta);
    private sealed record GeriAlinan(int BelgeId, short Durum, short Yontem, int IsteyenId, int OnayId, decimal Oran,
                                     string BelgeNo, int Sube);

    private static string YontemAdi(short y) => y switch { YontemSozlu => "Sözlü", YontemIkisi => "İkisi de", _ => "Dijital" };

    /// <summary>Şubenin iskonto onay yöntemi (1375); şube yoksa dijital.</summary>
    private static async Task<short> YontemAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction? islem, int sube,
        CancellationToken iptal)
        => await b.TekDegerAsync<short?>("select iskonto_onay_yontemi from public.sube where id = @p0", islem, [sube], iptal)
           ?? YontemDijital;

    /// <summary>ONAYI GERİ AL (1377) - iki uç (talep / satır) aynı kuralla.</summary>
    private static async Task<IResult> GeriAlAsync(int id, GeriAlIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
        LogDeposu log, BelgeDeposu belgeDeposu, KayitErisimi erisim, HttpContext ctx, CancellationToken iptal)
    {
        var baglam = await cozucu.CozAsync(ctx, iptal);
        baglam.YazmaIste();
        var neden = (istek?.Neden ?? "").Trim();
        if (neden.Length == 0)
            throw GentegreHatasi.Dogrulama("Geri alma nedeni zorunlu.", new AlanHatasi("neden", "Zorunlu."));

        await using var b = await veri.AcAsync(iptal);
        var t = await b.TekAsync("""
            select t.belge_id, t.durum, t.onay_yontemi, t.isteyen_id, coalesce(t.onay_id, 0), t.oran,
                   coalesce(be.belge_no, ''), coalesce(be.sube_id, 0)
              from public.iskonto_talep t join public.belge be on be.id = t.belge_id
             where t.id = @p0
            """, null, [id], o => new GeriAlinan(o.GetInt32(0), o.GetInt16(1), o.GetInt16(2), o.GetInt32(3),
                o.GetInt32(4), o.GetDecimal(5), o.GetString(6), o.GetInt32(7)), iptal)
            ?? throw GentegreHatasi.Bulunamadi("İskonto talebi bulunamadı.");
        await erisim.IsteAsync(baglam, "belge", t.BelgeId, "Belge bulunamadı.", iptal);

        var sozlu = t.Yontem == 2;
        var onayci = OnayciMi(baglam);
        if (!(onayci || (sozlu && t.IsteyenId == baglam.KullaniciId)))
            throw GentegreHatasi.Yasak(sozlu
                ? "Sözlü onayı yalnız uygulayan görevli ya da iskonto onay yetkilisi geri alabilir."
                : "Dijital onaylı iskontoyu yalnız iskonto onay yetkilisi geri alabilir.");
        // Kod inceleme 18.11.2026: onaycı olmayan (sözlüyü uygulayan görevli) belgeyi değiştirebilmeli; iptal
        //   edilmiş belgede satır tutarı değiştirilmez.
        if (!onayci) baglam.YetkiIste("belge", Islem.Degistir);
        if (await b.TekDegerAsync<short?>("select durum from public.belge where id = @p0", null, [t.BelgeId], iptal) == 6)
            throw GentegreHatasi.IsKurali("İptal edilmiş belgede iskonto geri alınamaz.");

        await using var islem = await b.BeginTransactionAsync(iptal);
        await b.CalistirAsync("select public.fn_iskonto_talep_geri_al(@p0, @p1, @p2)", islem,
            [id, baglam.KullaniciId, neden], iptal);
        // DİJİTAL ZİNCİR DE KAPANIR (kod inceleme 18.11.2026): talep "Geri çekildi" iken onay ekranları zinciri
        //   "onaylandı" göstermesin - zincir İPTAL (3); basamakların onay geçmişi olduğu gibi kalır.
        await b.CalistirAsync(
            "update public.onay set durum = 3, bitis = now(), degistiren = @p1, degistirme_tarihi = now() "
            + "where kaynak_tur = @p2 and kaynak_id = @p0 and durum = 1",
            islem, [id, baglam.KullaniciId, KaynakIskonto], iptal);
        await belgeDeposu.IskontoSonrasiYenileAsync(b, islem, id, iptal);
        await log.YazAsync(b, islem, LogIslemi.Degistir, KaynakIskonto, id, baglam.KullaniciId, baglam.SubeId,
            baglam.Ip, new Dictionary<string, string>
            {
                ["islem"] = "İskonto onayı geri alındı",
                ["yontem"] = sozlu ? "Sözlü" : "Dijital",
                ["belge"] = t.BelgeNo,
                ["oran"] = t.Oran.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ["neden"] = neden,
            }, iptal: iptal);
        // SÖZLÜ: sözünü veren yönetici haberdar olur (kendisi geri almadıysa).
        if (sozlu && t.OnayId > 0 && t.OnayId != baglam.KullaniciId)
        {
            var kim = await b.TekDegerAsync<string>(
                "select coalesce(public.fn_taraf_ad(unvan, ad, soyad)::varchar(120), '') from public.taraf where id = @p0",
                islem, [baglam.KullaniciId], iptal) ?? "";
            await b.CalistirAsync("""
                insert into public.hatirlatma (sahip_id, baslik, notu, zaman, uyar_dk, oncelik, kanal_uygulama,
                                               kaynak, kaynak_id, kaynak_ad, sube_id, ekleyen)
                values (@p0, @p1, @p2, now(), 0, 2, 1, 'basvuru', @p3, @p4, @p5, @p6)
                """, islem,
                [t.OnayId, "Sözlü onayınızla verilen iskonto geri alındı",
                 $"{kim} {t.BelgeNo} başvurusundaki sözlü onaylı iskontoyu geri aldı. Neden: {neden}",
                 t.BelgeId, t.BelgeNo, t.Sube, baglam.KullaniciId], iptal);
        }
        await islem.CommitAsync(iptal);
        return Results.Ok(new { id, izlemeNo = baglam.IzlemeNo });
    }

    /// <summary>
    /// Talebe giren satır sayısı istenenle aynı mı (kod inceleme 18.11.2026): TalepAcAsync belgeye ait olmayan satırı
    /// sessizce atlar - eksikse işlem geri alınır, satırsız talep onaylanıp "uygulandı" bildirimi gitmez.
    /// </summary>
    private static async Task SatirlarTamMiAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction islem, int talepId,
        int beklenen, CancellationToken iptal)
    {
        var giren = await b.TekDegerAsync<long>(
            "select count(*) from public.iskonto_talep_satir where talep_id = @p0", islem, [talepId], iptal);
        if (giren != beklenen)
            throw GentegreHatasi.Dogrulama(
                "Seçilen satırlardan bazıları bu belgeye ait değil ya da kaydedilmemiş; kartı yenileyip yeniden deneyin.",
                new AlanHatasi("kalemler", "Geçersiz satır."));
    }
}
