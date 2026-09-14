import { bruta } from './kdvModu';
import { satirTutari } from '../belgeSatir';
import { hamSayi } from '../../bilesenler/bicim';

/**
 * KALEM PENCERESİNİN FİYAT / İSKONTO MATEMATİĞİ.
 *
 * Ekranda üç kutu aynı tek alanı (`belge_satir.iskonto`) yazar - biri yüzdeyle,
 * biri lirayla, biri hedef birim fiyatla - ve hepsi aynı tabana bakmak
 * zorundadır. Bu kural bugüne kadar bileşenin içinde, `useState` çağrılarının
 * arasında duruyordu; üç ayrı hata oradan çıktı:
 *
 *   · "200'ün %10'u neden 16,67" — sağdaki tutar matrahtan, üstteki kutu
 *     brütten hesaplanıyordu,
 *   · "birim fiyat boş geldi" — döviz fiyatı 0 kayıtlı satırda taban sıfır
 *     çıkıyordu,
 *   · yuvarlama artığı — brüt yerine matrahtan geri çarpma (500 → 500,01).
 *
 * Kural artık SAF FONKSİYONLARDA: ekran onları çağırır, test doğrudan sınar.
 * Hesabın kendisi değişmedi - yalnız yeri değişti.
 */

/** Ekranda düzenlenen kalemin fiyat matematiği için gereken alanlar. */
export interface FiyatGirdisi {
  /** Satırın birim fiyatı (MATRAH - veritabanında saklanan). */
  fiyat: number;
  /** Kutuya yazılmış brüt metin (KDV dahil modda); boşsa matrahtan türetilir. */
  brutMetni?: string;
  kdv: unknown;
  /** Ekran KDV DAHİL mi çalışıyor (başvuruda her zaman öyle). */
  kdvDahil: boolean;
  /** Saf SGK rotası: iskonto SUT'a değil HASTA KATKISINA işler. */
  sgkKilitli: boolean;
  /** Hasta katkısı (saf SGK'da iskonto tabanı). */
  katkiTutar?: string | number | null;
  /** Satırdaki iskonto yüzdesi (ekranda metin tutulur). */
  iskonto: string;
  iskonto2: string;
}

/**
 * İSKONTO TABANI: iskontonun İŞLEDİĞİ sayı.
 *
 * Saf SGK'da SUT bedeli iskontolanmaz (fn_dagilim_coz) - indirim hastanın
 * katkısına işler; öteki rotalarda taban birim fiyattır.
 */
export const iskontoTabani = (g: FiyatGirdisi): number =>
  g.sgkKilitli ? hamSayi(g.katkiTutar ?? '0') : g.fiyat;

/**
 * BRÜT BİRİM FİYAT. Dahil modunda KULLANICININ YAZDIĞI brüt esastır: matrahtan
 * geri çarpmak kuruş kaydırır (500 / 1,10 = 454,5455 → 454,55 → × 1,10 = 500,01).
 */
export const brutBirimFiyat = (g: FiyatGirdisi): number =>
  g.kdvDahil ? (hamSayi(g.brutMetni) || bruta(g.fiyat, g.kdv)) : g.fiyat;

/**
 * EKRANDA GÖSTERİLEN TABAN: üst kutuda hangi sayı yazıyorsa o.
 *
 * Sağdaki iskonto kutusu bununla aynı tabana bakmak zorunda - yoksa aynı
 * satırdaki iki sayı farklı tabandan konuşur ("%10'u neden 16,67").
 * ORAN DEĞİŞMEZ: yüzde ölçek bağımsızdır, değişen yalnız gösterilen sayıdır.
 */
export const gosterimTabani = (g: FiyatGirdisi): number =>
  g.kdvDahil
    ? (g.sgkKilitli ? bruta(iskontoTabani(g), g.kdv) : brutBirimFiyat(g))
    : iskontoTabani(g);

/** Oranın TUTAR karşılığı - gösterim tabanından. */
export const iskontoKarsiligi = (g: FiyatGirdisi): number =>
  gosterimTabani(g) * Math.min(hamSayi(g.iskonto), 100) / 100;

/** Oranın HEDEF BİRİM FİYAT karşılığı (iskonto sonrası birim). */
export const hedefBirimFiyat = (g: FiyatGirdisi): number =>
  gosterimTabani(g) - iskontoKarsiligi(g);

/**
 * HEDEF BİRİM FİYAT → ORAN. Kullanıcı ekrandaki (KDV dahil) fiyatı yazar; oran
 * aynı tabana göre hesaplandığı için matrah/brüt farkı önemsizdir.
 *
 * Girilen fiyat asıl fiyattan BÜYÜKSE iskonto 0'dır: bu kutudan zam yapılamaz -
 * fiyatı yükseltmek fiyat listesinin işidir.
 */
export function fiyattanOran(g: FiyatGirdisi, hedef: number): number {
  const taban = gosterimTabani(g);
  if (!(taban > 0) || !(hedef > 0)) return 0;
  const oran = (1 - Math.min(hedef, taban) / taban) * 100;
  return Math.round(oran * 1e4) / 1e4;
}

/** Oran tavanı aşmasın - her yoldan gelen değer buradan geçer. */
export const oranKirp = (oran: number, tavan: number): number =>
  Math.max(0, Math.min(oran, tavan, 100));

/**
 * İSKONTOLU BİRİM FİYAT (önizleme). Hesap `satirTutari` ile yapılır (adet 1):
 * satır tutarındaki yuvarlama kuralının AYNISI - kendi çarpanını yazmak kuruş
 * farkı üretirdi.
 */
export const iskontoluBirim = (g: FiyatGirdisi): number =>
  satirTutari(1, gosterimTabani(g), g.iskonto, g.iskonto2);

/** İskonto gerçekten var mı - yoksa önizleme satırı üst kutunun kopyasıdır. */
export const iskontoVarMi = (g: FiyatGirdisi): boolean =>
  Math.abs(gosterimTabani(g) - iskontoluBirim(g)) > 0.004;
