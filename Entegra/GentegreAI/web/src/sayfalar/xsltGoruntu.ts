/**
 * UBL -> GORUNTU (XSLT donusumu) - tek yer.
 *
 * Giden ve gelen e-Belge ekranlarinin ikisi de ayni islemi yapiyordu:
 * XML'i ayristir, "parsererror" var mi bak, XSLTProcessor kur, donustur,
 * seri hale getir. Iki kopya birebir aynidi; tek fark XSLT'nin NEREDEN
 * geldigiydi (giden: sunucudan; gelen: belgenin icine gomulu base64).
 * O yuzden donusum burada, kaynak farki cagiranlarda kaldi.
 *
 * Donusum basarisiz olursa null doner - cagiran kendi yedek gorunumune duser;
 * kullanici bos ekran gormemeli.
 */

// Ayristirici ICE AKTARIMDA degil ILK KULLANIMDA kurulur: modul seviyesinde
//   `new DOMParser()` tarayici disinda (test kosucusu) icin aktarimi bile
//   patlatiyordu - bu modulu hic kullanmayan bir test bile cokuyordu.
let ayristirici: DOMParser | null = null;
const dom = () => (ayristirici ??= new DOMParser());

/** XML metnini ayristirir; "parsererror" dugumu birakan bozuk girdide null. */
export function xmlAyristir(metin: string): Document | null {
  const belge = dom().parseFromString(metin, 'application/xml');
  return belge.querySelector('parsererror') ? null : belge;
}

/** UBL'e XSLT uygular; ikisinden biri bozuksa ya da cikti bossa null. */
export function xsltUygula(ubl: string | Document, xslt: string | Document): string | null {
  try {
    const kaynak = typeof ubl === 'string' ? xmlAyristir(ubl) : ubl;
    const sablon = typeof xslt === 'string' ? xmlAyristir(xslt) : xslt;
    if (!kaynak || !sablon) return null;

    const islemci = new XSLTProcessor();
    islemci.importStylesheet(sablon);
    const sonuc = islemci.transformToDocument(kaynak);
    return sonuc?.documentElement ? new XMLSerializer().serializeToString(sonuc) : null;
  } catch {
    // Desteklenmeyen XSLT surumu / bozuk sablon - cagiran yedege duser.
    return null;
  }
}

/** HTML'e gomulecek metni kacirir. */
export const kacir = (m: string) =>
  m.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

/** Sablon bulunamayinca gosterilen sade XML dokumu. */
export const hamXmlGorunumu = (ubl: string) =>
  `<pre style="font:12px/1.5 monospace;white-space:pre-wrap">${kacir(ubl)}</pre>`;
