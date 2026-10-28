/**
 * RADYOLOJİ RAPORU BİÇİMİ - TEK PARÇA (kullanıcı 27.10.2026). Tek parça rapor `radyoloji_rapor_bolum`'da
 * başlığı TEK_BASLIK olan TEK satırdır; yazma ekranı (RadyolojiRapor) onu A4 metin olarak açar, çıktı
 * (RadyolojiRaporCikti) başlığı basmaz. Eski programdan aktarılan raporlar da bu biçimde yazılmalı
 * (tek satır, baslik = 'Rapor') - ekranda kendiliğinden Tek modda açılırlar.
 */
import { cinsiyetAdi } from '../../bilesenler/kisiKodlari';

export const TEK_BASLIK = 'Rapor';

/** Bölüm listesi tek parça rapor mu (tek satır, başlık TEK_BASLIK). */
export const tekParcaMi = (b: { baslik?: unknown }[]) => b.length === 1 && String(b[0].baslik ?? '') === TEK_BASLIK;

/**
 * ŞABLON YER TUTUCULARI (kullanıcı 27.10.2026: "{istem.on_tani} hatasını düzelt"): şablon bölümü / makro
 * metnindeki yer tutucular istemle doldurulur - şablon kartında belgelenmişti ama uygulanmıyordu, metne
 * "{istem.on_tani}" olduğu gibi düşüyordu. Bilinmeyen yer tutucu olduğu gibi kalır (şablonu yazan fark etsin).
 *   {istem.on_tani}  ön tanı          {istem.sikayet} / {istem.klinik_bilgi}  istemin klinik bilgisi
 *   {hasta.yas}      yaş ("41")       {hasta.cinsiyet}                        Erkek / Kadın
 */
export function yerTutucuDoldur(metin: string, istem: Record<string, unknown> | null): string {
  if (!metin.includes('{')) return metin;
  const d = istem?.dogumTarihi ? new Date(String(istem.dogumTarihi)) : null;
  const yas = d && !Number.isNaN(d.getTime()) ? String(Math.floor((Date.now() - d.getTime()) / 31557600000)) : '';
  const deger: Record<string, string> = {
    'istem.on_tani': String(istem?.onTani ?? '').trim(),
    'istem.sikayet': String(istem?.klinikBilgi ?? '').trim(),
    'istem.klinik_bilgi': String(istem?.klinikBilgi ?? '').trim(),
    'hasta.yas': yas,
    'hasta.cinsiyet': cinsiyetAdi(istem?.cinsiyet),
  };
  return metin.replace(/\{([a-z_]+\.[a-z_]+)\}/g, (tam, ad: string) => (ad in deger ? deger[ad] : tam));
}

/**
 * TEK PARÇA METİNDE BÖLÜM YAZ (BI-RADS "Rapora aktar", 1194): "BAŞLIK:" satırından bir sonraki büyük harfli
 * başlığa (ya da metin sonuna) kadar olan kısım yenisiyle değişir; başlık yoksa metnin sonuna eklenir.
 */
export function tekMetneBolumYaz(metin: string, baslik: string, yeni: string): string {
  const b = baslik.toLocaleUpperCase('tr');
  const kacisli = b.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const kalip = new RegExp(`(^|\\n)${kacisli}:\\n[\\s\\S]*?(?=\\n\\n[A-ZÇĞİÖŞÜ0-9 /]+:\\n|$)`);
  if (kalip.test(metin)) return metin.replace(kalip, (_t, on: string) => `${on}${b}:\n${yeni}`);
  return `${metin.trimEnd()}${metin.trim() ? '\n\n' : ''}${b}:\n${yeni}`;
}

/** Bölüm başlığı BULGULAR / SONUÇ mu (yapısal metnin yazıldığı bölümler). */
export const bulguBolumuMu = (baslik: string) => baslik.toLocaleLowerCase('tr').includes('bulgu');
export const sonucBolumuMu = (baslik: string) => /sonu[çc]/.test(baslik.toLocaleLowerCase('tr'));
