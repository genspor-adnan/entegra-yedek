import { istek, gonder } from '../cekirdek';

/** Sigorta / provizyon. */
export const sigortaUclari = {
  // --------------------------------------------------------------- SIGORTA
  /** Sağlayıcı kataloğu + yetenekler (430): ekran düğmeleri buna göre çizilir. */
  sigortaSaglayicilar: () =>
    istek<{ saglayicilar: { id: number; kod: string; ad: string;
                            yetenekler: string; durum: number; hesap: number }[] }>(
      '/api/sigorta/saglayicilar'),

  /** checkPolicy - poliçe bu kurumda, bu hekimle, bu tarihte geçerli mi. */
  sigortaPoliceSorgu: (govde: { tarafId: number; kurumId: number; hekimId?: number;
                                policeNo?: string; tarih?: string }) =>
    gonder<{ id: number; gecerli: boolean; policeNo: string; policeAdi: string;
             kartNo: string; agKodu: string; notlar: string[]; mesaj: string }>(
      '/api/sigorta/police-sorgu', govde),

  /** createProvision - başvurudan provizyon oluştur/güncelle; paylar yazılır. */
  sigortaProvizyon: (govde: { belgeId: number; tip?: number; altTip?: number;
                              hizmetTipi?: number; vakaTipi?: number;
                              talepTuru?: number; acil?: boolean; not?: string }) =>
    gonder<{ id: number; mesaj: string }>('/api/sigorta/provizyon', govde),

  sigortaProvizyonOku: (id: number) =>
    istek<{ ozet: Record<string, unknown>;
            satirlar: Record<string, unknown>[];
            tanilar: { kod: string; ad: string }[];
            notlar: { tip: string; metin: string }[];
            dokumanlar: Record<string, unknown>[] }>(`/api/sigorta/provizyon/${id}`),

  sigortaTazele: (id: number) =>
    gonder<{ mesaj: string }>(`/api/sigorta/provizyon/${id}/tazele`, {}),

  sigortaIptal: (id: number, nedenKodu: number, aciklama: string) =>
    gonder<{ mesaj: string }>(`/api/sigorta/provizyon/${id}/iptal`,
      { nedenKodu, aciklama }),

  sigortaDokumanGonder: (id: number, tipKodu: string, dokumanId: number) =>
    gonder<{ mesaj: string }>(`/api/sigorta/provizyon/${id}/dokuman`,
      { tipKodu, dokumanId }),

  sigortaHesapTest: (id: number) =>
    gonder<{ saglayici: string; test: boolean; mesaj: string; notlar: string[] }>(
      `/api/sigorta/hesap/${id}/test`, {}),

};
