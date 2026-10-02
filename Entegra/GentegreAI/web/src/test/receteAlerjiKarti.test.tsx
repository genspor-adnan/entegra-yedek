// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react';

/**
 * REÇETE ve ALERJİ KARTLARI (mockup Ekranlar/Muayene/recete_karti ·
 * alerji_karti). Kurallar:
 *   * reçete: taslakta tür/açıklama yazılır; imzalıda düzenleme düğmeleri
 *     yok, Medula'ya Gönder var; tanılar muayeneden okunur;
 *   * alerji: hızlı reaksiyon çipi metne ekler/çıkarır; yeni kayıt hastayı ve
 *     açan muayeneyi yazar; "Pasif yap" silmez, aktif=0 yazar.
 */
const api = {
  kartOku: vi.fn(), kartGuncelle: vi.fn(), kartEkle: vi.fn(), kartSil: vi.fn(),
  liste: vi.fn(), muayeneTanilari: vi.fn(),
  receteImzala: vi.fn(), medulaReceteGonder: vi.fn(), receteOncekiKopyala: vi.fn(),
  receteIlacSil: vi.fn(), receteIlacEkle: vi.fn(), receteSatirGuncelle: vi.fn(),
};
vi.mock('../api/istemci', () => ({ api }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, onay: () => Promise.resolve(true), guvenli: (f: () => Promise<void>) => f(),
}));
// Gomulu grid bu testin konusu degil.
vi.mock('../bilesenler/GenGrid', () => ({ GenGrid: () => <div data-testid="grid" /> }));

const { ReceteKarti } = await import('../bilesenler/recete/ReceteKarti');
const { AlerjiKarti } = await import('../bilesenler/hasta/AlerjiKarti');

const bosListe = { satirlar: [], toplamKayit: 0 };

describe('reçete kartı', () => {
  beforeEach(() => {
    Object.values(api).forEach(f => f.mockReset());
    api.liste.mockImplementation((kaynak: string) => Promise.resolve(
      kaynak === 'muayene'
        ? { satirlar: [{ id: 11, hastaAdi: 'AYŞE YILMAZ', bolumAdi: 'İç Hastalıkları' }], toplamKayit: 1 }
        : bosListe));
    api.muayeneTanilari.mockResolvedValue({ tanilar: [{ id: 1, kod: 'J03.9', ad: 'Akut tonsillit', tur: 1 }] });
  });

  it('taslak: tanı muayeneden görünür, tür değişince Kaydet yalnız tür/açıklama yazar', async () => {
    api.kartOku.mockResolvedValue({ kart: { id: 5, muayeneId: 11, hastaId: 3, tur: 0, aciklama: '',
                                            durum: 1, surum: 'x1' }, yetki: {}, izlemeNo: '' });
    api.kartGuncelle.mockResolvedValue({ kart: { id: 5, tur: 1, durum: 1, surum: 'x2' } });
    render(<ReceteKarti receteId={5} onKapat={() => {}} />);
    await waitFor(() => expect(document.body.textContent).toContain('J03.9'));
    expect(document.body.textContent).toContain('AYŞE YILMAZ');

    await act(async () => { screen.getByRole('radio', { name: /Kırmızı/ }).click() });
    await act(async () => { screen.getByText(/Kaydet/).closest('button')!.click() });
    expect(api.kartGuncelle).toHaveBeenCalledWith('recete', 5, { surum: 'x1', kart: { tur: 1, aciklama: '' } });
  });

  it('imzalı: düzenleme / e-İmzala yok, Medula\'ya Gönder var', async () => {
    api.kartOku.mockResolvedValue({ kart: { id: 6, muayeneId: 11, hastaId: 3, tur: 0, durum: 2,
                                            receteNo: 'R-1', surum: 'y' }, yetki: {}, izlemeNo: '' });
    render(<ReceteKarti receteId={6} onKapat={() => {}} />);
    await waitFor(() => expect(document.body.textContent).toContain("Medula'ya Gönder"));
    expect(document.body.textContent).not.toContain('e-İmzala');
    expect(screen.queryByText(/＋ İlaç/)).toBeNull();
  });
});

describe('alerji kartı', () => {
  beforeEach(() => {
    Object.values(api).forEach(f => f.mockReset());
    api.liste.mockResolvedValue(bosListe);
    api.kartEkle.mockResolvedValue({ kart: { id: 9 } });
    api.kartGuncelle.mockResolvedValue({ kart: { id: 9 } });
  });

  it('yeni: hızlı reaksiyon çipi metne ekler; kayıt hasta ve açan muayeneyle gider', async () => {
    const onKapat = vi.fn();
    render(<AlerjiKarti id="yeni" hastaId={3} hastaAdi="AYŞE YILMAZ" muayeneId={11} onKapat={onKapat} />);
    fireEvent.change(screen.getByLabelText(/^Etken \(/), { target: { value: 'Penisilin' } });
    fireEvent.change(screen.getByLabelText(/Etken madde/), { target: { value: 'benzilpenisilin' } });
    await act(async () => { screen.getByRole('button', { name: 'Ürtiker' }).click() });
    await act(async () => { screen.getByRole('button', { name: 'Anjiyoödem' }).click() });
    expect((screen.getByLabelText('Reaksiyon') as HTMLInputElement).value).toBe('Ürtiker, Anjiyoödem');
    await act(async () => { screen.getByRole('button', { name: 'Ürtiker' }).click() });
    expect((screen.getByLabelText('Reaksiyon') as HTMLInputElement).value).toBe('Anjiyoödem');
    await act(async () => { screen.getByRole('radio', { name: 'Anafilaksi' }).click() });

    await act(async () => { screen.getByText(/^💾 Kaydet$/).closest('button')!.click() });
    expect(api.kartEkle).toHaveBeenCalledWith('hasta-alerji', { kart: expect.objectContaining({
      hastaId: 3, kayitMuayeneId: 11, etken: 'Penisilin', etkenMadde: 'benzilpenisilin',
      reaksiyon: 'Anjiyoödem', siddet: 4, tur: 1, aktif: 1 }) });
    expect(onKapat).toHaveBeenCalled();
  });

  it('kayıtlı: Pasif yap silmez, yalnız aktif=0 yazar', async () => {
    api.kartOku.mockResolvedValue({ kart: { id: 9, hastaId: 3, tur: 1, etken: 'Penisilin',
      etkenMadde: 'benzilpenisilin', reaksiyon: '', siddet: 3, kaynak: 1, dogrulandi: 0, aktif: 1,
      kayitMuayeneId: 11, surum: 's1' }, kodAd: { hastaId: { '3': 'AYŞE YILMAZ' } }, yetki: {}, izlemeNo: '' });
    render(<AlerjiKarti id={9} onKapat={() => {}} />);
    await waitFor(() => expect(screen.getByText(/Pasif yap/)).toBeTruthy());
    await act(async () => { screen.getByText(/Pasif yap/).closest('button')!.click() });
    expect(api.kartSil).not.toHaveBeenCalled();
    expect(api.kartGuncelle).toHaveBeenCalledWith('hasta-alerji', 9, { surum: 's1', kart: { aktif: 0 } });
  });
});
