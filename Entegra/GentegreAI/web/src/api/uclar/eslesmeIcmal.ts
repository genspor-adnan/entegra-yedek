import { gonder, istek } from '../cekirdek';

/**
 * İRSALİYE-FATURA EŞLEŞME İCMALİ (EslesmeIcmalUclari, `/api/eslesme-icmal`).
 * Rakamlar ve durumlar sunucuda hesaplanır; ekran toplamaz. Alan adları sunucuyla birebir.
 */
export type EslesmeYon = 'satis' | 'alis' | 'ikisi';
/** kabul · red · sure (yanıt süresi doldu) · bekliyor · gonderildi · hazir · kagit */
export type EIrsaliyeDurumu = 'kabul' | 'red' | 'sure' | 'bekliyor' | 'gonderildi' | 'hazir' | 'kagit';

export type FaturasizIrsaliye = {
  id: number; tur: number; yon: 'satis' | 'alis'; no: string; tarih: string; tarafId: number; cari: string; depo: string;
  kalem: number; miktar: number; tutar: number; bekleyen: number;
  /** Eşikten uzun faturasız (konsinye muaf). */
  sureAsimi: boolean; konsinye: boolean; iade: boolean;
  eIrsaliye: EIrsaliyeDurumu; taslakFatura: boolean;
  kalemler: { kod: string; ad: string; miktar: number; birimFiyat: number }[];
};

export type EslesmeFarki = {
  irsaliyeId: number; tur: number; yon: 'satis' | 'alis'; irsaliyeNo: string; tarih: string; tarafId: number; cari: string;
  faturaNo: string; faturaId: number | null; satirId: number; kod: string; ad: string;
  irsMiktar: number; fatMiktar: number; kalan: number; irsFiyat: number; fatFiyat: number | null;
  fark: number; sapma: number; durum: 'kismi' | 'fazla' | 'fiyat' | 'tam';
  konsinye: boolean; eIrsaliye: EIrsaliyeDurumu;
};

export type BaglaOnerisi = {
  faturaSatirId: number; kod: string; ad: string; miktar: number; lotlu: boolean;
  irsaliyeSatirId: number | null; irsaliyeId: number | null; irsaliyeNo: string | null; irsaliyeKalan: number | null;
};

export type IrsaliyesizFatura = {
  id: number; tur: number; yon: 'satis' | 'alis'; no: string; tarih: string; tarafId: number; cari: string; tutar: number;
  stokluKalem: number;
  acikIrsaliyeler: { id: number; no: string; tarih: string; tutar: number; ortakKalem: number }[];
  eslesme: BaglaOnerisi[]; eslesenKalem: number; lotlu: boolean;
  /** bagla: aynı carinin açık irsaliyesinde aynı kalem var (mükerrer stok çıkışı şüphesi) · incele · normal */
  oneri: 'bagla' | 'incele' | 'normal';
  kapanmisDonem: boolean;
};

export type CariEslesme = {
  tarafId: number; cari: string; yon: 'satis' | 'alis'; irsaliye: number; tam: number; acik: number; acikTutar: number;
  ortSure: number | null; enEski: number | null; sureAsimi: number;
};

export type EslesmeIcmali = {
  yon: EslesmeYon; bas: string; bit: string; cari: number; sube: number; esik: number; tam: boolean;
  aySonuKalanGun: number; acikDonemBasi: string;
  ozet: {
    incelenen: number; faturasiz: number; faturasizTutar: number; enEskiGun: number; kismi: number; kismiKalan: number;
    irsaliyesiz: number; supheli: number; miktarFarki: number; fazla: number; fiyatFarki: number; fiyatFarkTutar: number;
    tam: number; tamOran: number; ortSure: number | null; sureAsimi: number; konsinyeAcik: number; redAcik: number;
    acikTutar: number; farkSatir: number;
  };
  faturasiz: FaturasizIrsaliye[];
  farklar: EslesmeFarki[];
  irsaliyesiz: IrsaliyesizFatura[];
  cariler: CariEslesme[];
  secim: { cariler: { id: number; ad: string }[]; subeler: { id: number; ad: string }[] };
  yetkiler: { faturala: boolean; bagla: boolean };
  izlemeNo: string;
};

export type BaglaYaniti = {
  faturaId: number; faturaNo: string; baglanan: number; irsaliyeler: { id: number; no: string }[];
  kapanmisDonem: boolean; donemler: string[]; uyarilar: string[]; izlemeNo: string;
};

export const eslesmeIcmalUclari = {
  eslesmeIcmali: (q: URLSearchParams) => istek<EslesmeIcmali>(`/api/eslesme-icmal?${q}`),
  /**
   * İrsaliyesiz faturayı açık irsaliye satırlarına bağlar ve faturanın stok etkisini kaldırır.
   * Kapanmış döneme dokunuyorsa `onay` olmadan 422 (engel.kod = KAPANMIS_DONEM) döner.
   */
  bagla: (faturaId: number, satirlar: { faturaSatirId: number; irsaliyeSatirId: number }[], onay: boolean) =>
    gonder<BaglaYaniti>('/api/eslesme-icmal/bagla', { faturaId, satirlar, onay }),
};
