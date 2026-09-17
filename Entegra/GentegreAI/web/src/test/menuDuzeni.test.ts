import { describe, expect, it } from 'vitest';
import { LISTELER } from '../sayfalar/Liste';
import { BOLGE_HBYS, GRUP_SIRA_HBYS, CALISMA_ALANLARI, rolCalismaAlani } from '../sayfalar/kabuk/menuBolgeleri';

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
    // 20: Diş (706) modülü eklendi. 21: Medula (707).
    // 22: Ameliyathane (715) · 23: Acil (716). İkisi de kendi iş akışı ve
    //   kendi rolü olan modül (plan ilke 1) - Yönetim altına gömseydik günlük
    //   klinik akış ayarların içinde kalırdı.
    // 24: FTR (719) - fizik tedavi kendi is akisi (kür / seans / pano).
    // 27: Eczane (722) ve Satınalma (724) eklendi. Biyomedikal (723) YENİ GRUP
    //   AÇMADI - hastanedeki cihaz da bir demirbaş, ekranları mevcut Demirbaş
    //   grubuna girdi; ayrı grup aynı envanteri iki menü dalına bölerdi.
    // 28: İşyeri Hekimliği (741) - OSGB / hastane İSG birimi, kendi iş akışı.
    expect(GRUPLAR.length).toBeLessThanOrEqual(28);
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

  it('her HBYS grubunun bir bölgesi var (menü V2)', () => {
    // Bölgesiz grup son bölgeye (Yönetim) düşer ve orada kaybolur; yeni modül
    //   eklerken kabuk/menuBolgeleri.ts'e de yazılmalı. ERP'ye özgü gruplar
    //   (Satış/Alış/Üretim) bölge kullanmaz.
    const ERP_OZGU = ['Satış', 'Alış', 'Üretim'];
    for (const g of GRUPLAR.filter(g => !ERP_OZGU.includes(g)))
      expect(GRUP_SIRA_HBYS, `"${g}" grubu hiçbir bölgede değil`).toContain(g);
  });

  it('bölge sayısı ve bölge başına grup tavanı (7 · 4)', () => {
    // Bölge = hasta yolculuğunun bir adımı; dokuzuncu bölge "diğer" olur.
    //   Bir bölgede 4'ten çok grup accordion'un anlamını bozar (tek bölge
    //   açıkken bile ekran taşar).
    // 8: "Tedarik & Teknik" (722-724). Adı olan bir adım, artık bir torba
    //   değil: eczane - satınalma - depo - biyomedikal aynı zincir. Finans'ın
    //   ve Yönetim'in içine dağıtılsalardı günlük tedarik işi iki dala bölünürdü.
    expect(BOLGE_HBYS.length).toBeLessThanOrEqual(8);
    for (const b of BOLGE_HBYS)
      // 5: Klinikler bölgesine İşyeri Hekimliği (741) eklendi - beşinci klinik dal.
      expect(b.gruplar.length, `"${b.ad}" bölgesinde çok grup var`).toBeLessThanOrEqual(5);
    const tekrar = GRUP_SIRA_HBYS.filter((g, i) => GRUP_SIRA_HBYS.indexOf(g) !== i);
    expect(tekrar, 'grup iki bölgede birden').toEqual([]);
  });

  it('çalışma alanları var olan bölgelere işaret eder; standart roller bir alana düşer', () => {
    const bolgeAdlari = BOLGE_HBYS.map(b => b.ad);
    for (const a of CALISMA_ALANLARI)
      for (const b of a.bolgeler)
        expect(bolgeAdlari, `"${a.ad}" alanı olmayan "${b}" bölgesine işaret ediyor`).toContain(b);
    expect(CALISMA_ALANLARI[0].bolgeler, 'ilk alan Tümü olmalı (boş liste)').toEqual([]);
    // StandartRolUclari.cs adları: rol varsayılanı boşa düşmesin.
    const beklenen: [string, string][] = [
      ['Kayıt Kabul / Banko', 'banko'], ['Vezne', 'banko'], ['Yatış / Taburcu Ofisi', 'banko'],
      ['Hekim', 'hekim'], ['Diş Hekimi', 'hekim'], ['Göz Hekimi', 'hekim'], ['FTR Uzmanı', 'hekim'],
      ['Hemşire', 'hemsire'], ['Fizyoterapist', 'hemsire'], ['Diş Asistanı', 'hemsire'],
      ['Lab Teknisyeni', 'tani'], ['Radyolog', 'tani'], ['Numune Kabul', 'tani'],
      ['Muhasebe / Finans', 'muhasebe'], ['Medula Sorumlusu', 'muhasebe'],
      ['Yönetici', 'tumu'], ['Bilgi İşlem Sorumlusu', 'tumu'],
    ];
    for (const [rol, alan] of beklenen)
      expect(rolCalismaAlani(rol), `"${rol}" rolü`).toBe(alan);
    expect(rolCalismaAlani(undefined)).toBe('tumu');
  });
});
