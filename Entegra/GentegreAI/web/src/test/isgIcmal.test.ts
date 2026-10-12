import { describe, expect, it } from 'vitest';
import { gecikmeRenk, karsilamaRozeti, sozlesmeRozeti, tahsilRozeti, yuzde } from '../sayfalar/isgIcmal/isgIcmalOrtak';

describe('İSG / OSGB icmali', () => {
  it('hizmet süresi karşılama rozeti', () => {
    expect(karsilamaRozeti(null)).toEqual({ ad: 'plan yok', renk: 'pas' });
    expect(karsilamaRozeti(102).renk).toBe('ok');
    expect(karsilamaRozeti(90)).toEqual({ ad: '%90', renk: 'sari' });
    expect(karsilamaRozeti(77.4).renk).toBe('kir');
    expect(yuzde(89.6)).toBe('%90');
  });
  it('sözleşme bitişi rozeti', () => {
    expect(sozlesmeRozeti(null).renk).toBe('pas');
    expect(sozlesmeRozeti(-3)).toEqual({ ad: '3 gün geçti', renk: 'kir' });
    expect(sozlesmeRozeti(21).renk).toBe('kir');
    expect(sozlesmeRozeti(51)).toEqual({ ad: '51 gün kaldı', renk: 'sari' });
    expect(sozlesmeRozeti(113).renk).toBe('pas');
  });
  it('tahsil ve gecikme renkleri', () => {
    expect(tahsilRozeti('Tahsil edildi').renk).toBe('ok');
    expect(tahsilRozeti('Kısmi').renk).toBe('sari');
    expect(tahsilRozeti('Bekliyor').renk).toBe('kir');
    expect(gecikmeRenk(135)).toBe('kir');
    expect(gecikmeRenk(45)).toBe('sari');
    expect(gecikmeRenk(11)).toBe('');
  });
});
