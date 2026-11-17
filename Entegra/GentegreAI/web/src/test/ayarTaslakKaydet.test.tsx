// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';

/**
 * AYAR SAYFASI DESENİ (17.11.2026): otomatik kayıt yok - değişiklik taslakta kalır, "Kaydet & Uygula" yazar;
 * kayıtlı değere dönülürse değişiklik sayılmaz.
 */
const ayarYaz = vi.fn();
let sunucu = [{ anahtar: 'kasa.duzenleme_gun', deger: '7' }, { anahtar: 'basvuru.pos_aksiyon', deger: '0' }];
vi.mock('../api/istemci', () => ({ api: {
  ayarlar: async () => sunucu,
  ayarYaz: async (a: string, d: string) => { ayarYaz(a, d); sunucu = sunucu.map(x => x.anahtar === a ? { ...x, deger: d } : x); return sunucu },
} }));
vi.mock('../api/ayarlar', () => ({ ayarOnbellegiTemizle: vi.fn() }));
const { AyarAlani, useAyarlar } = await import('../bilesenler/AyarAlani');
const { AyarSayfaBasligi } = await import('../bilesenler/AyarSayfaBasligi');

function Sayfa() {
  const ayar = useAyarlar({ taslakli: true });
  return (
    <MemoryRouter>
      <AyarSayfaBasligi baslik="Deneme" ayar={ayar} />
      {!ayar.yukleniyor && <>
        <AyarAlani anahtar="kasa.duzenleme_gun" etiket="Gün" ayarlar={ayar.ayarlar} onYaz={ayar.yaz} />
        <AyarAlani anahtar="basvuru.pos_aksiyon" etiket="POS" tip="secenek"
                   secenekler={[{ deger: '0', ad: 'Yok' }, { deger: '1', ad: 'Fiş' }]} ayarlar={ayar.ayarlar} onYaz={ayar.yaz} />
      </>}
    </MemoryRouter>
  );
}

describe('ayar sayfası: taslak + Kaydet & Uygula', () => {
  it('değişiklik anında kaydedilmez, Kaydet ile yazılır; geri dönülen değer değişiklik sayılmaz', async () => {
    render(<Sayfa />);
    const kaydet = () => screen.getByTestId('ayar-kaydet') as HTMLButtonElement;
    await waitFor(() => expect(screen.getByDisplayValue('7')).toBeTruthy());
    expect(kaydet().disabled).toBe(true);

    const gun = screen.getByDisplayValue('7');
    fireEvent.change(gun, { target: { value: '14' } });
    fireEvent.blur(gun, { target: { value: '14' } });
    fireEvent.change(screen.getByDisplayValue('Yok'), { target: { value: '1' } });
    expect(ayarYaz).not.toHaveBeenCalled();
    expect(kaydet().disabled).toBe(false);
    expect(screen.getByTestId('ayar-degisti')).toBeTruthy();

    // POS'u eski değerine döndür: o anahtar taslaktan düşer.
    fireEvent.change(screen.getByDisplayValue('Fiş'), { target: { value: '0' } });

    await act(async () => { kaydet().click() });
    expect(ayarYaz).toHaveBeenCalledTimes(1);
    expect(ayarYaz).toHaveBeenCalledWith('kasa.duzenleme_gun', '14');
    await waitFor(() => expect(kaydet().disabled).toBe(true));
    expect(screen.queryByTestId('ayar-degisti')).toBeNull();
  });
});
