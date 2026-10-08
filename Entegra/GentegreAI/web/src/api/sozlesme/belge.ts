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
}
