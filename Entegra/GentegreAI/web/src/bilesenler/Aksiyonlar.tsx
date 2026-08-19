import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type AksiyonYaniti } from '../api/sozlesme';

/**
 * Aksiyon katalogu (API §7). Arac cubugu, sag tus menusu ve komut paleti AYNI
 * kaynaktan beslenir — Delphi'de bu uc yuzey ayri ayri kodlaniyor ve zamanla
 * birbirinden ayrisiyordu.
 *
 * Yetkisiz aksiyon sunucudan HIC gelmez; kosul nedeniyle kapali olan `aktif: false`
 * + `pasifSebep` ile gelir ve sebebi ekranda gorunur.
 */
export function useAksiyonlar(ekran: string, kayitId?: number | null) {
  const [aksiyonlar, setAksiyonlar] = useState<AksiyonYaniti[]>([]);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      const yanit = await api.aksiyonlar(ekran, kayitId ?? undefined);
      setAksiyonlar(yanit.aksiyonlar);
      setHata(null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      setAksiyonlar([]);
    }
  }, [ekran, kayitId]);

  useEffect(() => { void yukle() }, [yukle]);

  return { aksiyonlar, hata, yenile: yukle };
}

export const hedefte = (a: AksiyonYaniti, hedef: string) => a.hedef.split(',').includes(hedef);

interface CalistirProps {
  aksiyonlar: AksiyonYaniti[];
  calistir(kod: string): void;
}

/** Ust arac cubugu. */
export function GenToolbar({ aksiyonlar, calistir }: CalistirProps) {
  const gorunen = aksiyonlar.filter(a => hedefte(a, 'araccubugu'));
  if (gorunen.length === 0) return null;

  return (
    <div className="arac-cubugu">
      {gorunen.map(a => (
        <button
          key={a.kod}
          disabled={!a.aktif}
          title={a.aktif ? (a.kisayol ?? a.ad) : (a.pasifSebep ?? '')}
          // Yalniz "Yeni" birincil (dolu mor); Duzenle/Yazdir/... renksiz-transparan kalir.
          className={`d ${a.kod.endsWith('.yeni') ? 'bir' : ''}`}
          onClick={() => calistir(a.kod)}
        >
          <span>{a.ad}</span>
        </button>
      ))}
    </div>
  );
}

interface SagTusProps extends CalistirProps {
  konum: { x: number; y: number } | null;
  onKapat(): void;
}

/** Sag tus menusu — ayni katalogdan, yalniz "sagtus" hedefli aksiyonlar. */
export function GenSagTus({ aksiyonlar, calistir, konum, onKapat }: SagTusProps) {
  useEffect(() => {
    if (!konum) return;
    const kapat = () => onKapat();
    window.addEventListener('click', kapat);
    window.addEventListener('scroll', kapat, true);
    return () => { window.removeEventListener('click', kapat); window.removeEventListener('scroll', kapat, true) };
  }, [konum, onKapat]);

  if (!konum) return null;
  const gorunen = aksiyonlar.filter(a => hedefte(a, 'sagtus'));
  if (gorunen.length === 0) return null;

  return (
    <div className="sag-tus" style={{ left: konum.x, top: konum.y }}>
      {gorunen.map(a => (
        <button
          key={a.kod}
          disabled={!a.aktif}
          title={a.aktif ? '' : (a.pasifSebep ?? '')}
          onClick={() => { if (a.aktif) { calistir(a.kod); onKapat() } }}
        >
          <span>{a.ad}</span>
          {a.kisayol && <span className="kisayol">{a.kisayol}</span>}
          {!a.aktif && a.pasifSebep && <span className="pasif-sebep">{a.pasifSebep}</span>}
        </button>
      ))}
    </div>
  );
}

/** Komut paleti (Ctrl+K) — ayni katalog, arama ile. */
export function GenKomutPaleti({ aksiyonlar, calistir }: CalistirProps) {
  const [acik, setAcik] = useState(false);
  const [arama, setArama] = useState('');
  const [secili, setSecili] = useState(0);

  useEffect(() => {
    const tus = (e: KeyboardEvent) => {
      // Ctrl+K bazi tarayicilarda adres cubugunu aciyor; F1 ve Ctrl+Shift+P yedek.
      const paletTusu =
        ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') ||
        ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key.toLowerCase() === 'p') ||
        e.key === 'F1';
      if (paletTusu) {
        e.preventDefault();
        setAcik(a => !a);
        setArama('');
        setSecili(0);
      } else if (e.key === 'Escape') setAcik(false);
    };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  }, []);

  const gorunen = useMemo(() => {
    const hepsi = aksiyonlar.filter(a => hedefte(a, 'palet'));
    const q = arama.trim().toLocaleLowerCase('tr');
    return q ? hepsi.filter(a => a.ad.toLocaleLowerCase('tr').includes(q) || a.kod.includes(q)) : hepsi;
  }, [aksiyonlar, arama]);

  if (!acik) return null;

  const sec = (a: AksiyonYaniti) => { if (a.aktif) { calistir(a.kod); setAcik(false) } };

  return (
    <>
      <div className="perde" onClick={() => setAcik(false)} />
      <div className="palet" onKeyDown={e => {
        if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(s => Math.min(s + 1, gorunen.length - 1)) }
        else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(s => Math.max(s - 1, 0)) }
        else if (e.key === 'Enter' && gorunen[secili]) { e.preventDefault(); sec(gorunen[secili]) }
      }}>
        <input
          autoFocus
          className="arama"
          placeholder="Komut ara… (Ctrl+K / F1)"
          value={arama}
          onChange={e => { setArama(e.target.value); setSecili(0) }}
        />
        <div className="palet-liste">
          {gorunen.map((a, i) => (
            <button
              key={a.kod}
              className={i === secili ? 'secili' : ''}
              disabled={!a.aktif}
              onMouseEnter={() => setSecili(i)}
              onClick={() => sec(a)}
            >
              <span>{a.ad}</span>
              <span className="grup">{a.grup}</span>
              {a.kisayol && <span className="kisayol">{a.kisayol}</span>}
              {!a.aktif && a.pasifSebep && <span className="pasif-sebep">{a.pasifSebep}</span>}
            </button>
          ))}
          {gorunen.length === 0 && <div className="bos">Komut yok</div>}
        </div>
      </div>
    </>
  );
}
