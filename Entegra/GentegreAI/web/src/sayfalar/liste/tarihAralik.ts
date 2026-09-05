/**
 * HAZIR TARİH ARALIKLARI (kullanıcı: başvuru listesi şeridinde "Bugün / Dün /
 * Son 3 Gün / Son 1 Hafta / Son 1 Ay / Son 3 Ay / Bu Yıl").
 *
 * Hesap YEREL günden yapılır: `toISOString` UTC'ye kaydırdığı için gece
 * yarısına yakın saatlerde "Bugün" bir önceki güne düşüyordu.
 *
 * "Son N gün" BUGÜNÜ DE SAYAR: kullanıcı "son 3 gün" derken bugün + iki gün
 * öncesini kastediyor, bugünü dışarıda bırakan bir aralık boş görünürdü.
 */
export type TarihOnAyar =
  | 'bugun' | 'dun' | 'son3gun' | 'son1hafta' | 'son1ay' | 'son3ay' | 'buyil';

export const TARIH_ON_AYARLAR: { deger: TarihOnAyar; ad: string }[] = [
  { deger: 'bugun',     ad: 'Bugün' },
  { deger: 'dun',       ad: 'Dün' },
  { deger: 'son3gun',   ad: 'Son 3 Gün' },
  { deger: 'son1hafta', ad: 'Son 1 Hafta' },
  { deger: 'son1ay',    ad: 'Son 1 Ay' },
  { deger: 'son3ay',    ad: 'Son 3 Ay' },
  { deger: 'buyil',     ad: 'Bu Yıl' },
];

const gun = (t: Date) =>
  `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}-${String(t.getDate()).padStart(2, '0')}`;

/** Ön ayarın [başlangıç, bitiş] günü. Gün metni `yyyy-MM-dd`. */
export function tarihAraligi(onAyar: TarihOnAyar): { bas: string; bit: string } {
  const b = new Date();
  const gunOnce = (n: number) => new Date(b.getFullYear(), b.getMonth(), b.getDate() - n);
  const ayOnce = (n: number) => new Date(b.getFullYear(), b.getMonth() - n, b.getDate());

  switch (onAyar) {
    // Dün TEK GÜN: hem başı hem sonu dün - "dünden bugüne" değil.
    case 'dun':       return { bas: gun(gunOnce(1)), bit: gun(gunOnce(1)) };
    case 'son3gun':   return { bas: gun(gunOnce(2)),  bit: gun(b) };
    case 'son1hafta': return { bas: gun(gunOnce(6)),  bit: gun(b) };
    case 'son1ay':    return { bas: gun(ayOnce(1)),   bit: gun(b) };
    case 'son3ay':    return { bas: gun(ayOnce(3)),   bit: gun(b) };
    case 'buyil':     return { bas: `${b.getFullYear()}-01-01`, bit: gun(b) };
    case 'bugun':
    default:          return { bas: gun(b), bit: gun(b) };
  }
}
