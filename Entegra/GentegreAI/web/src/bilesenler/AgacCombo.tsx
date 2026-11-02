import { useEffect, useMemo, useRef, useState } from 'react';
import { c } from '../dil/ceviri';

/**
 * AĞAÇ COMBO (kullanıcı 02.11.2026: "kategori ağaç şeklinde gelsin").
 *
 * Girintili `<select>` (484, agacSecenek) uzun ağaçta düz liste gibi okunuyordu. Bu bileşen
 * combo görünümünde bir kutu açar; içinde açılır-kapanır dallar ve arama vardır. Kutuda seçili
 * düğümün YOLU görünür ("İlaç › Analjezik") - aynı adlı iki dal ("Genel") ayırt edilir.
 *
 * Saklanan değer yine tek kod (id). Üstü listede olmayan / döngüdeki düğüm kök sayılır -
 * agacSecenekleri ile aynı kural: veri bozukken bir kayıt kaybolmasın.
 */
export function AgacCombo({ kodlar, kodUst, deger, onDegis, disabled, zorunlu, alanAdi }: {
  kodlar: Record<string, string>;
  kodUst?: Record<string, string> | null;
  deger: string;
  onDegis(kod: string): void;
  disabled?: boolean;
  zorunlu?: boolean;
  alanAdi?: string;
}) {
  const [acik, setAcik] = useState(false);
  const [ara, setAra] = useState('');
  const [genis, setGenis] = useState<Set<string>>(new Set());
  const kutu = useRef<HTMLDivElement>(null);

  const { ust, cocuklar, kokler } = useMemo(() => {
    const var_ = (k: string) => Object.prototype.hasOwnProperty.call(kodlar, k);
    const ham = (k: string) => { const u = kodUst?.[k]; return u != null && u !== k && var_(u) ? u : null };
    const kokMu = (k: string) => {
      const gorulen = new Set([k]);
      for (let g = ham(k); g; g = ham(g)) { if (gorulen.has(g)) return true; gorulen.add(g) }
      return ham(k) === null;
    };
    const ust = new Map<string, string | null>();
    const cocuklar = new Map<string, string[]>();
    const kokler: string[] = [];
    for (const k of Object.keys(kodlar)) {
      const u = kokMu(k) ? null : ham(k);
      ust.set(k, u);
      if (u === null) kokler.push(k); else cocuklar.set(u, [...(cocuklar.get(u) ?? []), k]);
    }
    const sirala = (a: string[]) => a.sort((x, y) => kodlar[x].localeCompare(kodlar[y], 'tr'));
    sirala(kokler); cocuklar.forEach(sirala);
    return { ust, cocuklar, kokler };
  }, [kodlar, kodUst]);

  const yol = (k: string): string[] => {
    const r: string[] = [];
    for (let g: string | null | undefined = k; g && r.length < 20; g = ust.get(g)) r.unshift(g);
    return r;
  };

  // Açılınca seçili düğümün ataları açık gelir; dışarı tıklama / Esc kapatır.
  useEffect(() => {
    if (!acik) return;
    if (deger && kodlar[deger] !== undefined) setGenis(new Set(yol(deger).slice(0, -1)));
    const disari = (e: MouseEvent) => { if (!kutu.current?.contains(e.target as Node)) setAcik(false) };
    // Esc yalnız paneli kapatır - kartın / sekmenin Esc kısayoluna gitmesin (yakalama evresinde durdurulur).
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') { e.stopPropagation(); e.preventDefault(); setAcik(false) } };
    document.addEventListener('mousedown', disari); window.addEventListener('keydown', tus, true);
    return () => { document.removeEventListener('mousedown', disari); window.removeEventListener('keydown', tus, true) };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acik]);

  // Aramada eşleşen düğümler + ataları görünür, hepsi açık.
  const aramaKumesi = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    if (!q) return null;
    const k = new Set<string>();
    for (const [kod, ad] of Object.entries(kodlar))
      if (ad.toLocaleLowerCase('tr').includes(q)) yol(kod).forEach(x => k.add(x));
    return k;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [ara, kodlar, ust]);

  const sec = (k: string) => { onDegis(k); setAcik(false); setAra('') };

  const dal = (k: string, derinlik: number): React.ReactNode => {
    if (aramaKumesi && !aramaKumesi.has(k)) return null;
    const alt = cocuklar.get(k) ?? [];
    const acikDal = aramaKumesi ? true : genis.has(k);
    return (
      <div key={k}>
        <div className={`agcb-dugum${k === deger ? ' on' : ''}`} style={{ paddingLeft: 6 + derinlik * 16 }}
             onClick={() => sec(k)}>
          <span className="agcb-ok" onClick={e => {
            e.stopPropagation();
            if (alt.length) setGenis(g => { const n = new Set(g); if (n.has(k)) n.delete(k); else n.add(k); return n });
          }}>{alt.length ? (acikDal ? '▾' : '▸') : ''}</span>
          <span>{alt.length ? '📁' : '📄'} {c(kodlar[k], 'kod')}</span>
        </div>
        {acikDal && alt.map(x => dal(x, derinlik + 1))}
      </div>
    );
  };

  const metin = deger && kodlar[deger] !== undefined ? yol(deger).map(x => c(kodlar[x], 'kod')).join(' › ') : '';

  return (
    <div className="agcb" ref={kutu} data-alan={alanAdi}>
      <button type="button" className={`agcb-kutu${metin ? '' : ' bos'}`} data-agcb-kutu disabled={disabled}
              onClick={() => setAcik(a => !a)} title={metin}>
        <span className="agcb-metin">{metin || (zorunlu ? c('— seçiniz') : '—')}</span>
        <span className="agcb-isaret">▾</span>
      </button>
      {acik && !disabled && (
        <div className="agcb-pano">
          <input className="agcb-ara" autoFocus placeholder={c('Ara…')} value={ara} onChange={e => setAra(e.target.value)} />
          <div className="agcb-liste">
            {!zorunlu && <div className={`agcb-dugum${deger ? '' : ' on'}`} onClick={() => sec('')}>
              <span className="agcb-ok" /> —</div>}
            {kokler.map(k => dal(k, 0))}
            {aramaKumesi && aramaKumesi.size === 0 && <div className="agcb-bos">{c('Eşleşen kayıt yok.')}</div>}
          </div>
        </div>
      )}
    </div>
  );
}
