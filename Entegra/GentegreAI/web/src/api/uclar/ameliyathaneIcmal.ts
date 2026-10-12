import { istek } from '../cekirdek';

/** Ameliyathane icmali (AmeliyathaneIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type AmeliyathaneIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    ameliyat: number; planDisi: number; salon: number; kullanimDk: number; kapasiteDk: number; doluluk?: number | null; isGunu: number;
    ortSureDk?: number | null; ortPlanDk?: number | null; sapma?: number | null; ilkVakaZamaninda: number; ilkVaka: number;
    ilkVakaOrani?: number | null; gecIlkVaka: number; ortDevirDk?: number | null; devir: number;
    ciro: number; sarf: number; implant: number; brutKar: number; marj?: number | null;
    iptal: number; ertelenen: number; iptalOrani?: number | null; faturasizVaka: number; faturasizTutar: number;
    cerrah: number; anestezi: number; anestezisiz: number;
  };
  salonlar: { id: number; kod: string; ad: string; brans: string; vaka: number; planDisi: number; kullanimDk: number; kapasiteDk: number;
              doluluk?: number | null; ortSureDk?: number | null; ortPlanDk?: number | null; sapma?: number | null;
              ilkVakaZamaninda: number; ilkVaka: number; ortDevirDk?: number | null; iptal: number; ciro: number;
              cerrahlar: { ad: string; adet: number }[] }[];
  cerrahlar: { id: number; ad: string; brans: string; vaka: number; masaDk: number; sapma?: number | null; gecIlkVaka: number;
               iptal: number; ciro: number; marj?: number | null }[];
  anestezi: { id: number; ad: string; vaka: number; sureDk: number }[];
  ameliyatlar: { id: number; tarih?: string | null; protokol: string; salon: string; ameliyat: string; cerrah: string;
                 planDk?: number | null; gercekDk?: number | null; sapmaDk?: number | null; ciro: number; sarf: number;
                 marj?: number | null; acil: boolean; faturasizSarf: boolean }[];
  turler: { ad: string; brans: string; adet: number; ciro: number; sarf: number; implant: number; vakaBasi: number; brutKar: number;
            marj?: number | null; ortSureDk?: number | null }[];
  faturasizSarf: { id: number; tarih?: string | null; protokol: string; ameliyat: string; cerrah: string; toplamSarf: number;
                   faturasiz: number; kalem: number }[];
  iptaller: { id: number; tarih?: string | null; protokol: string; salon: string; ameliyat: string; cerrah: string; neden: string;
              ertelendi: boolean }[];
  iptalNedenleri: { neden: string; adet: number; pay: number }[];
  salonAdlari: { id: number; ad: string }[];
  branslar: string[];
};

export const ameliyathaneIcmalUclari = {
  ameliyathaneIcmali: (bas: string, bit: string, salon: number, brans: string) => {
    const q = new URLSearchParams({ bas, bit });
    if (salon) q.set('salon', String(salon));
    if (brans) q.set('brans', brans);
    return istek<AmeliyathaneIcmali>(`/api/ameliyathane-icmal?${q}`);
  },
};
