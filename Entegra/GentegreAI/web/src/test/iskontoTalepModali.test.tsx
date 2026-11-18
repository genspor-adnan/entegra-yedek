// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { act, fireEvent, render, screen } from '@testing-library/react';
import { IskontoTalepModali, type IskontoTalepSonucu } from '../bilesenler/belge/IskontoTalepModali';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * TÜMÜNE NET TUTAR (kullanıcı 18.11.2026): girilen rakam hastanın ödeyeceği net toplam; indirim (toplam - net)
 * seçili kalemlerin toplamına oranlanır, "tümüne oran"a yazılır ve oradan satırlara yansır. Oran 4 ondalık.
 */
const satir = (anahtar: number, fiyat: string): SatirDurumu =>
  ({ ...bosSatir(anahtar), satirId: anahtar, stokAdi: `Kalem ${anahtar}`, birimFiyat: fiyat, kdv: '0' });

function ciz(sonuc = vi.fn()) {
  render(<IskontoTalepModali satirlar={[satir(1, '200'), satir(2, '100')]} tavan={25}
                             onKapat={() => {}} onSonuc={sonuc} />);
  return {
    tutar: screen.getByLabelText('Tümüne Net Tutar') as HTMLInputElement,
    oran: screen.getByLabelText('Tümüne oran') as HTMLInputElement,
  };
}

describe('İskonto Uygula › tümüne net tutar', () => {
  it('net 270 -> indirim 30 toplam tutara oranlanır, tümüne orana yazılır ve satırlara yansır', async () => {
    const sonuc = vi.fn<(s: IskontoTalepSonucu) => void>();
    const { tutar, oran } = ciz(sonuc);
    fireEvent.change(tutar, { target: { value: '270' } });
    expect(oran.value).toBe('10');
    await act(async () => { fireEvent.click(screen.getByText('✔ Uygula')) });
    expect(sonuc).toHaveBeenCalledTimes(1);
    expect(sonuc.mock.calls[0][0].kalemler.map(k => k.oran)).toEqual([10, 10]);
  });

  it('kesirli oran 4 ondalıkla yazılır', () => {
    const { tutar, oran } = ciz();
    fireEvent.change(tutar, { target: { value: '250' } });
    expect(oran.value).toBe('16,6667');
  });

  it('kalem seçimi değişince oran aynı netle yeniden hesaplanır; oran elle yazılınca tutar boşalır', () => {
    const { tutar, oran } = ciz();
    fireEvent.change(tutar, { target: { value: '270' } });
    fireEvent.click(screen.getAllByRole('checkbox')[1]);          // 100'lük kalem indirilmez -> indirim 30 / 200
    expect(oran.value).toBe('15');
    fireEvent.change(oran, { target: { value: '5' } });
    expect(tutar.value).toBe('');
  });

  it('indirilemeyen kalemlerin altındaki net %100 ile sınırlanır ve söylenir', () => {
    const { tutar, oran } = ciz();
    fireEvent.click(screen.getAllByRole('checkbox')[1]);          // 100'lük kalem indirilmez
    fireEvent.change(tutar, { target: { value: '50' } });
    expect(oran.value).toBe('100');
    expect(screen.getByText(/altında olamaz/)).toBeTruthy();
  });

  it('toplamdan büyük net indirim yapmaz', () => {
    const { tutar, oran } = ciz();
    fireEvent.change(tutar, { target: { value: '350' } });
    expect(oran.value).toBe('');
    expect(screen.getByText(/indirim yok/)).toBeTruthy();
  });

  it('satırda istenen tutar o satırın oranını verir; oran elle yazılınca istenen boşalır', async () => {
    const sonuc = vi.fn<(s: IskontoTalepSonucu) => void>();
    ciz(sonuc);
    const istenen = screen.getByLabelText('İstenen Tutar Kalem 1') as HTMLInputElement;
    fireEvent.change(istenen, { target: { value: '150' } });     // 200 -> 150: %25
    const oranlar = () => (screen.getAllByRole('textbox') as HTMLInputElement[])
      .filter(i => !i.getAttribute('aria-label') && i.closest('tbody'));
    expect(oranlar()[0].value).toBe('25');
    await act(async () => { fireEvent.click(screen.getByText('✔ Uygula')) });
    expect(sonuc.mock.calls[0][0].kalemler).toEqual([{ anahtar: 1, satirId: 1, oran: 25 }]);
    fireEvent.change(oranlar()[0], { target: { value: '5' } });
    expect(istenen.value).toBe('');
  });
});
