import { gonder, istek } from '../cekirdek';

/** Sevk kartı şeridi / ön izleme (1110). */
export interface SevkOzet {
  no: string; hasta: string; hastaKod: string; cinsiyetYas: string;
  hekim: string; bolum: string; tani: string;
  epikriz: boolean; lab: number; goruntuleme: number;
  medulaSevkNo: string; durum: number;
}

type Mesaj = { id: number; mesaj: string };

/** SEVK (1110) - mockup v2: kart taslağı yazar; gönder / iptal / sonuç burada. */
export const sevkUclari = {
  sevkKapsam: () => istek<{ ben: number; bolumler: number[] }>('/api/sevk/kapsam'),
  sevkOzet: (id: number) => istek<SevkOzet>(`/api/sevk/${id}/ozet`),
  sevkGonder: (id: number) => gonder<Mesaj>(`/api/sevk/${id}/gonder`, {}),
  sevkIptal: (id: number, gerekce: string) => gonder<Mesaj>(`/api/sevk/${id}/iptal`, { gerekce }),
  sevkSonuc: (id: number) => gonder<Mesaj>(`/api/sevk/${id}/sonuc`, {}),
  /** Muayeneden sevk: taslak açılır (hasta, hekim, bölüm, başvuru muayeneden). */
  muayenedenSevk: (muayeneId: number) => gonder<Mesaj>(`/api/muayene/${muayeneId}/sevk`, {}),
};
