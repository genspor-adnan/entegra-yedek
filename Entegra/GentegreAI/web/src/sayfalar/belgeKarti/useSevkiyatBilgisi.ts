import { useState } from 'react';

/**
 * IRSALIYE / SEVKIYAT BASLIGI (e-Irsaliye alanlari): tasiyici, arac, sofor,
 * sevk tarihi ve teslim sekli.
 *
 * `BelgeKarti` govdesinden ayrildi: sekiz `useState` yan yana duruyor ve tek
 * bir sekmeye (Taşıyıcı) tek tek prop olarak geciyordu. Demet halinde
 * tasindiginda yeni bir alan eklemek iki dosyada degil BIR yerde degisiklik
 * demek.
 */
export interface TarafSecimi { id: number; ad: string }

export function useSevkiyatBilgisi() {
  const [teslimSekli, setTeslimSekli] = useState(0);
  const [sevkTarihi, setSevkTarihi] = useState('');
  const [soforTckn, setSoforTckn] = useState('');
  const [tasiyici, setTasiyici] = useState<TarafSecimi | null>(null);
  const [aracPlaka, setAracPlaka] = useState('');
  const [soforAd, setSoforAd] = useState('');
  const [teslimEden, setTeslimEden] = useState<TarafSecimi | null>(null);
  /** Depo fisinde "talep eden", irsaliyede "teslim alan". */
  const [teslimAlan, setTeslimAlan] = useState<TarafSecimi | null>(null);

  return { teslimSekli, setTeslimSekli, sevkTarihi, setSevkTarihi,
           soforTckn, setSoforTckn, tasiyici, setTasiyici,
           aracPlaka, setAracPlaka, soforAd, setSoforAd,
           teslimEden, setTeslimEden, teslimAlan, setTeslimAlan };
}

export type SevkiyatBilgisi = ReturnType<typeof useSevkiyatBilgisi>;

/**
 * TEKLIF BASLIGI (218): durum, revize numarasi, konu ve teslim sekli.
 * Yalniz teklif turunde cizilir - digerlerinde alanlar bos durur.
 */
export function useTeklifBilgisi() {
  const [durum, setDurum] = useState('1');
  const [revizeNo, setRevizeNo] = useState('');
  const [konu, setKonu] = useState('');
  const [teslim, setTeslim] = useState('');
  return { durum, setDurum, revizeNo, setRevizeNo, konu, setKonu, teslim, setTeslim };
}

export type TeklifBilgisi = ReturnType<typeof useTeklifBilgisi>;
