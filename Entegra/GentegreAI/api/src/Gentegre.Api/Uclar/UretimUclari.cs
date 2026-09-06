using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÜRETİM UÇLARI — v1 (429): ürün ağacı maliyeti/sürümü, üretim emri açma,
/// rezerv, sarf, mamul girişi, fire ve maliyet kapanışı.
///
/// <para><b>Stok hareketi TEK HATTAN geçer.</b> Sarf, mamul girişi ve fire,
/// kendi tablolarına yazılmaz - normal <see cref="BelgeDeposu"/> üzerinden
/// belge olur (tür 121/122/123). Böylece stok kontrolü, izleme (lot/seri),
/// ağırlıklı ortalama ve muhasebe fişi üretimi radyoloji sarfıyla aynı yolu
/// izler; üretime özel ikinci bir stok yolu bakımı imkânsız hale getirirdi.</para>
///
/// <para><b>Ağaç emre KOPYALANIR.</b> Emir açılırken bileşen ve operasyonlar
/// emrin kendi satırlarına yazılır; ağaç sonradan değişse açık emir
/// etkilenmez. "Ağaçtan Yenile" yalnız Taslak/Onaylı emirde çalışır.</para>
/// </summary>
public static class UretimUclari
{
    // Durumlar (db/429): 0 iptal · 1 taslak · 2 onaylı · 3 planlandı ·
    //   4 üretimde · 5 kısmi · 6 tamamlandı · 7 kapatıldı.
    private const short Iptal = 0, Taslak = 1, Onayli = 2,
                        Uretimde = 4, Kismi = 5, Tamamlandi = 6, Kapatildi = 7;

    public sealed record EmirIstegi(int StokId, int? AgacId, decimal Adet, short? Tur,
                                    DateOnly? PlanBas, DateOnly? Termin,
                                    int? SarfDepoId, int? MamulDepoId,
                                    int? KaynakBelgeId, int? KaynakSatirId,
                                    int? UstEmirId, string? Aciklama);

    public sealed record MiktarIstegi(decimal Adet, decimal? BirimFiyat, string? Aciklama);

    public sealed record FireIstegi(int StokId, decimal Adet, string? Neden);

    public sealed record SarfIstegi(SarfSatiri[]? Satirlar);

    public sealed record SarfSatiri(int SatirId, decimal Miktar);

    public sealed record MaliyetIstegi(decimal? GugYuzde);

    public sealed record IptalIstegi(string? Neden);

    public static void UretimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/uretim").WithTags("Üretim").RequireAuthorization();

        // ------------------------------------------------------------- ağaç ---

