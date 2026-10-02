using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// YZ KONTÖR &amp; KULLANIM (934; mockup Ekranlar/Ayarlar/yz_kontor_kullanim.html).
///
/// Özet göstergeler, hareketler, kullanıcıya göre kullanım, kurum ayarları ve
/// KONTÖR SATIN ALMA (kullanıcı: "KK girip benden kontör alabilecek müşteri").
///
/// <b>KART VERİSİ BU SUNUCUYA GELMEZ.</b> Sipariş oluşturulur, müşteri ödeme
/// kuruluşunun formunda öder, kuruluş imzalı bildirimle (webhook) sonucu
/// yollar; kontör YALNIZ <see cref="SiparisSonuclandirAsync"/> ile yüklenir.
/// <c>Odeme:Saglayici</c>: "iyzico" (Ödeme Formu; <see cref="Servisler.IyzicoIstemcisi"/>;
/// tarayıcı <c>/iyzico/donus</c>'a döner, sonuç iyzico'ya SORULUR) ya da
/// "simulasyon" (varsayılan; kart yok, sonuç ekrandan seçilir).
/// </summary>
public static class AiKontorUclari
{
    private const decimal KdvOrani = 0.20m;

    public sealed record AyarIstegi(int? GunlukSinir, int? KullaniciGunlukSinir, decimal? UyariEsigi,
        bool? ModelAktif, bool? OzRehber, bool? OzTani, bool? OzTetkik, bool? OzIlac, string? OtomatikEkPaket);
    public sealed record FaturaBilgisi(string? Unvan, string? Vkn, string? VergiDairesi, string? Adres, string? Eposta,
                                       string? Il = null);
    public sealed record SiparisIstegi(string Tur, string Kod, int? DonemAy, FaturaBilgisi? Fatura);
    public sealed record SimulasyonIstegi(bool Basarili);

    private sealed record SiparisSatiri(long Id, short Tur, int? PlanId, short DonemAy, int Kontor, short Durum);

    private static string OdemeSaglayici(IConfiguration c) => c["Odeme:Saglayici"] ?? "simulasyon";

    public static void AiKontorUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ai/kontor").WithTags("YZ Kontör").RequireAuthorization();

