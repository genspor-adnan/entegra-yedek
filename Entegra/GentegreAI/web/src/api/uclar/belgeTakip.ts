import { dosyaYukle, gonder, istek } from '../cekirdek';

/** İK › Belge Takibi yan uçları (PersonelBelgeTakipUclari, 1135-1137). */
export type BelgeTakipOzeti = {
  eksik: number; eksikKisi: number; doldu: number; dolduKisi: number;
  yaklasan: number; yaklasanKisi: number; personel: number;
};

export const belgeTakipUclari = {
  belgeTakipOzet: () => istek<BelgeTakipOzeti>('/api/ik/belge-takip/ozet'),
  /** Seçili personele eksik / süresi dolan / yaklaşan belgeler (e-posta, yoksa SMS). */
  belgeTakipHatirlat: (personelIds: number[]) =>
    gonder<{ kuyruga: number; atlanan: { ad: string; neden: string }[] }>(
      '/api/ik/belge-takip/hatirlat', { personelIds }),
  /** Belge ekle / değiştir / sil, dosya yükleme ve hatırlatmalar - yeni önce. */
  belgeTakipHareketler: (personelId: number) =>
    istek<{ zaman: string; islem: string; belge: string; ayrinti: string; kullanici: string }[]>(
      `/api/ik/belge-takip/${personelId}/hareketler`),
  /** Belge satırı + dosyası tek adımda (belgeTuruId, belgeTarihi, gecerlilikTarihi, belgeNo, dosya). */
  belgeTakipYukle: (personelId: number, form: FormData) =>
    dosyaYukle<{ id: number }>(`/api/ik/belge-takip/${personelId}/belge`, form),
};
