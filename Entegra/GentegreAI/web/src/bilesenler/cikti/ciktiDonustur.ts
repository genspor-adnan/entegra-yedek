/**
 * ÇIKTI DÖNÜŞÜMLERİ - Çıktı menüsünün (CiktiMenusu) biçimleri.
 *
 * Kaynak HER ZAMAN ekranın çizdiği A4 belgesidir: rakamlar sunucudan gelmiş,
 * ekran onları zaten biçimlendirmiştir. Burada yeniden hesap YOK - yalnız
 * aynı belgeyi başka bir dosya türüne döker. Böylece Excel'deki toplam ile
 * kâğıttaki toplam asla ayrışmaz.
 */

export type Hucre = string | number | null;
export type TabloVerisi = { satirlar: Hucre[][]; kalin: number[] };

/** "1.234,56" / "-12,50 ₺" / "2026" → sayı; tarih, yüzde, kod METİN kalır. */
export function sayiCoz(metin: string): number | null {
  const m = metin.replace(/ /g, ' ').trim().replace(/\s*₺$/, '');
  if (!/^-?(\d{1,3}(\.\d{3})+|\d+)(,\d+)?$/.test(m)) return null;
  // Başında sıfır olan kod (0012) sayı değildir - Excel sıfırı yutar.
  if (/^-?0\d/.test(m)) return null;
  return Number(m.replace(/\./g, '').replace(',', '.'));
}

const metinOf = (el: Element) => (el as HTMLElement).innerText ?? el.textContent ?? '';

/**
 * Belgeyi satırlara döker - DOM sırasıyla: tablo satırları hücre hücre,
 * diğer bloklar (başlık, dönem, not) satır satır. Tablo başlıkları ve
 * "kalan / toplam" satırları kalın işaretlenir.
 */
export function belgeTablolari(kok: Element, sayiyaCevir = true): TabloVerisi {
  const satirlar: Hucre[][] = [];
  const kalin: number[] = [];
  const hucre = (t: string): Hucre => { const s = t.trim(); const n = sayiyaCevir ? sayiCoz(s) : null; return n ?? s };
  const gez = (el: Element) => {
    if (el.tagName === 'TABLE') {
      if (satirlar.length && satirlar[satirlar.length - 1].length) satirlar.push([]);
      el.querySelectorAll('tr').forEach(tr => {
        const h = [...tr.children].filter(c => c.tagName === 'TD' || c.tagName === 'TH');
        if (!h.length) return;
        if (h.every(c => c.tagName === 'TH') || tr.classList.contains('kalan') || tr.classList.contains('top'))
          kalin.push(satirlar.length);
        satirlar.push(h.map(c => hucre(metinOf(c))));
      });
      satirlar.push([]);
      return;
    }
    if (el.tagName === 'IMG' || el.tagName === 'SVG' || el.tagName === 'STYLE') return;
    // İçinde tablo / blok çocuk varsa in; yoksa düz metin satırları.
    if ([...el.children].some(c => c.tagName === 'TABLE' || c.tagName === 'DIV' || c.tagName === 'P' || c.tagName === 'H3')) {
      [...el.children].forEach(gez);
      return;
    }
    const satir = metinOf(el).split('\n').map(x => x.trim()).filter(Boolean);
    if (el.children.length > 1 && [...el.children].every(c => c.tagName === 'SPAN')) {
      // Bilgi şeridi (a4-hasta): her span bir hücre.
      satirlar.push([...el.children].map(c => hucre(metinOf(c))));
      return;
    }
    if (el.tagName === 'H3') kalin.push(satirlar.length);
    satir.forEach(s => satirlar.push([s]));
  };
  gez(kok);
  while (satirlar.length && !satirlar[satirlar.length - 1].length) satirlar.pop();
  return { satirlar, kalin };
}

/** <img> kaynağını data: URL'e çevirir (blob: logolar dosyada kaybolmasın). */
async function resimGom(img: HTMLImageElement): Promise<void> {
  if (!img.src || img.src.startsWith('data:')) return;
  try {
    const b = await (await fetch(img.src)).blob();
    img.src = await new Promise<string>((ok, red) => {
      const r = new FileReader(); r.onload = () => ok(String(r.result)); r.onerror = red; r.readAsDataURL(b);
    });
  } catch { img.removeAttribute('src') }
}

