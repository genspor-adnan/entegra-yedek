using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DİKTE (705) — mockup <c>Ekranlar/Goz/goz_dikte.html</c> — ve onunla aynı
/// kapıyı kullanan <b>bulgu metni yazma</b> ucu.
///
/// <para><b>Dikte yalnız METİN alanına yazar.</b> Görme, refraksiyon, GİB,
/// pakimetri ve kodlu alanlar (ICD, LOCS) kapalıdır: yanlış duyulan
/// "yirmi altı / yirmi yedi" sessizce tedavi değiştirir. Sayı ya elle girilir
/// ya cihazdan gelir.</para>
///
/// <para><b>Hedef listesi sunucudan gelir.</b> Hangi alana yazılabileceği bir
/// iş kuralıdır; ekranın kendi listesini tutması, kapalı bir alanın bir gün
/// sessizce açılması demekti. Aynı beyaz liste hem dikteyi hem çizimden
/// gelen metni denetler — iki yol, tek kapı.</para>
///
/// <para><b>Metin ezilmez, sonuna eklenir.</b> Muayene sırasında aynı alana
/// birkaç kez konuşulur; üzerine yazmak, hekimin bir önceki cümlesini sessizce
/// silmek olurdu.</para>
///
/// <para><b>Sözlük veridir.</b> "see de → C/D" eşlemesi hekimden hekime
/// değişir; kurum ve kullanıcı satırları <c>dikte_terim</c> tablosunda durur,
/// yeni terim için sürüm çıkmak gerekmez. Ses tanımanın kendisi istemcide
/// (tarayıcıda) çalışır — bu uç sesi değil, <b>onaylanmış metni</b> alır.</para>
/// </summary>
public static partial class GozUclari
{
    private const int LogTabloDikte = 956;

    /// <summary>Metin yazılabilen alanlar: beyaz liste, sunucuda.</summary>
    private sealed record BulguHedefi(
        string Kod, string Ad, bool GozGerekir, string Tablo, string Kolon, string Alan);

    private static readonly BulguHedefi[] BulguHedefleri =
    [
        new("muayene.sikayet",     "Şikâyet",            false, "muayene", "sikayet", ""),
        new("muayene.hikaye",      "Hikâye",             false, "muayene", "hikaye", ""),
        new("muayene.bulgu_ozet",  "Değerlendirme",      false, "muayene", "bulgu_ozet", ""),
        new("muayene.karar",       "Plan",               false, "muayene", "karar", ""),

        new("onSegment.kapak",       "Ön segment › Kapak / kirpik", true, "on_segment", "deger_metin", "kapak"),
        new("onSegment.konjonktiva", "Ön segment › Konjonktiva",    true, "on_segment", "deger_metin", "konjonktiva"),
        new("onSegment.kornea",      "Ön segment › Kornea",         true, "on_segment", "deger_metin", "kornea"),
        new("onSegment.on_kamara",   "Ön segment › Ön kamara",      true, "on_segment", "deger_metin", "on_kamara"),
        new("onSegment.iris",        "Ön segment › İris",           true, "on_segment", "deger_metin", "iris"),
        new("onSegment.pupil",       "Ön segment › Pupil",          true, "on_segment", "deger_metin", "pupil"),
        new("onSegment.lens",        "Ön segment › Lens",           true, "on_segment", "deger_metin", "lens"),

        new("fundus.disk",     "Fundus › Optik disk", true, "fundus", "disk_metin", ""),
        new("fundus.makula",   "Fundus › Makula",     true, "fundus", "makula_metin", ""),
        new("fundus.damar",    "Fundus › Damarlar",   true, "fundus", "damar_metin", ""),
        new("fundus.periferi", "Fundus › Periferi",   true, "fundus", "periferi_metin", ""),
    ];

    /// <summary>Dikteye KAPALI alanlar: ekran nedenini de gösterir.</summary>
    private static readonly (string Ad, string Neden)[] DikteKapali =
    [
        ("Görme keskinliği", "sayısal ölçüm"),
        ("Refraksiyon",      "sayısal ölçüm"),
        ("GİB / pakimetri",  "sayısal ölçüm"),
        ("Tanı (ICD)",       "kodlu alan"),
        ("LOCS III / Van Herick", "kodlu alan"),
    ];

    public sealed record BulguMetniIstegi(
        string Hedef, int Goz, string Metin, int Yontem);

    public sealed record DikteTerimIstegi(
        string Soylenen, string Yazilan, int Tur, string? Eylem, bool Kisisel);

