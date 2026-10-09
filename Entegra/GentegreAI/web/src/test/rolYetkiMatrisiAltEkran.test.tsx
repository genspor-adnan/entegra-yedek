// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { act, render, fireEvent } from '@testing-library/react';
import { RolYetkiMatrisi } from '../bilesenler/RolYetkiMatrisi';

/**
 * BAŞKA GRUPTAKİ ALT EKRAN ÜST KODUN ALTINA GİRMEZ (09.10.2026, kullanıcı:
 * "uzman doktor barış ile girdim.. seçtiğim yetki matrisi dışında menüler
 * var").
 *
 * 998 `belge`'yi ekran kodlarına böldü; `belge.satis` noktalı olduğu için
 * aksiyon sanılıp Kayıt Kabul > Başvurular satırının altına konuyordu.
 * Başvurular'a tik atmak Satış ekranlarını da açıyordu. Sunucu bu satırın
 * grubunu da "Kayıt Kabul" döndürüyor - grup menüden alınmalı.
 */
const satir = (yetkiId: number, kod: string, ad: string, tur: number) => ({
  yetkiId, kod, ad, grup: 'Kayıt Kabul', tur,
  gor: false, ekle: false, degistir: false, sil: false, degerAlir: false, deger: '',
  kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '',
});
const YETKILER = [
  satir(1, 'belge', 'Belgeler', 0),
  // 1003'ten beri Kurumlar & Sigorta › Faturalar kendi kodunu taşır.
  satir(2, 'belge.kurum_fatura', 'Kurum faturaları', 0),
  satir(3, 'belge.kesinlestir', 'Kesinleştir', 1),
];

vi.mock('../api/istemci', () => ({
  api: {
    rolYetkileri: () => Promise.resolve(YETKILER),
    menuDuzen: () => Promise.resolve({ satirlar: [] }),
  },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: { urunModu: 2, moduller: [], menuBolgeli: 0 },
    yetki: () => true,
  }),
}));

describe('yetki matrisi - başka gruptaki alt ekran', () => {
  it('Başvurular satırı başka gruptaki fatura ekranını kapsamaz', async () => {
    const k = render(<RolYetkiMatrisi rolId={1} saltOkunur={false} />);
    await act(async () => { await Promise.resolve() });
    await act(async () => { fireEvent.click(k.getByText('Tümünü Aç')) });

    const satirBul = (metin: string) =>
      [...k.container.querySelectorAll('tr')].find(tr => tr.textContent?.includes(metin))!;
    // Noktalı ekran kodu kendi menü yerinde durur: Kurumlar &
    //   Sigorta > Faturalar, Kayıt Kabul altında değil.
    expect(k.container.textContent).toContain('Kurumlar & Sigorta');

    // Başvurular satırının GÖR kutusu (ilk sütun): alt dalındaki aksiyonu açar, Satış'ı açmaz.
    const basvuru = satirBul('Başvurular');
    const gor = basvuru.querySelector('input[type=checkbox]')!;
    await act(async () => { fireEvent.click(gor) });

    const satis = satirBul('Faturalar');
    const satisGor = satis.querySelector('input[type=checkbox]') as HTMLInputElement;
    expect(satisGor.checked).toBe(false);
    const kes = satirBul('Kesinleştir');
    const kesGor = kes.querySelector('input[type=checkbox]') as HTMLInputElement;
    expect(kesGor.checked).toBe(true);
  });
});
