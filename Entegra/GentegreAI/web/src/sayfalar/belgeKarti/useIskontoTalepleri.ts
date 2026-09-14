import { useEffect, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import type { IskontoTalebi } from '../../api/sozlesme';

/**
 * BELGENİN İSKONTO TALEPLERİ (662) — ücret sekmesindeki durum rozeti.
 *
 * Karar ZİLDEN ya da onay ekranından verilir; banko kartı bunu kendiliğinden
 * duymaz. BEKLEYEN talep varken 60 sn'de bir yoklanır, karar düşünce
 * zamanlayıcı susar - sonuçlanmış bir belgeyi sonsuza kadar sormak, açık
 * kalan her başvuru kartı için boş istek üretirdi.
 *
 * KARAR GELİNCE SATIRLAR DA TAZELENİR: onay oranı satırlara SUNUCUDA işlenir
 * (fn_iskonto_talep_karar) ve satırlar kilitlenir; ekrandaki eski oran ile
 * kilitsiz satırlar yanlış gösterirdi.
 */
export function useIskontoTalepleri(basvuruMu: boolean, belgeId: number | undefined,
                                    kararSonrasi: () => Promise<void>) {
  const [talepler, setTalepler] = useState<IskontoTalebi[]>([]);
  /* Karar sonrasi isi REF'TE: cagiran her cizimde yeni bir kapanis verir,
     bagimliliga koymak yoklama zamanlayicisini surekli sifirlardi. */
  const isRef = useRef(kararSonrasi);
  isRef.current = kararSonrasi;

  useEffect(() => {
    if (!basvuruMu || !belgeId) { setTalepler([]); return }
    let durduruldu = false;
    let bekleyenVar = false;

    const oku = async (ilk: boolean) => {
      try {
        const liste = await api.iskontoTalepleri(belgeId);
        if (durduruldu) return;
        const simdiBekleyen = liste.some(t => t.durum === 0);
        // BEKLEYENDEN SONUCLANMIS'A gecis: satirlar sunucuda degisti.
        if (!ilk && bekleyenVar && !simdiBekleyen) await isRef.current();
        bekleyenVar = simdiBekleyen;
        setTalepler(liste);
      } catch { if (ilk) setTalepler([]) }
    };

    void oku(true);
    const z = window.setInterval(() => {
      // Zamanlayici hep doner ama bekleyen yoksa istek ATILMAZ: tek bir
      //   kosul, iki ayri efekt kurmaktan basit.
      if (bekleyenVar) void oku(false);
    }, 60000);
    return () => { durduruldu = true; window.clearInterval(z) };
    // `kararSonrasi` her cizimde yeniden kurulur; bagimliliga koymak
    //   zamanlayiciyi surekli sifirlardi - guncel hali ref'ten okunur.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [basvuruMu, belgeId]);

  return talepler;
}
