import { gonder, istek } from '../cekirdek';

/** Zimmet / Hareketler (1007) - DemirbasZimmetUclari. */
export type ZimmetOzet = {
  kpi: {
    toplam: number; zimmetli: number; bosta: number; buAyHareket: number;
    /** Zimmetli ama sahibi pasif (işten ayrılmış) personel. */
    iadeBekleyen: number; zimmetliDeger: number;
  };
  lokasyonlar: { ad: string; adet: number; zimmetli: number; deger: number }[];
  personeller: { id: number; ad: string; aktif: boolean; adet: number; deger: number }[];
};

export type PersonelZimmeti = {
  id: number; kod: string; ad: string; kategori: string;
  zimmetTarihi: string | null; tutanakNo: string; deger: number;
};

export type DemirbasBulunan = {
  id: number; kod: string; ad: string; zimmetId: number | null; zimmet: string;
  lokasyon: number | null; lokasyonAd: string;
};

export type ZimmetIslemi = 'veris' | 'iade' | 'devir' | 'yer';

export type Tutanak = {
  tutanakNo: string; tarih: string; iade: boolean; teslimEden: string; teslimAlan: string;
  lokasyon: string; aciklama: string; metin: string;
  kalemler: { kod: string; ad: string; seriNo: string; markaModel: string; deger: number }[];
};

export const demirbasZimmetUclari = {
  zimmetOzet: () => istek<ZimmetOzet>('/api/demirbas-zimmet/ozet'),
  zimmetPersonel: (id: number) => istek<PersonelZimmeti[]>(`/api/demirbas-zimmet/personel/${id}`),
  zimmetPersoneller: () => istek<{ id: number; ad: string }[]>('/api/demirbas-zimmet/personeller'),
  zimmetDemirbasAra: (q: string) =>
    istek<DemirbasBulunan[]>(`/api/demirbas-zimmet/ara?q=${encodeURIComponent(q)}`),
  zimmetIslem: (g: { islem: ZimmetIslemi; demirbasIdler: number[]; kisiId?: number | null;
                     lokasyon?: number | null; aciklama?: string }) =>
    gonder<{ adet: number; tutanakNo: string }>('/api/demirbas-zimmet/islem', g),
  zimmetTutanak: (no: string) =>
    istek<Tutanak>(`/api/demirbas-zimmet/tutanak/${encodeURIComponent(no)}`),
};
