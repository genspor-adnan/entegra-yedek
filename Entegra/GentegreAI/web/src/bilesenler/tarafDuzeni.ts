import type { ReactNode } from 'react';
import type { Kosul, ListeSatiri } from '../api/sozlesme';

/**
 * TARAF ARAMA DÜZENİ (mockup Ekranlar/taraf_arama.html, kullanıcı 05.11.2026: "müş / ted aramayı mockup'a göre yap" →
 * "personel ve ilgili aramayı da bu standartlara göre yap"). Ortak çatı TarafArama'da; kaynağa özel olan bu
 * nesnede: sabit koşul (pasif gelmez), sunucuya giden çipler, yüklü satırlardan beslenen seçim süzgeçleri, kolonlar,
 * satır rengi, lejant, sağ önizleme. Düzenler `tarafDuzenleri.ts`te kaynak adına bağlanır.
 */

/** Çağıranın kipinden türeyen bağlam: alış belgesinde tedarikçi gözü (ekFiltre tedarikci), satışta müşteri. */
export interface TarafBaglam {
  tedarikci: boolean;
  musteri: boolean;
}

export interface CipTanimi {
  kod: string;
  ad: string;
  ipucu?: string;
  kosul: Kosul;
}

/** Seçim süzgeci: seçenekler yüklü satırların o alanındaki değerlerden; seçilince sunucuya `esit` koşulu gider. */
export interface SecimTanimi {
  alan: string;
  etiket: string;
}

export interface TarafDuzeni {
  /** Pencere genişliği (CSS). */
  genislik: string;
  /** Her aramaya eklenen koşul - ör. `durum = 1` (pasif gelmez). */
  sabitKosul?: Kosul;
  cipler(b: TarafBaglam): CipTanimi[];
  secimler: SecimTanimi[];
  /** Metin aramasına eklenen alanlar (kod / unvan / telefon ham dışında). */
  ekArama: string[];
  /** İşaret kutusu dahil kolon sayısı ("Kayıt yok" satırı için). */
  kolonSayisi: number;
  yeniEtiketi(b: TarafBaglam): string;
  Basliklar(p: { b: TarafBaglam }): ReactNode;
  Hucreler(p: { s: ListeSatiri; b: TarafBaglam }): ReactNode;
  Onizleme(p: { s: ListeSatiri | undefined; b: TarafBaglam; onKapat(): void }): ReactNode;
  /** Araç çubuğunda Seç'in sağına eklenen düğmeler (cari: Ekstre). */
  EkDugmeler?(p: { s: ListeSatiri | undefined }): ReactNode;
  satirSinifi(s: ListeSatiri, b: TarafBaglam): string;
  lejant: { renk: string; ad: string }[];
}

export const sayiya = (v: unknown): number => { const n = Number(v ?? 0); return Number.isFinite(n) ? n : 0 };
/** Harf ya da rakam içermeyen değer (".", "-", "—": aktarımdan kalan dolgu) boş sayılır. */
export const metin = (v: unknown): string => { const t = String(v ?? '').trim(); return /[\p{L}\p{N}]/u.test(t) ? t : '' };
/** ISO tarih -> gg.aa.yyyy. */
export const tarihYaz = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

/** Düzenin koşulu: sabit + işaretli çipler + seçimler, VE ile. */
export function duzenKosulu(d: TarafDuzeni, b: TarafBaglam, cipler: Set<string>, secimler: Record<string, string>): Kosul | undefined {
  const k: Kosul[] = [];
  if (d.sabitKosul) k.push(d.sabitKosul);
  for (const c of d.cipler(b)) if (cipler.has(c.kod)) k.push(c.kosul);
  for (const s of d.secimler) { const v = secimler[s.alan]; if (v) k.push({ alan: s.alan, op: 'esit', deger: v }) }
  return k.length === 0 ? undefined : k.length === 1 ? k[0] : { op: 'and', kosullar: k };
}

/** Önizleme paneli tercihi (tarayıcıda; dar ekranda varsayılan kapalı). */
export const ONIZLEME_ANAHTARI = 'tarafArama.onizleme';
export function onizlemeOku(): boolean {
  try { const v = localStorage.getItem(ONIZLEME_ANAHTARI); return v === null ? window.innerWidth > 1100 : v === '1' }
  catch { return true }
}
export function onizlemeYaz(acik: boolean) {
  try { localStorage.setItem(ONIZLEME_ANAHTARI, acik ? '1' : '0') } catch { /* özel pencere */ }
}
