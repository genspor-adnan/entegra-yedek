import { epostaGecerliMi, telefonAlaniMi, telefonGecerliMi } from './alanBicim';
import { EPOSTA_ALANLARI, type Deger } from './kartAlanCizim';
import type { KartMetaYaniti } from '../api/sozlesme';

/** Kaydetmeyi durduran ilk alan hatasi. */
export interface AlanDogrulamaHatasi {
  alan: string;
  mesaj: string;
}

/**
 * KART ALAN KONTROLLERI - kaydetmeden ONCE, sunucuya hic gitmeden.
 *
 * Uc kural:
 *  1. e-posta bicimi,
 *  2. EKRANA OZEL zorunluluk (katalogda alan zorunlu degil; kontrol yalniz
 *     burada - yoksa ekrandaki yildiz kozmetik kalirdi),
 *  3. telefon (yerel numara 10 hane).
 *
 * Ilk hatayi dondurur; cagiran alan hatasini gosterip o alanin sekmesine atlar.
 * Sunucu ayni kontrolleri kendi tarafinda da yapar - burasi yalniz kullaniciyi
 * erken uyarmak icindir.
 */
export function kartDogrula(
  meta: KartMetaYaniti | null,
  deger: Record<string, Deger>,
  zorunluAlanlar?: string[]): AlanDogrulamaHatasi | null
{
  const gecersizEposta = meta?.alanlar.find(a => {
    const v = deger[a.ad];
    return EPOSTA_ALANLARI.has(a.ad) && typeof v === 'string' && v !== '' && !epostaGecerliMi(v);
  });
  if (gecersizEposta)
    return { alan: gecersizEposta.ad, mesaj: 'Gecerli bir e-posta adresi girin.' };

  const eksikZorunlu = meta?.alanlar.find(a =>
    a.zorunlu && a.yazilabilir && !a.gizli
    && (zorunluAlanlar?.includes(a.ad) ?? false)
    && String(deger[a.ad] ?? '').trim() === '');
  if (eksikZorunlu)
    return { alan: eksikZorunlu.ad, mesaj: `${eksikZorunlu.baslik} zorunlu.` };

  const gecersizTelefon = meta?.alanlar.find(a => {
    const v = deger[a.ad];
    return telefonAlaniMi(a.ad) && typeof v === 'string' && !telefonGecerliMi(v);
  });
  if (gecersizTelefon)
    return { alan: gecersizTelefon.ad,
             mesaj: 'Telefon 10 haneli olmalı (5xx / 2xx / 3xx / 4xx).' };

  return null;
}
