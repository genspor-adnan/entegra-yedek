import { type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KADRO HAREKETLERİ (840) — personelin pozisyon geçmişi.
 *
 * Kullanıcı: *"personelin pozisyon değişikliklerini kronolojik olarak nasıl
 * takip ederiz"*. `taraf_personel` yalnız bugünkü hâli tutuyordu; işlem
 * günlüğü denetim iziydi (yürürlük tarihi yok, tam fotoğraf yok).
 *
 * Her satır o tarihteki TAM pozisyon. Kart kaydedilince `taraf_personel`
 * ondan türetilir (DB tetiği) - defter ve kart iki ayrı gerçek söylemesin.
 *
 * ONAY ZİNCİRİ YOK (kullanıcı kararı): hareket girildiği an geçerlidir.
 */
export const KADRO_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'personel-hareket', rota: 'personel-hareket',
    baslik: 'Kadro Hareketleri', yol: 'İK › Kadro Hareketleri',
    kartYolu: '/personel-hareket', kartBaslik: 'Kadro Hareketi',
    aksiyonEkrani: 'personel-hareket-liste',
    tarihAlani: 'yururluk',
    // İLK ÇİP "Geçerli": günlük soru "bu kişi şu an ne" - geçmişi görmek
    //   ikinci adımdır. "İleri tarihli" ayrı çip: yürürlüğe girmemiş terfi
    //   gözden kaçarsa personel yanlış kadroda görünmeye devam eder.
    cipler: [
      { ad: 'Geçerli',       filtre: { alan: 'gecerli', op: 'esit', deger: 1 } },
      { ad: 'İleri tarihli', filtre: { alan: 'ileri', op: 'esit', deger: 1 } },
      { ad: 'Terfi',         filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Şube nakli',    filtre: { alan: 'tur', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAd: 'Kadro Hareketleri', ic: '🪜',
    yetkiKodu: 'ik.kadro', modul: 'ik', menuSira: 12,
  },
];
