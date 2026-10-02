// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render, waitFor } from '@testing-library/react';

/**
 * STOK / HİZMET ARAMA: İKİ EKLEME HIZI (786).
 *
 * Kullanıcı: *"sola '1 Adet Ekle (Enter)' basınca veya Enter basınca fiyat
 * ekranı açmadan direkt 1 adet eklesin.. sağına 'Miktar Ekle' basınca fiyat /
 * miktar sorma ekranı açsın"*. Kısayol önce F12'ydi, tarayıcının geliştirici
 * araçlarıyla çakıştığı için **Shift+Enter** oldu (kullanıcı).
 *
 * Kayıt kabulde ücretlerin çoğu tek adet ve liste fiyatıyla giriliyor; her
 * birinde kalem penceresi açıp Enter'lamak iki fazladan tuştu. Ayrım tek bir
 * bayrakta (`hizli`) taşınıyor - pencerenin kendisi iki yol bilmiyor.
 */
const liste = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  get liste() { return liste },
  ilacStokKarti: vi.fn(),
  aramaIsaretle: vi.fn(),
} }));
vi.mock('../bilesenler/KategoriSuzgeci', () => ({
  KategoriSuzgeci: () => null,
}));
// Pencere urun modunu oturumdan okuyor (HBYS'de ilac da aranir); testte
//   saglayici yok - HBYS kullanicisi taklit ediliyor.
vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({ kullanici: { urunModu: 2, subeId: 1 },
                      aksiyonDegeri: () => 0 }),
}));

const { StokAramaPenceresi } = await import('../bilesenler/StokAramaPenceresi');

const SATIR = { id: 9, tip: 'hizmet', ad: 'Diş Hekimi Muayenesi',
                kod: '401010', fiyat: 1000 };

const ciz = (onSec = vi.fn()) => {
  const r = render(
    <StokAramaPenceresi etkin onSec={onSec} onKapat={() => {}}
                        eklenen={{ sayi: 2, son: 'Muayene İşlemi' }} />);
  return { ...r, onSec };
};

/** Arama kutusuna tuş gönderir (liste zaten yüklü). */
const tus = async (kod: string, shift = false) => {
  const kutu = document.querySelector('input[type=search]') as HTMLInputElement;
  await act(async () => {
    kutu.dispatchEvent(new KeyboardEvent('keydown',
      { key: kod, shiftKey: shift, bubbles: true, cancelable: true }));
  });
};

