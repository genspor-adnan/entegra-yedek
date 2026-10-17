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

export type YaziBoyu = 90 | 100 | 110;
export type GridCizgi = 'ince' | 'belirgin' | 'yok';

export interface GorunumTercihi {
  yogunluk: Yogunluk;
  /** Listelerin açılış sayfa boyu (GenGrid'in başlangıç değeri). */
  listeSatir: number;
  /** Mockup "Yazı boyu": tüm arayüz yüzdeyle ölçeklenir (CSS zoom). */
  yaziBoyu: YaziBoyu;
  /** Mockup "Grid çizgileri": tablo hücre çizgisi kalınlığı. */
  gridCizgi: GridCizgi;
  /** MUAYENE KARTI DÜZENİ (mockup muayene_duzen_tercihi): aynı alanlar, sekmeli ya da
      tek sayfa (sekmesiz). Varsayılan sekmeli - mevcut düzen değişmez. */
  muayeneDuzeni: MuayeneDuzeni;
  /** ANA EKRAN v3 (mockup ana_ekran_sekmeli_v3): açılan ekranlar üstte sekme olarak
      kalır, dönünce kaldığı yerde. Kapatılırsa eski tek ekran davranışı. */
  ekranSekmeleri: boolean;
  /** Sol menü her zaman açık (true) ya da ☰ / Ctrl+B ile geçici açılıp seçimden
      sonra kapanır (false, v3). Varsayılan true - bugünkü davranış. */
  menuSabit: boolean;
  /** ANA SAYFA ARKA PLANI (kullanıcı 17.10.2026: "home için background tema olsun"). */
  anaSayfaArka: AnaSayfaArka;
}

export type AnaSayfaArka = 'duz' | 'mavi' | 'doku' | 'lacivert';
export const ANA_SAYFA_ARKA_SECENEKLERI: { deger: AnaSayfaArka; ad: string }[] = [
  { deger: 'duz', ad: 'Düz' }, { deger: 'mavi', ad: 'Yumuşak mavi' },
  { deger: 'doku', ad: 'Açık doku' }, { deger: 'lacivert', ad: 'Lacivert' },
];

export type MuayeneDuzeni = 'sekmeli' | 'sekmesiz';

export const LISTE_SATIR_SECENEKLERI = [25, 50, 100, 200];
export const YAZI_BOYU_SECENEKLERI: { deger: YaziBoyu; ad: string }[] = [
  { deger: 90, ad: 'Küçük (%90)' }, { deger: 100, ad: 'Normal (%100)' }, { deger: 110, ad: 'Büyük (%110)' },
];
export const GRID_CIZGI_SECENEKLERI: { deger: GridCizgi; ad: string }[] = [
  { deger: 'ince', ad: 'İnce' }, { deger: 'belirgin', ad: 'Belirgin' }, { deger: 'yok', ad: 'Yok' },
];

const VARSAYILAN: GorunumTercihi = { yogunluk: 'normal', listeSatir: 50, yaziBoyu: 100, gridCizgi: 'ince',
                                     muayeneDuzeni: 'sekmeli', ekranSekmeleri: true, menuSabit: true,
                                     anaSayfaArka: 'duz' };
const AYNA = 'gentegre.gorunum';
/** Görünüm tercihi değişti (uygulandı) olayı. */
export const GORUNUM_OLAYI = 'gentegre-gorunum';

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
  const yb = Number(o.yaziBoyu);
  return {
    yogunluk: y,
    listeSatir: LISTE_SATIR_SECENEKLERI.includes(n) ? n : VARSAYILAN.listeSatir,
    yaziBoyu: yb === 90 || yb === 110 ? yb : 100,
    gridCizgi: o.gridCizgi === 'belirgin' || o.gridCizgi === 'yok' ? o.gridCizgi : 'ince',
    muayeneDuzeni: o.muayeneDuzeni === 'sekmesiz' ? 'sekmesiz' : 'sekmeli',
    ekranSekmeleri: o.ekranSekmeleri !== false,
    menuSabit: o.menuSabit !== false,
    anaSayfaArka: ANA_SAYFA_ARKA_SECENEKLERI.some(s => s.deger === o.anaSayfaArka) ? o.anaSayfaArka! : 'duz',
  };
}

export function gorunumOku(): GorunumTercihi { return mevcut }

/** Yalnız ekrana uygular (kaydetmez) - önizleme ve açılış için. */
export function gorunumUygula(t: GorunumTercihi) {
  mevcut = t;
  document.documentElement.dataset.yogunluk = t.yogunluk;
  document.documentElement.dataset.grid = t.gridCizgi;
  document.documentElement.dataset.anaArka = t.anaSayfaArka;
  // ZOOM: tema px ile yazilmis, kok font-size'i buyutmek hicbir seyi
  //   olceklemezdi. `zoom` Chromium/Edge/Firefox 126+ 'da calisir; eski
  //   Firefox'ta yok sayilir - ayar bozmaz, sadece etkisiz kalir.
  (document.documentElement.style as CSSStyleDeclaration & { zoom?: string }).zoom =
    t.yaziBoyu === 100 ? '' : `${t.yaziBoyu}%`;
  try { localStorage.setItem(AYNA, JSON.stringify(t)) } catch { /* yoksay */ }
  // Kabuk (ekran sekmeleri, sol menü) tercih değişince anında tepki verir.
  if (typeof window !== 'undefined') window.dispatchEvent(new Event(GORUNUM_OLAYI));
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
