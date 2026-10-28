/**
 * ERLENMAYER İKONU (kullanıcı 27.10.2026: "Laboratuvar İstemi Listesi ... ikonu erlenmayer flask olsun"): emoji seti
 * erlenmeyer taşımıyor (🧪 tüp, ⚗️ imbik) - konik şişe, içinde mavi sıvı. `@erlen` (MenuIkon) ile menüde ve sekmede.
 */
export function ErlenmeyerIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true" style={{ verticalAlign: '-3px', flex: 'none' }}>
      {/* sıvı */}
      <path d="M7.2 14.5h9.6l3 5.3c.4.7-.1 1.7-1 1.7H5.2c-.9 0-1.4-1-1-1.7z" fill="#4a90d9" />
      <circle cx="10.5" cy="17.8" r=".9" fill="#d6e9fb" />
      <circle cx="13.6" cy="16.6" r=".6" fill="#d6e9fb" />
      {/* cam gövde: dar boyun, konik alt */}
      <path d="M9.5 2.8h5M10.2 2.8v6.1L4.2 19.8c-.4.7.1 1.7 1 1.7h13.6c.9 0 1.4-1 1-1.7l-6-10.9V2.8"
            fill="none" stroke="#2f5d8a" strokeWidth="1.5" strokeLinejoin="round" strokeLinecap="round" />
    </svg>
  );
}
