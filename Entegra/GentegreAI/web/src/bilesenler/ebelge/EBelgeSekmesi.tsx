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
 * grubu, `sekmeBasliklari` ile "Genel") · Seri Bilgileri · XSLT · e-Fatura · e-Arşiv Fatura · e-İrsaliye · e-SMM.
 *
 * TÜR SEKMELERİ MÜKELLEFİYETE BAĞLI (172): ek sekmenin `kosulAlani`'sı kartın mükellefiyet kutusu - GenForm
 * detay sekmeleriyle aynı kuralla çizer / gizler, kutu işaretlenince kaydetmeyi beklemeden belirir.
 */
export const EBELGE_EK_SEKMELERI = [
  { anahtar: 'ozel:ebelge-seri', baslik: 'Seri Bilgileri', ciz: () => <SeriKurallari /> },
  { anahtar: 'ozel:ebelge-xslt', baslik: 'XSLT',           ciz: () => <XsltSablonlari /> },
  ...EBELGE_TURLERI.map(t => ({ anahtar: `ozel:ebelge-${t.tur}`, baslik: t.baslik, kosulAlani: t.mukellefAlani,
                                 ciz: () => <TurAyarlari tur={t.tur} /> })),
];

export const EBELGE_SEKME_BASLIKLARI: Record<string, string> = { 'e-Belge': 'Genel' };

/** Genel sekmesi: kartın e-Belge alanları + altında şubelerin e-Belge durumu (Satış Belgeleri › e-Belge'den taşındı). */
export const ebelgeSekmeSarmalayici = (tazele: number) =>
  (sekmeBasligi: string, icerik: React.ReactNode) =>
    sekmeBasligi === 'Genel' ? <>{icerik}<MukellefOzeti tazele={tazele} /></> : icerik;
