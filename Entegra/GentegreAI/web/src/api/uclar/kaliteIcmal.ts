import { istek } from '../cekirdek';

/** Gösterge durumu: hedefte · disi · hedefsiz · veriyok (payda 0) · kaynakyok (kayıt kaynağı yok). */
export type GostergeDurumu = 'hedefte' | 'disi' | 'hedefsiz' | 'veriyok' | 'kaynakyok';

export type KaliteGostergesi = {
  kod: string; ad: string; kaynak: 'SKS' | 'Klinik'; yon: string; hedef?: number | null; birim: string; pay: number; payda: number;
  sonuc?: number | null; onceki?: number | null; durum: GostergeDurumu;
  kirilim: { ad: string; pay: number; payda: number; birim: string; sonuc?: number | null }[]; not: string; kesin: boolean;
};

/** Kalite / SKS icmali (KaliteIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type KaliteIcmali = {
  donem: { bas: string; bit: string; oncekiBas: string; oncekiBit: string };
  ozet: {
    gosterge: number; hedefte: number; hedefDisi: number; kaynakYok: number; veriYok: number; klinikOlculmeyen: number;
    bildirim: number; bildirimHedefte: number; bildirimOran?: number | null; bildirimAsan: number; ortSure?: number | null;
    labOrt?: number | null; radOrt?: number | null; panikHedef: number; kritikHedef: number;
    grs: number; grsCiddi: number; grsOnceki: number; dusme: number; dusmeBinde?: number | null; hastaGun: number; eslesmeyenDusme: number;
    basi: number; bradenRiskli: number; basiOran?: number | null; elFirsat: number; elUyulan: number; elOran?: number | null;
    anketGonderilen: number; anket: number; memnun: number; memnuniyetOran?: number | null; ortPuan?: number | null;
    ameliyat: number; cerrahiTam: number;
  };
  gostergeler: KaliteGostergesi[];
  bildirimKaynaklari: { kaynak: string; hedefDk: number; bildirim: number; hedefte: number; asan: number; oran?: number | null;
                        ortSure?: number | null; enUzun?: number | null; teyit: number; yukseltme: number }[];
  bildirimler: { zaman: string; protokolNo: string; kaynak: 'Lab' | 'Rad'; tetkik: string; deger: string; bolum: string; bildirilen: string;
                 kanal: string; sureDk?: number | null; hedefDk: number; asti: boolean; teyit: boolean; yukseltme: boolean }[];
  zararAdlari: string[];
  grsMatris: { tur: string; duzey: number[]; toplam: number }[];
  grsOlaylar: { no: string; tarih: string; tur: string; birim: string; zarar: string; duzey: number; anonim: boolean }[];
  servisler: { servis: string; yatan: number; hastaGun: number; itakiYuksek: number; dusme: number; dusmeBinde?: number | null;
               bradenRiskli: number; gelisen: number; basiOran?: number | null }[];
  elMeslek: { ad: string; firsat: number; uyulan: number; oran?: number | null }[];
  elEndikasyon: { ad: string; firsat: number; uyulan: number; oran?: number | null }[];
  memnuniyetBirim: { birim: string; gonderilen: number; dolduran: number; yanit?: number | null; ortPuan?: number | null;
                     memnun: number; oran?: number | null }[];
  memnuniyetSorular: { soru: string; cevap: number; ortalama?: number | null }[];
};

export const kaliteIcmalUclari = {
  kaliteIcmali: (bas: string, bit: string) => istek<KaliteIcmali>(`/api/kalite-icmal?${new URLSearchParams({ bas, bit })}`),
};
