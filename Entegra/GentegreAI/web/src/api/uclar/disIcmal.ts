import { istek } from '../cekirdek';

/** Diş icmali (DisIcmalUclari). Rakamlar ve toplamlar sunucuda hesaplanır. */
export type DisIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    seans: number; hasta: number; hekimHastaToplami: number; islem: number; faturasiz: number;
    ciro: number; sarf: number; lab: number; sarfLab: number; kar: number; marj?: number | null;
    planSunulan: number; planSunulanTutar: number; planKabul: number; planKabulTutar: number; kabulYuzde?: number | null;
    planSuruyor: number; planTamam: number; tamamYuzde?: number | null; planBekliyor: number; planIptal: number; planYapilanTutar: number;
    yarimAdet: number; yarimTutar: number; yarimYapilan: number; yarimKalan: number; yarimTahsil: number; yarimFark: number; yarimGun: number;
    uniteSayisi: number; uniteKullanim: number; uniteKapasite: number; uniteDoluluk?: number | null; ortSeansDk?: number | null;
    isGunu: number; uniteSaat: number;
    labIs: number; labHastaya: number; labFark: number; labGec: number; labAcik: number; islemSarf: number; islemLab: number;
  };
  hekimler: {
    id: number; ad: string; brans: string; seans: number; hasta: number; islem: number; ciro: number; sarf: number; lab: number; sarfLab: number; kar: number;
    marj?: number | null; planKabul?: number | null; ortSeansDk?: number | null; ciroPayi?: number | null;
    islemler: { ad: string; grup: string; adet: number; ciro: number; sarf: number; lab: number; kar: number }[];
  }[];
  planHekim: {
    hekim: string; sunulan: number; tutar: number; bekliyor: number; kabul: number; kabulTutar: number; kabulYuzde?: number | null;
    suruyor: number; tamam: number; tamamYuzde?: number | null; iptal: number; yapilanTutar: number;
  }[];
  yarimKalan: {
    id: number; planNo: string; protokolNo: string; hasta: string; hekim: string; tutar: number; yapilan: number; kalan: number; tahsil: number;
    sonSeans?: string | null; gun: number; seansYok: boolean; neden: string;
  }[];
  islemTurleri: {
    hizmetId: number; ad: string; grup: string; adet: number; ciro: number; ortFiyat: number; sarf: number; lab: number; kar: number;
    marj?: number | null; hekim: number; ciroPayi?: number | null; faturasiz: number;
  }[];
  laboratuvarlar: {
    id: number; ad: string; anaIs: string; isAdet: number; acik: number; labBedeli: number; hastaya: number; fark: number; slaGun: number;
    ortSureGun?: number | null; gec: number;
  }[];
  uniteler: { id: number; ad: string; hekimler: string[]; seans: number; kullanimSaat: number; kapasiteSaat?: number | null; doluluk?: number | null }[];
  hekimAdlari: { id: number; ad: string }[];
  gruplar: { id: number; ad: string }[];
};

export const disIcmalUclari = {
  disIcmali: (bas: string, bit: string, hekim: number, islemGrubu: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (hekim) q.set('hekim', String(hekim));
    if (islemGrubu) q.set('islemGrubu', String(islemGrubu));
    return istek<DisIcmali>(`/api/dis-icmal?${q}`);
  },
};
