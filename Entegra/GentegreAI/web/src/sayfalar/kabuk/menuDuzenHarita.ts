import type { MenuDuzenSatiri } from '../../api/sozlesme';

/**
 * MENÜ DÜZENİ FARKININ HARİTASI (979).
 *
 * Ayrı dosyada: `menuDuzeni.ts` menü ağacının tiplerini (`menuAgaci`) alıyor,
 * o da `Liste`ye bağlı - yetki matrisi gibi menü dışı bir ekran oradan tek bir
 * yardımcı için import edince `api → sayfalar → Liste → api` döngüsü oluşuyordu
 * (donguselImport testi). Bu dosyanın menü koduna hiç bağı yok.
 *
 * <b>ANAHTAR TÜR + KOD</b> (kullanıcı 07.10.2026: *"aktif bölgede yönetim bölge
 * altında yönetim grup yok ama ana menüde var"*): "Yönetim" hem bir BÖLGE hem
 * bir GRUP adı. Harita yalnız `sistemKod` ile kurulduğunda ikisi tek satıra
 * düşüyordu - bölgenin kaydı grubun kaydıymış gibi okunuyor, grup düzenleme
 * ağacından kayboluyordu. `dugum_tur` veritabanında zaten ayrı bir alan;
 * eşleşme de ikisini birlikte kullanır.
 */
export const DUGUM = { bolge: 1, grup: 2, altBaslik: 3, ekran: 4 } as const;

export type DuzenHaritasi = {
  /** Tür + kod ile satır; tür verilmezse ekran (4) varsayılır. */
  bul(kod: string, dugumTur?: number): MenuDuzenSatiri | undefined;
  boyut: number;
};

export function duzenHaritasi(satirlar: MenuDuzenSatiri[] | null | undefined): DuzenHaritasi {
  const h = new Map<string, MenuDuzenSatiri>();
  for (const s of satirlar ?? []) h.set(`${s.dugumTur}|${s.sistemKod}`, s);
  return {
    bul: (kod, dugumTur = DUGUM.ekran) => h.get(`${dugumTur}|${kod}`),
    boyut: h.size,
  };
}
