import { BolumSuzgeci } from '../../bilesenler/BolumSuzgeci';
import { RolSuzgeci } from '../../bilesenler/RolSuzgeci';
import type { PersonelSuzgeci } from './usePersonelSuzgeci';
import { c } from '../../dil/ceviri';

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
        <RolSuzgeci roller={s.roller} bolumler={s.rolBolumleri}
                    deger={s.rol} onDegis={s.setRol} />
      )}
      {(s.bolum !== null || s.rol !== '') && (
        <button type="button" className="kapat" title={c('Bölüm/rol filtresini kaldır')}
                onClick={() => { s.setBolum(null); s.setRol('') }}>×</button>
      )}
    </>
  );
}
