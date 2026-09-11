import { istek, gonder } from '../cekirdek';

/** Kurum icmali (289). */
export const icmalUclari = {
  // -------------------------------------------------------- kurum icmali ----
  /** Donemde faturalanacak acik kurum paylari (289) - icmal oncesi onizleme. */
  icmalOnizleme: (kurumId: number, donemBas: string, donemBit: string) =>
    istek<{ satirlar: Record<string, unknown>[]; toplam: number }>(
      `/api/kurum-icmal/onizleme?kurumId=${kurumId}`
      + `&donemBas=${donemBas}&donemBit=${donemBit}`),

  icmalOlustur: (govde: { kurumId: number; donemBas: string; donemBit: string;
                          aciklama?: string }) =>
    gonder<{ icmalId: number; satir: number }>('/api/kurum-icmal', govde),

  /** Icmali TEK faturaya cevirir; cari KURUMDUR, satirlarin kurum payi kapanir. */
  icmalFaturala: (icmalId: number) =>
    gonder<{ belgeId: number; satir: number; uyarilar?: string[] }>(
      `/api/kurum-icmal/${icmalId}/faturala`, {}),

};
