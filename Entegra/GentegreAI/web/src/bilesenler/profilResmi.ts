import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * PROFİL FOTOĞRAFI (kullanıcı: "avatara tıklayıp profil resmi ekleyebilsin").
 *
 * Ayrı bir depo YOK: fotoğraf kişinin PERSONEL KARTININ varsayılan resmidir
 * (dokuman galerisi, kart "personel", kaynak = kullanıcı kimliği). Böylece
 * personel listesinde/kartında görünen resim ile üst şeritteki avatar aynı
 * dosyadır; iki yerde iki foto tutulmaz. Sunucu, kişinin kendi kartı için
 * personel yetkisi aramaz (DokumanUclari.KendiKartiMi).
 *
 * Modül düzeyinde küçük bir önbellek + dinleyici: Kabuk'taki avatar ile
 * ayarlar penceresi aynı URL'yi paylaşır, yükleme sonrası ikisi de tazelenir.
 */
const onbellek = new Map<number, string | null>();
const dinleyiciler = new Set<() => void>();
const bildir = () => dinleyiciler.forEach(d => d());

async function getir(kullaniciId: number): Promise<string | null> {
  try {
    const satirlar = await api.dokumanlar('personel', kullaniciId);
    const resimler = satirlar.filter(s => s.contentType.startsWith('image/'));
    const resim = resimler.find(s => s.varsayilan) ?? resimler[0];
    return resim ? await api.dokumanIcerikUrl(resim.id) : null;
  } catch { return null }
}

export async function profilResmiGetir(kullaniciId: number, tazele = false): Promise<string | null> {
  if (!tazele && onbellek.has(kullaniciId)) return onbellek.get(kullaniciId) ?? null;
  const eski = onbellek.get(kullaniciId);
  const url = await getir(kullaniciId);
  if (eski && eski !== url) { try { URL.revokeObjectURL(eski) } catch { /* yoksay */ } }
  onbellek.set(kullaniciId, url);
  bildir();
  return url;
}

/** Yeni fotoğraf: varsayılan resim olarak yüklenir; eski varsayılanın yerini alır. */
export async function profilResmiYukle(kullaniciId: number, dosya: File): Promise<string | null> {
  await api.dokumanYukle('personel', kullaniciId, dosya, true);
  return profilResmiGetir(kullaniciId, true);
}

/** Kaldır: kartın TÜM resimlerini siler (belge/dosya kalır) - baş harflere dönülür. */
export async function profilResmiSil(kullaniciId: number): Promise<void> {
  const satirlar = await api.dokumanlar('personel', kullaniciId);
  for (const s of satirlar.filter(x => x.contentType.startsWith('image/')))
    await api.dokumanSil('personel', kullaniciId, s.id);
  await profilResmiGetir(kullaniciId, true);
}

/** Bileşen kancası: URL değişince yeniden çizer. */
export function useProfilResmi(kullaniciId: number | undefined): string | null {
  const [url, setUrl] = useState<string | null>(kullaniciId ? onbellek.get(kullaniciId) ?? null : null);
  useEffect(() => {
    if (!kullaniciId) { setUrl(null); return }
    const d = () => setUrl(onbellek.get(kullaniciId) ?? null);
    dinleyiciler.add(d);
    if (!onbellek.has(kullaniciId)) void profilResmiGetir(kullaniciId); else d();
    return () => { dinleyiciler.delete(d) };
  }, [kullaniciId]);
  return url;
}
