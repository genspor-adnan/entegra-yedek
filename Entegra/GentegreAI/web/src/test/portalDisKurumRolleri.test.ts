import { describe, expect, it } from 'vitest';
import { menuSatirlariKur } from '../sayfalar/kabuk/menuAgaci';
import { LISTELER } from '../sayfalar/listeTanimlari';
import { portalBolumleri, type MenuKaynagi } from '../sayfalar/portal/portalMenu';

/**
 * DIŞ KURUM: KLİNİK ve YÖNETİCİ ROLLERİ (824).
 *
 * Kullanıcı: *"anlaşmalı kurumdan hasta gönderen doktor ve hesapları kontrol
 * eden yönetici var"* → *"kurum kapsamı olsun, fatura satırında hasta adı
 * görünmesin"*.
 *
 * İkisi de AYNI kapsamda çalışır (kurum, `portal_turu = 2`); ayrım YETKİDE.
 * Bu test iki yönü de kilitler:
 *   - yönetici TIBBİ ekran görmez (muhasebeci hasta sonucuna bakmasın),
 *   - klinik rol MALİ ekran görmez (fatura/ekstre hekimin işi değil).
 *
 * Yetki listeleri db/824 sonrası gerçek rol içerikleridir.
 */

// db/824: rol_yetki içerikleri.
const KLINIK = ['ai.rehber', 'hasta', 'lab', 'lab.numune', 'lab.sonuc', 'mesaj',
                'teleradyoloji'];
const YONETICI = ['ai.rehber', 'mesaj', 'portal.mali'];

/** Rolün yetkileriyle portal menüsünde çıkan ekran yolları. */
function yollar(yetkiler: string[], kapsam: string[]): string[] {
  const satirlar = menuSatirlariKur(LISTELER, k => yetkiler.includes(k), 2, undefined);
  // PortalKabuk ile AYNI düzleştirme: grup satırı alt öğelerini, düz satır
  //   kendi öğesini verir.
  const ogeler = satirlar.flatMap(s => (s.tur === 'duz' ? [s.m] : s.alt)) as MenuKaynagi[];
  return portalBolumleri(ogeler, 2, kapsam).flatMap(b => b.ogeler.map(o => o.yol));
}

describe('dış kurum rolleri (824)', () => {
  it('yönetici mali ekranları görür, tıbbi ekranları GÖRMEZ', () => {
    // Sunucunun bu rol için açtığı kaynaklar: yalnız mali olanlar.
    const y = yollar(YONETICI, ['kurum-belge', 'kurum-ekstre']);

    expect(y).toContain('/kurum-belge');
    expect(y).toContain('/kurum-ekstre');
    for (const tibbi of ['/hasta', '/lab-istem', '/lab-numune', '/lab-sonuc',
                         '/teleradyoloji', '/radyoloji'])
      expect(y).not.toContain(tibbi);
  });

  it('klinik rol mali ekranları GÖRMEZ', () => {
    const k = yollar(KLINIK, ['hasta', 'lab-istem', 'lab-numune', 'lab-sonuc',
                              'telerad-istek']);

    expect(k).toContain('/hasta');
    expect(k).toContain('/teleradyoloji');
    expect(k).not.toContain('/kurum-belge');
    expect(k).not.toContain('/kurum-ekstre');
  });

  it('mali ekranlar YALNIZ portal.mali yetkisiyle üretilir', () => {
    // Yetki kodu yanlışlıkla `belge`/`cari` gibi genel bir koda çevrilirse
    //   ekran iç rollerde de menüye düşer - bu satır onu yakalar.
    const mali = LISTELER.filter(l => l.kaynak === 'kurum-belge'
                                   || l.kaynak === 'kurum-ekstre');
    expect(mali.length).toBe(2);
    for (const l of mali) expect(l.yetkiKodu).toBe('portal.mali');
  });
});
