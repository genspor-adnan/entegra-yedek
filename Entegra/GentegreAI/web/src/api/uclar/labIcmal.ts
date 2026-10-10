import { istek } from '../cekirdek';

/** Laboratuvar icmali (LabIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type LabTetkik = {
  /** p<id> = panel, t<id> = tetkik. */
  anahtar: string; kod: string; ad: string; grup: number; grupAd: string; dis: boolean;
  adet: number; ciro: number; kurum: number; birimFiyat: number; kurumYuzde: number;
  maliyet: number; testMaliyet: number; marj?: number | null; ortTat?: number | null; disGun?: number | null;
  tekrar: number; asan: number; faturasiz: number; bolumler: { ad: string; adet: number }[];
};
export type LabIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    tetkik: number; hasta: number; istem: number; ciro: number; kurum: number; hastaPayi: number; reaktif: number;
    disAdet: number; disMaliyet: number; disCiro: number; kar: number; marj?: number | null;
    tekrar: number; tekrarOrani: number; numune: number; ret: number; retOrani: number;
    ortTat?: number | null; rutinAdet: number; asan: number; faturasiz: number; zarardaDisLab: number; maliyetsiz: number;
  };
  tetkikler: LabTetkik[];
  gruplar: { grup: number; ad: string; cesit: number; adet: number; ciro: number; kurum: number; hasta: number;
             maliyet: number; kar: number; marj?: number | null; tekrar: number }[];
  cihazlar: { id: number; ad: string; tetkikler: string; grup: string; test: number; qc: number; qcOrani: number;
              arizaGun: number; reaktif: number; testBasi: number }[];
  disLablar: { id: number; ad: string; cesit: number; adet: number; ciro: number; maliyet: number; fark: number; ortGun?: number | null;
               tetkikler: { kod: string; ad: string; adet: number; ciro: number; maliyet: number; fark: number; ortGun?: number | null }[] }[];
  tatDagilimi: { ad: string; adet: number }[];
  asanlar: { belgeId: number; protokolNo: string; tarih: string; tetkik: string; bolum: string; hedef: number; gercek: number; asim: number }[];
  retNedenleri: { ad: string; adet: number; enCok: string }[];
  bolumAdlari: { id: number; ad: string }[];
  grupAdlari: { id: number; ad: string }[];
};

export const labIcmalUclari = {
  labIcmali: (bas: string, bit: string, tetkikGrubu: number, bolum: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (tetkikGrubu) q.set('tetkikGrubu', String(tetkikGrubu));
    if (bolum) q.set('bolum', String(bolum));
    return istek<LabIcmali>(`/api/lab-icmal?${q}`);
  },
};
