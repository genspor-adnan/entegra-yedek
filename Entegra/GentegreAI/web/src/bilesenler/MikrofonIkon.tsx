/**
 * MİKROFON SİMGESİ (kullanıcı 19.10.2026: "mic değişsin google gibi olsun"): arama kutularındaki
 * sesle arama düğmesi - dört renkli kapsül mikrofon (mavi gövde, kırmızı / sarı yay, yeşil ayak).
 * Emoji (🎤) her sistemde farklı çiziliyordu; SVG her yerde aynı.
 */
export function MikrofonIkon({ boyut = 18 }: { boyut?: number }) {
  return (
    <svg width={boyut} height={boyut} viewBox="0 0 24 24" aria-hidden="true" focusable="false">
      <rect x="8.5" y="2" width="7" height="12.5" rx="3.5" fill="#4285F4" />
      <path d="M5.5 10.5a6.5 6.5 0 0 0 6.5 6.5" fill="none" stroke="#EA4335" strokeWidth="2" strokeLinecap="round" />
      <path d="M18.5 10.5a6.5 6.5 0 0 1-6.5 6.5" fill="none" stroke="#FBBC04" strokeWidth="2" strokeLinecap="round" />
      <path d="M12 17v4.5M9 21.5h6" fill="none" stroke="#34A853" strokeWidth="2" strokeLinecap="round" />
    </svg>
  );
}
