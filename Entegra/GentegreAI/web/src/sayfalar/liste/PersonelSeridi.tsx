import { BolumSuzgeci } from '../../bilesenler/BolumSuzgeci';
import type { PersonelSuzgeci } from './usePersonelSuzgeci';

/**
 * PERSONEL SERIDI (kullanici): ciplerin SAGINDA bolum agac combosu + rol
 * combosu. Ikisi de sunucuda suzer - istemci listeyi kendi sirasindan
 * ayiklamaz, sayfali listede yanlis olurdu.
 */
export function PersonelSeridi(
  { s, bolumSuzgeci }: { s: PersonelSuzgeci; bolumSuzgeci: boolean | undefined },
) {
  return (
    <>
      {bolumSuzgeci && (
        <BolumSuzgeci
          deger={s.bolum?.id ?? null}
          onDegis={(id, agac) => s.setBolum(id === null ? null : { id, agac })}
        />
      )}
      {s.rolSuzgeciVar && (
        <select className="kat-suzgec" value={s.rol}
                title="Kullanıcı rolüne göre süz"
                onChange={e => s.setRol(e.target.value ? Number(e.target.value) : '')}>
          <option value="">Tüm Roller</option>
          {s.roller.map(r => <option key={r.id} value={r.id}>{r.ad}</option>)}
        </select>
      )}
      {(s.bolum !== null || s.rol !== '') && (
        <button type="button" className="kapat" title="Bölüm/rol filtresini kaldır"
                onClick={() => { s.setBolum(null); s.setRol('') }}>×</button>
      )}
    </>
  );
}
