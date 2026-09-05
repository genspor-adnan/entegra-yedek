import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * e-NABIZ KUYRUK AKSIYONLARI (415).
 *
 * Paket satirini ELLE DUZELTMEK YOK: eksik alan KAYNAKTA duzeltilir (hekim
 * kartinda tescil no, klinik eslemesi, muayenede tani...) ve paket kaynaktan
 * yeniden uretilir. Paketi elle duzeltmek, USS'ye gideni hastanin
 * dosyasindakinden ayirirdi.
 *
 * Yeniden uretim ESKI PAKETI IPTAL EDER: ayni kaynaktan iki bekleyen paket
 * kalirsa USS'ye ayni olay iki kez giderdi.
 */
export interface EnabizBaglam {
  tazele(): void;
}

export async function enabizAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: EnabizBaglam,
): Promise<boolean> {
  if (kod !== 'enabiz.yeniden-uret' && kod !== 'enabiz.iptal'
      && kod !== 'enabiz.gonder') return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir paket seçin.'); return true }
  const no = String(satir?.paketNo ?? id);

  if (kod === 'enabiz.gonder') {
    await guvenli(async () => {
      const y = await api.enabizGonder(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'enabiz.iptal') {
    if (!await onay(`${no} paketi iptal edilsin mi?\n\n`
                  + 'İptal edilen paket USS\'ye gönderilmez.', true)) return true;
    await guvenli(async () => {
      const y = await api.enabizPaketIptal(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  await guvenli(async () => {
    const y = await api.enabizYenidenUret(id);
    // Eksik SURUYORSA bunu soylemek gerekir: "üretildi" demek, kullanicinin
    //   sorunu cozuldu sanmasina yol acardi.
    mesaj(y.eksikler?.length
      ? `${y.mesaj}\n\nHâlâ eksik: ${y.eksikler.join(', ')}`
      : y.mesaj);
    b.tazele();
  });
  return true;
}
