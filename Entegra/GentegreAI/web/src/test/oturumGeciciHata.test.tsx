// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { ApiHatasi } from '../api/sozlesme';

/**
 * GECICI /ben HATASI OTURUMU SILMEZ (denetim 28.09.2026 #11).
 *
 * Eskiden acilistaki /ben'in HER hatasi `oturum.temizle()` idi: sunucu
 * yeniden baslarken (502/503) ya da ag koptugunda refresh token da silinir,
 * kullanici giris ekranina duserdi. Burada GERCEK oturum baglami cizilir,
 * yalniz sunucu (api.ben) taklit edilir; token'larin localStorage'da kalip
 * kalmadigi dogrudan okunur.
 */
const ben = vi.fn();
vi.mock('../api/istemci', async () => {
  const gercek = await vi.importActual<typeof import('../api/istemci')>('../api/istemci');
  return { ...gercek, api: { ...gercek.api, ben: () => ben(), cikis: () => Promise.resolve() } };
});

const { OturumSaglayici, useOturum, benHatasiSinifi } = await import('../kimlik/OturumBaglami');

function Durum() {
  const o = useOturum();
  if (o.yukleniyor) return <div>yukleniyor</div>;
  if (o.oturumHatasi) return <button onClick={() => void o.yenidenDene()}>yeniden</button>;
  return <div>{o.kullanici ? `giris:${o.kullanici.kod}` : 'cikis'}</div>;
}
const ciz = () => render(<OturumSaglayici><Durum /></OturumSaglayici>);

const hata = (durum: number, kod = 'SUNUCU') =>
  new ApiHatasi(durum, { kod: kod as never, mesaj: `hata ${durum}`, izlemeNo: '' });

const BEN = {
  kullanici: { id: 1, kod: 'ayse', ad: 'Ayse', rolId: 1, rolAdi: 'R', dil: 0, yetkiSurumu: 1,
               subeId: 1, subeYazma: true, subeler: [], urunModu: 1, moduller: [], hekimRolu: 0 },
  aksiyonlar: [], kaynaklar: [],
};

beforeEach(() => {
  ben.mockReset();
  localStorage.clear();
  localStorage.setItem('gentegre.access', 'A1');
  localStorage.setItem('gentegre.refresh', 'R1');
});

describe('benHatasiSinifi', () => {
  it('401 ve refresh silinmis: kesin ret', () =>
    expect(benHatasiSinifi(hata(401, 'YETKISIZ'), false)).toBe('kesin'));
  it('401 ama refresh duruyor (yenileme gecici hatadan dondu): gecici', () =>
    expect(benHatasiSinifi(hata(401, 'YETKISIZ'), true)).toBe('gecici'));
  it('502/503: gecici', () => {
    expect(benHatasiSinifi(hata(502), true)).toBe('gecici');
    expect(benHatasiSinifi(hata(503), true)).toBe('gecici');
  });
  it('ag hatasi (fetch TypeError): gecici', () =>
    expect(benHatasiSinifi(new TypeError('Failed to fetch'), true)).toBe('gecici'));
  it('403 YASAK (sube) oturumu kapatmaz', () =>
    expect(benHatasiSinifi(hata(403, 'YASAK'), true)).toBe('sube'));
});

describe('OturumSaglayici acilis', () => {
  it('503: token korunur, yeniden deneme oturumu geri yukler', async () => {
    ben.mockRejectedValueOnce(hata(503)).mockResolvedValueOnce(BEN);
    ciz();
    const dugme = await screen.findByText('yeniden');
    // Korumali ekran da giris ekrani da cizilmedi; token'lar yerinde.
    expect(localStorage.getItem('gentegre.access')).toBe('A1');
    expect(localStorage.getItem('gentegre.refresh')).toBe('R1');
    dugme.click();
    await screen.findByText('giris:ayse');
    expect(ben).toHaveBeenCalledTimes(2);
  });

  it('ag kesintisi: refresh token silinmez', async () => {
    ben.mockRejectedValueOnce(new TypeError('Failed to fetch'));
    ciz();
    await screen.findByText('yeniden');
    expect(localStorage.getItem('gentegre.refresh')).toBe('R1');
  });

  it('kesin kimlik reddi: temizlenir ve girise donulur', async () => {
    // Cekirdek 401'de refresh'i denedi, sunucu reddetti ve token'lari sildi.
    ben.mockImplementationOnce(async () => {
      localStorage.removeItem('gentegre.access');
      localStorage.removeItem('gentegre.refresh');
      throw hata(401, 'YETKISIZ');
    });
    ciz();
    await screen.findByText('cikis');
    expect(localStorage.getItem('gentegre.refresh')).toBeNull();
  });

  it('gecersiz sube (403): sube secimi birakilip BIR KEZ tekrar denenir, dongu yok', async () => {
    localStorage.setItem('gentegre.sube', '7');
    ben.mockRejectedValueOnce(hata(403, 'YASAK')).mockResolvedValueOnce(BEN);
    ciz();
    await screen.findByText('giris:ayse');
    expect(localStorage.getItem('gentegre.sube')).toBeNull();
    expect(localStorage.getItem('gentegre.refresh')).toBe('R1');
    expect(ben).toHaveBeenCalledTimes(2);
  });

  it('surekli 403: iki denemede durur, oturumu silmez', async () => {
    localStorage.setItem('gentegre.sube', '7');
    ben.mockRejectedValue(hata(403, 'YASAK'));
    ciz();
    await screen.findByText('yeniden');
    await waitFor(() => expect(ben).toHaveBeenCalledTimes(2));
    expect(localStorage.getItem('gentegre.refresh')).toBe('R1');
  });
});
