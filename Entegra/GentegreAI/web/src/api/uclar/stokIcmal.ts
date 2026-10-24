import { istek } from '../cekirdek';

/** Stok icmalleri (StokIcmalUclari, 1173). Rakamlar sunucuda hesaplanır. */
type Secenek = { id: number; ad: string };

export type StokDegerSatiri = {
  id: number; kod: string; ad: string; kategori: string; izleme: number; birim: string;
  miktar: number; birimMaliyet: number; tutar: number;
  sonGiris: string | null; sonCikis: string | null; cikan12: number;
  /** Son hareketten (giriş ya da çıkış) bu yana gün; hiç hareket yoksa null. */
  hareketsizGun: number | null;
  depolar: { depoId: number; depo: string; miktar: number }[];
  lotlar: { lot: string; skt: string | null; kalan: number; depoId: number }[];
  /** İzlemli stokta depo bakiyesi - lot toplamı (yalnız bugün). */
  lotsuz: number;
};
export type StokDegerIcmali = {
  tarih: string; bugun: boolean; yontem: 'ort' | 'son' | 'satis';
  ozet: {
    deger: number; kalem: number; aktifStok: number; miktar: number; lotluKalem: number; lotluDeger: number; lotSayisi: number;
    hareketsizDeger: number; hareketsizKalem: number; maliyetsiz: number; eksiKalem: number; eksiMiktar: number;
    oncekiAySonu: string; oncekiDeger: number;
  };
  stoklar: StokDegerSatiri[];
  depolar: Secenek[];
  katDepo: { kategori: string; hucreler: number[]; toplam: number; kalem: number }[];
  yas: { ad: string; tutar: number; kalem: number }[];
  devir: { kategori: string; devir: number; gun: number | null; stokDeger: number }[];
  dikkat: {
    eksi: { id: number; kod: string; ad: string; depo: string; miktar: number; sonCikis: string | null }[];
    maliyetsiz: { id: number; kod: string; ad: string; miktar: number; sonGiris: string | null }[];
    lotUyumsuz: { id: number; kod: string; ad: string; miktar: number; lotToplam: number; lotsuz: number }[];
    hareketsiz: { id: number; kod: string; ad: string; tutar: number; sonCikis: string | null; hareketsizGun: number | null }[];
  };
  kategoriler: Secenek[]; depoListesi: Secenek[];
};

export type SktLotSatiri = {
  stokId: number; kod: string; ad: string; kategori: string; izleme: number; depoId: number; depo: string;
  seriLotId: number; lot: string; uretim: string | null; skt: string | null; kalanGun: number | null;
  kalan: number; birimMaliyet: number; tutar: number; cikan90: number; tahminiArtan: number;
  /** imha · fefo · hiz (satış hızı yetmez) · takip · eksi · sktsiz · '' */
  oneri: string;
};
type SktKutu = { tutar: number; lot: number; miktar: number };
export type SktIcmali = {
  tarih: string; ufuk: number;
  ozet: {
    gecmis: SktKutu; gun30: SktKutu; gun90: SktKutu; gun180: SktKutu; ufukOtesi: SktKutu; sktsiz: SktKutu;
    lotluDeger: number; lotluKalem: number; lotSayisi: number; eksiLot: number; eksiMiktar: number; lotsuzKalem: number;
  };
  takvim: {
    gecmis: { lot: number; miktar: number; tutar: number; enBuyuk: string };
    aylar: { ay: string; lot: number; miktar: number; tutar: number; enBuyuk: string }[];
    otesi: { lot: number; tutar: number };
  };
  lotlar: SktLotSatiri[];
  stoklar: {
    stokId: number; kod: string; ad: string; izleme: number; lot: number; toplam: number; enYakin: string | null;
    yakin90: number; gecmis: number; lotsuz: number;
    lotlar: { lot: string; skt: string | null; kalan: number; depo: string }[];
  }[];
  dikkat: {
    eksi: { stokId: number; kod: string; ad: string; lot: string; skt: string | null; kalan: number; depo: string }[];
    lotsuz: { stokId: number; kod: string; ad: string; depo: string; stok: number; lotToplam: number; lotsuz: number }[];
    sktsiz: { stokId: number; kod: string; ad: string; lot: string; kalan: number; depo: string }[];
    hiz: { stokId: number; kod: string; ad: string; lot: string; skt: string | null; kalan: number; cikan90: number; tahminiArtan: number }[];
  };
  kategoriler: Secenek[]; depoListesi: Secenek[];
};

export type SayimFarkIcmali = {
  bas: string; bit: string; acikDahil: boolean;
  ozet: {
    sayim: number; kapanan: number; acik: number; sayilanSatir: number; dogruluk: number | null;
    fazla: number; fazlaKalem: number; eksik: number; eksikKalem: number; net: number; tekrar: number; lotsuzFark: number;
  };
  sayimlar: {
    id: number; no: string; tarih: string; depoId: number; depo: string; kapsam: string; durum: number;
    satir: number; sayilan: number; farkVar: number; fazla: number; eksik: number; net: number;
    girisId: number | null; girisNo: string; cikisId: number | null; cikisNo: string;
    farklar: { kod: string; ad: string; lot: string; fark: number; tutar: number }[];
  }[];
  kalemler: {
    stokId: number; kod: string; ad: string; kategori: string; izleme: number; sayim: number; farkCikan: number;
    toplamFark: number; net: number; sonTarih: string; sonFark: number;
    /** tekrar (2+ sayımda eksik) · lot (stok tutuyor, lotlar ters) · tek */
    durum: 'tekrar' | 'lot' | 'tek';
  }[];
  kirilim: {
    kategori: { ad: string; sayilan: number; farkKalem: number; net: number; dogruluk: number }[];
    depo: { ad: string; sayim: number; fazla: number; eksik: number; net: number; son: string }[];
    sayan: { ad: string; satir: number; farkCikan: number }[];
  };
  dikkat: {
    tekrar: { stokId: number; kod: string; ad: string; farkCikan: number; sayim: number; toplamFark: number; net: number }[];
    yuksek: { sayim: string; kod: string; ad: string; lot: string; fark: number; tutar: number }[];
    lotsuz: { sayim: string; kod: string; ad: string; sistem: number; sayilan: number; fark: number }[];
    sayilmayan: { id: number; ad: string; son: string | null; gun: number | null }[];
  };
  depoListesi: Secenek[]; kategoriler: Secenek[];
};

export const stokIcmalUclari = {
  stokDegerIcmali: (q: URLSearchParams) => istek<StokDegerIcmali>(`/api/stok-icmal/deger?${q}`),
  stokSktIcmali: (q: URLSearchParams) => istek<SktIcmali>(`/api/stok-icmal/skt?${q}`),
  stokSayimFarkIcmali: (q: URLSearchParams) => istek<SayimFarkIcmali>(`/api/stok-icmal/sayim-fark?${q}`),
};
