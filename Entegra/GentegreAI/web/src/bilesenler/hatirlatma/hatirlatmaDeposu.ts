import { useSyncExternalStore } from 'react';
import { api } from '../../api/istemci';
import type { Hatirlatma } from '../../api/uclar/hatirlatma';
import { yerelAnMetni } from '../bicim';

/**
 * KİŞİSEL HATIRLATICI ORTAK DEPOSU (1139, mockup Ekranlar/Kullanici/kisisel_hatirlatici.html).
 *
 *  · ZİL VERİSİ tek yerde: kabuktaki HatirlatmaYoneticisi dakikada bir `/api/hatirlatma/zil` okur;
 *    zil paneli, açılır uyarılar ve Başlangıç aynı listeyi izler (ikinci istek yok).
 *  · PENCERE her ekrandan açılır: `hatirlatmaPenceresiAc({ ... })` olay yayar, yönetici dinler.
 *  · Bir hatırlatma değişince `hatirlatmaDegisti()` - liste, rozet ve zil tazelenir.
 */

let zil: Hatirlatma[] = [];
const dinleyiciler = new Set<() => void>();
const yay = () => dinleyiciler.forEach(f => f());

export async function zilYukle(): Promise<void> {
  try { zil = await api.hatirlatmaZil(); yay() } catch { /* zil zorunlu değil */ }
}

export function useHatirlatmaZil(): Hatirlatma[] {
  return useSyncExternalStore(f => { dinleyiciler.add(f); return () => { dinleyiciler.delete(f) } }, () => zil, () => zil);
}

/** Zil rozeti: gecikmiş + uyarı anı gelmiş + bir saat içinde olanlar. */
export function zilSayisi(satirlar: Hatirlatma[], simdi = Date.now()): number {
  return satirlar.filter(s => new Date(s.uyariZamani).getTime() <= simdi || new Date(s.zaman).getTime() <= simdi + 3600_000).length;
}

export const HATIRLATMA_AC_OLAYI = 'gentegre:hatirlatma-ac';
export const HATIRLATMA_DEGISTI_OLAYI = 'gentegre:hatirlatma-degisti';

export type HatirlatmaAcIstegi = {
  /** Var olan hatırlatma; yoksa yeni kart. */
  id?: number;
  /** Yeni kartta bağlı kayıt: kart rotası (ör. "cari") + id + görünen ad. */
  kaynak?: string; kaynakId?: number; kaynakAd?: string;
  baslik?: string;
  /** Yeni kartın zamanı (yerel "yyyy-MM-ddTHH:mm"). */
  zaman?: string;
};

export function hatirlatmaPenceresiAc(istek: HatirlatmaAcIstegi = {}) {
  window.dispatchEvent(new CustomEvent<HatirlatmaAcIstegi>(HATIRLATMA_AC_OLAYI, { detail: istek }));
}

export function hatirlatmaDegisti() {
  void zilYukle();
  window.dispatchEvent(new Event(HATIRLATMA_DEGISTI_OLAYI));
}

// --------------------------------------------------------------- zaman --

const saatte = (d: Date, s: number, dk = 0) => { const y = new Date(d); y.setHours(s, dk, 0, 0); return y };
const gunEkle = (d: Date, n: number) => { const y = new Date(d); y.setDate(y.getDate() + n); return y };
const dakikaya = (d: Date) => { const y = new Date(d); y.setSeconds(0, 0); return y };

