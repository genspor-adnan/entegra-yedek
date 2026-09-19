import { istek } from '../cekirdek';

/** Mükerrer hasta kontrolü (GET /api/hasta/mukerrer). */
export interface MukerrerKayit { id: number; ad: string; kod: string; dogumTarihi?: string | null }
export interface MukerrerYaniti { kimlik: MukerrerKayit | null; telefon: MukerrerKayit[] }

export const hastaUclari = {
  /** Kimlik no aynı → tek kayıt (engel); telefon aynı → liste (uyarı). `haric`: düzenlenen kartın kendisi. */
  hastaMukerrer: (p: { vkno?: string; cepTel?: string; haric?: number }) => {
    const q = new URLSearchParams();
    if (p.vkno) q.set('vkno', p.vkno);
    if (p.cepTel) q.set('cepTel', p.cepTel);
    if (p.haric) q.set('haric', String(p.haric));
    return istek<MukerrerYaniti>(`/api/hasta/mukerrer?${q}`);
  },
};
