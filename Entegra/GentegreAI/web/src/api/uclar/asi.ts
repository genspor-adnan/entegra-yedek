import { gonder, istek } from '../cekirdek';

/**
 * AŞI MODÜLÜ (898 — KTS maddesi H10, USS 207 Aşı Veri Seti).
 *
 * Kayıt hasta bazlıdır ve 207 paketi kayıttan doğar. DOZ NUMARASINI SUNUCU
 * SÖYLER: elle yazılan doz, USS'deki şemayı kaydırır.
 */
export interface AsiSiradaki {
  asiId: number; kod: string; ad: string;
  /** 0 = şemasız (seyahat aşısı, kuduz profilaksisi kendi akışında). */
  dozSayisi: number;
  sonrakiDoz: number;
}

export interface AsiUygulamasi {
  id: number; asiId: number; asiKod: string; asi: string;
  /** Boşsa aşı e-Nabız'a GÖNDERİLEMEZ - ekran bunu söyler. */
  skrsKod: string;
  dozNo: number; dozSayisi: number; kalanDoz: number;
  lot: string; barkod: string;
  uygulamaZamani: string; uygulayan: string;
  /** 1 uygulandı · 0 iptal (kayıt silinmez). */
  durum: number; iptalNeden: string;
  enabizDurum: number; aciklama: string;
}

export const asiUclari = {
  asiHastaGecmisi: (hastaId: number) =>
    istek<{ uygulamalar: AsiUygulamasi[]; siradaki: AsiSiradaki[] }>(
      `/api/asi/hasta/${hastaId}`),

  asiUygula: (govde: {
      tarafId: number; asiId: number; dozNo?: number;
      belgeId?: number | null; muayeneId?: number | null;
      lot?: string; barkod?: string;
      uygulamaSekli?: number; uygulamaYeri?: number; islemTuru?: number;
      ozelDurum?: number; izlemYeri?: number; uygulayanId?: number;
      uygulamaZamani?: string; bilgiAlinanAd?: string; bilgiAlinanTel?: string;
      sorguNo?: string; aciklama?: string }) =>
    gonder<{ id: number; doz: number; mesaj: string }>('/api/asi/uygula', govde),

  /** Yanlış kayıt SİLİNMEZ, gerekçesiyle iptal edilir. */
  asiIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/asi/${id}/iptal`, { neden }),
};
