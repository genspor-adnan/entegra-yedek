import { gonder, istek } from '../cekirdek';

/** Kurumsal Kalite genel ayarları (1069) - referans anahtarları, /api/kys-ayar. */
export type KysAyar = {
  dofTerminGun: number; riskDusuk: number; riskOrta: number; riskYuksek: number;
  genelSorumluId: number | null; olayAnonim: boolean;
};

export const kysAyarUclari = {
  kysAyar: () => istek<KysAyar & { duzenle: boolean }>('/api/kys-ayar'),
  kysAyarYaz: (a: KysAyar) => gonder<KysAyar & { duzenle: boolean }>('/api/kys-ayar', a, 'PUT'),
};
