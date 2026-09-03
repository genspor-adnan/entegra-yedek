import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';

/**
 * Kart/pencere kabugu - kart ekranlari ve secim pencereleri ayni cerceveyi
 * paylasir. GenForm'dan AYRI dosyada: paket sekmesi gibi bilesenler modali
 * kullanip GenForm tarafindan da cizildigi icin, ayni dosyada kalsa
 * dairesel import olurdu.
 */
export function Modal({ baslik, ustBilgi, ustSerit, sekmeBar, alt, dar, ekSinif, enUst,
                       onKapat, children }: {
  baslik: string;
  ustBilgi?: React.ReactNode;
  ustSerit?: React.ReactNode;
  sekmeBar?: React.ReactNode;
  alt: React.ReactNode;
  /** Az alanli kartlar icin yarim genislik (1080 -> 560): bos beyaz alan kalmasin. */
  dar?: boolean;
  /** Pencereye ek sinif (or. randevu karti mockup genisligi: `kart-orta`). */
  ekSinif?: string;
  /**
   * EN UST KATMAN: butun perdeler ayni z-index'te (320) oldugundan, ust uste
   * acilan iki modalde DOM'da SONRA gelen kazaniyordu. Mesaj/onay penceresi
   * (MesajKatmani) App kokunde, yani sayfa modallerinden ONCE ciziliyor -
   * belge karti acikken sorulan onay GORUNMEZ kaliyordu (dugme "hic tepki
   * vermiyor" gibi). Bu bayrak perdeyi kalici olarak en uste alir.
   */
  enUst?: boolean;
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

  /**
   * YUKSEKLIK KILIDI - EKRANLA SINIRLI (kullanici: "form alt kismi kirpiliyor").
   *
   * Kilit eskiden govdeye ham `scrollHeight`i minHeight olarak yaziyordu.
   * Pencere bir flex sutunu ve `max-height: 88vh` ile sinirli; govde
   * KUCULEMEYINCE tasan kisim pencerenin altindan tasip ekran disinda kaliyor
   * ve kaydirma cubugu da olusmuyordu - uzun sekmelerde (basvuru) alt satirlar
   * hic gorulemiyordu.
   *
   * Simdi kilit her zaman KULLANILABILIR yukseklikle kirpiliyor: govde en fazla
   * "pencere tavani - (baslik + arac cubugu + serit + sekme)" kadar uzar,
   * gerisi govdenin kendi kaydirmasina duser. Sekme degisince pencerenin
   * alcalmamasi ozelligi korunur.
   */
  useLayoutEffect(() => {
    const uygula = () => {
      const el = govdeRef.current;
      if (!el) return;
      const pencere = el.parentElement;            // .kawin
      // Govde disinda kalan sabit seritler (baslik/toolbar/ustSerit/sekme).
      const disi = pencere ? pencere.offsetHeight - el.offsetHeight : 0;
      // .kawin max-height'i ile ayni oran; en az 160px govde birakilir.
      const tavan = Math.max(160, window.innerHeight * 0.88 - disi);
      if (el.scrollHeight > enYuksek.current) enYuksek.current = el.scrollHeight;
      el.style.minHeight = `${Math.min(enYuksek.current, tavan)}px`;
      el.style.maxHeight = `${tavan}px`;
    };
    uygula();
    // Pencere boyutu degisince tavan da degisir (kilit ekrana sigmali).
    window.addEventListener('resize', uygula);
    return () => window.removeEventListener('resize', uygula);
  });

  /*
   * PERDE BODY'YE PORTALLANIR. `.kawin` her zaman `transform` tasiyor (ortalama)
   * ve transform, icindeki `position: fixed` ogeler icin KAPSAYICI BLOK olur:
   * kart icinden acilan ikinci pencere (or. Faturalama sekmesinden acilan fis
   * karti) ekrana degil ACAN KARTIN kutusuna gore konumlanip kirpiliyordu.
   * Portal ile her pencere gercekten ekrana gore ortalanir.
   */
  return createPortal(
    <div className={`kaperde${enUst ? ' enust' : ''}`}
         onMouseDown={e => { if (e.target === e.currentTarget) onKapat?.() }}>
      <div className={`kawin${dar ? '' : ' genis'}${ekSinif ? ' ' + ekSinif : ''}`}
           onMouseDown={e => e.stopPropagation()}
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
    </div>,
    document.body,
  );
}

