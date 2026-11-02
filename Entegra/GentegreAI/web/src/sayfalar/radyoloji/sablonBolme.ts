/**
 * ŞABLON BÖLME / BİRLEŞTİRME (1216, mockup Ekranlar/Radyoloji/radyoloji_sablon_karti_v3.html).
 *
 * Bakanlık Teleradyoloji raporu (Entegrasyon Kılavuzu 3.46, OBX-5) gövdeyi DÖRT parça ister:
 *   ^1 Teknik · ^2 Karşılaştırma · ^3 Bulgular (zorunlu, ≥ 50 karakter) · ^4 Sonuç ve Öneriler (zorunlu).
 * Tek A4 şablon (eski HBYS Word şablonları) bu parçalara KALIN BAŞLIKLARDAN bölünür: bir paragraf yalnız
 * "BULGULAR" ya da "Bulgular:" ile başlıyorsa başlıktır (iki nokta zorunlu değil ama satır başlıkla bitmeli ya da
 * iki noktayla devam etmeli - "Bulgular ile uyumlu..." başlık sayılmaz). Başlıksız ön kısım ve başlığı tanınmayan
 * metin Bulgular'a gider; Klinik bilgi ayrı bölüm (Bakanlık parçası değil, istemle gider).
 */

export interface SablonBolumu {
  baslik: string;
  html: string;
  bakanlikParca: number;
  zorunlu: boolean;
  yazdir: boolean;
}

export const BAKANLIK_PARCALARI: { parca: number; ad: string; zorunlu: boolean }[] = [
  { parca: 1, ad: 'Teknik', zorunlu: false },
  { parca: 2, ad: 'Karşılaştırma', zorunlu: false },
  { parca: 3, ad: 'Bulgular', zorunlu: true },
  { parca: 4, ad: 'Sonuç ve öneriler', zorunlu: true },
];

/** Tek A4 şablonun tek bölümünün başlığı (rapor ekranındaki TEK_BASLIK). */
export const TEK_BOLUM = 'Rapor';

const sade = (s: string) => s.toLocaleUpperCase('tr').replace(/[ÇĞİÖŞÜ]/g, h => ({ Ç: 'C', Ğ: 'G', İ: 'I', Ö: 'O', Ş: 'S', Ü: 'U' })[h] ?? h);

/** Başlık sözlüğü (sadeleştirilmiş, büyük harf) -> parça (0 = klinik bilgi). Uzun olan önce denenir. */
const BASLIKLAR: [string, number][] = [
  ['SONUC VE ONERILER', 4], ['SONUC VE ONERI', 4], ['INCELEME TEKNIGI', 1], ['ONCEKI TETKIK', 2],
  ['KLINIK BILGI', 0], ['ENDIKASYON', 0], ['KLINIK', 0],
  ['KARSILASTIRMA', 2], ['TEKNIK', 1], ['BULGULAR', 3], ['BULGU', 3],
  ['SONUC', 4], ['KANAAT', 4], ['IZLENIM', 4], ['ONERILER', 4], ['ONERI', 4], ['YORUM', 4],
];

/** Blok metni bir başlıkla mı başlıyor: [parça, başlıktan sonra kalan metin]. */
export function baslikBul(metin: string): [number, string] | null {
  const t = metin.replace(/\s+/g, ' ').trim();
  const s = sade(t);
  for (const [b, parca] of BASLIKLAR) {
    if (!s.startsWith(b)) continue;
    const kalan = t.slice(b.length);
    // "BULGULAR" tek başına, ya da "Bulgular :" / "Bulgular:" + devamı.
    const m = /^\s*[:：]\s*(.*)$/.exec(kalan);
    if (m) return [parca, m[1]];
    if (kalan.trim() === '') return [parca, ''];
    return null;
  }
  return null;
}

const kacis = (s: string) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

/** Tek A4 HTML'i Bakanlık parçalarına böler. Dört parça her zaman döner (boşu boş); klinik bilgi varsa başta. */
export function bakanligaBol(html: string): SablonBolumu[] {
  const govde = new DOMParser().parseFromString(`<body>${html}</body>`, 'text/html').body;
  const kova: Record<number, string[]> = { 0: [], 1: [], 2: [], 3: [], 4: [] };
  let etkin = 3;   // başlıktan önceki kısım Bulgular'a
  for (const dugum of Array.from(govde.childNodes)) {
    const el = dugum as HTMLElement;
    const metin = dugum.textContent ?? '';
    const blok = dugum.nodeType === 1 && /^(P|DIV|H[1-6]|LI)$/.test(el.tagName);
    const b = blok ? baslikBul(metin) : null;
    if (b) {
      etkin = b[0];
      if (b[1].trim()) kova[etkin].push(`<p>${kacis(b[1].trim())}</p>`);
      continue;
    }
    const parca = dugum.nodeType === 1 ? el.outerHTML : kacis(metin);
    if (parca.trim()) kova[etkin].push(parca);
  }
  // Baştaki / sondaki BOŞ paragraflar atılır (eski şablonlarda stilli: <p style="..."><br></p>).
  const bos = String.raw`<(p|div)\b[^>]*>(?:\s|&nbsp;|<br\s*\/?>|<(span|b|i|u)\b[^>]*>(?:\s|&nbsp;|<br\s*\/?>)*<\/\2>)*<\/\1>`;
  const kenar = new RegExp(String.raw`^(?:${bos}|\s)+|(?:${bos}|\s)+$`, 'g');
  const temiz = (p: string[]) => p.join('').replace(kenar, '');
  const sonuc: SablonBolumu[] = [];
  if (temiz(kova[0])) sonuc.push({ baslik: 'Klinik bilgi', html: temiz(kova[0]), bakanlikParca: 0, zorunlu: false, yazdir: true });
  for (const p of BAKANLIK_PARCALARI)
    sonuc.push({ baslik: p.ad, html: temiz(kova[p.parca]), bakanlikParca: p.parca, zorunlu: p.zorunlu, yazdir: true });
  return sonuc;
}

/** Bölümleri tek A4'e birleştirir: her basılan bölüm kalın "BAŞLIK:" satırı + metni. */
export function teke(bolumler: SablonBolumu[]): SablonBolumu {
  const html = bolumler.filter(b => b.yazdir && b.html.replace(/<[^>]+>/g, '').trim() !== '')
    .map(b => `<p><b>${kacis(b.baslik.toLocaleUpperCase('tr'))}:</b></p>${b.html}`).join('<p><br></p>');
  return { baslik: TEK_BOLUM, html, bakanlikParca: 0, zorunlu: false, yazdir: true };
}

/** Eksik Bakanlık parçalarını ekler (var olanlara dokunmaz), parça sırasına dizer. */
export function bakanlikIskeleti(bolumler: SablonBolumu[]): SablonBolumu[] {
  const yeni = [...bolumler];
  for (const p of BAKANLIK_PARCALARI)
    if (!yeni.some(b => b.bakanlikParca === p.parca))
      yeni.push({ baslik: p.ad, html: '', bakanlikParca: p.parca, zorunlu: p.zorunlu, yazdir: true });
  // Parçası olmayan (0) bölümler yerinde; parçalılar 1-4 sırasıyla.
  const sira = (b: SablonBolumu) => (b.bakanlikParca === 0 ? -1 : b.bakanlikParca);
  return yeni.map((b, i) => ({ b, i })).sort((x, y) => sira(x.b) - sira(y.b) || x.i - y.i).map(x => x.b);
}
