// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render } from '@testing-library/react';
import { PosSecModali } from '../bilesenler/banko/PosSecModali';

/**
 * TEK POS DOĞRUDAN SEÇİLİR (09.10.2026, kullanıcı: "tek pos varsa direkt
 * seçilmiş olsun pos tahsilatında"). Birden çok terminalde pencere açılır.
 */
const pos = (id: number) => ({ id, hesapAdi: `POS ${id}`, terminalNo: `00${id}`, varsayilan: false,
  oturumId: 17, bankoId: 6, bankoAd: 'Banko 01', hesapId: 280 + id });
let liste = [pos(5)];
vi.mock('../api/istemci', () => ({ api: { bankoOturumPosSecenekleri: () => Promise.resolve(liste) } }));

beforeEach(() => { liste = [pos(5)] });

describe('POS seçimi', () => {
  it('tek POS varsa pencere açılmadan seçilir', async () => {
    const onSec = vi.fn();
    const k = render(<PosSecModali onSec={onSec} onKapat={() => {}} onOturumYok={() => {}} />);
    await act(async () => { await Promise.resolve() });
    expect(onSec).toHaveBeenCalledTimes(1);
    expect(onSec.mock.calls[0][0].id).toBe(5);
    expect(k.container.textContent).not.toContain('POS Seç');
  });

  it('birden çok POS varsa pencere açılır, seçim kullanıcıya kalır', async () => {
    liste = [pos(5), pos(6)];
    const onSec = vi.fn();
    const k = render(<PosSecModali onSec={onSec} onKapat={() => {}} onOturumYok={() => {}} />);
    await act(async () => { await Promise.resolve() });
    expect(onSec).not.toHaveBeenCalled();
    expect(k.container.textContent).toContain('POS Seç');
  });
});
