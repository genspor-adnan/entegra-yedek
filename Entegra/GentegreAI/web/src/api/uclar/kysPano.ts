import { istek } from '../cekirdek';

/** Kalite panosu (KysPanoUclari, 1055). Sayılar sunucuda hesaplanır. */
export type KysPano = {
  bugun: string;
  ozet: {
    acikDof: number; vadesiGecenDof: number; olay: number; denetimAy: number; denetimYapilan: number;
    yuksekRisk: number; hedefDisi: number; hedefToplam: number; kalibrasyonYaklasan: number;
    kalibrasyonGecen: number; eksikEgitim: number;
  };
  /** Oturumdaki kullanıcıya atanmış açık işler; `yol` kaydın kartı. */
  banaDusenler: { tur: string; id: number; no: string; is: string; birim: string; termin?: string | null; gecikti: boolean; yol: string }[];
};

export const kysPanoUclari = {
  kysPano: () => istek<KysPano>('/api/kys-pano'),
};
