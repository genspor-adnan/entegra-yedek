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
});
