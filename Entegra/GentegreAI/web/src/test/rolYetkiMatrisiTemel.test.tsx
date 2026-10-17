// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { act, render, fireEvent } from '@testing-library/react';
import { RolYetkiMatrisi } from '../bilesenler/RolYetkiMatrisi';

/**
 * TEMEL YETKİLER AYRI KUTUDA (17.10.2026, kullanıcı: "banko görevlisi olarak girdim hasta ve başvuru
 * listeleri gör olduğu halde gelmedi"). `Sistem` grubundaki menüsüz çekirdek yetkiler (Sol menüyü
 * görür...) Yönetim kutusundaydı; "Yönetim'i kapat" sol menüyü de kapatıyordu.
 */
const satir = (yetkiId: number, kod: string, ad: string, grup: string) => ({
  yetkiId, kod, ad, grup, tur: 0, gor: true, ekle: false, degistir: false, sil: false,
  degerAlir: false, deger: '', kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '',
});
vi.mock('../api/istemci', () => ({
  api: {
    rolYetkileri: () => Promise.resolve([
      satir(1, 'kabuk.menu', 'Sol menüyü görür', 'Sistem'),
      satir(2, 'menu.duzen', 'Menü Düzeni', 'Sistem'),
    ]),
    menuDuzen: () => Promise.resolve({ satirlar: [] }),
  },
}));
vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({ kullanici: { urunModu: 2, moduller: [] }, yetki: () => true }),
}));

describe('yetki matrisi temel yetkiler', () => {
  it('menüsüz sistem yetkisi Yönetim kutusunda değil, Yönetim kapanınca açık kalır', async () => {
    const k = render(<RolYetkiMatrisi rolId={1} saltOkunur={false} ilkGorunum="kutu" />);
    await act(async () => { await Promise.resolve() });
    const kutu = (ad: string) => [...k.container.querySelectorAll('.ym-kutu')]
      .find(x => x.querySelector('.ym-kb')?.textContent?.includes(ad)) as HTMLElement | undefined;
    expect(kutu('Temel Yetkiler')?.textContent).toContain('Sol menüyü görür');
    expect(kutu('Yönetim')?.textContent ?? '').not.toContain('Sol menüyü görür');
    const yon = kutu('Yönetim');
    if (yon) await act(async () => { fireEvent.click(yon.querySelector('.ym-uc')!) });
    const menu = [...kutu('Temel Yetkiler')!.querySelectorAll('.ym-sat')]
      .find(x => x.textContent?.includes('Sol menüyü görür'))!;
    expect((menu.querySelector('input[type=checkbox]') as HTMLInputElement).checked).toBe(true);
  });
});
