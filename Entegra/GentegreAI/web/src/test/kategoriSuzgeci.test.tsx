// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { KategoriSuzgeci } from '../bilesenler/KategoriSuzgeci';

/**
 * KATEGORI AGAC COMBOSU (484 · kullanici: "fiyat listesi kartı satırlarda
 * kategori ağaç combo ekle").
 *
 * Iki sey kilitleniyor:
 *   - IKI AGAC BIRDEN (stok + hizmet) istendiginde secenekler tur basina
 *     gruplanir - "Genel" hem stokta hem hizmette bulunabiliyor, gruplama
 *     olmadan hangisi oldugu anlasilmaz.
 *   - SINIRLA verildiginde yalniz o dallar VE USTLERI listelenir; ust
 *     dusurulurse girinti kopar ve dal kokte gorunur.
 */
const liste = vi.fn();
vi.mock('../api/istemci', () => ({ api: { liste: (...a: unknown[]) => liste(...a) } }));

const kategoriler = [
  { id: 1, ad: 'İlaç',      ustId: null, tur: 1 },
  { id: 2, ad: 'Kontrast',  ustId: 1,    tur: 1 },
  { id: 3, ad: 'Radyoloji', ustId: null, tur: 2 },
  { id: 4, ad: 'Angio',     ustId: 3,    tur: 2 },
  { id: 5, ad: 'Röntgen',   ustId: 3,    tur: 2 },
];

const kur = (ek: Partial<Parameters<typeof KategoriSuzgeci>[0]> = {}) => {
  liste.mockResolvedValue({ satirlar: kategoriler });
  const onDegis = vi.fn();
  render(<KategoriSuzgeci tur={[1, 2]} deger={null} onDegis={onDegis} {...ek} />);
  return onDegis;
};

describe('KategoriSuzgeci - agac combo', () => {
  it('iki agac istenince secenekler Stok / Hizmet olarak gruplanir', async () => {
    kur();
    await waitFor(() => expect(screen.getByRole('option', { name: /İlaç/ })).toBeTruthy());
    const gruplar = document.querySelectorAll('optgroup');
    expect([...gruplar].map(g => g.label)).toEqual(['Stok', 'Hizmet']);
    expect(gruplar[0].children.length).toBe(2);   // İlaç > Kontrast
    expect(gruplar[1].children.length).toBe(3);   // Radyoloji > Angio, Röntgen
  });

  it('sinirla verilince yalniz o dallar ve USTLERI kalir', async () => {
    kur({ sinirla: new Set([4]) });               // yalniz Angio kullaniliyor
    await waitFor(() => expect(document.querySelectorAll('option').length).toBe(3));
    const adlar = [...document.querySelectorAll('option')].map(o => o.textContent?.trim());
    expect(adlar).toEqual(['Tüm Kategoriler', 'Radyoloji', '└ Angio']);
    expect(document.querySelectorAll('optgroup').length).toBe(0);  // tek agac kaldi
  });

  it('secim dalin TUM ALTLARINI birlikte dondurur', async () => {
    const onDegis = kur();
    await waitFor(() => expect(screen.getByRole('option', { name: /Radyoloji/ })).toBeTruthy());
    fireEvent.change(document.querySelector('select')!, { target: { value: '3' } });
    // Ucuncu arguman secilen dalin ADI: fiyat listesi toplu pencerelerinde
    //   dugme etiketi oluyor ("Radyoloji uygula").
    expect(onDegis).toHaveBeenCalledWith(3, [3, 4, 5], 'Radyoloji');
  });
});
