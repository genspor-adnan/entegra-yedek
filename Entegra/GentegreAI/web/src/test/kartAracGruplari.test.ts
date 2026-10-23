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
    // Cari kartında ekstre SEKMESİ yok, üstte Ekstre düğmesi (Kasa › Cari Ekstre) - yeni kartta yok.
    expect(isValidElement(kartAracGrubu(b('cari')))).toBe(true);
    expect(kartAracGrubu(b('cari', { yeniMi: true, id: 'yeni' }))).toBeNull();
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

describe('karta özel sekme gövdeleri ve başlık parçaları (refaktör 23.10.2026)', () => {
  it('özel detay / yer tutucu / ozel: sekme yalnız kendi kaynağında', async () => {
    const { ozelDetayGovdesi, ozelYerTutucuGovdesi, ozelSekmeGovdesi } = await import('../bilesenler/kart/kartOzelSekmeleri');
    for (const [k, d] of [['dis-hekim', 'hekim'], ['stok', 'uts'], ['stok', 'paket'], ['hizmet', 'fiyatlar']])
      expect(ozelDetayGovdesi(k, d), `${k}.${d}`).toBeTypeOf('function');
    expect(ozelDetayGovdesi('cari', 'uts')).toBeUndefined();
    expect(ozelDetayGovdesi('stok', 'barkodlar')).toBeUndefined();
    for (const [k, s] of [['radyoloji-istem', 'Kontrol Listesi'], ['dis-hekim', 'Gönderim Geçmişi'], ['banko', 'Oturumlar']])
      expect(ozelYerTutucuGovdesi(k, s), `${k}.${s}`).toBeTypeOf('function');
    expect(ozelYerTutucuGovdesi('banko', 'Kontrol Listesi')).toBeUndefined();
    expect(ozelSekmeGovdesi('rol', 'ozel:yetkiler')).toBeTypeOf('function');
    expect(ozelSekmeGovdesi('personel', 'ozel:yetkiler')).toBeUndefined();
  }, 30_000);   // dinamik içe aktarma: tam koşuda yük altında 5 sn yetmiyor

  it('başlık rozeti ve üst şerit yeni kartta yok', async () => {
    const { kartBaslikRozeti, kartUstSeridi } = await import('../bilesenler/kart/kartBasligi');
    const bb = { id: 'yeni' as const, yeniMi: true, deger: {}, meta: null, detaylar: {} };
    for (const k of ['hasta', 'personel', 'dokuman']) expect(kartBaslikRozeti({ ...bb, kaynak: k }), k).toBeNull();
    expect(isValidElement(kartBaslikRozeti({ ...bb, kaynak: 'hasta', id: 3, yeniMi: false }))).toBe(true);
    expect(kartBaslikRozeti({ ...bb, kaynak: 'dis-hekim', id: 3, yeniMi: false })).toBeNull();
    expect(kartUstSeridi('yatan', 'yeni')).toBeNull();
    expect(isValidElement(kartUstSeridi('radyoloji-istem', 7))).toBe(true);
    expect(kartUstSeridi('cari', 7)).toBeNull();
  }, 30_000);
});
