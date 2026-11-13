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

  // AYNI ÖRNEK api/tests/.../SablonBakanlikBolmeTestleri.cs'de SQL fn_rad_sablon_bol (1332) için sınanır.
  it('eski Word kalıntıları atılır: yer tutuculu üst bilgi, hitap, imza (1332)', () => {
    const b = bakanligaBol('<table><tbody><tr><td>HASTA ADI</td><td><b>@ADSOYAD</b></td></tr></tbody></table>'
      + '<p><br></p><p>Sayın Meslektaşım,</p><p><b>Teknik: </b>T2A aksial.</p>'
      + '<p><b><u>Bulgular</u></b><b>:</b></p><p>Karaciğer boyutları normal, parankim homojen, fokal lezyon izlenmedi.</p>'
      + '<p><b>SONU&#199;:</b></p><p><b>Normal sınırlarda.</b></p><p><br></p>'
      + '<p style="text-align: center">Saygılarımızla,</p><p>Rad.Dr. X</p>');
    expect(b.map(x => x.bakanlikParca)).toEqual([1, 2, 3, 4]);
    expect(b[0].html).toBe('<p>T2A aksial.</p>');
    expect(b[2].html).toBe('<p>Karaciğer boyutları normal, parankim homojen, fokal lezyon izlenmedi.</p>');
    expect(b[3].html).toBe('<p><b>Normal sınırlarda.</b></p>');
    expect(b.map(x => x.html).join('')).not.toMatch(/@ADSOYAD|Meslektaşım|Saygılarımızla|Rad\.Dr/);
  });

  it('yer tutucu ilk başlıktan sonra korunur', () => {
    const b = bakanligaBol('<p>BULGULAR:</p><p>Ölçüm @OLCUM mm.</p>');
    expect(b[2].html).toBe('<p>Ölçüm @OLCUM mm.</p>');
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
