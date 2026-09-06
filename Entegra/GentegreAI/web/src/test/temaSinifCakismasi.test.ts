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

/**
 * İKİ ANLAMLI AD KİLİDİ.
 *
 * Bir sınıf adı hem GLOBAL (görünüm veren, kapsamsız) hem de başka bir
 * bileşenin kabı içinde tanımlıysa, o ad iki anlam taşır. Çoğu meşru (ortak
 * `.detay-tablo`nun kart içinde daraltılması gibi); ama `.bolum` böyle
 * başlayıp rapor metnini sol menü başlığına çevirmişti - global kural
 * 10 px BÜYÜK HARF veriyor, kapsamlı kural yalnız `margin` ekliyordu.
 *
 * Liste KİLİTLİ: yeni bir ad iki anlamlı hâle gelirse test kırılır ve karar
 * bilinçli verilir; sessizce sızmaz.
 */
const IKI_ANLAMLI = [
  'alan-izgara', 'bos', 'cikti-arac', 'd', 'detay-tablo', 'dip-toplam',
  'kagov', 'kagrup-resim', 'kawin', 'lookup-kutu', 'lookup-liste', 'mi',
  'minibtn', 'resim-kutusu', 'satir-ici', 'tuslar', 'yan',
];

const GORUNUM = /\b(width|height|border|background|position|display|padding|flex)\b/;

/** `.KAP .ad` biçiminde tanımlı (kabı kendi adıyla başlamayan) sınıf adları. */
function kapIcinde(css: string): Set<string> {
  const küme = new Set<string>();
  for (const blok of css.matchAll(/([^{}]+)\{[^{}]*\}/g)) {
    for (const parca of blok[1].split(',')) {
      const p = parca.trim();
      if (/^\.[a-zA-Z0-9_-]+$/.test(p)) continue;
      const adlar = [...p.matchAll(/\.([a-zA-Z0-9_-]+)/g)].map(m => m[1]);
      const son = adlar[adlar.length - 1];
      if (adlar.length >= 2 && !p.startsWith('.' + son)) küme.add(son);
    }
  }
  return küme;
}

/** Kapsamsız (`.ad { … }`) ve GÖRÜNÜM veren kurallar. */
function globalGorunum(css: string): Set<string> {
  const küme = new Set<string>();
  for (const blok of css.matchAll(/([^{}]+)\{([^{}]*)\}/g)) {
    if (!/^\s*\.[a-zA-Z0-9_-]+\s*$/.test(blok[1])) continue;
    if (GORUNUM.test(blok[2])) küme.add(blok[1].trim().slice(1));
  }
  return küme;
}

describe('iki anlamlı sınıf adları', () => {
  it('kilitli listenin dışında yeni iki anlamlı ad yok', () => {
    const kap = kapIcinde(temaCss);
    const bulunan = [...globalGorunum(temaCss)]
      .filter(a => kap.has(a) && globalSiniflar(temaCss).has(a)).sort();
    expect(bulunan).toEqual([...IKI_ANLAMLI].sort());
  });

  it('arama kutusu ikiye ayrıldı: üst şerit ve liste ayrı sınıf', () => {
    // `.ara` üst şeridin KOYU kutusuydu; sekiz bileşen aynı adı kullanıp
    //   zemini/rengi inline eziyordu. Biri unutulsa beyaz zeminde açık mavi
    //   yazı kalıyordu - artık iki ayrı sınıf var.
    const global = globalSiniflar(temaCss);
    expect(global.has('ara')).toBe(false);
    expect(global.has('ust-ara')).toBe(true);
    expect(global.has('ara-kutu')).toBe(true);
    expect(temaCss).toMatch(/\.ara-kutu input/);
  });

  it('rapor bölümü artık sol menü başlığının adını taşımıyor', () => {
    // `.cikti-sayfa .bolum` metni 10 px BÜYÜK HARF yapıyordu.
    expect(temaCss).not.toMatch(/\.cikti-sayfa\s+\.bolum\b/);
    expect(temaCss).toMatch(/\.cikti-sayfa\s+\.rapor-bolum\b/);
  });
});
