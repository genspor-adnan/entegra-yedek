import { describe, expect, it } from 'vitest';
import { devirRozeti, neredeRozeti, oturumRozeti, terminalRozeti } from '../sayfalar/vezne/icmal/vezneOrtak';

describe('vezne icmali', () => {
  it('oturum rozeti durum ve açıklamasız farka göre', () => {
    expect(oturumRozeti({ durum: 2, fark: null, farkAciklama: '' }).ad).toBe('Açık');
    expect(oturumRozeti({ durum: 3, fark: -50, farkAciklama: '' }).ad).toBe('Kapanış onayı bekliyor');
    expect(oturumRozeti({ durum: 4, fark: 0, farkAciklama: '' })).toEqual({ ad: 'Teslim edildi', renk: 'ok' });
    expect(oturumRozeti({ durum: 4, fark: -50, farkAciklama: '' }).renk).toBe('kir');
    expect(oturumRozeti({ durum: 4, fark: -50, farkAciklama: 'bozuk para' }).renk).toBe('sari');
  });

  it('POS terminali: gün sonu girilmeden fark hesaplanmaz', () => {
    expect(terminalRozeti({ eksik: true, fark: null }).ad).toBe('Cihaz gün sonu girilmedi');
    expect(terminalRozeti({ eksik: false, fark: 0 }).ad).toBe('Eşleşti');
    expect(terminalRozeti({ eksik: false, fark: 250 }).ad).toBe('Kasaya girilmemiş işlem');
    expect(terminalRozeti({ eksik: false, fark: -10 }).ad).toBe('Cihazda olmayan kayıt');
  });

  it('nerede ve devir rozetleri', () => {
    expect(neredeRozeti({ kasaDurumu: 1, hesapTuru: 'K', net: 100 }).ad).toBe('Kasada');
    expect(neredeRozeti({ kasaDurumu: 2, hesapTuru: 'P', net: 100 }).ad).toBe('Bankada (bloke)');
    expect(neredeRozeti({ kasaDurumu: 3, hesapTuru: '', net: 100 }).ad).toBe('Portföyde');
    expect(devirRozeti({ durum: 4, fark: 0 }).ad).toBe('Devredildi');
    expect(devirRozeti({ durum: 2, fark: null }).ad).toBe('Oturum açık');
  });
});
