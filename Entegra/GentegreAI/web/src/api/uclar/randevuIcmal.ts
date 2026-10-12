import { istek } from '../cekirdek';

/** Randevu / poliklinik satırı değerleri (sunucuda hesaplanır, RandevuIcmalUclari.Satir). */
export type RandevuDeger = {
  slot: number; verilen: number; bos: number; doluluk?: number | null; gelen: number; gelmeyen: number; bekleyen: number;
  noShow?: number | null; iptal: number; randevusuz: number; muayene: number; ortBeklemeDk?: number | null; uzunBekleme: number;
  ilk: number; kontrol: number;
};

/** Randevu / poliklinik icmali (RandevuIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type RandevuIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    kayit: number; verilen: number; gelen: number; gelmeyen: number; bekleyen: number; iptal: number; gelenOran?: number | null;
    noShow?: number | null; iptalOran?: number | null; slot: number; doluluk?: number | null; bos: number; ortBeklemeDk?: number | null;
    uzunBekleme: number; beklemeOlculen: number; randevusuz: number; muayene: number; ilk: number; kontrol: number; ilkOran?: number | null; kontrolOran?: number | null;
    poliklinik: number; hekim: number; kanal: number; ucuncuGelmeme: number; gelmeyenToplam: number; calismaGunu: number;
  };
  poliklinikler: { id: number; ad: string; hekimSayisi: number; deger: RandevuDeger;
                   hekimler: { hekim: number; hekimAd: string; gun: number; izin: number; deger: RandevuDeger }[] }[];
  toplam: RandevuDeger;
  hekimler: { bolum: number; hekim: number; bolumAd: string; hekimAd: string; gun: number; izin: number; gunBasi?: number | null; deger: RandevuDeger }[];
  kanallar: { id: number; ad: string; kayit: number; pay?: number | null; verilen: number; gelen: number; gelmeyen: number;
              noShow?: number | null; iptal: number; ortOneAlmaGun?: number | null }[];
  kanalToplam: { kayit: number; verilen: number; gelen: number; gelmeyen: number; noShow?: number | null; iptal: number; ortOneAlmaGun?: number | null };
  gunSaat: {
    gunler: { dow: number; ad: string; gunSayisi: number; verilen: number }[];
    satirlar: { saat: string; verilen: number; hucreler: { slot: number; verilen: number; doluluk?: number | null; gelmeme?: number | null }[] }[];
    toplam: number;
  };
  beklemeDagilimi: { ad: string; hasta: number; pay?: number | null }[];
  gelmeyenler: { id: number; no: string; tarih: string; hasta: string; poliklinik: string; hekim: string; kanal: string; tip: string;
                 onceki: number; verilme: string }[];
  bolumAdlari: { id: number; ad: string }[];
  hekimAdlari: { id: number; ad: string }[];
  kanalAdlari: { id: number; ad: string }[];
  tipAdlari: { id: number; ad: string }[];
};

export type RandevuIcmalSuzgec = { bolum: number; hekim: number; kanal: number; tip: number };

export const randevuIcmalUclari = {
  randevuIcmali: (bas: string, bit: string, s: RandevuIcmalSuzgec) => {
    const q = new URLSearchParams({ bas, bit });
    for (const [k, v] of Object.entries(s)) if (v) q.set(k, String(v));
    return istek<RandevuIcmali>(`/api/randevu-icmal?${q}`);
  },
};
