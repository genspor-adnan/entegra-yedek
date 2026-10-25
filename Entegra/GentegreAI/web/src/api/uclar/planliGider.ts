import { gonder, istek } from '../cekirdek';

/**
 * PLANLI GİDER UÇLARI (1177) - `/api/planli-gider`. Mockup Ekranlar/ERP/planli_gider.html (liste, takvim)
 * ve planli_gider_karti.html (kart). Tanım tekrarlayan gideri tutar; dönemler takvimden SUNUCUDA türetilir.
 * Tutar, dönem tarihi, eşleşme, önizleme ve özetler sunucunun hesabıdır - ekran yalnız gösterir.
 *
 * Kodlar: tutarTur 1 sabit · 2 son N dönem ort. · 3 geçen yıl aynı ay · 4 hesaplanan · 5 elle (her dönem);
 * periyot 1 haftalık · 2 aylık · 3 3 aylık · 4 6 aylık · 5 yıllık · 6 tek sefer; tatilKural 1 önceki iş günü ·
 * 2 sonraki iş günü · 0 kaydırma; odemeYontem 1 havale/EFT · 2 otomatik talimat · 3 kredi kartı · 4 nakit ·
 * 5 vergi tahsilatı; artış tur 1 oran (%) · 2 yeni tutar (KDV hariç).
 */
type Secenek = { id: number; ad: string };

export type PlanliGiderDonemDurumu =
  'odendi' | 'gec' | 'erken' | 'planli' | 'bugun' | 'gecikti' | 'atlandi' | 'faturalandi' | 'beklemede';

export type PlanliGiderListeSuzgeci = {
  durum?: 'aktif' | 'pasif' | 'tumu';
  cip?: 'buay' | 'gecikmis' | 'degisken' | 'hesaplanan' | 'dovizli' | 'bitiyor' | '';
  kategori?: number; hesap?: number; ara?: string;
};

export type PlanliGiderSatiri = {
  id: number; ad: string; kategori: string; kategoriId: number | null; taraf: string; tarafId: number | null;
  masraf: string; periyot: number; periyotMetni: string;
  /** Dönemin NAKİT ÇIKIŞI (KDV dahil − stopaj), tanım dövizinde. */
  tutar: number; tutarTl: number; doviz: string; kdvHaric: number; kdvOran: number;
  tutarTur: number; tutarTurAdi: string; tahmini: boolean; artisRozet: string;
  hesap: string; hesapId: number | null; yontem: string;
  sonraki: string | null;
  buDonem: { durum: PlanliGiderDonemDurumu | string; tarih: string | null; gun: number | null; not: string } | null;
  durum: number; bitis: string | null; kalanDonem: number | null;
};

export type PlanliGiderListesi = {
  ozet: {
    aylik: number; sonraki30: number; sonraki30Donem: number; enBuyuk: { ad: string; tutar: number } | null;
    gecikmis: number; gecikmisDonem: number; tahminiPay: number;
    buAyPlan: number; buAyOdenen: number; buAyOdenenTanim: number; buAyTanim: number; planGercekFark6Ay: number | null;
  };
  satirlar: PlanliGiderSatiri[];
  toplam: { aylik: number; aktif: number; pasif: number };
  secim: { kategoriler: Secenek[]; hesaplar: (Secenek & { tur: string })[] };
  yetkiler: { ekle: boolean; degistir: boolean; sil: boolean; odeme: boolean };
  izlemeNo?: string;
};

export type PlanliGiderTakvimi = {
  aylar: { ay: string; toplam: number; sabit: number; tahmini: number; hesaplanan: number; kirilim: Record<string, number> }[];
  kolonlar: { anahtar: string; ad: string }[];
  izlemeNo?: string;
};

export type PlanliGiderKategorisi = {
  id: number; kod: string; ad: string; masrafId: number | null; masraf: string;
  tutarTur: number; hesapKaynak: string; tatilKural: number; hatirlatmaGun: number;
};

