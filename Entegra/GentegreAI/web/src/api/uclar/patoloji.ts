import { gonder, istek } from '../cekirdek';

/** PATOLOJİ (1104) - vaka ve dış lab gönderimi adımları (/api/patoloji). */
export const patolojiUclari = {
  /** Patoloji istem penceresinin seçenekleri - muayene yetkisiyle (tanım yetkisi gerekmez). */
  patolojiIstemSecenekleri: (muayeneId: number) => istek<{
    tipler: { id: number; ad: string; vakaTuru: number; calismaYeri: number; disLabId: number | null; tatGun: number }[];
    lablar: { id: number; ad: string }[];
  }>(`/api/muayene/${muayeneId}/patoloji-secenekler`),
  patolojiHazirlandi: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/hazirlandi`, {}),
  patolojiPaketeEkle: (idler: number[]) => gonder<{ mesaj: string }>('/api/patoloji/vaka/pakete-ekle', { idler }),
  patolojiPakettenCikar: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/paketten-cikar`, {}),
  patolojiLabKabul: (id: number, labVakaNo: string) =>
    gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/lab-kabul`, { labVakaNo }),
  patolojiRet: (id: number, retNedeniId: number | null, aciklama: string) =>
    gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/ret`, { retNedeniId, aciklama }),
  patolojiIptal: (id: number, muayeneden = false) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/iptal${muayeneden ? '?muayeneden=true' : ''}`, {}),
  patolojiGordum: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/gordum`, {}),
  patolojiEkKarar: (id: number, karar: 'onayla' | 'reddet') =>
    gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/ek-${karar}`, {}),
  patolojiIlet: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/gonderim/${id}/ilet`, {}),
  patolojiKurye: (id: number, kurye: string) => gonder<{ mesaj: string }>(`/api/patoloji/gonderim/${id}/kurye`, { kurye }),
  patolojiLabTeslim: (id: number, teslimAlan: string) =>
    gonder<{ mesaj: string }>(`/api/patoloji/gonderim/${id}/lab-teslim`, { teslimAlan }),
};
