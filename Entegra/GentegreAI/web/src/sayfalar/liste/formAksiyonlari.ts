import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';

/**
 * FORM MOTORU (740) liste aksiyonları: şablon kopyala / önizle / editör,
 * istek aç / hatırlat / yeniden / iptal, hasta listesinden Formlar.
 */
export async function formAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                   b: { tazele(): void; git(yol: string): void; geri: string }): Promise<boolean> {
  if (!kod.startsWith('form.')) return false;
  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir satır seçin.'); return true }
  const geri = `?geri=${encodeURIComponent(b.geri)}`;

  if (kod === 'form.sablon-kopyala') {
    if (!await onay('Şablon yeni kodla kopyalansın mı? (taslak olarak)')) return true;
    await guvenli(async () => { const y = await api.formSablonKopyala(id); mesaj('Kopya oluşturuldu.'); b.tazele(); b.git(`/form-editor/${y.id}${geri}`) });
    return true;
  }
  if (kod === 'form.sablon-onizle' || kod === 'form.sablon-editor') { b.git(`/form-editor/${id}${geri}`); return true }
  if (kod === 'form.istek-ac') { b.git(`/form-doldur/${id}${geri}`); return true }
  if (kod === 'form.istek-hatirlat') {
    await guvenli(async () => { await api.formHatirlat(id); mesaj('Hatırlatma kuyruğa alındı.'); b.tazele() });
    return true;
  }
  if (kod === 'form.istek-yeniden') {
    if (!await onay('Eski bağlantı iptal edilip yeni bağlantı gönderilsin mi?')) return true;
    await guvenli(async () => { const y = await api.formYeniden(id); mesaj(y.bildirimId ? 'Yeni bağlantı kuyruğa alındı.' : `Yeni istek #${y.id}`); b.tazele() });
    return true;
  }
  if (kod === 'form.istek-iptal') {
    if (!await onay('İstek iptal edilsin mi? Bağlantı geçersiz olur.', true)) return true;
    await guvenli(async () => { await api.formIptal(id); b.tazele() });
    return true;
  }
  if (kod === 'form.hasta-formlar') { b.git(`/hasta-formlar/${id}${geri}`); return true }
  return false;
}
