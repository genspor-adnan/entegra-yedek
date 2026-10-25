import type { CariGibBilgisi } from '../../api/uclar/kimlik';
import type { KartYazmaIstegi } from '../../api/sozlesme';
import { paletSadelestir } from './paletMetin';

/**
 * CTRL+K "VKN + MÜŞTERİ / TEDARİKÇİ KARTI" (kullanıcı 25.10.2026: "ctrl k arama prompt'a şu tür komut yazarsam
 * izibiz'den bilgi alıp oluştur.. örnek: 3850065757 müş (veya müşteri) / ted (tedarikçi) kart veya kartı aç veya
 * oluştur"; "o vkno ile kart varsa uyarı verecek ve kartı açacak"; "aynı vkno ile kart açılamaz").
 *
 * Kalıp: 10 haneli VKN ya da 11 haneli TCKN + rol sözcüğü (ilk 3 harf yeter: müş / müşteri, ted / tedarikçi) +
 * isteğe bağlı "kart / kartı", "aç", "oluştur", "yeni". Sıra serbest ("müş 3850065757 aç"). Rol yoksa kalıp
 * değildir - düz numara araması sürer.
 */
export type CariRol = 'musteri' | 'tedarikci';

export function cariNiyetCoz(metin: string): { vkn: string; rol: CariRol } | null {
  const n = /(?:^|\D)(\d{10,11})(?!\d)/.exec(metin);
  if (!n) return null;
  const vkn = n[1];
  const bas = n.index + n[0].indexOf(vkn);
  const kalan = paletSadelestir((metin.slice(0, bas) + ' ' + metin.slice(bas + vkn.length)).trim())
    .split(/\s+/).map(k => k.replace(/[^a-z]/g, ''))
    .filter(k => k && k !== 'yeni' && !/^kart/.test(k) && k !== 'ac' && k !== 'olustur' && k !== 've');
  let rol: CariRol | null = null;
  for (const k of kalan) {
    if (k.length < 3) return null;
    if ('musteri'.startsWith(k)) rol = 'musteri';
    else if ('tedarikci'.startsWith(k)) rol = 'tedarikci';
    else return null;      // tanınmayan sözcük: bu kalıp değil
  }
  return rol ? { vkn, rol } : null;
}

/** Rolün kart yolu: Müşteri Listesi '/cari', Tedarikçi Listesi '/tedarikci' (aynı 'cari' kartı). */
export const cariKartYolu = (rol: CariRol) => (rol === 'musteri' ? '/cari' : '/tedarikci');
export const rolAdi = (rol: CariRol) => (rol === 'musteri' ? 'müşteri' : 'tedarikçi');

/**
 * Entegratör bilgisinden YENİ cari kartının gövdesi - kartın normal yeni kayıt ucuna gider (doğrulama, kod, log
 * orada). Rol bayrağı istenen rol; e-Fatura bayrağı ve posta kutusu GİB kullanıcı listesinden; adres (varsa)
 * "Fatura" türünde varsayılan adres olarak.
 */
export function cariKartGovdesi(vkn: string, rol: CariRol, g: CariGibBilgisi): KartYazmaIstegi {
  const adresVar = !!(g.adres || g.il || g.ilce);
  return {
    kart: {
      unvan: g.unvan, vkno: vkn, vd: g.vergiDairesi,
      musteri: rol === 'musteri', tedarikci: rol === 'tedarikci',
      efatura: g.mukellef, ...(g.alias ? { aliasEposta: g.alias } : {}),
    },
    ...(adresVar ? {
      detaylar: { adresler: { eklenen: [{ tur: 1, adres: g.adres, il: g.il, ilce: g.ilce, varsayilan: true, aktif: true }] } },
    } : {}),
  } as unknown as KartYazmaIstegi;
}
