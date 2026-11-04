import { UretimSeviyeAyari } from './UretimSeviyeAyari';
import { c } from '../../dil/ceviri';

/**
 * ÜRETİM AYARLARI (1262, Üretim › Ayarlar › Üretim Ayarları) - kasa / stok / demirbaş ayarlarıyla aynı desen
 * (modülün ayarı kendi menü grubunda, kendi ekran kodu `uretim.ayar`).
 *
 * Kullanıcı 04.11.2026: "Genel Ayarlar altındaki Üretim sekmesini Üretim modülünde ayarlar altına 'Üretim Ayarları'
 * olarak taşı". İçerik 1253'teki seviye ayarı (UretimSeviyeAyari): Basit · Standart · Denetimli + "Üretim emri kullan".
 */
export function UretimAyarlar() {
  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{c('Üretim Ayarları')}</h1>
          <span className="yol">{c('Üretim › Ayarlar › Üretim Ayarları')}</span>
        </div>
      </div>
      <div className="sahne">
        <UretimSeviyeAyari />
      </div>
    </>
  );
}

export default UretimAyarlar;
