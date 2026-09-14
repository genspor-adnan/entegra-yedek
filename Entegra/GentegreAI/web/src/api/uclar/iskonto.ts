import { istek, gonder } from '../cekirdek';
import type { IskontoTalebi, IskontoLimiti } from '../sozlesme';

/**
 * ISKONTO ONAYI (662). Kayit kabul talep acar, yetkili ZILDEN onaylar.
 *
 * Onay/ret yetkisi sunucuda dogrulanir (`basvuru.iskonto` ve TAVAN); istemci
 * yalniz gormedigi dugmeyi cizmez - "bekleyenler" zaten tavani yetmeyen
 * kullaniciya bos doner.
 */
export const iskontoUclari = {
  /** Belgenin talep gecmisi - ucret sekmesindeki durum rozeti. */
  iskontoTalepleri: (belgeId: number) =>
    istek<IskontoTalebi[]>(`/api/iskonto-talep/belge/${belgeId}`),

  /** Zile dusenler: bu kullanicinin onaylayabilecegi bekleyen talepler. */
  iskontoBekleyenler: () =>
    istek<IskontoTalebi[]>('/api/iskonto-talep/bekleyenler'),

  /** SONUCLANANLAR (666): denetim izi - tavan suzmesi YOK. */
  iskontoGecmis: (gun: number) =>
    istek<IskontoTalebi[]>(`/api/iskonto-talep/gecmis?gun=${gun}`),

  /** Rol tavanlari - "bu talep neden bana dustu" (666). */
  iskontoLimitler: () =>
    istek<IskontoLimiti[]>('/api/iskonto-talep/limitler'),

  /**
   * Talep acar. `kalemler` KALEM BAZLI oranlari tasir (664); `oran` yalniz
   * bilgi - sunucu basligi kalemlerin EN YUKSEGINDEN hesaplar.
   */
  iskontoTalepAc: (belgeId: number, oran: number, gerekce: string,
                   kalemler: { satirId: number; oran: number }[]) =>
    gonder<{ id: number }>('/api/iskonto-talep',
      { belgeId, oran, gerekce, kalemler }),

  iskontoOnayla: (id: number, oran: number, not: string) =>
    gonder<{ durum: number }>(`/api/iskonto-talep/${id}/onay`, { oran, not }),

  iskontoReddet: (id: number, not: string) =>
    gonder<{ durum: number }>(`/api/iskonto-talep/${id}/ret`, { oran: 0, not }),
};
