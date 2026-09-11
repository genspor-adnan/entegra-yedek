import { useState } from 'react';

/**
 * ISTEYEN HEKIM VE KURUM (dis istem).
 *
 * Ic istemde hekim kurumun kendi listesinden secilir; DIS istemde iki yol var:
 * kayitli dis hekim (jenerik taraf aramasi, kaynak 'dis-hekim') ya da bir
 * kerelik gelen, kaydedilmeye degmeyen hekim icin SERBEST METIN. Isteyen kurum
 * da jenerik cari aramasindan gelir - combo yalniz ilk 200 cariyi tasiyordu ve
 * sevk eden hastane listede yoksa alan bos birakiliyordu.
 *
 * `IstemModali` govdesinde sekiz ayri `useState` olarak duruyordu.
 */
export function useIsteyenHekim() {
  /** Kayitli dis hekim secildiyse id; "listede yok" ise serbest metin. */
  const [disHekimId, setDisHekimId] = useState<number | null>(null);
  const [disHekimSecim, setDisHekimSecim] = useState('');
  const [disHekimAd, setDisHekimAd] = useState('');
  const [hekimArama, setHekimArama] = useState(false);
  /** Ic istemde kurumun kendi hekimi. */
  const [istekHekimId, setIstekHekimId] = useState<number | null>(null);
  const [istekKurumId, setIstekKurumId] = useState<number | null>(null);
  /** Secili kurumun ADI - kutuda id degil ad gorunur. */
  const [istekKurumAd, setIstekKurumAd] = useState('');
  const [kurumArama, setKurumArama] = useState(false);

  /** Aramadan kayitli hekim secildi: serbest metin temizlenir. */
  const hekimSec = (id: number, ad: string) => {
    setDisHekimId(id);
    setDisHekimSecim(ad);
    setDisHekimAd('');
    setHekimArama(false);
  };
  const hekimBirak = () => { setDisHekimId(null); setDisHekimSecim('') };

  const kurumSec = (id: number, ad: string) => {
    setIstekKurumId(id);
    setIstekKurumAd(ad);
    setKurumArama(false);
  };
  const kurumBirak = () => { setIstekKurumId(null); setIstekKurumAd('') };

  return { disHekimId, disHekimSecim, disHekimAd, setDisHekimAd,
           hekimArama, setHekimArama, hekimSec, hekimBirak,
           istekHekimId, setIstekHekimId,
           istekKurumId, istekKurumAd, kurumArama, setKurumArama,
           kurumSec, kurumBirak };
}
