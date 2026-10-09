using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// EKRAN SATIR KISITININ KART TARAFI (1003/1004, kullanıcı 09.10.2026:
/// "tedarikçi satır süzgecini de ekle", "Finans'tan başla"). Liste koşulu
/// <see cref="EkranKodlari.SatirKurali"/> ile sorguya girer; kart uçları
/// kimliği yoldan aldığı için aynı kural burada:
///
///   - Kayıt kısıt dışındaysa <b>bulunamadı</b> (KayitErisimi): kimliği deneyen
///     kişi başka ekranın kaydının varlığını öğrenemez.
///   - Yeni kayıt / güncelleme kısıtın dışına ÇIKAMAZ: Tedarikçiler'den gelen
///     kullanıcı tedarikçi bayrağını kapatamaz, Banka Hesapları'ndan gelen
///     hesabı kasa hesabına çeviremez, kişiyi başka cariye bağlayamaz.
///
/// Kullanıcı kaynağın serbest koduna (veri çekirdeği) sahipse hiçbir şey yapmaz.
/// </summary>
public static class EkranSatirKurali
{
    public static async Task KartAsync(string ad, IstekBaglami baglam, KayitErisimi erisim,
        IDictionary<string, object?>? degerler, long? id, Islem islem, CancellationToken iptal)
    {
        var k = EkranKodlari.Kisit(ad, kod => baglam.Yetkiler.VarTam(kod, islem));
        if (k is null) return;
        if (k.Kurallar.Count == 0)
            throw GentegreHatasi.Bulunamadi("Kayıt bulunamadı.");

        if (id is not null)
            await erisim.IsteAsync(baglam, ad, id.Value, "Kayıt bulunamadı.", iptal);
        if (degerler is null) return;

        // ALAN: bu ekranlara ait değerlerden biri olmalı (yeni kayıtta zorunlu,
        //   güncellemede verildiyse).
        var alanli = k.Kurallar.Where(x => x.Alan is not null).GroupBy(x => x.Alan!);
        foreach (var g in alanli)
        {
            if (id is not null && !degerler.ContainsKey(g.Key)) continue;
            var deger = degerler.TryGetValue(g.Key, out var v) ? v : null;
            if (!g.Any(x => Esit(deger, x.Deger)))
                throw GentegreHatasi.Yasak("Bu kaydı yetkili olduğunuz ekranın dışına çıkaramazsınız ("
                                         + g.Key + ").");
        }

        foreach (var u in k.Kurallar.Where(x => x.UstAlani is not null && x.UstKaynak is not null))
        {
            if (id is not null && !degerler.ContainsKey(u.UstAlani!)) continue;
            var ustId = Sayi(degerler.TryGetValue(u.UstAlani!, out var uv) ? uv : null)
                ?? throw GentegreHatasi.Yasak("Kayıt yetkili olduğunuz bir üst kayda bağlı olmalı.");
            await erisim.IsteAsync(baglam, u.UstKaynak!, ustId, "Bağlı kayıt bulunamadı.", iptal);
        }
    }

    private static bool Esit(object? v, object? beklenen) => beklenen switch
    {
        null => true,
        bool b => Dogru(v) == b,
        _ => Metin(v) == Convert.ToString(beklenen, CultureInfo.InvariantCulture),
    };

    private static string? Metin(object? v) => v switch
    {
        null => null,
        JsonElement { ValueKind: JsonValueKind.String } j => j.GetString(),
        JsonElement j => j.GetRawText(),
        _ => Convert.ToString(v, CultureInfo.InvariantCulture),
    };

    private static bool Dogru(object? v) => v switch
    {
        null => false,
        bool x => x,
        JsonElement { ValueKind: JsonValueKind.True } => true,
        JsonElement { ValueKind: JsonValueKind.Number } j => j.GetDecimal() != 0,
        IConvertible c => Convert.ToDecimal(c, CultureInfo.InvariantCulture) != 0,
        _ => false,
    };

    private static long? Sayi(object? v) => v switch
    {
        null => null,
        JsonElement { ValueKind: JsonValueKind.Number } j => j.GetInt64(),
        JsonElement => null,
        IConvertible c => Convert.ToInt64(c, CultureInfo.InvariantCulture),
        _ => null,
    };
}
