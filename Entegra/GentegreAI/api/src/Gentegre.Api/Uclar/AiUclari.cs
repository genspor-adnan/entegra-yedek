using System.Diagnostics;
using System.Text;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// YAPAY ZEKA ASİSTANI uçları (341/343) — İletişim &amp; AI › Yapay Zeka.
///
/// Mockup: `Ekranlar/ai_asistan.html`. Mockup'ın kuralı bire bir uygulanır:
///   * Model veritabanına DOĞRUDAN bağlanmaz - veriyi yalnız İZİNLİ
///     FONKSİYONLAR (`ai_arac`) okur ve her fonksiyon çağıranın uygulama
///     yetkisiyle çalışır (yetkisi yoksa çağrı reddedilir).
///   * YAZAN işlem yoktur: görev/e-posta gibi çıktılar `ai_taslak` satırıdır,
///     kayıt ancak kullanıcı ONAYLAYINCA oluşur.
///   * Her çağrı `ai_arac_log`'a yazılır (parametre · kayıt sayısı · süre).
///
/// MODEL BAĞLANTISI henüz yok: serbest metin yanıtı üretilmez, hazır komutlar
/// (fonksiyonlar) doğrudan çalışır. Model kimliği `entegrasyon_hesap` (kod
/// 'AI') üzerinden tanımlanınca serbest sohbet buraya eklenecek - fonksiyon
/// katmanı ve denetim izi o zaman da aynı kalır.
/// </summary>
public static class AiUclari
{
    public sealed record SoruIstegi(string Metin, string? Arac, JsonElement? Parametre,
                                    Dictionary<string, object?>? Baglam);
    public sealed record TaslakIstegi(int TaslakId, bool Iptal);
    public sealed record GizleIstegi(string Kod, bool Gizle);
    public sealed record GeriBildirimIstegi(int MesajId, short Deger);


    public static void AiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ai").WithTags("Yapay Zeka").RequireAuthorization();

