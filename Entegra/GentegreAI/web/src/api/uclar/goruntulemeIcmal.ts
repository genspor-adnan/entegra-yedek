import { istek } from '../cekirdek';

/** Görüntüleme (radyoloji) icmali (GoruntulemeIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type GoruntulemeModalite = {
  modalite: number; ad: string; cekim: number; ciro: number; kurum: number; kurumYuzde: number; kontrastli: number;
  sarf: number; telerad: number; kar: number; marj?: number | null; ortRapor?: number | null; asan: number;
  enCok: { ad: string; adet: number; ciro: number }[];
};
export type GoruntulemeIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    cekim: number; hasta: number; ciro: number; kurum: number; hastaPayi: number; sarf: number; kontrastli: number;
    teleradMaliyet: number; kar: number; marj?: number | null; ortRapor?: number | null; asan: number; bekleyen: number;
    giden: number; gelen: number; gelenGelir: number; teleradNet: number; doluluk?: number | null; cihazsiz: number;
    faturasiz: number; sarfsiz: number; hedefRutin: number; hedefAcil: number;
  };
  modaliteler: GoruntulemeModalite[];
  tetkikler: { hizmetId: number; kod: string; ad: string; modalite: string; adet: number; ciro: number; ortFiyat: number;
               sarfCekim: number; maliyet: number; marj?: number | null; faturasiz: number }[];
  /** tur: ic = iç radyolog (onaylayan), telerad = dışarıya raporlatılan (kurum). */
  raporlayanlar: { tur: 'ic' | 'telerad'; id: number; ad: string; rapor: number; bekleyen: number; ortSure?: number | null;
                   asan: number; kritik: number; revizyon: number; ikinciOkuma: number }[];
  cihazlar: { id: number; ad: string; modalite: string; cekim: number; kullanimSaat: number; kapasiteSaat: number;
              doluluk: number; kapaliGun: number; sarf: number; sarfCekim: number }[];
  teleradGiden: { kurumId: number; ad: string; cekim: number; birimUcret: number; maliyet: number }[];
  teleradGelen: { kurumId: number; ad: string; cekim: number; gelir: number; raporlanan: number; slaAsan: number }[];
  hedefAsanlar: { belgeId: number; protokolNo: string; tarih: string; tetkik: string; modalite: string; hedef: number; gercek: number; asim: number }[];
  modaliteAdlari: { id: number; ad: string }[];
};

export const goruntulemeIcmalUclari = {
  goruntulemeIcmali: (bas: string, bit: string, modalite: number, raporlayan: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (modalite) q.set('modalite', String(modalite));
    if (raporlayan) q.set('raporlayan', String(raporlayan));
    return istek<GoruntulemeIcmali>(`/api/goruntuleme-icmal?${q}`);
  },
};
