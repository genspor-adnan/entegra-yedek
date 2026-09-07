import { useSyncExternalStore } from 'react';

/**
 * AÇIK KAYIT BAĞLAMI (449) — AI Rehber paneli hangi kaydın üstünde
 * durduğumuzu buradan öğrenir.
 *
 * <b>Neden rota yetmiyor:</b> belge ve başvuru kartları MODAL açılıyor, rota
 * `/belge` olarak kalıyor. "Bu kayıtta ne eksik" sorusunun cevabı ise açık
 * karta bağlı; panelin kartın id'sini bilmesi gerekiyor.
 *
 * Store minik ve tek yönlü: kartı açan ekran yazar, panel okur. Panel hiçbir
 * şeye yazmaz - asistan Faz 3'te de okuyucudur.
 */
export interface AiKayitBaglami { kaynak: string; id: number }

let baglam: AiKayitBaglami | null = null;
const dinleyiciler = new Set<() => void>();

/** Kart açılınca çağrılır; kapanınca `null` ile temizlenir. */
export function aiBaglamAyarla(yeni: AiKayitBaglami | null) {
  const aynisi = baglam?.kaynak === yeni?.kaynak && baglam?.id === yeni?.id;
  if (aynisi) return;
  baglam = yeni;
  dinleyiciler.forEach(d => d());
}

function abone(d: () => void) {
  dinleyiciler.add(d);
  return () => { dinleyiciler.delete(d) };
}

export function useAiBaglam(): AiKayitBaglami | null {
  return useSyncExternalStore(abone, () => baglam, () => null);
}
