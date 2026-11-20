import { istek, gonder } from '../cekirdek';

/**
 * ÇEK / SENET PORTFÖY İŞLEMLERİ (1386, CekSenetUclari): kartın "⚙ İşlem ▾" menüsü - Delphi UCekListeFrame sağ tık
 * menüsünün karşılığı. Hangi işlemin yapılabildiğine SUNUCU karar verir (kıymetin yönü + durumu).
 */
export type CekSenetIslemi = {
  kod: string; ad: string; ikon: string;
  /** 'cari' cari seçimi · 'hesap' kasa / banka hesabı · '' hiçbiri. */
  hedef: '' | 'cari' | 'hesap';
  ayrac: boolean;
  /** Kasa işlemi (cari / para etkisi) yazar. */
  kasa: boolean;
};

export type CekSenetIslemleri = {
  yon: number; durum: number; hesapId: number | null;
  geriAlinir: boolean;
  islemler: CekSenetIslemi[];
};

export type CekSenetIslemIstegi = {
  kod: string; tarih?: string; tarafId?: number; hesapId?: number; belgeNo?: string; aciklama?: string;
};

export const cekSenetIslemUclari = {
  cekSenetIslemleri: (id: number) => istek<CekSenetIslemleri>(`/api/cek-senet/${id}/islemler`),
  cekSenetIslem: (id: number, govde: CekSenetIslemIstegi) =>
    gonder<{ hareketId: number; kasaIslemId: number | null }>(`/api/cek-senet/${id}/islem`, govde),
  cekSenetGeriAl: (id: number) => gonder<unknown>(`/api/cek-senet/${id}/geri-al`, {}),
};
