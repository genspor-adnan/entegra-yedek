import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — Kalite Panosu (db/1055) — mockup `Ekranlar/Kalite2/kalite_panosu.html`.
 * Özel sayfa (KysPano, /api/kys-pano): yedi sayı + bana düşenler. Menüde ilk satır.
 */
export const KYS_PANO_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-pano', rota: 'kys-pano', ozelSayfa: true, baslik: 'Kalite Panosu', yol: 'Kalite › Pano',
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Pano', ic: '🏆', yetkiKodu: 'kys.pano', menuSira: 10,
  },
];
