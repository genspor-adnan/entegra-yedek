import { useMemo } from 'react';
import type { DisOdontogramSatiri } from '../../api/uclar/dis';

/**
 * DOĞAL GÖRÜNÜMLÜ ODONTOGRAM — mockup `Ekranlar/Dis Klinigi/dis_hasta_karti_v5.html`.
 *
 * İki düz sıra: üst çene kökler yukarı (18…28), alt çene kökler aşağı (48…38).
 * Sekiz diş tipi için kron ve kök yolu; kronun üstünde beş GÖRÜNMEZ yüzey
 * bölgesi (M · D · O/I · V · L) - tıklanır ve durumla boyanır.
 *
 * <b>Veri tek kaynaktan:</b> `dis_odontogram` aktif satırları. Katman 1
 * (mevcut) yüzeyi/dişi boyar, katman 2 (planlanan) kesikli kırmızı çerçeve,
 * katman 3 (tamamlanan) yeşil çerçeve. Aynı dizi Diş Tablosu görünümünü de
 * besler - iki görünüm birbirinden ayrışamaz.
 *
 * Çizim SVG path'leri buradadır, veri modeli değildir: "36 O çürük" satırı
 * sunucuda durur, burada yalnız boyanır.
 */

export interface DisSecim { disNo: number; yz: string[] }

export const DIS_ADLARI: Record<number, string> = {
  1: 'santral kesici', 2: 'lateral kesici', 3: 'kanin', 4: '1. küçük azı',
  5: '2. küçük azı', 6: '1. büyük azı', 7: '2. büyük azı', 8: "3. büyük azı (20'lik)",
};
export const CENE_ADLARI: Record<number, string> = { 1: 'sağ üst', 2: 'sol üst', 3: 'sol alt', 4: 'sağ alt',
                                                     5: 'sağ üst (süt)', 6: 'sol üst (süt)', 7: 'sol alt (süt)', 8: 'sağ alt (süt)' };
export const disAdi = (n: number) => `${CENE_ADLARI[Math.floor(n / 10)] ?? ''} ${DIS_ADLARI[n % 10] ?? ''}`.trim();

/** Durum kodu (kod_liste dis.durum) → çizim sınıfı. Yalnız çizilebilenler. */
export function durumSinifi(kod: number): string {
  if (kod >= 1 && kod <= 3) return 'curuk';
  if (kod === 10) return 'dolgu';
  if (kod === 11 || kod === 12) return 'kompozit';
  if (kod === 20) return 'kanal';
  if (kod >= 30 && kod <= 32) return 'kron';
  if (kod === 40) return 'implant';
  if (kod === 50) return 'eksik';
  if (kod === 80) return 'protez';
  return '';
}

export const DURUM_ADLARI: Record<number, string> = {
  0: 'Sağlam', 1: 'Çürük (başlangıç)', 2: 'Çürük (dentin)', 3: 'Çürük (derin)', 10: 'Amalgam dolgu',
  11: 'Kompozit dolgu', 12: 'İnlay / onlay', 20: 'Kanal tedavili', 30: 'Kron', 31: 'Köprü ayağı',
  32: 'Köprü gövdesi', 40: 'İmplant', 50: 'Eksik', 51: 'Çekim endikasyonu', 52: 'Gömülü', 60: 'Kırık',
  61: 'Aşınma', 62: 'Mobil', 70: 'Süt kalıntısı', 71: 'Sürmemiş', 80: 'Protez',
};

/** Bir dişin çizim özeti: yüzey → sınıf, tüm diş bayrakları, plan/tamam. */
export interface DisGorunumu {
  yz: Record<string, string>;
  kron: boolean; kanal: boolean; implant: boolean; eksik: boolean;
  plan: boolean; tamam: boolean;
  /** Katman 1 satırları (rozet listesi için). */
  bulgular: DisOdontogramSatiri[];
}

