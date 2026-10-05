/**
 * KİŞİ KOD → ETİKET SÖZLÜKLERİ.
 *
 * <b>Neden tek yerde:</b> cinsiyet sözlüğü beş dosyada ayrı yazılmıştı (lab
 * etiketi, lab raporu, radyoloji raporu, göz şeması çıktısı, göz muayene
 * şeridi) ve iki biçimde: etikette "E / K", raporda "Erkek / Kadın". Kod
 * listesine üçüncü bir değer girdiği gün beş dosyadan dördü eski kalırdı.
 *
 * Kısa biçim ETİKET VE ŞERİT için: barkod etiketinde satır 50 mm, "Erkek"
 * yazısı yaşı dışarı atıyordu; raporda ise kısaltma resmî bir belgede
 * okunmaz duruyor - iki biçim bilinçli, iki sözlük değil.
 */

/** `taraf_hasta.cinsiyet` — resmî belgelerde ve kartta tam ad. */
export const CINSIYET: Record<number, string> = { 1: 'Erkek', 2: 'Kadın' };

/** Etiket / şerit gibi dar yerlerde tek harf. */
export const CINSIYET_KISA: Record<number, string> = { 1: 'E', 2: 'K' };

/** Boş / tanımsız kodda BOŞ döner: "—" yazmak kararı çağırana ait. */
export const cinsiyetAdi = (kod: unknown, kisa = false): string =>
  (kisa ? CINSIYET_KISA : CINSIYET)[Number(kod ?? 0)] ?? '';
