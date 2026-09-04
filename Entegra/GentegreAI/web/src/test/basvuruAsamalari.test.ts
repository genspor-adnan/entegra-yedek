import { describe, it, expect } from 'vitest';
import {
  basvuruAsamalari, KURUM_OZEL, KURUM_OSS, KURUM_SGK,
  type AsamaGirdisi,
} from '../sayfalar/belgeKarti/basvuruAsamalari';

/**
 * BASVURU TAMAMLANMA SERIDI (370).
 *
 * Serit "bu basvuruda ne eksik" sorusunun TEK cevabi - yanlisi iki yone de
 * zarar verir: eksik is tamam gorunurse basvuru yarim kapanir (faturalanmamis
 * hizmet, tahsil edilmemis para), tamam is eksik gorunurse memur olmayan bir
 * isi arar. Sira da kozmetik degil: odeyen kuruma gore provizyonun YERI
 * degisir.
 */
const g = (y: Partial<AsamaGirdisi> = {}): AsamaGirdisi => ({
  kurumTuru: KURUM_OZEL, kayitliId: 0, ucretGenel: 0, tahsilToplam: 0,
  provizyonDurum: 0, kapanmaDurum: 0, ...y,
});
const adlar = (y: Partial<AsamaGirdisi> = {}) =>
  basvuruAsamalari(g(y)).asamalar.map(a => a.ad);
const tamam = (y: Partial<AsamaGirdisi>, kod: string) =>
  basvuruAsamalari(g(y)).asamalar.find(a => a.kod === kod)!.tamam;

describe('asama sirasi odeyen kuruma gore', () => {
  it('ÖZELDE provizyon HIC cizilmez - hasta kendi oder', () => {
    expect(adlar({ kurumTuru: KURUM_OZEL }))
      .toEqual(['Başvuru', 'Ücretlendirme', 'Tahsilat', 'Faturalama']);
  });

  it('ÖSS: provizyon UCRETLENDIRMEDEN ONCE (police kapsami once bilinmeli)', () => {
    expect(adlar({ kurumTuru: KURUM_OSS }))
      .toEqual(['Başvuru', 'Provizyon', 'Ücretlendirme', 'Tahsilat', 'Faturalama']);
  });

  it('SGK: provizyon UCRETLENDIRMEDEN SONRA (takip girilen hizmetler uzerinden)', () => {
    expect(adlar({ kurumTuru: KURUM_SGK }))
      .toEqual(['Başvuru', 'Ücretlendirme', 'Provizyon', 'Tahsilat', 'Faturalama']);
  });

  it('kurum SECILMEMISSE ozel akisi cizilir', () => {
    expect(adlar({ kurumTuru: null })).toHaveLength(4);
    expect(adlar({ kurumTuru: undefined })).toHaveLength(4);
  });

  it('her asama kendi rengini tasir', () => {
    const renkler = basvuruAsamalari(g({ kurumTuru: KURUM_OSS }))
      .asamalar.map(a => a.renk);
    expect(renkler).toEqual(['kirmizi', 'turuncu', 'sari', 'mavi', 'yesil']);
  });
});

describe('asamalarin tamamlanma kurallari', () => {
  it('BASVURU: protokol verilince (kayit olusunca) tamamlanir', () => {
    expect(tamam({ kayitliId: 0 }, 'basvuru')).toBe(false);
    expect(tamam({ kayitliId: 114351 }, 'basvuru')).toBe(true);
  });

  it('UCRETLENDIRME: en az bir kalem tutari olmali', () => {
    expect(tamam({ ucretGenel: 0 }, 'ucret')).toBe(false);
    expect(tamam({ ucretGenel: 1100 }, 'ucret')).toBe(true);
  });

  it('TAHSILAT: acik borc kalmayinca tamamlanir', () => {
    expect(tamam({ ucretGenel: 1100, tahsilToplam: 500 }, 'tahsilat')).toBe(false);
    expect(tamam({ ucretGenel: 1100, tahsilToplam: 1100 }, 'tahsilat')).toBe(true);
    // Fazla tahsilat da kapatir - hasta lehine bakiye ayri bir konu.
    expect(tamam({ ucretGenel: 1100, tahsilToplam: 1500 }, 'tahsilat')).toBe(true);
  });

  it('TAHSILAT: UCRET YOKKEN tamam SAYILMAZ - 0 TL "tahsil edildi" degildir', () => {
    expect(tamam({ ucretGenel: 0, tahsilToplam: 0 }, 'tahsilat')).toBe(false);
  });

  it('TAHSILAT: kurus altindaki fark kapanmis sayilir (yuvarlama artigi)', () => {
    expect(tamam({ ucretGenel: 500.004, tahsilToplam: 500 }, 'tahsilat')).toBe(true);
    expect(tamam({ ucretGenel: 500.02, tahsilToplam: 500 }, 'tahsilat')).toBe(false);
  });

  it('PROVIZYON: yalniz Onaylandi (1) ve Kismi Onay (3) tamamlar', () => {
    const oss = (d: number) => tamam({ kurumTuru: KURUM_OSS, provizyonDurum: d }, 'provizyon');
    expect(oss(0)).toBe(false);   // Alınmadı
    expect(oss(1)).toBe(true);    // Onaylandı
    expect(oss(2)).toBe(false);   // Reddedildi - is bitmedi, DURDU
    expect(oss(3)).toBe(true);    // Kısmi Onay
    expect(oss(4)).toBe(false);   // İptal
  });

  it('FATURALAMA: yalniz TAM faturalanmis belge (kapanma 2) tamamlar', () => {
    expect(tamam({ kapanmaDurum: 0 }, 'fatura')).toBe(false);
    expect(tamam({ kapanmaDurum: 1 }, 'fatura')).toBe(false);  // kismi
    expect(tamam({ kapanmaDurum: 2 }, 'fatura')).toBe(true);
  });
});

