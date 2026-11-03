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
export type CariIslem = 'siparis' | 'fatura' | 'irsaliye' | 'tahsilat' | 'odeme' | 'kart' | 'ekstre';
export type CariYon = 'satis' | 'alis';
export interface SeciliCari { id: number; ad: string; kod: string; musteri: boolean; tedarikci: boolean; il?: string;
  /** Ad aramasında seçilen kaydın türü (03.11.2026): kişi / personel / hastada belge komutları yok, öneriler + kart var. */
  tur?: 'musteri' | 'tedarikci' | 'kisi' | 'personel' | 'hasta' }

const ISLEM_SOZ: [string, CariIslem][] = [
  ['sip', 'siparis'], ['siparis', 'siparis'], ['fat', 'fatura'], ['fatura', 'fatura'],
  ['irs', 'irsaliye'], ['irsaliye', 'irsaliye'], ['kart', 'kart'], ['karti', 'kart'], ['eks', 'ekstre'], ['ekstre', 'ekstre'],
  // TAHSİLAT / ÖDEME (kullanıcı 03.11.2026: "cari türüne müş/ted oluşuna göre tahsilat/ödeme işlemleri de gelebilir").
  ['tah', 'tahsilat'], ['tahsilat', 'tahsilat'], ['ode', 'odeme'], ['odeme', 'odeme'],
];
const FIIL = new Set(['al', 'kes', 'ac', 'olus', 'olustur', 'yeni', 'ver', 'gir', 'yap']);

/**
 * TAHSİLAT / ÖDEME ARACI (kullanıcı 03.11.2026: "tahsilat var sadece menüde o da nakit.. havale/çek vb de gelmiş olabilir..
 * tahsilat a subquery yapsan iyi olur"). Kasa işlemi türleri CariAksiyonMenusu ile aynı: tahsilat 21-25 + plan 61,
 * ödeme 31-35 + plan 71. "tah çek", "öde havale", "tahsilat pos" doğrudan o aracı açar; araçsız "tahsilat" alt listeyi verir.
 */
export type KasaArac = 'nakit' | 'havale' | 'kart' | 'cek' | 'senet' | 'plan';
export const KASA_ARACLARI: Record<'tahsilat' | 'odeme', { arac: KasaArac; ad: string; tur: number; ikon: string }[]> = {
  tahsilat: [
    { arac: 'nakit', ad: 'Nakit', tur: 21, ikon: '💵' }, { arac: 'havale', ad: 'Havale / EFT', tur: 22, ikon: '🏦' },
    { arac: 'kart', ad: 'POS', tur: 25, ikon: '💳' }, { arac: 'cek', ad: 'Çek', tur: 23, ikon: '📃' },
    { arac: 'senet', ad: 'Senet', tur: 24, ikon: '📜' }, { arac: 'plan', ad: 'Tahsilat Planı', tur: 61, ikon: '🗓️' },
  ],
  odeme: [
    { arac: 'nakit', ad: 'Nakit', tur: 31, ikon: '💸' }, { arac: 'havale', ad: 'Havale / EFT', tur: 32, ikon: '🏦' },
    { arac: 'kart', ad: 'Kredi Kartı', tur: 35, ikon: '💳' }, { arac: 'cek', ad: 'Çek', tur: 33, ikon: '📃' },
    { arac: 'senet', ad: 'Senet', tur: 34, ikon: '📜' }, { arac: 'plan', ad: 'Ödeme Planı', tur: 71, ikon: '🗓️' },
  ],
};
const ARAC_SOZ: [string, KasaArac][] = [
  ['nakit', 'nakit'], ['nak', 'nakit'], ['havale', 'havale'], ['hav', 'havale'], ['eft', 'havale'], ['banka', 'havale'],
  ['pos', 'kart'], ['kredi', 'kart'], ['kk', 'kart'], ['cek', 'cek'], ['senet', 'senet'], ['sen', 'senet'], ['plan', 'plan'],
  ['plani', 'plan'], ['taksit', 'plan'],
];

