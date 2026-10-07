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
 * importları izlenir; bilinen kümenin dışında bir çevrim bulunursa zincir adıyla
 * raporlanır.
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
  // ZAMAN AŞIMI YÜKSEK: test bütün kaynak ağacını okuyup grafiği kuruyor;
  //   dosya sayısı arttıkça 5 sn'lik varsayılan, paralel koşuda yetmiyor ve
  //   döngü yokken "FAIL" veriyordu.
  it('döngüsel import içermez (bilinen küme dışında)', () => {
    const graf = new Map<string, string[]>();
    for (const dosya of dosyalar(KOK)) {
      const hedefler = goreliImportlar(readFileSync(dosya, 'utf8'))
        .map(y => coz(dosya, y))
        .filter((y): y is string => y !== null);
      graf.set(dosya, hedefler);
    }
    const kisa = (y: string) => y.slice(KOK.length + 1).replace(/\\/g, '/');

    // GÜÇLÜ BAĞLI BİLEŞENLER (Tarjan). ESKİ KONTROL DFS'in bulduğu zincirleri
    //   bir "bilinen" listesiyle karşılaştırıyordu; DFS döngüyü kümeye İLK
    //   girdiği dosyadan yazdığı için alakasız bir import (933: App ->
    //   OzelKartSayfalari -> MuayeneSablonKarti -> GenDetayTablo) giriş
    //   noktasını değiştirince aynı küme 20 "yeni" döngü gibi raporlanıyordu.
    //   Bileşen üyeliği gezinti sırasından bağımsızdır.
    let sayac = 0;
    const indeks = new Map<string, number>(), dusuk = new Map<string, number>();
    const yigin: string[] = [], yiginda = new Set<string>(), kumeler: string[][] = [];
    function bagla(v: string) {
      indeks.set(v, sayac); dusuk.set(v, sayac); sayac++;
      yigin.push(v); yiginda.add(v);
      for (const w of graf.get(v) ?? []) {
        if (!indeks.has(w)) { bagla(w); dusuk.set(v, Math.min(dusuk.get(v)!, dusuk.get(w)!)) }
        else if (yiginda.has(w)) dusuk.set(v, Math.min(dusuk.get(v)!, indeks.get(w)!));
      }
      if (dusuk.get(v) !== indeks.get(v)) return;
      const kume: string[] = [];
      let w: string;
      do { w = yigin.pop()!; yiginda.delete(w); kume.push(w) } while (w !== v);
      if (kume.length > 1 || (graf.get(v) ?? []).includes(v)) kumeler.push(kume);
    }
    for (const v of graf.keys()) if (!indeks.has(v)) bagla(v);

    // BİLİNEN KÜME: GenForm ↔ GenDetayTablo ↔ TarafArama ↔ BelgeKarti ailesi.
    //   Hepsi bileşen-bileşen ve hiçbiri modül yüklenirken DEĞER okumuyor -
    //   React bileşen referansları çağrı anında çözüldüğü için tarayıcıda
    //   patlamıyor. Yine de borçtur: listeye yenisi EKLENMEMELİ, buradakiler
    //   zamanla temizlenmeli (kök kenar GenForm -> BelgeKarti: karttan başvuru
    //   açılır; onu kırmadan bu aile temizlenemez). Bu kümeye yeni bir dosya
    //   katılırsa ya da AYRI bir döngü oluşursa test kırılır. (Kümenin İÇİNDE
    //   yeni kenar yakalanmaz - bileşen aynı kalır.)
    const bilinen = new Set([
      'bilesenler/BelgeDonusumModali.tsx', 'bilesenler/GenDetayTablo.tsx', 'bilesenler/GenForm.tsx',
      'bilesenler/IlgiliKisiler.tsx', 'bilesenler/PaketSekmesi.tsx', 'bilesenler/PersonelKimlikOzet.tsx',
      'bilesenler/TarafArama.tsx', 'bilesenler/TekAdres.tsx', 'bilesenler/TekKayit.tsx',
      'bilesenler/TekOzluk.tsx', 'bilesenler/belge/BasvuruSekmesi.tsx',
      'bilesenler/belge/BelgeErpSekmeleri.tsx', 'bilesenler/belge/BelgeKartiModallari.tsx',
      'bilesenler/belge/BelgeSekmeleri.tsx', 'bilesenler/belge/BelgeTahsilatModallari.tsx',
      'bilesenler/belge/basvuru/ProvizyonSekmesi.tsx', 'bilesenler/goz/GozOlcumMatrisi.tsx',
      'bilesenler/goz/gozMatrisTanimlari.ts', 'bilesenler/kart/KartDetaySekmesi.tsx',
      'bilesenler/kart/KartGrupSarmalayici.tsx', 'bilesenler/kart/KartGrupSekmesi.tsx',
      'bilesenler/kart/KartKimlikSeridi.tsx', 'bilesenler/kart/kartGovdesi.ts',
      'bilesenler/kart/tarifeKurallari.ts', 'bilesenler/prim/KalemRolModali.tsx',
      'bilesenler/radyoloji/IstemModali.tsx', 'bilesenler/tarafSecimEngeli.ts',
      'sayfalar/BelgeKarti.tsx', 'sayfalar/KasaIslemKarti.tsx', 'sayfalar/belgeKarti/belgeOkuma.ts',
      'sayfalar/belgeKarti/stokSecimi.ts', 'sayfalar/belgeKarti/useBasvuruAlanlari.ts',
      'sayfalar/belgeKarti/useDagilimOnizleme.ts', 'sayfalar/belgeKarti/useKalemAkisi.ts',
    ]);

    /** Yeni üyenin içinden geçen bir döngü (kümede kalarak kendine dönen yol). */
    function ornekZincir(bas: string, kume: Set<string>): string {
      const onceki = new Map<string, string>([[bas, '']]);
      const kuyruk = [bas];
      while (kuyruk.length) {
        const v = kuyruk.shift()!;
        for (const w of graf.get(v) ?? []) {
          if (!kume.has(w)) continue;
          if (w === bas) {
            const ara: string[] = []; let u = v;
            while (u !== bas) { ara.unshift(u); u = onceki.get(u)! }
            return [bas, ...ara, bas].map(kisa).join(' -> ');
          }
          if (!onceki.has(w)) { onceki.set(w, v); kuyruk.push(w) }
        }
      }
      return kisa(bas);
    }

    const yeniler = kumeler.flatMap(k => {
      const ks = new Set(k);
      return k.filter(y => !bilinen.has(kisa(y))).map(y => ornekZincir(y, ks));
    });
    // Zincir ADIYLA raporlanır: "üç döngü var" hangisini düzelteceğini söylemez.
    expect(yeniler, `Yeni döngüsel import:\n  ${yeniler.join('\n  ')}`).toEqual([]);
  }, 30_000);
});
