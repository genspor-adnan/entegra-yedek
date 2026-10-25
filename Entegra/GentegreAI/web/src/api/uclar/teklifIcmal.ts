import { gonder, istek } from '../cekirdek';

/**
 * Teklif / Fırsat Dönüşüm İcmali (TeklifIcmalUclari, 1186) - `/api/teklif-icmal`. Rakamlar sunucuda: tutar
 * teklifin dip toplamı (KDV hariç, TL), dönen tutar teklif satırından türeyen sipariş / irsaliye / fatura
 * miktarıyla ağırlıklı. Süresi dolan teklif gece "kaybedildi · süre doldu" olur. Ekran hesap yapmaz.
 * Sunucu null alanları yazmaz: `?` işaretli alanlar yoksa "yok / tanımsız" demektir.
 */
type Secenek = { id: number; ad: string };

/** dondu · kismen · kaybedildi · iptal · kabul (sipariş bekliyor) · suresi_doldu (gece işi bekliyor) · hazirlaniyor · bekliyor */
export type TeklifDurumu = 'dondu' | 'kismen' | 'kaybedildi' | 'iptal' | 'kabul' | 'suresi_doldu' | 'hazirlaniyor' | 'bekliyor';

export type TeklifSatiri = {
  id: number; no: string; tarih: string; tarafId: number; cari: string; musteri: boolean; tedarikci: boolean; temsilci: string;
  tutar: number; iskonto: number; gecerlilik?: string; revize: string; konu: string;
  durum: TeklifDurumu; durumAdi: string; donenTutar: number; donenOran: number; ilkDonus?: string;
  kayipNeden?: number; rakip: string; rakipFiyat?: number; sistem: boolean;
};

export type HuniAsamasi = { asama: string; adet: number; tutar: number; gecis?: number; ortGun?: number };

export type TemsilciDonusum = {
  id: number; ad: string; teklif: number; tutar: number; donen: number; donusum: number; donusumAdet: number;
  kayip: number; ortIskonto: number; ortGun?: number; bekleyen: number;
};

export type MusteriDonusum = {
  id: number; ad: string; musteri: boolean; tedarikci: boolean; teklif: number; tutar: number; donen: number; donusum: number;
  kayip: number; sonTeklif: string; sonSiparis?: string; dusuk: boolean;
};

export type TakipSatiri = {
  id: number; no: string; tarih: string; tarafId: number; cari: string; musteri: boolean; tedarikci: boolean; temsilci: string;
  tutar: number; gecerlilik?: string; kalanGun?: number; hareketsizGun: number;
  durum: 'bugun' | 'yarin' | 'yakin' | 'hareketsiz'; durumAdi: string;
};

export type TeklifIcmali = {
  bas: string; bit: string; bugun: string; sube: number; temsilci: number; takipGun: number;
  ozet: {
    teklif: number; tutar: number; iptal: number; donenAdet: number; donenTutar: number; donusumTutar: number; donusumAdet: number;
    kaybedilenAdet: number; kaybedilenTutar: number; kayipOran: number; bekleyenAdet: number; bekleyenTutar: number;
    ortDonusGun?: number; ortIskonto: number; kazanilanIskonto: number;
    firsat: { adet: number; acik: number; acikTutar: number; agirlikli: number };
    sureDolanAdet: number; sureDolanTutar: number; dolacakAdet: number; dolacakTutar: number;
  };
  huni: HuniAsamasi[];
  teklifler: TeklifSatiri[]; teklifSayi: number;
  temsilciler: TemsilciDonusum[];
  temsilciToplam: { teklif: number; tutar: number; donen: number; donusum: number; kayip: number; ortIskonto: number; ortGun?: number; bekleyen: number };
  musteriler: MusteriDonusum[];
  kategoriler: { ad: string; satir: number; tutar: number; donen: number; donusum: number; ortIskonto: number }[];
  kayiplar: { neden: number; ad: string; adet: number; tutar: number; pay: number; rakipler: string; ortFiyatFark?: number }[];
  kayipToplam: { adet: number; tutar: number };
  takip: TakipSatiri[];
  esik: { dusukTeklif: number; dusukYuzde: number };
  otomatikKayip: boolean;
  secim: { subeler: Secenek[]; temsilciler: Secenek[]; kayipNedenleri: Secenek[] };
  yetkiler: { kayip: boolean };
  izlemeNo: string;
};

const Y = '/api/teklif-icmal';

export const teklifIcmalUclari = {
  teklifIcmali: (q: URLSearchParams) => istek<TeklifIcmali>(`${Y}?${q}`),
  /** Teklifi kaybedildi işaretle (satis.teklif_kayip). Neden zorunlu; kısmen dönmüş teklif reddedilir. */
  teklifKayip: (g: { belgeId: number; neden: number; rakip?: string; rakipFiyat?: number | null; aciklama?: string }) =>
    gonder<{ belgeId: number; durum: string }>(`${Y}/kayip`, g),
};
