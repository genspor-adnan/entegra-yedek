import { useEffect, useLayoutEffect, useRef } from 'react';
import { makroKullanildi, type Makro } from './muayeneMakro';
import { c } from '../dil/ceviri';
import { SesDugmesi } from './SesDugmesi';

/**
 * MAKROLU METİN KUTUSU (kullanıcı 14.10.2026: "metin makrosu edite rozet içinde gelse ve sağında
 * x olsa, basınca silinse ama içine de ekleme yapabilsem · özet veya print ederken rozet görünmese").
 *
 * Muayenenin makro alanlarında (şikâyet, hikâye, bulgular, değerlendirme) textarea yerine
 * içerik düzenlenebilir kutu: makro (kısayol + boşluk / Tab ya da ipucu çipi) ROZET olarak girer,
 * rozetin içine yazılabilir, sağındaki × rozeti siler.
 *
 * DEĞER DÜZ METİNDİR: alan her değişiklikte kutunun metnine çevrilip yazılır - özette, çıktıda
 * ve veritabanında rozet yoktur. Rozet bu düzenleme oturumuna aittir; kayıt yeniden açılınca
 * metin düz görünür (dışarıdan gelen değişiklik - dikte, kopyala - kutuyu düz metne çevirir).
 */
export const MAKRO_EKLE_OLAYI = 'gentegre-makro-ekle';

/** Kutunun DOM'unu düz metne çevirir: rozetin × işareti metne girmez. */
function metneCevir(kok: HTMLElement): string {
  let s = '';
  const gez = (n: Node) => {
    if (n.nodeType === Node.TEXT_NODE) { s += n.textContent ?? ''; return }
    if (!(n instanceof HTMLElement)) return;
    if (n.dataset.mlx === '1') return;
    if (n.tagName === 'BR') { s += '\n'; return }
    const blok = n !== kok && (n.tagName === 'DIV' || n.tagName === 'P');
    if (blok && s && !s.endsWith('\n')) s += '\n';
    n.childNodes.forEach(gez);
  };
  gez(kok);
  return s;
}

/** Rozet düğümü: düzenlenebilir metin + düzenlenemez × düğmesi. */
function rozetYap(metin: string, onSil: (r: HTMLElement) => void): { rozet: HTMLElement; metinDugumu: Text } {
  const rozet = document.createElement('span');
  rozet.className = 'mlm-rozet';
  const t = document.createTextNode(metin);
  rozet.appendChild(t);
  const x = document.createElement('span');
  x.className = 'mlm-x';
  x.dataset.mlx = '1';
  x.contentEditable = 'false';
  x.textContent = '×';
  x.title = c('Makroyu kaldır');
  x.addEventListener('mousedown', e => { e.preventDefault(); e.stopPropagation(); onSil(rozet) });
  rozet.appendChild(x);
  return { rozet, metinDugumu: t };
}

function imleciKoy(dugum: Node, ofset: number) {
  const sec = window.getSelection();
  if (!sec) return;
  const r = document.createRange();
  r.setStart(dugum, Math.min(ofset, dugum.textContent?.length ?? 0));
  r.collapse(true);
  sec.removeAllRanges(); sec.addRange(r);
}

