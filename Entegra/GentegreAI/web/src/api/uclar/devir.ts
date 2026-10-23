import { gonder, istek } from '../cekirdek';

/** Devir / açılış bakiyesi - tek uç (DevirUclari, 1160; cari için 1156). */
export type DevirTuru = 'cari' | 'kasa' | 'banka' | 'pos' | 'kredi' | 'kredikarti';

export type DevirSatiri = {
  id: number; tarih: string; vade: string | null; belgeNo: string;
  /** İşaretli: cari + borçlu / - alacaklı; hesap + giriş / - çıkış (hesabın para biriminde). */
  tutar: number; doviz: string; kur: number; yerel: number; aciklama: string; delphi: boolean;
};
export type DevirHesabi = {
  id: number; kod: string; ad: string; altBilgi: string; doviz: string;
  // cari
  musteri?: number; tedarikci?: number; vadeGun?: number; riskLimiti?: number;
  // hesap
  durum?: number; acilisBakiye?: number; acilisTarihi?: string | null; komisyonOrani?: number; valorGun?: number;
  bankaBakiye?: number | null; bankaBakiyeZaman?: string | null; limit?: number; hesapKesimGunu?: number; sonOdemeGunu?: number;
  bagliHesap?: string; krediAnapara?: number; krediVadeAy?: number; krediFaiz?: number; krediIlkTaksit?: string | null;
};
export type Devir = {
  tur: DevirTuru; harf: string; turler: DevirTuru[];
  hesap: DevirHesabi;
  /** Eski ad (1156) - hesap ile aynı nesne. */
  cari: DevirHesabi;
  ilkHareket: string | null;
  /** Hesabın hareket bakiyesi (devir dahil, v_hesap_bakiye) - banka API bakiyesi farkı için. */
  hareketBakiye: number;
  varsayilanTarih: string;
  delphiKaynakli: boolean;
  satirlar: DevirSatiri[];
  delphiSatirlari: DevirSatiri[];
  dovizler: string[];
};
export type DevirGirdisi = {
  belgeNo?: string; belgeTarihi?: string | null; vade?: string | null;
  tutar: number; doviz?: string; kur?: number | null; aciklama?: string;
};
export type TopluDevirSonucu = {
  sonuc: { sira: number; tur: string | null; hesap: string; hesapId: number | null; hesapKod: string; hesapAd: string;
           durum: 'hazir' | 'cari_yok' | 'coklu' | 'devir_var' | 'hareket_once' | 'hata'; mesaj: string }[];
  hazir: number; yazilan: number;
};
export type AcilisBakiyesi = {
  id: number; harf: string; tur: string; kod: string; ad: string; doviz: string; acilisBakiye: number;
  acilisTarihi: string | null; hareketBakiye: number; ilkHareket: string | null; devirVar: boolean;
};

export const devirUclari = {
  devirOku: (tur: DevirTuru | 'hesap', id: number) => istek<Devir>(`/api/devir/${tur}/${id}`),
  devirKaydet: (tur: DevirTuru | 'hesap', id: number, g: { tarih: string; satirlar: DevirGirdisi[]; zorla?: boolean }) =>
    istek<{ satir: number; silinen: number; yerel: number }>(`/api/devir/${tur}/${id}`, { method: 'PUT', body: JSON.stringify(g) }),
  devirKur: (doviz: string, tarih: string) =>
    istek<{ kur: number | null }>(`/api/devir/kur?doviz=${encodeURIComponent(doviz)}&tarih=${tarih}`),
  devirToplu: (g: { tarih: string; eslestirme: string; kontrol: boolean;
                    satirlar: { tur?: string; hesap: string; tutar: number; doviz?: string; kur?: number | null; vade?: string | null; belgeNo?: string; aciklama?: string }[] }) =>
    gonder<TopluDevirSonucu>('/api/devir/toplu', g),
  devirAcilisBakiyeleri: () => istek<{ hesaplar: AcilisBakiyesi[] }>('/api/devir/acilis-bakiyeleri'),
  devirAcilisCevir: (idler: number[]) => gonder<{ cevrilen: number; atlanan: { id: number; neden: string }[] }>('/api/devir/acilis-cevir', { idler }),
  // Eski adlar (1156) - kart penceresi.
  cariDevirOku: (id: number) => istek<Devir>(`/api/devir/cari/${id}`),
  cariDevirKur: (doviz: string, tarih: string) =>
    istek<{ kur: number | null }>(`/api/devir/kur?doviz=${encodeURIComponent(doviz)}&tarih=${tarih}`),
};
