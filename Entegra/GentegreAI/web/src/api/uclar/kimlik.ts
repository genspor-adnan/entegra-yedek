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

  // ------------------------------------- KULLANICI AYARLARI (669) ----
  // Hepsi KISININ KENDI hesabi; kullanici kimligi token'dan gelir,
  //   istemci "kim oldugunu" gondermez.

  /** Hesabim sekmesi: iletisim, roller, son giris, parola yasi. */
  hesabim: () => istek<HesapBilgisi>('/api/kimlik/hesabim'),

  iletisimKaydet: (eposta: string, cepTel: string) =>
    gonder<void>('/api/kimlik/iletisim', { eposta, cepTel }, 'PUT'),

  /** Acik oturumlar (cihazlar). `buCihaz` IP + tarayici esinden gelir. */
  oturumlar: () => istek<AcikOturum[]>('/api/kimlik/oturumlar'),

  /** Secilen oturumu kapatir - ayni ailenin tum refresh kayitlari kapanir. */
  oturumKapat: (oturumId: number) =>
    gonder<{ kapanan: number }>(`/api/kimlik/oturumlar/${oturumId}/kapat`, {}),

  /** Son 10 giris denemesi - BASARISIZLAR DAHIL. */
  girisGecmisi: () => istek<GirisDenemesi[]>('/api/kimlik/giris-gecmisi'),
};

/** Kullanici Ayarlari > Hesabim (669). */
export interface HesapBilgisi {
  unvan: string; gorev: string;
  eposta: string; cepTel: string;
  parolaTarihi?: string | null; sonGiris?: string | null; sonGirisIp: string;
  hataliGiris: number; totpAktif: boolean;
  anaRol: string; ekRoller: string[];
}

/** Kullanici Ayarlari > Guvenlik (669): acik oturum satiri. */
export interface AcikOturum {
  id: number; ip: string; istemci: string;
  olusma: string; sonKullanim: string; bitis: string;
  sube: string; buCihaz: boolean;
}

/** Kullanici Ayarlari > Guvenlik (669): giris denemesi. */
export interface GirisDenemesi {
  tarih: string; basarili: boolean; sebep: string; ip: string; istemci: string;
}
