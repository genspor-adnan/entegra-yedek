/** API sozlesmesi - belge. Alan adlari sunucuyla birebir. */

// ---------------------------------------------------------------- belge ----
export interface DipToplamSatiri {
  tur: number; aciklama: string; deger: number;
  dovizTutari: number; kur: string; belgeDovizi: string;
}

export interface BelgeYaniti {
  belge: Record<string, unknown>;
  satirlar: Record<string, unknown>[];
  dipToplam: DipToplamSatiri[];
  uyarilar?: string[];
  izlemeNo: string;
  /** Bu kayıtta başvurunun ücret satırından açılan radyoloji istemleri (1242). */
  radyolojiIstemleri?: AcilanRadyolojiIstemi[];
  /** Hasta dış kurumdan gönderildi (gönderen dış hekim / geliş şekli Sevkli): istem kartı kabul için açılır. */
  disKurumSevki?: boolean;
}

export interface AcilanRadyolojiIstemi { id: number; accessionNo: string; tetkik: string }
