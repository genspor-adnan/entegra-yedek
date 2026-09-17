import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * ONAY GELEN KUTUSU (738/739).
 *
 * TEK EKRAN, TÜM TÜRLER. "Onayımda ne var" sorusu bugün yalnız Talepler
 * listesinden yanıtlanabiliyordu; izin, avans ve masraflı onarım gelince
 * kullanıcı aynı soruyu dört ekranda sormak zorunda kalırdı - ve birini
 * açmayı unutunca onay orada beklerdi.
 *
 * MODÜL KAPISI YOK: onay kutusu satınalmaya ait değil, kurumun kendisine
 * ait. Modüle bağlasaydık satınalma modülü kapalı bir kurumda izin onayı da
 * görünmezdi.
 */
export const ONAY_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'onayKutusu', rota: 'onay-kutusu',
    baslik: 'Onayımdakiler',
    yol: 'Yönetim › Onaylar',
    aksiyonEkrani: 'onay-kutusu-liste',
    tarihAlani: 'baslama',
    // İLK ÇİP GÜNLÜK İŞ KÜMESİ: bekleyen her şey. "Geciken" ile açsaydık
    //   zamanında gelen onay hiç görünmez, kuyruk ancak gecikince fark
    //   edilirdi - kutunun varlık sebebi tam tersi.
    cipler: [
      { ad: 'Bekleyen',      filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Geciken',       filtre: { alan: 'gecikmeGun', op: 'buyuk', deger: 0 } },
      // BİLGİ İSTENDİ: zincir DURDU ama bitmedi - yanıt bekleyen basamak
      //   kimsenin kutusunda "iş" gibi görünmezse orada unutulur.
      { ad: 'Bilgi istendi', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Satınalma',     filtre: { alan: 'kaynakTur', op: 'esit', deger: 1241 } },
      { ad: 'Tümü' },
    ],
    // YÖNETİM GRUBUNUN BAŞINDA (menuSira 1). Onay kuyruğu günlük iştir,
    //   ayar değil - Kurum Profili / Güvenlik / Platform arasında dursaydı
    //   her gün bakılacak bir kutu, yılda bir açılan ekranların arasında
    //   kaybolurdu.
    //
    //   KENDİ GRUBU AÇILMADI: depo kuralı her grubun sonunda "Dökümler"
    //   ister ve grup tavanı 28'dir. Tek ekran için ikisini birden esnetmek,
    //   kuralı kuralsızlığa çevirirdi. İzin ve avans gelince "Onaylar"
    //   grubu kendi dökümleriyle birlikte açılacak.
    menuGrup: 'Yönetim', menuAd: 'Onayımdakiler', ic: '✍️',
    yetkiKodu: 'panel', menuSira: 1,
  },
  {
    // AKIŞ TANIMI (742): kurumun imza düzeni. Kurallar 738'de veriye
    //   taşınmıştı ama düzenleyecek ekran yoktu - eşiği değiştirmek göç
    //   dosyası yazmak demekti, yani kural yine koda gömülüydü.
    kaynak: 'onayAkis', rota: 'onay-akis',
    baslik: 'Onay Akışları',
    yol: 'Yönetim › Onay Akışları',
    kartYolu: '/onay-akis', kartBaslik: 'Onay Akışı',
    aksiyonEkrani: 'onay-akis-liste',
    cipler: [
      { ad: 'Aktif',   filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      // İMZASIZ GEÇEN AKIŞ: taban basamağı olmayan akışta küçük tutarlı
      //   kayıt hiç imza görmeden onaylanır - çip bunu ortaya çıkarır.
      { ad: 'Taban basamağı yok', filtre: { alan: 'tabanBasamak', op: 'esit', deger: 0 } },
      { ad: 'Gecikmesi olan', filtre: { alan: 'geciken', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Yönetim', menuAd: 'Onay Akışları', ic: '🧭',
    yetkiKodu: 'kullanici', menuSira: 3,
  },
  {
    // VEKÂLET (741): imza yetkisinin geçici devri. Vekâlet olmadan onay
    //   zinciri kişinin izniyle birlikte duruyor; kurum da çareyi "şifresini
    //   ver"de buluyor - imzanın kime ait olduğu o noktada kayboluyor.
    kaynak: 'onayVekalet', rota: 'onay-vekalet',
    baslik: 'Onay Vekâletleri',
    yol: 'Yönetim › Onay Vekâleti',
    kartYolu: '/onay-vekalet', kartBaslik: 'Onay Vekâleti',
    aksiyonEkrani: 'onay-vekalet-liste',
    tarihAlani: 'baslangic',
    // İLK ÇİP YÜRÜRLÜKTEKİLER: listenin sorusu "şu an kim kimin yerine
    //   bakıyor". Süresi dolmuşlarla açsaydık ekran bir arşiv olurdu.
    cipler: [
      { ad: 'Yürürlükte',   filtre: { alan: 'yururlukte', op: 'esit', deger: 1 } },
      { ad: 'Bekleyen',     filtre: { alan: 'bekliyor', op: 'esit', deger: 1 } },
      { ad: 'Aktif',        filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Yönetim', menuAd: 'Onay Vekâleti', ic: '🤝',
    yetkiKodu: 'kullanici', menuSira: 2,
  },
];
