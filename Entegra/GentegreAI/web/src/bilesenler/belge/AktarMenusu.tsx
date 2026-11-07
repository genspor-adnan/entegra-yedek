import { useEffect, useRef, useState } from 'react';
import { c } from '../../dil/ceviri';

/** Kalemler sekmesindeki "Aktar" seçeneği: kaynak belge türü + yazı + ikon. */
export interface AktarSecenegi { tur: number; ad: string; ikon: string }

/** Fiş kartı: Siparişten / İrsaliyeden (alış fişinde 9 / 10). */
export const FIS_AKTAR = (alisMi: boolean): AktarSecenegi[] => [
  { tur: alisMi ? 9 : 19, ad: 'Siparişten', ikon: '📋' },
  { tur: alisMi ? 10 : 14, ad: 'İrsaliyeden', ikon: '🚚' },
];
/** Satış siparişi kartı: Tekliften (yalnız KABUL teklifler; pencere süzer). */
export const SIPARIS_AKTAR: AktarSecenegi[] = [{ tur: 18, ad: 'Tekliften Aktar', ikon: '⇩' }];
/** İrsaliye kartı: Siparişten (alış irsaliyesinde alış siparişi) - Kalemler sekmesinde (kullanıcı 07.11.2026). */
export const IRSALIYE_AKTAR = (alisMi: boolean): AktarSecenegi[] => [{ tur: alisMi ? 9 : 19, ad: 'Siparişten Aktar', ikon: '📋' }];

/**
 * "⇩ Aktar ▾" (kullanıcı 07.11.2026): Kalemler sekmesinde Sil'in sağında. Tek seçenekte düz düğme ("⇩ Tekliften
 * Aktar"), birden çokta açılır menü. Dışarı tık / Esc kapatır (DonusumMenusu deseni).
 */
export function AktarMenusu({ secenekler, onSec }: { secenekler: AktarSecenegi[]; onSec(kaynakTur: number): void }) {
  const [acik, setAcik] = useState(false);
  const kok = useRef<HTMLSpanElement>(null);
  useEffect(() => {
    if (!acik) return;
    const kapat = (e: MouseEvent) => { if (!kok.current?.contains(e.target as Node)) setAcik(false) };
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    window.addEventListener('mousedown', kapat);
    window.addEventListener('keydown', esc);
    return () => { window.removeEventListener('mousedown', kapat); window.removeEventListener('keydown', esc) };
  }, [acik]);
  const sec = (tur: number) => { setAcik(false); onSec(tur) };
  if (secenekler.length === 0) return null;
  if (secenekler.length === 1) {
    const t = secenekler[0];
    return (
      <button type="button" className="d" title={c('Kaynak belgenin açık satırlarını bu belgeye aktar')}
              onClick={() => sec(t.tur)}>
        {t.ikon} {c(t.ad)}
      </button>
    );
  }
  return (
    <span className="dugme-menu" ref={kok}>
      <button type="button" className="d" title={c('Kaynak belgenin açık satırlarını bu belgeye aktar')}
              aria-haspopup="menu" aria-expanded={acik} onClick={() => setAcik(a => !a)}>
        ⇩ {c('Aktar')} ▾
      </button>
      {acik && (
        <div className="dugme-menu-liste" role="menu">
          {secenekler.map(t => (
            <button key={t.tur} type="button" className="mi" role="menuitem" onClick={() => sec(t.tur)}>
              {t.ikon} {c(t.ad)}
            </button>
          ))}
        </div>
      )}
    </span>
  );
}
