import type { HastaIcmali, IcmalTahsilat } from '../../../api/uclar/hastaIcmal';

/** Hasta icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export const tarihKisa = (t: string | null | undefined) =>
  (t ? new Date(t).toLocaleDateString('tr-TR') : '—');

export const isoGun = (d: Date) => d.toISOString().slice(0, 10);

/** Ödeme rozeti: kasa hesabının türünden (K nakit, P POS, B banka). */
export function odemeRozeti(t: IcmalTahsilat): { ad: string; renk: string } {
  if (t.iptal) return { ad: 'iptal', renk: 'pas' };
  if (t.iade) return { ad: 'iade', renk: 'kir' };
  if (t.hesapTuru === 'K') return { ad: 'nakit', renk: 'sari' };
  if (t.hesapTuru === 'P') return { ad: 'POS', renk: 'mavi' };
  if (t.hesapTuru === 'B') return { ad: 'havale', renk: 'mavi' };
  return { ad: t.tur.toLocaleLowerCase('tr-TR'), renk: '' };
}

export type Hareket = { t: string; belge: string; aciklama: string; borc: number; alacak: number; bakiye: number };

/**
 * HAREKET ÖZETİ (cari ekstre gibi): başvurunun HASTA PAYI borç, tahsilat
 * alacak, iade borç; tarihe göre sıralı yürüyen bakiye. İptal başvuru ve
 * iptal tahsilat girmez. Kurum payı borç yazılmaz - hastadan istenmez.
 */
export function hareketleriKur(v: Pick<HastaIcmali, 'basvurular' | 'tahsilatlar'>): Hareket[] {
  const satir = [
    ...v.basvurular.filter(b => !b.iptal).map(b => ({
      t: b.tarih ?? '', belge: b.no, aciklama: `Başvuru · ${b.bolum || '—'} · hasta payı`,
      borc: b.hastaPayi, alacak: 0 })),
    ...v.tahsilatlar.filter(t => !t.iptal).map(t => ({
      t: t.tarih ?? '', belge: t.makbuzNo, aciklama: `${t.tur}${t.basvuruNo ? ` · ${t.basvuruNo}` : ''}`,
      borc: t.iade ? t.tutar : 0, alacak: t.iade ? 0 : t.tutar })),
  ].sort((a, b) => a.t.localeCompare(b.t));
  let bakiye = 0;
  return satir.map(s => { bakiye += s.borc - s.alacak; return { ...s, bakiye } });
}

/** Başvurunun durum rozeti. */
export function basvuruDurumu(b: { iptal: boolean; kalan: number; tahsil: number }): { ad: string; renk: string } {
  if (b.iptal) return { ad: 'İptal', renk: 'pas' };
  if (b.kalan > 0.005) return { ad: b.tahsil > 0 ? 'Kısmi' : 'Açık', renk: 'sari' };
  return { ad: 'Kapandı', renk: 'ok' };
}
