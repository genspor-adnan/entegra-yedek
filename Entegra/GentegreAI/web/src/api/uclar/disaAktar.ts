import { gonderDosya } from '../cekirdek';

/** Çıktı menüsü "Gönder › Excel" ucu (DisaAktarUclari). */
export type ExcelHucresi = string | number | null;

export const disaAktarUclari = {
  /** Satırlardan gerçek .xlsx üretir; kalın satırlar başlık / toplam satırlarıdır. */
  disaAktarExcel: (govde: { dosyaAdi: string; sayfaAdi: string; satirlar: ExcelHucresi[][]; kalinSatirlar: number[] }) =>
    gonderDosya('/api/disa-aktar/excel', govde),
};
