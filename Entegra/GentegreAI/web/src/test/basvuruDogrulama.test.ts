import { describe, it, expect } from 'vitest';
import { belgeDogrula, type BelgeGirdisi } from '../sayfalar/belgeKaydet';

/**
 * BASVURUNUN ZORUNLU ALANLARI (kullanici: "bölüm, dr, ödeyen kurum zorunlu").
 *
 * Ucu de sonradan telafi edilemeyen bilgi: BOLUM fiyat listesini ve prim
 * dagitimini, HEKIM primin kime yazilacagini, ODEYEN KURUM ise pay dagilimini
 * ve provizyon kurallarini belirler. Bos gecilen bir basvuruda islem
 * sahiplenilemiyor, hata ancak ay sonu hakedisinde goze carpiyordu.
 */
const g = (y: Partial<BelgeGirdisi> = {}): BelgeGirdisi => ({
  tur: 19, cari: { id: 5, unvan: 'Test Hasta' },
  tarih: '2026-09-04T10:00', geriGun: 7, seri: 'WEB', belgeNo: '', vadeGun: '30',
  aciklama: '', satirlar: [], yerelPara: 'TL', belgeKuru: '1',
  raporDovizi: 'TL', ekstreDovizi: 'TL', senaryo: 0, teslimSekli: 0, fisTipi: 0,
  aracPlaka: '', soforAd: '', soforTckn: '', sevkTarihi: '',
  basvuruMu: true, kilitli: false,
  odeyenKurumId: 4990, bolumId: 3, personelId: 4997,
  ...y,
} as BelgeGirdisi);

describe('basvuruda zorunlu alanlar', () => {
  it('ucu de doluysa gecer', () => {
    expect(belgeDogrula(g())).toBeNull();
  });

  it('ODEYEN KURUM bos ise kendi alaninda hata verir', () => {
    expect(belgeDogrula(g({ odeyenKurumId: null }))).toEqual(
      { odeyenKurumId: 'Ödeyen kurum seçilmeli.' });
  });

  it('BOLUM bos ise kendi alaninda hata verir', () => {
    expect(belgeDogrula(g({ bolumId: null }))).toEqual({ bolumId: 'Bölüm seçilmeli.' });
  });

  it('HEKIM / gonderen bos ise kendi alaninda hata verir', () => {
    expect(belgeDogrula(g({ personelId: null }))).toEqual(
      { personelId: 'Hekim / gönderen seçilmeli.' });
  });

  it('BOLUM ve HEKIM birlikte eksikse IKISI BIRDEN dondurulur', () => {
    // Memur uc alani tek tek deneyerek bulmasin - hepsi ayni anda kizarsin.
    expect(belgeDogrula(g({ bolumId: null, personelId: null }))).toEqual({
      bolumId: 'Bölüm seçilmeli.',
      personelId: 'Hekim / gönderen seçilmeli.',
    });
  });

  it('ODEYEN KURUM once sorulur - o eksikken oteki ikisi beklemeye alinir', () => {
    const h = belgeDogrula(g({ odeyenKurumId: null, bolumId: null, personelId: null }));
    expect(h).toEqual({ odeyenKurumId: 'Ödeyen kurum seçilmeli.' });
  });
});

describe('kurallarin GECERLI OLMADIGI durumlar', () => {
  it('KILITLI (kesin) belgede kural islemez - eski kayit oldugu gibi kalir', () => {
    // Kullanici: "ödeyen kurum dolu olmalı diyor ama her taraf donmuş" -
    //   degistirilemeyen alani zorunlu tutmak karti kilitliyordu.
    expect(belgeDogrula(g({
      kilitli: true, odeyenKurumId: null, bolumId: null, personelId: null,
    }))).toBeNull();
  });

  it('BASVURU DEGILSE (normal siparis) bu alanlar aranmaz', () => {
    expect(belgeDogrula(g({
      basvuruMu: false, odeyenKurumId: null, bolumId: null, personelId: null,
      // Basvuru disi belge KALEMSIZ olamaz - o kural ayri.
      satirlar: [{ stokId: 1 } as never],
    }))).toBeNull();
  });

  it('BASVURU KALEMSIZ acilabilir - once protokol, hizmetler sonra', () => {
    expect(belgeDogrula(g({ satirlar: [] }))).toBeNull();
  });
});
