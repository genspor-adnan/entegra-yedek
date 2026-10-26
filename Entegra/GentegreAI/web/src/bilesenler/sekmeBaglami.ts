import { createContext } from 'react';

/**
 * EKRAN SEKMESİ GÖRÜNÜR MÜ (ana ekran v3, mockup Ekranlar/Ayarlar/ana_ekran_sekmeli_v3.html).
 *
 * Açık ekranlar sekmede CANLI tutulur (dönünce kaldığı yerde). Gizli sekmenin
 * penceresi (kart Modal'ı body'ye portal ile çizilir) aktif sekmenin üstünde
 * görünmemeli ve Esc'e tepki vermemeli - Modal ve useEscIleKapat bunu okur.
 * Sekmesiz çalışan her yerde varsayılan `true`: davranış değişmez.
 */
export const SekmeGorunurBaglami = createContext(true);

/**
 * İÇİNDE BULUNULAN EKRAN SEKMESİ: ekran kendi sekmesini kapatabilir (ör. "Yeni Hasta
 * Kartı" sekmesinde Kaydet -> sekme kapanır, listeye dönülür). Sekmeler kapalıyken null.
 */
export const EkranSekmesiBaglami = createContext<{
  kapat(hedef?: string): void;
  /** Kart aç - aynı kart sekmesindeki kart kayıtsız değişiklikliyse açmaz, onu öne alır. */
  kartaGit(yol: string): void;
  baslik(ad: string, yol: string): void;
  /**
   * Sekmenin × / Alt+W'si ekranın KENDİ Kapat'ını çağırsın (kayıtsız değişiklik sorusu). null = kaldır.
   * `kirli`: kart sekmesinde kayıtsız değişiklik var mı - varken aynı sekmede başka kart açılmaz.
   */
  kapatmaIsleyicisi(f: (() => void) | null, kirli?: () => boolean): void;
} | null>(null);

/** Bir listenin kayıtları değişti (başka sekmeden): liste tazelenir. detail = kaynak. */
export const LISTE_TAZELE_OLAYI = 'gentegre-liste-tazele';

/**
 * SEKME BAŞLIĞINDA AD (kullanıcı 24.10.2026: "müşteri, tedarikçi, hasta, başvuru, kurum, dış doktor,
 * kişi vb. sekme kartı açıldığında başlığa ünvanı / ad soyadından ilk 2 kelimeyi yaz"): uzun ünvan
 * sekmeyi kesiyordu. Yalnız ad / ünvan kısaltılır; belge no, kod gibi başlıklar olduğu gibi kalır.
 */
export const sekmeAdi = (ad: string) => ad.trim().split(/\s+/).filter(Boolean).slice(0, 2).join(' ');

/**
 * EKSTRE SEKMESİ KİMLİĞİ (kullanıcı 26.10.2026: "ekstre sekme başlıkta cari/kasa... adın ilk 2 kelimesi
 * yazsın ve 3 sekmeye kadar izin verilmeli", "carinin zaten açık ekstresi varsa ona konumlanmalı tekrar
 * açmamalı"): hesapla açılan ekstre (`/ekstre?tur=..&id=..`) hesabın kendi sekmesidir. Cari taraf, öteki
 * türler hesap tablosundandır - 'hesap' türü sunucuda kasa / banka ... diye çözülse de kimlik aynı kalır.
 * Hesapsız ekstre (menü / komut araması) '' - tek, genel Ekstre sekmesi.
 */
export function ekstreKimligi(k: { pathname: string; search: string }): string {
  if (k.pathname !== '/ekstre') return '';
  const q = new URLSearchParams(k.search);
  const id = Number(q.get('id') ?? 0);
  const tur = q.get('tur') || 'cari';
  return id > 0 ? `${tur === 'cari' ? 'c' : 'h'}:${id}` : '';
}
/**
 * YENİ KAYIT YUVASI ADRESİ: '/…/yeni' kartı ön değerleriyle (ör. /kasa-islem/yeni?tur=22&tarafId=5) ayrı kayıttır -
 * iki müşteriye açılan iki tahsilat aynı sekmeye düşüp birinin yerine geçmesin. Kayıtlı kart yalnız adresiyle.
 */
export const yuvaYolu = (k: { pathname: string; search?: string }) =>
  k.pathname.endsWith('/yeni') ? k.pathname + (k.search ?? '') : k.pathname;
/** Ekranın verdiği sekme başlığının anahtarı: adres; hesaplı ekstrede adres + hesap (hepsi /ekstre). */
export const baslikAnahtari = (k: { pathname: string; search: string }) => {
  const e = ekstreKimligi(k);
  return e ? `/ekstre?${e}` : yuvaYolu(k);
};
