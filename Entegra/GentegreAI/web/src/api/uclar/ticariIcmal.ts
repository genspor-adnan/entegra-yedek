import { istek } from '../cekirdek';

/**
 * Satış / Alış İcmali (TicariIcmalUclari) - `/api/ticari-icmal/satis` ve `/alis`.
 * Rakamlar sunucuda (belge dip toplamından); ekran hesap yapmaz. Para birimi seçiliyse
 * bütün tutarlar o dövizin cinsinden, değilse TL karşılığı (belge kuruyla).
 */
type Secenek = { id: number; ad: string };
type DovizRozeti = { para: string; tutar: number };
type Karsi = { tur: 'gy' | 'od'; bas: string; bit: string };

type Ortak = {
  bas: string; bit: string; karsi: Karsi; gun: number;
  kdvDahil: boolean; iadeDus: boolean; taslak: boolean;
  /** '' = TL karşılığı; dolu = yalnız o döviz, tutarlar o dövizde. */
  para: string; yerelPara: string; sube: number; izlemeNo: string;
};

export type ParaSatiri = {
  para: string; yerel: boolean; belge: number; doviz: number | null; ortKur: number | null; tl: number; pay: number;
  acikDoviz: number | null; bugunkuKur: number | null; acikBugun: number | null; kurFarki: number | null;
};
export type ParaTablosu = { satirlar: ParaSatiri[]; toplam: { belge: number; tl: number; acikBugun: number; kurFarki: number } };

export type FaturasizIrsaliye = {
  sayi: number; tutar: number;
  liste: { id: number; no: string; tarih: string; cariId: number; cari: string; tutar: number; gun: number }[];
};

// ===================================================================== SATIŞ ==

export type SatisMusteriSatiri = {
  id: number; ad: string; musteri: boolean; tedarikci: boolean; temsilci: string; belge: number;
  brut: number; iskonto: number; iade: number; net: number; gecenYil: number | null; degisim: number | null; yeni: boolean;
  kar: number; marj: number | null; pay: number; cubuk: number; dusukMarj: boolean; doviz: DovizRozeti[];
  belgeSayisi: number; belgeler: { id: number; no: string; tarih: string; tutar: number; iade: boolean }[];
};
export type SatisUrunSatiri = {
  anahtar: string; stokId: number; hizmet: boolean; kod: string; ad: string; kategori: string;
  miktar: number; net: number; ortFiyat: number | null; listeFiyati: number | null; maliyet: number | null;
  kar: number; marj: number | null; musteri: number; dusukFiyat: boolean; eksiMarj: boolean;
  musteriler: { id: number; ad: string; miktar: number; net: number }[];
};
/** Delphi'den satırsız aktarılan tahakkuk (17 satış / 13 alış): icmale girmez, yalnız bilgi (KDV dahil cari tutar). */
export type AktarimTahakkuk = { belge: number; tutar: number };
export type SatisIcmali = Ortak & {
  temsilci: number;
  aktarimTahakkuk: AktarimTahakkuk;
  ozet: {
    net: number; brut: number; iskonto: number; iade: number; iadeBelge: number; karsiNet: number; degisim: number | null;
    belge: number; fatura: number; fis: number; musteri: number; yeniMusteri: number;
    maliyet: number; kar: number; marj: number | null; iskontoOran: number; iadeOran: number; vadesiGecen: number;
  };
  musteriler: SatisMusteriSatiri[];
  musteriToplam: {
    musteri: number; belge: number; brut: number; iskonto: number; iade: number; net: number; gecenYil: number;
    degisim: number | null; kar: number; marj: number | null;
  };
  urunler: SatisUrunSatiri[];
  trend: {
    aylar: { ay: string; net: number; gecenYil: number; degisim: number | null; belge: number; kar: number; marj: number | null; kismiGun: number | null; cubuk: number }[];
    /** Dönem 62 günü aşmıyorsa gün gün (karşılaştırma döneminin aynı günüyle); aksi halde null. */
    gunler: { tarih: string; karsiTarih: string; net: number; karsi: number; degisim: number | null; belge: number; kar: number; marj: number | null }[] | null;
  };
  kirilim: {
    temsilci: { id: number; ad: string; net: number; musteri: number; marj: number | null; tahsil: number }[];
    kategori: { ad: string; net: number; pay: number; marj: number | null }[];
    subeDepo: { ad: string; net: number; belge: number }[];
    belgeTuru: { ad: string; net: number; belge: number }[];
    para: ParaTablosu;
  };
  dikkat: {
    zarar: { belgeId: number; belgeNo: string; tarih: string; cariId: number; cari: string; stokId: number; kod: string; urun: string;
      miktar: number; fiyat: number; maliyet: number; zarar: number }[];
    dusen: { id: number; ad: string; simdi: number; once: number; degisim: number | null; kayip: boolean }[];
    irsaliye: FaturasizIrsaliye;
    ebelge: { id: number; no: string; cariId: number; cari: string; tarih: string; iade: boolean; durum: string }[];
  };
  secim: { subeler: Secenek[]; temsilciler: Secenek[]; paralar: string[] };
};

