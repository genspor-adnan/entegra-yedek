import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — EĞİTİM & YETKİNLİK (db/1056, sade) — mockup
 * `Ekranlar/Kalite2/egitim.html` (ISO 9001 7.2).
 *
 * Sekme cipleri SONDA: ilk cip (indeks 0) açılışta seçili süzgeçtir.
 * Tek menü girdisi (kys.egitim); "Eksik Zorunlu Eğitim" ve "Zorunlu
 * Eğitimler" aynı ekranın SEKMELERİ (rotalı cip, menuGizli) - bir yetki
 * kodu tek menü ekranı açar (menuKoduTekEkran testi).
 * Eğitim kartı özel (KysEgitimKarti): katılımcılar tek seferde seçilir,
 * satırlar personel kartının Eğitim / Sertifika sekmesine de düşer.
 */
const SEKMELER = [
  { ad: '🎓 Eğitimler',             rota: 'kys-egitim',         sekme: true },
  { ad: '⚠ Eksik Zorunlu Eğitim',   rota: 'kys-egitim-eksik',   sekme: true },
  { ad: '📋 Zorunlu Eğitimler',     rota: 'kys-zorunlu-egitim', sekme: true },
];

export const KYS_EGITIM_LISTELERI: ListeGirdisi[] = [
  // MENÜ GİRİŞİ (1065, mockup Kalite2/egitim.html): Eğitimler + Eksik Zorunlu Eğitim
  //   sekmeli özel sayfa (KysEgitimler). Aşağıdaki generic listeler menüde
  //   görünmez; zorunlu tanımlar sayfadaki bağlantıyla açılır.
  {
    kaynak: 'kys-egitimler', rota: 'kys-egitimler', ozelSayfa: true, baslik: 'Eğitim & Yetkinlik Kaydı Listesi',
    yol: 'Kalite › Eğitim',
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Eğitim', ic: '🎓', yetkiKodu: 'kys.egitim.liste', menuSira: 80,
  },
  {
    kaynak: 'kys-egitim', rota: 'kys-egitim', aksiyonEkrani: 'kys-egitim-liste', baslik: 'Eğitim & Yetkinlik Kaydı Listesi',
    yol: 'Kalite › Eğitim',
    kartYolu: '/kys-egitim', kartBaslik: 'Eğitim Kaydı', ozelKart: true,
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Zorunlu', filtre: { alan: 'zorunlu', op: 'esit', deger: 1 } },
      ...SEKMELER,
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Eğitim Listesi', menuGizli: true, ic: '🎓', yetkiKodu: 'kys.egitim.liste', menuSira: 81,
  },
  {
    kaynak: 'kys-egitim-eksik', rota: 'kys-egitim-eksik', baslik: 'Eksik Zorunlu Eğitim',
    yol: 'Kalite › Eğitim › Eksik Zorunlu',
    menuAd: 'Eksik Zorunlu Eğitim', ic: '⚠',
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Hiç almadı',   filtre: { alan: 'durumAdi', op: 'esit', deger: 'Hiç almadı' } },
      { ad: 'Süresi geçti', filtre: { alan: 'durumAdi', op: 'esit', deger: 'Süresi geçti' } },
      { ad: 'Yaklaşıyor',   filtre: { alan: 'durumAdi', op: 'esit', deger: 'Yaklaşıyor' } },
      ...SEKMELER,
    ],
    modul: 'kys', menuGrup: 'Kalite', menuGizli: true, yetkiKodu: 'kys.egitim.liste',
  },
  {
    kaynak: 'kys-zorunlu-egitim', rota: 'kys-zorunlu-egitim', aksiyonEkrani: 'kys-zorunlu-egitim-liste', baslik: 'Zorunlu Eğitim Listesi',
    yol: 'Kalite › Eğitim › Zorunlu Eğitim Listesi',
    menuAd: 'Zorunlu Eğitim Listesi', ic: '📋',
    kartYolu: '/kys-zorunlu-egitim', kartBaslik: 'Zorunlu Eğitim',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
      ...SEKMELER,
    ],
    modul: 'kys', menuGrup: 'Kalite', menuGizli: true, yetkiKodu: 'kys.egitim.liste',
  },
];
