/**
 * AĞAÇ COMBO SEÇENEKLERİ - 484.
 *
 * Kullanıcı: "hizmet kartında kategori combo yerine ağaç combo olmalı."
 *
 * Kategori hiyerarşiktir (269, stokla ortak ağaç). Düz combo yalnız yaprak
 * adını gösteriyordu: "Genel" hem Laboratuvar hem Radyoloji altında olabilir ve
 * listede ikisi ayırt edilemiyordu. Burası seçenekleri AĞAÇ SIRASINDA dizer ve
 * derinliğe göre girintiler; saklanan değer yine tek id'dir.
 *
 * SAF fonksiyon: çizim yapmaz, `<option>` üretmez - sıralama kuralı tek yerde
 * dursun ve testi DOM olmadan yazılabilsin.
 */

/** Girinti işareti: `<option>` içinde ardışık boşluklar sıkışır, nbsp kalır. */
const GIRINTI = '   ';
const DAL = '└ ';

export interface AgacSecenek {
  kod: string;
  /** Girintili gösterim adı ("   └ BT"). */
  etiket: string;
  /** Ham ad - arama/eşleştirme girintiye takılmasın. */
  ad: string;
  derinlik: number;
}

/**
 * Seçenekleri ağaç sırasında (önce kök, hemen altında çocukları) dizer.
 *
 * ÜÇ KURAL, üçü de veri bozukken bir şeyin KAYBOLMAMASI için:
 *  * Üstü listede OLMAYAN düğüm KÖK sayılır - yetkiye ya da `aktif = 0`e takılıp
 *    gelmemiş bir üst, çocuğunu listeden düşürmemeli.
 *  * DÖNGÜ (a -> b -> a) kök sayılır: sonsuz döngü yerine görünür bir kayıt.
 *  * Kardeşler ada göre Türkçe sıralanır - sunucudaki sıra değil, kullanıcının
 *    okuduğu sıra.
 */
export function agacSecenekleri(
  kodlar: Record<string, string>,
  kodUst?: Record<string, string> | null,
): AgacSecenek[] {
  const adlar = new Map(Object.entries(kodlar));
  const ust = (kod: string): string | null => {
    const u = kodUst?.[kod];
    return u != null && u !== kod && adlar.has(u) ? u : null;
  };

  // Döngüdeki düğümleri kök say: zincirini yukarı yürürken kendine dönen kayıt
  //   hiçbir kökün altında olmadığı için çizimde hiç görünmezdi.
  const kokMu = (kod: string): boolean => {
    let g = ust(kod);
    const gorulen = new Set([kod]);
    while (g) {
      if (gorulen.has(g)) return true;
      gorulen.add(g);
      g = ust(g);
    }
    return ust(kod) === null;
  };

  const cocuklar = new Map<string, string[]>();
  const kokler: string[] = [];
  for (const kod of adlar.keys()) {
    const u = kokMu(kod) ? null : ust(kod);
    if (u === null) kokler.push(kod);
    else cocuklar.set(u, [...(cocuklar.get(u) ?? []), kod]);
  }

  const sirala = (a: string[]) =>
    [...a].sort((x, y) => (adlar.get(x) ?? '').localeCompare(adlar.get(y) ?? '', 'tr'));

  const sonuc: AgacSecenek[] = [];
  const yaz = (kod: string, derinlik: number) => {
    const ad = adlar.get(kod) ?? '';
    sonuc.push({
      kod, ad, derinlik,
      etiket: derinlik === 0 ? ad : GIRINTI.repeat(derinlik - 1) + DAL + ad,
    });
    for (const c of sirala(cocuklar.get(kod) ?? [])) yaz(c, derinlik + 1);
  };
  for (const k of sirala(kokler)) yaz(k, 0);
  return sonuc;
}
