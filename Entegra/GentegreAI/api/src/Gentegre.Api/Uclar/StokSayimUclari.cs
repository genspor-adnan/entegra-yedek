using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// STOK SAYIMI UÇLARI (1169, sade sürüm - mockup Ekranlar/Stok/stok_sayim_karti_ver2.html).
///
/// ============ DELPHI'DEKİ ELLE DÜZELTMENİN OTOMATİK HALİ ===============
/// Kullanıcı Delphi'de sayım farkını Giriş / Çıkış fişi (tipi Sayım Fazlası /
/// Sayım Eksiği) keserek düzeltiyordu. Burada sayılan miktarlar girilir, fark
/// sunucuda hesaplanır ve "Farkları Fişle ve Kapat" AYNI iki fişi keser - yeni
/// hareket türü yok, fişler Giriş / Çıkış Fişi listelerinde de görünür.
///
/// ============ KESİT = AÇILIŞ ANI =====================================
/// Sistem miktarı sayım açıldığı andaki bakiyedir (fn_stok_sayim_satir_uret).
/// Fark = Sayılan - Sistem, yalnız SAYILAN satırda; sayılmayan satıra dokunulmaz.
///
/// ============ KAPANIŞ TEK İŞLEMDE ===================================
/// İki fiş + sayımın kapanması aynı transaction'da: fiş kesilip sayım açık
/// kalsaydı ikinci "Kapat" farkları iki kez fişlerdi.
/// </summary>
public static class StokSayimUclari
{
    /// <summary>islem_log.tablo_id — stok_sayim / satır.</summary>
    private const int LogSayim = 1620;
    private const int LogSatir = 1621;

    private const string Kod = "stok.sayim";

    public sealed class SayimIstegi
    {
        public int DepoId { get; set; }
        public short Kapsam { get; set; }
        public int? KategoriId { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class AciklamaIstegi { public string? Aciklama { get; set; } }

    public sealed class SayilanIstegi { public decimal? Sayilan { get; set; } }

    /// <summary>Okutma: barkod / stok kodu ya da (listeden seçilen) stok id. Miktar ana birim değil OKUTULAN birim.</summary>
    public sealed class OkutIstegi
    {
        public string? Kod { get; set; }
        public int? StokId { get; set; }
        public decimal Miktar { get; set; } = 1;
    }

    private sealed record Baslik(int Id, int SubeId, int DepoId, short Durum, DateTime SayimTarihi, string SayimNo);

    public static void StokSayimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/stok-sayim").WithTags("Stok Sayımı").RequireAuthorization();

        // ----------------------------------------------------------- aç ----
        grup.MapPost("", async (SayimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Ekle);
            var subeId = baglam.SubeId ?? throw GentegreHatasi.IsKurali("Sayım için çalışılan şube seçilmeli.");

            if (istek.DepoId <= 0)
                throw GentegreHatasi.Dogrulama("Depo zorunlu.", new AlanHatasi("depoId", "Sayılacak depoyu seçin."));
            if (istek.Kapsam is < 0 or > 2)
                throw GentegreHatasi.Dogrulama("Kapsam geçersiz.", new AlanHatasi("kapsam", "Tüm depo, kategori ya da seçili stoklar."));
            if (istek.Kapsam == 1 && istek.KategoriId is not > 0)
                throw GentegreHatasi.Dogrulama("Kategori zorunlu.", new AlanHatasi("kategoriId", "Kategori kapsamında kategori seçilmeli."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // AYNI DEPODA TEK AÇIK SAYIM (db indeksi de korur): iki açık sayım
            //   aynı farkı iki kez fişlerdi.
            var acik = await baglanti.TekDegerAsync<string>(
                "select sayim_no from public.stok_sayim where depo_id = @p0 and durum = 0 for update",
                islem, [istek.DepoId], iptal);
            if (acik is not null)
                throw GentegreHatasi.IsKurali($"Bu depoda açık sayım var ({acik}) - önce onu kapatın ya da silin.");

            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.stok_sayim (sube_id, depo_id, kapsam, kategori_id, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5)
                returning id
                """, islem,
                [subeId, istek.DepoId, istek.Kapsam, istek.Kapsam == 1 ? istek.KategoriId : null,
                 (istek.Aciklama ?? "").Trim(), baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.stok_sayim
                   set sayim_no = 'SYM-' || to_char(sayim_tarihi, 'YYYY') || '-' || lpad(id::text, 4, '0')
                 where id = @p0
                """, islem, [id], iptal);

            var kalem = await baglanti.TekDegerAsync<int>(
                "select public.fn_stok_sayim_satir_uret(@p0, @p1)", islem, [id, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogSayim, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.DepoId, istek.Kapsam, istek.KategoriId, kalem }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, kalem, izlemeNo = baglam.IzlemeNo });
        });

