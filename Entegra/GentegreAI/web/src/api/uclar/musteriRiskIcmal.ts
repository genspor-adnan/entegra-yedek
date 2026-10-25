import { gonder, istek } from '../cekirdek';

/**
 * Müşteri Risk / Limit İcmali (MusteriRiskIcmalUclari, 1178) - rakamlar sunucuda hesaplanır, ekran toplamaz.
 * Sunucu null alanları yazmaz: `?` işaretli alanlar yoksa "tanımsız / yok" demektir.
 */
export type RiskDurumu = 'tanimsiz' | 'kurYok' | 'asim' | 'yaklasiyor' | 'uygun';
export type BlokeOneriKodu = 'blokele' | 'uyar' | 'kalsin' | 'kaldir';

export type RiskMusteri = {
  id: number; kod: string; ad: string; temsilci: string; temsilciId: number; riskGrubu: string;
  bakiye: number; vadesiGecen: number; cek: number; cekAdet: number; cek7Gun: number;
  irsaliye: number; irsaliyeAdet: number; siparis: number; siparisAdet: number; toplam: number;
  /** Kendi dövizinde; yoksa limit TANIMSIZ (limitsiz değil). */
  limit?: number; limitDoviz: string; limitTl?: number; kullanim?: number; asim: number; durum: RiskDurumu;
  teminat: number; teminatAdet: number; teminatOzet: string; teminatIcinde: boolean;
  sevkBlokesi: boolean; blokeNeden: string; blokeKim: string; blokeAn?: string;
  skor?: string; skorPuan?: number; kurYok: boolean; surum: string;
  sonLimitAn?: string; sonLimitKim?: string;
  yas: { gelmemis: number; d30: number; d60: number; d90: number; d90p: number; enEskiGun: number; enEskiTarih?: string };
  odeme?: RiskOdeme;
  karsiliksiz: number; karsiliksiz12: number; karsiliksizYil?: number;
  sonTahsilat?: string; sonTahsilatGun?: number;
  oneri?: { kod: BlokeOneriKodu; ad: string; nedenler: string[] };
};
export type RiskOdeme = {
  fatura: number; ortVade?: number; ortOdeme?: number; ortGecikme?: number; zamaninda?: number;
  egilim: '' | 'iyilesiyor' | 'kotulesiyor' | 'sabit';
};

export type MusteriRiskIcmali = {
  tarih: string; sube: number; temsilci: number; grup: string;
  cekDahil: boolean; siparisDahil: boolean; tanimsizGizle: boolean;
  /** `satis.limit_davranis`: satış belgesinde limit aşımı / blokede ne olur. */
  davranis: 'uyar' | 'engelle';
  ozet: {
    toplamRisk: number; musteri: number; acikBakiye: number; vadesiGecen: number; vadesiGecenYuzde: number;
    vadesiGecenMusteri: number; cek: number; cekAdet: number; irsaliye: number; siparis: number;
    limitAsan: number; asimTutar: number; yaklasan: number; ilk10Pay: number;
    limitTanimli: number; limitTanimsiz: number; blokeli: number; oneri: number; kurYok: number; cekRiskli: number;
  };
  musteriler: RiskMusteri[];
  limitAsimi: {
    id: number; ad: string; toplam: number; limit?: number; limitDoviz: string; limitTl?: number; asim: number; kullanim?: number;
    teminat: number; teminatOzet: string; teminatIcinde: boolean; sonLimitAn?: string; sonLimitKim?: string;
    durum: RiskDurumu; durumMetni: string;
  }[];
  yaslandirma: { id: number; ad: string; yas: RiskMusteri['yas']; ortGecikme?: number; vadesiGecen: number }[];
  yasToplam: { gelmemis: number; d30: number; d60: number; d90: number; d90p: number; ortGecikme?: number };
  cekRiski: {
    tarafId: number; cari: string; kesideci: string; ucuncuKisi: boolean; banka: string; adet: number; tutar: number;
    ilkVade: string; sonVade: string; yediGun: number; karsiliksiz: number; karsiliksizYil?: number; uyarilar: string[]; riskli: boolean;
  }[];
  odemeDavranisi: {
    id: number; ad: string; odeme: RiskOdeme; karsiliksiz12: number; karsiliksiz: number;
    skor?: string; skorPuan?: number; kullanim?: number;
  }[];
  yogunlasma: { sira: number; id: number; ad: string; toplam: number; pay: number; kumulatif: number; yuksek: boolean }[];
  blokeOnerisi: {
    id: number; ad: string; nedenler: string[]; toplam: number; asim: number; sevkBlokesi: boolean; blokeNeden: string;
    oneri: BlokeOneriKodu; oneriAd: string;
  }[];
  gruplar: { ad: string; musteri: number; toplam: number; limitTl?: number; asan: number }[];
  secim: { subeler: { id: number; ad: string }[]; temsilciler: { id: number; ad: string }[]; riskGruplari: string[] };
  yetkiler: { limit: boolean };
};

