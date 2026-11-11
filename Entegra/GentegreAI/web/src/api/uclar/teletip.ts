import { gonder, istek } from '../cekirdek';

/**
 * TELETIP GÖNDERİMİ (1302-1304; Bakanlık Teleradyoloji, Mirth K1 üzerinden). Sunucu mesajı kurar, denetler, gönderir;
 * istemci yalnız izi gösterir, ham mesajı açar ve "yeniden gönder" der.
 * Durum: 0 kuyrukta · 1 gönderildi (AA) · 2 reddedildi (AE) · 3 gidemez (eksik) · 4 atlandı · 5 ulaşmadı (tekrar).
 * Emir: 1 NW (yeni istem) · 2 XO (güncelleme) · 3 CA (iptal).
 */
export interface TeletipSatir {
  id: number; kanal: number; emir: number; durum: number; denemeNo: number; ackKodu: string; hata: string;
  kontrolNo: string; accessionNo: string; eklemeTarihi: string; sonDeneme: string | null; sonrakiDeneme: string | null;
}
export interface TeletipIstemOzet {
  id: number; accessionNo: string; durum: number; hastaId: number; hastaAdi: string; tetkikAdi: string; modalite: string; kabul: string;
}

export const teletipUclari = {
  /** İstemin Teletıp mesaj izi (şerit + kart). `aktif` false ise kurumda Teletıp kapalı. */
  teletipIstem: (istemId: number) =>
    istek<{ aktif: boolean; istem: TeletipIstemOzet | null; satirlar: TeletipSatir[]; detayYetkisi: boolean }>(`/api/teletip/istem/${istemId}`),
  /** Ham HL7 mesajı ve ACK (hasta kimliği içerir - radyoloji.teletip). */
  teletipMesaj: (gonderimId: number) => istek<{ mesaj: string; yanit: string }>(`/api/teletip/gonderim/${gonderimId}/mesaj`),
  /** Reddedilen / gidemez / ulaşmadı satırını şimdi yeniden dener. */
  teletipDene: (gonderimId: number) =>
    gonder<{ gonderimId: number; durum: number; ackKodu: string; hata: string }>(`/api/teletip/gonderim/${gonderimId}/dene`, {}),
  /** Göndermeden: istemin şu anki verisiyle NW mesajı ve eksik listesi. */
  teletipOnizle: (istemId: number) => istek<{ eksikler: string[]; mesaj: string }>(`/api/teletip/istem/${istemId}/onizle`),
};

export const TELETIP_DURUM: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'kuyrukta', sinif: 'uyari' },
  1: { ad: 'gönderildi', sinif: 'olumlu' },
  2: { ad: 'reddedildi', sinif: 'hata' },
  3: { ad: 'gidemez', sinif: 'hata' },
  4: { ad: 'atlandı', sinif: 'gri' },
  5: { ad: 'ulaşmadı', sinif: 'uyari' },
};
export const TELETIP_EMIR: Record<number, string> = { 1: 'NW', 2: 'XO', 3: 'CA' };
export const TELETIP_EMIR_ADI: Record<number, string> = { 1: 'Yeni istem', 2: 'Güncelleme', 3: 'İptal' };
