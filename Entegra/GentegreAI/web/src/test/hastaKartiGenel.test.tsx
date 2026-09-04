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

  it('YAKINLAR gridi GENEL sekmesinde (ayri sekme DEGIL - kullanici)', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    await waitFor(() => expect([...document.querySelectorAll('table')].some(t =>
      (t.textContent ?? '').includes('Yakınlık'))).toBe(true));
    // Sekme olarak DA cizilmemeli - ayni grid iki yerde olmasin.
    expect([...document.querySelectorAll('.kat')].map(x => x.textContent ?? '')
      .some(x => x.includes('Acil Durumda Aranacak'))).toBe(false);
  });

  it('KIMLIK DETAYI kutusu KALDIRILDI (kullanici)', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    await waitFor(() => expect([...document.querySelectorAll('h6')]
      .map(x => x.textContent)).toContain('Kimlik Bilgileri'));
    expect([...document.querySelectorAll('h6')].map(x => x.textContent))
      .not.toContain('Kimlik Detayı');
  });

  it('UYRUK adres kutusunda, ULKENIN saginda (kullanici)', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    // Uyruk ozluk detayinda ama ULKE ile ayni satirda soruluyor; kimlik
    //   kutusunda ARTIK OLMAMALI - iki yerde birden cizilirse ikisi ayni
    //   alani farkli degerle yazar.
    const etiketler = await waitFor(() => {
      const e = [...document.querySelectorAll('.etiket')].map(x => x.textContent ?? '');
      if (!e.includes('Uyruk')) throw new Error('Uyruk alani yok');
      return e;
    });
    expect(etiketler.filter(x => x === 'Uyruk')).toHaveLength(1);
    const ulke = [...document.querySelectorAll('.adres-satir')]
      .find(r => (r.textContent ?? '').includes('Ülke'));
    expect(ulke?.textContent).toContain('Uyruk');
  });

  it('YAKINLAR kutusu FLEX SATIRININ DISINDA - kendi satirinda', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    // ASIL HATA BUYDU: kutu ".kasira" (sarmayan flex satiri) icindeyken
    //   Iletisim/Kimlik/Fotograf'in yanina ucuncu sutun olarak diziliyor ve
    //   kartin gorunur alanindan tasiyordu. DOM SIRASI DOGRUYDU - bu yuzden
    //   sadece sirayi olcen test uc kez yesil kalirken ekranda grid yoktu.
    const kutu = await waitFor(() => {
      const k = [...document.querySelectorAll('.kagrup')].find(x =>
        (x.querySelector('h6')?.textContent ?? '').startsWith('Yakınlar'));
      if (!k) throw new Error('Yakınlar kutusu yok');
      return k;
    });
    expect(kutu.closest('.kasira')).toBeNull();
  });

  it('SUBE ve EKLEME TARIHI cizilmez (kullanici)', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    await waitFor(() => expect([...document.querySelectorAll('h6')]
      .map(x => x.textContent)).toContain('Kimlik Bilgileri'));
    const etiketler = [...document.querySelectorAll('.etiket')].map(x => x.textContent ?? '');
    expect(etiketler.some(x => x.includes('Şube'))).toBe(false);
    expect(etiketler.some(x => x.includes('Ekleme Tarihi'))).toBe(false);
  });

  it('ILETISIM kutusu KIMLIGIN SOLUNDA (kullanici)', async () => {
    ciz();
    await waitFor(() => expect(kartOku).toHaveBeenCalled());
    const basliklar = await waitFor(() => {
      const b = [...document.querySelectorAll('h6')].map(x => x.textContent ?? '');
      if (!b.includes('İletişim')) throw new Error('İletişim kutusu yok');
      return b;
    });
    expect(basliklar.indexOf('İletişim'))
      .toBeLessThan(basliklar.indexOf('Kimlik Bilgileri'));
    // YAKINLAR IKISININ DE USTUNDE (kullanici): altta kaldiginda kartin
    //   gorunur alanindan tasiyor ve "grid yok" gibi gorunuyordu.
    expect(basliklar.indexOf('Yakınlar / Acil Durumda Aranacak'))
      .toBeLessThan(basliklar.indexOf('İletişim'));
  });
});
