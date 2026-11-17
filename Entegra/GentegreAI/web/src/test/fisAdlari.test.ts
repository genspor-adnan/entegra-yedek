import { describe, it, expect } from 'vitest';
import { belgeKisaAdi, belgeTuruBilgisi, HASTA_FISI } from '../sayfalar/belgeTuru';
import { donusumMenusu, DONUSUM_MENUSU } from '../sayfalar/listeTanimlari';
import { HEDEFLER } from '../bilesenler/belge/donusumHedefleri';

/**
 * FİŞ ADLARI YÖNLÜ, TEK KAYNAKTAN (kullanıcı 17.11.2026: "Belgelerde Fiş rename Satış Fişi", "alış fişi de Alış Fişi
 * olsun"): kısa ad, başlık adı, dönüşüm menüsü (türe göre ve sabit yedek) aynı adı verir.
 */
describe('fiş adları', () => {
  it('kısa ad ve başlık adı yönlü', () => {
    expect(belgeKisaAdi(16)).toBe('Satış Fişi');
    expect(belgeKisaAdi(12)).toBe('Alış Fişi');
    expect(belgeKisaAdi(HASTA_FISI)).toBe('Hasta Fişi');
    expect(belgeKisaAdi(3)).toBe('Fiş');
    expect(belgeTuruBilgisi(16).ad).toBe('Satış Fişi');
    expect(belgeTuruBilgisi(12).ad).toBe('Alış Fişi');
    expect(belgeTuruBilgisi(HASTA_FISI).ad).toBe('Hasta Fişi');
  });

  it('dönüşüm menüsü adı kısa addan alır - türe göre ve sabit yedek menüde', () => {
    const satis = donusumMenusu(14, HEDEFLER)['belge.donustur'].map(x => x.ad);
    expect(satis.some(a => a.endsWith('Satış Fişi'))).toBe(true);
    const alis = donusumMenusu(10, HEDEFLER)['belge.donustur'].map(x => x.ad);
    expect(alis.some(a => a.endsWith('Alış Fişi'))).toBe(true);
    expect(DONUSUM_MENUSU['belge.donustur'].find(x => x.kod === 'belge.donustur.16')!.ad).toContain('Satış Fişi');
  });
});
