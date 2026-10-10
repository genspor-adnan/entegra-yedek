import { gonder, istek } from '../cekirdek';

/** Hasta borç takibi (HastaBorcTakipUclari). Borç sunucuda hesaplanır. */
export type BorcSozu = {
  id: number;
  /** 2 ödeme sözü, 3 ödeme planı. */
  tur: number; tutar?: number | null; vade?: string | null; taksitSayisi?: number | null;
  durum: 'bekliyor' | 'tutulmadi';
};
export type BorcProtokolu = {
  belgeId: number; protokolNo: string; tarih: string; bolum: string;
  hastaPayi: number; tahsil: number; kalan: number; gun: number;
};
export type Borclu = {
  id: number; ad: string; dosyaNo: string; telefon: string; telefonVar: boolean; epostaVar: boolean;
  borc: number; acikProtokol: number; gun: number; sonBasvuru: string; sonTahsilat?: string | null;
  sonHatirlatma?: string | null; sonHatirlatmaKanal?: number | null;
  soz?: BorcSozu | null; isaretId?: number | null;
  durum: 'yeni' | 'hatirlatildi' | 'soz' | 'planli' | 'soz_tutulmadi' | 'tahsilata';
  protokoller: BorcProtokolu[];
};
export type BorcTakibi = {
  tarih: string;
  ozet: {
    borclu: number; toplam: number; gun30: number; gun30Hasta: number; hatirlatmaBekleyen: number;
    buAyTahsil: number; sozTutar: number; planTutar: number; tutulmayan: number; tahsilata: number;
  };
  borclular: Borclu[];
};
export type BorcIslemi = {
  id: number; hastaId: number; hasta: string;
  /** 1 hatırlatma, 2 söz, 3 plan, 4 tahsilata çağır, 5 not. */
  tur: number; kanal?: number | null; bildirimId?: number | null;
  /** bildirim.durum: 1 kuyrukta, 2 gönderiliyor, 3 gönderildi, 4 hata, 5 iptal, 6 vazgeçildi. */
  bildirimDurum?: number | null;
  tutar?: number | null; vade?: string | null; taksitSayisi?: number | null;
  aciklama: string; durum: number; zaman: string; ekleyen: string;
};

export const hastaBorcUclari = {
  hastaBorcTakibi: () => istek<BorcTakibi>('/api/hasta-borc'),
  hastaBorcGecmisi: (hastaId?: number) =>
    istek<{ islemler: BorcIslemi[] }>(`/api/hasta-borc/gecmis${hastaId ? `?hastaId=${hastaId}` : ''}`),
  hastaBorcHatirlat: (hastaIds: number[], kanal: 1 | 2) =>
    gonder<{ kuyruga: number; atlanan: { ad: string; neden: string }[] }>('/api/hasta-borc/hatirlat', { hastaIds, kanal }),
  hastaBorcSoz: (govde: { hastaId: number; tur: 2 | 3; tutar: number; vade: string; taksitSayisi?: number; aciklama?: string }) =>
    gonder<{ id: number }>('/api/hasta-borc/soz', govde),
  hastaBorcIsaret: (hastaIds: number[], aciklama?: string) =>
    gonder<{ isaretlenen: number }>('/api/hasta-borc/isaret', { hastaIds, aciklama }),
  hastaBorcNot: (hastaId: number, aciklama: string) => gonder<{ id: number }>('/api/hasta-borc/not', { hastaId, aciklama }),
  hastaBorcKaldir: (id: number) => gonder<{ kaldirildi: boolean }>(`/api/hasta-borc/islem/${id}/kaldir`, {}),
};
