import { istek } from '../cekirdek';

/** İSG / OSGB icmali (IsgIcmalUclari). Rakamlar ve toplamlar sunucuda hesaplanır. */
export type IsgIcmali = {
  donem: { bas: string; bit: string };
  bugun: string;
  ozet: {
    firma: number; calisan: number; cokTehlikeli: number; hekim: number; planDk: number; gercekDk: number; karsilama?: number | null;
    sureEksikFirma: number; sureEksikDk: number; muayene: number; iseGiris: number; periyodik: number; muayeneDk: number;
    geciken: number; geciken90: number; ziyaret: number; ziyaretDk: number; imzaEksik: number;
    kaza: number; meslekHastaligi: number; ramakKala: number; gunKaybi: number; sgkGec: number; acikOlay: number;
    faturalanan: number; tahsil: number; bakiye: number; sozlesme60: number;
  };
  firmalar: { id: number; ad: string; nace: string; naceAd: string; tehlike: number; tehlikeAdi: string; calisan: number; hekim: string;
              planDk: number; gercekDk: number; ziyaret: number; ziyaretDk: number; muayeneDk: number; karsilama?: number | null;
              sureEksik: number; muayene: number; geciken: number; kaza: number;
              bolumler: { ad: string; maruziyet: string; calisan: number; periyotAy: number; geciken: number }[] }[];
  muayeneler: { id: number; ad: string; iseGiris: number; periyodik: number; iseDonus: number; erkenKontrol: number; isDegisikligi: number;
                toplam: number; calisir: number; kosullu: number; calisamaz: number; bekliyor: number; sureDk: number }[];
  muayeneToplam: { iseGiris: number; periyodik: number; iseDonus: number; erkenKontrol: number; isDegisikligi: number; toplam: number;
                   calisir: number; kosullu: number; calisamaz: number; bekliyor: number; sureDk: number };
  geciken: { id: number; ad: string; firma: string; bolum: string; tehlike: string; sonMuayene?: string | null; vade: string; gecikmeGun: number }[];
  ziyaretler: { id: number; tarih: string; firma: string; tur: string; hekim: string; sureDk: number; imzali: boolean; defterSayfa: string }[];
  sureler: { id: number; ad: string; ziyaret: number; ziyaretDk: number; muayeneDk: number; toplamDk: number; planDk: number; eksikDk: number }[];
  olaylar: { id: number; tarih: string; tur: number; turAdi: string; firma: string; bolum: string; calisan: string; yaralanma: string;
             gunKaybi: number; sgkBildirim?: string | null; bildirimGerekir: boolean; sgkSon?: string | null; sgkGec: boolean; acik: boolean }[];
  hizmet: { id: number; ad: string; aylikUcret: number; devreden: number; faturalanan: number; tahsil: number; bakiye: number;
            tahsilDurumu: string; sozlesmeBit?: string | null; kalanGun?: number | null }[];
  hizmetToplam: { aylikUcret: number; devreden: number; faturalanan: number; tahsil: number; bakiye: number };
  hekimAdlari: { id: number; ad: string }[];
  secimli: boolean;
};

export const isgIcmalUclari = {
  isgIcmali: (bas: string, bit: string, hekim: number, tehlike: number, firmalar: number[] = []) => {
    const q = new URLSearchParams({ bas, bit });
    if (hekim) q.set('hekim', String(hekim));
    if (tehlike) q.set('tehlike', String(tehlike));
    if (firmalar.length) q.set('firmalar', firmalar.join(','));
    return istek<IsgIcmali>(`/api/isg-icmal?${q}`);
  },
};
