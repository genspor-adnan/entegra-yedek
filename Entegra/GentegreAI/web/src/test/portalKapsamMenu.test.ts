import { describe, expect, it } from 'vitest';
import { portalBolumleri, type MenuKaynagi } from '../sayfalar/portal/portalMenu';

/**
 * PORTAL MENÜSÜ — KAPSAM SÜZGECİ (796 V2).
 *
 * Tarayıcıda görüldü: dış kurum menüsünde "Diğer" başlığı altında
 * <b>Teslim Kuyruğu, Gelen Raporlar, Bakanlık Eksikleri, Telerad Panosu</b>
 * çıkıyordu. Sebep: kurum rolü kendi isteğini açabilsin diye `teleradyoloji`
 * yetkisini taşıyor; o ekranların portal kapsam kuralı ise `false` - açılsalar
 * BOŞ gelirlerdi.
 *
 * Kural: menü <b>yetki + kapsam</b>a bakar. Boş gelecek ekranı göstermek, her
 * zaman hata veren düğme göstermekle aynı sınıfta.
 */

const oge = (yol: string, ad: string, kaynak?: string): MenuKaynagi =>
  ({ yol, ad, ic: '•', kaynak });

describe('portal menüsü kapsam süzgeci', () => {
  const menu: MenuKaynagi[] = [
    oge('/teleradyoloji', 'Teleradyoloji Listesi', 'telerad-istek'),
    oge('/telerad-teslim', 'Teslim Kuyruğu', 'telerad-teslim'),
    oge('/telerad-gelen', 'Gelen Raporlar', 'telerad-gelen'),
    oge('/telerad-bakanlik-eksik', 'Bakanlık Eksikleri', 'telerad-bakanlik-eksik'),
    oge('/telerad-pano', 'Telerad Panosu'),              // özel sayfa: kaynağı yok
  ];
  // Sunucunun söylediği: bu portalda yalnız telerad-istek satır gösterebilir.
  const kapsam = ['telerad-istek', 'lab-istem', 'hasta'];

  it('kapsamı kapalı iç ekranlar menüde görünmez', () => {
    const b = portalBolumleri(menu, 2, kapsam);
    const adlar = b.flatMap(x => x.ogeler.map(o => o.ad));

    expect(adlar).toEqual(['Görüntü isteklerim']);
    expect(adlar).not.toContain('Teslim Kuyruğu');
    expect(adlar).not.toContain('Gelen Raporlar');
  });

  it('kaynağı olmayan özel sayfa da kapsam bilinmeden gösterilmez', () => {
    // Pano/ayar gibi ekranların liste kaynağı yok; portal tablosunda adı
    //   geçmiyorsa iç ekran sayılır.
    const b = portalBolumleri([oge('/telerad-pano', 'Telerad Panosu')], 2, kapsam);
    expect(b).toEqual([]);
  });

  it('portal tablosundaki ekranlar süzgeçten muaf', () => {
    // Mesajlaşma ve AI rehber kaynak tablosunda yok ama portal için bilerek
    //   seçilmiş ekranlar - kapsam listesi onları kapsamaz.
    const b = portalBolumleri([oge('/mesajlar', 'Mesajlar'), oge('/yapay-zeka', 'AI')],
                              2, kapsam);
    expect(b.flatMap(x => x.ogeler.map(o => o.ad)))
      .toEqual(['Yazışmalar', 'Yardım (AI rehber)']);
  });

  it('kapsam listesi gelmemişse eski davranış: hiçbir şey düşmez', () => {
    // Eski sunucuya bağlanan istemci menüsünü boşaltmasın.
    const b = portalBolumleri(menu, 2, undefined);
    expect(b.flatMap(x => x.ogeler).length).toBe(menu.length);
  });
});
