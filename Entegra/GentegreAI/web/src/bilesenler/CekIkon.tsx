/**
 * ÇEK İKONU (kullanıcı 26.10.2026: "çek listesi ikonu değiş çek resmi yap"): emoji setinde çek yok - açık yeşil
 * kağıt, üstte banka satırı, sağda tutar kutusu, altta imza. Menüde `@cek` (MenuIkon); EkstreIkon gibi bağımsız dosya.
 */
export function CekIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true"
         style={{ verticalAlign: '-3px', flex: 'none' }}>
      <rect x="1" y="5" width="22" height="14" rx="2" fill="#e9f6ec" stroke="#2e7d46" strokeWidth="1.6" />
      <line x1="4" y1="9" x2="11" y2="9" stroke="#2e7d46" strokeWidth="1.8" strokeLinecap="round" />
      <rect x="14.5" y="7.6" width="6" height="3.2" rx="0.6" fill="#2e7d46" />
      <line x1="4" y1="15.5" x2="10" y2="15.5" stroke="#2e7d46" strokeWidth="1.2" strokeLinecap="round" />
      <path d="M13 16 q1.3 -2.6 2.6 0 t2.6 0 t2.3 -0.6" fill="none" stroke="#2e7d46" strokeWidth="1.4" strokeLinecap="round" />
    </svg>
  );
}
