/** API sozlesmesi - stok. Alan adlari sunucuyla birebir. */

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
  /** Ağırlıklı ortalama alış maliyeti (fn_uretim_stok_maliyeti) ve toplam × maliyet. */
  birimMaliyet?: number;
  deger?: number;
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
  /** Başlama tarihinden önceki net toplam. */
  devir: number;
  kapanis: number;
  satirlar: StokHareketSatiri[];
  birim: string;
}

/** Stok kartı Ürün Ağacı / BOM sekmesi (StokDurumDeposu.UrunAgaclariAsync). */
export interface StokAgacBileseni {
  sira: number; stokId: number | null; stokKod: string; stokAd: string; tip: string;
  miktar: number; birim: string; fireYuzde: number; altAgac: string;
}
export interface StokUrunAgaci {
  id: number; kod: string; ad: string; tur: string; surum: number; aktif: boolean; varsayilan: boolean;
  ciktiMiktar: number; maliyetToplam: number; maliyetTarih: string | null; bilesenler: StokAgacBileseni[];
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
