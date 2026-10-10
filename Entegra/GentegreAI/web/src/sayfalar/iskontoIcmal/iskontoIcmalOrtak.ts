import type { IskontoKaynagi } from '../../api/uclar/iskontoIcmal';

/** İskonto icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** İskontonun kaynağı: onaylı talep, kampanya, bankonun talepsiz verdiği ya da karma. */
export function kaynakRozeti(k: IskontoKaynagi): Rozet {
  switch (k) {
    case 'talep': return { ad: 'Onaylı talep', renk: 'ok' };
    case 'kampanya': return { ad: 'Kampanya', renk: 'mavi' };
    case 'banko': return { ad: 'Banko (talepsiz)', renk: 'sari' };
    default: return { ad: 'Karma', renk: 'mor' };
  }
}

/** Oran gösterimi: "%15,9". */
export const oranMetni = (o: number) => `%${o.toFixed(1).replace('.', ',')}`;

export const KAYNAKLAR: [string, string][] = [['hepsi', 'Tümü'], ['talep', 'Onaylı talep'], ['kampanya', 'Kampanya'], ['banko', 'Banko (talepsiz)']];
