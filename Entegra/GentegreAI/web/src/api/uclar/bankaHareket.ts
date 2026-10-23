import { gonder, istek } from '../cekirdek';

/** BANKA HAREKETLERİ (1157, mockup Ekranlar/ERP/banka_hareketleri.html). */

export interface BankaOzeti {
  sayac: { cekilen: number; bekleyen: number; oneriHazir: number; secimBekleyen: number; islendi: number;
           yoksayilan: number; bekleyenTutar: number } | null;
  hesap: null | {
    id: number; ad: string; iban: string; doviz: string; kaynak: number; bankaBakiye: number | null;
    sonCekim: string | null; sonSonuc: string; cekmeDk: number; onayBitis: string | null; entegrasyon: string;
    test: boolean; sistemBakiye: number;
  };
  hesaplar: { id: number; ad: string; iban: string; kaynak: number }[];
}

export interface BankaOneri {
  tur?: 'tahsilat' | 'tediye' | 'virman' | 'pos' | 'masraf' | 'yoksay';
  tarafId?: number; tarafAd?: string; belgeId?: number; belgeNo?: string;
  hedefHesapId?: number; hedefHesapAd?: string; masrafId?: number;
  guven?: number; neden?: string; secim?: boolean; islenen?: string;
}

export interface BankaHareketDetayi {
  hareket: {
    id: number; hesapId: number; hesapAd: string; bankaIslemNo: string; islemTarihi: string; valorTarihi: string | null;
    tutar: number; dovizCinsi: string; bakiye: number | null; aciklama: string; karsiAd: string; karsiIban: string;
    karsiVkn: string; faturaMetni: string; sinif: string; durum: number; kaynak: number; oneri: BankaOneri;
    kasaIslemId: number | null; kasaIslemNo: string | null;
  };
  hesaplar: { id: number; ad: string; tur: string }[];
  masraflar: { id: number; ad: string }[];
}

export interface BankaKarar {
  tur?: string; tarafId?: number | null; belgeId?: number | null; hedefHesapId?: number | null; masrafId?: number | null;
  ibanEkle?: boolean; kural?: string;
}

export const bankaHareketUclari = {
  bankaOzet: (hesapId?: number | null) =>
    istek<BankaOzeti>(`/api/banka-hareket/ozet${hesapId ? `?hesapId=${hesapId}` : ''}`),
  bankaHareket: (id: number) => istek<BankaHareketDetayi>(`/api/banka-hareket/${id}`),
  bankaCek: (hesapId?: number | null, bas?: string, bit?: string) =>
    gonder<{ sonuclar: { mesaj?: string; hata?: string; yeni?: number; benzetim?: boolean }[] }>(
      '/api/banka-hareket/cek', { hesapId: hesapId || null, bas: bas || null, bit: bit || null }),
  bankaIsle: (id: number, karar: BankaKarar) =>
    gonder<{ kasaIslemId: number }>(`/api/banka-hareket/${id}/isle`, karar),
  bankaTopluIsle: (idler: number[]) =>
    gonder<{ islenen: number; hatalar: string[] }>('/api/banka-hareket/isle-toplu', { idler }),
  bankaYoksay: (id: number) => gonder<{ tamam: boolean }>(`/api/banka-hareket/${id}/yoksay`, {}),
  bankaGeriAl: (id: number) => gonder<{ tamam: boolean }>(`/api/banka-hareket/${id}/geri-al`, {}),
  bankaOneriYenile: (hesapId?: number | null) =>
    gonder<{ yenilenen: number }>('/api/banka-hareket/oneri-yenile', { hesapId: hesapId || null }),
};
