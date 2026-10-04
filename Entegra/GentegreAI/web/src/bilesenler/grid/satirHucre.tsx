import type { KolonMeta, ListeSatiri } from '../../api/sozlesme';
import { sayi } from '../bicim';

/**
 * SATIRDAN BESLENEN HÜCRELER (963, mockup Ekranlar/IK/personel_listesi.html).
 *
 * Biçim SUNUCUDAN gelir (KolonTanimi.Bicim); ikinci satırın ya da çubuğun
 * hangi alandan okunacağını da o söyler - istemci kolon adı bilmez:
 *   "kisi:rolAdi"     avatar (baş harfler) + ad + altında rolAdi
 *   "alt:gorev"       değer + altında gorev
 *   "cubuk:hakToplam" değer + değer/hakToplam doluluk çubuğu
 *   "sayac"           0 boş, >0 turuncu rozet
 *   "uyari"           dolu ise kırmızı "⚠ ..."
 *   "odos:gibOs:gibYuksek"  sağ / sol iki değer (değer = OD); üçüncü alan bayrak
 *                     biti (1 OD, 2 OS) kırmızı çizer (970 göz muayene listesi)
 *   "dozlar"          "08:00|2;20:00|1" -> saat çipleri (968 order listesi):
 *                     2 verildi ✓ · 1 bekliyor · 5 gecikti · 3/4 atlandı / reddetti
 */

/** "Dr. Aslı Demir" -> "AD" (unvan öneki ve "(çağrı)" gibi parantezli ekler atlanır). */
export function basHarfler(ad: string): string {
  const p = ad.replace(/\([^)]*\)/g, ' ').split(/\s+/).filter(x => /^\p{L}/u.test(x) && !x.endsWith('.'));
  return ((p[0]?.[0] ?? '') + (p.length > 1 ? p[p.length - 1][0] : '')).toLocaleUpperCase('tr-TR') || '?';
}

const RENKLER = ['#2f6db3', '#8e44ad', '#16a085', '#c0392b', '#d35400', '#27ae60', '#2c3e50', '#2980b9', '#7f8c8d', '#b7950b'];
/** Aynı kişi her ekranda aynı renk: addan türetilir. */
export function avatarRengi(ad: string): string {
  let h = 0;
  for (const ch of ad) h = (h * 31 + ch.charCodeAt(0)) >>> 0;
  return RENKLER[h % RENKLER.length];
}

export function Avatar({ ad, buyuk, soluk }: { ad: string; buyuk?: boolean; soluk?: boolean }) {
  return (
    <span className={`gh-av${buyuk ? ' buyuk' : ''}`} style={{ background: soluk ? '#b8c2cc' : avatarRengi(ad) }}>
      {basHarfler(ad)}
    </span>
  );
}

export function satirHucre(satir: ListeSatiri, kolon: KolonMeta) {
  const b = kolon.bicim ?? '';
  const v = satir[kolon.ad];
  if (b.startsWith('kisi:')) {
    const ad = String(v ?? '');
    const alt = String(satir[b.slice(5)] ?? '');
    return (
      <span className="gh-kisi">
        <Avatar ad={ad} soluk={Number(satir.durum ?? 1) !== 1} />
        <span><b>{ad}</b>{alt && <small>{alt}</small>}</span>
      </span>
    );
  }
  if (b.startsWith('alt:')) {
    const alt = String(satir[b.slice(4)] ?? '');
    return <span className="gh-iki">{String(v ?? '')}{alt && <small>{alt}</small>}</span>;
  }
  if (b.startsWith('cubuk:')) {
    if (v === null || v === undefined || v === '') return <span className="gh-sonuk">—</span>;
    const n = Number(v), tavan = Number(satir[b.slice(6)] ?? 0);
    const oran = tavan > 0 ? Math.max(0, Math.min(100, (n / tavan) * 100)) : 0;
    return (
      <span className="gh-cubuk" title={tavan > 0 ? `${sayi.format(n)} / ${sayi.format(tavan)}` : undefined}>
        <span className="yol"><span style={{ width: `${oran}%` }} className={n < 0 ? 'eksi' : undefined} /></span>
        {sayi.format(n)}
      </span>
    );
  }
  if (b === 'sayac') {
    const n = Number(v ?? 0);
    return n > 0 ? <span className="gh-sayac">{n}</span> : null;
  }
  if (b.startsWith('odos:')) {
    const [, osAlan, bayrakAlan] = b.split(':');
    const bayrak = Number(satir[bayrakAlan] ?? 0);
    const yaz = (x: unknown) => (x === null || x === undefined || x === '' ? '—'
      : Number(x).toLocaleString('tr-TR', { maximumFractionDigits: 2 }));
    return (
      <span className="gh-odos">
        <i>S</i><span className={bayrak & 1 ? 'kirmizi' : undefined}>{yaz(v)}</span>
        <i>L</i><span className={bayrak & 2 ? 'kirmizi' : undefined}>{yaz(satir[osAlan])}</span>
      </span>
    );
  }
  if (b === 'dozlar') {
    const l = String(v ?? '').split(';').filter(Boolean);
    if (l.length === 0) return <span className="gh-sonuk">—</span>;
    return (
      <span className="gh-dozlar">{l.map((x, i) => {
        const [saat, d] = x.split('|');
        const dn = Number(d);
        const sinif = dn === 2 ? 'ok' : dn === 5 ? 'gec' : dn === 3 || dn === 4 ? 'atl' : 'bek';
        return <span key={i} className={`gh-doz ${sinif}`}>{saat}{dn === 2 ? ' ✓' : dn === 5 ? ' gecikti' : ''}</span>;
      })}</span>
    );
  }
  if (b === 'uyari') {
    const m = String(v ?? '').trim();
    return m ? <span className="gh-uyari">⚠ {m}</span> : null;
  }
  return undefined;
}
