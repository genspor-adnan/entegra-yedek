import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { paraYaz } from '../bicim';

/**
 * DIS HEKIM GONDERIM OZETI (305) - hekim kartinin "Gönderim Geçmişi"
 * sekmesinde, listenin USTUNDE.
 *
 * Altindaki grid satirlari gosterir; buradaki soru baska: "ne kadar, ne
 * zaman, hangi cihazda". Sayilari istemcide grid satirlarindan toplamak
 * SAYFALAMA yuzunden yanlis sonuc verirdi (ilk 25 satirin toplami) - ozet
 * sunucudan tek sorguyla gelir.
 */

interface Ozet {
  toplam: number; buAy: number; raporlanan: number; bekleyen: number;
  tutar: number; sonGonderim: string | null;
}
interface Dagilim { ad: string; adet: number }

const gun = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '—';
};

export function HekimGonderimOzeti({ hekimId }: { hekimId: number }) {
  const [ozet, setOzet] = useState<Ozet | null>(null);
  const [dagilim, setDagilim] = useState<Dagilim[]>([]);

  const yukle = useCallback(async () => {
    try {
      const y = await api.radyolojiHekimOzeti(hekimId);
      setOzet(y.ozet as unknown as Ozet);
      setDagilim(y.dagilim as unknown as Dagilim[]);
    } catch { /* ozet gelmezse sekme yine calisir - grid asil veridir */ }
  }, [hekimId]);

  useEffect(() => { void yukle() }, [yukle]);

  if (!ozet) return null;

  // Cubuk genisligi EN COK istenen modaliteye gore olceklenir: mutlak
  //   piksel vermek az sayida istemde cubuklari gorunmez yapardi.
  const enCok = Math.max(1, ...dagilim.map(d => Number(d.adet)));

  return (
    <div className="kagrup hekim-ozet">
      <h6>Özet</h6>
      <div className="ozet-kutular">
        <div className="k"><b>{ozet.toplam}</b><span>Toplam tetkik</span></div>
        <div className="k"><b>{ozet.buAy}</b><span>Bu ay</span></div>
        <div className="k"><b>{ozet.raporlanan}</b><span>Raporlanan</span></div>
        <div className="k"><b>{ozet.bekleyen}</b><span>Bekleyen</span></div>
        <div className="k"><b>{paraYaz(Number(ozet.tutar ?? 0))}</b><span>Toplam tutar</span></div>
        <div className="k"><b>{gun(ozet.sonGonderim)}</b><span>Son gönderim</span></div>
      </div>

      {dagilim.length > 0 && (
        <div className="ozet-dagilim">
          {dagilim.map(d => (
            <div className="bar" key={d.ad}>
              <span className="ad">{d.ad}</span>
              <span className="ct"
                    style={{ width: `${Math.round((Number(d.adet) / enCok) * 180)}px` }} />
              <span className="sayi">{d.adet}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
