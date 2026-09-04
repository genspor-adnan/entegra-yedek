import { describe, it, expect } from 'vitest';
import { tarafSecimEngeli } from '../bilesenler/tarafSecimEngeli';

describe('tarafSecimEngeli', () => {
  it('bos gridde gecerli secim ENGELLENMEZ', () => {
    expect(tarafSecimEngeli([], 'tarafId',
      { id: 4997, unvan: 'Op.Dr. Kerem ATALAY' })).toBeNull();
  });

  it('ZATEN EKLI kisi engellenir - pencere kapanmadigi icin en olasi hata', () => {
    const engel = tarafSecimEngeli([{ tarafId: '4997' }], 'tarafId',
      { id: 4997, unvan: 'Op.Dr. Kerem ATALAY' });
    expect(engel).toBe('Op.Dr. Kerem ATALAY zaten ekli.');
  });

  it('sayi/metin farki mukerreri KACIRMAZ', () => {
    // Grid degeri metin, arama sonucu sayi gelir.
    expect(tarafSecimEngeli([{ tarafId: 4997 }], 'tarafId',
      { id: 4997, unvan: 'X' })).toContain('zaten ekli');
  });

  it('KOD LISTESI ARTIK ENGEL DEGIL (377)', () => {
    // Once "listede olmayan kisi eklenemez" kurali vardi ve jenerik aramadan
    //   secilen personelin cogu sessizce dusuyordu. Rol eksikligi artik
    //   gridin "Prim Rolü" kolonunda gorunur, secim engellenmez.
    expect(tarafSecimEngeli([], 'tarafId', { id: 1234, unvan: 'Ali Veli' })).toBeNull();
  });

  it('BASKA satirdaki farkli kisi engel degildir', () => {
    expect(tarafSecimEngeli([{ tarafId: '4999' }], 'tarafId',
      { id: 4997, unvan: 'Kerem' })).toBeNull();
  });
});
