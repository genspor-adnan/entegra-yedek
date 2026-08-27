/**
 * Ulke bayragi - SVG.
 *
 * Neden emoji degil: Windows'ta bayrak emojisi (bolgesel gosterge cifti) icin
 * font YOK; tarayici onu harf cifti olarak cizer - kullanici "TR", "GB", "DE"
 * yazisi goruyordu. SVG her isletim sisteminde ayni gorunur.
 */
export function Bayrak({ dil, boy = 16 }: { dil: number; boy?: number }) {
  const en = boy;
  const yuk = Math.round(boy * 0.7);
  const ortak = {
    width: en, height: yuk, viewBox: '0 0 30 21',
    style: { borderRadius: 2, display: 'block', flex: 'none' as const },
  };

  // 0 TR / 1 EN (Birlesik Krallik) / 2 DE - db/081: taraf_kullanici.dil
  if (dil === 1) {
    return (
      <svg {...ortak} aria-hidden="true">
        <rect width="30" height="21" fill="#012169" />
        <path d="M0 0l30 21M30 0L0 21" stroke="#fff" strokeWidth="4" />
        <path d="M0 0l30 21M30 0L0 21" stroke="#C8102E" strokeWidth="2" />
        <path d="M15 0v21M0 10.5h30" stroke="#fff" strokeWidth="7" />
        <path d="M15 0v21M0 10.5h30" stroke="#C8102E" strokeWidth="4" />
      </svg>
    );
  }
  if (dil === 2) {
    return (
      <svg {...ortak} aria-hidden="true">
        <rect width="30" height="7" y="0" fill="#000" />
        <rect width="30" height="7" y="7" fill="#DD0000" />
        <rect width="30" height="7" y="14" fill="#FFCE00" />
      </svg>
    );
  }
  return (
    <svg {...ortak} aria-hidden="true">
      <rect width="30" height="21" fill="#E30A17" />
      <circle cx="12" cy="10.5" r="5" fill="#fff" />
      <circle cx="13.6" cy="10.5" r="4" fill="#E30A17" />
      <path d="M18.4 10.5l3.4-1.1-2.1 2.9V8.7l2.1 2.9z" fill="#fff" />
    </svg>
  );
}
