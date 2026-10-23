import { istek } from '../cekirdek';

/** Tek ekstre (EkstreUclari, 1158). Devir ve yürüyen bakiye sunucuda. */
export type EkstreTuru = 'cari' | 'kasa' | 'banka' | 'pos' | 'kredi' | 'kredikarti';

export type EkstreSatiri = {
  id: number; tarih: string; vade: string | null; tur: number; turAdi: string; turGrup: string;
  belgeNo: string; islemNo: string; belgeId: number; kasaIslemId: number; aciklama: string;
  /** Cari: işlemin hesabı (hangi kasa / banka); hesap: cari. */
  karsi: string;
  borc: number; alacak: number; kur: number; yerelBorc: number; yerelAlacak: number;
  bakiye: number; bakiyeYerel: number; bakiyeDahil: boolean;
};
export type EkstreParasi = {
  doviz: string; yerelMi: boolean; devir: number; devirYerel: number;
  borc: number; alacak: number; yerelBorc: number; yerelAlacak: number;
  bakiye: number; bakiyeYerel: number; adet: number; satirlar: EkstreSatiri[];
};
export type EkstreHesabi = {
  id: number; kod: string; ad: string; altBilgi: string; durum: number;
  // cari
  musteri?: boolean; tedarikci?: boolean; vadeGun?: number; riskLimiti?: number; vadesiGecen?: number;
  toplamBakiye?: number; sonTahsilat?: string | null; sonSatis?: string | null;
  // hesap
  doviz?: string; acilisBakiye?: number; acilisTarihi?: string | null; bagliHesap?: string; altTur?: number; limit?: number;
};
export type Ekstre = {
  tur: EkstreTuru; harf: string; bas: string; bit: string; yerel: string;
  /** Kullanıcının görebildiği türler (veri yetkisi). */
  turler: EkstreTuru[];
  hesap: EkstreHesabi | null;
  paralar: EkstreParasi[];
  ozet: {
    devirYerel: number; borcYerel: number; alacakYerel: number; bakiyeYerel: number;
    adet: number; borcAdet: number; alacakAdet: number; sonHareket: string | null;
    sonAlacak: string | null; sonAlacakTutar: number; sonAlacakTur: string;
    sonBorc: string | null; sonBorcTutar: number; sonBorcTur: string;
  };
};
export type EkstreHesapSecimi = { id: number; kod: string; ad: string; altBilgi: string; durum: number };

export const ekstreUclari = {
  ekstre: (q: URLSearchParams) => istek<Ekstre>(`/api/ekstre?${q}`),
  ekstreHesaplar: (tur: string, q = '') => istek<EkstreHesapSecimi[]>(`/api/ekstre/hesaplar?tur=${tur}&q=${encodeURIComponent(q)}`),
};
