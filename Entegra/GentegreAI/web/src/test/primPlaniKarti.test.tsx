// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { GenForm } from '../bilesenler/GenForm';
import gercek from './veri/primPlaniKart.json';

/**
 * PRIM PLANI KARTI - "Prim Alanlar" sekmesine aramayla kisi ekleme, KART
 * SEVIYESINDE (kullanici: "eklenmedi test et").
 *
 * Bilesen testi (primAlanlarEkleme) satirin gride girdigini kanitliyor; bu test
 * ondan sonrasini olcer: satir KAYDA giriyor mu - yani `kartGuncelle`
 * govdesinde `taraflar.eklenen` olarak sunucuya gidiyor mu.
 */
const kartAlanlari = vi.fn();
const kartOku = vi.fn();
const kartGuncelle = vi.fn();
const liste = vi.fn();

vi.mock('../api/istemci', () => ({
  api: {
    kartAlanlari: (k: string) => kartAlanlari(k),
    kartOku: (k: string, id: number) => kartOku(k, id),
    kartGuncelle: (k: string, id: number, govde: unknown) => kartGuncelle(k, id, govde),
    liste: (k: string, i: unknown) => liste(k, i),
    aramaIsaretle: () => Promise.resolve({}),
    kodListe: () => Promise.resolve({ degerler: [] }),
    dovizKur: () => Promise.resolve({ kur: 1 }),
    yerler: () => Promise.resolve({ ulkeler: [], iller: [] }),
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
  const yetki = { duzenle: true, sil: true, gizliAlanlar: [] };
  kartAlanlari.mockResolvedValue({ ...gercek.meta, yetki });
  kartOku.mockResolvedValue({ ...gercek.kart, yetki });
  kartGuncelle.mockResolvedValue({ kart: { ...gercek.kart.kart, surum: '2' } });
  liste.mockResolvedValue({ satirlar: [{ id: 4888, kod: 'P-4888', unvan: 'aaa ooo' }] });
});

const ciz = () => render(
  <MemoryRouter>
    <GenForm kaynak="prim-plani" id={10} baslik="Prim Planı" onKapat={() => {}} />
  </MemoryRouter>);

const sekmeAc = async (ad: string) => {
  const kat = await waitFor(() => {
    const k = [...document.querySelectorAll('.kat')].find(x => (x.textContent ?? '').includes(ad));
    if (!k) throw new Error(`${ad} sekmesi yok`);
    return k;
  });
  fireEvent.click(kat);
};

describe('Prim Planı kartı - Prim Alanlar', () => {
  it('aramayla eklenen kisi KAYDA girer (taraflar.eklenen)', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    await sekmeAc('Prim Alanlar');

    fireEvent.click(await screen.findByRole('button', { name: /Kişi Ekle/ }));
    await screen.findByPlaceholderText(/Kişi ara/);
    // Ad hem arama listesinde hem gridin kod combosunda gecebilir - arama
    //   listesi icinde beklenir.
    await waitFor(() => expect(
      document.querySelector('.lookup-liste')?.textContent).toContain('aaa ooo'));
    // ISARETLE, sonra "Seç" - pencere kapanir ve satir gride girer.
    const satir = [...document.querySelectorAll('.lookup-liste tbody tr')]
      .find(x => (x.textContent ?? '').includes('aaa ooo'))!;
    fireEvent.click(satir);
    fireEvent.click(screen.getByRole('button', { name: /^Seç \(1\)$/ }));

    // Birden fazla "Kaydet" olabilir (kart alti + modal) - KART altindaki.
    const kaydet = screen.getAllByRole('button', { name: 'Kaydet' });
    fireEvent.click(kaydet[kaydet.length - 1]);

    await waitFor(() => expect(kartGuncelle).toHaveBeenCalled());
    const govde = kartGuncelle.mock.calls[0][2] as
      { detaylar?: Record<string, { eklenen?: { tarafId?: unknown }[] }> };
    expect(govde.detaylar?.taraflar?.eklenen?.[0]?.tarafId).toBe('4888');
  });
});
