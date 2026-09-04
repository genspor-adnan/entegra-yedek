// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { GenForm } from '../bilesenler/GenForm';

/**
 * HASTA KARTI "GENEL" SEKMESI.
 *
 * Uc bolum bu sekmeye ciziliyor: Kimlik Bilgileri kutusu, Kimlik Detayı ve
 * YAKINLAR gridi. Ucu de ayni kosula ("aktif sekme Genel") bagli oldugu icin
 * sekme olusmazsa UCU BIRDEN sessizce kaybolur - kullanici "yakınlar gridi
 * görünmüyor" derken tam bunu yasadi. Bu yuzden gerceklik testi: kart
 * cizilecek ve grid DOM'da aranacak.
 */
const kartAlanlari = vi.fn();
const kartOku = vi.fn();

vi.mock('../api/istemci', () => ({
  api: {
    kartAlanlari: (k: string) => kartAlanlari(k),
    kartOku: (k: string, id: number) => kartOku(k, id),
    kodListe: () => Promise.resolve({ degerler: [] }),
    dovizKur: () => Promise.resolve({ kur: 1 }),
    liste: () => Promise.resolve({ satirlar: [] }),
    yerler: () => Promise.resolve({ ulkeler: [{ id: 1, ad: 'T.C.' }], iller: [] }),
    aramaIsaretle: () => Promise.resolve({}),
    dokumanlar: () => Promise.resolve({ satirlar: [] }),
    kartKullanicisi: () => Promise.resolve(null),
  },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: { id: 1, kod: 't', ad: 'T', rolId: 1, rolAdi: 'Yonetici', dil: 0,
                 yetkiSurumu: 1, subeId: 1, subeYazma: true,
                 subeler: [{ id: 1, ad: 'Merkez', varsayilan: true, yazma: true }],
                 urunModu: 2, moduller: [], hekimRolu: 1 },
    aksiyonlar: [], kaynaklar: [], yukleniyor: false,
    yetki: () => true, aksiyonVar: () => true,
  }),
}));

const alan = (ad: string, baslik: string, y: Record<string, unknown> = {}) =>
  ({ ad, baslik, tip: 'metin', yazilabilir: true, zorunlu: false, gizli: false, ...y });

const detay = (ad: string, baslik: string, alanlar: unknown[] = []) =>
  ({ ad, baslik, alanlar, kosulAlani: null, tekSatir: false, saltOkunur: false });

beforeEach(() => {
  vi.clearAllMocks();
  // GERCEK hasta kartinin sekli: kimlik alanlari grupta, grupsuz gorunur alan
  //   YOK (randevuVerilebilir gizlendi) - "Genel" sekmesi bu yuzden alan
  //   sayisindan bagimsiz olmali.
  const yetki = { duzenle: true, sil: true, gizliAlanlar: [] };
  kartAlanlari.mockResolvedValue({
    yetki,
    alanlar: [
      alan('id', 'Id', { yazilabilir: false }),
      alan('kod', 'Dosya No', { grup: 'Kimlik' }),
      alan('ad', 'Ad', { grup: 'Kimlik' }),
      alan('soyad', 'Soyad', { grup: 'Kimlik' }),
      alan('vkno', 'TC No', { grup: 'Kimlik' }),
      alan('durum', 'Durum', { grup: 'Kimlik', tip: 'kod', kodlar: { 1: 'Aktif' } }),
      alan('cepTel', 'Telefon', { grup: 'İletişim' }),
      alan('gorevId', 'Görev', { tip: 'kod', kodlar: {} }),
      alan('faturaUnvan', 'Fatura Unvanı', { grup: 'Adres / Fatura Bilgisi' }),
    ],
    detaylar: [
      detay('ozluk', 'Hasta Bilgisi', [
        alan('dogumTarihi', 'Doğum Tarihi', { tip: 'tarih' }),
        alan('cinsiyet', 'Cinsiyet', { tip: 'kod', kodlar: { 1: 'Erkek' } }),
      ]),
      detay('acilKisiler', 'Acil Durumda Aranacak Kişiler', [
        alan('adSoyad', 'Ad Soyad'), alan('yakinlik', 'Yakınlık'),
      ]),
      detay('adresler', 'Adresler', [alan('adres', 'Adres')]),
      detay('kurum', 'Kurum / Ödeyen', [alan('policeNo', 'Poliçe No')]),
    ],
  });
  kartOku.mockResolvedValue({
    kart: { id: 77, kod: 'H-77', ad: 'Test', soyad: 'Hasta', vkno: '11111111111', durum: 1 },
    detaylar: { ozluk: [{ id: 77, dogumTarihi: '1979-03-14', cinsiyet: 1 }], acilKisiler: [] },
    surum: '1',
    yetki,
  });
});

const ciz = () => render(
  <MemoryRouter><GenForm kaynak="hasta" id={77} baslik="Hasta" onKapat={() => {}} /></MemoryRouter>,
);

describe('hasta kartinda Yakınlar gridi', () => {
  it('GENEL sekmesi cizilir (grupsuz gorunur alan olmasa da)', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    await waitFor(() => expect(
      [...document.querySelectorAll('.kat')].map(x => x.textContent))
      .toEqual(expect.arrayContaining([expect.stringContaining('Genel')])));
  });

  it('YAKINLAR gridi Genel sekmesinde GORUNUR', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    await waitFor(() => {
      const g = document.body.textContent ?? '';
      expect(g).toContain('Acil Durumda Aranacak Kişiler');
    });
    // Gridin kendisi de cizilmis olmali - yalniz baslik degil.
    expect([...document.querySelectorAll('table')].some(t =>
      (t.textContent ?? '').includes('Yakınlık'))).toBe(true);
  });
});
