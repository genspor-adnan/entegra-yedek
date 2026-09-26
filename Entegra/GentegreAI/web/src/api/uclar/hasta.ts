import { istek } from '../cekirdek';

/** Mükerrer taraf (hasta/personel) kontrolü (GET /api/hasta/mukerrer). */
export interface MukerrerKayit { id: number; ad: string; kod: string; dogumTarihi?: string | null }
export interface MukerrerYaniti {
  kimlik: MukerrerKayit | null;     // aynı kimlik + AKTİF → ENGEL
  telefon: MukerrerKayit[];         // aynı telefon → UYARI
  eposta: MukerrerKayit[];          // aynı e-posta → UYARI
}

export const hastaUclari = {
  /**
   * Kimlik no aynı + AKTİF → tek kayıt (engel, geçiş sorulur); telefon/e-posta
   * aynı → liste (uyarı, onayla geçilir). `rol`: hasta | personel. `haric`:
   * düzenlenen kartın kendisi.
   */
  tarafMukerrer: (p: { rol?: 'hasta' | 'personel'; vkno?: string; cepTel?: string; eposta?: string; haric?: number }) => {
    const q = new URLSearchParams();
    if (p.rol) q.set('rol', p.rol);
    if (p.vkno) q.set('vkno', p.vkno);
    if (p.cepTel) q.set('cepTel', p.cepTel);
    if (p.eposta) q.set('eposta', p.eposta);
    if (p.haric) q.set('haric', String(p.haric));
    return istek<MukerrerYaniti>(`/api/hasta/mukerrer?${q}`);
  },
};
