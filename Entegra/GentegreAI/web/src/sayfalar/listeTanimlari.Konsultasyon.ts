import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KONSÜLTASYON (1107) - mockup Ekranlar/Muayene/konsultasyon_listesi.html ·
 * konsultasyon_karti.html. Muayene grubunda; sekmeler (bana / bölümüme gelen ·
 * istediklerim · bölüm geneli), özet kutuları ve ön izleme Liste'de
 * (KonsultasyonPanelleri). Terim "yanıtla"dır - "üstlen" yok (kullanıcı).
 */
export const KONSULTASYON_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'konsultasyon', rota: 'konsultasyon', baslik: 'Konsültasyon Listesi',
    yol: 'Muayene › Konsültasyon Listesi',
    kartYolu: '/konsultasyon', kartBaslik: 'Konsültasyon', yeniSekmede: 'Yeni Konsültasyon Kartı',
    aksiyonEkrani: 'konsultasyon-liste',
    cipler: [
      { ad: 'Açık', filtre: { alan: 'durum', op: 'icinde', deger: [1, 2] } },
      { ad: 'Çok acil', filtre: { op: 'and', kosullar: [{ alan: 'aciliyet', op: 'esit', deger: 3 }, { alan: 'acik', op: 'esit', deger: 1 }] } },
      { ad: 'Acil', filtre: { op: 'and', kosullar: [{ alan: 'aciliyet', op: 'esit', deger: 2 }, { alan: 'acik', op: 'esit', deger: 1 }] } },
      { ad: 'Rutin', filtre: { op: 'and', kosullar: [{ alan: 'aciliyet', op: 'esit', deger: 1 }, { alan: 'acik', op: 'esit', deger: 1 }] } },
      { ad: 'Yanıtlandı', filtre: { alan: 'durum', op: 'icinde', deger: [3, 4] } },
      { ad: 'İptal / ret', filtre: { alan: 'durum', op: 'icinde', deger: [9, 0] } },
      { ad: 'Taslak', filtre: { alan: 'durum', op: 'esit', deger: 6 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 25, menuGrup: 'Muayene', menuAd: 'Konsültasyon Listesi', ic: '🧑‍⚕️', yetkiKodu: 'muayene.konsultasyon',
  },
];