export type Teminat = {
  id: number; tur: number; turAdi: string; tutar: number; doviz: string; baslangic?: string; bitis?: string;
  aciklama: string; aktif: boolean; ekleyen: string; eklemeTarihi: string; surum: string;
};
export type TeminatYazma = {
  tarafId: number; tur: number; tutar: number; doviz: string; baslangic: string | null; bitis: string | null;
  aciklama: string; surum?: string;
};

/** Tek müşteri - cari kartı Satış & Risk sekmesi ve icmal pencereleri (satış belgesi kontrolüyle aynı hesap). */
export type MusteriRiskOzeti = {
  tarafId: number; ad: string; bakiye: number; cek: number; cekAdet: number; cekIlkVade?: string;
  irsaliye: number; irsaliyeAdet: number; siparis: number; siparisAdet: number; toplam: number;
  limit?: number; limitDoviz: string; limitTl?: number; kullanim?: number; asim: number; durum: RiskDurumu;
  teminat: number; teminatAdet: number; teminatOzet: string;
  sevkBlokesi: boolean; blokeNeden: string; blokeKim: string; blokeAn?: string; riskGrubu: string; kurYok: boolean; surum: string;
  teminatlar: Teminat[]; davranis: 'uyar' | 'engelle'; yetkiler: { limit: boolean };
};

const Y = '/api/musteri-risk-icmal';

export const musteriRiskIcmalUclari = {
  musteriRiskIcmali: (q: URLSearchParams) => istek<MusteriRiskIcmali>(`${Y}?${q}`),
  musteriRiskOzeti: (tarafId: number) => istek<MusteriRiskOzeti>(`${Y}/taraf/${tarafId}`),
  /** limit null = tanımsız; riskGrubu verilmezse değişmez. Hiçbir alan değişmediyse `degisti: false`. */
  musteriRiskLimit: (g: { tarafId: number; limit: number | null; doviz: string; riskGrubu?: string; neden: string; surum?: string }) =>
    gonder<{ degisti: boolean; surum: string }>(`${Y}/limit`, g),
  musteriRiskBloke: (tarafId: number, bloke: boolean, neden: string) =>
    gonder<{ sevkBlokesi: boolean; surum: string }>(`${Y}/bloke`, { tarafId, bloke, neden }),
  musteriTeminatlari: (tarafId: number) =>
    istek<{ teminatlar: Teminat[]; yetkiler: { limit: boolean } }>(`${Y}/teminat?tarafId=${tarafId}`),
  musteriTeminatEkle: (g: TeminatYazma) => gonder<{ id: number }>(`${Y}/teminat`, g),
  musteriTeminatGuncelle: (id: number, g: TeminatYazma) => gonder<{ degisti: boolean; surum: string }>(`${Y}/teminat/${id}`, g, 'PUT'),
  musteriTeminatSil: (id: number) => istek<{ silindi: boolean }>(`${Y}/teminat/${id}`, { method: 'DELETE' }),
};
