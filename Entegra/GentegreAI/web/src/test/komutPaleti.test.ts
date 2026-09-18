import { describe, expect, it } from 'vitest';
import { LISTELER } from '../sayfalar/Liste';
import { menuSatirlariKur } from '../sayfalar/kabuk/menuAgaci';
import { paletEkranlari, paletPuan, paletSadelestir }
  from '../sayfalar/kabuk/KomutPaleti';

/**
 * KOMUT PALETİ (790) — üst şeritteki "Ara ya da komut yaz" kutusu.
 *
 * Kullanıcı: *"en üstteki ara ya da komut yaz editini şu anki menü ve ekran
 * adlarına göre yapılandır.. oradan kısa yoldan ulaşabileyim"*.
 *
 * Paletin içeriği MENÜNÜN KENDİSİDİR; bu testler o bağın kopmadığını ve
 * aramanın Türkçe yazımda (İ/ı, ş, ğ) tutmaya devam ettiğini korur - bir
 * kullanıcı "İstem" yazıp sonuç alamayınca kutuyu bir daha açmaz.
 */

/** Yönetici gibi: her yetki açık, HBYS modu, tüm modüller. */
const TUM_MODULLER = [
  'acil', 'ameliyathane', 'dis', 'dokuman', 'eczane', 'enabiz', 'erp_satis',
  'form', 'ftr', 'goz', 'ik', 'isg', 'kasa', 'kayit_kabul', 'lab', 'mesaj',
  'muayene', 'muhasebe', 'prim', 'radyoloji', 'randevu', 'satinalma', 'servis',
  'stok', 'teleradyoloji', 'teletip', 'uretim', 'yatan_hasta',
];
const satirlar = menuSatirlariKur(LISTELER, () => true, 2, TUM_MODULLER);
const ekranlar = paletEkranlari(satirlar);

describe('komut paleti', () => {
  it('menüdeki her ekran palette aranabilir', () => {
    // Palet menüden ÜRETİLİR: ayrı bir komut listesi tutulsaydı, yeni eklenen
    //   ekran menüde çıkıp palette hiç görünmezdi ve kimse fark etmezdi.
    const menuOgeleri = satirlar.flatMap(s => (s.tur === 'duz' ? [s.m] : s.alt));
    expect(ekranlar.length).toBeGreaterThan(50);
    expect(ekranlar.length).toBe(new Set(menuOgeleri.map(m => m.yol)).size);
    for (const e of ekranlar) expect(e.ad.trim().length).toBeGreaterThan(0);
  });

  it('grup adı ekranla birlikte taşınır (aynı adlı ekranlar ayrışsın)', () => {
    // "Listeler" adlı iki ekran ayrı gruplarda olabilir; grup yoksa palet iki
    //   aynı satır gösterir ve kullanıcı hangisine gittiğini bilmez.
    const grupluAdet = ekranlar.filter(e => e.grup.length > 0).length;
    expect(grupluAdet).toBeGreaterThan(ekranlar.length / 2);
  });

  it('Türkçe yazım aramayı bozmaz', () => {
    expect(paletSadelestir('İstem Şablonu')).toBe('istem sablonu');
    expect(paletSadelestir('ÇAĞRI')).toBe('cagri');
    // "İstem" yazan "istem"i bulmalı: tr'de lower('I') = 'ı', iki taraf aynı
    //   kurala indirgenmezse sonuç boş döner.
    expect(paletPuan('İstemler', 'Laboratuvar', 'istem')).not.toBeNull();
    expect(paletPuan('Şube Tanımları', 'Yönetim', 'sube')).not.toBeNull();
  });

  it('adın BAŞI grup eşleşmesinden değerli', () => {
    const basi = paletPuan('Hasta Listesi', 'Kayıt Kabul', 'has');
    const icinde = paletPuan('Randevu', 'Hasta İşlemleri', 'has');
    expect(basi).not.toBeNull();
    expect(icinde).not.toBeNull();
    expect(basi!).toBeLessThan(icinde!);
  });

  it('çok kelimeli aramada her kelime tutmalı', () => {
    expect(paletPuan('Kasa İşlemleri', 'Finans', 'kasa isl')).not.toBeNull();
    // "kasa fatura" tek bir ekranı tarif etmiyor: yarısı tutuyor diye sonuç
    //   vermek, kullanıcıyı yanlış ekrana götürür.
    expect(paletPuan('Kasa İşlemleri', 'Finans', 'kasa fatura')).toBeNull();
  });

  it('boş sorgu her şeye uyar (kısa yol listesi çizilebilsin)', () => {
    expect(paletPuan('Hasta Listesi', 'Kayıt Kabul', '')).toBe(0);
  });

  it('gerçek aramalar gerçek ekranları buluyor', () => {
    const ara = (q: string) => ekranlar
      .map(e => ({ e, puan: paletPuan(e.ad, e.grup, q) }))
      .filter(x => x.puan !== null)
      .sort((a, b) => a.puan! - b.puan!)
      .map(x => x.e.ad);

    for (const q of ['hasta', 'randevu', 'kasa', 'fatura']) {
      const sonuc = ara(q);
      expect(sonuc.length, `"${q}" için palet boş döndü`).toBeGreaterThan(0);
    }
  });
});