/** Hızlı zaman seçenekleri (mockup kart "Hızlı zaman" ve kayıttan hızlı hatırlatma). */
export function hizliZamanlar(simdi = new Date()): { ad: string; zaman: Date }[] {
  const yarin = saatte(gunEkle(simdi, 1), 9);
  const gun = simdi.getDay();   // 0 Pz
  const pazartesi = saatte(gunEkle(simdi, ((8 - gun) % 7) || 7), 9);
  const liste = [
    { ad: '15 dk sonra', zaman: dakikaya(new Date(simdi.getTime() + 15 * 60_000)) },
    { ad: '1 saat sonra', zaman: dakikaya(new Date(simdi.getTime() + 60 * 60_000)) },
    ...(simdi.getHours() < 17 ? [{ ad: 'Bu akşam', zaman: saatte(simdi, 18) }] : []),
    { ad: 'Yarın sabah', zaman: yarin },
    { ad: 'Pazartesi', zaman: pazartesi },
    { ad: '1 hafta sonra', zaman: saatte(gunEkle(simdi, 7), 9) },
  ];
  return liste;
}

/** Erteleme seçenekleri: dakika ya da yerel zaman. */
export function erteleSecenekleri(simdi = new Date()): { ad: string; dakika?: number; zaman?: string }[] {
  return [
    { ad: '10 dk', dakika: 10 }, { ad: '30 dk', dakika: 30 }, { ad: '1 saat', dakika: 60 },
    ...(simdi.getHours() < 17 ? [{ ad: 'Bu akşam 18:00', zaman: yerelAnMetni(saatte(simdi, 18)) }] : []),
    { ad: 'Yarın 09:00', zaman: yerelAnMetni(saatte(gunEkle(simdi, 1), 9)) },
    { ad: 'Pazartesi 09:00', zaman: yerelAnMetni(saatte(gunEkle(simdi, ((8 - simdi.getDay()) % 7) || 7), 9)) },
  ];
}

const p2 = (n: number) => String(n).padStart(2, '0');
export const kisaZaman = (d: Date, simdi = new Date()) => {
  const ayni = d.toDateString() === simdi.toDateString();
  return ayni ? `${p2(d.getHours())}:${p2(d.getMinutes())}` : `${p2(d.getDate())}.${p2(d.getMonth() + 1)} ${p2(d.getHours())}:${p2(d.getMinutes())}`;
};

/** "25 dk sonra" · "18 sa gecikti" · "yarın" · "5 gün". */
export function kalanMetni(zaman: string, simdi = Date.now()): { metin: string; sinif: '' | 'kir' | 'sari' | 'mavi' } {
  const dk = Math.round((new Date(zaman).getTime() - simdi) / 60_000);
  if (dk < 0) {
    const g = -dk;
    return { metin: g < 60 ? `${g} dk gecikti` : g < 1440 ? `${Math.round(g / 60)} sa gecikti` : `${Math.round(g / 1440)} gün gecikti`, sinif: 'kir' };
  }
  const z = new Date(zaman), b = new Date(simdi);
  if (z.toDateString() === b.toDateString()) return { metin: dk === 0 ? 'şimdi' : dk < 60 ? `${dk} dk sonra` : 'bugün', sinif: dk < 60 ? 'sari' : 'mavi' };
  if (z.toDateString() === gunEkle(b, 1).toDateString()) return { metin: 'yarın', sinif: '' };
  return { metin: `${Math.ceil((saatte(z, 0).getTime() - saatte(b, 0).getTime()) / 86_400_000)} gün`, sinif: '' };
}

/** Bağlı kayıt türleri: kart rotasının ilk parçası -> ikon + ad. */
export const KAYIT_TURLERI: Record<string, { ic: string; ad: string }> = {
  hasta: { ic: '🧑', ad: 'Hasta' }, cari: { ic: '🏢', ad: 'Cari' }, personel: { ic: '👤', ad: 'Personel' },
  kisi: { ic: '👥', ad: 'Kişi' }, belge: { ic: '📄', ad: 'Belge' }, fatura: { ic: '📄', ad: 'Fatura' },
  randevu: { ic: '📅', ad: 'Randevu' }, gorev: { ic: '✅', ad: 'Görev' }, stok: { ic: '📦', ad: 'Stok' },
};
export const kayitIkonu = (kaynak: string) => KAYIT_TURLERI[kaynak.split('/')[0]]?.ic ?? '🔗';
