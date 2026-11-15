import type { KartAlanMeta } from '../api/sozlesme';

type Deger = string | number | boolean | null | undefined;

/** Karşıt alanın değeri "dolu" mu: boş metin, 0, false, null değil. */
export const degerDolu = (v: unknown): boolean =>
  !['', '0', 'false', 'null', 'undefined'].includes(String(v ?? '').trim());

/**
 * KARŞIT ALAN (1346; kullanıcı 15.11.2026: "randevu kartında gönderen yoksa başvuru gibi Kendi İsteği check
 * olmalı"): mantık alanın `karsitAlan`ı DOLDURULUNCA işaret kalkar, BOŞALTILINCA geri gelir - başvurudaki
 * "gönderen hekim ↔ kendi isteği" kuralının jenerik kart karşılığı (370: iki bilgi aynı anda doğru olamaz).
 * `yeni` yerinde değiştirilir; `ad` değişen alan, `v` yeni değeri.
 */
export function karsitAlanUygula(alanlar: readonly Pick<KartAlanMeta, 'ad' | 'karsitAlan'>[],
                                 yeni: Record<string, Deger>, ad: string, v: Deger): void {
  for (const x of alanlar) {
    if (x.karsitAlan !== ad) continue;
    yeni[x.ad] = !degerDolu(v);
  }
}

/** Karşıt alan doluyken mantık kutusu kilitli çizilir. */
export const karsitDolu = (a: Pick<KartAlanMeta, 'karsitAlan'>, deger: Record<string, unknown>): boolean =>
  !!a.karsitAlan && degerDolu(deger[a.karsitAlan]);
