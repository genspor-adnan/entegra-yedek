import type { IzlemVital } from '../../api/uclar/yatan';

/**
 * VİTAL EĞRİSİ — mockup `Ekranlar/Yatan/hemsire_izlem.html` (`.grafik`).
 *
 * <b>ÇİFT EKSEN:</b> ateş (35–41 °C) ile nabız/solunum (0–140) aynı eksene
 * konulsaydı ateş düz bir çizgi olurdu — oysa 37,4 ile 38,9 arasındaki fark
 * tedavi değiştirir.
 *
 * <b>Kütüphane yok, düz SVG.</b> Grafik dört çizgi ve bir eşik bandından
 * ibaret; bunun için 60 KB'lık bir çizim kütüphanesi yüklemek, mockup'ın
 * ölçülerini de o kütüphanenin varsayılanlarına teslim etmek olurdu.
 *
 * <b>Eksik ölçüm noktası ATLANIR, sıfır çizilmez:</b> ölçülmemiş nabzı sıfır
 * göstermek, eğriyi taban çizgisine indirip "hasta kötüleşti" izlenimi verir.
 */

const G = 34;           // sol/sağ eksen payı
const UST = 12;
const YUK = 190;
const GEN = 760;

interface Seri { ad: string; renk: string; deg: (v: IzlemVital) => number | null; sag?: boolean }

const SERILER: Seri[] = [
  { ad: 'Nabız',   renk: '#b3261e', deg: v => v.nabiz },
  { ad: 'Solunum', renk: '#2f6db3', deg: v => v.solunum },
  { ad: 'SpO₂',    renk: '#2e7d46', deg: v => v.spo2 },
  // ATEŞ SAĞ EKSENDE: kendi ölçeğinde okunur.
  { ad: 'Ateş',    renk: '#8a6218', deg: v => (v.ates == null ? null : Number(v.ates)), sag: true },
];

export function VitalEgrisi({ vitaller }: { vitaller: IzlemVital[] }) {
  const n = vitaller.length;
  if (n === 0) {
    return <div className="sonuk" style={{ padding: 14 }}>Bu pencerede ölçüm yok.</div>;
  }

  const x = (i: number) => G + (n === 1 ? (GEN - 2 * G) / 2 : (i * (GEN - 2 * G)) / (n - 1));
  // SOL EKSEN 0-140: nabız, solunum ve SpO₂'nin ortak aralığı.
  const ySol = (v: number) => UST + (YUK - UST) * (1 - Math.min(Math.max(v, 0), 140) / 140);
  // SAĞ EKSEN 35-41 °C: ateşin klinik aralığı; dışına taşan değer kırpılır.
  const ySag = (v: number) => UST + (YUK - UST) * (1 - (Math.min(Math.max(v, 35), 41) - 35) / 6);

  const yol = (s: Seri) => {
    const parcalar: string[] = [];
    let kalem = false;
    vitaller.forEach((v, i) => {
      const d = s.deg(v);
      // ÖLÇÜLMEYEN DEĞER ÇİZGİYİ KESER: ara değer uydurmak, olmayan bir
      //   ölçümü varmış gibi gösterir.
      if (d == null) { kalem = false; return }
      const py = s.sag ? ySag(d) : ySol(d);
      parcalar.push(`${kalem ? 'L' : 'M'}${x(i).toFixed(1)},${py.toFixed(1)}`);
      kalem = true;
    });
    return parcalar.join(' ');
  };

  const saat = (t: string) => new Date(t).toTimeString().slice(0, 5);

  return (
    <div className="vital-egri">
      <svg viewBox={`0 0 ${GEN} ${YUK + 26}`} width="100%" height="220"
           preserveAspectRatio="none">
        {/* ATEŞ EŞİK BANDI (38 °C üstü): hekimin eşiği hatırlamasını beklemek
            yerine bandı çiziyoruz. */}
        <rect x={G} y={UST} width={GEN - 2 * G} height={ySag(38) - UST}
              fill="#fdf3e6" />
        {[0, 35, 70, 105, 140].map(v => (
          <g key={v}>
            <line x1={G} x2={GEN - G} y1={ySol(v)} y2={ySol(v)} stroke="#e3e9f0" />
            <text x={4} y={ySol(v) + 3} fontSize="9" fill="#6b7a8b">{v}</text>
          </g>
        ))}
        {[35, 37, 39, 41].map(v => (
          <text key={v} x={GEN - G + 4} y={ySag(v) + 3} fontSize="9" fill="#8a6218">{v}°</text>
        ))}

        {SERILER.map(s => (
          <path key={s.ad} d={yol(s)} fill="none" stroke={s.renk} strokeWidth="1.6" />
        ))}

        {/* NOKTALAR: ölçüm anı görünsün - çizgi tek başına "kaç ölçüm var"
            sorusunu cevaplamaz. */}
        {SERILER.map(s => vitaller.map((v, i) => {
          const d = s.deg(v);
          if (d == null) return null;
          return <circle key={`${s.ad}${i}`} cx={x(i)} cy={s.sag ? ySag(d) : ySol(d)}
                         r="2.2" fill={s.renk} />;
        }))}

        {/* ZAMAN ETİKETLERİ seyrek: on ölçümde on etiket okunmaz. */}
        {vitaller.map((v, i) => (
          (n <= 8 || i % Math.ceil(n / 8) === 0) && (
            <text key={v.id} x={x(i)} y={YUK + 16} fontSize="9" fill="#6b7a8b"
                  textAnchor="middle">{saat(v.zaman)}</text>
          )
        ))}
      </svg>
      <div className="egri-lejant">
        {SERILER.map(s => (
          <span key={s.ad}><i style={{ background: s.renk }} />{s.ad}
            {s.sag && <em> (sağ eksen)</em>}</span>
        ))}
        <span className="sonuk">Ateş kendi ekseninde: ortak eksende 37,4 ile 38,9 aynı görünürdü.</span>
      </div>
    </div>
  );
}
