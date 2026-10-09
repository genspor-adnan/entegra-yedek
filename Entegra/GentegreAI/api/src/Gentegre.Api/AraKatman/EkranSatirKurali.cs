using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// EKRAN SATIR KISITININ KART TARAFI (1003, kullanıcı 09.10.2026: "tedarikçi
/// satır süzgecini de ekle"). Liste koşulu <see cref="EkranKodlari.SatirKisiti"/>
/// ile sorguya girer; kart uçları kimliği yoldan aldığı için aynı kural burada:
///
///   - Kayıt kısıt dışındaysa <b>bulunamadı</b> (KayitErisimi): kimliği deneyen
///     kişi müşteri kaydının varlığını öğrenemez.
///   - Yeni kayıt / güncelleme kısıtın dışına ÇIKAMAZ: Tedarikçiler'den gelen
///     kullanıcı tedarikçi bayrağını kapatıp kaydı müşteriye çeviremez, kişiyi
///     tedarikçi olmayan bir cariye bağlayamaz.
///
/// Kullanıcıda eski kodun kendisi (`cari`) varsa hiçbir şey yapmaz.
/// </summary>
public static class EkranSatirKurali
{
    public static async Task KartAsync(string ad, IstekBaglami baglam, KayitErisimi erisim,
        IDictionary<string, object?>? degerler, long? id, Islem islem, CancellationToken iptal)
    {
        var k = EkranKodlari.Kisit(ad, kod => baglam.Yetkiler.VarTam(kod, islem));
        if (k is null) return;

        if (id is not null)
            await erisim.IsteAsync(baglam, ad, id.Value, "Kayıt bulunamadı.", iptal);
        if (degerler is null) return;

        if (k.BayrakAlani is { } bayrak && (id is null || degerler.ContainsKey(bayrak))
            && !Dogru(degerler.TryGetValue(bayrak, out var b) ? b : null))
            throw GentegreHatasi.Yasak("Bu ekrandan yalnız tedarikçi kaydı açılır ve değiştirilir; "
                                     + "Tedarikçi işareti kapatılamaz.");

        if (k.UstAlani is { } ust && k.UstKaynak is { } ustKaynak
            && (id is null || degerler.ContainsKey(ust)))
        {
            var ustId = Sayi(degerler.TryGetValue(ust, out var u) ? u : null);
            if (ustId is null)
                throw GentegreHatasi.Yasak("Kişi bir tedarikçiye bağlı olmalı.");
            await erisim.IsteAsync(baglam, ustKaynak, ustId.Value, "Bağlı cari bulunamadı.", iptal);
        }
    }

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
