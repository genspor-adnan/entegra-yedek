import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { c } from '../dil/ceviri';
import { tarihSaat } from './bicim';
import { Modal } from './Modal';

/**
 * ÖLÇÜM GEÇMİŞİ GRAFİĞİ (mockup Ekranlar/Muayene/muayene_karti_v7.html).
 *
 * Bir vital ya da tahlil seçilince hastanın BÜTÜN ölçümleri: çizgi + referans
 * aralığı (yeşil bant), aralık dışı nokta kırmızı, altında tablo. Tansiyonda
 * iki seri (sistolik / diyastolik), her biri kendi referansıyla boyanır.
 *
 * Düz SVG, kütüphane yok (VitalEgrisi ile aynı gerekçe). Sayısal olmayan
 * sonuç ("pozitif", "<5") eğriye girmez, tabloda kalır.
 */
type Veri = Awaited<ReturnType<typeof api.muayeneOlcumGecmisi>>;
const ARALIKLAR = [['3 ay', 92], ['1 yıl', 366], ['Tümü', 0]] as const;
const W = 640, H = 230, SOL = 44, SAG = 14, UST = 14, ALT = 26;
const sayi = (d: number) => (Math.abs(d) < 10 ? d.toFixed(1) : d.toFixed(0)).replace('.', ',');

export function OlcumGrafigi({ muayeneId, secim, onKapat }: {
  muayeneId: number;
  secim: { vital: string } | { tetkik: string };
  onKapat(): void;
}) {
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [gun, setGun] = useState(0);
  const anahtar = 'vital' in secim ? `v:${secim.vital}` : `t:${secim.tetkik}`;

  useEffect(() => {
    let iptal = false;
    api.muayeneOlcumGecmisi(muayeneId, secim)
      .then(v => { if (!iptal) setVeri(v) })
      .catch(h => { if (!iptal) setHata(h instanceof Error ? h.message : String(h)) });
    return () => { iptal = true };
    // secim nesnesi her çizimde yeni; anahtar yeterli.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [muayeneId, anahtar]);

  const sinir = gun > 0 ? Date.now() - gun * 86400000 : 0;
  const tum = (veri?.noktalar ?? []).filter(n => new Date(n.zaman).getTime() >= sinir);
  const noktalar = tum.filter(n => n.deger !== null && n.deger !== undefined);
  const ref = veri?.referans ?? null, ref2 = veri?.referans2 ?? null;

  let svg: React.ReactNode = null;
  if (noktalar.length > 0) {
    const degerler = [...noktalar.map(n => Number(n.deger)),
                      ...noktalar.filter(n => n.deger2 != null).map(n => Number(n.deger2)),
                      ...(ref ?? []), ...(ref2 ?? [])];
    let mn = Math.min(...degerler), mx = Math.max(...degerler);
    const pay = (mx - mn) * 0.12 || 1; mn -= pay; mx += pay;
    const X = (i: number) => SOL + (noktalar.length === 1 ? (W - SOL - SAG) / 2 : i * (W - SOL - SAG) / (noktalar.length - 1));
    const Y = (d: number) => UST + (mx - d) * (H - UST - ALT) / (mx - mn);
    const disari = (d: number, r: number[] | null) => !!r && (d < r[0] || d > r[1]);
    const cizgi = (al: (n: typeof noktalar[0]) => number | null | undefined, renk: string, r: number[] | null) => {
      const p = noktalar.map((n, i) => [i, al(n)] as const).filter(([, d]) => d != null) as [number, number][];
      return <g>
        <polyline fill="none" stroke={renk} strokeWidth={2} points={p.map(([i, d]) => `${X(i)},${Y(d)}`).join(' ')} />
        {p.map(([i, d]) => <g key={i}>
          <circle cx={X(i)} cy={Y(d)} r={4} fill={disari(d, r) ? 'var(--hata)' : renk} />
          <text x={X(i)} y={Y(d) - 8} fontSize={10} textAnchor="middle" fill="currentColor">{sayi(d)}</text>
        </g>)}
      </g>;
    };
    svg = (
      <svg viewBox={`0 0 ${W} ${H}`} className="olcum-svg" preserveAspectRatio="none">
        {ref && <rect x={SOL} y={Y(ref[1])} width={W - SOL - SAG} height={Math.max(0, Y(ref[0]) - Y(ref[1]))} className="olcum-ref" />}
        {[0, 1, 2, 3, 4].map(k => { const d = mn + (mx - mn) * k / 4;
          return <g key={k}><line x1={SOL} x2={W - SAG} y1={Y(d)} y2={Y(d)} className="olcum-izgara" />
            <text x={SOL - 6} y={Y(d) + 3} fontSize={10} textAnchor="end" className="olcum-eksen">{sayi(d)}</text></g>; })}
        {noktalar.map((n, i) => (noktalar.length <= 8 || i % Math.ceil(noktalar.length / 8) === 0 || i === noktalar.length - 1) && (
          <text key={i} x={X(i)} y={H - 8} fontSize={10} textAnchor="middle" className="olcum-eksen">
            {n.bu ? c('bugün') : tarihSaat(n.zaman).slice(0, 10)}</text>))}
        {noktalar.some(n => n.deger2 != null) && cizgi(n => n.deger2, 'var(--mor)', ref2)}
        {cizgi(n => n.deger, 'var(--vurgu)', ref)}
      </svg>
    );
  }

  return (
    <Modal baslik={veri ? `📈 ${veri.ad}${veri.birim ? ` · ${veri.birim}` : ''}` : c('Ölçüm geçmişi')} enUst buyutmeYok
           onKapat={onKapat}
           alt={<button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>}>
      <div className="olcum-ust">
        <span className="not">
          {veri && `${tum.length} ${c('ölçüm')}`}
          {ref && ` · ${c('referans')} ${sayi(ref[0])}–${sayi(ref[1])}`}
        </span>
        <span className="olcum-aralik">
          {ARALIKLAR.map(([ad, g]) => (
            <button key={ad} type="button" className={g === gun ? 'on' : ''} onClick={() => setGun(g)}>{c(ad)}</button>
          ))}
        </span>
      </div>
      {hata && <p className="hata-kutusu">{hata}</p>}
      {veri && noktalar.length === 0 && <p className="not">{c('Bu aralıkta sayısal ölçüm yok.')}</p>}
      {svg}
      {tum.length > 0 && (
        <table className="olcum-tablo">
          <thead><tr><th>{c('Tarih')}</th><th>{c('Değer')}</th><th>{c('Nerede')}</th></tr></thead>
          <tbody>
            {[...tum].reverse().map((n, i) => {
              const d = n.deger == null ? null : Number(n.deger);
              const dis = d != null && !!ref && (d < ref[0] || d > ref[1]);
              return <tr key={i} className={n.bu ? 'bu' : ''}>
                <td>{tarihSaat(n.zaman)}</td>
                <td className={dis ? 'olcum-dis' : ''}>
                  {d == null ? (n.metin ?? '—') : sayi(d)}{n.deger2 != null ? ` / ${sayi(Number(n.deger2))}` : ''} {veri?.birim}
                </td>
                <td>{n.bu ? c('bu muayene') : (n.yer ?? '')}</td>
              </tr>;
            })}
          </tbody>
        </table>
      )}
    </Modal>
  );
}
