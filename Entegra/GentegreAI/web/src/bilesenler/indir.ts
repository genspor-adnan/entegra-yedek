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

/**
 * DOKUMAN ADINDAN INDIRME DOSYA ADI.
 *
 * Kartta gorunen ad kullanicinin verdigi addir ve UZANTISI OLMAYABILIR
 * ("PR-07 Numune Kabul Proseduru"). Uzantisiz inen dosyayi isletim sistemi
 * hicbir programla acamiyor; bu yuzden ad uzantisizsa icerik tipinden
 * tamamlanir.
 *
 * Dosya sisteminde gecersiz karakterler de temizlenir - Windows'ta ':' ya da
 * '/' iceren ad indirmeyi sessizce basarisiz yapar.
 */
const TIP_UZANTI: Record<string, string> = {
  'application/pdf': 'pdf', 'image/png': 'png', 'image/jpeg': 'jpg',
  'image/gif': 'gif', 'image/webp': 'webp', 'text/plain': 'txt',
  'text/csv': 'csv', 'application/xml': 'xml', 'text/xml': 'xml',
  'application/xslt+xml': 'xslt', 'application/zip': 'zip',
  'application/json': 'json',
  'application/msword': 'doc',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
  'application/vnd.ms-excel': 'xls',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
};

export function dokumanDosyaAdi(ad: string, contentType?: string | null): string {
  const temiz = (ad || 'dokuman').replace(/[\/:*?"<>|]/g, '-').trim() || 'dokuman';
  // Zaten uzantisi varsa dokunma: kullanicinin yazdigi ".pdf" ikinci kez
  //   eklenmemeli ("rapor.pdf.pdf").
  if (/\.[a-z0-9]{2,5}$/i.test(temiz)) return temiz;
  const uzanti = TIP_UZANTI[(contentType ?? '').split(';')[0].trim().toLowerCase()];
  return uzanti ? `${temiz}.${uzanti}` : temiz;
}
