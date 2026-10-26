import { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { api } from '../../api/istemci';
import type { EFaturaDurumu, EFaturaKodu } from '../../api/uclar/efatura';
import { COKLU_KODLAR, efaturaCokluCalistir } from './efaturaIslem';
import { mesaj } from '../mesaj';
// IKONLAR DELPHI'DEKININ AYNISI (kullanici 11.10.2026: "menüdeki tüm ikonlar delphi gibi
//   olsun"): Utablo.dfm Tablo.PNGImageList1 - UFaturalar e-Fatura menusunun ImageIndex'leri
//   (Hazirla 1, Onizle 46, Gonder 50, PDF/HTML/XML 10, Seri 39, Geri Al 17, Mesajlar 43, e-Fatura 30).
import efaturaIkon from './ikon/efatura.png';
import gerialIkon from './ikon/gerial.png';
import gonderIkon from './ikon/gonder.png';
import hazirlaIkon from './ikon/hazirla.png';
import kaydetIkon from './ikon/kaydet.png';
import mesajlarIkon from './ikon/mesajlar.png';
import onizleIkon from './ikon/onizle.png';
import seriIkon from './ikon/seri.png';

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
  ['ebelge.hazirla', hazirlaIkon, 'Hazırla'],
  ['ebelge.onizle', onizleIkon, 'Önizle'],
  ['ebelge.gonder', gonderIkon, 'Gönder'],
  null,
  ['ebelge.pdf', kaydetIkon, 'PDF Kaydet'],
  ['ebelge.html', kaydetIkon, 'HTML Kaydet'],
  ['ebelge.xml', kaydetIkon, 'XML Kaydet'],
  null,
  ['ebelge.seri', seriIkon, 'Seri Değiştir'],
  ['ebelge.sifirla', gerialIkon, 'Hazırı Geri Al'],
  null,
  ['ebelge.mesajlar', mesajlarIkon, 'Mesaj Geçmişini Göster'],
];

