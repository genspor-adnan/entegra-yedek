import qrcode from 'qrcode-generator';
import { useMemo } from 'react';

/**
 * KAREKOD (QR) - satır içi SVG (1389: radyoloji raporunun köşesindeki rapor bağlantısı). Görsel dosya / dış servis yok;
 * yazıcıda keskin basılır. Hata düzeltme M: kâğıttaki küçük leke / kırışıkla okunur kalır.
 */
export function Karekod({ deger, boyut = 84, baslik }: { deger: string; boyut?: number; baslik?: string }) {
  const { n, yol } = useMemo(() => {
    const q = qrcode(0, 'M');
    q.addData(deger);
    q.make();
    const adet = q.getModuleCount();
    let d = '';
    for (let y = 0; y < adet; y++)
      for (let x = 0; x < adet; x++)
        if (q.isDark(y, x)) d += `M${x} ${y}h1v1h-1z`;
    return { n: adet, yol: d };
  }, [deger]);
  // 4 modül sessiz bölge (QR standardı) - kenardaki yazıya yapışırsa okunmaz.
  return (
    <svg className="karekod" width={boyut} height={boyut} viewBox={`-4 -4 ${n + 8} ${n + 8}`} role="img"
         aria-label={baslik ?? 'Karekod'} shapeRendering="crispEdges" data-testid="karekod">
      <rect x={-4} y={-4} width={n + 8} height={n + 8} fill="#fff" />
      <path d={yol} fill="#000" />
    </svg>
  );
}
