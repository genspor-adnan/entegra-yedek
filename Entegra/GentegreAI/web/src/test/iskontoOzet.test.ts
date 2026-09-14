import { describe, it, expect } from 'vitest';
import type { IskontoTalebi } from '../api/sozlesme';
import {
  gerekceAnalizi, indirim, isteyenAnalizi, kuyrugaDiz, ozetCikar, sure, verilenIndirim,
} from '../sayfalar/iskonto/ortak';

/**
 * İSKONTO ONAY EKRANININ ÖZET HESAPLARI.
 *
 * Sayaçlar sunucudan gelmez, listeden hesaplanır; aynı rakam üç sekmede
 * birden okunur (kuyruk kutusu, tablo satırı, analiz). Ayrışırlarsa kullanıcı
 * hangisine inanacağını bilemez - kural saf modülde, testi burada.
 */

const talep = (y: Partial<IskontoTalebi> & { id: number }): IskontoTalebi => ({
  belgeId: 1, oran: 20, onaylananOran: 0, gerekce: '', durum: 0,
  isteyen: 'Banko 1', istekTs: '2026-09-15T08:00:00', onaylayan: '', onayTs: null,
  kararNotu: '', satirSayisi: 1, tutar: 1000, hasta: 'Hasta', belgeNo: 'P-1',
  cinsiyet: 0, yas: 0, kurum: '', doktor: '', kalemler: [], ...y,
});

describe('iskonto ozet hesaplari', () => {
  it('sure bicimi: dakika, saat, saat+dakika', () => {
    expect(sure(0)).toBe('< 1 dk');
    expect(sure(42)).toBe('42 dk');
    expect(sure(120)).toBe('2 sa');
    expect(sure(195)).toBe('3 sa 15 dk');
  });

  it('indirim KALEM BAZLI; kalem yoksa baslik oranina duser', () => {
    const kalemli = talep({ id: 1, tutar: 1300, kalemler: [
      { ad: 'Muayene', tutar: 1000, oran: 20 },
      { ad: 'EKG', tutar: 300, oran: 10 },
    ] });
    expect(indirim(kalemli)).toBeCloseTo(230, 2);      // 200 + 30
    // Eski kayit: kalem yok, %20 x 1000.
    expect(indirim(talep({ id: 2 }))).toBeCloseTo(200, 2);
  });

  it('KISMI ONAYDA oranlar orantili duser - verilen indirim de oyle', () => {
    const t = talep({ id: 3, durum: 1, oran: 20, onaylananOran: 10, tutar: 1000 });
    expect(verilenIndirim(t)).toBeCloseTo(100, 2);     // 200 x (10/20)
    // Bekleyen ve reddedilen talepte VERILEN indirim yoktur.
    expect(verilenIndirim(talep({ id: 4 }))).toBe(0);
    expect(verilenIndirim(talep({ id: 5, durum: 2 }))).toBe(0);
  });

  it('kuyruk EN UZUN BEKLEYEN ustte siralanir', () => {
    const liste = [
      talep({ id: 1, istekTs: '2026-09-15T10:00:00' }),
      talep({ id: 2, istekTs: '2026-09-15T08:00:00' }),
      talep({ id: 3, istekTs: '2026-09-15T09:00:00' }),
    ];
    expect(kuyrugaDiz(liste).map(t => t.id)).toEqual([2, 3, 1]);
  });

  it('ozet: onay/red/kismi sayilari ve verilen tutar', () => {
    const gecmis = [
      talep({ id: 1, durum: 1, oran: 20, onaylananOran: 20, tutar: 1000,
              onayTs: '2026-09-15T08:10:00' }),
      talep({ id: 2, durum: 1, oran: 20, onaylananOran: 10, tutar: 1000,
              onayTs: '2026-09-15T08:30:00' }),
      talep({ id: 3, durum: 2, onayTs: '2026-09-15T08:20:00' }),
    ];
    const o = ozetCikar(gecmis, []);
    expect(o.onayli).toBe(2);
    expect(o.red).toBe(1);
    expect(o.kismi).toBe(1);
    expect(o.verilen).toBeCloseTo(300, 2);   // 200 + 100
    expect(o.hizmet).toBeCloseTo(2000, 2);   // yalniz ONAYLI taleplerin tutari
    expect(o.ort).toBeCloseTo(20, 2);        // (10 + 30 + 20) / 3 dk
  });

  it('gerekce analizi: kategori BASLIKTAN, red orani ve ort. oran', () => {
    const gecmis = [
      talep({ id: 1, durum: 1, oran: 20, onaylananOran: 20, tutar: 1000,
              gerekce: 'Personel yakını — kızı' }),
      talep({ id: 2, durum: 2, oran: 30, gerekce: 'Personel yakını — eşi' }),
      talep({ id: 3, durum: 1, oran: 10, onaylananOran: 10, tutar: 500,
              gerekce: 'Yuvarlama' }),
    ];
    const [ilk, ikinci] = gerekceAnalizi(gecmis);
    // Tutara gore sirali: personel yakini 200, yuvarlama 50.
    expect(ilk.ad).toBe('Personel yakını');
    expect(ilk.adet).toBe(2);
    expect(ilk.red).toBe(1);
    expect(ilk.tutar).toBeCloseTo(200, 2);
    expect(ilk.ortOran).toBeCloseTo(25, 2);          // (20 + 30) / 2
    expect(ikinci.ad).toBe('Yuvarlama');
  });

  it('isteyen analizi BEKLEYENLERI DE sayar - kuyruktaki talep de onun', () => {
    const gecmis = [
      talep({ id: 1, durum: 1, oran: 20, onaylananOran: 10, tutar: 1000, isteyen: 'Elif' }),
      talep({ id: 2, durum: 2, isteyen: 'Elif' }),
    ];
    const bekleyen = [talep({ id: 3, isteyen: 'Elif' })];
    const [e] = isteyenAnalizi(gecmis, bekleyen);
    expect(e.ad).toBe('Elif');
    expect(e.talep).toBe(3);
    expect(e.kismi).toBe(1);
    expect(e.onay).toBe(0);
    expect(e.red).toBe(1);
    expect(e.tutar).toBeCloseTo(100, 2);
  });
});
