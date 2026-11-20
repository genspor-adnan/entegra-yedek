import { TABAN, istek, gonder } from '../cekirdek';

/**
 * RADYOLOJİ RAPOR GÖNDERİMİ (1389-1392, RaporGonderimUclari): şube ayarı + zaman kuralları, istemin bağlantıları,
 * elle gönderim ve GİRİŞSİZ rapor sayfası (`/r/{kod}`).
 */
export type RaporGonderimKurali = {
  id?: number;
  /** 0 tümü · 1 kategori · 2 kod (tetkik). */
  kapsam: number;
  kategoriId: number | null; hizmetId: number | null;
  /** 0 hemen · 1 N saat sonra · 2 ertesi gün saat. */
  zamanTur: number;
  saat: number;
  /** Ertesi gün kuralında günün dakikası (900 = 15:00). */
  gunDakika: number;
  aktif: boolean;
  kategoriAd?: string; hizmetKod?: string; hizmetAd?: string;
};

export type RaporGonderimAyari = {
  otomatik: boolean;
  /** Radyoloji kritik bulgu süresi (dk; 0 = elle). */
  kritikDakika: number;
  /** Laboratuvar panik değer süresi (dk; 0 = elle) - 1394. */
  labPanikDakika: number;
  borcKontrol: boolean; hastaSms: boolean; hastaEposta: boolean;
  gecerlilikGun: number; webKok: string;
  /** Basılı çıktıda bağlantı karekodu - radyoloji ve laboratuvar AYRI AYRI (1396). */
  karekodRadyoloji: boolean; karekodLab: boolean;
};

export type RaporGonderimSatiri = {
  id: number; raporId: number;
  /** 1 hasta · 2 gönderen dış doktor. */
  aliciTur: number;
  kod: string; kanal: number;
  /** 0 hazır · 1 planlandı · 2 borç bekliyor · 3 gönderildi · 4 gönderilemedi · 9 iptal. */
  durum: number;
  planlanan: string | null; gonderim: string | null; ilkAcilma: string | null; acilmaSayisi: number;
  kural: string; hata: string; sonGecerli: string; webKok: string; borcaRagmen: boolean;
  alici: string; sms: string; eposta: string;
};

export type RaporGonderimIstemYaniti = {
  satirlar: RaporGonderimSatiri[]; borc: number; gonderebilir: boolean; borcaRagmenGonderebilir: boolean;
};

export type AcikRaporImza = {
  imzali: boolean; gecerli: boolean; hata: string; hekim: string; tescil: string; zaman: string | null;
  sahip: string; veren: string; gecerlilikBas: string | null; gecerlilikBit: string | null; seriNo: string; ozet: string;
};

/** Geçmiş sonuç hücresi (önceki başvuru). */
export type AcikLabOnceki = { deger: string; bayrak: string; panik: boolean };

/** LAB bağlantı sayfası verisi (1394): Bakanlık Tetkik Sonuç Raporu alanları + bölümün onaylı sonuçları. */
export type AcikLabRaporu = {
  bolum: number; bolumAd: string;
  baslik: {
    hasta: string; tc: string; dogumTarihi: string | null; cinsiyet: number; dosyaNo: string; protokolNo: string;
    isteyen: string; kurum: string; sube: string; gonderilecekYer: string; raporNo: string; ornekNo: string;
    istemZamani: string | null; numuneAlma: string | null; numuneKabul: string | null; onayZamani: string | null;
    basimZamani: string | null;
  };
  /** Geçmiş sonuç kolonlarının günleri (en yeni önce; en çok iki). */
  gecmisGunler: string[];
  satirlar: {
    kod: string; ad: string; sonuc: string; birim: string;
    /** N / L / H / LL / HH. */
    bayrak: string; panik: boolean; referans: string; kararNotu: string; yorum: string; ornekNo: string; yontem: string;
    onceki1: AcikLabOnceki | null; onceki2: AcikLabOnceki | null;
  }[];
  /** Hastaya gösterilmeyen ("bağlantıda gizle") test sayısı. */
  gizlenen: number;
  uzman: { ad: string; brans: string; tescilNo: string } | null;
};

export type AcikRapor = {
  /** ok rapor var · iletisim (borç) · sure · guncel (geri çekildi) · gecersiz (imza bozuk) · yok. */
  durum: 'ok' | 'iletisim' | 'sure' | 'guncel' | 'gecersiz' | 'yok';
  aliciTur?: number; sonGecerli?: string;
  /** 'lab' ise `lab` dolu (laboratuvar sonucu); yoksa radyoloji raporu. */
  tur?: 'lab';
  lab?: AcikLabRaporu;
  kurum?: Record<string, unknown> | null;
  ozet?: { tetkik?: string; cekimTarihi?: string | null } | null;
  imza?: AcikRaporImza;
  rapor?: Record<string, unknown>; bolumler?: Record<string, unknown>[]; alanlar?: Record<string, unknown>[];
  ekler?: Record<string, unknown>[]; tipografi?: Record<string, unknown>;
};

export const raporGonderimUclari = {
  raporGonderimAyari: () =>
    istek<{ ayar: RaporGonderimAyari; kurallar: RaporGonderimKurali[]; degistirebilir: boolean }>('/api/radyoloji/rapor-gonderim/ayar'),
  raporGonderimAyariYaz: (govde: RaporGonderimAyari & { kurallar: RaporGonderimKurali[] }) =>
    gonder<{ tamam: boolean }>('/api/radyoloji/rapor-gonderim/ayar', govde, 'PUT'),
  raporGonderimleri: (istemId: number) => istek<RaporGonderimIstemYaniti>(`/api/radyoloji/rapor-gonderim/istem/${istemId}`),
  raporGonder: (id: number, borcaRagmen = false) =>
    gonder<{ durum: number }>(`/api/radyoloji/rapor-gonderim/${id}/gonder`, { borcaRagmen }),
  /** Lab bölümünün elden teslimi (1396) - tek teslim listesinin lab satırı. */
  labSonucTeslim: (govde: { belgeId: number; bolum: number; alanAd: string; alanYakinlik: string; aciklama: string }) =>
    gonder<{ tamam: boolean }>('/api/radyoloji/rapor-gonderim/lab-teslim', govde),
  raporGonderimIptal: (id: number) => gonder<{ tamam: boolean }>(`/api/radyoloji/rapor-gonderim/${id}/iptal`, {}),
};

/** Web'in kök adresi (alt yol dahil): bağlantılar `${kok}/r/{kod}`. */
export function webKoku(): string {
  return (window.location.origin + import.meta.env.BASE_URL).replace(/\/+$/, '');
}
export const raporBaglantisi = (kod: string, kok?: string) => `${(kok || webKoku()).replace(/\/+$/, '')}/r/${kod}`;

/** GİRİŞSİZ: rapor sayfası verisi. Kod yoksa durum 'yok'. */
export async function acikRaporOku(kod: string): Promise<AcikRapor> {
  const y = await fetch(`${TABAN}/api/acik/rapor/${encodeURIComponent(kod)}`, { headers: { accept: 'application/json' } });
  if (y.status === 404) return { durum: 'yok' };
  if (!y.ok) throw new Error(`Sunucu hatası (${y.status})`);
  return await y.json() as AcikRapor;
}
export const acikRaporImzaliAdresi = (kod: string) => `${TABAN}/api/acik/rapor/${encodeURIComponent(kod)}/imzali`;
