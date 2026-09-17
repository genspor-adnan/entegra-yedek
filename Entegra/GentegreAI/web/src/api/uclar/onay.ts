import { gonder, istek } from '../cekirdek';

/**
 * ONAY UÇLARI (738/739) — modülden bağımsız onay omurgası.
 *
 * TEK KUTU, TÜM MODÜLLER: satınalma talebi bugün, izin/avans/onarım yarın.
 * Satır bir KAYIT değil BASAMAKTIR - aynı talebin iki basamağı iki ayrı
 * kişiye düşer; kayıt başına tek satır göstermek, sıradaki basamağın
 * sahibini kendi işinden habersiz bırakırdı.
 */

export interface OnayKutuSatiri {
  id: number;
  onayId: number;
  kaynakTur: number;
  kaynakId: number;
  kayitNo: string;
  konu: string;
  talepEden: string;
  birim: string;
  olcu: number;
  olcuAdi: string;
  adimAd: string;
  sira: number;
  rol: number;
  durum: number;
  gerekce: string;
  baslama: string;
  termin: string | null;
  gecikmeGun: number;
  akisKod: string;
  akisAd: string;
  atananKullaniciId: number | null;
}

export interface OnayAdimi {
  id: number;
  sira: number;
  ad: string;
  rol: number;
  durum: number;
  kararVerenId: number | null;
  kararZamani: string | null;
  gerekce: string;
  yaziliSon: string | null;
  termin: string | null;
}

export interface AkisDenemeAdimi {
  sira: number;
  ad: string;
  sahipTuru: number;
  rol: number;
  kullaniciId: number | null;
  sureGun: number;
  esikAlt: number | null;
  bayrak: string;
  eImza: number;
}

export const onayUclari = {
  /**
   * AKIŞI DENE (742) - KURU ÇALIŞTIRMA, kayıt üretmez. Zincir kurmayla aynı
   * metottan geçer: ayrı yazılsaydı deneme, gerçekte kurulacaktan başka bir
   * şey gösterir ve kimse farkı görmeden akışı yanlış kurardı.
   */
  onayAkisDene: (akisId: number, olcu: number, bayraklar: string[]) =>
    gonder<{
      akis: string; akisAd: string; olcuAdi: string; olcu: number;
      bayraklar: string[]; tanimliBasamak: number;
      adimlar: AkisDenemeAdimi[]; uyarilar: string[];
    }>(`/api/onay/akis/${akisId}/dene`, { olcu, bayraklar }),

  /** Kullanıcının bekleyen onayları (kişiye atanan + rol basamakları). */
  onayKutum: () => istek<{ satirlar: OnayKutuSatiri[] }>('/api/onay/kutum'),

  /** Bir kaydın zinciri - verilmiş imzalar dahil. */
  onayZinciri: (kaynakTur: number, kaynakId: number) =>
    istek<{
      onay: { id: number; durum: number; olcu: number; akisKod: string;
              akisAd: string; olcuAdi: string } | null;
      adimlar: OnayAdimi[];
    }>(`/api/onay/kayit/${kaynakTur}/${kaynakId}`),

  /**
   * Basamağa karar. Karar hep BEKLEYEN EN KÜÇÜK basamağa yazılır - basamak
   * atlanamaz; zincirin anlamı farklı kişilerin sırayla bakmasıdır.
   */
  onayKarar: (kaynakTur: number, kaynakId: number, g: {
    karar: 'onayla' | 'reddet' | 'bilgi-iste' | 'sozlu-onay';
    gerekce?: string; yaziliSaat?: number;
  }) => gonder<{
    karar: string; basamak: number; adim: string; zincirDurum: number;
    sonrakiBasamak: number | null; kayitDurum: number | null;
    yaziliSon: string | null;
  }>(`/api/onay/kayit/${kaynakTur}/${kaynakId}/karar`, g),
};
