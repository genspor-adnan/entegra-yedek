import { istek } from '../cekirdek';

/** Hekim / bölüm performans icmali (HekimPerformansUclari). Rakamlar sunucuda hesaplanır. */
export type PerformansDegeri = {
  basvuru: number; hizmet: number; ciro: number; kurumPayi: number; hastaPayi: number; kurumOrani: number;
  iskonto: number; tahsil: number; hakedis: number; ortBasvuru: number; oncekiCiro: number;
  /** Önceki döneme göre ciro değişimi (%); önceki dönem cirosu yoksa null. */
  degisim?: number | null;
};
export type HekimPerformansi = { id: number; ad: string; bolum: string; deger: PerformansDegeri };
export type BolumPerformansi = { id: number; ad: string; hekim: number; deger: PerformansDegeri };
export type HekimPerformansIcmali = {
  donem: { bas: string; bit: string; oncekiBas: string; oncekiBit: string };
  secili: number[];
  ozet: PerformansDegeri;
  hekimsiz: { basvuru: number; ciro: number };
  hekimler: HekimPerformansi[]; bolumler: BolumPerformansi[];
  gruplar: { grup: string; kalem: number; tutar: number; kurumPayi: number; iskonto: number }[];
  trend: { yil: number; ay: number; basvuru: number; ciro: number; kurumPayi: number }[];
  bolumAdlari: { id: number; ad: string }[];
};

export const hekimPerformansUclari = {
  hekimPerformans: (bas: string, bit: string, kurumTuru: number, bolum: number, hekimler: number[]) => {
    const q = new URLSearchParams({ bas, bit });
    if (kurumTuru) q.set('kurumTuru', String(kurumTuru));
    if (bolum) q.set('bolum', String(bolum));
    if (hekimler.length) q.set('hekimler', hekimler.join(','));
    return istek<HekimPerformansIcmali>(`/api/hekim-performans?${q}`);
  },
};
