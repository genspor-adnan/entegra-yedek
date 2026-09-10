import type { ComponentProps } from 'react';
import type { GenForm } from '../../bilesenler/GenForm';

/**
 * KARTA ÖZEL YERLEŞİM - kaynak adına göre, tek yerde.
 *
 * `Liste.tsx` her kartın kendi düzenini JSX'in içinde `tanim.kaynak === '...'`
 * üçlü koşullarıyla taşıyordu: muayene kartının sekme sırası, kurumun gömülü
 * adres gridi, vital bulguların ızgarası... Yüz satırlık saf yapılandırma,
 * bileşenin ortasında, her biri ayrı bir prop'un içinde.
 *
 * İki derdi vardı. Bir kartın düzenini görmek için dosyanın altı ayrı yerine
 * bakmak gerekiyordu; ve yeni bir kart özelleştirmek, 2500 satırlık bileşeni
 * yeniden düzenlemek demekti. Burası VERİ: hangi kartın hangi sekmesi nerede
 * durur. Davranış değil - JSX üreten prop'lar (`sekmeSarmalayici`, `ekAraclar`,
 * `ekSekmeler`) bileşenin bağlamına muhtaç olduğu için orada kaldı.
 */
type GenFormProps = ComponentProps<typeof GenForm>;

export interface KartOzellestirme {
  /** Sekme sırası (başlıklara göre) - mockup sırası. */
  sekmeSirasi?: GenFormProps['sekmeSirasi'];
  /** Sekmesi açılmayacak detaylar (ekranda başka yerde çiziliyorsa). */
  gizliDetaylar?: GenFormProps['gizliDetaylar'];
  /** Bir GRUP sekmesinin içine gömülen detaylar. */
  detayGrupta?: GenFormProps['detayGrupta'];
  /** Detayı grid yerine etiket + kutu ızgarası olarak çizer. */
  detayIzgara?: GenFormProps['detayIzgara'];
  /** Kendi sekmesinde çizilen detaya ekran-özel seçenekler. */
  detaySecenekleri?: GenFormProps['detaySecenekleri'];
  /** Kimlik şeridinde çizilecek alanlar. */
  seritAlanlari?: GenFormProps['seritAlanlari'];
}

