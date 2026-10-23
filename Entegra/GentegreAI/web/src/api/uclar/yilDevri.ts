import { gonder, istek } from '../cekirdek';

/** YIL SONU / BAŞI DEVRİ (1155, mockup Ekranlar/Muhasebe/yil_sonu_devir.html). */

export interface DevirKontrol {
  sira: number; kod: string; ad: string; tur: 'engel' | 'uyari' | 'bilgi';
  adet: number; tutar: number | null; aciklama: string; rota: string;
}

export interface DevirDegerleme {
  kaynak: 'cari' | 'hesap'; kaynakId: number; ad: string; alt: string; doviz: string;
  dovizBakiye: number; yerelBakiye: number; kur: number | null; degerli: number; fark: number; hesap: string | null;
}

export interface DevirFis {
  adim: number; id: number; fisNo: string; tarih: string; tur: number; aciklama: string;
  borc: number; alacak: number;
  satirlar: { kod: string; ad: string; borc: number; alacak: number; adet: number }[];
}

export interface DevirDurumu {
  yil: number;
  devir: null | {
    id: number; kaynakYil: number; hedefYil: number; tamamAdim: number; durum: number;
    secenekler: Record<string, unknown>; baslama: string; bitis: string | null; baslatan: string;
  };
  gunluk: { adim: number; islem: 'yap' | 'geri' | 'not'; aciklama: string; zaman: string; kullanici: string }[];
  fisler: DevirFis[];
  donem: { yil: number; durum: number }[];
}

export interface DevirSecenek { cari?: boolean; hesap?: boolean; bilanco?: boolean; izin?: boolean; kilit?: boolean }

export interface DevirOnizleme {
  fisler: DevirFis[];
  kayitlar: { tur: string; adet: number }[];
  sablonlar: { tur: number; turAdi: string; onEk: string; baslamaNo: string; eskiNo: string | null }[];
}

export const yilDevriUclari = {
  yilDevri: (yil?: number) => istek<DevirDurumu>(`/api/yil-devri${yil ? `?yil=${yil}` : ''}`),
  yilDevriKontrol: (yil: number) => istek<DevirKontrol[]>(`/api/yil-devri/kontrol?yil=${yil}`),
  yilDevriDegerleme: (yil: number) => istek<DevirDegerleme[]>(`/api/yil-devri/degerleme?yil=${yil}`),
  yilDevriOnizle: (yil: number, adim: number, s: DevirSecenek) =>
    gonder<DevirOnizleme>('/api/yil-devri/onizle', { yil, adim, ...s }),
  yilDevriAdim: (yil: number, adim: number, s: DevirSecenek) =>
    gonder<DevirDurumu>('/api/yil-devri/adim', { yil, adim, ...s }),
  yilDevriGeriAl: (yil: number) => gonder<DevirDurumu>('/api/yil-devri/geri-al', { yil }),
};
