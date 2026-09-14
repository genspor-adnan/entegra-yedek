import type { IskontoTalebi } from '../../api/sozlesme';

/**
 * İSKONTO ONAY EKRANININ ORTAK KURALLARI VE ÖZET HESAPLARI.
 *
 * Ekran dört sekmeye bölündü (kuyruk / detay / limit / analiz); süre biçimi,
 * "verilen indirim" ve özet sayaçları üç sekmede birden kullanılıyor. Kopya
 * çıkarmak yerine tek yerde: sayaçtaki rakamla tablodaki rakam ayrışırsa
 * kullanıcı hangisine inanacağını bilemez.
 *
 * Hepsi SAF: ekran çizmez, veri okumaz - doğrudan test edilir.
 */

/** Bekleme süresi: 42 -> "42 dk", 195 -> "3 sa 15 dk". */
export function sure(dakika: number): string {
  const d = Math.max(0, Math.round(dakika));
  if (d < 1) return '< 1 dk';
  if (d < 60) return `${d} dk`;
  const sa = Math.floor(d / 60);
  return d % 60 === 0 ? `${sa} sa` : `${sa} sa ${d % 60} dk`;
}

/** İki an arası dakika; `son` yoksa ŞİMDİye kadar (bekleyen talep). */
export const dakikaFarki = (bas: string, son?: string | null) =>
  ((son ? new Date(son).getTime() : Date.now()) - new Date(bas).getTime()) / 60000;

/**
 * İSTENEN indirim tutarı - KALEM BAZLI (673). Kalem gelmediyse (eski kayıt)
 * başlık oranına düşer; `carpan` kısmi onayda oranların orantılı düşüşüdür.
 */
export const indirim = (t: IskontoTalebi, carpan = 1) =>
  t.kalemler.length > 0
    ? t.kalemler.reduce((s, k) => s + k.tutar * k.oran / 100, 0) * carpan
    : t.tutar * t.oran / 100 * carpan;

/** Kararın GERÇEKLEŞEN indirimi: onayda oranlar orantılı düşer (673). */
export const verilenIndirim = (t: IskontoTalebi) =>
  t.durum === 1 ? indirim(t, t.oran > 0 ? t.onaylananOran / t.oran : 0) : 0;

/** "Personel yakını — kızı" -> "Personel yakını": analiz başlığı kategoridir. */
export const gerekceBasi = (g: string) =>
  (g.split('—')[0] || '(belirtilmemiş)').trim();

/** ACİL: 15 dk üstü bekleyen talep - hasta veznede duruyor. */
export const ACIL_DAKIKA = 15;

export const DURUM_ROZET: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Bekliyor',     sinif: 'uyari' },
  1: { ad: 'Onay',         sinif: 'ok' },
  2: { ad: 'Red',          sinif: 'hata' },
  3: { ad: 'Geri çekildi', sinif: 'gri' },
};

/** Yetkiden BAĞIMSIZ kurallar (mockup: Kural İstisnaları) - ekranda okunur. */
export const ISTISNALAR: { kural: string; etki: string; sinif: string; neden: string }[] = [
  { kural: 'SGK katkı payı', etki: 'İndirilemez', sinif: 'hata',
    neden: 'Yasal olarak hastadan tahsili zorunlu; birim fiyat zaten kapalıdır.' },
  { kural: 'Kurum anlaşmalı fiyat', etki: 'İndirilemez', sinif: 'hata',
    neden: 'Fiyat sözleşmeyle belirlenmiş; üstüne indirim sözleşme ihlalidir.' },
  { kural: 'Onaylanmış satır', etki: 'Kilitli', sinif: 'hata',
    neden: 'Onaydan sonra satır değişmez ve silinemez (iskonto_kilit) — değişseydi '
         + 'onaylanan rakam ile tahsil edilen rakam ayrışırdı.' },
  { kural: 'Kısmi onay', etki: 'Oranlar orantılı düşer', sinif: 'mavi',
    neden: '%20 istenip %10 verilirse her kalem kendi oranının yarısını alır; '
         + 'görevlinin kurduğu kalem dengesi korunur.' },
  { kural: 'İskonto sonrası iade', etki: 'Oranla iade', sinif: 'mavi',
    neden: 'İade indirimli tutar üzerinden yapılır; liste fiyatından iade '
         + 'kurumu zarara sokardı.' },
];

