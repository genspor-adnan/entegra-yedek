import type { ListeSatiri } from '../../api/sozlesme';

/**
 * KURUMSAL KALİTE — KALİTE DOKÜMANLARI (1068) liste aksiyonu: "🗄️ Tüm
 * Dokümanlar" Doküman modülünün listesine gider (mockup). Yükle / Aç
 * Doküman modülünün kendi aksiyonları (dokumanAksiyonlari).
 */
export async function kysDokumanAksiyonu(kod: string, _satir: ListeSatiri | null | undefined,
                                         b: { git(yol: string): void }): Promise<boolean> {
  if (kod !== 'kys.dokuman-tumu') return false;
  b.git('/dokuman');
  return true;
}
