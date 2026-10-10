import { useEffect, useRef, useState, type ReactNode } from 'react';
import { api } from '../../api/istemci';
import { dosyaAdiTemiz, dosyaIndir } from '../indir';
import { guvenli, mesaj } from '../mesaj';
import { belgeTablolari, htmlBelgesi, stilGomuluKopya, wordBelgesi } from './ciktiDonustur';

/**
 * ÇIKTI MENÜSÜ (kullanıcı 10.10.2026, İskonto İcmali'nde test - "olursa tüm
 * icmallerde uygularız"): yazdır düğmesinin yerine ekranın adını taşıyan
 * açılır menü.
 *
 *     🔍 Baskı Önizleme
 *     🖨️ Yazıcıya Yazdır
 *     ───────────────
 *     📤 Gönder ▸   📕 PDF · 📘 Word · 📗 Excel · 🌐 HTML
 *
 * (JPEG, Text, CSV ve E-Posta da tasarlanmıştı; kullanıcı istemedi.)
 *
 * A4 belgesi (children) BU BİLEŞENDE yaşar: ekranda gizli, yazdırırken ve
 * Baskı Önizleme'de görünür - ayrı "Önizleme" sekmesi gerekmez. Bütün
 * biçimler aynı belgeden üretilir (ciktiDonustur) - kâğıt ile dosya ayrışmaz.
 */
type Bicim = 'pdf' | 'word' | 'excel' | 'html';

/**
 * Dosya türü simgesi (kullanıcı: "pdf word excel ikonları değiştir"): emoji
 * kitap yerine tanınan dosya simgesi - köşesi kıvrık sayfa + renkli etiket
 * (PDF kırmızı, Word mavi W, Excel yeşil X, HTML turuncu </>).
 */
function DosyaIkonu({ renk, yazi }: { renk: string; yazi: string }) {
  return (
    <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
      <path d="M6 2.5h8.5L19 7v14.5H6z" fill="#fff" stroke="#9aa7b4" strokeWidth="1" strokeLinejoin="round" />
      <path d="M14.5 2.5V7H19" fill="#e8edf2" stroke="#9aa7b4" strokeWidth="1" strokeLinejoin="round" />
      <rect x="2.5" y="10" width={yazi.length > 1 ? 15 : 11} height="9" rx="1.6" fill={renk} />
      <text x={yazi.length > 1 ? 10 : 8} y="17" textAnchor="middle" fontSize={yazi.length > 2 ? 5.6 : 7.5}
            fontWeight="700" fontFamily="Arial, sans-serif" fill="#fff">{yazi}</text>
    </svg>
  );
}

const GONDER: { bicim: Bicim; ik: ReactNode; ad: string }[] = [
  { bicim: 'pdf', ik: <DosyaIkonu renk="#d93025" yazi="PDF" />, ad: 'PDF' },
  { bicim: 'word', ik: <DosyaIkonu renk="#2b579a" yazi="W" />, ad: 'Word' },
  { bicim: 'excel', ik: <DosyaIkonu renk="#1e7145" yazi="X" />, ad: 'Excel' },
  { bicim: 'html', ik: <DosyaIkonu renk="#e8710a" yazi="</>" />, ad: 'HTML' },
];