        // ---------------------------------------------------------- oku ----
        grup.MapGet("/{id:int}", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var baslik = await baglanti.TekAsync("""
                select y.id, y.sayim_no as "sayimNo", y.sube_id as "subeId", y.depo_id as "depoId",
                       coalesce(d.ad, '') as "depoAdi", y.sayim_tarihi as "sayimTarihi",
                       y.kapsam, y.kategori_id as "kategoriId", coalesce(k.ad, '') as "kategoriAdi",
                       y.aciklama, y.durum, y.kapanis_tarihi as "kapanisTarihi",
                       y.giris_belge_id as "girisBelgeId", coalesce(gb.belge_no, '') as "girisBelgeNo",
                       y.cikis_belge_id as "cikisBelgeId", coalesce(cb.belge_no, '') as "cikisBelgeNo"
                  from public.stok_sayim y
                  left join public.depo d on d.id = y.depo_id
                  left join public.kategori k on k.id = y.kategori_id
                  left join public.belge gb on gb.id = y.giris_belge_id
                  left join public.belge cb on cb.id = y.cikis_belge_id
                 where y.id = @p0
                """, null, [id], o => o.Sozluk(), iptal);
            if (baslik is null || !SubeErisir(baglam, Convert.ToInt32(baslik["subeId"])))
                throw GentegreHatasi.Bulunamadi("Sayım bulunamadı.");

            var satirlar = await baglanti.ListeAsync("""
                select ss.id, ss.stok_id as "stokId", s.kod as "stokKodu", s.ad as "stokAdi",
                       coalesce((select kd.ad from public.kod_deger kd
                                   join public.kod_liste kl on kl.id = kd.liste_id
                                  where kl.kod = 'stok.ana_birim' and kd.deger = s.ana_birim), '') as birim,
                       ss.seri_lot_id as "seriLotId",
                       coalesce(nullif(l.lot_no, ''), nullif(l.seri_no, ''), '') as lot,
                       l.son_kullanma_tarihi as skt,
                       -- İZLEME ADI (kullanıcı 24.10.2026: "sayım kalemlerine İzleme ekle") - stok listesiyle aynı ifade.
                       case s.izleme when 1 then 'Seri No' when 2 then 'Lot No' when 3 then 'SKT'
                            when 4 then 'Karekod' when 5 then 'Lot No + SKT' when 6 then 'Seri + Lot' else '' end as "izlemeAdi",
                       ss.sistem, ss.sayilan, ss.birim_maliyet as "birimMaliyet",
                       coalesce(s.kategori, 0) as kategori
                  from public.stok_sayim_satir ss
                  join public.stok s on s.id = ss.stok_id
                  left join public.stok_seri_lot l on l.id = ss.seri_lot_id
                 where ss.sayim_id = @p0
                 order by s.ad, l.son_kullanma_tarihi nulls last, ss.id
                """, null, [id], o => o.Sozluk(), iptal);

            return Results.Ok(new { baslik, satirlar });
        });

