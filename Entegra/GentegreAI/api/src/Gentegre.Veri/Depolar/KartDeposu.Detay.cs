using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// KART DETAY SATIRLARI (adres, ilgili kisi, taksit...): kartla AYNI
/// transaction icinde ekle/guncelle/sil ve degisikliklerin loglanmasi.
/// </summary>
public sealed partial class KartDeposu
{

    // ========================================================== detay farki ====
    private async Task<Dictionary<string, List<Dictionary<string, string>>>> DetayUygulaAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        KartTanimi tanim, long ustId, Dictionary<string, DetayFarki> farklar,
        YazmaBaglami baglam, CancellationToken iptal, bool eklemeDetayLoguYaz = true)
    {
        var eklenenLoglari = new Dictionary<string, List<Dictionary<string, string>>>(StringComparer.Ordinal);

        foreach (var (ad, fark) in farklar)
        {
            var detay = tanim.Detay(ad)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen detay: {ad}",
                       new AlanHatasi(ad, "Bu kartta boyle bir detay yok."));

            foreach (var satir in fark.Eklenen ?? new List<Dictionary<string, JsonElement>>())
            {
                var degerler = DetayDegerleri(detay, satir, yeni: true);
                var kolonlar = new List<string> { detay.UstKolon, "ekleyen" };
                var parametreler = new List<object?> { ustId, baglam.KullaniciId };

                // 019'da sube_id kolonlari NOT NULL yapildi: detay satiri oturumun subesine yazilir.
                if (detay.SubeKolonu is { } detaySube)
                {
                    kolonlar.Add(detaySube);
                    parametreler.Add(baglam.SubeId);
                }

                foreach (var (alanAdi, deger) in degerler)
                {
                    kolonlar.Add(detay.Alanlar.First(a => a.Ad == alanAdi).Kolon);
                    parametreler.Add(deger);
                }

                var yerTutucular = Enumerable.Range(0, parametreler.Count)
                    .Select(i => "@p" + i.ToString(CultureInfo.InvariantCulture));

                var sql = $"insert into {detay.Tablo} ({string.Join(", ", kolonlar)}) " +
                          $"values ({string.Join(", ", yerTutucular)}) returning {detay.IdKolonu}";

                long detayId;
                await using (var komut = Komut(baglanti, islem, sql, parametreler))
                    detayId = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal));

                var logDegerleri = EklemeLogDegerleri(degerler);
                if (logDegerleri.Count > 0)
                    logDegerleri["id"] = detayId.ToString(CultureInfo.InvariantCulture);

                if (logDegerleri.Count > 0)
                {
                    if (!eklenenLoglari.TryGetValue(ad, out var detayListesi))
                        eklenenLoglari[ad] = detayListesi = new List<Dictionary<string, string>>();
                    detayListesi.Add(logDegerleri);
                }

                if (eklemeDetayLoguYaz && logDegerleri.Count > 0)
                    await DetayLogAsync(baglanti, islem, tanim, detay, LogIslemi.Ekle, detayId, ustId,
                        logDegerleri, baglam, iptal);
            }

            foreach (var satir in fark.Degisen ?? new List<Dictionary<string, JsonElement>>())
            {
                if (!satir.TryGetValue("id", out var idElemani) || !idElemani.TryGetInt64(out var satirId))
                    throw GentegreHatasi.Dogrulama($"{ad}: degisen satirda id yok.",
                        new AlanHatasi(ad, "Degisen detay satiri id tasimali."));

                var degerler = DetayDegerleri(detay, satir, yeni: false);
                if (degerler.Count == 0) continue;

                var atamalar = new List<string>();
                var parametreler = new List<object?>();

                foreach (var (alanAdi, deger) in degerler)
                {
                    var kolon = detay.Alanlar.First(a => a.Ad == alanAdi).Kolon;
                    atamalar.Add($"{kolon} = @p{parametreler.Count.ToString(CultureInfo.InvariantCulture)}");
                    parametreler.Add(deger);
                }

                atamalar.Add($"degistiren = @p{parametreler.Count.ToString(CultureInfo.InvariantCulture)}");
                parametreler.Add(baglam.KullaniciId);

                var idSira = parametreler.Count;
                parametreler.Add(satirId);
                var ustSira = parametreler.Count;
                parametreler.Add(ustId);

                // Ust kayit kontrolu: baska karta ait satir guncellenemez.
                var sql = $"update {detay.Tablo} set {string.Join(", ", atamalar)} " +
                          $"where {detay.IdKolonu} = @p{idSira.ToString(CultureInfo.InvariantCulture)} " +
                          $"and {detay.UstKolon} = @p{ustSira.ToString(CultureInfo.InvariantCulture)}";

                await using (var komut = Komut(baglanti, islem, sql, parametreler))
                    if (await komut.ExecuteNonQueryAsync(iptal) == 0)
                        throw GentegreHatasi.Bulunamadi($"{ad}: {satirId} nolu satir bu kartta yok.");

                await DetayLogAsync(baglanti, islem, tanim, detay, LogIslemi.Degistir, satirId, ustId,
                    degerler.ToDictionary(d => d.Key, d => LogDeposu.Metin(d.Value)), baglam, iptal);
            }

            foreach (var satirId in fark.Silinen ?? new List<long>())
            {
                // Silme logu DELETE'ten ONCE: satirin tam hali saklanir ("Geri Al").
                var yedek = new Dictionary<string, string>(StringComparer.Ordinal);
                var secim = string.Join(", ", detay.Alanlar.Select(a => $"{a.Kolon} as \"{a.Ad}\""));
                await using (var oku = new NpgsqlCommand(
                    $"select {secim} from {detay.Tablo} where {detay.IdKolonu} = @p0 and {detay.UstKolon} = @p1",
                    baglanti, islem))
                {
                    oku.Parameters.AddWithValue("p0", satirId);
                    oku.Parameters.AddWithValue("p1", ustId);
                    await using var okuyucu = await oku.ExecuteReaderAsync(iptal);
                    if (await okuyucu.ReadAsync(iptal))
                        for (var i = 0; i < okuyucu.FieldCount; i++)
                            yedek[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? "" : LogDeposu.Metin(okuyucu.GetValue(i));
                }

                if (yedek.Count > 0)
                    await DetayLogAsync(baglanti, islem, tanim, detay, LogIslemi.Sil, satirId, ustId,
                        yedek, baglam, iptal);

                await using var komut = baglanti.Komut(
                    $"delete from {detay.Tablo} where {detay.IdKolonu} = @p0 and {detay.UstKolon} = @p1", islem,
                    satirId, ustId);
                await komut.ExecuteNonQueryAsync(iptal);
            }
        }

        return eklenenLoglari;
    }

    /// <summary>
    /// Detay satiri logu. Kart logundan ayri satir acilir ama ust_tablo_id /
    /// ust_kayit_id ile karta baglanir - UInfo ekrani kart gecmisinde birlikte gosterir.
    /// </summary>
    private async Task DetayLogAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        KartTanimi tanim, DetayTanimi detay, short islemTipi, long detayId, long ustId,
        Dictionary<string, string> bilgi, YazmaBaglami baglam, CancellationToken iptal)
        => await _log.YazAsync(baglanti, islem, islemTipi,
            detay.LogTabloId == 0 ? tanim.LogTabloId : detay.LogTabloId,
            detayId, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi,
            ustTabloId: tanim.LogTabloId, ustKayitId: ustId,
            tarafId: tanim.Ad == "cari" ? (int)ustId : null,
            stokId: tanim.Ad == "stok" ? (int)ustId : null,
            iptal: iptal);

    private static Dictionary<string, object?> DetayDegerleri(DetayTanimi detay,
        Dictionary<string, JsonElement> gelen, bool yeni)
    {
        var sonuc = new Dictionary<string, object?>(StringComparer.Ordinal);

        foreach (var (ad, deger) in gelen)
        {
            if (ad == "id") continue;

            var alan = detay.Alanlar.FirstOrDefault(a => a.Ad == ad)
                ?? throw GentegreHatasi.Dogrulama($"{detay.Ad}: bilinmeyen alan {ad}",
                       new AlanHatasi($"{detay.Ad}.{ad}", "Bu detayda boyle bir alan yok."));

            if (!alan.Yazilabilir) continue;

            var cevrilmis = DegerCevirici.Cevir(deger, alan.Tip, $"{detay.Ad}.{ad}", ad);
            DegerCevirici.UzunlukKontrol(alan, cevrilmis, $"{detay.Ad}.{ad}");
            sonuc[ad] = cevrilmis;
        }

        if (yeni)
            foreach (var zorunlu in detay.Alanlar.Where(a => a.Zorunlu))
                if (!sonuc.TryGetValue(zorunlu.Ad, out var d) || d is null ||
                    (d is string m && m.Length == 0))
                    throw GentegreHatasi.Dogrulama($"{detay.Ad}: {zorunlu.Etiket} zorunlu.",
                        new AlanHatasi($"{detay.Ad}.{zorunlu.Ad}", $"{zorunlu.Etiket} boş bırakılamaz."));

        return sonuc;
    }
}
