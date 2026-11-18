/**
 * PI-RADS v2.1 OTOMATİK HESAP (1380 paketi "PROSTAT-PIRADS", kullanıcı 18.11.2026: "4 ve 5'e geç").
 *
 * KATEGORİ (seçenek SIRASIYLA okunur - zon: 0 periferik · 1 transizyonel; t2 / dwi: 1-5; dce: 0 negatif · 1 pozitif):
 *   Periferik zon   : belirleyici DWI. DWI 3 + DCE pozitif -> 4; diğerleri DWI skorudur (DWI 3'te DCE bilinmiyorsa yok).
 *   Transizyonel zon: belirleyici T2. T2 3 + DWI 5 -> 4; T2 2 + DWI >= 4 -> 3 (v2.1); T2 1 / 4 / 5 -> T2 skoru.
 *     T2 2 ve 3'te DWI girilmeden kategori yazılmaz.
 * HACİM  : elipsoid = AP x TR x KK (mm) x 0,52 / 1000 -> mL (bir ondalık).
 * PSA YOĞUNLUĞU: PSA / hacim (iki ondalık).
 * Yalnız girdi değişince yeniden yazılır; hekim sonucu elle değiştirebilir (TI-RADS deseni).
 */

interface Alan { alanKod: string; secenekler?: string }
const secenekleri = (alanlar: Alan[], kod: string) => (alanlar.find(a => a.alanKod === kod)?.secenekler ?? '').split('|');
const sira = (alanlar: Alan[], d: Record<string, string>, kod: string) => secenekleri(alanlar, kod).indexOf(d[kod] ?? '');
const sayi = (v: string | undefined) => {
  const s = String(v ?? '').trim().replace(',', '.');
  const n = Number(s.replace(/[^\d.]/g, ''));
  return s !== '' && Number.isFinite(n) && n > 0 ? n : null;
};
const yaz = (n: number, ondalik: number) => n.toFixed(ondalik).replace('.', ',');

export const PIRADS_GIRDILERI = ['zon', 't2', 'dwi', 'dce'] as const;

/** Kategori 1-5; hesaplanamazsa null. zon 0 PZ / 1 TZ; t2, dwi 1-5 (yoksa null); dce 0 / 1 (yoksa null). */
export function piradsKategorisi(zon: number, t2: number | null, dwi: number | null, dce: number | null): number | null {
  if (zon === 0) {
    if (dwi === null) return null;
    if (dwi === 3) return dce === null ? null : dce === 1 ? 4 : 3;
    return dwi;
  }
  if (zon === 1) {
    if (t2 === null) return null;
    if (t2 === 2 || t2 === 3) {
      if (dwi === null) return null;
      if (t2 === 3) return dwi === 5 ? 4 : 3;
      return dwi >= 4 ? 3 : 2;
    }
    return t2;
  }
  return null;
}

/** "45x38x40", "45 x 38 x 40 mm", "4,5x3,8x4 cm" -> mL (elipsoid); üç boyut yoksa null. */
export function prostatHacmi(metin: string | undefined): number | null {
  const s = String(metin ?? '').toLocaleLowerCase('tr').replace(/,/g, '.');
  const b = (s.match(/\d+(\.\d+)?/g) ?? []).map(Number).filter(n => n > 0);
  if (b.length < 3) return null;
  const mm = /cm/.test(s) ? b.slice(0, 3).map(x => x * 10) : b.slice(0, 3);
  return Math.round(mm[0] * mm[1] * mm[2] * 0.52 / 1000 * 10) / 10;
}

export function piradsUygula(alanlar: Alan[], degerler: Record<string, string>, degisen: string): Record<string, string> {
  let yeni = degerler;
  if (alanlar.some(a => a.alanKod === 'prostat_hacim') && degisen === 'prostat_boyut') {
    const h = prostatHacmi(degerler.prostat_boyut);
    if (h !== null) yeni = { ...yeni, prostat_hacim: yaz(h, 1) };
  }
  if (alanlar.some(a => a.alanKod === 'psad') && ['prostat_boyut', 'prostat_hacim', 'psa'].includes(degisen)) {
    const psa = sayi(yeni.psa), hacim = sayi(yeni.prostat_hacim);
    if (psa !== null && hacim !== null) yeni = { ...yeni, psad: yaz(Math.round(psa / hacim * 100) / 100, 2) };
  }
  if (alanlar.some(a => a.alanKod === 'pirads') && (PIRADS_GIRDILERI as readonly string[]).includes(degisen)) {
    const skor = (kod: string) => { const i = sira(alanlar, yeni, kod); return i < 0 ? null : i + 1 };
    const dce = sira(alanlar, yeni, 'dce');
    const k = piradsKategorisi(sira(alanlar, yeni, 'zon'), skor('t2'), skor('dwi'), dce < 0 ? null : dce);
    const secenek = k === null ? undefined : secenekleri(alanlar, 'pirads')[k - 1];
    if (secenek) yeni = { ...yeni, pirads: secenek };
  }
  return yeni;
}
