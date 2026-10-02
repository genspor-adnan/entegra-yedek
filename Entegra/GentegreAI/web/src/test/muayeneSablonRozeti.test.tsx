// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render, waitFor } from '@testing-library/react';

/**
 * ÖNERİLEN ŞABLON ROZETİ (933, kullanıcı: "muayene sırasında doktor adına şablon
 * varsa onu kullansın yoksa genel branş şablonu"): öneri sunucudan; doktorun
 * şablonu 👤, bölümünkü 🩺; tık o şablonu uygular; öneri yoksa rozet yok.
 */
const api = { muayeneSablonlari: vi.fn(), muayeneSablonUygula: vi.fn() };
vi.mock('../api/istemci', () => ({ api }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, onay: () => Promise.resolve(true), guvenli: (f: () => Promise<void>) => f(),
}));
const { MuayeneSablonRozeti } = await import('../bilesenler/MuayeneSablonRozeti');

const s = (id: number, ad: string, oncelik: number) =>
  ({ id, ad, tur: 1, varsayilan: false, oncelik, doktor: '', alanSayisi: 5 });

describe('önerilen şablon rozeti', () => {
  beforeEach(() => { Object.values(api).forEach(f => f.mockReset()) });

  it('doktorun şablonu varsa 👤 onu önerir ve tıkta uygular', async () => {
    api.muayeneSablonlari.mockResolvedValue({ sablonlar: [], onerilen: s(50, 'Benim KBB', 0) });
    api.muayeneSablonUygula.mockResolvedValue({ mesaj: 'ok' });
    const onUygulandi = vi.fn();
    render(<MuayeneSablonRozeti muayeneId={9} onUygulandi={onUygulandi} />);
    await waitFor(() => expect(document.body.textContent).toContain('👤 Benim KBB'));
    await act(async () => { (document.querySelector('button') as HTMLButtonElement).click() });
    expect(api.muayeneSablonUygula).toHaveBeenCalledWith(9, 50);
    expect(onUygulandi).toHaveBeenCalled();
  });

  it('doktorunki yoksa bölüm şablonu 🩺; öneri yoksa hiç çizilmez', async () => {
    api.muayeneSablonlari.mockResolvedValue({ sablonlar: [], onerilen: s(2, 'Dahiliye Genel', 1) });
    const { unmount } = render(<MuayeneSablonRozeti muayeneId={9} onUygulandi={() => {}} />);
    await waitFor(() => expect(document.body.textContent).toContain('🩺 Dahiliye Genel'));
    unmount();
    api.muayeneSablonlari.mockResolvedValue({ sablonlar: [], onerilen: null });
    render(<MuayeneSablonRozeti muayeneId={9} onUygulandi={() => {}} />);
    await waitFor(() => expect(api.muayeneSablonlari).toHaveBeenCalledTimes(2));
    expect(document.querySelector('button')).toBeNull();
  });
});
