import { useEffect, useState } from 'react';

/** Grid ust seridindeki hazir tarih araligi secenegi. */
export type TarihVarsayilan = 'yilbasindanBugune' | 'buAy' | undefined;

/** YEREL gun (toISOString UTC'ye kayar, gece yarisi tuzagi). */
export const gunMetni = (t: Date) =>
  `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}-${String(t.getDate()).padStart(2, '0')}`;

/**
 * GRID TARIH ARALIGI.
 *
 * 'yilbasindanBugune': 1 Ocak - bugun. Ust sinir SUNUCUDA gun sonuna kadar
 * kapsanir (SorguUretici 'arasinda' + 1 gun), yani bugun 23:59'daki hareket de
 * listeye girer.
 *
 * Acilistaki varsayilan da disari bildirilir - ust seritteki suzgec ilk
 * yuklemede dogru araligi gorsun (efekt ilk render'da da calisir).
 */
export function useTarihAraligi(
  varsayilan: TarihVarsayilan,
  onAralik?: (bas: string, bit: string) => void,
) {
  const [bas, setBas] = useState(() => {
    const t = new Date();
    if (varsayilan === 'yilbasindanBugune') return `${t.getFullYear()}-01-01`;
    // 'buAy' (kullanici, hakedis satirlari): bulunulan ayin 1'i.
    if (varsayilan === 'buAy') return gunMetni(new Date(t.getFullYear(), t.getMonth(), 1));
    return '';
  });
  const [bit, setBit] = useState(() => {
    const t = new Date();
    if (varsayilan === 'yilbasindanBugune') return gunMetni(t);
    // Ayin SONU: gelecek ayin 0. gunu = bu ayin son gunu (28/29/30/31 dert degil).
    if (varsayilan === 'buAy') return gunMetni(new Date(t.getFullYear(), t.getMonth() + 1, 0));
    return '';
  });

  useEffect(() => { onAralik?.(bas, bit) }, [bas, bit, onAralik]);

  return { bas, setBas, bit, setBit };
}