    private static void DikteUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------- sözlük ----
        grup.MapGet("/dikte/sozluk", async (
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // KURUM + KENDİ terimleri: başkasının kişisel sözlüğü gelmez.
            //   Kişisel satır kurum satırını EZER (aynı söyleniş), çünkü
            //   hekim kendi ağzına göre düzeltmiş demektir.
            var terimler = await baglanti.ListeAsync("""
                select t.id, t.kapsam, t.soylenen, t.yazilan, t.tur, t.eylem, t.sira
                  from public.dikte_terim t
                 where t.aktif = 1
                   and (t.kapsam = 1 or t.kullanici_id = @p0)
                 order by t.tur, t.sira, t.soylenen
                """, null, [baglam.KullaniciId], o => new
            {
                id = o.GetInt32(0),
                kapsam = (int)o.GetInt16(1),
                soylenen = o.GetString(2),
                yazilan = o.GetString(3),
                tur = (int)o.GetInt16(4),
                eylem = o.GetString(5),
                sira = o.GetInt32(6),
            }, iptal);

            return Results.Ok(new
            {
                terimler = terimler.Where(t => t.tur == 1),
                komutlar = terimler.Where(t => t.tur == 2),
                cumleler = terimler.Where(t => t.tur == 3),
                hedefler = BulguHedefleri.Select(h => new { h.Kod, h.Ad, h.GozGerekir }),
                kapali = DikteKapali.Select(k => new { k.Ad, k.Neden }),
                // Güven eşiği kuraldır, ekran ayarı değil: bunun altındaki
                //   parça yazılmaz, dökümde "atıldı" görünür.
                guvenEsigi = 0.60,
            });
        });

