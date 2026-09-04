/**
 * MENUDE "EN SON" LISTESI (kullanici: "Favori'den sonra 'En Son' ekle, son 10
 * secilmis menu listelensin") - saf kural.
 *
 * Favoriler kullanicinin BILEREK isaretledikleri; bu liste kendiliginden
 * birikir. Kural kucuk ama uc kenari var (kopya, sinir, sirasi) ve menu
 * bileseninin icinde denenemiyordu.
 */

/** Listede tutulacak en fazla oge - menu serIdi uzamasin. */
export const EN_SON_SINIR = 10;

/**
 * Secilen yolu listenin BASINA yazar.
 *
 * Ayni yol ikinci kez secilirse KOPYA BIRIKMEZ, yukari tasinir - "son 10 farkli
 * ekran" isteniyor, "son 10 tiklama" degil. Zaten en ustteyse liste AYNEN
 * doner: her gezinmede yeni dizi uretmek gereksiz render ve gereksiz
 * localStorage yazimi demek.
 */
export function sonMenuEkle(liste: readonly string[], yol: string): readonly string[] {
  if (!yol) return liste;
  if (liste[0] === yol) return liste;
  return [yol, ...liste.filter(x => x !== yol)].slice(0, EN_SON_SINIR);
}

/**
 * Menude cizilecek "en son" yollari: FAVORIDEKILER ELENIR - iki liste ust uste
 * durdugu icin ayni satiri iki kez gostermek menuyu uzatmaktan baska ise
 * yaramaz.
 */
export function sonMenuGorunen(
  liste: readonly string[], favoriler: readonly string[],
): string[] {
  return liste.filter(y => !favoriler.includes(y));
}
