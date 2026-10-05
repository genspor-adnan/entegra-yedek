/**
 * ACİL SERVİS KOD SÖZLÜKLERİ (istemci).
 *
 * Sunucudaki karşılığı <c>Gentegre.Cekirdek/Katalog/AcilKodlari.cs</c>:
 * liste kolonları ve kart alanları metinleri ORADAN alıyor, bu dosya da aynı
 * metinleri tutuyor. Acil kodları için veritabanında kod listesi yok
 * (<c>kod_liste</c>'de <c>acil.*</c> satırı yok), bu yüzden iki tarafta
 * birer sözlük var - ama her tarafta <b>bir</b> tane.
 *
 * <b>Düzeltilen ayrışma:</b> çıkış şekli üç yerde yazılıydı (liste kataloğu,
 * kart kataloğu, bu ekranın çıkış penceresi) ve metinler farklıydı - "Sevk"
 * ile "Sevk (başka kuruma)", "Kendi isteğiyle" ile "Kendi isteğiyle ayrıldı".
 * Gridde sütun dar olduğu için KISA ad sunucuda ayrı tutulur; pencerede tam
 * ad yazılır (hekim neyi seçtiğini okumalı).
 *
 * Triyaj düzeyi de burada: sayı BÜYÜDÜKÇE aciliyet AZALIR (1 = kırmızı).
 * Düşürme ayrı yetki ister ve gerekçe zorunludur - o kural sunucuda
 * (<c>AcilUclari</c>), burada yalnız etiket var.
 */

export interface AcilKod { kod: number; ad: string }

/** `acil_basvuru.triyaj` — seçim listesi (numara + renk + açıklama). */
export const ACIL_TRIYAJ: AcilKod[] = [
  { kod: 1, ad: '1 · Kırmızı (resüsitasyon)' },
  { kod: 2, ad: '2 · Turuncu (acil)' },
  { kod: 3, ad: '3 · Sarı (acele)' },
  { kod: 4, ad: '4 · Yeşil (az acil)' },
  { kod: 5, ad: '5 · Mavi (acil değil)' },
];

/** Triyajın renk adı - rozet / çip metni (dar yer). */
export const ACIL_TRIYAJ_RENK: Record<number, string> = {
  0: 'Triyaj bekliyor', 1: 'Kırmızı', 2: 'Turuncu', 3: 'Sarı', 4: 'Yeşil', 5: 'Mavi',
};

/** `acil_basvuru.cikis_sekli` — çıkış penceresinde TAM ad gösterilir. */
export const ACIL_CIKIS_SEKLI: AcilKod[] = [
  { kod: 1, ad: 'Taburcu' },
  { kod: 2, ad: 'Servise yatış' },
  { kod: 3, ad: 'Yoğun bakım' },
  { kod: 4, ad: 'Sevk (başka kuruma)' },
  { kod: 5, ad: 'Ölüm' },
  { kod: 6, ad: 'Kendi isteğiyle ayrıldı' },
  { kod: 7, ad: 'Ameliyathane' },
];

/** `acil_cagri.tur` — konsültasyon ve renk kodları. */
export const ACIL_CAGRI_TURU: AcilKod[] = [
  { kod: 1, ad: 'Konsültasyon' },
  { kod: 2, ad: 'Mavi Kod' },
  { kod: 3, ad: 'Beyaz Kod' },
  { kod: 4, ad: 'Pembe Kod' },
  { kod: 5, ad: 'Kateter Lab' },
  { kod: 6, ad: 'Ameliyathane' },
  { kod: 7, ad: 'Yoğun Bakım' },
];

/** Soru penceresi (`listeSor`) kod'u metin bekliyor. */
export const secenekler = (l: AcilKod[]): { kod: string; ad: string }[] =>
  l.map(x => ({ kod: String(x.kod), ad: x.ad }));
