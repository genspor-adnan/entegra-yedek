import { gonder, istek } from '../cekirdek';

/**
 * Temsilci Performans İcmali (TemsilciPerformansUclari, 1186) - `/api/temsilci-performans`. Rakamlar sunucuda:
 * temsilci FATURADAN (satıcı; boşsa id -1 "(temsilcisiz)"), ciro / brüt kâr / tahsil edilen Kârlılık İcmali
 * kuralıyla, vadesi geçen ve ödeme davranışı müşterinin temsilcisine (son 12 ayın en çok satanı) göre.
 * Sunucu null alanları yazmaz: `?` işaretli alanlar yoksa "yok / tanımsız" demektir. Ekran hesap yapmaz.
 */
export type DonemKipi = 'ay' | 'ceyrek' | 'yil';

export type TemsilciSatiri = {
  id: number; ad: string; ciro: number; kar: number; marj?: number; tahsilat: number; vadesiGecen: number;
  aktifMusteri: number; yeniMusteri: number; iskonto: number; iskontoOran?: number; teklif: number;
  hedefCiro?: number; hedefOran?: number;
  musteriler: { id: number; ad: string; net: number; kar: number }[];
};

export type HedefSatiri = {
  temsilciId: number; temsilci: string; olcut: number; olcutAdi: string;
  hedef: number; gerceklesen: number; oran?: number; kalan: number; tahmin?: number;
};

export type TemsilciPerformans = {
  kip: DonemKipi; bas: string; bit: string; bugun: string; sube: number; iadeDus: boolean;
  ozet: {
    ciro: number; temsilcisizCiro: number; hedef?: number; hedefOran?: number; kar: number; marj?: number;
    tahsilat: number; tahsilatOran?: number; vadesiGecen: number; vadesiGecenMusteri: number; yeniMusteri: number;
    iskontoOran?: number; teklif: number; prim?: number;
  };
  temsilciler: TemsilciSatiri[];
  toplam: {
    ciro: number; kar: number; marj?: number; tahsilat: number; vadesiGecen: number; aktifMusteri: number;
    yeniMusteri: number; iskonto: number; iskontoOran?: number; teklif: number;
  };
  hedefler: HedefSatiri[];
  tahminVar: boolean;
  gidisat: {
    aylar: string[]; gecenYilAy: string;
    satirlar: { id: number; ad: string; degerler: number[]; gecenYil?: number; degisim?: number }[];
  };
  portfoy: { id: number; ad: string; musteri: number; buDonemAlan: number; almayan90: number; kaybedilen: number; ilk5Pay?: number; limitAsan: number }[];
  tahsilat: {
    id: number; ad: string; tahsilat: number; ortTahsilGun?: number; ortGecikme?: number; zamaninda?: number;
    vadesiGecen: number; d90p: number; karsiliksiz: number; skor?: 'A' | 'B' | 'C' | 'D'; skorPuan?: number;
  }[];
  aktivite: {
    id: number; ad: string; gorusme: number; toplanti: number; gorev: number; acikGorev: number; gecikenGorev: number;
    teklif: number; temasBasinaCiro?: number;
  }[];
  prim: {
    planVar: boolean;
    satirlar: { id: number; ad: string; plan: string; taslak: number; kesin: number; onayli: number; odendi: number; toplam: number }[];
    toplam: { taslak: number; kesin: number; onayli: number; odendi: number; toplam: number };
  };
  hedefYetkisi: boolean;
  secim: { subeler: { id: number; ad: string }[] };
  izlemeNo: string;
};

export type HedefListesi = {
  donem: string;
  temsilciler: { id: number; ad: string }[];
  hedefler: { temsilciId: number; olcut: number; hedef: number }[];
  olcutler: { id: number; ad: string }[];
  yetki: boolean;
};

const Y = '/api/temsilci-performans';

export const temsilciPerformansUclari = {
  temsilciPerformans: (q: URLSearchParams) => istek<TemsilciPerformans>(`${Y}?${q}`),
  /** ay: ayın herhangi bir günü (YYYY-MM-DD). */
  temsilciHedefleri: (ay: string) => istek<HedefListesi>(`${Y}/hedef?ay=${ay}`),
  /** hedef null / 0 = o ölçütün hedefini kaldır. */
  temsilciHedefYaz: (g: { temsilciId: number; donem: string; olcut: number; hedef: number | null }) =>
    gonder<{ degisti: boolean }>(`${Y}/hedef`, g, 'PUT'),
};
