import { istek } from '../cekirdek';

/** Cari İcmali (CariIcmalUclari, 1154). Rakamlar sunucuda hesaplanır. */
export type CariIcmalSatiri = {
  id: number; kod: string; ad: string; musteri: boolean; tedarikci: boolean; durum: number;
  temsilci: string; kategori: string; il: string;
  devir: number; donemBorc: number; donemAlacak: number; bakiye: number; vadesiGecen: number; enEskiGun: number;
  sonHareket: string | null; sonTahsilat: string | null; riskLimiti: number; riskYuzde: number | null;
  /** "USD:42500.0000;EUR:-18900" - kendi para biriminde (+ borç, - alacak). */
  doviz: string;
  /** Bakiyenin yönüyle: yalnız müşteri / yalnız tedarikçi / ikisi birden ise borçlu → musteri. */
  grup: 'musteri' | 'tedarikci';
  gelmemis: number; d30: number; d60: number; d90: number; d90p: number;
};
export type CariDilim = { ad: string; tutar: number; cari: number; enBuyuk: string; enBuyukTutar: number };
export type CariIcmal = {
  bas: string; bit: string; kapsam: string;
  /** HBYS kurulumu: kapsam sunucuda tedarikçiye sabit (müşteri tarafı hasta / kurum icmallerinde). */
  sadeceTedarikci: boolean;
  ozet: {
    alacak: number; alacakCari: number; borc: number; borcCari: number; net: number;
    vadesiGecenAlacak: number; vadesiGecenAlacakCari: number; vadesiGecenAlacakGun: number;
    vadesiGecenBorc: number; vadesiGecenBorcCari: number; vadesiGecenBorcGun: number;
    satis: number; tahsilat: number; alis: number; odeme: number;
    cekAlinan: number; cekAlinanAdet: number; cekVerilen: number; cekVerilenAdet: number;
    musteriCari: number; tedarikciCari: number;
  };
  yaslandirma: { alacak: CariDilim[]; borc: CariDilim[] };
  nakit: { bas: string; bit: string; tahsilat: number; odeme: number; cekAlinan: number; cekVerilen: number }[];
  kirilim: {
    temsilci: { ad: string; cari: number; satis: number; tahsilat: number; bakiye: number; vadesiGecen: number }[];
    kategori: { ad: string; cari: number; bakiye: number; vadesiGecen: number }[];
    il: { ad: string; cari: number; bakiye: number; satis: number }[];
    para: { doviz: string; cari: number; alacak: number; borc: number; yerel: number }[];
  };
  dikkat: {
    limit: { id: number; ad: string; bakiye: number; riskLimiti: number; yuzde: number }[];
    tahsilatsiz: { id: number; ad: string; bakiye: number; sonTahsilat: string | null; temsilci: string; gun: number | null }[];
    alacakli: { id: number; ad: string; bakiye: number; sonHareket: string | null }[];
    odemeler: { id: number; ad: string; vade: string; turAdi: string; belgeNo: string; tutar: number }[];
  };
  temsilciler: { id: number; ad: string }[];
  carilar: CariIcmalSatiri[];
};

export const cariIcmalUclari = {
  cariIcmal: (q: URLSearchParams) => istek<CariIcmal>(`/api/cari-icmali?${q}`),
};
