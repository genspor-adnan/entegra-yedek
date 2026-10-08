/** API sozlesmesi - liste. Alan adlari sunucuyla birebir. */

// ---------------------------------------------------------------- liste ----
export type KosulOp =
  | 'esit' | 'esitDegil' | 'icerir' | 'baslar' | 'biter'
  | 'buyuk' | 'buyukEsit' | 'kucuk' | 'kucukEsit'
  | 'arasinda' | 'bos' | 'bosDegil' | 'icinde';

export interface Kosul {
  alan?: string;
  op: KosulOp | 'and' | 'or';
  deger?: unknown;
  kosullar?: Kosul[];
}

export interface Siralama { alan: string; yon: 'asc' | 'desc' }

/** Belgenin e-Belge gecmisi satiri (178). */
export interface EBelgeMesaji {
  sira: number;
  tarih: string | null;
  olay: string;
  durum: string;
  kod: string;
  aciklama: string;
}

/** Toplu e-Belge isleminde satir basina sonuc (183). */
export interface TopluEBelgeSonucu {
  belgeId: number;
  basarili: boolean;
  belgeNo: string;
  mesaj: string;
}

export interface ListeIstegi {
  sayfa?: number;
  boyut?: number;
  sirala?: Siralama[];
  filtre?: Kosul;
  grup?: string[];
  toplam?: string[];
  gorunum?: string;
  /** gorunum = 'kullanim' iken hangi poliklinigin gecmisi (550). */
  bolum?: number;
}

export type ListeSatiri = Record<string, unknown>;

export interface ListeYaniti {
  satirlar: ListeSatiri[];
  toplamKayit: number;
  toplamlar?: Record<string, unknown>;
  /** Gruplu liste (ekstre: para birimi basina). Toplamlar TUM suzulmus kume icin. */
  gruplar?: { anahtar: string; ad: string; adet: number; toplamlar?: Record<string, unknown> }[];
  /** Satirlarin hangi kolona gore obeklendigi ("dovizCinsi"). */
  grupKolonu?: string | null;
  sureMs: number;
  izlemeNo: string;
}

/**
 * Cikis belgesinde secilebilecek lot (114). "kalan" o lottan geriye ne kaldigi -
 * cikista bundan fazlasi secilemez.
 */
export interface StokLotSatiri {
  seriLotId: number;
  lotNo: string;
  seriNo: string;
  uretimTarihi?: string | null;
  sonKullanmaTarihi?: string | null;
  kalan: number;
  /** Lotun bulundugu depo - gocmus hareketlerde bilinmiyor (null). */
  depoId?: number | null;
  depoAdi?: string;
}

/** Paket icerigi satiri (124). */
export interface PaketIcerikSatiri {
  stokId: number;
  kod: string;
  ad: string;
  birim: number;
  adet: number;
  kdv: number;
  fiyat: number;
  izleme: number;
}

/**
 * Bir alanin/kolonun VERI TIPI. Liste kolonu (KolonMeta) ve kart alani
 * (KartAlanMeta) ayni kumeyi kullanir - iki yerde ayri yazilinca sunucuya yeni
 * bir tip eklendiginde birinde unutuluyordu.
 */
/** "ondalik" = olculen kesirli deger (ates 36,6 · BKI 30,4); "sayi" tam sayi. */
// 'json': jsonb kolonu (cihaz olcum eslemesi, time-out teyitleri). Istemci
//   icin METINDIR - cok satirli yazilir; gecerlilik sunucuda dogrulanir ve
//   yazarken ::jsonb cast'i orada eklenir.
export type AlanTipi = 'metin' | 'sayi' | 'ondalik' | 'para' | 'tarih' | 'zaman' | 'json' | 'saat'
                     | 'kod' | 'mantik';

/** §2.4 kolon metasi. Yetkisiz kolon bu listede HIC donmez. */
export interface KolonMeta {
  ad: string;
  baslik: string;
  tip: AlanTipi;
  hizalama: 'sol' | 'orta' | 'sag';
  bicim?: string | null;
  varsayilan: boolean;
  siralanabilir: boolean;
  filtrelenebilir: boolean;
  genislik?: number | null;
  /** Yalniz grup ara toplaminda toplanir (ekstrede doviz tutarlari). */
  sadeceGrupToplami?: boolean;
  /** Kod kolonunun deger-etiket sozlugu (492) - ust serit suzgec combosu. */
  kodlar?: Record<string, string> | null;
}
