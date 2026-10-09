import { describe, it, expect } from 'vitest';
import { LISTELER } from '../sayfalar/listeTanimlari';

/**
 * MENÜ KODU = YETKİ KODU (1003/1004 — kullanıcı 09.10.2026: "genprofil ile
 * seçtiğim menüler yetki matrisinde görünecek.. yetki matrisinde gör=True
 * dediğim menüler de kullanıcı menüsünde görünecek", "menü koduyla yetki
 * matrisi kodları aynı olmalı").
 *
 * Bir yetki kodu birden çok menü ekranını açarsa matristeki tek kutu menüde
 * birden çok satırı açıp kapatır - prensip bozulur. Yeni ekran eklerken ya
 * kendi kodunu verin ya da (gerçekten aynı ekransa) aşağıdaki istisnaya
 * gerekçesiyle ekleyin.
 */
const ISTISNA: Record<string, string> = {
  // Portal menüsü (dış kurum): portal rolleri ayrı yönetilir, matriste yok.
  'portal.mali': 'portal',
};

describe('menü kodu tek ekran', () => {
  it('her yetki kodu en çok bir menü ekranı açar', () => {
    const say = new Map<string, string[]>();
    for (const l of LISTELER) {
      if (!l.yetkiKodu || !l.menuAd || l.menuGizli) continue;
      const a = say.get(l.yetkiKodu) ?? [];
      a.push(`${l.menuGrup ?? ''} › ${l.menuAd}`);
      say.set(l.yetkiKodu, a);
    }
    const coklu = [...say].filter(([k, v]) => v.length > 1 && !ISTISNA[k])
                          .map(([k, v]) => `${k}: ${v.join(' | ')}`);
    expect(coklu).toEqual([]);
  });
});
