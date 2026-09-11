import { useState } from 'react';

/** Kasa kartinda secilen hesap (nakit / banka / POS) ve cari. */
export interface HesapSecimi { id: number; ad: string; doviz: string }
export interface CariSecimi { id: number; unvan: string }

/**
 * CEK / SENET KIYMETI (23/24/33/34) - kiymetin kendi bilgileri.
 *
 * Vade ZORUNLU: portfoyun ve vade raporunun tasiyicisi odur; digerleri
 * kiymetin uzerindeki bilgilerdir. `KasaIslemKarti` govdesinde bes ayri
 * `useState` olarak duruyordu.
 */
export function useKiymetBilgisi() {
  const [vade, setVade] = useState('');
  const [seriNo, setSeriNo] = useState('');
  const [kesideci, setKesideci] = useState('');
  const [banka, setBanka] = useState('');
  const [sube, setSube] = useState('');
  return { vade, setVade, seriNo, setSeriNo, kesideci, setKesideci,
           banka, setBanka, sube, setSube };
}

/**
 * PLAN GERCEKLESTIRME PANELI: planlanmis islem gercek hesaba/tutara baglanir.
 * Hesap zorunlu; tutar bos birakilirsa planin tutari kullanilir.
 */
export function usePlanGerceklestirme(bugun: () => string) {
  const [hesap, setHesap] = useState<HesapSecimi | null>(null);
  const [tutar, setTutar] = useState('');
  // Tembel ilklendirme: `bugunIso` her render'da degil BIR KEZ cagrilir.
  const [tarih, setTarih] = useState(bugun);
  return { hesap, setHesap, tutar, setTutar, tarih, setTarih };
}
