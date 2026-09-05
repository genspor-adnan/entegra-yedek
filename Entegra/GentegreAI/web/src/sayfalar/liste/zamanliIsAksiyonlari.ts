import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * ZAMANLI IS LISTE AKSIYONLARI (405).
 *
 * Tek is var: "Simdi Calistir" - zamani beklemeden denemek ve kacan bir isi
 * telafi etmek icin. Kilit SUNUCUDA (is zaten calisiyorsa ikinci kez
 * baslamaz); burasi yalnizca sonucu kullaniciya soyler.
 *
 * ONAY ISTENIR: bazi isler dis servise gidiyor ve uzun suruyor (TITCK listesi
 * 23 bin satir) - yanlislikla basilan dugme sessizce dakikalarca calismasin.
 */
export interface ZamanliIsBaglam {
  tazele(): void;
}

export async function zamanliIsAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: ZamanliIsBaglam,
): Promise<boolean> {
  if (kod !== 'zamanli-is.calistir') return false;

  const isKodu = String(satir?.kod ?? '');
  if (!isKodu) { mesaj('Önce bir iş seçin.'); return true }

  const ad = String(satir?.ad ?? isKodu);
  if (!await onay(`"${ad}" şimdi çalıştırılsın mı?\n\n`
                + 'İş dış servise gidebilir ve bir süre sürebilir.')) return true;

  await guvenli(async () => {
    const y = await api.zamanliIsCalistir(isKodu);
    mesaj(y.sonuc || 'İş çalıştı.');
    b.tazele();
  });
  return true;
}
