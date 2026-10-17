import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — DÖF (db/1050, sade) — mockup `Ekranlar/Kalite/kalite_dof.html`.
 *
 * Tek liste + generic kart (KartKatalogu "kys-dof": kaynak, birim, sorumlu,
 * termin, tanım, kök neden, doğrulama, durum; altında Faaliyetler tablosu).
 * Kaynak ekranlarındaki "DÖF Aç" `/kys-dof/yeni?kaynakTur&kaynakId&kaynakNo&
 * birimId&tanim` ile kartı dolu açar (ListeKarti).
 */
export const KYS_DOF_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-dof', rota: 'kys-dof', aksiyonEkrani: 'kys-dof-liste', baslik: 'DÖF — Düzeltici / Önleyici Faaliyet Listesi',
    yol: 'Kalite › DÖF',
    kartYolu: '/kys-dof', kartBaslik: 'DÖF',
    // Kaynak kaydın kimliği: "DÖF Aç" doldurur, kullanıcı görmez (kaynak no görünür).
    gizliKartAlanlari: ['kaynakId'],
    tarihAlani: 'acilis',
    cipler: [
      { ad: 'Açık',         filtre: { alan: 'acik', op: 'esit', deger: 1 } },
      { ad: 'Vadesi geçen', filtre: { alan: 'vadesiGecti', op: 'esit', deger: 1 } },
      { ad: 'Kapalı',       filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'DÖF', ic: '🛠️', yetkiKodu: 'kys.dof.liste', menuSira: 30,
  },
];
