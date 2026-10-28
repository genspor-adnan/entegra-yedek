import { describe, expect, it } from 'vitest';
import {
  biradsGovdesi, durumOku, genelOneri, lezyonKategorisi, metinUret, yeniLezyon, type BiradsDurumu, type Lezyon,
} from '../sayfalar/radyoloji/birads';

/** BI-RADS kural motoru (1194): öneri kuralları, genel kategori, metin üretimi, sunucu gövdesi. */
const lez = (x: Partial<Lezyon>): Lezyon => ({ ...yeniLezyon('us'), ...x });
const durum = (l: Lezyon[], x: Partial<BiradsDurumu> = {}): BiradsDurumu =>
  ({ kompozisyon: 'Homojen - fibroglandüler', lezyonlar: l, sonElle: null, gerekce: '', ...x });

describe('BI-RADS lezyon kategorisi', () => {
  it('basit kist 2, oval düzgün paralel solid 3', () => {
    expect(lezyonKategorisi(lez({ eko: 'Anekoik', kenar: 'Düzgün sınırlı' }), 'us').kategori).toBe('2');
    expect(lezyonKategorisi(lez({ eko: 'Hipoekoik', kenar: 'Düzgün sınırlı' }), 'us').kategori).toBe('3');
  });
  it('kenar ve şekil şüpheyi artırır', () => {
    expect(lezyonKategorisi(lez({ kenar: 'Mikrolobüle' }), 'us').kategori).toBe('4A');
    expect(lezyonKategorisi(lez({ kenar: 'Belirsiz' }), 'us').kategori).toBe('4B');
    expect(lezyonKategorisi(lez({ sekil: 'Düzensiz', oryantasyon: 'Paralel değil' }), 'us').kategori).toBe('4C');
    expect(lezyonKategorisi(lez({ sekil: 'Düzensiz', kenar: 'Spiküle' }), 'us').kategori).toBe('5');
  });
  it('kalsifikasyon ve büyüme', () => {
    expect(lezyonKategorisi(lez({ kalsifikasyon: 'İnce lineer / dallanan' }), 'mg').kategori).toBe('5');
    expect(lezyonKategorisi(lez({ kalsifikasyon: 'Amorf' }), 'mg').kategori).toBe('4B');
    expect(lezyonKategorisi(lez({ buyume: true }), 'us').kategori).toBe('4A');
  });
});

describe('BI-RADS genel öneri ve metin', () => {
  it('lezyon yoksa 1, varsa en yüksek', () => {
    expect(genelOneri(durum([]), 'us').kategori).toBe('1');
    expect(genelOneri(durum([lez({ eko: 'Anekoik' }), lez({ kenar: 'Belirsiz' })]), 'us').kategori).toBe('4B');
  });
  it('metin: lezyon cümlesi ve sonuç', () => {
    const m = metinUret(durum([lez({ taraf: 'Sol', saat: '2:00', boyut: '6×5 mm', eko: 'Anekoik' })]), 'us');
    expect(m.bulgular).toContain('Sol meme saat 2:00 hizasında');
    expect(m.bulgular).toContain('[BI-RADS 2]');
    expect(m.sonuc).toBe('BI-RADS 2. Rutin tarama önerilir.');
  });
  it('öneriden farklı karar: gerekçe metne ve gövdeye girer', () => {
    const d = durum([lez({ kenar: 'Belirsiz' })], { sonElle: '3', gerekce: 'önceki tetkikle stabil' });
    expect(metinUret(d, 'us').sonuc).toContain('Not: önceki tetkikle stabil');
    const g = biradsGovdesi(d, 'us');
    expect(g).toMatchObject({ oneri: '4B', kategori: '3', gerekce: 'önceki tetkikle stabil' });
    expect(g.lezyonlar[0]).toMatchObject({ kategori: '4B', buyume: 0 });
  });
  it('kayıttan okuma: farklı kategori elle seçim olarak döner', () => {
    const d = durumOku({ biradsKategori: '3', biradsGerekce: 'x' },
                       [{ taraf: 'Sağ', kenar: 'Belirsiz', sekil: 'Oval', oryantasyon: 'Paralel', eko: 'Hipoekoik' }], 'us');
    expect(d.sonElle).toBe('3');
    expect(durumOku({ biradsKategori: '4B' }, [{ kenar: 'Belirsiz', sekil: 'Oval' }], 'us').sonElle).toBeNull();
  });
});

describe('tek parça metne bölüm yazma', () => {
  it('var olan BULGULAR / SONUÇ kısmı değişir, öteki başlıklar korunur; yoksa sona eklenir', async () => {
    const { tekMetneBolumYaz } = await import('../sayfalar/radyoloji/raporBicimi');
    const m = 'TEKNİK:\nUS.\n\nBULGULAR:\neski\nsatır\n\nSONUÇ:\neski sonuç';
    const y = tekMetneBolumYaz(tekMetneBolumYaz(m, 'Bulgular', 'yeni bulgu'), 'Sonuç', 'yeni sonuç');
    expect(y).toBe('TEKNİK:\nUS.\n\nBULGULAR:\nyeni bulgu\n\nSONUÇ:\nyeni sonuç');
    expect(tekMetneBolumYaz('serbest metin', 'Sonuç', 'S')).toBe('serbest metin\n\nSONUÇ:\nS');
  });
});
