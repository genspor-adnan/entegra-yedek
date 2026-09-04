import { describe, it, expect } from 'vitest';
import { detayHucreMetni } from '../bilesenler/detayGorunum';
import type { KartAlanMeta } from '../api/sozlesme';

const alan = (a: Partial<KartAlanMeta>) => a as Pick<KartAlanMeta, 'ad' | 'tip' | 'kodlar'>;

const BELGE = { '15,16': 'Fatura / Fiş', '17': 'Tahakkuk' };

describe('detayHucreMetni', () => {
  it('MANTIK alani ✓ / bos', () => {
    expect(detayHucreMetni({ x: 1 }, alan({ ad: 'x', tip: 'mantik' }))).toBe('✓');
    expect(detayHucreMetni({ x: true }, alan({ ad: 'x', tip: 'mantik' }))).toBe('✓');
    expect(detayHucreMetni({ x: 0 }, alan({ ad: 'x', tip: 'mantik' }))).toBe('');
  });

  it('KODLU METIN: bos deger "Tümü" - kriter YOK demek', () => {
    // Bos hucre "doldurulmamis" gibi okunuyordu; oysa bos = tum belge turleri.
    expect(detayHucreMetni({ b: '' }, alan({ ad: 'b', tip: 'metin', kodlar: BELGE })))
      .toBe('Tümü');
    expect(detayHucreMetni({}, alan({ ad: 'b', tip: 'metin', kodlar: BELGE })))
      .toBe('Tümü');
  });

  it('KODLU METIN: combo secenegi TAM ESLESIR', () => {
    expect(detayHucreMetni({ b: '15,16' }, alan({ ad: 'b', tip: 'metin', kodlar: BELGE })))
      .toBe('Fatura / Fiş');
    expect(detayHucreMetni({ b: '17' }, alan({ ad: 'b', tip: 'metin', kodlar: BELGE })))
      .toBe('Tahakkuk');
  });

  it('KODLU METIN: eski kombinasyon tek tek cozulur', () => {
    // db/381 oncesi kayitlar ('4,14,15' gibi) combo secenegi degil; ham metin
    //   gridde hicbir sey ifade etmiyordu - bilinen kodlar adiyla yazilir,
    //   bilinmeyen kod OLDUGU GIBI kalir (kaybolmasin).
    expect(detayHucreMetni({ b: '17,99' }, alan({ ad: 'b', tip: 'metin', kodlar: BELGE })))
      .toBe('Tahakkuk, 99');
  });

  it('KOD alani etiketine cevrilir, taninmayan deger BOS', () => {
    const rol = alan({ ad: 'r', tip: 'kod', kodlar: { '1': 'Gönderen' } });
    expect(detayHucreMetni({ r: 1 }, rol)).toBe('Gönderen');
    expect(detayHucreMetni({ r: 7 }, rol)).toBe('');
  });

  it('PARA alani TR bicimiyle, dort haneye kadar', () => {
    // para4 iki haneye EZMEZ: carpan 7,0092'yi 7,01 gostermek yaniltir.
    expect(detayHucreMetni({ t: 1234.5 }, alan({ ad: 't', tip: 'para' })))
      .toBe('1.234,50');
    expect(detayHucreMetni({ t: '' }, alan({ ad: 't', tip: 'para' }))).toBe('');
  });

  it('DIGER alanlar metne cevrilir, null bos', () => {
    expect(detayHucreMetni({ a: 'x' }, alan({ ad: 'a', tip: 'metin' }))).toBe('x');
    expect(detayHucreMetni({ a: null }, alan({ ad: 'a', tip: 'metin' }))).toBe('');
  });
});