export function disGorunumleri(satirlar: DisOdontogramSatiri[]): Record<number, DisGorunumu> {
  const h: Record<number, DisGorunumu> = {};
  const al = (n: number) => (h[n] ??= { yz: {}, kron: false, kanal: false, implant: false, eksik: false,
                                       plan: false, tamam: false, bulgular: [] });
  for (const s of satirlar) {
    const g = al(s.disNo);
    if (s.katman === 2) { g.plan = true; continue; }
    if (s.katman === 3) { g.tamam = true; continue; }
    g.bulgular.push(s);
    const sinif = durumSinifi(s.durumKod);
    if (!sinif) continue;
    if (sinif === 'eksik') g.eksik = true;
    else if (sinif === 'kron' || sinif === 'protez') g.kron = true;
    else if (sinif === 'kanal') g.kanal = true;
    else if (sinif === 'implant') g.implant = true;
    else if (s.yuzeyler) for (const y of s.yuzeyler) g.yz[y] = sinif;
    else for (const y of ['M', 'D', 'O', 'I', 'V', 'L']) g.yz[y] = sinif;
  }
  return h;
}

// ---------------------------------------------------------- SVG geometri ----
function kronYolu(t: number, w: number, ch: number): string {
  const a = w / 2;
  switch (t) {
    case 1: case 2:
      return `M${-a * 0.62} 0 C${-a * 0.95} ${ch * 0.45} ${-a} ${ch * 0.9} ${-a * 0.9} ${ch}`
           + ` L${a * 0.9} ${ch} C${a} ${ch * 0.9} ${a * 0.95} ${ch * 0.45} ${a * 0.62} 0 Z`;
    case 3:
      return `M${-a * 0.7} 0 C${-a} ${ch * 0.45} ${-a * 0.9} ${ch * 0.85} 0 ${ch}`
           + ` C${a * 0.9} ${ch * 0.85} ${a} ${ch * 0.45} ${a * 0.7} 0 Z`;
    case 4: case 5:
      return `M${-a * 0.75} 0 C${-a * 1.05} ${ch * 0.35} ${-a} ${ch * 0.95} ${-a * 0.35} ${ch}`
           + ` Q0 ${ch * 0.86} ${a * 0.35} ${ch} C${a} ${ch * 0.95} ${a * 1.05} ${ch * 0.35} ${a * 0.75} 0 Z`;
    default:
      return `M${-a * 0.9} 0 C${-a * 1.1} ${ch * 0.35} ${-a * 1.05} ${ch * 0.95} ${-a * 0.55} ${ch}`
           + ` Q${-a * 0.3} ${ch * 0.84} 0 ${ch * 0.97} Q${a * 0.3} ${ch * 0.84} ${a * 0.55} ${ch}`
           + ` C${a * 1.05} ${ch * 0.95} ${a * 1.1} ${ch * 0.35} ${a * 0.9} 0 Z`;
  }
}

function kokYolu(no: number, w: number, rh: number): string {
  const t = no % 10, ust = Math.floor(no / 10) <= 2 || Math.floor(no / 10) === 5 || Math.floor(no / 10) === 6, a = w / 2;
  const tek = (g: number, L: number, kay = 0) =>
    `M${-a * g} 0 C${-a * g * 0.9 + kay} ${-L * 0.45} ${-a * 0.12 + kay} ${-L * 0.9} ${kay} ${-L}`
    + ` C${a * 0.12 + kay} ${-L * 0.9} ${a * g * 0.9 + kay} ${-L * 0.45} ${a * g} 0 Z`;
  const cift = (L: number, ac: number) =>
    `M${-a * 0.85} 0 C${-a * 0.95} ${-L * 0.5} ${-a * ac - a * 0.1} ${-L * 0.9} ${-a * ac} ${-L}`
    + ` C${-a * ac + a * 0.12} ${-L * 0.85} ${-a * 0.12} ${-L * 0.45} 0 ${-L * 0.28}`
    + ` C${a * 0.12} ${-L * 0.45} ${a * ac - a * 0.12} ${-L * 0.85} ${a * ac} ${-L}`
    + ` C${a * ac + a * 0.1} ${-L * 0.9} ${a * 0.95} ${-L * 0.5} ${a * 0.85} 0 Z`;
  const uclu = (L: number) => `${cift(L * 0.9, 0.55)} ${tek(0.32, L, 0)}`;
  switch (t) {
    case 1: return tek(0.5, rh * 1.05);
    case 2: return tek(0.47, rh);
    case 3: return tek(0.55, rh * 1.3);
    case 4: return ust ? cift(rh * 0.95, 0.45) : tek(0.6, rh * 0.95);
    case 5: return tek(0.6, rh * 0.9);
    case 6: return ust ? uclu(rh * 0.95) : cift(rh * 0.9, 0.62);
    case 7: return ust ? uclu(rh * 0.85) : cift(rh * 0.8, 0.58);
    default: return ust ? tek(0.75, rh * 0.6) : cift(rh * 0.55, 0.4);
  }
}

