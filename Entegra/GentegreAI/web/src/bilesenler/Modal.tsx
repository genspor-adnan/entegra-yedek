import { useEffect, useLayoutEffect, useRef, useState } from 'react';

/**
 * Kart/pencere kabugu - kart ekranlari ve secim pencereleri ayni cerceveyi
 * paylasir. GenForm'dan AYRI dosyada: paket sekmesi gibi bilesenler modali
 * kullanip GenForm tarafindan da cizildigi icin, ayni dosyada kalsa
 * dairesel import olurdu.
 */
export function Modal({ baslik, ustBilgi, ustSerit, sekmeBar, alt, dar, onKapat, children }: {
  baslik: string;
  ustBilgi?: React.ReactNode;
  ustSerit?: React.ReactNode;
  sekmeBar?: React.ReactNode;
  alt: React.ReactNode;
  /** Az alanli kartlar icin yarim genislik (1080 -> 560): bos beyaz alan kalmasin. */
  dar?: boolean;
  onKapat?(): void;
  children: React.ReactNode;
}) {
  useEffect(() => {
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') onKapat?.() };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  }, [onKapat]);

  // YUKSEKLIK KILIDI (kullanici): sekme degisince pencere ALCALMASIN -
  //   icerik buyudukce yukselir, o yukseklik minHeight olarak korunur.
  //   Pencere basina yasar; kapaninca ref'le birlikte gider.
  // Pencere kaydirmasi (baslikitan surukleme) - piksel cinsinden ofset.
  const [kaydirma, setKaydirma] = useState({ x: 0, y: 0 });
  const surukleBasla = (e: React.MouseEvent) => {
    // Baslik icindeki dugme/girdi tiklamalari surukleme baslatmaz.
    if ((e.target as HTMLElement).closest('button, input, select, a')) return;
    e.preventDefault();
    const bas = { x: e.clientX, y: e.clientY };
    const ilk = { ...kaydirma };
    const hareket = (o: MouseEvent) => setKaydirma({
      x: ilk.x + (o.clientX - bas.x),
      y: ilk.y + (o.clientY - bas.y),
    });
    const birak = () => {
      window.removeEventListener('mousemove', hareket);
      window.removeEventListener('mouseup', birak);
    };
    window.addEventListener('mousemove', hareket);
    window.addEventListener('mouseup', birak);
  };

  const govdeRef = useRef<HTMLDivElement | null>(null);
  const enYuksek = useRef(0);
  useLayoutEffect(() => {
    const el = govdeRef.current;
    if (!el) return;
    const h = el.scrollHeight;
    if (h > enYuksek.current) {
      enYuksek.current = h;
      el.style.minHeight = `${h}px`;
    }
  });

  return (
    <div className="kaperde" onMouseDown={e => { if (e.target === e.currentTarget) onKapat?.() }}>
      <div className={`kawin${dar ? '' : ' genis'}`} onMouseDown={e => e.stopPropagation()}
           style={kaydirma.x || kaydirma.y
             ? { transform: `translate(${kaydirma.x}px, ${kaydirma.y}px)` } : undefined}>
        {/* Baslik cubugundan tutup FAREYLE TASINIR (kullanici): arkadaki listeyi
            gormek icin pencereyi kenara cekmek gerekiyordu. Cift tik ilk yerine
            dondurur; dugmeler/girdiler surukleme baslatmaz. */}
        <div className="kabas" style={{ cursor: 'move', userSelect: 'none' }}
             onMouseDown={surukleBasla}
             onDoubleClick={() => setKaydirma({ x: 0, y: 0 })}>
          <span>{baslik}</span>
          {ustBilgi}
          <span className="kapt">Esc ile kapanır</span>
        </div>
        {/* Mockup: Kaydet/Sil/Yazdir/Kapat baslikla idstrip ARASINDA arac cubugu (alt degil). */}
        <div className="katoolbar">{alt}</div>
        {ustSerit}
        {sekmeBar}
        <div className="kagov" ref={govdeRef}>{children}</div>
      </div>
    </div>
  );
}

