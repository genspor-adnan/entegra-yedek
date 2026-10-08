/** API sozlesmesi - anaSayfa. Alan adlari sunucuyla birebir. */

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

/** Kurum profiline ozel panel kutusu (508) - icerigi SUNUCU belirler. */
export interface ProfilKutusu {
  kod: string; baslik: string; deger: number; alt: string;
  /** 'normal' | 'uyari' | 'tehlike' | 'olumlu' */
  vurgu: string;
  /** 'para' verilirse tutar olarak bicimlenir. */
  bicim?: string;
  rota?: string;
}

/** Kurum profiline ozel panel blogu: baslik + kolonlar + satirlar. */
export interface ProfilBloku {
  kod: string; baslik: string; ipucu?: string;
  kolonlar: string[];
  /** Kolon basina bicim: 'metin' | 'sayi' | 'para'. */
  bicimler?: string[];
  satirlar: string[][];
}

/** Kurum profili paneli (508): bos `kutular` = genel (ERP) duzen cizilir. */
export interface PanelProfili {
  kurumTipi: string; baslik: string;
  kutular: ProfilKutusu[];
  bloklar: ProfilBloku[];
}

export interface PanelYaniti {
  /** Kurum profiline ozel panel (508); yoksa genel duzen. */
  profil?: PanelProfili | null;
  kutular: PanelKutusu[];
  sonBelgeler: PanelSatiri[];
  kritikStok: PanelSatiri[];
  buyukBakiyeler: PanelSatiri[];
  /** Kullanicinin bitmemis gorevleri - once GECIKENLER. */
  gorevler: PanelSatiri[];
  /** Onumuzdeki 14 gunun takvimi (baslangici olan kayitlar). */
  takvim: PanelSatiri[];
}

/** Randevu Ayarlari > Bolumler (251) - bolum ya da hekim satiri. */
export interface RandevuAyarSatiri {
  id: number | null;
  departmanId: number;
  hekimId: number | null;
  /** Bolum ya da hekim adi (ekranda gosterilir). */
  ad: string;
  baslangicSaat: string;
  bitisSaat: string;
  ogleBaslangic: string;
  ogleBitis: string;
  slotDk: number | null;
  varsayilanSure: number | null;
  calismaGunleri: string;
  aktif: number;
  aciklama: string;
}

/** Sol agacin bir dugumu: bolum + altindaki hekimler. */
/** Hekim çalışma planı (711): şablon + istisnadan türetilen bloklar. */
export interface CalismaBlok {
  hekimId: number; hekim: string; subeId: number; departmanId: number; departman: string;
  gun: string; saatBas?: string | null; saatBit?: string | null; slotDk: number; kanallar: string;
  /** 1 şablon · 2 istisna (saat değişikliği / ek mesai) · 3 kapalı (izin / kongre / kapalı). */
  kaynak: number; istisnaTur?: number | null; sablonId?: number | null; istisnaId?: number | null; aciklama: string; randevu: number;
  /** Randevuların kapladığı slot (şube saatinde) ve şablon adı. */
  dolu?: number; sablon?: string;
}
export interface CalismaPlaniYaniti {
  bas: string; bit: string; subeId: number; bloklar: CalismaBlok[];
  hekimler: { id: number; ad: string; departmanId: number }[];
  bolumler: { id: number; ad: string; randevusuz: boolean }[];
  subeler: { id: number; ad: string }[];
  /** ozet=1 ile: onay bekleyen istisnalar (plan henüz uygulamaz) ve işlem bekleyen randevu. */
  bekleyenIstisnalar?: { id: number; hekimId: number; tur: number; bas: string; bit: string; aciklama: string; saatBas?: string | null; saatBit?: string | null; randevu: number }[];
  islemBekleyen?: number;
}

export interface RandevuBolumDugumu {
  departmanId: number;
  ad: string;
  ayar: RandevuAyarSatiri;
  hekimler: RandevuAyarSatiri[];
}

/** Bolum/hekim ayar yazma istegi - bos alan ust seviyeden miras alinir. */
export type RandevuAyarYazma = Omit<RandevuAyarSatiri, 'id' | 'ad'>;
