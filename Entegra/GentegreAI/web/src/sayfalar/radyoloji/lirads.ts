/**
 * LI-RADS v2018 (BT / MR) OTOMATİK HESAP (1380 paketi "KARACIGER-LIRADS", kullanıcı 18.11.2026: "4 ve 5'e geç").
 *
 * TANI TABLOSU - ek majör bulgu = non-periferik washout + kontrastlanan kapsül + eşik büyüme sayısı:
 *                         APHE yok            |            non-rim APHE var
 *   ek bulgu        < 20 mm    >= 20 mm       |  < 10 mm    10-19 mm                         >= 20 mm
 *   0               LR-3       LR-3           |  LR-3       LR-3                             LR-4
 *   1               LR-3       LR-4           |  LR-4       kapsül -> LR-4 · washout / büyüme -> LR-5   LR-5
 *   >= 2            LR-4       LR-4           |  LR-4       LR-5                             LR-5
 * ÖZEL KATEGORİ (hekim): LR-1 / LR-2 / LR-M / LR-TIV / LR-NC seçiliyse tablo yerine o yazılır.
 * Yardımcı bulgularla ±1 düzeltme hekimin elle seçimidir (son değişiklik girdi değilse hesap dokunmaz).
 * Kategori alanı seçenek sırası: 0 LR-1 · 1 LR-2 · 2 LR-3 · 3 LR-4 · 4 LR-5 · 5 LR-M · 6 LR-TIV · 7 LR-NC.
 */

interface Alan { alanKod: string; secenekler?: string }
const secenekleri = (alanlar: Alan[], kod: string) => (alanlar.find(a => a.alanKod === kod)?.secenekler ?? '').split('|');
const sira = (alanlar: Alan[], d: Record<string, string>, kod: string) => secenekleri(alanlar, kod).indexOf(d[kod] ?? '');
const mm = (v: string | undefined) => {
  const s = String(v ?? '').trim().replace(',', '.');
  const n = Number(s.replace(/[^\d.]/g, ''));
  return s !== '' && Number.isFinite(n) && n > 0 ? n : null;
};

export const LIRADS_GIRDILERI = ['aphe', 'lezyon_cap', 'washout', 'kapsul', 'buyume', 'ozel'] as const;

/** Tablo kategorisi 3 / 4 / 5. */
export function liradsTablosu(aphe: boolean, capMm: number, washout: boolean, kapsul: boolean, buyume: boolean): number {
  const ek = Number(washout) + Number(kapsul) + Number(buyume);
  if (!aphe) return capMm < 20 ? (ek >= 2 ? 4 : 3) : (ek >= 1 ? 4 : 3);
  if (capMm < 10) return ek >= 1 ? 4 : 3;
  if (capMm < 20) {
    if (ek === 0) return 3;
    if (ek >= 2) return 5;
    return washout || buyume ? 5 : 4;            // tek bulgu: yalnız kapsül -> LR-4
  }
  return ek >= 1 ? 5 : 4;
}

/** Özel kategori sırası (ozel alanı: 0 yok · 1 LR-1 · 2 LR-2 · 3 LR-M · 4 LR-TIV · 5 LR-NC) -> kategori alanı sırası. */
const OZEL_HEDEF = [null, 0, 1, 5, 6, 7] as const;

/** Kategori alanının seçenek sırası; hesaplanamazsa null (APHE ya da çap yok). */
export function liradsSirasi(alanlar: Alan[], d: Record<string, string>): number | null {
  const ozel = sira(alanlar, d, 'ozel');
  if (ozel > 0) return OZEL_HEDEF[ozel] ?? null;
  const aphe = sira(alanlar, d, 'aphe');
  const cap = mm(d.lezyon_cap);
  if (aphe < 0 || cap === null) return null;
  const var_ = (kod: string) => sira(alanlar, d, kod) === 1;
  return liradsTablosu(aphe === 1, cap, var_('washout'), var_('kapsul'), var_('buyume')) - 1;
}

export function liradsUygula(alanlar: Alan[], degerler: Record<string, string>, degisen: string): Record<string, string> {
  if (!alanlar.some(a => a.alanKod === 'lirads')) return degerler;
  if (!(LIRADS_GIRDILERI as readonly string[]).includes(degisen)) return degerler;
  const i = liradsSirasi(alanlar, degerler);
  const secenek = i === null ? undefined : secenekleri(alanlar, 'lirads')[i];
  return secenek ? { ...degerler, lirads: secenek } : degerler;
}
