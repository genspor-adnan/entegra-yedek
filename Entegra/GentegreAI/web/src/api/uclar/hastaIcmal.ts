import { istek } from '../cekirdek';

/** Hasta hesap icmali (HastaIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type IcmalBasvuru = {
  id: number; no: string; tarih: string | null; iptal: boolean;
  bolum: string; hekim: string; kurum: string;
  toplam: number; iskonto: number; kurumPayi: number; hastaPayi: number;
  tahsil: number; kalan: number;
};
export type IcmalHizmet = {
  basvuruId: number; basvuruNo: string; tarih: string | null; kod: string; ad: string;
  adet: number; birimFiyat: number; tutar: number; kurumPayi: number; hastaPayi: number;
};
export type IcmalTahsilat = {
  id: number; makbuzNo: string; tarih: string | null; basvuruId: number | null; basvuruNo: string;
  tur: string; grup: string; iade: boolean; tutar: number; iptal: boolean; banko: string;
  hesapTuru: string;
};
export type IcmalProvizyon = {
  basvuruId: number; basvuruNo: string; provizyonNo: string; durum: number;
  sgk: number; ozelSigorta: number; satir: number;
};
export type HastaIcmali = {
  hasta: { id: number; ad: string; tc: string; dosyaNo: string; dogumTarihi: string | null; cinsiyet: number };
  donem: { bas: string; bit: string };
  ozet: {
    basvuru: number; kalem: number; toplam: number; kurumPayi: number; hastaPayi: number;
    iskonto: number; tahsil: number; iade: number; kalan: number; avans: number;
  };
  basvurular: IcmalBasvuru[]; hizmetler: IcmalHizmet[];
  tahsilatlar: IcmalTahsilat[]; provizyonlar: IcmalProvizyon[];
};

export const hastaIcmalUclari = {
  hastaIcmal: (hastaId: number, bas?: string, bit?: string) => {
    const q = new URLSearchParams();
    if (bas) q.set('bas', bas);
    if (bit) q.set('bit', bit);
    const s = q.toString();
    return istek<HastaIcmali>(`/api/hasta-icmal/${hastaId}${s ? `?${s}` : ''}`);
  },
};
