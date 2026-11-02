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
  /** Hizmet kartında "yön zorunlu" (1229): kabulde sağ / sol / bilateral sorulur. */
  yonZorunlu?: number;
  /** Yönlü SUT kodunun sabit yönü (1230) - seçim kilitli gelir. */
  sabitYon?: number;
  /** Yön ailesinde (1232) Bakanlık kodu olan yönler ("1,2"); boş = sınır yok. */
  yonlar?: string;
}

export interface Hekim { id: number; ad: string; bolumAdi: string }

export interface Gecmis { hizmetId: number; tetkikAdi: string; tarih: string }

/** Secili tetkik: listedeki tetkik + isteme ozel secimler. */
export interface Secim {
  tetkik: Tetkik; oncelik: number; kontrast: number;
  /** 1229: 0 yok · 1 sağ · 2 sol · 3 bilateral. */
  yon?: number;
  /** 1229: dışarıdan gelen hastanın accession no'su - boşsa şube şablonundan üretilir. */
  accessionNo?: string;
}

/** Tetkik yönü seçenekleri (1229; eski HBYS PARA.YON ile aynı kodlar). */
export const YONLER = [{ deger: 0, ad: '—' }, { deger: 1, ad: 'Sağ' }, { deger: 2, ad: 'Sol' }, { deger: 3, ad: 'Bilateral' }];

/** Hizmetin seçilebilen yönleri (1232 yön ailesi "1,2" süzgeci; boşsa hepsi). Seçili değer listede kalır. */
export const yonSecenekleri = (yonlar?: string, secili?: number) => {
  const izin = (yonlar ?? '').split(',').filter(Boolean).map(Number);
  return izin.length ? YONLER.filter(o => o.deger === 0 || izin.includes(o.deger) || o.deger === secili) : YONLER;
};

/**
 * Kalem fiyati (mockup radyoloji_kayit_kabul: Liste / Indirim / Tutar).
 * Sunucudaki kuralin AYNISI (liste -> kampanya) - kabul masasi tutari
 * kaydetmeden once gormeli, hastaya soylenen rakam faturayla tutmali.
 */
export interface KalemFiyati { liste: number; tutar: number; kdv: number }
