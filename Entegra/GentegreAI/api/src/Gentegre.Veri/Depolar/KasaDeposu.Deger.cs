using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Okuma / donusum yardimcilari: satir sozlugu, tip cevrimleri, komut kurma ve motor fonksiyonu cagrisi. Is kurali YOK.
/// </summary>
public sealed partial class KasaDeposu
{
    private async Task<IDictionary<string, object?>> BaslikSozlukAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction tx, int id, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select doviz_cinsi as \"dovizCinsi\", doviz_kuru as \"dovizKuru\" " +
            "from public.kasa_islem where id = @p0", baglanti, tx);
        komut.Parameters.AddWithValue("p0", id);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        return await o.ReadAsync(iptal) ? Satir(o) : new Dictionary<string, object?>();
    }

    private async Task<KasaIslemTuru?> TurOkuAsync(NpgsqlConnection baglanti, NpgsqlTransaction tx,
        int tur, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            select kod, ad, grup, cari_zorunlu, kalem_turu, fis_mi, aktif
              from public.kasa_islem_turu where kod = @p0
            """, baglanti, tx);
        komut.Parameters.AddWithValue("p0", tur);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) return null;
        if (!o.Bayrak("aktif"))
            throw GentegreHatasi.IsKurali($"İşlem türü pasif: {o.Metin("ad")}");

        return new KasaIslemTuru
        {
            Kod = o.Sayi("kod"), Ad = o.Metin("ad"), Grup = o.Metin("grup"),
            CariZorunlu = o.Sayi("cari_zorunlu"), KalemTuru = o.Sayi("kalem_turu"),
            FisMi = o.Bayrak("fis_mi")
        };
    }

    /// <summary>Motor cagrisi - GK422 SQLSTATE'i is-kurali (422) yanitina cevirir.</summary>

    /// <summary>Motor cagrisi - GK422 SQLSTATE'i is-kurali (422) yanitina cevirir.</summary>
    private static async Task MotorAsync(NpgsqlConnection baglanti, NpgsqlTransaction tx,
        string sql, IReadOnlyList<object?> par, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(sql, baglanti, tx);
        for (var i = 0; i < par.Count; i++)
            komut.Parameters.AddWithValue("p" + i, par[i] ?? DBNull.Value);
        await CalistirAsync(komut, iptal);
    }

    private static async Task<object?> CalistirAsync(NpgsqlCommand komut, CancellationToken iptal,
                                                     bool satirSayisi = false)
    {
        try
        {
            return satirSayisi
                ? await komut.ExecuteNonQueryAsync(iptal)
                : await komut.ExecuteScalarAsync(iptal);
        }
        catch (PostgresException hata) when (hata.SqlState == IsKuraliKodu)
        {
            // Motorun kullaniciya yonelik mesaji aynen gecer (Turkce, alan adsiz).
            throw GentegreHatasi.IsKurali(hata.MessageText);
        }
    }

    private static NpgsqlCommand Komut(NpgsqlConnection baglanti, NpgsqlTransaction tx,
                                       string sql, IReadOnlyList<object?> par)
    {
        var komut = new NpgsqlCommand(sql, baglanti, tx);
        for (var i = 0; i < par.Count; i++)
            komut.Parameters.AddWithValue("p" + i, par[i] ?? DBNull.Value);
        return komut;
    }

    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }

    private static string Kirp(string deger, int sinir)
        => deger.Length <= sinir ? deger : deger[..sinir];

    private static long Sayi(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt64(v) : 0;

    private static int? SayiNull(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToInt32(v) : null;

    private static decimal Ondalik(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? Convert.ToDecimal(v) : 0m;

    private static string Metin(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is not null ? v.ToString() ?? "" : "";

    private static DateTime? Tarih(IDictionary<string, object?> d, string ad)
        => d.TryGetValue(ad, out var v) && v is DateTime t ? t : null;
}
