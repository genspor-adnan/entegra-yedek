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
const YASAK_GRUPLAR = ['Satış', 'Alış', 'Stok & Hizmet', 'Cari & CRM',
                       'Kurumlar & Sigorta'];

/**
 * FİNANS İSTİSNASI (kullanıcı 09.10.2026: "sadece Bankolar menüsünü de eski
 * yeri olan Finans altına al.. oturum ve onay burada kalsın"). Banko TANIMI
 * kasa/POS kurulumudur, Finans'ta durur; banko görevlisi onu `banko`
 * yetkisiyle görür. Grubun geri kalanı (kasa işlem listeleri, hesap
 * tanımları) `kasa.finans` / `hesap.tanim` ister - bankoda yok.
 */
const FINANS_BANKODA = ['Bankolar'];

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

  it('Finans grubu bankoda YALNIZ Banko tanımını gösterir', () => {
    const satirlar = menuSatirlariKur(LISTELER, k => BANKO_YETKILERI.has(k), 2, undefined);
    const finans = satirlar.find(s => s.tur === 'grup' && s.ad === 'Finans');
    // Grup ya hiç çıkmaz ya da yalnız izinli ekranı taşır; "Kasa İşlemleri"
    //   ya da "POS" sızarsa yetki bölmesi geri gelmiş olur.
    if (finans && finans.tur === 'grup')
      expect(finans.alt.map(m => m.ad).sort()).toEqual(FINANS_BANKODA);
  });

  it('Banko Görevlisi kendi işini YAPABİLİR (Kayıt Kabul + Randevu durur)', () => {
    const g = gruplar(BANKO_YETKILERI, 2);
    expect(g).toContain('Kayıt Kabul');
    expect(g).toContain('Randevu');
    // Başvurular `belge` çekirdek yetkisiyle gelir - bölme onu götürmedi.
    const satirlar = menuSatirlariKur(LISTELER, k => BANKO_YETKILERI.has(k), 2, undefined);
    const adlar = satirlar.flatMap(s => s.tur === 'grup' ? s.alt.map(m => m.ad) : [s.m.ad]);
    expect(adlar).toContain('Başvurular');
    expect(adlar).toContain('Banko Oturumları');
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
