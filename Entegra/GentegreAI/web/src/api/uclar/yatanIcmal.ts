import { istek } from '../cekirdek';

/** Yatan hasta / servis dönem icmali (YatanDonemIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type YatanOzet = {
  yatak: number; yatis: number; taburcu: number; hastaGun: number; doluluk?: number | null; alos?: number | null;
  ciro: number; gunBasi: number; kurum: number; hasta: number; acikAdet: number; acikTutar: number; yatiyor: number;
};
export type YatanIcmali = {
  donem: { bas: string; bit: string; gun: number; haftalar: { bas: string; bit: string }[] };
  ozet: YatanOzet; toplamYatak: number; kapaliYatak: number; devirHizi: number; tekrarYatis: number; uzunYatis: number;
  servisler: { id: number; ad: string; kapaliYatak: number; ozet: YatanOzet; doktorlar: { id: number; ad: string; ozet: YatanOzet }[] }[];
  yatislar: { id: number; protokolNo: string; hasta: string; servis: string; doktor: string; giris: string; cikis?: string | null;
              gun: number; odeyen: string; ciro: number; tekrar: boolean; durum: 'yatiyor' | 'acik' | 'kapandi' }[];
  acikHesaplar: { id: number; protokolNo: string; hasta: string; servis: string; odeyen: string; cikis: string; bekleme: number;
                  toplam: number; faturasiz: number; neden: string }[];
  haftalik: { id: number; ad: string; yatak: number; haftalar: (number | null)[]; donem?: number | null; bosYatakGun: number; kapaliYatak: number }[];
  tanilar: { kod: string; ad: string; adet: number; alos: number; ortTutar: number }[];
  doktorlar: { ad: string; servis: string; ozet: YatanOzet }[];
  servisAdlari: { id: number; ad: string }[];
};

export const yatanIcmalUclari = {
  yatanIcmali: (bas: string, bit: string, servis: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (servis) q.set('servis', String(servis));
    return istek<YatanIcmali>(`/api/yatan-icmal?${q}`);
  },
};
