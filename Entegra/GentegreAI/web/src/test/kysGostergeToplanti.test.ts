import { describe, expect, it } from 'vitest';
import { KYS_GOSTERGE_LISTELERI } from '../sayfalar/listeTanimlari.KysGosterge';
import { KYS_TOPLANTI_LISTELERI } from '../sayfalar/listeTanimlari.KysToplanti';

describe('kurumsal kalite göstergeler / toplantılar', () => {
  const hepsi = [...KYS_GOSTERGE_LISTELERI, ...KYS_TOPLANTI_LISTELERI];
  it('Kalite menüsünde, kys modülünde, kendi yetki koduyla', () => {
    for (const l of hepsi) {
      expect(l.menuGrup).toBe('Kalite');
      expect(l.modul).toBe('kys');
      expect(l.yetkiKodu).toMatch(/^kys\.(gosterge|toplanti|karar)$/);
      expect(l.urunModu).toBeUndefined();
    }
  });
  it('generic kart rotaları kaynakla aynı', () => {
    // Özel sayfa (Politika & Hedefler, 1063) kartsızdır - hedef kartı generic listenin.
    for (const l of hepsi.filter(x => !x.ozelSayfa)) expect(l.kartYolu).toBe(`/${l.rota}`);
  });
});
