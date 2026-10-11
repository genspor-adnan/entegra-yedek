import { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import type { ListeSatiri } from '../../api/sozlesme';
import { mesaj } from '../mesaj';
import { EFM_STILI } from './EFaturaMenusu';
// IKONLAR DELPHI'DEKININ AYNISI: Utablo.dfm Tablo.PNGImageList1 - UFaturalar e-Fatura
//   menusunun GELEN belge maddeleri (Onizle 46, Kabul Et 11, Red Et 31, 'Sistem'e Tasi 11,
//   PDF/HTML/XML 10, Mesajlar 43; dugme 30).
import efaturaIkon from './ikon/efatura.png';
import kabulIkon from './ikon/kabul.png';
import kaydetIkon from './ikon/kaydet.png';
import mesajlarIkon from './ikon/mesajlar.png';
import onizleIkon from './ikon/onizle.png';
import redIkon from './ikon/red.png';

/**
 * GELEN KUTUSU e-FATURA MENÜSÜ (kullanıcı 11.10.2026: "gelen kutusunu da yeni
 * menüye çevir"). Delphi'deki gelen belge maddeleri, giden menüyle aynı görünüm;
 * seçili satırların hepsinde çalışır (tek belge isteyen maddeler çokluda pasif).
 *
 *     Önizle | Kabul Et · Red Et | Alış Faturasına Aktar |
 *     PDF / HTML / XML Kaydet | Mesaj Geçmişini Göster
 *
 * İşi liste aksiyon zinciri yapar (gelenBelgeIslem) - burası yalnız menüdür.
 */
const TEK = ['ebelge.onizle', 'ebelge.pdf', 'ebelge.mesajlar'];
const MADDELER: (readonly [string, string, string] | null)[] = [
  ['ebelge.onizle', onizleIkon, 'Önizle'],
  null,
  ['gelen.kabul', kabulIkon, 'Kabul Et'],
  ['gelen.red', redIkon, 'Red Et'],
  ['gelen.aktar', kabulIkon, 'Alış Faturasına Aktar'],
  null,
  ['ebelge.pdf', kaydetIkon, 'PDF Kaydet'],
  ['ebelge.html', kaydetIkon, 'HTML Kaydet'],
  ['ebelge.xml', kaydetIkon, 'XML Kaydet'],
  null,
  ['ebelge.mesajlar', mesajlarIkon, 'Mesaj Geçmişini Göster'],
];

/** Pasiflik sebebi; null = aktif. Kabul / red yalnız YANIT BEKLEYEN (100) ticari belgede. */
export function gelenEngel(kod: string, satirlar: ListeSatiri[]): string | null {
  if (satirlar.length === 0) return 'Önce belge seçin.';
  if (satirlar.length > 1 && TEK.includes(kod)) return 'Bu işlem için tek bir belge seçin.';
  if ((kod === 'gelen.kabul' || kod === 'gelen.red') && !satirlar.some(s => Number(s.durum) === 100))
    return 'Yalnız yanıt bekleyen (ticari) belge kabul / red edilir.';
  return null;
}

export function GelenMenusu({ satirlar, etiket = 'E-Fatura', onSec }: {
  satirlar: ListeSatiri[];
  etiket?: string;
  onSec(kod: string): void;
}) {
  const [acik, setAcik] = useState(false);
  const [konum, setKonum] = useState<React.CSSProperties>({});
  const kok = useRef<HTMLSpanElement>(null);
  const liste = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!acik) return;
    const kapat = (e: MouseEvent) => {
      const h = e.target as Node;
      if (!kok.current?.contains(h) && !liste.current?.contains(h)) setAcik(false);
    };
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    window.addEventListener('mousedown', kapat);
    window.addEventListener('keydown', esc);
    return () => { window.removeEventListener('mousedown', kapat); window.removeEventListener('keydown', esc) };
  }, [acik]);

  const ac = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.stopPropagation();
    if (satirlar.length === 0) { mesaj('Önce belge seçin (Ctrl / Shift ile birden çok).'); return }
    const d = e.currentTarget.getBoundingClientRect();
    const asagi = window.innerHeight - d.bottom > 320 || d.top < window.innerHeight - d.bottom;
    setKonum({ position: 'fixed', left: Math.max(4, Math.min(d.left, window.innerWidth - 270)),
               maxHeight: (asagi ? window.innerHeight - d.bottom : d.top) - 12, overflowY: 'auto',
               ...(asagi ? { top: d.bottom + 3, bottom: 'auto' } : { top: 'auto', bottom: window.innerHeight - d.top + 3 }) });
    setAcik(a => !a);
  };

  const coklu = satirlar.length > 1;
  return (
    <span className="dugme-menu efm" ref={kok}>
      <button type="button" className={'d bir' + (satirlar.length === 0 ? ' efm-pasif' : '')} onClick={ac}
              title="Gelen e-Belge işlemleri">
        <img src={efaturaIkon} alt="" width={16} height={16} className="efm-dugme-ikon" /> {etiket}
        {coklu ? ` (${satirlar.length})` : ''} ▾
      </button>
      {acik && createPortal(
        <div className="dugme-menu-liste efm-liste" role="menu" style={konum} ref={liste}>
          <div className="efm-bas">
            {coklu ? <b>{satirlar.length} belge seçili</b>
              : <><b>{String(satirlar[0]?.belgeTuruAdi ?? 'Gelen belge')}</b> · {String(satirlar[0]?.durumAdi ?? '')}
                  {' · '}{String(satirlar[0]?.belgeNo ?? '')}</>}
          </div>
          {MADDELER.map((m, i) => m === null
            ? <div key={i} className="menu-ayrac" />
            : (
              <button key={m[0]} type="button" className="mi" role="menuitem"
                      disabled={gelenEngel(m[0], satirlar) !== null}
                      title={gelenEngel(m[0], satirlar) ?? undefined}
                      onClick={() => { setAcik(false); onSec(m[0]) }}>
                <span className="efm-ikon"><img src={m[1]} alt="" width={16} height={16} /></span>{m[2]}
              </button>
            ))}
        </div>, document.body)}
      <style>{EFM_STILI}</style>
    </span>
  );
}
