import { gonder, istek } from '../cekirdek';

/**
 * ARIZA / TALEP UÇLARI (hizmet masası, 911).
 *
 * Demirbaşa bağlı OLMAYAN genel arıza (klima, pencere, PC, masa): herkes
 * self-servis açar, kategori SORUMLU EKİBE yönlendirir, ekip devralır →
 * çözer → kapatır. Yönlendirme ve durum geçişleri SUNUCUDA (fn_ariza_talep_ac
 * + akış uçları); istemci yalnız formu ve düğmeyi uca bağlar.
 */

export interface ArizaSecenek { deger: number; ad: string }
export interface ArizaSecenekleri {
  kategoriler: ArizaSecenek[];
  oncelikler: ArizaSecenek[];
}

export const arizaUclari = {
  /** Self-servis formun kategori + öncelik seçenekleri (kod_deger). */
  arizaSecenekler: () => istek<ArizaSecenekleri>('/api/ariza/secenekler'),

  /** Talep aç; kategoriye göre ekip otomatik atanır, AT-NNNNNN üretilir. */
  arizaTalepAc: (g: {
    kategori: number; aciklama: string; konum?: string;
    oncelik?: number; demirbasId?: number | null;
  }) => gonder<{ id: number; talepNo: string; mesaj: string }>(
      '/api/ariza/talep', g),

  /** Ekip devralır: sorumlu = ben, durum İşlemde. */
  arizaDevral: (id: number) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/devral`, {}),

  /** Başka personele ata. */
  arizaAta: (id: number, sorumluId: number) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/ata`, { sorumluId }),

  /** Çöz: çözüm notu zorunlu. */
  arizaCoz: (id: number, notu: string) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/coz`, { notu }),

  /** Kapat. */
  arizaKapat: (id: number) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/kapat`, {}),
};
