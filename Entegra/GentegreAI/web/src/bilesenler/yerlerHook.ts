import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { YerlerYaniti } from '../api/sozlesme';
import { subeAyari } from './subeAyari';

export const VARSAYILAN_ULKE = 'TC';
// Uyruk artık SKRS MERNİS kodu (614): ülke ADI değil. 9980 = TÜRKİYE
// CUMHURİYETİ - e-Nabız'ın kabul ettiği tek Türkiye kodu; "TR" ISO
// kodu USS tarafından reddediliyor.
export const VARSAYILAN_UYRUK = '9980'; // public.ulke.ad (045_ulke_tc_kisa.sql - kullanici: "ülke kısa TC olsun")

// Statik referans veri (81 il + 970 ilce + 232 ulke) - degismiyor, tek sefer cekilip modul
// seviyesinde onbelleklenir (Adresler her acilista tekrar istek atmasin).
let yerlerPromise: Promise<YerlerYaniti> | null = null;
const yerleriGetir = () => (yerlerPromise ??= api.yerler());

/**
 * SKRS ULKE LISTESI (1350, kullanici: "hasta kartinda uyruk ulke listesi ile ayni olsun"): hasta kartinda ulke ve
 * uyruk AYNI listeden secilir - SKRS MERNIS kodu olan ulkeler. Kodsuz eski kisa adlar ("TC", "ALMANYA") e-Nabiz'e
 * uyruk olarak gonderilemez; ulke kutusunda da ayni ulkenin iki adi gorunuyordu.
 */
export function skrsUlkeleri(yerler: YerlerYaniti | null) {
  return (yerler?.ulkeler ?? []).filter(u => u.skrsKod != null);
}

/**
 * AKTIF SUBENIN ULKESI (1350, kullanici: "ulke ve uyruk defaultu sube hangi ulkedeyse o olsun"): sube ulkeyi ISO
 * iki harfle tutar (666), ulke satiri ayni kodu `iso`da. Eslesme yoksa Turkiye satiri, o da yoksa null (cagiran
 * sabit varsayilana duser).
 */
export function subeUlkesi(yerler: YerlerYaniti | null) {
  const liste = skrsUlkeleri(yerler);
  const kod = (subeAyari().ulkeKod || 'TR').toUpperCase();
  return liste.find(u => u.iso === kod) ?? liste.find(u => u.iso === 'TR') ?? null;
}

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
