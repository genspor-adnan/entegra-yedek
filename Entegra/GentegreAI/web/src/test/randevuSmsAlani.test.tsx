// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';

/**
 * RANDEVU KARTI › SMS (1382): işaret kayda gider, metin şube önizlemesinden gelir ve kartta değiştirilebilir,
 * şube hatırlatması açıksa ikinci işaret çıkar; telefon yoksa uyarı.
 */
const onizleme = vi.fn();
vi.mock('../api/istemci', () => ({ api: { randevuSmsOnizleme: (g: unknown) => onizleme(g) } }));
const { RandevuSmsAlani } = await import('../bilesenler/RandevuSmsAlani');

describe('RandevuSmsAlani', () => {
  it('önizleme metni, işaretler ve elle metin', async () => {
    onizleme.mockResolvedValue({ bilgi: 'Sayın Ali, 20.11.2026 10:00 randevunuz', telefonVar: true,
                                 hatirlatmaAcik: true, hatirlatmaSaat: 24, bilgiGitti: false });
    const degistir = vi.fn();
    render(<RandevuSmsAlani deger={{ hastaId: 5, baslangic: '2026-11-20T10:00', smsGonder: true, smsHatirlatma: true }}
                            alanDegistir={degistir} id={null} salt={false} />);
    const metin = await screen.findByLabelText('SMS metni') as HTMLTextAreaElement;
    await waitFor(() => expect(metin.value).toBe('Sayın Ali, 20.11.2026 10:00 randevunuz'));
    expect(onizleme).toHaveBeenCalledWith(expect.objectContaining({ hastaId: 5, baslangic: '2026-11-20T10:00' }));

    fireEvent.change(metin, { target: { value: 'Elle metin' } });
    expect(degistir).toHaveBeenCalledWith('smsMetni', 'Elle metin');
    fireEvent.click(screen.getByLabelText('SMS Gönder'));
    expect(degistir).toHaveBeenCalledWith('smsGonder', false);
    expect(screen.getByText(/24 saat önce/)).toBeTruthy();
    fireEvent.click(screen.getByLabelText('Hatırlatma SMS\'i'));
    expect(degistir).toHaveBeenCalledWith('smsHatirlatma', false);
  });

  it('telefon yoksa uyarı; şube hatırlatması kapalıysa ikinci işaret yok', async () => {
    onizleme.mockResolvedValue({ bilgi: 'x', telefonVar: false, hatirlatmaAcik: false, hatirlatmaSaat: 24, bilgiGitti: false });
    render(<RandevuSmsAlani deger={{ hastaId: 7, smsGonder: true }} alanDegistir={() => {}} id={null} salt={false} />);
    expect(await screen.findByText(/cep telefonu yok/)).toBeTruthy();
    expect(screen.queryByLabelText('Hatırlatma SMS\'i')).toBeNull();
  });
});
