// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, fireEvent, render, screen, waitFor, within } from '@testing-library/react';

/**
 * KRONİK TANI ve KULLANILAN İLAÇ KARTLARI (mockup Ekranlar/Muayene/
 * kronik_tani_karti · kullanilan_ilac_karti):
 *   * kronik: ICD seçilince ad kayda kopyalanır; aynı kod aktif kayıtta
 *     varsa mevcut kayıt açılır; "Geçmişe al" silmez, durum 3 + bitiş yazar;
 *   * ilaç: katalogdan seçim barkod/ad/madde doldurur; madde hastanın
 *     alerjisiyle çakışırsa uyarı çıkar (kayıt engellenmez); "İlacı bıraktı"
 *     aktif=0, uyum=3, bitiş yazar.
 */
const api = {
  kartOku: vi.fn(), kartGuncelle: vi.fn(), kartEkle: vi.fn(), kartAlanlari: vi.fn(), liste: vi.fn(),
};
vi.mock('../api/istemci', () => ({ api }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, onay: () => Promise.resolve(true), guvenli: (f: () => Promise<void>) => f(),
}));

const { KronikTaniKarti } = await import('../bilesenler/hasta/KronikTaniKarti');
const { IlacKaydiKarti } = await import('../bilesenler/hasta/IlacKaydiKarti');

const bugun = new Date().toISOString().slice(0, 10);

describe('kronik tanı kartı', () => {
  beforeEach(() => {
    Object.values(api).forEach(f => f.mockReset());
    api.kartAlanlari.mockResolvedValue({ alanlar: [{ ad: 'takipHekimId', kodlar: { '7': 'Dr. Kaya' } }] });
    api.kartEkle.mockResolvedValue({ kart: { id: 1 } });
    api.kartGuncelle.mockResolvedValue({ kart: { id: 1 } });
  });

  it('ICD seçimi adı kopyalar; yeni kayıt hasta + muayeneyle gider', async () => {
    api.liste.mockImplementation((kaynak: string) => Promise.resolve(kaynak === 'icd'
      ? { satirlar: [{ kod: 'J45.9', ad: 'Astım, tanımlanmamış' }], toplamKayit: 1 }
      : { satirlar: [], toplamKayit: 0 }));
    const onKapat = vi.fn();
    render(<KronikTaniKarti id="yeni" hastaId={3} hastaAdi="AYŞE" muayeneId={11} onKapat={onKapat} />);
    fireEvent.change(screen.getByLabelText(/ICD-10/), { target: { value: 'astım' } });
    await waitFor(() => expect(screen.getByRole('listbox')).toBeTruthy(), { timeout: 2000 });
    await act(async () => { within(screen.getByRole('listbox')).getByRole('option').click() });
    expect((screen.getByLabelText(/Tanı adı/) as HTMLInputElement).value).toBe('Astım, tanımlanmamış');
    await act(async () => { screen.getByText(/^💾 Kaydet$/).closest('button')!.click() });
    expect(api.kartEkle).toHaveBeenCalledWith('hasta-kronik', { kart: expect.objectContaining({
      hastaId: 3, icdKod: 'J45.9', taniAd: 'Astım, tanımlanmamış', kayitMuayeneId: 11, durum: 1 }) });
    expect(onKapat).toHaveBeenCalled();
  });

  it('aynı ICD aktif kayıtta varsa MEVCUT kayıt açılır (ikinci kayıt yok)', async () => {
    api.liste.mockImplementation((kaynak: string) => Promise.resolve(
      kaynak === 'icd' ? { satirlar: [{ kod: 'E11', ad: 'Tip 2 diyabet' }], toplamKayit: 1 }
      : kaynak === 'hasta-kronik' ? { satirlar: [{ id: 42, icdKod: 'E11', taniAd: 'Tip 2 diyabet', durum: 1 }], toplamKayit: 1 }
      : { satirlar: [], toplamKayit: 0 }));
    api.kartOku.mockResolvedValue({ kart: { id: 42, hastaId: 3, icdKod: 'E11', taniAd: 'Tip 2 diyabet',
      durum: 1, kaynak: 1, surum: 's' }, yetki: {}, izlemeNo: '' });
    render(<KronikTaniKarti id="yeni" hastaId={3} hastaAdi="AYŞE" onKapat={() => {}} />);
    await waitFor(() => expect(document.body.textContent).toContain('Mevcut: E11'));
    fireEvent.change(screen.getByLabelText(/ICD-10/), { target: { value: 'E11' } });
    await waitFor(() => expect(screen.getByRole('listbox')).toBeTruthy(), { timeout: 2000 });
    await act(async () => { within(screen.getByRole('listbox')).getByRole('option').click() });
    await waitFor(() => expect(api.kartOku).toHaveBeenCalledWith('hasta-kronik', 42));
    expect(document.body.textContent).toContain('#42');
  });

  it('Geçmişe al: silmez, durum 3 ve bitiş bugün yazar', async () => {
    api.liste.mockResolvedValue({ satirlar: [], toplamKayit: 0 });
    api.kartOku.mockResolvedValue({ kart: { id: 5, hastaId: 3, icdKod: 'I10', taniAd: 'HT', durum: 1,
      kaynak: 1, surum: 'v1' }, kodAd: { hastaId: { '3': 'AYŞE' } }, yetki: {}, izlemeNo: '' });
    render(<KronikTaniKarti id={5} onKapat={() => {}} />);
    await waitFor(() => expect(screen.getByText(/Geçmişe al/)).toBeTruthy());
    await act(async () => { screen.getByText(/Geçmişe al/).closest('button')!.click() });
    expect(api.kartGuncelle).toHaveBeenCalledWith('hasta-kronik', 5, { surum: 'v1', kart: { durum: 3, bitis: bugun } });
  });
});

