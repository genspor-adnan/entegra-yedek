// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, act, waitFor } from '@testing-library/react';

const kasaAvans = vi.fn();
const kasaAvansMahsup = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  get kasaAvans() { return kasaAvans },
  get kasaAvansMahsup() { return kasaAvansMahsup },
} }));

const { useAvansDurumu } = await import('../bilesenler/avansDurumu');

/**
 * AVANS DURUMU KANCASI (781/783).
 *
 * Serit, "⋯ > Avans Kullan" ve "Avans İade" menusu ayni nesneden okur; tutar
 * ve acik avans listesi burada cozulur. Kismi mahsup (783) govdeye TUTAR
 * koymali - koymazsa sunucu avansin TAMAMINI dagitir ve hastanin kalan
 * parasi yok olur.
 */
describe('useAvansDurumu', () => {
  beforeEach(() => {
    kasaAvans.mockReset();
    kasaAvansMahsup.mockReset();
    kasaAvans.mockResolvedValue({ toplam: 500, satirlar: [
      { kasaIslemId: 7, islemTarihi: '2026-09-16', dagitilmamis: 500 },
      // Kalani bitmis avans listede YER ALMAZ: iade/mahsup menusu kapali
      //   bir avansi secenek olarak sunmamali.
      { kasaIslemId: 8, islemTarihi: '2026-09-10', dagitilmamis: 0 },
    ] });
    kasaAvansMahsup.mockResolvedValue({ dagitilan: 120, islemSayisi: 1 });
  });

  it('acik avanslari okur, KALANI SIFIR olani elemez sayfaya koymaz', async () => {
    const { result } = renderHook(() => useAvansDurumu(42));
    await waitFor(() => expect(result.current.toplam).toBe(500));
    expect(result.current.satirlar.map(s => s.kasaIslemId)).toEqual([7]);
    expect(result.current.adet).toBe(1);
  });

  it('KISMI mahsupta govdeye tutar konur', async () => {
    const { result } = renderHook(() => useAvansDurumu(42));
    await waitFor(() => expect(result.current.toplam).toBe(500));
    await act(async () => { await result.current.mahsupEt(99, 120) });
    expect(kasaAvansMahsup).toHaveBeenCalledWith({ belgeId: 99, tutar: 120 });
  });

  it('tutar verilmezse alan HIC gonderilmez (tamami dagitilir)', async () => {
    const { result } = renderHook(() => useAvansDurumu(42));
    await waitFor(() => expect(result.current.toplam).toBe(500));
    await act(async () => { await result.current.mahsupEt(99) });
    expect(kasaAvansMahsup).toHaveBeenCalledWith({ belgeId: 99 });
  });

  it('mahsuptan sonra durum TAZELENIR - serit bayat kalmasin', async () => {
    const { result } = renderHook(() => useAvansDurumu(42));
    await waitFor(() => expect(result.current.toplam).toBe(500));
    kasaAvans.mockResolvedValue({ toplam: 380, satirlar: [
      { kasaIslemId: 7, islemTarihi: '2026-09-16', dagitilmamis: 380 }] });
    await act(async () => { await result.current.mahsupEt(99, 120) });
    await waitFor(() => expect(result.current.toplam).toBe(380));
  });

  it('taraf YOKSA istek atilmaz', async () => {
    renderHook(() => useAvansDurumu(null));
    expect(kasaAvans).not.toHaveBeenCalled();
  });
});
