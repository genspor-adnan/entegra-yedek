import { describe, expect, it } from 'vitest';
import { ONAYA_SUNULABILIR, TEKLIF_ONAY_KILIDI, teklifOnayDugmesi } from '../bilesenler/belge/TeklifOnay';
import { TEKLIF_DURUMLARI, TEKLIF_DURUM_ELLE } from '../sayfalar/belgeSabitleri';
import { gecmisOlayi } from '../bilesenler/belge/TeklifGecmisi';

// TEKLİF İÇ ONAYI (1282, mockup Ekranlar/Teklif/teklif_ic_onay.html): durum kodları ve araç çubuğu düğmesi.
describe('teklif iç onay durumları', () => {
  it('yeni kodlar adlı; elle seçilebilenler yalnız 1-5', () => {
    expect(TEKLIF_DURUMLARI['6']).toBe('Onayda');
    expect(TEKLIF_DURUMLARI['9']).toBe('Reddedildi');
    expect(Object.keys(TEKLIF_DURUM_ELLE)).toEqual(['1', '2', '3', '4', '5']);
  });
  it('kilit onayda ve onaylandı; sunulabilir hazırlanıyor / düzeltme / ret', () => {
    expect([...TEKLIF_ONAY_KILIDI].sort()).toEqual([6, 7]);
    expect([...ONAYA_SUNULABILIR].sort()).toEqual([1, 8, 9]);
  });
  it('düğme: kayıtsız yok · 1/8/9 Onaya Sun · 6 Geri Çek · 7/2/3 yok', () => {
    expect(teklifOnayDugmesi(1, false)).toBeNull();
    expect(teklifOnayDugmesi(1, true)).toBe('onaya-sun');
    expect(teklifOnayDugmesi(8, true)).toBe('onaya-sun');
    expect(teklifOnayDugmesi(9, true)).toBe('onaya-sun');
    expect(teklifOnayDugmesi(6, true)).toBe('geri-cek');
    expect(teklifOnayDugmesi(7, true)).toBeNull();
    expect(teklifOnayDugmesi(2, true)).toBeNull();
  });
  it('geçmiş olayları: onaya sunuldu / geri çekildi', () => {
    const k = { id: 1, tarih: '2026-11-10T10:00:00Z', kullanici: 'admin', islemTipi: 2, tabloId: 30, hedefBelgeNo: '' };
    expect(gecmisOlayi({ ...k, bilgi: '{"aksiyon":"onaya-sun","sonTarih":"2026-11-12","not":"bayi fiyatı"}' }))
      .toEqual({ baslik: 'Onaya sunuldu', ayrinti: 'son 2026-11-12 · "bayi fiyatı"' });
    expect(gecmisOlayi({ ...k, bilgi: '{"aksiyon":"onay-geri-cek"}' }).baslik).toBe('Onaydan geri çekildi');
  });
});
