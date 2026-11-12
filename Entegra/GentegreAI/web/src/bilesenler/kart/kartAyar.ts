import type { EkSekmeBaglami } from '../GenForm';

/**
 * ENTEGRASYON KARTI SEKMELERİ ORTAK YARDIMCILARI (PACS / TeleRadyoloji / e-Nabız kimliği). Hesabın serbest ayarları
 * `ayarlar` JSON alanında; sekmeler oradan okur, tek anahtar yazar.
 */

/** `ayarlar` değeri (nesne ya da JSON metni) → nesne; bozuksa boş. */
export function jsonOku(v: unknown): Record<string, unknown> {
  if (v && typeof v === 'object') return v as Record<string, unknown>;
  try { const o = JSON.parse(String(v ?? '') || '{}'); return o && typeof o === 'object' ? o : {} } catch { return {} }
}

export const metin = (v: unknown) => (v === null || v === undefined ? '' : String(v));

/** `ayarlar` JSON'una tek anahtar yazan işlev; boş değer anahtarı siler. */
export function ayarYazici(e: EkSekmeBaglami) {
  return (anahtar: string, v: string | number) => {
    const yeni: Record<string, unknown> = { ...jsonOku(e.deger.ayarlar), [anahtar]: v };
    if (v === '') delete yeni[anahtar];
    e.alanYaz('ayarlar', JSON.stringify(yeni));
  };
}

/** Bakanlık test ortamı kodları - gerçek bağlantıdan önce değişmeli (sunucuda KurumKimlik.TestSkrs / TestTesis). */
export const TEST_SKRS = '999999';
export const TEST_TESIS = '99999999';
