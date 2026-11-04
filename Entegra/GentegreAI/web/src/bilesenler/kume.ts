/**
 * KÜME (Set) YARDIMCILARI.
 *
 * `kumeCevir`: öğe varsa çıkarır, yoksa ekler; state için YENİ Set döner. 04.11.2026 refaktor: aynı satır
 * (`const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n`) 20'den fazla icmal / kart ekranında
 * kopyaydı ve lint'in "kullanılmayan ifade" uyarısını veriyordu.
 */
export function kumeCevir<T>(kume: ReadonlySet<T>, deger: T): Set<T> {
  const n = new Set(kume);
  if (n.has(deger)) n.delete(deger); else n.add(deger);
  return n;
}
