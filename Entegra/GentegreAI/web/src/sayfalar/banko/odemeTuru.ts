/**
 * ÖDEME TÜRÜ İKONU (kullanıcı 09.10.2026: "ödeme türleri mockup gibi
 * ikonlu"): banko oturumu ve vezne icmali aynı ikonu kullanır. Tür ayrımı
 * ana hesap türünden: K nakit, P POS, B havale; grup çek/senet ve kupon.
 */
export function odemeTuruIkonu(x: { hesapTuru: string; turGrup: string }): string {
  if (x.hesapTuru === 'K') return '💵';
  if (x.hesapTuru === 'P') return '💳';
  if (x.hesapTuru === 'B') return '🏦';
  if (x.turGrup === 'ceksenet') return '🧾';
  if (x.turGrup === 'kupon') return '🎟';
  return '💠';
}
