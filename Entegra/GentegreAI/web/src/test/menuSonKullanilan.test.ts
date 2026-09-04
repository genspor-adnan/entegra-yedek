import { describe, it, expect } from 'vitest';
import {
  sonMenuEkle, sonMenuGorunen, EN_SON_SINIR,
} from '../sayfalar/menuSonKullanilan';

/**
 * MENUDE "EN SON" LISTESI.
 *
 * Kural kucuk ama uc kenari var; yanlisi menuyu ya sisirir (kopya birikmesi)
 * ya da yaniltir (yanlis sira). Liste kullanicinin BASINA tarayicida saklandigi
 * icin bozuk bir kural gunler boyunca oyle kalir.
 */
describe('sonMenuEkle', () => {
  it('yeni yol EN BASA girer', () => {
    expect(sonMenuEkle(['/b', '/c'], '/a')).toEqual(['/a', '/b', '/c']);
  });

  it('ZATEN VARSA kopya birikmez, yukari tasinir', () => {
    // Istenen "son 10 farkli ekran", "son 10 tiklama" degil.
    expect(sonMenuEkle(['/b', '/a', '/c'], '/a')).toEqual(['/a', '/b', '/c']);
  });

  it('zaten EN USTTEYSE liste AYNEN doner (gereksiz yazim olmasin)', () => {
    const l = ['/a', '/b'];
    expect(sonMenuEkle(l, '/a')).toBe(l);
  });

  it('bos yol listeyi degistirmez', () => {
    const l = ['/a'];
    expect(sonMenuEkle(l, '')).toBe(l);
  });

  it('sinir 10: en eski duser', () => {
    const on = Array.from({ length: EN_SON_SINIR }, (_, i) => `/y${i}`);
    const y = sonMenuEkle(on, '/yeni');
    expect(y).toHaveLength(EN_SON_SINIR);
    expect(y[0]).toBe('/yeni');
    expect(y).not.toContain('/y9');          // en eski
    expect(y).toContain('/y0');              // en yeniden bir onceki korunur
  });

  it('bos listeye ilk oge eklenir', () => {
    expect(sonMenuEkle([], '/a')).toEqual(['/a']);
  });
});

describe('sonMenuGorunen', () => {
  it('FAVORIDEKILER elenir - ayni satir iki kez cizilmesin', () => {
    expect(sonMenuGorunen(['/a', '/b', '/c'], ['/b'])).toEqual(['/a', '/c']);
  });

  it('hepsi favorideyse liste BOS doner (bolum hic cizilmez)', () => {
    expect(sonMenuGorunen(['/a', '/b'], ['/a', '/b'])).toEqual([]);
  });

  it('favori yoksa liste aynen gorunur - SON KULLANIM sirasiyla', () => {
    expect(sonMenuGorunen(['/c', '/a', '/b'], [])).toEqual(['/c', '/a', '/b']);
  });
});
