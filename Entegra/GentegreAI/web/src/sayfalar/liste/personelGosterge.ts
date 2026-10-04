import type { Kosul } from '../../api/sozlesme';

/** PERSONEL GÖSTERGE ŞERİDİ (963): kutu kodu ve liste süzgeci. */
export type GostergeKodu = 'izinde' | 'raporlu' | 'talep' | 'deneme' | 'dogum' | 'eksik';

/** Gösterge kutusunun liste süzgeci (kolonlar katalogda: bugunKod, onaydaTalep...). */
export function gostergeKosulu(g: GostergeKodu): Kosul {
  switch (g) {
    case 'izinde': return { alan: 'bugunKod', op: 'esit', deger: 2 };
    case 'raporlu': return { alan: 'bugunKod', op: 'esit', deger: 3 };
    case 'talep': return { alan: 'onaydaTalep', op: 'buyuk', deger: 0 };
    case 'deneme': return { alan: 'bugunKod', op: 'esit', deger: 4 };
    case 'dogum': return { alan: 'dogumBuAy', op: 'esit', deger: 1 };
    case 'eksik': return { alan: 'eksik', op: 'esitDegil', deger: '' };
  }
}

