/** İSG / OSGB icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(0)}`);
export const dk = (n: number) => n.toLocaleString('tr-TR');

/** Hizmet süresi karşılama: %100 ve üstü tamam, %85 altı kırmızı, arası sarı; plan yoksa gri. */
export function karsilamaRozeti(k: number | null | undefined): Rozet {
  if (k == null) return { ad: 'plan yok', renk: 'pas' };
  return { ad: yuzde(k), renk: k >= 100 ? 'ok' : k < 85 ? 'kir' : 'sari' };
}

/** Sözleşme bitişi: geçmiş / 30 gün içinde kırmızı, 60 gün içinde sarı. */
export function sozlesmeRozeti(kalan: number | null | undefined): Rozet {
  if (kalan == null) return { ad: 'tanımsız', renk: 'pas' };
  if (kalan < 0) return { ad: `${-kalan} gün geçti`, renk: 'kir' };
  if (kalan <= 30) return { ad: `${kalan} gün kaldı`, renk: 'kir' };
  if (kalan <= 60) return { ad: `${kalan} gün kaldı`, renk: 'sari' };
  return { ad: `${kalan} gün`, renk: 'pas' };
}

/** Tahsil durumu rozeti (metin sunucudan). */
export function tahsilRozeti(durum: string): Rozet {
  return { ad: durum, renk: durum === 'Tahsil edildi' ? 'ok' : durum === 'Kısmi' ? 'sari' : durum === 'Bekliyor' ? 'kir' : 'pas' };
}

/** Gecikme: 90+ gün kırmızı, 30+ sarı. */
export const gecikmeRenk = (gun: number) => (gun >= 90 ? 'kir' : gun >= 30 ? 'sari' : '');
