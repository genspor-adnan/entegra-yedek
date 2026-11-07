import type { ReactNode } from 'react';
import type { Kosul, ListeSatiri } from '../api/sozlesme';
import { metne } from './bicim';
import { filtreBirlestir } from './gridSorgu';

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
  cipler?(b: TarafBaglam): CipTanimi[];
  secimler: SecimTanimi[];
  /** Metin aramasına eklenen alanlar (kod / unvan / telefon ham dışında). */
  ekArama: string[];
  /** İşaret kutusu dahil kolon sayısı ("Kayıt yok" satırı için). */
  kolonSayisi: number;
  yeniEtiketi(b: TarafBaglam): string;
  Basliklar(p: { b: TarafBaglam }): ReactNode;
  Hucreler(p: { s: ListeSatiri; b: TarafBaglam }): ReactNode;
  /** Seçili satırın önizleme İÇERİĞİ; çerçeve (başlık, kapat, "Satır seçin") TarafArama'da. */
  Onizleme(p: { s: ListeSatiri; b: TarafBaglam }): ReactNode;
  /** Araç çubuğunda Seç'in sağına eklenen düğmeler (cari: Ekstre). */
  EkDugmeler?(p: { s: ListeSatiri | undefined }): ReactNode;
  satirSinifi?(s: ListeSatiri, b: TarafBaglam): string;
  lejant?: { renk: string; ad: string }[];
}

// Sayı / tarih çözme bicim.ts'ten (sayiya, gunNokta); yalnız `metin` taraf aramalarına özgü.
export { sayiya, gunNokta as tarihYaz } from './bicim';
/** Harf ya da rakam içermeyen değer (".", "-", "—": aktarımdan kalan dolgu) boş sayılır. */
export const metin = (v: unknown): string => { const t = metne(v); return /[\p{L}\p{N}]/u.test(t) ? t : '' };

/** Düzenli aramalarda sabit koşul: pasifler gelmez (kullanıcı 05.11.2026 "pasifler aramaya gelmesin"). */
export const AKTIF_KOSULU: Kosul = { alan: 'durum', op: 'esit', deger: 1 };

/** Düzenin koşulu: sabit + işaretli çipler + seçimler, VE ile. */
export function duzenKosulu(d: TarafDuzeni, b: TarafBaglam, cipler: Set<string>, secimler: Record<string, string>): Kosul | undefined {
  return filtreBirlestir([
    AKTIF_KOSULU,
    ...(d.cipler?.(b) ?? []).filter(c => cipler.has(c.kod)).map(c => c.kosul),
    ...d.secimler.map(s => secimler[s.alan] ? { alan: s.alan, op: 'esit' as const, deger: secimler[s.alan] } : undefined),
  ]);
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