type Nokta = [number, number];
function yuzeyler(no: number, w: number, ch: number): Record<string, Nokta[]> {
  const a = w / 2, cene = Math.floor(no / 10);
  const solMu = cene === 2 || cene === 3 || cene === 6 || cene === 7;
  const on = no % 10 <= 3;
  const oy = on ? ch * 0.82 : ch * 0.72;
  const z: Record<string, Nokta[]> = {
    L: [[-a * 0.62, 0], [a * 0.62, 0], [a * 0.72, ch * 0.18], [-a * 0.72, ch * 0.18]],
    V: [[-a * 0.42, ch * 0.18], [a * 0.42, ch * 0.18], [a * 0.42, oy], [-a * 0.42, oy]],
    M: [[-a * 0.72, ch * 0.18], [-a * 0.42, ch * 0.18], [-a * 0.42, oy], [-a * 0.9, oy]],
    D: [[a * 0.42, ch * 0.18], [a * 0.72, ch * 0.18], [a * 0.9, oy], [a * 0.42, oy]],
    O: [[-a * 0.9, oy], [a * 0.9, oy], [a * 0.9, ch], [-a * 0.9, ch]],
  };
  if (solMu) { const t = z.M; z.M = z.D; z.D = t; }
  return z;
}

const UST_DAIMI = [18, 17, 16, 15, 14, 13, 12, 11, 21, 22, 23, 24, 25, 26, 27, 28];
const ALT_DAIMI = [48, 47, 46, 45, 44, 43, 42, 41, 31, 32, 33, 34, 35, 36, 37, 38];
const UST_SUT = [55, 54, 53, 52, 51, 61, 62, 63, 64, 65];
const ALT_SUT = [85, 84, 83, 82, 81, 71, 72, 73, 74, 75];
export const DIS_SIRASI = [...UST_DAIMI, ...ALT_DAIMI];
export const SUT_SIRASI = [...UST_SUT, ...ALT_SUT];

interface Props {
  satirlar: DisOdontogramSatiri[];
  secili: DisSecim | null;
  onSec(secim: DisSecim): void;
  /** Katman görünürlüğü: mevcut · planlanan · tamamlanan. */
  katmanlar?: { mevcut: boolean; plan: boolean; tamam: boolean };
  /** 1 daimi · 2 süt. Karma (3) daimi sırayı çizer. */
  dentisyon?: number;
}

