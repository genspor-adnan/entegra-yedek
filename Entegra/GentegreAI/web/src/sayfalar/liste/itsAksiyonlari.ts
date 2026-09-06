import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * ITS BILDIRIM AKSIYONLARI (427).
 *
 * GONDERILMIS bildirim IPTAL EDILEMEZ: ITS'de kayit olustu, geri almak ayri
 * bir bildirim turudur (iade / deaktivasyon). Kural sunucuda; dugme yine de
 * gosterilir ki kullanici sebebini ogrensin - gizlenen bir dugme "neden
 * yapamiyorum" sorusunu cevapsiz birakirdi.
 */
export interface ItsBaglam {
  tazele(): void;
}

export async function itsAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: ItsBaglam,
): Promise<boolean> {
  if (kod !== 'its.gonder' && kod !== 'its.iptal') return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir bildirim seçin.'); return true }

  if (kod === 'its.gonder') {
    await guvenli(async () => {
      const y = await api.itsGonder(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  const kutu = String(satir?.kutuSayisi ?? '');
  if (!await onay(`Bildirim iptal edilsin mi? (${kutu} kutu)\n\n`
                + 'Gönderilmiş bildirim iptal edilemez; İTS\'de kayıt oluştuysa '
                + 'iade ya da deaktivasyon gerekir.', true)) return true;

  await guvenli(async () => {
    const y = await api.itsIptal(id);
    mesaj(y.mesaj);
    b.tazele();
  });
  return true;
}
