import { api } from '../api/istemci';

/**
 * GÖRÜNÜM ve BİLDİRİM TERCİHLERİ (669 · mockup: Ekranlar/Ayarlar/kullanici_ayarlari.html)
 *
 * İkisi de sunucuda `kullanici_tercih` tablosunda durur (397 altyapısı):
 * kişi hangi cihazdan girerse girsin aynı düzeni bulur. TEMA bilerek burada
 * DEĞİL - o cihaza aittir (poliklinikte gündüz, evde gece) ve `tema.ts`
 * içinde localStorage'da kalır.
 *
 * Sunucu cevabı beklenirken ekran boş kalmasın diye değer localStorage'da
 * AYNALANIR: açılışta anında uygulanır, API cevabı gelince üzerine yazılır.
 * Ayna yoksa varsayılan kullanılır - ayarın gecikmesi ekranı bozmamalı.
 */

export type Yogunluk = 'sikisik' | 'normal' | 'ferah';

export interface GorunumTercihi {
  yogunluk: Yogunluk;
  /** Listelerin açılış sayfa boyu (GenGrid'in başlangıç değeri). */
  listeSatir: number;
}

export const LISTE_SATIR_SECENEKLERI = [25, 50, 100, 200];

const VARSAYILAN: GorunumTercihi = { yogunluk: 'normal', listeSatir: 50 };
const AYNA = 'gentegre.gorunum';

let mevcut: GorunumTercihi = aynadanOku();

function aynadanOku(): GorunumTercihi {
  try {
    const ham = localStorage.getItem(AYNA);
    return ham ? duzelt(JSON.parse(ham)) : { ...VARSAYILAN };
  } catch { return { ...VARSAYILAN } }
}

/** Sunucudan/aynadan gelen değer BOZUK olabilir - alan alan doğrulanır. */
function duzelt(h: unknown): GorunumTercihi {
  const o = (h ?? {}) as Partial<GorunumTercihi>;
  const y: Yogunluk = o.yogunluk === 'sikisik' || o.yogunluk === 'ferah'
    ? o.yogunluk : 'normal';
  const n = Number(o.listeSatir);
  return {
    yogunluk: y,
    listeSatir: LISTE_SATIR_SECENEKLERI.includes(n) ? n : VARSAYILAN.listeSatir,
  };
}

export function gorunumOku(): GorunumTercihi { return mevcut }

/** Yalnız ekrana uygular (kaydetmez) - önizleme ve açılış için. */
export function gorunumUygula(t: GorunumTercihi) {
  mevcut = t;
  document.documentElement.dataset.yogunluk = t.yogunluk;
  try { localStorage.setItem(AYNA, JSON.stringify(t)) } catch { /* yoksay */ }
}

/** Oturum açılışında: aynayı uygula, sonra sunucudakini getir. */
export async function gorunumYukle(tercihler?: Record<string, string>) {
  gorunumUygula(mevcut);
  try {
    const t = tercihler ?? await api.tercihler();
    if (t.gorunum) gorunumUygula(duzelt(JSON.parse(t.gorunum)));
  } catch { /* tercih okunamadi: ayna/varsayilan yeterli */ }
}

// Modul yuklenir yuklenmez AYNA uygulanir: sunucu cevabini beklemek, her
//   acilista bir anlik "normal yogunluk" titremesi yaratirdi.
if (typeof document !== 'undefined') gorunumUygula(mevcut);

export async function gorunumKaydet(t: GorunumTercihi) {
  gorunumUygula(t);
  await api.tercihYaz('gorunum', JSON.stringify(t));
}
