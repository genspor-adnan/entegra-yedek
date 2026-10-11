import { istek } from '../cekirdek';

/** Belge türü / seri özeti (EFaturaIcmalUclari). */
export type EFaturaTurOzeti = {
  belge: number; matrah: number; kdv: number; toplam: number; iade: number; iadeTutar: number;
  iptal: number; ulasan?: number | null; sorunlu: number; yediGun: number;
};

export type EFaturaSorunlu = {
  id: number; belgeNo: string; tarih: string; tur: string; alici: string; protokol: string; tutar: number;
  sorun: string; gun: number; gonderildi: boolean; aciklama: string; gonderim?: string | null; hazir: boolean;
};

export type EFaturaBelgeSatiri = {
  id: number; belgeNo: string; tarih: string; tur: string; alici: string; protokol: string;
  matrah: number; kdv: number; toplam: number; durum: string;
};

/** Fatura / e-Belge icmali - rakamlar sunucuda hesaplanır. */
export type EFaturaIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    kesilen: number; kayit: number; iptal: number; toplam: number; matrah: number; kdv: number; faturaKdv: number;
    eFatura: number; eFaturaTutar: number; eFaturaIade: number; eArsiv: number; eArsivTutar: number;
    eIrsaliye: number; eIrsaliyeTutar: number; sorunlu: number; gitmedi: number; hata: number;
    hazirlanmadi: number; yediGun: number; ulasan?: number | null;
  };
  turler: { tur: string; ozet: EFaturaTurOzeti; seriler: { seri: string; ozet: EFaturaTurOzeti }[] }[];
  sorunlu: EFaturaSorunlu[];
  kdvOzet: { oran: number; satir: number; belge: number; eFatura: number; eArsiv: number; matrah: number; kdv: number; pay: number }[];
  alicilar: { grup: string; belge: number; matrah: number; kdv: number; toplam: number; iade: number; iptal: number; sorunlu: number; pay: number }[];
  kurumlar: { ad: string; fatura: number; toplam: number; durumlar: { ad: string; adet: number }[] }[];
  seriler: { seri: string; tur: string; kullanim: string; ilk: string; son: string; kayit: number; gecerli: number;
             iade: number; iptal: number; toplam: number; atlama: number }[];
  iadeler: EFaturaBelgeSatiri[];
  iptaller: EFaturaBelgeSatiri[];
  seriAdlari: string[];
};

export const efaturaIcmalUclari = {
  efaturaIcmali: (bas: string, bit: string, tur = '', seri = '', alici = '') =>
    istek<EFaturaIcmali>(`/api/efatura-icmal?bas=${bas}&bit=${bit}`
      + (tur ? `&tur=${encodeURIComponent(tur)}` : '') + (seri ? `&seri=${encodeURIComponent(seri)}` : '')
      + (alici ? `&alici=${encodeURIComponent(alici)}` : '')),
};
