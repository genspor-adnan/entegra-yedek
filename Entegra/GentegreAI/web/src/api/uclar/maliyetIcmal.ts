import { istek } from '../cekirdek';

/** Hasta başı maliyet / sarf icmali (MaliyetIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type MaliyetKalemi = {
  stokId: number; ad: string; miktar: number; maliyet: number; ilac: boolean;
  /** radyoloji / dis / ameliyat = düşülen sarf; fatura = başvurudaki stok satırı. */
  kaynak: string; faturali: boolean;
};
export type MaliyetliBasvuru = {
  id: number; protokolNo: string; tarih: string; hastaId: number; hasta: string; bolumId: number; bolum: string; hekim: string;
  ciro: number; sarf: number; ilac: number; kar: number; marj?: number | null; kalemler: MaliyetKalemi[];
};
export type MaliyetIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    basvuru: number; ciro: number; sarf: number; ilac: number; kar: number; marj?: number | null;
    zarar: number; zararTutar: number; maliyetliBasvuru: number; hastaBasi: number;
    faturasizKalem: number; faturasizMaliyet: number;
  };
  basvurular: MaliyetliBasvuru[];
  hizmetler: { hizmetId: number; ad: string; adet: number; ciro: number; maliyet: number; ortFiyat: number;
               ortMaliyet: number; standartSarf: number; marj?: number | null }[];
  faturasizSarf: { belgeId: number; protokolNo: string; tarih: string; hasta: string; bolum: string; stokId: number;
                   ad: string; miktar: number; maliyet: number; ilac: boolean; kaynak: string }[];
  bolumler: { id: number; ad: string; basvuru: number; ciro: number; sarf: number; ilac: number; kar: number;
              marj?: number | null; hastaBasi: number }[];
  bolumAdlari: { id: number; ad: string }[];
};

export const maliyetIcmalUclari = {
  maliyetIcmali: (bas: string, bit: string, bolum: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (bolum) q.set('bolum', String(bolum));
    return istek<MaliyetIcmali>(`/api/maliyet-icmal?${q}`);
  },
};
