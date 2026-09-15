import { describe, expect, it } from 'vitest';
import type { DikteTerimi } from '../api/uclar/goz';
import { dikteAyristir, duzelt, guvenliMi } from '../bilesenler/goz/dikteMotoru';

/**
 * DİKTE MOTORU (705).
 *
 * Dikte, hekimin söylediğini hasta kaydına çeviriyor: burada yapılan bir hata
 * epikrize girer. Bu yüzden ayrıştırma bileşenden ayrı bir dosyada ve testi
 * mikrofonsuz çalışıyor.
 */

const terim = (soylenen: string, yazilan: string, id = 1): DikteTerimi =>
  ({ id, kapsam: 1, soylenen, yazilan, tur: 1, eylem: '', sira: 0 });
const komut = (soylenen: string, eylem: string, id = 100): DikteTerimi =>
  ({ id, kapsam: 1, soylenen, yazilan: '', tur: 2, eylem, sira: 0 });

const SOZLUK = {
  terimler: [terim('gib', 'GİB', 1), terim('floresein', 'fluoresein', 2),
             terim('negatif', '(−)', 3), terim('see de', 'C/D', 4)],
  komutlar: [komut('sağ göz', 'goz:1', 101), komut('sol göz', 'goz:2', 102),
             komut('kornea', 'hedef:onSegment.kornea', 103),
             komut('yeni satır', 'satir', 104), komut('nokta', 'noktalama:.', 105),
             komut('onayla', 'onayla', 106)],
};

describe('dikte ayrıştırma', () => {
  it('sesli komutu metinden çıkarır, komut olarak döndürür', () => {
    const s = dikteAyristir('sağ göz kornea saydam', SOZLUK);
    expect(s.komutlar.map(k => `${k.tur}:${k.deger}`))
      .toEqual(['goz:1', 'hedef:onSegment.kornea']);
    // Komut yazıya GEÇMEZ: "sağ göz" bulgunun içinde kalsaydı, alan zaten
    //   göz bazlıyken cümle "sağ göz kornea saydam" diye tekrar ederdi.
    expect(s.metin).toBe('Saydam.');
  });

  it('terim sözlüğünü uygular', () => {
    const s = dikteAyristir('gib yirmi altı floresein negatif', SOZLUK);
    expect(s.metin).toBe('GİB yirmi altı fluoresein (−).');
  });

  it('uzun komut kısa komuttan önce eşleşir', () => {
    // "sol göz" varken yalnız "göz" eşleşseydi cümle ortadan bölünürdü.
    const s = dikteAyristir('sol göz kornea saydam', SOZLUK);
    expect(s.komutlar[0].deger).toBe('2');
  });

  it('kelimenin içindeki eşleşmeyi komut saymaz', () => {
    const s = dikteAyristir('korneada leke var', SOZLUK);
    expect(s.komutlar).toEqual([]);
    expect(s.metin).toBe('Korneada leke var.');
  });

  it('noktalama ve satır komutları işaretini bırakır', () => {
    const s = dikteAyristir('kornea saydam nokta yeni satır lens berrak', SOZLUK);
    expect(s.metin).toBe('Saydam.\nLens berrak.');
  });

  it('onayla komutu ayrı bir komut olarak döner', () => {
    const s = dikteAyristir('onayla', SOZLUK);
    expect(s.komutlar.map(k => k.tur)).toEqual(['onayla']);
  });

  it('boş sözlükle metni yine düzeltir', () => {
    const s = dikteAyristir('kornea saydam', { terimler: [], komutlar: [] });
    expect(s.metin).toBe('Kornea saydam.');
  });
});

describe('metin düzeltme', () => {
  it('cümle başını büyütür, sonuna nokta koyar', () => {
    expect(duzelt('kornea saydam')).toBe('Kornea saydam.');
  });

  it('Türkçe büyütme yapar (i -> İ)', () => {
    expect(duzelt('iris doğal')).toBe('İris doğal.');
  });

  it('noktalama öncesi boşluğu toplar', () => {
    expect(duzelt('saydam , berrak')).toBe('Saydam, berrak.');
  });

  it('var olan noktalamayı çoğaltmaz', () => {
    expect(duzelt('Saydam.')).toBe('Saydam.');
  });

  it('boş metni boş bırakır', () => {
    expect(duzelt('   ')).toBe('');
  });
});

describe('güven eşiği', () => {
  it('eşik altındaki parça yazılmaz', () => {
    expect(guvenliMi(0.41, 0.6)).toBe(false);
  });

  it('eşik üstü yazılır', () => {
    expect(guvenliMi(0.93, 0.6)).toBe(true);
  });

  it('güven bildirmeyen motor engellenmez', () => {
    // Bazı tarayıcılar confidence=0 döndürüyor; hepsini atmak dikteyi
    //   tamamen sessizleştirirdi.
    expect(guvenliMi(0, 0.6)).toBe(true);
  });
});
