import { describe, expect, it } from 'vitest';
import { csvMetni } from '../bilesenler/csv';

/**
 * CSV iki ekranda ayri ayri uretiliyordu ve kacirma kurallari farkliydi
 * (biri her alani tirnakliyor, oteki yalniz gerekeni). Excel-TR kurallari
 * (";" ayrac + UTF-8 BOM) burada sabitlendi.
 */
describe('csvMetni', () => {
  it('BOM ile baslar ve ";" ile ayirir', () => {
    const m = csvMetni(['Ad', 'Tutar'], [['Kalem', 12.5]]);
    expect(m.charCodeAt(0)).toBe(0xfeff);
    expect(m).toBe('﻿Ad;Tutar\r\nKalem;12.5');
  });

  it('yalniz gerekeni tirnaklar - sayilar Excelde sayi kalsin', () => {
    const m = csvMetni(['a'], [['1234,56'], ['metin; icinde ayrac'], ['tirnak "var"']]);
    const satirlar = m.split('\r\n');
    expect(satirlar[1]).toBe('1234,56');                    // tirnaksiz
    expect(satirlar[2]).toBe('"metin; icinde ayrac"');
    expect(satirlar[3]).toBe('"tirnak ""var"""');           // ictekiler ikilenir
  });

  it('null/undefined bos hucre olur', () => {
    expect(csvMetni(['a', 'b'], [[null, undefined]])).toBe('﻿a;b\r\n;');
  });

  it('satir sonu tasiyan alan tirnaklanir - satir kaymaz', () => {
    expect(csvMetni(['a'], [['iki\nsatir']])).toBe('﻿a\r\n"iki\nsatir"');
  });

  /** K90: formül enjeksiyonu - Excel'de formül olabilecek öncü karakterler kesme ile nötrlenir, sayılar değil. */
  it('formul oncusu kesme alir, negatif sayi dokunulmaz', () => {
    const satirlar = csvMetni(['a'], [['=HYPERLINK("x")'], ['@SUM(1)'], ['+cmd'], ['-5'], ['-1.250,00'], ['normal']]).split('\r\n');
    expect(satirlar[1]).toBe(`"'=HYPERLINK(""x"")"`);
    expect(satirlar[2]).toBe(`"'@SUM(1)"`);
    expect(satirlar[3]).toBe(`"'+cmd"`);
    expect(satirlar[4]).toBe('-5');
    expect(satirlar[5]).toBe('-1.250,00');
    expect(satirlar[6]).toBe('normal');
  });
});
