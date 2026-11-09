import { describe, expect, it } from 'vitest';
import { kaynakAdlari, kaynakAramaUyar, kaynakListeSuzgeci } from '../bilesenler/belge/SiparistenAktarPenceresi';

// KAYNAKTAN AKTAR penceresi (09.11.2026, mockup Ekranlar/ERP/kaynaktan_aktar.html): sol listenin süzgeci ve araması.
describe('kaynakListeSuzgeci', () => {
  it('satış siparişi + cari + açık çipi', () => {
    expect(kaynakListeSuzgeci(19, 377, 'acik')).toEqual({ op: 'and', kosullar: [
      { alan: 'tur', op: 'esit', deger: 19 }, { alan: 'tarafId', op: 'esit', deger: 377 },
      { alan: 'kapanmaDurum', op: 'esit', deger: 0 }] });
  });
  it('teklifte yalnız KABUL (3); carisiz kartta cari koşulu yok', () => {
    const k = kaynakListeSuzgeci(18, null, 'kismi').kosullar!;
    expect(k).toContainEqual({ alan: 'teklifDurum', op: 'esit', deger: 3 });
    expect(k.find(x => x.alan === 'tarafId')).toBeUndefined();
    expect(k).toContainEqual({ alan: 'kapanmaDurum', op: 'esit', deger: 1 });
  });
  it('tümü: kapananlar da gelir, yalnız iptal (durum 2) dışarıda', () => {
    const k = kaynakListeSuzgeci(14, 5, 'tumu').kosullar!;
    expect(k.find(x => x.alan === 'kapanmaDurum')).toBeUndefined();
    expect(k).toContainEqual({ alan: 'durum', op: 'esitDegil', deger: 2 });
  });
});

describe('kaynakAramaUyar', () => {
  const b = { belgeNo: '000000418', aciklama: 'Kasım sevkiyatı', tarafUnvan: 'Medikal Plus' };
  it('boş arama hepsini geçirir; no / açıklama / cari içinde Türkçe küçük-büyük duyarsız', () => {
    expect(kaynakAramaUyar(b, '')).toBe(true);
    expect(kaynakAramaUyar(b, '418')).toBe(true);
    expect(kaynakAramaUyar(b, 'KASIM')).toBe(true);
    expect(kaynakAramaUyar(b, 'plus')).toBe(true);
    expect(kaynakAramaUyar(b, 'aralık')).toBe(false);
  });
});

describe('kaynakAdlari', () => {
  it('tür -> başlık / ek', () => {
    expect(kaynakAdlari(19).baslik).toBe('Siparişten Aktar');
    expect(kaynakAdlari(14)).toMatchObject({ irsaliyeMi: true, den: 'irsaliyeden', liste: 'satış irsaliyesi' });
    expect(kaynakAdlari(18)).toMatchObject({ teklifMi: true, liste: 'kabul edilmiş teklifi' });
  });
});
