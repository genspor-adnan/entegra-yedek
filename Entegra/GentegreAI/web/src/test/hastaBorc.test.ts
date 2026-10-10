import { describe, expect, it } from 'vitest';
import type { Borclu } from '../api/uclar/hastaBorc';
import { durumRozeti, islemSonucu, kanalaUygun } from '../sayfalar/borc/borcOrtak';

const b = (id: number, tel: boolean, ep: boolean) => ({ id, telefonVar: tel, epostaVar: ep }) as Borclu;

describe('hasta borç takibi', () => {
  it('durum rozetleri', () => {
    expect(durumRozeti('tahsilata').renk).toBe('kir');
    expect(durumRozeti('soz_tutulmadi').ad).toBe('Söz tutulmadı');
    expect(durumRozeti('yeni').ad).toBe('Hatırlatma bekliyor');
  });
  it('hatırlatma sonucu bildirim durumundan', () => {
    expect(islemSonucu({ tur: 1, durum: 0, bildirimDurum: 3 }).ad).toBe('Gönderildi');
    expect(islemSonucu({ tur: 1, durum: 0, bildirimDurum: 4 }).renk).toBe('kir');
    expect(islemSonucu({ tur: 2, durum: 0, bildirimDurum: null }).ad).toBe('Geçerli');
    expect(islemSonucu({ tur: 2, durum: 9, bildirimDurum: null }).ad).toBe('Kaldırıldı');
  });
  it('kanala uygun seçili hastalar', () => {
    const l = [b(1, true, false), b(2, false, true), b(3, true, true)];
    expect(kanalaUygun(l, [1, 2], 1).map(x => x.id)).toEqual([1]);
    expect(kanalaUygun(l, [1, 2, 3], 2).map(x => x.id)).toEqual([2, 3]);
  });
});
