import { describe, expect, it } from 'vitest';
import { erteleSecenekleri, hizliZamanlar, kalanMetni, kisaZaman, zilSayisi } from '../bilesenler/hatirlatma/hatirlatmaDeposu';
import type { Hatirlatma } from '../api/uclar/hatirlatma';

/** KİŞİSEL HATIRLATICI (1139) - istemci zaman yardımcıları (yerel saatle). */
const yerel = (a: number, g: number, s = 9, d = 0) => new Date(2026, a - 1, g, s, d, 0, 0);
const PERSEMBE = yerel(10, 22, 10);   // 22.10.2026 Perşembe 10:00

describe('hizliZamanlar', () => {
  it('perşembe sabah: 15 dk, 1 saat, bu akşam, yarın sabah, pazartesi, 1 hafta', () => {
    const z = hizliZamanlar(PERSEMBE);
    expect(z.map(x => x.ad)).toEqual(['15 dk sonra', '1 saat sonra', 'Bu akşam', 'Yarın sabah', 'Pazartesi', '1 hafta sonra']);
    expect(z[0].zaman).toEqual(yerel(10, 22, 10, 15));
    expect(z[2].zaman).toEqual(yerel(10, 22, 18));
    expect(z[3].zaman).toEqual(yerel(10, 23, 9));
    expect(z[4].zaman).toEqual(yerel(10, 26, 9));
    expect(z[5].zaman).toEqual(yerel(10, 29, 9));
  });

  it('akşam 17:00 sonrası "Bu akşam" yok; pazartesi günü "Pazartesi" bir sonraki haftadır', () => {
    expect(hizliZamanlar(yerel(10, 22, 17, 30)).map(x => x.ad)).not.toContain('Bu akşam');
    const pzt = hizliZamanlar(yerel(10, 26, 10)).find(x => x.ad === 'Pazartesi')!;
    expect(pzt.zaman).toEqual(yerel(11, 2, 9));
  });

  it('saniye ve salise sıfırlanır (dakika hassasiyeti)', () => {
    const z = hizliZamanlar(new Date(2026, 9, 22, 10, 7, 41, 500));
    expect(z[0].zaman.getSeconds()).toBe(0);
    expect(z[0].zaman.getMilliseconds()).toBe(0);
  });
});

describe('erteleSecenekleri', () => {
  it('dakikalı seçenekler ve yarın 09:00 yerel metni', () => {
    const e = erteleSecenekleri(PERSEMBE);
    expect(e.filter(x => x.dakika).map(x => x.dakika)).toEqual([10, 30, 60]);
    expect(e.find(x => x.ad === 'Yarın 09:00')?.zaman).toBe('2026-10-23T09:00');
    expect(e.find(x => x.ad === 'Pazartesi 09:00')?.zaman).toBe('2026-10-26T09:00');
  });
});

describe('kalanMetni', () => {
  const simdi = PERSEMBE.getTime();
  it('gecikme dakika / saat / gün', () => {
    expect(kalanMetni(yerel(10, 22, 9, 30).toISOString(), simdi)).toEqual({ metin: '30 dk gecikti', sinif: 'kir' });
    expect(kalanMetni(yerel(10, 21, 16).toISOString(), simdi)).toEqual({ metin: '18 sa gecikti', sinif: 'kir' });
    expect(kalanMetni(yerel(10, 19, 10).toISOString(), simdi).metin).toBe('3 gün gecikti');
  });
  it('bugün: şimdi / dk sonra / bugün; yarın; N gün', () => {
    expect(kalanMetni(yerel(10, 22, 10).toISOString(), simdi).metin).toBe('şimdi');
    expect(kalanMetni(yerel(10, 22, 10, 25).toISOString(), simdi)).toEqual({ metin: '25 dk sonra', sinif: 'sari' });
    expect(kalanMetni(yerel(10, 22, 16).toISOString(), simdi)).toEqual({ metin: 'bugün', sinif: 'mavi' });
    expect(kalanMetni(yerel(10, 23, 9).toISOString(), simdi).metin).toBe('yarın');
    expect(kalanMetni(yerel(10, 28, 8).toISOString(), simdi).metin).toBe('6 gün');
  });
});

describe('zilSayisi', () => {
  const h = (zaman: Date, uyari: Date) => ({ zaman: zaman.toISOString(), uyariZamani: uyari.toISOString() }) as Hatirlatma;
  it('gecikmiş + uyarı anı gelmiş + bir saat içindekiler sayılır, uzaktakiler sayılmaz', () => {
    const simdi = PERSEMBE.getTime();
    const l = [
      h(yerel(10, 22, 9), yerel(10, 22, 9)),            // gecikmiş
      h(yerel(10, 22, 10, 40), yerel(10, 22, 10, 40)),  // 40 dk sonra
      h(yerel(10, 22, 15), yerel(10, 22, 9, 45)),       // uyarısı geldi (5 sa önceden)
      h(yerel(10, 22, 15), yerel(10, 22, 14, 45)),      // uzak
      h(yerel(10, 23, 9), yerel(10, 23, 9)),            // yarın
    ];
    expect(zilSayisi(l, simdi)).toBe(3);
  });
});

describe('kisaZaman', () => {
  it('bugün yalnız saat, başka gün gün.ay saat', () => {
    expect(kisaZaman(yerel(10, 22, 15, 5), PERSEMBE)).toBe('15:05');
    expect(kisaZaman(yerel(10, 23, 9), PERSEMBE)).toBe('23.10 09:00');
  });
});
