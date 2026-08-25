import type { KolonMeta } from '../api/sozlesme';

/**
 * TEK BICIM KAYNAGI: tutar / miktar bicimleri butun ekranlarda ayni olmali.
 *   para  - iki hane, tutar kolonlari
 *   say4  - dorde kadar hane, MIKTAR (0,5 adet / 12,375 kg)
 *   sayi  - tam sayi
 * Onceden her dosya kendi Intl.NumberFormat'ini kuruyordu (8 kopya); biri
 * degistiginde otekiler geride kaliyordu.
 */
export const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
export const say4 = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 4 });
export const sayi = new Intl.NumberFormat('tr-TR');
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
/**
 * TELEFON GOSTERIMI (genel kural): kayitta ne olursa olsun ekranda ayni bicim.
 * "+905324187720" / "0532 418 77 20" / "5324187720" -> "+90 532 418 77 20".
 * Yabanci numarada gruplama yapilmaz (format ulkeden ulkeye degisir), yalniz
 * ulke kodu ayrilir.
 */
export function telefonBicimle(ham: unknown): string {
  const metin = String(ham ?? '').trim();
  if (!metin) return '';

  const artili = metin.startsWith('+');
  const rakam = metin.replace(/\D/g, '');
  if (!rakam) return metin;

  // Yerel yazim: "0532...", "532..." - Turkiye kabul edilir.
  if (!artili) {
    const on = rakam.length === 11 && rakam.startsWith('0') ? rakam.slice(1) : rakam;
    if (on.length === 10) return `+90 ${on.slice(0, 3)} ${on.slice(3, 6)} ${on.slice(6, 8)} ${on.slice(8)}`;
    return metin;
  }

  if (rakam.startsWith('90')) {
    // Kullanici ulke kodunun ARDINDAN da "0" yazabiliyor ("+90 0532..."):
    //   yerel onek atilir, kalan 10 hane ise gruplanir.
    let on = rakam.slice(2);
    if (on.length === 11 && on.startsWith('0')) on = on.slice(1);
    if (on.length === 10)
      return `+90 ${on.slice(0, 3)} ${on.slice(3, 6)} ${on.slice(6, 8)} ${on.slice(8)}`;
  }
  // Diger ulkeler: rakamlara dokunma, yalniz "+" korunur.
  return `+${rakam}`;
}

/** Kolon telefon mu - katalogda Bicim:"telefon" ya da adindan anlasilir. */
const telefonKolonu = (kolon: KolonMeta) =>
  kolon.bicim === 'telefon' || /telefon|ceptel|gsm|faks/i.test(kolon.ad);

export function bicimle(deger: unknown, kolon: KolonMeta): string {
  if (deger === null || deger === undefined) return '';
  // Telefon HER LISTEDE ayni bicimde (genel kural) - kolon tipi metin oldugu
  //   icin switch'e girmeden once yakalanir.
  if (telefonKolonu(kolon)) return telefonBicimle(deger);

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
