using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÜRÜN AĞACI (REÇETE) LİSTESİ UÇLARI (1257, mockup urun_agaci_listesi_v2.html). Özet şeridi, Kopyala, Pasife Al ve
/// denetimli seviyenin onay akışı (Onaya Gönder → Onayla / Reddet, e-imza, ECN no, yürürlük, eski onaylı sürüm kilitlenir).
/// Yeni Sürüm / Maliyet / Nerede Kullanılıyor UretimUclari.cs'de (429).
/// </summary>
public static partial class UretimUclari
{
    private const short OnayTaslak = 0, Onayda = 1, OnayliRecete = 2, Kilitli = 3;

    public sealed record GerekceIstegi(string? Gerekce, string? Parola);
    public sealed record OnayIstegi(short Karar, string? Gerekce, string? Parola);

    /// <summary>Denetimli seviyede onaylı olmayan reçeteden emir açılmaz (422).</summary>
    private static async Task ReceteOnayliMiAsync(NpgsqlConnection b, NpgsqlTransaction? t, int agacId, CancellationToken iptal)
    {
        var (seviye, _) = await UretimFisiUclari.SeviyeOkuAsync(b, t, iptal);
        if (seviye != "denetimli") return;
        var onay = await b.TekDegerAsync<short?>("select onay_durum from public.urun_agaci where id = @p0", t, [agacId], iptal) ?? 0;
        if (onay != OnayliRecete)
            throw GentegreHatasi.IsKurali(onay switch
            {
                Onayda => "Reçete onayda - onaylanmadan üretim emri açılamaz.",
                Kilitli => "Bu reçete sürümü kilitli (yeni sürüm yürürlükte) - yürürlükteki sürümü seçin.",
                _ => "Reçete taslak - denetimli seviyede önce onaya gönderilip onaylanmalı.",
            });
    }

