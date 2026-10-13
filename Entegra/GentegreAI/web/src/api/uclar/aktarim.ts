import { gonder, istek } from '../cekirdek';

/** Delphi aktarımı - Aktarım Durumu ekranı (AktarimUclari, 1090). */
export type AktarimAdimi = {
  sira: number; fonksiyon: string; tablolar: string[];
  /** Adımın tablolarındaki en düşük CT versiyonu (null: hiç yüklenmedi). */
  versiyon: number | null; eksikTablo: number; sonPaket: string | null; bugunSatir: number; hata: boolean;
};
export type AktarimHatasi = {
  id: number; adim: string; sira: number; tablolar: string[]; mesaj: string; deneme: number; ilk: string; son: string;
};
export type AktarimPaketi = {
  alinma: string; sureMs: number; durum: number; hata: string | null; yazilan: number;
  ozet: Record<string, { U: number; D: number }> | null;
};
export type AktarimDurumu = {
  veriKaynagi: string; hareketBaslangic: string | null; sonPaket: string | null;
  ajanlar: { id: number; ad: string; aktif: number; olusturma: string; sonNabiz: string | null; surum: string | null }[];
  bugun: { paket: number; satir: number; silme: number; ortMs: number; hatali: number };
  adimlar: AktarimAdimi[]; hatalar: AktarimHatasi[]; sonPaketler: AktarimPaketi[];
  /** Tablo başına son mutabakat (1091). */
  mutabakat: { tablo: string; zaman: string; delphi: number; web: number; eksik: number; fazla: number;
               giderilen: number; atlanan: number; ornek: { eksik?: number[]; fazla?: number[] } | null }[];
};

export const aktarimUclari = {
  aktarimDurumu: () => istek<AktarimDurumu>('/api/aktarim-yonetim/durum'),
  aktarimHataHam: (id: number) => istek<unknown>(`/api/aktarim-yonetim/hata/${id}/ham`),
  aktarimHataCozuldu: (id: number) => istek<{ id: number }>(`/api/aktarim-yonetim/hata/${id}/cozuldu`, { method: 'POST' }),
};

/** Kurum Profili › Veri Kaynağı (adım 6d). Ajan anahtarı yalnız üretildiği yanıtta döner. */
export type AktarimProfili = {
  veriKaynagi: 'web' | 'delphi'; hareketBaslangic: string | null; varsayilanSube: string | null;
  subeEsleme: { delphiSube: number; subeId: number; subeAd: string }[];
  ajanlar: AktarimDurumu['ajanlar'];
};

export const aktarimProfilUclari = {
  aktarimProfili: () => istek<AktarimProfili>('/api/kurum-profil/aktarim'),
  aktarimProfiliYaz: (govde: { veriKaynagi?: 'web' | 'delphi'; hareketBaslangic?: string }) =>
    gonder<{ tamam: boolean }>('/api/kurum-profil/aktarim', govde, 'PUT'),
  aktarimAjanEkle: (ad: string) => gonder<{ anahtar: string }>('/api/kurum-profil/aktarim/ajan', { ad }),
  aktarimAjanPasif: (id: number) => istek<{ id: number }>(`/api/kurum-profil/aktarim/ajan/${id}/pasif`, { method: 'POST' }),
};
