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
