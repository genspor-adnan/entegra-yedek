// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { useState } from 'react';
import type { KartMetaYaniti } from '../api/sozlesme';

/**
 * ÇEK / SENET BAŞLIĞI (kullanıcı 20.11.2026: "uygula.. view/edit deseni de yap", "çekin içinde cari arama editi
 * olmasın"): cari bantta (arama kutusu yok, avatar cariyi değiştirir); tutar / vade / seri no yalnız ✎ ile düzenlemede;
 * portföyden çıkmış kıymet kilitli.
 */
vi.mock('../api/istemci', () => ({
  api: { liste: async () => ({ satirlar: [{ id: 7, kod: '120.01.012', unvan: 'Akana Mühendislik Ltd. Şti.' }] }) },
}));
const { CekSenetBasligi, vadeBilgisi } = await import('../bilesenler/kart/CekSenetBasligi');
const { KartKipBaglami } = await import('../bilesenler/kart/KipKalemi');
const { KIPLI_GOVDE_KARTLAR } = await import('../bilesenler/kart/KartKimlikSeridi');

const meta = { alanlar: [{ ad: 'durum', kodlar: { '10': 'Portföyde', '20': 'Ciro Edildi' } },
                         { ad: 'ciroTarafId', kodlar: { '9': 'Akın Hırdavat' } }] } as unknown as KartMetaYaniti;

function Sarmal({ deger, yeniMi = false, cariAra }: { deger: Record<string, unknown>; yeniMi?: boolean; cariAra?(): void }) {
  const [acik, setAcik] = useState(yeniMi);
  return (
    <MemoryRouter>
      <KartKipBaglami.Provider value={{ acik, pasif: false, degistir: () => setAcik(v => !v) }}>
        <CekSenetBasligi deger={deger as never} meta={meta} yeniMi={yeniMi} cariAra={cariAra}
                         duzenAlanlari={<input data-testid="tutar-kutusu" />} />
      </KartKipBaglami.Provider>
    </MemoryRouter>
  );
}
const cek = { id: 3, tarafId: 7, tutar: 45000, dovizCinsi: 'TL', vade: '2026-12-05', seriNo: 'A-1', durum: 10, tur: 1, yon: 1 };

describe('çek / senet başlığı', () => {
  it('kipli kartlar arasında', () => { expect(KIPLI_GOVDE_KARTLAR.has('cek-senet')).toBe(true) });

  it('görüntülemede tutar bantta, düzenleme alanı yok; ✎ açar', async () => {
    render(<Sarmal deger={cek} />);
    expect(await screen.findByText('Akana Mühendislik Ltd. Şti.')).toBeTruthy();
    expect(screen.getByTestId('cek-senet-tutar').textContent).toContain('45.000,00 ₺');
    expect(screen.queryByTestId('tutar-kutusu')).toBeNull();
    expect(screen.getByTestId('cek-senet-basligi').querySelector('input[placeholder]')).toBeNull();
    fireEvent.click(screen.getByTestId('cek-senet-kalem'));
    expect(screen.getByTestId('tutar-kutusu')).toBeTruthy();
  });

  it('avatar cari aramasını açar ve kartı düzenlemeye geçirir', () => {
    const ara = vi.fn();
    render(<Sarmal deger={cek} cariAra={ara} />);
    fireEvent.click(screen.getByTestId('cek-senet-avatar'));
    expect(ara).toHaveBeenCalledOnce();
    expect(screen.getByTestId('tutar-kutusu')).toBeTruthy();
  });

  it('ciro edilmiş çek kilitli: ✎ pasif, avatar tıklanmaz, iz şeridi', () => {
    const ara = vi.fn();
    render(<Sarmal deger={{ ...cek, durum: 20, ciroTarafId: 9 }} cariAra={ara} />);
    expect((screen.getByTestId('cek-senet-kalem') as HTMLButtonElement).disabled).toBe(true);
    fireEvent.click(screen.getByTestId('cek-senet-avatar'));
    expect(ara).not.toHaveBeenCalled();
    expect(screen.getByText('Akın Hırdavat')).toBeTruthy();
  });

  it('vade: kalan / geçen gün ve renk', () => {
    const bugun = new Date(2026, 10, 20, 15, 0);
    expect(vadeBilgisi('2026-12-05', bugun)).toEqual({ gun: '05.12.2026', alt: '15 gün kaldı', sinif: 'sari' });
    expect(vadeBilgisi('2026-11-10', bugun)?.sinif).toBe('kir');
    expect(vadeBilgisi('2027-03-01', bugun)?.sinif).toBe('');
    expect(vadeBilgisi('', bugun)).toBeNull();
  });
});
