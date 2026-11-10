import { gonder, istek } from '../cekirdek';

export interface PlanZiyareti {
  id: number; tarih: string; hekim_id: number; hekim_ad: string; hekim_ilce: string; hekim_kurum: string;
  durum: number; oneri: number; sonuc_ad: string; acik_talep: number; notu: string; amac_ad: string; tur_ad: string;
}
export interface SahaPerformansi {
  donem: { bas: string; bit: string; oncekiBas: string; oncekiBit: string };
  ozet: { gonderim: number; onceki: number; degisim: number; tutar: number; oncekiTutar: number; ziyaret: number;
          planUyumu: number | null; dusenHekim: number; sessizHekim: number; gonderenPrimi: number; temsilciPrimi: number;
          temsilci: number; hekim: number };
  temsilciler: { id: number; ad: string; subeId: number; subeAd: string; hekim: number; aktifHekim: number; ziyaret: number;
                 planUyumu: number | null; gonderim: number; onceki: number; degisim: number; tutar: number; yeniHekim: number;
                 kaybedilen: number; acikTalep: number; terminiGecen: number; prim: number }[];
  doktorlar: { id: number; ad: string; brans: string; kurum: string; temsilciler: string; gonderim: number; onceki: number;
               degisim: number; tutar: number; modaliteler: string; sonGonderim: string | null; sonZiyaret: string | null;
               ziyaret: number; acikTalep: number; gonderenPrimi: number; dusen: boolean; sessiz: boolean; yeni: boolean;
               ziyaretEdilmeyen: boolean; gecikme: number }[];
  subeler: { subeId: number; subeAd: string; temsilci: number; hekim: number; aktifHekim: number; ziyaret: number;
             planUyumu: number | null; gonderim: number; onceki: number; degisim: number; tutar: number; temsilciPrimi: number }[];
  talepler: { tur: string; acik: number; onayda: number; terminiGecen: number; kapanan: number; ortKapanmaGun: number; encok: string }[];
  subeAdlari: { id: number; ad: string }[];
}
export interface HaftalikPlan {
  haftaBas: string; temsilciId: number;
  temsilciler: { id: number; ad: string }[];
  ziyaretler: PlanZiyareti[];
  vade: { geciken: number; planlanacak: number; dusen: number; talepli: number } | null;
}

/**
 * DIŞ DOKTOR SAHA UÇLARI (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html): talebi kapat / ret, göreve çevir,
 * ziyareti "gördüm" işaretle. Kurallar uçta (kapalı talep çevrilmez, ikinci çağrı aynı görevi döndürür).
 */
export const disHekimUclari = {
  /** Talebi kapatır (durum 3) ya da reddeder (4); sonuç metni isteğe bağlı. */
  disHekimTalepKapat: (id: number, g: { durum: 3 | 4; sonuc?: string }) =>
    gonder<{ mesaj: string }>(`/api/dis-hekim/talep/${id}/kapat`, g),

  /** Talebi göreve çevirir: sorumlu / termin verilmezse talebinki, o da yoksa oturum kullanıcısı. */
  disHekimTalepGoreveCevir: (id: number, g?: { sorumluId?: number; termin?: string | null }) =>
    gonder<{ gorevId: number; mesaj: string }>(`/api/dis-hekim/talep/${id}/goreve-cevir`, g ?? {}),

  /** Yönetici ziyaret notunu okudu (eski HBYS "görüldü"). */
  disHekimZiyaretGoruldu: (id: number) =>
    gonder<{ mesaj: string }>(`/api/dis-hekim/ziyaret/${id}/goruldu`, {}),

  // ---- haftalık plan (1290) ----
  disHekimPlan: (haftaBas: string, temsilciId?: number) =>
    istek<HaftalikPlan>(`/api/dis-hekim/plan?hafta=${haftaBas}${temsilciId ? `&temsilciId=${temsilciId}` : ''}`),
  disHekimPlanUret: (g: { haftaBas: string; temsilciId?: number; gunBasi?: number; grupla?: boolean }) =>
    gonder<{ sayi: number; mesaj: string }>('/api/dis-hekim/plan/uret', g),
  disHekimZiyaretTasi: (id: number, tarih: string) =>
    gonder<{ mesaj: string }>(`/api/dis-hekim/ziyaret/${id}/tasi`, { tarih }),
  disHekimZiyaretOnayla: (id: number) =>
    gonder<{ mesaj: string }>(`/api/dis-hekim/ziyaret/${id}/onayla`, {}),
  disHekimZiyaretIptal: (id: number) =>
    gonder<{ mesaj: string }>(`/api/dis-hekim/ziyaret/${id}/iptal`, {}),
  disHekimPlanla: (g: { hekimId: number; tarih: string; temsilciId?: number }) =>
    gonder<{ id: number; mesaj: string }>('/api/dis-hekim/planla', g),

  /** Saha performansı (1292): dönem × şube; temsilci / doktor / şube / talep. */
  sahaPerformans: (bas: string, bit: string, sube: number) =>
    istek<SahaPerformansi>(`/api/dis-hekim/performans?bas=${bas}&bit=${bit}${sube ? `&sube=${sube}` : ''}`),
};
