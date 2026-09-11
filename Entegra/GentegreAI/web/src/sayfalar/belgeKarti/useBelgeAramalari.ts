import { useState } from 'react';

/**
 * BELGE KARTININ ARAMA / SECIM PENCERELERI.
 *
 * Cari, hasta, satici, personel, stok ve iade aramalari ile radyoloji istem
 * modali `BelgeKarti` govdesinde on ayri `useState` olarak duruyor ve tek bir
 * bilesene (BelgeKartiModallari) yirmi prop halinde geciyordu. Demet halinde
 * tasindiginda yeni bir pencere eklemek tek dosyada degisiklik demek.
 */
export function useBelgeAramalari(acilistaCariArama: boolean) {
  /** Teslim eden / teslim alan personel secimi - hangisi arandigi degerde. */
  const [personel, setPersonel] = useState<'eden' | 'alan' | null>(null);
  const [stok, setStok] = useState(false);
  /** Arama penceresinden eklenen satir sayaci - "3 kalem eklendi" rozeti. */
  const [eklenen, setEklenen] = useState({ sayi: 0, son: '' });
  /** Iade satiri secimi: onceki belgeden satir getirir. */
  const [iade, setIade] = useState(false);
  /** Cari/hasta arama penceresi - yeni kartta acilista da acilabilir. */
  const [cari, setCari] = useState(acilistaCariArama);
  /** Hasta aramasina tasinan metin (kart ustundeki kutudan gelir). */
  const [hastaMetni, setHastaMetni] = useState('');
  /** "Yeni hasta" ile acildiysa pencere dogrudan kayit kipinde baslar. */
  const [hastaYeni, setHastaYeni] = useState(false);
  /** Hasta KARTI (kimlik) penceresi - aramadan degil, karttan acilir. */
  const [hastaKartId, setHastaKartId] = useState<number | null>(null);
  /** Radyoloji istem modali (304). */
  const [istem, setIstem] = useState(false);
  const [satici, setSatici] = useState(false);

  return { personel, setPersonel, stok, setStok, eklenen, setEklenen,
           iade, setIade, cari, setCari, hastaMetni, setHastaMetni,
           hastaYeni, setHastaYeni, hastaKartId, setHastaKartId,
           istem, setIstem, satici, setSatici };
}

export type BelgeAramalari = ReturnType<typeof useBelgeAramalari>;