describe('kullanılan ilaç kartı', () => {
  beforeEach(() => {
    Object.values(api).forEach(f => f.mockReset());
    api.kartEkle.mockResolvedValue({ kart: { id: 1 } });
    api.kartGuncelle.mockResolvedValue({ kart: { id: 1 } });
  });

  it('katalog seçimi barkod/ad/madde doldurur; alerjiyle çakışırsa uyarı, kayıt yine gider', async () => {
    api.liste.mockImplementation((kaynak: string) => Promise.resolve(
      kaynak === 'ilac' ? { satirlar: [{ barkod: '869', ad: 'AUGMENTIN BID 1000 MG', etkenMadde: 'amoksisilin, klavulanik asit', atcKod: 'J01CR02' }], toplamKayit: 1 }
      : kaynak === 'hasta-alerji' ? { satirlar: [{ id: 1, etken: 'Penisilin', etkenMadde: 'amoksisilin', aktif: 1 }], toplamKayit: 1 }
      : { satirlar: [], toplamKayit: 0 }));
    render(<IlacKaydiKarti id="yeni" hastaId={3} hastaAdi="AYŞE" onKapat={() => {}} />);
    fireEvent.change(screen.getByLabelText(/İlaç \(katalogdan\)/), { target: { value: 'augm' } });
    await waitFor(() => expect(screen.getByRole('listbox')).toBeTruthy(), { timeout: 2000 });
    await act(async () => { within(screen.getByRole('listbox')).getByRole('option').click() });
    await waitFor(() => expect(document.body.textContent).toContain('⚠ amoksisilin'));
    expect(document.body.textContent).toContain('J01CR02');
    await act(async () => { screen.getByText(/^💾 Kaydet$/).closest('button')!.click() });
    expect(api.kartEkle).toHaveBeenCalledWith('hasta-ilac', { kart: expect.objectContaining({
      hastaId: 3, ilacBarkod: '869', ilacAd: 'AUGMENTIN BID 1000 MG',
      etkenMadde: 'amoksisilin, klavulanik asit', kaynak: 2, uyum: 1, aktif: 1 }) });
  });

  it('İlacı bıraktı: silmez, aktif=0, uyum=3, bitiş bugün', async () => {
    api.liste.mockResolvedValue({ satirlar: [], toplamKayit: 0 });
    api.kartOku.mockResolvedValue({ kart: { id: 8, hastaId: 3, ilacAd: 'Glifor', etkenMadde: 'metformin',
      kaynak: 2, uyum: 1, aktif: 1, surum: 'q' }, yetki: {}, izlemeNo: '' });
    render(<IlacKaydiKarti id={8} hastaAdi="AYŞE" onKapat={() => {}} />);
    await waitFor(() => expect(screen.getByText(/İlacı bıraktı/)).toBeTruthy());
    await act(async () => { screen.getByText(/İlacı bıraktı/).closest('button')!.click() });
    expect(api.kartGuncelle).toHaveBeenCalledWith('hasta-ilac', 8,
      { surum: 'q', kart: { aktif: 0, uyum: 3, bitis: bugun } });
  });
});
