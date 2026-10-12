import { describe, expect, it } from 'vitest';
import { devamRozeti, dolulukRozeti, durumRozeti, ondalik, vasFark, yanitRozeti, yuzde } from '../sayfalar/ftrIcmal/ftrIcmalOrtak';

describe('FTR icmali', () => {
  it('devam ve doluluk rozetleri', () => {
    expect(devamRozeti(null)).toEqual({ ad: '—', renk: 'pas' });
    expect(devamRozeti(95.2).renk).toBe('ok');
    expect(devamRozeti(85.7)).toEqual({ ad: '%85,7', renk: 'sari' });
    expect(devamRozeti(70).renk).toBe('kir');
    expect(dolulukRozeti(90).renk).toBe('kir');
    expect(dolulukRozeti(14.8).renk).toBe('sari');
    expect(dolulukRozeti(37.5)).toEqual({ ad: '%37,5', renk: 'ok' });
  });
  it('VAS farkı ve biçim', () => {
    expect(vasFark(-4.2)).toBe('−4,2');
    expect(vasFark(1)).toBe('+1,0');
    expect(vasFark(null)).toBe('—');
    expect(ondalik(12.25)).toBe('12,3');
    expect(yuzde(null)).toBe('—');
  });
  it('durum ve yanıt rozetleri', () => {
    expect(durumRozeti(4, 'Tamamlandı').renk).toBe('ok');
    expect(durumRozeti(5, 'Sonlandırıldı').renk).toBe('kir');
    expect(yanitRozeti('')).toBeNull();
    expect(yanitRozeti('Kısmi yanıt')?.renk).toBe('sari');
  });
});
