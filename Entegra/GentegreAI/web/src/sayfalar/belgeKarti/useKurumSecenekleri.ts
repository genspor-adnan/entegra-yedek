import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';

/** Kurumun basvuruya baglanabilen sozlesmeleri (469). */
export interface KurumSozlesmesi {
  id: number; ad: string; altKurum: number; altKurumAdi: string;
  rota: number; tur: number;
  /** Sozlesme numarasi ve varsayilan karsilama orani (468) - provizyon
   *  sekmesinin baslangic degerleri bunlardan gelir. */
  sozlesmeNo?: string;
  varsayilanKarsilama?: number;
}

/**
 * ODEYEN KURUMA BAGLI SECENEKLER: sozlesme listesi ve SGK alt kurumlari.
 *
 * Ikisi de yalniz kurum degisince sunucudan cekilir ve yalniz Başvuru
 * sekmesinde cizilir; `BelgeKarti` govdesinde iki durum + iki etki olarak
 * duruyordu.
 */
export function useKurumSecenekleri(odeyenKurumId: number | null, kurumTuru?: number) {
  const [sozlesmeler, setSozlesmeler] = useState<KurumSozlesmesi[]>([]);
  const [altKurumlar, setAltKurumlar] = useState<{ id: number; ad: string }[]>([]);

  useEffect(() => {
    let iptal = false;
    if (!odeyenKurumId) { setSozlesmeler([]); return }
    void (async () => {
      try {
        const y = await api.kurumSozlesmeleri(odeyenKurumId);
        if (!iptal) setSozlesmeler(y.sozlesmeler ?? []);
      } catch { if (!iptal) setSozlesmeler([]) }
    })();
    return () => { iptal = true };
  }, [odeyenKurumId]);

  // SGK'da DEVREDILEN KURUM secenekleri (SSK / Bag-Kur / ES / Yesil Kart).
  //   Kod listesi tur * 100 + kod uzayinda: SGK'ninkiler 3 ile baslar.
  useEffect(() => {
    let iptal = false;
    if (kurumTuru !== 3) { setAltKurumlar([]); return }
    void (async () => {
      try {
        const y = await api.kodListe("kurum.alt_kurum");
        if (!iptal)
          setAltKurumlar((y.degerler ?? [])
            .filter(d => Math.floor(Number(d.deger) / 100) === 3)
            .map(d => ({ id: Number(d.deger), ad: String(d.ad) })));
      } catch { if (!iptal) setAltKurumlar([]) }
    })();
    return () => { iptal = true };
  }, [kurumTuru]);

  return { sozlesmeler, altKurumlar };
}
