import { istek } from '../cekirdek';

/** Sterilizasyon icmali (SterilIcmalUclari). Rakamlar sunucuda hesaplanır. */
export type SterilIcmali = {
  donem: { bas: string; bit: string };
  ozet: {
    sterilDongu: number; serbest: number; test: number; yikamaDongu: number; doluluk?: number | null; yuklenen: number; kapasite: number;
    kapasitesiz: number; uretilen: number; setTuru: number; birim: number; kullanilan: number; bolum: number; depoda: number;
    indikatorOkuma: number; indikatorBasarisiz: number; karantina: number; geriCagrilanPaket: number; geriKullanilmis: number;
    acikGeriCagirma: number; suresiDolan: number; islenmemis: number; esigeYakin: number; validasyonGeciken: string[];
  };
  cihazlar: { id: number; ad: string; tur: string; sterilizasyon: boolean; model: string; dongu: number; serbest: number; karantina: number;
              basarisiz: number; test: number; yuklenen: number; kapasite?: number | null; yukKapasite?: number | null; doluluk?: number | null;
              ortSureDk?: number | null; validasyon?: string | null; validasyonGecikti: boolean; sonBakim?: string | null;
              programlar: { ad: string; adet: number }[] }[];
  setler: { id: number; kod: string; ad: string; implant: boolean; paketTur: string; birim: number; uretilen: number; birimBasi: number;
            kullanilan: number; omur?: number | null; esik: number; esigeYakin: number; depoda: number; minStok: number; stokAz: boolean }[];
  indikatorOzet: { tur: string; okuma: number; gecti: number; kaldi: number; bekliyor: number; basari?: number | null }[];
  basarisizIndikatorler: { tarih?: string | null; cihaz: string; dongu: number; tur: string; lot: string; aksiyon: string }[];
  geriCagirmalar: { id: number; cihaz: string; tetikDongu: number; tarih: string; dongu: number; paket: number; kullanilan: number;
                    hasta: number; acik: boolean; kapanis?: string | null; aciklama: string }[];
  karantina: { dongu: number; cihaz: string; set: string; paket: number; biBitis?: string | null }[];
  suresiDolan: { barkod: string; set: string; raf: string; skt: string; durum: string; islenmedi: boolean }[];
  bolumler: { bolum: string; paket: number; setCesidi: number; implant: number; hasta: number; ortBeklemeGun?: number | null;
              setler: { ad: string; adet: number }[] }[];
  cihazAdlari: { id: number; ad: string }[];
  setAdlari: { id: number; ad: string }[];
};

export const sterilIcmalUclari = {
  sterilIcmali: (bas: string, bit: string, cihaz: number, set: number) => {
    const q = new URLSearchParams({ bas, bit });
    if (cihaz) q.set('cihaz', String(cihaz));
    if (set) q.set('set', String(set));
    return istek<SterilIcmali>(`/api/steril-icmal?${q}`);
  },
};
