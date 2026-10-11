import { gonder, istek } from '../cekirdek';

/** Kasa / gün sonu mutabakatı (KasaGunSonuUclari). Rakamlar sunucuda hesaplanır. */
export type FarkAciklamasi = { neden: number; nedenAd: string; aciklama: string; fark: number; giren: string };
export type GunSonuKasa = {
  id: number; ad: string; kod: string; banko: boolean; devir: number; giris: number; cikis: number; transfer: number;
  beklenen: number; sayilan?: number | null; fark?: number | null; durum: string; sorumlu: string; acik: boolean;
  sayimGerekli: boolean; kirilim: { ad: string; adet: number; tutar: number }[]; kalem: string; aciklama?: FarkAciklamasi | null;
};
export type GunSonuPos = {
  id: number; ad: string; terminal: string; banko: string; adet: number; sistem: number; batchAdet?: number | null;
  batch?: number | null; kaynak: '' | 'elle' | 'oturum'; fark?: number | null; durum: string; kalem: string; aciklama?: FarkAciklamasi | null;
};
export type GunSonuBanka = {
  id: number; ad: string; iban: string; yatisBeklenen: number; yatisGerceklesen?: number | null; havaleAdet: number;
  havaleSistem: number; havaleEkstre?: number | null; fark?: number | null; durum: string; kalem: string; aciklama?: FarkAciklamasi | null;
};
export type GunSonu = {
  tarih: string;
  kapanis?: { kapali: boolean; kapanisZamani: string; kapatan: string; acilisZamani?: string | null; acan: string; gerekce: string } | null;
  onceki?: { tarih: string; kapali: boolean; zaman: string; kapatan: string } | null;
  ozet: {
    devir: number; girisNakit: number; cikisNakit: number; makbuz: number; beklenen: number; sayilan: number; sayilanBeklenen: number;
    kasaFark: number; sayilanAdet: number; kasaAdet: number; pos: number; posAdet: number; posBatch: number; posBatchSistem: number;
    posFark: number; posBekleyen: string[]; havale: number; havaleAdet: number; havaleEkstre: number; bankaFark: number;
    bankayaYatirilan: number; ertesiGunDevri: number; ertesiKesin: boolean; acikOturum: number;
  };
  kasalar: GunSonuKasa[]; poslar: GunSonuPos[]; bankalar: GunSonuBanka[];
  hareketler: { islemId: number; zaman: string; hesap: string; hesapTuru: string; tur: number; turAdi: string; tutar: number;
                belgeNo: string; aciklama: string; kullanici: string }[];
  farklar: { kalem: string; tur: string; ad: string; fark: number; sorumlu: string; aciklama?: FarkAciklamasi | null; engel: boolean }[];
  engeller: string[];
  nedenler: { kod: number; ad: string }[];
};

type T = { tamam: boolean };
export const kasaGunSonuUclari = {
  kasaGunSonu: (tarih: string) => istek<GunSonu>(`/api/kasa-gun-sonu?tarih=${tarih}`),
  kasaGunSayim: (g: { tarih: string; hesapId: number; sayilan: number; aciklama?: string }) => gonder<T>('/api/kasa-gun-sonu/sayim', g),
  kasaGunPos: (g: { tarih: string; hesapId: number; adet: number; tutar: number | null }) => gonder<T>('/api/kasa-gun-sonu/pos', g),
  kasaGunBanka: (g: { tarih: string; hesapId: number; yatis: number | null; havale: number | null }) => gonder<T>('/api/kasa-gun-sonu/banka', g),
  kasaGunFark: (g: { tarih: string; kalem: string; fark: number; neden: number; aciklama: string }) => gonder<T>('/api/kasa-gun-sonu/fark', g),
  kasaGunKapat: (tarih: string) => gonder<T>('/api/kasa-gun-sonu/kapat', { tarih }),
  kasaGunAc: (tarih: string, gerekce: string) => gonder<T>('/api/kasa-gun-sonu/ac', { tarih, gerekce }),
};
