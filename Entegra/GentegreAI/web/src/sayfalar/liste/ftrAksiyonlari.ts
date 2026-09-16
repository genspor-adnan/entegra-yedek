import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';

/** FTR (719) liste aksiyonları: seans planla / bugünkü seans / sonlandır / seans bitir / gelmedi. */
export async function ftrAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                  b: { tazele(): void; git(yol: string): void }): Promise<boolean> {
  if (!kod.startsWith('ftr.')) return false;
  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir satır seçin.'); return true }

  if (kod === 'ftr.program-planla') {
    if (!await onay('Seanslar sıklığa göre planlansın mı? (mevcut planlı seanslar korunur)')) return true;
    await guvenli(async () => { const y = await api.ftrPlanla(id); mesaj(`${y.eklenen} seans planlandı.`); b.tazele() });
    return true;
  }
  if (kod === 'ftr.program-seans-ac') {
    await guvenli(async () => { const y = await api.ftrSeansAc(id); b.git(`/ftr-seans/${y.id}`) });
    return true;
  }
  if (kod === 'ftr.program-sonlandir') {
    const not = await metinSor('Sonlandırma / kür sonu notu:'); if (not === null) return true;
    await guvenli(async () => { const y = await api.ftrSonlandir(id, { not }); mesaj(y.durum === 4 ? 'Kür tamamlandı.' : 'Program sonlandırıldı.'); b.tazele() });
    return true;
  }
  if (kod === 'ftr.seans-bitir') {
    if (!await onay('Seans bitirilsin mi?')) return true;
    await guvenli(async () => { const y = await api.ftrSeansBitir(id); mesaj(`Seans bitti · ${y.yapilan}/${y.seansSayisi}${y.uyari ? ` — ${y.uyari}` : ''}`); b.tazele() });
    return true;
  }
  if (kod === 'ftr.seans-gelmedi') {
    if (!await onay('Hasta gelmedi olarak işaretlensin mi?')) return true;
    await guvenli(async () => { const y = await api.ftrSeansGelmedi(id); mesaj(`Devamsızlık ${y.devamsiz}`); b.tazele() });
    return true;
  }
  return false;
}
