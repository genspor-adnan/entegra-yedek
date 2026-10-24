// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { IzlemPenceresi } from '../bilesenler/belge/IzlemPenceresi';
import type { IzlemSatiri } from '../sayfalar/belgeSatir';

/**
 * ÇIKIŞ BELGESİNDE KAYITLI LOT DEĞİŞTİRME (kullanıcı 24.10.2026: "satış irs de lot değiştiremedim").
 *
 * Kayıtlı satırın lotları (sunucudan, `kalan`sız) pencereye gelince eskiden yalnız onlar listeleniyor,
 * depodaki diğer lotlar hiç çıkmıyor ve "Tamam" kalan 0 sayıldığı için "lotunda kaldı" diyordu.
 * Artık: depodaki lotlar + seçili lotlar birlikte, seçili lotun kalanına bu belgenin düştüğü miktar eklenir.
 */

vi.mock('../api/istemci', () => ({
  api: {
    // Depoda: A'dan 2 kaldı (bu belge 3 düşmüş), B'den 5. C tamamen bu belgeyle çıkmış - listede yok.
    stokLotlari: vi.fn().mockResolvedValue([
      { seriLotId: 3, lotNo: 'A', seriNo: '', kalan: 2, uretimTarihi: null, sonKullanmaTarihi: null },
      { seriLotId: 4, lotNo: 'B', seriNo: '', kalan: 5, uretimTarihi: null, sonKullanmaTarihi: null },
    ]),
  },
}));

const kayitli: IzlemSatiri[] = [
  { seriLotId: 3, lotNo: 'A', seriNo: '', uretimTarihi: '', sonKullanmaTarihi: '', durum: 0, miktar: '3' },
  { seriLotId: 9, lotNo: 'C', seriNo: '', uretimTarihi: '', sonKullanmaTarihi: '', durum: 0, miktar: '1' },
];

describe('cikista kayitli lot secimi', () => {
  it('depodaki lotlar + secili lotlar listelenir, B secilip kaydedilebilir', async () => {
    const onKaydet = vi.fn();
    render(<IzlemPenceresi stokAdi="X" stokId={1} depoId={1} izleme={4} miktar={4} satirlar={kayitli}
                           cikis onKapat={() => {}} onKaydet={onKaydet} />);
    await waitFor(() => expect(screen.getByDisplayValue('B')).toBeTruthy());
    expect(screen.getByDisplayValue('A')).toBeTruthy();
    expect(screen.getByDisplayValue('C')).toBeTruthy();
    // Değişmeden Tamam: seçim geçerli (A kalanı 2 + 3 = 5, C kalanı 1).
    fireEvent.click(screen.getByText(/Tamam/));
    expect(onKaydet).toHaveBeenCalledTimes(1);
    expect(onKaydet.mock.calls[0][0].map((z: IzlemSatiri) => [z.seriLotId, z.miktar]))
      .toEqual([[9, '1'], [3, '3']]);
  });
});

describe('Seri No sutunu (kullanici 24.10.2026)', () => {
  const ciz = (izleme: number, satirlar: IzlemSatiri[] = []) => render(
    <IzlemPenceresi stokAdi="X" stokId={null} depoId={1} izleme={izleme} miktar={1} satirlar={satirlar}
                    cikis={false} onKapat={() => {}} onKaydet={() => {}} />);
  const baslikVar = () => [...document.body.querySelectorAll('th')].some(t => (t.textContent ?? '').startsWith('Seri No'));
  it('Lot No + SKT stokta yok', () => { ciz(5); expect(baslikVar()).toBe(false) });
  it('Seri No + Lot No stokta var', () => { ciz(6); expect(baslikVar()).toBe(true) });
  it('Karekod stokta var', () => { ciz(4); expect(baslikVar()).toBe(true) });
  it('eski satirda seri girilmisse gizlenmez', () => {
    ciz(5, [{ lotNo: 'L', seriNo: 'S1', uretimTarihi: '', sonKullanmaTarihi: '', durum: 0, miktar: '1' }]);
    expect(baslikVar()).toBe(true);
  });
});

