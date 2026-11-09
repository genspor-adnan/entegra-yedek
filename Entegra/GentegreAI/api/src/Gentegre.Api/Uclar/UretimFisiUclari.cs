using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÜRETİM FİŞİ (1253) + ÜRETİM SEVİYESİ — mockuplar Ekranlar/Uretim/uretim_fisi(.html, _v2.html), uretim_basit.html,
/// uretim_emri_v2.html. Kullanıcı 03.11.2026: "basit / karmaşık planlama yaptığın üretim emri ve üretim fişini
/// mockuplara uygun uygula".
///
/// <para><b>Fiş tek adımlı gerçekleşmiş üretimin kaydıdır.</b> Taslak kaydedilir; <c>Gerçekleştir</c> sarf çıkışı (121),
/// fire çıkışı (123) ve üretim girişini (122) NORMAL BELGE HATTINDAN keser (kaynak_tur 61) ve maliyeti hesaplar.
/// Stok kontrolü, lot / seri, ağırlıklı ortalama aynı yoldan geçer (429 kararı: üretime özel ikinci stok yolu yok).</para>
///
/// <para><b>Maliyet (IAS 2):</b> ana ürün maliyeti = malzeme + işçilik / gider + NORMAL fire − yan ürün (elle değer);
/// ANORMAL fire mamule yüklenmez (dönem gideri), ayrı toplanır. Birim maliyet = ana ürün maliyeti ÷ ana ürün miktarı.
/// Sarf birim maliyeti yönteme göre: son giriş fiyatı ya da ağırlıklı ortalama. Her seviyede aynı hesap.</para>
///
/// <para><b>Seviye</b> (referans uretim.seviye: basit · standart · denetimli) ekranı ve zorunlulukları değiştirir;
/// sunucuda yalnız şu kurallar seviyeye bakar: malzeme eksikken kaydetme (basit uyarıyla, standart yetkiyle, denetimli yok),
/// denetimlide gerçekleşen çıktı KARANTİNADA (durum 2) kalır - kalite kontrol listesi tamam ve parolalı serbest bırakma (durum 3)
/// olmadan satılabilir sayılmaz; emir atölyeye SERBEST BIRAKILMADAN (durum 3, ön kontroller) başlatılamaz.</para>
///
/// <para><b>Silinmez.</b> Gerçekleşmiş fişte Sil = TERS KAYIT: belgeler geri alınır (stok ve lot bakiyesi döner), fiş
/// durum 0 ile iz olarak kalır, emir sayaçları geri alınır. Taslak fiş gerçekten silinir.</para>
/// </summary>
public static partial class UretimFisiUclari
{
    /// <summary>Fiş durumları (db/1253).</summary>
    private const short TersKayit = 0, Taslak = 1, Gerceklesti = 2, Serbest = 3, Reddedildi = 4;

    /// <summary>islem_log.tablo_id - uretim_fisi (998; 993 emir, 990 ağaç ile aynı blok).</summary>
    private const int LogFis = 998;
    private const int LogEmir = 993;

    private const string SeviyeBasit = "basit", SeviyeStandart = "standart", SeviyeDenetimli = "denetimli";

    // ------------------------------------------------------------ istekler ---

    public sealed record FisSatirIstegi(short Grup, int? StokId, int? MasrafId, string? Ad, bool AnaUrun,
                                        decimal BirimIhtiyac, decimal PlanMiktar, decimal Miktar, short Birim,
                                        decimal BirimMaliyet, bool ElleMaliyet, short FireTuru,
                                        JsonElement? Izlemler, string? Aciklama);

    public sealed record FisOperasyonIstegi(string Ad, int? TarafId, int? IsMerkeziId, DateTime? Bas, DateTime? Bit,
                                            decimal MolaDk, decimal SureSaat, decimal Adet, decimal SaatUcreti,
                                            short Durum, string? Aciklama);

    public sealed record FisKontrolIstegi(string Ad, string? Kriter, short Sonuc, string? Notu);

    public sealed record FisIstegi(int StokId, int? AgacId, int? EmirId, decimal Miktar, DateTime? Bas, DateTime? Bit,
                                   int? SarfDepoId, int? GirisDepoId, int? IsMerkeziId, int? SorumluId, int? OnaylayanId,
                                   int? ProjeId, string? PartiNo, short MaliyetYontemi, bool OtomatikHesap, string? Aciklama,
                                   FisSatirIstegi[] Satirlar, FisOperasyonIstegi[]? Operasyonlar, FisKontrolIstegi[]? Kontroller,
                                   /// <summary>Kaydet + Gerçekleştir tek istekte (basit seviyede "Kaydet" bunu yapar).</summary>
                                   bool Gerceklestir,
                                   /// <summary>Malzeme eksikken yine de kaydet (basit: uyarıyla; standart: yetkiyle; denetimli: yok).</summary>
                                   bool EksiyeIzin,
                                   long? Surum);

    public sealed record DoldurIstegi(int StokId, int? AgacId, decimal Miktar, int? SarfDepoId, short? MaliyetYontemi);

