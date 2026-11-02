// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { bakanligaBol, bakanlikIskeleti, baslikBul, teke } from './sablonBolme';

describe('şablon bölme (1216)', () => {
  it('başlık: yalnız başlık ya da iki noktayla devam', () => {
    expect(baslikBul('BULGULAR')).toEqual([3, '']);
    expect(baslikBul('Bulgular :')).toEqual([3, '']);
    expect(baslikBul('Teknik : T2W koronal')).toEqual([1, 'T2W koronal']);
    expect(baslikBul('SONUÇ:')).toEqual([4, '']);
    expect(baslikBul('Klinik Bilgi:')).toEqual([0, '']);
    expect(baslikBul('Bulgular ile uyumlu görünüm')).toBeNull();
  });

  it('eski şablon dört parçaya bölünür, tablo bulgularda kalır', () => {
    const b = bakanligaBol('<p>SAĞ DİZ MR</p><p><i>Teknik : T2W koronal</i></p><p><b><u>Bulgular</u>:</b></p>'
      + '<p>Menisküs normal.</p><table><tbody><tr><td>a</td></tr></tbody></table><p><b>SONUÇ:</b></p><p>Normal.</p>');
    expect(b.map(x => [x.baslik, x.bakanlikParca, x.zorunlu])).toEqual([
      ['Teknik', 1, false], ['Karşılaştırma', 2, false], ['Bulgular', 3, true], ['Sonuç ve öneriler', 4, true]]);
    expect(b[0].html).toBe('<p>T2W koronal</p>');
    expect(b[1].html).toBe('');
    expect(b[2].html).toContain('SAĞ DİZ MR');
    expect(b[2].html).toContain('<table>');
    expect(b[3].html).toBe('<p>Normal.</p>');
    const s = bakanligaBol('<p><b>Bulgular:</b></p><p style="text-align: justify"><br></p><p style="x"><span style="y"> </span></p><p>Var.</p>');
    expect(s.find(x => x.bakanlikParca === 3)?.html).toBe('<p>Var.</p>');
  });

  it('başlıksız metin bütünüyle bulgulara', () => {
    const b = bakanligaBol('<p>Serbest metin.</p>');
    expect(b.find(x => x.bakanlikParca === 3)?.html).toBe('<p>Serbest metin.</p>');
  });

  it('teke birleştirme ve iskelet', () => {
    const t = teke([{ baslik: 'Bulgular', html: '<p>x</p>', bakanlikParca: 3, zorunlu: true, yazdir: true },
                    { baslik: 'Teknik', html: '', bakanlikParca: 1, zorunlu: false, yazdir: true }]);
    expect(t.html).toBe('<p><b>BULGULAR:</b></p><p>x</p>');
    const i = bakanlikIskeleti([{ baslik: 'Bulgular', html: '<p>x</p>', bakanlikParca: 3, zorunlu: true, yazdir: true }]);
    expect(i.map(x => x.bakanlikParca)).toEqual([1, 2, 3, 4]);
    expect(i[2].html).toBe('<p>x</p>');
  });
});
