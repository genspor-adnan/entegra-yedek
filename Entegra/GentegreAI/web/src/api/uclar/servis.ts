import { gonder, istek } from '../cekirdek';

/**
 * TEKNİK SERVİS UÇLARI (773).
 *
 * ÜÇ KATMAN: çağrı (SLA işliyor) → iş emri (yapılan iş) → ziyaret (bir
 * gidiş). İstemci hiçbirini kendi hesaplamaz; SLA, toplam ve durum geçişleri
 * sunucudadır - ekranda görünen taahhüt ile sözleşmeye yazılan aynı olmalı.
 */

export interface ServisCihazi {
  id: number;
  ad: string;
  markaModel: string;
  seriNo: string;
  /** 0 bilinmiyor · 1 sürüyor · 2 bitti */
  garantiDurum: number;
  sozlesmeId: number | null;
  cagriSayisi: number;
  bolge: string;
  durum: number;
}

export const servisUclari = {
  /**
   * Çağrı açar. Sözleşme verilmezse cihazınki, o da yoksa carinin yürürlükteki
   * sözleşmesi bulunur ve SLA ondan hesaplanır - taahhüt sözleşmeden kopmasın.
   */
  servisCagriAc: (g: {
    tarafId: number; tarafCihazId?: number; sozlesmeId?: number;
    cihazMetni?: string; sikayet: string; kapsamTur?: number;
    oncelik?: number; bildiren?: string; telefon?: string;
  }) => gonder<{
    id: number; cagriNo: string; slaBitis: string | null;
    slaKalanDk: number | null; kapsam: string; sozlesmeId: number | null;
    mesaj: string;
  }>('/api/servis/cagri', g),

  /** Çağrıdan iş emri açar; çağrı "atandı" olur ve ilk yanıt damgalanır. */
  servisIsEmriAc: (cagriId: number, g?: {
    tur?: number; yapanId?: number; planlanan?: string; aciklama?: string;
  }) => gonder<{ id: number; isEmriNo: string; cagriId: number; mesaj: string }>(
      `/api/servis/cagri/${cagriId}/is-emri`, g ?? {}),

  /** Ziyaret açar (varış damgalanır); plan verilirse ileri tarihli plandır. */
  servisZiyaretAc: (isEmriId: number, g?: {
    teknisyenId?: number; planZamani?: string; arac?: string;
  }) => gonder<{ id: number; sira: number; isEmriId: number; mesaj: string }>(
      `/api/servis/is-emri/${isEmriId}/ziyaret`, g ?? {}),

  /**
   * Ziyareti kapatır. İMZASIZ KAPANMAZ: alınamadıysa `imzaNotu` zorunlu -
   * kural esner ama iz kalır. Sonuç "çözüldü" ise çağrı da kapanır.
   */
  servisZiyaretKapat: (ziyaretId: number, g: {
    yapilan: string; sonuc?: number; sonucMetni?: string;
    yolKm?: number; iscilikSaat?: number; tutar?: number;
    imzaAlindi: boolean; imzaNotu?: string; mesaiDisi?: boolean;
  }) => gonder<{ durum: number; toplamTutar: number; mesaj: string }>(
      `/api/servis/ziyaret/${ziyaretId}/kapat`, g),

  servisEmanetVer: (isEmriId: number, g: {
    tarafId?: number; demirbasId?: number; cihazMetni?: string; aciklama?: string;
  }) => gonder<{ id: number; emanetNo: string; mesaj: string }>(
      `/api/servis/is-emri/${isEmriId}/emanet`, g),

  servisEmanetIade: (emanetId: number) =>
    gonder<{ durum: number }>(`/api/servis/emanet/${emanetId}/iade`, {}),

  /** Teslim bir KAPIDIR: açık emanet ya da kapanmamış ziyaret varsa reddeder. */
  servisTeslim: (isEmriId: number, not?: string) =>
    gonder<{ durum: number; toplamTutar: number; ziyaret: number; mesaj: string }>(
      `/api/servis/is-emri/${isEmriId}/teslim`, { not }),

  servisCihazParki: (tarafId: number) =>
    istek<{ satirlar: ServisCihazi[] }>(`/api/servis/cihaz-parki/${tarafId}`),
};
