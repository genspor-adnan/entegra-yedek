import type { ListeSatiri } from '../../api/sozlesme';

/**
 * GRID AĞACI (kullanıcı: "+ gibi alt dallar açılır yap").
 *
 * Liste ucu satırları DÜZ döndürür; hiyerarşi bir alandadır (bölümde
 * `ustbirimId`). Burası o alandan ağacı kurar, kapalı dalların altını eler ve
 * her satıra çizim için gereken üç bilgiyi ekler: derinlik, çocuğu var mı,
 * açık mı.
 *
 * SUNUCUYA DOKUNULMAZ: sayfa, sıralama ve süzgeç olduğu gibi kalır - ağaç
 * yalnız GÖRÜNEN satırların dizilişidir. Üstü gelen sayfada olmayan satır
 * (süzgeç bir dalı kesmişse) KÖK sayılır; yoksa listeden düşerdi.
 */
export interface AgacSatiri extends ListeSatiri {
  __derinlik: number;
  __cocukVar: boolean;
  __acik: boolean;
}

export function agacDiz(
  satirlar: ListeSatiri[], ustAlani: string, kapalilar: ReadonlySet<string>,
): AgacSatiri[] {
  const anahtar = (s: ListeSatiri) => String(s.id ?? '');
  const ust = (s: ListeSatiri) => {
    const v = s[ustAlani];
    return v === null || v === undefined || v === '' || Number(v) === 0
      ? '' : String(v);
  };

  const varOlan = new Set(satirlar.map(anahtar));
  const cocuklar = new Map<string, ListeSatiri[]>();
  const kokler: ListeSatiri[] = [];

  satirlar.forEach(s => {
    const u = ust(s);
    if (u && varOlan.has(u)) cocuklar.set(u, [...(cocuklar.get(u) ?? []), s]);
    else kokler.push(s);
  });

  const sonuc: AgacSatiri[] = [];
  const gez = (liste: ListeSatiri[], derinlik: number) => {
    liste.forEach(s => {
      const id = anahtar(s);
      const alt = cocuklar.get(id) ?? [];
      const acik = !kapalilar.has(id);
      sonuc.push({ ...s, __derinlik: derinlik, __cocukVar: alt.length > 0, __acik: acik });
      if (alt.length > 0 && acik) gez(alt, derinlik + 1);
    });
  };
  gez(kokler, 0);
  return sonuc;
}

/** Ağaç kipinde sunucunun "— " öneki gereksiz: girintiyi çizim veriyor. */
export function agacAdi(deger: unknown): string {
  const s = String(deger ?? '');
  return s.startsWith('— ') ? s.slice(2) : s;
}