        // ------------------------------------------------- açıklama ----
        grup.MapPut("/{id:int}", async (int id, AciklamaIstegi istek, BaglamCozucu cozucu,
                                        VeriKaynagi veri, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            await AcikBaslikAsync(baglanti, islem, baglam, id, iptal);
            await baglanti.CalistirAsync("""
                update public.stok_sayim set aciklama = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, (istek.Aciklama ?? "").Trim(), baglam.KullaniciId], iptal);
            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogSayim, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { istek.Aciklama }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        // ------------------------------------------- sayılan miktar ----
        // NULL = "sayılmadı"ya geri döner (fark yazılmaz); 0 = sayıldı, yok.
        grup.MapPut("/satir/{satirId:int}", async (int satirId, SayilanIstegi istek, BaglamCozucu cozucu,
                                                   VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            if (istek.Sayilan is < 0)
                throw GentegreHatasi.Dogrulama("Sayılan eksi olamaz.", new AlanHatasi("sayilan", "0 ya da daha büyük."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var sayimId = await baglanti.TekDegerAsync<int?>(
                "select sayim_id from public.stok_sayim_satir where id = @p0", islem, [satirId], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Sayım satırı bulunamadı.");
            await AcikBaslikAsync(baglanti, islem, baglam, sayimId, iptal);

            // Sayım satırı log'u yazılmaz: yüzlerce okutma yüzlerce log satırı olurdu;
            //   sonuç kapanışta (farklar) ve fişlerde kalır. Kimin saydığı satırda.
            await baglanti.CalistirAsync("""
                update public.stok_sayim_satir
                   set sayilan = @p1::numeric, sayan = @p2,
                       sayim_zamani = case when @p1::numeric is null then null else now() end
                 where id = @p0
                """, islem, [satirId, istek.Sayilan, baglam.KullaniciId], iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { satirId, sayilan = istek.Sayilan });
        });

        // ---------------------------------------------------- okut ----
        // Barkod (stok_birim.barkod - çarpanıyla) ya da stok kodu ya da stok id:
        //   listede tek satırı varsa sayılanı artırır; izlemsiz stok listede yoksa
        //   satır eklenir (sistem = depo bakiyesi); lotlu stokta birden çok satır
        //   varsa ARTIRMAZ, satırları döner - hangi lot olduğunu kullanıcı seçer.
        grup.MapPost("/{id:int}/okut", async (int id, OkutIstegi istek, BaglamCozucu cozucu,
                                              VeriKaynagi veri, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);
            if (istek.Miktar <= 0) istek.Miktar = 1;

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var b = await AcikBaslikAsync(baglanti, islem, baglam, id, iptal);

            int stokId; decimal carpan = 1;
            if (istek.StokId is > 0) stokId = istek.StokId.Value;
            else
            {
                var kod = (istek.Kod ?? "").Trim();
                if (kod.Length == 0) throw GentegreHatasi.Dogrulama("Barkod ya da stok kodu girin.", new AlanHatasi("kod", "Boş."));
                var bulunan = await baglanti.TekAsync("""
                    select x.stok_id, x.carpan from (
                        select sb.stok_id, coalesce(nullif(sb.carpan, 0), 1) as carpan, 1 as oncelik
                          from public.stok_birim sb join public.stok s on s.id = sb.stok_id
                         where sb.barkod = @p0 and s.durum = 1
                        union all
                        select s.id, 1, 2 from public.stok s where lower(s.kod) = lower(@p0) and s.durum = 1
                    ) x order by x.oncelik limit 1
                    """, islem, [kod], o => new { StokId = o.GetInt32(0), Carpan = Convert.ToDecimal(o.GetValue(1)) }, iptal)
                    ?? throw GentegreHatasi.IsKurali($"\"{kod}\" ile kayıtlı stok bulunamadı.");
                stokId = bulunan.StokId; carpan = bulunan.Carpan;
            }

            var stok = await baglanti.TekAsync(
                "select ad, izleme from public.stok where id = @p0", islem, [stokId],
                o => new { Ad = o.GetString(0), Izleme = Convert.ToInt16(o.GetValue(1)) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Stok bulunamadı.");

            var satirlar = await baglanti.ListeAsync(
                "select id from public.stok_sayim_satir where sayim_id = @p0 and stok_id = @p1 order by id",
                islem, [id, stokId], o => o.GetInt32(0), iptal);

            var miktar = istek.Miktar * carpan;

            // İZLEMLİ STOK LİSTEDE YOKSA (UNIVERSE uçtan uca testi, 25.10.2026): "Seçili stoklar"
            //   sayımı boş açılır; lotlu stok okutulunca lotları bu depodaki bakiyeden eklenir
            //   (fn_stok_sayim_satir_uret kuralı: kalanı olan her lot + lotsuz bakiye) ve
            //   lot seçimi döner. Önceden "kalanı olan lotu yok" diye reddediliyordu.
            if (satirlar.Count == 0 && stok.Izleme != 0)
            {
                var eklenen = await baglanti.ListeAsync("""
                    insert into public.stok_sayim_satir (sayim_id, stok_id, seri_lot_id, sistem, birim_maliyet, ekleyen)
                    select @p0, x.stok_id, x.seri_lot_id, x.sistem, coalesce(public.fn_uretim_stok_maliyeti(x.stok_id), 0), @p3
                      from (
                        select ld.stok_id, ld.seri_lot_id, ld.kalan as sistem
                          from public.stok_lot_durum ld
                         where ld.stok_id = @p1 and ld.depo_id = @p2 and ld.kalan <> 0
                        union all
                        select @p1, null::integer,
                               coalesce((select sd.kalan from public.stok_durum sd where sd.stok_id = @p1 and sd.depo_id = @p2), 0)
                             - coalesce((select sum(l.kalan) from public.stok_lot_durum l where l.stok_id = @p1 and l.depo_id = @p2), 0)
                      ) x
                     where x.seri_lot_id is not null or x.sistem <> 0
                    on conflict do nothing
                    returning id
                    """, islem, [id, stokId, b.DepoId, baglam.KullaniciId], o => o.GetInt32(0), iptal);
                if (eklenen.Count > 0)
                {
                    await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogSatir, eklenen[0],
                        baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { sayimId = id, stokId, lotSatiri = eklenen.Count }, iptal: iptal);
                    await islem.CommitAsync(iptal);
                    return Results.Ok(new { lotSec = true, satirIdleri = eklenen, stokAdi = stok.Ad, miktar });
                }
            }

            int satirId;
            if (satirlar.Count > 1)
            {
                await islem.CommitAsync(iptal);
                return Results.Ok(new { lotSec = true, satirIdleri = satirlar, stokAdi = stok.Ad, miktar });
            }
            if (satirlar.Count == 1)
            {
                satirId = satirlar[0];
                await baglanti.CalistirAsync("""
                    update public.stok_sayim_satir
                       set sayilan = coalesce(sayilan, 0) + @p1, sayan = @p2, sayim_zamani = now()
                     where id = @p0
                    """, islem, [satirId, miktar, baglam.KullaniciId], iptal);
            }
            else
            {
                // LİSTEDE OLMAYAN STOK: izlemsizse eklenir (sistem = şimdiki depo bakiyesi, çoğu
                //   zaman 0 -> fazla). Lotlu stokta lotu bilmeden satır açılamaz.
                if (stok.Izleme != 0)
                    throw GentegreHatasi.IsKurali(
                        $"{stok.Ad} lot/seri izlemli ve bu depoda kalanı olan lotu yok - fazlası Giriş Fişi ile lotuyla girilmeli.");
                satirId = await baglanti.TekDegerAsync<int>("""
                    insert into public.stok_sayim_satir
                        (sayim_id, stok_id, sistem, sayilan, birim_maliyet, sayan, sayim_zamani, ekleyen)
                    select @p0, @p1,
                           coalesce((select sd.kalan from public.stok_durum sd where sd.stok_id = @p1 and sd.depo_id = @p2), 0),
                           @p3, coalesce(public.fn_uretim_stok_maliyeti(@p1), 0), @p4, now(), @p4
                    returning id
                    """, islem, [id, stokId, b.DepoId, miktar, baglam.KullaniciId], iptal);
                await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogSatir, satirId,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { sayimId = id, stokId }, iptal: iptal);
            }

            var sayilan = await baglanti.TekDegerAsync<decimal>(
                "select sayilan from public.stok_sayim_satir where id = @p0", islem, [satirId], iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { lotSec = false, satirId, stokAdi = stok.Ad, sayilan, miktar, eklendi = satirlar.Count == 0 });
        });

        // ----------------------------------------------------- sil ----
        grup.MapDelete("/{id:int}", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
                                           LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Sil);
            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var b = await AcikBaslikAsync(baglanti, islem, baglam, id, iptal);
            // Silme logu SİLMEDEN ÖNCE (ULog kuralı).
            await log.YazAsync(baglanti, islem, LogIslemi.Sil, LogSayim, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { b.SayimNo, b.DepoId }, iptal: iptal);
            await baglanti.CalistirAsync("delete from public.stok_sayim where id = @p0", islem, [id], iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        // ------------------------------------------ farkları fişle ----
        grup.MapPost("/{id:int}/kapat", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
                                               BelgeDeposu belgeDepo, LogDeposu log,
                                               HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var b = await AcikBaslikAsync(baglanti, islem, baglam, id, iptal);

            var farklar = await baglanti.ListeAsync("""
                select ss.stok_id, ss.seri_lot_id, ss.sayilan - ss.sistem as fark, ss.birim_maliyet,
                       s.izleme, coalesce(l.lot_no, ''), coalesce(l.seri_no, ''),
                       l.uretim_tarihi, l.son_kullanma_tarihi, s.ad
                  from public.stok_sayim_satir ss
                  join public.stok s on s.id = ss.stok_id
                  left join public.stok_seri_lot l on l.id = ss.seri_lot_id
                 where ss.sayim_id = @p0 and ss.sayilan is not null and ss.sayilan <> ss.sistem
                 order by s.ad, ss.id
                """, islem, [id], o => new Fark(
                    o.GetInt32(0), o.IsDBNull(1) ? null : o.GetInt32(1), o.GetDecimal(2), o.GetDecimal(3),
                    Convert.ToInt16(o.GetValue(4)), o.GetString(5), o.GetString(6),
                    o.IsDBNull(7) ? null : o.GetDateTime(7), o.IsDBNull(8) ? null : o.GetDateTime(8),
                    o.GetString(9)), iptal);

            // LOTSUZ SATIR FİŞLENEMEZ: izlemli stokta fiş lot ister. Sessizce atlamak farkı
            //   kaybettirirdi - kullanıcı ya lotu düzeltir ya sayılanı boşaltır.
            var lotsuz = farklar.Where(f => f.Izleme != 0 && f.SeriLotId is null).Select(f => f.StokAdi).ToList();
            if (lotsuz.Count > 0)
                throw GentegreHatasi.IsKurali(
                    "Lot izlenen şu stokların lotsuz satırında fark var - lot bilgisi olmadan fiş kesilemez: " +
                    string.Join(", ", lotsuz.Take(5)) + (lotsuz.Count > 5 ? $" (+{lotsuz.Count - 5})" : "") +
                    ". Farkı lotlu satıra yazın ya da bu satırın sayılanını boşaltın.");

            var fazla = farklar.Where(f => f.Miktar > 0).ToList();
            var eksik = farklar.Where(f => f.Miktar < 0).ToList();
            // FİŞİN KENDİ YETKİSİ: sayım yetkisi giriş/çıkış fişi kesme hakkı değildir.
            if (fazla.Count > 0 && !BelgeUclari.TurIzinli(baglam, 3, 2, Islem.Ekle))
                throw GentegreHatasi.Yasak("Sayım fazlası için Giriş Fişi yetkiniz yok.");
            if (eksik.Count > 0 && !BelgeUclari.TurIzinli(baglam, 4, 5, Islem.Ekle))
                throw GentegreHatasi.Yasak("Sayım eksiği için Çıkış Fişi yetkiniz yok.");

            // Fiş tarihi = sayım tarihi (kesit), şubenin saatiyle.
            var tarih = TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(b.SayimTarihi.ToUniversalTime(), DateTimeKind.Utc), Saat.Dilim(null));
            var uyarilar = new List<string>();
            int? girisId = null, cikisId = null;

            if (fazla.Count > 0)
            {
                var (fid, u) = await belgeDepo.KaydetAsync(baglanti, islem,
                    FisBasligi(3, 2, b, tarih, baglam), FisSatirlari(fazla, b.DepoId, giris: true),
                    new BelgeSecenekleri { Taslak = false, StokKontrolu = false }, baglam.Yazma, iptal);
                girisId = fid; uyarilar.AddRange(u);
            }
            if (eksik.Count > 0)
            {
                var (fid, u) = await belgeDepo.KaydetAsync(baglanti, islem,
                    FisBasligi(4, 5, b, tarih, baglam), FisSatirlari(eksik, b.DepoId, giris: false),
                    new BelgeSecenekleri { Taslak = false, StokKontrolu = true }, baglam.Yazma, iptal);
                cikisId = fid; uyarilar.AddRange(u);
            }

            await baglanti.CalistirAsync("""
                update public.stok_sayim
                   set durum = 1, giris_belge_id = @p1, cikis_belge_id = @p2,
                       kapanis_tarihi = now(), kapatan = @p3, degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, girisId, cikisId, baglam.KullaniciId], iptal);
            // Depo kartının son sayım tarihi (Delphi DEPOLAR.SONSAYIMTARIHI karşılığı).
            await baglanti.CalistirAsync(
                "update public.depo set son_sayim_tarihi = @p1 where id = @p0",
                islem, [b.DepoId, tarih], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogSayim, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { kapandi = true, fazlaKalem = fazla.Count, eksikKalem = eksik.Count, girisId, cikisId }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, girisBelgeId = girisId, cikisBelgeId = cikisId,
                                    fazlaKalem = fazla.Count, eksikKalem = eksik.Count, uyarilar,
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    private sealed record Fark(int StokId, int? SeriLotId, decimal Miktar, decimal BirimMaliyet, short Izleme,
                               string LotNo, string SeriNo, DateTime? Uretim, DateTime? Skt, string StokAdi);

    private static bool SubeErisir(IstekBaglami baglam, int subeId) => baglam.Subeler.Any(s => s.Id == subeId);

    /// <summary>Başlığı kilitler; açık değilse ya da şube dışıysa durdurur.</summary>
    private static async Task<Baslik> AcikBaslikAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        IstekBaglami baglam, int id, CancellationToken iptal)
    {
        var b = await baglanti.TekAsync("""
            select id, sube_id, depo_id, durum, sayim_tarihi, sayim_no
              from public.stok_sayim where id = @p0 for update
            """, islem, [id], o => new Baslik(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2),
                Convert.ToInt16(o.GetValue(3)), o.GetDateTime(4), o.GetString(5)), iptal);
        if (b is null || !SubeErisir(baglam, b.SubeId)) throw GentegreHatasi.Bulunamadi("Sayım bulunamadı.");
        if (b.Durum != 0) throw GentegreHatasi.IsKurali("Sayım kapanmış - değiştirilemez.");
        return b;
    }

