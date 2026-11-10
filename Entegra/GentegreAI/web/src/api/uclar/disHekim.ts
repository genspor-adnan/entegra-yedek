import { gonder } from '../cekirdek';

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
};
