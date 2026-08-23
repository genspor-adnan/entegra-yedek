import { api } from './istemci';

/**
 * Ayar okuma yardimcisi — /api/ayar'i OTURUMDA BIR KEZ ceker.
 *
 * Ayarlar ekranlarin davranisini belirliyor (sayfa boyu, belge tarih penceresi…)
 * ve her liste/kart acilisinda okunuyor; her bilesenin ayri istek atmasi ayni
 * yaniti onlarca kez indirmek olurdu. Ayar YAZILINCA (Genel Ayarlar ekrani)
 * onbellek dusurulur, sonraki okuma tazesini alir.
 */
let istekSozu: Promise<Record<string, string>> | null = null;

async function tumu(): Promise<Record<string, string>> {
  istekSozu ??= api.ayarlar()
    .then(liste => Object.fromEntries(liste.map(a => [a.anahtar, a.deger])))
    .catch(() => {
      istekSozu = null;             // gecici hata kalici bos onbellege donmesin
      return {} as Record<string, string>;
    });
  return istekSozu;
}

/** Ayar degistiginde cagrilir - sonraki okuma sunucudan gelir. */
export function ayarOnbellegiTemizle() {
  istekSozu = null;
}

/** Sayisal ayar; ayar yok/bozuksa `varsayilan` doner. */
export async function ayarSayi(anahtar: string, varsayilan: number): Promise<number> {
  const d = (await tumu())[anahtar];
  const s = Number(d);
  return d !== undefined && d !== '' && Number.isFinite(s) ? s : varsayilan;
}
