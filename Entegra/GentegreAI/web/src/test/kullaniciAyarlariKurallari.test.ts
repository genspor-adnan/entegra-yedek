// @vitest-environment jsdom
import { describe, it, expect } from 'vitest';
import { basHarfler, gunOnce, sifreGucu } from '../bilesenler/kullaniciAyarlariKurallari';
import { acilisSubesiGerekliMi } from '../bilesenler/calismaTercihi';
import { sessizMi, type BildirimTercihi } from '../bilesenler/bildirimTercihi';

/**
 * Kullanıcı Ayarları penceresinin saf kuralları (mockup kullanici_ayarlari.html).
 */
describe('şifre gücü', () => {
  it('dört kural: uzunluk, büyük/küçük, rakam, ad-soyad içermiyor', () => {
    const g = sifreGucu('Osman2026x', 'Dr. Osman AKAR');
    expect(g.kurallar.map(k => k.tamam)).toEqual([true, true, true, false, null]);
    expect(g.puan).toBe(3);
    expect(sifreGucu('Kuvvetli!2026', 'Osman AKAR').puan).toBe(4);
    // Ad bilinmiyorsa 'ad-soyad icermiyor' kurali gecer: puan 1.
    expect(sifreGucu('abc', '').puan).toBe(1);
  });
  it('Türkçe harf duyarsız ad karşılaştırması', () => {
    expect(sifreGucu('gunesli123A', 'Barış GÜNEŞ').kurallar[3].tamam).toBe(false);
  });
});

describe('baş harfler', () => {
  it('unvan atılır, ilk ve son kelime', () => {
    expect(basHarfler('Dr. Osman AKAR')).toBe('OA');
    expect(basHarfler('Ayşe Nur Öztürk')).toBe('AÖ');
    expect(basHarfler('admin')).toBe('AD');
    expect(basHarfler('')).toBe('?');
  });
});

describe('gün önce', () => {
  const simdi = new Date(2026, 8, 15, 10);
  it('bugün / dün / N gün önce', () => {
    expect(gunOnce('2026-09-15T08:00:00', undefined, simdi)).toBe('bugün');
    expect(gunOnce('2026-09-14T23:00:00', undefined, simdi)).toBe('dün');
    expect(gunOnce('2026-07-15T00:00:00', undefined, simdi)).toBe('62 gün önce');
    expect(gunOnce('bozuk', undefined, simdi)).toBe('bilinmiyor');
  });
});

describe('açılış şubesi', () => {
  it('yalnız yetkili ve farklı şubede, oturumda bir kez', () => {
    sessionStorage.removeItem('gentegre.acilisSube');
    const subeler = [{ id: 1 }, { id: 2 }];
    expect(acilisSubesiGerekliMi({ acilisSube: 0, acilisEkran: '' }, 1, subeler)).toBe(false);
    expect(acilisSubesiGerekliMi({ acilisSube: 1, acilisEkran: '' }, 1, subeler)).toBe(false);
    expect(acilisSubesiGerekliMi({ acilisSube: 9, acilisEkran: '' }, 1, subeler)).toBe(false);
    expect(acilisSubesiGerekliMi({ acilisSube: 2, acilisEkran: '' }, 1, subeler)).toBe(true);
    // ikinci çağrı aynı oturumda uygulamaz (kullanıcı şeritten değiştirmiş olabilir)
    expect(acilisSubesiGerekliMi({ acilisSube: 2, acilisEkran: '' }, 1, subeler)).toBe(false);
  });
});

describe('sessiz saat hafta sonu', () => {
  const t: BildirimTercihi = { olaylar: {}, sessiz: { acik: false, bas: '20:00', bit: '08:00', haftaSonu: true } };
  it('Cumartesi/Pazar tüm gün sessiz, hafta içi saat kuralı', () => {
    expect(sessizMi(new Date(2026, 8, 12, 12), t)).toBe(true);   // Cumartesi
    expect(sessizMi(new Date(2026, 8, 14, 12), t)).toBe(false);  // Pazartesi, sessiz saat kapalı
    const t2 = { ...t, sessiz: { ...t.sessiz, acik: true } };
    expect(sessizMi(new Date(2026, 8, 14, 22), t2)).toBe(true);
    expect(sessizMi(new Date(2026, 8, 14, 12), t2)).toBe(false);
  });
});
