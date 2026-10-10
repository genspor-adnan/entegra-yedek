/**
 * LİSTE SEÇİMİ - icmal listeleri ortak (Kurum İcmali kurumları, Vezne İcmali
 * oturumları). Kullanıcı 10.10.2026: "seçimde diğer seçimler kalksın.. ctrl
 * veya shift ile birden fazla seçilir": düz tıklama yalnız o satırı seçer;
 * Ctrl (Mac'te Cmd) ekler / çıkarır; Shift son tıklanandan bu satıra kadar
 * aralığı seçer (Ctrl+Shift aralığı mevcut seçime ekler).
 */
export function secimUygula<K extends number | string>(secili: K[], id: K, sira: K[], sonId: K | null,
                                                     tus: { ctrl: boolean; shift: boolean }): K[] {
  if (tus.shift && sonId != null && sira.includes(sonId)) {
    const a = sira.indexOf(sonId), b = sira.indexOf(id);
    const aralik = sira.slice(Math.min(a, b), Math.max(a, b) + 1);
    return tus.ctrl ? [...new Set([...secili, ...aralik])] : aralik;
  }
  if (tus.ctrl) return secili.includes(id) ? secili.filter(x => x !== id) : [...secili, id];
  return [id];
}
