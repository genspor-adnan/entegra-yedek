// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { belgeTablolari, sayiCoz } from '../bilesenler/cikti/ciktiDonustur';

describe('çıktı dönüşümü', () => {
  it('TR sayıları sayıya çevirir, tarih / kod / yüzde metin kalır', () => {
    expect(sayiCoz('1.234,56')).toBe(1234.56);
    expect(sayiCoz('-12,50 ₺')).toBe(-12.5);
    expect(sayiCoz('2026')).toBe(2026);
    expect(sayiCoz('01.09.2026')).toBeNull();
    expect(sayiCoz('%12,5')).toBeNull();
    expect(sayiCoz('0012')).toBeNull();
    expect(sayiCoz('P-000147')).toBeNull();
  });
  it('belgeyi satırlara döker: başlık kalın, tablo hücreleri, toplam satırı kalın', () => {
    const d = document.createElement('div');
    d.innerHTML = `<h3>İCMAL</h3><div class="a4-hasta"><span>Dönem: Eylül</span><span>Adet: 3</span></div>
      <table><thead><tr><th>Ad</th><th>Tutar</th></tr></thead>
      <tbody><tr><td>A</td><td>1.000,00</td></tr><tr class="top"><td>Toplam</td><td>1.000,00</td></tr></tbody></table>`;
    const v = belgeTablolari(d);
    expect(v.satirlar[0]).toEqual(['İCMAL']);
    expect(v.satirlar[1]).toEqual(['Dönem: Eylül', 'Adet: 3']);
    expect(v.satirlar).toContainEqual(['A', 1000]);
    const toplam = v.satirlar.findIndex(s => s[0] === 'Toplam');
    expect(v.kalin).toContain(0);
    expect(v.kalin).toContain(toplam);
    expect(v.kalin).toContain(v.satirlar.findIndex(s => s[0] === 'Ad'));
  });
});
