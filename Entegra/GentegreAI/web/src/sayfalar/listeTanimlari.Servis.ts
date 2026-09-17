import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * TEKNİK SERVİS LİSTELERİ (773) — mockup `Ekranlar/TeknikServis/*.html`.
 *
 * ÜÇ KATMAN, ÜÇ LİSTE: çağrı (müşteri aradı, SLA işliyor) · iş emri (o
 * çağrıyı kapatacak iş) · ziyaret (bir gidiş). Tek listede toplamak "kaç
 * saatte yanıt verdik, kaç günde kapattık" sorularını ölçülemez yapardı.
 *
 * `urunModu` YOK: modül ERP'de de HBYS'de de çalışır. ERP'de müşterinin
 * cihazını onarıp para kazanır, HBYS'de kurumun cihazını onarıp maliyet
 * üretir - ekranlar aynı, değişen paranın kime yazıldığı.
 *
 * MODÜL KAPISI `servis`: teknik servisi olmayan kurumda menüde hiç görünmez.
 */
export const SERVIS_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'servis-cagri', rota: 'servis-cagri',
    baslik: 'Servis Çağrıları',
    yol: 'Teknik Servis › Çağrılar',
    kartYolu: '/servis-cagri', kartBaslik: 'Servis Çağrısı',
    aksiyonEkrani: 'servis-cagri-liste',
    tarihAlani: 'acilis',
    // İLK ÇİP AÇIK ÇAĞRILAR: listenin günlük iş kümesi bu. "SLA riski" ayrı
    //   çip çünkü gecikmiş iş ile taahhüdü dolmak üzere olan iş farklı
    //   aciliyetlerdir - biri özür, öteki koşturmaca gerektirir.
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'durum', op: 'kucuk', deger: 5 } },
      { ad: 'SLA riski',   filtre: { alan: 'slaKalanDk', op: 'kucuk', deger: 120 } },
      { ad: 'Atanmamış',   filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Parça bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Teknik Servis', menuAd: 'Çağrılar', ic: '📞',
    yetkiKodu: 'servis', modul: 'servis', menuSira: 10,
  },
  {
    kaynak: 'servis-is-emri', rota: 'servis-is-emri',
    baslik: 'Servis İş Emirleri',
    yol: 'Teknik Servis › İş Emirleri',
    // KART YOLU BİYOMEDİKALİN KARTI: aynı tabloyu yazar (773'te genişletildi),
    //   ikinci bir kart aynı satırın iki doğrulama kümesiyle düzenlenmesi olurdu.
    kartYolu: '/demirbas-is-emri', kartBaslik: 'Servis İş Emri',
    aksiyonEkrani: 'servis-is-emri-liste',
    tarihAlani: 'bildirimZamani',
    cipler: [
      { ad: 'Açık',     filtre: { alan: 'durum', op: 'kucuk', deger: 5 } },
      { ad: 'Dış iş',   filtre: { alan: 'sahiplik', op: 'esit', deger: 2 } },
      { ad: 'İç iş',    filtre: { alan: 'sahiplik', op: 'esit', deger: 1 } },
      // AÇIK EMANET: kapanmaya hazır görünen ama cihazı hâlâ dışarıda olan
      //   iş emirleri - teslim bunlarda reddedilir.
      { ad: 'Emanetli', filtre: { alan: 'acikEmanet', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Teknik Servis', menuAd: 'İş Emirleri', ic: '🔧',
    yetkiKodu: 'servis', modul: 'servis', menuSira: 20,
  },
  {
    kaynak: 'servis-ziyaret', rota: 'servis-ziyaret',
    baslik: 'Ziyaretler',
    yol: 'Teknik Servis › Ziyaretler',
    kartYolu: '/servis-ziyaret', kartBaslik: 'Servis Ziyareti',
    aksiyonEkrani: 'servis-ziyaret-liste',
    tarihAlani: 'varis',
    cipler: [
      { ad: 'Sürüyor',     filtre: { alan: 'sonuc', op: 'esit', deger: 0 } },
      { ad: 'Çözülemedi',  filtre: { alan: 'sonuc', op: 'esit', deger: 2 } },
      // İMZASIZ ZİYARET: kapanmış ama kanıtı olmayan iş - yerinde yapılanın
      //   tek kanıtı müşterinin onayıdır.
      { ad: 'İmzasız',     filtre: { alan: 'imzaAlindi', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Teknik Servis', menuAd: 'Ziyaretler', ic: '🚐',
    yetkiKodu: 'servis', modul: 'servis', menuSira: 30,
  },
  {
    kaynak: 'servis-emanet', rota: 'servis-emanet',
    baslik: 'Emanet Cihazlar',
    yol: 'Teknik Servis › Emanet Cihazlar',
    kartYolu: '/servis-emanet', kartBaslik: 'Emanet Cihaz',
    aksiyonEkrani: 'servis-emanet-liste',
    tarihAlani: 'veris',
    cipler: [
      { ad: 'Dışarıda', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Teknik Servis', menuAd: 'Emanet Cihazlar', ic: '🔄',
    yetkiKodu: 'servis', modul: 'servis', menuSira: 40,
  },
  {
    kaynak: 'taraf-cihaz', rota: 'taraf-cihaz',
    baslik: 'Müşteri Cihaz Parkı',
    yol: 'Teknik Servis › Cihaz Parkı',
    kartYolu: '/taraf-cihaz', kartBaslik: 'Müşteri Cihazı',
    aksiyonEkrani: 'taraf-cihaz-liste',
    cipler: [
      { ad: 'Kullanımda',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Garantisi bitmiş', filtre: { alan: 'garantiDurum', op: 'esit', deger: 2 } },
      // HİÇ ARIZALANMAMIŞ CİHAZ: yenileme ve sözleşme teklifi tam onlara gider;
      //   yalnız arıza geçmişine bakan bir liste onları görünmez yapardı.
      { ad: 'Hiç çağrı yok', filtre: { alan: 'cagriSayisi', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Teknik Servis', menuAd: 'Cihaz Parkı', ic: '📋',
    yetkiKodu: 'servis.cihaz', modul: 'servis', menuSira: 50,
  },
  {
    kaynak: 'servis-sozlesme', rota: 'servis-sozlesme',
    baslik: 'Servis Sözleşmeleri',
    yol: 'Teknik Servis › Sözleşmeler',
    kartYolu: '/servis-sozlesme', kartBaslik: 'Bakım Sözleşmesi',
    aksiyonEkrani: 'servis-sozlesme-liste',
    tarihAlani: 'bitis',
    cipler: [
      { ad: 'Yürürlükte', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Yenileme yakın', filtre: { alan: 'kalanGun', op: 'kucuk', deger: 60 } },
      // SLA AŞIMI: sözleşme cezasının ve yenileme görüşmesinin girdisi.
      { ad: 'SLA aşımı var', filtre: { alan: 'slaAsim', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Teknik Servis', menuAd: 'Sözleşmeler', ic: '📑',
    yetkiKodu: 'servis.sozlesme', modul: 'servis', menuSira: 60,
  },
];
