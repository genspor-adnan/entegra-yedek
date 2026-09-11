/**
 * RADYOLOJI ISTEM EKRANININ ORTAK TIPLERI.
 *
 * `IstemModali` govdesinden ayrildi: ayni tipleri hem modal hem de secim /
 * fiyatlandirma kancasi kullaniyor.
 */

export interface Tetkik {
  id: number; kod: string; ad: string; modalite: number;
  modaliteAdi: string; kdv: number;
  /** Tetkikin protokol hazirligi, yoksa modalite varsayilani (311). */
  hazirlik?: string;
  /** Cekim protokolunden (314): personele uyari ve varsayilan kontrast. */
  ozelUyari?: string; varsayilanKontrast?: number; sureDk?: number;
}

export interface Hekim { id: number; ad: string; bolumAdi: string }

export interface Gecmis { hizmetId: number; tetkikAdi: string; tarih: string }

/** Secili tetkik: listedeki tetkik + isteme ozel secimler. */
export interface Secim { tetkik: Tetkik; oncelik: number; kontrast: number }

/**
 * Kalem fiyati (mockup radyoloji_kayit_kabul: Liste / Indirim / Tutar).
 * Sunucudaki kuralin AYNISI (liste -> kampanya) - kabul masasi tutari
 * kaydetmeden once gormeli, hastaya soylenen rakam faturayla tutmali.
 */
export interface KalemFiyati { liste: number; tutar: number; kdv: number }
