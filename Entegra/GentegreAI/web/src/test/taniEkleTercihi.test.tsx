// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, renderHook, waitFor } from '@testing-library/react';

/**
 * ICD PENCERESİ TÜR / TARAF (kullanıcı): tür = Kesin / Ön Tanı, taraf = Sağ /
 * Sol / Bilateral; en son bırakılan seçim pencere açılınca seçili gelir -
 * hesapta (`taniEkle` tercihi), yerelde kopya.
 */
const tercihler = vi.fn();
const tercihYaz = vi.fn();
const secenekler = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  tercihler: () => tercihler(),
  tercihYaz: (...a: unknown[]) => tercihYaz(...a),
  muayeneTaniSecenekleri: () => secenekler(),
} }));

const { useTaniEkleTercihi } = await import('../bilesenler/taniEkleTercihi');

describe('tanı ekleme tercihi', () => {
  beforeEach(() => {
    localStorage.clear();
    tercihler.mockReset(); tercihYaz.mockReset(); secenekler.mockReset();
    tercihYaz.mockResolvedValue({});
  });

  it('uç yoksa (eski API) yedek listeler: Kesin/Ön, —/Sağ/Sol/Bilateral; varsayılan Kesin ve —', async () => {
    tercihler.mockRejectedValue(new Error('x'));
    secenekler.mockRejectedValue(new Error('404'));
    const { result } = renderHook(() => useTaniEkleTercihi(true, 7));
    await waitFor(() => expect(secenekler).toHaveBeenCalled());
    expect(result.current.kesinlikler.map(k => k.ad)).toEqual(['Kesin Tanı', 'Ön Tanı']);
    expect(result.current.taraflar.map(k => k.ad)).toEqual(['—', 'Sağ', 'Sol', 'Bilateral']);
    expect(result.current.kesinlik).toBe(1);
    expect(result.current.taraf).toBe(0);
  });

  it('seçim hesaba ve yerele yazılır; yeniden açılınca hesaptaki son seçim gelir', async () => {
    tercihler.mockResolvedValue({});
    secenekler.mockResolvedValue({ kesinlikler: [{ kod: 1, ad: 'Kesin Tanı' }, { kod: 2, ad: 'Ön Tanı' }],
                                   taraflar: [{ kod: 0, ad: '—' }, { kod: 1, ad: 'Sağ' }] });
    const ilk = renderHook(() => useTaniEkleTercihi(true, 7));
    await waitFor(() => expect(tercihler).toHaveBeenCalled());
    act(() => ilk.result.current.setKesinlik(2));
    act(() => ilk.result.current.setTaraf(3));
    expect(tercihYaz).toHaveBeenLastCalledWith('taniEkle', JSON.stringify({ kesinlik: 2, taraf: 3 }));
    expect(localStorage.getItem('taniEkle.7')).toBe(JSON.stringify({ kesinlik: 2, taraf: 3 }));
    ilk.unmount();

    // Başka makinede değişmiş: hesap yerel kopyayı ezer.
    tercihler.mockResolvedValue({ taniEkle: JSON.stringify({ kesinlik: 1, taraf: 2 }) });
    const ikinci = renderHook(() => useTaniEkleTercihi(true, 7));
    expect(ikinci.result.current.kesinlik).toBe(2);           // anında yerel kopya
    await waitFor(() => expect(ikinci.result.current.taraf).toBe(2));
    expect(ikinci.result.current.kesinlik).toBe(1);
  });
});
