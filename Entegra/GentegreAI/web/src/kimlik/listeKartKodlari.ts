/**
 * LİSTE / KART YETKİ AYRIMI (1115 aşama 2 + 1128 pilot; sunucu: EkranKodlari.YalnizGorListe).
 *
 * Menüdeki liste ekranının kodu (anahtar) yalnız GÖR taşır; kartın işlemleri değerdeki koddadır.
 * Bu tablo sunucudakiyle AYNI kalmalı (listeKartKodlari testi menü tanımlarıyla denetler).
 * Kurala yeni ekran eklemek: buraya, sunucu tablosuna ve bir göçe (1128 örnek) aynı satır.
 */
export const LISTE_KART_KODU: Readonly<Record<string, string>> = {
  'hasta.liste': 'hasta',
  'basvuru.liste': 'belge',
  'randevu.liste': 'randevu',
  'randevu.plan.sablon.liste': 'randevu.plan.sablon',
  'randevu.plan.istisna.liste': 'randevu.plan.istisna',
  'radyoloji-istem.liste': 'radyoloji-istem',
  'radyoloji.sablon.liste': 'radyoloji.sablon',
  'radyoloji.protokol.liste': 'radyoloji.protokol',
  'radyoloji.cihaz.liste': 'radyoloji.cihaz',
  'teleradyoloji.liste': 'teleradyoloji',
  'teleradyoloji.kurum.liste': 'teleradyoloji.kurum',
  'teleradyoloji.nobet.liste': 'teleradyoloji.nobet',
  'teleradyoloji.kural.liste': 'teleradyoloji.kural',
  'teleradyoloji.sozlesme.liste': 'teleradyoloji.sozlesme',
};

/** Liste ekranı kodunun kart kodu; ayrım yoksa kodun kendisi. */
export const kartKodu = (listeKodu: string): string => LISTE_KART_KODU[listeKodu] ?? listeKodu;

/** Kod yalnız Gör taşıyan bir liste ekranı mı. */
export const yalnizGorListe = (kod: string) => kod in LISTE_KART_KODU;
