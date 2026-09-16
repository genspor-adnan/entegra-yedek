import { PlanlamaModali } from '../../bilesenler/ameliyathane/PlanlamaModali';
import { KontrolListesiModali } from '../../bilesenler/ameliyathane/KontrolListesiModali';
import { FaturaStokModali } from '../../bilesenler/ameliyathane/FaturaStokModali';
import { CikisModali } from '../../bilesenler/acil/CikisModali';
import type { AmeliyatAcilModalDurumu } from './useAmeliyatAcilModallari';

/**
 * Ameliyathane ve acil ekran modalleri - durum `useAmeliyatAcilModallari`
 * kancasinda; burasi yalniz cizim ve kapanis.
 */
export function AmeliyatAcilModallari(
  { m, tazele }: { m: AmeliyatAcilModalDurumu; tazele: () => void },
) {
  return (
    <>
      {m.planlama && (
        <PlanlamaModali
          talepId={m.planlama.talepId}
          talepNo={m.planlama.talepNo}
          hastaAdi={m.planlama.hastaAdi}
          islem={m.planlama.islem}
          tahminiSure={m.planlama.tahminiSure}
          eksikler={m.planlama.eksikler}
          onKapat={() => m.setPlanlama(null)}
          onTamam={tazele}
        />
      )}

      {m.kontrol && (
        <KontrolListesiModali
          ameliyatId={m.kontrol.ameliyatId}
          ameliyatNo={m.kontrol.ameliyatNo}
          onKapat={() => m.setKontrol(null)}
          onTamam={tazele}
        />
      )}

      {m.faturaStok && (
        <FaturaStokModali
          ameliyatId={m.faturaStok.ameliyatId}
          ameliyatNo={m.faturaStok.ameliyatNo}
          onKapat={() => m.setFaturaStok(null)}
          onTamam={tazele}
        />
      )}

      {m.acilCikis && (
        <CikisModali
          basvuruId={m.acilCikis.basvuruId}
          protokolNo={m.acilCikis.protokolNo}
          hastaAdi={m.acilCikis.hastaAdi}
          onKapat={() => m.setAcilCikis(null)}
          onTamam={tazele}
        />
      )}
    </>
  );
}
