import type { Satir } from './GenDetayTablo';

/**
 * ARAMAYLA SATIR EKLEMEDE SECIM DENETIMI (375).
 *
 * Pencere secimde kapanmadigi icin kullanici hizli hizli Enter'lar; ayni
 * kisiyi iki kez eklemek an meselesi. Veritabaninda `unique(plan_id,
 * taraf_id)` zaten var ama o KAYIT ANINDA, anlamsiz bir kisit hatasiyla
 * konusur - kullanici o ana kadar on kisi daha eklemis olur.
 *
 * Ikinci engel daha sinsi: KOD LISTESINDE OLMAYAN biri. Jenerik arama tum
 * personeli tarar, oysa gride yazilan deger kod listesinden okunur - listede
 * olmayan kisi gridde ADSIZ gorunur ve kayit sessizce ise yaramaz olur
 * (prim rolu isaretlenmemis personel hicbir hakedis uretmez).
 *
 * @returns engel sebebi, ya da secim gecerliyse null.
 */
export function tarafSecimEngeli(
  satirlar: readonly Satir[],
  alanAd: string,
  kodlar: Record<string, string> | null | undefined,
  secilen: { id: number; unvan: string },
): string | null {
  const id = String(secilen.id);
  if (satirlar.some(x => String(x[alanAd] ?? '') === id))
    return `${secilen.unvan} zaten ekli.`;
  if (kodlar && !(id in kodlar))
    return `${secilen.unvan} bu listede seçilebilir değil.`;
  return null;
}
