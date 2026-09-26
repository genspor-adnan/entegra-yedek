import { gonder, istek } from '../cekirdek';

/**
 * BAŞVURU → İSTEM BANKO KAPISI (912). Poliklinikte hekimin açtığı lab/radyoloji
 * isteği başvuruda "ücretlendirme bekliyor" (serbest=0) durur; banko serbest
 * bırakınca çalışma listelerine düşer. Ödeme ayrı - serbest = ücretlendirildi/
 * kabule hazır, tahsilat sonraya kalabilir.
 */
export interface BekleyenIstem { tur: 'lab' | 'radyoloji'; id: number; oncelik: number; tetkik: string }
export interface BekleyenIstemYaniti {
  lab: BekleyenIstem[];
  radyoloji: BekleyenIstem[];
  toplam: number;
}

export const basvuruIstemUclari = {
  /** Başvurunun banko ücretlendirmesi bekleyen (serbest=0) istemleri. */
  basvuruBekleyenIstem: (belgeId: number) =>
    istek<BekleyenIstemYaniti>(`/api/basvuru/${belgeId}/bekleyen-istem`),

  /** Bekleyen istemleri serbest bırak (id verilmezse tümü). */
  basvuruIstemSerbest: (belgeId: number, ids?: { lab?: number[]; radyoloji?: number[] }) =>
    gonder<{ lab: number; radyoloji: number; toplam: number; mesaj: string }>(
      `/api/basvuru/${belgeId}/istem-serbest`,
      { labIstemIdler: ids?.lab ?? null, radyolojiIstemIdler: ids?.radyoloji ?? null }),

  /** Doktor istemlerini ücretlendir: bekleyen istemlerin hizmetlerini ücret
   *  satırı olarak başvuruya ekler (fiyat + iskonto + karşılama); istemler
   *  serbest kalır (worklist'e düşer). */
  basvuruIstemUcretlendir: (belgeId: number) =>
    gonder<{ eklenen: number; mesaj: string }>(`/api/basvuru/${belgeId}/istem-ucretlendir`, {}),
};
