// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { excelBloklari } from '../bilesenler/cikti/ciktiDonustur';

describe('çıktı dönüşümü - Excel blokları', () => {
  it('A4 yapısını bloklara ayırır, imzayı atlar', () => {
    const d = document.createElement('div');
    d.innerHTML = `<div class="a4-bas"><img /><div><div class="kurum">Demo</div><div class="kurum-alt">Adres</div></div>
        <div class="a4-tarih">Düzenleme: 10.10.2026</div></div>
      <h3>İSKONTO İCMALİ</h3>
      <div class="a4-hasta"><span>Dönem: Eylül</span><span>Başvuru: 3</span></div>
      <table class="a4-t"><thead><tr><th>Ad</th><th>Tutar</th></tr></thead>
        <tbody><tr><td>A</td><td>1.000,00</td></tr><tr class="top"><td>Toplam</td><td>1.000,00</td></tr></tbody></table>
      <table class="a4-toplam"><tbody><tr><td>Ara</td><td>10,00 ₺</td></tr><tr class="kalan"><td>TOPLAM</td><td>10,00 ₺</td></tr></tbody></table>
      <p class="a4-not">Not metni</p>
      <div class="a4-imza"><div>Hazırlayan</div></div>`;
    const b = excelBloklari(d);
    expect(b.map(x => x.tur)).toEqual(['kurum', 'baslik', 'bilgi', 'tablo', 'ozet', 'not']);
    expect(b[0]).toMatchObject({ satirlar: ['Demo', 'Adres'], sag: ['Düzenleme: 10.10.2026'] });
    expect(b[2]).toMatchObject({ hucreler: ['Dönem: Eylül', 'Başvuru: 3'] });
    expect(b[3]).toMatchObject({ basliklar: ['Ad', 'Tutar'], satirlar: [['A', '1.000,00'], ['Toplam', '1.000,00']], kalin: [1] });
    expect(b[4]).toMatchObject({ satirlar: [{ ad: 'Ara', deger: '10,00 ₺', kalin: false }, { ad: 'TOPLAM', kalin: true }] });
  });
});
