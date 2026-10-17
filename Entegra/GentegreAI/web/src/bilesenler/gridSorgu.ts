import type { KolonMeta, Kosul } from '../api/sozlesme';

/**
 * GRID SORGU KOSULLARI - hizli arama, filtre satiri, tarih araligi ve bunlarin
 * birlestirilmesi.
 *
 * Saf fonksiyonlar: gridin durumuna dokunmazlar, girdi verilir kosul doner.
 * Ayni tarih/birlestirme mantigi hem listeleme hem disa aktarma yolunda
 * kopyalanmisti; biri degistiginde oteki geride kalirdi.
 */

/** Hizli arama: metin kolonlarinda 'icerir' (sunucuda pg_trgm indeksli, Turkce duyarsiz). */
export function aramaKosulu(metin: string, kolonlar: KolonMeta[]): Kosul | undefined {
  const aranan = metin.trim();
  if (!aranan) return undefined;
  const hedefler = kolonlar.filter(k => k.tip === 'metin' && k.filtrelenebilir);
  if (hedefler.length === 0) return undefined;
  // HAM TELEFON (16.10.2026): "0533 666 88 99" / "5336668899" yazılışı rakama indirgenir - ham kolon
  //   yalnız rakam tutar. En az 4 rakam (kısa parça bütün listeyi getirmesin).
  const rakamlar = aranan.replace(/\D/g, '');
  const kosullar = hedefler.flatMap(k => /^telefonHam$/i.test(k.ad)
    ? (rakamlar.length >= 4 ? [{ alan: k.ad, op: 'icerir' as const, deger: rakamlar }] : [])
    : [{ alan: k.ad, op: 'icerir' as const, deger: aranan }]);
  return kosullar.length ? { op: 'or', kosullar } : undefined;
}

/** Sutun basligi altindaki filtre satiri - metin/kod kolonlarinda "icerir". */
export function filtreSatiriKosulu(
  filtreDeger: Record<string, string>, kolonlar: KolonMeta[]): Kosul | undefined
{
  const kosullar: Kosul[] = [];
  kolonlar.forEach(k => {
    if (k.tip !== 'metin' && k.tip !== 'kod') return;
    const v = (filtreDeger[k.ad] ?? '').trim();
    if (v) kosullar.push({ alan: k.ad, op: 'icerir', deger: v });
  });
  return kosullar.length ? { op: 'and', kosullar } : undefined;
}

/**
 * Tarih araligi: iki uc da doluysa 'arasinda' (ust sinir gun sonuna kadar),
 * tek uc verilirse >= / <= olarak uygulanir.
 */
export function tarihKosulu(
  alan: string | undefined, bas: string, bit: string): Kosul | undefined
{
  if (!alan) return undefined;
  if (bas && bit) return { alan, op: 'arasinda', deger: [bas, bit] };
  if (bas) return { alan, op: 'buyukEsit', deger: bas };
  if (bit) return { alan, op: 'kucukEsit', deger: bit };
  return undefined;
}

/** Bos olmayan kosullari AND ile birlestirir; tek kosul varsa oldugu gibi doner. */
export function filtreBirlestir(parcalar: (Kosul | undefined | null | false)[]): Kosul | undefined {
  const dolu = parcalar.filter(Boolean) as Kosul[];
  if (dolu.length === 0) return undefined;
  if (dolu.length === 1) return dolu[0];
  return { op: 'and', kosullar: dolu };
}
