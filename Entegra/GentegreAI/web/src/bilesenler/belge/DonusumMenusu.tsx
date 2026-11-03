import { useEffect, useRef, useState } from 'react';
import { HEDEFLER } from './donusumHedefleri';
import { mesaj } from '../mesaj';

const HEDEF_IKON: Record<number, string> = { 10: '🚚', 14: '🚚', 11: '🧾', 15: '🧾', 12: '🧮', 16: '🧮', 13: '📑', 17: '📑', 19: '📋' };

/**
 * BELGE DÖNÜŞTÜR ▾ (kullanıcı 03.11.2026: "satış irs kartında dönüştür butona basınca alta hedef menüsü çıksın: Satış
 * Faturası / Satış Fişi / Satış Tahakkuku"). Hedefler dönüşüm penceresinin listesinden (HEDEFLER) - liste ekranındaki
 * menüyle aynı; seçilen hedef pencereyi ÖN SEÇİLİ açar. Menü düğmenin altında açılır, dışarı tık / Esc kapatır.
 */
export function DonusumMenusu({ kaynakTur, devre, devreSebep, onSec, title }: {
  kaynakTur: number;
  devre?: boolean;
  devreSebep?: string;
  onSec(hedefTur: number): void;
  title?: string;
}) {
  const [acik, setAcik] = useState(false);
  const kok = useRef<HTMLSpanElement>(null);
  const hedefler = HEDEFLER[kaynakTur] ?? [];

  useEffect(() => {
    if (!acik) return;
    const kapat = (e: MouseEvent) => { if (!kok.current?.contains(e.target as Node)) setAcik(false) };
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    window.addEventListener('mousedown', kapat);
    window.addEventListener('keydown', esc);
    return () => { window.removeEventListener('mousedown', kapat); window.removeEventListener('keydown', esc) };
  }, [acik]);

  return (
    <span className="dugme-menu" ref={kok}>
      <button type="button" className={'d' + (devre ? ' efm-pasif' : '')} title={title} aria-haspopup="menu" aria-expanded={acik}
              onClick={() => {
                // PASİF DÜĞME SESSİZ KALMASIN: sebep mesajla söylenir (EFaturaMenusu deseni).
                if (devre) { mesaj(devreSebep || 'Önce belgeyi kaydedin.'); return }
                setAcik(a => !a);
              }}>
        🧾 Belge Dönüştür ▾
      </button>
      {acik && (
        <div className="dugme-menu-liste" role="menu">
          {hedefler.map(h => (
            <button key={h.kod} type="button" className="mi" role="menuitem"
                    onClick={() => { setAcik(false); onSec(h.kod) }}>
              {HEDEF_IKON[h.kod] ?? '⇢'} {h.ad}
            </button>
          ))}
        </div>
      )}
    </span>
  );
}
