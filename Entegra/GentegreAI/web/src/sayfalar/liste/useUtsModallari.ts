import { useState } from 'react';
import type { UtsBildirimTuru } from '../../bilesenler/uts/UtsGenelBildirimModali';
import type { UtsBelgeBildirimYaniti, UtsHazirlaYaniti } from '../../api/istemci';

/**
 * ÜTS EKRAN MODALLARI (223 · 226) - tek yerde toplanan durum.
 *
 * Setter'lari `utsAksiyonlari` / `belgeAksiyonlari` BAGLAM olarak alir,
 * cizimi `UtsModallari` yapar.
 */
export function useUtsModallari() {
  // ÜTS alma bildirimi (223): askidaki envanter satirindan modal.
  const [alma, setAlma] = useState<{ envanterId: number; urunNo: string;
    kurumUnvan: string; askiAdet: number; seriNo: string } | null>(null);
  const [kullanim, setKullanim] = useState(false);
  const [genel, setGenel] = useState<UtsBildirimTuru | null>(null);
  // Verme hazirlama raporu (atlananlar gridi + CSV).
  const [hazirla, setHazirla] = useState<UtsHazirlaYaniti | null>(null);
  // Belge koprusu sonucu (226): satir satir verme/alma raporu.
  const [belgeSonuc, setBelgeSonuc] = useState<UtsBelgeBildirimYaniti | null>(null);

  return { alma, setAlma, kullanim, setKullanim, genel, setGenel,
           hazirla, setHazirla, belgeSonuc, setBelgeSonuc };
}

export type UtsModalDurumu = ReturnType<typeof useUtsModallari>;
