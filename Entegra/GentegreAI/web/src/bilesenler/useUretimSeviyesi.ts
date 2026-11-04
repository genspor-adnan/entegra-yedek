import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { UretimSeviyesi, UretimSeviyeYaniti } from '../api/uclar/uretimFisi';

/**
 * ÜRETİM SEVİYESİ (1253, mockup uretim_basit.html): basit · standart · denetimli - oturumda bir kez okunur, ayar
 * ekranı yazınca önbellek düşer ve AÇIK HOOK'LAR YENİDEN OKUR (04.11.2026: Kabuk menüsü "Üretim emri kullan"
 * işaretlenince Üretim Emiri Listesi'ni sayfa yenilenmeden gösterir; önce yalnız önbellek temizleniyordu, menü eski
 * değerde kalıyordu). Ekran ve kayıt yapısı TEK; seviye yalnız görüneni değiştirir, bu yüzden hook "ne gösterilsin"
 * sorularını da cevaplar (`standartVe`, `denetimli`).
 */
let onbellek: Promise<UretimSeviyeYaniti> | null = null;
/** Çözülmüş son değer - hook olmayan yerler (kart eklentileri) için anlık okuma. */
let sonDeger: UretimSeviyeYaniti | null = null;
const VARSAYILAN: UretimSeviyeYaniti = { seviye: 'basit', emirKullan: false };
/** Önbellek düşünce haberdar edilen açık hook'lar. */
const dinleyiciler = new Set<() => void>();

function oku(): Promise<UretimSeviyeYaniti> {
  onbellek ??= api.uretimSeviye().then(d => { sonDeger = d; return d }).catch(() => { onbellek = null; return VARSAYILAN });
  return onbellek;
}

export function uretimSeviyesiOnbellegiTemizle() {
  onbellek = null; sonDeger = null;
  for (const d of dinleyiciler) d();
}

/**
 * ANLIK SEVİYE (1258): kart eklentileri hook çağıramaz (render içinde kaynağa göre dallanan düz fonksiyonlar). Üretim
 * listesi / kartı açılmadan önce hook en az bir kez okumuş olur; okunmamışsa 'basit' döner ve okumayı tetikler.
 */
export function uretimSeviyesiAnlik(): UretimSeviyesi {
  if (!sonDeger) void oku();
  return sonDeger?.seviye ?? 'basit';
}

/**
 * `etkin=false` istek atmaz (Liste.tsx her listede çağırır; üretim dışı listede /api/uretim/seviye'ye gidilmez) -
 * değer varsayılan kalır, `yuklendi` false.
 */
export function useUretimSeviyesi(etkin = true) {
  const [deger, setDeger] = useState<UretimSeviyeYaniti | null>(null);
  useEffect(() => {
    if (!etkin) return;
    let iptal = false;
    const yukle = () => { void oku().then(d => { if (!iptal) setDeger(d) }) };
    yukle();
    dinleyiciler.add(yukle);
    return () => { iptal = true; dinleyiciler.delete(yukle) };
  }, [etkin]);
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