        // ---------------------------------------------------------- rehber --
        // POST /api/ai/rehber - "ne nerede, nasil yapilir" (447).
        //
        // FAZ 1: asistan REHBERDIR, operator degil. Bu uc veri yazmaz; katalog
        //   okur ve metin uretir. Yetki sunucuda suzulur: kullanicinin
        //   goremedigi ekran onerilmez, yetkisi olmayan isin adimlari
        //   paylasilmaz.
        grup.MapPost("/rehber", async (
            RehberServisi.Istek istek, RehberServisi rehber, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.rehber", Islem.Gor);

            var yanit = await rehber.CevaplaAsync(istek, baglam, iptal);
            return Results.Ok(new
            {
                yanit.Cevap, yanit.Adimlar, yanit.OnerilenEkranlar,
                yanit.OnerilenAksiyonlar, yanit.GuvenSkoru, yanit.EksikBilgiSorusu,
                yanit.Uyarilar, yanit.KonuKod, yanit.KaynakTuru, yanit.KontorBakiye,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ----------------------------------------------- kontrollu oneri --
        // POST /api/ai/oneri - acik kaydin eksikleri (449, Faz 3).
        //
        // OKUR VE ISARET EDER, YAZMAZ. Her oneri `ai_oneri_kural` satirina
        //   bagli; kural AI'ya yazdirilmaz. Kullanicinin goremedigi kaynagin
        //   onerisi uretilmez.
        grup.MapPost("/oneri", async (
            OneriServisi.Istek istek, OneriServisi oneri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.rehber", Islem.Gor);

            var yanit = await oneri.OnerilerAsync(istek, baglam, iptal);
            return Results.Ok(new
            {
                yanit.Kaynak, yanit.KayitId, yanit.Oneriler,
                yanit.Engel, yanit.Uyari, yanit.Bilgi, izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/ai/oneri/gizle - "bunu bir daha gosterme".
        //   Kural SILINMEZ; yalniz bu kullanici icin susar - on uyari gosteren
        //   asistan kapatilir, ama kuralin kendisi kurumun kurali.
        grup.MapPost("/oneri/gizle", async (
            GizleIstegi istek, OneriServisi oneri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai.rehber", Islem.Gor);

            await oneri.GizleAsync(istek.Kod, istek.Gizle, baglam, iptal);
            return Results.Ok(new { mesaj = istek.Gizle ? "Uyarı gizlendi." : "Uyarı geri açıldı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------- sohbetler --
        grup.MapGet("/sohbetler", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var sohbetler = await baglanti.ListeAsync("""
                select s.id, s.baslik, s.son_tarih as "sonTarih", s.token_toplam as "token",
                       (select count(*) from public.ai_mesaj m where m.sohbet_id = s.id)::int as "mesajSayisi"
                  from public.ai_sohbet s
                 where s.kullanici_id = @p0 and s.durum = 1
                 order by s.son_tarih desc limit 30
                """, null, [baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Araç kataloğu: kullanıcının YETKİSİ OLANLAR (mockup "İzinli
            //   Fonksiyonlar"). Yetkisiz fonksiyonu listede göstermek,
            //   çalışmayacak bir düğme göstermektir.
            var araclar = (await baglanti.ListeAsync("""
                select a.kod, a.ad, a.aciklama, a.yetki_kodu as "yetkiKodu", a.yazar,
                       coalesce(a.kaynak_tablo, '') as "kaynakTablo",
                       coalesce(a.liste_rota, '') as "listeRota",
                       coalesce(a.liste_adi, '') as "listeAdi"
                  from public.ai_arac a where a.aktif = 1 order by a.sira, a.ad
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal))
                .Where(a => baglam.Yetkiler.Var(a["yetkiKodu"]?.ToString() ?? "", Islem.Gor))
                .ToList();

            var bekleyen = await baglanti.TekAsync("""
                select count(*)::int as adet from public.ai_taslak t
                  join public.ai_sohbet s on s.id = t.sohbet_id
                 where s.kullanici_id = @p0 and t.durum = 1
                """, null, [baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { sohbetler, araclar, bekleyenTaslak = bekleyen?["adet"] });
        });

        grup.MapPost("/sohbet", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            var yeni = await baglanti.TekAsync("""
                insert into public.ai_sohbet (kullanici_id) values (@p0) returning id
                """, null, [baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { id = Convert.ToInt32(yeni!["id"]) });
        });

        // ------------------------------------------------------ sohbet akışı -
        grup.MapGet("/{sohbetId:int}", async (
            int sohbetId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var sohbet = await baglanti.TekAsync("""
                select s.id, s.baslik, s.baglam, s.model, s.token_toplam as "token"
                  from public.ai_sohbet s where s.id = @p0 and s.kullanici_id = @p1
                """, null, [sohbetId, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Sohbet bulunamadı.");

            var mesajlar = await baglanti.ListeAsync("""
                select m.id, m.rol, m.metin, m.veri, m.token, m.tarih,
                       m.geribildirim as "geriBildirim"
                  from public.ai_mesaj m where m.sohbet_id = @p0 order by m.tarih, m.id
                """, null, [sohbetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var taslaklar = await baglanti.ListeAsync("""
                select t.id, t.tip, t.baslik, t.icerik, t.durum,
                       t.hedef_modul as "hedefModul", t.hedef_id as "hedefId",
                       t.onay_tarihi as "onayTarihi", t.mesaj_id as "mesajId"
                  from public.ai_taslak t where t.sohbet_id = @p0 order by t.id
                """, null, [sohbetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Denetim izi (mockup sağ panel "AI log"): araç çağrıları.
            var gunluk = await baglanti.ListeAsync("""
                select l.id, l.arac_kod as "aracKod", l.mesaj_id as "mesajId", l.parametre,
                       l.kayit_sayisi as "kayitSayisi", l.sure_ms as "sureMs",
                       l.hata, l.tarih,
                       -- Kaynak ve "listede ac" rotasi (344): kullanici
                       --   asistanin sayisini kendi gozuyle dogrulayabilsin.
                       coalesce(a.kaynak_tablo, '') as "kaynakTablo",
                       coalesce(a.liste_rota, '') as "listeRota",
                       coalesce(a.liste_adi, '') as "listeAdi"
                  from public.ai_arac_log l
                  left join public.ai_arac a on a.kod = l.arac_kod
                 where l.sohbet_id = @p0
                 order by l.tarih desc limit 20
                """, null, [sohbetId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { sohbet, mesajlar, taslaklar, gunluk });
        });

        // --------------------------------------------------------- soru sor --
        // `arac` verilmişse o fonksiyon çalışır (hazır komut). SERBEST METİN
        //   REHBERE gider (447-450): katalogdan "ne nerede, nasıl yapılır"
        //   cevabı üretilir; sunucuda model anahtarı varsa cevabı model yazar
        //   (kontör düşülür). Model yokken de ekran boş dönmez - "model bağlı
        //   değil" cevabı kullanıcının sorusunu cevapsız bırakıyordu.
        grup.MapPost("/{sohbetId:int}/sor", async (
            int sohbetId, SoruIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            RehberServisi rehber, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            var sahip = await baglanti.TekAsync(
                "select 1 from public.ai_sohbet where id = @p0 and kullanici_id = @p1",
                null, [sohbetId, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);
            if (sahip is null) throw GentegreHatasi.Bulunamadi("Sohbet bulunamadı.");

            var soru = (istek.Metin ?? "").Trim();
            if (soru.Length == 0 && string.IsNullOrWhiteSpace(istek.Arac))
                throw GentegreHatasi.IsKurali("Soru boş olamaz.");

            // Kullanıcı mesajı + ilk soruda sohbet başlığı (mockup sol liste).
            var kMesaj = await baglanti.TekAsync("""
                insert into public.ai_mesaj (sohbet_id, rol, metin) values (@p0, 1, @p1)
                returning id
                """, null, [sohbetId, soru], OkuyucuGenisletmeleri.Sozluk, iptal);

            await baglanti.CalistirAsync("""
                update public.ai_sohbet
                   set son_tarih = (now())::timestamp,
                       baslik = case when baslik = 'Yeni sohbet' and @p1 <> ''
                                     then left(@p1, 60) else baslik end,
                       baglam = case when @p2::jsonb is null then baglam else @p2::jsonb end
                 where id = @p0
                """, null,
                [sohbetId, soru,
                 istek.Baglam is null ? null : JsonSerializer.Serialize(istek.Baglam)], iptal);

            // ---------------------------------------------- fonksiyon çağrısı
            if (!string.IsNullOrWhiteSpace(istek.Arac))
            {
                var arac = await baglanti.TekAsync("""
                    select kod, ad, yetki_kodu as "yetkiKodu", yazar
                      from public.ai_arac where kod = @p0 and aktif = 1
                    """, null, [istek.Arac], OkuyucuGenisletmeleri.Sozluk, iptal)
                    ?? throw GentegreHatasi.IsKurali("Tanımsız fonksiyon.");

                // YETKİ: asistan kullanıcının göremediği veriyi okuyamaz.
                var yetkiKodu = arac["yetkiKodu"]?.ToString() ?? "";
                if (yetkiKodu != "" && !baglam.Yetkiler.Var(yetkiKodu, Islem.Gor))
                    throw GentegreHatasi.IsKurali(
                        $"Bu fonksiyon için yetkiniz yok ({yetkiKodu}).");

                var kronometre = Stopwatch.StartNew();
                var (metin, veri2, taslak) = await AracCalistirAsync(
                    baglanti, istek.Arac!, istek.Parametre, baglam, iptal);
                kronometre.Stop();

                var aMesaj = await baglanti.TekAsync("""
                    insert into public.ai_mesaj (sohbet_id, rol, metin, veri)
                    values (@p0, 2, @p1, @p2::jsonb) returning id
                    """, null,
                    [sohbetId, metin, veri2 is null ? null : JsonSerializer.Serialize(veri2)],
                    OkuyucuGenisletmeleri.Sozluk, iptal);
                var aMesajId = Convert.ToInt32(aMesaj!["id"]);

                await baglanti.CalistirAsync("""
                    insert into public.ai_arac_log
                           (sohbet_id, mesaj_id, kullanici_id, arac_kod, parametre,
                            kayit_sayisi, sure_ms)
                    values (@p0, @p1, @p2, @p3, coalesce(@p4::jsonb, '{}'::jsonb), @p5, @p6)
                    """, null,
                    [sohbetId, aMesajId, baglam.KullaniciId, istek.Arac,
                     istek.Parametre?.ToString(), veri2?.Count ?? 0,
                     (int)kronometre.ElapsedMilliseconds], iptal);

                // Yazan fonksiyon TASLAK üretir - kayıt onayla oluşur.
                if (taslak is not null)
                    await baglanti.CalistirAsync("""
                        insert into public.ai_taslak
                               (sohbet_id, mesaj_id, tip, baslik, icerik)
                        values (@p0, @p1, @p2, @p3, @p4)
                        """, null,
                        [sohbetId, aMesajId, taslak.Value.Tip, taslak.Value.Baslik,
                         taslak.Value.Icerik], iptal);

                return Results.Ok(new { mesajId = aMesajId, kayit = veri2?.Count ?? 0 });
            }

            // ------------------------------------------------ serbest metin
            // Rehber cevabı: adımlar + yetkili ekranlar. Yetki süzgeci
            //   rehberin içinde; burada yalnız METNE çevriliyor.
            var rehberYanit = await rehber.CevaplaAsync(
                new RehberServisi.Istek(soru, null, istek.Baglam is not null
                    && istek.Baglam.TryGetValue("rota", out var r) ? r?.ToString() : null,
                    null),
                baglam, iptal);

            var kalem = new StringBuilder(rehberYanit.Cevap);
            foreach (var adim in rehberYanit.Adimlar)
                kalem.AppendLine().Append(adim.No).Append(". ").Append(adim.Metin);
            if (rehberYanit.OnerilenEkranlar.Count > 0)
                kalem.AppendLine().AppendLine()
                     .Append("İlgili ekranlar: ")
                     .Append(string.Join(" · ",
                             rehberYanit.OnerilenEkranlar.Select(e => e.Yol)));
            foreach (var u in rehberYanit.Uyarilar)
                kalem.AppendLine().AppendLine().Append("⚠ ").Append(u);
            if (rehberYanit.EksikBilgiSorusu is { Length: > 0 } ek)
                kalem.AppendLine().AppendLine().Append(ek);

            var yanit = kalem.ToString();

            var bMesaj = await baglanti.TekAsync("""
                insert into public.ai_mesaj (sohbet_id, rol, metin, model)
                values (@p0, 2, @p1, @p2)
                returning id
                """, null, [sohbetId, yanit, rehberYanit.Model],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { mesajId = Convert.ToInt32(bMesaj!["id"]), kayit = 0,
                                    model = rehberYanit.ModelKullanildi });
        });

        // ------------------------------------------------------ taslak onayı --
        grup.MapPost("/taslak", async (
            TaslakIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var t = await baglanti.TekAsync("""
                select t.id, t.tip, t.baslik, t.icerik, t.durum, t.taraf_id as "tarafId"
                  from public.ai_taslak t
                  join public.ai_sohbet s on s.id = t.sohbet_id
                 where t.id = @p0 and s.kullanici_id = @p1
                """, null, [istek.TaslakId, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Taslak bulunamadı.");

            if (Convert.ToInt32(t["durum"]) != 1)
                throw GentegreHatasi.IsKurali("Bu taslak zaten karara bağlanmış.");

            if (istek.Iptal)
            {
                await baglanti.CalistirAsync(
                    "update public.ai_taslak set durum = 3 where id = @p0",
                    null, [istek.TaslakId], iptal);
                return Results.Ok(new { durum = 3 });
            }

            // ONAY: hedef kayıt ŞİMDİ oluşur. Görev dışındaki tipler (e-posta,
            //   not) kayıt üretmez - metni kullanıcı kopyalar; gönderim
            //   asistanın işi değil (mockup: "Gönderim yapmadım").
            int? hedefId = null;
            var tip = Convert.ToInt32(t["tip"]);
            if (tip == 1)
            {
                baglam.YetkiIste("gorev", Islem.Ekle);
                var g = await baglanti.TekAsync("""
                    insert into public.gorev (konu, aciklama, tur, oncelik, durum,
                                              sorumlu_id, acan_id, taraf_id, sube_id, ekleyen)
                    values (@p0, @p1, 1, 2, 0, @p2, @p2, nullif(@p3, 0), @p4, @p2)
                    returning id
                    """, null,
                    [t["baslik"]?.ToString() ?? "AI görevi", t["icerik"]?.ToString() ?? "",
                     baglam.KullaniciId, t["tarafId"] is null ? 0 : Convert.ToInt32(t["tarafId"]),
                     baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
                hedefId = Convert.ToInt32(g!["id"]);
            }

            await baglanti.CalistirAsync("""
                update public.ai_taslak
                   set durum = 2, onaylayan = @p1, onay_tarihi = (now())::timestamp,
                       hedef_modul = case when @p2 is null then '' else 'gorev' end,
                       hedef_id = @p2
                 where id = @p0
                """, null, [istek.TaslakId, baglam.KullaniciId, hedefId], iptal);

            return Results.Ok(new { durum = 2, hedefModul = hedefId is null ? "" : "gorev", hedefId });
        });

        // ------------------------------------------------------ geri bildirim -
        grup.MapPost("/geribildirim", async (
            GeriBildirimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ai", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await baglanti.CalistirAsync("""
                update public.ai_mesaj m set geribildirim = @p1
                  from public.ai_sohbet s
                 where m.id = @p0 and s.id = m.sohbet_id and s.kullanici_id = @p2
                """, null, [istek.MesajId, istek.Deger, baglam.KullaniciId], iptal);

            return Results.Ok(new { tamam = true });
        });
    }

    private readonly record struct TaslakCiktisi(short Tip, string Baslik, string Icerik);

    /// <summary>
    /// İZİNLİ FONKSİYON GÖVDELERİ (343). Model buraya erişmez - uçlar çağırır,
    /// SQL burada durur ve her sorgu kullanıcının şubesiyle sınırlıdır.
    /// </summary>
    private static async Task<(string Metin, List<IDictionary<string, object?>>? Veri,
                               TaslakCiktisi? Taslak)>
        AracCalistirAsync(NpgsqlConnection baglanti, string kod, JsonElement? parametre,
                          IstekBaglami baglam, CancellationToken iptal)
    {
        string P(string ad, string varsayilan = "")
            => parametre is { ValueKind: JsonValueKind.Object } o
               && o.TryGetProperty(ad, out var d)
               ? (d.ValueKind == JsonValueKind.String ? d.GetString() ?? varsayilan : d.ToString())
               : varsayilan;

        switch (kod)
        {
            case "cari_vadesi_gecen":
            {
                var satirlar = await baglanti.ListeAsync("""
                    select t.id as "cariId", coalesce(nullif(btrim(t.unvan), ''), t.kod) as cari,
                           round(sum(h.borc - h.alacak), 2) as bakiye,
                           (current_date - min(coalesce(h.plan_tarihi, h.islem_tarihi))::date)::int
                               as "geciken_gun"
                      from public.mali_hareket h
                      join public.taraf t on t.id = h.taraf_id
                     where h.hesap_turu = 'C' and h.durum <> 3
                       and coalesce(h.plan_tarihi, h.islem_tarihi)::date < current_date
                       and h.sube_id = @p0
                     group by t.id, cari
                    having sum(h.borc - h.alacak) > 0
                     order by bakiye desc limit 20
                    """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

                var toplam = satirlar.Sum(s => Convert.ToDecimal(s["bakiye"] ?? 0m));
                return ($"Vadesi geçmiş bakiyesi olan {satirlar.Count} cari var; "
                        + $"toplam {toplam:N2}. En yüksek tutardan sıralandı.",
                        satirlar, null);
            }

            case "stok_kritik":
            {
                // MIN STOK DEPO BAZINDA (`stok_durum`), stok kartinda degil:
                //   ayni urun bir depoda kritik, otekinde bol olabilir - toplam
                //   bakiye kritik durumu gizlerdi.
                var satirlar = await baglanti.ListeAsync("""
                    select s.id as "stokId", s.kod, s.ad,
                           round(sum(d.kalan), 2) as mevcut,
                           round(sum(d.min_stok), 2) as "minStok"
                      from public.stok_durum d
                      join public.stok s on s.id = d.stok_id
                     where coalesce(d.min_stok, 0) > 0
                     group by s.id, s.kod, s.ad
                    having sum(d.kalan) < sum(d.min_stok)
                     order by (sum(d.min_stok) - sum(d.kalan)) desc limit 20
                    """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

                return (satirlar.Count == 0
                        ? "Minimum seviyenin altına düşen ürün yok."
                        : $"{satirlar.Count} üründe stok minimum seviyenin altında.",
                        satirlar, null);
            }

            case "bugun_ozet":
            {
                var satirlar = await baglanti.ListeAsync("""
                    select 'Bugün kesilen belge' as baslik,
                           (select count(*) from public.belge b
                             where b.belge_tarihi::date = current_date and b.sube_id = @p0)::int as deger
                    union all
                    select 'Bugünkü kasa işlemi',
                           (select count(*) from public.kasa_islem k
                             where k.islem_tarihi::date = current_date and k.sube_id = @p0)::int
                    union all
                    select 'Açık görev',
                           (select count(*) from public.gorev g
                             where g.durum in (0, 1) and g.sorumlu_id = @p1)::int
                    """, null, [baglam.SubeId, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

                return ("Bugünün özeti:", satirlar, null);
            }

            case "gorev_taslagi":
            {
                var konu = P("konu", "Görev");
                var aciklama = P("aciklama");
                // KAYIT OLUŞMAZ: taslak üretilir, onayı kullanıcı verir.
                return ($"Görev taslağını hazırladım - onaylarsan kayıt oluşturulur. "
                        + "Onaylamadan hiçbir şey yazılmaz.",
                        null, new TaslakCiktisi(1, konu, aciklama));
            }

            default:
                throw GentegreHatasi.IsKurali("Bu fonksiyon tanımlı değil.");
        }
    }
}
