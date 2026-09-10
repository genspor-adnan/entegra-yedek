import { useEffect, useLayoutEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';

/**
 * Kart/pencere kabugu - kart ekranlari ve secim pencereleri ayni cerceveyi
 * paylasir. GenForm'dan AYRI dosyada: paket sekmesi gibi bilesenler modali
 * kullanip GenForm tarafindan da cizildigi icin, ayni dosyada kalsa
 * dairesel import olurdu.
 */
export function Modal({ baslik, ustBilgi, ustSerit, sekmeBar, alt, dar, ekSinif, enUst,
                       buyutmeYok, onKapat, children }: {
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
  /**
   * BUYUTME YOK (543, kullanici: "mesaj ekranı max'ta kalmış o yüzden büyük
   * görünüyormuş" · "mesaj ekranlarında max butonu olmasın"). Tam ekran
   * tercihi KALICI ve TUM pencereler icin ortak - kart ekraninda bir kez
   * buyutulunce iki cumlelik onay penceresi de ekrani kapliyordu. Tek soruluk
   * pencerede buyutmenin bir karsiligi da yok: icerik zaten iki satir.
   */
  buyutmeYok?: boolean;
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
      // Govde DISINDAKI seritlerin toplami. Pencere yuksekliginden govdeyi
      //   cikarmak YANLIS olur: govde tavanindan kucukse aradaki BOSLUK da
      //   "serit" sayilip tavani her olcumde biraz daha kisiyordu.
      const disi = pencere
        ? Array.from(pencere.children).reduce(
            (t, c) => t + (c === el ? 0 : (c as HTMLElement).offsetHeight), 0)
        : 0;
      // PENCERENIN GERCEK TAVANI: normalde `max-height: 88vh`, TAM EKRANDA
      //   ise ekranin tamami eksi 8px kenar (`.kawin.tam` top/bottom: 8px).
      //   Sabit 88vh kullanmak tam ekranda govdeyi ekranin cok altinda
      //   birakiyordu: pencerenin alt kismi BOS BEYAZ kaliyor, icerik ise
      //   kendi icinde kirpiliyordu (kullanici: "maximuma alinca altta beyaz
      //   bir bolum olusuyor ve kirpiyor").
      //   Tam ekranda pencerenin KENDI ic yuksekligi olculur (kenarlik
      //   haric); normalde CSS'teki 88vh tavani gecerlidir.
      const sinir = pencere?.classList.contains('tam')
        ? pencere.clientHeight
        : window.innerHeight * 0.88 - 2;
      const tavan = Math.max(160, sinir - disi);
      // DOGAL YUKSEKLIK: govde bir flex sutununda (flex: 1) YAYILDIGI icin
      //   scrollHeight kutunun kendisini olcuyordu - tam ekranda buyuyen
      //   govde, pencereye donunce de o yuksekligi "icerik" sanip kilide
      //   yaziyor ve kart ekranin yarisini kaplamis kaliyordu. Olcum icin
      //   yayilma bir an kapatilir.
      const eskiFlex = el.style.flex;
      const eskiMin = el.style.minHeight;
      const eskiMax = el.style.maxHeight;
      el.style.flex = 'none';
      el.style.minHeight = '0px';
      el.style.maxHeight = 'none';
      const dogal = el.offsetHeight;
      el.style.flex = eskiFlex;
      el.style.minHeight = eskiMin;
      el.style.maxHeight = eskiMax;
      if (dogal > enYuksek.current) enYuksek.current = dogal;
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
  /**
   * TAM EKRAN (kullanici: "kartlari full ekran yapma / geri eski haline
   * getirme olabilir mi"). Cok sekmeli kartlarda (tetkik, cari, belge) grid ve
   * takvim 1080px'e sigmiyordu; kullanici pencereyi buyutemedigi icin yatay
   * kaydirmak zorundaydi.
   *
   * Secim OTURUMLUK degil KALICI: her kart acilisinda yeniden buyutmek,
   * "gecen sefer nasil biraktimsa oyle acilsin" beklentisini kiriyordu.
   * Tasima kaydirmasi tam ekranda SIFIRLANIR - ekrana oturmus bir pencerenin
   * kaydirilmis olmasi anlamsiz.
   */
  const [tamEkranSecimi, setTamEkran] = useState(() => {
    try { return localStorage.getItem('gentegre.kart.tamekran') === '1' }
    catch { return false }
  });
  // Kayitli tercih tek soruluk pencereye UYGULANMAZ (543).
  const tamEkran = tamEkranSecimi && !buyutmeYok;
  const tamEkranDegis = () => setTamEkran(a => {
    const yeni = !a;
    try { localStorage.setItem('gentegre.kart.tamekran', yeni ? '1' : '0') } catch { /* yok say */ }
    if (yeni) setKaydirma({ x: 0, y: 0 });
    // YUKSEKLIK KILIDI SIFIRLANIR: tam ekranda buyuyen govde, pencereye
    //   donunce de o yuksekligi koruyup ekranin yarisini kaplamis bir kart
    //   birakiyordu. Kilit "sekme degisince alcalmasin" icin var, kip
    //   degisiminde degil.
    enYuksek.current = 0;
    return yeni;
  });

  return createPortal(
    <div className={`kaperde${enUst ? ' enust' : ''}`}
         onMouseDown={e => { if (e.target === e.currentTarget) onKapat?.() }}>
      <div className={`kawin${dar ? '' : ' genis'}${tamEkran ? ' tam' : ''}`
                      + `${ekSinif ? ' ' + ekSinif : ''}`}
           onMouseDown={e => e.stopPropagation()}
           style={!tamEkran && (kaydirma.x || kaydirma.y)
             ? { transform: `translate(${kaydirma.x}px, ${kaydirma.y}px)` } : undefined}>
        {/* Baslik cubugundan tutup FAREYLE TASINIR (kullanici): arkadaki listeyi
            gormek icin pencereyi kenara cekmek gerekiyordu. Cift tik ilk yerine
            dondurur; dugmeler/girdiler surukleme baslatmaz. */}
        <div className="kabas"
             style={{ cursor: tamEkran ? 'default' : 'move', userSelect: 'none' }}
             onMouseDown={tamEkran ? undefined : surukleBasla}
             onDoubleClick={() => setKaydirma({ x: 0, y: 0 })}>
          <span>{baslik}</span>
          {ustBilgi}
          <span className="kapt">Esc ile kapanır</span>
          {/* Baslik cubugundaki dugme SURUKLEMEYI baslatmasin. */}
          {!buyutmeYok && (
          <button type="button" className="kabas-dugme"
                  title={tamEkran ? 'Pencereye döndür' : 'Tam ekran'}
                  onMouseDown={e => e.stopPropagation()}
                  onClick={tamEkranDegis}>{tamEkran ? '🗗' : '🗖'}</button>
          )}
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

