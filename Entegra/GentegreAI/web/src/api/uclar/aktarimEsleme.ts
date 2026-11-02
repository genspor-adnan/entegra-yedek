import { gonder, istek } from '../cekirdek';

/**
 * SKRS EŞLEME MASASI UÇLARI (1222, mockup Ekranlar/Aktarim/skrs_esleme_masasi.html). Eski HBYS hizmetleri Bakanlık
 * (SUT) listesine bağlanır; liste satırları jenerik liste kaynağından (aktarim-esleme-hizmet) gelir.
 */
export interface EslemeAdayi { kod: string; ad: string; puan: number; dikkat: string | null }
export interface EslemeSatiri {
  id: number; kayitId: number; eskiKod: string; eskiAd: string; tur: string; modalite: number | null; kullanim: number;
  adaylar: string; durum: number;
  /** Yön ailesi önerisi (1232) - JSON {kok, seed, varyant:[{kod, ad, yon, kontrastli}]}; boşsa ''. */
  aile: string; uygulandi: number; secilenKod: string; secilenAd: string; notlar: string;
  fiyatSatiri: number; ayniKodlu: string; liste: EslemeListesi;
}
export interface EslemeAilesi {
  kok: string; seed: string; varyant: { kod: string; ad: string; yon: number; kontrastli: number }[];
}
export interface EslemeOnizleme {
  onayli: number; aile: number; ozel: number; bekleyen: number; adayYok: number; birlesen: number; belgeSatiri: number; uygulanmis: number;
}

/** Masa listesi (1222 hizmet · 1224 bölüm / branş). */
export type EslemeListesi = 'hizmet' | 'bolum' | 'brans';
const lq = (l?: EslemeListesi) => (l && l !== 'hizmet' ? `liste=${l}` : '');

export const aktarimEslemeUclari = {
  eslemeDoldur: (liste?: EslemeListesi) => gonder<{ satir: number }>(`/api/aktarim/esleme/doldur?${lq(liste)}`, {}),
  eslemeSatiri: (id: number) => istek<{ satir: EslemeSatiri }>(`/api/aktarim/esleme/${id}`),
  /** durum: 0 bekliyor · 1 onayla (kod) · 2 kuruma özel · 3 aday yok · 4 yön ailesi (kod = ailenin bir üyesi). */
  eslemeKarar: (id: number, durum: number, kod?: string, not?: string) =>
    gonder<unknown>(`/api/aktarim/esleme/${id}/karar`, { durum, kod: kod ?? null, not: not ?? null }),
  eslemeTopluOnay: (esik?: number, idler?: number[], liste?: EslemeListesi) =>
    gonder<{ onaylanan: number }>(`/api/aktarim/esleme/toplu-onay?${lq(liste)}`, { esik: esik ?? null, idler: idler ?? null }),
  /** Bölüm (departman) / SKRS branş arama (1224). */
  eslemeHedefAra: (liste: EslemeListesi, q: string) =>
    istek<{ satirlar: { kod: string; ad: string; puan: number }[] }>(
      `/api/aktarim/esleme/hedef-ara?liste=${liste}&q=${encodeURIComponent(q)}`),
  eslemeSutAra: (q: string, tur?: string) =>
    istek<{ satirlar: { kod: string; ad: string; tip: string; puan: number }[] }>(
      `/api/aktarim/esleme/sut-ara?q=${encodeURIComponent(q)}${tur ? `&tur=${encodeURIComponent(tur)}` : ''}`),
  eslemeOnizleme: (liste?: EslemeListesi) => istek<{ onizleme: EslemeOnizleme }>(`/api/aktarim/esleme/onizleme?${lq(liste)}`),
  eslemeUygula: (liste?: EslemeListesi) => gonder<{ sonuc: string }>(`/api/aktarim/esleme/uygula?${lq(liste)}`, {}),
};
