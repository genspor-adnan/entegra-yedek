import { istek } from '../cekirdek';

/**
 * Kârlılık İcmali (KarlilikIcmalUclari) - `/api/karlilik-icmal`. Rakamlar sunucuda: net satış
 * belge dip toplamından (KDV hariç) satırlara dağıtılır, maliyet satış anındaki ortalama
 * maliyet (maliyetKipi 'bugun' yalnız bilgi; `a4` her zaman satış anıyla). Para birimi seçiliyse
 * tutarlar o dövizin cinsinden, değilse TL karşılığı (belge kuruyla). Ekran hesap yapmaz.
 */
type Secenek = { id: number; ad: string };
type DovizRozeti = { para: string; tutar: number };

/** İki seviye (karar 25.10.2026): 'zarar' maliyet altı (kırmızı) · 'hedef_alti' hedef marjın altı (sarı). */
export type KarSeviye = 'zarar' | 'hedef_alti' | '';
/** Ürünün maliyet kaynağı: satış anı ortalaması · kart alış fiyatı · bir kısmı / hepsi maliyetsiz · hizmet (maliyet 0). */
export type MaliyetKaynagi = 'ortalama' | 'kart' | 'kismi' | 'maliyetsiz' | 'hizmet';

export type KarlilikMusteriSatiri = {
  id: number; ad: string; musteri: boolean; tedarikci: boolean; temsilci: string;
  net: number; maliyet: number; kar: number; marj: number | null;
  oncekiMarj: number | null; yeni: boolean; marjDegisim: number | null; iskonto: number;
  /** Kâra katkıya göre ABC (A ilk %80, B sonraki %15, C kalan). */
  abc: 'A' | 'B' | 'C'; karPayi: number; cubuk: number; seviye: KarSeviye;
  maliyetsiz: number; zararli: number; doviz: DovizRozeti[];
  urunSayisi: number;
  urunler: { anahtar: string; ad: string; miktar: number; net: number; kar: number; marj: number | null; maliyetsiz: boolean }[];
};

export type KarlilikUrunSatiri = {
  anahtar: string; stokId: number; hizmet: boolean; kod: string; ad: string; kategori: string;
  miktar: number; ortSatis: number | null; ortMaliyet: number | null;
  net: number; maliyet: number; kar: number; marj: number | null; oncekiMarj: number | null; marjDegisim: number | null;
  maliyetKaynagi: MaliyetKaynagi; seviye: KarSeviye; zararli: number;
  musteri: number; musteriler: { id: number; ad: string; miktar: number; net: number; kar: number }[];
};

export type KarlilikTemsilciSatiri = {
  id: number; ad: string; musteri: number; net: number; kar: number; marj: number | null;
  iskonto: number; iskontoOran: number; zararli: number; tahsil: number; seviye: KarSeviye;
};

export type ZararliSatir = {
  belgeId: number; belgeNo: string; tarih: string; cariId: number; cari: string; temsilci: string;
  stokId: number; kod: string; urun: string; miktar: number;
  netFiyat: number; maliyet: number; fark: number; iskonto: number;
  listeFiyati: number | null; sonAlis: number | null;
  neden: 'yuksek_iskonto' | 'maliyet_arti' | ''; nedenAdi: string;
};

export type MatrisHucresi = {
  ciro: 'A' | 'B' | 'C'; marj: 'dusuk' | 'orta' | 'yuksek'; musteri: number; net: number; kar: number;
  /** Isı kademesi 0-4 (sunucu hesaplar). */
  isi: number; oneri: string;
  musteriler: { id: number; ad: string; net: number; kar: number; marj: number | null }[];
};

export type KarlilikIcmali = {
  bas: string; bit: string; karsi: { tur: 'gy' | 'od'; bas: string; bit: string }; gun: number;
  iadeDus: boolean; hizmetDahil: boolean; maliyetsizHaric: boolean; maliyetKipi: 'satis' | 'bugun';
  /** '' = TL karşılığı; dolu = yalnız o döviz, tutarlar o dövizde. */
  para: string; yerelPara: string; sube: number; temsilci: number; kategori: number;
  hedefMarj: number; esik: { dusukMarj: number; yuksekMarj: number; yuksekIskonto: number };
  ozet: {
    net: number; maliyet: number; kar: number; marj: number | null;
    karsiKar: number; karsiMarj: number | null; marjFark: number | null;
    iskonto: number; iskontoKarOran: number; iade: number; iadeMaliyet: number;
    belge: number; iadeBelge: number; musteri: number; kalem: number;
    zararli: { satir: number; tutar: number; musteri: number };
    maliyetsiz: { satir: number; net: number; haric: boolean; urun: number };
    hizmet: { net: number; pay: number; dahil: boolean };
  };
  /** Delphi'den satırsız aktarılan satış tahakkuku (17): icmale girmez, yalnız bilgi. */
  aktarimTahakkuk: { belge: number; tutar: number };
  musteriler: KarlilikMusteriSatiri[];
  musteriToplam: { musteri: number; net: number; maliyet: number; kar: number; marj: number | null; oncekiMarj: number | null; iskonto: number };
  urunler: KarlilikUrunSatiri[];
  temsilciler: KarlilikTemsilciSatiri[];
  temsilciToplam: { musteri: number; net: number; kar: number; marj: number | null; iskonto: number; iskontoOran: number; zararli: number; tahsil: number };
  kirilim: {
    kategori: { ad: string; net: number; kar: number; marj: number | null; pay: number; seviye: KarSeviye }[];
    subeDepo: { ad: string; net: number; kar: number; marj: number | null }[];
    para: {
      satirlar: { para: string; yerel: boolean; belge: number; doviz: number | null; tl: number; tlMaliyet: number; marj: number | null }[];
      toplam: { belge: number; tl: number; tlMaliyet: number; marj: number | null };
    };
  };
  zararli: { satirlar: ZararliSatir[]; sayi: number; tutar: number };
  matris: MatrisHucresi[];
  trend: {
    aylar: {
      ay: string; net: number; maliyet: number; kar: number; marj: number | null; iskontoOran: number;
      maliyetsiz: number; belge: number; aktarim: number; aktarimSatirYok: boolean; kismiGun: number | null; cubuk: number;
    }[];
  };
  /** A4 her zaman SATIŞ ANINDAKİ maliyetle (şeritte "Bugünkü maliyetle" seçili olsa da). */
  a4: {
    musteriler: { id: number; ad: string; net: number; maliyet: number; kar: number; marj: number | null }[];
    toplam: { net: number; maliyet: number; maliyetsizNet: number; kar: number; marj: number | null; musteri: number; kalem: number };
    doviz: DovizRozeti[];
  };
  secim: { subeler: Secenek[]; temsilciler: Secenek[]; paralar: string[]; kategoriler: Secenek[] };
  izlemeNo: string;
};

export const karlilikIcmalUclari = {
  karlilikIcmali: (q: URLSearchParams) => istek<KarlilikIcmali>(`/api/karlilik-icmal?${q}`),
};
