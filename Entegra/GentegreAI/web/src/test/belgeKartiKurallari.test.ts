import { describe, it, expect } from 'vitest';
import {
  provizyonVarMi, donusumSatirlari, posFisiSecimi, kasaAramaSirasi,
  gelisSekliKarari, acikBorcHesapla,
} from '../sayfalar/belgeKartiKurallari';
import type { AcikSatir } from '../api/sozlesme';

/**
 * Belge kartinin is kurallari - hepsi kullanici kararı, hepsi burada kilitli.
 * Kart 2000 satirlik bir bilesen; bu kurallar orada yasarken kimse
 * dogrulayamiyordu.
 */
const satir = (y: Partial<AcikSatir> = {}): AcikSatir => ({
  satirId: 1, belgeId: 100, belgeNo: 'B-1', belgeTarihi: '2026-09-03',
  satirTur: 2, stokId: null, hizmetId: 900, stokKodu: 'MUA', stokAdi: 'Muayene',
  miktar: 1, kapatilanMiktar: 0, kalanMiktar: 1,
  birim: 1, birimFiyat: 1000, iskonto: 0, kdv: 10,
  belgeTur: 19, tarafUnvan: 'HASTA', belgeDovizi: 'TL', kapanmaDurum: 0,
  ...y,
} as AcikSatir);

describe('provizyonVarMi - pay kolonlari / provizyon sekmesi', () => {
  const kurumlar = [{ id: 1, tur: 1 }, { id: 2, tur: 2 }, { id: 3, tur: 3 }];

  it('Özel kurumda YOK (hasta kendi öder)', () => {
    expect(provizyonVarMi(kurumlar, 1)).toBe(false);
  });
  it('ÖSS ve SGK kurumunda VAR', () => {
    expect(provizyonVarMi(kurumlar, 2)).toBe(true);
    expect(provizyonVarMi(kurumlar, 3)).toBe(true);
  });
  it('kurum secilmemisse YOK', () => {
    expect(provizyonVarMi(kurumlar, null)).toBe(false);
  });
  it('liste henuz yuklenmediyse YOK (sahte "var" gostermez)', () => {
    expect(provizyonVarMi([], 3)).toBe(false);
  });
});

describe('donusumSatirlari - ADET olcusu', () => {
  it('kalan miktari gonderir, tutar GONDERMEZ', () => {
    const c = donusumSatirlari([satir({ miktar: 5, kalanMiktar: 2 })], 16, 'adet');
    expect(c).toEqual([{ satirId: 1, miktar: 2 }]);
  });

  it('kalani bitmis satiri atlar', () => {
    expect(donusumSatirlari([satir({ kalanMiktar: 0 })], 16, 'adet')).toEqual([]);
  });
});

describe('donusumSatirlari - TUTAR olcusu (352)', () => {
  // Hasta payi 1000, tahsil edilen 300 (KDV haric matrahlar), KDV %10.
  const kismi = satir({ hastaTutar: 1000, kurumTutar: 0, hastaKalan: 1000,
                        hastaTahsilMatrah: 300, tutar: 1000, tutarKalan: 1000 });

  it('fiste TAHSIL EDILEN kadar cevirir (matraha inerek)', () => {
    const c = donusumSatirlari([kismi], 16, 'tutar');
    expect(c).toHaveLength(1);
    expect(c[0].satirId).toBe(1);
    expect(c[0].tutar).toBeCloseTo(300, 4);      // 330 KDV dahil / 1,10
  });

  it('tahakkukta KALANIN TAMAMINI cevirir', () => {
    const c = donusumSatirlari([kismi], 17, 'tutar');
    expect(c[0].tutar).toBeCloseTo(1000, 4);
  });

  it('tahsilat yoksa fis satiri URETMEZ (bos donusum yapilmaz)', () => {
    const tahsilatsiz = satir({ hastaTutar: 1000, hastaKalan: 1000, hastaTahsilMatrah: 0 });
    expect(donusumSatirlari([tahsilatsiz], 16, 'tutar')).toEqual([]);
  });

  it('kurus altindaki artik satir acmaz', () => {
    const artik = satir({ hastaTutar: 1000, hastaKalan: 1000, hastaTahsilMatrah: 0.001 });
    expect(donusumSatirlari([artik], 16, 'tutar')).toEqual([]);
  });
});

describe('posFisiSecimi (355)', () => {
  it('tahsil edilen kadar satir ve KDV DAHIL toplam verir', () => {
    const s = satir({ hastaTutar: 1000, hastaKalan: 1000, hastaTahsilMatrah: 500, kdv: 10 });
    const { satirlar, toplamDahil } = posFisiSecimi([s]);
    expect(satirlar).toHaveLength(1);
    expect(satirlar[0].tutar).toBeCloseTo(500, 4);   // API matrah ister
    expect(toplamDahil).toBeCloseTo(550, 4);         // ekranda KDV dahil gosterilir
  });

  it('dagitilmis tahsilat yoksa bos doner (sessizce cikilir)', () => {
    expect(posFisiSecimi([satir({ hastaTahsilMatrah: 0 })]).satirlar).toEqual([]);
  });
});

describe('kasaAramaSirasi (hesap.atama, 200)', () => {
  it('once KULLANICIYA atanmis kasa, sonra ANA KASA, sonra herhangi biri', () => {
    const s = kasaAramaSirasi(4901, 'TL');
    expect(s).toHaveLength(3);
    const atama = (k: unknown) =>
      (k as { kosullar: { alan?: string; deger?: unknown }[] })
        .kosullar.find(x => x.alan === 'atama')?.deger;
    expect(atama(s[0])).toBe(4901);
    expect(atama(s[1])).toBe(-1);
    expect(atama(s[2])).toBeUndefined();
  });

  it('kullanici yoksa ANA KASA ile baslar', () => {
    const s = kasaAramaSirasi(null, 'TL');
    expect(s).toHaveLength(2);
  });

  it('her adim yerel para ve AKTIF hesap suzgecini tasir', () => {
    for (const k of kasaAramaSirasi(1, 'USD')) {
      const alt = (k as { kosullar: { alan?: string; deger?: unknown }[] }).kosullar;
      expect(alt.find(x => x.alan === 'dovizCinsi')?.deger).toBe('USD');
      expect(alt.find(x => x.alan === 'durum')?.deger).toBe(1);
      expect(alt.find(x => x.alan === 'tur')?.deger).toBe('K');
    }
  });
});

describe('gelisSekliKarari', () => {
  it('gonderen secilince Sevkli (3)', () => expect(gelisSekliKarari(true)).toBe(3));
  it('gonderen yoksa Kendi imkânıyla (1)', () => expect(gelisSekliKarari(false)).toBe(1));
});

describe('acikBorcHesapla', () => {
  it('kalem varken CANLI onizleme toplamini kullanir', () => {
    expect(acikBorcHesapla(2, 10000, 4000, 3000)).toBe(7000);
  });
  it('kalem yokken sunucunun kayitli toplamini kullanir', () => {
    expect(acikBorcHesapla(0, 0, 4000, 1000)).toBe(3000);
  });
  it('fazla tahsilatta EKSIYE dusmez... degeri oldugu gibi verir (ekranda "Alacaklı")', () => {
    expect(acikBorcHesapla(1, 10000, 0, 20100)).toBe(-10100);
  });
  it('kurus yuvarlar', () => {
    expect(acikBorcHesapla(1, 100.005, 0, 0)).toBe(100.01);
  });
});
