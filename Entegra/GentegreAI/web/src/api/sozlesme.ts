// Sunucu sozlesmesinin (dokuman/01_API_SOZLESMELERI.md) TypeScript karsiligi.
// Alan adlari sunucudakiyle BIREBIR ayni tutulur - cevrim katmani yok.

export type HataKodu =
  | 'DOGRULAMA' | 'YETKISIZ' | 'YASAK' | 'BULUNAMADI'
  | 'CAKISMA' | 'IS_KURALI' | 'SUNUCU';

export interface AlanHatasi { alan: string; mesaj: string }

export interface HataGovdesi {
  kod: HataKodu;
  mesaj: string;
  izlemeNo: string;
  alanlar?: AlanHatasi[];
  cakisanAlanlar?: string[];
  guncelDeger?: Record<string, unknown>;
  engel?: { tablo: string; adet: number };
}

/** Sunucudan donen hata; istemcide bu tip firlatilir. */
export class ApiHatasi extends Error {
  durum: number;
  hata: HataGovdesi;

  constructor(durum: number, hata: HataGovdesi) {
    super(hata.mesaj);
    this.durum = durum;
    this.hata = hata;
  }
  get dogrulamaMi() { return this.hata.kod === 'DOGRULAMA' }
  get cakismaMi()   { return this.hata.kod === 'CAKISMA' }
}

// --------------------------------------------------------------- kimlik ----
export interface SubeOzeti { id: number; ad: string; varsayilan: boolean; yazma: boolean }

export interface KullaniciOzeti {
  id: number; kod: string; ad: string;
  rolId: number; rolAdi: string;
  yetkiSurumu: number;
  subeId?: number | null;
  subeYazma: boolean;
  subeler: SubeOzeti[];
}

export interface GirisYaniti {
  accessToken: string;
  refreshToken: string;
  sonaErme: string;
  refreshSonaErme: string;
  parolaDegismeli: boolean;
  subeSecimiGerekli: boolean;
  kullanici: KullaniciOzeti;
}

export interface KaynakYetkisi {
  kod: string; gor: boolean; ekle: boolean; degistir: boolean; sil: boolean;
}

export interface BenYaniti {
  kullanici: KullaniciOzeti;
  aksiyonlar: string[];
  kaynaklar: KaynakYetkisi[];
}

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

export interface ListeIstegi {
  sayfa?: number;
  boyut?: number;
  sirala?: Siralama[];
  filtre?: Kosul;
  grup?: string[];
  toplam?: string[];
  gorunum?: string;
}

export type ListeSatiri = Record<string, unknown>;

export interface ListeYaniti {
  satirlar: ListeSatiri[];
  toplamKayit: number;
  toplamlar?: Record<string, unknown>;
  gruplar?: { anahtar: string; ad: string; adet: number }[];
  sureMs: number;
  izlemeNo: string;
}

/** §2.4 kolon metasi. Yetkisiz kolon bu listede HIC donmez. */
export interface KolonMeta {
  ad: string;
  baslik: string;
  tip: 'metin' | 'sayi' | 'para' | 'tarih' | 'kod' | 'mantik';
  hizalama: 'sol' | 'orta' | 'sag';
  bicim?: string | null;
  varsayilan: boolean;
  siralanabilir: boolean;
  filtrelenebilir: boolean;
  genislik?: number | null;
}

// ----------------------------------------------------------------- kart ----
export interface KartYetkisi { duzenle: boolean; sil: boolean; gizliAlanlar: string[] }

export interface KartYaniti {
  kart: Record<string, unknown> & { id?: number; surum?: string };
  detaylar?: Record<string, Record<string, unknown>[]>;
  kodAd?: Record<string, Record<string, string>>;
  yetki: KartYetkisi;
  izlemeNo: string;
}

/** Cari kartı "İlgili Kişiler" (GenForm > Genel, /api/kart/cari/{id}/kisiler). */
export interface KisiKaydi {
  id: number;
  unvan: string;
  telefon?: string | null;
  eposta?: string | null;
  aktif: boolean;
  gorev?: string | null;
  departman?: number | null;
  bagli: boolean;
}

export interface KisiIstegi {
  unvan: string;
  telefon?: string | null;
  eposta?: string | null;
  aktif?: boolean;
  gorev?: string | null;
  departman?: number | null;
}

export interface YetkiSatiri {
  yetkiId: number;
  kod: string;
  ad: string;
  grup: string;
  gor: boolean;
  ekle: boolean;
  degistir: boolean;
  sil: boolean;
}

export interface YetkiSatiriIstegi {
  yetkiId: number;
  gor: boolean;
  ekle: boolean;
  degistir: boolean;
  sil: boolean;
}

export interface DokumanSatiri {
  id: number;
  ad: string;
  contentType: string;
  boyut: number;
  varsayilan: boolean;
  sira: number;
  eklemeTarihi: string;
  paylasimKodu?: string | null;
}

export interface DetayFarki {
  eklenen?: Record<string, unknown>[];
  degisen?: Record<string, unknown>[];
  silinen?: number[];
}

export interface KartYazmaIstegi {
  surum?: string;
  kart?: Record<string, unknown>;
  detaylar?: Record<string, DetayFarki>;
}

/** Kart alan metasi (/api/kart/{kaynak}/alanlar) - liste tarafindaki KolonMeta karsiligi. */
export interface KartAlanMeta {
  ad: string;
  baslik: string;
  tip: 'metin' | 'sayi' | 'para' | 'tarih' | 'kod' | 'mantik';
  grup?: string | null;
  altGrup?: string | null;
  eslesAlan?: string | null;
  yazilabilir: boolean;
  zorunlu: boolean;
  enFazlaUzunluk?: number | null;
  kodlar?: Record<string, string> | null;
}

export interface KartDetayMeta { ad: string; baslik: string; saltOkunur: boolean; alanlar: KartAlanMeta[] }

export interface KartMetaYaniti {
  kaynak: string;
  alanlar: KartAlanMeta[];
  detaylar: KartDetayMeta[];
  yetki: KartYetkisi;
}

/** API §7 — aksiyon katalogu. Yetkisiz aksiyon HIC donmez. */
export interface AksiyonYaniti {
  kod: string;
  ad: string;
  grup: string;
  hedef: string;              // "araccubugu,sagtus,palet"
  kisayol?: string | null;
  kayitGerekir: boolean;
  aktif: boolean;
  pasifSebep?: string | null;
}

export interface AksiyonListesi {
  ekran: string;
  kayitId?: number | null;
  aksiyonlar: AksiyonYaniti[];
}

// ---------------------------------------------------------------- belge ----
export interface DipToplamSatiri {
  tur: number; aciklama: string; deger: number;
  dovizTutari: number; kur: string; belgeDovizi: string;
}

export interface BelgeYaniti {
  belge: Record<string, unknown>;
  satirlar: Record<string, unknown>[];
  dipToplam: DipToplamSatiri[];
  uyarilar?: string[];
  izlemeNo: string;
}

// -------------------------------------------------------------- referans ----
/** Il/Ilce/Ulke (039_il_ilce_ulke.sql) - Adresler grid'inde il->ilce cascading secim. */
export interface YerlerYaniti {
  iller: { id: number; ad: string }[];
  ilceler: { id: number; ilId: number; ad: string }[];
  ulkeler: { id: number; ad: string }[];
}
