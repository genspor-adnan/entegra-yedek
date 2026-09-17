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

  /**
   * ONAY/RET OMURGADAN (754): iskontonun kendi karar ucu yok, talep
   * `belge.iskonto` zincirinde yuruyor (kaynak_tur 1256).
   *
   * KISMI ONAY = OLCUYU DUSURMEK: `olcu` verilince zincirin olcusu o orana
   * cekilir ve o orana artik gerekmeyen ileri basamaklar ATLANIR - %30 ust
   * yonetime gidiyorsa ve mali isler %8'e indirdiyse ust yonetimin imzasi
   * ortadan kalkmis bir is icin istenmis olurdu.
   */
  iskontoOnayla: (id: number, oran: number, not: string) =>
    gonder<{ zincirDurum: number; kayitDurum: number | null;
             olcu: number | null; atlananBasamak: number | null }>(
      `/api/onay/kayit/1256/${id}/karar`,
      { karar: 'onayla', olcu: oran, gerekce: not }),

  iskontoReddet: (id: number, not: string) =>
    gonder<{ zincirDurum: number; kayitDurum: number | null }>(
      `/api/onay/kayit/1256/${id}/karar`,
      { karar: 'reddet', gerekce: not }),
};
