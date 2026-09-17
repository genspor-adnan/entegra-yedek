import { gonder, istek } from '../cekirdek';

/**
 * İZİN UÇLARI (743).
 *
 * GÜN SAYISINI SUNUCU HESAPLAR: başlangıç ve bitişten. İstemci de
 * hesaplasaydı ekranın gösterdiği ile bakiyeden düşen farklı olabilir ve
 * fark kimsenin dikkatini çekmeden bakiyeyi eritirdi.
 *
 * BAKİYE AŞIMI ENGEL DEĞİL: hakkı olmayan personele izin vermek ücretsiz
 * ya da avans izindir - ayrı bir karardır ve zincire bir basamak ekler.
 */

export interface IzinBakiyesi {
  tarafId: number;
  personelAd: string;
  yil: number;
  /** null = işe giriş tarihi yok, kanunî hak hesaplanamıyor. */
  hakGun: number | null;
  devirGun: number;
  ekGun: number;
  kullanilanGun: number;
  /** Onaylı ama henüz başlamamış izin - bakiyeden düşer, "kullanıldı" değil. */
  planlananGun: number;
  onaydaGun: number;
  kalan: number;
  not: string | null;
}

export const izinUclari = {
  izinBakiye: (tarafId: number, yil?: number) =>
    istek<IzinBakiyesi>(`/api/ik/personel/${tarafId}/izin-bakiye`
      + (yil ? `?yil=${yil}` : '')),

  /** Talep açar (taslak). Gün sayısı sunucuda hesaplanır. */
  izinAc: (g: {
    tarafId: number; tur: number; baslangic: string; bitis: string;
    isGunu?: boolean; aciklama?: string; belgeNo?: string; yerineId?: number;
  }) => gonder<{
    id: number; gun: number; durum: number;
    bakiye: IzinBakiyesi; uyarilar: string[];
  }>('/api/ik/izin', g),

  /* Not: onaya gönderme yanıtındaki `randevu`, izin tarihlerindeki AÇIK
     randevu sayısıdır - izin onaylanınca takvim kapanır ama o randevular
     kendiliğinden taşınmaz. */

  /** Onay zincirini kurar. Âmiri tanımlı olmayan personelde reddedilir. */
  izinGonder: (id: number) =>
    gonder<{
      durum: number; gun: number; bayraklar: string[]; randevu: number;
      basamaklar: { sira: number; ad: string; rol: number }[];
      bakiye: IzinBakiyesi;
    }>(`/api/ik/izin/${id}/gonder`, {}),

  /**
   * Bir yılın MİLLÎ tatillerini üretir (749). Dinî bayramlar DÂHİL DEĞİL:
   * hicrî takvime bağlıdırlar ve algoritmayla üretilmezler - bir gün kayan
   * hesap izin gününü ve bordroyu yanlış hesaplar.
   */
  resmiTatilUret: (yil: number) =>
    gonder<{ yil: number; eklenen: number; dini: number; uyarilar: string[] }>(
      `/api/ik/tatil/uret/${yil}`, {}),

  /** Onaylı izin de iptal edilir - silinmez; "alınmış mıydı" sorusu sonra da sorulur. */
  izinIptal: (id: number, gerekce: string) =>
    gonder<{ durum: number }>(`/api/ik/izin/${id}/iptal`, { gerekce }),
};
