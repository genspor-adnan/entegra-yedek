import { istek } from '../cekirdek';

/** Çağrı merkezi icmali (CagriIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type CagriOzet = {
  gelen: number; cevaplanan: number; terk: number; sesli: number; cevapOrani?: number | null; sla?: number | null;
  ortBekleme?: number | null; enUzunBekleme?: number | null; ortGorusme?: number | null; ortIslemSonrasi?: number | null; randevu: number;
};
export type CagriIcmali = {
  donem: { bas: string; bit: string };
  ozet: CagriOzet & {
    telefon: number; whatsapp: number; digerKanal: number; donusum?: number | null; geriIstek: number; geriZamaninda: number;
    geriGec: number; geriYok: number; geriOran?: number | null; hedefDk: number; giden: number; gidenGeriArama: number;
    gidenKampanya: number; slaHedef: number; temsilci: number; asiriSure: number;
  };
  kuyruklar: { id: number; ad: string; slaSn: number; hedef: number; slaTanimsiz: boolean; ozet: CagriOzet; sonuclar: { ad: string; adet: number }[] }[];
  temsilciler: { id: number; ad: string; dahili: string; gelen: number; giden: number; konusmaSn: number; ortGorusme?: number | null;
                 ortIslemSonrasi?: number | null; randevu: number; donusum?: number | null; geriZamaninda: number; geriGec: number;
                 geriYok: number; kalite?: number | null }[];
  saatler: { saat: number; gelen: number; cevaplanan: number; terk: number; sesli: number; sla?: number | null; ortBekleme?: number | null }[];
  gunler: { gun: number; gunSayisi: number; gelen: number; gunBasina: number; cevapOrani?: number | null }[];
  geriAramaOzet: { kaynak: string; istek: number; zamaninda: number; gec: number; yapilmadi: number; tamam: number; ulasildi: number;
                   ortSure?: number | null; oran?: number | null }[];
  gecikenler: { id: number; istek: string; arayan: string; telefon: string; kuyruk: string; kaynak: string; temsilci: string;
                sure?: number | null; durum: 'gec' | 'yapilmadi' }[];
  kampanyalar: { id: number; ad: string; tur: string; kanal: string; kisi: number; arama: number; ulasilan: number; onay: number;
                 iptal: number; ulasilamadi: number; bekliyor: number; basari?: number | null }[];
  kuyrukAdlari: { id: number; ad: string }[];
};

export const cagriIcmalUclari = {
  cagriIcmali: (bas: string, bit: string, kuyruk: number, kanal: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (kuyruk) q.set('kuyruk', String(kuyruk));
    if (kanal) q.set('kanal', String(kanal));
    return istek<CagriIcmali>(`/api/cagri-icmal?${q}`);
  },
};
