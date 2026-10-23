import { istek } from '../cekirdek';

/** Kasa Listesi / Kartı V3 (KasaListeUclari, 1161). */
export interface KasaGostergesi {
  aktif: number; sube: number; nakit: number; sayimBekleyen: number; farkli: number; farkToplam: number;
  limitAsan: number; acikOturum: number; bugunGiris: number; bugunCikis: number; bugunAdet: number;
}
export interface KasaSayimi {
  id: number; tarih: string; zaman: string; sayilan: number; aciklama: string; sayan: string; sistem: number; fark: number;
  neden: number; farkAciklama: string;
}
export interface KasaHareketi {
  id: number; tarih: string; turAdi: string; cari: string; belgeNo: string; giris: number; cikis: number; kasaIslemId: number; belgeId: number;
}
export interface KasaKartOzeti {
  ozet: {
    id: number; ad: string; doviz: string; durum: number; altTur: number; bakiye: number; yerelBakiye: number;
    bugunGiris: number; bugunCikis: number; bugunAdet: number; ayNet: number; sonYatirma: string | null;
    sonSayim: string | null; sonSayilan: number | null; sonFark: number | null; sonFarkAciklama: string; bugunSayildi: number;
    acikOturum: number; oturumKisiler: string; guvenlikLimiti: number; sayimZorunlu: number; farkToleransi: number;
    limitYuzde: number | null; yetkili: number; bagliHesap: string; muhHesap: string;
  };
  sayimlar: KasaSayimi[];
  hareketler: KasaHareketi[];
  egilim: { tam: number; toleransIci: number; toleransUstu: number; toplam: number; enBuyuk: KasaSayimi | null };
}

export const kasaListeUclari = {
  kasaGosterge: () => istek<{ gosterge: KasaGostergesi }>('/api/kasa/gosterge'),
  kasaKartOzet: (id: number) => istek<KasaKartOzeti>(`/api/kasa/${id}/ozet`),
};
