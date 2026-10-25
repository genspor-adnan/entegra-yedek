import { istek } from '../cekirdek';

/**
 * Teknik Servis İcmali (ServisIcmalUclari) - `GET /api/servis-icmal`.
 * Çağrı → iş emri → ziyaret; dönem çağrının açılışına göre. Rakamlar sunucuda
 * (iş emri tutarı fn_servis_is_emri_topla'dan, SLA sla_bitis'ten); ekran hesap yapmaz.
 * Saatler ondalık saat (1 hane), tutarlar KDV hariç TL.
 */
type Secenek = { id: number; ad: string };

export type ServisOzet = {
  cagri: number; kapanan: number; iptal: number; isEmri: number; ziyaret: number;
  acik: number; parcaBekliyor: number; atanmamis: number;
  ilkYanitSaat: number | null; ilkYanitMedyan: number | null; cozumSaat: number | null;
  slaOlculen: number; slaIhlal: number; slaIhlalOran: number | null; slaIhlalAcik: number; slaAsanAcik: number;
  ilkZiyaretCozum: number | null; ilkZiyaretSayi: number; ikinciZiyaret: number;
  tekrarGun: number; tekrar: number; tekrarOran: number | null;
  /** Ciro = ücretli + üretici garantisi (karar 25.10.2026). */
  ciro: number; ciroIscilik: number; ciroParca: number; ciroDiger: number;
  /** Servis maliyeti = sözleşme + kendi garantimiz + iç iş. */
  maliyet: number; maliyetSozlesme: number; maliyetGaranti: number; maliyetIc: number;
  faturasiz: number; faturasizTutar: number; teknisyen: number;
};

export type ServisKapsamSatiri = {
  kod: number; ad: string; cagri: number; isEmri: number; iscilik: number; parca: number; diger: number; toplam: number;
  kime: string; ciro: boolean;
};

export type ServisTeknisyenSatiri = {
  id: number; ad: string; ziyaret: number; cozulen: number; ilkZiyaretCozum: number | null; ilkZiyaretSayi: number;
  iscilikSaat: number; yolKm: number; slaIhlal: number; tekrar: number; ciro: number; imzasiz: number;
  memnuniyet: number | null; puanSayisi: number; ziyaretSayisi: number;
  ziyaretler: {
    id: number; isEmriId: number; isEmriNo: string; tarih: string | null; taraf: string; cihaz: string; sonuc: string;
    saat: number; tutar: number; puan: number | null; imzasiz: boolean;
  }[];
};

export type ServisCihazSatiri = {
  marka: string; model: string; park: number | null; cagri: number; arizaCihaz: number | null; tekrar: number;
  enSikAriza: string; enSikAdet: number; enSikKodlu: boolean; cozumSaat: number | null; parcaTutar: number;
};

export type ServisSlaSatiri = {
  sozlesmeId: number; no: string; taraf: string; kapsam: string; slaSaat: number | null; cagri: number;
  ilkYanitSaat: number | null; ihlal: number; acikIhlal: number; enUzunGecikme: number | null;
  durum: 'uygun' | 'sinirda' | 'ihlal';
};

export type ServisParcaSatiri = {
  anahtar: string; stokId: number; kod: string; ad: string; miktar: number; maliyet: number | null; tutar: number;
  faturalanan: number; faturalanmayan: number; sozlesmeGaranti: number;
  iadeBekliyor: number; iadeGeciken: number; iadeToplandi: number;
};

export type ServisSozlesmeSatiri = {
  id: number; no: string; tarafId: number; taraf: string; kapsam: string; bas: string; bit: string;
  yillikBedel: number; gecenGun: number; toplamGun: number; gecenPay: number; isEmri: number;
  iscilik: number; parca: number; diger: number; kar: number; karOran: number | null;
  /** Personel saat maliyeti bilinmediği için tarife kullanılan ziyaret sayısı (rozet). */
  tarifeli: number; zarar: boolean;
};

export type ServisFaturasizSatiri = {
  id: number; no: string; kapanis: string; tarafId: number; taraf: string; kapsam: string; uretici: boolean;
  iscilik: number; parca: number; diger: number; toplam: number; gun: number;
};

export type TeknikServisIcmali = {
  bas: string; bit: string; sube: number; teknisyen: number; musteri: number; marka: string; model: string;
  kapsam: number;
  /** 0 ikisi · 1 iç (demirbaş) · 2 dış (müşteri). Verilmezse sunucu ürün moduna göre seçer (HBYS iç). */
  sahiplik: number;
  tekrarGun: number;
  ozet: ServisOzet;
  kapsamlar: ServisKapsamSatiri[];
  kapsamToplam: { cagri: number; isEmri: number; iscilik: number; parca: number; diger: number; toplam: number };
  durumlar: { kod: number; ad: string; adet: number; slaAsan: number }[];
  oncelikler: { kod: number; ad: string; cagri: number; ilkYanitSaat: number | null; cozumSaat: number | null; slaIhlal: number }[];
  teknisyenler: ServisTeknisyenSatiri[];
  teknisyenToplam: {
    ziyaret: number; cozulen: number; ilkZiyaretCozum: number | null; iscilikSaat: number; yolKm: number; slaIhlal: number;
    tekrar: number; ciro: number; imzasiz: number; memnuniyet: number | null; puanSayisi: number; atanmamisCiro: number;
  };
  cihazlar: ServisCihazSatiri[];
  arizalar: { ad: string; kodlu: boolean; isEmri: number; cagri: number; markaModel: string }[];
  arizaKodlu: number; arizaKodsuz: number;
  sla: {
    satirlar: ServisSlaSatiri[];
    ihlaller: {
      anahtar: string; id: number; no: string; taraf: string; cihaz: string; acilis: string; slaBitis: string | null;
      ilkYanit: string | null; gecikmeSaat: number; acik: boolean; sozlesme: string;
    }[];
    /** Sözleşmesi ve kurum varsayılanı olmayan (SLA işlemeyen) çağrı sayısı. */
    slasiz: number;
  };
  parcalar: ServisParcaSatiri[];
  parcaToplam: {
    kalem: number; miktar: number; maliyet: number; tutar: number; faturalanan: number; faturalanmayan: number;
    sozlesmeGaranti: number; iadeBekliyor: number; iadeGeciken: number;
  };
  emanetler: {
    id: number; no: string; cihaz: string; taraf: string; tarafId: number; isEmriId: number; isEmriNo: string;
    veris: string; gun: number; isEmriDurum: string; iadeBekleniyor: boolean;
  }[];
  sozlesmeler: ServisSozlesmeSatiri[];
  sozlesmeToplam: {
    sozlesme: number; yillikBedel: number; gecenPay: number; iscilik: number; parca: number; diger: number; kar: number;
    zarardaki: number; karOran: number | null;
  };
  faturasiz: { sayi: number; tutar: number; liste: ServisFaturasizSatiri[] };
  secim: {
    subeler: Secenek[]; teknisyenler: Secenek[]; musteriler: Secenek[];
    markalar: { marka: string; model: string }[];
  };
  izlemeNo: string;
};

export const servisIcmalUclari = {
  teknikServisIcmali: (q: URLSearchParams) => istek<TeknikServisIcmali>(`/api/servis-icmal?${q}`),
};
