import { describe, expect, it } from 'vitest';
import { siraliCariler } from '../sayfalar/cariIcmal/CariIcmalTablolari';
import type { CariIcmalSatiri } from '../api/uclar/cariIcmal';

// CARİ İCMALİ SIRALAMA (03.11.2026): metin Türkçe sırayla, tutar işaretli, boş tarih / risk sonda.
const s = (id: number, ad: string, bakiye: number, son: string | null, risk: number | null) =>
  ({ id, ad, kod: String(id), temsilci: '', bakiye, sonHareket: son, riskYuzde: risk, vadesiGecen: 0, enEskiGun: 0 }) as unknown as CariIcmalSatiri;
const l = [s(1, 'Çelik', 10, '2026-10-01', null), s(2, 'Ahmet', -50, null, 80), s(3, 'Zeki', 200, '2026-11-01', 20)];

describe('cari icmali sıralama', () => {
  it('sırasız = sunucu sırası', () => expect(siraliCariler(l, null).map(c => c.id)).toEqual([1, 2, 3]));
  it('ünvan Türkçe', () => expect(siraliCariler(l, { alan: 'ad', artan: true }).map(c => c.ad)).toEqual(['Ahmet', 'Çelik', 'Zeki']));
  it('bakiye büyükten', () => expect(siraliCariler(l, { alan: 'bakiye', artan: false }).map(c => c.id)).toEqual([3, 1, 2]));
  it('son hareket boş sonda', () => expect(siraliCariler(l, { alan: 'sonHareket', artan: false }).map(c => c.id)).toEqual([3, 1, 2]));
  it('risk boş sonda', () => expect(siraliCariler(l, { alan: 'riskYuzde', artan: false }).map(c => c.id)).toEqual([2, 3, 1]));
});
