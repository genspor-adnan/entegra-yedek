import { gonder, istek } from '../cekirdek';

/**
 * SATINALMA SÜREÇ İCMALİ (SatinalmaIcmalUclari, `/api/satinalma-icmal`).
 * Dönem talep tarihidir; aşama sayıları, süreler, tasarruf ve bütçe sunucuda hesaplanır, ekran toplamaz.
 * Alan adları sunucuyla birebir.
 */
type Secenek = { id: number; ad: string };
/** Kalem rozeti (karar 25.10.2026 - hizmet alımları dahil). */
export type KalemTuru = 'urun' | 'hizmet' | 'karma';

export type HuniSatiri = {
  sira: number; kod: 'talep' | 'onay' | 'teklif' | 'siparis' | 'kabul' | 'fatura' | 'odeme'; ad: string;
  adet: number; tutar: number; bekleyen: number | null; bekleyenNot: string;
  ortGun: number | null; hedefGun: number | null; hedefAsimi: boolean; cubuk: number;
};

export type BekleyenSatiri = {
  anahtar: string; belgeTur: 'talep' | 'teklif' | 'siparis' | 'fatura'; id: number; talepId: number; no: string;
  asama: string; talepEden: string; konu: string; kalem: KalemTuru; tutar: number; kimde: string; gun: number;
  oncelik: 'acil' | 'yuksek' | 'normal'; gecikme: boolean; not: string;
  hatirlatmaSayi: number; sonHatirlatma: string | null; bugunHatirlatildi: boolean; hatirlatilabilir: boolean; bolundu: boolean;
};

export type TedarikciKarneSatiri = {
  id: number; ad: string; siparis: number; tutar: number; zamanindaOran: number | null; olculen: number; ortGecikme: number | null;
  eksikFazla: number; kaliteRet: number; fiyatSapma: number | null; faturaFark: number; skor: number | null;
  hizmet: boolean; urun: boolean;
  olaylar: { zaman: string; tur: number; turAd: string; aciklama: string; skorEtki: number; belgeId: number }[];
};

export type FiyatSatiri = {
  anahtar: string; stokId: number; hizmet: boolean; kod: string; ad: string; tedarikci: string;
  onceki3: number | null; onceki3Tarih: string | null; onceki2: number; onceki2Tarih: string; son: number; sonTarih: string;
  degisim: number | null; yuksek: boolean; miktar: number; etki: number;
};

export type TasarrufSatiri = {
  siparisId: number; siparisNo: string; teklifId: number; teklifNo: string; talepNo: string; tedarikci: string;
  teklifSayisi: number; ortTeklif: number; kazananTeklif: number; siparisTutar: number; tasarruf: number; oran: number | null;
  sonAlisFark: number | null; kalem: KalemTuru;
};

export type ButceSatiri = {
  id: number; kod: string; ad: string; plan: number; gerceklesen: number; taahhut: number; kalan: number; kullanim: number;
  asim: number; asimAd: string; onayliTalep: number;
};

export type KritikTalepSatiri = {
  id: number; no: string; tarih: string; elle: boolean; kaynakAd: string; urun: string; miktar: number; durum: number; durumAd: string;
  talepSiparisGun: number | null; tedarikci: string; siparisId: number; bolundu: boolean;
};

export type SatinalmaIcmali = {
  bas: string; bit: string; sube: number; departman: number; kategori: number; tedarikci: number; butceKalem: number; kaynak: number; yil: number;
  /** Genel Ayarlar satinalma.hedef_gun_* - boş = hedef yok, yalnız ortalama (karar 25.10.2026). */
  hedefler: { onay: number | null; teklif: number | null; siparis: number | null; kabul: number | null; odeme: number | null };
  ozet: {
    talep: number; talepTutar: number; kritik: number; hizmetTalep: number;
    acik: number; onayda: number; teklifte: number; onayli: number; taslak: number;
    talepSiparisGun: number | null; talepSiparisMedyan: number | null; bolunen: number;
    siparis: number; kabulGun: number | null; terminUyum: number | null;
    teklifTalep: number | null; tekTeklif: number; tekTeklifTutar: number;
    tasarruf: number; tasarrufOran: number | null; sonAlisFark: number; tasarrufSiparis: number;
    uyusmaz: number; odemeDurdu: number; farkTutar: number; odemeOnay: number; siparisTutar: number;
    butceKullanim: number | null; uzunOnay: number; uzunOnayEsik: number; tedarikci: number;
  };
  huni: HuniSatiri[];
  redIptal: { adet: number; tutar: number };
  bekleyenler: BekleyenSatiri[];
  bekleyenSayi: number;
  tedarikciler: TedarikciKarneSatiri[];
  fiyat: { satirlar: FiyatSatiri[]; kalem: number; etki: number };
  tasarruf: { satirlar: TasarrufSatiri[]; toplam: number; oran: number | null; sonAlisFark: number; tekTeklif: number; tekTeklifTutar: number };
  butce: {
    yil: number; satirlar: ButceSatiri[];
    toplam: { plan: number; gerceklesen: number; taahhut: number; onayliTalep: number; kalan: number; kullanim: number | null };
  };
  kritik: KritikTalepSatiri[];
  secim: { subeler: Secenek[]; departmanlar: Secenek[]; kategoriler: Secenek[]; tedarikciler: Secenek[]; butceler: Secenek[] };
  yetkiler: { hatirlat: boolean };
  izlemeNo: string;
};

export type HatirlatYaniti = {
  belgeTur: string; belgeId: number; talepNo: string; basamak: number; adimAd: string;
  alicilar: Secenek[]; eskalasyon: boolean; ikinci: boolean;
  ustAdim: { basamak: number; ad: string } | null; ustBilgi: Secenek[];
  bildirim: number; beklemeGun: number; izlemeNo: string;
};

export const satinalmaIcmalUclari = {
  satinalmaIcmali: (q: URLSearchParams) => istek<SatinalmaIcmali>(`/api/satinalma-icmal?${q}`),
  /**
   * Onaycıya hatırlat: aynı belge için günde bir (ikinci istek 422 IS_KURALI, engel.kod = GUNDE_BIR);
   * aynı onaycıya ikinci kez hatırlatılıyorsa bir üst basamağa da bilgi gider.
   */
  hatirlat: (belgeTur: 'talep', belgeId: number) =>
    gonder<HatirlatYaniti>('/api/satinalma-icmal/hatirlat', { belgeTur, belgeId }),
};
