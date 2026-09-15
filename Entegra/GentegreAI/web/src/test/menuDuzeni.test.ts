import { describe, expect, it } from 'vitest';
import { LISTELER } from '../sayfalar/Liste';

/**
 * MENÜ DÜZENİ (plan: dokuman/11_MENU_DUZENI_PLANI.md · mockup
 * Ekranlar/Ayarlar/menu_duzeni.html).
 *
 * Buradaki kurallar menünün SÖZÜDÜR: bozulursa kullanıcı aradığı ekranı
 * bulamaz, ama hiçbir test kırılmadığı için kimse fark etmez.
 */
const GRUPLAR = [...new Set(LISTELER.map(l => l.menuGrup).filter(Boolean))] as string[];

describe('menü düzeni', () => {
  it('kaldırılan gruplar geri gelmedi', () => {
    // Kasa+Banka = Finans · Cari+CRM = Cari & CRM · Roller Yönetim'de ·
    //   Mesajlar/AI üst çubukta.
    // DOKÜMAN LİSTEDE DEĞİL: Yönetim'in alt grubu yapılınca ana menüden
    //   kaybolmuştu, kullanıcı geri istedi (kendi grubu, Demirbaş'tan önce).
    for (const eski of ['Kasa', 'Banka', 'CRM', 'Cari', 'İK', 'İletişim & AI'])
      expect(GRUPLAR, `"${eski}" grubu menüden kalkmıştı`).not.toContain(eski);
  });

  it('grup sayısı tavanı aşmıyor (HBYS 13 · ERP 10 + ortak)', () => {
    // 19: Doküman kendi grubuna geri döndü (kullanıcı) + Göz (691) ve
    //   Yatan Hasta (695) modülleri eklendi.
    expect(GRUPLAR.length).toBeLessThanOrEqual(19);
  });

  it('her grubun sonunda Dökümler var', () => {
    // Plan kural 2: günlük iş listeleri → tanımlar → Dökümler → Ayarlar.
    const dokumlu = new Set(LISTELER.filter(l => l.menuAd === 'Dökümler' && l.menuGrup)
                                    .map(l => l.menuGrup));
    // e-Nabız (kuyruk) ve Yönetim (tasarımcının kendisi) dışarıda.
    for (const g of GRUPLAR) {
      if (g === 'e-Nabız' || g === 'Yönetim' || g === 'Demirbaş') continue;
      expect(dokumlu.has(g), `"${g}" grubunda Dökümler yok`).toBe(true);
    }
  });

  it('Dökümler öğeleri rota AÇMAZ, süzgeçli bağlantıdır', () => {
    // Hepsi tek /dokumler ekranına gider; ayrı rota açmak aynı ekranı on kez
    //   kaydetmek olurdu (App.tsx menuYol'lu tanımı rota listesine almaz).
    // Yönetim › Dökümler TASARIMCIDIR (süzgeçsiz, gerçek ekran); grup içi
    //   öğeler ona süzgeçle giden bağlantılardır (plan kural 4).
    for (const l of LISTELER.filter(x => x.menuAd === 'Dökümler' && x.menuGrup
                                      && x.menuGrup !== 'Yönetim')) {
      expect(l.menuYol, `${l.menuGrup} › Dökümler bağlantısız`).toBeTruthy();
      expect(l.menuYol).toContain('/dokumler?grup=');
    }
  });

  it('kayıt-bağımlı listeler menüde değil', () => {
    // "Hangi hasta?" / "hangi fiş?" sorusu cevapsız kalan ekranlar kartın
    //   sekmesidir; rota kalır, menüde durmaz.
    const gizliOlmali = ['Tıbbi Özet', 'Kronik Tanılar', 'Geçmiş Olaylar', 'Alerjiler',
                         'Kullanılan İlaçlar', 'Fiş Satırları', 'Hakediş Satırları',
                         'Kasa Hareketleri', 'Fiyat Listesi Satırları'];
    for (const ad of gizliOlmali) {
      const l = LISTELER.find(x => x.menuAd === ad);
      if (!l) continue;
      expect(l.menuGizli || !l.menuGrup, `"${ad}" hâlâ menüde`).toBeTruthy();
    }
  });

  it('araçlar menüde değil (üst çubukta)', () => {
    for (const ad of ['Mesajlar', 'Yapay Zeka']) {
      const l = LISTELER.find(x => x.menuAd === ad);
      expect(l?.menuGizli || !l?.menuGrup, `"${ad}" menüde durmamalı`).toBeTruthy();
    }
  });
});
