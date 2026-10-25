import { gonder, istek } from '../cekirdek';

/**
 * Döviz Pozisyonu / Kur Farkı İcmali (DovizPozisyonUclari, 1186) - rakamlar sunucuda hesaplanır, ekran toplamaz.
 * Sunucu null alanları yazmaz: `?` işaretli alanlar yoksa "yok / hesaplanamadı" demektir (ör. kuru olmayan döviz).
 */
export type DovizTutar = Record<string, number>;
export type KurFarkiDurumu = 'oneri' | 'aleyhte' | 'kesildi' | 'gerekYok';

export type DovizPozisyonu = {
  tarih: string; donem: string; donemBas: string; donemBit: string;
  kurTuru: 'alis' | 'efektif' | 'satis'; kurAdi: string; sube: number; siparisDahil: boolean; cekDahil: boolean; yerel: string;
  dovizler: string[];
  kurlar: { doviz: string; kur?: number; kurTarihi?: string; eski: boolean; yok: boolean }[];
  ozet: {
    netTl: number; varlikTl: number; yukumlulukTl: number; net: DovizTutar; netDovizTl: DovizTutar; artis10: number;
    gerceklesen: number; cariDegerleme: number; hesapDegerleme: number; degerleme: number;
    faturaAdet: number; faturaSatir: number; faturaTutar: number;
    ortVadeGun?: number; enYakinBorc?: { tarih: string; doviz: string; tutar: number };
    dovizliCari: number; kurYok: number; kurEski: number;
  };
  pozisyon: {
    satirlar: { anahtar: string; kalem: string; varlik: boolean; tutar: DovizTutar; tl: number; adet: number }[];
    varlik: DovizTutar; yukumluluk: DovizTutar; net: DovizTutar; varlikTl: number; yukumlulukTl: number; netTl: number;
  };
  cariler: {
    tarafId: number; kod: string; ad: string; musteri: boolean; tedarikci: boolean; doviz: string; bakiye: number;
    ortKur: number; bugunKur?: number; kayitliTl: number; bugunTl?: number; fark?: number;
  }[];
  kurFarki: { satirlar: { kaynak: string; gelir: number; gider: number; net: number; adet: number; not: string }[]; gerceklesen: number };
  faturalar: KurFarkiSatiri[];
  vade: { dilim: string; ad: string; alacak: DovizTutar; borc: DovizTutar; net: DovizTutar; netTl: number }[];
  duyarlilik: { yuzde: number; senaryo: string; etkiler: DovizTutar; toplam: number }[];
  kurGecmisi: { tarih: string; aySonu: boolean; kurlar: DovizTutar }[];
  secim: { subeler: { id: number; ad: string }[] };
  yetkiler: { kurFarki: boolean };
};

export type KurFarkiSatiri = {
  tarafId: number; cari: string; belgeId: number; belgeNo: string; belgeTarihi: string;
  kapamaAnahtar: string; kapamaNo: string; kapamaTur: string; kapamaTarihi: string;
  doviz: string; tutarDoviz: number; faturaKuru: number; kapamaKuru: number; kurFarki: number;
  durum: KurFarkiDurumu; ihracat: boolean;
  takipId?: number; kesilenBelgeId?: number; kesilenBelgeNo: string; takipAciklama: string; takipAn?: string; takipKim: string;
};

export type KurFarkiIsaret = {
  tarafId: number; belgeId: number; kapamaAnahtar: string; doviz: string; tutarDoviz: number;
  faturaKuru: number; kapamaKuru: number; kurFarki: number;
  /** 1 kesildi · 2 gerek yok */
  durum: 1 | 2; kesilenBelgeNo?: string; aciklama?: string;
};

const Y = '/api/doviz-pozisyon';

export const dovizPozisyonUclari = {
  dovizPozisyonu: (q: URLSearchParams) => istek<DovizPozisyonu>(`${Y}?${q}`),
  /** Kur farkı satırını "kesildi" (kesilen satış faturası no) ya da "gerek yok" işaretler (finans.kur_farki). */
  kurFarkiIsaretle: (g: KurFarkiIsaret) => gonder<{ id: number; kesilenBelgeId?: number }>(`${Y}/kur-farki`, g),
  kurFarkiGeriAl: (takipId: number) => istek<{ silindi: boolean }>(`${Y}/kur-farki/${takipId}`, { method: 'DELETE' }),
};
