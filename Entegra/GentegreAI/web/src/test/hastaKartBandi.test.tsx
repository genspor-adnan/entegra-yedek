// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';

/**
 * HASTA KARTI İSİM BANDI 3. SATIR (kullanıcı 17.11.2026): avatar + ad soyad hücresinde doğum tarihi · kimlik no ·
 * durum rozeti; etiketsiz.
 */
const ozet = {
  dogumTarihi: '1979-03-14', cinsiyet: 2, kanGrubu: 'A Rh+', vefat: 0, kurum: '', sonBasvuru: null, sonBolum: '',
  sonDoktor: '', basvuruSayisi: 0, sonrakiRandevu: null, randevuBolum: '', randevuHekim: '', bakiye: 0,
  alerjiSayisi: 0, alerjiSiddet: 0, alerjiler: [], kronikSayisi: 0, kronikler: [], ilacSayisi: 0, bekleyenSonuc: 0,
  kayitTarihi: null, ilaclar: [],
};
vi.mock('../api/cekirdek', () => ({ istek: async () => ozet }));
const { HastaKartBandi } = await import('../sayfalar/hasta/HastaKartBandi');

describe('hasta kartı isim bandı', () => {
  it('3. satır: doğum tarihi · kimlik no · durum rozeti', async () => {
    render(<HastaKartBandi id={5} git={() => {}}
                           deger={{ ad: 'Ayşe', soyad: 'Kaya', vkno: '10000000146', durum: '1', kod: 'H-1' } as never} />);
    await waitFor(() => expect(document.querySelector('.hkb-3')!.textContent).toContain('14.03.1979'));
    const satir = document.querySelector('.hkb-3')!;
    expect(satir.textContent).toContain('10000000146');
    expect(satir.textContent).not.toContain('Kimlik');
    expect(screen.getByTestId('hasta-durum').textContent).toBe('Aktif');
    expect(screen.getByTestId('hasta-durum').classList.contains('ok')).toBe(true);
  });

  it('pasif hasta kırmızı rozet', async () => {
    render(<HastaKartBandi id={6} git={() => {}} deger={{ ad: 'Ali', soyad: 'Can', durum: '0' } as never} />);
    await waitFor(() => expect(screen.getByTestId('hasta-durum').textContent).toBe('Pasif'));
    expect(screen.getByTestId('hasta-durum').classList.contains('hata')).toBe(true);
  });
});

describe('bant ✎ (KipKalemi)', () => {
  it('kipli kart bağlamında ad soyadın sağında; basınca kip değişir', async () => {
    const { KartKipBaglami } = await import('../bilesenler/kart/KipKalemi');
    const degistir = vi.fn();
    render(<KartKipBaglami.Provider value={{ acik: false, pasif: false, degistir }}>
      <HastaKartBandi id={7} git={() => {}} deger={{ ad: 'Can', soyad: 'Er', durum: '1' } as never} />
    </KartKipBaglami.Provider>);
    const k = screen.getByTestId('hasta-bant-kalem');
    expect(k.closest('.hkb-ad-sat')).not.toBeNull();
    k.click();
    expect(degistir).toHaveBeenCalledTimes(1);
  });

  it('bağlam yoksa ✎ çizilmez', () => {
    render(<HastaKartBandi id={8} git={() => {}} deger={{ ad: 'Can', soyad: 'Er' } as never} />);
    expect(screen.queryByTestId('hasta-bant-kalem')).toBeNull();
  });
});
