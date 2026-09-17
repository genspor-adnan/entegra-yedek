import { useEffect, useRef, useState } from 'react';

/**
 * İMZA KANVASI (form motoru 740): parmak / kalem / fare ile ıslak imza.
 * Çıktı PNG data URL (form_istek.imzalar[].veri). Boş kanvas = imza yok.
 */
export function ImzaKanvas({ deger, onChange, etiket, salt }: {
  deger?: string; onChange: (png: string | undefined) => void; etiket?: string; salt?: boolean;
}) {
  const ref = useRef<HTMLCanvasElement>(null);
  const [cizildi, setCizildi] = useState(!!deger);
  const ciziyor = useRef(false);
  const son = useRef<{ x: number; y: number } | null>(null);

  useEffect(() => {
    const c = ref.current; if (!c) return;
    const ctx = c.getContext('2d'); if (!ctx) return;
    ctx.clearRect(0, 0, c.width, c.height);
    if (deger) { const im = new Image(); im.onload = () => ctx.drawImage(im, 0, 0, c.width, c.height); im.src = deger; }
  }, [deger]);

  const nokta = (e: React.PointerEvent<HTMLCanvasElement>) => {
    const c = ref.current!; const r = c.getBoundingClientRect();
    return { x: (e.clientX - r.left) * (c.width / r.width), y: (e.clientY - r.top) * (c.height / r.height) };
  };
  const bas = (e: React.PointerEvent<HTMLCanvasElement>) => {
    if (salt) return;
    ciziyor.current = true; son.current = nokta(e); (e.target as HTMLCanvasElement).setPointerCapture(e.pointerId);
  };
  const hareket = (e: React.PointerEvent<HTMLCanvasElement>) => {
    if (!ciziyor.current || !ref.current || !son.current) return;
    const ctx = ref.current.getContext('2d')!; const n = nokta(e);
    ctx.strokeStyle = '#1c4374'; ctx.lineWidth = 2.2; ctx.lineCap = 'round'; ctx.lineJoin = 'round';
    ctx.beginPath(); ctx.moveTo(son.current.x, son.current.y); ctx.lineTo(n.x, n.y); ctx.stroke();
    son.current = n; if (!cizildi) setCizildi(true);
  };
  const birak = () => {
    if (!ciziyor.current) return;
    ciziyor.current = false; son.current = null;
    if (ref.current) onChange(ref.current.toDataURL('image/png'));
  };
  const sil = () => {
    const c = ref.current; if (!c) return;
    c.getContext('2d')!.clearRect(0, 0, c.width, c.height); setCizildi(false); onChange(undefined);
  };

  return (
    <div className={`fm-imza${salt ? ' fm-imza-salt' : ''}`}>
      <canvas ref={ref} width={520} height={160} onPointerDown={bas} onPointerMove={hareket} onPointerUp={birak} onPointerLeave={birak} />
      <div className="fm-imza-alt">
        <span className="sonuk">{etiket ?? 'İmza'}{cizildi ? '' : ' — parmağınızla / kalemle imzalayın'}</span>
        {!salt && cizildi && <button type="button" className="d" onClick={sil}>Sil</button>}
      </div>
    </div>
  );
}
