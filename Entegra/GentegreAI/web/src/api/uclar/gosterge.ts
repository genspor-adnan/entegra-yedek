import { istek } from '../cekirdek';

/** Gösterge kutusu / bloğu (1103, fn_gosterge_kutu / fn_gosterge_blok - Ana Sayfa profil paneliyle aynı biçim). */
export interface GostergeKutu {
  kod: string; baslik: string; deger: number | string; alt?: string; vurgu?: string; rota?: string; bicim?: string;
}
export interface GostergeBlok {
  kod: string; baslik: string; ipucu?: string; kolonlar: string[]; bicimler?: string[]; satirlar: string[][];
}
export interface GostergePaneliOzet { kod: string; ad: string; ikon: string; aciklama: string; ilk: GostergeKutu | null }
export interface BaslangicKutucugu {
  ad: string; ikon: string;
  satirlar: { yol: string; ad: string; gosterge?: string; deger?: GostergeKutu | null }[];
}

export const gostergeUclari = {
  /** Kullanıcının rol yetki matrisine göre görebildiği paneller (+ ilk gösterge). */
  gostergeler: () => istek<GostergePaneliOzet[]>('/api/gosterge'),
  gostergePaneli: (kod: string) =>
    istek<{ kod: string; ad: string; ikon: string; aciklama: string; kutular: GostergeKutu[]; bloklar: GostergeBlok[] }>(
      `/api/gosterge/${encodeURIComponent(kod)}`),
  /** Rollerin elle düzenlenmiş Başlangıç kutucukları (boşsa ekran menüden öneri çizer). */
  baslangic: () => istek<BaslangicKutucugu[]>('/api/baslangic'),
  /** Sade başlangıç "Bekleyen işler" - oturumun kişisine (16.10.2026). */
  baslangicBekleyen: () => istek<{ konsultasyon: number; konsultasyonGecikmis: number; istemSonuc: number;
                                   randevu: number; randevuBekleyen: number;
                                   /** Onayımdakiler: kararı bende olan basamaklar (+ geciken). */
                                   onay: number; onayGeciken: number }>('/api/baslangic/bekleyen'),
};
