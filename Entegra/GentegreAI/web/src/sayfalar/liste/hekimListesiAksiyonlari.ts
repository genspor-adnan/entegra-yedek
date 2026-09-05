import { api } from '../../api/istemci';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * HEKIM CALISMA LISTESI AKSIYONLARI (410, Faz 1).
 *
 * Uc dugme, uc ayri an:
 *
 *   * "Siradakini Cagir" - sirayi SUNUCU secer (fn_siradaki_hasta: once
 *     oncelik, sonra kayit sirasi). Istemcinin sirayi hesaplamasi, iki hekim
 *     ayni anda basinca ayni hastayi iki kez cagirmak olurdu.
 *   * "Secileni Cagir" - sirayi atlayip belirli hastayi cagirmak (hasta
 *     salonda degil, yanindaki once alinacak gibi durumlar).
 *   * "Muayeneye Al" - hasta iceri girdi. Cagirmadan da basilabilir; sunucu o
 *     zaman cagirma zamanini da yazar, cunku bekleme o an bitmistir.
 *
 * Cagirma ve muayeneye alma AYRI: hasta cagrilip gelmeyebilir. Ikisini
 * birlestirmek "cagirdik ama gelmedi" olcusunu yok ederdi.
 */
export interface HekimListesiBaglam {
  tazele(): void;
  git(yol: string): void;
}

export async function hekimListesiAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: HekimListesiBaglam,
): Promise<boolean> {
  if (kod !== 'hekim.cagir' && kod !== 'hekim.secileni-cagir' && kod !== 'hekim.al')
    return false;

  if (kod === 'hekim.cagir') {
    // Hekim SECILI SATIRDAN okunur: ekranda birden cok hekimin hastasi
    //   olabilir ve "siradaki" sorusunun cevabi hekime gore degisir.
    const hekimId = Number(satir?.personelId ?? 0);
    if (!hekimId) {
      mesaj('Hangi hekimin sırası çağrılacak? Listeden o hekimin bir hastasını seçin.');
      return true;
    }

    await guvenli(async () => {
      const y = await api.siraCagir({ hekimId });
      mesaj(y.belgeId ? `${y.mesaj}\n\nBekleme ekranı: ${y.ekranAdi}` : y.mesaj);
      b.tazele();
    });
    return true;
  }

  const belgeId = Number(satir?.id ?? 0);
  if (!belgeId) { mesaj('Önce bir hasta seçin.'); return true }

  if (kod === 'hekim.secileni-cagir') {
    await guvenli(async () => {
      const y = await api.siraCagir({ belgeId });
      mesaj(`${y.mesaj}\n\nBekleme ekranı: ${y.ekranAdi}`);
      b.tazele();
    });
    return true;
  }

  await guvenli(async () => {
    const y = await api.basvurudanMuayeneyeAl(belgeId);
    b.tazele();
    // Muayene kartina GECILIR: "aldim" deyip ekranda kalmak hekimi bir
    //   tiklama daha zorlardi - amac zaten muayeneyi yazmak.
    b.git(`/muayene/${y.muayeneId}`);
  });
  return true;
}
