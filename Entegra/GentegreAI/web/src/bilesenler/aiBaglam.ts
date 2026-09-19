import { useSyncExternalStore } from 'react';

/**
 * AÇIK KAYIT BAĞLAMI (449 · 871) — AI yardım paneli hangi kaydın ve hangi
 * sekmenin üstünde durduğumuzu buradan öğrenir.
 *
 * <b>Neden rota yetmiyor:</b> belge ve başvuru kartları MODAL açılıyor, rota
 * `/belge` olarak kalıyor. "Bu kayıtta ne eksik" sorusunun cevabı ise açık
 * karta bağlı; panelin kartın id'sini bilmesi gerekiyor.
 *
 * <b>Yalnız kimlik:</b> kaynak kodu, kayıt numarası, sekme adı. Kaydın
 * içeriği (ad, kimlik no, tanı) buraya YAZILMAZ - panel bunları sunucuya
 * göndermez, sunucu da istemese okumaz.
 *
 * Store minik ve tek yönlü: kartı açan ekran yazar, panel okur. Panel hiçbir
 * şeye yazmaz - asistan okuyucudur.
 */
export interface AiKayitBaglami { kaynak: string; id: number; sekme?: string }

let baglam: AiKayitBaglami | null = null;
const dinleyiciler = new Set<() => void>();

/** Kart açılınca çağrılır; kapanınca `null` ile temizlenir. */
export function aiBaglamAyarla(yeni: AiKayitBaglami | null) {
  const aynisi = baglam?.kaynak === yeni?.kaynak && baglam?.id === yeni?.id
              && baglam?.sekme === yeni?.sekme;
  if (aynisi) return;
  baglam = yeni;
  dinleyiciler.forEach(d => d());
}

/** Açık kartın görünen sekmesi değişince (kart bileşeni çağırır). */
export function aiSekmeAyarla(sekme: string | undefined) {
  if (!baglam || baglam.sekme === sekme) return;
  baglam = { ...baglam, sekme };
  dinleyiciler.forEach(d => d());
}

function abone(d: () => void) {
  dinleyiciler.add(d);
  return () => { dinleyiciler.delete(d) };
}

export function useAiBaglam(): AiKayitBaglami | null {
  return useSyncExternalStore(abone, () => baglam, () => null);
}
