import { describe, expect, it } from 'vitest';
import { LISTELER } from '../sayfalar/Liste';
import { GRUP_SIRA_HBYS } from '../sayfalar/kabuk/menuGrupSirasi';
import { GRUP_IKON, GRUP_IKON_CEV } from '../sayfalar/kabuk/menuAgaci';

/**
 * MENÜ DÜZENİ (plan: dokuman/11_MENU_DUZENI_PLANI.md · mockup
 * Ekranlar/Ayarlar/menu_duzeni.html).
 *
 * Buradaki kurallar menünün SÖZÜDÜR: bozulursa kullanıcı aradığı ekranı
 * bulamaz, ama hiçbir test kırılmadığı için kimse fark etmez.
 */
const GRUPLAR = [...new Set(LISTELER.map(l => l.menuGrup).filter(Boolean))] as string[];

describe('menü düzeni', () => {
  it('her grubun KENDİ ikonu var (varsayılan klasöre düşmüyor)', () => {
    // 781: "Satınalma" ikon tablosunda yoktu ve menüde 📁 ile çiziliyordu -
    //   on beş grubun arasında hiçbir şey anlatmayan bir klasör. Yeni grup
    //   açan, ikonunu da yazsın: eksik ikon ekranda ancak o menü açılınca
    //   fark ediliyor.
    // 781'de dördü (Eczane · Demirbaş · Teknik Servis · Doküman) atandı;
    //   artık istisna yok - yeni grup açan ikonunu da yazar.
    const eksik = GRUPLAR.filter(g => !GRUP_IKON[g] && !GRUP_IKON_CEV[g]);
    expect(eksik, `İkonu olmayan menü grubu: ${eksik.join(', ')}`).toEqual([]);
  });

  it('kaldırılan gruplar geri gelmedi', () => {
    // Kasa+Banka = Finans · Cari+CRM = Cari & CRM · Roller Yönetim'de ·
    //   Mesajlar/AI üst çubukta.
    // DOKÜMAN LİSTEDE DEĞİL: Yönetim'in alt grubu yapılınca ana menüden
    //   kaybolmuştu, kullanıcı geri istedi (kendi grubu, Demirbaş'tan önce).
    // "İK" DE LİSTEDE DEĞİL (kullanıcı 07.10.2026: "İK & Prim rename İK her
    //   yerde"): grup adı yeniden "İK" oldu - eskiden kaldırılmış bir ad
    //   olması, bugün bilinçle seçilmiş olmasını engellemiyor.
    for (const eski of ['Kasa', 'Banka', 'CRM', 'Cari', 'İletişim & AI'])
      expect(GRUPLAR, `"${eski}" grubu menüden kalkmıştı`).not.toContain(eski);
  });

  it('grup sayısı tavanı aşmıyor (HBYS 14 · ERP 10 + ortak)', () => {
    // 19: Doküman kendi grubuna geri döndü (kullanıcı) + Göz (691) ve
    //   Yatan Hasta (695) modülleri eklendi.
    // 20: Diş (706) modülü eklendi. 21: Medula (707).
    // 22: Ameliyathane (715) · 23: Acil (716). İkisi de kendi iş akışı ve
    //   kendi rolü olan modül (plan ilke 1) - Yönetim altına gömseydik günlük
    //   klinik akış ayarların içinde kalırdı.
    // 24: FTR (719) - fizik tedavi kendi is akisi (kür / seans / pano).
    // 27: Eczane (722) ve Satınalma (724) eklendi. Biyomedikal (723) YENİ GRUP
    //   AÇMADI - hastanedeki cihaz da bir demirbaş, ekranları mevcut Demirbaş
    //   grubuna girdi; ayrı grup aynı envanteri iki menü dalına bölerdi.
    // 28: İşyeri Hekimliği (741) - OSGB / hastane İSG birimi, kendi iş akışı.
    // 29: Teknik Servis (773) - MÜŞTERİNİN cihazını onarır; Demirbaş kurumun
    //   kendi cihazını izler. İkisi aynı iş emri tablosunu paylaşır ama menüde
    //   ayrıdır: biyomedikal teknisyeni ile saha servisi aynı kişiler değil ve
    //   çağrı/SLA/sözleşme yalnız dış işte var. ERP kurulumunda da çıkar.
    // ÇAĞRI MERKEZİ (839) 14. HBYS grubu: hasta akışının ilk teması, randevunun önünde.
    // 33: Kalite · Güvenlik · Platform (10.10.2026, kullanıcı) Yönetim'in alt
    //   başlığıydı, Yönetim bölgesinde ayrı grup oldu.
    // 34: Onay grubu (10.10.2026, kullanıcı) - Yönetim'den ayrıldı.
    // 35: Formlar grubu (10.10.2026) - Yönetim › Formlar alt başlığıydı.
    // 36: Dökümler (tasarımcı) kendi grubu; Yönetim grubu Sistem adını aldı (10.10.2026).
    // 37: Kalite (1048, ISO / SKS kurumsal kalite) Doküman'dan sonra; eski Kalite = Klinik Kalite.
    // 38: Patoloji (1104) Tanı & Tetkik bölgesinde, Laboratuvar / Radyoloji yanında.
    expect(GRUPLAR.length).toBeLessThanOrEqual(38);
  });

  it('her grubun sonunda Dökümler var', () => {
    // Plan kural 2: günlük iş listeleri → tanımlar → Dökümler → Ayarlar.
    const dokumlu = new Set(LISTELER.filter(l => l.menuAd === 'Dökümler' && l.menuGrup)
                                    .map(l => l.menuGrup));
    // e-Nabız (kuyruk) ve Yönetim (tasarımcının kendisi) dışarıda.
    for (const g of GRUPLAR) {
      // Kalite / Güvenlik / Platform (10.10.2026): yönetim ayar grupları, Yönetim gibi.
      if (['e-Nabız', 'Yönetim', 'Sabit Varlıklar', 'Kalite', 'Klinik Kalite', 'Güvenlik', 'Platform', 'Onay', 'Formlar', 'Sistem', 'Dökümler'].includes(g)) continue;
      expect(dokumlu.has(g), `"${g}" grubunda Dökümler yok`).toBe(true);
    }
  });

  it('Dökümler öğeleri rota AÇMAZ, süzgeçli bağlantıdır', () => {
    // Hepsi tek /dokumler ekranına gider; ayrı rota açmak aynı ekranı on kez
    //   kaydetmek olurdu (App.tsx menuYol'lu tanımı rota listesine almaz).
    // Yönetim › Dökümler TASARIMCIDIR (süzgeçsiz, gerçek ekran); grup içi
    //   öğeler ona süzgeçle giden bağlantılardır (plan kural 4).
    for (const l of LISTELER.filter(x => x.menuAd === 'Dökümler' && x.menuGrup
                                      // Tasarımcı 10.10.2026'dan beri kendi grubunda (Dökümler, tek satır).
                                      && x.menuGrup !== 'Yönetim' && x.menuGrup !== 'Dökümler')) {
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

  it('her HBYS grubu menü sırasında var', () => {
    // Sırada olmayan grup menünün sonuna düşer; yeni modül eklerken kabuk/menuGrupSirasi.ts'e de
    //   yazılmalı. ERP'ye özgü gruplar (Satış/Alış/Üretim) kendi sırasını kullanır.
    const ERP_OZGU = ['Satış', 'Alış', 'Üretim'];
    for (const g of GRUPLAR.filter(g => !ERP_OZGU.includes(g)))
      expect(GRUP_SIRA_HBYS, `"${g}" grubu menü sırasında değil`).toContain(g);
  });

  it('menü sırasında grup tekrarı yok', () => {
    const tekrar = GRUP_SIRA_HBYS.filter((g, i) => GRUP_SIRA_HBYS.indexOf(g) !== i);
    expect(tekrar, 'grup sırada iki kez').toEqual([]);
  });
});
