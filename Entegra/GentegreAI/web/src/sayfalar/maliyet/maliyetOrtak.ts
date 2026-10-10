/** Hasta başı maliyet icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Marj rozeti: zarar kırmızı, %20 altı sarı, %50 altı mavi, üstü yeşil; maliyet yoksa gri. */
export function marjRozeti(marj: number | null | undefined, maliyetVar: boolean): Rozet {
  if (marj == null) return { ad: '—', renk: 'pas' };
  const m = `%${marj.toFixed(1).replace('.', ',')}`;
  if (!maliyetVar) return { ad: `${m} · maliyet yok`, renk: 'pas' };
  if (marj < 0) return { ad: `${m} zarar`, renk: 'kir' };
  if (marj < 20) return { ad: m, renk: 'sari' };
  if (marj < 50) return { ad: m, renk: 'mavi' };
  return { ad: m, renk: 'ok' };
}

export const KAYNAK_ADI: Record<string, string> = {
  radyoloji: 'Radyoloji sarfı', dis: 'Diş seansı', ameliyat: 'Ameliyat', fatura: 'Faturalı stok',
};
