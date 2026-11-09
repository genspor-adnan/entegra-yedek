import { describe, expect, it } from 'vitest';
import { gecmisOlayi } from '../bilesenler/belge/TeklifGecmisi';
import type { BelgeGecmisKaydi } from '../api/uclar/belge';

// TEKLİF GEÇMİŞİ (kullanıcı 09.11.2026): islem_log satırı -> okunur olay. Veri biçimleri UNIVERSE teklif 10302'nin
//   gerçek log satırlarından (ekle / kaydet / teklif-durum) ve dönüşüm logundan.
const k = (y: Partial<BelgeGecmisKaydi>): BelgeGecmisKaydi =>
  ({ id: 1, tarih: '2026-11-09T16:46:55Z', kullanici: 'admin', islemTipi: 2, tabloId: 30, bilgi: '{}', hedefBelgeNo: '', ...y });

describe('gecmisOlayi', () => {
  it('oluşturma: belge no + kalem', () => {
    const o = gecmisOlayi(k({ islemTipi: 1, bilgi: '{"tur": "18", "taslak": "0", "belgeNo": "000000002", "tarafId": "377", "satirAdedi": "3"}' }));
    expect(o).toEqual({ baslik: 'Teklif oluşturuldu', ayrinti: 'No 000000002 · 3 kalem' });
  });
  it('kaydetme: kalem adedi', () => {
    expect(gecmisOlayi(k({ bilgi: '{"satirAdedi": "2"}' }))).toEqual({ baslik: 'Kaydedildi', ayrinti: '2 kalem' });
  });
  it('durum değişimi: kodlar ada çevrilir', () => {
    expect(gecmisOlayi(k({ bilgi: '{"aksiyon": "teklif-durum", "teklifDurum": "1 -> 2"}' })))
      .toEqual({ baslik: 'Durum değişti', ayrinti: 'Hazırlanıyor → Sunuldu' });
  });
  it('dönüşüm: hedef tür + numara', () => {
    expect(gecmisOlayi(k({ bilgi: '{"aksiyon": "donustur", "hedefTur": "19", "hedefBelgeId": "10291", "satirAdedi": "2"}', hedefBelgeNo: '000001' })))
      .toEqual({ baslik: 'Siparişe dönüştürüldü', ayrinti: 'No 000001 · 2 kalem' });
  });
  it('satır logu: kalem eklendi / silindi', () => {
    expect(gecmisOlayi(k({ tabloId: 31, islemTipi: 3, bilgi: '{"stokAdi": "Cihaz"}' }))).toEqual({ baslik: 'Kalem silindi', ayrinti: 'Cihaz' });
  });
  it('bozuk bilgi çökertmez', () => {
    expect(gecmisOlayi(k({ islemTipi: 3, bilgi: '{bozuk' })).baslik).toBe('Teklif silindi');
  });
});
