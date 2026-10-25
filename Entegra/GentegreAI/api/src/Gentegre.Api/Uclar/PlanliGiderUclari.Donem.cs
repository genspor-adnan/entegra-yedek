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
using static Gentegre.Api.Servisler.PlanliGiderMotoru;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PLANLI GİDER DÖNEM İŞLEMLERİ: atla / bu dönemin tutarı / geri al, eşleşme önerileri, elle eşleştir /
/// kaldır, Ödeme Oluştur (taslak tediye, KasaDeposu) ve toplu eşleştirme. Dönem yolu `{vade}` =
/// takvimin KAYDIRILMAMIŞ günü (yyyy-MM-dd). Her dönem değişikliği kendi log satırını alır
/// (planli_gider_donem 1722, üst = tanım 1720 - sözleşmedeki 1390-1392 Patoloji ile çakışıyordu); eşleşme ayrı satırdır.
/// </summary>
public static partial class PlanliGiderUclari
{
    public sealed record AtlaIstegi(string? Aciklama);
    public sealed record TutarIstegi(decimal? Tutar, string? Aciklama);
    public sealed record EslesIstegi(string? Tur, long? KayitId);
    public sealed record OdemeIstegi(string? Vade);

    /// <summary>Tanımın o vadedeki dönemi (takvimde yoksa 404).</summary>
    private static PlanliGiderDonemi DonemBul(Paket p, Tanim t, DateTime vade, DateTime bugun)
    {
        var ufuk = new[] { KartUfku(t, bugun), vade.AddDays(1) }.Max();
        return p.Donemler(t, ufuk).FirstOrDefault(d => d.Vade == vade)
               ?? throw GentegreHatasi.Bulunamadi("Bu tarihte tanımın dönemi yok.");
    }

    private static async Task<long> DonemSatiriAsync(NpgsqlConnection b, NpgsqlTransaction tx, int tanim, DateTime vade, int kullanici,
        CancellationToken iptal)
        => await b.TekDegerAsync<long>("""
            insert into public.planli_gider_donem (planli_gider_id, vade, ekleyen) values (@p0, @p1::date, @p2)
            on conflict (planli_gider_id, vade) do update set degistiren = excluded.ekleyen
            returning id
            """, tx, [tanim, vade, kullanici], iptal);

    private static Task DonemLogAsync(NpgsqlConnection b, NpgsqlTransaction tx, LogDeposu log, IstekBaglami baglam, Tanim t,
        long donemId, DateTime vade, Dictionary<string, string> bilgi, CancellationToken iptal)
    {
        bilgi["donem"] = DonemAdi(vade);
        bilgi["vade"] = T(vade)!;
        return log.YazAsync(b, tx, LogIslemi.Degistir, LogDonem, donemId, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi,
            LogTanim, t.Id, t.TarafId, iptal: iptal);
    }

    private static Satir? SatirAl(Paket p, Tanim t, DateTime vade) => p.Satirlar[t.Id].FirstOrDefault(x => x.Vade.Date == vade);

    private static string Aciklama300(string? s)
    {
        var a = (s ?? "").Trim();
        return a.Length <= 300 ? a : throw GentegreHatasi.Dogrulama("Açıklama en çok 300 karakter.", new AlanHatasi("aciklama", "En çok 300 karakter."));
    }

