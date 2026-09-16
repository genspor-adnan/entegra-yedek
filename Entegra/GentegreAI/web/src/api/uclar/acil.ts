import { gonder, istek } from '../cekirdek';

/**
 * Acil servis iş akışı uçları (api/AcilUclari, db 716).
 *
 * ŞUBE GÖNDERİLMEZ: sunucu oturumun aktif şubesini kullanır.
 *
 * SÜRE HESABI İSTEMCİDE YAPILMAZ. Kapı-triyaj / kapı-hekim / toplam süre ve
 * hedefe uyum `v_acil_sure`den gelir; ekranda yeniden hesaplasaydık panoda 16,
 * raporda 18 dakika görünürdü (716 kuralı).
 */
export interface AcilSureOzeti {
  kapiTriyajDk: number | null;
  kapiHekimDk: number | null;
  toplamDk: number | null;
  hedefDk: number | null;
  hedefeUyuldu: number | null;
}

export const acilUclari = {
  /** Kart/pano şeridi: süreler, yatak, açık çağrı, bekleyen bildirim. */
  acilSure: (id: number) =>
    istek<Record<string, unknown>>(`/api/acil/basvuru/${id}/sure`),

  /** Yükseltme serbest; DÜŞÜRME ayrı yetki + gerekçe ister (sunucu reddeder). */
  acilTriyaj: (id: number, duzey: number, gerekce?: string, yatakId?: number) =>
    gonder<{ triyaj: number; onceki: number; dusurme: boolean }>(
      `/api/acil/basvuru/${id}/triyaj`, { duzey, gerekce, yatakId }),

  /** "İlk gördü" damgası bir kez yazılır; ikinci çağrıda mevcut korunur. */
  acilHekimGordu: (id: number, hekimId?: number) =>
    gonder<{ zatenVardi: boolean; sure: AcilSureOzeti }>(
      `/api/acil/basvuru/${id}/hekim`, { hekimId }),

  /** yatakId boş ise yatak BOŞALTILIR (eski yatak temizliğe düşer). */
  acilYatak: (id: number, yatakId: number | null) =>
    gonder<{ yatakId: number | null }>(`/api/acil/basvuru/${id}/yatak`, { yatakId }),

  /** Tanı zorunlu, sevk ayrı yetki, yatak temizliğe düşer - hepsi tek uçta. */
  acilCikis: (id: number, g: {
    cikisSekli: number; cikisTani: string; hedefBolumId?: number | null; cikisNotu?: string;
  }) =>
    gonder<{ cikisSekli: number; yatakTemizlige: boolean; sure: AcilSureOzeti }>(
      `/api/acil/basvuru/${id}/cikis`, g),

  acilCagriAc: (basvuruId: number, g: {
    tur: number; hedefBolumId?: number | null; hedefKisiId?: number | null; notMetni?: string;
  }) =>
    gonder<{ cagriId: number }>(`/api/acil/basvuru/${basvuruId}/cagri`, g),

  /** durum: 1 yanıtlandı · 2 kapandı · 3 yanıt yok (tekrar sayacı artar). */
  acilCagriYanit: (cagriId: number, durum: number, notMetni?: string) =>
    gonder<{ cagri: { durum: number; tekrarSayi: number; yanitDk: number | null } }>(
      `/api/acil/cagri/${cagriId}/yanit`, { durum, notMetni }),

  /** Temizliği biten yatağı boşa döndürür - kim yaptığı loglanır. */
  acilYatakTemizlendi: (yatakId: number) =>
    gonder<{ durum: number }>(`/api/acil/yatak/${yatakId}/temizlendi`, {}),
};
