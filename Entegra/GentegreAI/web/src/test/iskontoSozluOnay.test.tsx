// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { IskontoTalepModali, type IskontoTalepSonucu } from '../bilesenler/belge/IskontoTalepModali';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * SÖZLÜ ONAY (1375, kullanıcı 18.11.2026: "sözlü onay / dijital onay opsiyonlu olabilmeli"). Pencere şubenin
 * yöntemini okur: sözlüde "Onaya Gönder" yerine yönetici seçimi + "Sözlü Onayla Uygula"; ikisi de ise iki yol;
 * dijitalde bugünkü gibi. Sonuç sözünü veren yöneticiyi taşır.
 */
const bilgi = vi.fn();
vi.mock('../api/istemci', () => ({ api: { iskontoSozluBilgi: (id: number) => bilgi(id) } }));

const satir = (anahtar: number, fiyat: string): SatirDurumu =>
  ({ ...bosSatir(anahtar), satirId: anahtar, stokAdi: `Kalem ${anahtar}`, birimFiyat: fiyat, kdv: '0' });

async function ciz(yontem: 1 | 2 | 3, sonuc = vi.fn()) {
  bilgi.mockResolvedValue({ yontem, onaycilar: [{ id: 7, ad: 'Dr. Yönetici' }] });
  render(<IskontoTalepModali satirlar={[satir(1, '1000')]} tavan={10} belgeId={55}
                             onKapat={() => {}} onSonuc={sonuc} />);
  await waitFor(() => expect(bilgi).toHaveBeenCalledWith(55));
  // %40: banko tavanı (%10) üstü.
  fireEvent.change(screen.getByLabelText('Tümüne oran'), { target: { value: '40' } });
}

describe('İskonto Uygula › sözlü onay', () => {
  beforeEach(() => bilgi.mockReset());

  it('sözlü şubede dijital düğme yok; yönetici + gerekçe ile sözlü onay sonucu döner', async () => {
    const sonuc = vi.fn<(s: IskontoTalepSonucu) => void>();
    await ciz(2, sonuc);
    await waitFor(() => expect(screen.getByText(/Sözlü Onayla Uygula/)).toBeTruthy());
    expect(screen.queryByText(/Onaya Gönder/)).toBeNull();
    const dugme = screen.getByText(/Sözlü Onayla Uygula/).closest('button')!;
    expect(dugme.disabled).toBe(true);                               // yönetici seçilmedi
    fireEvent.change(screen.getByLabelText('Sözlü onay veren'), { target: { value: '7' } });
    const kat = screen.getByLabelText('Kategori') as HTMLSelectElement;   // gerekçe zorunlu
    fireEvent.change(kat, { target: { value: kat.options[1].value } });
    await act(async () => { fireEvent.click(dugme) });
    expect(sonuc).toHaveBeenCalledTimes(1);
    const s = sonuc.mock.calls[0][0];
    expect(s.sozluOnaylayanId).toBe(7);
    expect(s.onaya).toBe(false);
    expect(s.kalemler).toEqual([{ anahtar: 1, satirId: 1, oran: 40 }]);
  });

  it('ikisi de: iki yol birlikte; dijital: yalnız Onaya Gönder', async () => {
    await ciz(3);
    await waitFor(() => expect(screen.getByText(/Sözlü Onayla Uygula/)).toBeTruthy());
    expect(screen.getByText(/Onaya Gönder/)).toBeTruthy();
  });

  it('dijital şubede sözlü yol çizilmez', async () => {
    await ciz(1);
    expect(screen.getByText(/Onaya Gönder/)).toBeTruthy();
    expect(screen.queryByText(/Sözlü Onayla Uygula/)).toBeNull();
  });
});
