// @vitest-environment jsdom
import { describe, it, expect } from 'vitest';
import { menuSatirlariKur } from '../sayfalar/kabuk/menuAgaci';
import { LISTELER } from '../sayfalar/listeTanimlari';

/**
 * YETKİ KODU EKRAN KÜMESİNİ AŞMAMALI (998, kullanıcı 09.10.2026: "hasan aydın
 * banko görevlisi olarak login oldum ama yetki dışında menü geldi" ... "yetki
 * matrisinde neler varsa onlar menüde görünmeli").
 *
 * Tek `belge` yetkisi 21 ekran açıyordu: Kayıt Kabul'ün ihtiyacı olan
 * "Başvurular" ile birlikte Satış Faturaları, Alış Siparişleri ve Stok
 * Transfer de geliyordu. Yetkiyi rolden kaldırmak işi bozardı (başvuru
 * açılamaz), bu yüzden kod ekran bazında bölündü:
 * `belge.satis` / `belge.alis` / `belge.stok`, `hesap.tanim`, `kasa.finans`,
 * `sigorta.tanim`.
 *
 * Test, menüyü GERÇEK kurucuyla hesaplıyor; yetki seti Banko Görevlisi
 * rolünün dev veritabanındaki hâli. Bir ekranın yetki kodu yeniden
 * genişletilirse (ör. yeni bir satış ekranına `belge` yazılırsa) bu test
 * düşer - menü sızıntısı sessizce geri gelmesin.
 */

/** Banko Görevlisi (kayit_kabul) rolünün gör yetkileri - 998 sonrası. */
const BANKO_YETKILERI = new Set([
  'sigorta', 'sigorta.iptal', 'sigorta.provizyon',
  'ai', 'ai.rehber', 'mesaj',
  'banko', 'banko_oturum', 'hesap', 'kasa_islem', 'kasa.makbuz-yazdir',
  'basvuru.iskonto', 'belge', 'hasta', 'iskonto_onay',
  'randevu', 'randevu.plan',
  'belge_satir', 'taraf',
]);

/** Bankoda ÇIKMAMASI gereken gruplar: ERP ticari/mali ekran kümeleri. */
const YASAK_GRUPLAR = ['Satış', 'Alış', 'Stok & Hizmet', 'Finans', 'Cari & CRM',
                       'Kurumlar & Sigorta'];

function gruplar(izin: Set<string>, urunModu: number) {
  return menuSatirlariKur(LISTELER, k => izin.has(k), urunModu, undefined)
    .filter(s => s.tur === 'grup')
    .map(s => (s as { ad: string }).ad);
}

describe('menü yetki kapsamı', () => {
  it('Banko Görevlisi ERP ticari gruplarını GÖRMEZ', () => {
    const g = gruplar(BANKO_YETKILERI, 2);
    for (const yasak of YASAK_GRUPLAR) expect(g).not.toContain(yasak);
  });

  it('Banko Görevlisi kendi işini YAPABİLİR (Kayıt Kabul + Randevu durur)', () => {
    const g = gruplar(BANKO_YETKILERI, 2);
    expect(g).toContain('Kayıt Kabul');
    expect(g).toContain('Randevu');
    // Başvurular `belge` çekirdek yetkisiyle gelir - bölme onu götürmedi.
    const satirlar = menuSatirlariKur(LISTELER, k => BANKO_YETKILERI.has(k), 2, undefined);
    const adlar = satirlar.flatMap(s => s.tur === 'grup' ? s.alt.map(m => m.ad) : [s.m.ad]);
    expect(adlar).toContain('Başvurular');
    expect(adlar).toContain('Bankolar');
  });

  it('ERP ticari yetkileri verilince o gruplar GERİ gelir', () => {
    // Bölmenin ERP tarafını kırmadığının kanıtı: muhasebe/yönetici rolleri
    //   yeni kodları aldı (998 dağıtımı) ve menüleri aynı kalmalı.
    const erp = new Set([...BANKO_YETKILERI, 'belge.satis', 'belge.alis',
                         'belge.stok', 'hesap.tanim', 'kasa.finans', 'sigorta.tanim']);
    const g = gruplar(erp, 1);
    expect(g).toContain('Satış');
    expect(g).toContain('Alış');
    expect(g).toContain('Finans');
  });
});
