/**
 * ŞEMA ZEMİNLERİ — mockup `Ekranlar/Goz/goz_semasi.html` çizimleri.
 *
 * Zemin SABİT bir anatomi çizimidir: hekim üzerine işaret koyar, zemini
 * değiştirmez. Bu yüzden veri değil, çizim; kayıtta yalnız işaretler durur.
 *
 * <b>OD ve OS AYNA:</b> fundus görüntüsünde optik disk nazal taraftadır -
 * sağ gözde sağda, sol gözde solda. Saat kadranı da bu yüzden OD'de saat
 * yönünde, OS'de ters numaralanır. Aynı zemini iki göze de çizmek, sağ/sol
 * karışmasının en sessiz yoluydu.
 *
 * Koordinat sistemi 0–320 (viewBox). Kayıt 0–1 oranıyla tutulur: ekran boyu
 * değişse de işaret aynı yere düşer.
 */

/** Şema türü: 1 ön segment · 2 fundus · 3 periferi · 4 kapak / adneks. */
export function SemaZemini({ semaTuru, goz }: { semaTuru: number; goz: number }) {
  if (semaTuru === 2) return <FundusZemini goz={goz} />;
  if (semaTuru === 3) return <PeriferiZemini goz={goz} />;
  if (semaTuru === 4) return <KapakZemini />;
  return <OnSegmentZemini />;
}

/** Saat rakamları: OD saat yönünde, OS ters. */
function SaatKadrani({ goz, yaricap = 150 }: { goz: number; yaricap?: number }) {
  const saatler = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  return (
    <g fontSize="9" fill="#8a97a5" textAnchor="middle">
      {saatler.map((s, i) => {
        const aci = ((i * 30 - 90) * Math.PI) / 180;
        const x = 160 + Math.cos(aci) * (yaricap + 8);
        const y = 160 + Math.sin(aci) * (yaricap + 8) + 3;
        // OS aynadır: aynı köşede farklı saat yazar.
        const etiket = goz === 2 ? saatler[(12 - i) % 12] : s;
        return <text key={i} x={x} y={y}>{etiket}</text>;
      })}
    </g>
  );
}

function FundusZemini({ goz }: { goz: number }) {
  // Disk nazalde: OD'de sağ, OS'de sol. Makula karşı tarafta.
  const diskX = goz === 2 ? 106 : 214;
  const makulaX = goz === 2 ? 208 : 112;
  const yon = goz === 2 ? -1 : 1;
  const ark = (dy: number, uzun: number) =>
    `M${diskX} ${160 + dy} C ${diskX - 18 * yon} ${160 + dy * 3}, `
    + `${diskX - 64 * yon} ${160 + dy * 5}, ${diskX - 118 * yon} ${160 + uzun}`;
  return (
    <>
      <circle cx="160" cy="160" r="150" fill="#fdf1ec" stroke="#cdd6e0" strokeWidth="1.5" />
      <circle cx="160" cy="160" r="100" fill="none" stroke="#e6d3cb" strokeDasharray="3 4" />
      <circle cx="160" cy="160" r="50" fill="none" stroke="#e6d3cb" strokeDasharray="3 4" />
      <SaatKadrani goz={goz} />
      <g fill="none" stroke="#c0564a" strokeWidth="2.4" strokeLinecap="round">
        <path d={ark(0, -74)} /><path d={ark(0, 74)} />
        <path d={ark(-8, -42)} /><path d={ark(8, 42)} />
      </g>
      <g fill="none" stroke="#7f95c4" strokeWidth="2" strokeLinecap="round">
        <path d={ark(-6, -84)} /><path d={ark(6, 84)} />
      </g>
      <circle cx={diskX} cy="160" r="26" fill="#fcefd8" stroke="#c9a96b" strokeWidth="1.5" />
      <ellipse cx={diskX} cy="160" rx="14" ry="15" fill="#f6dfae" stroke="#c9a96b" />
      <circle cx={makulaX} cy="160" r="26" fill="none" stroke="#d8bfb2" strokeDasharray="2 3" />
      <circle cx={makulaX} cy="160" r="4" fill="#a9705c" />
      <text x={makulaX} y="204" fontSize="9" fill="#8a7f79" textAnchor="middle">makula</text>
      <text x={diskX} y="204" fontSize="9" fill="#8a6218" textAnchor="middle">disk</text>
    </>
  );
}

/**
 * PERİFERİ: retina çevresi saat kadranı olarak açılır — dekolman ve yırtık
 * hep "saat kaçta, kaç kadranda" diye konuşulur. Merkez arka kutup, dış
 * halka ora serrata.
 */
