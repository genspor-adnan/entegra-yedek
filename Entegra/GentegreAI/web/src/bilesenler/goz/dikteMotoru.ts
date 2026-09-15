import type { DikteTerimi } from '../../api/uclar/goz';

/**
 * DİKTE METİN MOTORU (705) — ham tanıma çıktısını okunur bulgu cümlesine
 * çevirir: sesli komutları ayıklar, terim sözlüğünü uygular, noktalar ve
 * büyük harfleri düzeltir.
 *
 * <b>Neden ayrı dosya:</b> bu, ekranın çizim işi değil metin işidir ve tek
 * test edilebilir yer burasıdır. "sağ göz kornea saydam" cümlesinin hangi
 * alana, hangi gözle, nasıl yazılacağı bileşenin içinde kalsaydı, doğruluğu
 * ancak mikrofonla denenebilirdi.
 *
 * <b>Sözlük sunucudan gelir</b> (kurum + kişisel satırlar): burada hiçbir
 * terim ya da komut gömülü değildir. Yeni bir kısaltma eklemek sürüm değil
 * satır meselesi.
 *
 * <b>Motor hiçbir şey yazmaz.</b> Ürettiği metin hekimin onayına gider;
 * yazma işi tek kapıdan (`bulgu-metni` ucu) geçer.
 */

/** Ayrıştırılmış komut: göz değiştir, hedef alana atla, noktala, sil, onayla. */
export interface DikteKomutu {
  tur: 'goz' | 'hedef' | 'noktalama' | 'satir' | 'sil' | 'onayla';
  deger: string;
  /** Komutu tetikleyen söyleniş — dökümde gösterilir. */
  soylenen: string;
}

export interface DikteSonucu {
  /** Sözlük ve noktalama uygulanmış metin. */
  metin: string;
  komutlar: DikteKomutu[];
}

/** Türkçe küçültme: `toLowerCase()` "I"yı "i" yapar, eşleşme kaçar. */
const kucuk = (s: string) => s.toLocaleLowerCase('tr');

/** Kelime sınırı: harf/rakam dışındaki her şey ayraç sayılır. */
const HARF = /[0-9a-zçğıöşü]/i;

function kelimeSinirinda(metin: string, bas: number, son: number) {
  const onceki = bas > 0 ? metin[bas - 1] : ' ';
  const sonraki = son < metin.length ? metin[son] : ' ';
  return !HARF.test(onceki) && !HARF.test(sonraki);
}

/** "goz:1" · "hedef:fundus.disk" · "noktalama:." biçimindeki eylemi çözer. */
function eylemCoz(eylem: string, soylenen: string): DikteKomutu | null {
  const [tur, ...kalan] = eylem.split(':');
  const deger = kalan.join(':');
  switch (tur) {
    case 'goz': case 'hedef': case 'noktalama':
      return deger ? { tur, deger, soylenen } : null;
    case 'satir': case 'sil': case 'onayla':
      return { tur, deger: '', soylenen };
    default:
      return null;
  }
}

/**
 * Ham metni işler. Komutlar metinden ÇIKARILIR (yazıya geçmez), noktalama
 * komutu kendi işaretini bırakır, terimler yerine konur.
 *
 * Eşleşme UZUNDAN KISAYA denenir: "sol göz" varken "göz" kısa eşleşmesi
 * cümleyi bölerdi.
 */
export function dikteAyristir(ham: string, sozluk: {
  terimler: DikteTerimi[]; komutlar: DikteTerimi[];
}): DikteSonucu {
  const komutlar: DikteKomutu[] = [];
  let metin = ` ${ham.trim()} `;

  const komutSirali = [...sozluk.komutlar]
    .sort((a, b) => b.soylenen.length - a.soylenen.length);

  for (const k of komutSirali) {
    const kalip = kucuk(k.soylenen);
    if (!kalip) continue;
    let ara = 0;
    for (;;) {
      const i = kucuk(metin).indexOf(kalip, ara);
      if (i < 0) break;
      // Kelimenin İÇİNDE kalan eşleşme komut değildir ("lensler"deki "lens").
      if (!kelimeSinirinda(metin, i, i + kalip.length)) { ara = i + 1; continue }
      const komut = eylemCoz(k.eylem, k.soylenen);
      if (komut) komutlar.push(komut);
      const yerine = komut?.tur === 'noktalama' ? komut.deger
        : komut?.tur === 'satir' ? '\n' : ' ';
      metin = metin.slice(0, i) + yerine + metin.slice(i + kalip.length);
      ara = i + yerine.length;
    }
  }

  // TERİMLER: kişisel satır kurum satırını ezsin diye sona konan kazanır -
  //   sunucu kurumu önce, kişiseli sonra gönderiyor.
  const terimSirali = [...sozluk.terimler]
    .sort((a, b) => b.soylenen.length - a.soylenen.length);
  for (const t of terimSirali) {
    const kalip = kucuk(t.soylenen);
    if (!kalip || !t.yazilan) continue;
    let ara = 0;
    for (;;) {
      const i = kucuk(metin).indexOf(kalip, ara);
      if (i < 0) break;
      if (kelimeSinirinda(metin, i, i + kalip.length)) {
        metin = metin.slice(0, i) + t.yazilan + metin.slice(i + kalip.length);
        ara = i + t.yazilan.length;
      } else {
        ara = i + kalip.length;
      }
    }
  }

  return { metin: duzelt(metin), komutlar };
}

/**
 * Noktalama ve büyük harf düzeltmesi: tanıma çıktısı küçük harfli ve
 * boşlukları dağınık gelir. Cümle sonuna nokta EKLENİR - epikrizde yarım
 * kalmış cümle, yazılmamış cümleden daha kötüdür.
 */
export function duzelt(ham: string): string {
  let metin = ham
    .replace(/\s+([,.;:!?])/g, '$1')      // "saydam ." -> "saydam."
    .replace(/([,.;:!?])(?=\S)/g, '$1 ')  // "saydam.fluoresein" -> ". f"
    .replace(/[ \t]+/g, ' ')
    .replace(/ *\n */g, '\n')
    .trim();
  if (!metin) return '';

  // Cümle başlarını büyüt: satır başı ve ". " sonrası.
  metin = metin.replace(/(^|[.!?]\s+|\n)([a-zçğıöşü])/g,
    (_, on: string, harf: string) => on + harf.toLocaleUpperCase('tr'));

  if (!/[.!?]$/.test(metin)) metin += '.';
  return metin;
}

/**
 * Tanıma parçası yazılabilir mi? Güven eşiği SUNUCUDAN gelir; eşiğin
 * altındaki parça sessizce yazılmaz, dökümde "atıldı" olarak görünür —
 * yanlış duyulmuş bir cümlenin bulguya karışması, hiç yazılmamasından
 * çok daha pahalıdır.
 */
export function guvenliMi(guven: number, esik: number) {
  return guven <= 0 || guven >= esik;   // güven bildirmeyen motor engellenmez
}
