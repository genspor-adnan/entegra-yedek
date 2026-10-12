/** Kalite / SKS icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

const virgul = (n: number, h = 1) => n.toFixed(h).replace('.', ',');

/** Gösterge sonucu birimiyle: % → "%82,6", ‰ → "2,08‰", diğer → "12,0 gün". */
export function sonucMetni(n: number | null | undefined, birim: string): string {
  if (n == null) return '—';
  if (birim === '%') return `%${virgul(n)}`;
  if (birim === '‰') return `${virgul(n, 2)}‰`;
  return `${virgul(n)}${birim ? ' ' + birim : ''}`;
}

const YON: Record<string, string> = { '>=': '≥', '<=': '≤', '>': '>', '<': '<' };

/** Hedef: "≥ %90,0", "≤ 2,50‰"; tanımsızsa "—". */
export function hedefMetni(yon: string, hedef: number | null | undefined, birim: string): string {
  if (hedef == null || !yon) return '—';
  return `${YON[yon] ?? yon} ${sonucMetni(hedef, birim)}`;
}

export function durumRozeti(durum: string): Rozet {
  switch (durum) {
    case 'hedefte': return { ad: 'Hedefte', renk: 'ok' };
    case 'disi': return { ad: 'Hedef dışı', renk: 'kir' };
    case 'veriyok': return { ad: 'Veri yok', renk: 'pas' };
    case 'kaynakyok': return { ad: 'Kaynak yok', renk: 'pas' };
    default: return { ad: 'Hedef tanımsız', renk: 'sari' };
  }
}

/**
 * Trend: önceki döneme göre fark; iyileşme hedef yönüne göre
 * (≥ hedefte artış iyi, ≤ hedefte azalış iyi). Fark 0 ya da veri yoksa nötr.
 */
export function trend(sonuc: number | null | undefined, onceki: number | null | undefined, yon: string, birim: string):
  { ok: string; fark: string; yon: 'iyi' | 'kotu' | 'notr' } | null {
  if (sonuc == null || onceki == null) return null;
  const f = sonuc - onceki;
  if (Math.abs(f) < 0.005) return { ok: '■', fark: '0', yon: 'notr' };
  const artis = f > 0;
  const iyi = yon.startsWith('>') ? artis : yon.startsWith('<') ? !artis : null;
  return { ok: artis ? '▲' : '▼', fark: virgul(Math.abs(f), birim === '‰' ? 2 : 1), yon: iyi == null ? 'notr' : iyi ? 'iyi' : 'kotu' };
}

/** Oran (%): el hijyeni / memnuniyet satırı hedefle karşılaştırılır. */
export function oranRozeti(oran: number | null | undefined, hedef: number): Rozet {
  if (oran == null) return { ad: '—', renk: 'pas' };
  return { ad: oran >= hedef ? 'Hedefte' : 'Hedef altı', renk: oran >= hedef ? 'ok' : 'kir' };
}

/** Memnuniyet sorusu ortalaması (1-5): ≥ 4,4 güçlü, < 4,0 iyileştir. */
export function soruDegerlendirme(ort: number | null | undefined): Rozet {
  if (ort == null) return { ad: '—', renk: 'pas' };
  return ort >= 4.4 ? { ad: 'güçlü', renk: 'ok' } : ort < 4 ? { ad: 'iyileştir', renk: 'kir' } : { ad: 'orta', renk: 'sari' };
}