        // GET /api/ai/kontor/ozet - göstergeler + 30 günlük seri + bu ay özellik dağılımı + plan.
        grup.MapGet("/ozet", async (BaglamCozucu cozucu, VeriKaynagi veri, Servisler.IModelSaglayici model,
            Servisler.ModelSecenekleri ayar, IConfiguration config, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.kontor", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var k = await b.TekAsync("""
                select k.bakiye, k.cagri_ucreti, k.uyari_esigi, k.model_aktif, k.gunluk_cagri_siniri,
                       k.kullanici_gunluk_siniri, k.oz_rehber, k.oz_tani, k.oz_tetkik, k.oz_ilac, k.otomatik_ek_paket,
                       (select count(*) from public.ai_kontor_hareket h where h.tur = 2 and h.basarili = 1 and h.tarih >= current_date),
                       (select coalesce(sum(h.miktar), 0) from public.ai_kontor_hareket h where h.tur = 2 and h.tarih >= current_date),
                       (select coalesce(sum(h.miktar), 0) from public.ai_kontor_hareket h
                         where h.tur = 2 and h.tarih >= date_trunc('month', now())),
                       (select coalesce(sum(h.miktar), 0) from public.ai_kontor_hareket h
                         where h.tur = 2 and h.tarih >= date_trunc('month', now()) - interval '1 month'
                           and h.tarih < date_trunc('month', now())),
                       (select count(*) from public.ai_kontor_hareket h
                         where h.tur = 2 and h.basarili = 0 and h.tarih >= date_trunc('month', now()))
                  from public.ai_kontor k where k.id = 1
                """, null, [], o => new
                {
                    bakiye = o.GetDecimal(0), cagriUcreti = o.GetDecimal(1), uyariEsigi = o.GetDecimal(2),
                    modelAktif = o.GetInt16(3) == 1, gunlukSinir = o.GetInt32(4), kullaniciGunlukSinir = o.GetInt32(5),
                    ozRehber = o.GetInt16(6) == 1, ozTani = o.GetInt16(7) == 1, ozTetkik = o.GetInt16(8) == 1,
                    ozIlac = o.GetInt16(9) == 1, otomatikEkPaket = o.GetString(10),
                    bugunCagri = o.GetInt64(11), bugunKontor = o.GetDecimal(12),
                    buAy = o.GetDecimal(13), gecenAy = o.GetDecimal(14), basarisizAy = o.GetInt64(15),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi();

            var sureler = await b.ListeAsync("""
                select ozellik, round(avg(sure_ms))::int from public.ai_kontor_hareket
                 where tur = 2 and basarili = 1 and sure_ms is not null and ozellik <> ''
                   and tarih >= date_trunc('month', now())
                 group by ozellik
                """, null, [], o => new { ozellik = o.GetString(0), ortalamaMs = o.GetInt32(1) }, iptal);
            var seri = await b.ListeAsync("""
                select g::date, h.ozellik, count(h.id)::int
                  from generate_series(current_date - 29, current_date, interval '1 day') g
                  left join public.ai_kontor_hareket h
                    on h.tur = 2 and h.basarili = 1 and h.tarih::date = g::date and h.ozellik <> ''
                 group by g, h.ozellik order by g
                """, null, [], o => new { gun = o.GetDateTime(0).ToString("yyyy-MM-dd"),
                                           ozellik = o.IsDBNull(1) ? "" : o.GetString(1), adet = o.GetInt32(2) }, iptal);
            var dagilim = await b.ListeAsync("""
                select ozellik, count(*)::int, coalesce(sum(miktar), 0) from public.ai_kontor_hareket
                 where tur = 2 and basarili = 1 and ozellik <> '' and tarih >= date_trunc('month', now())
                 group by ozellik
                """, null, [], o => new { ozellik = o.GetString(0), cagri = o.GetInt32(1), kontor = o.GetDecimal(2) }, iptal);

            return Results.Ok(new
            {
                kontor = k, sureler, seri, dagilim,
                abonelik = await AbonelikAsync(b, iptal),
                saglayici = new
                {
                    tur = ayar.Saglayici, model = model.Ad, hazir = model.Hazir, akilYurutme = ayar.AkilYurutme,
                    zamanAsimiSn = ayar.ZamanAsimiSn,
                    adres = Uri.TryCreate(ayar.Uc, UriKind.Absolute, out var u) ? u.Host : "",
                    test = !string.Equals(ayar.Saglayici, "anthropic", StringComparison.OrdinalIgnoreCase),
                },
                odemeSaglayici = OdemeSaglayici(config),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // GET /api/ai/kontor/hareketler?tur=&ozellik=&gun=
        grup.MapGet("/hareketler", async (short? tur, string? ozellik, int? gun, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.kontor", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select h.id, h.tarih, h.tur, h.ozellik, h.muayene_id, coalesce(k.ad, ''), h.jeton, h.sure_ms,
                       h.miktar, h.bakiye, h.aciklama, h.basarili, h.siparis_id
                  from public.ai_kontor_hareket h
                  left join public.v_kullanici_lookup k on k.id = h.kullanici_id
                 where (@p0::smallint is null or h.tur = @p0)
                   and (@p1 = '' or h.ozellik = @p1)
                   and h.tarih >= now() - make_interval(days => @p2)
                 order by h.tarih desc, h.id desc
                 limit 500
                """, null, [tur, ozellik ?? "", Math.Clamp(gun ?? 30, 1, 3650)], o => new
                {
                    id = o.GetInt64(0), tarih = o.GetDateTime(1), tur = (int)o.GetInt16(2), ozellik = o.GetString(3),
                    muayeneId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), kullanici = o.GetString(5),
                    jeton = o.GetInt32(6), sureMs = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                    miktar = o.GetDecimal(8), bakiye = o.GetDecimal(9), aciklama = o.GetString(10),
                    basarili = o.GetInt16(11) == 1, siparisId = o.IsDBNull(12) ? (long?)null : o.GetInt64(12),
                }, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/ai/kontor/kullanicilar?gun=30 - kullanıcıya göre özellik kullanımı.
        grup.MapGet("/kullanicilar", async (int? gun, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.kontor", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select coalesce(k.ad, '—'),
                       count(*) filter (where h.ozellik = 'tani')::int,
                       count(*) filter (where h.ozellik = 'tetkik')::int,
                       count(*) filter (where h.ozellik = 'ilac')::int,
                       count(*) filter (where h.ozellik = 'rehber')::int,
                       coalesce(sum(h.miktar), 0), max(h.tarih)
                  from public.ai_kontor_hareket h
                  left join public.v_kullanici_lookup k on k.id = h.kullanici_id
                 where h.tur = 2 and h.basarili = 1 and h.tarih >= now() - make_interval(days => @p0)
                 group by k.ad
                 order by 6 desc
                """, null, [Math.Clamp(gun ?? 30, 1, 3650)], o => new
                {
                    kullanici = o.GetString(0), tani = o.GetInt32(1), tetkik = o.GetInt32(2), ilac = o.GetInt32(3),
                    rehber = o.GetInt32(4), kontor = o.GetDecimal(5), son = o.GetDateTime(6),
                }, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/ai/kontor/planlar - planlar, ek paketler, mevcut abonelik.
        grup.MapGet("/planlar", async (BaglamCozucu cozucu, VeriKaynagi veri, IConfiguration config,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.kontor", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var planlar = await b.ListeAsync("""
                select kod, ad, aylik_kontor, aylik_fiyat, yillik_fiyat, devreder, one_cikan, ozellikler::text
                  from public.ai_plan where aktif = 1 order by sira, id
                """, null, [], o => new
                {
                    kod = o.GetString(0), ad = o.GetString(1), aylikKontor = o.GetInt32(2), aylikFiyat = o.GetDecimal(3),
                    yillikFiyat = o.GetDecimal(4), devreder = o.GetInt16(5) == 1, oneCikan = o.GetInt16(6) == 1,
                    ozellikler = System.Text.Json.JsonSerializer.Deserialize<string[]>(o.GetString(7)) ?? [],
                }, iptal);
            var paketler = await b.ListeAsync(
                "select kod, kontor, fiyat from public.ai_paket where aktif = 1 order by sira, id", null, [],
                o => new { kod = o.GetString(0), kontor = o.GetInt32(1), fiyat = o.GetDecimal(2) }, iptal);
            return Results.Ok(new
            {
                planlar, paketler, abonelik = await AbonelikAsync(b, iptal), kdvOrani = KdvOrani,
                odemeSaglayici = OdemeSaglayici(config), izlemeNo = baglam.IzlemeNo,
            });
        });

        // GET /api/ai/kontor/siparisler - faturalar ve ödemeler.
        grup.MapGet("/siparisler", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.kontor", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select s.id, s.tarih, s.tur, coalesce(p.ad, ''), coalesce(k.kontor, 0), s.donem_ay, s.kontor,
                       s.toplam, s.durum, s.hata, s.fatura_no, s.odeme_tarihi
                  from public.ai_siparis s
                  left join public.ai_plan p on p.id = s.plan_id
                  left join public.ai_paket k on k.id = s.paket_id
                 order by s.tarih desc limit 200
                """, null, [], o => new
                {
                    id = o.GetInt64(0), tarih = o.GetDateTime(1), tur = (int)o.GetInt16(2),
                    aciklama = o.GetInt16(2) == 2 ? $"Ek paket {o.GetInt32(4):N0}"
                             : $"{o.GetString(3)} · {(o.GetInt16(5) == 12 ? "yıllık" : "aylık")}",
                    kontor = o.GetInt32(6), toplam = o.GetDecimal(7), durum = (int)o.GetInt16(8), hata = o.GetString(9),
                    faturaNo = o.GetString(10), odemeTarihi = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
                }, iptal);
            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // PUT /api/ai/kontor/ayar - kurum ayarları. ÇAĞRI ÜCRETİ SATICININDIR, burada yok.
        grup.MapPut("/ayar", async (AyarIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.kontor", Islem.Degistir);
            if (istek.GunlukSinir is < 0 || istek.KullaniciGunlukSinir is < 0 || istek.UyariEsigi is < 0)
                throw GentegreHatasi.Dogrulama("Sınır ve eşik negatif olamaz.", []);
            if (istek.OtomatikEkPaket is { Length: > 0 } ek
                && await veri.TekDegerAsync<int>("select count(*)::int from public.ai_paket where kod = @p0 and aktif = 1", [ek], iptal) == 0)
                throw GentegreHatasi.Dogrulama("Otomatik ek paket bulunamadı.", []);
            static object? M(bool? v) => v is null ? null : (short)(v.Value ? 1 : 0);
            await veri.CalistirAsync("""
                update public.ai_kontor set
                   gunluk_cagri_siniri     = coalesce(@p0, gunluk_cagri_siniri),
                   kullanici_gunluk_siniri = coalesce(@p1, kullanici_gunluk_siniri),
                   uyari_esigi             = coalesce(@p2, uyari_esigi),
                   model_aktif             = coalesce(@p3::smallint, model_aktif),
                   oz_rehber = coalesce(@p4::smallint, oz_rehber), oz_tani = coalesce(@p5::smallint, oz_tani),
                   oz_tetkik = coalesce(@p6::smallint, oz_tetkik), oz_ilac = coalesce(@p7::smallint, oz_ilac),
                   otomatik_ek_paket       = coalesce(@p8, otomatik_ek_paket),
                   degistirme_tarihi = now()
                 where id = 1
                """, [istek.GunlukSinir, istek.KullaniciGunlukSinir, istek.UyariEsigi, M(istek.ModelAktif),
                      M(istek.OzRehber), M(istek.OzTani), M(istek.OzTetkik), M(istek.OzIlac), istek.OtomatikEkPaket], iptal);
            return Results.Ok(new { mesaj = "YZ ayarları kaydedildi.", izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/ai/kontor/siparis - plan / ek paket siparişi (ödeme BEKLER).
        //   Tutar SUNUCUDA hesaplanır (plan/paket tablosundan); istemci tutar yollamaz.
        grup.MapPost("/siparis", async (SiparisIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            IConfiguration config, Servisler.IyzicoIstemcisi iyzico, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ai.kontor_satin_al");
            var f = istek.Fatura;
            if (string.IsNullOrWhiteSpace(f?.Unvan) || string.IsNullOrWhiteSpace(f?.Vkn) || string.IsNullOrWhiteSpace(f?.Eposta))
                throw GentegreHatasi.Dogrulama("Fatura unvanı, VKN/TCKN ve e-posta zorunlu.",
                    [new("fatura", "Unvan, VKN/TCKN ve e-posta girin.")]);

            await using var b = await veri.AcAsync(iptal);
            int? planId = null, paketId = null;
            short donem = 1, tur;
            int kontor;
            decimal tutar;
            if (istek.Tur == "plan")
            {
                donem = (short)(istek.DonemAy == 12 ? 12 : 1);
                var p = await b.TekAsync(
                    "select id, aylik_kontor, aylik_fiyat, yillik_fiyat from public.ai_plan where kod = @p0 and aktif = 1",
                    null, [istek.Kod], o => new PlanFiyat(o.GetInt32(0), o.GetInt32(1), o.GetDecimal(2), o.GetDecimal(3)), iptal)
                    ?? throw GentegreHatasi.Dogrulama("Plan bulunamadı.", []);
                planId = p.Id; tur = 1;
                kontor = p.AylikKontor * donem;
                tutar = donem == 12 ? p.YillikFiyat : p.AylikFiyat;
            }
            else if (istek.Tur == "paket")
            {
                var p = await b.TekAsync("select id, kontor, fiyat from public.ai_paket where kod = @p0 and aktif = 1",
                    null, [istek.Kod], o => new PaketFiyat(o.GetInt32(0), o.GetInt32(1), o.GetDecimal(2)), iptal)
                    ?? throw GentegreHatasi.Dogrulama("Paket bulunamadı.", []);
                paketId = p.Id; tur = 2; kontor = p.Kontor; tutar = p.Fiyat;
            }
            else throw GentegreHatasi.Dogrulama("Tür 'plan' ya da 'paket' olmalı.", []);

            var kdv = Math.Round(tutar * KdvOrani, 2, MidpointRounding.ToEven);
            var saglayici = OdemeSaglayici(config);
            if (saglayici == "iyzico" && !iyzico.Hazir)
                throw GentegreHatasi.IsKurali("iyzico anahtarları bu kurulumda tanımlı değil; yöneticiye bildirin.");
            var il = string.IsNullOrWhiteSpace(f!.Il) ? "Istanbul" : f.Il.Trim();
            var faturaJson = System.Text.Json.JsonSerializer.Serialize(new
            {
                unvan = f.Unvan!.Trim(), vkn = f.Vkn!.Trim(), vergiDairesi = f.VergiDairesi?.Trim() ?? "",
                adres = f.Adres?.Trim() ?? "", eposta = f.Eposta!.Trim(), il,
            });
            var id = await b.TekDegerAsync<long>("""
                insert into public.ai_siparis (tur, plan_id, paket_id, donem_ay, kontor, tutar, kdv, toplam,
                                               odeme_saglayici, fatura, kullanici_id)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9::jsonb, @p10) returning id
                """, null, [tur, planId, paketId, donem, kontor, tutar, kdv, tutar + kdv, saglayici,
                            faturaJson, baglam.KullaniciId], iptal);

            string? odemeAdresi = null;
            if (saglayici == "iyzico")
            {
                // ALICI: iyzico ad/soyad/kimlik/e-posta/adres/il/ip ister. Ad-soyad siparişi
                //   veren kullanıcının kaydından; kimlik no fatura VKN/TCKN'si. Kart YOK.
                var kul = await b.TekAsync(
                    "select coalesce(nullif(ad, ''), unvan, 'Kullanici'), coalesce(nullif(soyad, ''), '-') from public.taraf where id = @p0",
                    null, [baglam.KullaniciId], o => new AdSoyad(o.GetString(0), o.GetString(1)), iptal)
                    ?? new AdSoyad("Kullanici", "-");
                var urunAdi = tur == 2 ? $"YZ ek paket {kontor:N0} kontör" : $"YZ plan {istek.Kod} ({(donem == 12 ? "yıllık" : "aylık")})";
                var baslat = await iyzico.BaslatAsync(id, tutar + kdv, urunAdi,
                    new Servisler.IyzicoIstemcisi.Alici(
                        "K" + baglam.KullaniciId, kul.Ad, kul.Soyad, new string(f.Vkn!.Where(char.IsDigit).ToArray()),
                        f.Eposta!.Trim(), string.IsNullOrWhiteSpace(f.Adres) ? f.Unvan!.Trim() : f.Adres.Trim(), il,
                        ctx.Connection.RemoteIpAddress?.MapToIPv4().ToString() ?? "127.0.0.1", f.Unvan!.Trim()),
                    tur == 1 && donem == 12 ? [1, 2, 3, 6] : [1], iptal);
                if (!baslat.Basarili)
                {
                    await b.CalistirAsync("update public.ai_siparis set durum = 4, hata = @p1 where id = @p0",
                        null, [id, baslat.Hata.Length > 300 ? baslat.Hata[..300] : baslat.Hata], iptal);
                    throw GentegreHatasi.IsKurali("iyzico ödeme formu açılamadı: " + baslat.Hata);
                }
                // TOKEN siparişte: dönüşte sipariş token'la bulunur, sonuç iyzico'ya SORULUR.
                await b.CalistirAsync("update public.ai_siparis set odeme_referans = @p1 where id = @p0",
                    null, [id, baslat.Token], iptal);
                odemeAdresi = baslat.OdemeSayfasi;
            }
            return Results.Ok(new
            {
                siparisId = id, kontor, tutar, kdv, toplam = tutar + kdv, odemeSaglayici = saglayici,
                odemeAdresi, izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/ai/kontor/siparis/{id}/simulasyon - TEST: webhook'un yerine geçer.
        //   Yalnız Odeme:Saglayici = simulasyon iken açık; kart verisi yok.
        grup.MapPost("/siparis/{id:long}/simulasyon", async (long id, SimulasyonIstegi istek, BaglamCozucu cozucu,
            VeriKaynagi veri, IConfiguration config, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ai.kontor_satin_al");
            if (OdemeSaglayici(config) != "simulasyon")
                throw GentegreHatasi.Yasak("Simülasyon ödeme bu kurulumda kapalı.");
            await using var b = await veri.AcAsync(iptal);
            var sonuc = await SiparisSonuclandirAsync(b, id, istek.Basarili,
                "SIM-" + id.ToString(System.Globalization.CultureInfo.InvariantCulture),
                istek.Basarili ? "4242" : "", istek.Basarili ? "" : "Kart reddedildi (simülasyon: yetersiz bakiye)",
                iptal, istek.Basarili ? "VISA" : "");
            return Results.Ok(new { sonuc.Durum, sonuc.YeniBakiye, sonuc.FaturaNo, sonuc.Mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/ai/kontor/iyzico/donus - iyzico ödeme sonrası TARAYICIYI buraya POST eder
        //   (form alanı "token"). Oturum yok (AllowAnonymous); güven kaynağı token'ın
        //   siparişte kayıtlı olması + sonucun iyzico'ya SORULMASI. Kontör yalnız Dogrula
        //   (durum + sipariş no + tutar + fraud) geçerse yüklenir; sonra kullanıcı ekrana döner.
        grup.MapPost("/iyzico/donus", async (HttpRequest istek, VeriKaynagi veri, Servisler.IyzicoIstemcisi iyzico,
            CancellationToken iptal) =>
        {
            var ekran = iyzico.Ayar.EkranAdresi;
            var token = istek.HasFormContentType ? (await istek.ReadFormAsync(iptal))["token"].ToString() : "";
            if (token.Length == 0) return Results.Redirect($"{ekran}?siparis=0&hata=token");

            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync(
                "select id, toplam from public.ai_siparis where odeme_referans = @p0 and odeme_saglayici = 'iyzico' order by id desc limit 1",
                null, [token], o => new SiparisToplam(o.GetInt64(0), o.GetDecimal(1)), iptal);
            if (s is null) return Results.Redirect($"{ekran}?siparis=0&hata=bulunamadi");

            var sorgu = await iyzico.SorgulaAsync(token, s.Id.ToString(System.Globalization.CultureInfo.InvariantCulture), iptal);
            var (odendi, sebep) = Servisler.IyzicoIstemcisi.Dogrula(sorgu, s.Id, s.Toplam);
            await SiparisSonuclandirAsync(b, s.Id, odendi, sorgu.OdemeNo.Length > 0 ? sorgu.OdemeNo : token,
                sorgu.KartSon4, sebep, iptal, sorgu.KartMarka);
            return Results.Redirect($"{ekran}?siparis={s.Id}");
        }).AllowAnonymous();

        // GET /api/ai/kontor/siparis/{id} - ödeme dönüşünde ekranın sonucu göstermesi için.
        grup.MapGet("/siparis/{id:long}", async (long id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.kontor", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync("""
                select s.durum, s.kontor, s.toplam, s.hata, s.fatura_no,
                       (select bakiye from public.ai_kontor where id = 1)
                  from public.ai_siparis s where s.id = @p0
                """, null, [id], o => new SiparisDurumu((int)o.GetInt16(0), o.GetInt32(1), o.GetDecimal(2),
                                                        o.GetString(3), o.GetString(4), o.GetDecimal(5)), iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new { durum = s.Durum, kontor = s.Kontor, toplam = s.Toplam, hata = s.Hata,
                                    faturaNo = s.FaturaNo, yeniBakiye = s.YeniBakiye, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/ai/kontor/abonelik/iptal - dönem sonunda biter, kontör kalır.
        grup.MapPost("/abonelik/iptal", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ai.kontor_satin_al");
            var n = await veri.CalistirAsync(
                "update public.ai_abonelik set durum = 2, degistirme_tarihi = now() where id = 1 and durum = 1", [], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Aktif abonelik yok.");
            return Results.Ok(new { mesaj = "Abonelik iptal edildi; dönem sonuna kadar kontör kullanılabilir.", izlemeNo = baglam.IzlemeNo });
        });
    }

    private sealed record PlanFiyat(int Id, int AylikKontor, decimal AylikFiyat, decimal YillikFiyat);
    private sealed record AdSoyad(string Ad, string Soyad);
    private sealed record SiparisToplam(long Id, decimal Toplam);
    private sealed record SiparisDurumu(int Durum, int Kontor, decimal Toplam, string Hata, string FaturaNo, decimal YeniBakiye);
    private sealed record PaketFiyat(int Id, int Kontor, decimal Fiyat);
    public sealed record SiparisSonucu(int Durum, decimal YeniBakiye, string FaturaNo, string Mesaj);

    /// <summary>
    /// ÖDEME SONUCUNU İŞLER (webhook / simülasyon ortak). Tek işlem: sipariş
    /// "bekliyor" değilse hiçbir şey yapmaz (aynı bildirim iki kez gelirse
    /// kontör iki kez yüklenmez). Başarılıysa kontör yüklenir (hareket tür 1),
    /// planda abonelik güncellenir.
    /// </summary>
    public static async Task<SiparisSonucu> SiparisSonuclandirAsync(Npgsql.NpgsqlConnection b, long siparisId,
        bool basarili, string odemeReferans, string kartSon4, string hata, CancellationToken iptal,
        string kartMarka = "")
    {
        await using var islem = await b.BeginTransactionAsync(iptal);
        var s = await b.TekAsync(
            "select id, tur, plan_id, donem_ay, kontor, durum from public.ai_siparis where id = @p0 for update",
            islem, [siparisId], o => new SiparisSatiri(o.GetInt64(0), o.GetInt16(1),
                o.IsDBNull(2) ? null : o.GetInt32(2), o.GetInt16(3), o.GetInt32(4), o.GetInt16(5)), iptal)
            ?? throw GentegreHatasi.Bulunamadi();
        var bakiye = await b.TekDegerAsync<decimal>("select bakiye from public.ai_kontor where id = 1", islem, [], iptal);
        if (s.Durum != 1)
        {
            await islem.RollbackAsync(iptal);
            return new SiparisSonucu(s.Durum, bakiye, "", "Sipariş zaten sonuçlanmış.");
        }
        if (!basarili)
        {
            await b.CalistirAsync("""
                update public.ai_siparis set durum = 3, hata = @p1, odeme_referans = @p2 where id = @p0
                """, islem, [siparisId, hata.Length > 300 ? hata[..300] : hata, odemeReferans], iptal);
            await islem.CommitAsync(iptal);
            return new SiparisSonucu(3, bakiye, "", hata.Length > 0 ? hata : "Ödeme alınamadı.");
        }

        var faturaNo = $"GYZ-{DateTime.Now:yyyy}-{siparisId:000000}";
        await b.CalistirAsync("""
            update public.ai_siparis set durum = 2, odeme_tarihi = now(), odeme_referans = @p1, fatura_no = @p2
             where id = @p0
            """, islem, [siparisId, odemeReferans, faturaNo], iptal);
        await b.CalistirAsync(
            "update public.ai_kontor set bakiye = bakiye + @p0, degistirme_tarihi = now() where id = 1",
            islem, [(decimal)s.Kontor], iptal);
        bakiye += s.Kontor;
        await b.CalistirAsync("""
            insert into public.ai_kontor_hareket (tur, miktar, bakiye, aciklama, siparis_id)
            values (1, @p0, @p1, @p2, @p3)
            """, islem, [(decimal)s.Kontor, bakiye,
                         (s.Tur == 2 ? "Ek paket" : "Plan") + $" satın alındı · {faturaNo}", siparisId], iptal);
        if (s.Tur == 1)
            await b.CalistirAsync("""
                update public.ai_abonelik
                   set plan_id = @p0, donem_ay = @p1, donem_baslangic = current_date,
                       sonraki_yenileme = (current_date + make_interval(months => @p1))::date,
                       durum = 1, kart_son4 = @p2,
                       kart_marka = case when @p4 <> '' then replace(@p4, '_', ' ') else kart_marka end,
                       odeme_referans = @p3, degistirme_tarihi = now()
                 where id = 1
                """, islem, [s.PlanId, (int)s.DonemAy, kartSon4, odemeReferans, kartMarka], iptal);
        await islem.CommitAsync(iptal);
        return new SiparisSonucu(2, bakiye, faturaNo, $"{s.Kontor:N0} kontör yüklendi.");
    }

    private static async Task<object?> AbonelikAsync(Npgsql.NpgsqlConnection b, CancellationToken iptal)
        => await b.TekAsync("""
            select a.durum, coalesce(p.kod, ''), coalesce(p.ad, ''), coalesce(p.aylik_kontor, 0), a.donem_ay,
                   a.donem_baslangic, a.sonraki_yenileme, a.kart_son4, a.kart_marka,
                   case when a.donem_ay = 12 then coalesce(p.yillik_fiyat, 0) else coalesce(p.aylik_fiyat, 0) end,
                   coalesce(p.devreder, 0)
              from public.ai_abonelik a left join public.ai_plan p on p.id = a.plan_id
             where a.id = 1
            """, null, [], o => (object)new
            {
                durum = (int)o.GetInt16(0), planKod = o.GetString(1), planAd = o.GetString(2), aylikKontor = o.GetInt32(3),
                donemAy = (int)o.GetInt16(4),
                donemBaslangic = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                sonrakiYenileme = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                kartSon4 = o.GetString(7), kartMarka = o.GetString(8), tutar = o.GetDecimal(9), devreder = o.GetInt16(10) == 1,
            }, iptal);
}