function PeriferiZemini({ goz }: { goz: number }) {
  const dilim = [...Array(12).keys()];
  return (
    <>
      <circle cx="160" cy="160" r="150" fill="#fdf7f4" stroke="#cdd6e0" strokeWidth="1.5" />
      <circle cx="160" cy="160" r="112" fill="#fdf1ec" stroke="#e6d3cb" />
      <circle cx="160" cy="160" r="66" fill="#fff" stroke="#e6d3cb" />
      <circle cx="160" cy="160" r="22" fill="#f6dfae" stroke="#c9a96b" />
      {dilim.map(i => {
        const aci = ((i * 30 - 90) * Math.PI) / 180;
        return (
          <line key={i} x1={160 + Math.cos(aci) * 22} y1={160 + Math.sin(aci) * 22}
                x2={160 + Math.cos(aci) * 150} y2={160 + Math.sin(aci) * 150}
                stroke="#e6d3cb" />
        );
      })}
      <SaatKadrani goz={goz} />
      <text x="160" y="196" fontSize="9" fill="#8a7f79" textAnchor="middle">arka kutup</text>
      <text x="160" y="284" fontSize="9" fill="#8a97a5" textAnchor="middle">ora serrata</text>
    </>
  );
}

/** ÖN SEGMENT: önden bakış — kapak aralığı, limbus, iris, pupil. */
function OnSegmentZemini() {
  return (
    <>
      <rect x="10" y="10" width="300" height="300" rx="6" fill="#fbfcfe" stroke="#cdd6e0" />
      {/* kapak aralığı (badem) */}
      <path d="M30 160 Q160 40 290 160 Q160 280 30 160 Z"
            fill="#fff" stroke="#b9c6d4" strokeWidth="1.6" />
      {/* limbus + iris + pupil */}
      <circle cx="160" cy="160" r="86" fill="#f4f8fc" stroke="#9fb6d4" strokeWidth="1.4" />
      <circle cx="160" cy="160" r="60" fill="#dfeaf6" stroke="#7f95c4" />
      <circle cx="160" cy="160" r="24" fill="#2b3946" />
      <text x="160" y="66" fontSize="9" fill="#8a97a5" textAnchor="middle">üst kapak</text>
      <text x="160" y="266" fontSize="9" fill="#8a97a5" textAnchor="middle">alt kapak</text>
      <text x="58" y="160" fontSize="9" fill="#8a97a5" textAnchor="middle">nazal</text>
      <text x="266" y="160" fontSize="9" fill="#8a97a5" textAnchor="middle">temporal</text>
      <text x="160" y="118" fontSize="9" fill="#7f95c4" textAnchor="middle">limbus</text>
    </>
  );
}

/** KAPAK / ADNEKS: kapak kenarı, punktum ve lakrimal bölge. */
function KapakZemini() {
  return (
    <>
      <rect x="10" y="10" width="300" height="300" rx="6" fill="#fbfcfe" stroke="#cdd6e0" />
      <path d="M26 170 Q160 54 294 170" fill="none" stroke="#b9c6d4" strokeWidth="2" />
      <path d="M26 170 Q160 286 294 170" fill="none" stroke="#b9c6d4" strokeWidth="2" />
      <path d="M26 170 Q160 54 294 170 Q160 286 26 170 Z" fill="#fff" opacity=".6" />
      {/* kirpik sırası */}
      <g stroke="#9aa8b6" strokeWidth="1.2">
        {[...Array(14).keys()].map(i => {
          const x = 44 + i * 18;
          const y = 170 - Math.sin(((x - 26) / 268) * Math.PI) * 108;
          return <line key={i} x1={x} y1={y} x2={x} y2={y - 12} />;
        })}
      </g>
      <circle cx="160" cy="170" r="52" fill="#dfeaf6" stroke="#7f95c4" />
      <circle cx="160" cy="170" r="20" fill="#2b3946" />
      {/* lakrimal bölge (nazal köşe) */}
      <circle cx="40" cy="170" r="12" fill="#fdf1ec" stroke="#c0564a" strokeDasharray="2 3" />
      <text x="40" y="200" fontSize="9" fill="#8a7f79" textAnchor="middle">punktum</text>
      <text x="160" y="76" fontSize="9" fill="#8a97a5" textAnchor="middle">üst kapak kenarı</text>
      <text x="160" y="278" fontSize="9" fill="#8a97a5" textAnchor="middle">alt kapak kenarı</text>
    </>
  );
}
