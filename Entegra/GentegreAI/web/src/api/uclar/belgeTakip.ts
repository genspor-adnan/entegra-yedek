import { dosyaYukle, gonder, istek } from '../cekirdek';

/** İK › Belge Takibi yan uçları (PersonelBelgeTakipUclari, 1135-1137). */
export type BelgeTakipOzeti = {
  eksik: number; eksikKisi: number; doldu: number; dolduKisi: number;
  yaklasan: number; yaklasanKisi: number; personel: number;
};

/** Belge Türleri listesi sayaçları (PersonelBelgeTurUclari, 1138). */
export type BelgeTuruOzeti = {
  aktif: number; zorunlu: number; sureli: number; eksigiOlan: number; istegeBagli: number; pasif: number;
};

/** Kart "👥 Personel durumu" satırı. durum: 1 eksik / dosya yok · 2 doldu · 3 yaklaşıyor · 4 tamam. */
export type BelgeTuruPersonel = {
  personelId: number; ad: string; birim: string; gorev: string;
  belgeTarihi?: string | null; gecerlilikTarihi?: string | null; kalanGun?: number | null;
  dosyaSayisi: number; durum: number; durumAdi: string; zorunlu: boolean; belgeVar: boolean;
  sonHatirlatma?: string | null; sonHatirlatmaKanal: string;
};

export type BelgeTuruKapsamOnizleme = {
  satirlar: { sira: number; eslesen: number; eksik: number }[];
  toplam: { kapsama: number; eksik: number; yeniEksik: number; cikacak: number };
  birimler: { ad: string; sayi: number }[];
};

export type BelgeTuruKartOzeti = {
  kapsam: string; personel: number; tamam: number; eksik: number; doldu: number; yaklasan: number;
  subeId: number; sube: string; eklemeTarihi: string; degistirmeTarihi?: string | null;
  ekleyen: string; degistiren: string;
};

const TUR = '/api/ik/belge-takip/tur';

export const belgeTakipUclari = {
  belgeTuruOzet: () => istek<BelgeTuruOzeti>(`${TUR}/ozet`),
  belgeTuruPersonel: (id: number) => istek<BelgeTuruPersonel[]>(`${TUR}/${id}/personel`),
  belgeTuruKartOzet: (id: number) => istek<BelgeTuruKartOzeti>(`${TUR}/${id}/kart-ozet`),
  /** Kaydedilmemiş kapsam kurallarıyla eşleşen personel (id 0 = yeni kart). */
  belgeTuruKapsamOnizle: (id: number, satirlar: { departmanId: number | null; gorevId: number | null }[]) =>
    gonder<BelgeTuruKapsamOnizleme>(`${TUR}/${id}/kapsam-onizleme`, { satirlar }),
  belgeTuruSablonlar: () => istek<{ id: number; kod: string; ad: string; kanal: number; konu: string;
    govde: string; aktif: boolean }[]>(`${TUR}/sablonlar`),
  belgeTuruHareketler: (id: number) =>
    istek<{ zaman: string; islem: string; ayrinti: string; kullanici: string }[]>(`${TUR}/${id}/hareketler`),
  belgeTuruKopyala: (id: number) => gonder<{ id: number; ad: string; kapsam: number }>(`${TUR}/${id}/kopyala`, {}),
  belgeTuruDurum: (id: number) => gonder<{ aktif: boolean }>(`${TUR}/${id}/durum`, {}),
  belgeTuruSira: (idler: number[]) => gonder<{ degisen: number }>(`${TUR}/sira`, { idler }),

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
