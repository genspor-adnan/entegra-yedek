import { gonder, istek } from '../cekirdek';

/**
 * GEBELİK DOSYASI VE GEBE İZLEMİ (900 — KTS maddesi H10, USS 221).
 *
 * İzlem DOSYAYA bağlıdır: "kaçıncı izlem" ancak bir gebelik içinde
 * anlamlıdır. Aynı hastada aynı anda tek açık dosya olur.
 *
 * <b>Kilo KİLOGRAM gider</b> - 209'daki gram çevrimi burada yoktur.
 */
export interface GebelikDosyasi {
  id: number; sat: string | null; beklenenDogum: string | null;
  tahminiDogum: string | null; hafta: number | null;
  gebelikNo: number; riskDurumu: number;
  /** 1 devam · 2 sonuçlandı · 0 iptal. */
  durum: number; sonucTarihi: string | null;
  izlemSayisi: number; aciklama: string;
  oncekiDogum: number | null;
  /** SAT + önceki doğum durumu varsa 223 gönderilebilir. */
  bildirimeHazir: boolean;
}

export interface GebeIzlemi {
  id: number; kacinciIzlem: number; izlemTarihi: string; hafta: number | null;
  boyCm: number | null; kiloKg: number | null;
  sistolik: number | null; diastolik: number | null;
  fetusKalpSesi: number | null; hemoglobin: number | null;
  idrarProtein: number | null; gdm: number | null;
  demir: number | null; dVitamini: number | null; anomali: number | null;
  riskSayisi: number; oneri: string;
  durum: number; iptalNeden: string; enabizDurum: number;
}

/** Gebelik sonucu (902 - USS 224). Sonuç yalnız doğum değildir. */
export interface GebelikSonucu {
  id: number; gebelikId: number; sonlanmaTarihi: string;
  sonlanmaHaftasi: number | null; sonuc: number;
  dogumYontemi: number | null; canliBebek: number | null; oluBebek: number | null;
  enabizDurum: number; durum: number;
}

export const gebelikUclari = {
  gebelikGecmisi: (hastaId: number) =>
    istek<{ dosyalar: GebelikDosyasi[]; acikGebelikId: number | null;
            izlemler: GebeIzlemi[]; sonraki: number; sonuclar: GebelikSonucu[] }>(
      `/api/gebelik/hasta/${hastaId}`),

  gebelikAc: (govde: { tarafId: number; sat?: string | null;
                       beklenenDogum?: string | null; gebelikNo?: number;
                       riskDurumu?: number; aciklama?: string;
                       /** 223'ün zorunlu ögesi: SKRS bir önceki doğum durumu. */
                       oncekiDogum?: number }) =>
    gonder<{ id: number; hafta: number | null; mesaj: string }>('/api/gebelik', govde),

  gebelikKapat: (id: number, govde: { sonucTarihi?: string | null; aciklama?: string }) =>
    gonder<{ mesaj: string }>(`/api/gebelik/${id}/kapat`, govde),

  /** Sonuç kaydı dosyayı KAPATIR ve 224 paketini doğurur. */
  gebelikSonucla: (gebelikId: number, govde: {
      sonuc: number; sonlanmaTarihi?: string; belgeId?: number | null;
      dogumYontemi?: number; dogumYeri?: number; dogumaYardim?: number;
      canliBebek?: number; oluBebek?: number;
      sezaryanEndikasyon?: number; endikasyonNeden?: number; aciklama?: string }) =>
    gonder<{ id: number; gebelikId: number; mesaj: string }>(
      `/api/gebelik/${gebelikId}/sonuc`, govde),

  gebeIzlemEkle: (govde: {
      gebelikId: number; kacinciIzlem: number; belgeId?: number | null;
      muayeneId?: number | null; islemTuru?: number; izlemTarihi?: string;
      boyCm?: number | null; kiloKg?: number | null;
      sistolik?: number | null; diastolik?: number | null;
      fetusKalpSesi?: number | null; hemoglobin?: number | null;
      idrarProtein?: number; gdm?: number; demir?: number; dVitamini?: number;
      anomali?: number; riskler?: number[]; oneri?: string; aciklama?: string }) =>
    gonder<{ id: number; hafta: number | null; mesaj: string }>(
      '/api/gebelik/izlem', govde),
};
