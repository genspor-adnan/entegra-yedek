import { istek } from '../cekirdek';

/** Sevk eden / dış doktor icmali (SevkEdenIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type OdemeDurumu = 'yok' | 'taslak' | 'hesaplandi' | 'onayli' | 'listede' | 'odendi';
export type SevkEden = {
  id: number; ad: string;
  /** dis = dış hekim (kendi adına), kurum = kurum adına gelen iş, ic = iç personel. */
  tur: 'dis' | 'kurum' | 'ic'; brans: string; telefon: string;
  basvuru: number; ciro: number; ortBasvuru: number;
  /** Gönderen primi (hakediş satırları rol 1). */
  komisyon: number; oran: number; odenen: number; bekleyen: number; odemeDurumu: OdemeDurumu;
  oncekiBasvuru: number; oncekiCiro: number; yeni: boolean; degisim?: number | null;
};
export type SevkEdenIcmali = {
  donem: { bas: string; bit: string; oncekiBas: string; oncekiBit: string };
  secili: number[];
  ozet: {
    gonderen: number; disHekim: number; kurum: number; basvuru: number; ciro: number; ortBasvuru: number;
    komisyon: number; odenen: number; bekleyen: number; yeni: number; oncekiBasvuru: number;
  };
  doktorlar: SevkEden[];
  basvurular: { belgeId: number; protokolNo: string; tarih: string; hasta: string; bolum: string;
                gonderenId: number; gonderen: string; tutar: number }[];
  /** Prim satırları: durum 1 taslak · 2 kesin · 3 onaylı · 4 ödendi; hakedisId dolu = ödeme listesinde. */
  odemeler: { id: number; gonderenId: number; gonderen: string; tarih: string; protokolNo: string; taban: number;
              oranTipi: number; deger: number; tutar: number; durum: number; hakedisId?: number | null; hakedisDurum: number }[];
};

export const sevkEdenUclari = {
  sevkEdenIcmali: (bas: string, bit: string, gonderenler: number[]) => {
    const q = new URLSearchParams({ bas, bit });
    if (gonderenler.length) q.set('gonderenler', gonderenler.join(','));
    return istek<SevkEdenIcmali>(`/api/sevk-eden?${q}`);
  },
};
