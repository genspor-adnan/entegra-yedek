// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { act, render, fireEvent } from '@testing-library/react';
import { RolYetkiMatrisi } from '../bilesenler/RolYetkiMatrisi';

/**
 * AKTİF MENÜDE OLMAYAN EKRAN MATRİSTE ÇİZİLMEZ (09.10.2026, kullanıcı:
 * "yetki matrisinde başvuruların altında erp menüleri var").
 *
 * HBYS'de Satış / Alış ekranları menüde yok. Kodları (`belge.satis.fatura`)
 * menü haritasında bulunamayınca aksiyon sanılıp önekleri `belge` olan
 * Başvurular'ın altına giriyordu. Aksiyonlar (tür 1) yine üst ekranın altında.
 */
const satir = (yetkiId: number, kod: string, ad: string, tur: number) => ({
  yetkiId, kod, ad, grup: 'Kayıt Kabul', tur,
  gor: false, ekle: false, degistir: false, sil: false, degerAlir: false, deger: '',
  kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '',
});
const YETKILER = [
  satir(1, 'belge', 'Belgeler', 0),
  // 1115: Başvuru Listesi menüsü kendi ekran kodunda (veri `belge`de).
  satir(90, 'basvuru.liste', 'Başvuru Listesi (Kayıt Kabul)', 0),
  satir(2, 'belge.satis.fatura', 'Satış Faturaları (Satış)', 0),
  satir(3, 'belge.alis.fis', 'Alış Fişleri (Alış)', 0),
  satir(4, 'belge.kesinlestir', 'Belgeyi kesinleştir', 1),
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

describe('yetki matrisi - aktif menüde olmayan ekran', () => {
  it('HBYS matrisinde ERP ekranları Başvurular altında çıkmaz, aksiyon çıkar', async () => {
    const k = render(<RolYetkiMatrisi rolId={1} saltOkunur={false} ilkGorunum="tablo" />);
    await act(async () => { await Promise.resolve() });
    await act(async () => { fireEvent.click(k.getByText('Tümünü Aç')) });
    const metin = k.container.textContent ?? '';
    expect(metin).toContain('Başvuru Listesi');
    expect(metin).toContain('Belgeyi kesinleştir');
    // Satış Faturaları HBYS menüsünde yok: matriste de yok.
    expect(metin).not.toContain('Satış Faturası Listesi');
    // Alış Fişleri HBYS menüsünde VAR: kendi Alış grubunda, Başvurular'ın altında değil.
    const sira = metin.indexOf('Alış Fişi Listesi');
    expect(sira).toBeGreaterThan(metin.indexOf('Alış('));
    expect(metin.slice(metin.indexOf('Başvuru Listesi'), metin.indexOf('Alış('))).not.toContain('Alış Fişi Listesi');
  });
});
