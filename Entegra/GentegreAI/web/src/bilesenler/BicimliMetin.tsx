import { useEffect, useRef, useState } from 'react';
import { c } from '../dil/ceviri';
import { mesaj } from './mesaj';

/**
 * BİÇİMLİ METİN (1195, kullanıcı 27.10.2026: "serbest bölümü formatlı yap.. font punto renk vb").
 * İki parça: tek ARAÇ ÇUBUĞU (font, punto, kalın / italik / altı çizili / üstü çizili, yazı ve vurgu rengi,
 * hizalama, liste, biçimi temizle, geri / ileri) ve onun etkilediği BİÇİMLİ ALAN(lar). Çubuk o an imlecin
 * bulunduğu alanda çalışır - parçalı raporda her bölüm için ayrı çubuk gerekmez. HTML sunucuda beyaz listeyle
 * temizlenir (RaporHtml); düz metin (innerText) ayrıca saklanır.
 * <para>RESİM VE TABLO (kullanıcı 01.11.2026: "rapor kartına resim ve tablo ekleme butonları"): resim dosyadan ya da
 * panodan (Ctrl+V) GÖMÜLÜ eklenir (data: URI - sunucu dış adresi atar); büyük resim 1000 piksele küçültülüp JPEG'e
 * çevrilir. Tablo seçilen boyutta, kenarlıklı açılır; imleç tablodayken satır / sütun ekle-sil. Tıklanan resmin
 * boyutu çubuktan değişir.</para>
 */

export const FONTLAR = ['Trebuchet MS', 'Arial', 'Calibri', 'Times New Roman', 'Georgia', 'Verdana', 'Tahoma', 'Courier New'];
export const PUNTOLAR = [8, 9, 10, 10.5, 11, 12, 13, 14, 16, 18, 20, 24, 28];   // 10,5 = kurum tipografisi varsayılanı (1344)

const kacis = (s: string) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
/** Düz metni biçimli alana: satırlar <br>. */
export const duzdenHtml = (s: string) => kacis(s).replace(/\n/g, '<br>');
/** Biçimli metnin düz hali - sunucudaki RaporHtml.DuzMetin ile aynı kural (hücre sekme, satır / paragraf satır sonu). */
export function htmldenDuz(html: string): string {
  const s = html.replace(/<\/t[dh]>/gi, '\t').replace(/\t*(<br\s*\/?>|<\/(p|div|li|h1|h2|h3|tr)>)/gi, '\n').replace(/<[^>]+>/g, '');
  const d = document.createElement('textarea');
  d.innerHTML = s;
  return d.value.trim();
}
/** HTML'de satır sonu dışında biçim var mı (dönüşümde kaybolacaksa sormak için). */
export const bicimVarMi = (html: string | undefined) => !!html && /<(?!\/?(br|div)\b)[a-z]/i.test(html);

/**
 * SON SEÇİM: font / punto / renk seçim kutusu açılınca odak alandan çıkar ve komut boşa gider - alanın son
 * seçimi saklanır, komuttan önce geri konur.
 */
let sonAralik: Range | null = null;
function secimiSakla() {
  const s = document.getSelection();
  const d = s?.anchorNode;
  if (s && s.rangeCount > 0 && (d instanceof Element ? d : d?.parentElement)?.closest('.bm-alan[contenteditable="true"]'))
    sonAralik = s.getRangeAt(0).cloneRange();
}
function secimiGeriKoy() {
  const s = document.getSelection();
  // Seçim hâlâ bir alanın içindeyse (düğmeye basıldı, odak kaçmadı) o kullanılır - saklanan eski olabilir.
  const simdi = s?.anchorNode;
  if (s && s.rangeCount > 0 && (simdi instanceof Element ? simdi : simdi?.parentElement)?.closest('.bm-alan[contenteditable="true"]')
      && document.activeElement?.closest('.bm-alan')) { secimiSakla(); return }
  const d = sonAralik?.startContainer;
  const host = (d instanceof Element ? d : d?.parentElement)?.closest('.bm-alan[contenteditable="true"]') as HTMLElement | null;
  if (!s || !sonAralik || !host || !document.contains(host)) return;
  if (document.activeElement !== host) host.focus();
  s.removeAllRanges(); s.addRange(sonAralik);
}

const degisti = (alan: Element | null | undefined) => alan?.dispatchEvent(new Event('input', { bubbles: true }));

/** Gömülü resim üst sınırı - sunucu (RaporHtml.ResimAzami) ile aynı. */
const RESIM_AZAMI = 4_000_000;
/** Eklenen resmin en geniş hali (piksel); kâğıt genişliği ~700 px. */
const RESIM_GENISLIK = 1000;

