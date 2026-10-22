import { gonder, istek } from '../cekirdek';

/** Kişisel hatırlatma satırı (HatirlatmaUclari, 1139). zamanYerel = şube yerel "yyyy-MM-ddTHH:mm". */
export type Hatirlatma = {
  id: number; baslik: string; notu: string; zaman: string; zamanYerel: string;
  uyarDk: number; uyariZamani: string; oncelik: number; renk: number; etiket: string;
  /** 0 yok · 1 her gün · 2 haftalık · 3 aylık · 4 yıllık · 5 iş günleri */
  tekrar: number; tekrarAralik: number; tekrarGunler: number; tekrarBitis?: string | null; tekrarMetni: string;
  kanalUygulama: boolean; kanalSms: boolean; kanalEposta: boolean;
  kaynak: string; kaynakId?: number | null; kaynakAd: string;
  sahipId: number; sahip: string; benim: boolean; acik: boolean; tamamlanma?: string | null;
  erteleSayisi: number; paylasim: number; gecikmis: boolean;
};

export type HatirlatmaDetay = {
  satir: Hatirlatma;
  paylasimDepartmanId?: number | null; herkesKapatir: boolean; paylasilanDuzenler: boolean; paylasimDepartman: string;
  paylasilanlar: { id: number; ad: string; tamam: boolean }[];
  hareketler: { zaman: string; olay: string; olayKod: number; ayrinti: string; kullanici: string }[];
};

export type HatirlatmaYazma = {
  baslik: string; notu: string; zaman: string; uyarDk: number; oncelik: number; renk: number; etiket: string;
  tekrar: number; tekrarAralik: number; tekrarGunler: number; tekrarBitis: string | null;
  kanalUygulama: boolean; kanalSms: boolean; kanalEposta: boolean;
  kaynak: string; kaynakId: number | null; kaynakAd: string;
  paylasim: number; paylasimDepartmanId: number | null; herkesKapatir: boolean; paylasilanDuzenler: boolean;
  paylasilanlar: number[];
};

export type HatirlatmaOzeti = { gecikmis: number; bugun: number; hafta: number; tekrar: number; acik: number; tamamAy: number };

const Y = '/api/hatirlatma';

export const hatirlatmaUclari = {
  hatirlatmalar: (cip: string, ara = '') =>
    istek<Hatirlatma[]>(`${Y}?${new URLSearchParams({ cip, ara })}`),
  hatirlatmaOzet: () => istek<HatirlatmaOzeti>(`${Y}/ozet`),
  hatirlatmaZil: () => istek<Hatirlatma[]>(`${Y}/zil`),
  hatirlatmaTakvim: (ay: string) => istek<{ gun: number; adet: number; gecikmis: number }[]>(`${Y}/takvim?ay=${ay}`),
  hatirlatmaKayit: (kaynak: string, id: number) =>
    istek<Hatirlatma[]>(`${Y}/kayit?${new URLSearchParams({ kaynak, id: String(id) })}`),
  hatirlatma: (id: number) => istek<HatirlatmaDetay>(`${Y}/${id}`),
  hatirlatmaEkle: (g: HatirlatmaYazma) => gonder<{ id: number }>(Y, g),
  hatirlatmaGuncelle: (id: number, g: HatirlatmaYazma) => gonder<{ id: number }>(`${Y}/${id}`, g, 'PUT'),
  hatirlatmaSil: (id: number) => istek<void>(`${Y}/${id}`, { method: 'DELETE' }),
  hatirlatmaTamamla: (id: number) => gonder<{ kapandi: boolean; sonuc: string }>(`${Y}/${id}/tamamla`, {}),
  hatirlatmaAc: (id: number) => gonder<{ id: number }>(`${Y}/${id}/ac`, {}),
  /** dakika: şimdiden itibaren; zaman: şube yerel "yyyy-MM-ddTHH:mm". */
  hatirlatmaErtele: (id: number, e: { dakika?: number; zaman?: string }) => gonder<{ id: number }>(`${Y}/${id}/ertele`, e),
  hatirlatmaKopyala: (id: number) => gonder<{ id: number }>(`${Y}/${id}/kopyala`, {}),
  hatirlatmaKisiler: (ara: string) => istek<{ id: number; ad: string }[]>(`${Y}/kisiler?ara=${encodeURIComponent(ara)}`),
  hatirlatmaBirimler: () => istek<{ id: number; ad: string }[]>(`${Y}/birimler`),
};
