import { useSyncExternalStore } from 'react';

/**
 * AÇIK EKRANIN KOMUTLARI (790) — komut paleti bunları "Bu ekranda" başlığı
 * altında gösterir.
 *
 * <b>Neden bir depo:</b> palet artık KABUKTA duruyor (her sayfada aynı yerden
 * açılıyor), aksiyonlar ise ekranın kendi kataloğundan geliyor. Paleti
 * GenGrid'in içinde bırakmak, onu yalnız liste ekranlarında çalışır kılıyordu:
 * kartta, panoda ya da özel sayfada Ctrl+K hiçbir şey açmıyordu.
 *
 * Tek yönlü ve minik (`aiBaglam` deseni): ekran yazar, palet okur. Ekran
 * kapanırken kendi yazdığını temizler - kapanmış ekranın düğmesi palette
 * kalırsa, çalıştırıldığında hiçbir şeye dokunmaz.
 */
export interface PaletKomutu {
  kod: string;
  ad: string;
  grup: string;
  kisayol?: string;
  aktif: boolean;
  pasifSebep?: string;
}

interface Kaynak {
  /** Aksiyon ekranı kodu; temizlerken "benim yazdığım mı" kontrolü için. */
  ekran: string;
  komutlar: PaletKomutu[];
  calistir(kod: string): void;
}

let kaynak: Kaynak | null = null;
const dinleyiciler = new Set<() => void>();

const duyur = () => dinleyiciler.forEach(d => d());

export function paletKomutlariAyarla(yeni: Kaynak) {
  kaynak = yeni;
  duyur();
}

/**
 * Ekran kapanırken çağrılır. EKRAN ADI sorulur: iki ekran art arda açılırken
 * (liste -> kart) eskisinin temizliği yenisinin komutlarını silmemeli.
 */
export function paletKomutlariTemizle(ekran: string) {
  if (kaynak?.ekran !== ekran) return;
  kaynak = null;
  duyur();
}

function abone(d: () => void) {
  dinleyiciler.add(d);
  return () => { dinleyiciler.delete(d) };
}

export function usePaletKomutlari(): Kaynak | null {
  return useSyncExternalStore(abone, () => kaynak, () => null);
}
