import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * ŞUBE LOGOSU (kullanıcı: "başlıktaki merkez combosunu kaldır, onun yerine
 * şube logo ve adını soldaki GenoTIP AI gibi yaz").
 *
 * Ayrı depo yok: logo şube kartının "Logo & Kaşe" görselidir (dokuman,
 * kaynak "sube", belge türü "Logo"). Kimlik sunucusu şube özetine
 * `logoDokumanId` koyar; içerik yetkili fetch ile çekilip blob URL olur
 * (`<img src>` Bearer taşıyamaz - profil fotoğrafıyla aynı yol).
 * Modül düzeyinde önbellek: şube değişince yeniden çekilir, aynı şube için
 * tek istek.
 */
const onbellek = new Map<number, string | null>();

export function useSubeLogo(dokumanId: number | null | undefined): string | null {
  const [url, setUrl] = useState<string | null>(dokumanId ? onbellek.get(dokumanId) ?? null : null);
  useEffect(() => {
    if (!dokumanId) { setUrl(null); return }
    if (onbellek.has(dokumanId)) { setUrl(onbellek.get(dokumanId) ?? null); return }
    let iptal = false;
    void (async () => {
      let u: string | null = null;
      try { u = await api.dokumanIcerikUrl(dokumanId) } catch { u = null }
      onbellek.set(dokumanId, u);
      if (!iptal) setUrl(u);
    })();
    return () => { iptal = true };
  }, [dokumanId]);
  return url;
}
