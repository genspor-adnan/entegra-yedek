import { gonder, istek } from '../cekirdek';

/** Kalite politikası & kapsam (1059) - tek metin, referans anahtarları. */
export type KysPolitika = { politika: string; kapsam: string; onaylayan: string; tarih: string; yayin?: string };

export const kysPolitikaUclari = {
  kysPolitika: () => istek<KysPolitika & { duzenle: boolean }>('/api/kys-politika'),
  kysPolitikaYaz: (p: KysPolitika) => gonder<KysPolitika & { duzenle: boolean }>('/api/kys-politika', p, 'PUT'),
};
