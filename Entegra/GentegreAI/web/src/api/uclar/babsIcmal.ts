import { dosyaIndir, istek } from '../cekirdek';

/**
 * Ba / Bs İcmali (BabsIcmalUclari, 1186) - `/api/babs-icmal`. Kural KDV İcmali ile ORTAK (yalnız kesin
 * fatura; Bs = satış + alış iadesi, Ba = alış + satış iadesi; KDV hariç; sınır `muhasebe.babs_sinir`).
 * Rakamlar sunucuda; ekran toplamaz. Sunucu null alanları yazmaz: `?` alanlar yoksa "yok" demektir.
 */
type Secenek = { id: number; ad: string };

export type BabsForm = 'Ba' | 'Bs';

export type BabsMutabakat = {
  id: number;
  /** 0 yanıt yok · 1 mutabık · 2 fark var. */
  yanit: 0 | 1 | 2;
  gonderimAn?: string; eposta: string; tutar: number; belge: number;
  carininTutari?: number; carininBelge?: number; fark?: number; yanitAn?: string; yanitNot: string;
  /** Gönderimden sonra bizim tutar / belge sayısı değişti. */
  degisti: boolean;
};

export type BabsSatiri = {
  sira: number; form: BabsForm;
  /** Satırın kimliği: "v" + VKN (geçerli VKN) ya da "t" + cari id. */
  anahtar: string;
  vkn: string; vknDurum: 'tamam' | 'eksik' | 'hatali'; unvan: string;
  tarafId: number; tarafSayisi: number; belge: number; tutar: number; iade: number; eposta: string;
  /** Eşik altında: sınıra kalan. */
  kalan?: number; yakin: boolean;
  mutabakat?: BabsMutabakat;
};

export type BabsUyari = {
  tur: 'vkn' | 'cokcari' | 'yurtdisi' | 'taslak' | 'degisti';
  seviye: 'kir' | 'sari' | 'mavi';
  form: '' | BabsForm; tarafId: number; unvan: string; tutar: number; aciklama: string; oneri: string;
};

export type BabsKiyas = {
  kdv: number; ustu: number; alti: number; nihai: number; yurtDisi: number; fis: number; toplam: number; fark: number;
};

export type BabsMukellef = { anahtar: string; vkn: string; unvan: string; subeler: Secenek[] };

export type BabsIcmali = {
  donem: string; donemAd: string; bas: string; bit: string;
  /** Bildirimin son günü (izleyen ayın son günü). */
  sonGun: string; gecikti: boolean;
  vkn: string; sube: number; sinir: number; kapsamli: boolean;
  mukellef: BabsMukellef;
  ozet: {
    ba: { cari: number; belge: number; tutar: number };
    bs: { cari: number; belge: number; tutar: number };
    esikAlti: { cari: number; tutar: number; yakin: number };
    vknEksik: number; gonderilmedi: number; bekleyen: number; mutabik: number; fark: number;
    yurtDisi: number; yurtDisiTutar: number; nihaiTutar: number; taslak: number;
  };
  ba: BabsSatiri[]; bs: BabsSatiri[]; esikAlti: BabsSatiri[]; esikAltiToplam: number; yurtDisi: BabsSatiri[];
  uyarilar: BabsUyari[];
  kiyas: { satis: BabsKiyas; alis: BabsKiyas; iadeBs: number; iadeBa: number };
  secim: { mukellefler: BabsMukellef[]; donemler: { donem: string; ad: string }[] };
  yetkiler: { mutabakat: boolean };
};

export type BabsBelge = { id: number; no: string; tarih: string; tarafId: number; taraf: string; yon: string; matrah: number };

export type BabsGonderYaniti = { yazilan: number; eposta: number; atlanan: string[] };

export const babsIcmalUclari = {
  babsIcmali: (q: URLSearchParams) => istek<BabsIcmali>(`/api/babs-icmal?${q}`),
  /** Satırın (form + anahtar) belgeleri. */
  babsBelgeler: (q: URLSearchParams, form: BabsForm, anahtar: string) => {
    const p = new URLSearchParams(q);
    p.set('form', form); p.set('anahtar', anahtar);
    return istek<{ belgeler: BabsBelge[] }>(`/api/babs-icmal/belgeler?${p}`);
  },
  /** Form Ba + Form Bs dökümü (.xlsx) - blob URL. e-Beyanname XML'i değildir. */
  babsDisaAktar: (q: URLSearchParams) => dosyaIndir(`/api/babs-icmal/disa-aktar?${q}`),
  /** Mutabakat gönder: tutar sunucuda yeniden hesaplanır; e-posta istenirse kuyruğa mektup. */
  babsMutabakatGonder: (g: { donem: string; vkn: string; sube?: number; satirlar: { form: BabsForm; anahtar: string; eposta: string }[];
                             epostaGonder: boolean }) =>
    istek<BabsGonderYaniti>('/api/babs-icmal/mutabakat', { method: 'POST', body: JSON.stringify(g) }),
  /** Carinin yanıtı: 1 mutabık · 2 fark (carinin tutarı zorunlu) · 0 yanıtı geri al. */
  babsMutabakatYanit: (id: number, g: { yanit: 0 | 1 | 2; carininTutari?: number; carininBelge?: number; not?: string }) =>
    istek<{ id: number; yanit: number }>(`/api/babs-icmal/mutabakat/${id}`, { method: 'PUT', body: JSON.stringify(g) }),
};
