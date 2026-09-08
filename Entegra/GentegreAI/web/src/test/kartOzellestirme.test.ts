import { describe, it, expect } from 'vitest';
import { KART_OZELLESTIRME, kartOzellestirme } from '../sayfalar/liste/kartOzellestirme';

/**
 * Karta özel yerleşim artık VERİ (Liste.tsx'in içindeki üçlü koşullar değil).
 * Testler yerleşimin kendisini değil, SÖZLEŞMESİNİ korur: tanımsız kaynak
 * çağıranı patlatmamalı, gömülü detay ile gizli sekme birbiriyle tutarlı olmalı.
 */
describe('kartOzellestirme', () => {
  it('tanımsız kaynakta BOŞ nesne döner - çağıran koşul yazmasın', () => {
    expect(kartOzellestirme('boyle-bir-kart-yok')).toEqual({});
    expect(kartOzellestirme('')).toEqual({});
  });

  it('kurum kartında Genel sekmesi ÖNCE gelir', () => {
    expect(kartOzellestirme('kurum').sekmeSirasi?.[0]).toBe('Genel');
  });

  it('kurumda adres grubu Adres / Fatura Bilgisi sekmesine gömülü', () => {
    expect(kartOzellestirme('kurum').detayGrupta?.adresler?.grup)
      .toBe('Adres / Fatura Bilgisi');
  });

  it('kurum türü ayrı sekme açmaz', () => {
    expect(kartOzellestirme('kurum').gizliDetaylar).toContain('kurumRolu');
  });

  it('muayenede vitaller sekme açmaz ama ızgarası vardır', () => {
    const m = kartOzellestirme('muayene');
    expect(m.gizliDetaylar).toContain('vitaller');
    expect(m.detayIzgara?.vitaller).toBeDefined();
  });

  it('GÖMÜLEN detay ayrıca SEKME de açmaz - ikisi çakışmamalı', () => {
    // Aynı detay hem bir gruba gömülüp hem kendi sekmesini açarsa kullanıcı
    //   aynı gridi iki yerde görür ve hangisinin geçerli olduğunu bilemez.
    for (const [kaynak, o] of Object.entries(KART_OZELLESTIRME)) {
      for (const detay of Object.keys(o.detayGrupta ?? {})) {
        expect(o.detaySecenekleri?.[detay], `${kaynak}.${detay}`).toBeUndefined();
      }
    }
  });

  it('ızgaraya alınan detay sekme listesinde GİZLİ olmalı', () => {
    for (const [kaynak, o] of Object.entries(KART_OZELLESTIRME)) {
      for (const detay of Object.keys(o.detayIzgara ?? {})) {
        expect(o.gizliDetaylar ?? [], `${kaynak}.${detay}`).toContain(detay);
      }
    }
  });
});