        // POST /api/uretim/agac/{id}/maliyet - ağacın birim maliyetini hesapla
        //   ve TARİHLİ olarak karta yaz. Sonuç kolonlara yazılmasaydı liste
        //   ekranında maliyet gösterilemez, her satır için hesap gerekirdi.
        grup.MapPost("/agac/{id:int}/maliyet", async (
            int id, MaliyetIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            var gug = istek?.GugYuzde ?? 0m;
            var sonuc = await veri.TekAsync("""
                select malzeme, iscilik, gug, toplam
                  from public.fn_urun_agaci_maliyet(@p0, @p1)
                """, [id, gug],
                o => new { Malzeme = o.GetDecimal(0), Iscilik = o.GetDecimal(1),
                           Gug = o.GetDecimal(2), Toplam = o.GetDecimal(3) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ürün ağacı bulunamadı.");

            await veri.CalistirAsync("""
                update public.urun_agaci
                   set maliyet_malzeme = @p1, maliyet_iscilik = @p2, maliyet_gug = @p3,
                       maliyet_toplam = @p4, maliyet_tarih = now(),
                       degistiren = @p5, degistirme_tarihi = now()
                 where id = @p0
                """, [id, sonuc.Malzeme, sonuc.Iscilik, sonuc.Gug, sonuc.Toplam,
                      baglam.KullaniciId], iptal);

            return Results.Ok(new { id, sonuc.Malzeme, sonuc.Iscilik, sonuc.Gug,
                                    sonuc.Toplam, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/agac/{id}/yeni-surum - ağacı kopyalar, sürümü artırır.
        //   ESKİ SÜRÜM SİLİNMEZ, pasifleşir: açık emirler ona bakmaya devam eder.
        grup.MapPost("/agac/{id:int}/yeni-surum", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var kod = await baglanti.TekDegerAsync<string>(
                "select kod from public.urun_agaci where id = @p0", islem, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ürün ağacı bulunamadı.");

            var yeniSurum = await baglanti.TekDegerAsync<int>("""
                select coalesce(max(surum), 0) + 1 from public.urun_agaci where kod = @p0
                """, islem, [kod], iptal);

            var yeniId = await baglanti.TekDegerAsync<int>("""
                insert into public.urun_agaci
                       (kod, ad, stok_id, tur, cikti_miktar, birim, surum, varsayilan,
                        alternatif_ad, gecerli_bas, sarf_depo_id, mamul_depo_id,
                        fire_depo_id, tavsiye_satis_katsayi, durum, notlar, sube_id, ekleyen)
                select a.kod, a.ad, a.stok_id, a.tur, a.cikti_miktar, a.birim, @p1, 0,
                       a.alternatif_ad, current_date, a.sarf_depo_id, a.mamul_depo_id,
                       a.fire_depo_id, a.tavsiye_satis_katsayi, 0, a.notlar, a.sube_id, @p2
                  from public.urun_agaci a where a.id = @p0
                returning id
                """, islem, [id, (short)yeniSurum, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                insert into public.urun_agaci_satir
                       (agac_id, sira, bilesen_stok_id, alt_agac_id, tur, miktar, birim,
                        fire_yuzde, operasyon_sira, depo_id, alternatif_grup, aciklama, ekleyen)
                select @p1, s.sira, s.bilesen_stok_id, s.alt_agac_id, s.tur, s.miktar,
                       s.birim, s.fire_yuzde, s.operasyon_sira, s.depo_id,
                       s.alternatif_grup, s.aciklama, @p2
                  from public.urun_agaci_satir s where s.agac_id = @p0 order by s.sira, s.id
                """, islem, [id, yeniId, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                insert into public.urun_agaci_operasyon
                       (agac_id, sira, ad, is_merkezi_id, hazirlik_dk, birim_sure_dk,
                        saat_ucreti, kalite_kontrol, fason, fason_taraf_id, aciklama, ekleyen)
                select @p1, o.sira, o.ad, o.is_merkezi_id, o.hazirlik_dk, o.birim_sure_dk,
                       o.saat_ucreti, o.kalite_kontrol, o.fason, o.fason_taraf_id,
                       o.aciklama, @p2
                  from public.urun_agaci_operasyon o where o.agac_id = @p0 order by o.sira, o.id
                """, islem, [id, yeniId, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = yeniId, kod, surum = yeniSurum,
                mesaj = $"{kod} v{yeniSurum} oluşturuldu (taslak, varsayılan değil).",
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/agac/nerede-kullaniliyor/{stokId} - ters ağaç.
        //   Hammadde fiyatı değişince etkilenen mamulleri bulmanın yolu.
        grup.MapGet("/agac/nerede-kullaniliyor/{stokId:int}", async (
            int stokId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select a.id, a.kod, a.ad, a.surum, s.miktar, s.fire_yuzde,
                       m.kod || ' · ' || m.ad as mamul, a.durum
                  from public.urun_agaci_satir s
                  join public.urun_agaci a on a.id = s.agac_id
                  join public.stok m on m.id = a.stok_id
                 where s.bilesen_stok_id = @p0
                 order by a.kod, a.surum desc
                """, [stokId],
                o => new { Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                           Surum = o.GetInt16(3), Miktar = o.GetDecimal(4),
                           FireYuzde = o.GetDecimal(5), Mamul = o.GetString(6),
                           Durum = o.GetInt16(7) }, iptal);

            return Results.Ok(new { stokId, kayitlar = liste, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------- emir ---

        // POST /api/uretim/emri - emir aç ve ağacı emre kopyala.
        grup.MapPost("/emri", async (
            EmirIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Ekle);

            if (istek.Adet <= 0)
                throw GentegreHatasi.Dogrulama("Emir adedi sıfırdan büyük olmalı.",
                    [new("adet", "Adet sıfırdan büyük olmalı.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // AĞAÇ SEÇİMİ: verilmemişse mamulün AKTİF VARSAYILAN ağacı. Varsayılan
            //   yoksa emir açılmaz - "hangi tarifle üreteceğiz" sorusu cevapsız
            //   bir emir, malzemesiz bir emirdir.
            var agac = await AgacBulAsync(baglanti, islem, istek.AgacId, istek.StokId, iptal);

            var no = await baglanti.TekDegerAsync<string>(
                "select public.fn_uretim_emri_no(@p0, current_date)", islem,
                [baglam.SubeId ?? 0], iptal) ?? "";

            var emirId = await baglanti.TekDegerAsync<int>("""
                insert into public.uretim_emri
                       (no, tur, durum, stok_id, agac_id, agac_kod, agac_surum, adet,
                        birim, plan_bas, termin, sarf_depo_id, mamul_depo_id, fire_depo_id,
                        kaynak_belge_id, kaynak_satir_id, ust_emir_id, mamul_lot,
                        aciklama, sube_id, ekleyen)
                values (@p0, @p1, 1, @p2, @p3, @p4, @p5, @p6, @p7, @p8::date, @p9::date,
                        @p10, @p11, @p12, @p13, @p14, @p15, @p0, @p16, @p17, @p18)
                returning id
                """, islem,
                [no, istek.Tur ?? (short)(istek.UstEmirId is > 0 ? 4 : 2), istek.StokId,
                 agac.Id, agac.Kod, agac.Surum, istek.Adet, agac.Birim,
                 istek.PlanBas?.ToDateTime(TimeOnly.MinValue),
                 istek.Termin?.ToDateTime(TimeOnly.MinValue),
                 istek.SarfDepoId ?? agac.SarfDepoId, istek.MamulDepoId ?? agac.MamulDepoId,
                 agac.FireDepoId, istek.KaynakBelgeId, istek.KaynakSatirId, istek.UstEmirId,
                 istek.Aciklama ?? "", baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

            var (bilesen, operasyon) = await AgactanKopyalaAsync(
                baglanti, islem, emirId, agac.Id, istek.Adet, agac.Cikti,
                baglam.KullaniciId, iptal);

            await PlanMaliyetiYazAsync(baglanti, islem, emirId, iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = emirId, no, bilesen, operasyon,
                mesaj = $"{no} açıldı: {bilesen} bileşen, {operasyon} operasyon.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/agactan-yenile
        //   YALNIZ TASLAK/ONAYLI: üretimdeki emirde sürüm sabittir, yoksa
        //   sarf edilmiş malzemenin karşılığı olmayan bir satır listesi kalır.
        grup.MapPost("/emri/{id:int}/agactan-yenile", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var emir = await EmirOkuAsync(baglanti, islem, id, iptal);
            if (emir.Durum is not (Taslak or Onayli))
                throw GentegreHatasi.IsKurali(
                    "Ağaçtan yenileme yalnız Taslak ve Onaylı emirde yapılabilir.");
            if (emir.AgacId is not > 0)
                throw GentegreHatasi.IsKurali("Emre bağlı bir ürün ağacı yok.");

            // Rezerv varsa önce bırakılır: satırlar silinecek, stok_durum'daki
            //   karşılığı asılı kalırdı.
            await RezerveUygulaAsync(baglanti, islem, id, false, iptal);

            await baglanti.CalistirAsync(
                "delete from public.uretim_emri_satir where emir_id = @p0", islem, [id], iptal);
            await baglanti.CalistirAsync(
                "delete from public.uretim_operasyon where emir_id = @p0", islem, [id], iptal);

            var cikti = await baglanti.TekDegerAsync<decimal>("""
                select coalesce(nullif(cikti_miktar, 0), 1) from public.urun_agaci where id = @p0
                """, islem, [emir.AgacId], iptal);

            var (bilesen, operasyon) = await AgactanKopyalaAsync(
                baglanti, islem, id, emir.AgacId!.Value, emir.Adet, cikti,
                baglam.KullaniciId, iptal);

            await PlanMaliyetiYazAsync(baglanti, islem, id, iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, bilesen, operasyon,
                mesaj = $"Ağaçtan yenilendi: {bilesen} bileşen, {operasyon} operasyon.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/rezerve?ac=true|false
        grup.MapPost("/emri/{id:int}/rezerve", async (
            int id, bool? ac, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var acMi = ac ?? true;
            var etkilenen = await RezerveUygulaAsync(baglanti, islem, id, acMi, iptal);
            await islem.CommitAsync(iptal);

            var hazirlik = await veri.TekDegerAsync<decimal>(
                "select public.fn_uretim_malzeme_hazirlik(@p0)", [id], iptal);

            return Results.Ok(new { id, satir = etkilenen, hazirlik,
                mesaj = acMi ? $"{etkilenen} satır rezerve edildi."
                             : $"{etkilenen} satırın rezervi bırakıldı.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/onayla
        grup.MapPost("/emri/{id:int}/onayla", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.onayla", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync("""
                update public.uretim_emri
                   set durum = 2, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum = 1
                """, [id, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Yalnız Taslak emir onaylanabilir.");

            return Results.Ok(new { id, durum = Onayli, mesaj = "Emir onaylandı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/baslat - emri üretime al; sarf modu "tek
        //   seferde" ise bütün bileşenler tek sarf fişiyle çıkar.
        grup.MapPost("/emri/{id:int}/baslat", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, BelgeDeposu belgeDepo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var emir = await EmirOkuAsync(baglanti, null, id, iptal);
            if (emir.Durum != Onayli)
                throw GentegreHatasi.IsKurali(
                    "Yalnız Onaylı emir başlatılabilir (önce Onayla).");

            int? belgeId = null;
            if (emir.SarfModu == 1)
                belgeId = await SarfEtAsync(baglanti, veri, belgeDepo, baglam, emir,
                                            null, iptal);

            await veri.CalistirAsync("""
                update public.uretim_emri
                   set durum = 4, gercek_bas = coalesce(gercek_bas, now()),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, [id, baglam.KullaniciId], iptal);

            return Results.Ok(new { id, durum = Uretimde, sarfBelgeId = belgeId,
                mesaj = belgeId is null ? "Emir üretime alındı."
                                        : "Emir üretime alındı, sarf fişi kesildi.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/sarf - kısmi/seçili sarf (geri-yıkama ve
        //   eksik malzeme sonradan gelince kullanılır).
        grup.MapPost("/emri/{id:int}/sarf", async (
            int id, SarfIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var emir = await EmirOkuAsync(baglanti, null, id, iptal);
            if (emir.Durum is < Onayli or >= Tamamlandi)
                throw GentegreHatasi.IsKurali(
                    "Sarf yalnız Onaylı ya da üretimdeki emirde yapılabilir.");

            var belgeId = await SarfEtAsync(baglanti, veri, belgeDepo, baglam, emir,
                                            istek?.Satirlar, iptal);
            if (belgeId is null)
                throw GentegreHatasi.IsKurali("Sarf edilecek malzeme kalmadı.");

            return Results.Ok(new { id, belgeId, mesaj = "Sarf fişi kesildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/mamul-giris - kısmi parti girişi.
        //   LOT = EMİR NO: kısmi girişlerin hepsi aynı lota yazılır, böylece
        //   "bu parti hangi emirden çıktı" izi tek anahtarda kalır.
        grup.MapPost("/emri/{id:int}/mamul-giris", async (
            int id, MiktarIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            if (istek.Adet <= 0)
                throw GentegreHatasi.Dogrulama("Giriş adedi sıfırdan büyük olmalı.",
                    [new("adet", "Adet sıfırdan büyük olmalı.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            var emir = await EmirOkuAsync(baglanti, null, id, iptal);
            if (emir.Durum is < Onayli or >= Tamamlandi)
                throw GentegreHatasi.IsKurali(
                    "Mamul girişi yalnız onaylı/üretimdeki emirde yapılabilir.");
            if (emir.MamulDepoId is not > 0)
                throw GentegreHatasi.IsKurali("Emirde mamul deposu seçili değil.");

            // GEÇİCİ BİRİM FİYAT = PLAN MALİYET. Kapanışta gerçek fiyatla
            //   güncellenir; sıfır fiyatla girmek stok ortalamasını bozardı.
            var birim = istek.BirimFiyat
                     ?? (emir.Adet > 0 ? decimal.Round(emir.PlanToplam / emir.Adet, 4) : 0m);

            var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = BelgeTuru.UretimGirisi,
                ["tipi"] = 1,
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["girisDepoId"] = emir.MamulDepoId,
                ["subeId"] = baglam.SubeId ?? emir.SubeId,
                ["kaynakTur"] = BelgeTuru.KaynakTurUretimEmri,
                ["kaynakId"] = id,
                ["aciklama"] = $"Üretim girişi · {emir.No}"
                             + (istek.Aciklama is { Length: > 0 } a ? $" · {a}" : ""),
            };

            var satir = SatirGovdesi(new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 1,
                ["stokId"] = emir.StokId,
                ["miktar"] = istek.Adet,
                ["birimFiyat"] = birim,
                ["kdv"] = 0,
                ["dovizCinsi"] = "TL",
                ["girisDepoId"] = emir.MamulDepoId,
                ["izlemeKodu"] = emir.MamulLot,
                ["aciklama"] = emir.No,
                ["sira"] = 1,
            });

            var (belgeId, uyarilar) = await belgeDepo.KaydetAsync(
                belge, [satir], new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

            // ÜRETİLEN ADET VE DURUM: emir adedine ulaşınca Tamamlandı, altındaysa
            //   Kısmi. Durum burada hesaplanır ki liste ekranı ayrı bir işe
            //   bağımlı olmasın.
            await veri.CalistirAsync("""
                update public.uretim_emri
                   set uretilen_adet = uretilen_adet + @p1,
                       durum = case when uretilen_adet + @p1 >= adet then 6 else 5 end,
                       gercek_bit = case when uretilen_adet + @p1 >= adet
                                         then now() else gercek_bit end,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, [id, istek.Adet, baglam.KullaniciId], iptal);

            var yeni = await veri.TekAsync("""
                select uretilen_adet, adet, durum from public.uretim_emri where id = @p0
                """, [id],
                o => new { Uretilen = o.GetDecimal(0), Adet = o.GetDecimal(1),
                           Durum = o.GetInt16(2) }, iptal);

            return Results.Ok(new { id, belgeId, uyarilar,
                uretilen = yeni?.Uretilen, adet = yeni?.Adet, durum = yeni?.Durum,
                mesaj = $"{istek.Adet:0.##} adet mamul girişi yapıldı ({emir.MamulLot}).",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/fire - ret/fire çıkışı.
        grup.MapPost("/emri/{id:int}/fire", async (
            int id, FireIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            if (istek.Adet <= 0)
                throw GentegreHatasi.Dogrulama("Fire adedi sıfırdan büyük olmalı.",
                    [new("adet", "Adet sıfırdan büyük olmalı.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            var emir = await EmirOkuAsync(baglanti, null, id, iptal);

            var depoId = emir.FireDepoId ?? emir.SarfDepoId
                ?? throw GentegreHatasi.IsKurali(
                    "Fire için depo bulunamadı - emirde fire ya da sarf deposu seçin.");

            var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = BelgeTuru.FireCikisi,
                ["tipi"] = 1,
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["cikisDepoId"] = depoId,
                ["subeId"] = baglam.SubeId ?? emir.SubeId,
                ["kaynakTur"] = BelgeTuru.KaynakTurUretimEmri,
                ["kaynakId"] = id,
                ["aciklama"] = $"Fire · {emir.No}"
                             + (istek.Neden is { Length: > 0 } n ? $" · {n}" : ""),
            };

            var satir = SatirGovdesi(new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 1,
                ["stokId"] = istek.StokId,
                ["miktar"] = istek.Adet,
                ["birimFiyat"] = 0m,
                ["kdv"] = 0,
                ["dovizCinsi"] = "TL",
                ["cikisDepoId"] = depoId,
                ["aciklama"] = istek.Neden ?? "",
                ["sira"] = 1,
            });

            var (belgeId, _) = await belgeDepo.KaydetAsync(
                belge, [satir], new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

            // Fire adedi yalnız MAMUL firesinde emrin sayacına işlenir; bileşen
            //   firesi zaten sarfın içindedir.
            if (istek.StokId == emir.StokId)
                await veri.CalistirAsync("""
                    update public.uretim_emri set fire_adet = fire_adet + @p1,
                           degistiren = @p2, degistirme_tarihi = now()
                     where id = @p0
                    """, [id, istek.Adet, baglam.KullaniciId], iptal);

            return Results.Ok(new { id, belgeId, mesaj = "Fire kaydedildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/maliyet-kapat
        grup.MapPost("/emri/{id:int}/maliyet-kapat", async (
            int id, MaliyetIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.maliyet", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var emir = await EmirOkuAsync(baglanti, islem, id, iptal);
            if (emir.Uretilen <= 0)
                throw GentegreHatasi.IsKurali(
                    "Mamul girişi yapılmamış emrin maliyeti kapatılamaz.");

            // MALZEME: sarf fişlerinin tutarı (hareket anındaki fiyat).
            var malzeme = await baglanti.TekDegerAsync<decimal>("""
                select coalesce(sum(bs.tutar), 0)
                  from public.belge b join public.belge_satir bs on bs.belge_id = b.id
                 where b.kaynak_tur = @p1 and b.kaynak_id = @p0 and b.tur = @p2
                """, islem, [id, BelgeTuru.KaynakTurUretimEmri, BelgeTuru.SarfCikisi], iptal);

            // İŞÇİLİK: zaman kayıtları (tetik süre × ücret olarak yazdı).
            var iscilik = await baglanti.TekDegerAsync<decimal>(
                "select coalesce(sum(tutar), 0) from public.uretim_zaman where emir_id = @p0",
                islem, [id], iptal);

            var fire = await baglanti.TekDegerAsync<decimal>("""
                select coalesce(sum(bs.tutar), 0)
                  from public.belge b join public.belge_satir bs on bs.belge_id = b.id
                 where b.kaynak_tur = @p1 and b.kaynak_id = @p0 and b.tur = @p2
                """, islem, [id, BelgeTuru.KaynakTurUretimEmri, BelgeTuru.FireCikisi], iptal);

            var gugYuzde = istek?.GugYuzde ?? 0m;
            var gug = decimal.Round((malzeme + iscilik) * gugYuzde / 100, 4);
            var toplam = malzeme + iscilik + gug;
            var birim = decimal.Round(toplam / emir.Uretilen, 4);
            var planBirim = emir.Adet > 0 ? decimal.Round(emir.PlanToplam / emir.Adet, 4) : 0m;
            var fark = planBirim > 0
                     ? decimal.Round((birim - planBirim) * 100 / planBirim, 2) : 0m;

            await baglanti.CalistirAsync("""
                insert into public.uretim_maliyet
                       (emir_id, malzeme, iscilik, gug, fire, toplam, uretilen_adet,
                        birim, plan_birim, fark_yuzde, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10)
                """, islem,
                [id, malzeme, iscilik, gug, fire, toplam, emir.Uretilen, birim,
                 planBirim, fark, baglam.KullaniciId], iptal);

            // MAMUL GİRİŞ FİYATLARI GERÇEKLEŞENLE GÜNCELLENİR: giriş anında plan
            //   maliyetle yazılmıştı. Güncellenmezse stok ağırlıklı ortalaması
            //   kalıcı olarak plan fiyatla kalır.
            await baglanti.CalistirAsync("""
                update public.belge_satir bs
                   set birim_fiyat = @p2, iskontolu_birim_fiyat = @p2,
                       tutar = round(bs.miktar * @p2, 4)
                  from public.belge b
                 where b.id = bs.belge_id and b.kaynak_tur = @p1 and b.kaynak_id = @p0
                   and b.tur = @p3
                """, islem, [id, BelgeTuru.KaynakTurUretimEmri, birim,
                             BelgeTuru.UretimGirisi], iptal);

            await baglanti.CalistirAsync("""
                update public.uretim_emri
                   set gercek_malzeme = @p1, gercek_iscilik = @p2, gercek_toplam = @p3,
                       degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, malzeme, iscilik, toplam, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, malzeme, iscilik, gug, fire, toplam,
                uretilen = emir.Uretilen, birim, planBirim, farkYuzde = fark,
                mesaj = $"Maliyet kapandı: birim {birim:0.00} (plan {planBirim:0.00}).",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/kapat - kalan rezervi bırak, emri kilitle.
        grup.MapPost("/emri/{id:int}/kapat", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.maliyet", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var emir = await EmirOkuAsync(baglanti, islem, id, iptal);
            if (emir.Durum is not (Kismi or Tamamlandi))
                throw GentegreHatasi.IsKurali(
                    "Yalnız kısmi ya da tamamlanmış emir kapatılabilir.");

            var kapanis = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.uretim_maliyet where emir_id = @p0",
                islem, [id], iptal);
            if (kapanis == 0)
                throw GentegreHatasi.IsKurali(
                    "Önce maliyet kapanışı yapılmalı (Maliyet Kapat).");

            await RezerveUygulaAsync(baglanti, islem, id, false, iptal);
            await baglanti.CalistirAsync("""
                update public.uretim_emri
                   set durum = 7, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            await baglanti.CalistirAsync("""
                update public.uretim_operasyon set durum = 4
                 where emir_id = @p0 and durum < 4
                """, islem, [id], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, durum = Kapatildi, mesaj = "Emir kapatıldı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/iptal
        //   v1'de yalnız Taslak/Onaylı iptal edilebilir. Üretime başlamış emirde
        //   sarf ve girişlerin TERS KAYITLA kapatılması gerekir; onu sessizce
        //   yapmak stok bakiyesini bozar, o yüzden Faz 2'ye bırakıldı.
        grup.MapPost("/emri/{id:int}/iptal", async (
            int id, IptalIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Degistir);

            if (istek?.Neden is not { Length: > 0 })
                throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                    [new("neden", "İptal nedeni yazılmalı.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var emir = await EmirOkuAsync(baglanti, islem, id, iptal);
            if (emir.Durum is not (Taslak or Onayli))
                throw GentegreHatasi.IsKurali(
                    "Üretime başlamış emir iptal edilemez; sarf ve girişler ters "
                  + "kayıtla kapatılmalıdır.");

            await RezerveUygulaAsync(baglanti, islem, id, false, iptal);
            await baglanti.CalistirAsync("""
                update public.uretim_emri
                   set durum = 0, iptal_neden = @p1, degistiren = @p2,
                       degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, istek.Neden, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, durum = Iptal, mesaj = "Emir iptal edildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/emri/{id}/eksik-malzeme - "Malz. %" penceresinin verisi.
        grup.MapGet("/emri/{id:int}/eksik-malzeme", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select s.id, st.kod, st.ad, s.gerekli, s.rezerve, s.sarf_edilen,
                       coalesce(d.kalan, 0) as mevcut,
                       greatest(0, s.gerekli - s.sarf_edilen - coalesce(d.kalan, 0)) as eksik
                  from public.uretim_emri_satir s
                  join public.uretim_emri e on e.id = s.emir_id
                  join public.stok st on st.id = s.bilesen_stok_id
                  left join public.stok_durum d on d.stok_id = s.bilesen_stok_id
                       and d.depo_id = coalesce(s.depo_id, e.sarf_depo_id)
                 where s.emir_id = @p0
                 order by s.sira, s.id
                """, [id],
                o => new { Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                           Gerekli = o.GetDecimal(3), Rezerve = o.GetDecimal(4),
                           SarfEdilen = o.GetDecimal(5), Mevcut = o.GetDecimal(6),
                           Eksik = o.GetDecimal(7) }, iptal);

            var hazirlik = await veri.TekDegerAsync<decimal>(
                "select public.fn_uretim_malzeme_hazirlik(@p0)", [id], iptal);

            return Results.Ok(new { id, hazirlik, satirlar = liste,
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    // ======================================================================
    //  YARDIMCILAR
    // ======================================================================

    private sealed record AgacBilgisi(int Id, string Kod, short Surum, short Birim,
                                      decimal Cikti, int? SarfDepoId, int? MamulDepoId,
                                      int? FireDepoId);

    private static async Task<AgacBilgisi> AgacBulAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int? agacId, int stokId, CancellationToken iptal)
    {
        var sql = agacId is > 0
            ? """
              select id, kod, surum, birim, coalesce(nullif(cikti_miktar, 0), 1),
                     sarf_depo_id, mamul_depo_id, fire_depo_id
                from public.urun_agaci where id = @p0
              """
            : """
              select id, kod, surum, birim, coalesce(nullif(cikti_miktar, 0), 1),
                     sarf_depo_id, mamul_depo_id, fire_depo_id
                from public.urun_agaci
               where stok_id = @p0 and durum = 0
               order by varsayilan desc, surum desc limit 1
              """;

        return await baglanti.TekAsync(sql, islem, [agacId is > 0 ? agacId : stokId],
            o => new AgacBilgisi(o.GetInt32(0), o.GetString(1), o.GetInt16(2),
                                 o.GetInt16(3), o.GetDecimal(4),
                                 o.IsDBNull(5) ? null : o.GetInt32(5),
                                 o.IsDBNull(6) ? null : o.GetInt32(6),
                                 o.IsDBNull(7) ? null : o.GetInt32(7)), iptal)
            ?? throw GentegreHatasi.IsKurali(
                "Bu mamul için aktif ürün ağacı yok - önce ağaç tanımlayın.");
    }

    private sealed record EmirBilgisi(int Id, string No, short Durum, int StokId,
                                      int? AgacId, decimal Adet, decimal Uretilen,
                                      short SarfModu, int? SarfDepoId, int? MamulDepoId,
                                      int? FireDepoId, string MamulLot, decimal PlanToplam,
                                      int SubeId);

    private static async Task<EmirBilgisi> EmirOkuAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int id, CancellationToken iptal)
        => await baglanti.TekAsync("""
            select id, no, durum, stok_id, agac_id, adet, uretilen_adet, sarf_modu,
                   sarf_depo_id, mamul_depo_id, fire_depo_id, mamul_lot, plan_toplam,
                   sube_id
              from public.uretim_emri where id = @p0
            """, islem, [id],
            o => new EmirBilgisi(o.GetInt32(0), o.GetString(1), o.GetInt16(2),
                                 o.GetInt32(3), o.IsDBNull(4) ? null : o.GetInt32(4),
                                 o.GetDecimal(5), o.GetDecimal(6), o.GetInt16(7),
                                 o.IsDBNull(8) ? null : o.GetInt32(8),
                                 o.IsDBNull(9) ? null : o.GetInt32(9),
                                 o.IsDBNull(10) ? null : o.GetInt32(10),
                                 o.GetString(11), o.GetDecimal(12), o.GetInt32(13)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Üretim emri bulunamadı.");

    /// <summary>
    /// Ağacın bileşen ve operasyonlarını emre kopyalar.
    ///
    /// Miktar = ağaç miktarı ÷ ağaç çıktısı × emir adedi × (1 + fire%).
    /// Ağaç bir PARTİ için yazılmış olabilir (5 Lt cila); orana çevirmeden
    /// çarpmak beş katı malzeme çıkarırdı.
    /// </summary>
    private static async Task<(int Bilesen, int Operasyon)> AgactanKopyalaAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, int emirId, int agacId,
        decimal adet, decimal cikti, int kullaniciId, CancellationToken iptal)
    {
        var bilesen = await baglanti.CalistirAsync("""
            insert into public.uretim_emri_satir
                   (emir_id, sira, agac_satir_id, bilesen_stok_id, alt_agac_id, tur,
                    operasyon_sira, birim, birim_ihtiyac, fire_yuzde, gerekli, depo_id,
                    aciklama, ekleyen)
            select @p0, s.sira, s.id, s.bilesen_stok_id, s.alt_agac_id, s.tur,
                   s.operasyon_sira, s.birim,
                   round(s.miktar / @p2, 6),
                   s.fire_yuzde,
                   round(s.miktar / @p2 * @p1 * (1 + s.fire_yuzde / 100), 6),
                   s.depo_id, s.aciklama, @p3
              from public.urun_agaci_satir s
             where s.agac_id = @p4
             order by s.sira, s.id
            """, islem, [emirId, adet, cikti, kullaniciId, agacId], iptal);

        // Plan saat = (hazırlık + birim süre × adet) / 60. Hazırlık PARTİ
        //   başınadır - adetle çarpılırsa 60 adetlik emirde 60 kez kurulum
        //   yapılmış gibi görünür.
        var operasyon = await baglanti.CalistirAsync("""
            insert into public.uretim_operasyon
                   (emir_id, sira, ad, is_merkezi_id, plan_saat, saat_ucreti,
                    kk_gerekli, fason, aciklama, ekleyen)
            select @p0, o.sira, o.ad, o.is_merkezi_id,
                   round((o.hazirlik_dk + o.birim_sure_dk * @p1) / 60, 3),
                   coalesce(nullif(o.saat_ucreti, 0), im.saat_ucreti, 0),
                   o.kalite_kontrol, o.fason, o.aciklama, @p2
              from public.urun_agaci_operasyon o
              left join public.is_merkezi im on im.id = o.is_merkezi_id
             where o.agac_id = @p3
             order by o.sira, o.id
            """, islem, [emirId, adet, kullaniciId, agacId], iptal);

        // Bileşen birim maliyeti emir açılırken DONDURULUR: plan/gerçek
        //   karşılaştırması ancak sabit bir plana karşı anlamlıdır.
        await baglanti.CalistirAsync("""
            update public.uretim_emri_satir s
               set birim_maliyet = public.fn_uretim_stok_maliyeti(s.bilesen_stok_id),
                   tutar = round(s.gerekli
                                 * public.fn_uretim_stok_maliyeti(s.bilesen_stok_id), 4)
             where s.emir_id = @p0
            """, islem, [emirId], iptal);

        return (bilesen, operasyon);
    }

    private static async Task PlanMaliyetiYazAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int emirId, CancellationToken iptal)
        => await baglanti.CalistirAsync("""
            update public.uretim_emri e
               set plan_malzeme = m.malzeme,
                   plan_iscilik = m.iscilik,
                   plan_toplam  = m.malzeme + m.iscilik
              from (select coalesce((select sum(s.tutar) from public.uretim_emri_satir s
                                      where s.emir_id = @p0), 0) as malzeme,
                           coalesce((select sum(o.plan_saat * o.saat_ucreti)
                                       from public.uretim_operasyon o
                                      where o.emir_id = @p0), 0) as iscilik) m
             where e.id = @p0
            """, islem, [emirId], iptal);

    /// <summary>
    /// REZERV: stok_durum.rezerve ile emir satırı BİRLİKTE hareket eder.
    ///
    /// Rezerv, stoktan düşmez; kullanılabilir miktarı azaltır. İki yerde ayrı
    /// tutulduğu için ikisi de aynı işlemde yazılır - biri yazılıp öteki
    /// yazılamazsa depoda hayalet rezerv kalırdı.
    /// </summary>
    private static async Task<int> RezerveUygulaAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int emirId, bool ac, CancellationToken iptal)
    {
        var satirlar = await baglanti.ListeAsync("""
            select s.id, s.bilesen_stok_id,
                   coalesce(s.depo_id, e.sarf_depo_id) as depo_id,
                   s.gerekli, s.sarf_edilen, s.rezerve
              from public.uretim_emri_satir s
              join public.uretim_emri e on e.id = s.emir_id
             where s.emir_id = @p0
             order by s.id
            """, islem, [emirId],
            o => new { Id = o.GetInt32(0), StokId = o.GetInt32(1),
                       DepoId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                       Gerekli = o.GetDecimal(3), Sarf = o.GetDecimal(4),
                       Rezerve = o.GetDecimal(5) }, iptal);

        var etkilenen = 0;
        foreach (var s in satirlar)
        {
            var hedef = ac ? Math.Max(0, s.Gerekli - s.Sarf) : 0m;
            var fark = hedef - s.Rezerve;
            if (fark == 0) continue;

            if (s.DepoId is > 0)
            {
                await baglanti.CalistirAsync("""
                    insert into public.stok_durum (stok_id, depo_id, rezerve)
                    values (@p0, @p1, @p2)
                    on conflict (stok_id, depo_id)
                    do update set rezerve = greatest(0, public.stok_durum.rezerve + @p2)
                    """, islem, [s.StokId, s.DepoId, fark], iptal);
            }

            await baglanti.CalistirAsync("""
                update public.uretim_emri_satir
                   set rezerve = @p1,
                       durum = case when sarf_edilen >= gerekli then 3
                                    when sarf_edilen > 0 then 2
                                    when @p1 > 0 then 1 else 0 end
                 where id = @p0
                """, islem, [s.Id, hedef], iptal);
            etkilenen++;
        }
        return etkilenen;
    }

    /// <summary>
    /// SARF FİŞİ: bileşenler sarf deposundan çıkar.
    ///
    /// Rezerv sarf ANINDA bırakılır: mal fiilen çıktıysa artık "ayrılmış"
    /// değildir; bırakılmazsa aynı miktar hem düşmüş hem rezerve görünür.
    /// Sarf edilecek satır kalmadıysa null döner (belge açılmaz).
    /// </summary>
    private static async Task<int?> SarfEtAsync(NpgsqlConnection baglanti, VeriKaynagi veri,
        BelgeDeposu belgeDepo, IstekBaglami baglam, EmirBilgisi emir,
        SarfSatiri[]? secili, CancellationToken iptal)
    {
        if (emir.SarfDepoId is not > 0)
            throw GentegreHatasi.IsKurali("Emirde sarf deposu seçili değil.");

        // HAREKET FIYATI SARF ANINDA OKUNUR: sarf fisi satirinin tutari
        //   uretimin MALZEME MALIYETIDIR (maliyet kapanisi bu tutarlari
        //   toplar). Fiyati bos birakip "maliyet stok tarafinda" demek -
        //   radyoloji sarfinda oyle - burada maliyeti sifirlardi.
        var satirlar = await baglanti.ListeAsync("""
            select s.id, s.bilesen_stok_id, coalesce(s.depo_id, e.sarf_depo_id),
                   s.gerekli, s.sarf_edilen, s.rezerve,
                   public.fn_uretim_stok_maliyeti(s.bilesen_stok_id)
              from public.uretim_emri_satir s
              join public.uretim_emri e on e.id = s.emir_id
             where s.emir_id = @p0
             order by s.sira, s.id
            """, null, [emir.Id],
            o => new { Id = o.GetInt32(0), StokId = o.GetInt32(1), DepoId = o.GetInt32(2),
                       Gerekli = o.GetDecimal(3), Sarf = o.GetDecimal(4),
                       Rezerve = o.GetDecimal(5), Maliyet = o.GetDecimal(6) }, iptal);

        var istenen = secili?.ToDictionary(x => x.SatirId, x => x.Miktar);
        var fisSatirlari = new List<Dictionary<string, JsonElement>>();
        var cikanlar = new List<(int Id, decimal Miktar, decimal Rezerve, int StokId, int DepoId)>();
        var sira = 0;

        foreach (var s in satirlar)
        {
            var kalan = s.Gerekli - s.Sarf;
            if (kalan <= 0) continue;

            var miktar = istenen is null ? kalan
                       : istenen.TryGetValue(s.Id, out var m) ? Math.Min(m, kalan) : 0m;
            if (miktar <= 0) continue;

            fisSatirlari.Add(SatirGovdesi(new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 1,
                ["stokId"] = s.StokId,
                ["miktar"] = miktar,
                ["birimFiyat"] = s.Maliyet,   // hareket anındaki ağırlıklı ortalama
                ["kdv"] = 0,
                ["dovizCinsi"] = "TL",
                ["cikisDepoId"] = s.DepoId,
                ["aciklama"] = emir.No,
                ["sira"] = ++sira,
            }));
            cikanlar.Add((s.Id, miktar, s.Rezerve, s.StokId, s.DepoId));
        }

        if (fisSatirlari.Count == 0) return null;

        var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
        {
            ["tur"] = BelgeTuru.SarfCikisi,
            ["tipi"] = 1,
            ["belgeTarihi"] = DateTime.Now,
            ["belgeDovizi"] = "TL",
            ["dovizKuru"] = 1m,
            ["cikisDepoId"] = emir.SarfDepoId,
            ["subeId"] = baglam.SubeId ?? emir.SubeId,
            ["kaynakTur"] = BelgeTuru.KaynakTurUretimEmri,
            ["kaynakId"] = emir.Id,
            ["aciklama"] = $"Üretim sarfı · {emir.No}",
        };

        var (belgeId, _) = await belgeDepo.KaydetAsync(
            belge, fisSatirlari,
            // STOK KONTROLÜ AÇIK: elde olmayan malzeme sarf edilemez - eksi
            //   bakiye üretim maliyetini baştan yanlış kılar.
            new BelgeSecenekleri { Taslak = false, StokKontrolu = true },
            new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

        foreach (var c in cikanlar)
        {
            var birakilan = Math.Min(c.Rezerve, c.Miktar);
            if (birakilan > 0)
                await veri.CalistirAsync("""
                    update public.stok_durum
                       set rezerve = greatest(0, rezerve - @p2)
                     where stok_id = @p0 and depo_id = @p1
                    """, [c.StokId, c.DepoId, birakilan], iptal);

            await veri.CalistirAsync("""
                update public.uretim_emri_satir
                   set sarf_edilen = sarf_edilen + @p1,
                       rezerve = greatest(0, rezerve - @p2),
                       durum = case when sarf_edilen + @p1 >= gerekli then 3 else 2 end
                 where id = @p0
                """, [c.Id, c.Miktar, birakilan], iptal);
        }

        // GERÇEK MALZEME: sarf fişlerinin tutarı. Belge yazma hattı satır
        //   tutarını hareket anındaki maliyetle doldurur, biz onu toplarız.
        await veri.CalistirAsync("""
            update public.uretim_emri e
               set gercek_malzeme = coalesce((
                       select sum(bs.tutar)
                         from public.belge b join public.belge_satir bs on bs.belge_id = b.id
                        where b.kaynak_tur = @p1 and b.kaynak_id = @p0 and b.tur = @p2), 0),
                   gercek_toplam = coalesce((
                       select sum(bs.tutar)
                         from public.belge b join public.belge_satir bs on bs.belge_id = b.id
                        where b.kaynak_tur = @p1 and b.kaynak_id = @p0 and b.tur = @p2), 0)
                                 + e.gercek_iscilik
             where e.id = @p0
            """, [emir.Id, BelgeTuru.KaynakTurUretimEmri, BelgeTuru.SarfCikisi], iptal);

        return belgeId;
    }

    /// <summary>
    /// Sözlük -> BelgeDeposu'nun beklediği JsonElement satırı (radyoloji sarfı
    /// ve icmal faturasıyla aynı desen).
    /// </summary>
    private static Dictionary<string, JsonElement> SatirGovdesi(
        IDictionary<string, object?> alanlar)
    {
        var json = JsonSerializer.SerializeToElement(alanlar);
        var sozluk = new Dictionary<string, JsonElement>(StringComparer.Ordinal);
        foreach (var alan in json.EnumerateObject()) sozluk[alan.Name] = alan.Value;
        return sozluk;
    }
}
