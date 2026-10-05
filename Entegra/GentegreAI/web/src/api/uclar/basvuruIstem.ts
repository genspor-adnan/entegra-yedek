import { gonder, istek } from '../cekirdek';

/**
 * BAŞVURU → İSTEM BANKO KAPISI (912). Poliklinikte hekimin açtığı lab/radyoloji
 * isteği başvuruda "ücretlendirme bekliyor" (serbest=0) durur; banko serbest
 * bırakınca çalışma listelerine düşer. Ödeme ayrı - serbest = ücretlendirildi/
 * kabule hazır, tahsilat sonraya kalabilir.
 */
export interface BekleyenIstem {
  tur: 'lab' | 'radyoloji' | 'goz'; id: number; oncelik: number; tetkik: string; kategori: string;
  /** Başvurunun kurum fiyat listesinden birim fiyat toplamı (ücretlendirmeyle AYNI kural). */
  fiyat: number;
  /** Sözleşme iskontosu (%): lab / görüntüleme ayrı. */
  iskonto: number;
  /** Ücrete eklenince yazılacak tutar (iskontolu). */
  tutar: number;
  /** Tetkiğin fiyatlanacak hizmet kartı tanımsız. */
  hizmetYok: boolean;
  /** Hizmet(ler) zaten başvuruda ücretli - tekrar eklenmez. */
  ucrette: boolean;
}
export interface BekleyenIstemYaniti {
  lab: BekleyenIstem[];
  radyoloji: BekleyenIstem[];
  /** Göz görüntüleme istemleri (974). */
  goz?: BekleyenIstem[];
  toplam: number;
  /** Ödeyen kurum ve sözleşme adı (fiyatın dayanağı). */
  kurum?: string;
  sozlesme?: string;
}

export const basvuruIstemUclari = {
  /** Başvurunun banko ücretlendirmesi bekleyen (serbest=0) istemleri. */
  basvuruBekleyenIstem: (belgeId: number) =>
    istek<BekleyenIstemYaniti>(`/api/basvuru/${belgeId}/bekleyen-istem`),

  /** Bekleyen istemleri serbest bırak (id verilmezse tümü). */
  basvuruIstemSerbest: (belgeId: number, ids?: { lab?: number[]; radyoloji?: number[]; goz?: number[] }) =>
    gonder<{ lab: number; radyoloji: number; goz: number; toplam: number; mesaj: string }>(
      `/api/basvuru/${belgeId}/istem-serbest`,
      { labIstemIdler: ids?.lab ?? null, radyolojiIstemIdler: ids?.radyoloji ?? null, gozIstemIdler: ids?.goz ?? null }),

  /** Doktor istemlerini ücretlendir: bekleyen istemlerin hizmetlerini ücret
   *  satırı olarak başvuruya ekler (fiyat + iskonto + karşılama); istemler
   *  serbest kalır (worklist'e düşer). */
  basvuruIstemUcretlendir: (belgeId: number, ids?: { lab?: number[]; radyoloji?: number[]; goz?: number[] }) =>
    gonder<{ eklenen: number; mesaj: string }>(`/api/basvuru/${belgeId}/istem-ucretlendir`,
      { labIstemIdler: ids?.lab ?? null, radyolojiIstemIdler: ids?.radyoloji ?? null, gozIstemIdler: ids?.goz ?? null }),
};
