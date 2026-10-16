import { useEffect, type ReactNode } from 'react';
import { c } from '../dil/ceviri';

/**
 * GÖSTERİM / DÜZENLEME ÇERÇEVESİ (kullanıcı 15.10.2026, muayene: "tanı, istem ve reçete için de
 * aynı deseni yap"). Başlıkta ✎ düzenlemeye geçer; düzenlemede 💾 kaydeder (kart KAPANMAZ) ve
 * gösterime döner. Gösterim mockup v7'deki sade satırlardır; düzenleme ekranın kendi grid/düğmeleri.
 *
 * Kip durumunu çağıran tutar (kart açılınca dolu bölüm gösterimde, boş bölüm düzenlemede açılır).
 */
export function KipCercevesi({ baslik, duzen, onDuzen, onKaydet, gosterim, children, ek }: {
  baslik: string;
  duzen: boolean;
  onDuzen(duzen: boolean): void;
  /** 💾: kartı kapatmadan kaydet. */
  onKaydet?(): void;
  gosterim: ReactNode;
  children: ReactNode;
  /** Başlığın sağına (her iki kipte) ek bilgi, ör. "3/5 sonuç". */
  ek?: ReactNode;
}) {
  return (
    <div className="kasira"><div className={`kagrup${duzen ? '' : ' katlanir-kapali'}`}>
      <h6 className="katlanir-bas" onClick={() => { if (duzen) onKaydet?.(); onDuzen(!duzen) }}>
        {c(baslik)}
        <span className="katlanir-sag" title={duzen ? c('Kaydet ve gösterime dön') : c('Düzenle')}>
          {duzen ? '💾' : '✎'}</span>
        {ek}
      </h6>
      {duzen ? <div className="fm-duzen">{children}</div> : gosterim}
    </div></div>
  );
}

/** Başlığın kendi adı (ilk metin düğümü) - sayaç / ikon gibi ekler değişse de aynı kalır. */
const baslikAdi = (h: Element) => (h.firstChild?.textContent ?? '').trim();

/** En yakın kaydırılabilir üst (yoksa sayfanın kendisi). */
function kaydiran(el: Element): HTMLElement {
  for (let p = el.parentElement; p; p = p.parentElement) {
    const oy = getComputedStyle(p).overflowY;
    if ((oy === 'auto' || oy === 'scroll') && p.scrollHeight > p.clientHeight) return p;
  }
  return (document.scrollingElement as HTMLElement) ?? document.documentElement;
}

/**
 * 💾 SONRASI KONUM KORUNUR (kullanıcı 16.10.2026: "orta kısımda edit olan bölümde save bastığımda konum
 * kaybolabiliyor, aynı konuma tekrar gelsin"). Kayıt kartı yeniden okur, çerçeve gösterime döner ve
 * yükseklik değişir; sayfa kayar. Başlığın ekrandaki yeri not edilir, ~2 sn boyunca (kayıt + yeniden
 * çizim) başlık aynı yerde tutulur. Kullanıcı kendisi kaydırırsa bırakılır.
 */
export function konumuKoru(baslik: Element) {
  // Kart yeniden kurulunca kaydırma kutusu da yeni öğe olabilir - her adımda başlıktan bulunur.
  let kap = kaydiran(baslik);
  const ad = baslikAdi(baslik);
  const ilk = baslik.getBoundingClientRect().top;
  const bitis = performance.now() + 2000;
  let birak = false;
  const kullanici = () => { birak = true };
  const olaylar = ['wheel', 'touchstart', 'keydown', 'mousedown'] as const;
  for (const o of olaylar) window.addEventListener(o, kullanici, { once: true, capture: true });
  const adim = () => {
    if (birak || performance.now() > bitis) { for (const o of olaylar) window.removeEventListener(o, kullanici, true); return }
    // Kart yeniden kurulduysa başlık yeni öğedir - adıyla bulunur.
    const el = baslik.isConnected ? baslik
      : [...document.querySelectorAll('.es-govde:not([hidden]) h6.katlanir-bas, h6.katlanir-bas')]
          .find(h => baslikAdi(h) === ad && (h as HTMLElement).offsetParent !== null);
    if (el) {
      if (!kap.isConnected || !kap.contains(el)) kap = kaydiran(el);
      const fark = el.getBoundingClientRect().top - ilk;
      if (Math.abs(fark) > 1) kap.scrollTop += fark;
    }
    requestAnimationFrame(adim);
  };
  requestAnimationFrame(adim);
}

/** Kapsayıcıdaki çerçeve başlıklarında 💾 tıklaması konumu korusun (muayene kartı). */
export function useKaydetKonumu(aktif: boolean) {
  useEffect(() => {
    if (!aktif) return;
    const f = (e: MouseEvent) => {
      const h = (e.target as Element | null)?.closest?.('h6.katlanir-bas');
      if (h && (h.textContent ?? '').includes('💾')) konumuKoru(h);
    };
    document.addEventListener('click', f, true);
    return () => document.removeEventListener('click', f, true);
  }, [aktif]);
}