    private static void DonemUclariniEkle(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------------------- atla --
        grup.MapPost("/{id:int}/donem/{vade}/atla", async (int id, string vade, AtlaIstegi? istek, VeriKaynagi veri,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Degistir);
            var v = VadeCoz(vade);
            var aciklama = Aciklama300(istek?.Aciklama);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal, yazma: true);
            var d = DonemBul(p, t, v, bugun);
            if (d.Eslesti) throw GentegreHatasi.IsKurali("Eşleşmiş dönem atlanamaz: önce eşleşmeyi kaldırın.");
            if (d.Atlandi) throw GentegreHatasi.IsKurali("Bu dönem zaten atlandı.");
            var did = await DonemSatiriAsync(b, tx, t.Id, v, baglam.KullaniciId, iptal);
            await b.CalistirAsync("""
                update public.planli_gider_donem set durum = 1, aciklama = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0
                """, tx, [did, aciklama, baglam.KullaniciId], iptal);
            await DonemLogAsync(b, tx, log, baglam, t, did, v, new()
            {
                ["durum"] = "planlı -> atlandı", ["aciklama"] = (SatirAl(p, t, v)?.Aciklama ?? "") + " -> " + aciklama,
            }, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, vade = T(v), durum = "atlandi" });
        });

        // ------------------------------------------------------- bu dönemin tutarı --
        grup.MapPost("/{id:int}/donem/{vade}/tutar", async (int id, string vade, TutarIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Degistir);
            var v = VadeCoz(vade);
            if (istek.Tutar is < 0 or > 9_999_999_999_999m)
                throw GentegreHatasi.Dogrulama("Tutar 0 ya da büyük olmalı.", new AlanHatasi("tutar", "Geçersiz."));
            var tutar = istek.Tutar is { } x ? R(x) : (decimal?)null;
            var aciklama = Aciklama300(istek.Aciklama);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal, yazma: true);
            var d = DonemBul(p, t, v, bugun);
            var eski = d.Satir?.ElleTutar;
            if (eski == tutar && (SatirAl(p, t, v)?.Aciklama ?? "") == aciklama)
                return Results.Ok(new { id, vade = T(v), elleTutar = tutar });
            var did = await DonemSatiriAsync(b, tx, t.Id, v, baglam.KullaniciId, iptal);
            await b.CalistirAsync("""
                update public.planli_gider_donem set elle_tutar = @p1, aciklama = @p2, degistiren = @p3, degistirme_tarihi = now() where id = @p0
                """, tx, [did, tutar, aciklama, baglam.KullaniciId], iptal);
            var bilgi = LogDeposu.Fark(new Dictionary<string, object?> { ["elleTutar"] = eski, ["aciklama"] = SatirAl(p, t, v)?.Aciklama ?? "" },
                                       new Dictionary<string, object?> { ["elleTutar"] = tutar, ["aciklama"] = aciklama })!;
            await DonemLogAsync(b, tx, log, baglam, t, did, v, bilgi, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, vade = T(v), elleTutar = tutar });
        });

        // ---------------------------------------------------------------- geri al --
        grup.MapPost("/{id:int}/donem/{vade}/geri-al", async (int id, string vade, VeriKaynagi veri, BaglamCozucu cozucu,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Degistir);
            var v = VadeCoz(vade);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal, yazma: true);
            var d = DonemBul(p, t, v, bugun);
            var s = p.Satirlar[t.Id].FirstOrDefault(x => x.Vade.Date == v);
            if (s is null || (s.Durum != 1 && s.ElleTutar is null))
                throw GentegreHatasi.IsKurali("Bu dönemde geri alınacak bir istisna (atlama / elle tutar) yok.");
            await b.CalistirAsync("""
                update public.planli_gider_donem
                   set durum = case when durum = 1 then 0 else durum end, elle_tutar = null, aciklama = '',
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, tx, [s.Id, baglam.KullaniciId], iptal);
            var bilgi = new Dictionary<string, string>();
            if (s.Durum == 1) bilgi["durum"] = "atlandı -> planlı";
            if (s.ElleTutar is not null) bilgi["elleTutar"] = LogDeposu.Metin(s.ElleTutar) + " -> ";
            if (s.Aciklama.Length > 0) bilgi["aciklama"] = s.Aciklama + " -> ";
            await DonemLogAsync(b, tx, log, baglam, t, s.Id, v, bilgi, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, vade = T(v), durum = d.Eslesti ? "eslesti" : "planli" });
        });

        // ------------------------------------------------------------- öneriler --
        grup.MapGet("/{id:int}/donem/{vade}/oneriler", async (int id, string vade, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var v = VadeCoz(vade);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            var (p, t) = await TanimAsync(b, null, baglam, id, bugun, iptal);
            var d = DonemBul(p, t, v, bugun);
            var adaylar = await AdaylarAsync(b, null, t, d, iptal);
            return Results.Ok(adaylar.Select(a => new
            {
                tur = a.Tur, id = a.Id, no = a.No, tarih = T(a.Tarih), taraf = a.Taraf, masraf = a.Masraf, tutar = a.Tutar,
                neden = a.Neden, secilebilir = a.Secilebilir && !d.Eslesti, engel = d.Eslesti && a.Secilebilir ? "Dönem zaten eşleşmiş." : a.Engel,
            }).ToList());
        });

        // ---------------------------------------------------------------- eşleş --
        grup.MapPost("/{id:int}/donem/{vade}/esles", async (int id, string vade, EslesIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Degistir);
            var v = VadeCoz(vade);
            if (istek.Tur is not ("kasa" or "fatura" or "banka"))
                throw GentegreHatasi.Dogrulama("Tür 'kasa', 'fatura' ya da 'banka' olmalı.", new AlanHatasi("tur", "Geçersiz."));
            if (istek.KayitId is not > 0) throw GentegreHatasi.Dogrulama("Kayıt seçilmeli.", new AlanHatasi("kayitId", "Zorunlu."));
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal, yazma: true);
            var d = DonemBul(p, t, v, bugun);
            if (d.Eslesti) throw GentegreHatasi.IsKurali("Dönem zaten eşleşmiş: önce eşleşmeyi kaldırın.");
            if (d.Atlandi) throw GentegreHatasi.IsKurali("Atlanan dönem eşleştirilemez: önce geri alın.");
            // Öneri listesindeyse oradan; değilse (tolerans dışı - kullanıcı bilerek seçti) kayıt doğrudan okunur.
            var aday = (await AdaylarAsync(b, tx, t, d, iptal)).FirstOrDefault(a => a.Tur == istek.Tur && a.Id == istek.KayitId)
                       ?? await KayitAdayiAsync(b, tx, t, istek.Tur!, istek.KayitId!.Value, iptal);
            await EslesAsync(b, tx, log, t, d, aday, false, baglam.KullaniciId, baglam.SubeId, baglam.Ip, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, vade = T(v), durum = aday.Tur == "fatura" ? "faturalandi" : aday.Tur == "banka" ? "beklemede" : "odendi" });
        });

        // ------------------------------------------------------- eşleşmeyi kaldır --
        grup.MapPost("/{id:int}/donem/{vade}/eslesme-kaldir", async (int id, string vade, VeriKaynagi veri, BaglamCozucu cozucu,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Degistir);
            var v = VadeCoz(vade);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal, yazma: true);
            var s = p.Satirlar[t.Id].FirstOrDefault(x => x.Vade.Date == v);
            if (s is null || s.Durum is not (3 or 4)) throw GentegreHatasi.IsKurali("Bu dönem eşleşmiş değil.");
            await b.CalistirAsync("""
                update public.planli_gider_donem
                   set durum = 0, eslesen_tur = '', eslesen_id = null, eslesen_tutar = null, eslesen_tarih = null,
                       eslesme_otomatik = 0, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, tx, [s.Id, baglam.KullaniciId], iptal);
            await DonemLogAsync(b, tx, log, baglam, t, s.Id, v, new()
            {
                ["eslesme"] = s.EslesenNo + (s.Otomatik == 1 ? " (otomatik)" : " (elle)") + " -> ",
                ["eslesenTur"] = s.EslesenTur, ["eslesenId"] = LogDeposu.Metin(s.EslesenId), ["eslesenTutar"] = LogDeposu.Metin(s.EslesenTutar),
                ["eslesenTarih"] = T(s.EslesenTarih) ?? "",
            }, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, vade = T(v), durum = "planli" });
        });

        // -------------------------------------------------------- ödeme oluştur --
        // TASLAK TEDİYE (karar: kendiliğinden kayıt yok): cari + masraf + tutar + hesap + açıklama şablonu
        //   dolu; kesinleştiren kullanıcı. Kesinleşince dönem eşleştirmesi (işçi / Eşleştir) onu bulur.
        grup.MapPost("/{id:int}/odeme", async (int id, OdemeIstegi? istek, VeriKaynagi veri, KasaDeposu kasa, BaglamCozucu cozucu,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            var (p, t) = await TanimAsync(b, null, baglam, id, bugun, iptal);
            if (t.SubeId != baglam.SubeId) throw GentegreHatasi.Yasak("Bu tanım başka bir şubenin; ödeme için o şubeye geçin.");
            if (t.OdemeHesapId is null)
                throw GentegreHatasi.IsKurali("Tanımda ödeme hesabı seçilmemiş: kartın Ödeme sekmesinden seçin.");
            if (t.TarafId is null && t.MasrafId is null)
                throw GentegreHatasi.IsKurali("Ödenecek yer ya da masraf kalemi seçilmeli: tediyenin karşı bacağı belli değil.");
            var donemler = p.Donemler(t, KartUfku(t, bugun));
            PlanliGiderDonemi d;
            if (!string.IsNullOrWhiteSpace(istek?.Vade)) d = DonemBul(p, t, VadeCoz(istek!.Vade), bugun);
            else d = donemler.FirstOrDefault(x => Gecikmis(x, t, bugun))
                     ?? donemler.FirstOrDefault(x => x.PlanTarihi >= bugun && !x.Atlandi && !x.Eslesti)
                     ?? throw GentegreHatasi.IsKurali("Ödenecek açık dönem yok.");
            if (d.Eslesti) throw GentegreHatasi.IsKurali("Bu dönem zaten ödeme / faturayla eşleşmiş.");
            if (d.Atlandi) throw GentegreHatasi.IsKurali("Bu dönem atlandı.");
            if (d.Plan <= 0) throw GentegreHatasi.IsKurali("Dönem tutarı sıfır: önce bu dönemin tutarını girin.");

            var tur = t.OdemeYontem switch { 4 => 31L, 3 => 35L, _ => 32L };
            var aciklama = PlanliGiderHesap.Aciklama(t.OdemeAciklama, t.Ad, d.Vade);
            if (aciklama.Length > 200) aciklama = aciklama[..200];
            var islem = new Dictionary<string, object?>
            {
                ["tur"] = tur, ["islemTarihi"] = Saat.An, ["tutar"] = d.Plan, ["dovizCinsi"] = t.Doviz,
                ["hesapId"] = (long)t.OdemeHesapId.Value, ["aciklama"] = aciklama,
            };
            if (t.MasrafId is { } mid) islem["masrafId"] = (long)mid;
            List<Dictionary<string, JsonElement>>? bacaklar = null;
            if (t.TarafId is { } tid) islem["tarafId"] = (long)tid;
            else
            {
                // CARİSİZ (SGK / vergi): bacaklar açık - masraf borç, hesap alacak (Banka Hareketleri'nin masraf deseni).
                Dictionary<string, JsonElement> Bacak(params (string Ad, object Deger)[] x)
                    => x.ToDictionary(a => a.Ad, a => JsonSerializer.SerializeToElement(a.Deger));
                bacaklar =
                [
                    Bacak(("masrafId", t.MasrafId!.Value), ("yon", "borc"), ("tutar", d.Plan)),
                    Bacak(("hesapId", t.OdemeHesapId.Value), ("yon", "alacak"), ("tutar", d.Plan)),
                ];
            }
            var (kasaId, uyarilar) = await kasa.KaydetAsync(islem, bacaklar,
                new KasaSecenekleri { Taslak = true, Plan = false }, baglam.Yazma, iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTanim, t.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["odemeOlustur"] = " -> taslak kasa işlemi #" + kasaId.ToString(CultureInfo.InvariantCulture),
                    ["donem"] = DonemAdi(d.Vade), ["tutar"] = LogDeposu.Metin(d.Plan), ["doviz"] = t.Doviz,
                }, tarafId: t.TarafId, iptal: iptal);
            var mesaj = $"Taslak ödeme oluşturuldu: {t.Ad} · {DonemAdi(d.Vade)} · {d.Plan.ToString("#,##0.00", Tr)} {t.Doviz}. "
                        + "Kasa işlemi kartında kontrol edip kesinleştirin; kesinleşince dönemle eşleşir."
                        + (uyarilar.Count > 0 ? " " + string.Join(" ", uyarilar) : "");
            return Results.Ok(new { kasaIslemId = kasaId, mesaj });
        });

        // ------------------------------------------------------ toplu eşleştir --
        grup.MapPost("/eslestir", async (VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            YazmaYetkisi(baglam, Islem.Degistir);
            var sube = AktifSube(baglam);
            var (eslesen, donduruldu) = await EslestirAsync(veri, log, [sube], baglam.KullaniciId, baglam.SubeId, baglam.Ip, iptal);
            return Results.Ok(new { eslesen, donduruldu });
        });
    }

    /// <summary>
    /// Öneri dışı (tolerans dışı) elle seçilen kayıt: türü ve durumu doğru mu, başka döneme eşleşmiş mi.
    /// Tutar tanım dövizinde (kasa / banka nakit, fatura brüt).
    /// </summary>
    private static async Task<Aday> KayitAdayiAsync(NpgsqlConnection b, NpgsqlTransaction tx, Tanim t, string tur, long id,
        CancellationToken iptal)
    {
        var sql = tur switch
        {
            "kasa" => """
                select coalesce(nullif(ki.islem_no, ''), nullif(ki.makbuz_no, ''), '#' || ki.id),
                       (ki.islem_tarihi at time zone public.fn_sube_zaman_dilimi(ki.sube_id))::date, ki.tutar,
                       (ki.durum = 2 and ki.tur = any(@p1::int[]) and (coalesce(ki.sube_id, 0) = 0 or ki.sube_id = @p2)
                        and public.fn_doviz_iso(coalesce(nullif(ki.doviz_cinsi, ''), public.fn_yerel_para())) = public.fn_doviz_iso(@p3::varchar))
                  from public.kasa_islem ki where ki.id = @p0
                """,
            "fatura" => """
                select 'Alış fatura ' || coalesce(nullif(bl.belge_no, ''), '#' || bl.id),
                       (bl.belge_tarihi at time zone public.fn_sube_zaman_dilimi(bl.sube_id))::date,
                       case when public.fn_doviz_iso(coalesce(nullif(bl.belge_dovizi, ''), public.fn_yerel_para())) = public.fn_yerel_para()
                            then coalesce(bl.genel_toplam, 0) else round(coalesce(bl.genel_toplam, 0) / nullif(bl.doviz_kuru, 0), 2) end,
                       (bl.tur = 11 and bl.durum = 0 and coalesce(bl.tipi, 0) <> 2 and cardinality(@p1::int[]) >= 0
                        and (bl.sube_id is null or bl.sube_id = @p2)
                        and public.fn_doviz_iso(coalesce(nullif(bl.belge_dovizi, ''), public.fn_yerel_para())) = public.fn_doviz_iso(@p3::varchar))
                  from public.belge bl where bl.id = @p0
                """,
            _ => """
                select 'Banka hareketi · bekliyor' || coalesce(' · ' || nullif(bh.banka_islem_no, ''), ''),
                       (bh.islem_tarihi at time zone public.fn_sube_zaman_dilimi(bh.sube_id))::date, abs(bh.tutar),
                       (bh.durum in (0, 1, 4) and bh.tutar < 0 and cardinality(@p1::int[]) >= 0 and bh.sube_id = @p2
                        and length(@p3::varchar) >= 0)
                  from public.banka_hareket bh where bh.id = @p0
                """,
        };
        object kimlik = tur == "banka" ? id : (int)id;
        var k = await b.TekAsync(sql, tx, [kimlik, TediyeTurleri, t.SubeId, t.Doviz],
            o => new { no = o.GetString(0), tarih = o.GetDateTime(1), tutar = o.GetDecimal(2), uygun = o.GetBoolean(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Kayıt bulunamadı.");
        if (!k.uygun)
            throw GentegreHatasi.IsKurali(tur switch
            {
                "kasa" => "Yalnız bu şubenin, tanımla aynı para birimindeki KESİN kasa / banka ödemesi eşleşir.",
                "fatura" => "Yalnız bu şubenin, tanımla aynı para birimindeki KESİN alış faturası eşleşir.",
                _ => "Yalnız bu şubenin işlenmemiş banka çıkışı eşleşir.",
            });
        var baska = await b.TekAsync("""
            select x.vade, g.ad from public.planli_gider_donem x join public.planli_gider g on g.id = x.planli_gider_id
             where x.eslesen_tur = @p0 and x.eslesen_id = @p1
            """, tx, [tur, id], o => new { vade = o.GetDateTime(0), ad = o.GetString(1) }, iptal);
        if (baska is not null)
            throw GentegreHatasi.IsKurali($"{baska.ad} · {DonemAdi(baska.vade)} dönemiyle zaten eşleşmiş — seçilemez.");
        return new Aday(tur, id, k.no, k.tarih, "", "", k.tutar, "elle seçildi", true, "");
    }
}
