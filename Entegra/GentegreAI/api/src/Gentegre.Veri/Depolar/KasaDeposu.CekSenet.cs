using System.Globalization;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// ÇEK / SENET PORTFÖY İŞLEMİ (1386, Delphi UCekListeFrame.CekIslemleriClick): kıymetin durumu, hareket satırı ve
/// gerekiyorsa kasa işlemi (cari / para etkisi) TEK TRANSACTION'da. Kurallar <see cref="CekSenetIslemleri"/>.
/// Delphi'nin "Hareketi Sil"i <see cref="CekSenetGeriAlAsync"/>: yalnız SON hareket, giriş hareketi asla.
/// </summary>
public sealed partial class KasaDeposu
{
    /// <summary>islem_log tablo kodu: 910 = cek_senet (KartKatalogu.CekSenet).</summary>
    private const int LogTabloCekSenet = 910;

    public sealed record CekSenetIslemIstegi(string Kod, DateTime? Tarih, int? TarafId, int? HesapId,
                                             string? BelgeNo, string? Aciklama);

    public sealed record CekSenetIslemSonucu(int HareketId, int? KasaIslemId);

    private sealed record Kiymet(int Tur, int Yon, int Durum, int? TarafId, decimal Tutar, string Doviz, decimal Kur,
                                 int? HesapId, string SeriNo, int? ProjeId);

    private sealed record Hareket(int Id, int Islem, DateTime Tarih, int EskiDurum, int YeniDurum, int? TarafId,
                                  int? HesapId, int? KasaIslemId);

    private static async Task<Kiymet> KiymetKilitleAsync(NpgsqlConnection b, NpgsqlTransaction tx, int id, CancellationToken iptal)
    {
        await using var k = b.Komut("""
            select tur, yon, durum, taraf_id, tutar, doviz_cinsi, doviz_kuru, hesap_id, seri_no, proje_id
              from public.cek_senet where id = @p0 for update
            """, tx, id);
        await using var o = await k.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi("Çek / senet bulunamadı.");
        return new Kiymet(o.GetInt16(0), o.GetInt16(1), o.GetInt16(2), o.IsDBNull(3) ? null : o.GetInt32(3), o.GetDecimal(4),
                          o.IsDBNull(5) ? "" : o.GetString(5), o.IsDBNull(6) ? 1m : o.GetDecimal(6),
                          o.IsDBNull(7) ? null : o.GetInt32(7), o.IsDBNull(8) ? "" : o.GetString(8),
                          o.IsDBNull(9) ? null : o.GetInt32(9));
    }