/** Dosyayı data: URI'ye çevirir; geniş ya da ağır resim küçültülüp JPEG olur. */
async function resimHazirla(dosya: File): Promise<{ src: string; gen: number; yuk: number }> {
  if (!/^image\/(png|jpeg|gif|webp)$/.test(dosya.type)) throw new Error(c('Yalnız PNG, JPEG, GIF ya da WEBP resim eklenebilir.'));
  const ham = await new Promise<string>((tamam, red) => {
    const o = new FileReader();
    o.onload = () => tamam(String(o.result)); o.onerror = () => red(o.error); o.readAsDataURL(dosya);
  });
  const img = await new Promise<HTMLImageElement>((tamam, red) => {
    const i = new Image(); i.onload = () => tamam(i); i.onerror = () => red(new Error(c('Resim okunamadı.'))); i.src = ham;
  });
  let gen = img.naturalWidth, yuk = img.naturalHeight, src = ham;
  if (gen > RESIM_GENISLIK || ham.length > 600_000) {
    const oran = Math.min(1, RESIM_GENISLIK / gen);
    gen = Math.round(gen * oran); yuk = Math.round(yuk * oran);
    const tuval = document.createElement('canvas');
    tuval.width = gen; tuval.height = yuk;
    const g = tuval.getContext('2d')!;
    g.fillStyle = '#fff'; g.fillRect(0, 0, gen, yuk);   // JPEG'de saydam alan siyah olmasın
    g.drawImage(img, 0, 0, gen, yuk);
    src = tuval.toDataURL('image/jpeg', 0.85);
  }
  if (src.length > RESIM_AZAMI) throw new Error(c('Resim çok büyük (en çok ~3 MB).'));
  // EKLEMEDE VARSAYILAN (kullanıcı 14.11.2026: "resim çok büyük geldi"): metin sütununun yarısı (340 px); kâğıtta en çok
  //   680 px. Hekim tıklayıp köşeden sürükleyerek ya da "Resim boyutu" ile büyütür / küçültür (oran korunur).
  const gorunen = Math.min(gen, 340);
  return { src, gen: gorunen, yuk: Math.round(yuk * gorunen / gen) };
}

async function resimEkle(dosya: File) {
  try {
    const r = await resimHazirla(dosya);
    komut('insertHTML', `<img src="${r.src}" width="${r.gen}" height="${r.yuk}">`);
  } catch (h) { mesaj(h instanceof Error ? h.message : String(h)) }
}

/** Son tıklanan resim (boyut değiştirmek için). Değişince araç çubuğu RESIM_OLAYI ile haberdar olur. */
let seciliResim: HTMLImageElement | null = null;
const RESIM_OLAYI = 'bm-resim-secildi';
function resimSec(img: HTMLImageElement | null) {
  if (seciliResim === img) return;
  seciliResim?.classList.remove('bm-img-on');
  seciliResim = img;
  img?.classList.add('bm-img-on');
  document.dispatchEvent(new CustomEvent(RESIM_OLAYI));
}
/** Resmin tam genişliği (kâğıtta en çok 680 px) - yüzde bunun üstünden. */
const resimTam = (img: HTMLImageElement) => Math.min(img.naturalWidth || Number(img.getAttribute('width')) || 300, 680);
const resimOran = (img: HTMLImageElement) => img.naturalWidth ? img.naturalHeight / img.naturalWidth
  : (Number(img.getAttribute('height')) || 1) / (Number(img.getAttribute('width')) || 1);
function resimGenislikAta(img: HTMLImageElement, gen: number) {
  const g = Math.max(20, Math.min(680, Math.round(gen)));
  img.setAttribute('width', String(g)); img.setAttribute('height', String(Math.round(g * resimOran(img))));
  img.style.removeProperty('width'); img.style.removeProperty('height');
  degisti(img.closest('.bm-alan'));
  document.dispatchEvent(new CustomEvent(RESIM_OLAYI));
}
/** Seçili resmin şimdiki yüzdesi (araç çubuğundaki kutu bunu gösterir). */
function resimYuzdesi(img: HTMLImageElement | null): number | null {
  if (!img || !document.contains(img)) return null;
  const g = Number(img.getAttribute('width')) || img.width;
  return g ? Math.round(g / resimTam(img) * 100) : null;
}

/**
 * RESİM TUTAMACI (kullanıcı 14.11.2026: "küçültemedim"): tıklanan resmin sağ alt köşesinde sürüklenebilir tutamaç;
 * sürükleyince genişlik değişir, oran korunur, 20-680 px. Tutamaç gövdeye eklenir, resim kaydıkça yeri güncellenir.
 */
