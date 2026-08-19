import type { KolonMeta } from '../api/sozlesme';

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const sayi = new Intl.NumberFormat('tr-TR');
const tarih = new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' });

/**
 * Hucre bicimlendirme. Sunucu sayilari JSON'da metin olarak da gonderebilir
 * (numeric alanlar) - ikisi de desteklenir.
 *
 * 'mantik' alanlar PG'de SMALLINT'tir (MSSQL bit karsiligi): 1 = evet.
 */
export function bicimle(deger: unknown, kolon: KolonMeta): string {
  if (deger === null || deger === undefined) return '';

  switch (kolon.tip) {
    case 'para': {
      const s = Number(deger);
      return Number.isFinite(s) ? para.format(s) : String(deger);
    }
    case 'sayi': {
      const s = Number(deger);
      return Number.isFinite(s) ? sayi.format(s) : String(deger);
    }
    case 'tarih': {
      const t = new Date(String(deger));
      return Number.isNaN(t.getTime()) ? String(deger) : tarih.format(t);
    }
    case 'mantik':
      return Number(deger) === 1 ? '✓' : '';
    default:
      return String(deger);
  }
}
