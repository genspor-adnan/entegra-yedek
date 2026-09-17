import { useEffect, useRef, useState } from 'react';

/**
 * İMZA TUVALİ (778) — parmakla çizilen müşteri imzası.
 *
 * ============ NEDEN GÖRSEL ===========================================
 * `imza_alindi` bayrağı "alındı" der ama KİMİN imzaladığını göstermez.
 * Yerinde yapılan işin tek kanıtı müşterinin onayıdır; sonradan çıkan
 * "gelmediler / yapmadılar" tartışmasında bir onay kutusu delil değildir.
 *
 * ============ POINTER EVENT, TOUCH DEĞİL =============================
 * `pointerdown/move/up` hem parmağı hem kalemi hem fareyi tek kodla
 * karşılar; ayrı `touch` ve `mouse` dinleyicisi yazmak, aynı çizimin iki
 * yolunu tutmak olurdu. `touch-action: none` olmadan parmak hareketi
 * sayfayı kaydırır ve çizgi kopar.
 *
 * ============ ÇÖZÜNÜRLÜK CİHAZINKİ ===================================
 * Tuval `devicePixelRatio` ile ölçekleniyor: CSS boyutuyla çizilen bir
 * tuval telefonda bulanık bir imza üretir ve imza, okunaklı olmadığında
 * kanıt olmaz.
 */
export function ImzaTuvali({ deger, onDegisti, salt }: {
  /** Kayıtlı imzanın görsel adresi (varsa) - salt okuma kipinde gösterilir. */
  deger?: string | null;
  /** Çizim bittiğinde PNG blob; temizlenince null. */
  onDegisti(blob: Blob | null): void;
  salt?: boolean;
}) {
  const tuval = useRef<HTMLCanvasElement | null>(null);
  const ciziyor = useRef(false);
  const [bos, setBos] = useState(true);

  useEffect(() => {
    const c = tuval.current;
    if (!c || salt) return;
    const oran = window.devicePixelRatio || 1;
    const g = c.getBoundingClientRect();
    c.width = Math.round(g.width * oran);
    c.height = Math.round(g.height * oran);
    const ctx = c.getContext('2d');
    if (!ctx) return;
    ctx.scale(oran, oran);
    ctx.lineWidth = 2.2;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.strokeStyle = '#1a2430';
  }, [salt]);

  if (salt) {
    return deger
      ? <img className="imza-gorsel" src={deger} alt="Müşteri imzası" />
      : <div className="imza-yok">İmza görseli yok</div>;
  }

  const nokta = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const g = e.currentTarget.getBoundingClientRect();
    return { x: e.clientX - g.left, y: e.clientY - g.top };
  };

  const bas = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const ctx = tuval.current?.getContext('2d');
    if (!ctx) return;
    // POINTER YAKALANIR: parmak tuvalin dışına taşsa da çizgi kopmaz.
    e.currentTarget.setPointerCapture(e.pointerId);
    ciziyor.current = true;
    const p = nokta(e);
    ctx.beginPath();
    ctx.moveTo(p.x, p.y);
  };

  const ciz = (e: React.PointerEvent<HTMLCanvasElement>) => {
    if (!ciziyor.current) return;
    const ctx = tuval.current?.getContext('2d');
    if (!ctx) return;
    const p = nokta(e);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();
    if (bos) setBos(false);
  };

  const birak = () => {
    if (!ciziyor.current) return;
    ciziyor.current = false;
    tuval.current?.toBlob(b => onDegisti(b), 'image/png');
  };

  const temizle = () => {
    const c = tuval.current;
    const ctx = c?.getContext('2d');
    if (!c || !ctx) return;
    ctx.clearRect(0, 0, c.width, c.height);
    setBos(true);
    onDegisti(null);
  };

  return (
    <div className="imza-kutu">
      <canvas ref={tuval} className="imza-tuval"
              onPointerDown={bas} onPointerMove={ciz}
              onPointerUp={birak} onPointerCancel={birak} onPointerLeave={birak} />
      {bos && <span className="imza-ipucu">Buraya imzalayın</span>}
      <button type="button" className="d mini imza-temizle" onClick={temizle}>
        Temizle
      </button>
    </div>
  );
}
