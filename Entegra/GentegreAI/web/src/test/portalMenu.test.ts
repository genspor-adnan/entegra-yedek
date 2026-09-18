import { describe, expect, it } from 'vitest';
import { aktifBolum, portalBolumleri, PORTAL_ADI, type MenuKaynagi }
  from '../sayfalar/portal/portalMenu';

/**
 * PORTAL MENÜSÜ V2 (796/818).
 *
 * Menünün İÇERİĞİNE yetki karar veriyor; buradaki tablo yalnız adlandırıp
 * gruplandırıyor. Testin koruduğu üç söz:
 *   1. Yetkisi olan bir ekran menüden DÜŞMEZ (eşlemede yoksa "Diğer"e gider).
 *   2. Aynı ekran portala göre farklı adlanır.
 *   3. Boş bölüm başlığı çizilmez.
 */

const oge = (yol: string, ad = 'Ekran', ic = '•'): MenuKaynagi => ({ yol, ad, ic });

describe('portal menüsü', () => {
  it('dış hekimde ekranlar mockup bölümlerine düşer', () => {
    const b = portalBolumleri(
      [oge('/hasta'), oge('/lab-istem'), oge('/lab-sonuc'), oge('/radyoloji')], 1);

    expect(b.map(x => x.ad)).toEqual(['Portal', 'Laboratuvar', 'Radyoloji']);
    expect(b[0].ogeler[0].ad).toBe('Hastalarım');
    expect(b[1].ogeler.map(x => x.ad)).toEqual(['Lab istemlerim', 'Lab sonuçları']);
  });

  it('aynı ekran portala göre farklı adlanır', () => {
    const hekim = portalBolumleri([oge('/hasta')], 1)[0].ogeler[0].ad;
    const kurum = portalBolumleri([oge('/hasta')], 2)[0].ogeler[0].ad;
    const hasta = portalBolumleri([oge('/hasta')], 3)[0].ogeler[0].ad;

    // "Hasta Listesi" üç portalda üç ayrı şey demek: dış hekimin kendi
    //   hastaları, kurumun gönderdikleri, hastanın kendi kaydı.
    expect([hekim, kurum, hasta])
      .toEqual(['Hastalarım', 'Gönderdiğim hastalar', 'Kayıtlarım']);
  });

  it('eşlemede olmayan ekran GİZLENMEZ, Diğer bölümüne düşer', () => {
    // Yetkisi olan ekranı menüden düşürmek, kullanıcının erişimi varmış gibi
    //   görünüp ekranı hiç bulamaması demekti.
    const b = portalBolumleri([oge('/hasta'), oge('/yeni-ekran', 'Yeni Ekran', '🆕')], 1);
    const diger = b.find(x => x.ad === 'Diğer');
    expect(diger?.ogeler).toEqual([{ yol: '/yeni-ekran', ad: 'Yeni Ekran', ic: '🆕' }]);
  });

  it('boş bölüm başlığı çizilmez', () => {
    const b = portalBolumleri([oge('/hasta')], 1);
    expect(b.map(x => x.ad)).toEqual(['Portal']);
  });

  it('yetkisiz kullanıcıda menü tamamen boş', () => {
    expect(portalBolumleri([], 3)).toEqual([]);
  });

  it('hasta portalında sıra: kayıtlar, randevu, sonra sonuçlar', () => {
    const b = portalBolumleri(
      [oge('/lab-sonuc'), oge('/randevu'), oge('/hasta'), oge('/radyoloji')], 3);
    expect(b.map(x => x.ad)).toEqual(['Portalım', 'Sonuçlarım']);
    expect(b[0].ogeler.map(x => x.ad)).toEqual(['Kayıtlarım', 'Randevularım']);
    expect(b[1].ogeler.map(x => x.ad)).toEqual(['Lab sonuçlarım', 'Görüntülemelerim']);
  });

  it('aktif bölüm EN UZUN eşleşmeden bulunur', () => {
    const b = portalBolumleri([oge('/hasta'), oge('/lab-sonuc'), oge('/lab-istem')], 2);
    expect(aktifBolum(b, '/lab-sonuc')).toBe('Laboratuvar');
    // Kart yolu (/hasta/4911) da menüde hastayı seçili gösterir.
    expect(aktifBolum(b, '/hasta/4911')).toBe('Portal');
    expect(aktifBolum(b, '/bilinmeyen')).toBeNull();
  });

  it('portal adları üç tür için tanımlı', () => {
    expect(PORTAL_ADI[1]).toBe('Hekim Portalı');
    expect(PORTAL_ADI[2]).toBe('Kurum Portalı');
    expect(PORTAL_ADI[3]).toBe('Hasta Portalı');
  });
});
