import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { BekleyenIstemYaniti } from '../../api/uclar/basvuruIstem';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj } from '../mesaj';

/**
 * BANKO SERBEST BARI (912) — başvuru kartında.
 *
 * Poliklinikte hekimin muayenede açtığı lab/radyoloji isteği "ücretlendirme
 * bekliyor" (serbest=0) durumundadır ve çalışma listelerinde GÖRÜNMEZ. Banko
 * tetkiği başvuruya ekleyip ücretlendirdikten sonra buradan SERBEST BIRAKIR;
 * istem lab/radyoloji worklist'ine düşer. Ödeme ayrı - serbest bırakmak
 * tahsilatı beklemez (açık borç kalabilir).
 *
 * Bekleyen istem yoksa bar hiç çizilmez.
 */
export function BankoSerbestBar({ belgeId, yenileAnahtari }: {
  belgeId: number;
  /** Değişince yeniden çeker (tetkik eklendi/istem açıldı). */
  yenileAnahtari?: number;
}) {
  const { yetki } = useOturum();
  const [b, setB] = useState<BekleyenIstemYaniti | null>(null);
  const [mesgul, setMesgul] = useState(false);

  const cek = useCallback(() => {
    if (!belgeId) return;
    api.basvuruBekleyenIstem(belgeId).then(setB).catch(() => setB(null));
  }, [belgeId]);
  useEffect(() => { cek() }, [cek, yenileAnahtari]);

  if (!b || b.toplam === 0) return null;
  const hepsi = [...b.lab, ...b.radyoloji];

  const serbest = async () => {
    setMesgul(true);
    await guvenli(async () => {
      const y = await api.basvuruIstemSerbest(belgeId);
      mesaj(y.mesaj);
      cek();
    });
    setMesgul(false);
  };

  return (
    <div className="banko-serbest" style={{
      display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap',
      margin: '8px 0', padding: '8px 12px', borderRadius: 6,
      background: '#fff6e5', border: '1px solid #e0a83c', color: '#7a5300',
    }}>
      <span style={{ fontWeight: 700 }}>
        🏦 Banko: {b.toplam} tetkik ücretlendirme bekliyor
      </span>
      <span style={{ fontSize: 12, opacity: 0.85 }}>
        {hepsi.map(i => `${i.tur === 'lab' ? '🧪' : '📷'} ${i.tetkik}`).join(' · ')}
      </span>
      <span style={{ flex: 1 }} />
      {yetki('belge', 'degistir') && (
        <button className="d bir" disabled={mesgul} onClick={() => void serbest()}>
          ✓ Serbest Bırak
        </button>
      )}
    </div>
  );
}
