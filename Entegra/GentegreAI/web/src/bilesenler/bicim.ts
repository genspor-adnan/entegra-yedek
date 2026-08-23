import type { KolonMeta } from '../api/sozlesme';

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const sayi = new Intl.NumberFormat('tr-TR');
const tarih = new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' });
const tarihSaat = new Intl.DateTimeFormat('tr-TR', {
  day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit',
});

function tarihParcala(deger: string): { gun: string; ay: string; yil: string; saat?: string; dakika?: string } | null {
  const eslesme = deger.match(/^(\d{4})-(\d{2})-(\d{2})(?:[T\s](\d{2}):(\d{2}))?/);
  if (!eslesme) return null;
  return {
    yil: eslesme[1],
    ay: eslesme[2],
    gun: eslesme[3],
    saat: eslesme[4],
    dakika: eslesme[5],
  };
}

export function tarihYaz(deger: string): string {
  const parca = tarihParcala(deger);
  if (parca) return `${parca.gun}.${parca.ay}.${parca.yil}`;

  const t = new Date(deger);
  return Number.isNaN(t.getTime()) ? deger : tarih.format(t);
}

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
      const metin = String(deger);
      const parca = tarihParcala(metin);
      if (parca) {
        const sadeceTarih = `${parca.gun}.${parca.ay}.${parca.yil}`;
        return kolon.bicim?.includes('HH') && parca.saat
          ? `${sadeceTarih} ${parca.saat}:${parca.dakika ?? '00'}`
          : sadeceTarih;
      }

      const t = new Date(metin);
      if (Number.isNaN(t.getTime())) return String(deger);
      return kolon.bicim?.includes('HH') ? tarihSaat.format(t) : tarih.format(t);
    }
    case 'mantik':
      return Number(deger) === 1 ? '✓' : '';
    default:
      return String(deger);
  }
}