    private static Dictionary<string, object?> FisBasligi(int tur, int tipi, Baslik b, DateTime tarih, IstekBaglami baglam)
        => new(StringComparer.Ordinal)
        {
            ["tur"] = tur,
            ["tipi"] = tipi,
            ["belgeTarihi"] = tarih,
            ["belgeDovizi"] = "TL",
            ["dovizKuru"] = 1m,
            [tur == 3 ? "girisDepoId" : "cikisDepoId"] = b.DepoId,
            ["subeId"] = b.SubeId,
            ["aciklama"] = $"{b.SayimNo} sayım farkı",
            ["saticiId"] = baglam.KullaniciId,
            // KAYNAK = sayım (log tablo kimliği, 30 = belge deseni): fişten sayıma gidilir.
            ["kaynakTur"] = LogSayim,
            ["kaynakId"] = b.Id,
        };

    private static List<Dictionary<string, System.Text.Json.JsonElement>> FisSatirlari(
        List<Fark> farklar, int depoId, bool giris)
    {
        var sonuc = new List<Dictionary<string, System.Text.Json.JsonElement>>();
        var sira = 0;
        foreach (var f in farklar)
        {
            var miktar = Math.Abs(f.Miktar);
            var satir = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = 1,
                ["stokId"] = f.StokId,
                ["miktar"] = miktar,
                ["birimFiyat"] = Math.Round(f.BirimMaliyet, 4),
                ["kdv"] = 0,
                ["dovizCinsi"] = "TL",
                [giris ? "girisDepoId" : "cikisDepoId"] = depoId,
                ["sira"] = ++sira,
            };
            // LOT: girişte mevcut lotun kimliği (lot/seri/tarihler) - aynı lot bulunur;
            //   çıkışta sayılan lot düşülür.
            if (f.Izleme != 0 && f.SeriLotId is { } lotId)
                satir["izlemler"] = new List<Dictionary<string, object?>>
                {
                    giris
                        ? new() { ["lotNo"] = f.LotNo, ["seriNo"] = f.SeriNo, ["miktar"] = miktar,
                                  ["uretimTarihi"] = f.Uretim, ["sonKullanmaTarihi"] = f.Skt }
                        : new() { ["seriLotId"] = lotId, ["miktar"] = miktar },
                };
            sonuc.Add(BelgeGovdesi.Satir(satir));
        }
        return sonuc;
    }
}
