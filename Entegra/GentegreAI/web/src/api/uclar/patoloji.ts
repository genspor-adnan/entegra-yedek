import { gonder } from '../cekirdek';

/** PATOLOJİ (1104) - vaka ve dış lab gönderimi adımları (/api/patoloji). */
export const patolojiUclari = {
  patolojiHazirlandi: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/hazirlandi`, {}),
  patolojiPaketeEkle: (idler: number[]) => gonder<{ mesaj: string }>('/api/patoloji/vaka/pakete-ekle', { idler }),
  patolojiPakettenCikar: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/paketten-cikar`, {}),
  patolojiLabKabul: (id: number, labVakaNo: string) =>
    gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/lab-kabul`, { labVakaNo }),
  patolojiRet: (id: number, retNedeniId: number | null, aciklama: string) =>
    gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/ret`, { retNedeniId, aciklama }),
  patolojiIptal: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/iptal`, {}),
  patolojiGordum: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/gordum`, {}),
  patolojiEkKarar: (id: number, karar: 'onayla' | 'reddet') =>
    gonder<{ mesaj: string }>(`/api/patoloji/vaka/${id}/ek-${karar}`, {}),
  patolojiIlet: (id: number) => gonder<{ mesaj: string }>(`/api/patoloji/gonderim/${id}/ilet`, {}),
  patolojiKurye: (id: number, kurye: string) => gonder<{ mesaj: string }>(`/api/patoloji/gonderim/${id}/kurye`, { kurye }),
  patolojiLabTeslim: (id: number, teslimAlan: string) =>
    gonder<{ mesaj: string }>(`/api/patoloji/gonderim/${id}/lab-teslim`, { teslimAlan }),
};
