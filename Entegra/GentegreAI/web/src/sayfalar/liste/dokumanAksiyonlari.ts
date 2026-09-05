import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * DOKUMAN AKSIYONLARI (419) - surum ve onay dongusu.
 *
 * Onay kuyrugunda satir = ADIM, dokuman degil: ayni dokuman iki adimda iki
 * farkli kisiyi bekliyor olabilir ve herkes yalniz kendi adimini gormeli.
 *
 * RET dokumani TASLAGA dondurur; hazirlayan duzeltip yeni surum acar.
 * Reddedilen surumu yeniden onaya gondermek, neyin degistigini gorunmez
 * kilardi - denetimde "hangi haliyle onaylandi" sorusu cevapsiz kalirdi.
 */
export interface DokumanBaglam {
  tazele(): void;
}

export async function dokumanAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: DokumanBaglam,
): Promise<boolean> {
  if (kod !== 'dokuman.onay' && kod !== 'dokuman.ret'
      && kod !== 'dokuman.onaya-gonder') return false;

  if (kod === 'dokuman.onaya-gonder') {
    const dokumanId = Number(satir?.id ?? 0);
    if (!dokumanId) { mesaj('Önce bir doküman seçin.'); return true }
    if (Number(satir?.surumlu ?? 0) !== 1) {
      mesaj('Bu tür sürümsüz: yüklenen dosya doğrudan yayında olur, onay akışı yok.');
      return true;
    }
    mesaj('Onaya göndermek için doküman kartından ilgili sürümü seçin.');
    return true;
  }

  const onayId = Number(satir?.onayId ?? 0);
  if (!onayId) { mesaj('Önce bir onay adımı seçin.'); return true }
  const ad = String(satir?.dokumanAd ?? '');

  if (kod === 'dokuman.onay') {
    if (!await onay(`"${ad}" onaylansın mı?\n\n`
                  + 'Son adımsa sürüm yayınlanır ve önceki sürüm arşive düşer.')) return true;
    await guvenli(async () => {
      const y = await api.dokumanOnayKarar(onayId, 1);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  // RET GEREKÇESİ ZORUNLU: hazırlayan neyi düzelteceğini bilmeli.
  const gerekce = await metinSor(`"${ad}" neden reddediliyor?`, '', 'Gerekçe');
  if (gerekce === null) return true;
  if (!gerekce.trim()) { mesaj('Ret gerekçesi zorunlu.'); return true }

  await guvenli(async () => {
    const y = await api.dokumanOnayKarar(onayId, 2, gerekce.trim());
    mesaj(y.mesaj);
    b.tazele();
  });
  return true;
}
