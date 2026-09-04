// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { GenForm } from '../bilesenler/GenForm';
import gercek from './veri/hastaKartMeta.json';

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

beforeEach(() => {
  vi.clearAllMocks();
  // GERCEK SUNUCU META'SI ve gercek bir hasta kaydi (kimlik alanlari
  //   maskelendi). Uydurma meta ile test GECIYOR ama ekranda grid
  //   gorunmuyordu - fark ancak gercek veriyle ortaya cikar.
  const yetki = { duzenle: true, sil: true, gizliAlanlar: [] };
  kartAlanlari.mockResolvedValue({ ...gercek.meta, yetki });
  kartOku.mockResolvedValue({ ...gercek.kart, yetki });
});

const ciz = () => render(
  <MemoryRouter><GenForm kaynak="hasta" id={Number(gercek.kart.kart.id)} baslik="Hasta" onKapat={() => {}} /></MemoryRouter>,
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
