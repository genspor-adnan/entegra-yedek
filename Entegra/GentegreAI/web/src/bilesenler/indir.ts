/**
 * DOSYA INDIRME - tek yer.
 *
 * Tarayicida dosya indirtmenin tek yolu gorunmez bir <a download> tiklatmak.
 * Bu bes ekranda ayri ayri yazilmisti ve her kopya biraz farkliydi:
 *   - biri `revokeObjectURL`u HEMEN cagiriyordu (Firefox indirme baslamadan
 *     URL'i serbest birakabiliyor, dosya bos iniyordu),
 *   - biri hic cagirmiyordu (sekme kapanana kadar blob bellekte kaliyordu).
 * Dogru olan: tiklamadan sonra kisa bir gecikmeyle serbest birak.
 */

/** Blob'u serbest birakmadan once tarayiciya indirmeyi baslatma payi. */
const SERBEST_BIRAK_MS = 1000;

/** Hazir bir URL'i (blob: ya da http:) verilen adla indirtir. */
export function dosyaIndirUrl(url: string, ad: string, serbestBirak = false): void {
  const bag = document.createElement('a');
  bag.href = url;
  bag.download = ad;
  document.body.appendChild(bag);
  bag.click();
  bag.remove();
  if (serbestBirak) setTimeout(() => URL.revokeObjectURL(url), SERBEST_BIRAK_MS);
}

/** Icerigi (metin ya da Blob) dosya olarak indirtir. */
export function dosyaIndir(icerik: BlobPart | Blob, ad: string, tip = 'application/octet-stream'): void {
  const blob = icerik instanceof Blob ? icerik : new Blob([icerik], { type: tip });
  dosyaIndirUrl(URL.createObjectURL(blob), ad, true);
}

/** Dosya adinda kullanilamayan karakterleri temizler (Windows kisitlari). */
export const dosyaAdiTemiz = (ad: string) => ad.replace(/[/\\:*?"<>|]/g, '').trim();