/** "sip al" -> siparis; "sat fat kes" -> fatura/satis; "" -> null (hepsi listelenir). Tanınmayan sözcük -> 'yok'. */
export function cariIslemCoz(metin: string): { islem: CariIslem | null; yon: CariYon | null; arac?: KasaArac } | 'yok' {
  const kel = paletSadelestir(metin).split(/\s+/).map(k => k.replace(/[^a-z]/g, '')).filter(Boolean);
  let islem: CariIslem | null = null; let yon: CariYon | null = null; let arac: KasaArac | undefined;
  const kasaMi = () => islem === 'tahsilat' || islem === 'odeme';
  for (const k of kel) {
    if (k === 'sat' || k === 'satis' || k === 'satiş') { yon = 'satis'; continue }
    if (k === 'alis' || k === 'alim') { yon = 'alis'; continue }
    if (FIIL.has(k)) continue;
    // Araç sözcüğü (çek, havale, pos…) - "kart" tahsilat / ödemeden SONRA araçtır (POS / kredi kartı), yoksa kart işlemi.
    const ar = ARAC_SOZ.find(([s]) => k === s) ?? (k === 'kart' || k === 'karti' ? (kasaMi() ? ['kart', 'kart' as KasaArac] : undefined) : undefined);
    if (ar) { arac = ar[1]; continue }
    // Önek: "siparisi", "faturası", "irsaliyesi", "kartı" - ilk 3 harf yeter.
    const bul = k.length >= 3 ? ISLEM_SOZ.find(([s]) => k.startsWith(s) || s.startsWith(k)) : undefined;
    if (bul) { if (!islem || islem === 'kart') islem = bul[1]; continue }
    return 'yok';
  }
  // Araç tek başına ("çek", "havale"): carinin rolüne göre tahsilat / ödeme paletin işi - burada tahsilat varsayılmaz.
  if (arac && !kasaMi()) return islem ? 'yok' : { islem: null, yon, arac };
  return arac ? { islem, yon, arac } : { islem, yon };
}

export const ISLEM_SIRASI: CariIslem[] = ['siparis', 'fatura', 'irsaliye', 'tahsilat', 'odeme', 'kart', 'ekstre'];
/** Komut yazılmadığında (boş kutu) carinin rolüne uyan işlemler: müşteriye tahsilat, tedarikçiye ödeme; rolsüzse ikisi de. */
export const rolIslemleri = (c: SeciliCari): CariIslem[] => ISLEM_SIRASI.filter(i =>
  i === 'tahsilat' ? c.musteri || !c.tedarikci : i === 'odeme' ? c.tedarikci || !c.musteri : true);
const BELGE_ROTA: Record<CariYon, Record<'siparis' | 'fatura' | 'irsaliye', string>> = {
  // Satış Faturası Listesi menüde '/belge' (yeni fatura '/belge/yeni?tur=15', BelgeYeniRota).
  satis: { siparis: '/siparis', fatura: '/belge', irsaliye: '/satis-irsaliye' },
  alis: { siparis: '/alis-siparis', fatura: '/alis-fatura', irsaliye: '/alis-irsaliye' },
};
const ISLEM_ADI: Record<CariIslem, string> = { siparis: 'siparişi', fatura: 'faturası', irsaliye: 'irsaliyesi', tahsilat: '', odeme: '', kart: '', ekstre: '' };

/** İşlemin ekranı (liste rotası - menüde yoksa yetki yok) ve gidilecek yol. */
export function cariIslemHedefi(c: SeciliCari, islem: CariIslem, yonIstenen: CariYon | null, arac?: KasaArac):
  { ad: string; liste: string; yol: string; ikon: string } {
  const yon: CariYon = yonIstenen ?? (c.musteri || !c.tedarikci ? 'satis' : 'alis');
  if (islem === 'kart') {
    const liste = c.musteri ? '/cari' : '/tedarikci';
    return { ad: `${c.musteri ? 'Müşteri' : 'Tedarikçi'} kartı`, liste, yol: `${liste}/${c.id}`, ikon: c.musteri ? '👥' : '🤝' };
  }
  if (islem === 'ekstre')
    return { ad: 'Cari ekstresi', liste: '/ekstre', yol: `/ekstre?tur=cari&id=${c.id}`, ikon: '📄' };
  // Kasa işlemi kartı cari dolu açılır (CariAksiyonMenusu ile aynı yol); araç verilmezse nakit.
  if (islem === 'tahsilat' || islem === 'odeme') {
    const a = KASA_ARACLARI[islem].find(x => x.arac === (arac ?? 'nakit'))!;
    return { ad: `${islem === 'tahsilat' ? 'Tahsilat al' : 'Ödeme yap'} — ${a.ad}`, liste: '/kasa-islem',
             yol: `/kasa-islem/yeni?tur=${a.tur}&tarafId=${c.id}&tarafUnvan=${encodeURIComponent(c.ad)}`, ikon: a.ikon };
  }
  const liste = BELGE_ROTA[yon][islem];
  return { ad: `Yeni ${yon === 'satis' ? 'satış' : 'alış'} ${ISLEM_ADI[islem]}`, liste,
           yol: `${liste}/yeni?${liste === '/belge' ? 'tur=15&' : ''}tarafId=${c.id}&tarafUnvan=${encodeURIComponent(c.ad)}`,
           ikon: islem === 'siparis' ? '📋' : islem === 'fatura' ? '🧾' : '🚚' };
}