export type PlanliGiderKartAlanlari = {
  id: number; ad: string; kategoriId: number | null; durum: number;
  tarafId: number | null; taraf: string; masrafId: number | null; masraf: string;
  masrafMerkeziId: number | null; sorumluId: number | null; referansNo: string; aciklama: string;
  tutarTur: number; ortalamaDonem: number; hesapKaynak: string; tutar: number; doviz: string;
  kdvOran: number; stopajOran: number; periyot: number; odemeGunu: number; tatilKural: number;
  baslangic: string; bitis: string | null; donemSayisi: number | null; hatirlatmaGun: number;
  odemeHesapId: number | null; odemeYontem: number; karsiIban: string; odemeAciklama: string;
  eslesGun: number; eslesYuzde: number; eslesOtomatik: number;
  subeId: number; ekleyen: number; ekleyenAd: string; eklemeTarihi: string | null; degistirmeTarihi: string | null;
  surum: string;
  /** Sözleşmede yok - sunucu verirse adlar ondan, vermezse ekran listeden çözer. */
  masrafMerkezi?: string; sorumlu?: string; odemeHesap?: string; sube?: string;
};

export type PlanliGiderArtis = {
  id: number; gecerlilik: string; tur: number; deger: number; aciklama: string;
  yeniKdvHaric: number | null; uygulandi: boolean;
};

export type PlanliGiderDonemi = {
  vade: string; planTarihi: string; kaydirildi: boolean; kaydirmaNedeni: string;
  plan: number; gercek: number | null; fark: number | null; odemeTarihi: string | null;
  eslesen: { tur: string; id: number; no: string; metin: string } | null;
  otomatik: boolean; durum: PlanliGiderDonemDurumu | string; gun: number | null;
  elleTutar: number | null; aciklama: string; dondurulmus: boolean;
};

export type PlanliGiderKarti = {
  kart: PlanliGiderKartAlanlari;
  artislar: PlanliGiderArtis[];
  ozet: {
    donemTutari: number; kdvHaric: number; kdv: number; stopaj: number;
    sonraki: { tarih: string; gun: number; gunAdi: string } | null;
    buYilOdenen: number; buYilPlan: number; buYilDonem: number; buYilOdenenDonem: number;
    kalanTaahhut: number | null; kalanDonem: number | null; toplamDonem: number | null;
    zamanindaOran: number | null; ortGecikme: number | null; planGercekFark12: number | null;
  };
  donemler: PlanliGiderDonemi[];
  onizleme: {
    tutarlar: { vade: string; tutar: number; artis: boolean }[];
    tarihler: { tarih: string; kaydirildi: boolean; neden: string }[];
  };
  kategoriler: PlanliGiderKategorisi[];
  uyarilar: { seviye: 'sari' | 'kir' | 'mavi'; metin: string }[];
  zaman: { tarih: string; metin: string; tur: 'ok' | 'kir' | '' }[];
  yetkiler: { degistir: boolean; sil: boolean; odeme: boolean };
  izlemeNo?: string;
};

/**
 * SUNUCU NULL ALANI GÖNDERMEZ (JSON ayarı: null'lar atlanır). Yeni kayıtta (`GET /0`) `ozet` / `onizleme`
 * gelmez; sekmeler bunları var sayıyordu ve "Tutar" / "Takvim" sekmesi açılınca sayfa çöküyordu. Eksikler
 * burada BOŞ değerlerle tamamlanır - rakam üretilmez (null = "—").
 */
export function kartiTamamla(y: PlanliGiderKarti): PlanliGiderKarti {
  const o: Partial<PlanliGiderKarti['ozet']> = y.ozet ?? {};
  return {
    ...y,
    artislar: y.artislar ?? [],
    ozet: {
      donemTutari: o.donemTutari ?? 0, kdvHaric: o.kdvHaric ?? 0, kdv: o.kdv ?? 0, stopaj: o.stopaj ?? 0,
      sonraki: o.sonraki ?? null,
      buYilOdenen: o.buYilOdenen ?? 0, buYilPlan: o.buYilPlan ?? 0, buYilDonem: o.buYilDonem ?? 0, buYilOdenenDonem: o.buYilOdenenDonem ?? 0,
      kalanTaahhut: o.kalanTaahhut ?? null, kalanDonem: o.kalanDonem ?? null, toplamDonem: o.toplamDonem ?? null,
      zamanindaOran: o.zamanindaOran ?? null, ortGecikme: o.ortGecikme ?? null, planGercekFark12: o.planGercekFark12 ?? null,
    },
    donemler: y.donemler ?? [],
    onizleme: { tutarlar: y.onizleme?.tutarlar ?? [], tarihler: y.onizleme?.tarihler ?? [] },
    kategoriler: y.kategoriler ?? [],
    uyarilar: y.uyarilar ?? [],
    zaman: y.zaman ?? [],
    yetkiler: y.yetkiler ?? { degistir: false, sil: false, odeme: false },
  };
}

