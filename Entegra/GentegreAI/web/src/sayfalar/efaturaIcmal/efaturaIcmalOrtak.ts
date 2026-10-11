/** Fatura / e-Belge icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);

/** GİB'e ulaşma oranı: %100 yeşil, %95 üstü sarı, altı kırmızı. */
export function ulasanRozeti(n: number | null | undefined): Rozet {
  if (n == null) return { ad: '—', renk: 'pas' };
  return { ad: yuzde(n), renk: n >= 100 ? 'ok' : n >= 95 ? 'sari' : 'kir' };
}

/** Sorun rozeti rengi. */
export function sorunRengi(sorun: string): string {
  return sorun === 'Gönderim hatası' ? 'kir' : sorun === "GİB'e gitmedi" ? 'kir'
    : sorun === 'e-Belge hazırlanmadı' ? 'sari' : 'pas';
}

/** e-Belge durumu rozeti (iade / iptal listeleri). */
export function durumRengi(durum: string): string {
  return durum === 'Gönderildi' ? 'ok' : durum === 'Gönderim hatası' ? 'kir' : durum === 'Hazır' ? 'sari' : 'pas';
}

/** Yeniden gönderilebilir mi: yalnız HAZIR (hazırlanmış, gönderilmemiş) belge. */
export const gonderilebilir = (s: { hazir: boolean; gonderildi: boolean }) => s.hazir && !s.gonderildi;
