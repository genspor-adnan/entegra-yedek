import { useState } from 'react';

/**
 * RADYOLOJI EKRAN MODALLARI (304 · 316 · 318 · 320) - tek yerde toplanan durum.
 *
 * `Liste` bileseninde yan yana duran sekiz `useState` buraya tasindi; aksiyon
 * modulleri (`radyolojiAksiyonlari`) bu setter'lari BAGLAM olarak aliyor,
 * cizimi `RadyolojiModallari` yapiyor.
 */
export function useRadyolojiModallari() {
  /**
   * RADYOLOJI ISTEM ACMA (304): listeden acilinca once HASTA secilir
   * (istem hastaya aittir), sonra tetkik modali gelir.
   */
  const [hastaArama, setHastaArama] = useState(false);
  const [istem, setIstem] = useState<
    { hastaId: number; hastaAdi: string; disIstem: boolean;
      /** Randevudan kabul (317): istem randevuya bağlanır, tetkik ön seçili gelir. */
      randevuId?: number; hizmetId?: number } | null>(null);
  /** Radyoloji: secili isteme randevu verme (316). */
  const [randevu, setRandevu] = useState<
    { istemId: number; accessionNo: string; tetkikAdi: string;
      modalite: number; sureDk: number } | null>(null);
  /** Sonuc teslimi (304) - film/CD/rapor kime verildi. */
  const [teslim, setTeslim] = useState<
    { istemId: number; accessionNo: string; cdIstendi?: boolean } | null>(null);
  /** Kritik bulgu bildirimi (318) - takip listesinden acilir. */
  const [kritik, setKritik] = useState<
    { istemId: number; accessionNo: string; hasta: string; tetkik: string;
      bulgu: string; bildirilenAd: string } | null>(null);
  /** Cekim sonrasi sarf onayi (320) - protokol malzemesi onerilir. */
  const [sarf, setSarf] = useState<
    { istemId: number; accessionNo: string; tetkikAdi: string } | null>(null);
  /** Takvimden cihaz kapatma (318): isaretli aralik + cihaz. */
  const [kapatma, setKapatma] = useState<
    { cihazId: number; cihazAdi: string; baslangic: string; bitis: string } | null>(null);
  /** Konsultasyon cevabi (318). */
  const [konsultasyon, setKonsultasyon] = useState<
    { istemId: number; konsultasyonId: number; accessionNo: string; hasta: string;
      tetkik: string; soru: string; gorus: string } | null>(null);

  return { hastaArama, setHastaArama, istem, setIstem, randevu, setRandevu,
           teslim, setTeslim, kritik, setKritik, sarf, setSarf,
           kapatma, setKapatma, konsultasyon, setKonsultasyon };
}

export type RadyolojiModalDurumu = ReturnType<typeof useRadyolojiModallari>;
