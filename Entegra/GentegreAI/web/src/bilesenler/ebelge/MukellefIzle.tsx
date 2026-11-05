import { useEffect } from 'react';
import { EBELGE_TURLERI } from './ebelgeTurleri';

/** Kartın e-Belge grubu çizilirken mükellefiyet bayraklarını dışarı taşır (render içinde setState yok). */
export function MukellefIzle({ deger, onDegis }: { deger: Record<string, unknown>; onDegis(v: string): void }) {
  const imza = EBELGE_TURLERI.map(t => (deger[t.mukellefAlani] ? '1' : '0')).join('');
  useEffect(() => { onDegis(imza) }, [imza, onDegis]);
  return null;
}

