import { gonder, istek } from '../cekirdek';

/** İK › Belge Takibi yan uçları (PersonelBelgeTakipUclari, 1135-1137). */
export type BelgeTakipOzeti = {
  eksik: number; eksikKisi: number; doldu: number; dolduKisi: number;
  yaklasan: number; yaklasanKisi: number; personel: number;
};

export const belgeTakipUclari = {
  belgeTakipOzet: () => istek<BelgeTakipOzeti>('/api/ik/belge-takip/ozet'),
  /** Seçili personele eksik / süresi dolan / yaklaşan belgeler (e-posta, yoksa SMS). */
  belgeTakipHatirlat: (personelIds: number[]) =>
    gonder<{ kuyruga: number; atlanan: { ad: string; neden: string }[] }>(
      '/api/ik/belge-takip/hatirlat', { personelIds }),
};
