/**
 * FLEISCHNER 2017 OTOMATİK ÖNERİ (1220 paketi "TORAKS-FLEISCHNER" + 1221, kullanıcı 01.11.2026: "Fleischner otomatik
 * hesaplamayı ekle"). 35 yaş üstü, insidental nodül; tarama / kanser öyküsü / bağışıklık baskılanmasında kriter
 * uygulanmaz (hekim o seçeneği elle seçer).
 *
 * Girdi alanları (seçenek SIRASIYLA okunur): nodul (Yok · Tek · Multiple), nodul_tip (Solid · Parsiyel solid ·
 * Saf buzlu cam), nodul_cap (mm, ortalama çap), solid_komp (mm), risk (Düşük · Yüksek). Öneri seçenek sırası (1221):
 *   0 rutin takip yok · 1 12. ayda isteğe bağlı BT · 2 6-12. ay, sonra 18-24. ay · 3 3-6. ay, sonra 18-24. ay ·
 *   4 3. ayda BT / PET-BT / biyopsi · 5 GGN 6-12. ay, 5 yıla kadar 2 yılda bir · 6 parsiyel solid 3-6. ay, 5 yıl yıllık ·
 *   7 kriter uygulanmaz · 8 çoklu subsolid < 6 mm · 9 çoklu subsolid ≥ 6 mm.
 *
 * SOLİD    tek:     < 6 düşük 0 / yüksek 1 · 6-8 → 2 · > 8 → 4
 *          çoklu:   < 6 düşük 0 / yüksek 1 · ≥ 6 → 3
 * SUBSOLİD tek GGN: < 6 → 0 · ≥ 6 → 5
 *          tek parsiyel solid: < 6 → 0 · ≥ 6 → 6 (solid komponent ≥ 6 mm → 4, yüksek şüphe)
 *          çoklu:   < 6 → 8 · ≥ 6 → 9
 * Gerekli girdi eksikse (ör. küçük solid nodülde risk grubu) öneri yazılmaz. Hekim seçimi elle değiştirebilir; yalnız
 * girdi alanlarından biri değişince yeniden hesaplanır.
 */

export const FLEISCHNER_GIRDILERI = ['nodul', 'nodul_tip', 'nodul_cap', 'solid_komp', 'risk'] as const;

interface Alan { alanKod: string; secenekler?: string }
const secenekleri = (alanlar: Alan[], kod: string) => (alanlar.find(a => a.alanKod === kod)?.secenekler ?? '').split('|');
const sira = (alanlar: Alan[], d: Record<string, string>, kod: string) => secenekleri(alanlar, kod).indexOf(d[kod] ?? '');
const mm = (v: string | undefined) => {
  const n = Number(String(v ?? '').replace(',', '.').replace(/[^\d.]/g, ''));
  return String(v ?? '').trim() !== '' && Number.isFinite(n) && n > 0 ? n : null;
};

/** Öneri seçenek sırası; hesaplanamıyorsa null. */
export function fleischnerOnerisi(alanlar: Alan[], d: Record<string, string>): number | null {
  const sayi = sira(alanlar, d, 'nodul');          // 1 tek · 2 çoklu (0 yok)
  const tip = sira(alanlar, d, 'nodul_tip');       // 0 solid · 1 parsiyel solid · 2 buzlu cam
  const cap = mm(d.nodul_cap);
  if (sayi < 1 || tip < 0 || cap === null) return null;
  const coklu = sayi === 2;
  if (tip === 0) {
    if (cap < 6) {
      const risk = sira(alanlar, d, 'risk');     // 0 düşük · 1 yüksek
      return risk < 0 ? null : risk === 0 ? 0 : 1;
    }
    if (coklu) return 3;
    return cap <= 8 ? 2 : 4;
  }
  if (coklu) return cap < 6 ? 8 : 9;
  if (cap < 6) return 0;
  if (tip === 2) return 5;
  const solid = mm(d.solid_komp);
  return solid !== null && solid >= 6 ? 4 : 6;
}

/** Girdi alanı değişince öneriyi yeniden yazar (paket yoksa / hesaplanamazsa dokunmaz). */
export function fleischnerUygula(alanlar: Alan[], degerler: Record<string, string>, degisen: string): Record<string, string> {
  if (!alanlar.some(a => a.alanKod === 'fleischner')) return degerler;
  if (!(FLEISCHNER_GIRDILERI as readonly string[]).includes(degisen)) return degerler;
  const i = fleischnerOnerisi(alanlar, degerler);
  const secenek = i === null ? undefined : secenekleri(alanlar, 'fleischner')[i];
  return secenek ? { ...degerler, fleischner: secenek } : degerler;
}
