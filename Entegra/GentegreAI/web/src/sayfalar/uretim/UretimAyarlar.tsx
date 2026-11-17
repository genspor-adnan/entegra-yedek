import { UretimSeviyeAyari, useUretimSeviyeAyari } from './UretimSeviyeAyari';
import { AyarSayfaBasligi } from '../../bilesenler/AyarSayfaBasligi';

/**
 * ÜRETİM AYARLARI (1262, Üretim › Ayarlar › Üretim Ayarları) - kasa / stok / demirbaş ayarlarıyla aynı desen
 * (modülün ayarı kendi menü grubunda, kendi ekran kodu `uretim.ayar`).
 *
 * Kullanıcı 04.11.2026: "Genel Ayarlar altındaki Üretim sekmesini Üretim modülünde ayarlar altına 'Üretim Ayarları'
 * olarak taşı". İçerik 1253'teki seviye ayarı (UretimSeviyeAyari): Basit · Standart · Denetimli + "Üretim emri kullan".
 */
export function UretimAyarlar() {
  // AYAR SAYFASI DESENİ (17.11.2026): seçim taslak; "Kaydet & Uygula" yazar, Kapat değişiklikte sorar.
  const a = useUretimSeviyeAyari();
  return (
    <>
      <AyarSayfaBasligi baslik="Üretim Ayarları" yol="Üretim › Ayarlar › Üretim Ayarları" ayar={a} />
      <div className="sahne">
        <UretimSeviyeAyari a={a} />
      </div>
    </>
  );
}

export default UretimAyarlar;
