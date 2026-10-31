import { useEffect } from 'react';

/**
 * YOKLAMA (kod inceleme 30.10.2026 K53): `setInterval` ile tazeleyen ekranlar sekme arka plandayken de
 * (20 açık sekme × 5-20 sn) sunucuyu dövüyor, hata alınca da aynı hızda dönmeye devam ediyordu.
 *
 *  - Sekme gizliyken tik atılmaz; görünür olunca HEMEN bir kez çalışır (okunmamış sayısı güncel olsun -
 *    "arka planda da çalışsın" ihtiyacını bu karşılar).
 *  - Arka arkaya hata: bekleme ikiye katlanır (en çok 8×); ilk başarıda sıfırlanır.
 */
export function useYoklama(calis: () => Promise<unknown> | void, ms: number, aktif = true) {
  useEffect(() => {
    if (!aktif) return;
    let hata = 0, zamanlayici = 0, iptal = false;
    const tik = async () => {
      if (iptal) return;
      if (document.hidden) { kur(); return }
      try { await calis(); hata = 0 }
      catch { hata = Math.min(hata + 1, 3) }
      kur();
    };
    const kur = () => { if (!iptal) zamanlayici = window.setTimeout(() => void tik(), ms * 2 ** hata) };
    const gorunur = () => { if (!document.hidden) { window.clearTimeout(zamanlayici); void tik() } };
    kur();
    document.addEventListener('visibilitychange', gorunur);
    return () => { iptal = true; window.clearTimeout(zamanlayici); document.removeEventListener('visibilitychange', gorunur) };
  }, [calis, ms, aktif]);
}
