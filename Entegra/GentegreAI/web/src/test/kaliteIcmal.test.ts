import { describe, expect, it } from 'vitest';
import { durumRozeti, hedefMetni, oranRozeti, soruDegerlendirme, sonucMetni, trend } from '../sayfalar/kaliteIcmal/kaliteIcmalOrtak';

describe('kalite / sks icmali', () => {
  it('sonuç ve hedef metni', () => {
    expect(sonucMetni(82.6, '%')).toBe('%82,6');
    expect(sonucMetni(2.08, '‰')).toBe('2,08‰');
    expect(sonucMetni(null, '%')).toBe('—');
    expect(hedefMetni('>=', 90, '%')).toBe('≥ %90,0');
    expect(hedefMetni('<=', 2.5, '‰')).toBe('≤ 2,50‰');
    expect(hedefMetni('', 90, '%')).toBe('—');
  });
  it('trend hedef yönüne göre renklenir', () => {
    expect(trend(82.6, 89.6, '>=', '%')).toEqual({ ok: '▼', fark: '7,0', yon: 'kotu' });
    expect(trend(2.08, 3.1, '<=', '‰')).toEqual({ ok: '▼', fark: '1,02', yon: 'iyi' });
    expect(trend(85.7, 84.9, '>=', '%')?.yon).toBe('iyi');
    expect(trend(10, null, '>=', '%')).toBeNull();
    expect(trend(10, 10, '>=', '%')?.yon).toBe('notr');
  });
  it('rozetler', () => {
    expect(durumRozeti('disi')).toEqual({ ad: 'Hedef dışı', renk: 'kir' });
    expect(durumRozeti('kaynakyok').ad).toBe('Kaynak yok');
    expect(oranRozeti(74.6, 85).renk).toBe('kir');
    expect(oranRozeti(87.5, 85).ad).toBe('Hedefte');
    expect(soruDegerlendirme(4.58).ad).toBe('güçlü');
    expect(soruDegerlendirme(3.74).ad).toBe('iyileştir');
    expect(soruDegerlendirme(4.21).ad).toBe('orta');
  });
});
