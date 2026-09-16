import { gonder } from '../cekirdek';

/**
 * Klinik Kalite hesaplama uçları (db/713 motoru, api/KlinikKaliteUclari).
 *
 * ŞUBE GÖNDERİLMEZ: sunucu oturumun aktif şubesini kullanır. İstemciden şube
 * yollasaydık, kullanıcı görmediği bir şubenin dönem sonucunu hesaplayıp
 * yazabilirdi.
 */
export const klinikKaliteUclari = {
  /** Dönemin tüm otomatik göstergelerini hesaplar ve yazar. */
  klinikKaliteHesapla: (yil: number, donemNo: number, periyot: number) =>
    gonder<{ yazilan: number; atlanan: number; kodsuz: number; sureMs: number }>(
      '/api/klinik-kalite/hesapla', { yil, donemNo, periyot }),

  /** Tek göstergeyi önizler - kayıt YAZMAZ. */
  klinikKaliteOnizle: (gostergeId: number, yil: number, donemNo: number, periyot: number) =>
    gonder<{ pay: number; payda: number; durum: string; aciklama: string }>(
      '/api/klinik-kalite/onizle', { gostergeId, yil, donemNo, periyot }),

  /** Dönemi kesinleştirir - TEK YÖN, geri alınamaz. */
  klinikKaliteKesinlestir: (yil: number, donemNo: number, periyot: number) =>
    gonder<{ kesinlesen: number }>(
      '/api/klinik-kalite/kesinlestir', { yil, donemNo, periyot }),
};
