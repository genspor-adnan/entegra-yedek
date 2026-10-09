// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { act, render, fireEvent } from '@testing-library/react';
import { RolYetkiMatrisi } from '../bilesenler/RolYetkiMatrisi';

/**
 * MATRİS = MENÜ (09.10.2026, kullanıcı: "genprofil ile seçtiğim menüler
 * yetki matrisinde görünecek.. yetki matrisinde gor dediğim menüler de
 * kullanıcı menüsünde görünecek").
 *
 * Uzman doktorun menüsünde Radyoloji, Görevler, Onayımdakiler ve Klinik
 * Kalite çıkıyordu ama matriste kutuları yoktu: yetki tablosundaki grupları
 * (`Sistem`, `CRM`, `Kalite`) menüde başlık değil, satır atlanıyordu. Menüde
 * ekranı olan yetki matriste o ekranın grubunda ve adıyla görünmeli.
 */
const satir = (yetkiId: number, kod: string, grup: string, gor = true) => ({
  yetkiId, kod, ad: kod, grup, tur: 0,
  gor, ekle: false, degistir: false, sil: false, degerAlir: false, deger: '',
  kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '',
});
const YETKILER = [
  satir(1, 'panel', 'Sistem'),
  satir(2, 'gorev', 'CRM'),
  satir(3, 'radyoloji-istem', 'Sistem'),
  satir(4, 'klinik_kalite.olgu', 'Kalite'),
  // Sunucu rolün TÜM yetki satırlarını döndürür; alt ekranın üst kodu da
  //   listede (kapalı) durur.
  satir(5, 'klinik_kalite', 'Kalite', false),
];

vi.mock('../api/istemci', () => ({
  api: {
    rolYetkileri: () => Promise.resolve(YETKILER),
    menuDuzen: () => Promise.resolve({ satirlar: [] }),
  },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: { urunModu: 2, moduller: undefined, menuBolgeli: 0 },
    yetki: () => true,
  }),
}));

describe('yetki matrisi - menüdeki her ekran matriste', () => {
  it('menüyü açan yetki matriste menü adıyla ve işaretli çizilir', async () => {
    const k = render(<RolYetkiMatrisi rolId={1} saltOkunur={false} />);
    await act(async () => { await Promise.resolve() });
    await act(async () => { fireEvent.click(k.getByText('Tümünü Aç')) });

    for (const ad of ['Onayımdakiler', 'Görevler', 'Klinik Kalite Göstergeleri']) {
      const tr = [...k.container.querySelectorAll('tr')].find(x => x.textContent?.includes(ad));
      expect(tr, ad).toBeTruthy();
      expect((tr!.querySelector('input[type=checkbox]') as HTMLInputElement).checked, ad).toBe(true);
    }
    // Radyoloji grubu da açılır (çalışma listesi `radyoloji-istem` ile).
    expect(k.container.textContent).toContain('Radyoloji');
  });
});
