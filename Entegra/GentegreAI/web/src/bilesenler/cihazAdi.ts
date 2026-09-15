/**
 * "Mozilla/5.0 (Windows NT 10.0…) … Chrome/…" → "Chrome · Windows".
 *
 * Iki ekran kullaniyor: Kullanici Ayarlari > Guvenlik (kisinin kendi cihazlari)
 * ve Kullanici karti > Guvenlik (yoneticinin gordugu cihazlar) - ham
 * user-agent metnini tabloya basmak satiri okunmaz yapiyordu.
 */
export function cihazAdi(istemci: string): string {
  if (!istemci) return 'Bilinmeyen cihaz';
  const tarayici = /Edg\//.test(istemci) ? 'Edge'
    : /Chrome\//.test(istemci) ? 'Chrome'
    : /Firefox\//.test(istemci) ? 'Firefox'
    : /Safari\//.test(istemci) ? 'Safari'
    : /curl/i.test(istemci) ? 'curl' : 'Tarayıcı';
  const isletim = /Android/.test(istemci) ? 'Android'
    : /iPhone|iPad/.test(istemci) ? 'iOS'
    : /Windows/.test(istemci) ? 'Windows'
    : /Mac OS/.test(istemci) ? 'macOS'
    : /Linux/.test(istemci) ? 'Linux' : '';
  return isletim ? `${tarayici} · ${isletim}` : tarayici;
}
