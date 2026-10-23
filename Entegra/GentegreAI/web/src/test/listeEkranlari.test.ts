import { describe, expect, it } from 'vitest';
import { listePaneli } from '../sayfalar/liste/listeEkranlari';

/** LİSTE PANELLERİ (refaktör 22.10.2026): Liste.tsx zincirlerinden ayrılan durumsuz şerit / panel tablosu. */
describe('listePaneli', () => {
  it('panelsiz kaynak: yok', () => {
    expect(listePaneli('kisi')).toBeUndefined();
  });

  it('müşteri listesi (1150): gösterge + önizleme; aynı kaynağın Tedarikçi Listesi (rota) çizmez', () => {
    const p = listePaneli('cari')!;
    const b = { rota: undefined, yenile: 0, seciliSatir: null, setCip: () => {}, tazele: () => {},
                git: () => {}, gitKart: () => {} } as unknown as Parameters<NonNullable<typeof p.ustPanel>>[0];
    expect(p.ustPanel!(b)).toBeTruthy();
    expect(p.yanPanel!(b)).toBeTruthy();
    expect(p.ustPanel!({ ...b, rota: 'tedarikci' })).toBeUndefined();
    expect(p.yanPanel!({ ...b, rota: 'tedarikci' })).toBeUndefined();
  });

  it('kullanıcılar: üstte sayaç şeridi, altta seçili hesabın paneli', () => {
    const p = listePaneli('kullanici')!;
    expect(p.ustSerit).toBeTypeOf('function');
    expect(p.altPanel).toBeTypeOf('function');
    expect(p.yanPanel).toBeUndefined();
  });

  it('lab istem kümesi: yan + alt panel; sonuç onayında üstte özet şeridi de (iki kaynak birleşir)', () => {
    const istem = listePaneli('lab-istem')!;
    expect(istem.yanPanel).toBeTypeOf('function');
    expect(istem.altPanel).toBeTypeOf('function');
    const sonuc = listePaneli('lab-sonuc')!;
    expect(sonuc.ustPanel).toBeTypeOf('function');
    expect(sonuc.yanPanel).toBeTypeOf('function');
    expect(sonuc.altPanel).toBeTypeOf('function');
    // Kültür: yalnız alt panel (yan panel yalnız istem kümesinde).
    const kultur = listePaneli('lab-kultur')!;
    expect(kultur.yanPanel).toBeUndefined();
    expect(kultur.altPanel).toBeTypeOf('function');
  });

  it('alt paneller seçili KAYIT ister (id yoksa çizilmez)', () => {
    const b = { seciliSatir: null } as Parameters<NonNullable<ReturnType<typeof listePaneli>>['altPanel'] & object>[0];
    expect(listePaneli('enabiz-paket')!.altPanel!(b)).toBeUndefined();
    expect(listePaneli('kullanici')!.altPanel!({ ...b, seciliSatir: { id: 0 } })).toBeUndefined();
  });
});
