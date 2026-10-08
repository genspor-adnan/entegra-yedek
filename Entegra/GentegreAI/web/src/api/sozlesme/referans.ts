/** API sozlesmesi - referans. Alan adlari sunucuyla birebir. */

// -------------------------------------------------------------- referans ----
/** Il/Ilce/Ulke (039_il_ilce_ulke.sql) - Adresler grid'inde il->ilce cascading secim. */
export interface YerlerYaniti {
  iller: { id: number; ad: string }[];
  ilceler: { id: number; ilId: number; ad: string }[];
  /** `skrsKod` = SKRS MERNIS kodu (617). Adres ülke ADINI saklar,
   *  uyruk ise bu KODU - e-Nabız uyrukta MERNİS kodu istiyor. */
  ulkeler: { id: number; ad: string; skrsKod: number | null }[];
}