export function MakroluMetin({ alan, deger, yaz, makrolar, salt, ses }: {
  alan: string;
  deger: string;
  yaz(v: string): void;
  makrolar: readonly Makro[];
  salt?: boolean;
  /** MİKROFON (kullanıcı 19.10.2026: "muayenede şikâyet ve hikâyede mikrofon"): kutunun içinde sağda;
      söylenen mevcut metnin SONUNA eklenir (sürekli dikte, yeniden basınca durur). */
  ses?: boolean;
}) {
  /** Dikte başladığında kutudaki metin - söylenen bunun ardına eklenir. */
  const dikteTabani = useRef<string | null>(null);
  const kok = useRef<HTMLDivElement | null>(null);
  /** Son yazdığımız değer: dışarıdan gelen değişikliği kendi yazdığımızdan ayırmak için. */
  const sonYazilan = useRef<string | null>(null);

  // DIŞARIDAN DEĞER (yükleme, dikte, kopyala): kutu düz metinle yeniden kurulur.
  useLayoutEffect(() => {
    const k = kok.current;
    if (!k) return;
    if (deger === sonYazilan.current && metneCevir(k) === deger) return;
    if (metneCevir(k) !== deger) k.textContent = deger;
    sonYazilan.current = deger;
  }, [deger]);

  const bildir = () => {
    const k = kok.current;
    if (!k) return;
    const v = metneCevir(k);
    sonYazilan.current = v;
    yaz(v);
  };

  const rozetSil = (r: HTMLElement) => { r.remove(); bildir(); kok.current?.focus() };

  /** Makroyu imlecin yerine (ya da verilen aralığa) ROZET olarak koyar; {|} imlecin yeri. */
  const makroKoy = (m: Makro, aralik?: Range) => {
    const k = kok.current;
    if (!k) return;
    const sec = window.getSelection();
    let r = aralik ?? (sec && sec.rangeCount && k.contains(sec.anchorNode) ? sec.getRangeAt(0) : null);
    if (!r) { r = document.createRange(); r.selectNodeContents(k); r.collapse(false) }
    r.deleteContents();
    const i = m.metin.indexOf('{|}');
    const govde = m.metin.replace('{|}', '');
    const { rozet, metinDugumu } = rozetYap(govde, rozetSil);
    r.insertNode(rozet);
    // Rozetten sonra bir boşluk: yazmaya rozetin dışında devam edilebilsin.
    const bosluk = document.createTextNode(' ');
    rozet.after(bosluk);
    if (i >= 0) imleciKoy(metinDugumu, i); else imleciKoy(bosluk, 1);
    makroKullanildi(m);
    bildir();
  };

  // İPUCU ÇİPİ (MakroIpucu) bu kutuya olayla ekler.
  useEffect(() => {
    const k = kok.current;
    if (!k) return;
    const dinle = (e: Event) => { k.focus(); makroKoy((e as CustomEvent<Makro>).detail) };
    k.addEventListener(MAKRO_EKLE_OLAYI, dinle);
    return () => k.removeEventListener(MAKRO_EKLE_OLAYI, dinle);
  });

  const tus = (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (e.key === 'Enter') { e.preventDefault(); document.execCommand('insertText', false, '\n'); return }
    if ((e.key !== ' ' && e.key !== 'Tab') || e.ctrlKey || e.altKey || e.metaKey) return;
    const sec = window.getSelection();
    if (!sec || !sec.isCollapsed || !sec.anchorNode || sec.anchorNode.nodeType !== Node.TEXT_NODE) return;
    const dugum = sec.anchorNode as Text;
    // Rozetin içindeyken kısayol açılmaz (rozet metnine yazılıyor).
    if ((dugum.parentElement as HTMLElement | null)?.classList.contains('mlm-rozet')) return;
    const once = (dugum.textContent ?? '').slice(0, sec.anchorOffset);
    const eslesme = /(\S+)$/.exec(once);
    if (!eslesme) return;
    const kisayol = eslesme[1];
    const m = makrolar.find(x => x.kisayol === kisayol && x.alan === alan)
      ?? makrolar.find(x => x.kisayol === kisayol && x.alan === '');
    if (!m) return;
    e.preventDefault();
    const r = document.createRange();
    r.setStart(dugum, sec.anchorOffset - kisayol.length);
    r.setEnd(dugum, sec.anchorOffset);
    makroKoy(m, r);
  };

  const kutu = (
    <div ref={kok} className={`mlm${salt ? ' salt' : ''}`} data-alan={alan}
         contentEditable={!salt} suppressContentEditableWarning role="textbox" aria-multiline="true"
         // ETİKET ETKİNLEŞMESİ YOK: kutu <label> içinde ve form girdisi değil - tık etiketin
         //   ilk düğmesine (makro çipi) gidip makro ekliyordu. İmleç mousedown'da konur.
         onClick={e => e.preventDefault()}
         onInput={bildir} onKeyDown={tus}
         onPaste={e => { e.preventDefault(); document.execCommand('insertText', false, e.clipboardData.getData('text/plain')) }} />
  );
  if (!ses || salt) return kutu;
  return (
    <div className="mlm-ses">
      {kutu}
      <SesDugmesi surekli baslik="Konuşarak yaz (söylenen sona eklenir)"
                  // Her yeni dikte o anki metinden başlar (önceki diktenin üstüne yazmaz).
                  onBasla={() => { dikteTabani.current = kok.current ? metneCevir(kok.current) : deger }}
                  onMetin={metin => {
                    if (dikteTabani.current === null) dikteTabani.current = deger;
                    const taban = dikteTabani.current.replace(/\s+$/, '');
                    yaz(taban ? `${taban} ${metin}` : metin);
                  }} />
    </div>
  );
}
