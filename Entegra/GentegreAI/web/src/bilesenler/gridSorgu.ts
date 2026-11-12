import type { KolonMeta, Kosul, KosulOp } from '../api/sozlesme';

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
    const v = (filtreDeger[k.ad] ?? '').trim();
    if (!v) return;
    if (k.tip === 'metin' || k.tip === 'kod') kosullar.push({ alan: k.ad, op: 'icerir', deger: v });
    else if (SAYISAL_TIPLER.has(k.tip)) { const s = sayiFiltresi(k.ad, v); if (s) kosullar.push(s) }
  });
  return kosullar.length ? { op: 'and', kosullar } : undefined;
}

/** Başlık filtresi sayısal kutu çizen kolon tipleri. */
export const SAYISAL_TIPLER = new Set(['sayi', 'para', 'ondalik']);

/**
 * SAYISAL BAŞLIK FİLTRESİ (kullanıcı 12.11.2026: "stok listesinde kalan sütununda … filtreleme yapamıyorum"): kutu
 * ">0", "<5", ">=10", "<=3", "<>0" / "!=0", "10..20" (arası, iki uç dahil) ve düz sayıyı (eşit) anlar; ondalık virgül
 * de olur ("2,5"). Anlaşılmayan ifade süzmez (null) - yazarken yarım ifade listeyi boşaltmasın.
 */
export function sayiFiltresi(alan: string, ifade: string): Kosul | null {
  const s = ifade.replace(/\s+/g, '');
  const sayi = (x: string) => {
    if (!/^-?\d+([.,]\d+)?$/.test(x)) return null;
    return Number(x.replace(',', '.'));
  };
  const aralik = s.match(/^(-?[\d.,]+)\.\.(-?[\d.,]+)$/);
  if (aralik) {
    const a = sayi(aralik[1]), b = sayi(aralik[2]);
    return a === null || b === null ? null : { alan, op: 'arasinda', deger: [Math.min(a, b), Math.max(a, b)] };
  }
  const m = s.match(/^(>=|<=|<>|!=|>|<|=)?(.*)$/);
  const op = m?.[1] ?? '=';
  const deger = sayi(m?.[2] ?? '');
  if (deger === null) return null;
  const islecler: Record<string, KosulOp> = { '>': 'buyuk', '>=': 'buyukEsit', '<': 'kucuk', '<=': 'kucukEsit',
                                             '<>': 'esitDegil', '!=': 'esitDegil', '=': 'esit' };
  return { alan, op: islecler[op] ?? 'esit', deger };
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
