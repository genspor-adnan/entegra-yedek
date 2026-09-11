import {
  type BenYaniti, type GirisYaniti, } from '../sozlesme';
import { istek, gonder, oturum } from '../cekirdek';

/** Kimlik ve oturum. */
export const kimlikUclari = {
  // ------------------------------------------------------------- kimlik ----
  giris: (kod: string, parola: string, subeId?: number) =>
    gonder<GirisYaniti>('/api/kimlik/giris', { kod, parola, subeId }),

  cikis: async () => {
    const refresh = oturum.refresh;
    if (refresh) { try { await gonder('/api/kimlik/cikis', { refreshToken: refresh }) } catch { /* yoksay */ } }
    oturum.temizle();
  },

  ben: () => istek<BenYaniti>('/api/kimlik/ben'),

  subeSec: (subeId: number) =>
    istek<GirisYaniti>('/api/kimlik/sube', {
      method: 'POST',
      body: JSON.stringify({ subeId }),
      headers: oturum.refresh ? { 'X-Refresh-Token': oturum.refresh } : {},
    }),

  /**
   * MARKA (502): giris ekrani hangi urunun kapisi - oturum ACILMADAN sorulur.
   * Kurulusun urun modu (1 Gentegre AI / 2 GenoTIP AI) sunucudan gelir.
   */
  marka: () => istek<{ urunModu: number }>('/api/kimlik/marka'),

  /** Ilk giris: otomatik acilan hesabin parolasini kisi kendisi tanimlar. */
  ilkParola: (kod: string, tcknSon4: string, yeniParola: string) =>
    gonder<{ mesaj: string }>('/api/kimlik/ilk-parola', { kod, tcknSon4, yeniParola }),

  parolaDegistir: (eskiParola: string, yeniParola: string) =>
    gonder<void>('/api/kimlik/parola', { eskiParola, yeniParola }),

  dilDegistir: (dil: number) =>
    gonder<void>('/api/kimlik/dil', { dil }),

};