/** Kuyruk sırası: EN UZUN BEKLEYEN ÜSTTE - hastayı bekleten sıra beklemez. */
export const kuyrugaDiz = (bekleyen: IskontoTalebi[]) =>
  [...bekleyen].sort((a, b) =>
    new Date(a.istekTs).getTime() - new Date(b.istekTs).getTime());

export interface Ozet {
  onayli: number; red: number; kismi: number;
  /** Verilen indirim toplamı (karar gerçekleşen oranla). */
  verilen: number;
  /** Onaylanan taleplerin hizmet toplamı - "hizmetin %'i" payda. */
  hizmet: number;
  /** Ortalama karar süresi (dk) ve kuyruktaki en eski bekleme (dk). */
  ort: number; enEski: number;
}

/**
 * SAYAÇLAR LİSTEDEN HESAPLANIR, sunucudan gelmez: ayrı bir özet ucu aynı
 * satırları ikinci kez okuyup farklı sonuç verebilirdi.
 */
export function ozetCikar(gecmis: IskontoTalebi[], kuyruk: IskontoTalebi[]): Ozet {
  const onayli = gecmis.filter(t => t.durum === 1);
  const sureler = gecmis.filter(t => t.onayTs).map(t => dakikaFarki(t.istekTs, t.onayTs));
  return {
    onayli: onayli.length,
    red: gecmis.filter(t => t.durum === 2).length,
    kismi: onayli.filter(t => t.onaylananOran > 0 && t.onaylananOran < t.oran).length,
    verilen: onayli.reduce((s, t) => s + verilenIndirim(t), 0),
    hizmet: onayli.reduce((s, t) => s + t.tutar, 0),
    ort: sureler.length > 0 ? sureler.reduce((s, x) => s + x, 0) / sureler.length : 0,
    enEski: kuyruk.length > 0 ? dakikaFarki(kuyruk[0].istekTs) : 0,
  };
}

export interface GerekceSatiri {
  ad: string; adet: number; red: number; tutar: number; oran: number; ortOran: number;
}

/** Gerekçeye göre: hangi sebep büyüyor - indirim değil SEBEP izlenir. */
export function gerekceAnalizi(gecmis: IskontoTalebi[]): GerekceSatiri[] {
  const kova = new Map<string, { adet: number; red: number; tutar: number; oran: number }>();
  for (const t of gecmis) {
    const a = gerekceBasi(t.gerekce);
    const k = kova.get(a) ?? { adet: 0, red: 0, tutar: 0, oran: 0 };
    k.adet++;
    if (t.durum === 2) k.red++;
    k.tutar += verilenIndirim(t);
    k.oran += t.durum === 1 ? t.onaylananOran : t.oran;
    kova.set(a, k);
  }
  return [...kova.entries()]
    .map(([ad, k]) => ({ ad, ...k, ortOran: k.adet > 0 ? k.oran / k.adet : 0 }))
    .sort((a, b) => b.tutar - a.tutar);
}

export interface IsteyenSatiri {
  ad: string; talep: number; onay: number; kismi: number; red: number; tutar: number;
}

/** İsteyene göre: yüksek red oranı limitin gerçeğe uymadığını gösterir. */
export function isteyenAnalizi(gecmis: IskontoTalebi[],
                               bekleyen: IskontoTalebi[]): IsteyenSatiri[] {
  const kova = new Map<string, Omit<IsteyenSatiri, 'ad'>>();
  for (const t of [...gecmis, ...bekleyen]) {
    const ad = t.isteyen || '—';
    const k = kova.get(ad) ?? { talep: 0, onay: 0, kismi: 0, red: 0, tutar: 0 };
    k.talep++;
    if (t.durum === 1) {
      if (t.onaylananOran < t.oran) k.kismi++; else k.onay++;
      k.tutar += verilenIndirim(t);
    }
    if (t.durum === 2) k.red++;
    kova.set(ad, k);
  }
  return [...kova.entries()].map(([ad, k]) => ({ ad, ...k }))
    .sort((a, b) => b.talep - a.talep);
}
