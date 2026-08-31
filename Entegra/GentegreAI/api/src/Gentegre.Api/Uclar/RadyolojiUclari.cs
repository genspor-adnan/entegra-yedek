using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RADYOLOJİ RAPORU (283/284) - kart sözleşmesine sığmayan ekran.
///
/// Rapor bölümleri ŞABLONDAN üretilir, metinleri hekim yazar; onay iki
/// aşamalıdır (asistan ön rapor → uzman onay) ve onaydan sonra rapor
/// KİLİTLENİR. Bu akış generic kartın "alanları oku/yaz" modeline sığmadığı
/// için kendi uçları var.
/// </summary>
public static class RadyolojiUclari
{
    /// <summary>islem_log.tablo_id - rapor.</summary>
    private const int LogTabloRapor = 941;

    public sealed record BolumIstegi(int? Id, int Sira, string Baslik, string Metin, short Yazdir);
    public sealed record AlanIstegi(string AlanKod, string AlanAd, string Deger);
    public sealed record RaporIstegi(int? SablonId, IReadOnlyList<BolumIstegi>? Bolumler,
                                     IReadOnlyList<AlanIstegi>? Alanlar, short? Kritik);
    public sealed record KritikIstegi(string Bulgu, string BildirilenAd, short Yol,
                                      string GeriBildirim);

    public static void RadyolojiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/radyoloji").WithTags("Radyoloji").RequireAuthorization();

        // ------------------------------------------------- rapor ekranı ----
        // Ekranın ihtiyacı olan HER ŞEY tek istekte: istem + hasta + tetkik,
        //   rapor (varsa bölümleriyle), uygun şablonlar, makrolar, skor
        //   tanımları ve hastanın önceki tetkikleri. Beş ayrı istek atmak
        //   ekranı açılışta yavaşlatır ve yarı dolu göstermeye açık bırakır.
        grup.MapGet("/istem/{id:int}/rapor", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var istem = await baglanti.TekAsync("""
                select i.id, i.accession_no as "accessionNo", i.durum, i.oncelik, i.modalite,
                       i.hasta_id as "hastaId", coalesce(h.unvan, '') as "hastaAdi",
                       coalesce(hs.cinsiyet, 0) as cinsiyet, hs.dogum_tarihi as "dogumTarihi",
                       i.hizmet_id as "hizmetId",
                       coalesce(hz.kod, '') as "tetkikKodu", coalesce(hz.ad, '') as "tetkikAdi",
                       i.on_tani as "onTani", i.klinik_bilgi as "klinikBilgi",
                       coalesce(ih.unvan, nullif(i.dis_hekim_ad, ''), '') as "isteyen",
                       i.cekim_tarihi as "cekimTarihi", i.kritik,
                       coalesce(cz.ad, '') as "cihazAdi",
                       i.seri_sayisi as "seriSayisi", i.goruntu_sayisi as "goruntuSayisi",
                       i.study_uid as "studyUid",
                       i.belge_id as "belgeId", coalesce(ok.unvan, '') as "odeyenKurum"
                  from public.radyoloji_istem i
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.taraf_hasta hs on hs.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.taraf ih on ih.id = i.istek_hekim_id
                  left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                 where i.id = @p0
                """, null, [id], Satir, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            var hizmetId = Convert.ToInt32(istem["hizmetId"] ?? 0);
            var hastaId  = Convert.ToInt32(istem["hastaId"] ?? 0);

            var rapor = await baglanti.TekAsync("""
                select r.id, r.sablon_id as "sablonId", r.sablon_surum as "sablonSurum",
                       r.durum, r.kilit, r.ust_rapor_id as "ustRaporId",
                       coalesce(yz.unvan, '') as "yazan", r.yazma_tarihi as "yazmaTarihi",
                       coalesce(on_.unvan, '') as "onaylayan", r.onay_tarihi as "onayTarihi"
                  from public.radyoloji_rapor r
                  left join public.taraf yz on yz.id = r.yazan_id
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where r.istem_id = @p0 and r.ust_rapor_id is null
                """, null, [id], Satir, iptal);

            var bolumler = rapor is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select b.id, b.sira, b.baslik, b.metin, b.yazdir,
                           coalesce(sb.zorunlu, 0) as zorunlu
                      from public.radyoloji_rapor_bolum b
                      join public.radyoloji_rapor r on r.id = b.rapor_id
                      left join public.radyoloji_sablon_bolum sb
                             on sb.sablon_id = r.sablon_id and sb.baslik = b.baslik
                     where b.rapor_id = @p0 order by b.sira
                    """, null, [Convert.ToInt32(rapor["id"])], Satir, iptal);

            var alanlar = rapor is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select alan_kod as "alanKod", alan_ad as "alanAd", deger
                      from public.radyoloji_rapor_alan where rapor_id = @p0 order by id
                    """, null, [Convert.ToInt32(rapor["id"])], Satir, iptal);

            // Şablonlar: önce tetkike bağlı olanlar, sonra aynı modalitenin
            //   genel şablonları (tetkike özel yoksa hekim yine bir şey bulsun).
            var sablonlar = await baglanti.ListeAsync("""
                select s.id, s.kod, s.ad, s.surum, s.varsayilan,
                       case when s.hizmet_id = @p0 then 1 else 0 end as "tetkigeOzel"
                  from public.radyoloji_sablon s
                 where s.durum = 1
                   and (s.hizmet_id = @p0
                        or (s.hizmet_id is null and s.modalite = @p1))
                 order by "tetkigeOzel" desc, s.varsayilan desc, s.ad
                """, null, [hizmetId, Convert.ToInt32(istem["modalite"] ?? 0)], Satir, iptal);

            var sablonId = rapor?["sablonId"] as int?
                        ?? (sablonlar.Count > 0 ? Convert.ToInt32(sablonlar[0]["id"]) : (int?)null);

            var makrolar = sablonId is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select kisayol, ad, metin, hedef_bolum as "hedefBolum"
                      from public.radyoloji_sablon_makro where sablon_id = @p0 order by id
                    """, null, [sablonId.Value], Satir, iptal);

            var skorlar = sablonId is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select alan_kod as "alanKod", alan_ad as "alanAd", tip, secenekler,
                           zorunlu, rapora_bas as "raporaBas"
                      from public.radyoloji_sablon_alan where sablon_id = @p0 order by sira
                    """, null, [sablonId.Value], Satir, iptal);

