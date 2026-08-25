import { describe, it, expect } from 'vitest';
import { kasaGovdesi, kasaDogrula, kasaTurBilgisi, type KasaGirdisi } from '../sayfalar/kasaKaydet';

/**
 * Kasa islemi govdesi ve dogrulamasi.
 *
 * Bu kurallar sunucuda da var; buradaki testler EKRANIN sunucuya ne
 * gonderdigini sabitler - bicim cevrimi (Turkce sayi), tur bayraklari ve
 * cek/senet ozel durumlari sessizce kaymasin.
 */
const temel: KasaGirdisi = {
  tur: 22, grup: 'tahsilat', tarih: '2026-08-25T14:30', planTarihi: '',
  cari: { id: 7, unvan: 'ACME' }, karsiCari: null,
  hesap: { id: 3, ad: 'USD Banka', doviz: 'USD' }, karsiHesap: null,
  tutar: '1.234,56', doviz: 'USD', ekstreDovizi: 'USD', kur: '41,2',
  karsiTutar: '', masrafTutar: '0', kalem: null, proje: null, aciklama: 'test',
  csVade: '', csSeriNo: '', csKesideci: '', csBanka: '', csSube: '',
  mevcutKiymet: 0, belgeBagi: 99, cariZorunlu: 1,
};
/** Cek/senet ile odeme (34 = senet ver) - kiymet alanlari dolu. */
const senet: KasaGirdisi = {
  ...temel, tur: 24, grup: 'ceksenet', hesap: null,
  csVade: '2026-09-30', csSeriNo: 'A123', csBanka: 'X Bank', csSube: 'Kadıköy',
};

describe('kasaGovdesi', () => {
  it('Turkce sayi bicimini cozer', () => {
    const g = kasaGovdesi(temel, false, false);
    expect(g.islem.tutar).toBe(1234.56);
    expect(g.islem.dovizKuru).toBe(41.2);
  });

  it('ekstre dovizini yalniz DOVIZLI islemde gonderir', () => {
    // Yerel islemde ekstre dovizi anlamsiz: sunucu islem dovizini kullanir (139).
    expect(kasaGovdesi(temel, false, false).islem.ekstreDovizi).toBe('USD');
    expect(kasaGovdesi({ ...temel, doviz: 'TL' }, false, false).islem.ekstreDovizi).toBe('');
  });

  it('belge bagini seceneklere koyar', () => {
    expect(kasaGovdesi(temel, false, false).secenekler.belgeId).toBe(99);
    expect(kasaGovdesi({ ...temel, belgeBagi: undefined }, false, false).secenekler)
      .not.toHaveProperty('belgeId');
  });

  it('cek/senet olmayan turde kiymet govdesi uretmez', () => {
    expect(kasaGovdesi(temel, false, false)).not.toHaveProperty('cekSenet');
  });

  it('senette banka alanlarini bos gonderir, keside ismini cariden alir', () => {
    const g = kasaGovdesi(senet, false, false) as { cekSenet: Record<string, string> };
    expect(g.cekSenet.bankaAdi).toBe('');
    expect(g.cekSenet.bankaSubesi).toBe('');
    expect(g.cekSenet.kesideci).toBe('ACME');
  });

  it('cekte banka alanlari korunur', () => {
    const g = kasaGovdesi({ ...senet, tur: 23 }, false, false) as { cekSenet: Record<string, string> };
    expect(g.cekSenet.bankaAdi).toBe('X Bank');
  });

  it('MEVCUT kiymete baglanirken ikinci kayit acmaz', () => {
    // Yoksa ayni cek iki kez portfoye girerdi.
    const g = kasaGovdesi({ ...senet, mevcutKiymet: 55 }, false, false);
    expect(g).not.toHaveProperty('cekSenet');
    expect(g.islem.cekSenetId).toBe(55);
  });

  it('plan tarihini yalniz PLAN kaydinda gonderir', () => {
    const planli = { ...temel, planTarihi: '2026-12-01' };
    expect(kasaGovdesi(planli, false, true).islem.planTarihi).toBe('2026-12-01');
    expect(kasaGovdesi(planli, false, false).islem.planTarihi).toBeNull();
  });
});

describe('kasaDogrula', () => {
  it('gecerli girdide hata uretmez', () => {
    expect(kasaDogrula(temel, false)).toEqual({});
  });

  it('nakit/banka isleminde hesap zorunlu', () => {
    expect(kasaDogrula({ ...temel, hesap: null }, false).hesapId).toBeDefined();
  });

  it('cek/senette hesap ZORUNLU DEGIL - kiymet portfoye girer', () => {
    expect(kasaDogrula(senet, false).hesapId).toBeUndefined();
  });

  it('yeni kiymette vade zorunlu, mevcut kiymette degil', () => {
    expect(kasaDogrula({ ...senet, csVade: '' }, false)['cekSenet.vade']).toBeDefined();
    expect(kasaDogrula({ ...senet, csVade: '', mevcutKiymet: 5 }, false)['cekSenet.vade'])
      .toBeUndefined();
  });

  it('katalog cari zorunlu diyorsa cari ister', () => {
    expect(kasaDogrula({ ...temel, cari: null }, false).tarafId).toBeDefined();
    expect(kasaDogrula({ ...temel, cari: null, cariZorunlu: 0 }, false).tarafId).toBeUndefined();
  });

  it('sifir ve eksi tutari reddeder', () => {
    expect(kasaDogrula({ ...temel, tutar: '0' }, false).tutar).toBeDefined();
    expect(kasaDogrula({ ...temel, tutar: '-5' }, false).tutar).toBeDefined();
  });

  it('cari virmanda karsi cari, virman/dovizde karsi hesap ister', () => {
    expect(kasaDogrula({ ...temel, tur: 49, grup: 'virman', karsiCari: null }, false)
      .karsiTarafId).toBeDefined();
    expect(kasaDogrula({ ...temel, grup: 'virman', karsiHesap: null }, false)
      .karsiHesapId).toBeDefined();
  });

  it('planda vade zorunlu', () => {
    expect(kasaDogrula({ ...temel, grup: 'plan', hesap: null }, true).planTarihi).toBeDefined();
  });
});

describe('kasaTurBilgisi', () => {
  it('tur bayraklarini dogru cikarir', () => {
    expect(kasaTurBilgisi(49, 'virman').cariVirman).toBe(true);
    expect(kasaTurBilgisi(24, 'ceksenet')).toMatchObject({ cekSenetMi: true, senetMi: true });
    expect(kasaTurBilgisi(23, 'ceksenet')).toMatchObject({ cekSenetMi: true, senetMi: false });
    expect(kasaTurBilgisi(45, 'doviz')).toMatchObject({ donusum: true, karsiHesapli: true });
    expect(kasaTurBilgisi(61, 'plan').planMi).toBe(true);
  });
});
