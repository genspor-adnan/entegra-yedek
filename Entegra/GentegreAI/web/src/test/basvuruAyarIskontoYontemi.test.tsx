// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';

/**
 * BAŞVURU AYARLARI › İSKONTO ONAY YÖNTEMİ (1375; kullanıcı 18.11.2026: "Onay yöntemi seçtim ama kaydet aktif değil",
 * "ayarlarda otomatik kaydet istemiyorum"): şube ayarı da sayfanın taslak + Kaydet desenine uyar - seçim anında
 * yazılmaz, Kaydet'i açar, Kaydet ile yazılır.
 */
const yontemYaz = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  ayarlar: async () => [{ anahtar: 'basvuru.iskonto_onay_esik', deger: '10' }],
  ayarYaz: vi.fn(),
  iskontoOnayYontemi: async () => ({ yontem: 1, subeId: 1 }),
  iskontoOnayYontemiYaz: async (y: number) => { yontemYaz(y); return { yontem: y } },
} }));
vi.mock('../api/ayarlar', () => ({ ayarOnbellegiTemizle: vi.fn() }));
const { KayitKabulAyarlar } = await import('../sayfalar/KayitKabulAyarlar');

describe('Başvuru Ayarları › İskonto Onay Yöntemi', () => {
  it('seçim taslakta kalır, Kaydet açılır ve yazar', async () => {
    render(<MemoryRouter><KayitKabulAyarlar bolum="basvuru" /></MemoryRouter>);
    const kaydet = () => screen.getByTestId('ayar-kaydet') as HTMLButtonElement;
    const secim = await screen.findByLabelText('İskonto Onay Yöntemi') as HTMLSelectElement;
    await waitFor(() => expect(secim.disabled).toBe(false));
    expect(kaydet().disabled).toBe(true);

    fireEvent.change(secim, { target: { value: '2' } });
    expect(yontemYaz).not.toHaveBeenCalled();                 // otomatik kayıt yok
    expect(kaydet().disabled).toBe(false);
    expect(screen.getByTestId('ayar-degisti')).toBeTruthy();

    await act(async () => { kaydet().click() });
    expect(yontemYaz).toHaveBeenCalledWith(2);
    await waitFor(() => expect(kaydet().disabled).toBe(true));
  });
});
