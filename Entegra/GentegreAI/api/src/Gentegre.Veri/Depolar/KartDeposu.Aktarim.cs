using Gentegre.Cekirdek.Aktarim;
using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Veri.Depolar;

/// <summary>DELPHI AKTARIMI - salt okunur kip (1089): ekran düğmeleri için okuma tarafı.</summary>
public sealed partial class KartDeposu
{
    /// <summary>Kurum Delphi kaynaklı mı (kurum_profil.veri_kaynagi, şube 0).</summary>
    public async Task<bool> DelphiKipiAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("select public.fn_veri_kaynagi_delphi()", null);
        return await komut.ExecuteScalarAsync(iptal) is true;
    }

    /// <summary>Bu kart satırı Delphi'den mi geldi (ve kurum Delphi kaynaklı mı)?</summary>
    public async Task<bool> DelphiKaydiAsync(KartTanimi tanim, long id, CancellationToken iptal = default)
    {
        if (!AktarilanKaynaklar.Tablolar.Contains(tanim.Tablo)) return false;
        if (tanim.Tablo == "public.stok_durum") return await DelphiKipiAsync(iptal);   // aynası; aktarım kolonu yok
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            $"select public.fn_delphi_kaynakli(aktarim_kaynak) from {tanim.Tablo} where {tanim.IdKolonu} = @p0", null, id);
        return await komut.ExecuteScalarAsync(iptal) is true;
    }
}
