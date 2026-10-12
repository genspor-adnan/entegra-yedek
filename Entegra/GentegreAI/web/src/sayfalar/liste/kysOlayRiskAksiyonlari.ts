import type { ListeSatiri } from '../../api/sozlesme';
import { mesaj } from '../../bilesenler/mesaj';

/** DÖF kaynak türü (1048 sözleşmesi): 2 olay bildirimi · 4 risk. */
const DOF_KAYNAK = { 'kys.olay-dof': 2, 'kys.risk-dof': 4 } as const;

/**
 * DÖF açma adresi - DÖF kartı (1050) kaynağı sorgu parametrelerinden okur.
 * Tanım satırdaki açıklamadan (olay: tür + zarar, risk: tanım) kısaltılır.
 */
export function dofAcmaYolu(kaynakTur: number, satir: ListeSatiri): string {
  const tanim = kaynakTur === 2
    ? [satir.turAdi, satir.zararAdi].filter(Boolean).join(' · ')
    : String(satir.tanim ?? '');
  const p = new URLSearchParams({
    kaynakTur: String(kaynakTur),
    kaynakId: String(satir.id ?? ''),
    kaynakNo: String(satir.no ?? ''),
    tanim: tanim.slice(0, 300),
  });
  if (satir.departmanId) p.set('birimId', String(satir.departmanId));
  return `/kys-dof/yeni?${p}`;
}

/**
 * KURUMSAL KALİTE (1052) olay / risk liste aksiyonları: yalnız "DÖF aç".
 * Kayıt ekle / düzenle generic kartta (Crud). Kodlar TAM eşleşir - aynı
 * `kys.` önekini diğer kalite ekranları da kullanır.
 */
export async function kysOlayRiskAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                          b: { git(yol: string): void }): Promise<boolean> {
  if (kod !== 'kys.olay-dof' && kod !== 'kys.risk-dof') return false;
  if (!satir?.id) { mesaj('Önce bir satır seçin.'); return true }
  b.git(dofAcmaYolu(DOF_KAYNAK[kod], satir));
  return true;
}
