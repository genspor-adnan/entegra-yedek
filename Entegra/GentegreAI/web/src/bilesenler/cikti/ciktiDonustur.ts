/**
 * ÇIKTI DÖNÜŞÜMLERİ - Çıktı menüsünün (CiktiMenusu) biçimleri.
 *
 * Kaynak HER ZAMAN ekranın çizdiği A4 belgesidir: rakamlar sunucudan gelmiş,
 * ekran onları zaten biçimlendirmiştir. Burada yeniden hesap YOK - yalnız
 * aynı belgeyi başka bir dosya türüne döker. Böylece Excel'deki toplam ile
 * kâğıttaki toplam asla ayrışmaz.
 */

export type Hucre = string;

const metinOf = (el: Element) => (el as HTMLElement).innerText ?? el.textContent ?? '';

/**
 * EXCEL BLOKLARI - A4 belgesinin YAPISI (kullanıcı: "excel çıktısı iyi
 * olmamış"; düz satır dökümü yerine rapor düzeni). Bütün icmal A4'leri aynı
 * sınıfları kullanır: a4-bas (antet) · h3 (başlık) · a4-hasta (bilgi
 * şeridi) · a4-t (veri tablosu) · a4-toplam (özet) · a4-not · a4-imza.
 * Sunucu her bloğu kendi biçimiyle yazar (DisaAktarUclari).
 */
export type ExcelBlok =
  | { tur: 'kurum'; satirlar: string[]; sag: string[]; logo?: string }
  | { tur: 'baslik' | 'altbaslik' | 'not'; metin: string }
  | { tur: 'bilgi'; hucreler: string[] }
  | { tur: 'tablo'; basliklar: string[]; satirlar: Hucre[][]; kalin: number[]; sag: boolean[] }
  | { tur: 'ozet'; satirlar: { ad: string; deger: Hucre; kalin: boolean }[] }
  | { tur: 'kutular'; kutular: { baslik: string; deger: string; alt: string; renk: string }[] };

/**
 * EKRANIN ÖZET KUTULARI (kullanıcı: "üstte kutular altta liste olsun"):
 * sayfadaki `.hi-ozet .hi-kutu` - bütün icmallerde aynı sınıf. Renk sınıfı
 * (mor / iyi / uy / teh) Excel'de değer rengine çevrilir.
 */
export function ozetKutulari(sayfa: Element | null): ExcelBlok | null {
  const kutular = [...(sayfa?.querySelectorAll('.hi-ozet .hi-kutu') ?? [])].map(k => ({
    baslik: (k.querySelector('.bas')?.textContent ?? '').trim(),
    deger: (k.querySelector('.deg')?.textContent ?? '').trim(),
    alt: (k.querySelector('.alt')?.textContent ?? '').trim(),
    renk: ['mor', 'iyi', 'uy', 'teh'].find(r => k.classList.contains(r)) ?? '',
  }));
  return kutular.length ? { tur: 'kutular', kutular } : null;
}

/**
 * EXCEL DÜZENİ: antet + başlık + dönem, sonra ekranın özet kutuları, altında
 * liste. A4'ün toplam ve not blokları Excel'e girmez - kutular onları taşır.
 */
export async function excelDuzeni(a4: Element, sayfa: Element | null): Promise<ExcelBlok[]> {
  const a4Bloklari = excelBloklari(a4).filter(b => b.tur !== 'ozet' && b.tur !== 'not');
  // Logo Excel'e resim olarak gider (antet: logonun sağında kurum bilgisi).
  const kurum = a4Bloklari.find(b => b.tur === 'kurum');
  const img = a4.querySelector<HTMLImageElement>('.a4-bas img');
  if (kurum && kurum.tur === 'kurum' && img?.src) {
    const kopya = img.cloneNode() as HTMLImageElement;
    await resimGom(kopya);
    if (kopya.src.startsWith('data:image/')) kurum.logo = kopya.src;
  }
  const kutu = ozetKutulari(sayfa);
  if (!kutu) return a4Bloklari;
  const ilkTablo = a4Bloklari.findIndex(b => b.tur === 'tablo');
  const i = ilkTablo < 0 ? a4Bloklari.length : ilkTablo;
  return [...a4Bloklari.slice(0, i), kutu, ...a4Bloklari.slice(i)];
}

