/**
 * ACR TI-RADS OTOMATİK HESAP (1218 paketi "TIROID-US", kullanıcı 01.11.2026: "TI-RADS otomatik hesaplamayı ekle").
 *
 * Puan SEÇENEK SIRASINDAN okunur (metin değişse de kırılmaz) - paket seçenek sıraları:
 *   kompozisyon  kistik 0 · süngerimsi 0 · mikst 1 · solid 2
 *   ekojenite    anekoik 0 · hiper/izo 1 · hipo 2 · belirgin hipo 3
 *   sekil        geniş > yüksek 0 · yüksek > geniş 3
 *   kenar        düzgün 0 · belirsiz 0 · lobüle / düzensiz 2 · tiroid dışı uzanım 3
 *   ekojen_odak  yok 0 · kuyruklu yıldız 0 · makro 1 · periferik 2 · punktat 3
 * Toplam: 0-1 TR1 · 2 TR2 · 3 TR3 · 4-6 TR4 · ≥7 TR5 (1 puan TR1 sayılır).
 * Öneri en büyük boyuttan (mm): TR3 İİAB ≥ 25 / takip ≥ 15 · TR4 ≥ 15 / ≥ 10 · TR5 ≥ 10 / ≥ 5; TR1-2 İİAB gerekmez.
 * Bileşenlerin BEŞİ de seçilmeden kategori yazılmaz; hekim sonucu elle değiştirebilir (son değişiklik bileşen değilse
 * hesap dokunmaz).
 */

export const TIRADS_BILESENLERI = ['kompozisyon', 'ekojenite', 'sekil', 'kenar', 'ekojen_odak'] as const;
const PUAN: Record<(typeof TIRADS_BILESENLERI)[number], number[]> = {
  kompozisyon: [0, 0, 1, 2],
  ekojenite: [0, 1, 2, 3],
  sekil: [0, 3],
  kenar: [0, 0, 2, 3],
  ekojen_odak: [0, 0, 1, 2, 3],
};

interface Alan { alanKod: string; secenekler?: string }
const secenekleri = (alanlar: Alan[], kod: string) => (alanlar.find(a => a.alanKod === kod)?.secenekler ?? '').split('|');

/** Toplam puan; bileşenlerden biri eksik ya da tanınmıyorsa null. */
export function tiradsPuani(alanlar: Alan[], degerler: Record<string, string>): number | null {
  let toplam = 0;
  for (const k of TIRADS_BILESENLERI) {
    const i = secenekleri(alanlar, k).indexOf(degerler[k] ?? '');
    const p = PUAN[k][i];
    if (i < 0 || p === undefined) return null;
    toplam += p;
  }
  return toplam;
}

/** Puandan kategori sırası (0 = TR1 ... 4 = TR5). */
export const tiradsKategorisi = (puan: number) => (puan <= 1 ? 0 : puan === 2 ? 1 : puan === 3 ? 2 : puan <= 6 ? 3 : 4);

/** "12x9x10", "12 x 9", "1,5 cm" -> en büyük boyut mm (cm verilirse çevrilir). */
export function enBuyukBoyutMm(metin: string | undefined): number | null {
  const s = String(metin ?? '').toLocaleLowerCase('tr').replace(',', '.');
  const sayilar = (s.match(/\d+(\.\d+)?/g) ?? []).map(Number).filter(n => n > 0);
  if (sayilar.length === 0) return null;
  const en = Math.max(...sayilar);
  return /cm/.test(s) ? en * 10 : en;
}

/** Öneri sırası: 0 İİAB gerekmez · 1 takip · 2 İİAB; boyut bilinmiyorsa null. */
export function tiradsOnerisi(kategori: number, boyutMm: number | null): number | null {
  if (kategori <= 1) return 0;
  if (boyutMm === null) return null;
  const [iiab, takip] = kategori === 2 ? [25, 15] : kategori === 3 ? [15, 10] : [10, 5];
  return boyutMm >= iiab ? 2 : boyutMm >= takip ? 1 : 0;
}

/**
 * Bir alan değişince TI-RADS kategori / öneri alanlarını yeniden yazar (yalnız değişen alan bileşen ya da boyutsa;
 * paket alanları yoksa hiçbir şey yapmaz). Dönen yeni değer haritası.
 */
export function tiradsUygula(alanlar: Alan[], degerler: Record<string, string>, degisen: string): Record<string, string> {
  if (!alanlar.some(a => a.alanKod === 'tirads')) return degerler;
  if (!(TIRADS_BILESENLERI as readonly string[]).includes(degisen) && degisen !== 'nodul_boyut') return degerler;
  const puan = tiradsPuani(alanlar, degerler);
  if (puan === null) return degerler;
  const kat = tiradsKategorisi(puan);
  const yeni: Record<string, string> = { ...degerler, tirads: secenekleri(alanlar, 'tirads')[kat] ?? degerler.tirads ?? '' };
  const oneri = tiradsOnerisi(kat, enBuyukBoyutMm(degerler.nodul_boyut));
  if (oneri !== null && alanlar.some(a => a.alanKod === 'oneri')) yeni.oneri = secenekleri(alanlar, 'oneri')[oneri] ?? yeni.oneri ?? '';
  return yeni;
}