function useResimSecimi() {
  const [resim, setResim] = useState<HTMLImageElement | null>(null);
  const [surum, setSurum] = useState(0);
  useEffect(() => {
    const olay = () => { setResim(seciliResim); setSurum(x => x + 1) };
    const tikla = (e: MouseEvent) => {
      const t = e.target as Element | null;
      if (t instanceof HTMLImageElement && t.closest('.bm-alan[contenteditable="true"]')) { resimSec(t); return }
      if (t?.closest?.('.bm-arac, .bm-resim-cerceve')) return;   // araç çubuğu / çerçeve seçimi bozmaz
      resimSec(null);
    };
    document.addEventListener(RESIM_OLAYI, olay);
    document.addEventListener('mousedown', tikla, true);
    return () => { document.removeEventListener(RESIM_OLAYI, olay); document.removeEventListener('mousedown', tikla, true); resimSec(null) };
  }, []);
  // ÇERÇEVE + DÖRT KÖŞE TUTAMACI (kullanıcı 14.11.2026: "bir çerçeve içinde olsa ve köşelerinde fare ile size
  //   ayarlasam"): resmin üstüne sabit konumlu çerçeve, köşelerinden sürükleyince genişlik değişir (oran korunur).
  //   Sol köşeler sola çekilince büyür; alt/üst fark etmez. Bırakınca width/height özniteliğe yazılır.
  useEffect(() => {
    if (!resim) return;
    const cer = document.createElement('div');
    cer.className = 'bm-resim-cerceve';
    const koseler = ['su', 'sa', 'au', 'aa'] as const;   // sol-üst, sağ-üst, alt-sol, alt-sağ
    const tutamaclar = koseler.map(k => { const t = document.createElement('i'); t.className = `bm-resim-tutamac ${k}`; t.title = c('Sürükleyerek boyutlandır'); cer.appendChild(t); return t });
    const bilgi = document.createElement('b'); bilgi.className = 'bm-resim-bilgi'; cer.appendChild(bilgi);
    document.body.appendChild(cer);
    const yerlestir = () => {
      if (!document.contains(resim)) { cer.remove(); resimSec(null); return }
      const r = resim.getBoundingClientRect();
      cer.style.left = `${r.left}px`; cer.style.top = `${r.top}px`; cer.style.width = `${r.width}px`; cer.style.height = `${r.height}px`;
      bilgi.textContent = `${Math.round(r.width)} × ${Math.round(r.height)} px · %${resimYuzdesi(resim) ?? ''}`;
    };
    yerlestir();
    let bas: { x: number; gen: number; yon: 1 | -1 } | null = null;
    const in_ = (yon: 1 | -1) => (e: MouseEvent) => { e.preventDefault(); e.stopPropagation(); bas = { x: e.clientX, gen: resim.getBoundingClientRect().width, yon } };
    const hareket = (e: MouseEvent) => {
      if (!bas) return;
      const g = Math.max(20, Math.min(680, bas.gen + bas.yon * (e.clientX - bas.x)));
      resim.style.width = `${g}px`; resim.style.height = 'auto'; yerlestir();
    };
    const birak = () => { if (!bas) return; bas = null; resimGenislikAta(resim, resim.getBoundingClientRect().width); yerlestir() };
    tutamaclar.forEach((t, i) => t.addEventListener('mousedown', in_(koseler[i].endsWith('a') ? 1 : -1)));
    document.addEventListener('mousemove', hareket); document.addEventListener('mouseup', birak);
    window.addEventListener('scroll', yerlestir, true); window.addEventListener('resize', yerlestir);
    return () => {
      cer.remove(); document.removeEventListener('mousemove', hareket); document.removeEventListener('mouseup', birak);
      window.removeEventListener('scroll', yerlestir, true); window.removeEventListener('resize', yerlestir);
    };
  }, [resim, surum]);
  return { resim, yuzde: resimYuzdesi(resim) };
}

const HUCRE = 'border: 1px solid #000; padding: 4px; vertical-align: top';
function tabloEkle(satir: number, sutun: number) {
  const td = `<td style="${HUCRE}"><br></td>`;
  const govde = Array.from({ length: satir }, () => `<tr>${td.repeat(sutun)}</tr>`).join('');
  komut('insertHTML', `<table style="border-collapse: collapse; width: 100%"><tbody>${govde}</tbody></table><br>`);
}