describe('stok arama: ekleme hızları (786)', () => {
  beforeEach(() => {
    liste.mockReset();
    liste.mockResolvedValue({ satirlar: [SATIR], toplamKayit: 1 });
  });

  it('başlıkta iki düğme ve "eklendi" bilgisi DÜĞMELERİN SAĞINDA durur', async () => {
    ciz();
    await waitFor(() => expect(document.querySelector('.stok-ara-eylem')).not.toBeNull());
    const serit = document.querySelector('.stok-ara-eylem')!;
    const metin = (serit.textContent ?? '').replace(/\s+/g, ' ');
    expect(metin).toContain('1 Adet Ekle (Enter)');
    expect(metin).toContain('Miktar Ekle (Shift+Enter)');
    // Kullanıcı: "üstte eklendi mesajı yine devam etsin, butonların sağında" -
    //   eskiden pencerenin ALT şeridindeydi, listeye bakan göz görmüyordu.
    expect(metin).toContain('2 kalem eklendi');
    expect(serit.querySelector('.stok-ara-eklendi')).not.toBeNull();
  });

  it('ENTER 1 adet ekler: hizli = true (fiyat penceresi açılmaz)', async () => {
    const { onSec } = ciz();
    await waitFor(() => expect(liste).toHaveBeenCalled());
    await tus('Enter');
    await waitFor(() => expect(onSec).toHaveBeenCalled());
    expect(onSec.mock.calls[0][1]).toBe(true);
    expect((onSec.mock.calls[0][0] as { id: number }).id).toBe(9);
  });

  it('SHIFT+ENTER miktar/fiyat penceresini açar: hizli = false', async () => {
    const { onSec } = ciz();
    await waitFor(() => expect(liste).toHaveBeenCalled());
    await tus('Enter', true);
    await waitFor(() => expect(onSec).toHaveBeenCalled());
    expect(onSec.mock.calls[0][1]).toBe(false);
  });

  it('DÜĞMELER de aynı iki yolu açar', async () => {
    const { onSec } = ciz();
    await waitFor(() => expect(document.querySelector('.stok-ara-eylem')).not.toBeNull());
    const dugme = (ad: string) => [...document.querySelectorAll('.stok-ara-eylem button')]
      .find(b => (b.textContent ?? '').includes(ad)) as HTMLButtonElement;

    await act(async () => { dugme('1 Adet Ekle').click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(1));
    expect(onSec.mock.calls[0][1]).toBe(true);

    await act(async () => { dugme('Miktar Ekle').click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(2));
    expect(onSec.mock.calls[1][1]).toBe(false);
  });

  it("TEKLİ SEÇİM varsayılan; Ctrl ve Shift ile çoklu, seçilenler 1'er adet eklenir", async () => {
    const IKINCI = { id: 10, tip: 'hizmet', ad: 'Kontrol Muayenesi', kod: '401020', fiyat: 500 };
    const UCUNCU = { id: 11, tip: 'hizmet', ad: 'Konsültasyon', kod: '401030', fiyat: 700 };
    // Pencere stok/hizmet/ilac kaynaklarini ayri sorar: satirlar yalniz hizmetten.
    liste.mockImplementation((kaynak: string) => Promise.resolve(kaynak === 'hizmet'
      ? { satirlar: [SATIR, IKINCI, UCUNCU], toplamKayit: 3 } : { satirlar: [], toplamKayit: 0 }));
    const { onSec } = ciz();
    // Pencere portalda; onceki testlerin penceresi de govdede kalabilir - SON pencere.
    const pencere = () => [...document.querySelectorAll('.stok-arama')].at(-1)!;
    await waitFor(() => expect(pencere()?.querySelectorAll('tbody tr').length).toBe(3));
    const satirlar = [...pencere().querySelectorAll('tbody tr')] as HTMLElement[];
    const kutu = (s: HTMLElement) => s.querySelector('input[type=checkbox]') as HTMLInputElement;
    const isaret = () => satirlar.map(s => kutu(s).checked);
    const tikla = async (s: HTMLElement, o: MouseEventInit = {}) => {
      await act(async () => { s.dispatchEvent(new MouseEvent('click', { bubbles: true, ...o })) });
    };

    // Düz tık: yalnız o satır (öncekini bırakır), ekleme YOK.
    await tikla(satirlar[0]);
    await tikla(satirlar[1]);
    expect(isaret()).toEqual([false, true, false]);
    expect(onSec).not.toHaveBeenCalled();

    // Ctrl: ekle / çıkar.
    await tikla(satirlar[0], { ctrlKey: true });
    expect(isaret()).toEqual([true, true, false]);
    await tikla(satirlar[1], { ctrlKey: true });
    expect(isaret()).toEqual([true, false, false]);

    // Shift: çapadan aralık.
    await tikla(satirlar[0]);                        // çapa 0, yalnız 0
    await tikla(satirlar[2], { shiftKey: true });    // 0..2
    expect(isaret()).toEqual([true, true, true]);

    // Ctrl ile biri çıkarılır, kalan ikisi eklenir.
    await tikla(satirlar[1], { ctrlKey: true });
    const dugme = [...document.querySelectorAll('.stok-ara-eylem button')]
      .reverse().find(b => (b.textContent ?? '').includes('Seçilenleri Ekle')) as HTMLButtonElement;
    expect(dugme.textContent).toContain('(2)');
    await act(async () => { dugme.click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(2));
    // Satırlar ada göre: Diş (9) · Konsültasyon (11) · Kontrol (10) - ortadaki çıktı.
    expect(onSec.mock.calls.map(c => (c[0] as { id: number }).id)).toEqual([9, 10]);
    expect(onSec.mock.calls.every(c => c[1] === true)).toBe(true);
    // Eklenince işaretler temizlenir.
    await waitFor(() => expect(kutu(satirlar[0]).checked).toBe(false));
  });
});