export function EFaturaMenusu({ belgeId, belgeIdler, devre, devreSebep, onDegisti, etiket = 'Fatura İşlem' }: {
  belgeId?: number;
  /** ÇOKLU SEÇİM: verilirse menü bu belgelerin hepsinde çalışır (tek-belge maddeleri pasif). */
  belgeIdler?: number[];
  devre?: boolean;
  devreSebep?: string;
  /** Durum değiştiren adımdan sonra (liste / kart tazelensin). */
  onDegisti?(): void;
  etiket?: string;
}) {
  const [acik, setAcik] = useState(false);
  const idler = belgeIdler ?? (belgeId ? [belgeId] : []);
  const coklu = idler.length > 1;
  const [durum, setDurum] = useState<EFaturaDurumu | null>(null);
  const [durumlar, setDurumlar] = useState<EFaturaDurumu[]>([]);
  const [hata, setHata] = useState('');
  const kok = useRef<HTMLSpanElement>(null);
  const liste = useRef<HTMLDivElement>(null);
  // SABIT KONUM: menu kart modalinin / .kagrup'un overflow'unda kirpiliyordu -
  //   dugmeye gore ekrana sabitlenir, altta yer yoksa yukari acilir.
  const [konum, setKonum] = useState<React.CSSProperties>({});
  const ac = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.stopPropagation();
    // PASIF DUGME SESSIZ KALMASIN: sebep mesajla soylenir (title'i kimse okumuyor).
    if (devre || idler.length === 0) { mesaj(devreSebep || 'Önce belgeyi kaydedin.'); return }
    const d = e.currentTarget.getBoundingClientRect();
    // Asagida yer yoksa yukari acilir. top/bottom IKISI de acikca verilir: ortak
    //   .dugme-menu-liste stilindeki `top: 100%` kalinca yukari acilan menu
    //   ekranin altina itiliyordu (kullanici: 768 px ekranda "menü çıkmadı").
    const asagi = window.innerHeight - d.bottom > 380 || d.top < window.innerHeight - d.bottom;
    setKonum({ position: 'fixed', left: Math.max(4, Math.min(d.left, window.innerWidth - 290)),
               maxHeight: (asagi ? window.innerHeight - d.bottom : d.top) - 12, overflowY: 'auto',
               ...(asagi ? { top: d.bottom + 3, bottom: 'auto' } : { top: 'auto', bottom: window.innerHeight - d.top + 3 }) });
    setAcik(a => !a);
  };

  useEffect(() => {
    if (!acik) return;
    setDurum(null); setDurumlar([]); setHata('');
    Promise.all(idler.map(id => api.efaturaDurum(id)))
      .then(d => { setDurumlar(d); setDurum(d[0] ?? null) })
      .catch(h => setHata(String(h?.message ?? h)));
    const kapat = (e: MouseEvent) => {
      const h = e.target as Node;
      if (!kok.current?.contains(h) && !liste.current?.contains(h)) setAcik(false);
    };
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    window.addEventListener('mousedown', kapat);
    window.addEventListener('keydown', esc);
    return () => { window.removeEventListener('mousedown', kapat); window.removeEventListener('keydown', esc) };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acik, idler.join(',')]);

  /** Pasiflik sebebi: tekte belgenin engeli; çokluda tek-belge maddesi ya da HİÇBİR belge uygun değil. */
  const pasif = (kod: EFaturaKodu): string | null => {
    if (!coklu) return !durum ? 'Yükleniyor…' : durum.engeller[kod] ?? null;
    if (durumlar.length === 0) return 'Yükleniyor…';
    if (!COKLU_KODLAR.includes(kod)) return 'Bu işlem için tek bir belge seçin.';
    return durumlar.every(d => d.engeller[kod]) ? (durumlar[0].engeller[kod] ?? null) : null;
  };
  const calistir = async (kod: EFaturaKodu) => {
    setAcik(false);
    await efaturaCokluCalistir(kod, idler, { tazele: onDegisti });
  };

  return (
    <span className="dugme-menu efm" ref={kok}>
      <button type="button" className={'d bir' + (devre || idler.length === 0 ? ' efm-pasif' : '')}
              title={devre ? devreSebep : etiket === 'Fatura İşlem' ? 'e-Fatura / e-Arşiv işlemleri' : `${etiket} işlemleri`}
              onClick={ac}>
        <img src={efaturaIkon} alt="" width={16} height={16} className="efm-dugme-ikon" /> {etiket}{coklu ? ` (${idler.length})` : ''} ▾
      </button>
      {acik && createPortal(
        <div className="dugme-menu-liste efm-liste" role="menu" style={konum} ref={liste}>
          {coklu && durumlar.length > 0 && (
            <div className="efm-bas"><b>{idler.length} belge seçili</b>
              {durumlar.some(d => d.testMi) && <span className="efm-test">TEST</span>}</div>
          )}
          {!coklu && durum && (
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
                      disabled={pasif(m[0]) !== null}
                      title={pasif(m[0]) ?? undefined}
                      onClick={() => void calistir(m[0])}>
                <span className="efm-ikon"><img src={m[1]} alt="" width={16} height={16} /></span>{m[2]}
              </button>
            ))}
        </div>, document.body)}
      <style>{EFM_STILI}</style>
    </span>
  );
}

export const EFM_STILI = `
.efm-liste { min-width: 220px; z-index: 10000; }   /* her modal katmaninin (enust 420) ustunde */
.efm-liste .mi { display: flex; align-items: center; gap: 8px; padding: 5px 8px; }
.efm-ikon { width: 18px; text-align: center; display: inline-flex; justify-content: center; }
.efm-liste .mi:disabled .efm-ikon img { filter: grayscale(1); }
.efm .efm-pasif { opacity: .55; }
.efm-dugme-ikon { vertical-align: -3px; }
.efm-bas { font-size: 11.5px; color: var(--soluk); padding: 4px 8px 6px; border-bottom: 1px solid var(--cizgi); margin-bottom: 4px; white-space: nowrap; }
.efm-bas.hata { color: var(--kirmizi, #c0392b); white-space: normal; }
.efm-test { margin-left: 6px; font-size: 10px; font-weight: bold; color: #b45309; background: #fef3c7; border-radius: 3px; padding: 0 4px; }
`;
