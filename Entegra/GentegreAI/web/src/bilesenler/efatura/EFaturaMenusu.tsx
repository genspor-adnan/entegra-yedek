import { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { api } from '../../api/istemci';
import type { EFaturaDurumu, EFaturaKodu } from '../../api/uclar/efatura';
import { efaturaCalistir } from './efaturaIslem';
import { mesaj } from '../mesaj';

/**
 * e-FATURA ▾ - Delphi UFaturalar e-Fatura menüsünün giden fatura maddeleri, AYNI
 * sıra ve ayraçlarla (kullanıcı 11.10.2026: "alta doğru menü açılsın daha önce
 * delphi de yaptığımız gibi"):
 *
 *     Hazırla · Önizle · Gönder | PDF / HTML / XML Kaydet |
 *     Seri Değiştir · Hazırı Geri Al | Mesaj Geçmişini Göster
 *
 * Menü açılınca belgenin durumu sunucudan okunur; pasif maddenin sebebi
 * title'da (kural tek yerde: EFaturaKodlari.Engel).
 */
const MADDELER: (readonly [EFaturaKodu, string, string] | null)[] = [
  ['ebelge.hazirla', '🛠', 'Hazırla'],
  ['ebelge.onizle', '👁', 'Önizle'],
  ['ebelge.gonder', '📤', 'Gönder'],
  null,
  ['ebelge.pdf', '📕', 'PDF Kaydet'],
  ['ebelge.html', '🌐', 'HTML Kaydet'],
  ['ebelge.xml', '🧾', 'XML Kaydet'],
  null,
  ['ebelge.seri', '🔁', 'Seri Değiştir'],
  ['ebelge.sifirla', '↩', 'Hazırı Geri Al'],
  null,
  ['ebelge.mesajlar', '🗒', 'Mesaj Geçmişini Göster'],
];

export function EFaturaMenusu({ belgeId, devre, devreSebep, onDegisti, etiket = 'e-Fatura' }: {
  belgeId: number;
  devre?: boolean;
  devreSebep?: string;
  /** Durum değiştiren adımdan sonra (liste / kart tazelensin). */
  onDegisti?(): void;
  etiket?: string;
}) {
  const [acik, setAcik] = useState(false);
  const [durum, setDurum] = useState<EFaturaDurumu | null>(null);
  const [hata, setHata] = useState('');
  const kok = useRef<HTMLSpanElement>(null);
  const liste = useRef<HTMLDivElement>(null);
  // SABIT KONUM: menu kart modalinin / .kagrup'un overflow'unda kirpiliyordu -
  //   dugmeye gore ekrana sabitlenir, altta yer yoksa yukari acilir.
  const [konum, setKonum] = useState<React.CSSProperties>({});
  const ac = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.stopPropagation();
    // PASIF DUGME SESSIZ KALMASIN: sebep mesajla soylenir (title'i kimse okumuyor).
    if (devre || !belgeId) { mesaj(devreSebep || 'Önce belgeyi kaydedin.'); return }
    const d = e.currentTarget.getBoundingClientRect();
    const asagi = window.innerHeight - d.bottom > 380;
    setKonum({ position: 'fixed', left: Math.min(d.left, window.innerWidth - 240),
               ...(asagi ? { top: d.bottom + 3 } : { bottom: window.innerHeight - d.top + 3 }) });
    setAcik(a => !a);
  };

  useEffect(() => {
    if (!acik) return;
    setDurum(null); setHata('');
    api.efaturaDurum(belgeId).then(setDurum).catch(h => setHata(String(h?.message ?? h)));
    const kapat = (e: MouseEvent) => {
      const h = e.target as Node;
      if (!kok.current?.contains(h) && !liste.current?.contains(h)) setAcik(false);
    };
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    window.addEventListener('mousedown', kapat);
    window.addEventListener('keydown', esc);
    return () => { window.removeEventListener('mousedown', kapat); window.removeEventListener('keydown', esc) };
  }, [acik, belgeId]);

  const calistir = async (kod: EFaturaKodu) => {
    setAcik(false);
    await efaturaCalistir(kod, belgeId, { tazele: onDegisti });
  };

  return (
    <span className="dugme-menu efm" ref={kok}>
      <button type="button" className={'d bir' + (devre || !belgeId ? ' efm-pasif' : '')}
              title={devre ? devreSebep : 'e-Fatura işlemleri'}
              onClick={ac}>
        📨 {etiket} ▾
      </button>
      {acik && createPortal(
        <div className="dugme-menu-liste efm-liste" role="menu" style={konum} ref={liste}>
          {durum && (
            <div className="efm-bas">
              <b>{durum.turAdi}</b> · {durum.durumAdi}
              {durum.belgeNo && durum.belgeNo !== '0' && <> · {durum.belgeNo}</>}
              {durum.testMi && <span className="efm-test">TEST</span>}
            </div>
          )}
          {hata && <div className="efm-bas hata">{hata}</div>}
          {MADDELER.map((m, i) => m === null
            ? <div key={i} className="menu-ayrac" />
            : (
              <button key={m[0]} type="button" className="mi" role="menuitem"
                      disabled={!durum || !!durum.engeller[m[0]]}
                      title={durum?.engeller[m[0]] ?? undefined}
                      onClick={() => void calistir(m[0])}>
                <span className="efm-ikon">{m[1]}</span>{m[2]}
              </button>
            ))}
        </div>, document.body)}
      <style>{EFM_STILI}</style>
    </span>
  );
}

const EFM_STILI = `
.efm-liste { min-width: 220px; z-index: 400; }
.efm-liste .mi { display: flex; align-items: center; gap: 8px; padding: 5px 8px; }
.efm-ikon { width: 18px; text-align: center; }
.efm .efm-pasif { opacity: .55; }
.efm-bas { font-size: 11.5px; color: var(--soluk); padding: 4px 8px 6px; border-bottom: 1px solid var(--cizgi); margin-bottom: 4px; white-space: nowrap; }
.efm-bas.hata { color: var(--kirmizi, #c0392b); white-space: normal; }
.efm-test { margin-left: 6px; font-size: 10px; font-weight: bold; color: #b45309; background: #fef3c7; border-radius: 3px; padding: 0 4px; }
`;
