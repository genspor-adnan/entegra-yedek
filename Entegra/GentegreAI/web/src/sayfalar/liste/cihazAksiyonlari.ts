import { api } from '../../api/istemci';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * CIHAZ AKSIYONLARI (432).
 *
 * <b>Yeniden İşle</b> ham metni SAKLADIĞIMIZ için mümkün: sürücü düzeltilince
 * cihazdan tekrar sonuç istemek gerekmiyor - cihazlar çoğu zaman aynı sonucu
 * ikinci kez göndermez.
 */
export interface CihazBaglam {
  tazele(): void;
}

export async function cihazAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: CihazBaglam,
): Promise<boolean> {
  if (!kod.startsWith('cihaz.')) return false;
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  if (kod === 'cihaz.klasor-tara') {
    await guvenli(async () => {
      const y = await api.cihazKlasorTara();
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'cihaz.yeniden-isle') {
    const id = Number(satir?.id ?? 0);
    if (!id) { mesaj('Önce bir mesaj seçin.'); return true }
    await guvenli(async () => {
      mesaj((await api.cihazYenidenIsle(id)).mesaj);
      b.tazele();
    });
    return true;
  }

  return false;
}
