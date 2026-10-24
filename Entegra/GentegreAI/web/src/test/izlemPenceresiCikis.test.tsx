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

