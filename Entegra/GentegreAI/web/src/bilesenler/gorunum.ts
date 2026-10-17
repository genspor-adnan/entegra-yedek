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

export type AnaSayfaArka = 'duz'
  | 'mavi' | 'nane' | 'seftali' | 'lavanta' | 'kum' | 'deniz' | 'gunbatimi'
  | 'lacivert' | 'orman' | 'murdum' | 'arduvaz'
  | 'doku' | 'cizgili' | 'izgara' | 'kareli' | 'dalga'
  | 'resim';
/** Grup: ayar ekranında optgroup; KOYU olanlarda selam / başlık yazısı açık renge döner. */
export const ANA_SAYFA_ARKA_SECENEKLERI: { deger: AnaSayfaArka; ad: string; grup: 'Düz' | 'Açık renkler' | 'Koyu renkler' | 'Dokular' | 'Resim' }[] = [
  { deger: 'duz', ad: 'Düz', grup: 'Düz' },
  { deger: 'mavi', ad: 'Yumuşak mavi', grup: 'Açık renkler' },
  { deger: 'nane', ad: 'Nane', grup: 'Açık renkler' },
  { deger: 'seftali', ad: 'Şeftali', grup: 'Açık renkler' },
  { deger: 'lavanta', ad: 'Lavanta', grup: 'Açık renkler' },
  { deger: 'kum', ad: 'Kum', grup: 'Açık renkler' },
  { deger: 'deniz', ad: 'Deniz', grup: 'Açık renkler' },
  { deger: 'gunbatimi', ad: 'Gün batımı', grup: 'Açık renkler' },
  { deger: 'lacivert', ad: 'Lacivert', grup: 'Koyu renkler' },
  { deger: 'orman', ad: 'Orman', grup: 'Koyu renkler' },
  { deger: 'murdum', ad: 'Mürdüm', grup: 'Koyu renkler' },
  { deger: 'arduvaz', ad: 'Arduvaz', grup: 'Koyu renkler' },
  { deger: 'doku', ad: 'Noktalı', grup: 'Dokular' },
  { deger: 'cizgili', ad: 'Çizgili', grup: 'Dokular' },
  { deger: 'izgara', ad: 'Izgara', grup: 'Dokular' },
  { deger: 'kareli', ad: 'Kareli', grup: 'Dokular' },
  { deger: 'dalga', ad: 'Dalga', grup: 'Dokular' },
  { deger: 'resim', ad: 'Kendi resmim', grup: 'Resim' },
];

/**
 * ANA SAYFA RESMİ (kullanıcı 17.10.2026: "resim yükleme de ekle"): hesapta ayrı büyük tercih
 * (`anaSayfaResim`, sunucuda toplu okumaya girmez). Yalnız "Kendi resmim" seçiliyken ve bir kez
 * indirilir; CSS'e `--ana-arka-resim` değişkeniyle verilir.
 */
let resimIndi = false;
function resimDegiskeni(dataUrl: string) {
  document.documentElement.style.setProperty('--ana-arka-resim', dataUrl ? `url("${dataUrl}")` : 'none');
}
function anaResimYukle() {
  if (resimIndi) return;
  resimIndi = true;
  void api.tercihOku('anaSayfaResim').then(resimDegiskeni).catch(() => { resimIndi = false });
}
/** Seçilen dosyayı Full HD'ye küçültüp JPEG'e çevirir, hesaba yazar ve hemen uygular. */
export async function anaResimKaydet(dosya: File): Promise<void> {
  const url = await new Promise<string>((tamam, hata) => {
    const r = new FileReader(); r.onload = () => tamam(String(r.result)); r.onerror = () => hata(r.error); r.readAsDataURL(dosya);
  });
  const img = await new Promise<HTMLImageElement>((tamam, hata) => {
    const i = new Image(); i.onload = () => tamam(i); i.onerror = () => hata(new Error('Resim okunamadı.')); i.src = url;
  });
  const olcek = Math.min(1, 1920 / img.width, 1080 / img.height);
  const tuval = document.createElement('canvas');
  tuval.width = Math.round(img.width * olcek); tuval.height = Math.round(img.height * olcek);
  tuval.getContext('2d')!.drawImage(img, 0, 0, tuval.width, tuval.height);
  // Sunucu sınırı ~700 KB: sığana kadar kaliteyi düşür.
  let kalite = 0.8, sonuc = tuval.toDataURL('image/jpeg', kalite);
  while (sonuc.length > 690_000 && kalite > 0.35) { kalite -= 0.1; sonuc = tuval.toDataURL('image/jpeg', kalite) }
  if (sonuc.length > 690_000) throw new Error('Resim çok büyük - daha küçük bir resim seçin.');
  await api.tercihYaz('anaSayfaResim', sonuc);
  resimIndi = true; resimDegiskeni(sonuc);
}
export async function anaResimKaldir(): Promise<void> {
  await api.tercihYaz('anaSayfaResim', '');
  resimIndi = true; resimDegiskeni('');
}

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
  if (t.anaSayfaArka === 'resim') anaResimYukle();
  document.documentElement.dataset.anaArkaKoyu =
    ANA_SAYFA_ARKA_SECENEKLERI.find(s => s.deger === t.anaSayfaArka)?.grup === 'Koyu renkler' ? '1' : '0';
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
