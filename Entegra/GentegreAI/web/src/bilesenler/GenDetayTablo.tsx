import type { DetayFarki, KartDetayMeta } from '../api/sozlesme';

type Satir = Record<string, unknown> & { id?: number };

/**
 * Detay tablosunun duzenleme durumu. Sunucuya TAM LISTE degil FARK gonderilir
 * (§3.2), bu yuzden ilk hal ile guncel hal birlikte tutulur.
 */
export interface DetayDurumu {
  ilk: Satir[];        // karttan geldigi hali
  guncel: Satir[];     // ekranda duzenlenmis hali
  silinen: number[];   // kaldirilan mevcut satirlarin id'leri
}

export const bosDetay = (satirlar: Satir[] = []): DetayDurumu => ({
  ilk: satirlar.map(s => ({ ...s })),
  guncel: satirlar.map(s => ({ ...s })),
  silinen: [],
});

/** Ekrandaki durumdan sunucunun bekledigi fark listesini uretir. */
export function detayFarki(durum: DetayDurumu): DetayFarki {
  const eklenen = durum.guncel.filter(s => s.id === undefined || s.id === null);

  const degisen = durum.guncel
    .filter(s => s.id !== undefined && s.id !== null)
    .map(s => {
      const eski = durum.ilk.find(i => i.id === s.id);
      if (!eski) return null;
      // Yalniz gercekten degisen alanlar gonderilir
      const fark: Satir = { id: s.id };
      let degisti = false;
      Object.keys(s).forEach(alan => {
        if (alan === 'id') return;
        if (String(s[alan] ?? '') !== String(eski[alan] ?? '')) { fark[alan] = s[alan]; degisti = true }
      });
      return degisti ? fark : null;
    })
    .filter(Boolean) as Satir[];

  return {
    eklenen: eklenen.length ? eklenen : undefined,
    degisen: degisen.length ? degisen : undefined,
    silinen: durum.silinen.length ? durum.silinen : undefined,
  };
}

interface Props {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  hatalar: Record<string, string>;
  onDegis(yeni: DetayDurumu): void;
}

export function GenDetayTablo({ meta, durum, saltOkunur, hatalar, onDegis }: Props) {
  const alanlar = meta.alanlar.filter(a => a.ad !== 'id');

  const hucreDegis = (satirIndeks: number, alan: string, deger: unknown) => {
    const guncel = durum.guncel.map((s, i) => i === satirIndeks ? { ...s, [alan]: deger } : s);
    onDegis({ ...durum, guncel });
  };

  const satirEkle = () => {
    const yeni: Satir = {};
    alanlar.forEach(a => { yeni[a.ad] = a.tip === 'mantik' ? 0 : '' });
    onDegis({ ...durum, guncel: [...durum.guncel, yeni] });
  };

  const satirSil = (satirIndeks: number) => {
    const satir = durum.guncel[satirIndeks];
    const guncel = durum.guncel.filter((_, i) => i !== satirIndeks);
    const silinen = satir.id != null ? [...durum.silinen, satir.id] : durum.silinen;
    onDegis({ ...durum, guncel, silinen });
  };

  return (
    <div className="kagrup">
      <h6>
        {meta.baslik}
        {!saltOkunur && <button type="button" className="d" onClick={satirEkle}>+ Satir</button>}
      </h6>

      <table className="detay-tablo">
        <thead>
          <tr>
            {alanlar.map(a => <th key={a.ad}>{a.baslik}{a.zorunlu && ' *'}</th>)}
            {!saltOkunur && <th />}
          </tr>
        </thead>
        <tbody>
          {durum.guncel.map((satir, i) => (
            <tr key={satir.id ?? `yeni-${i}`}>
              {alanlar.map(a => (
                <td key={a.ad}>
                  {a.tip === 'mantik' ? (
                    <input
                      type="checkbox"
                      checked={Number(satir[a.ad]) === 1 || satir[a.ad] === true}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.checked)}
                    />
                  ) : a.kodlar ? (
                    <select
                      value={String(satir[a.ad] ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {Object.entries(a.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  ) : (
                    <input
                      value={String(satir[a.ad] ?? '')}
                      maxLength={a.enFazlaUzunluk ?? undefined}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    />
                  )}
                  {hatalar[`${meta.ad}.${a.ad}`] && (
                    <span className="alan-hata">{hatalar[`${meta.ad}.${a.ad}`]}</span>
                  )}
                </td>
              ))}
              {!saltOkunur && (
                <td className="hiza-orta">
                  <button type="button" className="d teh" onClick={() => satirSil(i)}>×</button>
                </td>
              )}
            </tr>
          ))}
          {durum.guncel.length === 0 && (
            <tr><td colSpan={alanlar.length + 1} className="bos">Satir yok</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
