import { gonder, istek } from '../cekirdek';

/**
 * BEBEK / ÇOCUK İZLEMİ (899 — KTS maddesi H10, USS 209).
 *
 * Ölçümler ekrandaki birimlerle gider: boy cm, <b>kilo kg</b>, baş çevresi
 * cm. Pakette kilo grama çevrilir - çevrim sunucuda, tek yerde.
 *
 * <b>Persentil eğri verisine bağlıdır</b> (`cocuk_buyume_lms`): tablo boşken
 * alanlar null döner ve `egriVar` false gelir. Boş persentili "ölçüm kötü"
 * diye okumamak için ekran bunu ayrıca söyler.
 */
export interface CocukIzlemi {
  id: number; kacinciIzlem: number; izlemTarihi: string;
  yasAy: number | null;
  boyCm: number | null; kiloKg: number | null; basCevresiCm: number | null;
  kiloPersentil: number | null; boyPersentil: number | null;
  basPersentil: number | null;
  hemoglobin: number | null; hematokrit: number | null;
  beslenme: number | null; dVitamini: number | null; demir: number | null;
  gkd: number | null; gorme: number | null; dkh: number | null; ntp: number | null;
  oneri: string; aciklama: string;
  /** 1 geçerli · 0 iptal (kayıt silinmez). */
  durum: number; iptalNeden: string; enabizDurum: number;
}

export const cocukIzlemUclari = {
  cocukIzlemGecmisi: (hastaId: number) =>
    istek<{ izlemler: CocukIzlemi[]; sonraki: number; egriVar: boolean }>(
      `/api/cocuk-izlem/hasta/${hastaId}`),

  cocukIzlemEkle: (govde: {
      tarafId: number; kacinciIzlem: number; belgeId?: number | null;
      muayeneId?: number | null; islemTuru?: number; izlemTarihi?: string;
      boyCm?: number | null; kiloKg?: number | null; basCevresiCm?: number | null;
      dogumAgirligiG?: number | null; hemoglobin?: number | null;
      hematokrit?: number | null; beslenme?: number; dVitamini?: number;
      demir?: number; gkd?: number; gorme?: number; dkh?: number;
      dkhYapilmama?: number; ntp?: number; oneri?: string; aciklama?: string }) =>
    gonder<{ id: number; yasAy: number | null; kiloPersentil: number | null;
             boyPersentil: number | null; basPersentil: number | null; mesaj: string }>(
      '/api/cocuk-izlem', govde),

  cocukIzlemIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/cocuk-izlem/${id}/iptal`, { neden }),
};
