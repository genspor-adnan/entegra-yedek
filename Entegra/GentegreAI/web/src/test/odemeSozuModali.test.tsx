// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';

/**
 * ÖDEME SÖZÜ / PLAN PENCERESİ (19.11.2026): borç takibi ve başvuru Tahsilat "⋯" ortak pencere.
 */
const soz = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  hastaBorcSoz: (g: unknown) => soz(g),
  // Taksit tablosu sunucudan (kod inceleme 19.11.2026) - sahte uç sunucunun bölüşümünü döner.
  hastaBorcPlanOnizleme: (tutar: number, _ilk: string, n: number) => Promise.resolve({ taksitler: Array.from({ length: n },
    (_, i) => ({ tarih: '2026-12-0' + (i + 1), tutar: i === n - 1 ? tutar - Math.floor(tutar / n * 100) / 100 * (n - 1) : Math.floor(tutar / n * 100) / 100 })) }),
} }));
const { OdemeSozuModali } = await import('../bilesenler/borc/OdemeSozuModali');

describe('OdemeSozuModali', () => {
  it('söz: tutar varsayılanı borç, kayıt hasta bazında', async () => {
    soz.mockResolvedValue({ id: 1 });
    const kapat = vi.fn(), kaydedildi = vi.fn();
    render(<OdemeSozuModali hastaId={7} hastaAdi="Ali" borc={1250.5} onKapat={kapat} onKaydedildi={kaydedildi} />);
    expect((screen.getByLabelText('Tutar') as HTMLInputElement).value).toBe('1250.5');
    fireEvent.click(screen.getByText(/Kaydet/));
    await waitFor(() => expect(soz).toHaveBeenCalled());
    expect(soz.mock.calls[0][0]).toMatchObject({ hastaId: 7, tur: 2, tutar: 1250.5 });
    expect(soz.mock.calls[0][0].taksitSayisi).toBeUndefined();
    await waitFor(() => expect(kapat).toHaveBeenCalled());
    expect(kaydedildi).toHaveBeenCalled();
  });

  it('plan: taksit tablosu ve taksit sayısı gider', async () => {
    soz.mockClear(); soz.mockResolvedValue({ id: 2 });
    render(<OdemeSozuModali hastaId={7} hastaAdi="Ali" borc={1000} onKapat={() => {}} />);
    fireEvent.click(screen.getByText(/Ödeme planı/));
    fireEvent.change(screen.getByLabelText('Taksit sayısı'), { target: { value: '3' } });
    await waitFor(() => expect(screen.getAllByRole('row')).toHaveLength(4));   // başlık + 3 taksit (sunucudan)
    expect(screen.getByText(/333,34/)).toBeTruthy();                            // kuruş farkı son taksitte
    fireEvent.click(screen.getByText(/Kaydet/));
    await waitFor(() => expect(soz).toHaveBeenCalled());
    expect(soz.mock.calls[0][0]).toMatchObject({ tur: 3, tutar: 1000, taksitSayisi: 3 });
  });
});
