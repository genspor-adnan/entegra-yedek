/**
 * BELGE İKONLARI (kullanıcı 26.10.2026: "belge kopyalanın ikonu kopya resmi yap.. satış fat ikonu da hem burada hem
 * menüde değiş"): emoji setinde fatura ve kopya yok (🧾 fişle aynıydı). CekIkon deseni - bağımsız SVG; menüde
 * `@fatura` (MenuIkon).
 */
const STIL = { verticalAlign: '-3px', flex: 'none' } as const;

/** Fatura: köşesi kıvrık mavi sayfa, başlık satırı, kalem çizgileri, sağ altta ₺ rozeti. */
export function FaturaIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true" style={STIL}>
      <path d="M5 2.5h10l4 4v15H5z" fill="#eaf2fc" stroke="#2b579a" strokeWidth="1.5" strokeLinejoin="round" />
      <path d="M15 2.5v4h4" fill="#cfe0f5" stroke="#2b579a" strokeWidth="1.3" strokeLinejoin="round" />
      <line x1="8" y1="8" x2="12.5" y2="8" stroke="#2b579a" strokeWidth="1.6" strokeLinecap="round" />
      <line x1="8" y1="11.5" x2="16" y2="11.5" stroke="#2b579a" strokeWidth="1.1" strokeLinecap="round" />
      <line x1="8" y1="14" x2="16" y2="14" stroke="#2b579a" strokeWidth="1.1" strokeLinecap="round" />
      <circle cx="16.5" cy="18.3" r="3.6" fill="#2b579a" />
      <text x="16.5" y="20.4" textAnchor="middle" fontSize="5.6" fontWeight="700" fontFamily="Arial, sans-serif" fill="#fff">₺</text>
    </svg>
  );
}

/** Kopya: üst üste iki sayfa - arkadaki gri, öndeki mavi çerçeveli. */
export function KopyaIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true" style={STIL}>
      <rect x="3" y="2.5" width="12" height="15" rx="1.6" fill="#f1f4f8" stroke="#7d8b99" strokeWidth="1.4" />
      <rect x="8.5" y="6.5" width="12" height="15" rx="1.6" fill="#fff" stroke="#2b579a" strokeWidth="1.6" />
      <line x1="11.5" y1="11" x2="17.5" y2="11" stroke="#2b579a" strokeWidth="1.2" strokeLinecap="round" />
      <line x1="11.5" y1="14" x2="17.5" y2="14" stroke="#2b579a" strokeWidth="1.2" strokeLinecap="round" />
      <line x1="11.5" y1="17" x2="15.5" y2="17" stroke="#2b579a" strokeWidth="1.2" strokeLinecap="round" />
    </svg>
  );
}
