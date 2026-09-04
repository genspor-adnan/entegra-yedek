// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { KademeGridi } from '../bilesenler/prim/KademeGridi';

/**
 * KADEME GRIDI (388) - prim satiri modalinin alt bileseni.
 *
 * Kademe DONEM KAPANISINDA isler; ekranda aninda bir etki gostermez. Bu
 * yuzden gridin dogru davrandigini gozle anlamak zor - testin isi tam burada.
 */
const kademeler = vi.fn();
const kademeYaz = vi.fn();

vi.mock('../api/istemci', () => ({
  api: {
    primKademeler: (id: number) => kademeler(id),
    primKademeYaz: (id: number, satirlar: unknown) => kademeYaz(id, satirlar),
  },
}));

beforeEach(() => {
  vi.clearAllMocks();
  kademeler.mockResolvedValue({ satirlar: [
    { id: 1, adetAlt: 1, adetUst: 2, deger: 5 },
    { id: 2, adetAlt: 3, adetUst: null, deger: 9 },
  ] });
  kademeYaz.mockResolvedValue({ satirSayisi: 2 });
});

const satirlar = () => [...document.querySelectorAll('tbody tr')];
const kutu = (satir: Element, i: number) =>
  satir.querySelectorAll('input')[i] as HTMLInputElement;

describe('KademeGridi', () => {
  it('SATIR KAYDEDILMEMISSE uyarir, grid cizmez', () => {
    render(<KademeGridi planSatirId={null} />);
    expect(screen.getByText(/önce satırı kaydedin/i)).toBeInTheDocument();
    expect(document.querySelector('table')).toBeNull();
    // Bos grid gostermek "yazdim ama gitmedi" uretirdi - istek de atilmamali.
    expect(kademeler).not.toHaveBeenCalled();
  });

  it('mevcut kademeler yuklenir; ACIK UC bos kutu olarak gelir', async () => {
    render(<KademeGridi planSatirId={27} />);
    await waitFor(() => expect(satirlar()).toHaveLength(2));
    expect(kutu(satirlar()[0], 0).value).toBe('1');
    expect(kutu(satirlar()[0], 1).value).toBe('2');
    expect(kutu(satirlar()[0], 2).value).toBe('5');
    // "ve yukarisi" kademesinde ust sinir BOS - null'i 0 gostermek
    //   "3-0 arasi" gibi okunurdu.
    expect(kutu(satirlar()[1], 1).value).toBe('');
  });

  it('KADEME DONEM KAPANISINDA notu HER ZAMAN gorunur', async () => {
    render(<KademeGridi planSatirId={27} />);
    expect(await screen.findByText(/dönem kapanışında/i)).toBeInTheDocument();
    expect(screen.getByText(/önizlemedir/i)).toBeInTheDocument();
  });

  it('EKLE + KAYDET: bos ust sinir NULL gider, virgullu deger cozulur', async () => {
    kademeler.mockResolvedValue({ satirlar: [] });
    render(<KademeGridi planSatirId={27} />);
    await waitFor(() => expect(kademeler).toHaveBeenCalled());

    fireEvent.click(screen.getByTitle('Kademe ekle'));
    const s = satirlar()[0];
    fireEvent.change(kutu(s, 0), { target: { value: '3' } });
    fireEvent.change(kutu(s, 1), { target: { value: '' } });
    fireEvent.change(kutu(s, 2), { target: { value: '9,5' } });
    fireEvent.click(screen.getByRole('button', { name: /Kademeleri Kaydet/ }));

    await waitFor(() => expect(kademeYaz).toHaveBeenCalled());
    expect(kademeYaz.mock.calls[0][1]).toEqual([
      { adetAlt: 3, adetUst: null, deger: 9.5 },
    ]);
    expect(await screen.findByText(/1 kademe kaydedildi/)).toBeInTheDocument();
  });

  it('SIL satiri kaldirir, kaydedilene kadar sunucuya gitmez', async () => {
    render(<KademeGridi planSatirId={27} />);
    await waitFor(() => expect(satirlar()).toHaveLength(2));
    fireEvent.click(screen.getAllByTitle('Kademeyi sil')[0]);
    expect(satirlar()).toHaveLength(1);
    expect(kademeYaz).not.toHaveBeenCalled();
  });

  it('BOSALTIP kaydetmek kademeleri KALDIRIR (bos liste gider)', async () => {
    render(<KademeGridi planSatirId={27} />);
    await waitFor(() => expect(satirlar()).toHaveLength(2));
    screen.getAllByTitle('Kademeyi sil').forEach(() => {
      fireEvent.click(screen.getAllByTitle('Kademeyi sil')[0]);
    });
    fireEvent.click(screen.getByRole('button', { name: /Kademeleri Kaydet/ }));
    await waitFor(() => expect(kademeYaz).toHaveBeenCalledWith(27, []));
  });

  it('SUNUCU HATASI ekranda gorunur (cakisan aralik gibi)', async () => {
    kademeYaz.mockRejectedValue(new Error('Kademe aralıkları çakışıyor: 1-5 ile 3-8.'));
    render(<KademeGridi planSatirId={27} />);
    await waitFor(() => expect(satirlar()).toHaveLength(2));
    fireEvent.click(screen.getByRole('button', { name: /Kademeleri Kaydet/ }));
    expect(await screen.findByText(/çakışıyor/)).toBeInTheDocument();
  });
});
