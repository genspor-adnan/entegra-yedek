import { describe, it, expect } from 'vitest';
import { sekmeKosuluSaglandi } from '../bilesenler/kartSekmeleri';

/**
 * KOSULLU SEKME kurali (`DetayTanimi.KosulAlani`).
 *
 * Yanlisi iki yone de zarar verir: sekme gereksiz acilirsa kullaniciya
 * doldurulacak bir sey varmis izlenimi verir; HIC acilmazsa girilmis veri
 * (ör. personelin prim rolleri) kartta gorunmez olur ve kimse fark etmez.
 *
 * Iki bicim var:
 *   "paket"                -> kartin kendi mantik alani
 *   "ozluk.calismaSekli=3" -> 1:1 uzanti satirindaki alan su degere esit mi
 */
const yok = () => [];

describe('kartin kendi alanina bakan kosul', () => {
  it('alan isaretliyse sekme acilir, degilse acilmaz', () => {
    expect(sekmeKosuluSaglandi('paket', { paket: 1 }, yok)).toBe(true);
    expect(sekmeKosuluSaglandi('paket', { paket: 0 }, yok)).toBe(false);
    expect(sekmeKosuluSaglandi('paket', {}, yok)).toBe(false);
  });
});

describe('DETAY alanina bakan kosul (ozluk.calismaSekli=3)', () => {
  const ozluk = (v: unknown) => (ad: string) =>
    (ad === 'ozluk' ? [{ id: 1, calismaSekli: v }] : []);

  it('"Primli" (3) isaretli personelde Prim Rolleri sekmesi acilir', () => {
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk(3))).toBe(true);
  });

  it('tam / yari zamanlida acilmaz - prim almayan personele bos grid gosterilmez', () => {
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk(1))).toBe(false);
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk(2))).toBe(false);
  });

  it('isaret HIC girilmemisse acilmaz (null / bos / tanimsiz)', () => {
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk(null))).toBe(false);
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk(''))).toBe(false);
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk(undefined))).toBe(false);
  });

  it('kod alani METIN de gelse sayi da gelse ayni sonuc', () => {
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk('3'))).toBe(true);
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, ozluk(3))).toBe(true);
  });

  it('detay satiri HENUZ YOKSA (yeni kart) acilmaz - cokmez', () => {
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, yok)).toBe(false);
  });

  it('coklu detayda HERHANGI BIR satir sarti saglarsa yeter', () => {
    const cok = () => [{ calismaSekli: 1 }, { calismaSekli: 3 }];
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli=3', {}, cok)).toBe(true);
  });

  it('deger verilmezse "alan dolu mu" sorusuna doner', () => {
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli', {}, ozluk(1))).toBe(true);
    expect(sekmeKosuluSaglandi('ozluk.calismaSekli', {}, ozluk(0))).toBe(false);
  });
});
