import { describe, expect, it } from 'vitest';
import { ekstreYuvasiSec } from '../sayfalar/kabuk/EkranSekmeleri';
import { baslikAnahtari, ekstreKimligi } from '../bilesenler/sekmeBaglami';

/** Hesapla açılan ekstre hesabın sekmesi; en fazla 3; açık hesap yeniden açılmaz (26.10.2026). */
const T = '/ekstre';
const sekme = (anahtar: string, search: string, erisim: number) => ({ anahtar, konum: { pathname: T, search }, erisim });

describe('ekstreKimligi', () => {
  it('cari / hesap / hesapsız', () => {
    expect(ekstreKimligi({ pathname: T, search: '?tur=cari&id=7' })).toBe('c:7');
    expect(ekstreKimligi({ pathname: T, search: '?id=7' })).toBe('c:7');
    // 'hesap' sunucuda kasa'ya çözülür - kimlik aynı
    expect(ekstreKimligi({ pathname: T, search: '?tur=hesap&id=3' })).toBe(ekstreKimligi({ pathname: T, search: '?tur=kasa&id=3&bas=2026-01-01' }));
    expect(ekstreKimligi({ pathname: T, search: '?tur=cari' })).toBe('');
    expect(ekstreKimligi({ pathname: '/musteri/7', search: '?id=7' })).toBe('');
    expect(baslikAnahtari({ pathname: T, search: '?tur=cari&id=7' })).toBe('/ekstre?c:7');
    expect(baslikAnahtari({ pathname: '/musteri/7', search: '' })).toBe('/musteri/7');
  });
});

describe('ekstreYuvasiSec', () => {
  it('açık hesap aynı sekmede (dönem farklı olsa da)', () => {
    const s = [sekme(`${T}#ek#0`, '?tur=cari&id=1', 1), sekme(`${T}#ek#1`, '?tur=cari&id=2', 2)];
    expect(ekstreYuvasiSec(T, 'c:2', s, '/musteri')).toBe(`${T}#ek#1`);
    expect(ekstreYuvasiSec(T, 'c:1', [sekme(T, '?tur=cari&id=1&bas=2025-01-01', 1)], '/musteri')).toBe(T);
  });
  it('genel sekmede hesap seçimi sekme değiştirmez', () => {
    expect(ekstreYuvasiSec(T, 'c:5', [sekme(T, '?tur=cari', 1)], T)).toBe(T);
  });
  it('boş yuva, sonra en eskisi', () => {
    expect(ekstreYuvasiSec(T, 'c:9', [], '/musteri')).toBe(`${T}#ek#0`);
    const uc = [sekme(`${T}#ek#0`, '?id=1', 5), sekme(`${T}#ek#1`, '?id=2', 2), sekme(`${T}#ek#2`, '?id=3', 9)];
    expect(ekstreYuvasiSec(T, 'c:4', uc, '/musteri')).toBe(`${T}#ek#1`);
  });
});
