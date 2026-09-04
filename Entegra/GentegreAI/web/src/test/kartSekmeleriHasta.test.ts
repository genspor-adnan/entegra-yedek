import { describe, it, expect } from 'vitest';
import { sekmeleriKur } from '../bilesenler/kartSekmeleri';
import type { KartMetaYaniti, KartDetayMeta } from '../api/sozlesme';

/**
 * HASTA KARTI SEKME SIRASI.
 *
 * "Başvurular" sekmesi kartin DETAYI degil - baska bir ekranin kayitlari.
 * Detay sekmelerinin ARDINDAN geldigi icin sirasi katalogdaki detay sirasina
 * baglidir; biri eklenir/cikarilirsa sessizce kayar.
 */
const detay = (ad: string, baslik: string): KartDetayMeta =>
  ({ ad, baslik, alanlar: [], kosulAlani: null, tekSatir: false } as unknown as KartDetayMeta);

const meta = (detaylar: KartDetayMeta[]) =>
  ({ alanlar: [], detaylar } as unknown as KartMetaYaniti);

const kur = (kaynak: string, yeniMi: boolean, detaylar: KartDetayMeta[]) =>
  sekmeleriKur({
    gruplar: [], meta: meta(detaylar), kaynak, deger: {}, yeniMi,
    personelGibiKart: kaynak === 'hasta' || kaynak === 'personel',
  }).map(x => x.baslik);

describe('hasta kartinda "Başvurular" sekmesi', () => {
  it('KURUM / ÖDEYEN sekmesinin HEMEN SAGINDA', () => {
    const b = kur('hasta', false, [detay('acilKisiler', 'Yakınlar'),
                                   detay('kurum', 'Kurum / Ödeyen')]);
    expect(b.indexOf('Başvurular')).toBe(b.indexOf('Kurum / Ödeyen') + 1);
  });

  it('YENI kayitta CIZILMEZ - hasta kimligi henuz yok', () => {
    expect(kur('hasta', true, [detay('kurum', 'Kurum / Ödeyen')]))
      .not.toContain('Başvurular');
  });

  it('PERSONEL kartinda YOK - basvuru hastaya ait', () => {
    expect(kur('personel', false, [detay('ozluk', 'Özlük')]))
      .not.toContain('Başvurular');
  });
});

describe('hasta "Genel" sekmesi', () => {
  // Kimlik Bilgileri kutusu, kimlik detayi ve Yakinlar gridi bu sekmeye
  //   ciziliyor - ama sekme yalniz GRUPSUZ GORUNUR bir alan varsa olusuyordu.
  //   Hastada tek gorunur grupsuz alan "randevuVerilebilir"di; gizlenince
  //   sekme de yok oldu ve icindeki uc bolum birden kayboldu.
  it('GORUNUR GRUPSUZ ALAN OLMASA DA cizilir', () => {
    const b = kur('hasta', false, [detay('kurum', 'Kurum / Ödeyen')]);
    expect(b).toContain('Genel');
  });

  it('Genel EN BASTA durur', () => {
    const b = kur('hasta', false, [detay('kurum', 'Kurum / Ödeyen')]);
    expect(b[0]).toBe('Genel');
  });

  it('zaten varsa IKINCI KEZ eklenmez', () => {
    const b = sekmeleriKur({
      gruplar: [['Genel', []]], meta: meta([detay('kurum', 'Kurum / Ödeyen')]),
      kaynak: 'hasta', deger: {}, yeniMi: false, personelGibiKart: true,
    }).map(x => x.baslik);
    expect(b.filter(x => x === 'Genel')).toHaveLength(1);
  });
});