export function Odontogram({ satirlar, secili, onSec, katmanlar, dentisyon = 1 }: Props) {
  const g = useMemo(() => disGorunumleri(satirlar), [satirlar]);
  const k = katmanlar ?? { mevcut: true, plan: true, tamam: true };
  const sut = dentisyon === 2;
  const ust = sut ? UST_SUT : UST_DAIMI, alt = sut ? ALT_SUT : ALT_DAIMI;
  const adim = sut ? 50 : 32, bas = sut ? 20 : 14;
  const genislik = bas * 2 + adim * ust.length;
  const orta = genislik / 2;

  const dis = (no: number, x: number, y: number, ustMu: boolean) => {
    const d = g[no] ?? { yz: {}, kron: false, kanal: false, implant: false, eksik: false, plan: false, tamam: false, bulgular: [] };
    const t = no % 10;
    const w = t >= 6 ? 29 : t >= 4 ? 21 : t === 3 ? 18 : t === 1 ? 18 : 15;
    const ch = t >= 6 ? 21 : t >= 4 ? 21 : t === 3 ? 25 : 22;
    const rh = 34;
    const on = t <= 3, ad = on ? 'I' : 'O';
    const z = yuzeyler(no, w, ch);
    const sec = secili?.disNo === no;
    const L = rh * 0.9;
    const tumu = ['M', 'D', ad, 'V', 'L'];
    return (
      <g key={no}>
        <g transform={`translate(${x} ${y})${ustMu ? '' : ' scale(1 -1)'}`} className={d.eksik && k.mevcut ? 'eksik' : ''}>
          {d.implant && k.mevcut ? (
            <>
              <path d={`M${-w * 0.18} 0 L${-w * 0.12} ${-L} L${w * 0.12} ${-L} L${w * 0.18} 0 Z`} className="imp" />
              {[1, 2, 3, 4, 5, 6].map(q => (
                <line key={q} x1={-w * 0.2} y1={-L * q / 7} x2={w * 0.2} y2={-L * q / 7} className="impDis" />
              ))}
              <rect x={-w * 0.28} y={-4} width={w * 0.56} height={5} rx={1.5} className="imp" />
            </>
          ) : (
            <>
              <path d={kokYolu(no, w, rh)} className={`kok${d.kanal && k.mevcut ? ' kanal' : ''}`} />
              {d.kanal && k.mevcut && <path d={`M0 -3 L0 ${-rh * 0.8}`} className="kanalHat" />}
            </>
          )}
          <path d={kronYolu(t, w, ch)} className="kron" />
          {d.kron && k.mevcut && <path d={kronYolu(t, w, ch)} className="kronKap" />}
          {Object.keys(z).map(y => {
            const kod = y === 'O' ? ad : y;
            const durum = k.mevcut ? d.yz[kod] : undefined;
            return (
              <polygon key={y} points={z[y].map(p => p.join(',')).join(' ')}
                       className={`yz${durum ? ' ' + durum : ''}${sec && secili?.yz.includes(kod) ? ' sec' : ''}`}
                       onClick={() => onSec({ disNo: no, yz: [kod] })}>
                <title>{no} {kod}</title>
              </polygon>
            );
          })}
          {d.eksik && k.mevcut && (
            <>
              <line x1={-w * 0.45} y1={ch * 0.15} x2={w * 0.45} y2={ch * 0.95} className="x" />
              <line x1={w * 0.45} y1={ch * 0.15} x2={-w * 0.45} y2={ch * 0.95} className="x" />
            </>
          )}
          {d.plan && k.plan && <rect x={-w * 0.62} y={-3} width={w * 1.24} height={ch + 6} rx={4} className="plan" />}
          {d.tamam && k.tamam && <rect x={-w * 0.68} y={-5} width={w * 1.36} height={ch + 10} rx={5} className="tamam" />}
        </g>
        {/* numara kron kenarının ötesinde - aynalanmaz */}
        <rect x={x - 8} y={(ustMu ? y + 34 : y - 34) - 5} width={16} height={9} rx={2}
              className={`nokutu${sec ? ' sec' : ''}`} onClick={() => onSec({ disNo: no, yz: tumu })} />
        <text x={x} y={(ustMu ? y + 34 : y - 34) + 2} className={`no${sec ? ' sec' : ''}`}
              onClick={() => onSec({ disNo: no, yz: tumu })}>{no}</text>
      </g>
    );
  };

  return (
    <svg className="ds-odo" viewBox={`0 0 ${genislik} 212`} aria-label="Odontogram">
      <defs>
        <linearGradient id="dsMine" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor="#fffdf8" /><stop offset=".55" stopColor="#f3ede1" /><stop offset="1" stopColor="#ddd3c1" />
        </linearGradient>
        <linearGradient id="dsKok" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#efe2c8" /><stop offset="1" stopColor="#c9ae86" />
        </linearGradient>
        <linearGradient id="dsAltin" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#f6dc8a" /><stop offset=".5" stopColor="#d9a12b" /><stop offset="1" stopColor="#b8841a" />
        </linearGradient>
        <linearGradient id="dsAmalgam" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#c9d1d9" /><stop offset="1" stopColor="#8a95a1" />
        </linearGradient>
        <linearGradient id="dsMetal" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor="#d5dbe1" /><stop offset="1" stopColor="#7c8892" />
        </linearGradient>
      </defs>
      <line x1={orta} y1={12} x2={orta} y2={200} className="orta" />
      <line x1={8} y1={106} x2={genislik - 8} y2={106} className="dis" />
      <text x={16} y={11} className="cene">{sut ? 'ÜST ÇENE · süt · 55 … 65' : 'ÜST ÇENE · sağ ← 18 … 28 → sol'}</text>
      <text x={16} y={207} className="cene">{sut ? 'ALT ÇENE · 85 … 75' : 'ALT ÇENE · 48 … 38'}</text>
      {ust.map((no, i) => dis(no, bas + i * adim + adim / 2, 62, true))}
      {alt.map((no, i) => dis(no, bas + i * adim + adim / 2, 150, false))}
    </svg>
  );
}
