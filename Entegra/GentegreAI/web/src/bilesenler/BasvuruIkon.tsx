/**
 * BAŞVURU İKONU (kullanıcı 27.10.2026: "başvuru menü ikonu için arka zemin mavi içi beyaz H harfi olsun"):
 * mavi kare üstünde beyaz H - EkstreIkon'un Σ'sı ile aynı çizim dili (düz renk zemin, kalın çizgi harf).
 * `@basvuru` (MenuIkon) ile menüde ve sekmede kullanılır.
 */
export function BasvuruIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true"
         style={{ verticalAlign: '-3px', flex: 'none' }}>
      <rect x="0.5" y="0.5" width="23" height="23" rx="5" fill="#2463b0" />
      <path d="M7 5.5v13M17 5.5v13M7 12h10" fill="none" stroke="#fff" strokeWidth="3.2" strokeLinecap="square" />
    </svg>
  );
}