    /// <summary>Hareketler en yeniden eskiye (Delphi: TARIH desc).</summary>
    private static async Task<List<Hareket>> HareketlerAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int id, CancellationToken iptal)
    {
        await using var k = b.Komut("""
            select id, islem, tarih, eski_durum, yeni_durum, taraf_id, hesap_id, kasa_islem_id
              from public.cek_senet_hareket where cek_senet_id = @p0 order by tarih desc, id desc
            """, tx, id);
        await using var o = await k.ExecuteReaderAsync(iptal);
        var l = new List<Hareket>();
        while (await o.ReadAsync(iptal))
            l.Add(new Hareket(o.GetInt32(0), o.GetInt16(1), o.GetDateTime(2), o.GetInt16(3), o.GetInt16(4),
                              o.IsDBNull(5) ? null : o.GetInt32(5), o.IsDBNull(6) ? null : o.GetInt32(6),
                              o.IsDBNull(7) ? null : o.GetInt32(7)));
        return l;
    }

    /// <summary>Menü: yapılabilecek işlemler + son hareket geri alınabilir mi.</summary>
    public async Task<(int Yon, int Durum, int? HesapId, IReadOnlyList<CekSenetIslemleri.Kural> Islemler, bool GeriAlinir)>
        CekSenetIslemleriAsync(int id, CancellationToken iptal = default)
    {
        await using var b = await _veri.AcAsync(iptal);
        await using var tx = await b.BeginTransactionAsync(iptal);
        var c = await KiymetKilitleAsync(b, tx, id, iptal);
        var h = await HareketlerAsync(b, tx, id, iptal);
        return (c.Yon, c.Durum, c.HesapId, CekSenetIslemleri.Yapilabilir(c.Yon, c.Durum).ToList(), h.Count > 1);
    }

    public async Task<CekSenetIslemSonucu> CekSenetIslemAsync(int id, CekSenetIslemIstegi istek, YazmaBaglami baglam,
                                                              CancellationToken iptal = default)
    {
        await using var b = await _veri.AcAsync(iptal);
        await using var tx = await b.BeginTransactionAsync(iptal);
        var sonuc = await CekSenetIslemAsync(b, tx, id, istek, baglam, iptal);
        await tx.CommitAsync(iptal);
        return sonuc;
    }

    /// <summary>Çağıranın transaction'ında (test: işlem sonunda geri alınır).</summary>
    public async Task<CekSenetIslemSonucu> CekSenetIslemAsync(NpgsqlConnection b, NpgsqlTransaction tx, int id,
        CekSenetIslemIstegi istek, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        var kural = CekSenetIslemleri.Bul(istek.Kod)
            ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen çek / senet işlemi: {istek.Kod}", new AlanHatasi("kod", "Geçersiz."));

        var c = await KiymetKilitleAsync(b, tx, id, iptal);
        var hareketler = await HareketlerAsync(b, tx, id, iptal);

        if (kural.Yon != c.Yon)
            throw GentegreHatasi.IsKurali(c.Yon == 1 ? "Bu işlem verilen çek / senet içindir." : "Bu işlem alınan çek / senet içindir.");
        if (!kural.Durumlar.Contains(c.Durum))
            throw GentegreHatasi.IsKurali($"{kural.Ad.TrimEnd('…')}: kıymetin şimdiki durumunda yapılamaz.");

        // TARİH (Delphi): bugünden ileri olamaz, son hareketten önce olamaz.
        var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
        var gun = (istek.Tarih ?? bugun).Date;
        if (gun > bugun)
            throw GentegreHatasi.Dogrulama("İleri tarihli işlem yapılamaz.", new AlanHatasi("tarih", "Bugünden ileri olamaz."));
        if (hareketler.Count > 0 && hareketler[0].Tarih.Date > gun)
            throw GentegreHatasi.Dogrulama(
                $"Tarih son hareketin tarihinden ({hareketler[0].Tarih:dd.MM.yyyy}) önce olamaz.",
                new AlanHatasi("tarih", "Son hareketten önce."));

        // HEDEF: cari / hesap. Tahsil takastaki kıymette takas bankasına (Delphi), ödeme kıymetin bankasına varsayılır.
        int? tarafId = null, hesapId = null;
        if (kural.Hedef == CekSenetIslemleri.HedefCari)
            tarafId = istek.TarafId is > 0 ? istek.TarafId
                : throw GentegreHatasi.Dogrulama("Cari seçilmeli.", new AlanHatasi("tarafId", "Zorunlu."));
        if (kural.Hedef == CekSenetIslemleri.HedefHesap)
            hesapId = istek.HesapId is > 0 ? istek.HesapId
                : (kural.Kod is "tahsil" or "odendi" && c.HesapId is > 0 ? c.HesapId
                   : throw GentegreHatasi.Dogrulama("Hesap seçilmeli.", new AlanHatasi("hesapId", "Zorunlu.")));
        // CARİSİZ KIYMET (şema izin verir; ör. eşleşmemiş aktarım): menü açılır, ama çekin SAHİBİNE dönen işlemler yapılamaz.
        if (kural.Kod is "iade" or "iade-al" or "saticiya-ver" && c.TarafId is null)
            throw GentegreHatasi.IsKurali("Bu kıymetin carisi yok - önce kartında cariyi seçin.");
        if (kural.Kod == "iade") tarafId = c.TarafId;                    // alınan iade: çekin sahibine

        // KASA İŞLEMİ (cari / para etkisi).
        var senet = c.Tur == 2;
        var kasaTur = CekSenetIslemleri.KasaTuru(kural, senet);
        int? kasaCari = tarafId;
        if (kasaTur == CekSenetIslemleri.KasaTers)
        {
            // Önceki cari etkinin tersi: portföye geri alma - son hareketin kasa işlemi ciro / teminat / icra / iade
            //   (52 / 56) ise o carinin alacağı; verilenin iadesi - çekin sahibinin alacağı. Takas / bankaya teminat /
            //   karşılıksızdan dönüşte cari etkisi yok.
            kasaTur = 0;
            if (kural.Kod == "iade-al") { kasaTur = senet ? 24 : 23; kasaCari = c.TarafId; }
            else if (hareketler.Count > 0 && hareketler[0].KasaIslemId is { } onceki
                     && await TekSayiAsync(b, tx, "select tur from public.kasa_islem where id = @p0 and durum = 2", onceki, iptal) is 52 or 56)
            {
                kasaTur = senet ? 24 : 23;
                kasaCari = hareketler[0].TarafId ?? c.TarafId;
            }
        }
        else if (kural.Kod == "saticiya-ver") kasaCari = c.TarafId;

        var aciklama = (istek.Aciklama ?? "").Trim();
        var islemAdi = kural.Ad.TrimEnd('…');
        int? kasaIslemId = null;
        if (kasaTur > 0)
        {
            var islem = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = kasaTur,
                // Bugünse şimdiki an; geçmiş günse o günün öğlesi (şube saatiyle).
                ["islemTarihi"] = gun == bugun ? DateTime.UtcNow : Saat.UtcYap(gun.AddHours(12), baglam.ZamanDilimi),
                ["tutar"] = c.Tutar,
                ["dovizCinsi"] = c.Doviz,
                ["dovizKuru"] = c.Kur,
                ["cekSenetId"] = id,
                ["aciklama"] = Kirp($"{c.SeriNo} seri nolu {(senet ? "senet" : "çek")} - {islemAdi}"
                                    + (aciklama.Length > 0 ? $" ({aciklama})" : ""), 200),
            };
            if (kasaCari is > 0 && kasaTur is not (51 or 53 or 55)) islem["tarafId"] = kasaCari;
            if (hesapId is > 0 && kasaTur is 51 or 53 or 55) islem["hesapId"] = hesapId;
            if (c.ProjeId is > 0) islem["projeId"] = c.ProjeId;
            kasaIslemId = await KaydetIcAsync(b, tx, islem, null, new KasaSecenekleri(), baglam, [], null, false, iptal);
        }

        // KIYMET: durum + bulunduğu hesap + ciro edilen.
        var yeniHesap = hesapId;
        int? ciro = kural.Kod == "cirola" ? tarafId : null;
        await using (var k = b.Komut("""
            update public.cek_senet
               set durum = @p1, hesap_id = @p2, ciro_taraf_id = @p3,
                   degistiren = @p4, degistirme_tarihi = now()
             where id = @p0
            """, tx, id, (short)kural.YeniDurum, (object?)yeniHesap ?? DBNull.Value, (object?)ciro ?? DBNull.Value,
               baglam.KullaniciId))
            await CalistirAsync(k, iptal, satirSayisi: true);

        int hareketId;
        await using (var k = b.Komut("""
            insert into public.cek_senet_hareket
                (cek_senet_id, islem, tarih, eski_durum, yeni_durum, taraf_id, hesap_id, kasa_islem_id,
                 aciklama, belge_no, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10)
            returning id
            """, tx, id, (short)kural.Hareket, gun, (short)c.Durum, (short)kural.YeniDurum,
               (object?)(tarafId ?? (kasaTur > 0 ? kasaCari : null)) ?? DBNull.Value, (object?)hesapId ?? DBNull.Value,
               (object?)kasaIslemId ?? DBNull.Value, Kirp(aciklama.Length > 0 ? aciklama : islemAdi, 200),
               Kirp((istek.BelgeNo ?? "").Trim(), 30), baglam.KullaniciId))
            hareketId = Convert.ToInt32(await CalistirAsync(k, iptal));

        await _log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloCekSenet, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "cek-islem",
                ["islem"] = islemAdi,
                ["durum"] = $"{c.Durum.ToString(CultureInfo.InvariantCulture)} → {kural.YeniDurum.ToString(CultureInfo.InvariantCulture)}",
                ["kasaIslemId"] = kasaIslemId?.ToString(CultureInfo.InvariantCulture) ?? "",
            }, tarafId: tarafId ?? kasaCari, iptal: iptal);

        return new CekSenetIslemSonucu(hareketId, kasaIslemId);
    }

    /// <summary>
    /// SON HAREKETİ GERİ AL (Delphi "Hareketi Sil" / Tablo.CekHareketiSil): yalnız en yeni hareket; giriş hareketi
    /// geri alınmaz ("çeki silmeyi deneyin"). Hareketin kasa işlemi gerçekleşmişse İPTAL edilir (ters kayıt), kıymet
    /// önceki durumuna, bulunduğu hesaba ve ciro edilene döner; hareket satırı silinir (silme logu önce).
    /// </summary>
    public async Task CekSenetGeriAlAsync(int id, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var b = await _veri.AcAsync(iptal);
        await using var tx = await b.BeginTransactionAsync(iptal);
        await CekSenetGeriAlAsync(b, tx, id, baglam, iptal);
        await tx.CommitAsync(iptal);
    }

    /// <summary>Çağıranın transaction'ında.</summary>
    public async Task CekSenetGeriAlAsync(NpgsqlConnection b, NpgsqlTransaction tx, int id, YazmaBaglami baglam,
                                          CancellationToken iptal = default)
    {
        var c = await KiymetKilitleAsync(b, tx, id, iptal);
        var h = await HareketlerAsync(b, tx, id, iptal);
        if (h.Count <= 1)
            throw GentegreHatasi.IsKurali("Çekin giriş hareketi geri alınamaz - çeki / senedi silmeyi deneyin.");
        var son = h[0];
        var onceki = h[1];

        if (son.KasaIslemId is { } kasa
            && await TekSayiAsync(b, tx, "select durum from public.kasa_islem where id = @p0", kasa, iptal) == KasaDurum.Gerceklesti)
        {
            await using var k = new NpgsqlCommand("select public.fn_kasa_islem_iptal(@p0, @p1, @p2, @p3)", b, tx);
            k.Parameters.AddWithValue("p0", kasa);
            k.Parameters.AddWithValue("p1", baglam.KullaniciId);
            k.Parameters.AddWithValue("p2", DBNull.Value);
            k.Parameters.AddWithValue("p3", "Çek / senet hareketi geri alındı");
            await CalistirAsync(k, iptal);
        }

        var eski = son.EskiDurum;
        await using (var k = b.Komut("""
            update public.cek_senet
               set durum = @p1, hesap_id = @p2, ciro_taraf_id = @p3, degistiren = @p4, degistirme_tarihi = now()
             where id = @p0
            """, tx, id, (short)eski,
               (object?)(eski is 30 or 40 or 50 ? onceki.HesapId : null) ?? DBNull.Value,
               (object?)(eski == 20 ? onceki.TarafId : null) ?? DBNull.Value, baglam.KullaniciId))
            await CalistirAsync(k, iptal, satirSayisi: true);

        await _log.YazAsync(b, tx, LogIslemi.Sil, LogTabloCekSenet, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "cek-hareket-geri-al",
                ["hareketId"] = son.Id.ToString(CultureInfo.InvariantCulture),
                ["islem"] = son.Islem.ToString(CultureInfo.InvariantCulture),
                ["tarih"] = son.Tarih.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                ["durum"] = $"{c.Durum.ToString(CultureInfo.InvariantCulture)} → {eski.ToString(CultureInfo.InvariantCulture)}",
                ["kasaIslemId"] = son.KasaIslemId?.ToString(CultureInfo.InvariantCulture) ?? "",
            }, iptal: iptal);

        await using (var k = b.Komut("delete from public.cek_senet_hareket where id = @p0", tx, son.Id))
            await CalistirAsync(k, iptal, satirSayisi: true);
    }

    private static async Task<int?> TekSayiAsync(NpgsqlConnection b, NpgsqlTransaction tx, string sql, int p0, CancellationToken iptal)
    {
        await using var k = b.Komut(sql, tx, p0);
        var v = await k.ExecuteScalarAsync(iptal);
        return v is null or DBNull ? null : Convert.ToInt32(v, CultureInfo.InvariantCulture);
    }
}
