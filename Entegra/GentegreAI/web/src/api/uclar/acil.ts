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

  /** Yatak kartı düğmesi (1118): 0 kullanıma aç / temizlik bitti · 2 temizliğe al · 3 kullanım dışı. */
  acilYatakDurum: (yatakId: number, durum: 0 | 2 | 3, not?: string) =>
    gonder<{ durum: number }>(`/api/acil/yatak/${yatakId}/durum`, { durum, not }),

  /** Yatak kartı sekmeleri (1118): yataktaki hasta, özet, kullanım geçmişi, temizlik / bakım. */
  acilYatakAyrinti: (yatakId: number) => istek<AcilYatakAyrinti>(`/api/acil/yatak/${yatakId}/ayrinti`),
};

export interface AcilYatakAyrinti {
  hasta: { basvuruId: number; protokolNo: string; triyaj: number; hastaAd: string; hekimAd: string;
           sikayet: string; giris: string | null; yerlesme: string | null } | null;
  ozet: { bugunKullanim: number; ortKalisDk: number | null; ortTemizlikDk: number | null; doluluk7: number | null };
  gecmis: { basvuruId: number; giris: string; cikis: string | null; kalisDk: number | null; protokolNo: string;
            triyaj: number; cikisSekli: number; tasindi: boolean; hastaAd: string }[];
  temizlik: { tur: number; baslama: string; bitis: string | null; sureDk: number | null; not: string; yapan: string }[];
}
