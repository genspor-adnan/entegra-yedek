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

/**
 * CARİ SEÇİLDİKTEN SONRAKİ KOMUT (kullanıcı 25.10.2026: "'ahmet' yazarsam içinde ahmet geçen müşteri ve tedarikçi
 * listesi getir (max 3), birini seçeyim ve komut vereyim.. sipariş (veya sip) al (veya satış / sat siparişi / sip)
 * dediğimde satış sip kartı aç.. fat (fatura) kes dediğimde satış faturası kartı aç.. sat / satış irs / irsaliye
 * aç / oluş / oluştur veya boş"). Fiiller (al, kes, aç, oluş(tur), yeni, ver) isteğe bağlı. Yön: "sat / satış" satış,
 * "alış" alış; yazılmazsa carinin rolünden (müşteriyse satış, yalnız tedarikçiyse alış).
 */
export type CariIslem = 'siparis' | 'fatura' | 'irsaliye' | 'kart' | 'ekstre';
export type CariYon = 'satis' | 'alis';
export interface SeciliCari { id: number; ad: string; kod: string; musteri: boolean; tedarikci: boolean; il?: string }

const ISLEM_SOZ: [string, CariIslem][] = [
  ['sip', 'siparis'], ['siparis', 'siparis'], ['fat', 'fatura'], ['fatura', 'fatura'],
  ['irs', 'irsaliye'], ['irsaliye', 'irsaliye'], ['kart', 'kart'], ['karti', 'kart'], ['eks', 'ekstre'], ['ekstre', 'ekstre'],
];
const FIIL = new Set(['al', 'kes', 'ac', 'olus', 'olustur', 'yeni', 'ver', 'gir', 'yap']);

/** "sip al" -> siparis; "sat fat kes" -> fatura/satis; "" -> null (hepsi listelenir). Tanınmayan sözcük -> 'yok'. */
export function cariIslemCoz(metin: string): { islem: CariIslem | null; yon: CariYon | null } | 'yok' {
  const kel = paletSadelestir(metin).split(/\s+/).map(k => k.replace(/[^a-z]/g, '')).filter(Boolean);
  let islem: CariIslem | null = null; let yon: CariYon | null = null;
  for (const k of kel) {
    if (k === 'sat' || k === 'satis' || k === 'satiş') { yon = 'satis'; continue }
    if (k === 'alis' || k === 'alim') { yon = 'alis'; continue }
    if (FIIL.has(k)) continue;
    // Önek: "siparisi", "faturası", "irsaliyesi", "kartı" - ilk 3 harf yeter.
    const bul = k.length >= 3 ? ISLEM_SOZ.find(([s]) => k.startsWith(s) || s.startsWith(k)) : undefined;
    if (bul) { if (!islem || islem === 'kart') islem = bul[1]; continue }
    return 'yok';
  }
  return { islem, yon };
}

export const ISLEM_SIRASI: CariIslem[] = ['siparis', 'fatura', 'irsaliye', 'kart', 'ekstre'];
const BELGE_ROTA: Record<CariYon, Record<'siparis' | 'fatura' | 'irsaliye', string>> = {
  // Satış Faturası Listesi menüde '/belge' (yeni fatura '/belge/yeni?tur=15', BelgeYeniRota).
  satis: { siparis: '/siparis', fatura: '/belge', irsaliye: '/satis-irsaliye' },
  alis: { siparis: '/alis-siparis', fatura: '/alis-fatura', irsaliye: '/alis-irsaliye' },
};
const ISLEM_ADI: Record<CariIslem, string> = { siparis: 'siparişi', fatura: 'faturası', irsaliye: 'irsaliyesi', kart: '', ekstre: '' };

/** İşlemin ekranı (liste rotası - menüde yoksa yetki yok) ve gidilecek yol. */
export function cariIslemHedefi(c: SeciliCari, islem: CariIslem, yonIstenen: CariYon | null):
  { ad: string; liste: string; yol: string; ikon: string } {
  const yon: CariYon = yonIstenen ?? (c.musteri || !c.tedarikci ? 'satis' : 'alis');
  if (islem === 'kart') {
    const liste = c.musteri ? '/cari' : '/tedarikci';
    return { ad: `${c.musteri ? 'Müşteri' : 'Tedarikçi'} kartı`, liste, yol: `${liste}/${c.id}`, ikon: c.musteri ? '👥' : '🤝' };
  }
  if (islem === 'ekstre')
    return { ad: 'Cari ekstresi', liste: '/ekstre', yol: `/ekstre?tur=cari&id=${c.id}`, ikon: '📄' };
  const liste = BELGE_ROTA[yon][islem];
  return { ad: `Yeni ${yon === 'satis' ? 'satış' : 'alış'} ${ISLEM_ADI[islem]}`, liste,
           yol: `${liste}/yeni?${liste === '/belge' ? 'tur=15&' : ''}tarafId=${c.id}&tarafUnvan=${encodeURIComponent(c.ad)}`,
           ikon: islem === 'siparis' ? '📋' : islem === 'fatura' ? '🧾' : '🚚' };
}
