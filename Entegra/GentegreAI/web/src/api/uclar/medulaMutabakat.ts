import { istek } from '../cekirdek';

/** Medula mutabakat icmali (MedulaUclari.Mutabakat). Rakamlar sunucuda hesaplanır. */
export type MutabakatTakibi = {
  belgeId: number; protokolNo: string; tarih: string; hastaId: number; hasta: string; bolum: string; hekim: string;
  takipNo: string; takipTuru: number; cikis: boolean; kabulIslem: number; hataliIslem: number; satirSayisi: number;
  yerelTutar: number; faturaId?: number | null; faturaNo: string; medulaTutar?: number | null;
  /** medula.fatura_durum: 0 yok, 1 taslak, 2 kaydedildi, 3 dönemde, 4 dönem kapandı, 5 incelendi, 6 ödendi, 7 iptal. */
  faturaDurum: number; faturali: boolean; katilim?: number | null;
  /** '' faturalı; hizmet_yok / hizmet_hatali / hizmet_gonderilmedi / cikis_yok / taslak / hazir. */
  neden: string;
};
export type MutabakatFarki = {
  belgeId: number; protokolNo: string; hasta: string; takipNo: string; faturaNo: string;
  yerelTutar: number; medulaTutar: number; fark: number; katilim?: number | null;
};
export type MutabakatKesintisi = {
  id: number; belgeId: number; protokolNo: string; takipNo: string; faturaNo: string; hasta: string;
  sutKodu: string; kod: string; aciklama: string; tutar: number;
  /** medula.itiraz_durum: 0 edilmedi, 1 edildi · bekliyor, 2 kabul · iade, 3 red. */
  itirazDurum: number; iade: number; net: number;
};
export type MedulaMutabakati = {
  yil: number; ay: number; esik: number;
  donem?: { id: number; faturaSayisi: number; toplam: number; kesinti: number; odenen: number;
            odemeTarihi?: string | null; sonlandirma?: string | null; icmalNo: string; durum: number } | null;
  ozet: {
    takip: number; faturali: number; faturasiz: number; faturasizTutar: number; hazir: number;
    yerelTutar: number; faturaliYerel: number; medulaTutar: number; farkli: number; farkTutari: number;
    kesinti: number; kesintiKalem: number; itirazBekleyen: number; itirazBekleyenKalem: number;
    odenen: number; acik: number;
  };
  huni: { kod: string; ad: string; adet: number; tutar: number }[];
  faturasiz: MutabakatTakibi[]; farklar: MutabakatFarki[]; kesintiler: MutabakatKesintisi[];
  faturalar: MutabakatTakibi[];
};

export const medulaMutabakatUclari = {
  medulaMutabakat: (yil: number, ay: number) =>
    istek<MedulaMutabakati>(`/api/medula/mutabakat?yil=${yil}&ay=${ay}`),
};
