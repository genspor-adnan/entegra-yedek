/**
 * USB ÇİP İKONU (kullanıcı 17.11.2026: "e-İmzala ... ikonu usb çip olsun"): e-imza token'ı - USB gövdesi + altın çip.
 * Düğme metniyle aynı hizada, renkli (pasif düğmede opaklığı düğme verir).
 */
export function UsbCipIkon({ boyut = 16 }: { boyut?: number }) {
  return (
    <svg viewBox="0 0 24 24" width={boyut} height={boyut} aria-hidden="true" style={{ verticalAlign: '-3px', flex: 'none' }}>
      {/* USB konnektörü */}
      <rect x="8" y="1.5" width="8" height="5.5" rx="0.8" fill="#c9d1db" stroke="#7a8796" strokeWidth="0.8" />
      <rect x="9.6" y="3" width="1.6" height="1.6" fill="#7a8796" />
      <rect x="12.8" y="3" width="1.6" height="1.6" fill="#7a8796" />
      {/* gövde */}
      <rect x="5.5" y="6.5" width="13" height="16" rx="2.2" fill="#2463b0" />
      {/* çip */}
      <rect x="8.5" y="10" width="7" height="7" rx="1" fill="#e5b842" stroke="#a87d16" strokeWidth="0.6" />
      <path d="M12 10v7M8.5 13.5h7M10.2 10v1.6M13.8 10v1.6M10.2 15.4V17M13.8 15.4V17" stroke="#a87d16" strokeWidth="0.6" />
    </svg>
  );
}
