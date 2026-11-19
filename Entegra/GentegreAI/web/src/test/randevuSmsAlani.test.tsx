// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';

/**
 * RANDEVU KARTI › SMS bölümü (1382; 19.11.2026: "SMS Gönder" işareti başlık bandına taşındı, mesaj kutusu kalktı):
 * bölümde yalnız şube hatırlatması açıksa hatırlatma işareti, telefon yoksa uyarı; söylenecek bir şey yoksa çizilmez.
 */
const onizleme = vi.fn();
vi.mock('../api/istemci', () => ({ api: { randevuSmsOnizleme: (g: unknown) => onizleme(g) } }));
const { RandevuSmsAlani } = await import('../bilesenler/RandevuSmsAlani');

describe('RandevuSmsAlani', () => {
  it('hatırlatma işareti; mesaj kutusu ve SMS Gönder işareti yok', async () => {
    onizleme.mockResolvedValue({ bilgi: 'x', telefonVar: true, hatirlatmaAcik: true, hatirlatmaSaat: 24, bilgiGitti: false });
    const degistir = vi.fn();
    render(<RandevuSmsAlani deger={{ hastaId: 5, baslangic: '2026-11-20T10:00', smsGonder: true, smsHatirlatma: true }}
                            alanDegistir={degistir} id={null} salt={false} />);
    await waitFor(() => expect(screen.getByText(/24 saat önce/)).toBeTruthy());
    expect(onizleme).toHaveBeenCalledWith(expect.objectContaining({ hastaId: 5, baslangic: '2026-11-20T10:00' }));
    expect(screen.queryByLabelText('SMS metni')).toBeNull();
    expect(screen.queryByLabelText('SMS Gönder')).toBeNull();
    fireEvent.click(screen.getByLabelText('Hatırlatma SMS\'i'));
    expect(degistir).toHaveBeenCalledWith('smsHatirlatma', false);
  });

  it('telefon yoksa uyarı; söylenecek bir şey yoksa bölüm çizilmez', async () => {
    onizleme.mockResolvedValue({ bilgi: 'x', telefonVar: false, hatirlatmaAcik: false, hatirlatmaSaat: 24, bilgiGitti: false });
    const { unmount } = render(<RandevuSmsAlani deger={{ hastaId: 7, smsGonder: true }} alanDegistir={() => {}} id={null} salt={false} />);
    expect(await screen.findByText(/cep telefonu yok/)).toBeTruthy();
    expect(screen.queryByLabelText('Hatırlatma SMS\'i')).toBeNull();
    unmount();

    onizleme.mockResolvedValue({ bilgi: 'x', telefonVar: true, hatirlatmaAcik: false, hatirlatmaSaat: 24, bilgiGitti: false });
    const { container } = render(<RandevuSmsAlani deger={{ hastaId: 7, smsGonder: true }} alanDegistir={() => {}} id={null} salt={false} />);
    await waitFor(() => expect(onizleme).toHaveBeenCalledTimes(2));
    await new Promise(r => setTimeout(r, 400));
    expect(container.querySelector('.rv-sms')).toBeNull();
  });
});
