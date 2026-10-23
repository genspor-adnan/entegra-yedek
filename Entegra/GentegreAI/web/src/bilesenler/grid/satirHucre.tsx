import type { KolonMeta, ListeSatiri } from '../../api/sozlesme';
import { para, sayi } from '../bicim';

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
 *   "bakiye:dovizBakiye"  B/A renkli tutar + altında döviz bakiyeleri (1150 müşteri listesi)
 *   "risk:riskLimiti" limit kullanım çubuğu (yeşil <%70, sarı, kırmızı >%100); boş = limitsiz
 *   "gun"             "48 gün" - 30+ sarı, 90+ kırmızı
 *   "egri:ciro12Ay"   "a,b,c..." mini çizgi; title'da toplam
 */

/** "Dr. Aslı Demir" -> "AD" (unvan öneki ve "(çağrı)" gibi parantezli ekler atlanır). */
//   Ortak kural (basHarfler.ts): ünvan ve parantezli ekler atılır.
import { basHarfler } from '../basHarfler';
export { basHarfler };

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
  // MÜŞTERİ LİSTESİ VER3 (1150, mockup musteri_listesi_ver3.html).
  if (b.startsWith('bakiye:')) {
    const n = Number(v ?? 0);
    const doviz = dovizBakiyeMetni(satir[b.slice(7)]);
    return (
      <span className="gh-iki gh-bakiye">
        {Math.abs(n) < 0.005 ? <span className="gh-sonuk">{para.format(0)}</span>
          : <span className={n > 0 ? 'borc' : 'alacak'}>{para.format(Math.abs(n))} <small>{n > 0 ? 'B' : 'A'}</small></span>}
        {doviz && <small>{doviz}</small>}
      </span>
    );
  }
  if (b.startsWith('risk:')) {
    if (v === null || v === undefined || v === '') return <span className="gh-sonuk">limitsiz</span>;
    const n = Number(v), limit = Number(satir[b.slice(5)] ?? 0);
    const sinif = n > 100 ? 'kir' : n >= 70 ? 'sari' : '';
    return (
      <span className="gh-cubuk gh-risk" title={limit > 0 ? `Limit ${para.format(limit)}` : undefined}>
        <span className="yol"><span style={{ width: `${Math.min(100, Math.max(0, n))}%` }} className={sinif} /></span>
        %{sayi.format(n)}
      </span>
    );
  }
  if (b === 'gun') {
    if (v === null || v === undefined || v === '') return <span className="gh-sonuk">—</span>;
    const n = Number(v);
    return <span className={`gh-gun${n >= 90 ? ' kir' : n >= 30 ? ' sari' : ''}`}>{sayi.format(n)} gün</span>;
  }
  if (b.startsWith('egri')) {
    const d = String(v ?? '').split(',').filter(Boolean).map(Number);
    if (d.length < 2 || d.every(x => !x)) return <span className="gh-sonuk">—</span>;
    const toplam = b.startsWith('egri:') ? Number(satir[b.slice(5)] ?? 0) : null;
    return <Egri degerler={d} title={toplam !== null ? `12 ay: ${para.format(toplam)}` : undefined} />;
  }
  return undefined;
}

const DOVIZ_SEMBOL: Record<string, string> = { USD: '$', EUR: '€', GBP: '£' };

/** "USD:42500.0000;EUR:-18900" -> "$ 42.500,00 B · € 18.900,00 A" (+ borç, - alacak). */
export function dovizBakiyeMetni(ham: unknown): string {
  return String(ham ?? '').split(';').filter(Boolean).map(p => {
    const [kod, deger] = p.split(':');
    const n = Number(deger);
    return `${DOVIZ_SEMBOL[kod] ?? kod} ${para.format(Math.abs(n))} ${n > 0 ? 'B' : 'A'}`;
  }).join(' · ');
}

/** Mini çizgi grafik: son değer ilk değerden düşükse kırmızı. */
export function Egri({ degerler, genislik = 72, yukseklik = 18, title }:
                     { degerler: number[]; genislik?: number; yukseklik?: number; title?: string }) {
  const enb = Math.max(...degerler, 1), enk = Math.min(...degerler, 0);
  const ara = enb - enk || 1;
  const nokta = degerler.map((x, i) =>
    `${(i * genislik / (degerler.length - 1)).toFixed(1)},${(yukseklik - 2 - ((x - enk) / ara) * (yukseklik - 4)).toFixed(1)}`).join(' ');
  const dusus = degerler[degerler.length - 1] < degerler[0];
  return (
    <svg className="gh-egri" width={genislik} height={yukseklik} viewBox={`0 0 ${genislik} ${yukseklik}`}>
      {title && <title>{title}</title>}
      <polyline fill="none" stroke={dusus ? '#c0413d' : '#3f9a5e'} strokeWidth="1.5" points={nokta} />
    </svg>
  );
}