/** İmlecin bulunduğu hücre (biçimli alanın içinde). */
function etkinHucre(): HTMLTableCellElement | null {
  const d = sonAralik?.startContainer;
  const h = (d instanceof Element ? d : d?.parentElement)?.closest('td, th') as HTMLTableCellElement | null;
  return h && h.closest('.bm-alan[contenteditable="true"]') ? h : null;
}
function tabloIslem(is: 'satir' | 'sutun' | 'satirSil' | 'sutunSil' | 'sil') {
  const h = etkinHucre();
  if (!h) { mesaj(c('Önce imleci tablonun bir hücresine koyun.')); return }
  const alan = h.closest('.bm-alan');
  const tr = h.parentElement as HTMLTableRowElement, tablo = h.closest('table')!;
  const i = h.cellIndex;
  const yeniHucre = () => { const t = document.createElement('td'); t.setAttribute('style', HUCRE); t.innerHTML = '<br>'; return t };
  if (is === 'satir') {
    const y = document.createElement('tr');
    for (let k = 0; k < tr.cells.length; k++) y.appendChild(yeniHucre());
    tr.after(y);
  } else if (is === 'sutun') {
    for (const sr of Array.from(tablo.rows)) {
      const ref = sr.cells[Math.min(i, sr.cells.length - 1)];
      if (ref) ref.after(yeniHucre()); else sr.appendChild(yeniHucre());
    }
  } else if (is === 'satirSil') {
    if (tablo.rows.length <= 1) tablo.remove(); else tr.remove();
  } else if (is === 'sutunSil') {
    if (tr.cells.length <= 1) tablo.remove();
    else for (const sr of Array.from(tablo.rows)) sr.cells[Math.min(i, sr.cells.length - 1)]?.remove();
  } else tablo.remove();
  degisti(alan);
}

/** TABLO MENÜSÜ: boyut seçici (8 x 8) + imleç tablodayken satır / sütun işlemleri. */
function TabloMenusu({ pasif }: { pasif?: boolean }) {
  const [acik, setAcik] = useState(false);
  const [boy, setBoy] = useState<[number, number]>([0, 0]);
  const kutu = useRef<HTMLSpanElement>(null);
  useEffect(() => {
    if (!acik) return;
    const dis = (e: MouseEvent) => { if (kutu.current && !kutu.current.contains(e.target as Node)) setAcik(false) };
    document.addEventListener('mousedown', dis);
    return () => document.removeEventListener('mousedown', dis);
  }, [acik]);
  const islem = (ad: string, is: Parameters<typeof tabloIslem>[0]) => (
    <button type="button" onMouseDown={e => { e.preventDefault(); setAcik(false); tabloIslem(is) }}>{ad}</button>
  );
  return (
    <span className="bm-tablo" ref={kutu}>
      <button type="button" title={c('Tablo ekle / düzenle')} disabled={pasif}
              onMouseDown={e => { e.preventDefault(); setAcik(a => !a); setBoy([0, 0]) }}>▦ {c('Tablo')} ▾</button>
      {acik && (
        <div className="bm-tablo-menu">
          <div className="bm-tablo-izgara" onMouseLeave={() => setBoy([0, 0])}>
            {Array.from({ length: 64 }, (_, k) => {
              const sa = Math.floor(k / 8) + 1, su = (k % 8) + 1;
              return <i key={k} className={sa <= boy[0] && su <= boy[1] ? 'on' : undefined}
                        onMouseEnter={() => setBoy([sa, su])}
                        onMouseDown={e => { e.preventDefault(); setAcik(false); tabloEkle(sa, su) }} />;
            })}
          </div>
          <div className="bm-tablo-boy">{boy[0] ? `${boy[0]} × ${boy[1]}` : c('Boyut seçin')}</div>
          <div className="bm-tablo-ayrac" />
          {islem(c('Alta satır ekle'), 'satir')}
          {islem(c('Sağa sütun ekle'), 'sutun')}
          {islem(c('Satırı sil'), 'satirSil')}
          {islem(c('Sütunu sil'), 'sutunSil')}
          {islem(c('Tabloyu sil'), 'sil')}
        </div>
      )}
    </span>
  );
}

/** Seçili alana komut; alanın input olayı tetiklenir (değişiklik state'e yazılsın). */
function komut(ad: string, deger?: string) {
  secimiGeriKoy();
  document.execCommand('styleWithCSS', false, 'true');
  document.execCommand(ad, false, deger);
}

/** İmlecin bulunduğu (ya da son seçili) biçimli alana düz metin ekler - ör. şablon yer tutucusu. */
export function metinEkle(metin: string) { komut('insertText', metin) }

/** Seçime yeni biçim verilirken içteki aynı özellik temizlenir (yoksa iç span dıştakini ezer). */
function icBicimTemizle(kok: Element, ozellik: 'font-size' | 'font-family') {
  kok.querySelectorAll<HTMLElement>('[style]').forEach(e => {
    e.style.removeProperty(ozellik);
    if (!e.getAttribute('style')?.trim()) e.removeAttribute('style');
  });
  kok.querySelectorAll('font').forEach(f => f.removeAttribute(ozellik === 'font-size' ? 'size' : 'face'));
}

