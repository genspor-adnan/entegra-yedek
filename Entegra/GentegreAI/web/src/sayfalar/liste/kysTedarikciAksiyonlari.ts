import type { ListeSatiri } from '../../api/sozlesme';
import { mesaj } from '../../bilesenler/mesaj';

/** DÖF kaynak türü (1048 sözleşmesi): 8 tedarikçi. kaynakId = tedarikçinin taraf id'si. */
const KAYNAK_TEDARIKCI = 8;

/** Tedarikçi satırından DÖF açma adresi - DÖF kartı (1050) kaynağı sorgudan okur. */
export function tedarikciDofYolu(satir: ListeSatiri): string {
  const ad = String(satir.tedarikciAdi ?? '');
  const tanim = [ad, satir.sonucAdi ? `değerlendirme: ${satir.sonucAdi} (${satir.puan ?? ''})` : '']
    .filter(Boolean).join(' · ');
  const p = new URLSearchParams({
    kaynakTur: String(KAYNAK_TEDARIKCI),
    kaynakId: String(satir.tarafId ?? ''),
    kaynakNo: ad.slice(0, 40),
    tanim: tanim.slice(0, 300),
  });
  return `/kys-dof/yeni?${p}`;
}

/** Aynı tedarikçiye yeni değerlendirme kartı (tedarikçi ve "ne alıyoruz" dolu). */
export function tedarikciYenidenYolu(satir: ListeSatiri): string {
  const p = new URLSearchParams({ tarafId: String(satir.tarafId ?? '') });
  if (satir.neAliniyor) p.set('neAliniyor', String(satir.neAliniyor));
  return `/kys-tedarikci/yeni?${p}`;
}

/**
 * KURUMSAL KALİTE (1057) tedarikçi liste aksiyonları. Ekle / düzenle / sil
 * generic kartta (Crud). Kodlar TAM eşleşir.
 */
export async function kysTedarikciAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                           b: { git(yol: string): void }): Promise<boolean> {
  if (kod !== 'kys.tedarikci-dof' && kod !== 'kys.tedarikci-yeniden') return false;
  if (!satir?.tarafId) { mesaj('Önce bir satır seçin.'); return true }
  b.git(kod === 'kys.tedarikci-dof' ? tedarikciDofYolu(satir) : tedarikciYenidenYolu(satir));
  return true;
}
