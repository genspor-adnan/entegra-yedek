import { gonder, istek } from '../cekirdek';

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

// ------------------------------------------------- ikinci üçlü (1174) --
type SecimListeleri = { kategoriler: Secenek[]; depoListesi: Secenek[] };

export type HareketKolonu = { yon: 'giris' | 'cikis'; anahtar: string; ad: string };
export type HareketStokSatiri = {
  id: number; kod: string; ad: string; kategori: string; birim: string; devir: number;
  giris: Record<string, number>; cikis: Record<string, number>; girisToplam: number; cikisToplam: number;
  transferGiren: number; transferCikan: number; kalan: number; hareket: number; eksiyeDustu: boolean;
  depolar: { depoId: number; depo: string; devir: number; giris: number; cikis: number; transfer: number; kalan: number }[];
};
export type StokHareketIcmali = {
  bas: string; bit: string; birim: 'miktar' | 'tutar'; depo: number;
  ozet: {
    devir: number; kalan: number; giris: number; cikis: number; transfer: number; sayimNet: number; sayimFazla: number;
    sayimEksik: number; kalem: number; bakiyeliKalem: number; belge: number; eksiyeDusen: number; gun: number;
    /** Yalnız tutarda: kalan − (devir + giriş − çıkış ± transfer); girişler belge fiyatıyla, devir / kalan ortalama maliyetle. */
    degerlemeFarki?: number;
  };
  kolonlar: HareketKolonu[]; stoklar: HareketStokSatiri[];
  donemTuru: 'hafta' | 'ay'; donemler: string[];
  turDonem: { yon: 'giris' | 'cikis'; anahtar: string; ad: string; hucreler: number[]; toplam: number; belge: number }[];
  transferDonem: number[];
  depoAkis: { depoId: number; depo: string; devir: number; giris: number; cikis: number; transfer: number; kalan: number }[];
  transferMatrisi: { cikisId: number; cikis: string; girisId: number; giris: string; miktar: number; fis: number }[];
  ekstre: null | {
    stok: { id: number; kod: string; ad: string } | null; devir: number; giren: number; cikan: number; kalan: number; sinirli: boolean;
    hareketler: { tarih: string; belgeId: number; tur: number; belge: string; belgeNo: string; cari: string; aciklama: string;
      depo: string; giren: number; cikan: number; bakiye: number; lot: string }[];
  };
  secim: SecimListeleri;
};

export type OluStokSatiri = {
  id: number; kod: string; ad: string; kategori: string; birim: string; miktar: number; birimMaliyet: number; tutar: number;
  sonGiris: string | null; sonCikis: string | null; gun: number | null; hicCikmadi: boolean; enYakinSkt: string | null;
  depolar: { depoId: number; depo: string; miktar: number }[];
  oneri: 'skt' | 'transfer' | 'iade' | 'sayim' | 'kampanya'; oneriNot: string; abc: 'A' | 'B' | 'C';
  tedarikci: string; sonAlisTarihi: string | null; transferDepoId: number | null;
};
export type OluStokIcmali = {
  tarih: string; esik: number; hareket: 'cikis' | 'her'; depo: number;
  ozet: {
    deger: number; oluDeger: number; oluKalem: number; oluOran: number; devir: number; devirGun: number | null;
    hicCikmayan: number; hicCikmayanDeger: number; yavasKalem: number; yavasDeger: number;
    oluSktYakin: number; oluSktYakinDeger: number; aKalem: number; kalem: number;
    buDonemDusen: number; buDonemCikan: number; oncekiOran: number;
  };
  oluler: OluStokSatiri[];
  devir: { id: number; kod: string; ad: string; kategori: string; miktar: number; tutar: number; ortalamaStok: number;
    cikan12: number; devir: number; devirGun: number | null; sinif: 'hizli' | 'normal' | 'yavas' | 'olu'; abc: 'A' | 'B' | 'C' }[];
  matris: { abc: 'A' | 'B' | 'C'; hucreler: { sinif: string; kalem: number; tutar: number }[] }[];
  pareto: { abc: string; kalem: number; kalemOran: number; cikisOran: number }[];
  trend: { tarih: string; olu: number; kalem: number; deger: number; oran: number }[];
  secim: SecimListeleri;
};

export type KritikSatiri = {
  stokId: number; kod: string; ad: string; kategori: string; birim: string; depoId: number; depo: string;
  eldeki: number; yolda: number; min: number | null; max: number | null; gunluk: number; yeter: number | null;
  kritik: boolean; yok: boolean; tukeniyor: boolean; siparis: number; fiyat: number; tutar: number;
  /** SKT'si 30 gün içinde dolan (ya da geçmiş) lot miktarı - eldekinden düşülmüştür. */
  sktYakin: number;
  tedarikci: string; sonAlisTarihi: string | null; talep: string; siparisNo: string; minTanimsiz: boolean;
  baskaDepo: string; baskaDepoId: number | null; baskaFazla: number;
};
export type KritikStokIcmali = {
  depo: number; gun: number; tedarik: number; tip: number; tipler: Secenek[];
  ozet: {
    kritik: number; yok: number; tukeniyor: number; yolda: number; siparisTutar: number; siparisKalem: number;
    minTanimsiz: number; satir: number; minTanimsizA: number; maxUstu: number; maxUstuTutar: number; baskaDepoda: number;
    otomatikTalep: boolean; hedefKat: number; cikissiz: number; sktYakinKalem: number; sktYakinMiktar: number;
  };
  kritikler: KritikSatiri[];
  takvim: { ad: string; kalem: number; tedarikIcinde: number; ornekler: { kod: string; ad: string; depo: string; yeter: number | null; yolda: number }[] }[];
  oneriler: { stokId: number; kod: string; ad: string; depoId: number; depo: string; abc: 'A' | 'B' | 'C'; gunluk: number; sigma: number;
    tedarik: number; min: number | null; max: number | null; kartMin: number | null; oneriMin: number; oneriMax: number; eldeki: number }[];
  maxUstu: { stokId: number; kod: string; ad: string; depoId: number; depo: string; eldeki: number; max: number; fazla: number;
    tutar: number; fazlaGun: number | null; oneri: 'transfer' | 'durdur'; oneriDepo: string; acikTalep: boolean }[];
  secim: SecimListeleri;
  yetkiler: { talep: boolean; limit: boolean };
};

export const stokIcmalUclari2 = {
  stokHareketIcmali: (q: URLSearchParams) => istek<StokHareketIcmali>(`/api/stok-icmal/hareket?${q}`),
  oluStokIcmali: (q: URLSearchParams) => istek<OluStokIcmali>(`/api/stok-icmal/olu?${q}`),
  kritikStokIcmali: (q: URLSearchParams) => istek<KritikStokIcmali>(`/api/stok-icmal/kritik?${q}`),
  kritikTalepAc: (depoId: number, satirlar: { stokId: number; miktar: number }[], aciklama?: string) =>
    gonder<{ id: number; talepNo: string; kalem: number; atlanan: number }>('/api/stok-icmal/kritik/talep', { depoId, satirlar, aciklama }),
  kritikLimitYaz: (depoId: number, satirlar: { stokId: number; min: number | null; max: number | null }[]) =>
    gonder<{ yazilan: number }>('/api/stok-icmal/kritik/limit', { depoId, satirlar }),
};
