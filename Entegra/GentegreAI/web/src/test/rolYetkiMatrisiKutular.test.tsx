// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render, fireEvent } from '@testing-library/react';
import { RolYetkiMatrisi } from '../bilesenler/RolYetkiMatrisi';

/**
 * YETKİ MATRİSİ KUTULAR GÖRÜNÜMÜ (17.10.2026, mockup Ekranlar/Ayarlar/yetki_matrisi_kutular.html).
 *
 * Sözleşme:
 *  - kutu = menü grubu; en az bir yetkisi KAYITLI olarak açık grup YETKİLİ GRUPLAR'da, öteki YETKİSİZ'de;
 *  - işaretlemek kutuyu yerinden oynatmaz (bölüm kayıtlı duruma bağlı), yer değiştirecek kutu `bekliyor`;
 *  - Gör kapalıyken E/D/S rozetleri kilitli; rozet işlemi açar.
 */
const YETKILER = [
  { yetkiId: 1, kod: 'hasta', ad: 'Hasta Listesi', grup: 'Kayıt Kabul', tur: 0,
    gor: true, ekle: false, degistir: false, sil: false, degerAlir: false, deger: '',
    kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '' },
  { yetkiId: 2, kod: 'randevu', ad: 'Randevular', grup: 'Randevu', tur: 0,
    gor: false, ekle: false, degistir: false, sil: false, degerAlir: false, deger: '',
    kapsamAlir: false, kapsam: 0, urunModu: 0, modul: '' },
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

const ciz = async () => {
  const a = render(<RolYetkiMatrisi rolId={1} saltOkunur={false} ilkGorunum="kutu" />);
  await act(async () => { await Promise.resolve() });
  return a;
};

const kutu = (k: ReturnType<typeof render>, metin: string) =>
  [...k.container.querySelectorAll('.ym-kutu')].find(x => x.textContent?.includes(metin)) as HTMLElement;
/** Kutunun hangi bölümde durduğu: önündeki son bölüm başlığı. */
const bolum = (k: ReturnType<typeof render>, metin: string) => {
  const kok = k.container.querySelector('.ym-kok')!;
  let son = '';
  for (const el of kok.querySelectorAll('.ym-bolum-bas, .ym-kutu')) {
    if (el.classList.contains('ym-bolum-bas')) son = el.classList.contains('yetkisiz') ? 'yetkisiz' : 'yetkili';
    else if (el.textContent?.includes(metin)) return son;
  }
  return '?';
};

beforeEach(() => vi.clearAllMocks());

describe('yetki matrisi kutular', () => {
  it('yetkili ve yetkisiz gruplar ayrı bölümde', async () => {
    const k = await ciz();
    expect(k.container.textContent).toContain('YETKİLİ GRUPLAR');
    expect(k.container.textContent).toContain('YETKİSİZ GRUPLAR');
    expect(bolum(k, 'Hasta Listesi')).toBe('yetkili');
    expect(bolum(k, 'Randevu Listesi')).toBe('yetkisiz');
  });

  it('işaretleyince kutu yerinde kalır, bekliyor çerçevesi alır', async () => {
    const k = await ciz();
    const r = kutu(k, 'Randevu Listesi');
    await act(async () => { fireEvent.click(r.querySelector('.ym-sat input[type=checkbox]')!) });
    // Kaydedilmedi: bölüm değişmez, yalnız işaretlenir.
    expect(bolum(k, 'Randevu Listesi')).toBe('yetkisiz');
    expect(kutu(k, 'Randevu Listesi').classList.contains('bekliyor')).toBe(true);
    expect(k.container.textContent).toContain('1 satır kaydedilmedi');
  });

  it('Gör kapalıyken rozet kilitli, açıkken rozet işlemi açar', async () => {
    const k = await ciz();
    const kilitli = kutu(k, 'Randevu Listesi').querySelector('.ym-r.ym-e') as HTMLButtonElement;
    expect(kilitli.disabled).toBe(true);
    const ekle = kutu(k, 'Hasta Listesi').querySelector('.ym-r.ym-e') as HTMLButtonElement;
    expect(ekle.disabled).toBe(false);
    await act(async () => { fireEvent.click(ekle) });
    expect((kutu(k, 'Hasta Listesi').querySelector('.ym-r.ym-e') as HTMLElement).classList.contains('on')).toBe(true);
  });
});

describe('grup başı düğmesi', () => {
  it('açık grupta basınca bütün yetkiler kapanır (tam yetkiye geçmez)', async () => {
    const k = await ciz();
    const hasta = () => kutu(k, 'Hasta Listesi');
    await act(async () => { fireEvent.click(hasta().querySelector('.ym-uc')!) });
    expect((hasta().querySelector('.ym-sat input[type=checkbox]') as HTMLInputElement).checked).toBe(false);
    expect(hasta().querySelector('.ym-r.on')).toBeNull();
    // Kapalı grupta basınca yalnız Gör açılır.
    await act(async () => { fireEvent.click(hasta().querySelector('.ym-uc')!) });
    expect((hasta().querySelector('.ym-sat input[type=checkbox]') as HTMLInputElement).checked).toBe(true);
    expect(hasta().querySelector('.ym-r.on')).toBeNull();
  });
});
