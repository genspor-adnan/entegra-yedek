import {
  type KasaIslemTuru, type KasaIslemYaniti, type KasaIslemYazmaIstegi, type FisOzeti,
  } from '../sozlesme';
import { istek, gonder } from '../cekirdek';

/** Kasa / banka islemleri ve muhasebe fisi. */
export const kasaUclari = {
  // --------------------------------------------------------------- kasa ----
  kasaIslemTurleri: () =>
    istek<{ turler: KasaIslemTuru[] }>('/api/kasa-islem-turu').then(y => y.turler),

  kasaOku: (id: number) => istek<KasaIslemYaniti>(`/api/kasa-islem/${id}`),

  /** Nakit islemde acilacak kasa (196): once kullaniciya atanmis kasa, yoksa
      subenin varsayilan kasasi. Yoksa hesapId null doner. */
  kullaniciKasasi: (tur = 'K') =>
    istek<{ hesapId: number | null; ad?: string; dovizCinsi?: string; kendiKasasi?: boolean }>(
      `/api/kasa/kullanici-kasasi?tur=${encodeURIComponent(tur)}`),

  kasaEkle: (govde: KasaIslemYazmaIstegi) =>
    gonder<KasaIslemYaniti>('/api/kasa-islem', govde),

  kasaGuncelle: (id: number, govde: KasaIslemYazmaIstegi) =>
    gonder<KasaIslemYaniti>(`/api/kasa-islem/${id}`, govde, 'PUT'),

  kasaKesinlestir: (id: number) =>
    gonder<KasaIslemYaniti>(`/api/kasa-islem/${id}/kesinlestir`, {}),

  /** Plandan tahsilat/odeme uretir. tutar bos = planin kalani. */
  kasaGerceklestir: (id: number, hesapId: number, tutar?: number, tarih?: string, tur?: number) =>
    gonder<KasaIslemYaniti>(`/api/kasa-islem/${id}/gerceklestir`, { hesapId, tutar, tarih, tur }),

  kasaIptal: (id: number, sebep: string, tarih?: string) =>
    gonder<{ islem: Record<string, unknown>; tersIslemId: number }>(
      `/api/kasa-islem/${id}/iptal`, { sebep, tarih }),

  kasaSil: (id: number) =>
    istek<{ silindi: boolean }>(`/api/kasa-islem/${id}`, { method: 'DELETE' }),

  /** Kur kutusu: o tarihin kuru (yoksa onceki en yakin gun). yon 1 satis / 2 alis. */
  dovizKur: (cins: string, tarih: string, yon = 1) =>
    istek<{ dovizCinsi: string; tarih: string; kurTarihi: string | null; kur: number | null }>(
      `/api/referans/doviz-kur?cins=${encodeURIComponent(cins)}&tarih=${tarih}&yon=${yon}`),

  fisOku: (id: number) =>
    istek<{ fis: FisOzeti }>(`/api/muhasebe/fis/${id}`).then(y => y.fis),
};