/** Kaydet gövdesi: kart alanları (yeni kayıtta id 0, güncellemede surum dolu) + artış kuralları (tam liste). */
export type PlanliGiderKaydi = {
  kart: Partial<PlanliGiderKartAlanlari>;
  artislar: Omit<PlanliGiderArtis, 'yeniKdvHaric' | 'uygulandi'>[];
};

export type PlanliGiderOnerisi = {
  tur: string; id: number; no: string; tarih: string; taraf: string; masraf: string; tutar: number;
  neden: string; secilebilir: boolean; engel: string;
};

const sorgu = (s: PlanliGiderListeSuzgeci) => {
  const q = new URLSearchParams();
  if (s.durum) q.set('durum', s.durum);
  if (s.cip) q.set('cip', s.cip);
  if (s.kategori) q.set('kategori', String(s.kategori));
  if (s.hesap) q.set('hesap', String(s.hesap));
  if (s.ara?.trim()) q.set('ara', s.ara.trim());
  const m = q.toString();
  return m ? `?${m}` : '';
};
const kok = '/api/planli-gider';
const donem = (id: number, vade: string) => `${kok}/${id}/donem/${encodeURIComponent(vade)}`;

export const planliGiderUclari = {
  planliGiderListe: (s: PlanliGiderListeSuzgeci = {}) => istek<PlanliGiderListesi>(`${kok}${sorgu(s)}`),
  planliGiderTakvim: (ay = 12, gorunum: 'kategori' | 'hesap' = 'kategori') =>
    istek<PlanliGiderTakvimi>(`${kok}/takvim?ay=${ay}&gorunum=${gorunum}`),
  planliGiderKategoriler: () => istek<PlanliGiderKategorisi[]>(`${kok}/kategoriler`),
  /** id 0 = boş yeni kart (varsayılanlar + kategoriler). */
  planliGiderKart: (id: number) => istek<PlanliGiderKarti>(`${kok}/${id}`).then(kartiTamamla),
  planliGiderEkle: (k: PlanliGiderKaydi) => gonder<{ id: number }>(kok, k),
  planliGiderGuncelle: (id: number, k: PlanliGiderKaydi) => gonder<{ id: number; surum: string }>(`${kok}/${id}`, k, 'PUT'),
  planliGiderSil: (id: number) => istek<unknown>(`${kok}/${id}`, { method: 'DELETE' }),
  planliGiderKopyala: (id: number) => gonder<{ id: number }>(`${kok}/${id}/kopyala`, {}),
  planliGiderAtla: (id: number, vade: string, aciklama: string) => gonder<unknown>(`${donem(id, vade)}/atla`, { aciklama }),
  /** null tutar = elle tutarı kaldır. */
  planliGiderDonemTutar: (id: number, vade: string, tutar: number | null, aciklama: string) =>
    gonder<unknown>(`${donem(id, vade)}/tutar`, { tutar, aciklama }),
  planliGiderGeriAl: (id: number, vade: string) => gonder<unknown>(`${donem(id, vade)}/geri-al`, {}),
  planliGiderOneriler: (id: number, vade: string) => istek<PlanliGiderOnerisi[]>(`${donem(id, vade)}/oneriler`),
  planliGiderEsles: (id: number, vade: string, tur: string, kayitId: number) =>
    gonder<unknown>(`${donem(id, vade)}/esles`, { tur, kayitId }),
  planliGiderEslesmeKaldir: (id: number, vade: string) => gonder<unknown>(`${donem(id, vade)}/eslesme-kaldir`, {}),
  planliGiderOdeme: (id: number, vade: string) =>
    gonder<{ kasaIslemId: number; mesaj: string }>(`${kok}/${id}/odeme`, { vade }),
  /** Tek aday otomatik eşleşme + dondurma (bütün tanımlar). */
  planliGiderEslestir: () => gonder<{ eslesen: number; donduruldu: number }>(`${kok}/eslestir`, {}),
};
