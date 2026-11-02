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
export const PUNTOLAR = [8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 24, 28];

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
  // Kâğıtta en çok 680 px genişlikte görünür (oran korunur).
  const gorunen = Math.min(gen, 680);
  return { src, gen: gorunen, yuk: Math.round(yuk * gorunen / gen) };
}

async function resimEkle(dosya: File) {
  try {
    const r = await resimHazirla(dosya);
    komut('insertHTML', `<img src="${r.src}" width="${r.gen}" height="${r.yuk}">`);
  } catch (h) { mesaj(h instanceof Error ? h.message : String(h)) }
}

/** Son tıklanan resim (boyut değiştirmek için). */
let seciliResim: HTMLImageElement | null = null;
function resimBoyutu(yuzde: number) {
  const img = seciliResim;
  if (!img || !document.contains(img)) { mesaj(c('Önce metindeki resme tıklayın.')); return }
  const dogal = img.naturalWidth || Number(img.getAttribute('width')) || 300;
  const gen = Math.max(20, Math.min(680, Math.round(Math.min(dogal, 680) * yuzde / 100)));
  const oran = img.naturalWidth ? img.naturalHeight / img.naturalWidth
    : (Number(img.getAttribute('height')) || 1) / (Number(img.getAttribute('width')) || 1);
  img.setAttribute('width', String(gen)); img.setAttribute('height', String(Math.round(gen * oran)));
  degisti(img.closest('.bm-alan'));
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

export function BicimAracCubugu({ pasif }: { pasif?: boolean }) {
  // onMouseDown + preventDefault: tıklama seçimi alandan çalmasın.
  const d = (baslik: string, icerik: React.ReactNode, f: () => void) => (
    <button type="button" title={baslik} disabled={pasif} onMouseDown={e => { e.preventDefault(); f() }}>{icerik}</button>
  );
  return (
    <div className="bm-arac" role="toolbar">
      <select title={c('Yazı tipi')} disabled={pasif} defaultValue=""
              onChange={e => { if (e.target.value) komut('fontName', e.target.value); e.target.value = '' }}>
        <option value="">{c('Yazı tipi')}</option>
        {FONTLAR.map(f => <option key={f} value={f} style={{ fontFamily: f }}>{f}</option>)}
      </select>
      <select title={c('Punto')} disabled={pasif} defaultValue=""
              onChange={e => { if (e.target.value) puntoUygula(Number(e.target.value)); e.target.value = '' }}>
        <option value="">{c('Punto')}</option>
        {PUNTOLAR.map(p => <option key={p} value={p}>{p}</option>)}
      </select>
      <span className="bm-ayrac" />
      {d(c('Kalın (Ctrl+B)'), <b>B</b>, () => komut('bold'))}
      {d(c('İtalik (Ctrl+I)'), <i>I</i>, () => komut('italic'))}
      {d(c('Altı çizili (Ctrl+U)'), <u>U</u>, () => komut('underline'))}
      {d(c('Üstü çizili'), <s>S</s>, () => komut('strikeThrough'))}
      <span className="bm-ayrac" />
      <label className="bm-renk" title={c('Yazı rengi')}>A
        <input type="color" disabled={pasif} defaultValue="#c00000" onChange={e => komut('foreColor', e.target.value)} /></label>
      <label className="bm-renk vurgu" title={c('Vurgu rengi')}>▮
        <input type="color" disabled={pasif} defaultValue="#ffff00" onChange={e => komut('hiliteColor', e.target.value)} /></label>
      <span className="bm-ayrac" />
      {d(c('Sola hizala'), '⯇', () => komut('justifyLeft'))}
      {d(c('Ortala'), '≡', () => komut('justifyCenter'))}
      {d(c('Sağa hizala'), '⯈', () => komut('justifyRight'))}
      {d(c('İki yana yasla'), '☰', () => komut('justifyFull'))}
      <span className="bm-ayrac" />
      {d(c('Madde işaretli liste'), '•≡', () => komut('insertUnorderedList'))}
      {d(c('Numaralı liste'), '1≡', () => komut('insertOrderedList'))}
      <span className="bm-ayrac" />
      <label className={`bm-dosya${pasif ? ' pasif' : ''}`} title={c('Resim ekle (PNG / JPEG / GIF / WEBP) - panodan Ctrl+V ile de yapıştırılır')}
             onMouseDown={() => secimiSakla()}>🖼 {c('Resim')}
        <input type="file" accept="image/png,image/jpeg,image/gif,image/webp" disabled={pasif}
               onChange={e => { const f = e.target.files?.[0]; e.target.value = ''; if (f) void resimEkle(f) }} />
      </label>
      <select title={c('Tıklanan resmin boyutu')} disabled={pasif} defaultValue=""
              onChange={e => { if (e.target.value) resimBoyutu(Number(e.target.value)); e.target.value = '' }}>
        <option value="">{c('Resim boyutu')}</option>
        {[25, 50, 75, 100].map(y => <option key={y} value={y}>%{y}</option>)}
      </select>
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
         onClick={e => { if (e.target instanceof HTMLImageElement) seciliResim = e.target }}
         // PANODAN RESİM: tarayıcı kendiliğinden ya dış adresli <img> ya da hiçbir şey koyar - dosya gömülü eklenir.
         onPaste={e => {
           const f = Array.from(e.clipboardData.files).find(x => x.type.startsWith('image/'));
           if (!f || salt) return;
           e.preventDefault(); secimiSakla(); void resimEkle(f);
         }}
         onInput={e => onDegis(e.currentTarget.innerHTML, e.currentTarget.innerText.replace(/\n{3,}/g, '\n\n').trim())} />
  );
}
