/**
 * BELGE TURU DAVRANIS TABLOSU — tek dogruluk kaynagi.
 *
 * Belge karti 12 ayri bayrakla ("tur === 20", "tur === 3 || tur === 4"…) hangi
 * alanin gorunecegine karar ediyordu; her yeni tur (transfer, talep, giris/cikis
 * fisi) bu kosullari onlarca yere serpiyordu. Tur davranisi artik BURADA
 * tanimli: kart yalnizca `belgeTuruBilgisi(tur)` sonucunu okur.
 *
 * Sunucu tarafinin karsiligi: Gentegre.Cekirdek/Katalog/BelgeTuru.cs — ayni
 * kod uzayi, ayni gruplar. Ikisi de kasa_islem_turu katalogundaki kodlari
 * kullanir (grup='belge').
 */

/** Kartin acabilecegi turler - liste/menu "Yeni" dugmeleri bunlari gonderir. */
export const GIRILEBILIR_TURLER = [
  19, 15, 14, 9, 11, 10, 16, 12, 13, 17, 119, 109, 20, 105, 3, 4,
] as const;

/** Kart acilisinda tur verilmediyse (dogrudan /belge/yeni) kullanilan tur. */
export const VARSAYILAN_TUR = 15;

/** Kalem satirinin fiyat/vergi alanlarinin nasil davranacagi. */
export type KalemBicimi =
  | 'tam'        // fatura/siparis: fiyat + iskonto + KDV
  | 'sade'       // irsaliye / stok fisi: fiyat var, iskonto-KDV gizli
  | 'miktar';    // transfer / talep: yalniz miktar (para yok)

/** Baslikta kac depo alani cizilecegi. */
export type DepoBicimi = 'yok' | 'tek' | 'cift';

export interface BelgeTuruBilgisi {
  kod: number;
  /** Baslik/etiket metinlerinde gecen kisa ad ("Transfer No", "Fiş Tarihi"). */
  ad: string;
  /** Kaydettikten/kapattiktan sonra donulecek liste rotasi. */
  liste: string;

  // --- yon ve taraf ---
  alis: boolean;          // cari TEDARIKCI, stok GIRISI
  siparis: boolean;
  irsaliye: boolean;
  fatura: boolean;        // Tahsilat sekmesi olanlar (fatura + fis)
  tahakkuk: boolean;
  konsinye: boolean;
  transfer: boolean;      // 20 - depolar arasi
  talep: boolean;         // 105 - stoktan talep
  stokFisi: boolean;      // 3 giris / 4 cikis fisi
  /** Transfer + talep: parasiz "depo belgesi" - ortak sadelestirmeler. */
  depoBelgesi: boolean;

  // --- ekranin sekli ---
  eBelge: boolean;        // e-Belge sekmesi/alani/dugmeleri
  cariVar: boolean;       // baslikta cari alani ve yeni kartta cari aramasi
  depo: DepoBicimi;
  kalem: KalemBicimi;
  vade: boolean;
  doviz: boolean;         // Doviz/Kur alani
  /** Mal depoya giriyor: izlemli stokta lot/seri bu belgede toplanir. */
  girisIzlemi: boolean;
  /** Mal depodan cikiyor: izlemli stokta stoktaki lotlardan SECIM yapilir. */
  cikisIzlemi: boolean;
  /** Numara KARSI TARAFTA uretilir (alis faturasi): kullanici girer. */
  disNumara: boolean;
  /** Kaydedince kart kapanip listeye donulur (sonrasinda yapilacak is yok). */
  kaydedinceKapan: boolean;
  /** Ilk kalem eklenince baslik kilitlenir (depo/tarih sonradan degisemez). */
  kalemVarsaBaslikKilitli: boolean;
}

/** Turden turetilen ortak gruplar - tablo satirlari bunlarla kisaliyor. */
const ALIS_TURLERI      = new Set([9, 10, 11, 12, 17, 109]);
const SIPARIS_TURLERI   = new Set([9, 19]);
const IRSALIYE_TURLERI  = new Set([10, 14, 109, 119]);
const FATURA_TURLERI    = new Set([11, 12, 15, 16]);
const TAHAKKUK_TURLERI  = new Set([13, 17]);
const KONSINYE_TURLERI  = new Set([109, 119]);
const STOK_FISI_TURLERI = new Set([3, 4]);