    private static void ReceteUclari(RouteGroupBuilder grup)
    {
        // GET /api/uretim/agac/ozet - liste üst şeridi: reçete sayıları, boş reçete, maliyeti eski, açık emirde, bu ay
        //   üretilen, malzeme eksik (basit), onay bekleyen (denetimli). Şube kapsamı liste satırlarıyla aynı mantık.
        grup.MapGet("/agac/ozet", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ozet = await b.TekAsync("""
                with a as (select * from public.urun_agaci a where (@p0 = 0 or a.sube_id in (0, @p0)))
                select count(*)                                                                   as "recete",
                       count(*) filter (where a.durum = 0)                                         as "aktif",
                       count(*) filter (where a.durum <> 0)                                        as "pasif",
                       count(*) filter (where a.durum = 0 and not exists
                            (select 1 from public.urun_agaci_satir s where s.agac_id = a.id))      as "bos",
                       count(*) filter (where a.durum = 0 and (a.maliyet_tarih is null
                                          or a.maliyet_tarih < now() - interval '30 days'))        as "maliyetEski",
                       count(*) filter (where exists (select 1 from public.uretim_emri e
                                          where e.agac_id = a.id and e.durum between 1 and 5))     as "acikEmirde",
                       (select count(*) from public.uretim_emri e join a on a.id = e.agac_id
                         where e.durum between 1 and 5)                                            as "acikEmir",
                       count(*) filter (where a.durum = 0
                                          and coalesce(public.fn_urun_agaci_uretilebilir(a.id), 0) <= 0
                                          and exists (select 1 from public.urun_agaci_satir s where s.agac_id = a.id)) as "malzemeEksik",
                       (select coalesce(sum(f.uretilen), 0) from public.uretim_fisi f join a on a.id = f.agac_id
                         where f.durum in (2, 3) and f.bas >= date_trunc('month', now()))          as "buAyUretilen",
                       (select count(*) from public.uretim_fisi f join a on a.id = f.agac_id
                         where f.durum in (2, 3) and f.bas >= date_trunc('month', now()))          as "buAyFis",
                       count(*) filter (where a.onay_durum = 1)                                    as "onayBekleyen",
                       coalesce((select max(extract(day from now() - x.onaya_gonderme))::int from a x where x.onay_durum = 1), 0) as "onayBekleyenGun"
                  from a
                """, null, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { ozet, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/agac/{id}/surumler - aynı kodun sürümleri: onay / ECN / yürürlük, kim hazırladı / onayladı, açık
        //   emir, maliyet (kart "Sürümler" + "Değişiklik Geçmişi (ECN)" sekmeleri, 1258).
        grup.MapGet("/agac/{id:int}/surumler", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var surumler = await b.ListeAsync("""
                select a.id, a.surum, a.durum, a.varsayilan, a.onay_durum, coalesce(a.ecn_no, ''), a.yururluk, a.onay_tarihi,
                       coalesce(a.onay_gerekce, ''), a.onaya_gonderme, a.maliyet_toplam, a.degistirme_tarihi, a.ekleme_tarihi,
                       coalesce((select t.unvan from public.taraf t where t.id = a.onaya_gonderen), ''),   -- kullanıcı id = taraf id (taraf_kullanici)
                       coalesce((select t.unvan from public.taraf t where t.id = a.onaylayan), ''),
                       coalesce((select t.unvan from public.taraf t where t.id = coalesce(a.degistiren, a.ekleyen)), ''),
                       (select count(*) from public.uretim_emri e where e.agac_id = a.id and e.durum between 1 and 5),
                       (select count(*) from public.urun_agaci_satir s where s.agac_id = a.id),
                       (select count(*) from public.urun_agaci_operasyon o where o.agac_id = a.id),
                       (select count(*) from public.urun_agaci_kontrol c where c.agac_id = a.id),
                       coalesce(a.notlar, ''),
                       public.fn_urun_agaci_uretilebilir(a.id)
                  from public.urun_agaci a
                 where a.kod = (select kod from public.urun_agaci where id = @p0)
                 order by a.surum desc
                """, null, [id], o => new
                {
                    id = o.GetInt32(0), surum = o.GetInt16(1), durum = o.GetInt16(2), varsayilan = o.GetInt16(3), onayDurum = o.GetInt16(4),
                    ecnNo = o.GetString(5), yururluk = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                    onayTarihi = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7), onayGerekce = o.GetString(8),
                    onayaGonderme = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                    maliyet = o.IsDBNull(10) ? 0m : o.GetDecimal(10),
                    degisme = o.IsDBNull(11) ? (o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12)) : o.GetDateTime(11),
                    hazirlayan = o.GetString(13), onaylayan = o.GetString(14), degistiren = o.GetString(15),
                    acikEmir = o.GetInt64(16), bilesen = o.GetInt64(17), operasyon = o.GetInt64(18), kontrol = o.GetInt64(19), notlar = o.GetString(20),
                    uretilebilir = o.IsDBNull(21) ? (decimal?)null : o.GetDecimal(21),
                }, iptal);
            return Results.Ok(new { surumler, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/agac/{id}/kopyala - aynı reçeteden yeni kodla kopya (farklı renk / müşteri); sürüm 1, taslak.
        grup.MapPost("/agac/{id:int}/kopyala", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
                                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var kod = await b.TekDegerAsync<string>("select kod from public.urun_agaci where id = @p0", t, [id], iptal)
                      ?? throw GentegreHatasi.Bulunamadi("Ürün ağacı bulunamadı.");
            // Kod: ASIL-K, doluysa ASIL-K2, -K3… (kod uzunluğu 25).
            var govde = kod.Length > 21 ? kod[..21] : kod;
            string yeniKod = govde + "-K";
            for (var n = 2; await b.TekDegerAsync<int>("select count(*) from public.urun_agaci where kod = @p0", t, [yeniKod], iptal) > 0; n++)
                yeniKod = govde + "-K" + n;
            var yeniId = await b.TekDegerAsync<int>("""
                insert into public.urun_agaci
                       (kod, ad, stok_id, tur, cikti_miktar, birim, surum, varsayilan, alternatif_ad, gecerli_bas,
                        sarf_depo_id, mamul_depo_id, fire_depo_id, tavsiye_satis_katsayi, durum, notlar, sube_id, ekleyen)
                select @p1, a.ad || ' (kopya)', a.stok_id, a.tur, a.cikti_miktar, a.birim, 1, 0, a.alternatif_ad, current_date,
                       a.sarf_depo_id, a.mamul_depo_id, a.fire_depo_id, a.tavsiye_satis_katsayi, 0, a.notlar, a.sube_id, @p2
                  from public.urun_agaci a where a.id = @p0
                returning id
                """, t, [id, yeniKod, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                insert into public.urun_agaci_satir
                       (agac_id, sira, bilesen_stok_id, alt_agac_id, tur, miktar, birim, fire_yuzde, operasyon_sira, depo_id,
                        alternatif_grup, aciklama, ekleyen)
                select @p1, s.sira, s.bilesen_stok_id, s.alt_agac_id, s.tur, s.miktar, s.birim, s.fire_yuzde, s.operasyon_sira,
                       s.depo_id, s.alternatif_grup, s.aciklama, @p2
                  from public.urun_agaci_satir s where s.agac_id = @p0 order by s.sira, s.id
                """, t, [id, yeniId, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                insert into public.urun_agaci_operasyon
                       (agac_id, sira, ad, is_merkezi_id, hazirlik_dk, birim_sure_dk, saat_ucreti, kalite_kontrol, fason,
                        fason_taraf_id, aciklama, ekleyen)
                select @p1, o.sira, o.ad, o.is_merkezi_id, o.hazirlik_dk, o.birim_sure_dk, o.saat_ucreti, o.kalite_kontrol, o.fason,
                       o.fason_taraf_id, o.aciklama, @p2
                  from public.urun_agaci_operasyon o where o.agac_id = @p0 order by o.sira, o.id
                """, t, [id, yeniId, baglam.KullaniciId], iptal);
            var satir = await b.TekAsync("select * from public.urun_agaci where id = @p0", t, [yeniId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var bilgi = satir?.ToDictionary(x => x.Key, x => (object?)LogDeposu.Metin(x.Value)) ?? new Dictionary<string, object?>();
            bilgi["kaynak"] = "kopya #" + id.ToString(System.Globalization.CultureInfo.InvariantCulture);
            await log.YazAsync(b, t, LogIslemi.Ekle, LogAgac, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { id = yeniId, kod = yeniKod, mesaj = $"{yeniKod} oluşturuldu (kopya, taslak).", izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/agac/{id}/pasif {gerekce, parola?} - silme yerine pasife alma. Denetimlide onaylı reçetede e-imza
        //   (parola) ister; gerekçe her seviyede zorunlu değil ama varsa loga yazılır.
        grup.MapPost("/agac/{id:int}/pasif", async (int id, GerekceIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                                      KullaniciDeposu kullanicilar, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var a = await b.TekAsync("select kod, durum, onay_durum from public.urun_agaci where id = @p0 for update",
                                     t, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                    ?? throw GentegreHatasi.Bulunamadi("Ürün ağacı bulunamadı.");
            if (Convert.ToInt16(a["durum"]) != 0) throw GentegreHatasi.IsKurali("Reçete zaten pasif.");
            var (seviye, _) = await UretimFisiUclari.SeviyeOkuAsync(b, t, iptal);
            if (seviye == "denetimli")
            {
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.", new AlanHatasi("gerekce", "Gerekçe yazılmalı."));
                if (Convert.ToInt16(a["onay_durum"]) >= OnayliRecete)
                    await UretimFisiUclari.ParolaDogrulaAsync(kullanicilar, baglam.KullaniciId, istek.Parola, iptal);
            }
            await b.CalistirAsync("""
                update public.urun_agaci set durum = 1, varsayilan = 0, pasif_neden = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, t, [id, (istek.Gerekce ?? "").Trim(), baglam.KullaniciId], iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogAgac, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "pasife alma", gerekce = (istek.Gerekce ?? "").Trim(), eImza = seviye == "denetimli" }, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { id, mesaj = $"{a["kod"]} pasife alındı.", izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/agac/{id}/onaya-gonder {gerekce} - taslak → onayda (hazırlayan). Boş reçete gönderilmez.
        grup.MapPost("/agac/{id:int}/onaya-gonder", async (int id, GerekceIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                                             LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var a = await b.TekAsync("""
                select kod, surum, durum, onay_durum,
                       (select count(*) from public.urun_agaci_satir s where s.agac_id = a.id) as bilesen
                  from public.urun_agaci a where id = @p0 for update
                """, t, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Ürün ağacı bulunamadı.");
            if (Convert.ToInt16(a["durum"]) != 0) throw GentegreHatasi.IsKurali("Pasif reçete onaya gönderilemez.");
            if (Convert.ToInt16(a["onay_durum"]) != OnayTaslak)
                throw GentegreHatasi.IsKurali("Yalnız taslak reçete onaya gönderilir (reçete zaten onayda / onaylı / kilitli).");
            if (Convert.ToInt64(a["bilesen"]) == 0) throw GentegreHatasi.IsKurali("Boş reçete onaya gönderilemez - önce bileşen ekleyin.");
            await b.CalistirAsync("""
                update public.urun_agaci set onay_durum = 1, onaya_gonderen = @p1, onaya_gonderme = now(), onay_gerekce = @p2,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, t, [id, baglam.KullaniciId, (istek.Gerekce ?? "").Trim()], iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogAgac, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "onaya gönderme", gerekce = (istek.Gerekce ?? "").Trim() }, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { id, mesaj = $"{a["kod"]} v{a["surum"]} onaya gönderildi.", izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/agac/{id}/onayla {karar 1 onayla | 2 reddet, gerekce, parola} - e-imza; aksiyon yetkisi
        //   uretim.recete.onay; dört göz (onaya gönderen onaylayamaz). Onay: ECN no, yürürlük bugün, bu sürüm varsayılan,
        //   aynı kodun önceki onaylı sürümleri kilitlenir (açık emirler kendi sürümünde biter). Ret: taslağa döner.
        grup.MapPost("/agac/{id:int}/onayla", async (int id, OnayIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                                       KullaniciDeposu kullanicilar, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.recete.onay", Islem.Degistir);
            if (istek.Karar is not (1 or 2))
                throw GentegreHatasi.Dogrulama("Karar onayla (1) ya da reddet (2) olmalı.", new AlanHatasi("karar", "Geçersiz karar."));
            if (istek.Karar == 2 && string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("Ret gerekçesi zorunlu.", new AlanHatasi("gerekce", "Gerekçe yazılmalı."));
            await UretimFisiUclari.ParolaDogrulaAsync(kullanicilar, baglam.KullaniciId, istek.Parola, iptal);

            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var a = await b.TekAsync("select kod, surum, onay_durum, onaya_gonderen from public.urun_agaci where id = @p0 for update",
                                     t, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Ürün ağacı bulunamadı.");
            if (Convert.ToInt16(a["onay_durum"]) != Onayda) throw GentegreHatasi.IsKurali("Yalnız onaydaki reçete onaylanır / reddedilir.");
            if (a["onaya_gonderen"] is int gonderen && gonderen == baglam.KullaniciId)
                throw GentegreHatasi.IsKurali("Dört göz kuralı: onaya gönderen kişi onaylayamaz.");
            var kod = Convert.ToString(a["kod"]) ?? "";
            if (istek.Karar == 1)
            {
                var yil = Saat.Bugun.Year;
                var sira = await b.TekDegerAsync<long>(
                    "select count(*) + 1 from public.urun_agaci where ecn_no like @p0", t, [$"ECN-{yil}-%"], iptal);
                var ecn = $"ECN-{yil}-{sira:000}";
                // Aynı kodun önceki onaylı sürümleri kilitlenir, varsayılan bu sürüme geçer.
                await b.CalistirAsync("""
                    update public.urun_agaci set onay_durum = 3, varsayilan = 0, degistiren = @p1, degistirme_tarihi = now()
                     where kod = @p0 and id <> @p2 and onay_durum = 2
                    """, t, [kod, baglam.KullaniciId, id], iptal);
                await b.CalistirAsync("""
                    update public.urun_agaci
                       set onay_durum = 2, onaylayan = @p1, onay_tarihi = now(), onay_gerekce = @p2, ecn_no = @p3, yururluk = current_date,
                           varsayilan = 1, degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, t, [id, baglam.KullaniciId, (istek.Gerekce ?? "").Trim(), ecn], iptal);
                await log.YazAsync(b, t, LogIslemi.Degistir, LogAgac, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { eImza = true, anlam = "reçete onayı", ecn, gerekce = (istek.Gerekce ?? "").Trim() }, iptal: iptal);
                await t.CommitAsync(iptal);
                return Results.Ok(new { id, karar = 1, ecn, mesaj = $"{kod} v{a["surum"]} onaylandı · {ecn} · yürürlük bugün.", izlemeNo = baglam.IzlemeNo });
            }
            await b.CalistirAsync("""
                update public.urun_agaci set onay_durum = 0, onay_gerekce = @p2, degistiren = @p1, degistirme_tarihi = now() where id = @p0
                """, t, [id, baglam.KullaniciId, istek.Gerekce!.Trim()], iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogAgac, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { eImza = true, anlam = "reçete reddi", gerekce = istek.Gerekce.Trim() }, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { id, karar = 2, mesaj = $"{kod} v{a["surum"]} reddedildi - taslağa döndü.", izlemeNo = baglam.IzlemeNo });
        });
    }
}
