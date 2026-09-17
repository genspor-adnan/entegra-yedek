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
});
