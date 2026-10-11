/** Çağrı merkezi icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Saniye → "35 sn" / "3 dk 41 sn" / "1 sa 09 dk". */
export function sureMetni(sn: number | null | undefined): string {
  if (sn == null) return '—';
  const s = Math.round(sn);
  if (s < 60) return `${s} sn`;
  if (s < 3600) return `${Math.floor(s / 60)} dk ${String(s % 60).padStart(2, '0')} sn`;
  return `${Math.floor(s / 3600)} sa ${String(Math.floor((s % 3600) / 60)).padStart(2, '0')} dk`;
}

/** Dakika → "58 dk" / "1 sa 04 dk". */
export const dkMetni = (dk: number | null | undefined) => (dk == null ? '—' : sureMetni(dk * 60));

/** SLA rozeti: hedefte yeşil, 10 puan altına kadar sarı, daha kötüsü kırmızı. */
export function slaRozeti(sla: number | null | undefined, hedef: number): Rozet {
  if (sla == null) return { ad: '—', renk: 'pas' };
  const m = `%${sla.toFixed(1).replace('.', ',')}`;
  return sla >= hedef ? { ad: m, renk: 'ok' } : sla >= hedef - 10 ? { ad: m, renk: 'sari' } : { ad: m, renk: 'kir' };
}

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);

export const GUN_ADI: Record<number, string> = { 1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 0: 'Paz' };
