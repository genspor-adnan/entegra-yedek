import { istek } from '../cekirdek';

/** Vezne / kasa konsolide icmali (VezneIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type VezneOturumu = {
  id: number; bankoId: number; bankoKod: string; banko: string;
  /** 1 açılış onayı bekliyor, 2 açık, 3 kapanış onayı bekliyor, 4 kapandı. */
  durum: number; vardiyaKod: number; vardiya: string; gorevli: string;
  acilis?: string | null; kapanis?: string | null; devir: number;
  nakit: number; pos: number; havale: number; diger: number; iade: number; net: number; adet: number;
  beklenenNakit: number; sayim?: number | null; fark?: number | null; farkAciklama: string;
  teslimEdilen?: number | null; kasadaBirakilan?: number | null; teslimAlan: string;
  teslimZamani?: string | null; tutanakNo: string;
};
export type VezneTuru = {
  tur: number; turAdi: string; turGrup: string; hesapTuru: string;
  /** 1 kasada, 2 kasaya girmez (POS / banka), 3 çek-senet, 4 nakit akışı yok. */
  kasaDurumu: number; adet: number; tahsilat: number; iade: number; net: number;
};
export type VezneTerminali = {
  bankoPosId: number; terminalNo: string; banka: string; bankolar: string; oturum: number;
  kasaToplami: number; cihazToplami?: number | null; fark?: number | null; adet: number; eksik: boolean;
};
export type VezneIcmali = {
  donem: { bas: string; bit: string };
  secili: number[];
  ozet: {
    oturum: number; banko: number; acik: number; onayBekleyen: number; makbuz: number;
    nakit: number; pos: number; havale: number; diger: number; iade: number; net: number; tahsilat: number;
    beklenenNakit: number; sayim: number; kasaFarki: number; farkliOturum: number;
    posFarki: number; posAtanmamis: number;
    devredilen: number; devredilenOturum: number; bekleyenDevir: number;
  };
  oturumlar: VezneOturumu[]; turler: VezneTuru[]; pos: VezneTerminali[];
};

export const vezneIcmalUclari = {
  vezneIcmali: (bas: string, bit: string, vardiya: number, oturumlar: number[]) => {
    const q = new URLSearchParams({ bas, bit });
    if (vardiya) q.set('vardiya', String(vardiya));
    if (oturumlar.length) q.set('oturumlar', oturumlar.join(','));
    return istek<VezneIcmali>(`/api/vezne-icmal?${q}`);
  },
};
