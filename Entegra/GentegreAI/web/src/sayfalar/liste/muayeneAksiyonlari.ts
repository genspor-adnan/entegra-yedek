import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * MUAYENE LISTE AKSIYONLARI (409, Faz 1).
 *
 * Iki dugme, iki durum gecisi:
 *
 *   * "Muayeneye Al" baslangic zamanini yazar - USS Muayene Baslangic.
 *     Kartin acilma zamani DEGIL: kart sabah acilip hasta ogleden sonra
 *     girebilir. Ikinci tikta zaman ezilmez (kural sunucuda).
 *   * "Tamamla" kaydi kilitler, basvuruyu tahakkuka dondurur ve e-Nabiz
 *     kuyruguna atar; geri alinamaz, bu yuzden ONAY istenir. Eksik kayit
 *     sunucuda reddedilir (ana tani + sikayet + karar) - hata mesaji
 *     eksiklerin HEPSINI birden sayar.
 */
export interface MuayeneBaglam {
  tazele(): void;
}

export async function muayeneAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: MuayeneBaglam,
): Promise<boolean> {
  if (kod !== 'muayene.al' && kod !== 'muayene.tamamla') return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir muayene seçin.'); return true }
  const hasta = String(satir?.hastaAdi ?? '');

  if (kod === 'muayene.al') {
    await guvenli(async () => {
      const y = await api.muayeneyeAl(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (!await onay(`${hasta} muayenesi tamamlansın mı?\n\n`
                + 'Kayıt kilitlenir, başvuru tahakkuka döner ve e-Nabız kuyruğuna girer.'))
    return true;

  await guvenli(async () => {
    const y = await api.muayeneTamamla(id);
    mesaj(y.uyari ? `${y.mesaj}\n\n⚠ ${y.uyari}` : y.mesaj);
    b.tazele();
  });
  return true;
}