// ====================================================================== ALIŞ ==

export type AlisTedarikciSatiri = {
  id: number; ad: string; musteri: boolean; tedarikci: boolean; belge: number;
  brut: number; iskonto: number; iade: number; net: number; gecenYil: number | null; degisim: number | null; pay: number;
  teslimGun: number | null; gecTeslim: boolean; acikBorc: number; sonAlis: string | null; doviz: DovizRozeti[];
  kategoriler: { ad: string; net: number }[]; cubuk: number;
};
export type AlisUrunSatiri = {
  anahtar: string; stokId: number; hizmet: boolean; kod: string; ad: string; kategori: string;
  miktar: number; net: number; ortFiyat: number | null; enDusuk: number | null; enYuksek: number | null; sonFiyat: number | null;
  tedarikci: number; satilan: number | null; stokta: number | null;
  tedarikciler: { id: number; ad: string; miktar: number; ortFiyat: number | null; fark: number | null; enUcuz: boolean }[];
};
export type AlisFiyatSatiri = {
  anahtar: string; stokId: number; kod: string; ad: string; tedarikciId: number; tedarikci: string; para: string;
  ilkFiyat: number; ilkTarih: string; sonFiyat: number; sonTarih: string; degisim: number; etki: number; tutar: number; alis: number;
};
export type AlisIcmali = Ortak & {
  kategori: number; kalem: 'stok' | 'hizmet' | 'hepsi';
  aktarimTahakkuk: AktarimTahakkuk;
  ozet: {
    net: number; brut: number; iskonto: number; iade: number; iadeBelge: number; karsiNet: number; degisim: number | null;
    belge: number; fatura: number; fis: number; tedarikci: number; ilk3Pay: number;
    fiyatArtisi: number | null; fiyatKalem: number; teslimGun: number | null; teslimSiparis: number;
    vadesiGelen: number; vadesiGelenGecmis: number; stokNet: number; hizmetNet: number;
  };
  tedarikciler: AlisTedarikciSatiri[];
  tedarikciToplam: {
    tedarikci: number; belge: number; brut: number; iskonto: number; iade: number; net: number; gecenYil: number;
    degisim: number | null; teslimGun: number | null; acikBorc: number;
  };
  paraTablosu: ParaTablosu;
  urunler: AlisUrunSatiri[];
  fiyat: { satirlar: AlisFiyatSatiri[]; kalem: number; agirlikliDegisim: number | null; etki: number };
  trend: {
    aylar: { ay: string; net: number; gecenYil: number; degisim: number | null; stokAlis: number; smm: number | null;
      fark: number | null; kismiGun: number | null; cubuk: number }[];
  };
  dikkat: {
    sozlesmeUstu: { belgeId: number; belgeNo: string; tarih: string; cariId: number; cari: string; kod: string; urun: string;
      para: string; fiyat: number; sozlesme: number; sozlesmeNo: string; fark: number }[];
    ucuz: { stokId: number; urun: string; alinanId: number; alinan: string; fiyat: number; miktar: number;
      ucuzId: number; ucuz: string; ucuzFiyat: number; fark: number; kayip: number }[];
    irsaliye: FaturasizIrsaliye;
    geciken: { id: number; no: string; cariId: number; cari: string; termin: string; acikMiktar: number; siparisTarihi: string; gecikme: number }[];
    gelen: { id: number; cariId: number; cari: string; no: string; tarih: string | null; tutar: number; para: string; bekleyen: number | null; tur: string }[];
    gelenTutar: number;
  };
  secim: { subeler: Secenek[]; paralar: string[]; kategoriler: Secenek[] };
};

export const ticariIcmalUclari = {
  satisIcmali: (q: URLSearchParams) => istek<SatisIcmali>(`/api/ticari-icmal/satis?${q}`),
  alisIcmali: (q: URLSearchParams) => istek<AlisIcmali>(`/api/ticari-icmal/alis?${q}`),
};
