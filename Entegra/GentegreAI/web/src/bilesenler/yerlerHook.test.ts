import { afterEach, describe, expect, it } from 'vitest';
import type { YerlerYaniti } from '../api/sozlesme';
import { subeAyariniKur } from './subeAyari';
import { skrsUlkeleri, subeUlkesi } from './yerlerHook';

// 1350 (kullanici 16.11.2026): hasta kartinda ulke ve uyruk ayni SKRS listesi; varsayilan subenin ulkesi.
const yerler: YerlerYaniti = {
  iller: [], ilceler: [],
  ulkeler: [
    { id: 312, ad: 'TC', skrsKod: null, iso: null },
    { id: 101, ad: 'ALMANYA', skrsKod: 9892, iso: null },
    { id: 433, ad: 'ALMANYA FEDERAL CUMHURİYETİ', skrsKod: 9893, iso: 'DE' },
    { id: 510, ad: 'TÜRKİYE CUMHURİYETİ', skrsKod: 9980, iso: 'TR' },
  ],
};

const sube = (ulkeKod: string) => ({
  id: 1, ad: 'Ş', varsayilan: true, yazma: true, ulkeKod,
  telefonKodu: '+90', zamanDilimi: 'Europe/Istanbul', paraBirimi: 'TRY',
});

afterEach(() => subeAyariniKur(null));

describe('hasta kartı ülke / uyruk listesi', () => {
  it('yalnız SKRS kodlu ülkeler listelenir', () => {
    expect(skrsUlkeleri(yerler).map(u => u.id)).toEqual([101, 433, 510]);
  });

  it('varsayılan aktif şubenin ülkesidir', () => {
    subeAyariniKur(sube('DE'));
    expect(subeUlkesi(yerler)?.skrsKod).toBe(9893);
  });

  it('şube ülkesi listede yoksa Türkiye', () => {
    subeAyariniKur(sube('JP'));
    expect(subeUlkesi(yerler)?.skrsKod).toBe(9980);
  });

  it('liste gelmeden null', () => {
    expect(subeUlkesi(null)).toBeNull();
  });
});
