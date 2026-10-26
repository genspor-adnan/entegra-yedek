import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { ListeSatiri } from '../api/sozlesme';

/**
 * CARİ SATIRI: cari listesinin tek satırı (aynı kaynak, yetki ve şube kuralı) - bilgi bandı (CariBilgiBandi)
 * ve Aksiyon menüsü (CariAksiyonMenusu) aynı ekranda birlikte çizilir; aynı cari / tazeleme için tek istek.
 */
const bekleyen = new Map<string, Promise<ListeSatiri | null>>();
function satirGetir(id: number, tazele: number): Promise<ListeSatiri | null> {
  const anahtar = `${id}:${tazele}`;
  let p = bekleyen.get(anahtar);
  if (!p) {
    p = api.liste('cari', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: id } })
           .then(y => y.satirlar[0] ?? null);
    bekleyen.set(anahtar, p);
    // Eski anahtarlar birikmesin (bkz. CariKartParcalari.ozetGetir); hata çağırana gider.
    p.finally(() => setTimeout(() => bekleyen.delete(anahtar), 2000)).catch(() => {});
  }
  return p;
}

/** Satır gelene kadar ve okunamazsa null. */
export function useCariSatiri(id: number, tazele = 0): ListeSatiri | null {
  const [s, setS] = useState<ListeSatiri | null>(null);
  useEffect(() => {
    if (!(id > 0)) { setS(null); return }
    let iptal = false;
    satirGetir(id, tazele).then(v => { if (!iptal) setS(v) }, () => { if (!iptal) setS(null) });
    return () => { iptal = true };
  }, [id, tazele]);
  return s;
}
