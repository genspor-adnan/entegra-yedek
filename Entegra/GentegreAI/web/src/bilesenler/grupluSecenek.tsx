/**
 * GRUPLU COMBO SEÇENEKLERİ — 848.
 *
 * Kullanıcı: *"Yönetici combosunu da bölüme göre ağaç şeklinde yap"*.
 *
 * Ağaç (`agac`) üstünü AYNI listede arar; burada başlık BAŞKA bir varlıktır
 * (personelin bölümü). Başlık `optgroup` olarak çizilir: görünüm ağaçla aynı,
 * ama başlık seçilemez - `yonetici_taraf_id`ye bölüm kimliği yazılamaz.
 *
 * Grubu olmayan seçenekler EN ÜSTTE, başlıksız durur: "bölümü yok" bilgisi
 * uydurma bir başlık altında kaybolmasın.
 */
import { Fragment } from 'react';

export function grupluSecenekler(
  secenekler: [string, string][],
  kodGrup: Record<string, string>,
) {
  const gruplu = new Map<string, [string, string][]>();
  const grupsuz: [string, string][] = [];
  secenekler.forEach(s => {
    const g = kodGrup[s[0]];
    if (!g) { grupsuz.push(s); return }
    gruplu.set(g, [...(gruplu.get(g) ?? []), s]);
  });
  const basliklar = [...gruplu.keys()].sort((a, b) => a.localeCompare(b, 'tr'));
  return (
    <>
      {grupsuz.map(([k, v]) => <option key={k} value={k}>{v}</option>)}
      {basliklar.map(b => (
        <optgroup key={b} label={b}>
          {(gruplu.get(b) ?? []).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </optgroup>
      ))}
      <Fragment />
    </>
  );
}