/** e-Belge'ye GIDEN turler; kalanlarda sekme/alan hic cizilmez. */
const EBELGE_TURLERI = new Set([10, 11, 14, 15]);

const LISTE_YOLU: Record<number, string> = {
  // SATIS
  19: '/siparis', 14: '/satis-irsaliye', 15: '/belge', 16: '/satis-fisi',
  13: '/tahakkuk', 119: '/satis-konsinye',
  // ALIS
  9: '/alis-siparis', 10: '/alis-irsaliye', 11: '/alis-fatura', 12: '/alis-fisi',
  17: '/borc-tahakkuk', 109: '/alis-konsinye',
  // STOK
  20: '/stok-transfer', 105: '/stok-talep', 3: '/giris-fis', 4: '/cikis-fis',
};

/** Baslik etiketlerinde kullanilan kisa ad ("<ad> No", "<ad> Tarihi"). */
function turAdi(tur: number): string {
  if (STOK_FISI_TURLERI.has(tur)) return 'Fiş';
  if (tur === 105) return 'Talep';
  if (tur === 20) return 'Transfer';
  if (KONSINYE_TURLERI.has(tur)) return 'Konsinye';
  if (IRSALIYE_TURLERI.has(tur)) return 'İrsaliye';
  return 'Belge';
}

/**
 * Turun ekran davranisi. Bilinmeyen tur gelirse fatura gibi davranilir -
 * eksik tanim yuzunden ekranin bos acilmasindansa en genel bicim gosterilir.
 */
export function belgeTuruBilgisi(tur: number): BelgeTuruBilgisi {
  const transfer = tur === 20;
  const talep    = tur === 105;
  const stokFisi = STOK_FISI_TURLERI.has(tur);
  const depoBelgesi = transfer || talep;
  const irsaliye = IRSALIYE_TURLERI.has(tur);
  const tahakkuk = TAHAKKUK_TURLERI.has(tur);
  const siparis  = SIPARIS_TURLERI.has(tur);
  const alis     = ALIS_TURLERI.has(tur);

  return {
    kod: tur,
    ad: turAdi(tur),
    liste: LISTE_YOLU[tur] ?? '/belge',

    alis,
    siparis,
    irsaliye,
    fatura: FATURA_TURLERI.has(tur),
    tahakkuk,
    konsinye: KONSINYE_TURLERI.has(tur),
    transfer,
    talep,
    stokFisi,
    depoBelgesi,

    eBelge: EBELGE_TURLERI.has(tur),
    // Cari YOK: transfer (kendi depolarimiz), talep (ic istek), stok fisi
    //   (karsilik gider/gelir hesabi).
    cariVar: !depoBelgesi && !stokFisi,
    // Transferde iki depo (cikis + giris); talepte istenen + (opsiyonel) teslim
    //   deposu; tahakkukta stok yok.
    depo: tahakkuk ? 'yok' : depoBelgesi ? 'cift' : 'tek',
    kalem: depoBelgesi ? 'miktar' : (irsaliye || stokFisi) ? 'sade' : 'tam',
    vade: !irsaliye && !depoBelgesi && !stokFisi,
    doviz: !depoBelgesi && !stokFisi,
      disNumara: tur === 11,
    kaydedinceKapan: depoBelgesi || stokFisi,
    kalemVarsaBaslikKilitli: depoBelgesi || stokFisi,
    // Mal DEPOYA GIRIYOR: izlemli stokta lot/seri bilgisi burada TOPLANIR
    //   (alis irsaliyesi/faturasi, konsinye giris, giris fisi). Cikista lot
    //   girilmez SECILIR - mevcut stoktan, ayri ekran.
    girisIzlemi: (alis && !siparis && !tahakkuk) || tur === 3,
    // Satis irsaliyesi/faturasi/fisi, konsinye cikis, cikis fisi ve transferin
    //   CIKIS bacagi: lot girilmez, stoktakilerden secilir.
    cikisIzlemi: (!alis && !siparis && !tahakkuk && !talep
                  && (irsaliye || FATURA_TURLERI.has(tur) || tur === 16 || tur === 119))
                 || tur === 4,
  };
}
