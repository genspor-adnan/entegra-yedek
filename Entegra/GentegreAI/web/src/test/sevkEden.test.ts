import { describe, expect, it } from 'vitest';
import { odemeRozeti, sevkDegisimi, turRozeti } from '../sayfalar/sevk/sevkOrtak';

describe('sevk eden icmali', () => {
  it('ödeme durumu rozetleri', () => {
    expect(odemeRozeti('odendi').renk).toBe('ok');
    expect(odemeRozeti('hesaplandi').ad).toBe('Hesaplandı · onay bekliyor');
    expect(odemeRozeti('yok').ad).toBe('Komisyon yok');
  });
  it('tür ve sevk değişimi', () => {
    expect(turRozeti('kurum').ad).toBe('Kurum adına');
    expect(sevkDegisimi({ yeni: true, degisim: null }).ad).toBe('yeni');
    expect(sevkDegisimi({ yeni: false, degisim: 25 })).toEqual({ ad: '▲ %25', renk: 'ok' });
    expect(sevkDegisimi({ yeni: false, degisim: -40 }).renk).toBe('kir');
  });
});
