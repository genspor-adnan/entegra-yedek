import { MuayeneSablonListesi } from '../bilesenler/sablon/MuayeneSablonListesi';

/**
 * MUAYENE ŞABLONLARI & HEKİM TERCİHLERİ — BÖLÜM ve DOKTORA göre şablon listesi
 * (mockup Ekranlar/Muayene/muayene_sablon_listesi · muayene_sablon_karti).
 *
 * Sık tanılar, reçete şablonları, istem panelleri, metin makroları ve kurallar
 * eskiden bu sayfanın ayrı sekmeleriydi ve bölüm/doktor bilgisi taşımıyordu
 * (kullanıcı: "branş/doktora özel.. kartın içine al"). 931'den beri ŞABLON
 * KARTININ sekmeleri: kapsamları şablonun bölüm/doktoru, "Kopyala (bana)"
 * hepsini çoğaltır, düzenleme yetkisi şablonunki.
 *
 * Ağaçlı liste KALIR (kullanıcı, 933 standart liste denemesinden sonra:
 * "eski haline getir"); yalnız üstteki başlık, arama ve düğmeler standart
 * liste görünümündedir.
 */
export function MuayeneSablonlari() {
  return <MuayeneSablonListesi />;
}
