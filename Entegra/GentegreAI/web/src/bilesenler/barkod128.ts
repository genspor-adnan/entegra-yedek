/**
 * CODE 128 KODLAYICI (444) — laboratuvar tüp etiketleri için.
 *
 * <b>Neden kütüphane değil?</b> Tek ihtiyaç bir barkod çizmek; hazır paket
 * en küçük hâliyle bile onlarca KB ve tüm sembolojileri getiriyor. Kodlayıcı
 * standardın kendisi kadar: değer tablosu + ağırlıklı sağlama + desen dizisi.
 * SVG çıktısı yazıcıda da ekranda da aynı görünür (raster PNG'de dar barlar
 * kayboluyor).
 *
 * <b>Neden Code 128?</b> Laboratuvar cihazları (Cobas, VITEK, BACTEC) tüp
 * barkodunu bu sembolojide bekler; Code 39 daha basit ama %40 daha geniş ve
 * kontrol hanesi taşımaz.
 *
 * Barkodumuz 11 haneli sayısal (YY + 8 hane + Luhn). SET C çift haneyi tek
 * simgeye sıkıştırdığı için tek sayıda hane kalınca SET B'ye geçilir - burada
 * ilk haneyi B ile kodlayıp kalan çiftleri C ile yazıyoruz: 11 hane için
 * 1 + 5 = 6 simge (hepsi B olsaydı 11 simge, etiket iki katı genişlerdi).
 */

/** Code 128 desen tablosu: 0-106, her biri 11 modüllük bar/boşluk dizisi. */
const DESEN = [
  '11011001100', '11001101100', '11001100110', '10010011000', '10010001100',
  '10001001100', '10011001000', '10011000100', '10001100100', '11001001000',
  '11001000100', '11000100100', '10110011100', '10011011100', '10011001110',
  '10111001100', '10011101100', '10011100110', '11001110010', '11001011100',
  '11001001110', '11011100100', '11001110100', '11101101110', '11101001100',
  '11100101100', '11100100110', '11101100100', '11100110100', '11100110010',
  '11011011000', '11011000110', '11000110110', '10100011000', '10001011000',
  '10001000110', '10110001000', '10001101000', '10001100010', '11010001000',
  '11000101000', '11000100010', '10110111000', '10110001110', '10001101110',
  '10111011000', '10111000110', '10001110110', '11101110110', '11010001110',
  '11000101110', '11011101000', '11011100010', '11011101110', '11101011000',
  '11101000110', '11100010110', '11101101000', '11101100010', '11100011010',
  '11101111010', '11001000010', '11110001010', '10100110000', '10100001100',
  '10010110000', '10010000110', '10000101100', '10000100110', '10110010000',
  '10110000100', '10011010000', '10011000010', '10000110100', '10000110010',
  '11000010010', '11001010000', '11110111010', '11000010100', '10001111010',
  '10100111100', '10010111100', '10010011110', '10111100100', '10011110100',
  '10011110010', '11110100100', '11110010100', '11110010010', '11011011110',
  '11011110110', '11110110110', '10101111000', '10100011110', '10001011110',
  '10111101000', '10111100010', '11110101000', '11110100010', '10111011110',
  '10111101110', '11101011110', '11110101110', '11010000100', '11010010000',
  '11010011100', '11000111010',
];

const START_B = 104, START_C = 105, KOD_C = 99, STOP = 106;

/**
 * Kodlanacak simge değerlerini üretir (start ve sağlama dahil değil).
 * Sayısal olmayan girdi tamamen SET B ile kodlanır.
 */
function degerler(metin: string): { baslangic: number; degerler: number[] } {
  const sayisal = /^\d+$/.test(metin);
  if (!sayisal) {
    return {
      baslangic: START_B,
      // SET B: değer = ASCII − 32. Yazdırılamayan karakter gelirse boşluk.
      degerler: [...metin].map(k => {
        const n = k.charCodeAt(0) - 32;
        return n >= 0 && n <= 94 ? n : 0;
      }),
    };
  }

  // Tek sayıda hane: ilk hane SET B, kalan çiftler SET C.
  const tek = metin.length % 2 === 1;
  const d: number[] = [];
  let i = 0;
  if (tek) {
    d.push(metin.charCodeAt(0) - 32);   // '0'-'9' → 16-25
    d.push(KOD_C);                      // set değiştir
    i = 1;
  }
  for (; i + 1 < metin.length; i += 2) d.push(Number(metin.slice(i, i + 2)));
  return { baslangic: tek ? START_B : START_C, degerler: d };
}

/**
 * Code 128 sağlama hanesi: (start + Σ i·değer) mod 103.
 * Tarayıcı bunu doğrular; yanlış hesaplanan barkod hiç okunmaz - "etiket
 * bastı ama cihaz okumuyor" şikâyetinin en sık nedeni budur.
 */
export function code128Saglama(baslangic: number, deger: number[]): number {
  let toplam = baslangic;
  deger.forEach((d, i) => { toplam += d * (i + 1) });
  return toplam % 103;
}

/**
 * Barkodun bar/boşluk dizisini "1"/"0" katarı olarak döndürür.
 * Boş metin boş katar verir (çağıran çizmez).
 */
export function code128Desen(metin: string): string {
  if (!metin) return '';
  const { baslangic, degerler: d } = degerler(metin);
  const kodlar = [baslangic, ...d, code128Saglama(baslangic, d), STOP];
  // Sondaki 2 modüllük bitiş çubuğu standardın parçası ("11").
  return kodlar.map(k => DESEN[k]).join('') + '11';
}