/** Satır içine yazılan stil özellikleri (yerleşim, yazı, kenarlık, renk). */
const STIL_OZELLIKLERI = [
  'display', 'box-sizing', 'width', 'max-width', 'margin-top', 'margin-right', 'margin-bottom', 'margin-left',
  'padding-top', 'padding-right', 'padding-bottom', 'padding-left',
  'border-top', 'border-right', 'border-bottom', 'border-left', 'border-collapse', 'table-layout',
  'color', 'background-color', 'font-family', 'font-size', 'font-weight', 'font-style',
  'text-align', 'vertical-align', 'white-space', 'line-height', 'letter-spacing', 'text-transform', 'text-decoration-line',
  'grid-template-columns', 'gap', 'align-items', 'justify-content', 'flex-direction', 'object-fit', 'height',
];
/** Genişliği korunan öğeler (kök belge ayrıca). */
const GENISLIKLI = new Set(['TABLE', 'TH', 'TD', 'IMG']);
/** Yazılmayan (tarayıcı varsayılanı) değerler. */
const VARSAYILAN = new Set(['0px', 'none', 'normal', 'auto', 'rgba(0, 0, 0, 0)', '0px none rgb(0, 0, 0)', 'start', 'baseline',
  'separate', 'stretch', 'row', 'fill', '400', 'content-box']);

/**
 * Belgenin STİL GÖMÜLÜ kopyası: her öğenin hesaplanmış stili satır içine
 * yazılır. Word / HTML ekranın sınıf kurallarını bilmez; satır içi
 * stil ile belge kendi başına aynı görünür. Ölçüm için öğe görünür olmalı.
 */
export async function stilGomuluKopya(kok: HTMLElement): Promise<HTMLElement> {
  const kopya = kok.cloneNode(true) as HTMLElement;
  const asil = [kok, ...kok.querySelectorAll<HTMLElement>('*')];
  const yeni = [kopya, ...kopya.querySelectorAll<HTMLElement>('*')];
  asil.forEach((a, i) => {
    const cs = getComputedStyle(a);
    let css = '';
    // Yalnız görünümü belirleyen özellikler; varsayılan değerler yazılmaz -
    //   bütün hesaplanmış stil yazılınca 3 satırlık icmal 800 KB oluyordu.
    for (const ad of STIL_OZELLIKLERI) {
      const d = cs.getPropertyValue(ad);
      if (!d || VARSAYILAN.has(d) || (ad === 'display' && d === 'block')) continue;
      // Sabit en / boy yalnız tablo hücresi ve resimde: blok kutuya piksel
      //   yüksekliği yazılırsa Word'de yazı kesilir.
      if ((ad === 'width' || ad === 'max-width') && !GENISLIKLI.has(a.tagName) && i > 0) continue;
      if (ad === 'height' && a.tagName !== 'IMG') continue;
      css += `${ad}:${d};`;
    }
    yeni[i].setAttribute('style', css);
    yeni[i].removeAttribute('class');
  });
  kopya.style.margin = '0';
  await Promise.all([...kopya.querySelectorAll('img')].map(resimGom));
  return kopya;
}

/** Tek başına açılan HTML belgesi. */
export function htmlBelgesi(baslik: string, govde: HTMLElement): string {
  return `<!doctype html><html lang="tr"><head><meta charset="utf-8"><title>${kacir(baslik)}</title></head>`
    + `<body style="margin:16px;background:#f3f5f8">${govde.outerHTML}</body></html>`;
}

/** Word: Office HTML'i .doc olarak açar (A4 dikey sayfa). */
export function wordBelgesi(baslik: string, govde: HTMLElement): string {
  return `<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" `
    + `xmlns="http://www.w3.org/TR/REC-html40"><head><meta charset="utf-8"><title>${kacir(baslik)}</title>`
    + `<style>@page { size:21cm 29.7cm; margin:1.5cm; }</style></head><body>${govde.outerHTML}</body></html>`;
}

function kacir(s: string) { return s.replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]!)) }
