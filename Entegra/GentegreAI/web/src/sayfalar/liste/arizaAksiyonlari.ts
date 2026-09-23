import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * ARIZA / TALEP AKSİYONLARI (hizmet masası, 911).
 *
 * EKİP AKIŞI: devral (sorumlu = ben, İşlemde) → çöz (not zorunlu) → kapat.
 * Kural sunucuda (durum geçiş guard'ları uçta); ekran yalnız düğmeyi uca
 * bağlar ve reddi kullanıcıya olduğu gibi gösterir. Kart yok - serbest
 * düzenleme değil, sabit akış.
 */
export interface ArizaBaglam {
  tazele(): void;
}

export async function arizaAksiyonu(
  kod: string, satir: ListeSatiri | null | undefined, b: ArizaBaglam,
): Promise<boolean> {
  if (!kod.startsWith('ariza.')) return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir talep seçin.'); return true }

  if (kod === 'ariza.devral') {
    if (!await onay('Bu talebi devralıyorsunuz. Sorumlusu siz olacak, '
                  + 'durum "İşlemde" olarak işaretlenecek.')) return true;
    await guvenli(async () => {
      const y = await api.arizaDevral(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'ariza.coz') {
    const not = await metinSor('Yapılan iş / çözüm (zorunlu):', '', 'Çözüm notu');
    if (!not) return true;
    await guvenli(async () => {
      const y = await api.arizaCoz(id, not);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'ariza.kapat') {
    if (!await onay('Talep kapatılacak. Kapanış zamanı damgalanır.')) return true;
    await guvenli(async () => {
      const y = await api.arizaKapat(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  return false;
}
