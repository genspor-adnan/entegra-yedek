/**
 * DİŞ KLİNİĞİ KOD → ETİKET SÖZLÜKLERİ (`labKodlari.ts` deseni).
 *
 * <b>Neden tek yerde:</b> protez iş türü ÜÇ dosyada ayrı yazılmıştı (lab
 * panosu, plan kartı, hasta kartı) ve hakediş kuralı ikisinde; aynı işin adı
 * ekranlar arasında ayrışmaya hazır bekliyordu. Lab aşaması iki ayrı sözlükte
 * iki amaçla duruyordu - kartta tam ad ("Geri gönderildi"), günlük akışta
 * kısa rozet ("labda") - ve <b>akış sözlüğü 9 (İptal) kodunu hiç tanımıyordu</b>:
 * iptal edilmiş lab işi günlük akışta boş rozet olarak görünüyordu.
 *
 * Çözüm: tek sözlük, iki görünüm (`kisa` / `ad`). Kod listesine yeni aşama
 * girdiğinde iki görünüm birlikte güncellenir.
 *
 * Metinler sunucudaki liste kataloğuyla (`KaynakKatalogu.Dis`:
 * `DisPlanDurumAdi`, `DisLabAsamaAdi`, `DisLabIsTuruAdi`) aynı tutulur - aynı
 * kaydın durumu gridde sunucudan, kartta buradan geliyor.
 *
 * Burada <b>iş kuralı yok</b>: planın onaya gidişi, lab işinin aşama sırası ve
 * hakediş hesabı sunucunun işidir.
 */

export interface DisKodAdi { kisa: string; ad: string }

const kisalar = (k: Record<number, DisKodAdi>) =>
  Object.fromEntries(Object.entries(k).map(([kod, v]) => [Number(kod), v.kisa])) as Record<number, string>;
const adlar = (k: Record<number, DisKodAdi>) =>
  Object.fromEntries(Object.entries(k).map(([kod, v]) => [Number(kod), v.ad])) as Record<number, string>;

/** `dis_lab_isemri.is_turu` — protez / apareyin türü. */
export const DIS_LAB_IS_TURU: Record<number, string> = {
  1: 'Kron', 2: 'Köprü', 3: 'İmplant üstü', 4: 'Total protez',
  5: 'Parsiyel protez', 6: 'Ortodonti apareyi', 7: 'Gece plağı', 8: 'Diğer',
};

/** `dis_lab_isemri.olcu_tipi`. */
export const DIS_OLCU_TIPI: Record<number, string> = {
  1: 'Geleneksel', 2: 'Dijital tarama',
};

/**
 * `dis_lab_isemri.asama`. Kısa biçim GÜNLÜK AKIŞ rozeti içindir: orada satır
 * başına bir kelime yer var ve hekimin sorusu "işi labda mı" - aşamanın
 * hangisi olduğu kartta okunuyor.
 */
const LAB_ASAMA: Record<number, DisKodAdi> = {
  1: { kisa: 'ölçü', ad: 'Ölçü bekliyor' },
  2: { kisa: 'labda', ad: 'Gönderildi' },
  3: { kisa: 'labda', ad: 'Tasarım onayı' },
  4: { kisa: 'labda', ad: 'Üretim' },
  5: { kisa: 'lab ✔ geldi', ad: 'Geldi' },
  6: { kisa: 'prova', ad: 'Prova' },
  7: { kisa: 'labda', ad: 'Geri gönderildi' },
  8: { kisa: 'teslim', ad: 'Teslim edildi' },
  9: { kisa: 'iptal', ad: 'İptal' },
};
export const DIS_LAB_ASAMA = adlar(LAB_ASAMA);
export const DIS_LAB_ASAMA_KISA = kisalar(LAB_ASAMA);

/**
 * `dis_plan.durum`. Günlük akışta onaylı ve sürüyor AYNI rozeti taşır
 * ("Plan onaylı"): akışta soru "plan hazır mı", kaçıncı seansta olduğu yanında
 * yazan sayaçtan okunuyor. Kartta ikisi ayrı görünür.
 */
const PLAN_DURUM: Record<number, DisKodAdi> = {
  1: { kisa: 'Taslak', ad: 'Taslak' },
  2: { kisa: 'Proforma bekliyor', ad: 'Sunuldu' },
  3: { kisa: 'Plan onaylı', ad: 'Onaylı' },
  4: { kisa: 'Plan onaylı', ad: 'Sürüyor' },
  5: { kisa: 'Tamamlandı', ad: 'Tamamlandı' },
  6: { kisa: 'İptal', ad: 'İptal' },
  7: { kisa: 'Süresi doldu', ad: 'Süresi doldu' },
};
export const DIS_PLAN_DURUM = adlar(PLAN_DURUM);
export const DIS_PLAN_DURUM_KISA = kisalar(PLAN_DURUM);

/** `dis_plan_satir.ucret_kurali` — hakedişin hangi anda doğduğu. */
export const DIS_HAKEDIS_KURAL: Record<number, string> = {
  1: 'Tamamlanınca', 2: 'Seans başına oran', 3: 'Adet',
};
