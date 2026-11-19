// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';

/**
 * RANDEVU TAKVİMİ › KAYIT SEÇİMİ (kullanıcı 19.11.2026: "kayıtlı randevuyu işaretlemek için sağ üst köşesine check
 * ekle.. tek tıklama seçsin.. çift tıklama formu açsın").
 */
const bugun = new Date().toLocaleDateString('sv-SE');
const satir = { id: 77, hasta: 'Ali Test', tarih: bugun, baslangic: `${bugun}T09:00:00`, saat: '09:00', bitis: '09:15',
                sureDk: 15, durum: 1 };
vi.mock('../api/istemci', () => ({
  api: new Proxy({}, {
    get: (_t, ad) => ad === 'liste'
      ? () => Promise.resolve({ satirlar: [satir], toplam: 1 })
      : () => Promise.resolve({ kapatmalar: [], ogleArasi: [], bloklar: [], satirlar: [] }),
  }),
}));
const { RandevuTakvimi } = await import('../bilesenler/RandevuTakvimi');

describe('RandevuTakvimi seçim', () => {
  it('tek tık seçer, ikinci tık bırakır, çift tık açar; işaret kutusu da seçer', async () => {
    const onSec = vi.fn(), onAc = vi.fn();
    const { rerender } = render(<RandevuTakvimi onYeni={() => {}} onAc={onAc} onSec={onSec} seciliId={null} />);
    const blok = (await screen.findByText('Ali Test')).closest('.takvim-kayit') as HTMLElement;
    expect(blok).toBeTruthy();

    fireEvent.click(blok);
    expect(onSec).toHaveBeenLastCalledWith(expect.objectContaining({ id: 77 }));
    expect(onAc).not.toHaveBeenCalled();

    rerender(<RandevuTakvimi onYeni={() => {}} onAc={onAc} onSec={onSec} seciliId={77} />);
    const kutu = screen.getByLabelText('Randevuyu seç') as HTMLInputElement;
    expect(kutu.checked).toBe(true);
    expect(blok.className).toContain('secili');
    fireEvent.click(blok);
    expect(onSec).toHaveBeenLastCalledWith(null);

    fireEvent.doubleClick(blok);
    expect(onAc).toHaveBeenCalledWith(77);

    rerender(<RandevuTakvimi onYeni={() => {}} onAc={onAc} onSec={onSec} seciliId={null} />);
    onSec.mockClear();
    fireEvent.click(screen.getByLabelText('Randevuyu seç'));
    expect(onSec).toHaveBeenCalledTimes(1);
    expect(onSec).toHaveBeenLastCalledWith(expect.objectContaining({ id: 77 }));
  });
});
