import { describe, it, expect } from 'vitest';
import { tarafSecimEngeli } from '../bilesenler/tarafSecimEngeli';

const kodlar = { '4997': 'Op.Dr. Kerem ATALAY', '4999': 'Prof.Dr. Halil GÜNEŞ' };

describe('tarafSecimEngeli', () => {
  it('bos gridde gecerli secim ENGELLENMEZ', () => {
    expect(tarafSecimEngeli([], 'tarafId', kodlar,
      { id: 4997, unvan: 'Op.Dr. Kerem ATALAY' })).toBeNull();
  });

  it('ZATEN EKLI kisi engellenir - pencere kapanmadigi icin en olasi hata', () => {
    const engel = tarafSecimEngeli([{ tarafId: '4997' }], 'tarafId', kodlar,
      { id: 4997, unvan: 'Op.Dr. Kerem ATALAY' });
    expect(engel).toBe('Op.Dr. Kerem ATALAY zaten ekli.');
  });

  it('sayi/metin farki mukerreri KACIRMAZ', () => {
    // Grid degeri metin, arama sonucu sayi gelir.
    expect(tarafSecimEngeli([{ tarafId: 4997 }], 'tarafId', kodlar,
      { id: 4997, unvan: 'X' })).toContain('zaten ekli');
  });

  it('KOD LISTESINDE OLMAYAN kisi engellenir', () => {
    // Jenerik arama tum personeli tarar; gride yazilan deger kod listesinden
    //   okunur - listede olmayan kisi gridde ADSIZ gorunur ve kayit sessizce
    //   ise yaramaz olurdu.
    expect(tarafSecimEngeli([], 'tarafId', kodlar, { id: 1234, unvan: 'Ali Veli' }))
      .toBe('Ali Veli bu listede seçilebilir değil.');
  });

  it('kod listesi YOKSA (serbest alan) liste kontrolu yapilmaz', () => {
    expect(tarafSecimEngeli([], 'tarafId', null, { id: 1234, unvan: 'Ali Veli' })).toBeNull();
  });

  it('BASKA satirdaki farkli kisi engel degildir', () => {
    expect(tarafSecimEngeli([{ tarafId: '4999' }], 'tarafId', kodlar,
      { id: 4997, unvan: 'Kerem' })).toBeNull();
  });
});
