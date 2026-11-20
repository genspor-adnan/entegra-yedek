/**
 * LİSTEDE SATIRI AÇMA (çift tık / Enter) - hangi liste ne açar (refaktör 20.11.2026, dokuman/REFAKTOR_RAPORU_2026-11-20.md B4).
 *
 * `Liste.tsx`'te on bir `tanim.kaynak === '…'` karşılaştırmalı bir if / else merdiveniydi; yeni bir özel liste her
 * seferinde jenerik bileşene bir dal ekliyordu. Karar artık bu tabloda: jenerik bileşen yalnız TÜRE göre davranır,
 * hangi kaynağın hangi türe girdiği burada okunur. Tabloda olmayan liste kendi `kartYolu`na gider.
 */
export type SatirAcTuru =
  /** Belge kartı: sekme düzeninde sekmede, değilse pencerede. */
  | 'belge'
  /** Kasa işlemi penceresi ("Aç" aksiyonuyla aynı). */
  | 'kasaIslem'
  /** Cari ekstre: satırı üreten kayıt (kasa işlemi, yoksa belge). */
  | 'cariEkstre'
  /** Banko oturumu penceresi (kullanıcı 08.10.2026: çift tık "Düzenle" ile aynı). */
  | 'bankoOturum'
  /** Rapor teslim: istem kartı değil TESLİM penceresi (kullanıcı 18.11.2026). */
  | 'raporTeslim'
  /** Gelen belgenin kartı yok: gönderenin görüntüsü açılır. */
  | 'gelenBelge';

const TABLO: Record<string, SatirAcTuru> = {
  // Belge listelerinde kart belge kartıdır (rota yok). Satınalma sipariş TAKİP listesi de `belge` üzerinde (tür 9) ve
  //   satır kimliği belge id'sidir: ayrı bir kart açmak aynı belgeye ikinci bir düzenleme ekranı demek olurdu.
  'belge': 'belge', 'irsaliye': 'belge', 'stok-transfer': 'belge', 'stok-talep': 'belge',
  'giris-fis': 'belge', 'cikis-fis': 'belge', 'satinalmaSiparis': 'belge',
  'kasa-islem': 'kasaIslem',
  'cari-ekstre': 'cariEkstre',
  'bankoOturum': 'bankoOturum',
  'radyoloji-teslim': 'raporTeslim',
  'gelen-belge': 'gelenBelge',
};

/** Kaynağın özel açma türü; yoksa null (liste kendi kart yoluna gider). */
export const satirAcTuru = (kaynak: string): SatirAcTuru | null =>
  Object.prototype.hasOwnProperty.call(TABLO, kaynak) ? TABLO[kaynak] : null;
