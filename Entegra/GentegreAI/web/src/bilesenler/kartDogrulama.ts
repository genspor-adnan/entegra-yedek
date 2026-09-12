import { epostaGecerliMi, telefonAlaniMi, telefonGecerliMi, bicimHatasi }
  from './alanBicim';
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
  zorunluAlanlar?: string[],
  /** 1:1 detaylarin guncel satirlari: detay adi -> satirlar (484). */
  detaySatirlari?: Record<string, Record<string, unknown>[]>): AlanDogrulamaHatasi | null
{
  // BICIM KURALI OLAN ALANLAR (TCKN): kural alanin METASINDAN gelir, ekran
  //   alan adi bilmez. Hasta kartinda TC No ile anne/baba TC numaralari bu
  //   kurala bagli (KartKatalogu). Bos deger gecerli - zorunluluk ayri karar.
  const gecersizBicim = meta?.alanlar.find(a =>
    a.dogrulama ? bicimHatasi(a.dogrulama, String(deger[a.ad] ?? '')) !== null : false);
  if (gecersizBicim)
    return { alan: gecersizBicim.ad,
             mesaj: bicimHatasi(gecersizBicim.dogrulama, String(deger[gecersizBicim.ad] ?? ''))
                    ?? 'Geçersiz değer.' };

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

  // 1:1 DETAYIN ZORUNLU ALANI (484, kullanici: "kurum turu zorunlu olsun").
  //   Sunucu zorunlulugu yalnizca satir GONDERILDIGINDE bakiyordu: kullanici
  //   alana hic dokunmazsa satir hic olusmuyor, kontrol de calismiyordu -
  //   kurum turu sessizce DB varsayilanina (SGK) dusuyordu. Kart artik
  //   kaydetmeden once soruyor.
  for (const d of meta?.detaylar ?? []) {
    if (!d.tekSatir) continue;
    const satir = detaySatirlari?.[d.ad]?.[0] ?? {};
    const eksik = d.alanlar.find(a =>
      a.zorunlu && a.yazilabilir && !a.gizli
      && String(satir[a.ad] ?? '').trim() === '');
    if (eksik) return { alan: `${d.ad}.${eksik.ad}`, mesaj: `${eksik.baslik} zorunlu.` };
  }

  const gecersizTelefon = meta?.alanlar.find(a => {
    const v = deger[a.ad];
    return telefonAlaniMi(a.ad) && typeof v === 'string' && !telefonGecerliMi(v);
  });
  if (gecersizTelefon)
    return { alan: gecersizTelefon.ad,
             mesaj: 'Telefon 10 haneli olmalı (5xx / 2xx / 3xx / 4xx).' };

  return null;
}
