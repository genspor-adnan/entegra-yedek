import { istek } from '../cekirdek';

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
};

export const aktarimUclari = {
  aktarimDurumu: () => istek<AktarimDurumu>('/api/aktarim-yonetim/durum'),
  aktarimHataHam: (id: number) => istek<unknown>(`/api/aktarim-yonetim/hata/${id}/ham`),
  aktarimHataCozuldu: (id: number) => istek<{ id: number }>(`/api/aktarim-yonetim/hata/${id}/cozuldu`, { method: 'POST' }),
};
