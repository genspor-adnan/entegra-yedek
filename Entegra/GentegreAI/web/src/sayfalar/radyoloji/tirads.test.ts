import { describe, expect, it } from 'vitest';
import { enBuyukBoyutMm, tiradsKategorisi, tiradsOnerisi, tiradsPuani, tiradsUygula } from './tirads';

// 1218 paketinin seçenekleri (sıra puan demek).
const alanlar = [
  { alanKod: 'kompozisyon', secenekler: 'Kistik / neredeyse tamamen kistik|Süngerimsi|Mikst kistik-solid|Solid / neredeyse tamamen solid' },
  { alanKod: 'ekojenite', secenekler: 'Anekoik|Hiperekoik / izoekoik|Hipoekoik|Belirgin hipoekoik' },
  { alanKod: 'sekil', secenekler: 'Genişliği yüksekliğinden fazla|Yüksekliği genişliğinden fazla (taller-than-wide)' },
  { alanKod: 'kenar', secenekler: 'Düzgün|Belirsiz|Lobüle / düzensiz|Tiroid dışı uzanım gösteriyor' },
  { alanKod: 'ekojen_odak', secenekler: 'Yok|Büyük kuyruklu yıldız artefaktı|Makrokalsifikasyon|Periferik (rim) kalsifikasyon|Punktat ekojen odak' },
  { alanKod: 'tirads', secenekler: 'TR1 (benign)|TR2 (şüpheli değil)|TR3 (hafif şüpheli)|TR4 (orta derecede şüpheli)|TR5 (yüksek derecede şüpheli)' },
  { alanKod: 'oneri', secenekler: 'İİAB gerekmez|Ultrasonografi ile takip önerilir|İİAB önerilir' },
  { alanKod: 'nodul_boyut' },
];

describe('ACR TI-RADS', () => {
  it('puan ve kategori', () => {
    // solid 2 + hipoekoik 2 + geniş 0 + düzgün 0 + yok 0 = 4 -> TR4
    const d = { kompozisyon: 'Solid / neredeyse tamamen solid', ekojenite: 'Hipoekoik', sekil: 'Genişliği yüksekliğinden fazla',
                kenar: 'Düzgün', ekojen_odak: 'Yok' };
    expect(tiradsPuani(alanlar, d)).toBe(4);
    expect([0, 1, 2, 3, 4, 6, 7, 11].map(tiradsKategorisi)).toEqual([0, 0, 1, 2, 3, 3, 4, 4]);
  });

  it('eksik bileşende hesap yok', () => {
    expect(tiradsPuani(alanlar, { kompozisyon: 'Süngerimsi' })).toBeNull();
  });

  it('boyut ve öneri eşikleri', () => {
    expect(enBuyukBoyutMm('12x9x18')).toBe(18);
    expect(enBuyukBoyutMm('1,6 cm')).toBe(16);
    expect(tiradsOnerisi(3, 16)).toBe(2);    // TR4 ≥ 15 mm İİAB
    expect(tiradsOnerisi(3, 12)).toBe(1);    // TR4 ≥ 10 mm takip
    expect(tiradsOnerisi(2, 20)).toBe(1);    // TR3 ≥ 15 mm takip
    expect(tiradsOnerisi(4, 4)).toBe(0);
    expect(tiradsOnerisi(1, null)).toBe(0);  // TR2 hiç İİAB gerekmez
    expect(tiradsOnerisi(3, null)).toBeNull();
  });

  it('bileşen değişince kategori ve öneri yazılır', () => {
    const d = { kompozisyon: 'Solid / neredeyse tamamen solid', ekojenite: 'Belirgin hipoekoik',
                sekil: 'Yüksekliği genişliğinden fazla (taller-than-wide)', kenar: 'Düzgün', ekojen_odak: 'Punktat ekojen odak',
                nodul_boyut: '11x8x9' };
    const y = tiradsUygula(alanlar, d, 'ekojen_odak');   // 2+3+3+0+3 = 11 -> TR5, 11 mm -> İİAB
    expect(y.tirads).toBe('TR5 (yüksek derecede şüpheli)');
    expect(y.oneri).toBe('İİAB önerilir');
    // Kategori elle değiştirildiyse (bileşen değil) hesap dokunmaz.
    expect(tiradsUygula(alanlar, { ...y, tirads: 'TR4 (orta derecede şüpheli)' }, 'tirads').tirads).toBe('TR4 (orta derecede şüpheli)');
  });
});
