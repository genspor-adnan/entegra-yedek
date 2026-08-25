import { describe, it, expect, vi } from 'vitest';
import { gridMenuOgeleri, type GridMenuGirdisi } from '../bilesenler/grid/GridMenu';
import type { KolonMeta } from '../api/sozlesme';

/**
 * Gridin uc nokta menusu. Menu ogeleri SAF uretilir; test hangi ogenin
 * gorundugunu, hangisinin PASIF oldugunu ve tiklaninca ne cagirdigini sabitler.
 */
const kolon = (ad: string, ek: Partial<KolonMeta> = {}) =>
  ({ ad, baslik: ad.toUpperCase(), ...ek }) as KolonMeta;

function menu(ek: Partial<GridMenuGirdisi> = {}) {
  const cagri = {
    kolonTasi: vi.fn(), gruplaSec: vi.fn(), satirBoyuSec: vi.fn(),
    kolonDegistir: vi.fn(), kolonlariSifirla: vi.fn(), sayfaBoyuSec: vi.fn(),
  };
  const ogeler = gridMenuOgeleri({
    kolonlar: [kolon('a'), kolon('b')],
    tumKolonlar: [kolon('a'), kolon('b'), kolon('c')],
    satirSayisi: 3, seciliSayisi: 0, sirala: [], filtreAcik: false, filtreVar: false,
    sayfaBoyu: 50, boyutSabit: false, kullaniciGrup: null, satirBoyu: 'normal',
    yukle: vi.fn(), csvIndir: vi.fn(), setFiltreAcik: vi.fn(),
    filtreleriTemizle: vi.fn(), siralamayiTemizle: vi.fn(), tumunuSec: vi.fn(),
    secimiTemizle: vi.fn(), secimiTersineCevir: vi.fn(),
    ...cagri, ...ek,
  });
  const bul = (ad: string) => ogeler.find(o => o.ad === ad);
  return { ogeler, bul, ...cagri };
}

describe('pasiflik sebepleri', () => {
  it('kayit yokken CSV ve secim ogeleri pasif', () => {
    const { bul } = menu({ satirSayisi: 0 });
    expect(bul('CSV Kaydet')?.devre).toBeDefined();
    expect(bul('Tumunu Sec (bu sayfa)')?.devre).toBeDefined();
  });

  it('kayit varken CSV aktif', () => {
    expect(menu().bul('CSV Kaydet')?.devre).toBeUndefined();
  });

  it('siralama/filtre yokken temizleme pasif', () => {
    const { bul } = menu();
    expect(bul('Sıralamayı Temizle')?.devre).toBeDefined();
    expect(bul('Filtreleri Temizle')?.devre).toBeDefined();
  });

  it('siralama varken temizleme aktif', () => {
    expect(menu({ sirala: [{ alan: 'a', yon: 'asc' }] }).bul('Sıralamayı Temizle')?.devre)
      .toBeUndefined();
  });

  it('secim yokken "Secimi Temizle" pasif', () => {
    expect(menu().bul('Secimi Temizle')?.devre).toBeDefined();
    expect(menu({ seciliSayisi: 2 }).bul('Secimi Temizle')?.devre).toBeUndefined();
  });

  it('sayfa boyu disaridan sabitse degistirilemez', () => {
    expect(menu({ boyutSabit: true }).bul('Sayfada 25 kayıt')?.devre).toBeDefined();
  });
});

describe('gruplama', () => {
  it('siralanabilir her kolon icin oge uretir', () => {
    const { ogeler } = menu();
    expect(ogeler.filter(o => o.ad.startsWith('Grupla:'))).toHaveLength(2);
  });

  it('siralanamayan kolon gruplanamaz', () => {
    const { ogeler } = menu({ kolonlar: [kolon('a'), kolon('b', { siralanabilir: false })] });
    expect(ogeler.filter(o => o.ad.startsWith('Grupla:'))).toHaveLength(1);
  });

  it('secili gruplama isaretlenir', () => {
    expect(menu({ kullaniciGrup: 'a' }).bul('Grupla: A')?.secili).toBe(true);
    expect(menu({ kullaniciGrup: 'a' }).bul('Gruplama Yok')?.secili).toBe(false);
  });

  it('"Gruplama Yok" null gonderir, kolon secimi kolon adini', () => {
    const m1 = menu(); m1.bul('Gruplama Yok')!.fn();
    expect(m1.gruplaSec).toHaveBeenCalledWith(null);
    const m2 = menu(); m2.bul('Grupla: B')!.fn();
    expect(m2.gruplaSec).toHaveBeenCalledWith('b');
  });
});

describe('kolon sirasi (↑ ↓)', () => {
  it('ilk kolonun yukari oku, son kolonun asagi oku pasif', () => {
    const { bul } = menu();
    expect(bul('A')?.yan?.[0].devre).toBe(true);      // sola alinamaz
    expect(bul('A')?.yan?.[1].devre).toBe(false);
    expect(bul('B')?.yan?.[1].devre).toBe(true);      // saga alinamaz
  });

  it('gorunmeyen kolonda ok yoktur', () => {
    const { bul } = menu();
    expect(bul('C')?.yan).toBeUndefined();
    expect(bul('C')?.secili).toBe(false);
  });

  it('ok tiklaninca kolonTasi yonuyle cagrilir', () => {
    const m = menu(); m.bul('B')!.yan![0].fn();
    expect(m.kolonTasi).toHaveBeenCalledWith('b', -1);
  });

  it('kolon satirina tiklamak gorunurlugu degistirir', () => {
    const m = menu(); m.bul('C')!.fn();
    expect(m.kolonDegistir).toHaveBeenCalledWith(expect.objectContaining({ ad: 'c' }));
  });
});

describe('satir yuksekligi', () => {
  it('uc secenek sunar ve secili olani isaretler', () => {
    const { ogeler, bul } = menu({ satirBoyu: 'sik' });
    expect(ogeler.filter(o => o.ad.startsWith('Satır:'))).toHaveLength(3);
    expect(bul('Satır: Sık')?.secili).toBe(true);
    expect(bul('Satır: Normal')?.secili).toBe(false);
  });

  it('secim satirBoyuSec"e gider', () => {
    const m = menu(); m.bul('Satır: Geniş')!.fn();
    expect(m.satirBoyuSec).toHaveBeenCalledWith('genis');
  });
});

describe('menu duzeni', () => {
  it('gorunum ve arama gorunumu menude YOKTUR (arac cubugunda)', () => {
    const adlar = menu().ogeler.map(o => o.ad);
    expect(adlar).not.toContain('Liste');
    expect(adlar).not.toContain('Analiz');
    expect(adlar.some(a => a.includes('Son Aranan'))).toBe(false);
  });

  it('bolumler ayracla ayrilir', () => {
    expect(menu().ogeler.filter(o => o.ayrac).length).toBeGreaterThan(3);
  });
});
