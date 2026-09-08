import { describe, it, expect } from 'vitest';
import { agacSecenekleri } from '../bilesenler/agacSecenek';

/**
 * AĞAÇ COMBO (484) - kullanıcı: "kategori combo yerine ağaç combo olmalı".
 *
 * Kurallar veri BOZUKKEN de bir şeyin kaybolmaması üzerine kurulu: eksik üst,
 * döngü ve kendi kendine üstlük listeden kayıt düşürmemeli.
 */
describe('agacSecenekleri', () => {
  const kodlar = { '1': 'Radyoloji', '2': 'BT', '3': 'MR', '4': 'Laboratuvar', '5': 'Genel' };
  const ust = { '2': '1', '3': '1', '5': '4' };

  it('kökler ve altları ağaç sırasında dizilir', () => {
    const s = agacSecenekleri(kodlar, ust);
    expect(s.map(x => x.ad)).toEqual(['Laboratuvar', 'Genel', 'Radyoloji', 'BT', 'MR']);
  });

  it('derinliğe göre girintilenir, kök girintisiz kalır', () => {
    const s = agacSecenekleri(kodlar, ust);
    expect(s.find(x => x.ad === 'Radyoloji')!.etiket).toBe('Radyoloji');
    expect(s.find(x => x.ad === 'BT')!.etiket).toContain('BT');
    expect(s.find(x => x.ad === 'BT')!.etiket).not.toBe('BT');
    expect(s.find(x => x.ad === 'BT')!.derinlik).toBe(1);
  });

  it('üst haritası yoksa düz liste olur - ada göre sıralı', () => {
    expect(agacSecenekleri(kodlar).map(x => x.ad))
      .toEqual(['BT', 'Genel', 'Laboratuvar', 'MR', 'Radyoloji']);
  });

  it('üstü listede olmayan düğüm KÖK sayılır, kaybolmaz', () => {
    // Üst kayıt pasif ya da yetki dışı olabilir; çocuğu listeden düşmemeli.
    const s = agacSecenekleri({ '9': 'Öksüz' }, { '9': '404' });
    expect(s.map(x => x.ad)).toEqual(['Öksüz']);
    expect(s[0].derinlik).toBe(0);
  });

  it('döngü sonsuza gitmez, düğümler yine görünür', () => {
    const s = agacSecenekleri({ 'a': 'A', 'b': 'B' }, { 'a': 'b', 'b': 'a' });
    expect(s.map(x => x.ad).sort()).toEqual(['A', 'B']);
  });

  it('kendi kendinin üstü olan kayıt kök sayılır', () => {
    const s = agacSecenekleri({ 'x': 'X' }, { 'x': 'x' });
    expect(s).toHaveLength(1);
    expect(s[0].derinlik).toBe(0);
  });

  it('üç kat derinlik korunur', () => {
    const s = agacSecenekleri(
      { '1': 'Radyoloji', '2': 'BT', '3': 'Beyin BT' }, { '2': '1', '3': '2' });
    expect(s.map(x => x.derinlik)).toEqual([0, 1, 2]);
  });
});
