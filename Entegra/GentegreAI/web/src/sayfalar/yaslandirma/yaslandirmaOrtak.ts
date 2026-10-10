/** Alacak yaşlandırmanın saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Satırın en kötü dilimi: 90+ kırmızı, 61-90 sarı, 31-60 mavi, yoksa güncel. */
export function yasRozeti(x: { d30: number; d60: number; d90: number }): Rozet {
  if (x.d90 > 0.005) return { ad: '90+ gün var', renk: 'kir' };
  if (x.d60 > 0.005) return { ad: '61–90 gün', renk: 'sari' };
  if (x.d30 > 0.005) return { ad: '31–60 gün', renk: 'mavi' };
  return { ad: 'Güncel', renk: 'ok' };
}

/** Dilim çubuğu yüzdeleri (toplama göre); toplam 0 ise hepsi 0. */
export function dilimYuzdeleri(x: { d0: number; d30: number; d60: number; d90: number }): number[] {
  const t = x.d0 + x.d30 + x.d60 + x.d90;
  return t > 0 ? [x.d0, x.d30, x.d60, x.d90].map(v => (100 * v) / t) : [0, 0, 0, 0];
}

export const bugunYerel = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};

export const DILIM_RENK = ['#3f9a5e', '#2f6db3', '#d9a12b', '#b3261e'];
