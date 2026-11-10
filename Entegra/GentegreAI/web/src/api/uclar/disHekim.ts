import { gonder, istek } from '../cekirdek';

export interface PlanZiyareti {
  id: number; tarih: string; hekim_id: number; hekim_ad: string; hekim_ilce: string; hekim_kurum: string;
  durum: number; oneri: number; sonuc_ad: string; acik_talep: number; notu: string; amac_ad: string; tur_ad: string;
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
};