export function CiktiMenusu({ etiket, dosyaAdi, devre, children }: {
  /** Düğmede görünen ad (ekranın adı). */
  etiket: string;
  /** Uzantısız dosya adı (or. "İskonto İcmali 2026-09"). */
  dosyaAdi: string;
  /** Belge hazır değilse (veri yükleniyor) menü kapalı. */
  devre?: boolean;
  /** A4 belgesi. */
  children: ReactNode;
}) {
  const [acik, setAcik] = useState(false);
  const [altAcik, setAltAcik] = useState(false);
  const [onizleme, setOnizleme] = useState(false);
  const [mesgul, setMesgul] = useState('');
  const kutu = useRef<HTMLDivElement>(null);
  const belge = useRef<HTMLDivElement>(null);
  const ad = dosyaAdiTemiz(dosyaAdi) || 'Icmal';

  useEffect(() => {
    if (!acik && !onizleme) return;
    const dis = (e: MouseEvent) => { if (acik && kutu.current && !kutu.current.contains(e.target as Node)) { setAcik(false); setAltAcik(false) } };
    const tus = (e: KeyboardEvent) => {
      if (e.key === 'Escape') { setAcik(false); setAltAcik(false); setOnizleme(false) }
      if (e.key === 'ArrowRight' && acik) setAltAcik(true);
      if (e.key === 'ArrowLeft' && acik) setAltAcik(false);
    };
    document.addEventListener('mousedown', dis); document.addEventListener('keydown', tus);
    return () => { document.removeEventListener('mousedown', dis); document.removeEventListener('keydown', tus) };
  }, [acik, onizleme]);

  const kapat = () => { setAcik(false); setAltAcik(false) };
  const a4 = () => belge.current?.querySelector<HTMLElement>('.hi-a4') ?? belge.current!;

  /** Ölçüm / kopya için belge kısa süre ekran dışında görünür olur. */
  async function gorunurken<T>(is: (el: HTMLElement) => Promise<T>): Promise<T> {
    const kap = belge.current!;
    const onceki = kap.classList.contains('cm-acik');
    if (!onceki) kap.classList.add('cm-olcum');
    try { return await is(a4()) } finally { if (!onceki) kap.classList.remove('cm-olcum') }
  }

  /** Bir biçimi dosya (Blob) olarak üretir. */
  async function uret(bicim: Bicim): Promise<{ blob: Blob; dosya: string; tip: string }> {
    switch (bicim) {
      case 'excel': {
        // Görünürken oku: gizli öğede innerText satır sonlarını (<br>) kaybeder.
        const v = await gorunurken(async el => belgeTablolari(el));
        const blob = await api.disaAktarExcel({ dosyaAdi: ad, sayfaAdi: etiket, satirlar: v.satirlar, kalinSatirlar: v.kalin });
        return { blob, dosya: `${ad}.xlsx`, tip: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' };
      }
      case 'html': case 'word': {
        const kopya = await gorunurken(el => stilGomuluKopya(el));
        const tip = bicim === 'html' ? 'text/html;charset=utf-8' : 'application/msword';
        const metin = bicim === 'html' ? htmlBelgesi(ad, kopya) : wordBelgesi(ad, kopya);
        return { blob: new Blob(['﻿' + metin], { type: tip }), dosya: `${ad}.${bicim === 'html' ? 'html' : 'doc'}`, tip };
      }
      default: throw new Error(bicim);
    }
  }

  function yazdir(pdf = false) {
    kapat();
    // Yazdırma penceresi dosya adını sekme başlığından önerir - PDF kaydında ad doğru gelsin.
    const eski = document.title;
    document.title = ad;
    if (pdf) mesaj('Yazdırma penceresinde Hedef olarak "PDF olarak kaydet"i seçin; dosya adı hazır gelir.');
    setTimeout(() => { window.print(); document.title = eski }, pdf ? 400 : 0);
  }

  const gonder = (bicim: Bicim) => {
    kapat();
    if (bicim === 'pdf') { yazdir(true); return }
    void guvenli(async () => {
      setMesgul(bicim);
      try { const { blob, dosya } = await uret(bicim); dosyaIndir(blob, dosya) } finally { setMesgul('') }
    });
  };

  return (
    <span className="cm" ref={kutu}>
      <style>{CM_STILI}</style>
      <button type="button" className="hi-ana cm-dugme" disabled={devre || !!mesgul} aria-haspopup="menu" aria-expanded={acik}
              onClick={() => { setAcik(a => !a); setAltAcik(false) }}>
        🖨️ {etiket}{mesgul ? ' · hazırlanıyor…' : ''} <span className="cm-ok">▾</span>
      </button>
      {acik && (
        <div className="cm-menu" role="menu">
          <button type="button" role="menuitem" onClick={() => { kapat(); setOnizleme(true) }}>
            <span className="cm-ik">🔍</span>Baskı Önizleme</button>
          <button type="button" role="menuitem" onClick={() => yazdir()}>
            <span className="cm-ik">🖨️</span>Yazıcıya Yazdır</button>
          <div className="cm-ayrac" />
          <div className="cm-alt-kap" onMouseEnter={() => setAltAcik(true)} onMouseLeave={() => setAltAcik(false)}>
            <button type="button" role="menuitem" aria-haspopup="menu" aria-expanded={altAcik} onClick={() => setAltAcik(a => !a)}>
              <span className="cm-ik">📤</span>Gönder<span className="cm-sag">▸</span></button>
            {altAcik && (
              <div className="cm-menu cm-alt" role="menu">
                {GONDER.map(g => (
                  <button key={g.bicim} type="button" role="menuitem" onClick={() => gonder(g.bicim)}>
                    <span className="cm-ik">{g.ik}</span>{g.ad}</button>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {onizleme && <div className="cm-perde" onClick={() => setOnizleme(false)} />}
      {onizleme && (
        <div className="cm-onizleme-bar">
          <b>Baskı Önizleme</b> <span className="cm-soluk">{etiket}</span>
          <span className="cm-bosluk" />
          <button type="button" className="hi-ana" onClick={() => yazdir()}>🖨️ Yazıcıya Yazdır</button>
          <button type="button" onClick={() => setOnizleme(false)}>✕ Kapat</button>
        </div>
      )}
      <div ref={belge} className={'hi-onizleme cm-belge' + (onizleme ? ' cm-acik' : ' gizli')}>{children}</div>
    </span>
  );
}

const CM_STILI = `
.cm { position:relative; display:inline-block; }
.cm-ok { font-size:10px; margin-left:4px; }
.cm-menu { position:absolute; top:100%; left:0; margin-top:3px; min-width:200px; z-index:60; background:var(--yuz,#fff);
  border:1px solid var(--cizgi,#cdd6e0); border-radius:6px; box-shadow:0 8px 24px rgba(20,40,70,.18); padding:4px; }
.cm-menu button { display:flex; align-items:center; gap:8px; width:100%; border:0; background:transparent; text-align:left;
  padding:6px 10px; border-radius:4px; font-size:12.5px; cursor:pointer; color:var(--yazi,#1d2b3a); white-space:nowrap; }
.cm-menu button:hover, .cm-menu button[aria-expanded="true"] { background:var(--mor2,#eef4fc); color:var(--mor,#2f6db3); }
.cm-ik { width:20px; text-align:center; font-size:14px; flex:none; display:inline-flex; justify-content:center; }
.cm-sag { margin-left:auto; padding-left:16px; font-size:11px; }
.cm-ayrac { height:1px; background:var(--cizgi,#dde3ea); margin:4px 6px; }
.cm-alt-kap { position:relative; }
.cm-menu.cm-alt { top:-5px; left:100%; margin:0 0 0 2px; min-width:160px; }
.cm-perde { position:fixed; inset:0; background:rgba(15,25,40,.45); z-index:70; }
.cm-onizleme-bar { position:fixed; left:50%; transform:translateX(-50%); top:14px; width:min(794px, calc(100vw - 32px)); z-index:72;
  display:flex; align-items:center; gap:8px; background:var(--yuz,#fff); border-radius:6px; padding:6px 10px; box-shadow:0 4px 16px rgba(0,0,0,.2); }
.cm-bosluk { flex:1; }
.cm-soluk { color:var(--soluk,#6b7a8b); font-size:11.5px; }
.hi-onizleme.cm-belge.cm-acik { position:fixed; left:50%; transform:translateX(-50%); top:62px; bottom:14px; margin:0;
  width:min(794px, calc(100vw - 32px)); max-width:none; overflow:auto; z-index:71; }
.hi-onizleme.cm-belge.gizli.cm-olcum { display:block; position:fixed; left:-10000px; top:0; width:794px; max-width:none; }
@media print { .cm-onizleme-bar, .cm-perde, .cm-menu { display:none !important; }
  .hi-onizleme.cm-belge.cm-acik { position:static; transform:none; overflow:visible; } }
`;
