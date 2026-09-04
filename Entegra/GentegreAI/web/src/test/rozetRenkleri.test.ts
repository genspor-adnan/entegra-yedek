import { describe, it, expect } from 'vitest';
import { ROZET_SINIFI } from '../bilesenler/gridHucre';

/**
 * ROZET RENKLERI birbirinden AYRILMALI.
 *
 * Prim rolleri once uc ayri sinifa dagitilmisti ("mor", "bilgi", "mavi") ve
 * ekranda hepsi AYNI mavi gorunuyordu: tema degiskeni `--mor` aslinda
 * #2f6db3 MAVI. Gozle "farkli sinif verdim" demek yetmiyor - hangi siniflarin
 * gercekten ayri renk oldugu burada sabitlenir.
 */

/** Gozle AYIRT EDILEMEYEN siniflar - ayni gruptakiler ayni renk sayilir. */
const AYNI_GORUNEN: string[][] = [
  ['mor', 'bilgi', 'mavi'],   // ucu de --mor (#2f6db3) tonlari
];

const gorselRenk = (sinif: string) =>
  AYNI_GORUNEN.find(g => g.includes(sinif))?.[0] ?? sinif;

const PRIM_ROLLERI = ['Gönderen', 'İsteyen', 'Uygulayan', 'Yapan', 'Raporlayan',
                      'Onaylayan', 'Anestezi', 'Asistan', 'Teknisyen'];

describe('rozet renkleri', () => {
  it('her prim rolunun bir rengi VAR', () => {
    const eksik = PRIM_ROLLERI.filter(r => !ROZET_SINIFI[r]);
    expect(eksik).toEqual([]);
  });

  it('prim rolleri GORSEL olarak ayrisir (ayni maviye dusmez)', () => {
    const renkler = PRIM_ROLLERI.map(r => gorselRenk(ROZET_SINIFI[r]));
    expect(new Set(renkler).size).toBe(PRIM_ROLLERI.length);
  });

  it('odeyen tipleri ayrisir', () => {
    const tipler = ['Özel (Ücretli)', 'ÖSS', 'SGK', 'Tümü'];
    const renkler = tipler.map(t => gorselRenk(ROZET_SINIFI[t] ?? 'gri'));
    expect(new Set(renkler).size).toBe(tipler.length);
  });

  it('prim zamanlari ayrisir', () => {
    expect(gorselRenk(ROZET_SINIFI['Faturalamada']))
      .not.toBe(gorselRenk(ROZET_SINIFI['Tahsilatta']));
  });

  it('PASIF her zaman kirmizi, AKTIF yesil (kullanici)', () => {
    expect(ROZET_SINIFI['Pasif']).toBe('hata');
    expect(ROZET_SINIFI['Aktif']).toBe('ok');
  });
});
