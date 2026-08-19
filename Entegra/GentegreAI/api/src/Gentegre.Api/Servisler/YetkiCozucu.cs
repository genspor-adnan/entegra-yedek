using System.Collections.Concurrent;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// Yetki listesi token'a gomulmez; her istekte rolden cozulur. Maliyeti dusuk
/// tutmak icin cozulmus set bellekte tutulur ve YALNIZ rol.yetki_surumu
/// degistiginde yeniden yuklenir - yetki degisimi bir sonraki istekte etkili olur.
/// </summary>
public sealed class YetkiCozucu
{
    private readonly YetkiDeposu _depo;
    private readonly ConcurrentDictionary<int, YetkiSeti> _onbellek = new();

    public YetkiCozucu(YetkiDeposu depo) => _depo = depo;

    public async Task<YetkiSeti> CozAsync(int kullaniciId, CancellationToken iptal = default)
    {
        var surum = await _depo.YetkiSurumuAsync(kullaniciId, iptal);

        if (_onbellek.TryGetValue(kullaniciId, out var mevcut) && mevcut.YetkiSurumu == surum)
            return mevcut;

        var yetkiler = await _depo.YetkilerAsync(kullaniciId, iptal);
        var alanlar = await _depo.AlanYetkileriAsync(kullaniciId, iptal);

        var set = new YetkiSeti(surum, yetkiler, alanlar);
        _onbellek[kullaniciId] = set;
        return set;
    }

    public void Temizle(int kullaniciId) => _onbellek.TryRemove(kullaniciId, out _);
}
