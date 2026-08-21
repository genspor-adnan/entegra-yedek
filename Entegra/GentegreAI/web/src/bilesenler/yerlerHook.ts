import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { YerlerYaniti } from '../api/sozlesme';

export const VARSAYILAN_ULKE = 'TC'; // public.ulke.ad (045_ulke_tc_kisa.sql - kullanici: "ülke kısa TC olsun")

// Statik referans veri (81 il + 970 ilce + 232 ulke) - degismiyor, tek sefer cekilip modul
// seviyesinde onbelleklenir (Adresler her acilista tekrar istek atmasin).
let yerlerPromise: Promise<YerlerYaniti> | null = null;
const yerleriGetir = () => (yerlerPromise ??= api.yerler());

export function useYerler(aktif: boolean): YerlerYaniti | null {
  const [yerler, setYerler] = useState<YerlerYaniti | null>(null);

  useEffect(() => {
    if (!aktif) return;
    let iptal = false;
    yerleriGetir().then(y => { if (!iptal) setYerler(y) }).catch(() => { /* il/ilce combosuz metin kalir */ });
    return () => { iptal = true };
  }, [aktif]);

  return yerler;
}
