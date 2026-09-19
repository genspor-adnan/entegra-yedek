import type { PrimSuzgeci } from './usePrimSuzgeci';
import { c } from '../../dil/ceviri';

/**
 * HAKEDIS SATIRLARI SERIDI (kullanici): tarih araliginin SAGINDA once Prim
 * Rolu, onun saginda Kisi. Suzme sunucuda; kisi listesi secili role gore daralir.
 */
export function PrimSeridi({ s }: { s: PrimSuzgeci }) {
  return (
    <>
      <select className="kat-suzgec" value={s.rol} title={c('Prim rolüne göre süz')}
              onChange={e => s.setRol(e.target.value ? Number(e.target.value) : '')}>
        <option value="">{c('Tüm Prim Rolleri')}</option>
        {s.roller.map(r => (
          <option key={r.id} value={r.id}>{r.ad} ({r.adet})</option>
        ))}
      </select>
      <select className="kat-suzgec" value={s.kisi} title={c('Kişiye göre süz')}
              onChange={e => s.setKisi(e.target.value ? Number(e.target.value) : '')}>
        <option value="">{c('Tüm Kişiler')}</option>
        {s.kisiler.map(k => (
          <option key={k.id} value={k.id}>{k.ad} ({k.adet})</option>
        ))}
      </select>
      {(s.rol !== '' || s.kisi !== '') && (
        <button type="button" className="kapat" title={c('Prim rolü/kişi filtresini kaldır')}
                onClick={() => { s.setRol(''); s.setKisi('') }}>×</button>
      )}
    </>
  );
}
