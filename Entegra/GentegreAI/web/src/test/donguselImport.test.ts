import { describe, it, expect } from 'vitest';
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, dirname, resolve, extname } from 'node:path';

/**
 * DÖNGÜSEL IMPORT OLMAYACAK.
 *
 * GERÇEK VAKA: `listeTanimlari.ts` sekiz konu dosyasına bölündü; parçalar
 * ortak sabiti (`DURUM_CIPLERI`) ana dosyadan alıyordu, ana dosya da
 * parçaları. Döngü `tsc -b`'yi de `vite build`'i de sorunsuz geçti - ikisi
 * de modül grafiğini kurar, değerlendirme sırasını denemez. Tarayıcıda ise
 * uygulama BOŞ EKRANLA açıldı: parça modülü, ana modül henüz
 * değerlendirilmemişken sabite erişiyordu.
 *
 * Testlerin tamamı da yeşildi - vitest modülleri testin istediği sırada
 * yüklüyor ve döngünün kötü tarafına hiç düşmüyordu. Yani bu hatayı
 * yakalayacak tek yer burası: grafiğin KENDİSİNE bakmak.
 *
 * Kontrol statiktir (kodu çalıştırmaz): `src` altındaki her modülün göreli
 * importları izlenir ve bir çevrim bulunursa zincir adıyla raporlanır.
 */

const KOK = resolve(__dirname, '..');
const UZANTILAR = ['.ts', '.tsx'];

function dosyalar(dizin: string): string[] {
  const cikti: string[] = [];
  for (const ad of readdirSync(dizin)) {
    const yol = join(dizin, ad);
    if (statSync(yol).isDirectory()) { cikti.push(...dosyalar(yol)); continue }
    if (UZANTILAR.includes(extname(ad))) cikti.push(yol);
  }
  return cikti;
}

/** `import ... from './x'` ve `export ... from './x'` - yalnız GÖRELİ olanlar. */
function goreliImportlar(icerik: string): string[] {
  const bulunan: string[] = [];
  const kalip = /(?:^|\n)\s*(?:import|export)[\s\S]*?from\s+['"](\.[^'"]+)['"]/g;
  let e: RegExpExecArray | null;
  while ((e = kalip.exec(icerik)) !== null) bulunan.push(e[1]);
  return bulunan;
}

/** Göreli yolu gerçek dosyaya çözer (uzantısız yazım ve index dosyası dahil). */
function coz(kaynak: string, hedef: string): string | null {
  const taban = resolve(dirname(kaynak), hedef);
  for (const aday of [taban, ...UZANTILAR.map(u => taban + u),
                      ...UZANTILAR.map(u => join(taban, 'index' + u))]) {
    try { if (statSync(aday).isFile()) return aday } catch { /* yok */ }
  }
  return null;
}

describe('modül grafiği', () => {
  it('döngüsel import içermez', () => {
    const graf = new Map<string, string[]>();
    for (const dosya of dosyalar(KOK)) {
      const hedefler = goreliImportlar(readFileSync(dosya, 'utf8'))
        .map(y => coz(dosya, y))
        .filter((y): y is string => y !== null);
      graf.set(dosya, hedefler);
    }

    const durum = new Map<string, 0 | 1 | 2>();   // 0 yok · 1 yolda · 2 bitti
    const zincirler: string[] = [];

    const kisa = (y: string) => y.slice(KOK.length + 1).replace(/\\/g, '/');

    function gez(dugum: string, yol: string[]) {
      if (durum.get(dugum) === 2) return;
      if (durum.get(dugum) === 1) {
        const bas = yol.indexOf(dugum);
        zincirler.push([...yol.slice(bas), dugum].map(kisa).join(' -> '));
        return;
      }
      durum.set(dugum, 1);
      for (const komsu of graf.get(dugum) ?? []) gez(komsu, [...yol, dugum]);
      durum.set(dugum, 2);
    }

    for (const dosya of graf.keys()) gez(dosya, []);

    // BİLİNEN DÖNGÜLER: hepsi bileşen-bileşen ve hiçbiri modül yüklenirken
    //   DEĞER okumuyor - React bileşen referansları çağrı anında çözüldüğü
    //   için tarayıcıda patlamıyorlar. Yine de borçtur: listeye yenisi
    //   EKLENMEMELİ, buradakiler zamanla temizlenmeli.
    const bilinen = [
      'bilesenler/GenForm.tsx -> bilesenler/GenDetayTablo.tsx -> bilesenler/TarafArama.tsx -> bilesenler/GenForm.tsx',
      'bilesenler/GenDetayTablo.tsx -> bilesenler/tarafSecimEngeli.ts -> bilesenler/GenDetayTablo.tsx',
      'bilesenler/GenForm.tsx -> bilesenler/kart/KartGrupSarmalayici.tsx -> bilesenler/kart/KartGrupSekmesi.tsx -> bilesenler/IlgiliKisiler.tsx -> bilesenler/GenForm.tsx',
      'bilesenler/belge/BasvuruSekmesi.tsx -> bilesenler/belge/basvuru/ProvizyonSekmesi.tsx -> bilesenler/belge/BasvuruSekmesi.tsx',
      'bilesenler/GenForm.tsx -> sayfalar/BelgeKarti.tsx -> bilesenler/belge/BelgeKartiModallari.tsx -> bilesenler/BelgeDonusumModali.tsx -> bilesenler/GenForm.tsx',
      'bilesenler/GenForm.tsx -> sayfalar/BelgeKarti.tsx -> bilesenler/belge/BelgeKartiModallari.tsx -> bilesenler/radyoloji/IstemModali.tsx -> sayfalar/KasaIslemKarti.tsx -> bilesenler/GenForm.tsx',
      'bilesenler/GenForm.tsx -> sayfalar/BelgeKarti.tsx -> bilesenler/belge/BelgeKartiModallari.tsx -> bilesenler/belge/BelgeTahsilatModallari.tsx -> bilesenler/GenForm.tsx',
      'sayfalar/BelgeKarti.tsx -> bilesenler/belge/BelgeKartiModallari.tsx -> sayfalar/BelgeKarti.tsx',
    ];

    const yeniler = zincirler.filter(z => !bilinen.includes(z));
    // Zincir ADIYLA raporlanır: "üç döngü var" hangisini düzelteceğini söylemez.
    expect(yeniler, `Yeni döngüsel import:\n  ${yeniler.join('\n  ')}`).toEqual([]);
  });
});
