import { MEDULA_DONEM_DURUM, MEDULA_FATURA_DURUM } from '../../../api/uclar/medula';
import type { MutabakatKesintisi } from '../../../api/uclar/medulaMutabakat';

/** Medula mutabakat icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Medula kod listesi renkleri (gri / uyari / mavi / ok) icmal rozet sınıflarına. */
const RENK: Record<string, string> = { gri: 'pas', uyari: 'sari', mavi: 'mavi', ok: 'ok' };
const rozet = (s: Record<number, [string, string]>, d: number): Rozet =>
  s[d] ? { ad: s[d][0], renk: RENK[s[d][1]] ?? '' } : { ad: '—', renk: 'pas' };

export const faturaDurumRozeti = (d: number) => rozet(MEDULA_FATURA_DURUM, d);
export const donemDurumRozeti = (d: number) => rozet(MEDULA_DONEM_DURUM, d);

/**
 * FATURASIZ TAKİP NEDENİ (sunucunun `neden` kodu): huninin hangi adımında
 * kaldığı ve ne yapılacağı. Yalnız "hazir" toplu faturalamaya girer.
 */
export function nedenRozeti(neden: string): Rozet & { yapilacak: string } {
  switch (neden) {
    case 'hizmet_yok': return { ad: 'Hizmet girilmemiş', renk: 'kir', yapilacak: 'Başvuruya hizmet satırı girin' };
    case 'hizmet_hatali': return { ad: 'Hizmet hatalı', renk: 'kir', yapilacak: 'Medula hatasını düzeltip yeniden gönderin' };
    case 'hizmet_gonderilmedi': return { ad: "Hizmet Medula'ya gitmedi", renk: 'sari', yapilacak: 'Hizmet kaydını gönderin' };
    case 'cikis_yok': return { ad: 'Takip çıkışı yok', renk: 'sari', yapilacak: 'Takibe çıkış verin' };
    case 'taslak': return { ad: 'Fatura taslakta', renk: 'sari', yapilacak: 'Faturayı kaydedin' };
    case 'hazir': return { ad: 'Faturaya hazır', renk: 'mavi', yapilacak: 'Faturala' };
    default: return { ad: neden || '—', renk: 'pas', yapilacak: '' };
  }
}

/** Kesinti itiraz durumu (medula.itiraz_durum). */
export function itirazRozeti(k: Pick<MutabakatKesintisi, 'itirazDurum'>): Rozet {
  switch (k.itirazDurum) {
    case 1: return { ad: 'İtiraz bekliyor', renk: 'sari' };
    case 2: return { ad: 'Kabul · iade', renk: 'ok' };
    case 3: return { ad: 'Reddedildi', renk: 'kir' };
    default: return { ad: 'İtiraz edilmedi', renk: 'pas' };
  }
}

/** Huni çubuğu genişliği - ilk adıma göre yüzde. */
export const huniYuzde = (adet: number, ilk: number) => (ilk > 0 ? Math.round((100 * adet) / ilk) : 0);

/** Varsayılan dönem: geçen ay. */
export function gecenAyYilAy(bugun = new Date()): { yil: number; ay: number } {
  const d = new Date(bugun.getFullYear(), bugun.getMonth() - 1, 1);
  return { yil: d.getFullYear(), ay: d.getMonth() + 1 };
}

export const AY_ADLARI = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
