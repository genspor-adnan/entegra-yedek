using Npgsql;

namespace Gentegre.Veri.Depolar;

public sealed record YerKaydi(short Id, string Ad);
public sealed record IlceKaydi(int Id, short IlId, string Ad);
public sealed record YerlerYaniti(IReadOnlyList<YerKaydi> Iller, IReadOnlyList<IlceKaydi> Ilceler, IReadOnlyList<YerKaydi> Ulkeler);

/// <summary>
/// Il/Ilce/Ulke referans listeleri (039_il_ilce_ulke.sql). Tek statik payload - degismeyen
/// veri, cagiran (GenDetayTablo "adresler") tek seferde cekip client'ta filtreler.
/// </summary>
public sealed class ReferansDeposu
{
    private readonly VeriKaynagi _veri;

    public ReferansDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<YerlerYaniti> YerlerAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var iller = new List<YerKaydi>();
        await using (var komut = new NpgsqlCommand("select id, ad from public.il order by ad", baglanti))
        await using (var okuyucu = await komut.ExecuteReaderAsync(iptal))
            while (await okuyucu.ReadAsync(iptal))
                iller.Add(new YerKaydi(okuyucu.GetInt16(0), okuyucu.GetString(1)));

        var ulkeler = new List<YerKaydi>();
        await using (var komut = new NpgsqlCommand("select id, ad from public.ulke order by ad", baglanti))
        await using (var okuyucu = await komut.ExecuteReaderAsync(iptal))
            while (await okuyucu.ReadAsync(iptal))
                ulkeler.Add(new YerKaydi(okuyucu.GetInt16(0), okuyucu.GetString(1)));

        var ilceler = new List<IlceKaydi>();
        await using (var komut = new NpgsqlCommand("select id, il_id, ad from public.ilce where aktif = 1 order by ad", baglanti))
        await using (var okuyucu = await komut.ExecuteReaderAsync(iptal))
            while (await okuyucu.ReadAsync(iptal))
                ilceler.Add(new IlceKaydi(okuyucu.GetInt32(0), okuyucu.GetInt16(1), okuyucu.GetString(2)));

        return new YerlerYaniti(iller, ilceler, ulkeler);
    }
}
