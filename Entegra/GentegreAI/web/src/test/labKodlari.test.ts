import { describe, expect, it } from 'vitest';
import {
  TUP, bayrakSinifi, referansMetni, sayi, sirSinifi, tup,
} from '../bilesenler/labKodlari';

/**
 * LAB KOD SÖZLÜKLERİ (446) — ekranlar arası tutarlılık.
 *
 * Bu sözlük üç ekranda birden kullanılıyor (etiket, numune kabul paneli,
 * sonuç raporu). Sapma "mor tüp bir ekranda mor, diğerinde gri" olarak
 * sahaya çıkar; testler o sapmayı burada tutuyor.
 */
describe('labKodlari', () => {
  it('bilinmeyen tüp kodu DİĞER tüpüne düşer, patlamaz', () => {
    // Sunucu ileride yeni bir tüp tipi eklerse ekran boş kutu değil
    //   "Diğer" göstermeli - numune kabulde renk hücresi hiç boş kalmamalı.
    expect(tup(2)).toBe(TUP[2]);
    expect(tup(99)).toBe(TUP[9]);
    expect(tup(null)).toBe(TUP[9]);
    expect(tup(undefined).kisa).toBe('Diğer');
  });

  it('panik bayrağı KIRMIZI, tek yön SARI rozet alır', () => {
    // Mockup .rz kir / .rz sari karşılığı: LL/HH panik, L/H uyarı.
    expect(bayrakSinifi('HH')).toBe('rozet hata');
    expect(bayrakSinifi('ll')).toBe('rozet hata');
    expect(bayrakSinifi('H')).toBe('rozet uyari');
    expect(bayrakSinifi('N')).toBe('rozet gri');
    expect(bayrakSinifi('')).toBe('rozet gri');
  });

  it('antibiyogram S/I/R renkleri karışmaz', () => {
    // R'yi yeşil göstermek hastaya yanlış antibiyotik demektir.
    expect(sirSinifi('S')).toBe('rozet olumlu');
    expect(sirSinifi('r')).toBe('rozet hata');
    expect(sirSinifi('I')).toBe('rozet uyari');
    expect(sirSinifi(null)).toBe('rozet gri');
  });

  it('referans metni varsa aralık YERİNE o basılır', () => {
    // "negatif" ya da "< 14" gibi metinsel referans sayısal aralığa
    //   çevrilemez; sunucu ne yazdıysa o gösterilir.
    expect(referansMetni(1, 2, '< 14')).toBe('< 14');
    expect(referansMetni(0.7, 1.2, '')).toBe('0,7 – 1,2');
  });

  it('tek taraflı referans ≤ / ≥ ile yazılır, boş sınır uydurulmaz', () => {
    // "0 – 35" yazmak yanlış bilgidir: alt sınır tanımlı değil.
    expect(referansMetni(null, 35, '')).toBe('≤ 35');
    expect(referansMetni(60, null, '')).toBe('≥ 60');
    expect(referansMetni(null, null, '')).toBe('');
  });

  it('boş değer tabloda tire olur, sayı Türkçe biçimlenir', () => {
    expect(sayi(null)).toBe('—');
    expect(sayi('')).toBe('—');
    expect(sayi(1234.5678, 2)).toBe('1.234,57');
    // Sayıya çevrilemeyen metin (ör. ">90") olduğu gibi kalır.
    expect(sayi('>90')).toBe('>90');
  });
});
