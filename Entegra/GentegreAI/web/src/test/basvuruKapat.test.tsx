// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, waitFor, act } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { BelgeKarti } from '../sayfalar/BelgeKarti';
import kaynaklar from './veri/basvuruKaynaklari.json';
import yanitlar from './veri/basvuruYaniti.json';

/**
 * KAYDEDILMEMIS DEGISIKLIK UYARISI (kullanici: "başvuru kartında değişiklik
 * yaptım kapat deyince uyarı gelmedi").
 *
 * Uyari kartin IMZASINA dayanir (belgeImza): acilistaki imza ile simdiki imza
 * farkliysa kart "kirli"dir. Sessizce kaybolan bir uyari, kullanicinin
 * girdigi veriyi sessizce kaybettirir - bu yuzden hem uyarinin CIKTIGI hem de
 * HAKSIZ YERE cikmadigi denenmeli.
 *
 * ACILIS PENCERESI: kart acilirken bir kisim alan effect ile doluyor (gelis
 * sekli, varsayilan kurum, fiyat listesi, depo). Imza 1,5 sn boyunca surekli
 * tazeleniyor ki kullanici hic dokunmadan "kirli" gorunmesin. Testler o
 * pencereyi SAHTE ZAMANLA asiyor.
 */
const liste = vi.fn();
const belgeOku = vi.fn();
const secimSor = vi.fn();

vi.mock('../api/istemci', () => ({
  api: {
    liste: (k: string, i: unknown) => liste(k, i),
    belgeOku: (id: number) => belgeOku(id),
    ayarlar: () => Promise.resolve([{ anahtar: 'genel.yerel_para', deger: 'TL' }]),
    kasaIslemTurleri: () => Promise.resolve([{ kod: 19, ad: 'Satış Siparişi', grup: 'belge' }]),
    belgeDonusumler: () => Promise.resolve({ satirlar: [] }),
    dovizKur: () => Promise.resolve({ kur: 1 }),
    fiyatKampanya: () => Promise.resolve({ kampanyaId: null, ad: '', kod: '', paylasimModu: 1 }),
    fiyatKalem: () => Promise.resolve({}),
    belgeVarsayilanListe: () => Promise.resolve({ listeId: null }),
    kodListe: () => Promise.resolve({ degerler: [] }),
    aramaIsaretle: () => Promise.resolve({}),
    belgeAcikSatirlar: () => Promise.resolve({ satirlar: [] }),
    belgeEkle: () => Promise.resolve({ belge: { id: 1 }, satirlar: [], dipToplam: [] }),
    iskontoTalepleri: () => Promise.resolve([]),
  },
}));

vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {},
  onay: () => Promise.resolve(true),
  metinSor: () => Promise.resolve(null),
  guvenli: (f: () => Promise<void>) => f(),
  // Kaydedilmemis degisiklik sorusu - testin gozledigi sey bu.
  secimSor: (...a: unknown[]) => secimSor(...a),
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: {
      id: 1, kod: 'test', ad: 'Test', rolId: 1, rolAdi: 'Yonetici', dil: 0,
      yetkiSurumu: 1, subeId: 1, subeYazma: true,
      subeler: [{ id: 1, ad: 'Merkez', varsayilan: true, yazma: true }],
      urunModu: 2, moduller: ['kayit_kabul'], hekimRolu: 1,
    },
    aksiyonlar: [], kaynaklar: [], yukleniyor: false,
    yetki: () => true, aksiyonVar: () => true, aksiyonDegeri: () => 100,
  }),
}));

const kayitlar = kaynaklar as Record<string, Record<string, unknown>[]>;
const onKapat = vi.fn();

beforeEach(() => {
  vi.clearAllMocks();
  secimSor.mockResolvedValue('geri');
  liste.mockImplementation((kaynak: string) =>
    Promise.resolve({ satirlar: kayitlar[kaynak] ?? [] }));
  belgeOku.mockResolvedValue({
    belge: (yanitlar as Record<string, Record<string, unknown>>)['114349'],
    satirlar: [], dipToplam: [], izlemeNo: '',
  });
});

const ciz = (p: { id?: number } = {}) =>
  render(<MemoryRouter><BelgeKarti tur={19} {...p} onKapat={onKapat} /></MemoryRouter>);

/** Acilis penceresi (1,5 sn) gecsin - sonrasi KULLANICI degisikligi sayilir. */
const acilisiGec = async () => {
  await act(async () => { await new Promise(r => setTimeout(r, 1700)) });
};

const kapatTikla = async () => {
  const d = document.querySelector('.kapat-dugmesi') as HTMLButtonElement | null;
  if (!d) throw new Error('Kapat dugmesi yok');
  await act(async () => { d.click() });
};

/** Başvuru sekmesindeki "Başvuru Notu" - belgenin aciklama alanina yazar. */
const notYaz = async (metin: string) => {
  const sekme = [...document.querySelectorAll('.kat')]
    .find(x => x.textContent?.startsWith('Başvuru')) as HTMLElement | undefined;
  await act(async () => { sekme?.click() });
  const alan = await waitFor(() => {
    const a = [...document.querySelectorAll('label')]
      .find(l => l.textContent?.startsWith('Başvuru Notu'))
      ?.querySelector('textarea') as HTMLTextAreaElement | null;
    if (!a) throw new Error('Başvuru Notu alani yok');
    return a;
  });
  // React kontrollu alan: dogal setter ile yazip input olayi uretilir.
  const yaz = Object.getOwnPropertyDescriptor(
    HTMLTextAreaElement.prototype, 'value')!.set!;
  await act(async () => {
    yaz.call(alan, metin);
    alan.dispatchEvent(new Event('input', { bubbles: true }));
  });
};

describe('kaydedilmemis degisiklik uyarisi', () => {
  it('DEGISIKLIK YOKKEN kapat dogrudan kapatir - gereksiz soru sorulmaz', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    await acilisiGec();
    await kapatTikla();
    expect(secimSor).not.toHaveBeenCalled();
    expect(onKapat).toHaveBeenCalled();
  });

  it('BASVURU NOTU degisince kapat UYARIR (uc secenek)', async () => {
    // YENI kart: kayitli belge "Kesin" durumda kilitli olabilir, kilitli
    //   kartta zaten degisiklik yapilamaz.
    ciz();
    await acilisiGec();
    await notYaz('yeni açıklama');
    await kapatTikla();
    expect(secimSor).toHaveBeenCalled();
    const secenekler = (secimSor.mock.calls[0][1] as { kod: string }[]).map(x => x.kod);
    expect(secenekler).toEqual(['kaydet', 'iptal', 'geri']);
  });

  it('"Geri Dön" secilirse kart KAPANMAZ', async () => {
    secimSor.mockResolvedValue('geri');
    ciz();
    await acilisiGec();
    await notYaz('değişti');
    await kapatTikla();
    expect(onKapat).not.toHaveBeenCalled();
  });

  it('"İptal" secilirse degisiklik atilir ve kart KAPANIR', async () => {
    secimSor.mockResolvedValue('iptal');
    ciz();
    await acilisiGec();
    await notYaz('değişti');
    await kapatTikla();
    await waitFor(() => expect(onKapat).toHaveBeenCalled());
  });

  it('ACILIS PENCERESI icinde uyari CIKMAZ - effectler dolduruyor', async () => {
    // Kart acilir acilmaz kapatilirsa kullanici hicbir sey degistirmemistir -
    //   varsayilan kurum/liste/depo effect ile dolar, bunlar degisiklik degil.
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    await kapatTikla();
    expect(secimSor).not.toHaveBeenCalled();
  });
});