        // ------------------------------------------- kişisel terim ekleme ----
        grup.MapPost("/dikte/terim", async (
            DikteTerimIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // KURUM SÖZLÜĞÜ AYRI YETKİ: bir terimi kurum sözlüğüne yazmak
            //   herkesin diktesini değiştirir. Kişisel terim, muayene
            //   yetkisi olan herkesin kendi işidir.
            baglam.YetkiIste(istek.Kisisel ? "goz.muayene" : "goz.dikte_sozluk",
                             Islem.Degistir);

            var soylenen = (istek.Soylenen ?? "").Trim();
            var yazilan = (istek.Yazilan ?? "").Trim();
            if (soylenen.Length == 0)
                throw GentegreHatasi.Dogrulama("Söyleniş boş olamaz.");
            if (istek.Tur == 1 && yazilan.Length == 0)
                throw GentegreHatasi.Dogrulama("Terimin yazılacağı karşılık boş olamaz.");

            await using var baglanti = await veri.AcAsync(iptal);

            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.dikte_terim
                    (kapsam, kullanici_id, soylenen, yazilan, tur, eylem, sira,
                     sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 500, @p6, @p7)
                on conflict (kapsam, coalesce(kullanici_id, 0), lower(soylenen), tur)
                do update set yazilan = excluded.yazilan, eylem = excluded.eylem,
                              aktif = 1, degistiren = excluded.ekleyen,
                              degistirme_tarihi = now()
                returning id
                """, null,
                [istek.Kisisel ? 2 : 1, istek.Kisisel ? baglam.KullaniciId : (int?)null,
                 soylenen, yazilan, istek.Tur <= 0 ? 1 : istek.Tur, istek.Eylem ?? "",
                 baglam.SubeId, baglam.KullaniciId], iptal);

            return Results.Ok(new { id, soylenen, yazilan, kisisel = istek.Kisisel });
        });

        // ------------------------------------ bulgu metni yaz (dikte/çizim) ----
        // TEK KAPI: dikte de çizim de buradan yazar. İki ayrı uç olsaydı,
        //   "kapalı muayeneye yazma" kuralının iki kopyası olurdu.
        grup.MapPost("/muayene/{id:int}/bulgu-metni", async (
            int id, BulguMetniIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Degistir);

            var hedef = BulguHedefleri.FirstOrDefault(h => h.Kod == istek.Hedef)
                ?? throw GentegreHatasi.Dogrulama(
                       $"'{istek.Hedef}' dikteye/çizime kapalı bir alan. "
                     + "Sayısal ölçüm ve kodlu alanlar elle girilir.");

            var metin = (istek.Metin ?? "").Trim();
            if (metin.Length == 0)
                throw GentegreHatasi.Dogrulama("Yazılacak metin boş.");
            if (hedef.GozGerekir && istek.Goz is not (1 or 2))
                throw GentegreHatasi.Dogrulama(
                    $"'{hedef.Ad}' göz bazlı bir alan: OD ya da OS seçilmeli.");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync("""
                select gm.muayene_id, gm.hasta_id, (mu.tamamlanma is not null) as kapali
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.id = @p0
                """, islem, [id], o => new
            {
                muayeneId = o.GetInt32(0),
                hastaId = o.GetInt32(1),
                kapali = o.GetBoolean(2),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            if (m.kapali)
                throw GentegreHatasi.IsKurali("Muayene tamamlanmış; bulgu yazılamaz.");

            string sonHali;
            switch (hedef.Tablo)
            {
                case "muayene":
                    // Kolon adı BEYAZ LİSTEDEN geliyor; istekten gelen metin
                    //   her zaman parametre.
                    sonHali = await baglanti.TekDegerAsync<string>($"""
                        update public.muayene
                           set {hedef.Kolon} = case when coalesce({hedef.Kolon}, '') = ''
                                                    then @p1
                                                    else {hedef.Kolon} || E'\n' || @p1 end,
                               degistiren = @p2, degistirme_tarihi = now()
                         where id = @p0
                        returning {hedef.Kolon}
                        """, islem, [m.muayeneId, metin, baglam.KullaniciId], iptal) ?? "";
                    break;

                case "on_segment":
                    await baglanti.CalistirAsync("""
                        insert into public.goz_on_segment
                            (goz_muayene_id, goz, kaynak, alan, deger_metin, ekleyen)
                        select @p0, @p1, 1, @p2, '', @p3
                         where not exists (select 1 from public.goz_on_segment x
                                            where x.goz_muayene_id = @p0 and x.goz = @p1
                                              and x.alan = @p2)
                        """, islem, [id, istek.Goz, hedef.Alan, baglam.KullaniciId], iptal);

                    sonHali = await baglanti.TekDegerAsync<string>("""
                        update public.goz_on_segment
                           set deger_metin = case when coalesce(deger_metin, '') = ''
                                                  then @p3
                                                  else deger_metin || E'\n' || @p3 end,
                               degistiren = @p4, degistirme_tarihi = now()
                         where goz_muayene_id = @p0 and goz = @p1 and alan = @p2
                        returning deger_metin
                        """, islem,
                        [id, istek.Goz, hedef.Alan, metin, baglam.KullaniciId], iptal) ?? "";
                    break;

                case "fundus":
                    await baglanti.CalistirAsync("""
                        insert into public.goz_fundus (goz_muayene_id, goz, kaynak, ekleyen)
                        select @p0, @p1, 1, @p2
                         where not exists (select 1 from public.goz_fundus x
                                            where x.goz_muayene_id = @p0 and x.goz = @p1)
                        """, islem, [id, istek.Goz, baglam.KullaniciId], iptal);

                    sonHali = await baglanti.TekDegerAsync<string>($"""
                        update public.goz_fundus
                           set {hedef.Kolon} = case when coalesce({hedef.Kolon}, '') = ''
                                                    then @p2
                                                    else {hedef.Kolon} || E'\n' || @p2 end,
                               degistiren = @p3, degistirme_tarihi = now()
                         where goz_muayene_id = @p0 and goz = @p1
                        returning {hedef.Kolon}
                        """, islem, [id, istek.Goz, metin, baglam.KullaniciId], iptal) ?? "";
                    break;

                default:
                    throw GentegreHatasi.IsKurali("Bilinmeyen hedef tablo.");
            }

            await islem.CommitAsync(iptal);

            // YÖNTEM LOGA YAZILIR: "bunu kim yazdı" sorusunun cevabı sonradan
            //   "dikte · 10:44" ya da "çizim" olabilsin.
            await log.YazAsync(LogIslemi.Degistir, LogTabloDikte, m.muayeneId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    durum = "Bulgu metni eklendi",
                    hedef = hedef.Ad,
                    goz = istek.Goz == 1 ? "OD" : istek.Goz == 2 ? "OS" : "",
                    yontem = istek.Yontem == 2 ? "Çizim" : istek.Yontem == 1 ? "Dikte" : "Elle",
                    metin,
                }, tarafId: m.hastaId, iptal: iptal);

            return Results.Ok(new
            {
                id,
                hedef = hedef.Kod,
                hedefAdi = hedef.Ad,
                sonHali,
                aciklama = $"{hedef.Ad} alanına eklendi.",
            });
        });
    }
}
