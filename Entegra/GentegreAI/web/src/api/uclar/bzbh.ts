import { gonder, istek } from '../cekirdek';

/**
 * BİLDİRİMİ ZORUNLU BULAŞICI HASTALIK — BZBH (882, KTS maddesi H5).
 *
 * Tani konunca sunucu BEKLEYEN bir bildirim satiri acar; vaka tipi ve
 * klinik belirti baslangici girilip "bildir" denince 214 paketi uretilir.
 * Hastalik listesi generic kart/liste ile yonetilir (`bzbh-hastalik`).
 */
export interface BzbhBildirimi {
  id: number;
  hastaId: number; hasta: string; hastaKimlik: string;
  muayeneId: number | null;
  icdKod: string; icdAdi: string;
  hastalik: string;
  /** 1 Grup A (ivedi) · 2 B · 3 C · 4 D. */
  grup: number; grupAdi: string;
  /** Bildirim suresi (saat) - gecikme bundan hesaplanir. */
  sureSaat: number;
  hekim: string;
  taniZamani: string | null;
  /** SKRS vaka tipi: 1 supheli · 2 olasi · 3 kesin. */
  vakaTipi: number | null; vakaTipiAdi: string;
  belirtiTarihi: string | null;
  /** 0 bekliyor · 1 bildirildi · 2 vazgecildi. */
  durum: number; durumAdi: string;
  bildirimZamani: string | null;
  paketNo: string;
  not_: string;
  gecikti: boolean;
}

export const bzbhUclari = {
  bzbhPano: (durum?: number) =>
    istek<{ bildirimler: BzbhBildirimi[];
            sayac: { bekleyen: number; geciken: number; bildirilen: number } }>(
      `/api/bzbh/pano${durum === undefined ? '' : `?durum=${durum}`}`),

  bzbhBildirim: (id: number) =>
    istek<{ bildirim: BzbhBildirimi }>(`/api/bzbh/bildirim/${id}`),

  /** 214 paketini uretir; eksik zorunlu alan varsa 400 ile durur. */
  bzbhBildir: (id: number, g: { vakaTipi: number; belirtiTarihi: string; not?: string }) =>
    gonder<{ id: number; paketNo: string; eksikler: string[]; mesaj: string }>(
      `/api/bzbh/bildirim/${id}/bildir`, g),

  /** Gerekce ZORUNLU: denetimde "neden bildirilmedi" sorulur. */
  bzbhVazgec: (id: number, not: string) =>
    gonder<{ durum: number }>(`/api/bzbh/bildirim/${id}/vazgec`, { not }),

  bzbhVakaTipleri: () =>
    istek<{ tipler: { kod: number; ad: string }[] }>('/api/bzbh/vaka-tipleri'),
};
