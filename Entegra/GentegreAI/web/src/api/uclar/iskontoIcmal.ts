import { istek } from '../cekirdek';

/** İskonto ve ücretsiz hizmet icmali (IskontoIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type IskontoKaynagi = 'talep' | 'kampanya' | 'banko' | 'karma';
export type IskontoluBasvuru = {
  belgeId: number; protokolNo: string; tarih: string; hastaId: number; hasta: string; bolum: string; hekim: string;
  kaynak: IskontoKaynagi; isteyen: string; onaylayan: string; gerekce: string;
  liste: number; iskonto: number; oran: number;
  /** Talepsiz (banko) iskonto onay eşiğinin üstünde - onay atlanmış olabilir. */
  esikUstu: boolean;
  kalemler: { hizmet: string; liste: number; iskonto: number; kaynak: IskontoKaynagi }[];
};
export type IskontoGrubu = { ad: string; basvuru: number; kalem: number; liste: number; iskonto: number; oran: number };
export type IskontoIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    basvuru: number; iskonto: number; talepli: number; kampanya: number; banko: number;
    ucretsiz: number; ucretsizKalem: number; ortOran: number; esik: number; esikUstu: number;
    red: number; redTutar: number; personel: number; ciro: number; ciroOrani: number;
  };
  basvurular: IskontoluBasvuru[];
  onaylayanaGore: IskontoGrubu[]; verenGore: IskontoGrubu[]; gerekceGore: IskontoGrubu[];
  ucretsizler: { belgeId: number; protokolNo: string; tarih: string; hasta: string; bolum: string; hekim: string;
                 hizmet: string; liste: number; kaynak: IskontoKaynagi; gerekce: string; onaylayan: string }[];
  redler: { id: number; protokolNo: string; tarih?: string | null; gerekce: string; isteyen: string; reddeden: string;
            oran: number; istenen: number; not: string }[];
};

export const iskontoIcmalUclari = {
  iskontoIcmali: (bas: string, bit: string, kaynak: string, bolum: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (kaynak && kaynak !== 'hepsi') q.set('kaynak', kaynak);
    if (bolum) q.set('bolum', String(bolum));
    return istek<IskontoIcmali>(`/api/iskonto-icmal?${q}`);
  },
};
