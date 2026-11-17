// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { act, fireEvent, render, screen } from '@testing-library/react';

/** ONAY KODU PENCERESİ (17.11.2026): yanlış kodda kapanmaz, hata gösterir; doğru kodda onDogrulandi. */
const kodDogrula = vi.fn();
vi.mock('../api/istemci', () => ({ api: { basvuruKvkkKod: (...a: unknown[]) => kodDogrula(...a) } }));
const { KvkkKodPenceresi } = await import('../bilesenler/belge/KvkkKodPenceresi');

describe('KVKK onay kodu penceresi', () => {
  it('yanlış kod: hata görünür, pencere kapanmaz; doğru kod: onDogrulandi', async () => {
    const onDogrulandi = vi.fn(), onKapat = vi.fn();
    kodDogrula.mockRejectedValueOnce(new Error('Onay kodu hatalı - hastaya gönderilen kodla eşleşmiyor.'))
              .mockResolvedValueOnce({ kod: '123456', kvkkOnay: 4, etkOnay: 4 });
    render(<KvkkKodPenceresi belgeId={7} alici="***4178" onDogrulandi={onDogrulandi} onKapat={onKapat} />);
    fireEvent.change(screen.getByTestId('kvkk-kod-girdi'), { target: { value: '999999' } });
    await act(async () => { screen.getByTestId('kvkk-kod-dogrula').click() });
    expect(screen.getByTestId('kvkk-kod-hata').textContent).toContain('hatalı');
    expect(onKapat).not.toHaveBeenCalled();
    expect(onDogrulandi).not.toHaveBeenCalled();
    fireEvent.change(screen.getByTestId('kvkk-kod-girdi'), { target: { value: '123456' } });
    await act(async () => { screen.getByTestId('kvkk-kod-dogrula').click() });
    expect(onDogrulandi).toHaveBeenCalledWith({ kod: '123456', kvkkOnay: 4, etkOnay: 4 });
    expect(kodDogrula).toHaveBeenLastCalledWith(7, '123456');
  });
});
