import { gonder, istek } from '../cekirdek';

/**
 * DEMO VERİSİ UÇLARI (964, mockup Ekranlar/Ayarlar/demo_tohum.html).
 *
 * Okuma her kurulumda açık (ekran "DEMO değil" der); yazan uçlar yalnız
 * `kurulum.demo = 1` kurulumda çalışır. Giriş listesi kimliksizdir.
 */
export interface DemoAyar {
  profil: string; kurumAdi: string; sehir: string; tohum: number; olcek: 'kucuk' | 'orta' | 'buyuk'; moduller: string[];
}

export interface DemoDurum {
  demo: boolean;
  ayar: DemoAyar;
  son: { id: number; tetik: string; baslangic: string; bitis: string | null; durum: number; adim: string;
         ozet: string; hata: string | null; tohum: number | null } | null;
  gece: { aktif: number; sonraki: string | null; sonCalisma: string | null; basarili: number | null; sonSonuc: string | null } | null;
  gece7: { toplam: number; basarili: number } | null;
  sahne: { bugunRandevu: number; bekleyen: number; demoKayit: number; hasta: number; personel: number; senaryo: string | null } | null;
  kullanicilar: { kod: string; rol: string; ad: string }[];
  parola: string;
  tanimli: { kod: string; baslik: string; acilis: string }[];
}

export const demoUclari = {
  demoDurum: () => istek<DemoDurum>('/api/demo/durum'),
  demoAyarYaz: (ayar: DemoAyar) => gonder<unknown>('/api/demo/ayar', ayar, 'PUT'),
  /** Temizle + üret (arka planda); temizleYalniz = yalnız sil. */
  demoUret: (temizleYalniz = false) => gonder<{ id: number }>(`/api/demo/uret${temizleYalniz ? '?temizleYalniz=true' : ''}`, {}),
  demoGece: (aktif: boolean) => gonder<unknown>('/api/demo/gece', { aktif }, 'PUT'),
  /** Giriş ekranı "Demo olarak dene" - yalnız DEMO kurulumda dolu. */
  demoGirisler: () => istek<{ demo: boolean; girisler: { kod: string; baslik: string; parola: string }[] }>('/api/demo/girisler'),
};
