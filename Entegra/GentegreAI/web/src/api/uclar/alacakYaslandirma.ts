import { istek } from '../cekirdek';

/** Alacak yaşlandırma (AlacakYaslandirmaUclari). Rakamlar sunucuda hesaplanır. */
type Dilimli = { d0: number; d30: number; d60: number; d90: number; toplam: number; enEskiGun: number; ortGun: number; sonTahsilat?: string | null };
export type KurumAlacagi = Dilimli & {
  id: number; ad: string; tur: number; turAdi: string; acikBelge: number;
  /** Kesilmiş ama ödenmemiş fatura / tahakkuk. */
  faturali: number;
  /** Henüz faturalanmamış kurum payı. */
  faturasiz: number;
};
export type HastaAlacagi = Dilimli & { id: number; ad: string; dosyaNo: string; acikProtokol: number };
export type AlacakYaslandirma = {
  tarih: string;
  ozet: {
    toplam: number; kurum: number; hasta: number; d0: number; d30: number; d60: number; d90: number;
    enEskiGun: number; ortGun: number; kurumSayisi: number; hastaSayisi: number; faturasizKurumPayi: number;
  };
  dilimler: { ad: string; kurum: number; hasta: number; toplam: number }[];
  kurumlar: KurumAlacagi[]; hastalar: HastaAlacagi[];
};

export const alacakYaslandirmaUclari = {
  alacakYaslandirma: (tarih: string, taraf: string, kurumTuru: number) => {
    const q = new URLSearchParams({ tarih, taraf });
    if (kurumTuru) q.set('kurumTuru', String(kurumTuru));
    return istek<AlacakYaslandirma>(`/api/alacak-yaslandirma?${q}`);
  },
};