describe('yuzde ve tamamlanma', () => {
  it('hicbir sey yapilmamis basvuruda %0', () => {
    expect(basvuruAsamalari(g()).yuzde).toBe(0);
    expect(basvuruAsamalari(g()).tamamlandi).toBe(false);
  });

  it('ÖZELDE dort asama: her biri %25', () => {
    expect(basvuruAsamalari(g({ kayitliId: 1 })).yuzde).toBe(25);
    expect(basvuruAsamalari(g({ kayitliId: 1, ucretGenel: 100 })).yuzde).toBe(50);
  });

  it('ÖZELDE hepsi bitince %100 ve tamamlandi', () => {
    const y = basvuruAsamalari(g({
      kayitliId: 1, ucretGenel: 1100, tahsilToplam: 1100, kapanmaDurum: 2 }));
    expect(y.yuzde).toBe(100);
    expect(y.tamamlandi).toBe(true);
  });

  it('SGK/ÖSS bes asamali: provizyon alinmadan %100 OLMAZ', () => {
    const eksik = basvuruAsamalari(g({
      kurumTuru: KURUM_SGK, kayitliId: 1, ucretGenel: 1100,
      tahsilToplam: 1100, kapanmaDurum: 2, provizyonDurum: 0 }));
    expect(eksik.yuzde).toBe(80);
    expect(eksik.tamamlandi).toBe(false);

    const tam = basvuruAsamalari(g({
      kurumTuru: KURUM_SGK, kayitliId: 1, ucretGenel: 1100,
      tahsilToplam: 1100, kapanmaDurum: 2, provizyonDurum: 1 }));
    expect(tam.yuzde).toBe(100);
    expect(tam.tamamlandi).toBe(true);
  });

  it('ARADAKI asama atlanabilir - yuzde tamamlananlari sayar, sirayi degil', () => {
    // Provizyon alinmadan ucret + tahsilat yapilmis ÖSS basvurusu.
    const y = basvuruAsamalari(g({
      kurumTuru: KURUM_OSS, kayitliId: 1, ucretGenel: 500,
      tahsilToplam: 500, provizyonDurum: 0 }));
    expect(y.yuzde).toBe(60);          // 3 / 5
    expect(y.asamalar.find(a => a.kod === 'provizyon')!.tamam).toBe(false);
  });
});

describe('eksik asamanin sebebi (serit ipucu)', () => {
  it('acik borc TUTARIYLA yazilir - memur hangi sekmeye gidecegini bilsin', () => {
    const t = basvuruAsamalari(g({ ucretGenel: 1100, tahsilToplam: 850 }))
      .asamalar.find(a => a.kod === 'tahsilat')!;
    expect(t.ipucu).toContain('250.00');
  });

  it('REDDEDILEN provizyon "alinmadi" degil REDDEDILDI der', () => {
    const p = basvuruAsamalari(g({ kurumTuru: KURUM_OSS, provizyonDurum: 2 }))
      .asamalar.find(a => a.kod === 'provizyon')!;
    expect(p.ipucu).toContain('REDDEDİLDİ');
  });

  it('tamamlanan asamada ipucu BOS - gosterilecek eksik yok', () => {
    const b = basvuruAsamalari(g({ kayitliId: 5 })).asamalar[0];
    expect(b.ipucu).toBe('');
  });
});
