import { gonder, istek } from '../cekirdek';

/**
 * MASRAF İCMALİ (MasrafIcmalUclari, `/api/masraf-icmal`). Küme: kesin alış faturası / fişi / gider
 * pusulasının STOKSUZ satırları (belge dip toplamından pay) + kasa / banka masraf bacağı
 * (v_masraf_ekstre) + onaylı personel masraf beyanı + (varsayılan) demirbaş amortismanı. Rakamlar
 * sunucuda; ekran toplamaz. Alan adları sunucuyla birebir. Sunucu null alanları göndermez - isteğe
 * bağlı alanlar `?` ile.
 */
type Secenek = { id: number; ad: string };

/** Sanal kalem kimlikleri (sunucuyla aynı). */
export const KALEM_ATANMAMIS = -1;
export const KALEM_AMORTISMAN = -2;

export type MasrafAltKalem = {
  id: number; kod: string; ad: string; muhKodu: string; tutar: number; karsi: number; degisim?: number | null;
  pay: number; aylikOrt: number; satir: number; dogrudan: boolean;
};

export type MasrafUstKalem = {
  id: number; kod: string; ad: string; muhKodu: string; tutar: number; karsi: number; degisim?: number | null;
  pay: number; aylikOrt: number; satir: number;
  /** Olağan dışı artış (son 3 tam ay ort. önceki 6 ayın eşik üstü) - yüzde. */
  artis?: number | null;
  nakitDisi: boolean; atanmamis: boolean; plani: boolean;
  altlar: MasrafAltKalem[];
};

export type MasrafPlanSatiri = {
  masrafId: number; ad: string; tanimlar: Secenek[]; kalem: string; kod: string;
  plan: number; gercek: number; fark: number; farkYuzde?: number | null;
  donem: number; eslesen: number; odenmemis: number; tahmini: boolean;
  durum: 'planinda' | 'odenmedi' | 'tahmin' | 'artis' | 'alti'; durumAdi: string;
};

export type MasrafDikkat = {
  tur: 'atanmamis' | 'artis' | 'mukerrer' | 'kdv' | 'plansiz'; turAdi: string; kayit: string; tarih?: string | null;
  aciklama: string; oneri: string; kalemId: number; belgeler: { id: number; no: string }[];
};

export type MasrafIcmali = {
  bas: string; bit: string; karsi: { tur: 'gy' | 'od'; bas: string; bit: string }; gecenYil: { bas: string; bit: string }; gun: number;
  sube: number; merkez: number; kalem: number; kdvDahil: boolean; planKiyas: boolean; taslak: boolean; amortismanDahil: boolean;
  acikDonemBasi: string;
  esik: { artisYuzde: number; mukerrerGun: number };
  ozet: {
    toplam: number; karsi: number; degisim?: number | null; ay: number; aylikOrt: number; son3Ort: number;
    plan: number; planGercek: number; planFark: number; planFarkYuzde?: number | null; planTanim: number; planFarkKalemler: string[];
    enBuyuk?: { id: number; ad: string; tutar: number; pay: number } | null;
    ciro: number; giderCiro?: number | null;
    atanmamis: { satir: number; tutar: number };
    satir: number; kalem: number; merkez: number;
    amortisman: { dahil: boolean; tutar: number };
    beyan: number; kasa: number;
  };
  kalemler: MasrafUstKalem[];
  kalemToplam: { tutar: number; karsi: number; degisim?: number | null; aylikOrt: number };
  merkezMatris: {
    /** Son kolon her zaman "Diğer" (id -9: ilk 6 üst kalemin dışı + atanmamış). */
    kolonlar: Secenek[];
    satirlar: { id: number; ad: string; hucreler: number[]; toplam: number; pay: number }[];
    toplam: { hucreler: number[]; toplam: number };
  };
  trend: {
    ay: string; tutar: number; gecenYil: number; degisim?: number | null;
    plan?: number | null; planGercek?: number | null; planFark?: number | null; kismiGun?: number | null; cubuk: number;
  }[];
  plan: {
    satirlar: MasrafPlanSatiri[];
    toplam: { plan: number; gercek: number; fark: number; farkYuzde?: number | null; tanim: number };
  };
  tedarikciler: {
    id: number; ad: string; anaKalem: string; anaKalemId: number; tutar: number; belge: number;
    karsi?: number | null; degisim?: number | null; pay: number;
  }[];
  dikkat: MasrafDikkat[];
  uyarilar: string[];
  secim: {
    subeler: Secenek[]; merkezler: Secenek[];
    kalemler: { id: number; ad: string; derinlik: number; baslik: boolean }[];
    atanabilir: { id: number; kod: string; ad: string; ust: string }[];
  };
  yetkiler: { ata: boolean; kasaAta: boolean };
  izlemeNo: string;
};

/** Gider satırı kaynağı: belge satırı · kasa masraf bacağı · masraf beyanı satırı · amortisman (demirbaş × ay). */
export type MasrafKaynak = 'belge' | 'kasa' | 'beyan' | 'amortisman';

export type MasrafDetaySatiri = {
  kaynak: MasrafKaynak; satirId: number; belgeId: number; no: string; kaynakAdi: string; tarih: string;
  tarafId: number; taraf: string; aciklama: string; kalemId: number; kalem: string; kalemKod: string; ustKalem: string;
  merkezId: number; merkez: string; haric: number; kdv: number; tutar: number; kdvOran: number;
  iade: boolean; taslak: boolean; fis: boolean;
  /** Boş = atanabilir; dolu = neden atanamadığı (kapanmış dönem, hizmet bağlı, beyan…). */
  atamaEngeli: string;
};

export type MasrafDetay = {
  baslik: string; sayi: number; toplam: { haric: number; kdv: number; tutar: number }; atanabilir: number;
  satirlar: MasrafDetaySatiri[]; acikDonemBasi: string; izlemeNo: string;
};

export type MasrafAtaYaniti = {
  atanan: number; belgeSatiri: number; kasaBacagi: number; belgeler: number;
  masraf: { id: number; ad: string }; uyarilar: string[]; izlemeNo: string;
};

export const masrafIcmalUclari = {
  masrafIcmali: (q: URLSearchParams) => istek<MasrafIcmali>(`/api/masraf-icmal?${q}`),
  /** Belge Detayı: ana süzgeçler + ust / alt / dmerkez / tedarikci (en çok 2000 satır; toplam hepsinden). */
  detay: (q: URLSearchParams) => istek<MasrafDetay>(`/api/masraf-icmal/detay?${q}`),
  /**
   * Seçili belge satırlarına / kasa masraf bacaklarına masraf kalemi atar (belge Değiştir; kasa ayrıca
   * kasa_islem Değiştir). Kapanmış dönem 422 (engel.kod = KAPANMIS_DONEM) - onayla geçilmez.
   */
  ata: (masrafId: number, satirlar: { kaynak: 'belge' | 'kasa'; id: number }[]) =>
    gonder<MasrafAtaYaniti>('/api/masraf-icmal/ata', { masrafId, satirlar }),
};
