import { useState } from 'react';
import { MukellefIzle } from './MukellefIzle';
import { MukellefOzeti } from './MukellefOzeti';
import { EBELGE_TURLERI } from './ebelgeTurleri';
import { SeriKurallari } from './SeriKurallari';
import { XsltSablonlari } from './XsltSablonlari';
import { TurAyarlari } from './TurAyarlari';

/**
 * e-BELGE AYAR SEKMELERİ (Fatura Ayarları, 1270).
 *
 * Kullanıcı 05.11.2026: "genel, seri bilgileri vb butonları sekme haline getir" - eskiden şube kartının e-Belge
 * sekmesi içinde buton görünümlü alt bölümlerdi; şimdi GenForm'un KENDİ sekmeleri: Genel (kartın e-Belge alan
 * grubu, başlığı "Genel" olarak yeniden adlandırılır) · Seri Bilgileri · XSLT · e-Fatura · e-Arşiv Fatura ·
 * e-İrsaliye · e-SMM (ekSekmeler).
 *
 * TÜR SEKMELERİ MÜKELLEFİYETE BAĞLI (172): kutusu işaretli değilse sekme çizilmez - mükellefi olmadığımız türün
 * servis adresini doldurmak işe yaramıyor. Bayrak kartın GÜNCEL değerinden okunur (MukellefIzle, Genel sekmesi
 * çizilirken): kutu işaretlenince sekme kaydetmeyi beklemeden belirir.
 */

/** GenForm için `ekSekmeler` + `sekmeSarmalayici` + `sekmeBasliklari` üretir. */
/** @param tazele kart kaydedilince artar; Genel altındaki şube özeti yeniden okunur. */
export function useEBelgeSekmeleri(tazele = 0) {
  const [imza, setImza] = useState('0000');
  const ekSekmeler = [
    { anahtar: 'ozel:ebelge-seri', baslik: 'Seri Bilgileri', ciz: () => <SeriKurallari /> },
    { anahtar: 'ozel:ebelge-xslt', baslik: 'XSLT',           ciz: () => <XsltSablonlari /> },
    ...EBELGE_TURLERI.filter((_, i) => imza[i] === '1')
             .map(t => ({ anahtar: `ozel:ebelge-${t.tur}`, baslik: t.baslik, ciz: () => <TurAyarlari tur={t.tur} /> })),
  ];
  const sekmeSarmalayici = (sekmeBasligi: string, icerik: React.ReactNode, deger: Record<string, unknown>) =>
    (sekmeBasligi === 'e-Belge' || sekmeBasligi === 'Genel')
      // Genel: kartın e-Belge alanları + altında şubelerin e-Belge durumu (Satış Belgeleri › e-Belge'den taşındı).
      ? <><MukellefIzle deger={deger} onDegis={setImza} />{icerik}<MukellefOzeti tazele={tazele} /></>
      : icerik;
  return { ekSekmeler, sekmeSarmalayici, sekmeBasliklari: { 'e-Belge': 'Genel' } as Record<string, string> };
}