            // Önceki tetkikler: karşılaştırma bölümü bunlardan yazılır.
            var gecmis = await baglanti.ListeAsync("""
                select i.id, i.accession_no as "accessionNo", coalesce(hz.ad, '') as "tetkikAdi",
                       coalesce(i.cekim_tarihi, i.ekleme_tarihi) as tarih,
                       coalesce(on_.unvan, '') as "raporlayan",
                       coalesce((select left(b.metin, 120) from public.radyoloji_rapor_bolum b
                                  join public.radyoloji_rapor r2 on r2.id = b.rapor_id
                                 where r2.istem_id = i.id and b.baslik ilike '%sonu%'
                                 order by b.sira limit 1), '') as "ozet"
                  from public.radyoloji_istem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where i.hasta_id = @p0 and i.id <> @p1 and i.durum > 0
                 order by coalesce(i.cekim_tarihi, i.ekleme_tarihi) desc limit 8
                """, null, [hastaId, id], Satir, iptal);

            var kritikler = await baglanti.ListeAsync("""
                select bulgu, bildirilen_ad as "bildirilenAd", yol,
                       bildirim_zamani as "bildirimZamani", geri_bildirim as "geriBildirim"
                  from public.radyoloji_kritik_bulgu where istem_id = @p0 order by id desc
                """, null, [id], Satir, iptal);

