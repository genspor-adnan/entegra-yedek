// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render, fireEvent } from '@testing-library/react';
import { RolYetkiMatrisi } from '../bilesenler/RolYetkiMatrisi';

/**
 * AĞACIN AÇIKLIĞI YETKİ DEĞİŞİNCE BOZULMAMALI (09.10.2026, kullanıcı: "yetki
 * matrisinde gör sütununu değiştirince satır kapanıyor, üst kısım açılıyor").
 *
 * Kök neden: "ilk yüklemede tüm dallar kapalı" efekti `agac` NESNESİNE
 * bağlıydı. Kutu tıklaması `satirlar`ı yeniliyor, memo yeni nesne döndürüyor
 * ve efekt yeniden çalışıp elle açılmış dalı çöktürüyordu. Düzeltme: efekt
 * ağacın YAPI İMZASINA bağlı (düğüm anahtarlarının birleşimi) - yapı
 * değişmedikçe kapanma yeniden uygulanmıyor.
 *
 * Test gerçek bileşeni çiziyor, yalnız API ve oturum taklit ediliyor: hata
 * ağaç kurulumu ile efekt arasındaki bağda, oraya dokunan bir taklit testi
 * değersiz kılardı.
 */
const YETKILER = [
  { yetkiId: 1, kod: 'hasta', ad: 'Hasta Listesi', grup: 'Kayıt Kabul', tur: 0,
    gor: true, ekle: false, degistir: false, sil: false, degerAlir: false, deger: '',
    kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '' },
  { yetkiId: 2, kod: 'randevu', ad: 'Randevular', grup: 'Kayıt Kabul', tur: 0,
    gor: true, ekle: true, degistir: false, sil: false, degerAlir: false, deger: '',
    kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '' },
];

vi.mock('../api/istemci', () => ({
  api: {
    rolYetkileri: () => Promise.resolve(YETKILER),
    menuDuzen: () => Promise.resolve({ satirlar: [] }),
    rolYetkileriYaz: () => Promise.resolve({}),
  },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: { urunModu: 2, moduller: [], menuBolgeli: 0 },
    yetki: () => true,
  }),
}));

const ciz = async () => {
  const a = render(<RolYetkiMatrisi rolId={1} saltOkunur={false} />);
  // Yetki ve menü düzeni istekleri mikro-görev kuyruğunda.
  await act(async () => { await Promise.resolve() });
  return a;
};

beforeEach(() => vi.clearAllMocks());

describe('yetki matrisi ağacı', () => {
  it('yetki satırları yüklenir ve dallar KAPALI gelir', async () => {
    const k = await ciz();
    // 900 satırlık ağaç açık gelirse ekran okunmuyordu: varsayılan kapalı.
    expect(k.container.textContent).toContain('Kayıt Kabul');
    expect(k.container.textContent).toContain('▸');
  });

  it('GÖR değişince açıklık KORUNUR (ağaç çökmez)', async () => {
    const k = await ciz();

    // "Tümünü Aç": dalları açmanın en dayanıklı yolu - düğme metni ekranın
    //   sözleşmesi, DOM yapısı değişse de testi kırmaz.
    await act(async () => { fireEvent.click(k.getByText('Tümünü Aç')) });
    expect(k.container.textContent).toContain('Hasta Listesi');

    // "Gör" kutusunu değiştir (yaprak satırındaki son kutu).
    const kutular = [...k.container.querySelectorAll('input[type=checkbox]')];
    expect(kutular.length).toBeGreaterThan(0);
    await act(async () => { fireEvent.click(kutular[kutular.length - 1]) });

    // ASIL BEKLENTİ: ağaç açık kalır - yapraklar ekranda.
    //   Hata varken "ilk yüklemede tüm dallar kapalı" efekti yeniden çalışıp
    //   her tıklamada ağacı çöktürüyordu.
    expect(k.container.textContent).toContain('Hasta Listesi');
    expect(k.container.textContent).toContain('Randevular');
  });
});
