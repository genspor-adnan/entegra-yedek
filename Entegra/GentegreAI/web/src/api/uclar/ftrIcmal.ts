import { istek } from '../cekirdek';

/** FTR icmali (FtrIcmalUclari). Rakamlar ve toplamlar sunucuda hesaplanır. */
export type FtrIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    kur: number; suren: number; biten: number; yarida: number; seans: number; sureSaat: number; yarim: number; planli: number; gelmedi: number; iptal: number;
    devam?: number | null; kurBasiSeans?: number | null; ciro: number; kurum: number; hasta: number; ciroluSeans: number;
    medulaSeansPayi?: number | null; medulaCiroPayi?: number | null; iyiYanit?: number | null; vasDusus?: number | null;
    kabinDoluluk?: number | null; kabin: number; kabinsizSeans: number; isGunu: number; araGecikti: number;
  };
  fizyoterapistler: { id: number; ad: string; kur: number; aktif: number; seans: number; yarim: number; gelmedi: number; devam?: number | null;
                      sureSaat: number; ciro: number; bitenKur: number; vasDusus?: number | null; bolgeler: { ad: string; adet: number }[] }[];
  kurler: { id: number; programNo: string; protokolNo: string; bolge: string; icd: string; tani: string; odeyen: string; odeyenKod: string;
            kurum: string; fizyoterapist: string; plan: number; yapilanToplam: number; donem: number; gelmedi: number; kalanHak?: number | null;
            durum: string; durumKod: number; yanit: string; araGecikti: boolean; ciro: number }[];
  odeyenler: { kod: string; ad: string; kur: number; seans: number; seansUcreti: number; ciro: number; kurum: number; hasta: number;
               raporKullanilan?: number | null; raporHak?: number | null; ciroPayi?: number | null }[];
  odeyenToplam: { kur: number; seans: number; ciro: number; kurum: number; hasta: number };
  klinik: { bolge: string; olcek: string; kur: number; vasBas?: number | null; vasSon?: number | null; olcekBas?: number | null;
            olcekSon?: number | null; iyilesme?: number | null; iyi: number; kismi: number; yanitsiz: number; iyiOran?: number | null }[];
  araDegerlendirme: { gereken: number; yapildi: number; gecikti: number };
  uygulamalar: { ad: string; cihaz: string; yer: string; adet: number; ortDk: number; sureSaat: number; pay?: number | null }[];
  uygulamaToplam: { adet: number; sureSaat: number };
  kabinler: { id: number; ad: string; tur: string; cihazlar: string; seans: number; kullanimSaat: number; kapasiteSaat: number; doluluk?: number | null }[];
  kabinToplam: { kullanimSaat: number; kapasiteSaat: number; doluluk?: number | null };
  fizyoterapistAdlari: { id: number; ad: string }[];
  bolgeAdlari: { id: number; ad: string }[];
};

export const ftrIcmalUclari = {
  ftrIcmali: (bas: string, bit: string, fzt: number, bolge: number, odeyen: string) => {
    const q = new URLSearchParams({ bas, bit });
    if (fzt) q.set('fzt', String(fzt));
    if (bolge) q.set('bolge', String(bolge));
    if (odeyen) q.set('odeyen', odeyen);
    return istek<FtrIcmali>(`/api/ftr-icmal?${q}`);
  },
};