            return Results.Ok(new { istem, rapor, bolumler, alanlar, sablonlar, makrolar,
                                    skorlar, gecmis, kritikler });
        });

        // ------------------------------------------------- taslak kaydet ----
        // Rapor yoksa açılır, varsa güncellenir. Bölümler TOPLU yazılır
        //   (sil+yaz): sıra ve başlık şablondan gelir, kısmi güncelleme
        //   ikisini ayrıştırırdı.
        grup.MapPost("/istem/{id:int}/rapor", async (
            int id, RaporIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var mevcut = await baglanti.TekDegerAsync<int?>(
                "select id from public.radyoloji_rapor where istem_id = @p0 and ust_rapor_id is null",
                islem, [id], iptal);

            // KİLİT: onaylı rapor değiştirilemez - düzeltme addendum'dur.
            var kilit = mevcut is null ? 0 : await baglanti.TekDegerAsync<int>(
                "select coalesce(kilit, 0) from public.radyoloji_rapor where id = @p0",
                islem, [mevcut.Value], iptal);
            if (kilit == 1)
                throw GentegreHatasi.IsKurali(
                    "Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın.");

            int raporId;
            if (mevcut is null)
            {
                raporId = Convert.ToInt32(await baglanti.TekDegerAsync<int>("""
                    insert into public.radyoloji_rapor
                           (istem_id, sablon_id, sablon_surum, durum, yazan_id, yazma_tarihi, ekleyen)
                    select @p0, @p1,
                           coalesce((select surum from public.radyoloji_sablon where id = @p1), 1),
                           1, @p2, now()::timestamp, @p2
                    returning id
                    """, islem, [id, istek.SablonId, baglam.KullaniciId], iptal));
            }
            else
            {
                raporId = mevcut.Value;
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set sablon_id = coalesce(@p1, sablon_id),
                           degistiren = @p2, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, islem, [raporId, istek.SablonId, baglam.KullaniciId], iptal);
            }

            if (istek.Bolumler is { Count: > 0 })
            {
                await baglanti.CalistirAsync(
                    "delete from public.radyoloji_rapor_bolum where rapor_id = @p0",
                    islem, [raporId], iptal);
                foreach (var b in istek.Bolumler)
                    await baglanti.CalistirAsync("""
                        insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir)
                        values (@p0, @p1, @p2, @p3, @p4)
                        """, islem, [raporId, (short)b.Sira, b.Baslik, b.Metin ?? "", b.Yazdir], iptal);
            }

            if (istek.Alanlar is not null)
            {
                await baglanti.CalistirAsync(
                    "delete from public.radyoloji_rapor_alan where rapor_id = @p0",
                    islem, [raporId], iptal);
                foreach (var a in istek.Alanlar.Where(x => !string.IsNullOrWhiteSpace(x.Deger)))
                    await baglanti.CalistirAsync("""
                        insert into public.radyoloji_rapor_alan (rapor_id, alan_kod, alan_ad, deger)
                        values (@p0, @p1, @p2, @p3)
                        """, islem, [raporId, a.AlanKod, a.AlanAd ?? "", a.Deger], iptal);
            }

            if (istek.Kritik is { } kritik)
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set kritik = @p1 where id = @p0",
                    islem, [id, kritik], iptal);

            // İstem "Raporlanıyor"a geçer (henüz çekilmemişse dokunulmaz).
            await baglanti.CalistirAsync(
                "update public.radyoloji_istem set durum = 3 where id = @p0 and durum = 2",
                islem, [id], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { raporId });
        });

        // --------------------------------------------------- ön rapor / onay ----
        // İki aşama: asistan ÖN RAPOR gönderir (durum 2), uzman ONAYLAR
        //   (durum 3 + kilit). Onay ön koşulları veritabanında (284).
        grup.MapPost("/rapor/{id:int}/durum", async (
            int id, string hedef, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var onayMi = string.Equals(hedef, "onay", StringComparison.OrdinalIgnoreCase);
            baglam.AksiyonIste(onayMi ? "rad.rapor_onayla" : "rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);

            var engel = await baglanti.TekDegerAsync<string>(
                "select public.fn_radyoloji_rapor_onaylanabilir(@p0)", null, [id], iptal) ?? "";
            if (onayMi && engel.Length > 0) throw GentegreHatasi.IsKurali(engel);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var istemId = await baglanti.TekDegerAsync<int>(
                "select istem_id from public.radyoloji_rapor where id = @p0", islem, [id], iptal);

            if (onayMi)
            {
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set durum = 3, kilit = 1, onaylayan_id = @p1, onay_tarihi = now()::timestamp,
                           degistiren = @p1, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId], iptal);
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set durum = 5 where id = @p0", islem, [istemId], iptal);
            }
            else
            {
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set durum = 2, degistiren = @p1, degistirme_tarihi = now()::timestamp
                     where id = @p0 and coalesce(kilit, 0) = 0
                    """, islem, [id, baglam.KullaniciId], iptal);
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set durum = 4 where id = @p0", islem, [istemId], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRapor, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["durum"] = onayMi ? "Onaylandı" : "Ön rapor" },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });

        // -------------------------------------------------------- addendum ----
        // Onaylı rapor kilitlidir; düzeltme AYRI kayıt olarak eklenir ve
        //   orijinal metin korunur.
        grup.MapPost("/rapor/{id:int}/addendum", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.radyoloji_rapor
                       (istem_id, sablon_id, sablon_surum, durum, ust_rapor_id,
                        yazan_id, yazma_tarihi, ekleyen)
                select r.istem_id, r.sablon_id, r.sablon_surum, 1, r.id, @p1, now()::timestamp, @p1
                  from public.radyoloji_rapor r where r.id = @p0
                returning id
                """, null, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir)
                values (@p0, 1, 'Ek Rapor', '', 1)
                """, null, [yeni], iptal);

            return Results.Ok(new { raporId = yeni });
        });

        // ---------------------------------------------------- kritik bulgu ----
        grup.MapPost("/istem/{id:int}/kritik-bulgu", async (
            int id, KritikIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_kritik_bulgu
                       (istem_id, rapor_id, bulgu, bildiren_id, bildirilen_ad, yol,
                        geri_bildirim, ekleyen)
                select @p0,
                       (select id from public.radyoloji_rapor
                         where istem_id = @p0 and ust_rapor_id is null),
                       @p1, @p2, @p3, @p4, @p5, @p2
                """, islem, [id, istek.Bulgu ?? "", baglam.KullaniciId,
                             istek.BildirilenAd ?? "", istek.Yol, istek.GeriBildirim ?? ""], iptal);

            await baglanti.CalistirAsync(
                "update public.radyoloji_istem set kritik = 1 where id = @p0", islem, [id], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });
    }

    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }
}
