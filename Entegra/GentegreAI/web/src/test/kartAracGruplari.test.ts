import { describe, expect, it } from 'vitest';
import { isValidElement } from 'react';
import { kartAracGrubu, kartSagAraclari, type KartAracBaglami } from '../bilesenler/kart/KartAracGruplari';

/** KART ARAÇ GRUPLARI (refaktör 22.10.2026): GenForm alt araç çubuğundan ayrılan kaynak grupları. */
const b = (kaynak: string, ek: Partial<KartAracBaglami> = {}): KartAracBaglami => ({
  kaynak, id: 5, yeniMi: false, salt: false, meta: { alanlar: [] } as unknown as KartAracBaglami['meta'],
  deger: {}, setDeger: () => {}, alanDegistir: () => {}, detaylar: {}, setDetaylar: () => {}, setHata: () => {},
  kaydedilmemisDegisiklikVar: false, kaydet: async () => undefined, basvuruAc: () => {}, cariyeBagla: () => {},
  ...ek,
});

describe('kartAracGrubu', () => {
  it('grubu olmayan kaynak: yok', () => {
    expect(kartAracGrubu(b('stok'))).toBeNull();
    expect(kartSagAraclari(b('hasta'))).toBeNull();
  });

  it('kaynağa özel gruplar çizilir', () => {
    for (const k of ['hasta', 'cek-senet', 'hasta-aday', 'randevu', 'dokuman', 'entegrasyon-hesap', 'kisi'])
      expect(isValidElement(kartAracGrubu(b(k))), k).toBe(true);
    expect(isValidElement(kartSagAraclari(b('cari')))).toBe(true);
  });

  it('eski koşullar korunur: yeni kartta doküman / entegrasyon yok, salt randevuda akış yok, bağlı kişide Cariye Bağla yok', () => {
    expect(kartAracGrubu(b('dokuman', { yeniMi: true, id: 'yeni' }))).toBeNull();
    expect(kartAracGrubu(b('entegrasyon-hesap', { yeniMi: true, id: 'yeni' }))).toBeNull();
    expect(kartAracGrubu(b('randevu', { salt: true }))).toBeNull();
    expect(kartAracGrubu(b('kisi', { deger: { bagId: 3 } }))).toBeNull();
    expect(kartAracGrubu(b('kisi', { cariyeBaglaGizli: true }))).toBeNull();
    expect(kartAracGrubu(b('kisi', { salt: true }))).toBeNull();
  });
});
