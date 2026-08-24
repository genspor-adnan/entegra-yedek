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
  dil: number;
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
  belgeTuru: string;
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
  /** Formda cizilmez ama degeri tasinir (arka plan alani - or. cek/senet "Tür"). */
  gizli?: boolean;
}

export interface KartDetayMeta { ad: string; baslik: string; saltOkunur: boolean; alanlar: KartAlanMeta[] }

export interface KartMetaYaniti {
  /** Yeni kayitta doldurulacak alanlar (katalogdaki varsayilanlar). */
  varsayilanlar?: Record<string, unknown>;
  /** Doluysa yeni kayitta taraf secim ekrani acilir; deger yazilacak alan adi. */
  acilistaTarafSecimi?: string | null;
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

// ------------------------------------------------------- belge donusumu ----
/** v_belge_acik_satir: donusturulmeyi bekleyen satir (F8). */
export interface AcikSatir {
  satirId: number;
  sira: number;
  satirTur: number;
  stokId?: number | null;
  stokKodu?: string | null;
  stokAdi?: string | null;
  hizmetId?: number | null;
  masrafId?: number | null;
  aciklama: string;
  miktar: number;
  kapatilanMiktar: number;
  kalanMiktar: number;
  birim: number;
  birimFiyat: number;
  iskonto: number;
  kdv: number;
  belgeTur: number;
  belgeTurAdi?: string | null;
  belgeNo: string;
  tarafUnvan: string;
  belgeDovizi: string;
  kapanmaDurum: number;
}

/** belge.kapanma_durum */
export const KAPANMA_DURUM: Record<number, string> = {
  0: 'Açık', 1: 'Kısmi Dönüştü', 2: 'Kapandı',
};

// -------------------------------------------------------------- referans ----
/** Il/Ilce/Ulke (039_il_ilce_ulke.sql) - Adresler grid'inde il->ilce cascading secim. */
export interface YerlerYaniti {
  iller: { id: number; ad: string }[];
  ilceler: { id: number; ilId: number; ad: string }[];
  ulkeler: { id: number; ad: string }[];
}

// ----------------------------------------------------------------- kasa ----
/** Bacak sablonu (kasa_islem_turu.sablon) - ekran alanlarini bundan cizer. */
export interface BacakSablonu {
  rol: string;
  yon: 'B' | 'A';
  tutar: string;          // '@tutar' | '@masraf_tutar' | '@karsi_tutar'
}

export interface KasaIslemTuru {
  kod: number;
  ad: string;
  grup: string;           // tahsilat | odeme | virman | doviz | ceksenet | kredi | plan | ...
  yon: number;
  anaHesapTuru: string;   // K/B/P/V/R/H - ana hesap lookup'ini bu suzer
  karsiHesapTuru: string;
  cariZorunlu: number;    // 1 zorunlu, 0 opsiyonel, -1 yasak
  kalemTuru: number;      // 0 yok, 1 masraf, 2 hizmet, 3 ikisi
  planMi: boolean;
  fisMi: boolean;
  fisTuru: number;
  makbuzBasligi: string;
  sablon: BacakSablonu[];
}

export interface KasaBacagi {
  id?: number;
  sira: number;
  rol?: string;
  hesapTuru?: string;
  hesapId?: number | null;
  hesapAdi?: string | null;
  tarafId?: number | null;
  tarafUnvan?: string | null;
  masrafId?: number | null;
  masrafAdi?: string | null;
  hizmetId?: number | null;
  hizmetAdi?: string | null;
  projeId?: number | null;
  borc: number;
  alacak: number;
  yerelBorc: number;
  yerelAlacak: number;
  dovizCinsi: string;
  dovizKuru: number;
  aciklama?: string;
}

export interface FisSatiriOzeti {
  sira: number;
  hesapKodu: string;
  hesapAdi: string;
  borc: number;
  alacak: number;
  dovizCinsi: string;
  dovizBorc: number;
  dovizAlacak: number;
  aciklama: string;
}

export interface FisOzeti {
  id: number;
  fisNo: string;
  fisTarihi: string;
  tur: number;
  durum: number;
  toplamBorc: number;
  toplamAlacak: number;
  satirlar: FisSatiriOzeti[];
}

export interface KasaIslemYaniti {
  islem: Record<string, unknown>;
  bacaklar: KasaBacagi[];
  fis?: FisOzeti | null;
  uyarilar?: string[];
  izlemeNo: string;
}

export interface KasaSecenekleri {
  taslak?: boolean;
  plan?: boolean;
  kurKontrolu?: boolean;
  belgeId?: number | null;
}

export interface KasaIslemYazmaIstegi {
  surum?: string;
  /** Baslik alanlari (camelCase, sunucu beyaz listesi). yerelTutar GONDERILMEZ. */
  islem: Record<string, unknown>;
  /** Bos birakilirsa bacaklari sunucu turun sablonundan uretir (normal akis). */
  bacaklar?: Record<string, unknown>[];
  secenekler?: KasaSecenekleri;
}

/** kasa_islem.durum (DB check ile ayni). */
export const KASA_DURUM: Record<number, string> = {
  0: 'Taslak', 1: 'Planlı', 2: 'Gerçekleşti', 3: 'İptal', 4: 'Plan Kapandı',
};

// ------------------------------------------------ stok kartı: Stok Durumu ----
/** Depo bazlı stok satırı (stok_karti.html "Stok Durumu" sekmesi). */
export interface StokDurumSatiri {
  depoId: number;
  depoAdi: string;
  miktar: number;
  /** Açık SATIŞ siparişlerinde söz verilmiş miktar. */
  rezerve: number;
  /** miktar − rezerve. Kritik uyarısı bu değere bakar. */
  kullanilabilir: number;
  /** Açık ALIŞ siparişlerinde beklenen miktar. */
  yolda: number;
  /** null = bu depo için ayrı limit yok, stok.min_stok geçerli. */
  minStok: number | null;
  maxStok: number | null;
  /** 'yeterli' | 'kritik' | 'yok' */
  durum: string;
}

export interface StokDurumOzeti {
  toplam: number;
  rezerve: number;
  kullanilabilir: number;
  yolda: number;
  depoSayisi: number;
}

export interface StokDurumYaniti {
  ozet: StokDurumOzeti;
  satirlar: StokDurumSatiri[];
  /** Stokun ana birimi ("Adet", "Kg"...) - KPI kutularında miktarın yanına yazılır. */
  birim: string;
}

/** Stok kartı "Hareketler" sekmesi — bir hareket satırı. */
export interface StokHareketSatiri {
  belgeId: number;
  tarih: string;
  belgeTur: number;
  belgeTurAdi: string;
  belgeNo: string;
  tarafUnvan: string;
  /** Tek depo ya da transferde "Çıkış → Giriş". */
  depo: string;
  /** 'giris' | 'cikis' | 'transfer' (suzgecsiz gorunumde iki depoyu birden oynatir) */
  yon: string;
  giris: number;
  cikis: number;
  /** Devirden başlayıp satır satır yürüyen bakiye. */
  kalan: number;
  aciklama: string;
}

export interface StokHareketYaniti {
  /** Başlangıç tarihinden önceki net toplam. */
  devir: number;
  kapanis: number;
  satirlar: StokHareketSatiri[];
  birim: string;
}

/** Genel Ayarlar satiri (public.referans, sunucuda beyaz listeli). */
export interface AyarSatiri {
  anahtar: string;
  deger: string;
  tip: string;
  aciklama: string;
  /** public.help'ten gelen "?" metni - bos ise ikon gosterilmez (db/103). */
  yardimBaslik: string;
  yardim: string;
}

/** public.help satiri - alan/opsiyon yanindaki "?" ikonunun icerigi. */
export interface YardimKaydi {
  anahtar: string;
  baslik: string;
  metin: string;
}

// ------------------------------------------------------------- ana sayfa ----
/** Panel ust seridindeki kutu. `vurgu`: '', 'olumlu', 'uyari', 'hata'. */
export interface PanelKutusu {
  anahtar: string;
  baslik: string;
  deger: number;
  /** '₺' ise para bicimlenir, degilse adet/kalem gibi sayilir. */
  birim: string;
  alt: string;
  /** Tiklaninca gidilecek liste; bos ise kutu tiklanmaz. */
  yol: string;
  vurgu: string;
}

export interface PanelSatiri {
  id: number;
  ana: string;
  yan: string;
  deger: string;
  yol: string;
}

export interface PanelYaniti {
  kutular: PanelKutusu[];
  sonBelgeler: PanelSatiri[];
  kritikStok: PanelSatiri[];
  buyukBakiyeler: PanelSatiri[];
  /** Kullanicinin bitmemis gorevleri - once GECIKENLER. */
  gorevler: PanelSatiri[];
  /** Onumuzdeki 14 gunun takvimi (baslangici olan kayitlar). */
  takvim: PanelSatiri[];
}
