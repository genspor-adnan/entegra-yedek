import { useEffect, useRef } from 'react';
import { c } from '../dil/ceviri';

/**
 * BİÇİMLİ METİN (1195, kullanıcı 27.10.2026: "serbest bölümü formatlı yap.. font punto renk vb").
 * İki parça: tek ARAÇ ÇUBUĞU (font, punto, kalın / italik / altı çizili / üstü çizili, yazı ve vurgu rengi,
 * hizalama, liste, biçimi temizle, geri / ileri) ve onun etkilediği BİÇİMLİ ALAN(lar). Çubuk o an imlecin
 * bulunduğu alanda çalışır - parçalı raporda her bölüm için ayrı çubuk gerekmez. HTML sunucuda beyaz listeyle
 * temizlenir (RaporHtml); düz metin (innerText) ayrıca saklanır.
 */

export const FONTLAR = ['Trebuchet MS', 'Arial', 'Calibri', 'Times New Roman', 'Georgia', 'Verdana', 'Tahoma', 'Courier New'];
export const PUNTOLAR = [8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 24, 28];

const kacis = (s: string) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
/** Düz metni biçimli alana: satırlar <br>. */
export const duzdenHtml = (s: string) => kacis(s).replace(/\n/g, '<br>');
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

/** Seçili alana komut; alanın input olayı tetiklenir (değişiklik state'e yazılsın). */
function komut(ad: string, deger?: string) {
  secimiGeriKoy();
  document.execCommand('styleWithCSS', false, 'true');
  document.execCommand(ad, false, deger);
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
         onInput={e => onDegis(e.currentTarget.innerHTML, e.currentTarget.innerText.replace(/\n{3,}/g, '\n\n').trim())} />
  );
}