/** Yazı tipi: işaret fontla uygulanır, sonra gerçek font yazılır ve içteki eski font-family temizlenir. */
function fontUygula(font: string) {
  secimiGeriKoy();
  document.execCommand('styleWithCSS', false, 'false');
  document.execCommand('fontName', false, 'gentegre-isaret');
  const alan = (document.getSelection()?.anchorNode?.parentElement)?.closest('[contenteditable="true"]');
  const yeni: HTMLSpanElement[] = [];
  alan?.querySelectorAll('font[face="gentegre-isaret"]').forEach(f => {
    const s = document.createElement('span');
    s.style.fontFamily = font;
    s.innerHTML = f.innerHTML;
    icBicimTemizle(s, 'font-family');
    f.replaceWith(s);
    yeni.push(s);
  });
  if (yeni.length > 0) {
    const r = document.createRange();
    r.setStartBefore(yeni[0]); r.setEndAfter(yeni[yeni.length - 1]);
    const s = document.getSelection(); s?.removeAllRanges(); s?.addRange(r);
    sonAralik = r.cloneRange();
  }
  alan?.dispatchEvent(new Event('input', { bubbles: true }));
}

/** Punto: execCommand yalnız 1-7 bilir - 7 ile işaretlenip span font-size'a çevrilir. */
function puntoUygula(pt: number) {
  secimiGeriKoy();
  document.execCommand('styleWithCSS', false, 'false');
  document.execCommand('fontSize', false, '7');
  const alan = (document.getSelection()?.anchorNode?.parentElement)?.closest('[contenteditable="true"]');
  const yeni: HTMLSpanElement[] = [];
  alan?.querySelectorAll('font[size="7"]').forEach(f => {
    const s = document.createElement('span');
    s.style.fontSize = `${pt}pt`;
    s.innerHTML = f.innerHTML;
    // İÇTEKİ ESKİ PUNTO SİLİNİR (kullanıcı 15.11.2026: "Ctrl+A ile seçip 13 olan puntoyu 10'a düşürdüm ama değişmedi"):
    //   Word şablonundan gelen <span style="font-size: 13pt"> yeni dış span'ın içinde kalıp onu eziyordu.
    icBicimTemizle(s, 'font-size');
    f.replaceWith(s);
    yeni.push(s);
  });
  // Değiştirilen düğümler seçimi düşürür: yeni span'lar yeniden seçilir (ardından renk vb. aynı metne uygulansın).
  if (yeni.length > 0) {
    const r = document.createRange();
    r.setStartBefore(yeni[0]); r.setEndAfter(yeni[yeni.length - 1]);
    const s = document.getSelection(); s?.removeAllRanges(); s?.addRange(r);
    sonAralik = r.cloneRange();
  }
  alan?.dispatchEvent(new Event('input', { bubbles: true }));
}

/**
 * GENİŞ RENK PALETİ (kullanıcı 14.11.2026: "raporda renklendirme çok geniş seçimli olsun"). Tarayıcının küçük renk
 * penceresi yerine Word / Docs düzeni: standart 10 renk, 10 gri ton, 12 ton × 6 açıklık (=92 renk), son kullanılan 8,
 * "Otomatik / Renk yok" ve "Özel renk…" (işletim sisteminin tam seçicisi). Örnek tıklaması seçimi düşürmesin diye
 * onMouseDown + preventDefault; komut sonrası seçim korunur.
 */
const RENK_STANDART = ['#000000', '#980000', '#ff0000', '#ff9900', '#ffff00', '#00ff00', '#00ffff', '#4a86e8', '#0000ff', '#9900ff', '#ff00ff', '#ffffff'];
const RENK_GRI = ['#000000', '#1c1c1c', '#434343', '#666666', '#808080', '#999999', '#b7b7b7', '#cccccc', '#d9d9d9', '#efefef', '#f7f7f7', '#ffffff'];
const RENK_TONLAR = [0, 20, 35, 50, 75, 120, 160, 185, 205, 225, 265, 300];   // kırmızıdan mora 12 ton
const RENK_ACIKLIK = [22, 32, 42, 52, 66, 80, 90];                                // koyudan açığa 7 basamak
function hsl(h: number, s: number, l: number): string {
  const a = s * Math.min(l, 1 - l) / 100;
  const f = (n: number) => { const k = (n + h / 30) % 12; const c = l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1)); return Math.round(255 * c).toString(16).padStart(2, '0') };
  return `#${f(0)}${f(8)}${f(4)}`;
}
const RENK_IZGARA: string[][] = RENK_ACIKLIK.map(l => RENK_TONLAR.map(h => hsl(h, 72, l / 100)));
const SON_RENK_ANAHTAR = 'gentegre.bm.sonRenk';
function sonRenkler(): string[] { try { return JSON.parse(localStorage.getItem(SON_RENK_ANAHTAR) ?? '[]') as string[] } catch { return [] } }
function sonRenkEkle(r: string) {
  const l = [r, ...sonRenkler().filter(x => x !== r)].slice(0, 12);
  try { localStorage.setItem(SON_RENK_ANAHTAR, JSON.stringify(l)) } catch { /* özel pencere */ }
  return l;
}

