import type { ListeSatiri } from '../../api/sozlesme';
import { mesaj } from '../../bilesenler/mesaj';
import { dofAcmaYolu } from './kysOlayRiskAksiyonlari';

const KODLAR = new Set(['kys.gosterge-dof', 'kys.karar-dof', 'kys.bulgu-dof', 'kys.denetim-bulgular']);

/**
 * KURUMSAL KALİTE (1059) "DÖF aç" bağları - kaynak_tur 1048 sözleşmesi:
 *   kys.gosterge-dof  7 hedef dışı gösterge (Politika & Hedefler)
 *   kys.karar-dof     6 YGG / toplantı kararı (Karar Takibi)
 *   kys.bulgu-dof     1 iç denetim bulgusu (Denetim Bulguları)
 * ve denetim listesinden seçili denetimin bulgu listesine geçiş
 * (kys.denetim-bulgular). Kodlar TAM eşleşir.
 */
export async function kysDofBagAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                        b: { git(yol: string): void }): Promise<boolean> {
  if (!KODLAR.has(kod)) return false;
  if (!satir?.id) { mesaj('Önce bir satır seçin.'); return true }
  const s = satir;

  if (kod === 'kys.denetim-bulgular') {
    b.git(`/kys-denetim-bulgu?denetimId=${s.id}`);
    return true;
  }

  const kaynak = kod === 'kys.gosterge-dof'
    ? { tur: 7, no: String(s.kod ?? ''),
        tanim: `Hedef dışı: ${s.ad ?? ''} — son değer ${s.sonDeger ?? '-'}, hedef ${s.hedefMetin || '-'}` }
    : kod === 'kys.karar-dof'
    ? { tur: 6, no: `${s.kurulAdi ?? ''} ${s.toplantiTarihi ? String(s.toplantiTarihi).slice(0, 10) : ''}`.trim(),
        tanim: String(s.karar ?? '') }
    : { tur: 1, no: String(s.denetimNo ?? ''),
        tanim: `${s.sinifAdi ? `${s.sinifAdi} bulgu` : 'Bulgu'}${s.madde ? ` (${s.madde})` : ''}: ${s.aciklama ?? ''}` };

  b.git(dofAcmaYolu(kaynak.tur, { id: s.id, no: kaynak.no.slice(0, 40), tanim: kaynak.tanim, departmanId: s.departmanId }));
  return true;
}
