/**
 * OBSTETRİK USG OTOMATİK HESAP (1379 paketi "OBSTETRIK-US", kullanıcı 18.11.2026: "1, 2 ve 3'ü yap").
 *
 * TAHMİNİ FETAL AĞIRLIK - Hadlock 1985 (ölçüler cm, sonuç gram). Hangi ölçüler girildiyse en çok bileşenli formül:
 *   HC + AC + FL : log10(EFW) = 1.326 - 0.00326·AC·FL + 0.0107·HC + 0.0438·AC + 0.158·FL
 *   BPD + AC + FL: log10(EFW) = 1.335 - 0.0034·AC·FL + 0.0316·BPD + 0.0457·AC + 0.1623·FL
 *   AC + FL      : log10(EFW) = 1.304 + 0.05281·AC + 0.1938·FL - 0.004·AC·FL
 * Paket alanları mm'dir; hesapta cm'ye çevrilir. Persentil HEKİM seçimidir (büyüme eğrisi kuruma göre değişir).
 *
 * AMNİYON SIVISI - ACOG eşikleri: AFI <= 5 cm ya da en derin cep < 2 cm -> oligohidramnios; AFI >= 24 cm ya da en
 *   derin cep >= 8 cm -> polihidramnios; ikisinden biri girilmişse ve eşik yoksa normal. Değerlendirme seçenek
 *   SIRASIYLA yazılır (0 Normal · 1 Oligohidramnios · 2 Polihidramnios).
 *
 * Yalnız girdi alanı değişince yeniden yazılır; hekim sonucu elle değiştirebilir (TI-RADS / Fleischner deseni).
 */

interface Alan { alanKod: string; secenekler?: string }
const secenekleri = (alanlar: Alan[], kod: string) => (alanlar.find(a => a.alanKod === kod)?.secenekler ?? '').split('|');
const sayi = (v: string | undefined) => {
  const s = String(v ?? '').trim().replace(',', '.');
  const n = Number(s.replace(/[^\d.]/g, ''));
  return s !== '' && Number.isFinite(n) && n > 0 ? n : null;
};

export const BIYOMETRI = ['bpd', 'hc', 'ac', 'fl'] as const;

/** Hadlock tahmini fetal ağırlık (g, tam sayı); ölçüler mm. AC ve FL yoksa null. */
export function hadlockAgirlik(d: { bpd?: number | null; hc?: number | null; ac?: number | null; fl?: number | null }): number | null {
  const cm = (v?: number | null) => (v == null ? null : v / 10);
  const [bpd, hc, ac, fl] = [cm(d.bpd), cm(d.hc), cm(d.ac), cm(d.fl)];
  if (ac === null || fl === null) return null;
  const log = hc !== null
    ? 1.326 - 0.00326 * ac * fl + 0.0107 * hc + 0.0438 * ac + 0.158 * fl
    : bpd !== null
      ? 1.335 - 0.0034 * ac * fl + 0.0316 * bpd + 0.0457 * ac + 0.1623 * fl
      : 1.304 + 0.05281 * ac + 0.1938 * fl - 0.004 * ac * fl;
  return Math.round(10 ** log);
}

/** Amniyon değerlendirmesi: 0 normal · 1 oligo · 2 poli; ikisi de yoksa null. */
export function amniyonSinifi(afiCm: number | null, sdpCm: number | null): number | null {
  if (afiCm === null && sdpCm === null) return null;
  if ((afiCm !== null && afiCm <= 5) || (sdpCm !== null && sdpCm < 2)) return 1;
  if ((afiCm !== null && afiCm >= 24) || (sdpCm !== null && sdpCm >= 8)) return 2;
  return 0;
}

export function obstetrikUygula(alanlar: Alan[], degerler: Record<string, string>, degisen: string): Record<string, string> {
  let yeni = degerler;
  if (alanlar.some(a => a.alanKod === 'efw') && (BIYOMETRI as readonly string[]).includes(degisen)) {
    const g = hadlockAgirlik({ bpd: sayi(degerler.bpd), hc: sayi(degerler.hc), ac: sayi(degerler.ac), fl: sayi(degerler.fl) });
    if (g !== null) yeni = { ...yeni, efw: String(g) };
  }
  if (alanlar.some(a => a.alanKod === 'amniyon') && (degisen === 'afi' || degisen === 'sdp')) {
    const i = amniyonSinifi(sayi(degerler.afi), sayi(degerler.sdp));
    const secenek = i === null ? undefined : secenekleri(alanlar, 'amniyon')[i];
    if (secenek) yeni = { ...yeni, amniyon: secenek };
  }
  return yeni;
}
