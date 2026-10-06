import type { MenuDuzenSatiri } from '../../api/sozlesme';

/**
 * MENÜ DÜZENİ FARKININ KODA GÖRE HARİTASI (979).
 *
 * Ayrı dosyada: `menuDuzeni.ts` menü ağacının tiplerini (`menuAgaci`) alıyor,
 * o da `Liste`ye bağlı - yetki matrisi gibi menü dışı bir ekran oradan tek bir
 * yardımcı için import edince `api → sayfalar → Liste → api` döngüsü oluşuyordu
 * (donguselImport testi). Bu dosyanın menü koduna hiç bağı yok.
 */
export function duzenHaritasi(satirlar: MenuDuzenSatiri[] | null | undefined) {
  const h = new Map<string, MenuDuzenSatiri>();
  for (const s of satirlar ?? []) h.set(s.sistemKod, s);
  return h;
}