export function excelBloklari(kok: Element): ExcelBlok[] {
  const bloklar: ExcelBlok[] = [];
  const t = (el: Element | null | undefined) => (el ? metinOf(el) : '').replace(/[ \t]+\n/g, '\n').trim();
  // Hücreler METİN gider: sayı / tarih çözümü sunucuda - "375,00" ondalığını kaybetmesin.
  const hucre = (x: string): Hucre => x.trim();
  const gez = (el: Element) => {
    const c = el.classList;
    if (c.contains('a4-imza') || el.tagName === 'STYLE' || el.tagName === 'IMG') return;
    if (c.contains('a4-bas')) {
      const sol = [el.querySelector('.kurum'), ...el.querySelectorAll('.kurum-alt')].map(x => t(x)).filter(Boolean);
      bloklar.push({ tur: 'kurum', satirlar: sol, sag: t(el.querySelector('.a4-tarih')).split('\n').map(x => x.trim()).filter(Boolean) });
      return;
    }
    if (el.tagName === 'H3') { bloklar.push({ tur: 'baslik', metin: t(el) }); return }
    if (c.contains('a4-hasta')) {
      bloklar.push({ tur: 'bilgi', hucreler: [...el.children].map(x => t(x)).filter(Boolean) });
      return;
    }
    if (el.tagName === 'TABLE' && c.contains('a4-toplam')) {
      bloklar.push({ tur: 'ozet', satirlar: [...el.querySelectorAll('tr')].map(tr => {
        const h = [...tr.querySelectorAll('td, th')];
        return { ad: t(h[0]), deger: hucre(t(h[h.length - 1])), kalin: tr.classList.contains('kalan') };
      }) });
      return;
    }
    if (el.tagName === 'TABLE') {
      const satirlar = [...el.querySelectorAll('tr')];
      const basSatir = satirlar.find(tr => [...tr.children].every(x => x.tagName === 'TH'));
      const veri = satirlar.filter(tr => tr !== basSatir);
      const ornek = veri[0] ? [...veri[0].children] : [];
      bloklar.push({
        tur: 'tablo',
        basliklar: basSatir ? [...basSatir.children].map(x => t(x)) : [],
        satirlar: veri.map(tr => [...tr.children].map(x => hucre(t(x)))),
        kalin: veri.map((tr, i) => tr.classList.contains('top') || tr.classList.contains('kalan') ? i : -1).filter(i => i >= 0),
        sag: ornek.map(x => getComputedStyle(x).textAlign === 'right'),
      });
      return;
    }
    if ([...el.children].some(x => x.tagName === 'TABLE' || x.tagName === 'DIV' || x.tagName === 'H3' || x.tagName === 'P')) {
      [...el.children].forEach(gez);
      return;
    }
    const m = t(el);
    if (!m) return;
    bloklar.push({ tur: c.contains('a4-not') || el.tagName === 'P' ? 'not' : 'altbaslik', metin: m.replace(/\n+/g, ' ') });
  };
  gez(kok);
  return bloklar;
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
      if (ad.startsWith('border-') && d.startsWith('0px')) continue;   // kenarlıksız: "0px none <renk>" gürültüsü
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

/**
 * WORD UYARLAMASI: Word HTML 4 motoruyla çizer - flex / grid yok, piksel
 * genişliği sayfa kenarını aşınca tablo kesilir. Stil gömülü kopyada:
 *   - flex kutu → tek satırlık tablo (antet: logo | kurum | tarih),
 *   - grid kutu → kolon sayısınca satırlara bölünmüş tablo (bilgi, imza),
 *   - tablolar sayfa genişliğinde (%), hücre piksel genişlikleri silinir,
 *   - sağa yaslı dar tablo (toplamlar) align=right.
 */
export function wordIcinDuzenle(kok: HTMLElement): HTMLElement {
  const stil = (el: HTMLElement, ad: string) => el.style.getPropertyValue(ad);
  const tabloYap = (kap: HTMLElement, kolon: number, hizalar: string[]) => {
    const t = document.createElement('table');
    t.dataset.kap = '1';   // kendi kurduğumuz yerleşim tablosu - genişlikleri korunur
    t.setAttribute('width', '100%'); t.setAttribute('cellpadding', '0'); t.setAttribute('cellspacing', '0');
    t.style.cssText = 'width:100%;border-collapse:collapse;' + kap.style.cssText.replace(/display:[^;]+;/, '');
    const cocuklar = [...kap.children] as HTMLElement[];
    for (let i = 0; i < cocuklar.length; i += kolon) {
      const tr = t.insertRow();
      cocuklar.slice(i, i + kolon).forEach((c, j) => {
        const td = tr.insertCell();
        td.setAttribute('valign', 'top');
        const h = hizalar[j] ?? '';
        if (h) td.setAttribute('align', h);
        td.style.cssText = 'padding:2px 6px;' + (h ? `text-align:${h};` : '');
        c.style.removeProperty('display');
        td.appendChild(c);
      });
    }
    kap.replaceWith(t);
  };
  // İçten dışa: iç içe flex/grid önce çözülsün.
  [...kok.querySelectorAll<HTMLElement>('*')].reverse().forEach(el => {
    const d = stil(el, 'display');
    if (d === 'flex' && el.children.length > 1) {
      const n = el.children.length;
      // Antet gibi "sona yaslı son öğe" (margin-left:auto) sağa.
      const son = el.lastElementChild as HTMLElement | null;
      tabloYap(el, n, [...el.children].map((_, i) => i === n - 1 && n > 2 ? 'right' : ''));
      // Antet (logo | kurum | tarih): yüzde genişlik - kurum geniş, tarih dar.
      const td = son?.parentElement;
      if (td && n === 3) {
        const [a, b2, c] = [...td.parentElement!.children] as HTMLElement[];
        [[a, 9], [b2, 58], [c, 33]].forEach(([h, y]) => (h as HTMLElement).setAttribute('width', `${y}%`));
        // Tarih / düzenleyen satırı bölünmesin (Word white-space'i tanımıyor).
        const yuru = document.createTreeWalker(c, NodeFilter.SHOW_TEXT);
        for (let d = yuru.nextNode(); d; d = yuru.nextNode()) d.nodeValue = (d.nodeValue ?? '').replace(/ /g, ' ');
      }
    } else if (d === 'grid' && el.children.length > 0) {
      const kolon = Math.max(1, stil(el, 'grid-template-columns').trim().split(/\s+/).length);
      tabloYap(el, kolon, []);
    }
  });
  kok.querySelectorAll<HTMLElement>('table').forEach(t => {
    const sagaYasli = t.style.getPropertyValue('margin-left') !== '' && t.style.getPropertyValue('margin-left') !== '0px';
    t.style.removeProperty('table-layout');
    if (sagaYasli) {
      // Word tabloda align=right'ı yok sayıyor: iki hücreli kap (sol boş %40, sağda tablo).
      t.style.removeProperty('margin-left'); t.style.removeProperty('margin-right');
      t.setAttribute('width', '100%'); t.style.width = '100%';
      const kap = document.createElement('table');
      kap.dataset.kap = '1';
      kap.setAttribute('width', '100%'); kap.setAttribute('cellpadding', '0'); kap.setAttribute('cellspacing', '0');
      kap.style.cssText = 'width:100%;border-collapse:collapse;margin-top:6px;';
      const tr = kap.insertRow();
      tr.insertCell().setAttribute('width', '40%');
      const sag = tr.insertCell(); sag.setAttribute('width', '60%');
      t.replaceWith(kap); sag.appendChild(t);
    }
    else if (!t.getAttribute('width')) { t.setAttribute('width', '100%'); t.style.width = '100%' }
  });
  // Yerleşim hücresindeki kutunun yatay boşluğu (antette tarihin "margin-left:auto"su,
  //   hesaplanmış hâliyle yüzlerce piksel) Word'de sütunu genişletip kurum bilgisini
  //   daraltıyordu. Hizayı hücrenin align'ı taşır.
  kok.querySelectorAll<HTMLElement>('table[data-kap] > tbody > tr > td > *').forEach(el => {
    el.style.removeProperty('margin-left'); el.style.removeProperty('margin-right');
  });
  // Veri tablolarının piksel genişlikleri silinir (Word sayfaya kendisi yayar); yerleşim kapları korunur.
  kok.querySelectorAll<HTMLElement>('th, td').forEach(h => {
    if ((h.closest('table') as HTMLElement | null)?.dataset.kap) return;
    h.style.removeProperty('width'); h.style.removeProperty('max-width');
  });
  kok.style.width = '100%'; kok.style.removeProperty('max-width');
  return kok;
}

/** Word: Office HTML'i .doc olarak açar (A4 dikey sayfa). */
export function wordBelgesi(baslik: string, govde: HTMLElement): string {
  return `<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" `
    + `xmlns="http://www.w3.org/TR/REC-html40"><head><meta charset="utf-8"><title>${kacir(baslik)}</title>`
    + `<style>@page { size:21cm 29.7cm; margin:1.5cm; }</style></head><body>${govde.outerHTML}</body></html>`;
}

function kacir(s: string) { return s.replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]!)) }