export const KART_OZELLESTIRME: Record<string, KartOzellestirme> = {
  // ------------------------------------------------------------- kurum ----
  kurum: {
    // GENEL ÖNCE (484, kullanıcı: "genel ve adres sekmelerini yer değiştir").
    //   Sekme sırası normalde ALAN SIRASINDAN çıkar; kurumda Genel grubunun
    //   ilk alanları (ad/soyad/kişi rol kutuları) gizlenince grup sırası kayıp
    //   Adres öne geçmişti. Sıra artık açıkça yazılı - ekran düzeni gizlenen
    //   bir alana bağlı kalmasın.
    sekmeSirasi: ['Genel', 'Adres / Fatura Bilgisi', 'Sözleşmeler'],
    // KURUM TÜRÜ AYRI SEKME DEĞİL (484): tek alanlık 1:1 uzantı Genel
    //   sekmesindeki kimlik şeridinde çiziliyor - aynı alanı iki yerde
    //   göstermek hangisinin geçerli olduğunu belirsiz bırakırdı.
    gizliDetaylar: ['kurumRolu'],
    // ADRES AYRI SEKME DEĞİL (484, kullanıcı: "adresler sekmesindeki adres
    //   gridini adres / fatura bilgisi sekmesinde alta al"): fatura ünvanı,
    //   VKN ve adres aynı sorunun parçaları - biri ötekini doğrularken sekme
    //   değiştirmek gerekiyordu. Grid olduğu gibi kalır, yalnız yeri değişir.
    detayGrupta: { adresler: { grup: 'Adres / Fatura Bilgisi' } },
  },

  // ------------------------------------------------------- lab-tetkik ----
  // MIKROBIYOLOJI KATALOG KARTLARI - mockup sirasi
  //   (Ekranlar/Lab/besiyeri_karti.html · organizma_karti.html ·
  //    antibiyotik_karti.html). Sekme sirasi normalde ALAN SIRASINDAN cikiyor;
  //   ust serit mockup'a gore yeniden duzenlenince (kimlik grubu) kalan
  //   gruplarin sirasi mockup'takinden ayrildi - sira artik acikca yazili.
  //   "Tanım" HER UCUNDE ILK SEKME (mockup): kart acilinca once kartin ne
  //   soyledigi okunur, detay gridleri sonra gelir.
  'lab-besiyeri': {
    sekmeSirasi: ['Tanım', 'Numune Tipleri', 'Kalite Kontrol'],
  },
  'lab-organizma': {
    // Mockup: Tanim - Doğal Direnç - Antibiyogram Paneli - Kodlar & Bildirim.
    //   Kodlar EN SONDA: kart acilinca once "bu organizma nasil raporlanir"
    //   sorusu cevaplanmali, bildirim kodu sonra.
    sekmeSirasi: ['Tanım', 'Doğal Direnç', 'Antibiyogram Paneli',
                  'Kodlar & Bildirim'],
  },
  // Mockup: Tanım · Kademeli Bildirim · Sınır Değerler · Kullanıldığı
  //   Paneller · Kodlar. "Sınır Değerler" (EUCAST breakpoint) tablosu henuz
  //   veri modelinde YOK - o sekme acilmiyor; kalan dordu mockup sirasinda.
  'lab-antibiyotik': {
    sekmeSirasi: ['Tanım', 'Kademeli Bildirim', 'Kullanıldığı Paneller',
                  'Doğal Direnç'],
    // TERS ILISKI GRIDLERI SALT GORUNUM (mockup: duz metin tablo). Satirin
    //   sahibi ORGANIZMA karti; burada satir ici kutu gostermek, buradan da
    //   yazilabilirmis izlenimi veriyordu.
    detaySecenekleri: {
      paneller: { gridKipi: true },
      direnc:   { gridKipi: true },
    },
  },

  'lab-tetkik': {
    // MOCKUP SIRASI (Ekranlar/Lab/lab_tetkik_karti.html): once tetkigin NE
    //   OLDUGU, sonra sonucun NASIL OKUNACAGI, sonra NE ZAMAN calisildigi,
    //   en sonda baglantilar (cihaz, besiyeri, dis lab, panel). Sekme sirasi
    //   normalde alan sirasindan cikiyordu ve Dis Laboratuvar tek alanla
    //   ikinci siraya gecmisti.
    sekmeSirasi: ['Genel', 'Referans Aralıkları', 'Çalışma Zamanları',
                  'Cihaz Eşleme', 'Besiyeri Seti (kültür)', 'Dış Laboratuvar',
                  'Paneller'],
    // REFERANS GRİDİ SALT GÖRÜNÜM (kullanıcı, mockup): on iki kolonun her biri
    //   satır içi kutu olunca tablo okunmuyordu - hangi kuralın hangi yaşa ait
    //   olduğu ancak kutuların içine bakılarak anlaşılıyordu. Satırlar düz
    //   metin, düzenleme MODALDE: kural bir bütün olarak (cinsiyet + yaş +
    //   gebelik + sınırlar) görülüp değiştirilir.
    // GRİDLER SALT GÖRÜNÜM (kullanıcı, mockup): satır içi kutu yok, hücreler
    //   düz metin; ekleme/düzenleme başlıktaki ＋ ✎ 🗑 ile MODALDE yapılır.
    //   Referansta on iki, cihaz eşlemesinde yedi kolon var - her hücre bir
    //   kutu olunca tablo okunmuyordu. Kayıt bir BÜTÜN olarak görülüp
    //   değiştirilir: yarım girilmiş bir referans kuralı yanlış bayrak üretir.
    detaySecenekleri: {
      // YAŞ GÜN KOLONLARI GRİDDE YOK, MODALDE VAR (kullanıcı: "yaş alt gün ve
      //   üst gün sütunlarını kaldır ama edite izin ver"). Okunur "Kime"
      //   sütunu aynı bilgiyi zaten veriyor ("18 yaş ve üstü · ♀ kadın");
      //   ham gün değerleri kuralı DÜZENLERKEN gerekli, okurken gürültü.
      referanslar: { gridKipi: true, gridGizli: ['yasAltGun', 'yasUstGun'] },
      cihazlar:    { gridKipi: true },
    },
  },

  // ----------------------------------------------------------- muayene ----
  muayene: {
    // MOCKUP SIRASI (muayene_karti.html): hekimin iş akışı - önce anamnez ve
    //   muayene, sonra tanı, istem, reçete/rapor, en sonda sevk, ücret, geçmiş
    //   ve dosyalar.
    sekmeSirasi: ['Anamnez', 'Fizik Muayene', 'Tanı', 'İstem & Sonuçlar',
                  'e-Reçete', 'Rapor', 'Sevk', 'İşlem & Ücret', 'Geçmiş',
                  'Dosyalar'],
    // VİTAL BULGULAR SEKMESİ YOK (kullanıcı): ölçüm anamnez sekmesinin sağ
    //   panelinde düzenleniyor - aynı veriyi iki sekmede göstermek hangisinin
    //   geçerli olduğunu belirsiz bırakıyordu.
    gizliDetaylar: ['vitaller'],
    detayGrupta: {
      bulgular: {
        grup: 'Fizik Muayene', gizli: ['degerSayi', 'taraf'],
        etiket: ['sablonAlanId'], sinif: 'bulgu-gridi',
        // Çerçeve, başlık ve "+ Satır"/sil yok (kullanıcı): satırlar
        //   ŞABLONDAN açılır, elle satır eklemek sistem listesini bozar.
        sade: true,
      },
      // TANI TABLOSU "Tanı / Karar" SEKMESİNDE (mockup): ICD · Tür · Kesinlik ·
      //   Taraf · Kronik · Not. `sira` ve `baslangicTarihi` mockup'ta yok -
      //   sıralama sunucuda, kronik tarihi hastanın Kronik Tanılar ekranında.
      // GRID KİPİ (kullanıcı): satır başında tek seçim kutusu, üst satırda
      //   düzenle/sil ikonları, düzenleme MODALDE. Satır EKLEME kapalı - ICD
      //   kodu "＋ ICD-10 Ekle" ucundan gelir, boş satır yarım kayıt olurdu.
      tanilar: {
        grup: 'Tanı (ICD-10)', gizli: ['sira', 'baslangicTarihi'],
        sinif: 'tani-gridi', ustte: true, gridKipi: true, ekleGizli: true,
      },
    },
    // VİTAL BULGULAR MOCKUP IZGARASI: son ölçüm etiket + kutu ızgarasında,
    //   eski ölçümler altta salt görünüm. Grid satırlarında 14 sayısal kolon
    //   yan yana okunmuyordu.
    detayIzgara: {
      vitaller: {
        baslik: 'Vital bulgular', sinif: 'vital-izgara-kip',
        // Anamnez panelindeki sıra (kullanıcı): tansiyon, nabız, SpO2 · ateş,
        //   solunum, ağrı · boy-kilo, BKİ, bel. Glukoz/GKS ve ölçüm kimliği
        //   Vital Bulgular sekmesinde.
        alanSirasi: ['sistolik', 'nabiz', 'spo2', 'ates', 'solunum', 'agriVas',
                     'boyCm', 'bki', 'belCevresiCm'],
        yeniDugmesi: true,
        not: 'Ölçüm zamanı ve kaynağı kayıtta kalır; '
           + 'BKİ o anki boy/kilodan hesaplanır.',
        // Geçmiş listesi ÖZET: takip edilen ölçüler kalır, antropometri ve tek
        //   seferlik değerler üst ızgarada zaten görünür.
        gecmisGizli: ['boyCm', 'kiloKg', 'bki', 'belCevresiCm', 'glukozParmak',
                      'gks', 'olcenId', 'agriVas'],
      },
    },
    // RAPOR GRİDİ MOCKUP KOLONLARI: Tür · Alt tür · Başlangıç · Süre · Tanı ·
    //   Açıklama · İmza · Durum. Rapor no ve bitiş gizli - bitiş başlangıç +
    //   süreden hesaplanıyor (db/464).
    detaySecenekleri: {
      raporlar: { gizli: ['raporNo', 'bitis'], sinif: 'rapor-gridi', sade: true },
    },
    seritAlanlari: ['bolumId', 'personelId', 'tur', 'ustMuayeneId',
                    'baslangic', 'bitis'],
  },
};

/** Kartın özelleştirmesi; tanımsızsa boş nesne - çağıran koşul yazmasın. */
export function kartOzellestirme(kaynak: string): KartOzellestirme {
  return KART_OZELLESTIRME[kaynak] ?? {};
}
