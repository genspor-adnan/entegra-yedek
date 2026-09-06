import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

/** Kaynak dosyayı metin olarak okur (CSS `?raw` importu vitest'te boş döner). */
const dosyaOku = (yol: string) =>
  readFileSync(new URL(`../${yol}`, import.meta.url), 'utf8');
const temaCss = dosyaOku('tema.css');
const labEtiketKaynak = dosyaOku('sayfalar/LabEtiket.tsx');

/**
 * SINIF ADI ÇAKIŞMASI (446).
 *
 * Tüp barkod etiketi (444) iç kutularına kısa adlar vermişti: `.etiket`,
 * `.ust`, `.govde`. Üçü de temada **global** sınıflardır - `.etiket` her
 * formun alan etiketi, `.ust` uygulamanın üst şeridi. Sonuç: bütün kart ve
 * ayar ekranlarında alan etiketleri 50×25 mm'lik kutuya döndü, etiketin
 * kendi satırı 52 px lacivert blok oldu. Hata laboratuvarda yazılmıştı ama
 * Genel Ayarlar'da görüldü.
 *
 * Bu test o dersi tutuyor: <b>yazdırma bileşenleri kendi ön ekini kullanır</b>.
 * Ortak tasarım dilinden gelen sınıflar (rozet, kagrup…) serbesttir; kısa,
 * genel adlar yasaktır.
 */
/** `className="x y"` ve `className={\`x${...} y\`}` içindeki sabit adlar. */
function siniflar(kaynak: string): string[] {
  const bulunan = new Set<string>();
  const kalip = /className=(?:"([^"]*)"|\{`([^`]*)`\})/g;
  let e: RegExpExecArray | null;
  while ((e = kalip.exec(kaynak)) !== null) {
    const ham = (e[1] ?? e[2] ?? '').replace(/\$\{[^}]*\}/g, ' ');
    ham.split(/\s+/).filter(Boolean).forEach(a => bulunan.add(a));
  }
  return [...bulunan];
}

/** Temadaki GLOBAL (tek sınıflı, kapsamsız) seçiciler: `.ad {` veya `.ad,`. */
function globalSiniflar(css: string): Set<string> {
  const küme = new Set<string>();
  for (const satir of css.split('\n')) {
    const e = /^\.([a-z0-9-]+)\s*(?:[,{]|$)/i.exec(satir.trim());
    if (e) küme.add(e[1]);
  }
  return küme;
}

describe('tema sınıf çakışması', () => {
  it('tüp etiketi ekranı GLOBAL bir sınıf adını sahiplenmez', () => {
    // Ortak tasarım dilinden gelenler serbest (düğme, rozet, kutu); asıl
    //   yasak, kendi görünümünü verdiğin bir kutuya temanın global adını
    //   koymak - `.ust` uygulamanın üst şeridiydi.
    const ortakDil = new Set(['d', 'bir', 'rozet', 'uyari', 'uyari-kutusu',
                              'hata-kutusu', 'yukleniyor', 'cikti-arac',
                              'yazdirma', 'not', 'sonuk', 'sag', 'orta']);
    const global = globalSiniflar(temaCss);
    const cakisan = siniflar(labEtiketKaynak)
      .filter(a => !ortakDil.has(a) && a !== 'tup-etiket' && a !== 'etiket-sayfa')
      .filter(a => global.has(a));
    expect(cakisan).toEqual([]);
  });

  it('etiketin iç sınıfları temada GLOBAL olarak tanımlı değil', () => {
    const global = globalSiniflar(temaCss);
    // Bir zamanlar `.etiket`, `.ust`, `.govde` hem global hem etiket içiydi.
    for (const ad of ['et-serit', 'et-govde', 'et-ust', 'et-tup', 'et-tarih',
                      'et-hasta', 'et-alt', 'et-alt2', 'et-acil-rozet']) {
      expect(global.has(ad), `${ad} global tanımlanmış`).toBe(false);
    }
    // Global adların hâlâ orada olduğunu da doğrula: test yanlış sebeple
    //   yeşile dönmesin.
    expect(global.has('ust')).toBe(true);
    expect(global.has('etiket-sayfa')).toBe(true);
    // Etiket KUTUSU kendi ön ekiyle global olabilir - çakışan bir ad değil.
    expect(global.has('tup-etiket')).toBe(true);
  });
});