describe('Ürt. Tarihi + SKT sutunlari (kullanici 24.10.2026)', () => {
  const ciz = (izleme: number, satirlar: IzlemSatiri[] = []) => render(
    <IzlemPenceresi stokAdi="X" stokId={null} depoId={1} izleme={izleme} miktar={1} satirlar={satirlar}
                    cikis={false} onKapat={() => {}} onKaydet={() => {}} />);
  const basliklar = () => [...document.body.querySelectorAll('th')].map(t => t.textContent ?? '');
  const tarihVar = () => basliklar().some(b => b.startsWith('SKT')) && basliklar().some(b => b.startsWith('Ürt.'));
  const tarihYok = () => !basliklar().some(b => b.startsWith('SKT') || b.startsWith('Ürt.'));
  it('Lot No stokta yok', () => { ciz(2); expect(tarihYok()).toBe(true) });
  it('Seri No + Lot No stokta yok', () => { ciz(6); expect(tarihYok()).toBe(true) });
  it('Lot No + SKT stokta var', () => { ciz(5); expect(tarihVar()).toBe(true) });
  it('Karekod stokta var', () => { ciz(4); expect(tarihVar()).toBe(true) });
  it('eski satirda SKT girilmisse gizlenmez', () => {
    ciz(2, [{ lotNo: 'L', seriNo: '', uretimTarihi: '', sonKullanmaTarihi: '2030-01-01', durum: 0, miktar: '1' }]);
    expect(tarihVar()).toBe(true);
  });
});

describe('cikista miktar azaltilip yeniden artirilinca (kullanici 24.10.2026)', () => {
  it('oturumda birakilan kayitli lotlar yeniden secilebilir', async () => {
    const { api } = await import('../api/istemci');
    // Kayitli: A, B, C, D (1'er) - hepsi bu belgeyle cikmis, depoda yoklar. Depoda baska lot E (3).
    (api.stokLotlari as ReturnType<typeof vi.fn>).mockResolvedValueOnce([
      { seriLotId: 15, lotNo: 'E', seriNo: '', kalan: 3, uretimTarihi: null, sonKullanmaTarihi: null },
    ]);
    const lot = (id: number, ad: string, miktar: string, kalan?: number): IzlemSatiri =>
      ({ seriLotId: id, lotNo: ad, seriNo: '', uretimTarihi: '', sonKullanmaTarihi: '', durum: 0, miktar,
         ...(kalan !== undefined ? { kalan } : {}) });
    const kayitliLotlar = [lot(11, 'A', '1'), lot(12, 'B', '1'), lot(13, 'C', '1'), lot(14, 'D', '1')];
    // 4 -> 2'ye dusurulup Tamam denmis: guncel secim A, B (oturumda kalan'li).
    const guncel = [lot(11, 'A', '1', 1), lot(12, 'B', '1', 1)];
    const onKaydet = vi.fn();
    render(<IzlemPenceresi stokAdi="X" stokId={1} depoId={1} izleme={2} miktar={4} satirlar={guncel}
                           kayitli={kayitliLotlar} cikis onKapat={() => {}} onKaydet={onKaydet} />);
    await waitFor(() => expect(screen.getByDisplayValue('E')).toBeTruthy());
    for (const ad of ['A', 'B', 'C', 'D']) expect(screen.getByDisplayValue(ad)).toBeTruthy();
    // C ve D'yi yeniden sec: miktar kutulari (hiza-sag) satir sirasiyla.
    const satirlar = [...document.body.querySelectorAll('tbody tr')];
    const kutu = (ad: string) => satirlar.find(r => (r.querySelector('input') as HTMLInputElement)?.value === ad)!
      .querySelector('input.hiza-sag') as HTMLInputElement;
    fireEvent.change(kutu('C'), { target: { value: '1' } });
    fireEvent.change(kutu('D'), { target: { value: '1' } });
    fireEvent.click(screen.getAllByText(/Tamam/)[0]);
    expect(onKaydet).toHaveBeenCalledTimes(1);
    expect(onKaydet.mock.calls[0][0].map((z: IzlemSatiri) => z.lotNo).sort()).toEqual(['A', 'B', 'C', 'D']);
  });
});