    public sealed record GerceklestirIstegi(bool EksiyeIzin);

    public sealed record SerbestIstegi(short Karar, string? Gerekce, string? Parola);

    public sealed record TersIstegi(string? Neden);

    public sealed record SeviyeIstegi(string Seviye, bool EmirKullan);

    public sealed record UretIstegi(decimal Adet, DateTime? Tarih, int? FireStokId, decimal? FireAdet, string? FireNeden,
                                    bool EksiyeIzin, string? Aciklama);

    public sealed record EmirSerbestIstegi(string? Gerekce, string? Parola);

    public static void UretimFisiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/uretim").WithTags("Üretim").RequireAuthorization();

        // ------------------------------------------------------------ seviye ---

        // GET /api/uretim/seviye - ekranın hangi seviyede çizileceği. Üretimi gören herkes okur (ayar yetkisi
        //   gerekmez: fiş kartı açan atölye kullanıcısı o yetkiye sahip değil). `uretim.ayar` Üretim Ayarları sayfası (1262).
        grup.MapGet("/seviye", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("uretim", Islem.Gor) && !baglam.Yetkiler.Var("uretim.fis", Islem.Gor)
                && !baglam.Yetkiler.Var("uretim.ayar", Islem.Gor) && !baglam.Yetkiler.Var("ayar", Islem.Gor))
                throw GentegreHatasi.Yasak();
            await using var b = await veri.AcAsync(iptal);
            var (seviye, emirKullan) = await SeviyeOkuAsync(b, null, iptal);
            return Results.Ok(new { seviye, emirKullan, izlemeNo = baglam.IzlemeNo });
        });

        // PUT /api/uretim/seviye - seviye değişimi. ALTA GEÇİŞ KAPISI (uretim_basit.html ③): açık emir ya da
        //   karantinadaki fiş varken denetimliden inilmez; basite inince emir kullanımı açık kalabilir.
        grup.MapPut("/seviye", async (SeviyeIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Üretim › Ayarlar › Üretim Ayarları (uretim.ayar, 1262) ya da genel ayar yetkisi.
            if (!baglam.Yetkiler.Var("uretim.ayar", Islem.Degistir) && !baglam.Yetkiler.Var("ayar", Islem.Degistir))
                throw GentegreHatasi.Yasak();
            var yeni = (istek.Seviye ?? "").Trim().ToLowerInvariant();
            if (yeni is not (SeviyeBasit or SeviyeStandart or SeviyeDenetimli))
                throw GentegreHatasi.Dogrulama("Seviye basit, standart ya da denetimli olmalı.",
                    new AlanHatasi("seviye", "Geçersiz seviye."));

            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var (eski, eskiEmir) = await SeviyeOkuAsync(b, t, iptal);
            if (Sira(yeni) < Sira(eski))
            {
                var acikEmir = await b.TekDegerAsync<int>(
                    "select count(*) from public.uretim_emri where durum between 1 and 5", t, null, iptal);
                var karantina = await b.TekDegerAsync<int>(
                    "select count(*) from public.uretim_fisi where durum = 2 and seviye = 'denetimli'", t, null, iptal);
                if (acikEmir > 0 || karantina > 0)
                    throw GentegreHatasi.IsKurali(
                        $"Alt seviyeye geçilemez: {acikEmir} açık üretim emri, {karantina} kalite onayı bekleyen fiş var. "
                      + "Önce onları kapatın.");
            }
            // Üst seviyelerde emir hep açık.
            var emirKullan = yeni == SeviyeBasit ? istek.EmirKullan : true;
            await b.CalistirAsync("""
                insert into public.referans (anahtar, deger, tip, kapsam, aciklama, degistiren, degistirme_tarihi)
                values ('uretim.seviye', @p0, 'metin', 'firma', 'Üretim seviyesi', @p2, now()),
                       ('uretim.emir_kullan', @p1, 'metin', 'firma', 'Basit seviyede üretim emri kullan', @p2, now())
                on conflict (anahtar) do update set deger = excluded.deger, degistiren = excluded.degistiren,
                                                    degistirme_tarihi = now()
                """, t, [yeni, emirKullan ? "1" : "0", baglam.KullaniciId], iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogFis, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { ayar = "uretim.seviye", eski, yeni, eskiEmirKullan = eskiEmir, emirKullan }, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { seviye = yeni, emirKullan, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------- mamul ---

        // GET /api/uretim/fis/mamul/{stokId}?depoId= - MAMUL BANDI (cari bandının üretimdeki karşılığı): kod, ad,
        //   birim, izleme, kategori, varsayılan ağaç, depo stokları. Yeni fişte ilk iş mamul seçimidir.
        grup.MapGet("/fis/mamul/{stokId:int}", async (int stokId, int? depoId, BaglamCozucu cozucu, VeriKaynagi veri,
                                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var mamul = await MamulBilgisiAsync(b, null, stokId, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Stok kartı bulunamadı.");
            return Results.Ok(new { mamul, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/fis/doldur - ÜRÜN AĞACINDAN DOLDUR: önerilen satırlar (sarf · işçilik / gider · çıktı), depo
        //   stokları ve eksikler. YAZMAZ - kart satırları ekranda düzenler, kaydı ayrı. Ağaç verilmezse mamulün aktif
        //   varsayılanı; fire oranı tanımlıysa sarf miktarına eklenir (plan = miktar × birim ihtiyaç × (1 + fire%)).
        grup.MapPost("/fis/doldur", async (DoldurIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                           HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Gor);
            if (istek.Miktar <= 0)
                throw GentegreHatasi.Dogrulama("Miktar sıfırdan büyük olmalı.", new AlanHatasi("miktar", "Sıfırdan büyük olmalı."));
            await using var b = await veri.AcAsync(iptal);
            var sonuc = await AgactanDoldurAsync(b, null, istek.StokId, istek.AgacId, istek.Miktar, istek.SarfDepoId,
                                                 istek.MaliyetYontemi ?? 2, iptal);
            return Results.Ok(new { sonuc.Agac, satirlar = sonuc.Satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // --------------------------------------------------------------- fiş ---

        // GET /api/uretim/fis/{id}
        grup.MapGet("/fis/{id:int}", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var fis = await FisOkuAsync(b, null, id, iptal);
            return Results.Ok(new { fis = fis.Fis, satirlar = fis.Satirlar, operasyonlar = fis.Operasyonlar,
                                    kontroller = fis.Kontroller, belgeler = fis.Belgeler, emir = fis.Emir,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/fis - yeni fiş (taslak; `gerceklestir` ile tek adımda stoğa işlenir).
        grup.MapPost("/fis", async (FisIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, BelgeDeposu belgeDepo,
                                    LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Ekle);
            FisDogrula(istek);

            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);

            var (seviye, _) = await SeviyeOkuAsync(b, t, iptal);
            var agac = await AgacIziAsync(b, t, istek.AgacId, istek.StokId, iptal);
            var no = await b.TekDegerAsync<string>("select public.fn_uretim_fisi_no(@p0, @p1::date)", t,
                [baglam.SubeId ?? 0, (istek.Bas ?? Saat.Simdi).Date], iptal) ?? "";

            var id = await b.TekDegerAsync<int>("""
                insert into public.uretim_fisi
                       (no, durum, seviye, stok_id, agac_id, agac_surum, emir_id, miktar, birim, bas, bit,
                        sarf_depo_id, giris_depo_id, is_merkezi_id, sorumlu_id, onaylayan_id, proje_id, parti_no,
                        maliyet_yontemi, otomatik_hesap, aciklama, sube_id, ekleyen)
                values (@p0, 1, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9,
                        @p10, @p11, @p12, @p13, @p14, @p15, @p16,
                        @p17, @p18, @p19, @p20, @p21)
                returning id
                """, t,
                [no, seviye, istek.StokId, agac?.Id, (short)(agac?.Surum ?? 0), istek.EmirId, istek.Miktar,
                 (short)(agac?.Birim ?? 0), istek.Bas ?? Saat.Simdi, istek.Bit,
                 istek.SarfDepoId ?? agac?.SarfDepoId, istek.GirisDepoId ?? agac?.MamulDepoId ?? istek.SarfDepoId,
                 istek.IsMerkeziId, istek.SorumluId, istek.OnaylayanId, istek.ProjeId, istek.PartiNo ?? "",
                 istek.MaliyetYontemi == 1 ? (short)1 : (short)2, (short)(istek.OtomatikHesap ? 1 : 0),
                 istek.Aciklama ?? "", baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

            await SatirlariYazAsync(b, t, id, istek, baglam.KullaniciId, iptal);

            var fisSatir = await b.TekAsync("select * from public.uretim_fisi where id = @p0", t, [id],
                OkuyucuGenisletmeleri.Sozluk, iptal);
            var bilgi = fisSatir?.ToDictionary(x => x.Key, x => (object?)LogDeposu.Metin(x.Value)) ?? new();
            bilgi["__detaylar"] = new { satir = istek.Satirlar.Length, operasyon = istek.Operasyonlar?.Length ?? 0 };
            await log.YazAsync(b, t, LogIslemi.Ekle, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi,
                stokId: istek.StokId, iptal: iptal);

            List<string> uyarilar = [];
            if (istek.Gerceklestir)
                uyarilar = await GerceklestirAsync(b, t, belgeDepo, log, baglam, id, istek.EksiyeIzin, iptal);

            await t.CommitAsync(iptal);
            return Results.Ok(new { id, no, uyarilar, mesaj = istek.Gerceklestir ? $"{no} kaydedildi ve stoğa işlendi." : $"{no} taslak kaydedildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // PUT /api/uretim/fis/{id} - yalnız TASLAK düzenlenir (gerçekleşmiş fiş değişmez - ters kayıt + yeni fiş).
        grup.MapPut("/fis/{id:int}", async (int id, FisIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, BelgeDeposu belgeDepo,
                                            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Degistir);
            FisDogrula(istek);

            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var bas = await BaslikOkuAsync(b, t, id, iptal, kilitle: true);
            if (bas.Durum != Taslak)
                throw GentegreHatasi.IsKurali("Gerçekleşmiş fiş değiştirilemez; düzeltme için Ters Kayıt alıp yeni fiş kesin.");
            if (istek.Surum is { } s && s != bas.Surum)
                throw GentegreHatasi.Cakisma(await FisOkuAsync(b, t, id, iptal));

            var eski = await b.TekAsync("select * from public.uretim_fisi where id = @p0", t, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var agac = await AgacIziAsync(b, t, istek.AgacId, istek.StokId, iptal);
            await b.CalistirAsync("""
                update public.uretim_fisi
                   set stok_id = @p1, agac_id = @p2, agac_surum = @p3, emir_id = @p4, miktar = @p5, birim = @p6,
                       bas = @p7, bit = @p8, sarf_depo_id = @p9, giris_depo_id = @p10, is_merkezi_id = @p11,
                       sorumlu_id = @p12, onaylayan_id = @p13, proje_id = @p14, parti_no = @p15, maliyet_yontemi = @p16,
                       otomatik_hesap = @p17, aciklama = @p18, degistiren = @p19, degistirme_tarihi = now()
                 where id = @p0
                """, t,
                [id, istek.StokId, agac?.Id, (short)(agac?.Surum ?? 0), istek.EmirId, istek.Miktar, (short)(agac?.Birim ?? 0),
                 istek.Bas ?? Saat.Simdi, istek.Bit, istek.SarfDepoId ?? agac?.SarfDepoId,
                 istek.GirisDepoId ?? agac?.MamulDepoId ?? istek.SarfDepoId, istek.IsMerkeziId, istek.SorumluId,
                 istek.OnaylayanId, istek.ProjeId, istek.PartiNo ?? "", istek.MaliyetYontemi == 1 ? (short)1 : (short)2,
                 (short)(istek.OtomatikHesap ? 1 : 0), istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            await b.CalistirAsync("delete from public.uretim_fisi_satir where fis_id = @p0", t, [id], iptal);
            await b.CalistirAsync("delete from public.uretim_fisi_operasyon where fis_id = @p0", t, [id], iptal);
            await b.CalistirAsync("delete from public.uretim_fisi_kontrol where fis_id = @p0", t, [id], iptal);
            await SatirlariYazAsync(b, t, id, istek, baglam.KullaniciId, iptal);

            var yeni = await b.TekAsync("select * from public.uretim_fisi where id = @p0", t, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            var fark = eski is null || yeni is null ? null : LogDeposu.Fark(eski, yeni);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                fark is not null ? fark : new { satirlar = istek.Satirlar.Length }, stokId: istek.StokId, iptal: iptal);

            List<string> uyarilar = [];
            if (istek.Gerceklestir)
                uyarilar = await GerceklestirAsync(b, t, belgeDepo, log, baglam, id, istek.EksiyeIzin, iptal);

            await t.CommitAsync(iptal);
            return Results.Ok(new { id, no = bas.No, uyarilar, mesaj = istek.Gerceklestir ? $"{bas.No} stoğa işlendi." : $"{bas.No} kaydedildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/fis/{id}/gerceklestir - taslağı stoğa işle.
        grup.MapPost("/fis/{id:int}/gerceklestir", async (int id, GerceklestirIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                                           BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var uyarilar = await GerceklestirAsync(b, t, belgeDepo, log, baglam, id, istek?.EksiyeIzin ?? false, iptal);
            await t.CommitAsync(iptal);
            var fis = await FisOkuAsync(b, null, id, iptal);
            return Results.Ok(new { id, uyarilar, fis = fis.Fis, mesaj = "Fiş stoğa işlendi.", izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/fis/{id}/ters-kayit - gerçekleşmiş fişin stok etkisini geri al (Sil'in karşılığı).
        //   Belgeler BelgeDeposu.SilAsync ile kaldırılır (stok ve lot bakiyesi döner); fiş durum 0 ile iz kalır.
        //   MAMUL STOKTAN ÇIKMIŞSA (satılmış / sarf edilmiş) reddedilir: giriş geri alınırsa bakiye eksiye düşerdi.
        grup.MapPost("/fis/{id:int}/ters-kayit", async (int id, TersIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                                         BelgeDeposu belgeDepo, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);

            var bas = await BaslikOkuAsync(b, null, id, iptal);
            if (bas.Durum is Taslak or TersKayit)
                throw GentegreHatasi.IsKurali(bas.Durum == Taslak ? "Taslak fişte ters kayıt yok - fişi silin." : "Bu fiş zaten ters kayıtla kapatılmış.");
            // 1261: Delphi'den aktarılan fiş TEK belgedir (sarf ve mamul aynı tür-6 belgede); ters kayıt o belgeyi iki kez silmeye
            //   kalkardı. Geri alma belge üzerinden yapılır.
            if (bas.Aktarim)
                throw GentegreHatasi.IsKurali("Delphi'den aktarılan üretim fişi tek belgedir; ters kayıt yapılamaz. Gerekirse belgeyi stok hareketlerinden silin.");
            var (seviye, _) = await SeviyeOkuAsync(b, null, iptal);
            if (seviye == SeviyeDenetimli && string.IsNullOrWhiteSpace(istek?.Neden))
                throw GentegreHatasi.Dogrulama("Ters kayıt gerekçesi zorunlu.", new AlanHatasi("neden", "Gerekçe yazılmalı."));

            // Çıktı hâlâ stokta mı? (giriş deposunda mamul ve yan ürün kalanı üretilen kadar olmalı)
            var ciktilar = await b.ListeAsync("""
                select s.stok_id, s.miktar, coalesce(d.kalan, 0), st.ad
                  from public.uretim_fisi_satir s
                  join public.uretim_fisi f on f.id = s.fis_id
                  join public.stok st on st.id = s.stok_id
                  left join public.stok_durum d on d.stok_id = s.stok_id and d.depo_id = f.giris_depo_id
                 where s.fis_id = @p0 and s.grup = 4 and s.stok_id is not null
                """, null, [id], o => new { StokId = o.GetInt32(0), Miktar = o.GetDecimal(1), Kalan = o.GetDecimal(2), Ad = o.GetString(3) }, iptal);
            var eksik = ciktilar.FirstOrDefault(c => c.Kalan + 0.0001m < c.Miktar);
            if (eksik is not null)
                throw GentegreHatasi.IsKurali($"{eksik.Ad}: üretilen {eksik.Miktar:0.##} adedin depoda {eksik.Kalan:0.##} kaldı - mamul stoktan çıkmış, ters kayıt yapılamaz. Önce o hareketi geri alın.");

            // Belgeler kendi işlemlerinde silinir (SilAsync kendi transaction'ını açar). Fişin belge bağları (FK) ÖNCE
            //   kaldırılır - yoksa belge silinemez; silme yarıda kalırsa bağlar geri yazılır, belge kimlikleri log'da kalır.
            await b.CalistirAsync("update public.uretim_fisi set sarf_belge_id = null, giris_belge_id = null, fire_belge_id = null where id = @p0",
                null, [id], iptal);
            var silinen = new List<string>();
            try
            {
                foreach (var belgeId in new[] { bas.GirisBelgeId, bas.FireBelgeId, bas.SarfBelgeId })
                    if (belgeId is > 0)
                        silinen.Add(await belgeDepo.SilAsync(belgeId.Value, baglam.Yazma, iptal));
            }
            catch
            {
                // Silinmemiş belgelerin bağı geri yazılır (silinen zaten yok).
                var kalanGiris = silinen.Count >= 1 ? null : bas.GirisBelgeId;
                var kalanFire = silinen.Count >= (bas.GirisBelgeId is > 0 ? 2 : 1) ? null : bas.FireBelgeId;
                await b.CalistirAsync("update public.uretim_fisi set sarf_belge_id = @p1, giris_belge_id = @p2, fire_belge_id = @p3 where id = @p0",
                    null, [id, bas.SarfBelgeId, kalanGiris, kalanFire], iptal);
                throw;
            }

            await using var t = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                update public.uretim_fisi
                   set durum = 0, ters_an = now(), ters_kullanici_id = @p1, ters_neden = @p2,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, t, [id, baglam.KullaniciId, istek?.Neden ?? ""], iptal);
            if (bas.EmirId is > 0)
                await EmirSayacAsync(b, t, bas.EmirId.Value, id, geri: true, baglam.KullaniciId, iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { tersKayit = true, eskiDurum = bas.Durum, neden = istek?.Neden ?? "", belge = silinen.Count,
                      sarfBelgeId = bas.SarfBelgeId, girisBelgeId = bas.GirisBelgeId, fireBelgeId = bas.FireBelgeId }, stokId: bas.StokId, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { id, durum = TersKayit, mesaj = $"{bas.No} ters kayıtla kapatıldı; {silinen.Count} belge geri alındı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // DELETE /api/uretim/fis/{id} - yalnız TASLAK silinir.
        grup.MapDelete("/fis/{id:int}", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
                                               HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var bas = await BaslikOkuAsync(b, t, id, iptal, kilitle: true);
            if (bas.Durum != Taslak)
                throw GentegreHatasi.IsKurali("Gerçekleşmiş fiş silinmez; stok etkisini kaldırmak için Ters Kayıt kullanın.");
            var eski = await b.TekAsync("select * from public.uretim_fisi where id = @p0", t, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            await log.YazAsync(b, t, LogIslemi.Sil, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                eski?.ToDictionary(x => x.Key, x => (object?)LogDeposu.Metin(x.Value)), stokId: bas.StokId, iptal: iptal);
            await b.CalistirAsync("delete from public.uretim_fisi where id = @p0", t, [id], iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { silindi = true, izlemeNo = baglam.IzlemeNo });
        });

        // PUT /api/uretim/fis/{id}/operasyon - operasyon / personel satırları (gerçekleşmiş fişte de yazılır: süre
        //   kaydı maliyete DEĞMEZ, yalnız kayıttır; işçiliğe aktarma taslakta).
        grup.MapPut("/fis/{id:int}/operasyon", async (int id, FisOperasyonIstegi[] satirlar, BaglamCozucu cozucu, VeriKaynagi veri,
                                                       LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var bas = await BaslikOkuAsync(b, t, id, iptal, kilitle: true);
            if (bas.Durum == TersKayit) throw GentegreHatasi.IsKurali("Ters kayıtla kapanmış fişe operasyon yazılmaz.");
            await b.CalistirAsync("delete from public.uretim_fisi_operasyon where fis_id = @p0", t, [id], iptal);
            await OperasyonlariYazAsync(b, t, id, satirlar, baglam.KullaniciId, iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { operasyon = satirlar.Length }, iptal: iptal);
            await t.CommitAsync(iptal);
            var fis = await FisOkuAsync(b, null, id, iptal);
            return Results.Ok(new { operasyonlar = fis.Operasyonlar, izlemeNo = baglam.IzlemeNo });
        });

        // PUT /api/uretim/fis/{id}/kontrol - kalite kontrol listesi (denetimli): sonuçlar yazılır, yapan / zaman damgalanır.
        grup.MapPut("/fis/{id:int}/kontrol", async (int id, FisKontrolIstegi[] satirlar, BaglamCozucu cozucu, VeriKaynagi veri,
                                                     LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var bas = await BaslikOkuAsync(b, t, id, iptal, kilitle: true);
            if (bas.Durum is TersKayit or Serbest)
                throw GentegreHatasi.IsKurali("Serbest bırakılmış ya da ters kayıtlı fişin kontrol listesi değiştirilmez.");
            var eskiler = await b.ListeAsync("select ad, sonuc, yapan_id, zaman from public.uretim_fisi_kontrol where fis_id = @p0", t, [id],
                o => new { Ad = o.GetString(0), Sonuc = o.GetInt16(1), Yapan = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                           Zaman = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3) }, iptal);
            await b.CalistirAsync("delete from public.uretim_fisi_kontrol where fis_id = @p0", t, [id], iptal);
            var sira = 0;
            foreach (var k in satirlar)
            {
                if (string.IsNullOrWhiteSpace(k.Ad)) continue;
                // Sonuç değişmediyse eski imza korunur; değiştiyse bu kullanıcı ve şimdi.
                var eski = eskiler.FirstOrDefault(e => e.Ad == k.Ad.Trim());
                var ayni = eski is not null && eski.Sonuc == k.Sonuc;
                await b.CalistirAsync("""
                    insert into public.uretim_fisi_kontrol (fis_id, sira, ad, kriter, sonuc, yapan_id, zaman, notu, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
                    """, t, [id, ++sira, k.Ad.Trim(), k.Kriter ?? "", k.Sonuc is 1 or 2 ? k.Sonuc : (short)0,
                             k.Sonuc == 0 ? null : ayni ? eski!.Yapan : baglam.KullaniciId,
                             k.Sonuc == 0 ? null : ayni ? eski!.Zaman : Saat.Simdi, k.Notu ?? "", baglam.KullaniciId], iptal);
            }
            await log.YazAsync(b, t, LogIslemi.Degistir, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { kontrol = satirlar.Length, uygun = satirlar.Count(x => x.Sonuc == 1), uygunsuz = satirlar.Count(x => x.Sonuc == 2) }, iptal: iptal);
            await t.CommitAsync(iptal);
            var fis = await FisOkuAsync(b, null, id, iptal);
            return Results.Ok(new { kontroller = fis.Kontroller, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/fis/{id}/serbest - KALİTE SERBEST BIRAKMA / RET (denetimli; e-imza = parola tekrarı + gerekçe +
        //   anlam, 21 CFR Part 11 §11.50). Karar 1 serbest: bütün kontroller uygun olmalı; 2 ret: gerekçe zorunlu.
        grup.MapPost("/fis/{id:int}/serbest", async (int id, SerbestIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                                      KullaniciDeposu kullanicilar, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis.serbest", Islem.Degistir);
            if (istek.Karar is not (1 or 2))
                throw GentegreHatasi.Dogrulama("Karar serbest (1) ya da ret (2) olmalı.", new AlanHatasi("karar", "Geçersiz karar."));
            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.", new AlanHatasi("gerekce", "Gerekçe yazılmalı."));
            await ParolaDogrulaAsync(kullanicilar, baglam.KullaniciId, istek.Parola, iptal);

            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var bas = await BaslikOkuAsync(b, t, id, iptal, kilitle: true);
            if (bas.Durum != Gerceklesti)
                throw GentegreHatasi.IsKurali("Yalnız gerçekleşmiş (kalite bekleyen) fiş serbest bırakılır ya da reddedilir.");
            if (istek.Karar == 1)
            {
                var bekleyen = await b.TekDegerAsync<int>(
                    "select count(*) from public.uretim_fisi_kontrol where fis_id = @p0 and sonuc <> 1", t, [id], iptal);
                if (bekleyen > 0)
                    throw GentegreHatasi.IsKurali($"{bekleyen} kontrol bekliyor ya da uygunsuz - serbest bırakılamaz.");
            }
            var yeniDurum = istek.Karar == 1 ? Serbest : Reddedildi;
            await b.CalistirAsync("""
                update public.uretim_fisi
                   set durum = @p1, serbest_an = now(), serbest_kullanici_id = @p2, serbest_gerekce = @p3,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, t, [id, yeniDurum, baglam.KullaniciId, istek.Gerekce!.Trim()], iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogFis, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { eImza = true, anlam = istek.Karar == 1 ? "kalite serbest bırakma" : "kalite ret / uygunsuzluk",
                      durum = yeniDurum, gerekce = istek.Gerekce.Trim() }, stokId: bas.StokId, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { id, durum = yeniDurum, mesaj = istek.Karar == 1 ? "Parti serbest bırakıldı." : "Parti reddedildi (uygunsuz).",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/fis/{id}/gecmis - DENETİM İZİ (islem_log, salt okunur, silinemez).
        grup.MapGet("/fis/{id:int}/gecmis", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select g.tarih, coalesce(k.ad, ''), g.islem_tipi, coalesce(g.bilgi::text, '')
                  from public.islem_log g
                  left join public.v_kullanici_lookup k on k.id = g.kullanici_id
                 where g.tablo_id = @p1 and g.kayit_id = @p0
                 order by g.tarih desc, g.id desc
                 limit 100
                """, null, [id, LogFis],
                o => new { tarih = o.GetDateTime(0), kullanici = o.GetString(1), islemTipi = (int)o.GetInt16(2), bilgi = o.GetString(3) }, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/fis/{id}/izlenebilirlik - SOY AĞACI (ISO 13485 §7.5.9): çıktı lotları ← girdi lotları, belgeler,
        //   iş merkezi, personel. İleri izleme: çıktı lotunun sonraki çıkış belgeleri (kime satıldı).
        grup.MapGet("/fis/{id:int}/izlenebilirlik", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var bas = await BaslikOkuAsync(b, null, id, iptal);
            const string lotSql = """
                select i.belge_id, st.kod, st.ad, l.lot_no, l.seri_no, l.son_kullanma_tarihi::date, i.adet,
                       coalesce((select tb.unvan from public.taraf tb
                                   join public.belge_satir gs on gs.belge_id = i.belge_id and gs.stok_id = i.stok_id
                                   join public.belge gb on gb.id = (select x.belge_id from public.belge_satir x where x.id = (
                                        select y.id from public.belge_satir y where y.stok_id = i.stok_id and y.id = gs.id limit 1))
                                  where tb.id = gb.taraf_id limit 1), '') as tedarikci
                  from public.stok_izleme i
                  join public.stok st on st.id = i.stok_id
                  join public.stok_seri_lot l on l.id = i.seri_lot_id
                 where i.belge_id = @p0
                   and (@p1 = 0 or sign(coalesce((select bs.miktar from public.belge_satir bs where bs.id = i.belge_satir_id), 0)) = @p1)
                 order by st.kod, l.lot_no
                """;
            // Aktarılan fişte (1261) sarf ve çıktı AYNI belgede: lot satırları belge satırının işaretiyle ayrılır (eksi sarf, artı çıktı).
            var (sarfIsaret, girisIsaret) = bas.Aktarim ? (-1, 1) : (0, 0);
            var girdiler = bas.SarfBelgeId is > 0 ? await b.ListeAsync(lotSql, null, [bas.SarfBelgeId, sarfIsaret], LotSatiri, iptal) : [];
            var fireler = bas.FireBelgeId is > 0 ? await b.ListeAsync(lotSql, null, [bas.FireBelgeId, 0], LotSatiri, iptal) : [];
            var ciktilar = bas.GirisBelgeId is > 0 ? await b.ListeAsync(lotSql, null, [bas.GirisBelgeId, girisIsaret], LotSatiri, iptal) : [];
            // İLERİ İZLEME: çıktı lotunun sonraki çıkış hareketleri (satış irsaliyesi / faturası, sarf).
            var ileri = bas.GirisBelgeId is > 0 ? await b.ListeAsync("""
                select b.id, b.tur, t.ad, b.belge_tarihi, coalesce(b.belge_no, ''), coalesce(b.taraf_unvan, ''), i.adet, l.lot_no, l.seri_no
                  from public.stok_izleme g
                  join public.stok_izleme i on i.seri_lot_id = g.seri_lot_id and i.belge_id <> g.belge_id and i.ekleme_tarihi >= g.ekleme_tarihi
                  join public.stok_seri_lot l on l.id = i.seri_lot_id
                  join public.belge b on b.id = i.belge_id
                  left join public.kasa_islem_turu t on t.kod = b.tur
                 where g.belge_id = @p0
                 order by b.belge_tarihi, b.id
                 limit 100
                """, null, [bas.GirisBelgeId],
                o => new { belgeId = o.GetInt32(0), tur = (int)o.GetInt16(1), turAdi = o.IsDBNull(2) ? "" : o.GetString(2),
                           tarih = o.GetDateTime(3), belgeNo = o.GetString(4), taraf = o.GetString(5), miktar = o.GetDecimal(6),
                           lotNo = o.GetString(7), seriNo = o.GetString(8) }, iptal) : [];
            var personel = await b.ListeAsync("""
                select distinct coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), ''), coalesce(im.ad, ''), o.ad
                  from public.uretim_fisi_operasyon o
                  left join public.taraf p on p.id = o.taraf_id
                  left join public.is_merkezi im on im.id = o.is_merkezi_id
                 where o.fis_id = @p0
                """, null, [id], o => new { personel = o.GetString(0), isMerkezi = o.GetString(1), operasyon = o.GetString(2) }, iptal);
            return Results.Ok(new { girdiler, fireler, ciktilar, ileri, personel, izlemeNo = baglam.IzlemeNo });
        });

        OzetUclari(grup);
        EmirUclari(grup);
    }

    // ======================================================================
    //  YARDIMCILAR
    // ======================================================================

    private static int Sira(string s) => s switch { SeviyeDenetimli => 3, SeviyeStandart => 2, _ => 1 };

    /// <summary>Seviye ve emir kullanımı (referans). Boş = basit; üst seviyede emir hep açık.</summary>
    internal static async Task<(string Seviye, bool EmirKullan)> SeviyeOkuAsync(NpgsqlConnection b, NpgsqlTransaction? t, CancellationToken iptal)
    {
        var seviye = (await AyarDeposu.MetinAsync(b, t, "uretim.seviye", SeviyeBasit, iptal)).Trim().ToLowerInvariant();
        if (seviye is not (SeviyeBasit or SeviyeStandart or SeviyeDenetimli)) seviye = SeviyeBasit;
        var emir = (await AyarDeposu.MetinAsync(b, t, "uretim.emir_kullan", "0", iptal)).Trim();
        return (seviye, seviye != SeviyeBasit || emir == "1");
    }

    /// <summary>E-imza: parola tekrarı (Part 11 §11.200 - bilinen bileşen). Yanlışsa 400; hesabın kilit sayacına dokunmaz.</summary>
    internal static async Task ParolaDogrulaAsync(KullaniciDeposu kullanicilar, int kullaniciId, string? parola, CancellationToken iptal)
    {
        if (string.IsNullOrEmpty(parola))
            throw GentegreHatasi.Dogrulama("İmza için parolanızı yazın.", new AlanHatasi("parola", "Parola gerekli."));
        var k = await kullanicilar.IdIleBulAsync(kullaniciId, iptal) ?? throw GentegreHatasi.Yetkisiz();
        if (k.ParolaHash.Length == 0 || !BCrypt.Net.BCrypt.Verify(parola, k.ParolaHash))
            throw GentegreHatasi.Dogrulama("Parola doğrulanamadı; imza atılmadı.", new AlanHatasi("parola", "Parola hatalı."));
    }

    private static void FisDogrula(FisIstegi istek)
    {
        if (istek.StokId <= 0) throw GentegreHatasi.Dogrulama("Mamul seçilmeli.", new AlanHatasi("stokId", "Mamul seçin."));
        if (istek.Miktar <= 0) throw GentegreHatasi.Dogrulama("Miktar sıfırdan büyük olmalı.", new AlanHatasi("miktar", "Sıfırdan büyük olmalı."));
        var ana = istek.Satirlar.Where(s => s.Grup == 4 && s.AnaUrun).ToList();
        if (ana.Count > 1) throw GentegreHatasi.Dogrulama("Fişte tek ana ürün olur.", new AlanHatasi("satirlar", "Birden çok ana ürün."));
        foreach (var (s, i) in istek.Satirlar.Select((s, i) => (s, i)))
        {
            if (s.Grup is not (1 or 2 or 3 or 4))
                throw GentegreHatasi.Dogrulama($"{i + 1}. satırın grubu geçersiz.", new AlanHatasi($"satirlar[{i}].grup", "1-4 arası."));
            if (s.Grup != 2 && s.StokId is not > 0)
                throw GentegreHatasi.Dogrulama($"{i + 1}. satırda stok seçilmeli.", new AlanHatasi($"satirlar[{i}].stokId", "Stok seçin."));
            if (s.Grup == 2 && string.IsNullOrWhiteSpace(s.Ad) && s.MasrafId is not > 0)
                throw GentegreHatasi.Dogrulama($"{i + 1}. satır (gider) adsız.", new AlanHatasi($"satirlar[{i}].ad", "Gider adı ya da masraf kalemi."));
            if (s.Miktar < 0)
                throw GentegreHatasi.Dogrulama($"{i + 1}. satırda miktar eksi olamaz.", new AlanHatasi($"satirlar[{i}].miktar", "Eksi olamaz."));
        }
    }
}
