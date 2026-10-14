/**
 * AVATAR BAŞ HARFLERİ - tek kural, her ekranda aynı (kullanıcı 14.10.2026: "avatarda baş
 * harfleri kullanırken unvan kullanma, sadece ad ve soyad baş harfleri kullan").
 *
 *   "Dr. Osman AKAR" -> "OA" · "Prof. Dr. Ayşe Nur Öztürk" -> "AÖ" · "Op.Dr. Ali Can" -> "AC"
 *   "Uzm. Dr. Elif (çağrı)" -> "E" yerine tek kelimede ilk iki harf: "EL" · "" -> "?"
 *
 * Ünvan: bilinen önekler (Dr, Prof, Doç, Op, Uzm, Yrd, Öğr, Gör, Dt, Ecz, Hem, Psk, Dyt,
 * Fzt, Av, Müh, Sn) noktalı ya da noktasız, ve noktayla biten her kelime atlanır.
 * Parantezli ekler ("(çağrı)", "(yedek)") ve harfle başlamayan parçalar da atlanır.
 */
const UNVANLAR = new Set(['dr', 'prof', 'doç', 'doc', 'op', 'uzm', 'uz', 'yrd', 'öğr', 'ogr', 'gör', 'gor',
  'dt', 'ecz', 'hem', 'psk', 'dyt', 'fzt', 'av', 'müh', 'muh', 'sn', 'doçent', 'profesör', 'doktor']);

export function basHarfler(ad: string | null | undefined): string {
  const parcalar = String(ad ?? '')
    .replace(/\([^)]*\)/g, ' ')
    .replace(/\./g, '. ')
    .split(/\s+/)
    .filter(x => x && /^\p{L}/u.test(x) && !x.endsWith('.')
                 && !UNVANLAR.has(x.toLocaleLowerCase('tr-TR')));
  if (parcalar.length === 0) return '?';
  if (parcalar.length === 1) return parcalar[0].slice(0, 2).toLocaleUpperCase('tr-TR');
  return (parcalar[0][0] + parcalar[parcalar.length - 1][0]).toLocaleUpperCase('tr-TR');
}
