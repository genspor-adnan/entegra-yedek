// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, fireEvent, render, screen, waitFor, within } from '@testing-library/react';

/**
 * GEÇMİŞ OLAY KARTI (mockup Ekranlar/Muayene/gecmis_olay_karti.html):
 * tür aramayı belirler (aşı → aşı listesi, kod = SKRS kodu); "yalnız yıl"
 * 1 Ocak saklar ve yalnız yılı gösterir; zaman çizgisinde tıklanan olay
 * açılır; Sil yalnız kayıtlı olayda.
 */
const api = { kartOku: vi.fn(), kartGuncelle: vi.fn(), kartEkle: vi.fn(), kartSil: vi.fn(), liste: vi.fn() };
vi.mock('../api/istemci', () => ({ api }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, onay: () => Promise.resolve(true), guvenli: (f: () => Promise<void>) => f(),
}));

const { GecmisOlayKarti, olayTarihi } = await import('../bilesenler/hasta/GecmisOlayKarti');

describe('geçmiş olay kartı', () => {
  beforeEach(() => {
    Object.values(api).forEach(f => f.mockReset());
    api.kartEkle.mockResolvedValue({ kart: { id: 1 } });
  });

  it('olay tarihi: 1 Ocak = yalnız yıl', () => {
    expect(olayTarihi('1998-01-01')).toBe('1998');
    expect(olayTarihi('2023-05-17T00:00:00')).toBe('17.05.2023');
    expect(olayTarihi('')).toBe('');
  });

  it('Aşı türünde aşı listesinden seçilir, kod SKRS kodu olur; yalnız yıl 1 Ocak kaydedilir', async () => {
    api.liste.mockImplementation((kaynak: string) => Promise.resolve(kaynak === 'asi'
      ? { satirlar: [{ kod: 'INF', ad: 'İnfluenza aşısı', skrsKod: '10054' }], toplamKayit: 1 }
      : { satirlar: [], toplamKayit: 0 }));
    const onKapat = vi.fn();
    render(<GecmisOlayKarti id="yeni" hastaId={3} hastaAdi="AYŞE" muayeneId={11} onKapat={onKapat} />);
    await act(async () => { screen.getByRole('radio', { name: /Aşı/ }).click() });
    expect(screen.getByLabelText(/Aşı \(aşı listesinden\)/)).toBeTruthy();
    fireEvent.change(screen.getByLabelText(/Aşı \(aşı listesinden\)/), { target: { value: 'influ' } });
    await waitFor(() => expect(screen.getByRole('listbox')).toBeTruthy(), { timeout: 2000 });
    await act(async () => { within(screen.getByRole('listbox')).getByRole('option').click() });
    expect((screen.getByLabelText(/Kod \(SUT/) as HTMLInputElement).value).toBe('10054');

    await act(async () => { fireEvent.click(screen.getByLabelText('Yalnız yıl')) });
    fireEvent.change(screen.getByPlaceholderText('YYYY'), { target: { value: '2024' } });
    await act(async () => { screen.getByText(/^💾 Kaydet$/).closest('button')!.click() });
    expect(api.kartEkle).toHaveBeenCalledWith('hasta-gecmis', { kart: expect.objectContaining({
      hastaId: 3, tur: 4, ad: 'İnfluenza aşısı', kod: '10054', tarih: '2024-01-01', kaynak: 2 }) });
    expect(onKapat).toHaveBeenCalled();
  });

  it('zaman çizgisinde tıklanan olay açılır; yeni kayıtta Sil yok', async () => {
    api.liste.mockImplementation((kaynak: string) => Promise.resolve(kaynak === 'hasta-gecmis'
      ? { satirlar: [
          { id: 7, tur: 1, ad: 'Apendektomi', tarih: '1998-01-01', kurum: 'Numune' },
          { id: 8, tur: 4, ad: 'İnfluenza', tarih: '2025-10-01' },
        ], toplamKayit: 2 }
      : { satirlar: [], toplamKayit: 0 }));
    api.kartOku.mockResolvedValue({ kart: { id: 7, hastaId: 3, tur: 1, ad: 'Apendektomi', kod: '612460',
      tarih: '1998-01-01', kurum: 'Numune', notMetni: '', kaynak: 2, surum: 'v' }, yetki: {}, izlemeNo: '' });
    render(<GecmisOlayKarti id="yeni" hastaId={3} hastaAdi="AYŞE" onKapat={() => {}} />);
    expect(screen.queryByText(/🗑 Sil/)).toBeNull();
    await waitFor(() => expect(screen.getByText('Apendektomi')).toBeTruthy());
    // Yeni tarih önce: İnfluenza (2025) Apendektomi'den (1998) önce.
    const satirlar = [...document.querySelectorAll('.go-cizgi li')].map(l => l.textContent ?? '');
    expect(satirlar[0]).toContain('İnfluenza');
    expect(satirlar[1]).toContain('1998');
    await act(async () => { screen.getByText('Apendektomi').closest('button')!.click() });
    await waitFor(() => expect(api.kartOku).toHaveBeenCalledWith('hasta-gecmis', 7));
    await waitFor(() => expect(screen.getByText(/🗑 Sil/)).toBeTruthy());
  });
});
