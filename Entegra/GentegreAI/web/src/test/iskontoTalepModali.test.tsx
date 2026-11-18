// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { act, fireEvent, render, screen } from '@testing-library/react';
import { IskontoTalepModali, type IskontoTalepSonucu } from '../bilesenler/belge/IskontoTalepModali';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * TÜMÜNE TUTAR (kullanıcı 18.11.2026): girilen indirim tutarı seçili kalemlerin toplamına oranlanır, "tümüne
 * oran"a yazılır ve oradan satırlara yansır. Oran 4 ondalık (belge_satir.iskonto numeric(9,4)).
 */
const satir = (anahtar: number, fiyat: string): SatirDurumu =>
  ({ ...bosSatir(anahtar), satirId: anahtar, stokAdi: `Kalem ${anahtar}`, birimFiyat: fiyat, kdv: '0' });

function ciz(sonuc = vi.fn()) {
  render(<IskontoTalepModali satirlar={[satir(1, '200'), satir(2, '100')]} tavan={25}
                             onKapat={() => {}} onSonuc={sonuc} />);
  return {
    tutar: screen.getByLabelText('Tümüne tutar') as HTMLInputElement,
    oran: screen.getByLabelText('Tümüne oran') as HTMLInputElement,
  };
}

describe('İskonto Uygula › tümüne tutar', () => {
  it('tutar toplam tutara oranlanır, tümüne orana yazılır ve satırlara yansır', async () => {
    const sonuc = vi.fn<(s: IskontoTalepSonucu) => void>();
    const { tutar, oran } = ciz(sonuc);
    fireEvent.change(tutar, { target: { value: '30' } });
    expect(oran.value).toBe('10');
    await act(async () => { fireEvent.click(screen.getByText('✔ Uygula')) });
    expect(sonuc).toHaveBeenCalledTimes(1);
    expect(sonuc.mock.calls[0][0].kalemler.map(k => k.oran)).toEqual([10, 10]);
  });

  it('kesirli oran 4 ondalıkla yazılır', () => {
    const { tutar, oran } = ciz();
    fireEvent.change(tutar, { target: { value: '50' } });
    expect(oran.value).toBe('16,6667');
  });

  it('kalem seçimi değişince oran aynı tutarla yeniden hesaplanır; oran elle yazılınca tutar boşalır', () => {
    const { tutar, oran } = ciz();
    fireEvent.change(tutar, { target: { value: '30' } });
    fireEvent.click(screen.getAllByRole('checkbox')[1]);          // 100'lük kalem çıkar -> taban 200
    expect(oran.value).toBe('15');
    fireEvent.change(oran, { target: { value: '5' } });
    expect(tutar.value).toBe('');
  });

  it('indirilebilir toplamı aşan tutar %100 ile sınırlanır ve söylenir', () => {
    const { tutar, oran } = ciz();
    fireEvent.change(tutar, { target: { value: '400' } });
    expect(oran.value).toBe('100');
    expect(screen.getByText(/indirilebilir toplamı/)).toBeTruthy();
  });
});
