using System.Diagnostics;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Veri.Depolar;

public sealed class ListeDeposu
{
    private readonly VeriKaynagi _veri;
    public ListeDeposu(VeriKaynagi veri) => _veri = veri;

    /// <summary>
    /// Liste sorgusu. Kolon kumesi CAGIRAN tarafindan (alan yetkisiyle) suzulmus
    /// gelir - yetkisiz kolon SQL'e hic girmez, yanittan sonradan silinmez.
    /// </summary>
    public async Task<ListeYaniti> SorgulaAsync(KaynakTanimi kaynak, ListeIstegi istek,
        IReadOnlyList<KolonTanimi> kolonlar, int? subeId, IReadOnlyList<int>? kapsam,
        string izlemeNo, CancellationToken iptal = default)
    {
        var kronometre = Stopwatch.StartNew();

        var satirUretici = new SorguUretici(kaynak);
        var satirSorgu = satirUretici.Satirlar(istek, kolonlar, subeId, kapsam);

        var sayimSorgu = new SorguUretici(kaynak).Sayim(istek, subeId, kapsam);
        var toplamSorgu = new SorguUretici(kaynak).Toplamlar(istek, kolonlar, subeId, kapsam);

        await using var baglanti = await _veri.AcAsync(iptal);

        var satirlar = new List<IDictionary<string, object?>>();
        await using (var komut = _veri.Komut(baglanti, satirSorgu.Sql, satirSorgu.Parametreler))
        await using (var okuyucu = await komut.ExecuteReaderAsync(iptal))
        {
            while (await okuyucu.ReadAsync(iptal))
            {
                var satir = new Dictionary<string, object?>(okuyucu.FieldCount, StringComparer.Ordinal);
                for (var i = 0; i < okuyucu.FieldCount; i++)
                {
                    var ad = okuyucu.GetName(i);
                    satir[ad] = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
                }
                satirlar.Add(satir);
            }
        }

        long toplamKayit;
        await using (var komut = _veri.Komut(baglanti, sayimSorgu.Sql, sayimSorgu.Parametreler))
            toplamKayit = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal) ?? 0L);

        Dictionary<string, object?>? toplamlar = null;
        if (toplamSorgu is not null)
        {
            await using var komut = _veri.Komut(baglanti, toplamSorgu.Sql, toplamSorgu.Parametreler);
            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (await okuyucu.ReadAsync(iptal))
            {
                toplamlar = new Dictionary<string, object?>(StringComparer.Ordinal);
                for (var i = 0; i < okuyucu.FieldCount; i++)
                    toplamlar[okuyucu.GetName(i)] = okuyucu.IsDBNull(i) ? null : okuyucu.GetValue(i);
            }
        }

        kronometre.Stop();

        return new ListeYaniti
        {
            Satirlar = satirlar,
            ToplamKayit = toplamKayit,
            Toplamlar = toplamlar,
            SureMs = kronometre.ElapsedMilliseconds,
            IzlemeNo = izlemeNo
        };
    }
}