/**
 * MEVCUT BİÇİM (kullanıcı 14.11.2026: "yazı tipi, punto vb özellikleri üstte seçim kısmında göster.. fareyle
 * tıklandığında"): araç çubuğu Word gibi imlecin bulunduğu metnin fontunu, puntosunu,
 * kalın / italik / çizili durumunu, rengini ve hizasını gösterir. Hesaplanan stilden okunur: şablonun gömülü biçimi,
 * kurum tipografisi (CSS değişkeni) ve hekimin verdiği biçim aynı yoldan görünür.
 */
export interface BicimDurumu {
  font: string; punto: string; kalin: boolean; italik: boolean; alti: boolean; ustu: boolean; renk: string; vurgu: string; hiza: string;
}
const BOS_DURUM: BicimDurumu = { font: '', punto: '', kalin: false, italik: false, alti: false, ustu: false, renk: '', vurgu: '', hiza: '' };
export function bicimDurumu(dugum: Node | null | undefined): BicimDurumu {
  const el = (dugum instanceof Element ? dugum : dugum?.parentElement) ?? null;
  const alan = el?.closest('.bm-alan');
  if (!el || !alan) return BOS_DURUM;
  const cs = getComputedStyle(el);
  const font = cs.fontFamily.split(',')[0].trim().replace(/^["']|["']$/g, '');
  const pt = Math.round(parseFloat(cs.fontSize) * 0.75 * 2) / 2;
  let vurgu = '', alti = false, ustu = false;
  for (let e: Element | null = el; e; e = e.parentElement) {
    const k = getComputedStyle(e);
    if (!vurgu && e !== alan && k.backgroundColor && k.backgroundColor !== 'rgba(0, 0, 0, 0)' && k.backgroundColor !== 'transparent') vurgu = k.backgroundColor;
    if (k.textDecorationLine.includes('underline')) alti = true;
    if (k.textDecorationLine.includes('line-through')) ustu = true;
    if (e === alan) break;
  }
  return {
    font, punto: Number.isFinite(pt) ? String(pt) : '',
    kalin: cs.fontWeight === 'bold' || parseInt(cs.fontWeight, 10) >= 600, italik: cs.fontStyle === 'italic',
    alti, ustu, renk: cs.color, vurgu, hiza: cs.textAlign,
  };
}

/** İmleç yerleştikçe / seçim değiştikçe (fareyle tıklama, ok tuşları) araç çubuğunun gösterdiği biçim. Fare üzerinde
 *  gezinme DEĞİL (kullanıcı 14.11.2026: "fareyle punto tıklandığında göster") - gezinmede çubuk titrerdi. */
function useBicimDurumu(): BicimDurumu {
  const [durum, setDurum] = useState<BicimDurumu>(BOS_DURUM);
  useEffect(() => {
    const yenile = () => {
      const s = document.getSelection();
      const r = s && s.rangeCount > 0 ? s.getRangeAt(0) : sonAralik;
      let d: Node | null = r?.startContainer ?? null;
      // Seçim bir elemanın sınırında başlıyorsa (ör. yeni sarılan span'ın önü) içindeki ilk metne inilir -
      //   çubuk sarmalayıcıyı değil, görünen metnin biçimini göstersin.
      if (d && d.nodeType === Node.ELEMENT_NODE && r) {
        const c = d.childNodes[r.startOffset] ?? d.childNodes[r.startOffset - 1] ?? null;
        if (c) d = c;
        while (d && d.nodeType === Node.ELEMENT_NODE && d.firstChild) d = d.firstChild;
      }
      setDurum(bicimDurumu(d));
    };
    document.addEventListener('selectionchange', yenile);
    document.addEventListener('input', yenile, true);
    yenile();
    return () => { document.removeEventListener('selectionchange', yenile); document.removeEventListener('input', yenile, true) };
  }, []);
  return durum;
}

function RenkSecici({ tur, pasif, mevcut }: { tur: 'yazi' | 'vurgu'; pasif?: boolean; mevcut?: string }) {
  const [acik, setAcik] = useState(false);
  const [son, setSon] = useState<string[]>(() => sonRenkler());
  const [seciliRenk, setSeciliRenk] = useState(tur === 'yazi' ? '#c00000' : '#ffff00');
  const kutu = useRef<HTMLSpanElement>(null);
  const ozel = useRef<HTMLInputElement>(null);
  const komutAdi = tur === 'yazi' ? 'foreColor' : 'hiliteColor';
  useEffect(() => {
    if (!acik) return;
    const dis = (e: MouseEvent) => { if (!kutu.current?.contains(e.target as Node)) setAcik(false) };
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    document.addEventListener('mousedown', dis); document.addEventListener('keydown', tus);
    return () => { document.removeEventListener('mousedown', dis); document.removeEventListener('keydown', tus) };
  }, [acik]);
  const uygula = (renk: string) => {
    komut(komutAdi, renk);
    setSeciliRenk(renk); setSon(sonRenkEkle(renk)); setAcik(false);
  };
  const ornek = (renk: string, k: string) => (
    <button key={k} type="button" className={`bm-renk-ornek${renk === seciliRenk ? ' on' : ''}`} style={{ background: renk }} title={renk}
            onMouseDown={e => { e.preventDefault(); uygula(renk) }} aria-label={renk} />);
  return (
    <span className="bm-renk-kap" ref={kutu}>
      <button type="button" className={`bm-renk${tur === 'vurgu' ? ' vurgu' : ''}`} disabled={pasif}
              title={tur === 'yazi' ? c('Yazı rengi') : c('Vurgu rengi')} aria-haspopup="dialog" aria-expanded={acik}
              onMouseDown={e => { e.preventDefault(); secimiSakla(); setAcik(a => !a) }}>
        {tur === 'yazi' ? 'A' : '▮'}<i className="bm-renk-cizgi" style={{ background: mevcut || seciliRenk }} />
      </button>
      {acik && (
        <div className="bm-renk-menu" role="dialog" aria-label={tur === 'yazi' ? c('Yazı rengi') : c('Vurgu rengi')}>
          <div className="bm-renk-satir">
            <button type="button" className="bm-renk-oto" onMouseDown={e => { e.preventDefault(); uygula(tur === 'yazi' ? 'inherit' : 'transparent') }}>
              {tur === 'yazi' ? c('Otomatik') : c('Vurgu yok')}</button>
            <button type="button" className="bm-renk-oto" onMouseDown={e => { e.preventDefault(); secimiSakla(); ozel.current?.click() }}>{c('Özel renk…')}</button>
            <input ref={ozel} type="color" className="bm-renk-gizli" defaultValue={seciliRenk.startsWith('#') ? seciliRenk : '#c00000'}
                   onChange={e => uygula(e.target.value)} tabIndex={-1} />
          </div>
          <div className="bm-renk-bas">{c('Standart')}</div>
          <div className="bm-renk-izgara">{RENK_STANDART.map((r, i) => ornek(r, 's' + i))}</div>
          <div className="bm-renk-bas">{c('Gri tonları')}</div>
          <div className="bm-renk-izgara">{RENK_GRI.map((r, i) => ornek(r, 'g' + i))}</div>
          <div className="bm-renk-bas">{c('Tonlar (koyudan açığa)')}</div>
          {RENK_IZGARA.map((satir, i) => <div key={i} className="bm-renk-izgara">{satir.map((r, j) => ornek(r, `t${i}-${j}`))}</div>)}
          {son.length > 0 && <>
            <div className="bm-renk-bas">{c('Son kullanılan')}</div>
            <div className="bm-renk-izgara">{son.map((r, i) => ornek(r, 'son' + i))}</div>
          </>}
        </div>
      )}
    </span>
  );
}

export function BicimAracCubugu({ pasif }: { pasif?: boolean }) {
  const durum = useBicimDurumu();
  useResimSecimi();   // seçili resmin çerçevesi + köşe tutamaçları (boyut kutusu kaldırıldı, 14.11.2026)
  // onMouseDown + preventDefault: tıklama seçimi alandan çalmasın. `on`: imleçteki / fare altındaki metinde etkin.
  const d = (baslik: string, icerik: React.ReactNode, f: () => void, on = false) => (
    <button type="button" title={baslik} disabled={pasif} className={on ? 'on' : undefined}
            onMouseDown={e => { e.preventDefault(); f() }}>{icerik}</button>
  );
  const fontDeger = FONTLAR.includes(durum.font) ? durum.font : durum.font ? '__' : '';
  const puntoDeger = PUNTOLAR.includes(Number(durum.punto)) ? durum.punto : durum.punto ? '__' : '';
  const hizaKodu = durum.hiza === 'center' ? 'orta' : durum.hiza === 'right' || durum.hiza === 'end' ? 'sag'
                 : durum.hiza === 'justify' ? 'iki' : durum.hiza ? 'sol' : '';
  return (
    <div className="bm-arac" role="toolbar">
      <select title={c('Yazı tipi')} disabled={pasif} value={fontDeger} className={fontDeger ? 'dolu' : undefined}
              onChange={e => { if (e.target.value && e.target.value !== '__') fontUygula(e.target.value) }}>
        <option value="">{c('Yazı tipi')}</option>
        {fontDeger === '__' && <option value="__">{durum.font}</option>}
        {FONTLAR.map(f => <option key={f} value={f} style={{ fontFamily: f }}>{f}</option>)}
      </select>
      <select title={c('Punto')} disabled={pasif} value={puntoDeger} className={puntoDeger ? 'dolu' : undefined}
              onChange={e => { if (e.target.value && e.target.value !== '__') puntoUygula(Number(e.target.value)) }}>
        <option value="">{c('Punto')}</option>
        {puntoDeger === '__' && <option value="__">{durum.punto.replace('.', ',')}</option>}
        {PUNTOLAR.map(p => <option key={p} value={p}>{String(p).replace('.', ',')}</option>)}
      </select>
      <span className="bm-ayrac" />
      {d(c('Kalın (Ctrl+B)'), <b>B</b>, () => komut('bold'), durum.kalin)}
      {d(c('İtalik (Ctrl+I)'), <i>I</i>, () => komut('italic'), durum.italik)}
      {d(c('Altı çizili (Ctrl+U)'), <u>U</u>, () => komut('underline'), durum.alti)}
      {d(c('Üstü çizili'), <s>S</s>, () => komut('strikeThrough'), durum.ustu)}
      <span className="bm-ayrac" />
      <RenkSecici tur="yazi" pasif={pasif} mevcut={durum.renk} />
      <RenkSecici tur="vurgu" pasif={pasif} mevcut={durum.vurgu} />
      <span className="bm-ayrac" />
      {d(c('Sola hizala'), '⯇', () => komut('justifyLeft'), hizaKodu === 'sol')}
      {d(c('Ortala'), '≡', () => komut('justifyCenter'), hizaKodu === 'orta')}
      {d(c('Sağa hizala'), '⯈', () => komut('justifyRight'), hizaKodu === 'sag')}
      {d(c('İki yana yasla'), '☰', () => komut('justifyFull'), hizaKodu === 'iki')}
      <span className="bm-ayrac" />
      {d(c('Madde işaretli liste'), '•≡', () => komut('insertUnorderedList'))}
      {d(c('Numaralı liste'), '1≡', () => komut('insertOrderedList'))}
      <span className="bm-ayrac" />
      <label className={`bm-dosya${pasif ? ' pasif' : ''}`} title={c('Resim ekle (PNG / JPEG / GIF / WEBP) - panodan Ctrl+V ile de yapıştırılır')}
             onMouseDown={() => secimiSakla()}>🖼 {c('Resim')}
        <input type="file" accept="image/png,image/jpeg,image/gif,image/webp" disabled={pasif}
               onChange={e => { const f = e.target.files?.[0]; e.target.value = ''; if (f) void resimEkle(f) }} />
      </label>
      <TabloMenusu pasif={pasif} />
      <span className="bm-ayrac" />
      {d(c('Biçimi temizle'), '⌫', () => komut('removeFormat'))}
      {d(c('Geri al (Ctrl+Z)'), '↶', () => komut('undo'))}
      {d(c('Yinele (Ctrl+Y)'), '↷', () => komut('redo'))}
    </div>
  );
}

/** Biçimli alan: dışarıdan gelen html yalnız GERÇEKTEN farklıysa yazılır (imleç zıplamasın). */
export function BicimliAlan({ html, onDegis, salt, className, onFocus }: {
  html: string;
  onDegis(html: string, duz: string): void;
  salt?: boolean;
  className?: string;
  onFocus?(): void;
}) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (ref.current && ref.current.innerHTML !== html) ref.current.innerHTML = html;
  }, [html]);
  return (
    <div ref={ref} className={`bm-alan${className ? ` ${className}` : ''}`} contentEditable={!salt}
         suppressContentEditableWarning spellCheck lang="tr" onFocus={onFocus}
         onKeyUp={secimiSakla} onMouseUp={secimiSakla} onBlur={secimiSakla}
         onClick={e => { if (e.target instanceof HTMLImageElement) resimSec(e.target) }}
         // PANODAN RESİM: tarayıcı kendiliğinden ya dış adresli <img> ya da hiçbir şey koyar - dosya gömülü eklenir.
         onPaste={e => {
           const f = Array.from(e.clipboardData.files).find(x => x.type.startsWith('image/'));
           if (!f || salt) return;
           e.preventDefault(); secimiSakla(); void resimEkle(f);
         }}
         onInput={e => onDegis(e.currentTarget.innerHTML, e.currentTarget.innerText.replace(/\n{3,}/g, '\n\n').trim())} />
  );
}
