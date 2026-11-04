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

/// <summary>ÜRETİM FİŞİ - EMİR TARAFI (1253): basit seviye "Üret…" (emirden fiş), serbest bırakma ön kontrolleri (uretim_emri_v2.html), emir sayaçları.</summary>
public static partial class UretimFisiUclari
{
    private static void EmirUclari(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------------- emir ---

        // POST /api/uretim/emri/{id}/uret - BASİT SEVİYE "▶ Üret…" (uretim_basit.html ②): üretilen adedi sorar, emirden
        //   fişi kurar (sarf = emir satırları × adet / emir adedi, işçilik = operasyon planı oranlı, çıktı = mamul),
        //   gerçekleştirir, emir sayaçlarını yazar; emir dolunca Tamamlandı. Standart seviyede de çalışır (kısmi giriş fişle).
        grup.MapPost("/emri/{id:int}/uret", async (int id, UretIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, BelgeDeposu belgeDepo,
                                                   LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.fis", Islem.Ekle);
            if (istek.Adet <= 0)
                throw GentegreHatasi.Dogrulama("Üretilen adet sıfırdan büyük olmalı.", new AlanHatasi("adet", "Sıfırdan büyük olmalı."));

            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var (seviye, _) = await SeviyeOkuAsync(b, t, iptal);
            var emir = await b.TekAsync("""
                select e.id, e.no, e.durum, e.stok_id, e.agac_id, e.agac_surum, e.adet, e.uretilen_adet, e.sarf_depo_id,
                       e.mamul_depo_id, e.fire_depo_id, e.birim, e.sube_id, e.mamul_lot
                  from public.uretim_emri e where e.id = @p0 for update
                """, t, [id],
                o => new { Id = o.GetInt32(0), No = o.GetString(1), Durum = o.GetInt16(2), StokId = o.GetInt32(3),
                           AgacId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), AgacSurum = o.GetInt16(5), Adet = o.GetDecimal(6),
                           Uretilen = o.GetDecimal(7), SarfDepoId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
                           MamulDepoId = o.IsDBNull(9) ? (int?)null : o.GetInt32(9), FireDepoId = o.IsDBNull(10) ? (int?)null : o.GetInt32(10),
                           Birim = o.GetInt16(11), SubeId = o.GetInt32(12), Lot = o.GetString(13) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Üretim emri bulunamadı.");
            // Basit seviyede onay adımı yok: taslak emirden de üretilir. Üst seviyede onaylı / serbest / üretimde / kısmi.
            var izinli = seviye == SeviyeBasit ? emir.Durum is >= 1 and <= 5 : emir.Durum is >= 2 and <= 5;
            if (!izinli) throw GentegreHatasi.IsKurali("Bu durumdaki emirden üretim yapılamaz (iptal / tamamlanmış / kapatılmış).");
            if (seviye == SeviyeDenetimli && emir.Durum == 2)
                throw GentegreHatasi.IsKurali("Denetimli seviyede emir atölyeye SERBEST BIRAKILMADAN üretim yapılamaz (ön kontroller).");
            if (emir.SarfDepoId is not > 0) throw GentegreHatasi.IsKurali("Emirde sarf deposu seçili değil.");

            // Fiş satırları emrin KENDİ satırlarından (ağaç emre kopyalanmış): birim ihtiyaç × adet × (1 + fire%).
            var sarf = await b.ListeAsync("""
                select s.bilesen_stok_id, s.birim_ihtiyac, s.fire_yuzde, s.birim, coalesce(s.depo_id, 0)
                  from public.uretim_emri_satir s where s.emir_id = @p0 and s.alt_emir_id is null order by s.sira, s.id
                """, t, [id], o => new { StokId = o.GetInt32(0), BirimIhtiyac = o.GetDecimal(1), Fire = o.GetDecimal(2),
                                        Birim = o.GetInt16(3), DepoId = o.GetInt32(4) }, iptal);
            var opr = await b.ListeAsync("""
                select o.ad, o.plan_saat, o.saat_ucreti, o.is_merkezi_id from public.uretim_operasyon o where o.emir_id = @p0 order by o.sira, o.id
                """, t, [id], o => new { Ad = o.GetString(0), PlanSaat = o.GetDecimal(1), Ucret = o.GetDecimal(2),
                                        IsMerkeziId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3) }, iptal);
            var oran = emir.Adet > 0 ? istek.Adet / emir.Adet : 1m;
            var satirlar = new List<FisSatirIstegi>();
            foreach (var s in sarf)
                satirlar.Add(new(1, s.StokId, null, null, false, s.BirimIhtiyac, 0,
                    decimal.Round(s.BirimIhtiyac * istek.Adet * (1 + s.Fire / 100), 6), s.Birim, 0, false, 1, null, emir.No));
            foreach (var o in opr)
            {
                var saat = decimal.Round(o.PlanSaat * oran, 3);
                if (saat <= 0 || o.Ucret <= 0) continue;
                satirlar.Add(new(2, null, null, o.Ad, false, 0, saat, saat, 0, o.Ucret, false, 1, null, "operasyon planı"));
            }
            if (istek.FireStokId is > 0 && istek.FireAdet is > 0)
                satirlar.Add(new(3, istek.FireStokId, null, null, false, 0, 0, istek.FireAdet.Value, 0, 0, false, 1, null, istek.FireNeden ?? ""));
            satirlar.Add(new(4, emir.StokId, null, null, true, 1, istek.Adet, istek.Adet, emir.Birim, 0, false, 1, null, "ana ürün"));

            var fisIstek = new FisIstegi(emir.StokId, emir.AgacId, id, istek.Adet, istek.Tarih ?? Saat.Simdi, null,
                emir.SarfDepoId, emir.MamulDepoId ?? emir.SarfDepoId, null, null, null, null, emir.Lot, 2, true,
                string.IsNullOrWhiteSpace(istek.Aciklama) ? $"Üretim emri {emir.No}" : istek.Aciklama, satirlar.ToArray(), null, null,
                Gerceklestir: true, istek.EksiyeIzin, null);
            var no = await b.TekDegerAsync<string>("select public.fn_uretim_fisi_no(@p0, @p1::date)", t,
                [baglam.SubeId ?? 0, (fisIstek.Bas ?? Saat.Simdi).Date], iptal) ?? "";
            var fisId = await b.TekDegerAsync<int>("""
                insert into public.uretim_fisi
                       (no, durum, seviye, stok_id, agac_id, agac_surum, emir_id, miktar, birim, bas, sarf_depo_id, giris_depo_id,
                        parti_no, maliyet_yontemi, otomatik_hesap, aciklama, sube_id, ekleyen)
                values (@p0, 1, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, 2, 1, @p12, @p13, @p14)
                returning id
                """, t, [no, seviye, emir.StokId, emir.AgacId, emir.AgacSurum, id, istek.Adet, emir.Birim, fisIstek.Bas,
                         emir.SarfDepoId, emir.MamulDepoId ?? emir.SarfDepoId, emir.Lot, fisIstek.Aciklama,
                         baglam.SubeId ?? emir.SubeId, baglam.KullaniciId], iptal);
            await SatirlariYazAsync(b, t, fisId, fisIstek, baglam.KullaniciId, iptal);
            await log.YazAsync(b, t, LogIslemi.Ekle, LogFis, fisId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { no, emirId = id, emirNo = emir.No, adet = istek.Adet }, stokId: emir.StokId, iptal: iptal);
            var uyarilar = await GerceklestirAsync(b, t, belgeDepo, log, baglam, fisId, istek.EksiyeIzin, iptal);
            await t.CommitAsync(iptal);

            var yeni = await b.TekAsync("select uretilen_adet, adet, durum from public.uretim_emri where id = @p0", null, [id],
                o => new { Uretilen = o.GetDecimal(0), Adet = o.GetDecimal(1), Durum = o.GetInt16(2) }, iptal);
            return Results.Ok(new { id, fisId, fisNo = no, uyarilar, uretilen = yeni?.Uretilen, adet = yeni?.Adet, durum = yeni?.Durum,
                mesaj = $"{istek.Adet:0.##} adet üretildi, {no} kesildi" + (yeni?.Durum == 6 ? "; emir tamamlandı." : "."),
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/emri/{id}/on-kontrol - SERBEST BIRAKMA ÖN KONTROLLERİ (uretim_emri_v2.html, ISO 13485 §7.5.1).
        //   sonuc 1 uygun · 0 uygunsuz · -1 takip edilmiyor (kalibrasyon, personel yetkinliği, ortam kaydı bu sürümde
        //   izlenmez - uydurma "uygun" yazılmaz, açıkça söylenir).
        grup.MapGet("/emri/{id:int}/on-kontrol", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var k = await OnKontrolAsync(b, null, id, iptal);
            return Results.Ok(new { id, kontroller = k.Kontroller, serbestOlur = k.SerbestOlur, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/uretim/emri/{id}/serbest-birak - atölyeye serbest bırakma (durum 2 → 3). Denetimlide ön kontroller
        //   uygun + parola (e-imza, anlam "atölyeye serbest bırakıldı"); standartta parola istenmez.
        grup.MapPost("/emri/{id:int}/serbest-birak", async (int id, EmirSerbestIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                                             KullaniciDeposu kullanicilar, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim.onayla", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var t = await b.BeginTransactionAsync(iptal);
            var (seviye, _) = await SeviyeOkuAsync(b, t, iptal);
            var durum = await b.TekDegerAsync<short>("select durum from public.uretim_emri where id = @p0 for update", t, [id], iptal);
            if (durum != 2) throw GentegreHatasi.IsKurali("Yalnız Onaylı emir serbest bırakılır.");
            var k = await OnKontrolAsync(b, t, id, iptal);
            if (seviye == SeviyeDenetimli)
            {
                if (!k.SerbestOlur)
                    throw GentegreHatasi.IsKurali("Ön kontroller geçmedi: " + string.Join("; ",
                        k.Kontroller.Where(x => x.Sonuc == 0).Select(x => $"{x.Ad} ({x.Kural})")));
                if (string.IsNullOrWhiteSpace(istek?.Gerekce))
                    throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.", new AlanHatasi("gerekce", "Gerekçe yazılmalı."));
                await ParolaDogrulaAsync(kullanicilar, baglam.KullaniciId, istek.Parola, iptal);
            }
            // Liste kolonu (1254): ön kontrol özeti serbest bırakma anında emre yazılır ("7/7 ✍"); satır başına yeniden hesaplanmaz.
            var ozet = k.Kontroller.Count(x => x.Sonuc == 1) + "/" + k.Kontroller.Count + (seviye == SeviyeDenetimli ? " ✍" : "");
            await b.CalistirAsync("update public.uretim_emri set durum = 3, on_kontrol = @p2, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 2",
                t, [id, baglam.KullaniciId, ozet], iptal);
            await log.YazAsync(b, t, LogIslemi.Degistir, LogEmir, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = 3, durumAdi = "Serbest bırakıldı", eImza = seviye == SeviyeDenetimli, anlam = "atölyeye serbest bırakıldı",
                      gerekce = istek?.Gerekce ?? "", onKontrol = k.Kontroller.Count(x => x.Sonuc == 1) + "/" + k.Kontroller.Count }, iptal: iptal);
            await t.CommitAsync(iptal);
            return Results.Ok(new { id, durum = 3, mesaj = "Emir atölyeye serbest bırakıldı.", izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/uretim/emri/{id}/fisler - emre bağlı üretim fişleri (emir kartı "Üretim Girişleri" sekmesi).
        grup.MapGet("/emri/{id:int}/fisler", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("uretim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var fisler = await b.ListeAsync("""
                select f.id, f.no, f.durum, f.bas, f.uretilen, f.birim_maliyet, f.toplam, f.parti_no,
                       coalesce((select sum(s.miktar) from public.uretim_fisi_satir s where s.fis_id = f.id and s.grup = 3), 0)
                  from public.uretim_fisi f where f.emir_id = @p0 order by f.bas desc, f.id desc
                """, null, [id], o => new { id = o.GetInt32(0), no = o.GetString(1), durum = (int)o.GetInt16(2),
                                            tarih = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3), uretilen = o.GetDecimal(4),
                                            birimMaliyet = o.GetDecimal(5), toplam = o.GetDecimal(6), partiNo = o.GetString(7), fire = o.GetDecimal(8) }, iptal);
            return Results.Ok(new { fisler, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// EMİR SAYAÇLARI: fiş gerçekleşince üretilen (+ana), fire (+mamul firesi), satır sarf_edilen (+bileşen miktarı), gerçek
    /// malzeme (60 ve 61 kaynaklı sarf belgeleri) ve durum (kısmi / tamamlandı). Ters kayıtta tersi; dolmuş emir yeniden açılır.
    /// </summary>
    private static async Task EmirSayacAsync(NpgsqlConnection b, NpgsqlTransaction t, int emirId, int fisId, bool geri, int kullaniciId, CancellationToken iptal)
    {
        var isaret = geri ? -1 : 1;
        var e = await b.TekAsync("select stok_id, durum from public.uretim_emri where id = @p0 for update", t, [emirId],
            o => new { StokId = o.GetInt32(0), Durum = o.GetInt16(1) }, iptal);
        if (e is null || e.Durum is 0 or 7) return;
        var satirlar = await b.ListeAsync("select grup, stok_id, miktar, ana_urun from public.uretim_fisi_satir where fis_id = @p0", t, [fisId],
            o => new { Grup = o.GetInt16(0), StokId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), Miktar = o.GetDecimal(2), Ana = o.GetInt16(3) == 1 }, iptal);
        var uretilen = satirlar.Where(s => s.Grup == 4 && s.Ana).Sum(s => s.Miktar) * isaret;
        var fire = satirlar.Where(s => s.Grup == 3 && s.StokId == e.StokId).Sum(s => s.Miktar) * isaret;
        foreach (var s in satirlar.Where(s => s.Grup == 1 && s.StokId is > 0))
            await b.CalistirAsync("""
                update public.uretim_emri_satir
                   set sarf_edilen = greatest(0, sarf_edilen + @p2), rezerve = greatest(0, rezerve - greatest(0, @p2)),
                       durum = case when sarf_edilen + @p2 >= gerekli then 3 when sarf_edilen + @p2 > 0 then 2 when rezerve > 0 then 1 else 0 end
                 where emir_id = @p0 and bilesen_stok_id = @p1
                """, t, [emirId, s.StokId, s.Miktar * isaret], iptal);
        await b.CalistirAsync("""
            update public.uretim_emri e
               set uretilen_adet = greatest(0, uretilen_adet + @p1),
                   fire_adet = greatest(0, fire_adet + @p2),
                   durum = case when e.durum in (0, 7) then e.durum
                                when uretilen_adet + @p1 >= adet then 6
                                when uretilen_adet + @p1 > 0 then 5
                                when e.durum in (5, 6) then 4 else e.durum end,
                   gercek_bas = coalesce(gercek_bas, now()),
                   gercek_bit = case when uretilen_adet + @p1 >= adet then now() else null end,
                   gercek_malzeme = coalesce((select sum(bs.tutar) from public.belge bb join public.belge_satir bs on bs.belge_id = bb.id
                                               where bb.tur = @p4 and ((bb.kaynak_tur = 60 and bb.kaynak_id = e.id)
                                                  or (bb.kaynak_tur = 61 and bb.kaynak_id in (select f.id from public.uretim_fisi f where f.emir_id = e.id and f.durum <> 0)))), 0),
                   gercek_iscilik = coalesce((select sum(z.tutar) from public.uretim_zaman z where z.emir_id = e.id), 0)
                                  + coalesce((select sum(s.tutar) from public.uretim_fisi_satir s join public.uretim_fisi f on f.id = s.fis_id
                                               where f.emir_id = e.id and f.durum <> 0 and s.grup = 2), 0),
                   degistiren = @p3, degistirme_tarihi = now()
             where e.id = @p0
            """, t, [emirId, uretilen, fire, kullaniciId, BelgeTuru.SarfCikisi], iptal);
        await b.CalistirAsync("update public.uretim_emri set gercek_toplam = gercek_malzeme + gercek_iscilik where id = @p0", t, [emirId], iptal);
    }

    public sealed record OnKontrol(string Kod, string Ad, string Kural, int Sonuc);
    private sealed record OnKontrolSonucu(List<OnKontrol> Kontroller, bool SerbestOlur);

    /// <summary>Ön kontroller (uretim_emri_v2.html Ön Kontroller sekmesi). Takip edilmeyenler -1 - uydurma "uygun" yok.</summary>
    private static async Task<OnKontrolSonucu> OnKontrolAsync(NpgsqlConnection b, NpgsqlTransaction? t, int emirId, CancellationToken iptal)
    {
        var e = await b.TekAsync("""
            select e.agac_id, e.agac_kod, e.agac_surum, a.durum, a.gecerli_bas, a.gecerli_bit, a.varsayilan, e.plan_bas, e.termin,
                   public.fn_uretim_malzeme_hazirlik(e.id),
                   (select count(*) from public.uretim_emri_satir s where s.emir_id = e.id),
                   (select count(*) from public.uretim_emri_satir s where s.emir_id = e.id and s.rezerve + s.sarf_edilen >= s.gerekli),
                   (select count(*) from public.uretim_operasyon o where o.emir_id = e.id),
                   (select count(*) from public.uretim_operasyon o join public.is_merkezi im on im.id = o.is_merkezi_id where o.emir_id = e.id and im.durum <> 0),
                   (select count(*) from public.uretim_operasyon o where o.emir_id = e.id and o.is_merkezi_id is null),
                   (select coalesce(sum(o.plan_saat), 0) from public.uretim_operasyon o where o.emir_id = e.id),
                   (select coalesce(sum(im.gunluk_kapasite_saat), 0) from public.uretim_operasyon o join public.is_merkezi im on im.id = o.is_merkezi_id where o.emir_id = e.id),
                   (select count(*) from public.uretim_emri_satir s join public.urun_agaci_satir us on us.id = s.agac_satir_id
                     where s.emir_id = e.id and abs(us.miktar - s.birim_ihtiyac * (select coalesce(nullif(x.cikti_miktar, 0), 1) from public.urun_agaci x where x.id = e.agac_id)) > 0.000001)
              from public.uretim_emri e left join public.urun_agaci a on a.id = e.agac_id where e.id = @p0
            """, t, [emirId],
            o => new { AgacId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), AgacKod = o.GetString(1), AgacSurum = o.GetInt16(2),
                       AgacDurum = o.IsDBNull(3) ? (short?)null : o.GetInt16(3), GecerliBas = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                       GecerliBit = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5), Varsayilan = o.IsDBNull(6) ? (short)0 : o.GetInt16(6),
                       PlanBas = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7), Termin = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8),
                       Hazirlik = o.GetDecimal(9), Satir = o.GetInt64(10), Rezerveli = o.GetInt64(11), Opr = o.GetInt64(12), PasifIm = o.GetInt64(13),
                       ImSiz = o.GetInt64(14), PlanSaat = o.GetDecimal(15), GunlukKapasite = o.GetDecimal(16), Degisen = o.GetInt64(17) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Üretim emri bulunamadı.");
        var bugun = Saat.Bugun;
        var k = new List<OnKontrol>();
        // 1 ağaç onaylı / yürürlükte sürüm (aktif, geçerlilik aralığında, emirdeki sürüm = ağaç)
        var agacUygun = e.AgacId is > 0 && e.AgacDurum == 0 && (e.GecerliBas is null || e.GecerliBas <= bugun) && (e.GecerliBit is null || e.GecerliBit >= bugun);
        k.Add(new("agac", "Ürün ağacı onaylı sürüm",
            e.AgacId is > 0 ? $"{e.AgacKod} v{e.AgacSurum} · {(e.AgacDurum == 0 ? "aktif" : "pasif")}{(e.Varsayilan == 1 ? " · varsayılan" : "")}"
                              + (e.Degisen > 0 ? $" · {e.Degisen} bileşen ağaçtan sapmış" : "") : "emre bağlı ağaç yok",
            agacUygun ? 1 : 0));
        // 2 rota: operasyonlar ve iş merkezleri tanımlı ve aktif
        k.Add(new("rota", "Rota / iş merkezi", e.Opr == 0 ? "operasyon yok" : $"{e.Opr} operasyon · {e.PasifIm} pasif iş merkezi · {e.ImSiz} iş merkezsiz",
            e.Opr > 0 && e.PasifIm == 0 ? 1 : 0));
        // 3 malzeme mevcut ve rezerve
        k.Add(new("malzeme", "Malzeme mevcut ve rezerve", $"hazırlık %{e.Hazirlik:0} · {e.Rezerveli}/{e.Satir} kalem rezerve",
            e.Satir > 0 && e.Hazirlik >= 100 && e.Rezerveli == e.Satir ? 1 : 0));
        // 4 ekipman kalibrasyon / bakım - bu sürümde izlenmiyor
        k.Add(new("ekipman", "Ekipman kalibrasyon / bakım", "kalibrasyon kaydı bu sürümde izlenmiyor", -1));
        // 5 personel yetkinliği - izlenmiyor
        k.Add(new("personel", "Personel yetkinliği", "eğitim / yetkinlik kaydı bu sürümde izlenmiyor", -1));
        // 6 kapasite: plan saat ≤ iş günü × günlük kapasite (plan başlangıcı - termin)
        var gun = e.PlanBas is { } pb && e.Termin is { } tr && tr >= pb ? IsGunu(pb, tr) : 0;
        var kapasite = gun * e.GunlukKapasite;
        k.Add(new("kapasite", "Kapasite", e.Opr == 0 ? "operasyon yok" : gun == 0 ? "plan başlangıcı / termin boş - hesaplanamadı"
            : $"{e.PlanSaat:0.#} saat plan / {kapasite:0.#} saat kapasite ({gun} iş günü) · yük %{(kapasite > 0 ? e.PlanSaat * 100 / kapasite : 0):0}",
            e.Opr == 0 ? -1 : gun == 0 ? 0 : e.PlanSaat <= kapasite ? 1 : 0));
        // 7 ortam / hat temizliği - izlenmiyor
        k.Add(new("ortam", "Ortam / hat temizliği", "ortam izleme kaydı bu sürümde izlenmiyor", -1));
        return new OnKontrolSonucu(k, k.All(x => x.Sonuc != 0));
    }

    private static int IsGunu(DateTime bas, DateTime bit)
    {
        var n = 0;
        for (var d = bas.Date; d <= bit.Date; d = d.AddDays(1))
            if (d.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday)) n++;
        return n;
    }
}
