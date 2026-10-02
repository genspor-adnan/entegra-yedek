import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * ICD ARAMA PENCERESİNİN TÜR (Kesin / Ön Tanı) VE TARAF SEÇİMİ.
 *
 * Kullanıcı: *"tür combo'ya Ön Tanı ve Kesin Tanı, taraf combo'ya Sağ Sol ve
 * Bilateral ekle.. en son kullanıcı ne seçili bıraktıysa ekran açıldığında o
 * seçili gelsin"*.
 *
 * SON SEÇİM HESAPTA (`taniEkle` kullanıcı tercihi): hekim hangi makineden
 * girerse girsin aynı seçimle açar. `localStorage` yalnız anında açılış ve
 * çevrimdışı kopyası - sunucu cevabı gelince onu ezer.
 *
 * Seçenekler sunucudan (`/api/muayene/tani-secenekleri`); uç yanıt vermezse
 * (eski sürüm API) aynı kodlarla YEDEK liste - combolar boş kalmasın.
 */
export interface TaniSecenek { kod: number; ad: string }

const YEDEK_KESINLIK: TaniSecenek[] = [{ kod: 1, ad: 'Kesin Tanı' }, { kod: 2, ad: 'Ön Tanı' }];
const YEDEK_TARAF: TaniSecenek[] = [
  { kod: 0, ad: '—' }, { kod: 1, ad: 'Sağ' }, { kod: 2, ad: 'Sol' }, { kod: 3, ad: 'Bilateral' },
];

interface Secim { kesinlik: number; taraf: number }
const VARSAYILAN: Secim = { kesinlik: 1, taraf: 0 };

function coz(metin: string | null | undefined): Secim | null {
  if (!metin) return null;
  try {
    const d = JSON.parse(metin) as Partial<Secim>;
    return { kesinlik: Number(d.kesinlik) || 1, taraf: Number(d.taraf) || 0 };
  } catch { return null }
}

export function useTaniEkleTercihi(acik: boolean, kullaniciId: number | undefined) {
  const yerelAnahtar = `taniEkle.${kullaniciId ?? 0}`;
  const [secim, setSecimState] = useState<Secim>(() => {
    try { return coz(localStorage.getItem(yerelAnahtar)) ?? VARSAYILAN } catch { return VARSAYILAN }
  });
  const [kesinlikler, setKesinlikler] = useState<TaniSecenek[]>(YEDEK_KESINLIK);
  const [taraflar, setTaraflar] = useState<TaniSecenek[]>(YEDEK_TARAF);

  // Pencere her açılışta hesaptaki son seçimi okur (başka makinede değişmiş olabilir).
  useEffect(() => {
    if (!acik) return;
    let iptal = false;
    api.tercihler()
       .then(t => { const s = coz(t.taniEkle); if (s && !iptal) setSecimState(s) })
       .catch(() => {});
    api.muayeneTaniSecenekleri()
       .then(y => {
         if (iptal) return;
         if (y.kesinlikler?.length) setKesinlikler(y.kesinlikler);
         if (y.taraflar?.length) setTaraflar(y.taraflar);
       })
       .catch(() => {});
    return () => { iptal = true };
  }, [acik]);

  const yaz = (s: Secim) => {
    setSecimState(s);
    const metin = JSON.stringify(s);
    try { localStorage.setItem(yerelAnahtar, metin) } catch { /* yerel kopya şart değil */ }
    void api.tercihYaz('taniEkle', metin).catch(() => {});
  };

  return {
    kesinlik: secim.kesinlik, taraf: secim.taraf, kesinlikler, taraflar,
    setKesinlik: (k: number) => yaz({ ...secim, kesinlik: k }),
    setTaraf: (t: number) => yaz({ ...secim, taraf: t }),
  };
}
