/** API sozlesmesi - kurumProfil. Alan adlari sunucuyla birebir. */

// ------------------------------------------------------- kurum profili ----
/** Kurum tipi / modul katalog satiri (359). */
export interface KurumKatalogSatiri { kod: string; ad: string; sira: number }

/** Tip x modul varsayilani: 0 gizli · 1 acik · 2 opsiyonel. */
/**
 * PROFILDE GECERLI ROL (786). `varsayilan` sablonun karari, `gecerli` kurumun
 * karari (yoksa varsayilan), `yazili` kurum bu tip icin kaydini yazdi mi.
 * `kilitli` roller (yonetici, atanmamis) pasife alinamaz - DB tetigi de
 * reddeder.
 */
export interface ProfilRolu {
  id: number; kod: string; ad: string; amac: string;
  aktif: boolean; sistem: boolean; kisi: number;
  /**
   * PORTAL ROLÜ (dış kurum · dış hekim · firma · hasta). Kadro değil
   * dışarıya açılan kapı: kutusu kurum tipi geçerliliğine değil DOĞRUDAN
   * `rol.aktif`e yazar (829 + kullanıcı 08.10.2026).
   */
  portal?: boolean;
  sablon: boolean; modul?: string | null; modulKapali: boolean;
  varsayilan: boolean; gecerli: boolean; yazili: boolean; kilitli: boolean;
  /**
   * KADRO YERI (agac gorunumu): bolum adi, ust rolun kodu ve sira. Sunucudan
   * gelir (`SablonKadro`) - hiyerarsi YETKI degil GORUNUM; haritada olmayan
   * rol "Diger" bolumune duser.
   */
  bolum: string; ust?: string | null; sira: number;
}

export interface KurumTipiModul { kurumTipi: string; modul: string; varsayilan: number }

/** Kurulumun kurum profili - tek satir (kurum_profil.id = 1). */
export interface KurumProfil {
  urunModu: number;
  kurumTipi: string;
  altTip: string;
  basamak: string;
  tesisKodu: string;
  subeYapisi: number;
  hekimSayisi: number;
  uniteSayisi: number;
  dil: string;
  paraBirimi: string;
  /** Modul OVERRIDE'lari: {"lab": 1, "teletip": 0} - yoksa tipin varsayilani. */
  moduller: Record<string, number>;
  /**
   * KIMLIK NO BICIMI (679): `otomatik` subenin ulkesine bakar (TR'de T.C.
   * algoritmasi, disinda serbest), `tc` her zaman T.C., `serbest` bicim
   * kontrolu yok, `desen` asagidaki duzenli ifadeyi uygular.
   */
  kimlikBicimi?: string;
  kimlikDeseni?: string;
  /** Alan hatasinda kullaniciya yazilan aciklama ("6-12 hane pasaport no"). */
  kimlikAciklama?: string;
  /** Profilin subesi (364): 0 = kurum geneli, N = o sube. */
  subeId?: number;
  /**
   * Bu sube icin AYRI SATIR YOK, deger kurum genelinden geldi (364). Ekran
   * "devralindi" der ve "bu sube icin ayri ayar" onerir.
   */
  devralindi?: boolean;
}

/**
 * Kurulum adimi (490) - "Özet & Kurulum" sekmesindeki kontrol listesi.
 * Durum ve aciklama SUNUCUDAN gelir; ekran sayim/kontrol yapmaz.
 */
export interface KurumKurulumAdimi {
  sira: number;
  kod: string;
  ad: string;
  /** 1 tamam · 0 bekliyor. */
  durum: number;
  /** Kisa gerekce ("6 liste · 3702 hizmet", "tesis kodu (ÇKYS) boş"). */
  bilgi: string;
  /** Adimi tamamlayacak ekranin rotasi ("/fiyat-listesi"). */
  rota: string;
  /** Dugme yazisi ("Fiyat Listeleri"). */
  aksiyon: string;
}

/**
 * Entegrasyon satiri (491) - "5 · Entegrasyonlar" sekmesi. Gereklilik ve
 * durum SUNUCUDAN: ekran hesap tablosunu kendisi yorumlamaz.
 */
export interface KurumEntegrasyonDurumu {
  sira: number;
  kod: string;
  ad: string;
  /** 2 zorunlu · 1 önerilen · 0 opsiyonel. */
  gereklilik: number;
  /** Neden gerekli ("SGK'lı hasta kabul ediliyorsa zorunlu"). */
  gerekce: string;
  /** 2 canlı hesap · 1 test hesabı · 0 hesap yok. */
  durum: number;
  /** Bulunan hesabın adı. */
  hesap: string;
  /** Hesabın son bağlantı sonucu (kısaltılmış). */
  sonSonuc: string;
}

/**
 * Kurum profilinde acilip kapanan hizmet/stok kategorisi (527).
 * `aktif` kurulumun bugunku durumu, `onerilen` secili tipin varsayilani.
 */
export interface KurumKategoriSatiri {
  id: number; kod: string; ad: string;
  /** 1 stok · 2 hizmet. */
  tur: number;
  aktif: number; onerilen: number;
  /** Kategoriye bagli hizmet ya da stok adedi - kapatmanin etkisi. */
  adet: number;
}

export interface KurumProfilYaniti {
  profil: KurumProfil;
  tipler: KurumKatalogSatiri[];
  moduller: KurumKatalogSatiri[];
  matris: KurumTipiModul[];
  /** Kurulum adimlarinin canli durumu (490). */
  kurulum: KurumKurulumAdimi[];
  /** Entegrasyonlarin gerekliligi ve hesap durumu (491). */
  entegrasyonlar: KurumEntegrasyonDurumu[];
  /** Hizmet/stok kategorileri ve tipin onerisi (527). */
  kategoriler: KurumKategoriSatiri[];
}
