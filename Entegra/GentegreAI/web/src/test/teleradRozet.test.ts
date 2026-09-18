import { describe, it, expect } from 'vitest';
import { ROZET_SINIFI } from '../bilesenler/gridHucre';

/**
 * TELERADYOLOJI ROZET RENKLERI (mockup `telerad_calisma_listesi.html`).
 *
 * Calisma listesinde bes rozet kolonu yan yana durur (oncelik · durum ·
 * modalite · goruntu durumu · yon). Metinler ortak sozlukte yoksa hepsi GRI
 * dusuyor ve rozet olmalari hicbir sey soylemiyor - mockup ailesinin en
 * belirgin isareti renkli durum cipidir.
 */
const AYNI_GORUNEN = [['mor', 'bilgi', 'mavi']];
const gorsel = (s: string) => AYNI_GORUNEN.find(g => g.includes(s))?.[0] ?? s;

describe('teleradyoloji rozetleri', () => {
  it('oncelik: ACİL kirmizi, Rutin notr', () => {
    expect(ROZET_SINIFI['ACİL']).toBe('hata');
    expect(ROZET_SINIFI['Rutin']).toBe('gri');
    expect(gorsel(ROZET_SINIFI['ACİL'])).not.toBe(gorsel(ROZET_SINIFI['Öncelikli']));
  });

  it('durum akisinin her adiminin rengi VAR', () => {
    const durumlar = ['Görüntü bekleniyor', 'Sırada', 'Atandı', 'Okunuyor',
                      'Taslak', 'Onaylı', 'Teslim edildi', 'Ek görüntü istendi', 'İptal'];
    expect(durumlar.filter(d => !ROZET_SINIFI[d])).toEqual([]);
  });

  it('BEKLEYEN ile BITEN is ayni renge dusmez', () => {
    // "Sirada" ile "Onayli" ayni renkteyse liste bir bakista okunmaz.
    for (const bekleyen of ['Görüntü bekleniyor', 'Sırada'])
      for (const biten of ['Onaylı', 'Teslim edildi'])
        expect(gorsel(ROZET_SINIFI[bekleyen])).not.toBe(gorsel(ROZET_SINIFI[biten]));
  });

  it('goruntu durumu: sorun cikaranlar notr degil', () => {
    expect(ROZET_SINIFI['Tamam']).toBe('ok');
    expect(ROZET_SINIFI['Eksik seri']).toBe('uyari');
    expect(ROZET_SINIFI['Hatalı']).toBe('hata');
  });

  it('yon: gelen ile giden ayrisir', () => {
    expect(gorsel(ROZET_SINIFI['Gelen'])).not.toBe(gorsel(ROZET_SINIFI['Giden']));
  });
});
