import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * FORM MOTORU (740) — db/740, mockuplar `Ekranlar/Formlar/*.html`.
 * Menüde Yönetim › Formlar alt grubu: Şablonlar, Kütüphane (Bakanlık/SKS),
 * Doldurulan Formlar, Kurallar. Doldurma ekranı özel sayfa (/form-doldur/:id),
 * hasta formları hasta listesinden (📋 Formlar) ve /hasta-formlar/:hastaId.
 */
export const FORM_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'form-sablon', rota: 'form-sablon', aksiyonEkrani: 'form-sablon-liste', baslik: 'Form Şablonları',
    yol: 'Yönetim › Formlar › Şablonlar',
    kartYolu: '/form-sablon', kartBaslik: 'Form Şablonu',
    cipler: [
      { ad: 'Onam',           filtre: { alan: 'aile', op: 'esit', deger: 1 } },
      { ad: 'Değerlendirme',  filtre: { alan: 'aile', op: 'esit', deger: 2 } },
      { ad: 'Kontrol listesi', filtre: { alan: 'aile', op: 'esit', deger: 3 } },
      { ad: 'Beyan',          filtre: { alan: 'aile', op: 'esit', deger: 4 } },
      { ad: 'Anket',          filtre: { alan: 'aile', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'form',
    menuGrup: 'Yönetim', menuAltGrup: 'Formlar', menuAd: 'Form Şablonları', ic: '🗂', yetkiKodu: 'form.sablon', menuSira: 10,
  },
  {
    kaynak: 'form-kutuphane', ozelSayfa: true, baslik: 'Form Kütüphanesi', yol: 'Yönetim › Formlar › Kütüphane',
    urunModu: 2, modul: 'form',
    menuGrup: 'Yönetim', menuAltGrup: 'Formlar', menuAd: 'Kütüphane (Bakanlık / SKS)', ic: '📚', yetkiKodu: 'form.kutuphane', menuSira: 20,
  },
  {
    kaynak: 'form-istek', rota: 'form-istek', aksiyonEkrani: 'form-istek-liste', baslik: 'Doldurulan Formlar',
    yol: 'Yönetim › Formlar › Doldurulan Formlar',
    tarihAlani: 'eklemeTarihi',
    cipler: [
      { ad: 'Bekleyen',    filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3] } },
      { ad: 'Tamamlandı',  filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Süresi doldu / kilitli', filtre: { alan: 'durum', op: 'icinde', deger: [5, 6] } },
      { ad: 'Onam',        filtre: { alan: 'aile', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'form',
    menuGrup: 'Yönetim', menuAltGrup: 'Formlar', menuAd: 'Doldurulan Formlar', ic: '📋', yetkiKodu: 'form.istek', menuSira: 30,
  },
  {
    kaynak: 'form-kural', rota: 'form-kural', aksiyonEkrani: 'form-kural-liste', baslik: 'Form Kuralları (tetikleyiciler)',
    yol: 'Yönetim › Formlar › Kurallar',
    kartYolu: '/form-kural', kartBaslik: 'Form Kuralı',
    urunModu: 2, modul: 'form',
    menuGrup: 'Yönetim', menuAltGrup: 'Formlar', menuAd: 'Kurallar (tetikleyiciler)', ic: '⚡', yetkiKodu: 'form.kural', menuSira: 40,
  },
];
