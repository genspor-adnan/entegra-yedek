import { api } from '../api/istemci';

/**
 * BİLDİRİM TERCİHLERİ (669 · mockup: Ekranlar/Ayarlar/kullanici_ayarlari.html)
 *
 * Kanal listesi UYDURULMADI: yalnız gerçekten çalışan iki kanal var -
 *   · zil      → uygulama içindeki bildirim paneli (662),
 *   · masaustu → tarayıcının Notification API'si.
 * E-posta/SMS kanalları sunucuda yok; kutucuğunu çizip hiçbir şey
 * göndermemek, kullanıcıya "haber verilecek" diye yalan söylemek olurdu.
 *
 * Olay listesi de YETKİDEN türetilir (bkz. `olaylar()`): iskonto onayı satırı
 * yalnız onaylama yetkisi olan kişide görünür.
 */

export type Kanal = 'zil' | 'masaustu';

export interface OlayTercihi { zil: boolean; masaustu: boolean }

export interface BildirimTercihi {
  olaylar: Record<string, OlayTercihi>;
  /** Sessiz saat: masaüstü bildirimi susar, zil listesi DOLMAYA devam eder. */
  sessiz: { acik: boolean; bas: string; bit: string };
}

export interface OlayTanimi {
  kod: string;
  ad: string;
  aciklama: string;
  /** Kapatılamayan olay (klinik risk) - kutu kilitli çizilir. */
  kilit?: boolean;
}

const VARSAYILAN: BildirimTercihi = {
  olaylar: {},
  sessiz: { acik: false, bas: '20:00', bit: '08:00' },
};

const AYNA = 'gentegre.bildirim';

let mevcut: BildirimTercihi = aynadanOku();

function aynadanOku(): BildirimTercihi {
  try {
    const ham = localStorage.getItem(AYNA);
    return ham ? duzelt(JSON.parse(ham)) : { ...VARSAYILAN, olaylar: {} };
  } catch { return { ...VARSAYILAN, olaylar: {} } }
}

function duzelt(h: unknown): BildirimTercihi {
  const o = (h ?? {}) as Partial<BildirimTercihi>;
  const olaylar: Record<string, OlayTercihi> = {};
  for (const [k, v] of Object.entries(o.olaylar ?? {}))
    olaylar[k] = { zil: v?.zil !== false, masaustu: v?.masaustu === true };
  const s = o.sessiz ?? VARSAYILAN.sessiz;
  return {
    olaylar,
    sessiz: {
      acik: s.acik === true,
      bas: /^\d{2}:\d{2}$/.test(s.bas ?? '') ? s.bas : VARSAYILAN.sessiz.bas,
      bit: /^\d{2}:\d{2}$/.test(s.bit ?? '') ? s.bit : VARSAYILAN.sessiz.bit,
    },
  };
}

/**
 * Kullanıcının GÖREBİLECEĞİ olaylar. `iskontoTavani` 0 ise onay talebi ona
 * hiç düşmez - satırı da çizilmez (sunucu listesi zaten boş döner).
 */
export function olaylar(iskontoTavani: number): OlayTanimi[] {
  const l: OlayTanimi[] = [];
  if (iskontoTavani > 0)
    l.push({
      kod: 'iskonto',
      ad: 'İskonto onayı bekliyor',
      aciklama: 'Limitini aşan iskonto talebi onayınıza düştüğünde.',
    });
  return l;
}

/** Satır yoksa VARSAYILAN: zil açık, masaüstü kapalı (izin istemeden bildirim yok). */
export function olayTercihi(kod: string): OlayTercihi {
  return mevcut.olaylar[kod] ?? { zil: true, masaustu: false };
}

export function bildirimOku(): BildirimTercihi { return mevcut }

export function bildirimUygula(t: BildirimTercihi) {
  mevcut = t;
  try { localStorage.setItem(AYNA, JSON.stringify(t)) } catch { /* yoksay */ }
}

export async function bildirimYukle(tercihler?: Record<string, string>) {
  try {
    const t = tercihler ?? await api.tercihler();
    if (t.bildirim) bildirimUygula(duzelt(JSON.parse(t.bildirim)));
  } catch { /* tercih okunamadi: varsayilan yeterli */ }
}

export async function bildirimKaydet(t: BildirimTercihi) {
  bildirimUygula(t);
  await api.tercihYaz('bildirim', JSON.stringify(t));
}

/** Şu an sessiz saatte miyiz? Gece yarısını AŞAN aralık da doğru çalışır. */
export function sessizMi(simdi = new Date()): boolean {
  const s = mevcut.sessiz;
  if (!s.acik) return false;
  const dk = simdi.getHours() * 60 + simdi.getMinutes();
  const [bs, bd] = s.bas.split(':').map(Number);
  const [ts, td] = s.bit.split(':').map(Number);
  const bas = bs * 60 + bd, bit = ts * 60 + td;
  return bas <= bit ? (dk >= bas && dk < bit) : (dk >= bas || dk < bit);
}

/**
 * Masaüstü bildirimi. Üç kapı: kullanıcı bu olayda masaüstünü açmış olacak,
 * tarayıcı izni verilmiş olacak, sessiz saatte olmayacak. Sessiz saatte
 * bildirim SİLİNMEZ - zil listesinde durur, sabah görülür.
 */
export function masaustuBildir(kod: string, baslik: string, metin: string) {
  if (!olayTercihi(kod).masaustu) return;
  if (sessizMi()) return;
  if (typeof Notification === 'undefined' || Notification.permission !== 'granted') return;
  try { new Notification(baslik, { body: metin, tag: `gentegre-${kod}` }) }
  catch { /* tarayici reddetti - sessizce gec */ }
}

/** Tarayıcı izni ister; "granted" dönerse masaüstü bildirimi çalışır. */
export async function masaustuIzniIste(): Promise<NotificationPermission> {
  if (typeof Notification === 'undefined') return 'denied';
  if (Notification.permission !== 'default') return Notification.permission;
  try { return await Notification.requestPermission() } catch { return 'denied' }
}
