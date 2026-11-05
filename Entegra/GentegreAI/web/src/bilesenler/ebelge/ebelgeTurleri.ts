import type { EBelgeTuru } from './TurAyarlari';

/** e-Belge türleri ve şube kartındaki mükellefiyet bayrağı (Fatura Ayarları sekmeleri, 1270). */
export const EBELGE_TURLERI: { tur: EBelgeTuru; baslik: string; mukellefAlani: string }[] = [
  { tur: 'efatura',   baslik: 'e-Fatura',       mukellefAlani: 'efaturaMukellef' },
  { tur: 'earsiv',    baslik: 'e-Arşiv Fatura', mukellefAlani: 'earsivMukellef' },
  { tur: 'eirsaliye', baslik: 'e-İrsaliye',     mukellefAlani: 'eirsaliyeMukellef' },
  { tur: 'esmm',      baslik: 'e-SMM',          mukellefAlani: 'esmmMukellef' },
];
