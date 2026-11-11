import { istek } from '../cekirdek';

/**
 * DICOM GÖRÜNTÜLEME (kullanıcı 11.11.2026: ClearCanvas ImageServer + OHIF). Sunucu çalışmayı bulur (study_uid ya da
 * accession ile C-FIND), jetonlu manifest adresini OHIF köküne bağlar; istemci yalnız yeni sekmede açar.
 */
export interface PacsCalisma {
  studyUid: string; tarih: string; saat: string; modaliteler: string; aciklama: string; accession: string; adet: number;
  hastaAd: string; hastaNo: string; url: string;
}

export const dicomUclari = {
  /** Hastanın PACS'taki çalışmaları (ad / kimlik eşlemesi) - hasta kartı "PACS Görüntüleri" sekmesi. */
  dicomHastaCalismalari: (hastaId: number) =>
    istek<{ aktif: boolean; calismalar: PacsCalisma[] }>(`/api/dicom/hasta/${hastaId}`),
  dicomGoruntule: (g: { istemId?: number; studyUid?: string; accession?: string }) => {
    const q = new URLSearchParams();
    if (g.istemId) q.set('istemId', String(g.istemId));
    if (g.studyUid) q.set('studyUid', g.studyUid);
    if (g.accession) q.set('accession', g.accession);
    return istek<{ url: string; studyUid: string; manifest: string }>(`/api/dicom/goruntule?${q.toString()}`);
  },
};
