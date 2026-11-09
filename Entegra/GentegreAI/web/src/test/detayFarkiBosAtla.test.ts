import { describe, expect, it } from 'vitest';
import { detayFarki } from '../bilesenler/detayDurumu';

// BOŞ SATIR ATLANIR (kullanıcı 09.11.2026): yeni stok kartının Fiyatlar sekmesine her aktif liste ön satır gelir;
//   fiyat girilmeyen satır ne gönderilir ne "kaydedilmemiş değişiklik" sayılır, dolu olan eklenen satırdır.
describe('detayFarki bosAtlaAlani', () => {
  const durum = {
    ilk: [],
    guncel: [
      { listeId: 2, fiyat: '', dovizCinsi: 'TL' },
      { listeId: 3, fiyat: '0', dovizCinsi: 'TL' },
      { listeId: 4, fiyat: '125.5', dovizCinsi: 'TL' },
    ],
    silinen: [],
  };

  it('boş / 0 fiyatlı ön satırlar elenir, dolu olan eklenen gider', () => {
    const f = detayFarki(durum, undefined, 'fiyat');
    expect(f.eklenen).toHaveLength(1);
    expect(f.eklenen![0].listeId).toBe(4);
    expect(f.degisen).toBeUndefined();
  });

  it('alan verilmezse eski davranış: hepsi eklenen', () => {
    expect(detayFarki(durum).eklenen).toHaveLength(3);
  });

  it('hiç dolu satır yoksa fark boş - kapanışta soru çıkmaz', () => {
    const f = detayFarki({ ...durum, guncel: durum.guncel.slice(0, 2) }, undefined, 'fiyat');
    expect(f.eklenen).toBeUndefined();
  });
});
