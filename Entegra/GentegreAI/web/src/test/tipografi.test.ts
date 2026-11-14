// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { TIPOGRAFI_OZGUN, TIPOGRAFI_VARSAYILAN, gomuluBicimTemizle, sablonTipografisi, tipografiOku, tipografiStil } from '../sayfalar/radyoloji/tipografi';

/**
 * RAPOR TİPOGRAFİSİ (1344). Üç kural tutulur:
 *   1) şablon üst-seçimi: 1 kurum · 2 özel (boş alan kurumdan) · 3 özgün;
 *   2) Word'den gelen gömülü font / punto şablon uygulanırken atılır, kalın / renk / tablo kalır
 *      (kullanıcı 14.11.2026: "yazı tipi ve puntoyu rapor ekranında değiştiremiyorum" → CSS zorlaması yok, temizlik var);
 *   3) sınır dışı / bozuk değer yedeğe düşer (ayar elle bozulsa ekran çökmez).
 */
describe('rapor tipografisi', () => {
  it('şablon üst-seçimi: kurum / özel / özgün', () => {
    const kurum = { ...TIPOGRAFI_VARSAYILAN, punto: 11 };
    expect(sablonTipografisi({ tipografiKaynak: 1 }, kurum).punto).toBe(11);
    expect(sablonTipografisi({ tipografiKaynak: 3 }, kurum)).toEqual(TIPOGRAFI_OZGUN);
    const ozel = sablonTipografisi({ tipografiKaynak: 2, tipFont: 'times', tipPunto: 12, tipHiza: 1 }, kurum);
    expect(ozel).toMatchObject({ font: 'times', punto: 12, hiza: 'sol', satir: kurum.satir, kaynak: 'sablon' });
  });

  it('gömülü font / punto temizlenir, kalın ve renk kalır', () => {
    const h = '<p style="text-align: justify"><b><span style="font-size: 13pt; font-family: Calibri; color: #c00000">Sayın</span></b>'
            + '<font size="4" face="Arial">x</font><span style="line-height: 1.5">y</span></p>';
    const t = gomuluBicimTemizle(h);
    expect(t).not.toMatch(/font-size|font-family|line-height|size=|face=/);
    expect(t).toContain('<b>');
    expect(t).toContain('color: rgb(192, 0, 0)');
    expect(t).toContain('text-align: justify');
  });

  it('bozuk / sınır dışı ayar yedeğe düşer; CSS değişkenleri pt → px', () => {
    const t = tipografiOku({ font: 'comic', punto: 30, satir: 0.2, hiza: 'orta', kenar: 99 });
    expect(t).toMatchObject({ font: 'arial', punto: 12, satir: 1, hiza: 'iki', kenar: 25 });
    expect(tipografiStil({ ...TIPOGRAFI_VARSAYILAN, punto: 10.5 })).toMatchObject({ '--rt-punto': '14.00px', '--rt-hiza': 'justify' });
    expect(tipografiOku(null)).toEqual({ ...TIPOGRAFI_VARSAYILAN });
  });
});
