import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { UretimSeviyesi, UretimSeviyeYaniti } from '../api/uclar/uretimFisi';

/**
 * ÜRETİM SEVİYESİ (1253, mockup uretim_basit.html): basit · standart · denetimli - oturumda bir kez okunur, ayar
 * ekranı yazınca önbellek düşer. Ekran ve kayıt yapısı TEK; seviye yalnız görüneni değiştirir, bu yüzden hook
 * "ne gösterilsin" sorularını da cevaplar (`standartVe`, `denetimli`).
 */
let onbellek: Promise<UretimSeviyeYaniti> | null = null;
const VARSAYILAN: UretimSeviyeYaniti = { seviye: 'basit', emirKullan: false };

function oku(): Promise<UretimSeviyeYaniti> {
  onbellek ??= api.uretimSeviye().catch(() => { onbellek = null; return VARSAYILAN });
  return onbellek;
}

export function uretimSeviyesiOnbellegiTemizle() { onbellek = null }

export function useUretimSeviyesi() {
  const [deger, setDeger] = useState<UretimSeviyeYaniti | null>(null);
  useEffect(() => {
    let iptal = false;
    void oku().then(d => { if (!iptal) setDeger(d) });
    return () => { iptal = true };
  }, []);
  const seviye: UretimSeviyesi = deger?.seviye ?? 'basit';
  return {
    yuklendi: deger !== null,
    seviye,
    emirKullan: deger?.emirKullan ?? false,
    basit: seviye === 'basit',
    /** Standart ve denetimli (lot kolonu, gider / fire grupları, Maliyet ve Operasyon sekmeleri). */
    standartVe: seviye !== 'basit',
    denetimli: seviye === 'denetimli',
  };
}
