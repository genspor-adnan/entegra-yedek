import { useEffect } from 'react';

/**
 * Kart/pencere kabugu - kart ekranlari ve secim pencereleri ayni cerceveyi
 * paylasir. GenForm'dan AYRI dosyada: paket sekmesi gibi bilesenler modali
 * kullanip GenForm tarafindan da cizildigi icin, ayni dosyada kalsa
 * dairesel import olurdu.
 */
export function Modal({ baslik, ustBilgi, ustSerit, sekmeBar, alt, dar, gomulu, onKapat, children }: {
  baslik: string;
  ustBilgi?: React.ReactNode;
  ustSerit?: React.ReactNode;
  sekmeBar?: React.ReactNode;
  alt: React.ReactNode;
  /** Az alanli kartlar icin yarim genislik (1080 -> 560): bos beyaz alan kalmasin. */
  dar?: boolean;
  /** SAYFA ICINDE ciz (perde/pencere yok): Firma Bilgileri gibi kartin ekranin
      KENDISI oldugu yerlerde. Modal olarak cizilirse acilir acilmaz kapanmayan
      bir pencere olur - kapatinca gidecek bir sayfa yoktur. */
  gomulu?: boolean;
  onKapat?(): void;
  children: React.ReactNode;
}) {
  useEffect(() => {
    // Gomulu kipte Esc kapatmaz: kapatilacak pencere yok.
    if (gomulu) return;
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') onKapat?.() };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  }, [onKapat, gomulu]);

  if (gomulu) {
    return (
      <div className="kagomulu">
        <div className="katoolbar">{alt}</div>
        {ustSerit}
        {sekmeBar}
        <div className="kagov">{children}</div>
      </div>
    );
  }

  return (
    <div className="kaperde" onMouseDown={e => { if (e.target === e.currentTarget) onKapat?.() }}>
      <div className={`kawin${dar ? '' : ' genis'}`} onMouseDown={e => e.stopPropagation()}>
        <div className="kabas">
          <span>{baslik}</span>
          {ustBilgi}
          <span className="kapt">Esc ile kapanır</span>
        </div>
        {/* Mockup: Kaydet/Sil/Yazdir/Kapat baslikla idstrip ARASINDA arac cubugu (alt degil). */}
        <div className="katoolbar">{alt}</div>
        {ustSerit}
        {sekmeBar}
        <div className="kagov">{children}</div>
      </div>
    </div>
  );
}

